function bjh_09_plot_name_erp_cond_pool(PATHIN,PATHOUT,load_name,load_name_p3_amp_lat,save_name,p3_min,p3_max,smoothwin)
%% plots the grand average ERP (both conditioned pooled, topographies included)
% input:    PATHIN:         [string] path from which name_struct files will be loaded
%           PATHOUT:        [string] path in which .png figures will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           load_name_p3_amp_lat: [string] name of file in which P3 amplitudes are stored
%           save_name:      [string] name of .png figures to be saved 
%           p3_min:         [double] lower boundary of P3 window
%           p3_max:         [double] upper boundary of P3 window
%           smoothwin:      [double] time window for movmean in ms
%
% author: Bjoern Holtze
% date: 20.05.2020    
    
    %%% load name_struct %%%
    load([PATHIN, load_name, '.mat']);
    load([PATHIN, load_name_p3_amp_lat, '.mat']);
    
    %%% identify channels %%%
    Pz = find(strcmp({name_struct.chanlocs.labels},'E04'));
    
    % smooth ERPs (omni and beam pooled)
    ob_erp_smooth = movmean(name_struct.data_ob(:,:,:),(smoothwin/1000)*name_struct.srate,3);
    % smooth control ERPs (omni and beam pooled)
    cob_erp_smooth = movmean(name_struct.data_cob(:,:,:),(smoothwin/1000)*name_struct.srate,3);
    
    % Own name vs. control word (Wilcoxon signed rank test)
    ob_erp_pz_500_1200 = mean(squeeze(ob_erp_smooth(:,Pz,name_struct.times >= p3_min &...
        name_struct.times <= p3_max)),2);
    cob_erp_pz_500_1200 = mean(squeeze(cob_erp_smooth(:,Pz,name_struct.times >= p3_min &...
        name_struct.times <= p3_max)),2);
    [p,~,z] = signrank(ob_erp_pz_500_1200,cob_erp_pz_500_1200,...
        'tail','right','method','approximate');
    
    
    %%% Minimum and Maximum Amplitudes in Grand Average ERP %%%
    min_val_name_ob = min(min(mean(ob_erp_smooth(:,Pz,:),1)));
    max_val_name_ob = max(max(mean(ob_erp_smooth(:,Pz,:),1)));
    
    %%% Define Colors %%%
    pure_blue_0_5 = [127,184,222]/255; 
    pure_blue = [0,0.4470,0.7410]; 
    
    %%%%%% Grand Average ERPs %%%%%%
    
    %%% Omni and Beam %%%
    h_fig_p3 = figure('Units', 'centimeters', 'Position', [22 10 18 8]);
    h_ax_p3 = subplot(1,3,[1,2]);
    set(h_ax_p3,'Parent',h_fig_p3,'Units','centimeters','FontName', 'Arial');
    plot(name_struct.times, squeeze(mean(ob_erp_smooth(:,Pz,:),1)),'color',pure_blue,'LineWidth',1);
    hold on;
    h_ci_ob = ciplot(squeeze(mean(ob_erp_smooth(:,Pz,:),1)) - squeeze(std(ob_erp_smooth(:,Pz,:),1,1))...
        ./sqrt(size(name_struct.incl_subj,2)),...
        squeeze(mean(ob_erp_smooth(:,Pz,:),1)) + squeeze(std(ob_erp_smooth(:,Pz,:),1,1))...
        ./sqrt(size(name_struct.incl_subj,2)),...
        name_struct.times,pure_blue_0_5,0.5);
    h_ci_ob.EdgeColor = 'none';
    
    %%% Control (omni and beam)
    plot(name_struct.times, squeeze(mean(cob_erp_smooth(:,Pz,:),1)),'color',[0.5,0.5,0.5],'LineWidth',1);
    hold on;
    h_ci_cob = ciplot(squeeze(mean(cob_erp_smooth(:,Pz,:),1)) - squeeze(std(cob_erp_smooth(:,Pz,:),1,1))...
        ./sqrt(size(name_struct.incl_subj,2)),...
        squeeze(mean(cob_erp_smooth(:,Pz,:),1)) + squeeze(std(cob_erp_smooth(:,Pz,:),1,1))...
        ./sqrt(size(name_struct.incl_subj,2)),...
        name_struct.times,[0.75,0.75,0.75],0.5);
    h_ci_cob.EdgeColor = 'none';
    
    h_xl = line([0,0],[min_val_name_ob-2,max_val_name_ob+2]);
    h_xl.LineWidth = 0.5;
    h_xl.Color = [0,0,0];
    h_yl = line([-500,1500],[0,0]);
    h_yl.LineWidth = 0.5;
    h_yl.Color = [0,0,0];
    h_txt_name = text(-50,5,'Word Onset');
    h_txt_name.Rotation = 90;
    h_txt_name.FontSize = 8; 
    h_txt_name.HorizontalAlignment = 'center';
    h_ax_p3.XLabel.String = 'Time [ms]';
    h_ax_p3.XAxis.FontSize = 9;
    h_ax_p3.YLabel.String = 'Voltage [\muV]';
    h_ax_p3.YAxis.FontSize = 9;
    ylim([min_val_name_ob-2,max_val_name_ob+6]);
    h_ax_p3.YTick = h_ax_p3.YTick(1:end-2);
    xticks(-500:250:1500);
    txt_leg_name = text(1250,7.6,'\color[rgb]{0,0.4470,0.7410}Name');
    txt_leg_name.FontSize = 8;
    txt_leg_name.FontWeight = 'normal';
    txt_leg_name.HorizontalAlignment = 'left';
    txt_leg_word = text(1250,6.7,'\color[rgb]{0.5,0.5,0.5}Control');
    txt_leg_word.FontSize = 8;
    txt_leg_word.FontWeight = 'normal';
    txt_leg_word.HorizontalAlignment = 'left';
    rectangle('Position',[p3_min, 0, p3_max-p3_min, max_val_name_ob+2],...
        'EdgeColor','none','FaceColor',[pure_blue_0_5,0.1]);
    h_ax_p3.Children = h_ax_p3.Children([end,end-1,end-2,end-3,1:end-4]);
    h_ax_p3.Position = [1.5,1.25,9,6];
    
    h_ax_name_p3 = subplot(1,3,3);
    set(h_ax_name_p3,'Parent',h_fig_p3,'Units','centimeters','FontName', 'Arial');
    h_name_p3 = scatter([name_struct.name_quest(cellfun(@str2num, name_struct.incl_subj)).omni],...
        p3_amp_lat_struct.p3_amp_cond_pool,5,'MarkerEdgeColor','none','MarkerFaceColor',...
        pure_blue);
    h_ax_name_p3.Box = 'on';
    h_ax_name_p3.XLim = [-0.5,8];
    h_ax_name_p3.XLabel.String = 'Detected Names [%]';
    h_ax_name_p3.XAxis.FontSize = 9;
    h_ax_name_p3.XTickLabel = 0:20:80;
    h_ax_name_p3.YLim = [0,23];
    h_ax_name_p3.YLabel.String  = 'P3 Amplitude [\muV]';
    h_ax_name_p3.YAxis.FontSize = 9;
    lsline(h_ax_name_p3);
    h_ax_name_p3.Position = [12,1.25,5,6];
    
    annotation('textbox',[.0275 .89 .1 .1],'String','A','FontSize',10,'EdgeColor','none','FontName', 'Arial');
    annotation('textbox',[.61 .89 .1 .1],'String','B','FontSize',10,'EdgeColor','none','FontName', 'Arial');
    
    saveas(gcf, [PATHOUT, save_name,'_grand_average_cond_pool.svg']);
    saveas(gcf, [PATHOUT, save_name,'_grand_average_cond_pool.png']);
    close;

    %%%% Topogrpahies %%%
    min_erp_volt = min(min(squeeze(mean(ob_erp_smooth,1)),[],2));
    max_erp_volt = max(max(squeeze(mean(ob_erp_smooth,1)),[],2));
    h_fig_topo = figure('Units', 'centimeters', 'Position', [22 2 30 6]);
    
    tp = -250:250:1250;
    for t = 1:size(tp,2)
        h_tp(t) = subplot(1,8,t);
        topoplot(mean(ob_erp_smooth(:,:,name_struct.times == tp(t)),1),...
            name_struct.chanlocs,'maplimits',...
            [-max_erp_volt,max_erp_volt],'electrodes','off',...
            'numcontour',4);
        h_tp(t).Children(1).LineWidth = 0.5;
        h_tp(t).Children(2).LineWidth = 0.5;
        h_tp(t).Children(3).LineWidth = 0.5;
        h_tp(t).Children(4).LineWidth = 0.5;
        h_tp(t).Position(3:4) = [0.0759,0.8150]*1.1;
    end
    h_cb = subplot(1,8,8);
    set(h_cb,'Parent',h_fig_topo,'Units','centimeters');
    h_cb.Visible = 'off';
    h_cb.CLim = [-max_erp_volt,max_erp_volt];
    cb = colorbar('Units','centimeters');
    cb.Limits = [min_erp_volt,max_erp_volt];
    cb.AxisLocation = 'in';
    cb.Position = [24.5,2.25,0.45,2.2]; 
    cb.FontSize = 20;
    cb.Box = 'off';
    cb.Ticks = [-2,2,6];
    cb.TickLabels{2} = '\muV';
 
    saveas(gcf, [PATHOUT, save_name,'_grand_average_cond_pool_topo_timeline.svg']);
    saveas(gcf, [PATHOUT, save_name,'_grand_average_cond_pool_topo_timeline.png']);
    close; 

end