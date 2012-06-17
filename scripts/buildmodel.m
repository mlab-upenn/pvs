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

function buildmodel(modelType, outputs, SARV, AVRV, generateHDL)

% Builds a heart model based on input parameters
% modelType is the name of the .mat file
% outputs: 1d array containing node numbers desired for outputs


%global a_ratio_table;
%evalin('base', 'global a_ratio_table;'); %adds the table to global ws

bdclose('all'); %closes any open Simulink windows


%% Choose Nodes/Path Models
node = 'SimpleModeling/NA_simple2';
path = 'SimpleModeling/PA_simple2';
PVC = 'SimpleModeling/PVC';
systempath = '../SimpleModels/';
library = strcat(systempath, 'SimpleModeling');


%% Model Setup
simulink;
open_system(library);
open_system(new_system(modelType));

hdlsetup(modelType);  %%%%%% keep this?  (most settings are changed anyway)

%Simulation Parameters
set_param(modelType,'StopTime','100000');
set_param(modelType,'Solver','FixedStepDiscrete');
set_param(modelType,'FixedStep','1');

%HDL Generation Parameters
set_param(modelType,'AlgebraicLoopMsg','error');
set_param(modelType,'InlineParams','on');
set_param(modelType,'SignalLogging','off');
set_param(modelType,'BlockReduction','off');
set_param(modelType,'ProdHWDeviceType','ASIC/FPGA->ASIC/FPGA');
set_param(modelType,'ConditionallyExecuteInputs','off');

%More HDL Generation Parameters
hdlset_param(modelType,'HDLSubsystem',modelType);
hdlset_param(modelType,'TargetLanguage','Verilog');

%Save HDL files to folders with curr date/time
t = clock';
folder = sprintf('hdlsrc_%d%d_%d%d/',t(2),t(3),t(4),t(5));
hdlset_param(modelType,'TargetDirectory',strcat(systempath, folder));


%Model Spacing Values
topMargin = 50;
nodeSpacing = 80;
pathSpacing = 100;
orTop = topMargin;
orSpacing = 50;
orIncrement = 25; %starting value
outputSpacing = 50;
scopeSpacing = 20;

%Gets SA and RV node indices from input
%%%%%%%% Put this info in the mat file itself???
SA = SARV(1);
RV = SARV(2);

PACPVCVal = {'210' '400'};

%% Load Model Data
%TODO %%%%%%%%%%%%%%%%%%%%%%%%%Make this generic%%%%%%%%%%%%%%%%%%%%%%
load(sprintf('%s.mat',modelType));
setup_case2none;


%% Node Assembly
for i=1:size(node_param,1) %iterates through node list
    
    % Add Node
    block_name=sprintf('%s/%s',modelType,node_name{i}); %node_name comes from the setup script
    add_block(node,block_name); %adds block to model canvas
    
    % Puts all nodes in first column, each shifted accordingly
    left_corner=[110,(topMargin + (i-1)* nodeSpacing)];
    set_param(block_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+115 left_corner(2)+50]);
    
    % Add output tag for active signal
    out_name=sprintf('%s/NA%d_out',modelType,i);
    add_block('Simulink/Signal Routing/Goto',out_name);
    set_param(out_name,'Position',[left_corner(1)+140 left_corner(2) left_corner(1)+215 left_corner(2)+15]);
    set_param(out_name,'ShowName','off');
    set_param(out_name,'GotoTag',sprintf('NA%d_out',i));
    add_line(modelType,sprintf('%s/1',node_name{i}),sprintf('NA%d_out/1',i));
    
    % Add output tag for path_timer signal
    out_name=sprintf('%s/NA%d_pt',modelType,i);
    add_block('Simulink/Signal Routing/Goto',out_name);
    set_param(out_name,'Position',[left_corner(1)+140 left_corner(2)+30 left_corner(1)+215 left_corner(2)+45]);
    set_param(out_name,'ShowName','off');
    set_param(out_name,'GotoTag',sprintf('NA%d_pt',i));
    add_line(modelType,sprintf('%s/3',node_name{i}),sprintf('NA%d_pt/1',i));
    
    % add inActive input tag
    in_name1=sprintf('%s/NA%d_in',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name1);
    set_param(in_name1,'Position',[left_corner(1)-90 left_corner(2)+5 left_corner(1)-20 left_corner(2)+20]);
    set_param(in_name1,'GotoTag',sprintf('NA%d_in',i));
    set_param(in_name1,'ShowName','off');
    add_line(modelType,sprintf('NA%d_in/1',i),sprintf('%s/1',node_name{i}));
    
    % add tRest_def input tag
    % adds a programmable input if SA, constant from model otherwise
    in_name2=sprintf('%s/NA%d_tRest',modelType,i);
    if i == SA
        add_block('Simulink/Signal Routing/From',in_name2);
        set_param(in_name2,'GotoTag','SA_rest');
    else
        add_block('Simulink/Sources/Constant',in_name2);
        set_param(in_name2,'Value',sprintf('%d',node_param(i,6)));
        set_param(in_name2,'OutDataTypeStr','uint16');
        
    end
    set_param(in_name2,'Position',[left_corner(1)-90 left_corner(2)+30 left_corner(1)-20 left_corner(2)+45]);
    set_param(in_name2,'ShowName','off');
    add_line(modelType,sprintf('NA%d_tRest/1',i),sprintf('%s/2',node_name{i}));
    
    
    %% Set Node Parameters
    set_param(block_name,'TERP_s_m',sprintf('%d',node_param(i,1)));
    set_param(block_name,'TERP_defs_m',sprintf('%d',node_param(i,2)));
    set_param(block_name,'TRRP_s_m',sprintf('%d',node_param(i,3)));
    set_param(block_name,'TRRP_def_m',sprintf('%d',node_param(i,4)));
    set_param(block_name,'Trest_s_m',sprintf('%d',node_param(i,5)));
    set_param(block_name,'Terp_min_m',sprintf('%d',node_param(i,7)));
    set_param(block_name,'Terp_max_m',sprintf('%d',node_param(i,8)));
    
    
    %% Node Connections
    
    % Get list of Node-Path connections
    [row,col]=find(cell2mat(path_table(:,3:4))==i);
    
    % Positioning
    left_corner=[900, orTop];
    
    % Add output tag
    tag_out=sprintf('%s/NA%d',modelType,path_table{row(1), col(1)+2});
    add_block('Simulink/Signal Routing/Goto',tag_out);
    set_param(tag_out,'GotoTag',sprintf('NA%d_in',path_table{row(1),col(1)+2}));
    set_param(tag_out,'Position',[left_corner(1)+100 left_corner(2)+5+15*(length(row)-1) left_corner(1)+170 left_corner(2)+20+15*(length(row)-1)]);
    set_param(tag_out,'ShowName','off');
    
    % Accounts for additional input for SA and RV nodes from paces
    numIns = length(row);
    if (i == SA || i == RV)
        numIns = numIns + 2;
    end
    
    % Use OR block if multiple inputs
    if (numIns) > 1
        op_name=sprintf('%s/NA%d_OR',modelType,i);
        add_block('Simulink/Logic and Bit Operations/Logical Operator',op_name);
        set_param(op_name,'Inputs',num2str(numIns));
        set_param(op_name,'Operator','OR');
        set_param(op_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+50 left_corner(2)+numIns*25]);
        add_line(modelType,sprintf('NA%d_OR/1',i),sprintf('NA%d/1',i));
    end
    
    % Add input tags
    for j=1:numIns
        %for non-SA/RV nodes, or inputs before the pace input for SA/RV
        if ((i ~= SA && i ~= RV) || j < (numIns - 1))
            tag_in=sprintf('%s/PA%d_%d',modelType,row(j),col(j));
            line_in=sprintf('PA%d_%d/1',row(j),col(j));
            add_block('Simulink/Signal Routing/From',tag_in);
            set_param(tag_in,'GotoTag',sprintf('PA%d_out_%d',row(j),col(j)));
            
        elseif (j == numIns - 1) %extra pace input for SA and RV
            if (i == SA)
                tag_in = sprintf('%s/a_pace_f',modelType);
                line_in = 'a_pace_f/1';
                add_block('Simulink/Signal Routing/From',tag_in);
                set_param(tag_in,'GotoTag','a_pace');
            else %RV
                tag_in = sprintf('%s/v_pace_f',modelType);
                line_in = 'v_pace_f/1';
                add_block('Simulink/Signal Routing/From',tag_in);
                set_param(tag_in,'GotoTag','v_pace');
            end
        else %PAC / PVC
            if (i == SA)
                tag_in = sprintf('%s/PAC_tagIn',modelType);
                line_in = 'PAC_tagIn/1';
                add_block('Simulink/Signal Routing/From',tag_in);
                set_param(tag_in,'GotoTag','PAC_out');
            else %RV
                tag_in = sprintf('%s/PVC_tagIn',modelType);
                line_in = 'PVC_tagIn/1';
                add_block('Simulink/Signal Routing/From',tag_in);
                set_param(tag_in,'GotoTag','PVC_out');
            end
        end
        
        set_param(tag_in,'Position',[left_corner(1)-110 left_corner(2)+(j-1)*25+5 left_corner(1)-10 left_corner(2)+(j-1)*25+20]);
        set_param(tag_in,'ShowName','off');
        
        %Connects tag directly to node input tag if only one path, or
        %to OR block if multiple paths
        if numIns == 1
            dest = sprintf('NA%d/1',i);
        else
            dest = sprintf('NA%d_OR/%d',i,j);
        end
        
        add_line(modelType,line_in,dest);
    end
    
    %dynamically computes location of next OR block based on size of
    %this OR block
    orTop = orTop + orSpacing + orIncrement * numIns;
end

% a_ratio_table = cell(size(path_param,1),1);

%% Path Assembly
for i=1:size(path_param,1)
    
    % Create A_Ratio Lookup Table
    %     forw_param = path_param(path_table{i,3},path_table{i,4},6);
    %     table_dim = forw_param*3+1;
    %
    %     table_temp = zeros(table_dim,table_dim);
    %
    %     for j=1:table_dim
    %         for k=1:table_dim
    %             if j >= k
    %                 table_temp(j,k)=double(k)/double(j);
    %             end
    %         end
    %     end
    
    %    a_ratio_table(i) = {table_temp};
    
    
    % Add block
    block_name=sprintf('%s/%s',modelType,path_names{i});
    add_block(path,block_name);
    
    % Block positioning
    left_corner=[500,(topMargin + (i-1) * pathSpacing)];
    set_param(block_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+105 left_corner(2)+70]);
    
    initYOffset = 0; %initial Y offset for output tags
    
    % Add Output1 Tags
    out_name_1=sprintf('%s/PA%d_out_1',modelType,i);
    add_block('Simulink/Signal Routing/Goto',out_name_1);
    set_param(out_name_1,'Position',[left_corner(1)+140 left_corner(2)+initYOffset left_corner(1)+225 left_corner(2)+initYOffset+15]);
    set_param(out_name_1,'GotoTag',sprintf('PA%d_out_1',i));
    set_param(out_name_1,'ShowName','off');
    add_line(modelType,sprintf('%s/1',path_names{i}),sprintf('PA%d_out_1/1',i));
    
    % Add Output2 Tags
    out_name_2=sprintf('%s/PA%d_out_2',modelType,i);
    add_block('Simulink/Signal Routing/Goto',out_name_2);
    set_param(out_name_2,'Position',[left_corner(1)+140 left_corner(2)+initYOffset+25 left_corner(1)+225 left_corner(2)+initYOffset+40]);
    set_param(out_name_2,'GotoTag',sprintf('PA%d_out_2',i));
    set_param(out_name_2,'ShowName','off');
    add_line(modelType,sprintf('%s/2',path_names{i}),sprintf('PA%d_out_2/1',i));
    
    
    initYOffset = -5; %initial Y offset for input tags
    
    % Add Input1 Tags
    in_name_1=sprintf('%s/PA%d_in_1',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name_1);
    set_param(in_name_1,'Position',[left_corner(1)-105 left_corner(2)+initYOffset left_corner(1)-35 left_corner(2)+initYOffset+15]);
    set_param(in_name_1,'GotoTag',sprintf('NA%d_out',path_table{i,3}));
    set_param(in_name_1,'ShowName','off');
    add_line(modelType,sprintf('PA%d_in_1/1',i),sprintf('%s/1',path_names{i}));
    
    % Add Input2 Tags
    in_name_2=sprintf('%s/PA%d_in_2',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name_2);
    set_param(in_name_2,'Position',[left_corner(1)-105 left_corner(2)+initYOffset+15 left_corner(1)-35 left_corner(2)+initYOffset+30]);
    set_param(in_name_2,'GotoTag',sprintf('NA%d_out',path_table{i,4}));
    set_param(in_name_2,'ShowName','off');
    add_line(modelType,sprintf('PA%d_in_2/1',i),sprintf('%s/2',path_names{i}));
    
    % Add Input3 Tags
    in_name_3=sprintf('%s/PA%d_in_3',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name_3);
    set_param(in_name_3,'Position',[left_corner(1)-105 left_corner(2)+initYOffset+30 left_corner(1)-35 left_corner(2)+initYOffset+45]);
    set_param(in_name_3,'GotoTag',sprintf('NA%d_pt',path_table{i,3}));
    set_param(in_name_3,'ShowName','off');
    add_line(modelType,sprintf('PA%d_in_3/1',i),sprintf('%s/3',path_names{i}));
    
    % Add Input4 Tags
    in_name_4=sprintf('%s/PA%d_in_4',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name_4);
    set_param(in_name_4,'Position',[left_corner(1)-105 left_corner(2)+initYOffset+45 left_corner(1)-35 left_corner(2)+initYOffset+60]);
    set_param(in_name_4,'GotoTag',sprintf('NA%d_pt',path_table{i,4}));
    set_param(in_name_4,'ShowName','off');
    add_line(modelType,sprintf('PA%d_in_4/1',i),sprintf('%s/4',path_names{i}));
    
    % Add Input5 (path_fwd_param) Tags
    in_name_5=sprintf('%s/PA%d_forw',modelType,i);
    
    %If AV-RV path, then programmable input, otherwise constant from model
    if i == AVRV
        add_block('Simulink/Signal Routing/From',in_name_5);
        set_param(in_name_5,'GotoTag','AV_forw');
    else
        add_block('Simulink/Sources/Constant',in_name_5);
        set_param(in_name_5,'Value',sprintf('%d',path_param(path_table{i,3},path_table{i,4},6)));
        set_param(in_name_5,'OutDataTypeStr','uint16');
    end
    
    set_param(in_name_5,'Position',[left_corner(1)-105 left_corner(2)+initYOffset+60 left_corner(1)-35 left_corner(2)+initYOffset+75]);
    set_param(in_name_5,'ShowName','off');
    add_line(modelType,sprintf('PA%d_forw/1',i),sprintf('%s/5',path_names{i}));
    
    
    %% Path Parameters
    set_param(block_name,'min_path_par_m',sprintf('%d',path_param(path_table{i,3},path_table{i,4},5)));
    set_param(block_name,'bck_param_m',sprintf('%d',path_param(path_table{i,3},path_table{i,4},7)));
    %    set_param(block_name,'a_ratio_table_m', sprintf('cell2mat(a_ratio_table(%d))', i));
    
end


%% System Outputs
for i=1:length(outputs)
    
    left_corner=[1150,(topMargin + (i-1) * outputSpacing)];
    
    in_name=sprintf('%s/Output%d',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name);
    set_param(in_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+80 left_corner(2)+15]);
    set_param(in_name,'GotoTag',sprintf('NA%d_out',outputs(i)));
    set_param(in_name,'ShowName','off');
    
    out_name=sprintf('%s/NA%dOut',modelType,outputs(i));
    add_block('Simulink/Sinks/Out1',out_name);
    set_param(out_name,'Position',[left_corner(1)+130 left_corner(2) left_corner(1)+160 left_corner(2)+15]);
    
    add_line(modelType, sprintf('Output%d/1',i), sprintf('NA%dOut/1',outputs(i)));
end


%% System Inputs
inputNames = {'AP', 'VP', 'SArest', 'AVforw'};
inputTags = {'a_pace', 'v_pace', 'SA_rest', 'AV_forw'};

for i=1:length(inputTags)
    left_corner=[1150,(topMargin + ((i + length(outputs))-1) * outputSpacing)];
    in_name=sprintf('%s/%s',modelType, inputNames{i});
    add_block('Simulink/Sources/In1',in_name);
    set_param(in_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+30 left_corner(2)+15]);
    
    out_name=sprintf('%s/%s_inTag',modelType, inputTags{i});
    add_block('Simulink/Signal Routing/Goto',out_name);
    set_param(out_name,'Position',[left_corner(1)+80 left_corner(2) left_corner(1)+160 left_corner(2)+15]);
    set_param(out_name,'GotoTag',inputTags{i});
    set_param(out_name,'ShowName','off');
    
    add_line(modelType, sprintf('%s/1',inputNames{i}), sprintf('%s_inTag/1',inputTags{i}));
    
end



%% PAC and PVC

PACnames = {'PAC', 'PVC'};

for i = 1:length(PACnames)
    
    left_corner=[1200 500+125*i];
    
    name=sprintf('%s/%s',modelType, PACnames{i});
    add_block(PVC,name);
    set_param(name,'Position',[left_corner(1) left_corner(2) left_corner(1)+125 left_corner(2)+75]);
    
    out_name=sprintf('%s/%s_outTag',modelType, PACnames{i});
    add_block('Simulink/Signal Routing/Goto',out_name);
    set_param(out_name,'Position',[left_corner(1)+150 left_corner(2)+30 left_corner(1)+235 left_corner(2)+45]);
    set_param(out_name,'GotoTag',sprintf('%s_out',PACnames{i}));
    set_param(out_name,'ShowName','off');
    add_line(modelType, sprintf('%s/1',PACnames{i}), sprintf('%s_outTag/1',PACnames{i}));
    
    in_name=sprintf('%s/%s_en',modelType, PACnames{i});
    add_block('Simulink/Sources/In1',in_name);
    set_param(in_name,'Position',[left_corner(1)-60 left_corner(2) left_corner(1)-30 left_corner(2)+15]);
    add_line(modelType, sprintf('%s_en/1',PACnames{i}), sprintf('%s/1',PACnames{i}));
    
    in_name=sprintf('%s/%s_count',modelType, PACnames{i});
    add_block('Simulink/Sources/Constant',in_name);
    set_param(in_name,'Value',PACPVCVal{i});
    set_param(in_name,'OutDataTypeStr','uint16');
    set_param(in_name,'Position',[left_corner(1)-90 left_corner(2)+30 left_corner(1)-30 left_corner(2)+45]);
    set_param(in_name,'ShowName','off');
    add_line(modelType,sprintf('%s_count/1',PACnames{i}),sprintf('%s/2',PACnames{i}));
    
    in_name=sprintf('%s/%s_actIn',modelType, PACnames{i});
    add_block('Simulink/Signal Routing/From',in_name);
    set_param(in_name,'Position',[left_corner(1)-90 left_corner(2)+55 left_corner(1)-30 left_corner(2)+70]);
    set_param(in_name,'GotoTag',sprintf('NA%d_out',SARV(i)));
    set_param(in_name,'ShowName','off');
    add_line(modelType,sprintf('%s_actIn/1',PACnames{i}),sprintf('%s/3',PACnames{i}));

end

% %% Case Switch Module
% 
% block_name=sprintf('%s/%s',modelType,'Case_select');
% add_block('Simulink/Signal Routing/Multiport Switch',block_name);
% set_param(block_name,'Position',[1400,700,1400+50,700+100]);
% 
% add_block('Simulink/Sources/In1',sprintf('%s/Case_s',modelType));
% set_param(sprintf('%s/Case_s',modelType),'Position',[1300,700,1300+70,700+15]);
% set_param(sprintf('%s/Case_s',modelType),'OutDataTypeStr','uint16');
% add_line(modelType,'Case_s/1','Case_select/1');
% 
% for i=1:size(data,1)
%     add_block('Simulink/Sources/Constant',sprintf('%s/data%d',modelType,i));
%     set_param(sprintf('%s/data%d',modelType,i),'Position',[1300,720+(i-1)*20,1300+70,720+20+(i-1)*20]);
%     set_param(sprintf('%s/data%d',modelType,i),'Value',mat2str(data(i,:)));
%     add_line(modelType,sprintf('data%d/1',i),sprintf('Case_select/%d',i+1));
%     set_param(sprintf('%s/data%d',modelType,i),'ShowName','off');
%     set_param(sprintf('%s/data%d',modelType,i),'OutDataTypeStr','uint16');
% end
% 
% add_block('Simulink/Signal Routing/Demux',sprintf('%s/demux',modelType));
% set_param(sprintf('%s/demux',modelType),'Position',[1460,700,1460+10,700+100]);
% set_param(sprintf('%s/demux',modelType),'Outputs',num2str(size(data,2)));
% add_line(modelType,'Case_select/1','demux/1');
% 
% add_block('Simulink/Signal Routing/Goto',sprintf('%s/mux1',modelType));
% set_param(sprintf('%s/mux1',modelType),'Position',[1500,700,1500+60,700+15]);
% set_param(sprintf('%s/mux1',modelType),'GotoTag','SA_rest');
% add_line(modelType,'demux/1','mux1/1');
% set_param(sprintf('%s/mux1',modelType),'ShowName','off');
% 
% add_block('Simulink/Signal Routing/Goto',sprintf('%s/mux2',modelType));
% set_param(sprintf('%s/mux2',modelType),'Position',[1500,720,1500+60,720+15]);
% set_param(sprintf('%s/mux2',modelType),'GotoTag','AV_forw');
% add_line(modelType,'demux/2','mux2/1');
% set_param(sprintf('%s/mux2',modelType),'ShowName','off');


%% Saving

save_system(modelType, strcat(systempath, modelType)); %saves HDL model


%% Scope Connections
left_corner=[1400, topMargin];

out_name=sprintf('%s/HeartScope',modelType);
add_block('Simulink/Sinks/Scope',out_name);
set_param(out_name,'Position',[left_corner(1)+130 left_corner(2) left_corner(1)+180 left_corner(2)+15*(length(outputs)+1)]);
set_param(out_name,'NumInputPorts',sprintf('%d',length(outputs)));
set_param(out_name,'LimitDataPoints','off');
set_param(out_name,'SaveToWorkspace','on');
set_param(out_name,'DataFormat','StructureWithTime');
set_param(out_name,'SaveName','scopedata');

% Scope input names (for plot)
s = struct();

for i=1:length(outputs)
    
    left_corner=[1400,(topMargin + (i-1) * scopeSpacing)];
    
    in_name=sprintf('%s/ScopeOutput%d',modelType,i);
    add_block('Simulink/Signal Routing/From',in_name);
    set_param(in_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+80 left_corner(2)+15]);
    set_param(in_name,'GotoTag',sprintf('NA%d_out',outputs(i)));
    set_param(in_name,'ShowName','off');
    
    add_line(modelType, sprintf('ScopeOutput%d/1',i), sprintf('HeartScope/%d',i));
    
    %%%%%%%%%%%%%%%%% TODO: use something other than setfield here??? %%%%
    s = setfield(s, sprintf('axes%d',i), sprintf('NA_%d', outputs(i)));
end

set_param(out_name,'AxesTitles',s); %sets axes titles on scope

%% Saving (scope)
save_system(modelType, strcat(systempath, modelType, '_scope')); %saves scope model
open_system(strcat(systempath, modelType));


%% Generating HDL
if generateHDL == 1
    makehdl(modelType);
end

end
