function bjh_07_create_struct_xcorr_name(PATHIN,PATHOUT,load_name,save_name,max_lag)
%% performs cross-correlation of segments relative to the name
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which segments_struct will be stored
%           load_name:      [string] name of .mat file to be loaded
%           save_name:      [string] name of struct to be stored
%           max_lag:        [number] maximal lag in samples
%           
% 
% STRUCTURE:    attend          5D cross-correlation matrix (subject x segments x electrodes x samples x trials) 
%               unattend        5D cross-correlation matrix (subject x segments x electrodes x samples x trials) 
%               lag             time lags of cross-correlation in samples
%               lag_ms          time lags of cross-correlation in ms
%               edges           start and end of segments (in s)
%               incl_subj       string cell array containing subject numbers of included subjects
%               attended_ch     number of channel that was attended (only from included subjects)
%               chanlocs        channel locations from EEG.chanlocs (49 ch)
%               srate           sampling rate from EEG.srate 
%               name_quest      [1 x 25 struct]
%                               subj    number of subject
%                               both    reported #names in both conditions
%                               beam    reported #names in beam condition
%                               omni    reported #names in omni condition
%                               length  length of name [ms] 
% 
% author: Bjoern Holtze
% date: 26.05.2020
    
    load([PATHIN, load_name, '.mat']);
 
    % Cross Correlation
    for s = 1:size(segments_struct.eeg_mat,1)
        for p = 1:size(segments_struct.eeg_mat,2)
            for e = 1:size(segments_struct.eeg_mat,3)
                for t = 1:size(segments_struct.eeg_mat,5)                
                    if segments_struct.attended_ch(s) == 1
                        [xcorr_attend(s,p,e,:,t), lag] = xcorr(squeeze(segments_struct.eeg_mat(s,p,e,:,t)),...
                            squeeze(segments_struct.env_1_attend(p,:,t)),max_lag,'coeff');
                        [xcorr_unattend(s,p,e,:,t), lag] = xcorr(squeeze(segments_struct.eeg_mat(s,p,e,:,t)),...
                            squeeze(segments_struct.env_2_unattend(p,:,t)),max_lag,'coeff');
                    elseif segments_struct.attended_ch(s) == 2
                        [xcorr_attend(s,p,e,:,t), lag] = xcorr(squeeze(segments_struct.eeg_mat(s,p,e,:,t)),...
                            squeeze(segments_struct.env_2_attend(p,:,t)),max_lag,'coeff');
                        [xcorr_unattend(s,p,e,:,t), lag] = xcorr(squeeze(segments_struct.eeg_mat(s,p,e,:,t)),...
                            squeeze(segments_struct.env_1_unattend(p,:,t)),max_lag,'coeff');
                    end
                end
            end
        end
    end

    %%% Cross-Correlation %%%
    xcorr_struct.attend = xcorr_attend;
    xcorr_struct.unattend = xcorr_unattend;
    xcorr_struct.lag = lag;
    xcorr_struct.lag_ms = lag*(1000/segments_struct.srate);
    xcorr_struct.edges = segments_struct.edges;
    
    xcorr_struct.incl_subj = segments_struct.incl_subj;
    xcorr_struct.attended_ch = segments_struct.attended_ch;
    xcorr_struct.chanlocs = segments_struct.chanlocs;
    xcorr_struct.srate = segments_struct.srate;
    xcorr_struct.name_quest = segments_struct.name_quest;
    
    save([PATHOUT, save_name, '.mat'],'xcorr_struct','-v7.3');
    
end