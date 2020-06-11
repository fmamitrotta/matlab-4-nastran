classdef Spc1 < matlab.mixin.Copyable
    
    %% Properties
    properties
        Sid         % Identification number of single-point constraint set
        C           % Component numbers. See Remark 7. (Any unique combination of the Integers 1 through 6 with no embedded blanks for grid points. This number must be Integer 0, 1 or blank for scalar points.)
        GridVector  % Vector of Grid objects representing the constrained nodes
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        Gi      % Grid or scalar point identification numbers. (Integer > 0 or “THRU”; For “THRU” option, G1 < G2.)
    end
    
    methods
        %% Constructor
        function obj = Spc1(spc1Struct)
            %Spc1 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(spc1Struct);
                obj(m,n) = Spc1;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj(i,j).Sid = spc1Struct(i,j).sid;
                        obj(i,j).C = spc1Struct(i,j).c;
                        obj(i,j).GridVector = spc1Struct(i,j).gridVector;
                    end
                end
            end
        end
        
        %% Gi get method
        function gi = get.Gi(obj)
            if ~isempty(obj.GridVector)
                gi = [obj.GridVector.Id];
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % SPC1  SID C   G1  G2      G3  G4  G5  G6
            %       G7  G8  G9  -etc.-
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    nGridPoints = length(obj(i,j).Gi);
                    if nGridPoints <= 6
                        nGridPointEachLine = nGridPoints;
                    else
                        nLines = ceil((nGridPoints-6)/8)+1;
                        nGridPointEachLine = [6,repmat(8,1,nLines-2),...
                            nGridPoints-6-8*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = ['%-8s%-8d%-8d',...
                        repmat('%-8d',1,nGridPointEachLine(1)),'\n'];
                    for k = 2:length(nGridPointEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat('%-8d',1,nGridPointEachLine(k)),'\n'];
                    end
                    % Write to file
                    giCell = num2cell(obj(i,j).Gi);
                    fprintf(fileID,formatSpec,'SPC1',obj(i,j).Sid,...
                        obj(i,j).C,giCell{:});
                end
            end
        end
    end
end
