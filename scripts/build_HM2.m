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

function build_HM2(sys_name)

node = 'LookupModeling/NA';
path = 'LookupModeling/PA';

simulink;
open_system('LookupModeling');
load(sprintf('%s.mat',sys_name));
setup_case2none;
open_system(new_system(sys_name));
set_param(sys_name,'StopTime','10000');
set_param(sys_name,'Solver','FixedStepDiscrete')

for i=1:size(node_param,1)
    % add node
    block_name=sprintf('%s/%s',sys_name,node_name{i});
    add_block(node,block_name);
%     left_corner=[node_pos(i,1)/530*2500-500,2000-node_pos(i,2)/530*2500];
    left_corner=[100,i*70];
    set_param(block_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+115 left_corner(2)+25]);
    
    % add output tag for active signal
    out_name=sprintf('%s/NA%d_out',sys_name,i);
    add_block('Simulink/Signal Routing/Goto',out_name);
    set_param(out_name,'Position',[left_corner(1)+150 left_corner(2)-15 left_corner(1)+225 left_corner(2)+10]);
    set_param(out_name,'GotoTag',sprintf('NA%d_out',i));
    add_line(sys_name,sprintf('%s/1',node_name{i}),sprintf('NA%d_out/1',i));
    
    % add output tag for path_timer signal
    out_name=sprintf('%s/NA%d_pt',sys_name,i);
    add_block('Simulink/Signal Routing/Goto',out_name);
    set_param(out_name,'Position',[left_corner(1)+150 left_corner(2)+5 left_corner(1)+225 left_corner(2)+30]);
    set_param(out_name,'GotoTag',sprintf('NA%d_pt',i));
    add_line(sys_name,sprintf('%s/3',node_name{i}),sprintf('NA%d_pt/1',i));
    
    % add input tag
    in_name=sprintf('%s/NA%d_in',sys_name,i);
    add_block('Simulink/Signal Routing/From',in_name);
    set_param(in_name,'Position',[left_corner(1)-100 left_corner(2) left_corner(1)-25 left_corner(2)+25]);
    set_param(in_name,'GotoTag',sprintf('NA%d_in',i));
    add_line(sys_name,sprintf('NA%d_in/1',i),sprintf('%s/1',node_name{i}));

    %% %%%%%%%%%%%%%%%%%%% CLOCK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     add_block('Simulink/Sources/Pulse Generator',sprintf('%s/NA_clk%d',sys_name,i));
%     add_block('Simulink/Signal Routing/From',sprintf('%s/NA_clk%d',sys_name,i));
%     set_param(sprintf('%s/NA_clk%d',sys_name,i),'Position',[left_corner(1)-100 left_corner(2)+20 left_corner(1)-25 left_corner(2)+45]);
%     set_param(sprintf('%s/NA_clk%d',sys_name,i),'GotoTag','clk');
%     add_line(sys_name,sprintf('NA_clk%d/1',i),sprintf('%s/2',node_name{i}));
%     % set initial values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%

    set_param(block_name,'TERP_s_m',sprintf('%d',node_param(i,1)));
    set_param(block_name,'TERP_defs_m',sprintf('%d',node_param(i,2)));
    set_param(block_name,'TRRP_s_m',sprintf('%d',node_param(i,3)));
    set_param(block_name,'TRRP_def_m',sprintf('%d',node_param(i,4)));
    set_param(block_name,'Trest_s_m',sprintf('%d',node_param(i,5)));
    set_param(block_name,'Trest_def_m',sprintf('%d',node_param(i,6)));
    set_param(block_name,'Terp_min_m',sprintf('%d',node_param(i,7)));
    set_param(block_name,'Terp_max_m',sprintf('%d',node_param(i,8)));


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add input connection
    [row,col]=find(cell2mat(path_table(:,3:4))==i);
    l_corner=[850,i*100];
    % if only one connection, connect directly
    if length(row)==1
        tag_in=sprintf('%s/PA%d_%d',sys_name,row,col);
        add_block('Simulink/Signal Routing/From',tag_in);
        set_param(tag_in,'GotoTag',sprintf('PA%d_out_%d',row,col));
        set_param(tag_in,'Position',[l_corner(1)-100 l_corner(2) l_corner(1)-20 l_corner(2)+15]);
        
        tag_out=sprintf('%s/NA%d',sys_name,path_table{row,col+2});
        add_block('Simulink/Signal Routing/Goto',tag_out);
        set_param(tag_out,'GotoTag',sprintf('NA%d_in',path_table{row,col+2}));
        set_param(tag_out,'Position',[l_corner(1)+100 l_corner(2) l_corner(1)+150 l_corner(2)+15]);
        
        add_line(sys_name,sprintf('PA%d_%d/1',row,col),sprintf('NA%d/1',i));
    else % else connect them with OR operation
        op_name=sprintf('%s/NA_%d',sys_name,i);
        add_block('Simulink/Logic and Bit Operations/Logical Operator',op_name);
        set_param(op_name,'Inputs',num2str(length(row)));
        set_param(op_name,'Operator','OR');
        set_param(op_name,'Position',[l_corner(1) l_corner(2) l_corner(1)+50 l_corner(2)+length(row)*25]);
        
        for j=1:length(row)
            tag_in=sprintf('%s/PA%d_%d',sys_name,row(j),col(j));
            add_block('Simulink/Signal Routing/From',tag_in);
            set_param(tag_in,'GotoTag',sprintf('PA%d_out_%d',row(j),col(j)));
            set_param(tag_in,'Position',[l_corner(1)-100 l_corner(2)+(j-1)*30 l_corner(1)-20 l_corner(2)+(j-1)*30+15]);
            
            add_line(sys_name,sprintf('PA%d_%d/1',row(j),col(j)),sprintf('NA_%d/%d',path_table{row(j),col(j)+2},j));
        end
        
        tag_out=sprintf('%s/NA%d',sys_name,path_table{row(1),col(1)+2});
        add_block('Simulink/Signal Routing/Goto',tag_out);
        set_param(tag_out,'GotoTag',sprintf('NA%d_in',path_table{row(1),col(1)+2}));
        set_param(tag_out,'Position',[l_corner(1)+100 l_corner(2) l_corner(1)+150 l_corner(2)+15]);
        
        add_line(sys_name,sprintf('NA_%d/1',i),sprintf('NA%d/1',i));
        
    end

    
end

for i=1:size(path_param,1)
    % add block
    block_name=sprintf('%s/%s',sys_name,path_names{i});
    add_block(path,block_name);
    left_corner=[500,i*80];
    set_param(block_name,'Position',[left_corner(1) left_corner(2) left_corner(1)+95 left_corner(2)+55]);
    
   % set_param(block_name,'forw_t_s',sprintf('path_param(%d,%d,1)',path_table{i,3},path_table{i,4}));
   % set_param(block_name,'forw_t_def',sprintf('path_param(%d,%d,2)',path_table{i,3},path_table{i,4}));
   % set_param(block_name,'bck_t_s',sprintf('path_param(%d,%d,3)',path_table{i,3},path_table{i,4}));
   % set_param(block_name,'bck_t_def',sprintf('path_param(%d,%d,4)',path_table{i,3},path_table{i,4}));
    set_param(block_name,'min_path_par_m',sprintf('%d',path_param(path_table{i,3},path_table{i,4},5)));
    set_param(block_name,'forw_param_m',sprintf('%d',path_param(path_table{i,3},path_table{i,4},6)));
    set_param(block_name,'bck_param_m',sprintf('%d',path_param(path_table{i,3},path_table{i,4},7)));
    
    % add output tags
    out_name_1=sprintf('%s/PA%d_out_1',sys_name,i);
    add_block('Simulink/Signal Routing/Goto',out_name_1);
    set_param(out_name_1,'Position',[left_corner(1)+120 left_corner(2)-15 left_corner(1)+205 left_corner(2)]);
    set_param(out_name_1,'GotoTag',sprintf('PA%d_out_1',i));
    add_line(sys_name,sprintf('%s/1',path_names{i}),sprintf('PA%d_out_1/1',i));
    out_name_2=sprintf('%s/PA%d_out_2',sys_name,i);
    add_block('Simulink/Signal Routing/Goto',out_name_2);
    set_param(out_name_2,'Position',[left_corner(1)+120 left_corner(2)+15 left_corner(1)+205 left_corner(2)+30]);
    set_param(out_name_2,'GotoTag',sprintf('PA%d_out_2',i));
    add_line(sys_name,sprintf('%s/2',path_names{i}),sprintf('PA%d_out_2/1',i));
    
    % add input tags
    in_name_1=sprintf('%s/PA%d_in_1',sys_name,i);
%     in_name_1=sprintf('%s/NA%d_out',sys_name,path_table{i,3});
    add_block('Simulink/Signal Routing/From',in_name_1);
    set_param(in_name_1,'Position',[left_corner(1)-100 left_corner(2)-10 left_corner(1)-35 left_corner(2)+5]);
    set_param(in_name_1,'GotoTag',sprintf('NA%d_out',path_table{i,3}));
    add_line(sys_name,sprintf('PA%d_in_1/1',i),sprintf('%s/1',path_names{i}));
    in_name_2=sprintf('%s/PA%d_in_2',sys_name,i);
%     in_name_2=sprintf('%s/NA%d_out',sys_name,path_table{i,4});
    add_block('Simulink/Signal Routing/From',in_name_2);
    set_param(in_name_2,'Position',[left_corner(1)-100 left_corner(2)+20 left_corner(1)-35 left_corner(2)+35]);
    set_param(in_name_2,'GotoTag',sprintf('NA%d_out',path_table{i,4}));
    add_line(sys_name,sprintf('PA%d_in_2/1',i),sprintf('%s/2',path_names{i}));
    
    in_name_3=sprintf('%s/PA%d_in_3',sys_name,i);
    add_block('Simulink/Signal Routing/From',in_name_3);
    set_param(in_name_3,'Position',[left_corner(1)-100 left_corner(2)+30 left_corner(1)-35 left_corner(2)+45]);
    set_param(in_name_3,'GotoTag',sprintf('NA%d_pt',path_table{i,3}));
    add_line(sys_name,sprintf('PA%d_in_3/1',i),sprintf('%s/3',path_names{i}));
    
    in_name_4=sprintf('%s/PA%d_in_4',sys_name,i);
    add_block('Simulink/Signal Routing/From',in_name_4);
    set_param(in_name_4,'Position',[left_corner(1)-100 left_corner(2)+40 left_corner(1)-35 left_corner(2)+55]);
    set_param(in_name_4,'GotoTag',sprintf('NA%d_pt',path_table{i,4}));
    add_line(sys_name,sprintf('PA%d_in_4/1',i),sprintf('%s/4',path_names{i}));
    
%     add_block('Simulink/Signal Routing/From',sprintf('%s/PA_clk%d',sys_name,i));
%     set_param(sprintf('%s/PA_clk%d',sys_name,i),'Position',[left_corner(1)-100 left_corner(2)+50 left_corner(1)-25 left_corner(2)+65]);
%     set_param(sprintf('%s/PA_clk%d',sys_name,i),'GotoTag','clk');
%     add_line(sys_name,sprintf('PA_clk%d/1',i),sprintf('%s/3',path_names{i}));
    
end
save_system;

