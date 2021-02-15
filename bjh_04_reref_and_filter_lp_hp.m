function [] = bjh_04_reref_and_filter_lp_hp(PATHIN,PATHOUT,load_name,save_name,low_edge,high_edge)
%% filters the data with a low and highpass filter and referfernces it to common average
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which .set files will be stored
%           load_name:      [string] name of the .set file to be imported
%           save_name:      [string] name of the .set file to be saved
%           low_edge:       [double] higher edge of low pass filter
%           high_edge:      [double] lower edge of high pass filter
%
% 
% author: Bjoern Holtze
% date: 18.05.20   
    
    % load set files
    EEG_imp = pop_loadset([PATHIN, load_name, '.set']);
    
    % rereference to common average
    EEG_reref = pop_reref(EEG_imp,[]);
    
    % apply low pass filter
    EEG_lp = pop_eegfiltnew(EEG_reref, [], high_edge, [], 0, [], 0);
    
    % apply high pass filter
    EEG_lp_hp = pop_eegfiltnew(EEG_lp, [], low_edge, [], true, [], 0);
    
    % setname
    EEG_lp_hp.setname = save_name;
    
    % save dataset
    pop_saveset(EEG_lp_hp, [PATHOUT, save_name, '.set']);

    
end