%%% This script performs the following preprocessing operations:
%%% Remove X,Y,Z & VEOG channels
%%% Remove contaminated channels
%%% Apply a common average reference
%%% Remove the mean of each channel
%%% HighPassFiltr at 0.5Hz

clear all; clc
% %These directories are to work with UCSD dataset
datalocation='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\sanDiego_data_unpreprocessed\';   % Data are here
savedir='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\SanDiego_data\'; % Data go here


myDir = datalocation;
myFiles = dir(fullfile(myDir,'*.bdf'));	% Added closing parenthese!
%datapoints = 59000;
for k = 1:length(myFiles)
	baseFileName = myFiles(k).name;
	fullFileName = fullfile(myDir, baseFileName);  % Changed myFolder to myDir

    EEG = pop_biosig(fullFileName);
    EEG = pop_rmbase(EEG,[],[]);
    EEG = pop_reref(EEG,[]);
    EEG.data = eegfilt(EEG.data,512,0.5,0);
    %% ---------- Remove EXG
%     EEG.EXG1=squeeze(EEG.data(33,:,:));
%     EEG.EXG2=squeeze(EEG.data(34,:,:));
%     EEG.EXG3=squeeze(EEG.data(35,:,:));
%     EEG.EXG4=squeeze(EEG.data(36,:,:));
%     EEG.EXG5=squeeze(EEG.data(37,:,:));
%     EEG.EXG6=squeeze(EEG.data(38,:,:));
%     EEG.EXG7=squeeze(EEG.data(39,:,:));
%     EEG.EXG8=squeeze(EEG.data(40,:,:));
    EEG.data=EEG.data(1:32,:,:);
    EEG.nbchan=32;
    EEG.chanlocs=EEG.chanlocs(1:32,:,:);
    %% --------- Perform automatic artifact rejection/repair
    EEG = clean_artifacts(EEG);
    %% ---------- Re-ref to average again now that the contaminated channels are gone
    EEG = pop_reref(EEG, []);
    
    save([savedir,baseFileName(1:16),'.mat'],'EEG');
end