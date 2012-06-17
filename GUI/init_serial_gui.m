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

function init_serial_gui(serialObj,axisObj,handles)
%init_serial - Initializes serial interface and Timer function
%
%   com_port - COM port for serial interface
%   num_plots - number of different data streams
%   
%   Serial configured to read off line at 115200 baud. Timer function calls
%   draw_new_point every 0.001 seconds to retrieve data off serial and plot
%   it on appropriate plot (dependent on header byte)
%% 

%% setup timer object and callback function
timerObj = timer;
set(timerObj, 'Period', 0.1);
set(timerObj, 'executionMode', 'fixedRate');
set(timerObj, 'TimerFcn', {@draw_new_point_gui, axisObj, serialObj,handles, timerObj});

%% open the serial object and start the timer
start(timerObj);
