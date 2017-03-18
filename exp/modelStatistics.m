function [rdeTable, mseTable] = modelStatistics(modelFolders, modelOpts, functions, dimensions, instances, snapshots)
% modelStatistics --  creates a table with statistics, 
%                     each row represents model and number of snapshot (combined), 
%                     each column represents function and dimension (also combined),
%                     value of cell is average of values from given instances
%
% Input:
%   modelFolders  - list of folders with models that will be displayed in table | cell-array of 
%                  string
%   modelOpts    - model options (needed because modelFolders don't contain proper filename) | struct (cell-array of struct)
%   functions    - functions that will be displayed in table | array of integers
%   dimensions   - dimensions that will be displayed in table | array of integers
%   instances    - instances that will be displayed in table | array of integers
%   snapshots    - snapshots that will be displayed in table | array of integers
%
% Output:
%   tables with average RDE and MSE values
%

  % Default input parameters settings
  if (~exist('functions', 'var'))
    functions = 1; end
  if (~exist('dimensions', 'var'))
    dimensions = 2; end
  if (~exist('instances', 'var'))
    instances = 1:5; end
  if (~exist('snapshots', 'var'))
    snapshots = [1 3 9]; end

  assert(isnumeric(functions), '''funcToTest'' has to be integer')
  assert(isnumeric(dimensions), '''dimsToTest'' has to be integer')
  assert(isnumeric(instances), '''instToTest'' has to be integer')
  assert(isnumeric(snapshots), '''instToTest'' has to be integer')
  
  
  rowsCount = length(modelFolders)*length(snapshots);
  columnsCount = length(functions)*length(dimensions);
  columnsNames = cell(columnsCount,1);
  rowsNames = cell(rowsCount,1);
  
  cellIndex=1;
  for i=functions
    for j=dimensions
      columnsNames{cellIndex} = sprintf('F%d_%dD',i,j);
      cellIndex = cellIndex+1;
    end
  end
  valuesRDE = NaN(rowsCount, columnsCount);
  valuesMSE = NaN(rowsCount, columnsCount);
  
  rowIndex = 1;
  columnIndex = 1;
  
  for modelIndex = 1:length(modelFolders)
    modelFolder = modelFolders(modelIndex);
    hash = modelHash(modelOpts{modelIndex});
    for snapshot = snapshots
      rowsNames{rowIndex} = sprintf('%s S%d',hash,snapshot);
      for func = functions
        for dim = dimensions
          
          fileName = fullfile(modelFolder{1}, sprintf('gpmodel_%s_f%d_%dD.mat', hash, func, dim));
          if (~exist(fileName,'file'))
            warning('File %s not found', fileName)
          else
            data = load(fileName);
          end
          [~, instanceIndices] = ismember(data.instances, instances);
          valuesRDE(rowIndex, columnIndex) = mean(data.stats.rde(instanceIndices,snapshot));
          valuesMSE(rowIndex, columnIndex) = mean(data.stats.mse(instanceIndices,snapshot));
          columnIndex = columnIndex+1;
        end
      end
      rowIndex = rowIndex+1;
      columnIndex = 1;
    end
  end
  rdeTable = table(valuesRDE);
  rdeTable.Properties.VariableNames = columnsNames;
  rdeTable.Properties.RowNames = rowsNames;
  disp(rdeTable);
  mseTable = table(valuesMSE);
  mseTable.Properties.VariableNames = columnsNames;
  mseTable.Properties.RowNames = rowsNames;
  disp(mseTable);
  
end

function hash = modelHash(modelOptions)
%TODO: somehow remove this, its copied from testModels.m
% function creating hash for model identification using modelOptions

    % gain fields and values of modelOptions
    [modelField, modelValues] = getFieldsVals(modelOptions);

    S = printStructure(modelOptions, 'Format', 'field');
    S = double(S);
    % exclude not necessary characters
    S = S(S > 32 & S~= 61) - 32;

    % create hash
    hash = num2str(sum(S.*(1:length(S))));
end

function [sField, sVal] = getFieldsVals(s)
% sf = getFields(s, fields) extracts fields and its values from structure s

  sField = fieldnames(s);
  nFields = length(sField);
  sVal = cell(nFields, 1);
  for i = 1:nFields
    sVal{i} = s.(sField{i});
  end
end
