clc;clear;
% Import raw data and masks sepertately
MainDir = '/Users/Baotian/Documents/GitHub/Junjian_MRI_project/S';
cd(MainDir)
Subjects = dir('S*');
for i = 1:length(Subjects)
    cd(Subjects(i).name)
    Sequence = dir(pwd);
    Sequence = Sequence(3:end);
    for j = 1:length(Sequence)
        cd(Sequence(j).name)
        CurrentSequence = Sequence(j).name;
        cd('L')  % Left side
        % Screening the file names
        DataFile     = dir(strcat('*',Sequence(j).name,'.nii')); 
        STNMaskFile  = dir('*STN*');
        ContrastMaskFile = dir('*Con*');
        OutBrainMaskFile = dir('*Out*');
        % Load the corresponding data
        Data         = niftiread(DataFile.name);
        STNMask      = niftiread(STNMaskFile.name);
        ContrastMask = niftiread(ContrastMaskFile.name);
        OutBrainMask = niftiread(OutBrainMaskFile.name);
        % Extract the raw data     
        STNData      = single(Data) .* single(STNMask);
        ContrastData = single(Data) .* single(ContrastMask);
        OutBrainData = single(Data) .* single(OutBrainMask);
        % Calculate the CNR
        meanSTN        = sum(sum(sum(STNData)))/sum(sum(sum(STNMask)));
        meanContrast   = sum(sum(sum(ContrastData)))/sum(sum(sum(ContrastMask)));
        OutBrainInd    = find(OutBrainData);
        STDOutBrain = nanstd(OutBrainData(OutBrainInd));
        CNR_L = abs(meanSTN)/STDOutBrain;
        cd ..
        cd('R')  % Right side
        % Screening the file names
        DataFile     = dir(strcat('*',Sequence(j).name,'.nii')); 
        STNMaskFile  = dir('*STN*');
        ContrastMaskFile = dir('*Con*');
        OutBrainMaskFile = dir('*Out*');
        % Load the corresponding data
        Data         = niftiread(DataFile.name);
        STNMask      = niftiread(STNMaskFile.name);
        ContrastMask = niftiread(ContrastMaskFile.name);
        OutBrainMask = niftiread(OutBrainMaskFile.name);
        % Extract the raw data     
        STNData      = single(Data) .* single(STNMask);
        ContrastData = single(Data) .* single(ContrastMask);
        OutBrainData = single(Data) .* single(OutBrainMask);
        % Calculate the CNR
        meanSTN        = sum(sum(sum(STNData)))/sum(sum(sum(STNMask)));
        meanContrast   = sum(sum(sum(ContrastData)))/sum(sum(sum(ContrastMask)));
        OutBrainInd    = find(OutBrainData);
        STDOutBrain = nanstd(OutBrainData(OutBrainInd));
        CNR_R = abs(meanSTN)/STDOutBrain;
        eval(strcat('CNR_L_All','(',num2str(i),')','.',Sequence(j).name,'=','CNR_L'))
        eval(strcat('CNR_R_All','(',num2str(i),')','.',Sequence(j).name,'=','CNR_R'))
        cd ..
        cd ..   
    end   
    cd ..
end

% Write the table for statistics

% For the left side
LeftCNRTable = struct2table(CNR_L_All);
LeftCNRFileName = 'LeftSNR.xlsx';
writetable(LeftCNRTable,LeftCNRFileName)

% For the right side
RightCNRTable = struct2table(CNR_R_All);
RightCNRFileName = 'RightSNR.xlsx';
writetable(RightCNRTable,RightCNRFileName)

% For both side
BothCNRMatrix(1,:,:) = table2array(LeftCNRTable);
BothCNRMatrix(2,:,:) = table2array(RightCNRTable);
BothCNRMean = squeeze(mean(BothCNRMatrix));
BothCNRTable = RightCNRTable;
BothCNRTable{:,:} = BothCNRMean;
BothCNRFileName = 'BothSNR.xlsx';
writetable(BothCNRTable,BothCNRFileName)


