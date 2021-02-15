function bjh_06_create_struct_seg_xcorr(PATHIN,PATHOUT,STIMPATH,load_name,save_name,incl_subj,attended_ch,win_seg)
%%  creates a structure containing epochs for cross-correlation (not time-locked to name)
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which segments_struct will be stored
%           STIMPATH:       [string] path from which speech envelopes are loaded
%           load_name:      [string] name of .set file to be loaded 
%           save_name:      [string] name of segments_struct to be stored
%           incl_subj       [string cell array] all included subjects
%           attended_ch:    [double array] number of channel that was attended
%           win_seg:        [double] window of segments (in s) for cross-correlation
%           
% 
% STRUCTURE:    eeg_mat         5D data matrix (subject x electrode x frame x trial x block)
%               env_1           speech envelope segments of story 1 
%               env_2           speech envelope segments of story 2
%               attended_ch     number of channel that was attended (only from included subjects)
%               incl_subj       string cell array containing subject numbers of included subjects
%               chanlocs        channel locations from EEG.chanlocs (49 ch)
%               srate           sampling rate from EEG.srate 
% 
% author: Bjoern Holtze
% date: 16.07.2020

%%%%%% EEG Data Segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    block_length = 600; % in s
    
    for s = 1:size(incl_subj,2)
        EEG_cleaned = pop_loadset([PATHIN, 'sub-', incl_subj{s}, load_name, '.set']);
        % remove boundary events so that all epochs are kept in the end
        EEG_cleaned.event = EEG_cleaned.event(~strcmp({EEG_cleaned.event.type},'boundary'));
        EEG = pop_epoch(EEG_cleaned,{'StartTrigger'},[0, block_length], 'epochinfo', 'yes');
        
        for block = 1:5
            for segment = 1:block_length/win_seg
                % segment data and baseline correct segments
                EEG_mat(s,:,:,segment,block) = EEG.data(:,(segment-1)*win_seg*EEG.srate+1:...
                    (segment)*win_seg*EEG.srate,block) - mean(EEG.data(:,(segment-1)*win_seg*EEG.srate+1:...
                    (segment)*win_seg*EEG.srate,block),2);
            end
        end
    end


%%%%%% Speech Envelope Segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for block = 1:5
        % load envelope of the respective block
        load([STIMPATH,'sig1_', num2str(block),'.mat']);
        load([STIMPATH,'sig2_', num2str(block),'.mat']);

        for segment = 1:block_length/win_seg
            env_1(:,segment,block) = sig1((segment-1)*win_seg*EEG.srate+1:...
                    (segment)*win_seg*EEG.srate);
            env_2(:,segment,block) = sig2((segment-1)*win_seg*EEG.srate+1:...
                (segment)*win_seg*EEG.srate);
        end
    end

    
    %%% EEG segments %%%
    segments_struct.eeg_mat = EEG_mat;

    %%% speech envelopes %%%
    segments_struct.env_1 = env_1;
    segments_struct.env_2 = env_2;
    
    segments_struct.attended_ch = attended_ch(cellfun(@str2num,incl_subj));
    segments_struct.incl_subj = incl_subj;
    segments_struct.chanlocs = EEG_cleaned.chanlocs;
    segments_struct.srate = EEG_cleaned.srate;
    
    
    save([PATHOUT, save_name, '.mat'], 'segments_struct','-v7.3');
    
    
end
