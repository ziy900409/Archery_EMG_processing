clc, close all, clear
% Hsin Yang, 20211127

%% step 1: parameter setting
% setting folder path
FolderPath = 'D:\NTSU\TenLab\Archery\Archery_20211118\RawData';
ProcessData_file = 'D:\NTSU\TenLab\Archery\Archery_20211118\ProcessingData\AfterFilting';
% filter setting
% band pass filter setting
order = 4;                                              
BandPass_lowcutoff = 20;
BandPass_highcutoff = 450;
% low pass filter setting
LowPass_cutoff = 2.5;

SampleRate = 2000;
SampleRate1 = 2000;

%% input path of parent folder
% Raw data
Raw_FolderList = dir(FolderPath);
Raw_FolderList = Raw_FolderList(~ismember({Raw_FolderList.name}, {'.', '..'}));
%% step2: data pre-processing
for i = 1: length(Raw_FolderList)
    % dir back all '*.CSV' files
    Raw_FileList = dir(strcat(FolderPath, '\', Raw_FolderList(i).name, '\', '*.csv'));
    % set MVC matrix
    MVC_of_Muscle = {};
    
    
    for ii = 1:length(Raw_FileList)
        % read data seperatly
        ds = tabularTextDatastore(strcat(Raw_FileList(i).folder, '\',...
            Raw_FileList(ii).name));
        % assign data
        Raw_Data = readtable(string(ds.Files));
        % setting specific column to caculate
        Raw_EMGdata = Raw_Data(:, [2 10 18 26 34 42 50]);
 
        % bandpass filter
        % 4th-order Butterworth bandpass filter
        % with a lower cutoff frequency of 20 Hz and a higher cutoff frequency of 450 Hz
        % Specify a sample rate of 2000 Hz
        [A,B,C,D] = butter(10,[BandPass_lowcutoff BandPass_highcutoff]/...
            (SampleRate/2));
        sos = ss2sos(A,B,C,D);
        bEMGdata.Variables = sosfilt(sos, Raw_EMGdata.Variables);

        % Wave rectification
        bEMGdata.Variables = abs(bEMGdata.Variables);

        % linear enveploe analysis
        % bandpass filter
        % 2th-order Butterworth lowpass filter
        % with a cutoff frequency of 6 Hz Specify a sample rate of 2000 Hz
        [E,F,G] = butter(2, LowPass_cutoff/(SampleRate/2));
        sos1 = zp2sos(E,F,G);
        bEMGdata.Variables = sosfilt(sos1,bEMGdata.Variables);
        Raw_Data(:, [2 10 18 26 34 42 50]).Variables = bEMGdata.Variables;
        
        % key in MVC matrix
        % find maximum values in EMG data
        Max_R_Trapezius = string(max(Raw_Data(:, 2).Variables));
        Max_R_Deltoid = string(max(Raw_Data(:, 10).Variables));
        Max_R_Extensor = string(max(Raw_Data(:, 18).Variables));
        Max_R_Flexor = string(max(Raw_Data(:, 26).Variables));
        Max_L_Trapezius = string(max(Raw_Data(:, 34).Variables));
        Max_L_Deltoid = string(max(Raw_Data(:, 42).Variables));
        Max_L_Triceps = string(max(Raw_Data(:, 50).Variables));
        
        MVC_of_Muscle(ii, :) = {Raw_FolderList(i).name, Raw_FileList(ii).name,...
            Max_R_Trapezius, Max_R_Deltoid, Max_R_Extensor, Max_R_Flexor,...
            Max_L_Trapezius, Max_L_Deltoid, Max_L_Triceps};
        
        % write the data after processing
        writetable(Raw_Data, strcat(ProcessData_file, '\', Raw_FolderList(i).name, ...
            '\ed_', Raw_FileList(ii).name))
    end
    % set MVC matrix headerline
    MVC_of_Muscle_Headerline = {'SubjectNumber', 'FileName',...
        'R_Trapezius', 'R_Deltoid', 'R_Extensor', 'R_Flexor',...
        'L_Trapezius', 'L_Deltoid', 'L_Triceps'};
    MVC_of_Muscle_out = [MVC_of_Muscle_Headerline; MVC_of_Muscle];
    % write MVC matris
    writecell(MVC_of_Muscle_out,...
        strcat('D:\NTSU\TenLab\Archery\Archery_20211118\ProcessingData',...
        '\', Raw_FolderList(i).name, '_MVC', '.csv'));
end
