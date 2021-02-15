function [] = bjh_02_ica(PATHIN,PATHOUT,load_name,save_name,prob,kurt)
%% performs an ICA on 1-40 Hz filtered data and applies ICA weights to imported data.
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which .set files will be stored
%           load_name:      [string] name of .set files to be loaded 
%           save_name:      [string] name of .set files to be saved 
%           prob:           [double] probability threshold for pop_jointprob.m
%           kurt:           [double] kurtosis threshold for pop_jointprob.m
% 
% Procedure: 
%     Temporary Data:
%         lp at 40 Hz to remove linenoise
%         hp at 1 Hz to remove drifts
%         reject epochs (prob: 2, kurt: 2, this is rather strict)
%         run ICA
% 
% author: Björn Holtze
% date: 27.05.2020

    EEG_imported = pop_loadset([PATHIN,load_name,'.set']);

    %%%%%% Temporary Data %%%%%%
    % apply 40 Hz lowpass filter to eliminate line noise
    EEG_TMP = pop_eegfiltnew(EEG_imported, [], 40, [], 0, [], 0);
    
    % apply 1 Hz highpass filter (cut-off frequency: 1 Hz -> passband edge: 2 Hz) 
    EEG_TMP = pop_eegfiltnew(EEG_TMP, [], 2, [], true, [], 0);
    
    % epoch in consecutive 1 sec pieces
    EEG_TMP = eeg_regepochs(EEG_TMP);
    
    % reject epochs with atypical artifacts 
    EEG_TMP = pop_jointprob(EEG_TMP,1,[1:EEG_TMP.nbchan],prob,kurt,0,1,0,[],0);
    
    % decompose data with independent component analysis (ICA)  
    EEG_TMP = pop_runica(EEG_TMP, 'extended',1,'interupt','on');

    % save dataset
    EEG_TMP.setname = save_name;
    pop_saveset(EEG_TMP, [PATHOUT, save_name, '.set']);
    
end

