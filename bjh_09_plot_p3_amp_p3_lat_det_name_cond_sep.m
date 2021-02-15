function bjh_09_plot_p3_amp_p3_lat_det_name_cond_sep(PATHIN,PATHOUT,load_name,save_name)
%% plots boxplots for P3 amplitude, P3 latency and detected names (for each condition separately)
% input:    PATHIN:         [string] path from which .mat files will be loaded
%           PATHOUT:        [string] path in which .png files will be stored
%           load_name:      [string] name of .mat file to be loaded 
%           save_name:      [string] name of .png file to be saved 
% 
% author: Bjoern Holtze
% date: 21.05.2020 
    
    %%% load name_struct %%%
    load([PATHIN, load_name, '.mat']);
    
    %%% Plotting %%%
    pure_lila = [0.4940, 0.1840, 0.5560];
    pure_lila_0_5 = [190,150,206]/255;
    pure_green = [0.4660, 0.6740, 0.1880];
    pure_green_0_5 = [186,213,151]/255;
    
    
%%% P3 Amplitude %%%

    % Wilcoxon signed rank test (one-sided)
    [p_det_name,~,z_det_name] = signrank([p3_amp_lat_struct.name_quest(cellfun(@str2num, p3_amp_lat_struct.incl_subj)).omni],...
        [p3_amp_lat_struct.name_quest(cellfun(@str2num, p3_amp_lat_struct.incl_subj)).beam],...
        'tail','right','method','approximate');
    % Wilcoxon signed rank test (one-sided)
    [p_p3_amp,~,z_p3_amp] = signrank(p3_amp_lat_struct.p3_amp_omni,p3_amp_lat_struct.p3_amp_beam,...
        'tail','right','method','approximate');
    % Wilcoxon signed rank test (one-sided)
    [p_p3_lat,~,z_p3_lat] = signrank(p3_amp_lat_struct.p3_lat_omni,p3_amp_lat_struct.p3_lat_beam,...
        'tail','left','method','approximate');
    
    % Boxplot Detected Names % 
    h_easy_diff = figure('Units', 'centimeters', 'Position', [1 2 18 7]);
    h_det_name = subplot(1,3,1); % h_det_name is of type axes
    set(h_det_name,'Parent',h_easy_diff,'Unit','centimeters');
    h_det_name.Position(1) = 2;
    h_det_name.Position(3) = 3.5;
    boxplot(cat(1,[p3_amp_lat_struct.name_quest(cellfun(@str2num, p3_amp_lat_struct.incl_subj)).omni],...
        [p3_amp_lat_struct.name_quest(cellfun(@str2num, p3_amp_lat_struct.incl_subj)).beam])','Colors',...
        cat(1,pure_lila,pure_green));  
    set(findobj(h_det_name,'type','line'),'LineWidth',1);
    boxes = findobj(h_det_name,'Tag','Box');
    box_col = [pure_green_0_5;pure_lila_0_5];
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),box_col(b,:),'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(1,...
        [p3_amp_lat_struct.name_quest(cellfun(@str2num, p3_amp_lat_struct.incl_subj)).omni],...
        [p3_amp_lat_struct.name_quest(cellfun(@str2num, p3_amp_lat_struct.incl_subj)).beam]),...
        'color','k','linestyle',':');
    set(h_det_name, 'Children',h_det_name.Children([24,22,23,1:21]));
    h_det_name.XTickLabel = {'higher','lower'};
    h_det_name.XLabel.String = 'Name Intelligibility';
    h_det_name.XLabel.FontSize = 9;
    h_det_name.YTickLabel = 0:10:80;
    h_det_name.YLabel.String = 'Detected Names [%]';
    h_det_name.YLabel.FontSize = 9;
    h_det_name.YLim = [-0.5,8.5];
    s_det_name = significant_stars(p_det_name);
    sig_txt_det_name = text(1.5,7.75,s_det_name);
    sig_txt_det_name.HorizontalAlignment = 'center';
  
    
    % Boxplot P3 Amp %
    h_amp = subplot(1,3,2); % h_amp is of type axes
    set(h_amp,'Parent',h_easy_diff,'Unit','centimeters');
    h_amp.Position(1) = 2 * 2 + 3.5;
    h_amp.Position(3) = 3.5;
    boxplot(cat(2,p3_amp_lat_struct.p3_amp_omni,p3_amp_lat_struct.p3_amp_beam),'Colors',...
        cat(1,pure_lila,pure_green));  
    set(findobj(h_amp,'type','line'),'LineWidth',1);
    boxes = findobj(h_amp,'Tag','Box');
    box_col = [pure_green_0_5;pure_lila_0_5];
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),box_col(b,:),'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(2,p3_amp_lat_struct.p3_amp_omni,...
        p3_amp_lat_struct.p3_amp_beam)','color','k','linestyle',':');
    set(h_amp, 'Children',h_amp.Children([24,22,23,1:21]));
    h_amp.XTickLabel = {'higher','lower'};
    h_amp.XLabel.String = 'Name Intelligibility';
    h_amp.XLabel.FontSize = 9;
    h_amp.YLim = [-15,32];
    h_amp.YTick = h_amp.YTick(end-6:end);
    h_amp.YLabel.String = 'P3 Amplitude [\muV]';
    h_amp.YLabel.FontSize = 9;
    
    s_h_amp = significant_stars(p_p3_amp);
    sig_txt_amp = text(1.5,28,s_h_amp);
    sig_txt_amp.HorizontalAlignment = 'center';
    
    % Boxplot P3 Lat %
    h_lat = subplot(1,3,3);
    set(h_lat,'Parent',h_easy_diff,'Unit','centimeters');
    h_lat.Position(1) = 2 * 3 + 7;
    h_lat.Position(3) = 3.5;
    boxplot(cat(2,p3_amp_lat_struct.p3_lat_omni,p3_amp_lat_struct.p3_lat_beam),'Colors',...
        cat(1,pure_lila,pure_green));  
    set(findobj(h_lat,'type','line'),'LineWidth',1);
    boxes = findobj(h_lat,'Tag','Box');
    box_col = [pure_green_0_5;pure_lila_0_5];
    for b = 1:size(boxes,1)
    patch(get(boxes(b),'XData'),get(boxes(b),'YData'),box_col(b,:),'EdgeColor','none','FaceAlpha',1);
    end
    hold on;
    line(cat(2,ones(21,1),ones(21,1)+1)',cat(2,p3_amp_lat_struct.p3_lat_omni,...
        p3_amp_lat_struct.p3_lat_beam)','color','k','linestyle',':');
    set(h_lat, 'Children',h_lat.Children([24,22,23,1:21]));
    h_lat.XTickLabel = {'higher','lower'};
    h_lat.XLabel.String = 'Name Intelligibility';
    h_lat.XLabel.FontSize = 9;
    h_lat.YLabel.String = 'P3 Latency [ms]';
    h_lat.YLabel.FontSize = 9;
    h_lat.YLim = [490,1350];
    s_h_lat = significant_stars(p_p3_lat);
    sig_txt_lat = text(1.5,1275,s_h_lat);
    sig_txt_lat.HorizontalAlignment = 'center';
    
    annotation('textbox',[0.06 0.89 0.1 0.1],'String','A','FontSize',10,'EdgeColor','none');
    annotation('textbox',[0.365 0.89 0.1 0.1],'String','B','FontSize',10,'EdgeColor','none');
    annotation('textbox',[0.655, 0.89, 0.1, 0.1],'String','C','FontSize',10,'EdgeColor','none');

    saveas(gcf, [PATHOUT, save_name, '_cond_sep_det_name_P3_amp_lat.png']);
    saveas(gcf, [PATHOUT, save_name, '_cond_sep_det_name_P3_amp_lat.svg']);
    close;
 


    
    
end