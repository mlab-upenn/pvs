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

function [] = set_rate(serialObj, SA_rest, AV_forw, PACen, PVCen, pace_en, pace_en_changed)
%set_rate - Changes parameters for VHM at runtime 
%
%   serialObj - serial handle to transmit config data on
%   SA_rest - SA rest time
%	AV_forw - AV path forward delay factor
%   
%   Serial configured to read off line at 115200 baud.
%	See companion Verilog file mode_setter.v to see byte ordering
%
%   bit order:
%   first 15-bits: SA_rest (little-endian)
%   next 1-bit: pace_en
%   next 14-bits: AV_forw (little-endian)
%   next 1-bit: PACen
%   next 1-bit: PVCen
%   total: 32-bits, 4 byte transmission
%% 

persistent SA_rest_def;
persistent AV_forw_def;
persistent pace_en_def;

if isempty(SA_rest_def)
    SA_rest_def = 700; % XXX KEEP IN SYNC WITH MODE_SETTER.V
end
if isempty(AV_forw_def)
    AV_forw_def = 200; % XXX KEEP IN SYNC WITH MODE_SETTER.V
end
if isempty(pace_en_def)
    pace_en_def = 1;    % XXX KEEP IN SYNC WITH MODE_SETTER.V
end

% You can only send an update to SA/AV or send a PAC or send a PVC in 
% one transmission. The other values will be held constant to their
% previous value. Same if pace_en toggle button is hit
if (PACen == 1 || PVCen == 1)
    SA_rest_per = uint32(SA_rest_def);
    pace_en_sig = bitshift(uint32(pace_en_def), 15);
    AV_forw_per = bitshift(uint32(AV_forw_def),16);
    PAC_en_sig = bitshift(uint32(PACen),30);
    PVC_en_sig = bitshift(uint32(PVCen),31);
elseif (pace_en_changed)
    SA_rest_per = uint32(SA_rest_def);
    pace_en_sig = bitshift(uint32(pace_en), 15);
    AV_forw_per = bitshift(uint32(AV_forw_def),16);
    PAC_en_sig = uint32(0);
    PVC_en_sig = uint32(0);
    pace_en_def = pace_en;
else
    SA_rest_per = uint32(SA_rest);
    pace_en_sig = bitshift(uint32(pace_en_def), 15);
    AV_forw_per = bitshift(uint32(AV_forw),16);
    PAC_en_sig = uint32(0);
    PVC_en_sig = uint32(0);
    SA_rest_def = SA_rest;
    AV_forw_def = AV_forw;
end

fprintf('send SA %d, AV %d, PAC %d, PVC %d, pace_en %d\n', SA_rest_per, ...
    AV_forw_per, PAC_en_sig, PVC_en_sig, pace_en_sig);
% byte order is little-endian, SA then pace_en then AV then PACen then PVCen
transmit = bitor(pace_en_sig, SA_rest_per);
transmit = bitor(AV_forw_per, transmit);
transmit = bitor(PAC_en_sig, transmit);
transmit = bitor(PVC_en_sig, transmit);
fwrite(serialObj, transmit, 'uint32');
