function bjh_09_plot_xcorr_name_att_diff_unatt_diff_cond_sep(PATHIN,PATHOUT,load_name,save_name,con_order)
%% plots GFP differences from before to after the name separately for each condition
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which figure will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           save_name:      [string] name of figure to be stored
%           con_order       [string] condition order of all participants
%           
% 
% author: Bjoern Holtze
% date: 26.05.2020
    
    % load xcorr_struct
    load([PATHIN,load_name,'.mat']);
    
    % separate crosscorr functions for omni and beam condition
    for s = 1:size(xcorr_struct.incl_subj,2)
        if strcmp(con_order{str2num(xcorr_struct.incl_subj{s})},'OBOB')
            cc_attend_omni(s,:,:,:,:) = xcorr_struct.attend(s,:,:,:,[1:10,21:30]);
            cc_attend_beam(s,:,:,:,:) = xcorr_struct.attend(s,:,:,:,[11:20,31:40]);
            cc_unattend_omni(s,:,:,:,:) = xcorr_struct.unattend(s,:,:,:,[1:10,21:30]);
            cc_unattend_beam(s,:,:,:,:) = xcorr_struct.unattend(s,:,:,:,[11:20,31:40]);
        elseif strcmp(con_order{str2num(xcorr_struct.incl_subj{s})},'BOBO')
            cc_attend_omni(s,:,:,:,:) = xcorr_struct.attend(s,:,:,:,[11:20,31:40]);
            cc_attend_beam(s,:,:,:,:) = xcorr_struct.attend(s,:,:,:,[1:10,21:30]);
            cc_unattend_omni(s,:,:,:,:) = xcorr_struct.unattend(s,:,:,:,[11:20,31:40]);
            cc_unattend_beam(s,:,:,:,:) = xcorr_struct.unattend(s,:,:,:,[1:10,21:30]);
        end
    end
    
    % generate single-subject GFP functions of the crosscorr function
    gfp_cc_attend_omni = squeeze(std(mean(cc_attend_omni,5),1,3));
    gfp_cc_attend_beam = squeeze(std(mean(cc_attend_beam,5),1,3));
    gfp_cc_unattend_omni = squeeze(std(mean(cc_unattend_omni,5),1,3));
    gfp_cc_unattend_beam = squeeze(std(mean(cc_unattend_beam,5),1,3));
    
    % convert samples of lag into ms
    lag_ms = xcorr_struct.lag*(1000/500);
    
    % calculate mean GFP from 0 to 500 ms time lag per participant
    gfp_cc_attend_omni_mean_500 = mean(gfp_cc_attend_omni(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    gfp_cc_attend_beam_mean_500 = mean(gfp_cc_attend_beam(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    gfp_cc_unattend_omni_mean_500 = mean(gfp_cc_unattend_omni(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    gfp_cc_unattend_beam_mean_500 = mean(gfp_cc_unattend_beam(:,:,lag_ms >= 0 & lag_ms <= 500),3);
    
    % calculate difference from before to after name occurrence
    gfp_cc_attend_omni_mean_500_diff = gfp_cc_attend_omni_mean_500(:,7)-gfp_cc_attend_omni_mean_500(:,6);
    gfp_cc_attend_beam_mean_500_diff = gfp_cc_attend_beam_mean_500(:,7)-gfp_cc_attend_beam_mean_500(:,6);
    gfp_cc_unattend_omni_mean_500_diff = gfp_cc_unattend_omni_mean_500(:,7)-gfp_cc_unattend_omni_mean_500(:,6);
    gfp_cc_unattend_beam_mean_500_diff = gfp_cc_unattend_beam_mean_500(:,7)-gfp_cc_unattend_beam_mean_500(:,6);
    
    % Wilcoxon Signed Rank Test (Omni vs. Beam - Attend)
    [p_gfp_500_diff_att_ovb,~,z_att] = signrank(gfp_cc_attend_omni_mean_500_diff,...
        gfp_cc_attend_beam_mean_500_diff,'method','approximate');
    % Wilcoxon Signed Rank Test (Omni vs. Beam - Unattend)
    [p_gfp_500_diff_unatt_ovb,~,z_unatt] = signrank(gfp_cc_unattend_omni_mean_500_diff,...
        gfp_cc_unattend_beam_mean_500_diff,'method','approximate');
    
    pure_lila = [0.4940, 0.1840, 0.5560];
    pure_lila_0_5 = [190,150,206]/255;
    pure_green = [0.4660, 0.6740, 0.1880];
    pure_green_0_5 = [186,213,151]/255;

    % plotting %
    h_fig = figure('Units', 'centimeters', 'Position', [22 6 18 9]);
    
    h_att = subplot(1,2,1);
    set(h_att,'Parent',h_fig,'Unit','centimeters');
    boxplot(cat(2,gfp_cc_attend_omni_mean_500_diff,gfp_cc_attend_beam_mean_500_diff),...
        'Colors',cat(1,pure_lila,pure_green));   
    hold on;
    set(findobj(h_att,'type','line'),'LineWidth',1);
    boxes = findobj(h_att,'Tag','Box');
    box_col = [pure_green_0_5;pure_lila_0_5];
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),box_col(b,:),'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(2,...
        gfp_cc_attend_omni_mean_500_diff,gfp_cc_attend_beam_mean_500_diff)',...
        'color','k','linestyle',':');
    set(h_att, 'Children',h_att.Children([24,22,23,1:21]));
    h_att.XTickLabel = {'higher','lower'};
    h_att.XLabel.String = 'Name Intelligibility';
    h_att.XLabel.FontSize = 8;
    h_att.YLabel.String = 'Cross-Correlation Magnitude Change [a.u.]';
    h_att.YLabel.FontSize = 8;
    h_att.YLabel.Position = [0.3285,0.0060,-1];
    h_att.YLim = [-0.009,0.023];
    h_att.Title.String = 'to-be-attended';
    h_att.Position = [2.5,1.5,5.5,6.5];
    s_gfp_500_diff_att_ovb = significant_stars(p_gfp_500_diff_att_ovb);
    sig_txt_att = text(1.5,0.017,s_gfp_500_diff_att_ovb);
    sig_txt_att.HorizontalAlignment = 'center';
    
    h_unatt = subplot(1,2,2);
    set(h_unatt,'Parent',h_fig,'Unit','centimeters');
    boxplot(cat(2,gfp_cc_unattend_omni_mean_500_diff,gfp_cc_unattend_beam_mean_500_diff),...
        'Colors',cat(1,pure_lila,pure_green));   
    hold on;
    set(findobj(h_unatt,'type','line'),'LineWidth',1);
    boxes = findobj(h_unatt,'Tag','Box');
    box_col = [pure_green_0_5;pure_lila_0_5];
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),box_col(b,:),'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(2,...
        gfp_cc_unattend_omni_mean_500_diff,gfp_cc_unattend_beam_mean_500_diff)',...
        'color','k','linestyle',':');
    set(h_unatt, 'Children',h_unatt.Children([24,22,23,1:21]));
    h_unatt.XTickLabel = {'higher','lower'};
    h_unatt.XLabel.String = 'Name Intelligibility';
    h_unatt.XLabel.FontSize = 8;
    h_unatt.YLabel.String = 'Cross-Correlation Magnitude Change [a.u.]';
    h_unatt.YLabel.FontSize = 8;
    h_unatt.YLabel.Position = [0.3285,0.0060,-1];
    h_unatt.YLim = [-0.009,0.023];
    h_unatt.Title.String = 'to-be-ignored';
    h_unatt.Position = [10.5,1.5,5.5,6.5];
    s_gfp_500_diff_unatt_ovb = significant_stars(p_gfp_500_diff_unatt_ovb);
    sig_txt_unatt = text(1.5,0.017,s_gfp_500_diff_unatt_ovb);
    sig_txt_unatt.HorizontalAlignment = 'center';
    
    annotation('textbox',[.0875 .89 .1 .1],'String','A','FontSize',10,'EdgeColor','none');
    annotation('textbox',[.53 .89 .1 .1],'String','B','FontSize',10,'EdgeColor','none');

    
    saveas(gcf, [PATHOUT, save_name, '_cond_sep_gfp_mean_500_ss.png']);
    saveas(gcf, [PATHOUT, save_name, '_cond_sep_gfp_mean_500_ss.svg']);
    close;
 
end
