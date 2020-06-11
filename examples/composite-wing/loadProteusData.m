function proteusDataStruct = loadProteusData(excelFilePath)
%loadProteusResults Structure with Proteus results. 
%   proteusDataStruct = loadProteusData(excelInputName) reads the input
%   excel file and retrieves the path to the results folder of Proteus and
%   the iteration number from which the design vector will be taken. The
%   output structure contains the Proteus variables constant and loadcase
%   and the design vector.

% Get Proteus results folder path and iteration number from excel sheet
[iterationNo,textFieldArray] = xlsread(excelFilePath,'ProteusData');
proteusResultsFolderPath = textFieldArray{1,2};

% If path points to a folder, load the input.mat and output.mat files
if isfolder(proteusResultsFolderPath)
% Load input and output .mat files in the PROTEUS results folder
inputDataStruct = load(...
    [proteusResultsFolderPath,filesep,'input.mat'],'AnalysisInputs');
outputDataStruct = load(...
    [proteusResultsFolderPath,filesep,'output.mat'],'dvopt_s');
% Define the Proteus variables constant and loadcase and define the design
% vector
constant = inputDataStruct.AnalysisInputs.constant;
loadcase = inputDataStruct.AnalysisInputs.loadcase;
if isempty(iterationNo)
    designVector = outputDataStruct.dvopt_s{end}.tail;
else
    designVector = outputDataStruct.dvopt_s{iterationNo}.tail;
end
else
    % If path does not points to a folder then expect a .mat file
    load(proteusResultsFolderPath,'constant','loadcase','dvinp')
    designVector = dvinp.tail;
end

% Assemble output structure
proteusDataStruct = struct(...
    'constant',constant,...
    'loadcase',loadcase,...
    'designVector',designVector);
end
