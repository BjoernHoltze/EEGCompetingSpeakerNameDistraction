function [] = bjh_03_iclabel(PATHIN,PATHOUT,load_name,load_name_imp,save_name,subj,run_mode)
%% labels IC components and allows the user to select bad components
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which .set files will be stored
%           load_name:      [string] name of .set files to be loaded 
%           load_name_imp:  [string] name of .set files to be loaded (imported data before ICA)
%           save_name:      [string] name of .set files to be saved 
%           subj:           [string] participant's number
%           run_mode:       [string]    Option 1: 'new', bad ICs have to be chosen manually
%                                       Option 2: 'reproduce', bad ICs have been identified previously
% 
% author: Björn Holtze
% date: 27.05.2020

    EEG_TMP = pop_loadset([PATHIN,load_name,'.set']);
    
    % label components using IClabels
    EEG_TMP = pop_iclabel(EEG_TMP, 'default');

    if strcmp(run_mode,'new')
        % view properties of components
        pop_viewprops( EEG_TMP, 0, [1:35], {'freqrange', [2 40]}, {}, 1, '' );
        
        while(1)
            i = input('Enter "1" to continue: ');
            if i == 1
                break;
            end
        end
        % enter artefact components
        EEG_TMP.badcomps = input('Enter bad components: ');
    elseif strcmp(run_mode,'reproduce')
        load([PATHIN,'sub-',subj,'_ica_weights_and_badcomps.mat']);
        EEG_TMP.badcomps = icaw_badcomps.badcomps;
    end
   
    
    % load imported dataset
    EEG_imported = pop_loadset([load_name_imp,'.set']);
    
    % apply ICA weights and copy badcomps to imported data
    EEG_imported.icawinv = EEG_TMP.icawinv;
    EEG_imported.icaweights = EEG_TMP.icaweights;
    EEG_imported.icasphere = EEG_TMP.icasphere;
    EEG_imported.icachansind = EEG_TMP.icachansind;
    EEG_imported.badcomps = EEG_TMP.badcomps;
    
    
    % remove components which were marked as artefacts
    EEG_badcomps_rm = pop_subcomp(EEG_imported, EEG_imported.badcomps, 0); 
    
    
    % save ICA weights and badcomps
    icaw_badcomps.icawinv = EEG_TMP.icawinv;
    icaw_badcomps.icaweights = EEG_TMP.icaweights;
    icaw_badcomps.icasphere = EEG_TMP.icasphere;
    icaw_badcomps.icachansind = EEG_TMP.icachansind;
    icaw_badcomps.badcomps = EEG_TMP.badcomps;
    
    if strcmp(run_mode,'new')
        save([PATHOUT, 'sub-', subj, '_ica_weights_and_badcomps.mat'],'icaw_badcomps');
    end
    
    % save dataset
    EEG_badcomps_rm.setname = save_name; 
    pop_saveset(EEG_badcomps_rm, [PATHOUT, save_name, '.set']);
    close all; 
end

