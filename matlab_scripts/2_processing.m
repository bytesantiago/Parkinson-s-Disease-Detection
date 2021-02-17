% This script performs the following preprocessing operations:
% Remove X,Y,Z & VEOG channels
% Remove contaminated channels
% Apply a common average reference
% Remove the mean of each channel
% HighPassFiltr at 0.5Hz

clear all; clc
%These directories are to work with UNM dataset
datalocation='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\unpreprocessed_data\control\';   % Data are here
savedir='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\preprocessed_data\control\'; % Data go here

myDir = datalocation;
myFiles = dir(fullfile(myDir,'*.mat'));	% Added closing parenthese!
%datapoints = 59000;
for k = 1:length(myFiles)
	baseFileName = myFiles(k).name;
	fullFileName = fullfile(myDir, baseFileName);  % Changed myFolder to myDir

    load(fullFileName);
    
        %% If you want, you could do some of this to make life easier:
        
    % ----------Get Locs
    locpath=('C:\Program Files\Polyspace\R2020a\toolbox\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp');
    pop_chanedit(EEG,    'lookup', locpath);
    eeg_checkset( EEG );
    
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
    % ---------- Apply highPassFilter at 0.5Hz to remove low frequency drift
    EEG.data = eegfilt(EEG.data,500,0.5,0);
    %% --------- Perform automatic artifact rejection/repair
    EEG = clean_artifacts(EEG);
    
    save([savedir,baseFileName],'EEG');
end