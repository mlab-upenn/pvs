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

% clear all
% % % close all
% % clc
% 
% function [node_name,path_names,node_param,path_param,pacemaker_defaults]=setup_case2none
%  load case2_brad_WB
% % % % % % % % % % % % load pacemaker
% % % % % % % % load type_1
for i=1:size(node_table,1)
    node_name{i}=sprintf('NA%d_%s',i,node_table{i,1});
end
node_param = zeros(size(node_table,1),8,'int16'); %TODO: made int16

Tclk_h = 1;

path_table(3,10) = {2000};path_table(3,11) = {2000};

node_param(:,2) = cast(round(cell2mat(node_table(:,4))/Tclk_h), 'int16');    %defining TERP_default
node_param(:,4) = cast(round(cell2mat(node_table(:,6))/Tclk_h), 'int16');     %defining TRRP_default
node_param(:,6) = cast(round(cell2mat(node_table(:,8))/Tclk_h), 'int16');     %defining Trest_default
node_param(:,1) = cast(round(cell2mat(node_table(:,3))/Tclk_h), 'int16');     %defining TERP_default
node_param(:,3) = cast(round(cell2mat(node_table(:,5))/Tclk_h), 'int16');     %defining TRRP_default
node_param(:,5) = cast(round(cell2mat(node_table(:,7))/Tclk_h), 'int16');     %defining Trest_default

node_param(:,7:8) = cast(round(cell2mat(node_table(:,10))/Tclk_h), 'int16');    %defining Trest_default
% % % % node_param(:,8) = round(cell2mat(node_table(:,7))/Tclk_h);    %defining Trest_default


path_param = zeros(size(node_table,1),size(node_table,1),7, 'int16');
path_names=[];
for ii=1:size(path_table,1)
    path_param(cell2mat(path_table(ii,3)),cell2mat(path_table(ii,4)),1:7)= cast([cell2mat(path_table(ii,8)) cell2mat(path_table(ii,9)) ...
                                                 cell2mat(path_table(ii,10)) cell2mat(path_table(ii,11)) min([cell2mat(path_table(ii,9)) ...
                                                 cell2mat(path_table(ii,11))]) round(cell2mat(path_table(ii,12))./cell2mat(path_table(ii,6))) ...
                                                 round(cell2mat(path_table(ii,12))./cell2mat(path_table(ii,7)))], 'int16');            
    path_names{ii}=sprintf('PA%d_%dto%d',ii,path_table{ii,3},path_table{ii,4});
end

path_param(2,4,7) = 3000;

pacemaker_defaults = cell2mat(pace_para(:,4));


% 'done'
% 
% break
% 
% ds=[(ScopeData1.signals(1).values) (ScopeData1.signals(2).values) (ScopeData1.signals(3).values) (ScopeData1.signals(4).values) (ScopeData1.signals(5).values)].';
% for ii=1:5, subplot(6,1,ii), hold on, stairs(ds(ii,:),'rx-'), grid on, end
% pm = (2*(ScopeData2.signals(1).values) -2*(ScopeData2.signals(2).values) +1*(ScopeData2.signals(3).values) -1*(ScopeData2.signals(4).values)).';
% subplot(6,1,6), hold on, stairs(pm(:),'rx-')
