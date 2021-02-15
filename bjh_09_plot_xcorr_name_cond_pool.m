function bjh_09_plot_xcorr_name_cond_pool(PATHIN,PATHOUT,load_name,save_name)
%% plots GFP 500 values relative to name (grand average and single-subject, conditions pooled)
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which figure will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           save_name:      [string] name of figure to be stored
% 
% author: Bjoern Holtze
% date: 26.05.2020
    
    % load xcorr_struct
    load([PATHIN,load_name,'.mat']);
    
    % generate single-subject GFP functions of the cross-correlation function
    gfp_cc_attend = squeeze(std(mean(xcorr_struct.attend,5),1,3));
    gfp_cc_unattend = squeeze(std(mean(xcorr_struct.unattend,5),1,3));    
    
    % convert samples of lag into ms
    lag_ms = xcorr_struct.lag*(1000/500);
    
    % calculate mean GFP from 0 to 500 ms time lag per participant
    gfp_cc_attend_mean_500 = mean(gfp_cc_attend(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    gfp_cc_unattend_mean_500 = mean(gfp_cc_unattend(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    
    % create data structure for analysis in R
    subj_ID = xcorr_struct.incl_subj';
    att_before = gfp_cc_attend_mean_500(:,6);
    att_after = gfp_cc_attend_mean_500(:,7);
    unatt_before = gfp_cc_unattend_mean_500(:,6);
    unatt_after = gfp_cc_unattend_mean_500(:,7);
    
    gfp_500_rel_to_name = table(subj_ID,att_before,att_after,unatt_before,unatt_after);
    writetable(gfp_500_rel_to_name,[PATHOUT, save_name,'_gfp_500_relative_to_name.txt'],'Delimiter',';');
    
    % Wilcoxon signed rank test (attended)
    [p_gfp_500_att,~,z_gfp_500_att] = signrank(gfp_cc_attend_mean_500(:,7),...
        gfp_cc_attend_mean_500(:,6),'method','approximate');

    % Wilcoxon signed rank test (unattended)
    [p_gfp_500_unatt,~,z_gfp_500_unatt] = signrank(gfp_cc_unattend_mean_500(:,7),...
        gfp_cc_unattend_mean_500(:,6),'method','approximate');
    
    pure_blue = [0,0.4470,0.7410];
    pure_red = [0.8500, 0.3250, 0.0980];    
    
    seg_centers = (xcorr_struct.edges(1:13)+xcorr_struct.edges(2:14))/2;

    % plotting %
    h_fig_gfp = figure('Units', 'centimeters', 'Position', [22.5 3 18 16]);
    h_ax_gfp = subplot(2,2,[1,2]);
    set(h_ax_gfp,'Parent',h_fig_gfp,'Unit','centimeters');
    h_att = plot(h_ax_gfp,seg_centers([1:6,8:13]),mean(gfp_cc_attend_mean_500,1),...
        '.-','color',pure_red,'MarkerSize',20);
    hold on;
    h_unatt = plot(h_ax_gfp,seg_centers([1:6,8:13]),mean(gfp_cc_unattend_mean_500,1),...
        '.-','color',pure_blue,'MarkerSize',20);
    h_error_att = errorbar(seg_centers([1:6,8:13]),mean(gfp_cc_attend_mean_500,1),...
        std(gfp_cc_attend_mean_500,1,1)./sqrt(21),'color',pure_red);
    h_error_unatt = errorbar(seg_centers([1:6,8:13]),mean(gfp_cc_unattend_mean_500,1),...
        std(gfp_cc_unattend_mean_500,1,1)./sqrt(21),'color',pure_blue);
    h_ax_gfp.XLabel.String = 'Time [s]';
    h_ax_gfp.XLabel.FontSize = 9; 
    h_ax_gfp.XTick = xcorr_struct.edges([1:7,9:14]);
    h_ax_gfp.XLim = [-30,30.6];
    h_ax_gfp.YLabel.String = 'Cross-Correlation Magnitude [a.u.]';
    h_ax_gfp.YLabel.FontSize = 9;
    h_ax_gfp.YLim = [0.009, 0.017];
    h_ax_gfp.YAxis.Exponent = -3;
    h_rectangle = rectangle('Parent',h_ax_gfp,'Position',[0,h_ax_gfp.YLim(1),...
        0.6,h_ax_gfp.YLim(2)-h_ax_gfp.YLim(1)]);
    h_rectangle.EdgeColor = 'none';
    h_rectangle.FaceColor = [211,211,211]/255;
    h_txt_name = text('Parent',h_ax_gfp,'String','Name','Position',[-1,0.014]);
    h_txt_name.Rotation = 90;
    h_txt_name.FontSize = 9;
    h_txt_name.Color = [128,128,128]/255;
    h_txt_before = text('Parent',h_ax_gfp,'String','Before','Position',[-2.5,0.0095],...
        'FontSize',9,'Color',[128,128,128]/255);
    h_txt_before.HorizontalAlignment = 'center';
    h_txt_after = text('Parent',h_ax_gfp,'String','After','Position',[3.1,0.0095],...
        'FontSize',9,'Color',[128,128,128]/255);
    h_txt_after.HorizontalAlignment = 'center';
    h_line1 = line('Parent',h_ax_gfp,'XData',[-5,-5],'YData',[h_ax_gfp.YLim(1),h_ax_gfp.YLim(2)]);
    h_line1.LineStyle = ':';
    h_line2 = line('Parent',h_ax_gfp,'XData',[5.6,5.6],'YData',[h_ax_gfp.YLim(1),h_ax_gfp.YLim(2)]);
    h_line2.LineStyle = ':';
    h_ax_gfp.Children = h_ax_gfp.Children([end-1,end,1:end-2]);
    h_ax_gfp.Clipping = 'off';
    h_patch_att = patch(h_ax_gfp,[-5,-30,-4,5.6],[h_ax_gfp.YLim(1),0.0059,0.0059,h_ax_gfp.YLim(1)],[0,0,0]);
    h_patch_att.FaceAlpha = 0.03;
    h_patch_att.EdgeColor = 'none';
    h_patch_unatt = patch(h_ax_gfp,[-5,4.4,30.6,5.6],[h_ax_gfp.YLim(1),0.0059,0.0059,h_ax_gfp.YLim(1)],[0,0,0]);
    h_patch_unatt.FaceAlpha = 0.03;
    h_patch_unatt.EdgeColor = 'none';
    txt_legend_att = text(23,0.0143,'\color[rgb]{0.8500,0.3250,0.0980}to-be-attended');
    txt_legend_att.FontSize = 9;
    txt_legend_att.FontWeight = 'normal';
    txt_legend_att.HorizontalAlignment = 'center';
    txt_legend_unatt = text(23,0.01,'\color[rgb]{0,0.4470,0.7410}to-be-ignored');
    txt_legend_unatt.FontSize = 9;
    txt_legend_unatt.FontWeight = 'normal';
    txt_legend_unatt.HorizontalAlignment = 'center';
   
    
    
    h_ax_att = subplot(2,2,3);
    set(h_ax_att,'Parent',h_fig_gfp,'Unit','centimeters');
    boxplot(cat(2,gfp_cc_attend_mean_500(:,6),gfp_cc_attend_mean_500(:,7)),'Colors',pure_red); 
    set(findobj(h_ax_att,'type','line'),'LineWidth',1);
    boxes = findobj(h_ax_att,'Tag','Box');
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),[1,1,1],'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(2,gfp_cc_attend_mean_500(:,6),...
        gfp_cc_attend_mean_500(:,7))','color','k','linestyle',':');
    set(h_ax_att, 'Children',h_ax_att.Children([24,22,23,1:21]));
    h_ax_att.YLim = [0.006,0.028];
    h_ax_att.YTick = 0.005:0.002:0.028;
    h_ax_att.YAxis.Exponent = -3;
    ylabel('Cross-Correlation Magnitude [a.u.]','FontSize',9);
    xticklabels({'Before','After'});
    h_ax_att.XLabel.String = 'Name';
    h_ax_att.XLabel.FontSize = 9;
    h_outlier = findobj(h_ax_att,'tag','Outliers');
    h_outlier(2).Marker = 'o';
    h_outlier(2).MarkerFaceColor = pure_red;
    h_outlier(2).MarkerEdgeColor = 'none';
    h_outlier(2).MarkerSize = 2;
    h_ax_att.Title.String = '\color[rgb]{0.8500,0.3250,0.0980}to-be-attended';
    s_att = significant_stars(p_gfp_500_att);
    sig_txt_att = text(h_ax_att,1.5,0.025,s_att);
    sig_txt_att.HorizontalAlignment = 'center';
    
    h_ax_unatt = subplot(2,2,4);
    set(h_ax_unatt,'Parent',h_fig_gfp,'Unit','centimeters');
    boxplot(cat(2,gfp_cc_unattend_mean_500(:,6),gfp_cc_unattend_mean_500(:,7)),'Colors',pure_blue);
    set(findobj(h_ax_unatt,'type','line'),'LineWidth',1);
    boxes = findobj(h_ax_unatt,'Tag','Box');
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),[1,1,1],'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(2,gfp_cc_unattend_mean_500(:,6),...
        gfp_cc_unattend_mean_500(:,7))','color','k','linestyle',':');
    set(h_ax_unatt, 'Children',h_ax_unatt.Children([24,22,23,1:21]));
    h_ax_unatt.YLim = [0.006,0.028];
    h_ax_unatt.YTick = 0.005:0.002:0.028;
    h_ax_unatt.YAxis.Exponent = -3;
    xticklabels({'Before','After'});
    h_ax_unatt.XLabel.String = 'Name';
    h_ax_unatt.XLabel.FontSize = 9;
    h_ax_unatt.Title.String = '\color[rgb]{0,0.4470,0.7410}to-be-ignored';
    s_unatt = significant_stars(p_gfp_500_unatt);
    sig_txt_unatt = text(h_ax_unatt,1.5,0.025,s_unatt);
    sig_txt_unatt.HorizontalAlignment = 'center';
    
    annotation('textbox',[0.075,0.89,0.1,0.1],'String','A','FontSize',10,'EdgeColor','none');
    annotation('textbox',[0.075,0.41,0.1,0.1],'String','B','FontSize',10,'EdgeColor','none');
    
    saveas(gcf, [PATHOUT, save_name, '_cond_pool_grand_average_and_single_subject_gfp_500.svg']);
    saveas(gcf, [PATHOUT, save_name, '_cond_pool_grand_average_and_single_subject_gfp_500.png']);
    close;
 
end
