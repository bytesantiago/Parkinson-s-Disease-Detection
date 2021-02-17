clc
datalocation='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\UNM_Dataset\unpreprocessed_data\off_med\';   % Data are here
savedir='C:\Users\USER\Documents\Yachay_Tech\Thesis_Project\ParkinsonsDetection\UNM_Dataset\EEGNet_data\intra-patient\off_med\'; % Data go here

myDir = datalocation;
myFiles = dir(fullfile(myDir,'*.mat'));	% Added closing parenthese!

for k = 1:length(myFiles)
	baseFileName = myFiles(k).name;
	fullFileName = fullfile(myDir, baseFileName);  % Changed myFolder to myDir
    load(fullFileName);
    
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
    
    EEG.data = eegfilt(EEG.data,500,0.5,0);
    
    EEG.data(:,1:29000);
    
    num = 10; %How many divisions the original signal has
    index = 0;
    for j=1:num
        newdataMat = EEG.data(:,index+1:index+2900);
        index = index+2900;
        save([savedir,'chunk',num2str(j),'_',baseFileName],'newdataMat');
    end
    
%     newdataMat = EEG.data(:,1:600);
    
%     save([savedir,baseFileName],'newdataMat');
end