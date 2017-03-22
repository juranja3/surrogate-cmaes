function compressedFolder = compressModelData(modelFolder, modelPreposition)
% compressModelData - removes data that are not needed from modelPreposition*.mat files 
%                     saved in modelFolder
%                     and saves them into newModelFolder
%
% Input:
%   modelFolder - folder with files from testModels | string
%   modelPreposition - only files whose names start with this string will be
%                      compressed
% Output:
%   modelFolder  - folder containing results | string

compressedFolder = strcat(modelFolder,'_compressed');
fprintf('Compressing data in ''%s'', output folder is ''%s''\n',modelFolder, compressedFolder);
mkdir(compressedFolder);
dirs = dir(modelFolder);
dirIndex = find([dirs.isdir]);
% data are saved in separate folders
for i = 1:length(dirIndex)
  dirName = dirs(dirIndex(i)).name;
  fprintf('Processing ''%s''\n',dirName);
  modelFiles = dir(fullfile(modelFolder,dirName, strcat(modelPreposition,'*.mat')));
  % for each file that matches create its compressed copy in compressedFolder
  for j = 1:length(modelFiles)
    % load original data
    data = load(fullfile(modelFolder,dirName, modelFiles(j).name));
    % compress
    data = compressData(data);
    %create folder
    mkdir(fullfile(compressedFolder,dirName));
    %save compressed data
    save(fullfile(compressedFolder,dirName, modelFiles(j).name), '-struct', 'data');
  end
end
end

function data = compressData(data)
data.modelOptions = [];
for i=size(data.models,1)
  for j=size(data.models,2)
    data.models{i,j}.dataset=[];
  end
end
end