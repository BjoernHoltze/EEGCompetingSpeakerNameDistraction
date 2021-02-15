function bjh_05_add_control_events(PATHIN,PATHOUT,STIMPATH,load_name,save_name,att_ch,c_order)
%% adds events of control words (nouns at the end of a sentence)
% input:    PATHIN:         [string] path from which .set files will be loaded
%           PATHOUT:        [string] path in which .set file will be stored
%           STIMPATH:       [string] path from which contro_time.mat will be loaded
%           load_name:      [string] name of .set file to be loaded
%           save_name:      [string] name of .set to be stored
%           att_ch:         [double] story that the participant needed to attend
%           c_order:        [string] order in which conditions were presented
%
% author: Björn Holtze
% date: 04.02.2021
    
    % load filtered data
    EEG = pop_loadset([PATHIN,load_name,'.set']);
        
%%%%%% Add Control Event Markers %%%%%%
    load([STIMPATH, 'control_time.mat']);
    control_block = 1;
    
    for m = 1:size(EEG.event,2) 
        m_exist = size(EEG.event,2); 
            
        %%%%%% Control Word %%%%%%
        % There is no control word in the first block, therefore, 
        % don't consider the first "StartTrigger"
        if strcmp(EEG.event(m).type,'StartTrigger') ...
                && m ~= find(strcmp({EEG.event.type},"StartTrigger"),1)
    
            if att_ch == 1
                for col = 1:size(control_time_c2,2)
                    EEG.event(m_exist+col).latency = EEG.event(m).latency + ...
                        round(control_time_c2(control_block,col)* EEG.srate);
                    EEG.event(m_exist+col).duration = 1;
                    if strcmp(c_order(control_block),'O')
                        EEG.event(m_exist+col).type = 'control_omni';
                    elseif strcmp(c_order(control_block),'B')
                        EEG.event(m_exist+col).type = 'control_beam';
                    end
                end
            elseif att_ch == 2
                for col = 1:size(control_time_c1,2)
                    EEG.event(m_exist+col).latency = EEG.event(m).latency + ...
                        round(control_time_c1(control_block,col)* EEG.srate);
                    EEG.event(m_exist+col).duration = 1;
                    if strcmp(c_order(control_block),'O')
                        EEG.event(m_exist+col).type = 'control_omni';
                    elseif strcmp(c_order(control_block),'B')
                        EEG.event(m_exist+col).type = 'control_beam';
                    end
                end   
            end
            control_block = control_block + 1;
        end
    end

    % sort the events by latency 
    EEG = pop_editeventvals(EEG,'sort',{'latency', 0});

    % add setname
    EEG.setname = save_name;
    
    % save dataset in data_out_path
    pop_saveset(EEG, [PATHOUT, EEG.setname, '.set']);


end

