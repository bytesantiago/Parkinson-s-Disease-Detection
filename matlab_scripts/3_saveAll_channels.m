clc
datalocation='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\sanDiego_data_preprocessed\off_med\';   % Data are here
savedir='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\USanDiego_all_channels\off_med\'; % Data go here

myDir = datalocation;
myFiles = dir(fullfile(myDir,'*.mat'));	% Added closing parenthese!
% AVG_ON = zeros(27,29500);
% AVG_ON = zeros(15,92160);
for k = 1:length(myFiles)
	baseFileName = myFiles(k).name;
	fullFileName = fullfile(myDir, baseFileName);  % Changed myFolder to myDir
    load(fullFileName);
    
    newdataMat = zeros(1,length(EEG.data));
    
    for i = 1:length(EEG.chanlocs)
       newdataMat(1,:) = EEG.data(i,:);
       chan_name = EEG.chanlocs(i).labels;
       save([savedir,chan_name,'_',baseFileName],'newdataMat');
    end      
end