 % This script averages data from C3 and C4 channels to create one single data point
 % per subject, this signal of aproximately 60 seconds, is divided in chuncks, 12 chunks
 % of 5 seconds each. This is for the UNM data set.
 
 % This script averages data from C3 and C4 channels to create one single data point
 % per subject, this signal of aproximately 180 seconds, is divided in chuncks, 36 chunks
 % of 5 seconds each. This is for the UCSD data set.

clc
datalocation='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\UCSD_Dataset\data_processed\on_med\';   % Data are here
savedir='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\UCSD_Dataset\C3&C4_channels_data\on_med\'; % Data go here

myDir = datalocation;
myFiles = dir(fullfile(myDir,'*.mat'));	% Added closing parenthese!

for k = 1:length(myFiles)
	baseFileName = myFiles(k).name;
	fullFileName = fullfile(myDir, baseFileName);  % Changed myFolder to myDir
    load(fullFileName);
    
    index = zeros(1,2);
    for i = 1:length(EEG.chanlocs)
        chan_name = EEG.chanlocs(i).labels;
        if strcmp(chan_name,'C3')
            index(1) = i;
        end
        if strcmp(chan_name,'C4')
            index(2) = i;
        end
    end
    
    if index(1) == 0
        index(1) = index(2);
    end
    
    if index(2) == 0
        index(2) = index(1);
    end
    
    if index(1)==0 && index(2)==0
        index(1)=7;
        index(2)=21;
    end
    
    EEG.data=EEG.data(index,:,:);
    %Average between channels C3 and C4
    dataMat = EEG.data;
    dataMat_0 = zeros(1,length(EEG.data));
    for i=1:length(dataMat)
        dataMat_0(1,i)=(dataMat(1,i)+dataMat(2,i))/2;
    end
    
    num = 36; %How many divisions the original signal has
    chunks = reshape(dataMat_0(1:floor(numel(dataMat_0)/num)*num),[],num);
    chunk_size = size(chunks);
    newdataMat = zeros(1, length(chunks));
    for j=1:chunk_size(2)
        newdataMat = chunks(:,j);
        save([savedir,'chunk',num2str(j),'_',baseFileName],'newdataMat');
    end
end