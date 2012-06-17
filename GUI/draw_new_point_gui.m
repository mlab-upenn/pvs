% Copyright 2012 Sriram Radhakrishnan, Varun Sampath, Shilpa Sarode
% 
% This file is part of PVS.
% 
% PVS is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
% 
% PVS is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
% PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with PVS.  If not, see <http://www.gnu.org/licenses/>.

function [ ] = draw_new_point(obj, event, axisObj, serialObj,handles, timerObj)
%draw_new_point - Timer callback function that obtains & plots new point
%from serial
%   Data froms serialObj consists of a 1-byte header and a 4-byte
%   unsigned little endian body that holds a timer value. The header tells
%   what event that counter value is being transmitted for.
%
%   obj and event parameters are required for timer callbacks and simply
%   not used.
%
%   Header values:
%   0 - bad value
%   1 - SA node activation and no APace
%   2 - no SA node activation and APace
%   3 - SA node activation and APace
%   4 - RV node activation and no VPace
%   5 - no RV node activation and VPace
%   6 - RV node activation and VPace

global enableBeat;
global HBsound;
global ErrorSound;

persistent old_SA;
persistent old_AP;
persistent old_RV;
persistent old_VP;

persistent pulses;
persistent iterations;

persistent SA_diff;
persistent AP_diff;
persistent RV_diff;
persistent VP_diff;

persistent ecg_plot;
persistent sa_plot;
persistent rv_plot;
persistent a_plot;
persistent v_plot;

global flush;
persistent isRed;
persistent lastWave;
persistent isAlertMode;

% lastWave values:
% 0 - p
% 1 - qrst

%Axis Values
persistent x;
persistent tix;
persistent ecg_sig;
persistent sa_sig;
persistent rv_sig;
persistent apace_sig;
persistent vpace_sig;

persistent last_clock;


if isempty(SA_diff)
    SA_diff = 0;
end
if isempty(AP_diff)
    AP_diff = 0;
end
if isempty(RV_diff)
    RV_diff = 0;
end
if isempty(VP_diff)
    VP_diff = 0;
end
if isempty(enableBeat)
    enableBeat = 0;
end
if isempty(isRed)
    isRed = 0;
end
if isempty(lastWave)
    lastWave = 0;
end
if isempty(pulses)
    pulses = 0;
end


%% Constants
DEBUG = 1;
NUM_ITER_PER_FLASH = 4;


%% Position Constants
ylims = [0 15];
apzero = 5.85;
vpzero = 1;
pulselen = 2.5;

if enableBeat
    ecgzero = 11.75;
else
    ecgzero = 11;
end



%% Build PQRST Wave
beat = 3*ecg(400);
p_per = 0.205;
q_per_start = 0.295;
q_per_end = 0.815;

p = beat(1:round(p_per*length(beat)));
qrst = beat(round(q_per_start*length(beat)):(round(q_per_end*length(beat))));

origp = sgolayfilt(p,0,5);
origqrst = sgolayfilt(qrst,0,5);

p = origp + ecgzero;
qrst = origqrst + ecgzero;

%% Initializations
fpgaclk = 1.500; % clock rate is 1.5kHz
dt = 1/fpgaclk; %cache bucket size
c = clock;
c = c(6)*1000 + c(5)*60*1000 + c(4)*60*60*1000 + c(3)*24*60*60*1000;
% 
cacheSize = 7000; %including extra
plotSize = 5000; %plot area
% 
% %get serial value if bytes are availble
if serialObj.BytesAvailable || flush
    header = fread(serialObj, 1, 'uint8');
    val = fread(serialObj, 1, 'uint32');
    millisec = val/fpgaclk; %input ms value
    serialRead = 1;
else
    serialRead = 0;
end

shift = 0;

x = 0:dt:cacheSize*dt-dt;

%% Axis Calculations
if flush
    flush = 0;
%     x = ((millisec-((plotSize-1)*dt)):dt:(millisec+dt*(cacheSize-plotSize)));
    tix = (val-(plotSize-1):(val+(cacheSize-plotSize)));
    ecg_sig = ecgzero*ones(1,cacheSize);
    sa_sig = ecgzero*ones(1,cacheSize);
    rv_sig = ecgzero*ones(1,cacheSize);
    apace_sig = apzero*ones(1,cacheSize);
    vpace_sig = vpzero*ones(1,cacheSize);
    isAlertMode = 0;
    iterations = 0;

    hold(axisObj(1), 'off');

    % Initialize plots
    try
    if enableBeat
        ecg_plot = plot(axisObj(1), x(1:plotSize), ecg_sig(1:plotSize),...
            'Color', [0 1 0],'LineWidth', 1);
    else
        sa_plot = plot(axisObj(1), x(1:plotSize), sa_sig(1:plotSize),...
            'Color', [256 170 191]/256,'LineWidth', 3);
        hold(axisObj(1), 'on');
        rv_plot = plot(axisObj(1), x(1:plotSize), rv_sig(1:plotSize),...
            'Color', [0 1 0], 'LineWidth', 3);
    end
    hold(axisObj(1), 'on');

    a_plot = plot(axisObj(1),x(1:plotSize),apace_sig(1:plotSize), ...
        'Color', 'y', 'LineWidth', 3);
    v_plot = plot(axisObj(1),x(1:plotSize),vpace_sig(1:plotSize), ...
        'Color', 'c', 'LineWidth', 3);
    
    catch err
        disp('failed in plot init');
        flush = 1;
    end
    
    set(axisObj(1), 'Color', 'k','YLim', ylims, 'XGrid', 'on', ...
        'YTick', [], 'XTick', [0:300:dt*plotSize-dt], ...
        'XColor', [0.7 0.7 0.7]);
    
    xlabel(axisObj(1), 'Time (ms)');
    
else
    
    % Compute Shift Amount
%     disp(sprintf('diff:%d',(c-last_clock)));
    shift = ceil((c - last_clock)*1.5);
    
    tix = [tix((shift+1):end) (tix(end)+1):(tix(end)+shift)];
    ecg_sig = [ecg_sig(shift+1:cacheSize) ecgzero*ones(1,shift)];
    sa_sig = [sa_sig(shift+1:cacheSize) ecgzero*ones(1,shift)];
    rv_sig = [rv_sig(shift+1:cacheSize) ecgzero*ones(1,shift)];
    apace_sig = [apace_sig(shift+1:cacheSize) apzero*ones(1,shift)];
    vpace_sig = [vpace_sig(shift+1:cacheSize) vpzero*ones(1,shift)];
end

last_clock = c;


if serialRead
    
    %% SA pulse handling
    if header == 1 || header == 3
        SA_diff = val - old_SA;
        old_SA = val;
        
        if DEBUG
            print_string = sprintf('SA pulse at %d, diff: %d and shift: %d\n', val, SA_diff, shift);
            disp(print_string);
        end
        
        try
        sa_sig(tix == val) = ecgzero + pulselen;
        
        if enableBeat
            ecg_sig(find(tix==val):find(tix==val)+length(p)-1) = ...
                ecg_sig(find(tix==val):find(tix==val)+length(p)-1) + origp;

        end
        catch err
            disp('failed in SA');
%             disp(sprintf('numOnes=%d', sum(tix==val)));
            flush = 1;
        end
    end
    
    %% AP handling - plot orange lines on plot 2
    if header == 2 || header == 3
        AP_diff = val - old_AP;
        old_AP = val;
        
        
        if DEBUG
            print_string = sprintf('APace at %d, diff: %d\n', val, AP_diff);
            disp(print_string);
        end
        
        try
        apace_sig(tix == val) = apzero + pulselen;
        catch err
            disp('failed in AP');
            flush = 1;
        end
    end
    
    %% RV pulse handling - plot blue lines on plot 3
    if header == 4 || header == 6
        RV_diff = val - old_RV;
        old_RV = val;
        
        if DEBUG
            print_string = sprintf('RV pulse at %d, diff: %d, shift: %d\n', val, RV_diff, shift);
            disp(print_string);
        end
        
        try
        rv_sig(tix == val) = ecgzero + pulselen;
        
        if enableBeat
            ecg_sig(find(tix==val):find(tix==val)+length(qrst)-1) = ...
                ecg_sig(find(tix==val):find(tix==val)+length(qrst)-1) + origqrst;
        end
        catch err
            disp('failed in rv plot');
%             disp(sprintf('tix(end)=%d, val=%d', tix(end), val));
            flush = 1;
        end
        
        % border color routine
        if pulses >= 4
            BPM = round(60000*fpgaclk/RV_diff);
            set(handles.BPM, 'String', num2str(BPM));
            if (BPM <= handles.cThresh(1) || BPM >= handles.cThresh(2))
                isAlertMode = 1;
            else
                isAlertMode = 0;
                wavplay(HBsound, 44100, 'async');
            end
        end
        
    end
    
    %% VP handling - plot green lines on plot 4
    if header == 5 || header == 6
        VP_diff = val - old_VP;
        old_VP = val;
        
        if DEBUG
            print_string = sprintf('VPace at %d, diff: %d\n', val, VP_diff);
            disp(print_string);
        end
        try
        vpace_sig(tix == val) = vpzero + pulselen;
        catch err
            disp('error in vp plot');
            flush = 1;
        end
    end
    
    if header > 6 || header == 0
        print_string = sprintf('Header should not be %d. val: %d\n',header, val);
        disp(print_string);
        return;
    end
    
    pulses = pulses + 1; %increment for each pulse
    
end


%% Border Color Alert
if isAlertMode
    iterations = iterations + 1;
    if (iterations >= NUM_ITER_PER_FLASH)
        if ~isRed
            set(handles.figure1,'Color',[216 41 0]./256);
            isRed = 1;
%             wavplay(ErrorSound,44100,'async');
        else
            set(handles.figure1,'Color',[11 131 199]./256);
            isRed = 0;
%             wavplay(HBsound,44100,'async');
        end
        wavplay(ErrorSound,44100,'async');
        wavplay(HBsound,44100,'async');
        iterations = 0;
    end
else
    set(handles.figure1,'Color',[11 131 199]./256);
end

% tic;
% %% plot, update x-axis limits, and draw

try
if enableBeat
    %plot(axisObj(1), x(1:plotSize), ecg_sig(1:plotSize),...
    %    'Color', [0 1 0],'LineWidth', 2);
    set(ecg_plot,'YData',ecg_sig,'XData',x);
else
    %     plot(axisObj(1),x(1:plotSize), sa_sig(1:plotSize),...
    %         'Color',[0 1 0],'LineWidth', 4);
    %     hold(axisObj(1),'on');
    %     plot(axisObj(1),x(1:plotSize), rv_sig(1:plotSize),...
    %         'Color',[256 170 191]/256,'LineWidth', 4)
    
    set(sa_plot,'YData',sa_sig,'XData',x);
    set(rv_plot,'YData',rv_sig,'XData',x);
end


set(a_plot,'YData',apace_sig,'XData',x);
set(v_plot,'YData',vpace_sig,'XData',x);
catch err
    disp('failed in X/Y data set');
    flush = 1;
end
% titles = {'ECG','Atrial Pace','Ventricular Pace'};
% 
% for i=1:length(axisObj)
xlim(axisObj(1),[x(1) x(plotSize)]);
% xlim(axisObj(2),[x(1) x(plotSize)]);

% xlim(axisObj(3),[x(1) x(plotSize)]);

%     ylim(axisObj(i),[0 6]);
%     if i ~= length(axisObj)
%         set(axisObj(i),'xTick',[]);
%     end
%     title(axisObj(i),titles{i});
%     set(axisObj(i),'Color','k');
% end
% 
% xlabel(axisObj(length(axisObj)), 'Time (ms)');
% 
% %centers PQRST wave
% if enableBeat
%     ylim(axisObj(1), [floor(min(qrst)), ceil(max(qrst))]);
% end

drawnow;
% toc;
end

