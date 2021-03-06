%% step 3: caculate iMVC matrix
% setting the path of working folder
% AfterFilting/MVC = iMVC
% AfterFilting 
AfterFilting_Folder = 'D:\NTSU\TenLab\Archery\Archery_20211118\ProcessingData\AfterFilting';
% MVC
MVC_file_path = 'D:\NTSU\TenLab\Archery\Archery_20211118\ProcessingData\MVC';
% iMVC
iMVC_folder = 'D:\NTSU\TenLab\Archery\Archery_20211118\ProcessingData\iMVC';
% setting Staging file
StagingFile_path = 'D:\NTSU\TenLab\Archery\Archery_20211118\Archery_Staging_20211118_finish_03.xlsx';
% due to readtable will read the NAN value from EXCEL files
opts = detectImportOptions(StagingFile_path, 'Range' , 'A1:R87');
StagingFile = readtable(StagingFile_path, opts);

% dir back Folder list from AfterFilting folder
AfterFilting_FolderList = dir(AfterFilting_Folder);
% excluding '.', '..', 'MVC' folder
AfterFilting_FolderList = AfterFilting_FolderList(~ismember({AfterFilting_FolderList.name},...
    {'.', '..', 'MVC'}));

for j = 1: length(AfterFilting_FolderList)
    % read files list from processing and mvc folder
    Processing_FileList = dir(strcat(AfterFilting_Folder, '\', AfterFilting_FolderList(j).name,...
        '\', '*Shooting*.csv'));
%     MVC_FileList = dir(strcat(MVC_file_path, '\', '*.csv'));
    iMVC_Data = {};
    iMVC_Data_ed = [];
    iMVC_Data_eded = zeros(18000, length(Processing_FileList));
    %%
    name1 = {};
    name2 = {};
    for jj = 1:length(Processing_FileList)
        % read MVC folder list
        MVC_ds = tabularTextDatastore(strcat(MVC_file_path, '\', '*.csv'));
        for jjjj = 1:length(MVC_ds.Files)
        % read MVC files
            MVC_Data = readtable(string(MVC_ds.Files(jjjj)));
            zz = MVC_ds.Files(jjjj);
            tzz = AfterFilting_FolderList(j).name;
            tzz1 = strfind(zz, tzz);
            if  cell2mat(tzz1) ~= 0
                zz
                tzz
                break
            end
        end
        % read data
        Process_ds = tabularTextDatastore(strcat(Processing_FileList(jj).folder, '\',...
            Processing_FileList(jj).name));
        Processing_Data = readtable(string(Process_ds.Files));
        % judge subject name is correct with files name
        for jjj = 1:length(StagingFile.name)
            FolderName1 = StagingFile.trail(jjj);
            FileName2 = StagingFile.name(jjj);
            % transform cell to matrix
            % judge subject name is same with files name
            z = Process_ds.Files;
            tz = strfind(z, FolderName1);
            tz1 = strfind(z, FileName2);
            if cell2mat(tz) ~= 0 & cell2mat(tz1) ~= 0
                z
                FolderName1
                FileName2
                break
            end
        end
        % caculate iMVC
        % setting Aiming and rise bow timing
        AimingFrame = round(StagingFile.timing_H(jjj)*2000);
        RiseBowFrame = round(StagingFile.RaiseBow_H(jjj)*2000);
        % setting name to a matrix
        
        %% the Variables name need to change
        name3 = 'L_Triceps';     
        if StagingFile.L_Triceps_H(jjj) == 0
            %% the Variables name need to change
            Max_MVC = max(MVC_Data.L_Triceps);
            % setting muscle group
            %% the Variables name that need to change
            iMVC_Data_1 = Processing_Data.LTRICEPSBRACHII_EMG7./Max_MVC;
            % write iMVC matrix
%             iMVC_Data(jj, :) =  {name1; iMVC_Data_1};
            % make aiming time has value and value larger than 2.5
            if isnan(StagingFile.timing_H(jjj)) ~= 1 && StagingFile.timing_H(jjj) > 2.5 ...
                    && or(StagingFile.L_Triceps_H(jjj) == 0, StagingFile.L_Triceps_H(jjj) == 2)
                iMVC_Data_ed_1 = iMVC_Data_1(AimingFrame-5000:AimingFrame+1000, 1);
                iMVC_Data_ed(:, jj) = iMVC_Data_ed_1;
                name1(:, jj) = {Processing_FileList(jj).name};
            end
            % make sure aim time larger than 2.5 and Rise Bow time not
            % equal NaN
            if isnan(StagingFile.timing_H(jjj)) ~= 1 && StagingFile.timing_H(jjj) > 2.5 ...
                    && isnan(StagingFile.RaiseBow_H(jjj)) ~= 1 && StagingFile.L_Triceps_H(jjj) == 0
                iMVC_Data_eded_1 = iMVC_Data_1(RiseBowFrame:AimingFrame+1000, 1);
                iMVC_Data_eded(1:length(iMVC_Data_eded_1), jj) = iMVC_Data_eded_1;
                name2(:, jj) = {Processing_FileList(jj).name};
            end
        end
    end
    %% Right Trapezius
    % write iMVS data
%     writecell(iMVC_Data, strcat(iMVC_folder, '\', AfterFilting_FolderList(j).name,...
%                 '\', name2,'_iMVC_', Processing_FileList(jj).name));
%     % convert number to cell
    iMVC_Data_ed = array2table(iMVC_Data_ed);
    iMVC_Data_eded = array2table(iMVC_Data_eded);
%     % convert .CSV to .xlsx
    File_name = erase(Processing_FileList(jj).name, 'csv');
    % write iMVC data on aiming time
    writetable(iMVC_Data_ed, strcat(iMVC_folder, '\', AfterFilting_FolderList(j).name,...
                '\', name3, '_timing_', File_name, 'xlsx'), 'WriteVariableNames', false, 'Range','A2');
    writecell(name1, strcat(iMVC_folder, '\', AfterFilting_FolderList(j).name,...
                '\', name3, '_timing_', File_name, 'xlsx'), 'Range','A1')
            
    % write iMVC data on Rise Bow time
    writetable(iMVC_Data_eded, strcat(iMVC_folder, '\', AfterFilting_FolderList(j).name,...
                '\', name3, '_RiseBow_', File_name, 'xlsx'), 'WriteVariableNames', false, 'Range','A2')
    writecell(name1, strcat(iMVC_folder, '\', AfterFilting_FolderList(j).name,...
                '\', name3, '_RiseBow_', File_name, 'xlsx'), 'Range','A1')
end
