classdef Set1 < matlab.mixin.Copyable
    
    %% Properties
    properties
        Sid         % Unique identification number
        GridVector  % Vector of Grid objects representing the structural grid points in the list
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        Idi     % List of structural grid point or element identification numbers
    end
    
    methods
        %% Constructor
        function obj = Set1(set1Struct)
            %Set1 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(set1Struct);
                obj(m,n) = Set1;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(set1Struct,'sid')
                            obj(i,j).Sid = set1Struct(i,j).sid;
                        end
                        if isfield(set1Struct,'gridVector')
                            obj(i,j).GridVector =...
                                set1Struct(i,j).gridVector;
                        end
                    end
                end
            end
        end
        
        %% Idi get method
        function idi = get.Idi(obj)
            if ~isempty(obj.GridVector)
                idi = [obj.GridVector.Id];
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % SET1  SID ID1     ID2 ID3 ID4 ID5 ID6 ID7
            %       ID8 -etc.-
            % SET1  3   31      62  93  124 16  17  18
            %       19
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    nGridPoints = length(obj(i,j).Idi);
                    if nGridPoints <= 7
                        nGridPointEachLine = nGridPoints;
                    else
                        nLines = ceil((nGridPoints-7)/8)+1;
                        nGridPointEachLine = [7,...
                            repmat(8,1,nLines-2),nGridPoints-7-8*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = ['%-8s%-8d',...
                        repmat('%-8d',1,nGridPointEachLine(1)),'\n'];
                    for k = 2:length(nGridPointEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat('%-8d',1,nGridPointEachLine(k)),'\n'];
                    end
                    % Write to file
                    idiCell = num2cell(obj(i,j).Idi);
                    fprintf(fileID,formatSpec,'SET1',obj(i,j).Sid,idiCell{:});
                end
            end
        end
    end
end