%% PD Rest
clear all; clc
datalocation='Y:\EEG_Data\PDDys\EEG\Raw EEG Data\';   % Data are here
savedir='Y:\EEG_Data\PDDys\EEG\Processed EEG Data\REST for PREDiCT\'; % Data go here
cd(savedir);

PDsx=[801 802 803 804 805 806 807 808 809 810 811 813 814 815 816 817 818 819 820 821 822 823 824 825 826 827 828 829];
CTLsx=[894 908 8010 890 891 892 893 895 896 897 898 899 900 901 902 903 904 905 906 907 909 910 911 912 913 914 8060 8070];

% Data are 68 chans: 1=63 is EEG, 64 is VEOG, 66-68 is XYZ accelerometer on hand (varied L or R).  
% Ref'd to CPz - - will want to retrieve that during re-referencing.  See below for code for that.
% See bottom of script for the stimulus presentation script used to collect these data

for subj=[PDsx,CTLsx]
    for session=1:2;  % ON or OFF medication.  CTL only had 1 session
        if (subj>850 && session==1) || subj<850  % If not ctl, do session 2
            if ~(exist([num2str(subj),'_',num2str(session),'_PD_REST.mat'])==2); % If it doesn't already exist
                disp(['Do Rest --- Subno: ',num2str(subj),'      Session: ',num2str(session)]); disp(' ');
                                
                % ----------Load BrainVision data
                EEG = pop_loadbv(datalocation,[num2str(subj),'_',num2str(session),'_ODDBALL.vhdr']);
                
                % Note: 803 S1 is bad.  Don't use.
                
                % ----------Get Locs
                locpath=('Y:\Programs\eeglab12_0_2_1b\plugins\dipfit2.2\standard_BESA\standard-10-5-cap385.elp');
                EEG = pop_chanedit(EEG,    'lookup', locpath);
                EEG = eeg_checkset( EEG );
                
                
                % ---------- Get event types
                % All data start with 1 min of eyes closed rest:
                    % trigger 3 happens every 2 seconds
                    % trigger 4 happens every 2 seconds
                % Followed by 1 min of eyes open rest:
                    % trigger 1 happens every 2 seconds
                    % trigger 2 happens every 2 seconds
                for ai=2:length(EEG.event); temp=EEG.event(ai).type; TYPES(ai)=str2num(temp(2:end)) ; clear temp; end
                % For fun
                UNIQUE_TYPES=unique(TYPES);
                for bi=1:length(UNIQUE_TYPES); UNIQUE_TYPES_COUNT(bi)=sum(TYPES==UNIQUE_TYPES(bi)); end
                clc; TRIGGERS=[UNIQUE_TYPES;UNIQUE_TYPES_COUNT] % Trigger type, Frequency
                % OK, now find the last trigger of the restb 
                Rest_Triggers=find(TYPES<5);
                Last_Rest_Trigger=EEG.event(Rest_Triggers(end)).latency;  % Last trigger in **samples**
                Last_Rest_Trigger_ms=Last_Rest_Trigger .* (1/(EEG.srate/1000));
                Last_Rest_Trigger_Seconds=floor(Last_Rest_Trigger_ms/1000)+4;  % +4 for a little buffer
                
                % Cut data
                EEG = pop_select( EEG,'time',[0 Last_Rest_Trigger_Seconds] );

                % ---------- Make sure we have all 2 mins of rest
                clear UNIQUE* TYPES TRIGGERS
                for ai=2:length(EEG.event); temp=EEG.event(ai).type; TYPES(ai)=str2num(temp(2:end)) ; clear temp; end
                UNIQUE_TYPES=unique(TYPES);
                for bi=1:length(UNIQUE_TYPES); UNIQUE_TYPES_COUNT(bi)=sum(TYPES==UNIQUE_TYPES(bi)); end
                clc; TRIGGERS=[UNIQUE_TYPES;UNIQUE_TYPES_COUNT] % Trigger type, Frequency
                % Start the count
                N_Trigs=0;
                for ci=1:4, N_Trigs=N_Trigs+UNIQUE_TYPES_COUNT(UNIQUE_TYPES==ci); end
                if N_Trigs<120, BOOM; end  % BOOM just kills things
                
                % Note, 8070 only has a little bit of eyes closed data.
                % Must have started recording too late.  
                
                % ---------- Save
                save([savedir,num2str(subj),'_',num2str(session),'_PD_REST.mat'],'EEG');
                
                % ---------- Housekeeping
                clear EEG UNIQUE* TYPES TRIGGERS
                
            end
        end
    end
end

BOOM;

%% If you want, you could do some of this to make life easier:

% ---------- Remove X,Y,Z & VEOG
EEG.VEOG=squeeze(EEG.data(64,:,:));
EEG.X=squeeze(EEG.data(65,:,:));
EEG.Y=squeeze(EEG.data(66,:,:));
EEG.Z=squeeze(EEG.data(67,:,:));
EEG.data=EEG.data(1:63,:,:);
EEG.nbchan=63;
EEG.chanlocs(67)=[];  EEG.chanlocs(66)=[]; EEG.chanlocs(65)=[]; EEG.chanlocs(64)=[];
% ---------- Add CPz
EEG = pop_chanedit(EEG,'append',63,'changefield',{64 'labels' 'CPz'});
EEG = pop_chanedit(EEG,'lookup', locpath);
% ---------- Re-Ref to Average Ref and recover CPz
EEG = pop_reref(EEG,[],'refloc',struct('labels',{'CPz'},'type',{''},'theta',{180},'radius',{0.12662},'X',{-32.9279},'Y',{-4.0325e-15},'Z',{78.363},...
    'sph_theta',{-180},'sph_phi',{67.208},'sph_radius',{85},'urchan',{64},'ref',{''}),'keepref','on');
% ---------- Remove CONSISTENLY BAD channels now that CPz has been reconstructed from the total
EEG.MASTOIDS = squeeze(mean(EEG.data([10,21],:,:),1));
EEG.data = EEG.data([1:4,6:9,11:20,22:26,28:64],:,:);
EEG.nbchan=60;
EEG.chanlocs(27)=[];  EEG.chanlocs(21)=[];   EEG.chanlocs(10)=[];   EEG.chanlocs(5)=[];  % Have to be in this order!
% ---------- Re-ref to average again now that the contaminated channels are gone
EEG = pop_reref(EEG,[]);
% ---------- Remove mean
EEG = pop_rmbase(EEG,[],[]);

%%

%  ~ SNIP

% Experimenter instructions
Screen('TextSize',wPtr,30);
Screen('TextFont',wPtr,'Times');
Screen('TextStyle',wPtr,0);
Screen('TextColor',wPtr,[255 255 255]);
beginningText1 = 'Experimenter: Continue';
DrawFormattedText(wPtr,beginningText1,'center','center');
Screen(wPtr, 'Flip');
KbWait([],3); %Waits for keyboard(any) press

instructionText = 'Welcome and thank you for participating in our study. \n\n\n We are going to start by recording some activities \n\n of your brain activity at rest.';
DrawFormattedText(wPtr,instructionText,'center','center');
Screen(wPtr, 'Flip');
KbWait([],3); %Waits for keyboard(any) press

instructionText = 'All you need to do is sit and rest quietly. \n\n\nWe will be recording resting EEG with your eyes \n\n\n CLOSED for the next minute. \n\n\n A tone will sound to let you know when \n\nthe time is up.';
DrawFormattedText(wPtr,instructionText,'center','center');
Screen(wPtr, 'Flip');
KbWait([],3); %Waits for keyboard(any) press

% CLOSED
DrawFormattedText(wPtr,'Close Eyes','center','center'); Screen(wPtr, 'Flip'); WaitSecs(1);
for ai=1:30
    io64(ioObject,LTP1address,3);  WaitSecs(.05);  io64(ioObject,LTP1address,0); WaitSecs(.95);
    io64(ioObject,LTP1address,4);  WaitSecs(.05);  io64(ioObject,LTP1address,0); WaitSecs(.95);
end
sound(Tone(1,:),echant);

instructionText = 'Now another minute with your eyes OPEN.';
DrawFormattedText(wPtr,instructionText,'center','center');
Screen(wPtr, 'Flip');
KbWait([],3); %Waits for keyboard(any) press

% OPEN
DrawFormattedText(wPtr,' + ','center','center'); Screen(wPtr, 'Flip'); WaitSecs(1);
for ai=1:30
    io64(ioObject,LTP1address,1);  WaitSecs(.05);  io64(ioObject,LTP1address,0); WaitSecs(.95);
    io64(ioObject,LTP1address,2);  WaitSecs(.05);  io64(ioObject,LTP1address,0); WaitSecs(.95);
end
sound(Tone(1,:),echant);

%  ~ SNIP

