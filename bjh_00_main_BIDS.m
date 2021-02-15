%% bjh_00_main_BIDS
% author: Bjoern Holtze
% date: 12.05.2020
% adapted from: bjh_main_01.m

%% General Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MAINPATH = fullfile(pwd, '..', filesep);
    
    % add EEGLAB path
    addpath(fullfile('C:\Users\bjh\Desktop\bjh_name\software\eeglab13_6_5b\'));  
    eeglab;
    close 'EEGLAB v13.6.5b';
    
    % add name of folder to which BIDS data was downloaded
    BIDS_dataset_name = 'bjh_name';
    
    SOURCEDATAPATH = [MAINPATH,BIDS_dataset_name,filesep,'sourcedata',filesep];
    STIMPATH = [MAINPATH,BIDS_dataset_name,filesep,'stimuli',filesep];
    DATAPATH = [MAINPATH,'analysis',filesep];
    mkdir(DATAPATH);
    
    % included participants
    incl_subj = {'001','002','003','005','006','008','009','011','012','013','014',...
            '015','017','018','019','020','021','022','023','024','025'};
    % attended channel
    attended_ch = [1,1,2,2,1,1,2,2,1,1,2,2,1,1,2,2,1,1,2,2,1,1,2,2,1];
    % condition order
    con_order = {'OBOB','BOBO','OBOB','BOBO','OBOB','BOBO','OBOB','BOBO',...
                 'OBOB','BOBO','OBOB','BOBO','OBOB','BOBO','OBOB','BOBO',...
                 'OBOB','BOBO','OBOB','BOBO','OBOB','BOBO','OBOB','BOBO','OBOB'};

  
%% Independent Component Analysis (ICA) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    prob = 2; % local threshold for pop_jointprob
    kurt = 2; % global threshold for pop_jointprob
    ext_ica = ['_prob_', num2str(prob), '_kurt_', num2str(kurt)];
    run_mode = 'reproduce'; % either 'new' if ICA should newly run and badcomps should be newly identified
                            % or 'reproduce' if previous ICA results and identified badcomps should be used
                
    if strcmp(run_mode,'new')

        for s = 1:size(incl_subj,2)
            PATHIN_ICA = [MAINPATH,BIDS_dataset_name,filesep,'sub-',incl_subj{s},...
                filesep,'eeg',filesep];
            PATHOUT_ICA = DATAPATH;
            load_name_ica = ['sub-',incl_subj{s},'_task-AttendedSpeakerParadigmOwnName_eeg'];
            save_name_ica = ['sub-', incl_subj{s}, '_ica_tmp', ext_ica];
            
                bjh_02_ica(PATHIN_ICA,PATHOUT_ICA,load_name_ica,save_name_ica,prob,kurt);
        end

    elseif strcmp(run_mode,'reproduce')
        
        files_fdt = dir([SOURCEDATAPATH,'*.fdt']);
        files_set = dir([SOURCEDATAPATH,'*.set']);
        files_mat = dir([SOURCEDATAPATH,'*.mat']);
        
        for s = 1:size(incl_subj,2)
        copyfile([SOURCEDATAPATH, files_fdt(s).name], [DATAPATH, files_fdt(s).name]);
        copyfile([SOURCEDATAPATH, files_set(s).name], [DATAPATH, files_set(s).name]);
        copyfile([SOURCEDATAPATH, files_mat(s).name], [DATAPATH, files_mat(s).name]);
        end

    end
    
%% Visually Inspect ICs and Reject Artefactual Components %%%%%%%%%%%%%%%%%
    PATHIN_ICLABEL = DATAPATH;
    PATHOUT_ICLABEL = DATAPATH;
    
    for s = 1:size(incl_subj,2)
        load_name_iclabel = ['sub-', incl_subj{s}, '_ica_tmp', ext_ica];
        load_name_imported = [MAINPATH,BIDS_dataset_name,filesep,'sub-',incl_subj{s},...
                filesep,'eeg',filesep,'sub-',incl_subj{s},...
                '_task-AttendedSpeakerParadigmOwnName_eeg'];
        save_name_iclabel = ['sub-', incl_subj{s}, '_badcomps_removed', ext_ica];

            bjh_03_iclabel(PATHIN_ICLABEL,PATHOUT_ICLABEL,load_name_iclabel,load_name_imported,...
                save_name_iclabel,incl_subj{s},run_mode);
    end    
    
%% Filter (and Rereference) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    low_edge_erp = 0.1;
    high_edge_erp = 10;
    ext_filt_erp = ['_lp_',num2str(high_edge_erp),'_hp_',num2str(low_edge_erp)];
    low_edge_xcorr = 1;
    high_edge_xcorr = 15;
    ext_filt_xcorr = ['_reref_lp_',num2str(high_edge_xcorr),'_hp_',num2str(low_edge_xcorr)];
    PATHIN_FILT = DATAPATH;
    PATHOUT_FILT = DATAPATH;
    
    for s = 1:size(incl_subj,2)
        load_name_filt = ['sub-', incl_subj{s}, '_badcomps_removed', ext_ica];
        save_name_filt_erp = ['sub-', incl_subj{s}, '_filtered', ext_ica, ext_filt_erp];    
        save_name_filt_xcorr = ['sub-', incl_subj{s}, '_filtered', ext_ica, ext_filt_xcorr]; 
        
            bjh_04_filter_lp_hp(PATHIN_FILT,PATHOUT_FILT,load_name_filt,save_name_filt_erp,low_edge_erp,high_edge_erp);   
            bjh_04_reref_and_filter_lp_hp(PATHIN_FILT,PATHOUT_FILT,load_name_filt,save_name_filt_xcorr,low_edge_xcorr,high_edge_xcorr);  
    end

    

%% NAME - ERP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add Control Events %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PATHIN_CONTROL = DATAPATH;
    PATHOUT_CONTROL = DATAPATH;
    
    for s = 1:size(incl_subj,2)
        load_name_control = ['sub-', incl_subj{s}, '_filtered', ext_ica, ext_filt_erp];
        save_name_control = ['sub-', incl_subj{s}, '_control_words_added', ext_ica, ext_filt_erp];
        
            bjh_05_add_control_events(PATHIN_CONTROL,PATHOUT_CONTROL,STIMPATH,...
                load_name_control,save_name_control,attended_ch(str2double(incl_subj{s})),...
                con_order{str2double(incl_subj{s})});
    end
    
%% Epoch and Reject Artefactual Epochs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ep_start = -0.5;
    ep_end = 1.5;
    ext_ep = ['_eps_', num2str(ep_start), '_epe_', num2str(ep_end)];
    PATHIN_EP_NAME_ERP = DATAPATH;
    PATHOUT_EP_NAME_ERP = DATAPATH;
    
    for s = 1:size(incl_subj,2)
        load_name_ep_name_erp = ['sub-', incl_subj{s}, '_control_words_added', ext_ica, ext_filt_erp];
        save_name_ep_name_erp = ['sub-', incl_subj{s}, '_epoch_rejected', ext_ica, ext_filt_erp, ext_ep];
    
            bjh_05_tbt(PATHIN_EP_NAME_ERP,PATHOUT_EP_NAME_ERP,...
                load_name_ep_name_erp,save_name_ep_name_erp,ep_start,ep_end);
    end

%% Create Data Struct - Name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PATHIN_STRUCT_NAME_ERP = DATAPATH;
    PATHOUT_STRUCT_NAME_ERP = DATAPATH;
    load_name_struct_name_erp = ['_epoch_rejected',ext_ica,ext_filt_erp,ext_ep];
    save_name_struct_name_erp = ['name_erp_struct',ext_ica,ext_filt_erp,ext_ep];
    
        bjh_06_create_struct_name_erp(PATHIN_STRUCT_NAME_ERP,PATHOUT_STRUCT_NAME_ERP,...
            STIMPATH,load_name_struct_name_erp,save_name_struct_name_erp,...
            incl_subj,con_order);

%% Exctract P3 Amplitudes and Latencies %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p3_min = 500; % minimum of P3 time window
    p3_max = 1200; % maximum of P3 time window
    smoothwin = 100; % in ms
    ampwin = 100; % in ms
    PATHIN_P3_AMP_LAT = DATAPATH;
    PATHOUT_P3_AMP_LAT = DATAPATH;
    ext_p3 = ['_ampwin_', num2str(ampwin)];
    load_name_p3_amp_lat = save_name_struct_name_erp;
    save_name_p3_amp_lat = ['p3_amp_lat', ext_ica,ext_filt_erp,ext_ep,ext_p3]; 
                  
        bjh_08_get_p3_amp_lat(PATHIN_P3_AMP_LAT,PATHOUT_P3_AMP_LAT,load_name_p3_amp_lat,...
            save_name_p3_amp_lat,p3_min,p3_max,smoothwin,ampwin);
        
%% Plotting ERP - Name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    PATHIN_PLOT_NAME_ERP = DATAPATH;
    PATHOUT_PLOT_NAME_ERP = DATAPATH;
    load_name_plot_name_erp = save_name_struct_name_erp;
    save_name_plot_name_erp = ['name_erp',ext_ica,ext_filt_erp,ext_ep]; 
    load_name_plot_p3_amp_lat = save_name_p3_amp_lat;
    save_name_plot_p3_amp_lat = ['p3_amp_lat',ext_ica,ext_filt_erp,ext_ep]; 
        
    %%% ERPs %%%
        %%% Conditions Separate %%%
            % Figure 7 (inset) %
            bjh_09_plot_name_erp_cond_sep(PATHIN_PLOT_NAME_ERP,PATHOUT_PLOT_NAME_ERP,...
                load_name_plot_name_erp,save_name_plot_name_erp,smoothwin);
        
        %%% Conditions Pooled and Detected Names ~ P3 Amplitude%%%
            % Grand Average % 
            % Figure 3 %
            bjh_09_plot_name_erp_cond_pool(PATHIN_PLOT_NAME_ERP,PATHOUT_PLOT_NAME_ERP,...
                load_name_plot_name_erp,load_name_plot_p3_amp_lat,...
                save_name_plot_name_erp,p3_min,p3_max,smoothwin);
            
    %%% P3 Amplitude and Latency %%%
        %%% Conditions Separate %%% 
            % Single Subject % 
            % Figure 7 % 
            bjh_09_plot_p3_amp_p3_lat_det_name_cond_sep(PATHIN_P3_AMP_LAT,...
                PATHOUT_P3_AMP_LAT,load_name_plot_p3_amp_lat,...
                save_name_plot_p3_amp_lat);
            
            

%% NAME - CROSS - CORRELATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create segments relative to name onsets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    segsize = 5; % in sec (30 needs to be devisible by that number without rest)
    namecut = 0.6; % data from name onset to namecut (in s) is cut out
    PATHIN_SEG_XCORR_NAME = DATAPATH;
    PATHOUT_SEG_XCORR_NAME = DATAPATH;
    ext_seg_name = ['_segsize_', num2str(segsize),'_cut_end_',num2str(namecut)];
    load_name_seg_xcorr_name = ['_filtered', ext_ica, ext_filt_xcorr];
    save_name_seg_xcorr_name = ['xcorr_name_seg_struct',ext_ica,ext_filt_xcorr,ext_seg_name];

        bjh_06_create_struct_seg_xcorr_name(PATHIN_SEG_XCORR_NAME,PATHOUT_SEG_XCORR_NAME,...
            STIMPATH,load_name_seg_xcorr_name,...
            save_name_seg_xcorr_name,incl_subj,attended_ch,segsize,namecut);
        
%% Cross-correlate segments relative to name onset %%%%%%%%%%%%%%%%%%%%%%%%
    max_lag = 500; % in samples
    PATHIN_XCORR_NAME = DATAPATH;
    PATHOUT_XCORR_NAME = DATAPATH;
    load_name_xcorr_name = save_name_seg_xcorr_name;
    save_name_xcorr_name = ['xcorr_name_struct',ext_ica,ext_filt_xcorr,ext_seg_name];
    
        bjh_07_create_struct_xcorr_name(PATHIN_XCORR_NAME,PATHOUT_XCORR_NAME,load_name_xcorr_name,...
            save_name_xcorr_name,max_lag);   
        
%% Plot cross-correlation relative to name onset %%%%%%%%%%%%%%%%%%%%%%%%%%
    xlim_ms = [-150,500]; % limits of displayed cross-correlation functions
    PATHIN_PLOT_XCORR_NAME = DATAPATH;
    PATHOUT_PLOT_XCORR_NAME = DATAPATH;
    load_name_plot_xcorr_name = save_name_xcorr_name;
    save_name_plot_xcorr_name = ['xcorr_name',ext_ica,ext_filt_xcorr,ext_seg_name];
    
    % CC Magnitude (values averaged over time lags) relative to name onset (time course and boxplot)
    % Figure 5
    bjh_09_plot_xcorr_name_cond_pool(PATHIN_PLOT_XCORR_NAME,PATHOUT_PLOT_XCORR_NAME,...
        load_name_plot_xcorr_name,save_name_plot_xcorr_name);
    
    % P3 Amp ~ CC Magnitude Diff (Att) ~ CC Magnitude Diff (Unatt)
    % Figure 6 (3D)
    bjh_09_plot_xcorr_name_att_diff_unatt_diff_p3_amp_cond_pool_3d(PATHIN_PLOT_XCORR_NAME,...
        PATHOUT_PLOT_XCORR_NAME,load_name_plot_xcorr_name,save_name_p3_amp_lat,...
        save_name_plot_xcorr_name);
        
    % GFP 500 Diff (Omni and Beam separately)
    % Supplementary Figure 2
    bjh_09_plot_xcorr_name_att_diff_unatt_diff_cond_sep(PATHIN_PLOT_XCORR_NAME,...
        PATHOUT_PLOT_XCORR_NAME,load_name_plot_xcorr_name,...
        save_name_plot_xcorr_name,con_order);

  
  
%% CROSS - CORRELATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create Segments Struct (Speech Envelope and EEG) %%%%%%%%%%%%%%%%%%%%%%%
    % Segments unrelated to name onsets %    
    PATHIN_SEG_XCORR = DATAPATH;
    PATHOUT_SEG_XCORR = DATAPATH;
    ext_seg = ['_segsize_', num2str(segsize)];
    load_name_seg_xcorr = ['_filtered', ext_ica, ext_filt_xcorr];
    save_name_seg_xcorr = ['xcorr_seg_struct',ext_ica,ext_filt_xcorr,ext_seg];
    
        bjh_06_create_struct_seg_xcorr(PATHIN_SEG_XCORR,PATHOUT_SEG_XCORR,STIMPATH,...
            load_name_seg_xcorr,save_name_seg_xcorr,incl_subj,attended_ch,segsize);
        
%% Perform Cross-Correlation (save results as struct) %%%%%%%%%%%%%%%%%%%%%
    % Segments unrelated to name onsets %  
    PATHIN_XCORR = DATAPATH;
    PATHOUT_XCORR = DATAPATH;
    load_name_xcorr = save_name_seg_xcorr;
    save_name_xcorr = ['xcorr_struct',ext_ica,ext_filt_xcorr,ext_seg];
    
        bjh_07_create_struct_xcorr(PATHIN_XCORR,PATHOUT_XCORR,STIMPATH,...
            load_name_xcorr,save_name_xcorr,max_lag);
    
%% Plotting (Cross-Correlation) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % Segments unrelated to name onsets %  
    PATHIN_PLOT_XCORR = DATAPATH;
    PATHOUT_PLOT_XCORR = DATAPATH;
    load_name_plot_xcorr = save_name_xcorr;
    save_name_plot_xcorr = ['xcorr',ext_ica,ext_filt_xcorr,ext_seg];
        
        % CC magnitude (attend, unattend, control)
        % Figure 4 
        bjh_09_plot_xcorr_cond_pool(PATHIN_PLOT_XCORR,PATHOUT_PLOT_XCORR,...
                load_name_plot_xcorr,save_name_plot_xcorr,xlim_ms);
