function bjh_08_get_p3_amp_lat(PATHIN,PATHOUT,load_name,save_name,p3_min,p3_max,smoothwin,amp_win)
%% determines the P3 amplitude and latency and stores it in a .txt file 
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which .txt files will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           save_name:      [string] name of .txt file to be saved 
%           p3_min:         [double] lower boundary of P3 time window in ms 
%           p3_max:         [double] upper boundary of P3 time window in ms
%           smoothwin:      [double] length of window for moving average filter in ms
%           amp_win:        [double] length of time window around maximum peak in P3 
%                           window from which the amplitude is averaged (ms)
% 
% author: Bjoern Holtze
% date: 21.05.2020
    
    %%% load name_struct %%%
    load([PATHIN, load_name, '.mat']);
    
    Pz = find(strcmp({name_struct.chanlocs.labels},'E04'));
    
    % transform smoothing window from ms into samples
    mov_win_samples = (smoothwin/1000)*name_struct.srate;
    
    name_erps_omni_smooth = squeeze(movmean(name_struct.data_o(:,Pz,:),mov_win_samples,3));
    name_erps_beam_smooth = squeeze(movmean(name_struct.data_b(:,Pz,:),mov_win_samples,3));
    name_erps_cond_pool_smooth = squeeze(movmean(name_struct.data_ob(:,Pz,:),mov_win_samples,3));
    
    %%% P3 Latency %%%
        % Omni % 
        [~, p3_lat_omni_i] = max(name_erps_omni_smooth(:,name_struct.times >= p3_min & name_struct.times <= p3_max),[],2);
        p3_lat_omni = name_struct.times(p3_lat_omni_i + find(name_struct.times == p3_min) -1);

        % Beam % 
        [~, p3_lat_beam_i] = max(name_erps_beam_smooth(:,name_struct.times >= p3_min & name_struct.times <= p3_max),[],2);
        p3_lat_beam = name_struct.times(p3_lat_beam_i + find(name_struct.times == p3_min) -1);

        % Conditions Pooled % 
        [~, p3_lat_cond_pool_i] = max(name_erps_cond_pool_smooth(:,name_struct.times >= p3_min & name_struct.times <= p3_max),[],2);
        p3_lat_cond_pool = name_struct.times(p3_lat_cond_pool_i + find(name_struct.times == p3_min) -1);

    
    %%% P3 Amplitudes %%%
        for s = 1:size(name_struct.incl_subj,2)
            % Omni % 
            p3_amp_omni(s) = mean(name_erps_omni_smooth(s,name_struct.times >= (p3_lat_omni(s) - amp_win/2) & ...
                name_struct.times <= (p3_lat_omni(s) + amp_win/2)));
            % Beam % 
            p3_amp_beam(s) = mean(name_erps_beam_smooth(s,name_struct.times >= (p3_lat_beam(s) - amp_win/2) & ...
                name_struct.times <= (p3_lat_beam(s) + amp_win/2)));
            % Conditions Pooled % 
            p3_amp_cond_pool(s) = mean(name_erps_cond_pool_smooth(s,name_struct.times >= (p3_lat_cond_pool(s) - amp_win/2) & ...
                name_struct.times <= (p3_lat_cond_pool(s) + amp_win/2)));
        end 
        
    %%% Create Table %%%
        incl_subj = cellfun(@str2double, name_struct.incl_subj)';
        p3_amp_omni = p3_amp_omni';
        p3_lat_omni = p3_lat_omni';
        p3_amp_beam = p3_amp_beam';
        p3_lat_beam = p3_lat_beam';
        p3_amp_cond_pool = p3_amp_cond_pool';
        p3_lat_cond_pool = p3_lat_cond_pool';
        
        p3_amp_lat_struct.p3_amp_omni = p3_amp_omni;
        p3_amp_lat_struct.p3_lat_omni = p3_lat_omni;
        p3_amp_lat_struct.p3_amp_beam = p3_amp_beam ;
        p3_amp_lat_struct.p3_lat_beam = p3_lat_beam;
        p3_amp_lat_struct.p3_amp_cond_pool = p3_amp_cond_pool;
        p3_amp_lat_struct.p3_lat_cond_pool = p3_lat_cond_pool;
        p3_amp_lat_struct.name_quest = name_struct.name_quest;
        p3_amp_lat_struct.incl_subj = name_struct.incl_subj;
        p3_amp_lat_struct.con_order = name_struct.con_order;        
        
        p3_amp_lat = table(incl_subj,p3_amp_omni,p3_lat_omni,p3_amp_beam,p3_lat_beam,p3_amp_cond_pool,p3_lat_cond_pool);
        
        save([PATHOUT, save_name,'.mat'],'p3_amp_lat_struct');
        writetable(p3_amp_lat,[PATHOUT, save_name,'.txt'],'Delimiter',';');
    
end