function [] = bjh_05_tbt(PATHIN,PATHOUT,load_name,save_name,ep_start,ep_end)
%% rejects epochs if they exceed +/- 150 mV in more than one channel
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which 4D data matrix will be stored
%           load_name:      [string] name of .set file to be loaded (without 'subj_x')
%           save_name:      [string] name of struct to be stored
%           ep_start        [double] start of the epoch (in s)
%           ep_end          [double] end of the epoch (in s)
%
% author: Björn Holtze
% date: 25.06.2020
        
        % epoch data according to 'omni' and 'beam' events 
        EEG = pop_loadset([PATHIN,load_name,'.set']);
        EEG = pop_epoch(EEG,{'omni','beam','control_omni','control_beam'},[ep_start, ep_end]);
        EEG = pop_rmbase(EEG, [ep_start*1000 0]);
        
        % reject epochs in which more than 1 channel exceeds +/-150 uV
        % in epochs in which only one channel exceeds this threshold
        % the channel is interpolated
        [EEG, ~] = pop_eegmaxmin(EEG,[1:49],[-500  1498],150,1998,1,0);
        [EEG,~,tbt_info] = pop_TBT(EEG,EEG.reject.rejmaxminE,2,0.3,0);
        
        EEG.setname = save_name; 
        pop_saveset(EEG, [PATHOUT, save_name, '.set']);
        
        close all;
        
end

