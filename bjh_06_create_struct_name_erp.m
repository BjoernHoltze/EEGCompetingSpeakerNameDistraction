function [] = bjh_06_create_struct_name_erp(PATHIN,PATHOUT,NAMEQUESTPATH,load_name,save_name,incl_subj,con_order)
%% creates a structure containing epochs for Name ERP and info about all subjects
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which name_struct will be stored
%           NAMEQUESTPATH   [string] path from which info about detecetd names is acquired
%           load_name:      [string] name of .set file to be loaded (without 'subj_x')
%           save_name:      [string] name of struct to be stored
%           incl_subj       [string cell array] all included subjects
%           con_order       [string] condition order of all participants
%                           {'OBOB','BOBO',...}
% 
% STRUCTURE:    data_ob     omni and beam pooled (subject x electrode x frame)
%               data_cob    control words pooled for omni and beam (subject x electrode x frame)
%               data_o      omni (subject x electrode x frame)
%               data_b      beam (subject x electrode x frame)
%               data_co     control omni (subject x electrode x frame)
%               data_cb     control beam (subject x electrode x frame)
%               incl_subj   string cell array with numbers of included subjects
%               con_order   string cell array with condition order of included subjects
%               times       time vector of epochs from EEG.times
%               chanlocs    channel locations from EEG.chanlocs (49 ch)
%               srate       sampling rate of EEG data
%               name_quest  [1 x 25 struct]
%                               subj    number of subject
%                               both    reported #names in both conditions
%                               beam    reported #names in beam condition
%                               omni    reported #names in omni condition
%                               length  length of name [ms] 
% 
% author: Bjoern Holtze
% date: 13.05.2020
    
    for s = 1:size(incl_subj,2)
        EEG_both = pop_loadset([PATHIN, 'sub-', incl_subj{s}, load_name, '.set']);
        % name_struct (omni and beam)
        EEG_omni_beam = pop_selectevent( EEG_both, 'type',{'omni','beam'},'deleteevents',...
            'off','deleteepochs','on','invertepochs','off');
        name_struct.data_ob(s,:,:) = mean(EEG_omni_beam.data,3);
        % name_struct (control_omni and beam)
        EEG_control_omni_beam = pop_selectevent( EEG_both, 'type',{'control_omni','control_beam'},...
            'deleteevents','off','deleteepochs','on','invertepochs','off');
        name_struct.data_cob(s,:,:) = mean(EEG_control_omni_beam.data,3);
        % name_struct (omni)
        EEG_omni = pop_selectevent( EEG_both, 'type',{'omni'},'deleteevents','off','deleteepochs','on',...
            'invertepochs','off');
        name_struct.data_o(s,:,:) = mean(EEG_omni.data,3);
        % name_struct (beam)
        EEG_beam = pop_selectevent( EEG_both, 'type',{'beam'},'deleteevents','off','deleteepochs','on',...
            'invertepochs','off');
        name_struct.data_b(s,:,:) = mean(EEG_beam.data,3);
        % name_struct (control_omni)
        EEG_control_omni = pop_selectevent( EEG_both, 'type',{'control_omni'},'deleteevents','off','deleteepochs','on',...
            'invertepochs','off');
        name_struct.data_co(s,:,:) = mean(EEG_control_omni.data,3);
        % name_struct (control_beam)
        EEG_control_beam = pop_selectevent( EEG_both, 'type',{'control_beam'},'deleteevents','off','deleteepochs','on',...
            'invertepochs','off');
        name_struct.data_cb(s,:,:) = mean(EEG_control_beam.data,3);
    end
    
    % name_struct
    name_struct.incl_subj = incl_subj;
    name_struct.con_order = con_order(cellfun(@str2num,incl_subj));
    name_struct.times = EEG_both.times;
    name_struct.chanlocs = EEG_both.chanlocs;
    name_struct.srate = EEG_both.srate;
    
    % add information from questionnaire
    load([NAMEQUESTPATH, 'name_quest.mat']);
    name_struct.name_quest = name_quest; 

    save([PATHOUT, save_name, '.mat'], 'name_struct');
    
end

