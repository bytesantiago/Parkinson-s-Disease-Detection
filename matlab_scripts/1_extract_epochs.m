%This script returns two files from each original file from the original dataset.
%One file returns the Eyes closed data, and the anothor returns the eyes open data, 
% each has aproximately 1 min recording at 500Hz sampling rate
%That said, each resulting file contains aproximately 30k datapoints
%Resulting files are under the folder unpreprocessed_data

%% PD Rest
clear all; clc
datalocation='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\PD REST\';   % Data are here
savedir='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\unpreprocessed_data\'; % Data go here
cd(savedir);

PDsx=[801 802 804 805 806 807 808 809 810 811 813 814 815 816 817 818 819 820 821 822 823 824 825 826 827 828 829];
CTLsx=[894 908 8010 890 891 892 893 895 896 897 898 899 900 901 902 903 904 905 906 907 909 910 911 912 913 914 8060];

% Data are 68 chans: 1=63 is EEG, 64 is VEOG, 66-68 is XYZ accelerometer on hand (varied L or R).  
% Ref'd to CPz - - will want to retrieve that during re-referencing.  See below for code for that.
% See bottom of script for the stimulus presentation script used to collect these data

for subj=[PDsx,CTLsx]
    for session=1:2;  % ON or OFF medication.  CTL only had 1 session
        if (subj>850 && session==1) || subj<850  % If not ctl, do session 2
            if ~(exist([num2str(subj),'_',num2str(session),'_PD_REST.mat'])==2); % If it doesn't already exist
                disp(['Do Rest --- Subno: ',num2str(subj),'      Session: ',num2str(session)]); disp(' ');
                                
                % ----------Load BrainVision data
                load([datalocation,num2str(subj),'_',num2str(session),'_PD_REST.mat']);
                
                % Note: 803 S1 is bad.  Don't use.
                
                % ----------Get Locs
                locpath=('C:\Program Files\MATLAB\R2017b\toolbox\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp');
                pop_chanedit(EEG,    'lookup', locpath);
                eeg_checkset( EEG );
                
                % ---------- Get event types
                % All data start with 1 min of eyes closed rest:
                    % trigger 3 happens every 2 seconds
                    % trigger 4 happens every 2 seconds
                % Followed by 1 min of eyes open rest:
                    % trigger 1 happens every 2 seconds
                    % trigger 2 happens every 2 seconds
                
                            
                % Cut data
                
                EEG = pop_select( EEG,'point', [EEG.event(2).latency EEG.event(61).latency]);
                
                % ---------- Save
                save([savedir,num2str(subj),'_',num2str(session),'_EC_PD_REST.mat'],'EEG');
                
                % ----------Load BrainVision data
                load([datalocation,num2str(subj),'_',num2str(session),'_PD_REST.mat']);
                
                % Note: 803 S1 is bad.  Don't use.
                
                % ----------Get Locs
                pop_chanedit(EEG,    'lookup', locpath);
                eeg_checkset( EEG );
                
                EEG = pop_select( EEG,'point', [EEG.event(62).latency EEG.event(121).latency]);
                
                % ---------- Save
                save([savedir,num2str(subj),'_',num2str(session),'_EO_PD_REST.mat'],'EEG');
                
            end
        end
    end
end