function bjh_09_plot_xcorr_cond_pool(PATHIN,PATHOUT,load_name,save_name,xlim_ms)
%% plots GFP functions of segments not time-locked to name (conditions pooled)
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which figure will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           save_name:      [string] name of figure to be stored
%           xlim_ms:        [number] limits of x-axis (in ms)
%           
% 
% author: Bjoern Holtze
% % date: 26.05.2020

    % load xcorr_struct
    load([PATHIN,load_name,'.mat']);
    
    % generate single-subject GFP functions of the cross-correlation function
    gfp_cc_attend = squeeze(std(mean(reshape(xcorr_struct.attend(:,:,:,:,2:5),[21,49,1001,480]),4),1,2));
    gfp_cc_unattend = squeeze(std(mean(reshape(xcorr_struct.unattend(:,:,:,:,2:5),[21,49,1001,480]),4),1,2));
    gfp_cc_control = squeeze(std(mean(reshape(xcorr_struct.control(:,:,:,:,2:5),[21,49,1001,480]),4),1,2));
    
    % calculate GFP 500 for attended and unattended (for individuals)
    gfp_500_attend_ind = mean(gfp_cc_attend(:,xcorr_struct.lag_ms >= 0 & ...
        xcorr_struct.lag_ms <= 500),2);
    gfp_500_unattend_ind = mean(gfp_cc_unattend(:,xcorr_struct.lag_ms >= 0 & ...
        xcorr_struct.lag_ms <= 500),2);
    gfp_500_control_ind = mean(gfp_cc_control(:,xcorr_struct.lag_ms >= 0 & ...
        xcorr_struct.lag_ms <= 500),2);
    [p_att_unatt,~,z_att_unatt] = signrank(gfp_500_attend_ind,gfp_500_unattend_ind,...
        'tail','right','method','approximate');
    [p_att_contr,~,z_att_contr] = signrank(gfp_500_attend_ind,gfp_500_control_ind,...
        'tail','right','method','approximate');
    [p_unatt_contr,~,z_unatt_contr] = signrank(gfp_500_unattend_ind,gfp_500_control_ind,...
        'tail','right','method','approximate');
    
    % Colors
    pure_red = [0.8500, 0.3250, 0.0980];  
    pure_blue = [0,0.4470,0.7410]; 
    
    % define window of interest for plotting
    lag_ms_win_log = xcorr_struct.lag_ms>=xlim_ms(1) & xcorr_struct.lag_ms<=xlim_ms(2);
    
    
    % find minimum and maximum GFP values of grand average (define ylim as +/- 10%)
    [y_max_att, y_max_att_i] = max(mean(gfp_cc_attend(:,xcorr_struct.lag_ms >= 100 & ...
        xcorr_struct.lag_ms <= 200),1));
    y_max_att_i = find(xcorr_struct.lag_ms == 100) + y_max_att_i - 1;
    [y_max_unatt, y_max_unatt_i] = max(mean(gfp_cc_unattend(:,xcorr_struct.lag_ms >= 0 & ...
        xcorr_struct.lag_ms <= 100),1));
    y_max_unatt_i = find(xcorr_struct.lag_ms == 0) + y_max_unatt_i - 1;
    ylim_max = max([y_max_att,y_max_unatt])*1.2;
    abs_max = [-0.012,0.012];  

    % plotting %
    fig_gfp = figure('Units', 'centimeters', 'Position', [22 6 18 7]);
    ax_cc_magn = subplot(2,9,[1:5,10:14]);
    set(ax_cc_magn,'Parent',fig_gfp,'Units','centimeters','FontName', 'Arial');
    cc_magn_att = plot(xcorr_struct.lag_ms(lag_ms_win_log),squeeze(mean(gfp_cc_attend(:,lag_ms_win_log),1)),...
        'color',pure_red,'LineWidth',1);
    hold on;
    cc_magn_unatt = plot(xcorr_struct.lag_ms(lag_ms_win_log),squeeze(mean(gfp_cc_unattend(:,lag_ms_win_log),1)),...
        'color',pure_blue,'LineWidth',1);
    cc_magn_control  = plot(xcorr_struct.lag_ms(lag_ms_win_log),squeeze(mean(gfp_cc_control(:,lag_ms_win_log),1)),...
        'color',[0.5,0.5,0.5],'LineWidth',1);
    cc_magn_att_se = ciplot(squeeze(mean(gfp_cc_attend(:,lag_ms_win_log),1))-squeeze(std(gfp_cc_attend(:,lag_ms_win_log),1,1)./sqrt(21)),...
        squeeze(mean(gfp_cc_attend(:,lag_ms_win_log),1))+squeeze(std(gfp_cc_attend(:,lag_ms_win_log),1,1)./sqrt(21)),...
        xcorr_struct.lag_ms(lag_ms_win_log),pure_red,0.5);
    cc_magn_att_se.EdgeColor = 'none';
    cc_magn_unatt_se = ciplot(squeeze(mean(gfp_cc_unattend(:,lag_ms_win_log),1))-squeeze(std(gfp_cc_unattend(:,lag_ms_win_log),1,1)./sqrt(21)),...
        squeeze(mean(gfp_cc_unattend(:,lag_ms_win_log),1))+squeeze(std(gfp_cc_unattend(:,lag_ms_win_log),1,1)./sqrt(21)),...
        xcorr_struct.lag_ms(lag_ms_win_log),pure_blue,0.5);
    cc_magn_unatt_se.EdgeColor = 'none';
    cc_magn_control_se = ciplot(squeeze(mean(gfp_cc_control(:,lag_ms_win_log),1))-squeeze(std(gfp_cc_control(:,lag_ms_win_log),1,1)./sqrt(21)),...
        squeeze(mean(gfp_cc_control(:,lag_ms_win_log),1))+squeeze(std(gfp_cc_control(:,lag_ms_win_log),1,1)./sqrt(21)),...
        xcorr_struct.lag_ms(lag_ms_win_log),[0.5,0.5,0.5],0.5);
    cc_magn_control_se.EdgeColor = 'none';
    ax_cc_magn.XAxis.FontSize = 8;
    ax_cc_magn.XLim = xlim_ms;
    ax_cc_magn.XLabel.String = 'Time Lag [ms]';
    ax_cc_magn.YAxis.FontSize = 8;
    ax_cc_magn.YLim = [0,ylim_max];
    ax_cc_magn.YLabel.String = 'Cross-Correlation Magnitude [a.u.]';
    line_zero = line([0,0],[0,ylim_max],'Color','k');
    line_zero.LineWidth = 0.1;
    line_max_unatt = line([xcorr_struct.lag_ms(y_max_unatt_i),xcorr_struct.lag_ms(y_max_unatt_i)],...
        [0,ylim_max],'Color','k','LineStyle',':');
    line_max_att = line([xcorr_struct.lag_ms(y_max_att_i),xcorr_struct.lag_ms(y_max_att_i)],...
        [0,ylim_max],'Color','k','LineStyle',':');
    txt_legend_att = text(300,0.00975,'\color[rgb]{0.8500,0.3250,0.0980}to-be-attended');
    txt_legend_att.FontSize = 8;
    txt_legend_att.FontWeight = 'normal';
    txt_legend_att.HorizontalAlignment = 'center';
    txt_legend_unatt = text(300,0.00525,'\color[rgb]{0,0.4470,0.7410}to-be-ignored');
    txt_legend_unatt.FontSize = 8;
    txt_legend_unatt.FontWeight = 'normal';
    txt_legend_unatt.HorizontalAlignment = 'center';
    txt_legend_control = text(300,0.00175,'\color[rgb]{0.5,0.5,0.5}control');
    txt_legend_control.FontSize = 8;
    txt_legend_control.FontWeight = 'normal';
    txt_legend_control.HorizontalAlignment = 'center';
    ax_cc_magn.Children = ax_cc_magn.Children(end:-1:1);
    ax_cc_magn.Position = [1.5,1.25,8,5];
    
    annotation('textbox',[0.52,0.65,0.1,0.1],'String',...
        [num2str(xcorr_struct.lag_ms(y_max_unatt_i)),' ms'],...
        'FontSize',8,'EdgeColor','none');
    annotation('textbox',[0.52,0.3,0.1,0.1],'String',...
        [num2str(xcorr_struct.lag_ms(y_max_att_i)),' ms'],...
        'FontSize',8,'EdgeColor','none');
    annotation('textbox',[0.0025,0.89,0.1,0.1],'String','A','FontSize',10,'EdgeColor','none');
    annotation('textbox',[0.575,0.89,0.1,0.1],'String','B','FontSize',10,'EdgeColor','none');

    saveas(gcf, [PATHOUT, save_name, '_cond_pool_lines.svg']);
    saveas(gcf, [PATHOUT, save_name, '_cond_pool_lines.png']);
    close;
    
    % plot separate figure for topographies (due to image resolution)
    fig_gfp = figure('Units', 'centimeters', 'Position', [22 6 18 7]);
    ax_cc_magn = subplot(2,9,[1:5,10:14]);
    set(ax_cc_magn,'Parent',fig_gfp,'Units','centimeters','visible','off');
   
    % 50 ms
    % Attend
    tp_1 = subplot(2,9,6);
    set(tp_1,'Units','centimeters');
    topoplot(mean(mean(mean(xcorr_struct.attend(:,:,y_max_unatt_i,:,:),5),4),1),xcorr_struct.chanlocs,...
        'maplimits',abs_max);
    set(tp_1.Children(2:5), 'LineWidth', 1);
    tp_1.Children(1).MarkerSize = 4;
    
    % Unattend
    tp_2 = subplot(2,9,7);
    set(tp_2,'Units','centimeters');
    topoplot(mean(mean(mean(xcorr_struct.unattend(:,:,y_max_unatt_i,:,:),5),4),1),xcorr_struct.chanlocs,...
        'maplimits',abs_max);
    set(tp_2.Children(2:5), 'LineWidth', 1);
    tp_2.Children(1).MarkerSize = 4;
    
    tp_3 = subplot(2,9,8);
    set(tp_3,'Units','centimeters');
    topoplot(mean(mean(mean(xcorr_struct.control(:,:,y_max_unatt_i,:,:),5),4),1),xcorr_struct.chanlocs,...
        'maplimits',abs_max);
    set(tp_3.Children(2:5), 'LineWidth', 1);
    tp_3.Children(1).MarkerSize = 4;
    
    % 158 ms
    % Attend
    tp_4 = subplot(2,9,15);
    set(tp_4,'Units','centimeters');
    topoplot(mean(mean(mean(xcorr_struct.attend(:,:,y_max_att_i,:,:),5),4),1),xcorr_struct.chanlocs,...
        'maplimits',abs_max);
    set(tp_4.Children(2:5), 'LineWidth', 1);
    tp_4.Children(1).MarkerSize = 4;
    
    % Unattend
    tp_5 = subplot(2,9,16);
    set(tp_5,'Units','centimeters');
    topoplot(mean(mean(mean(xcorr_struct.unattend(:,:,y_max_att_i,:,:),5),4),1),xcorr_struct.chanlocs,...
        'maplimits',abs_max);
    set(tp_5.Children(2:5), 'LineWidth', 1);
    tp_5.Children(1).MarkerSize = 4;
    
    tp_6 = subplot(2,9,17);
    set(tp_6,'Units','centimeters');
    topoplot(mean(mean(mean(xcorr_struct.control(:,:,y_max_unatt_i,:,:),5),4),1),xcorr_struct.chanlocs,...
        'maplimits',abs_max);
    set(tp_6.Children(2:5), 'LineWidth', 1);
    tp_6.Children(1).MarkerSize = 4;
    
    ax_cb = subplot(2,9,18);
    ax_cb.CLim = abs_max;
    ax_cb.Visible = 'off';
    cb = colorbar(ax_cb);
    cb.Units = 'centimeters';
    cb.Box = 'off';   
    cb.Ticks = [abs_max(1),0,abs_max(2)];
    cb.TickLabels{2} = '[a.u.]';
    cb.FontSize = 8;
    cb.Position = [16.7,1.65,0.15,1.65];
    
    tp_1.Position = [10.5,3.2,1.3672,2.3902];
    tp_1.Position([3,4]) = [1.3672,2.3902]*1.3;
    tp_2.Position = [12.6,3.2,1.3672,2.3902];
    tp_2.Position([3,4]) = [1.3672,2.3902]*1.3;
    tp_3.Position = [14.7,3.2,1.3672,2.3902];
    tp_3.Position([3,4]) = [1.3672,2.3902]*1.3;
    tp_4.Position = [10.5,0.9,1.3672,2.3902];
    tp_4.Position([3,4]) = [1.3672,2.3902]*1.3;
    tp_5.Position = [12.6,0.9,1.3672,2.3902];
    tp_5.Position([3,4]) = [1.3672,2.3902]*1.3;
    tp_6.Position = [14.7,0.9,1.3672,2.3902];
    tp_6.Position([3,4]) = [1.3672,2.3902]*1.3; 
    
    saveas(gcf, [PATHOUT, save_name, '_cond_pool_topo.svg']);
    saveas(gcf, [PATHOUT, save_name, '_cond_pool_topo.png']);
    close;
    
end
