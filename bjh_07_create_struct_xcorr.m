function bjh_07_create_struct_xcorr(PATHIN,PATHOUT,STIMPATH,load_name,save_name,max_lag)
%% performs cross-correlation for consecutive segments not time-locked to name
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which segments_struct will be stored
%           STIMPATH:       [string] path from which order of speech envelope
%                           segments is loaded (necessary for control envelope)
%           load_name:      [string] name of .mat file to be loaded
%           save_name:      [string] name of struct to be stored
%           max_lag:        [number] maximal lag in samples
%           
% 
% STRUCTURE:    attend          5D data matrix (subject x electrode x frame x trial x block)
%                               frames includes cross-correlation values
%               unattend        5D data matrix (subject x electrode x frame x trial x block)
%                               frames includes cross-correlation values
%               control         5D data matrix (subject x electrode x frame x trial x block)
%                               control is same as attend but shuffled 
%               lag             lag vector in samples
%               lag_ms          lag vector in ms 
%               incl_subj       string cell array containing subject numbers of included subjects
%               attended_ch     number of channel that was attended (only from included subjects)
%               chanlocs        channel locations from EEG.chanlocs (49 ch)
%               srate           sampling rate from EEG.srate 
% 
% author: Bjoern Holtze
% date: 16.07.2020
 
    load([PATHIN, load_name, '.mat']);
    load([STIMPATH, 'control_envelope_order.mat']);
 
    % Cross Correlation
    for s = 1:size(segments_struct.eeg_mat,1)
        for e = 1:size(segments_struct.eeg_mat,2)
            for t = 1:size(segments_struct.eeg_mat,4)
                for b = 1:size(segments_struct.eeg_mat,5)
                    if segments_struct.attended_ch(s) == 1
                        [xcorr_attend(s,e,:,t,b), lag] = xcorr(squeeze(segments_struct.eeg_mat(s,e,:,t,b)),...
                            segments_struct.env_1(:,t,b),max_lag,'coeff');
                        [xcorr_unattend(s,e,:,t,b), ~] = xcorr(squeeze(segments_struct.eeg_mat(s,e,:,t,b)),...
                            segments_struct.env_2(:,t,b),max_lag,'coeff');
                        [xcorr_control(s,e,:,t,b), ~] = xcorr(squeeze(segments_struct.eeg_mat(s,e,:,t,b)),...
                            segments_struct.env_1(:,rand_array(s,t,b),b),max_lag,'coeff');
                    elseif segments_struct.attended_ch(s) == 2
                        [xcorr_attend(s,e,:,t,b), lag] = xcorr(squeeze(segments_struct.eeg_mat(s,e,:,t,b)),...
                            segments_struct.env_2(:,t,b),max_lag,'coeff');
                        [xcorr_unattend(s,e,:,t,b), ~] = xcorr(squeeze(segments_struct.eeg_mat(s,e,:,t,b)),...
                            segments_struct.env_1(:,t,b),max_lag,'coeff');
                        [xcorr_control(s,e,:,t,b), ~] = xcorr(squeeze(segments_struct.eeg_mat(s,e,:,t,b)),...
                            segments_struct.env_2(:,rand_array(s,t,b),b),max_lag,'coeff');
                    end
                end
            end
        end
    end 
       
    %%% Cross-Correlation %%%
    xcorr_struct.attend = xcorr_attend;
    xcorr_struct.unattend = xcorr_unattend;
    xcorr_struct.control = xcorr_control;
    xcorr_struct.lag = lag;
    xcorr_struct.lag_ms = lag*(1000/segments_struct.srate);

    xcorr_struct.incl_subj = segments_struct.incl_subj;
    xcorr_struct.attended_ch = segments_struct.attended_ch;
    xcorr_struct.chanlocs = segments_struct.chanlocs;
    xcorr_struct.srate = segments_struct.srate;
    
    save([PATHOUT, save_name, '.mat'],'xcorr_struct','-v7.3');
    
end