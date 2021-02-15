function bjh_09_plot_xcorr_name_att_diff_unatt_diff_p3_amp_cond_pool_3d(PATHIN,PATHOUT,load_name,load_name_p3,save_name)
%% plots relation between GFP 500 Diff (Attend), GFP 500 Diff (Unattend) and P3 amplitude as a 3D plot
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which figure will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           load_name_p3:   [string] name of .mat file containing info about P3 amplitude
%           save_name:      [string] name of figure to be stored
%           
% 
% author: Bjoern Holtze
% date: 16.09.2020

    % load xcorr_struct
    load([PATHIN,load_name,'.mat']);
    load([PATHIN,load_name_p3,'.mat']);
    
    % convert samples of lag into ms
    lag_ms = xcorr_struct.lag*(1000/500);
    
    % generate single-subject GFP of the cross-correlation functions
    gfp_cc_attend = squeeze(std(mean(xcorr_struct.attend,5),1,3));
    gfp_cc_unattend = squeeze(std(mean(xcorr_struct.unattend,5),1,3));    
    
    % calculate mean GFP from 0 to 500 ms time lag per participant
    gfp_cc_attend_mean_500 = mean(gfp_cc_attend(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    gfp_cc_unattend_mean_500 = mean(gfp_cc_unattend(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    
    % caluclate mean GFP 500 difference from before to after name
    gfp_cc_attend_mean_500_diff = gfp_cc_attend_mean_500(:,7)-gfp_cc_attend_mean_500(:,6);
    gfp_cc_unattend_mean_500_diff = gfp_cc_unattend_mean_500(:,7)-gfp_cc_unattend_mean_500(:,6);    
    
    [r_att_unatt, p_att_unatt] = corr(gfp_cc_attend_mean_500_diff,gfp_cc_unattend_mean_500_diff);
    [r_att_p3, p_att_p3] = corr(gfp_cc_attend_mean_500_diff,p3_amp_lat_struct.p3_amp_cond_pool);
    [r_unatt_p3, p_unatt_p3] = corr(gfp_cc_unattend_mean_500_diff,p3_amp_lat_struct.p3_amp_cond_pool);
    
    %%% 3D Plot %%%
    h_fig_3d = figure('Units','centimeters','Position',[22,6,18,9]);    
    h_ax_3d = subplot(1,2,1);
    set(h_ax_3d,'Parent',h_fig_3d,'Unit','centimeters');
    cm = colormap(h_ax_3d,parula(round(max(p3_amp_lat_struct.p3_amp_cond_pool))));
    for d = 1:size(p3_amp_lat_struct.p3_amp_cond_pool,1)
        dp(d) = stem3(gfp_cc_attend_mean_500_diff(d), gfp_cc_unattend_mean_500_diff(d),...
            p3_amp_lat_struct.p3_amp_cond_pool(d));
        hold(h_ax_3d,'on');
        cm_idx = round(p3_amp_lat_struct.p3_amp_cond_pool(d));
        set(dp(d), 'Color',cm(cm_idx,:), 'MarkerFaceColor',cm(cm_idx,:), 'MarkerEdgeColor',cm(cm_idx,:));
    end
    h_ax_3d.Position = [2,1.7,6.8,7];
    h_ax_3d.XLim = [-0.004,0.01];
    h_ax_3d.XTick = h_ax_3d.XLim(1):0.002:h_ax_3d.XLim(2);
    h_ax_3d.YLim = [-0.004,0.02];
    h_ax_3d.YTick = h_ax_3d.YLim(1):0.004:h_ax_3d.YLim(2);
    h_ax_3d.ZLim = [0,22];
    h_ax_3d.XAxis.FontSize = 8;
    h_ax_3d.YAxis.FontSize = 8;
    h_ax_3d.ZAxis.FontSize = 8;
    h_ax_3d.XLabel.String = ['Cross-Correlation',newline, 'Magnitude Change',...
        newline, '(to-be-attended)'];
    h_ax_3d.XLabel.FontSize = 8;
    h_ax_3d.XLabel.HorizontalAlignment = 'center';
    h_ax_3d.XLabel.Position = [0.0040,-0.0066,-2.9];
    h_ax_3d.YLabel.String = ['Cross-Correlation',newline, 'Magnitude Change',...
        newline, '(to-be-ignored)'];
    h_ax_3d.YLabel.FontSize = 8;
    h_ax_3d.YLabel.HorizontalAlignment = 'center';
    h_ax_3d.YLabel.Position = [-0.0074,0.0051,-4.1159];
    h_ax_3d.ZLabel.String = 'P3 Amplitude [\muV]';
    h_ax_3d.ZLabel.FontSize = 8;
    h_ax_3d.View = [-25,30];
    
    x = gfp_cc_attend_mean_500_diff;
    y = gfp_cc_unattend_mean_500_diff;
    z = p3_amp_lat_struct.p3_amp_cond_pool;

    B = [x(:) y(:) ones(size(x(:)))] \ z(:);
    xv = linspace(min(x), max(x), 10)';
    yv = linspace(min(y), max(y), 10)';
    [X,Y] = meshgrid(xv, yv);
    Z = reshape([X(:), Y(:), ones(size(X(:)))] * B, numel(xv), []);
    mesh(X, Y, Z, 'FaceAlpha', 0.5);
    
    h_corr = subplot(1,2,2);
    set(h_corr,'Parent',h_fig_3d);
    h_corr.Visible = 'off';
    txt_p3_amp  = text(0.85,0.5,'P3 Amplitude [\muV]','FontSize',8);
    txt_p3_amp.HorizontalAlignment = 'center';
    txt_cc_att  = text(0.3,0.2,['Cross-Correlation',newline, 'Magnitude Change',...
        newline, '(to-be-attended)'],'FontSize',8);
    txt_cc_att.HorizontalAlignment = 'center';
    txt_cc_unatt  = text(0.3,0.8,['Cross-Correlation',newline, 'Magnitude Change',...
        newline, '(to-be-ignored)'],'FontSize',8);
    txt_cc_unatt.HorizontalAlignment = 'center';
    txt_r_p3_amp_cc_att = text(0.675,0.35,['r = ',num2str(round(r_att_p3,2)),...
        significant_stars(p_att_p3)],'FontSize',8);
    txt_r_p3_amp_cc_att.HorizontalAlignment = 'center';
    txt_r_p3_amp_cc_unatt = text(0.675,0.65,['r = ',num2str(round(r_unatt_p3,2)),...
        significant_stars(p_unatt_p3)],'FontSize',8);
    txt_r_p3_amp_cc_unatt.HorizontalAlignment = 'center';
    txt_r_cc_att_cc_unatt = text(0.3,0.5,['r = ',num2str(round(r_att_unatt,2))],...
        'FontSize',8);
    txt_r_cc_att_cc_unatt.HorizontalAlignment = 'center';
    
    annotation('textbox',[0.05,0.88,0.1,0.1],'String','A','FontSize',10,'EdgeColor','none');
    annotation('textbox',[0.57,0.88,0.1,0.1],'String','B','FontSize',10,'EdgeColor','none');

    saveas(gcf, [PATHOUT, save_name, '_cond_pool_att_diff_unatt_diff_p3_amp_3d_figure.svg']);
    saveas(gcf, [PATHOUT, save_name, '_cond_pool_att_diff_unatt_diff_p3_amp_3d_figure.png']);
    close;
    
end

