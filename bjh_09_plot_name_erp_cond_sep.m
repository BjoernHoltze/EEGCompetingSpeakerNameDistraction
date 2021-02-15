function bjh_09_plot_name_erp_cond_sep(PATHIN,PATHOUT,load_name,save_name,smoothwin)
%% plots the grand average P3 topographies (conditions separate)
% input:    PATHIN:         [string] path from which .mat file will be loaded
%           PATHOUT:        [string] path in which figures will be stored
%           load_name:      [string] name of .mat files to be loaded 
%           save_name:      [string] name of figures to be saved 
%           smoothwin:      [double] time window for movmean in ms
%
% author: Bjoern Holtze
% date: 20.05.2020
    
    %%% load name_struct %%%
    load([PATHIN, load_name, '.mat']);
    
    %%% identify channels %%%
    Pz = find(strcmp({name_struct.chanlocs.labels},'E04'));	

    omni_erps_smooth = movmean(name_struct.data_o(:,:,:),(smoothwin/1000)*name_struct.srate,3);
    beam_erps_smooth = movmean(name_struct.data_b(:,:,:),(smoothwin/1000)*name_struct.srate,3);
    
    %%% Minimum and Maximum Amplitudes in Grand Average ERP %%%
    min_val_name_o_vs_b = min(min(mean(omni_erps_smooth(:,Pz,:),1)),min(mean(beam_erps_smooth(:,Pz,:),1)));
    max_val_name_o_vs_b = max(max(mean(omni_erps_smooth(:,Pz,:),1)),max(mean(beam_erps_smooth(:,Pz,:),1)));
    map_limit_name_o_vs_b = max(abs(min_val_name_o_vs_b),abs(max_val_name_o_vs_b));

        
    %%% Omnidirectional and Beamforming (P3 Topography) %%%
    % inset for figure 7 %
    [~, omni_p3_i] = max(squeeze(mean(omni_erps_smooth(:,Pz,:),1)));
    [~, beam_p3_i] = max(squeeze(mean(beam_erps_smooth(:,Pz,:),1)));

    f_p3_topo = figure;
    set(f_p3_topo, 'Units', 'centimeters', 'Position', [0.5 1.5 10 5]);
    % subplot 1 - omni P3 topography
    h_p3_topo_omni = subplot(1,3,1);
    set(h_p3_topo_omni,'Parent',f_p3_topo,'Unit','centimeters');
    topoplot(mean(omni_erps_smooth(:,:,omni_p3_i),1),...
        name_struct.chanlocs,'maplimits',...
        [-map_limit_name_o_vs_b,map_limit_name_o_vs_b],...
        'electrodes','off','emarker2',{Pz,'.','k',30,1});

    % subplot 2 - colobar
    min_volt_p3 = min(min(mean(omni_erps_smooth(:,:,omni_p3_i),1)),...
        min(mean(beam_erps_smooth(:,:,beam_p3_i),1)));
    max_volt_p3 = max(max(mean(omni_erps_smooth(:,:,omni_p3_i),1)),...
        max(mean(beam_erps_smooth(:,:,beam_p3_i),1)));
    ax_cb = subplot(1,3,2);
    ax_cb.CLim = [-max_volt_p3,max_volt_p3];
    ax_cb.Visible = 'off';   
    cb = colorbar(ax_cb);
    cb.Limits = [round(min_volt_p3,1),round(max_volt_p3,1)];
    cb.Units = 'centimeters';
    cb.Box = 'off';   
    cb.Ticks = [0,4,8];
    cb.TickLabels{2} = '\muV';

    % subplot 3 - beam P3 topography 
    h_p3_topo_beam = subplot(1,3,3);
    set(h_p3_topo_beam,'Parent',f_p3_topo,'Unit','centimeters');
    topoplot(mean(beam_erps_smooth(:,:,beam_p3_i),1),...
        name_struct.chanlocs,'maplimits',...
        [-map_limit_name_o_vs_b,map_limit_name_o_vs_b],...
        'electrodes','off','emarker2',{Pz,'.','k',30,1});

    h_p3_topo_omni.Position([3,4]) = h_p3_topo_omni.Position([3,4])*1.8;
    h_p3_topo_omni.Position([1,2]) = [0.25,-1.25];
    h_p3_topo_omni.Children(2).LineWidth = 2;
    h_p3_topo_omni.Children(3).LineWidth = 2;
    h_p3_topo_omni.Children(4).LineWidth = 2;
    h_p3_topo_omni.Children(5).LineWidth = 2;
    h_p3_topo_omni.Children(7).Visible = 'off';
    cb.Position = [4.3,0.6,0.5,3.6];
    cb.FontSize = 20;
    cb.AxisLocation = 'in';
    h_p3_topo_beam.Position([3,4]) = h_p3_topo_beam.Position([3,4])*1.8;
    h_p3_topo_beam.Position([1,2]) = [6,-1.25];
    h_p3_topo_beam.Children(2).LineWidth = 2;
    h_p3_topo_beam.Children(3).LineWidth = 2;
    h_p3_topo_beam.Children(4).LineWidth = 2;
    h_p3_topo_beam.Children(5).LineWidth = 2;
    h_p3_topo_beam.Children(7).Visible = 'off';

    saveas(gcf, [PATHOUT, save_name,'_grand_average_P3_topo_cond_sep','.svg']);
    saveas(gcf, [PATHOUT, save_name,'_grand_average_P3_topo_cond_sep','.png']);

    close;

end