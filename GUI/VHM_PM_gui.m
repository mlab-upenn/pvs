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

%% Figure and Axes

% get screen size (left, bottom, width, height)
screen = get(0,'MonitorPositions');
pad = 0.05;

% figure
f = figure('units','pixels',...
           'Position',[0 0 screen(3) screen(4)],...
           'Name','VHM-PM Interface',...
           'Resize','off',...
           'MenuBar','none');
       
% graph axes     
ax_width = (screen(3) - screen(3)*pad*3)/2;
ax_left = ax_width + screen(3)*pad*2;
ax_height = (screen(4) - screen(4)*pad*3)/2;
ax_bottom = ax_height + screen(4)*pad*2;
ax_sens = axes('ytick',[],...
         'xlim',[0 5000],...
         'ylim',[-3 3],...
         'units','pixels',...
         'Position',[ax_left ax_bottom ax_width ax_height]);
     
% ax_pace = axes('ytick',[],...
%          'xlim',[0 5000],...
%          'ylim',[-3 3],...
%          'units','pixels',...
%          'Position',[50 300 425 200]);

% image axes
ax_im = axes('units','pixels',...
             'Position',[screen(3)*pad ax_bottom ax_width ax_height]);

%% Heart Image

path = fullfile('C:','Users','medcps','Dropbox',...
    'VHM Testbed','Figures','heartabstr');
heart = imread(path,'png');
pic = imshow(heart,...
     'Parent',ax_im);
     
%% Control Buttons

