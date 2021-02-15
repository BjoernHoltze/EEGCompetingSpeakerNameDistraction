function bjh_06_create_struct_seg_xcorr_name(PATHIN,PATHOUT,STIMPATH,load_name,save_name,incl_subj,attended_ch,win_seg,cut_end)
%% creates a structure containing epochs for cross-correlation relative to the name
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which segments_struct will be stored
%           STIMPATH:       [string] path from which speech envelopes are loaded
%           load_name:      [string] name of .set file to be loaded 
%           save_name:      [string] name of struct to be stored
%           incl_subj       [string cell array] all included subjects
%           attended_ch:    [double array] number of channel that was attended
%           win_seg:        [double] window of segments (in s) for cross-correlation
%           cut_end:        [double] time point in s at which segment after name starts
%           
% 
% STRUCTURE:    eeg_mat         5D data matrix (subject x segment x electrode x frame x trial)
%                               omni and beam conditions pooled, 40 trials
%               env_1_before    speech envelope segments of story 1 before the name occurrences
%               env_1_after     speech envelope segments of story 1 after the name occurrences
%               env_2_before    speech envelope segments of story 2 before the name occurrences
%               env_2_after     speech envelope segments of story 2 after the name occurrences
%               attended_ch     number of channel that was attended (only from included subjects)
%               incl_subj       string cell array containing subject numbers of included subjects
%               chanlocs        channel locations from EEG.chanlocs (49 ch)
%               srate           sampling rate from EEG.srate 
%               edges           start end at points of segments relative to name (in s)
%               name_quest  [1 x 25 struct]
%                               subj    number of subject
%                               both    reported #names in both conditions
%                               beam    reported #names in beam condition
%                               omni    reported #names in omni condition
%                               length  length of name [ms] 
% 
% author: Bjoern Holtze
% date: 16.08.2020
    
%%%%%% EEG Data Segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    edge_before = -30:win_seg:0;
    edge_after = cut_end:win_seg:30+cut_end;
    edges = [edge_before,edge_after]; 
    
    for s = 1:size(incl_subj,2)
        EEG_cleaned = pop_loadset([PATHIN, 'sub-', incl_subj{s}, load_name, '.set']);
        
        seg = 1;
        for p = 1:size(edges,2)
            if p == size(edges,2)/2 || p == size(edges,2)
            else
                EEG = pop_epoch(EEG_cleaned,{'omni','beam'},[edges(p),edges(p+1)], 'epochinfo', 'yes');
                EEG = pop_rmbase(EEG, []);
                EEG_mat(s,seg,:,:,:) = EEG.data;
                seg = seg + 1;
            end
        end
    end


%%%%%% Speech Envelope Segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load([STIMPATH, 'name_time.mat']);

    for block = 2:5
        % load envelope of the respective block
        load([STIMPATH, 'sig1_', num2str(block),'.mat']);
        load([STIMPATH, 'sig2_', num2str(block),'.mat']);

        for occ = 1:10
            seg = 1;
            for p = 1:size(edges,2)
                if p == size(edges,2)/2 || p == size(edges,2)
                else
                    env_1_attend(seg,:,((block-2)*10)+occ) = sig1(round(name_time_c2(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p)*EEG_cleaned.srate) : round(name_time_c2(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p+1)*EEG_cleaned.srate-1))';
                    env_1_unattend(seg,:,((block-2)*10)+occ) = sig1(round(name_time_c1(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p)*EEG_cleaned.srate) : round(name_time_c1(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p+1)*EEG_cleaned.srate-1))';
                    env_2_attend(seg,:,((block-2)*10)+occ) = sig2(round(name_time_c1(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p)*EEG_cleaned.srate) : round(name_time_c1(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p+1)*EEG_cleaned.srate-1))';
                    env_2_unattend(seg,:,((block-2)*10)+occ) = sig2(round(name_time_c2(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p)*EEG_cleaned.srate) : round(name_time_c2(block-1,occ)*EEG_cleaned.srate)+...
                        round(edges(p+1)*EEG_cleaned.srate-1))';
                    seg = seg + 1;
                end
            end
        end
    end

    
    %%% EEG segments %%%
    segments_struct.eeg_mat = EEG_mat;

    %%% speech envelopes %%%
    segments_struct.env_1_attend = env_1_attend;
    segments_struct.env_1_unattend = env_1_unattend;
    segments_struct.env_2_attend = env_2_attend;
    segments_struct.env_2_unattend = env_2_unattend;
    
    segments_struct.attended_ch = attended_ch(cellfun(@str2num,incl_subj));
    segments_struct.incl_subj = incl_subj;
    segments_struct.chanlocs = EEG_cleaned.chanlocs;
    segments_struct.srate = EEG_cleaned.srate;
    segments_struct.edges = edges; 
    
    % add information from name questionnaire
    load([STIMPATH, 'name_quest.mat']);
    segments_struct.name_quest = name_quest;
    
    save([PATHOUT, save_name, '.mat'], 'segments_struct','-v7.3');
    
    
end
