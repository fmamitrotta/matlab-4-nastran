classdef Load < matlab.mixin.Copyable
    %Load Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Sid             % Load set identification number
        S = 1;          % Overall scale factor. (Real)
        Si              % Scale factor on Li. (Real)
        LoadObjectArray % Cell array of load obejcts (Force, Grav, etc.)
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        Li   % Load set identification numbers defined on entry types listed above. (Integer > 0)
    end
    
    methods
        %% Constructor
        function obj = Load(loadStruct)
            %Load Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(loadStruct);
                obj(m,n) = Load;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj.Sid = loadStruct(i,j).sid;
                        if isfield(loadStruct(i,j),'s')
                            obj.S = loadStruct(i,j).s;
                        end
                        obj.Si = loadStruct(i,j).si;
                        obj.LoadObjectArray = loadStruct(i,j).loadObjectArray;
                    end
                end
            end
        end
        
        %% Li get method
        function li = get.Li(obj)
            if ~isempty(obj.LoadObjectArray)
                li = cellfun(@(x) x.Sid,obj.LoadObjectArray);
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % LOAD  SID S       S1      L1  S2  L2 S3 L3
            %       S4  L4      -etc.-
            % LOAD  101 -0.5    1.0     3   6.2 4
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    baseFormatSpec = '%-8s%-8d%-8.2f';
                    % Count number of lines needed
                    nLoadObjects = length(obj(i,j).LoadObjectArray);
                    if nLoadObjects <= 3
                        nLoadObjectsEachLine = nLoadObjects;
                    else
                        nLines = ceil((nLoadObjects-3)/4)+1;
                        nLoadObjectsEachLine = [3,repmat(4,1,nLines-2),...
                            nLoadObjects-3-4*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = [baseFormatSpec,repmat('%-8.2f%-8d',1,...
                        nLoadObjectsEachLine(1)),'\n'];
                    for k = 2:length(nLoadObjectsEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),repmat(...
                            '%-8.2f%-8d',1,nLoadObjectsEachLine(k)),'\n'];
                    end
                    % Retrieve combined scales and ids
                    combinedCell = [num2cell(obj(i,j).Si);...
                        num2cell(obj(i,j).Li)];
                    fprintf(fileID,formatSpec,'LOAD',obj(i,j).Sid,...
                        obj(i,j).S,combinedCell{:});
                end
            end
        end
    end
end
