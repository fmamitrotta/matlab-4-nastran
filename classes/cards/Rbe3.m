classdef Rbe3 < matlab.mixin.Copyable
    
    %% Properties
    properties
        Eid                 % Element identification number
        ReferenceGrid       % Grid object representing the reference grid point
        Refc                % Component numbers at the reference grid point. (Any of the integers 1 through 6 with no embedded blanks.)
        Wti                 % Weighting factor for components of motion on the following entry at grid points Gi,j. (Real)
        Ci                  % Component numbers with weighting factor WTi at grid points Gi,j. (Any of the integers 1 through 6 with no embedded blanks.)
        MasterGridVector    % Grid object vector representing the master grid points
        UmFlag = false;     % Indicates the start of the degrees-of-freedom belonging to the dependent degrees-of-freedom. The default action is to assign only the components in REFC to the dependent degrees-of-freedom. (Character)
        GridMsetVector      % Grid object vector representing the grid points with dregrees-of-freedon in the m-set
        Cmi                 % Component numbers of GMi to be assigned to the m-set. (Any of the Integers 1 through 6 with no embedded blanks.)
        AlphaFlag = false;  % Indicates that the next number is the coefficient of thermal expansion.
        Alpha               % Thermal expansion coefficient.
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        Refgrid     % Reference grid point identification number.
        Gij         % Grid points with components Ci that have weighting factor WTi in the averaging equations. (Integer > 0)
        Gmi         % Identification numbers of grid points with degrees-of-freedom in the m-set. (Integer > 0)
    end
    
    methods
        %% Constructor
        function obj = Rbe3(rbe3Struct)
            %Rbe3 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(rbe3Struct);
                obj(m,n) = Rbe3;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj(i,j).Eid = rbe3Struct(i,j).eid;
                        obj(i,j).ReferenceGrid =...
                            rbe3Struct(i,j).referenceGrid;
                        obj(i,j).Refc = rbe3Struct(i,j).refc;
                        obj(i,j).Wti = rbe3Struct(i,j).wti;
                        obj(i,j).Ci = rbe3Struct(i,j).ci;
                        obj(i,j).MasterGridVector =...
                            rbe3Struct(i,j).masterGridVector;
                    end
                end
            end
        end
        
        %% Refgrid set method
        function set.Refgrid(obj,gridPoint)
            obj.Refgrid = gridPoint;
            for i = 1:length(gridPoint)
                if isempty(...
                        obj.Refgrid(i).ParentElement)
                    obj.Refgrid(i).ParentElement = obj;
                else
                    obj.Refgrid(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% MasterGridVector set method
        function set.MasterGridVector(obj,gridPointsVector)
            obj.MasterGridVector = gridPointsVector;
            % Iterate through the grid point of the element
            for i = 1:length(gridPointsVector)
                if isempty(obj.MasterGridVector(i).ParentElement)
                    % If current grid point has no parent element, then
                    % assign the current element as parent
                    obj.MasterGridVector(i).ParentElement = obj;
                elseif ~isa(obj,...
                        class(obj.MasterGridVector(i).ParentElement))
                    % If class of other parent elements of current grid
                    % point is different from the class of the current
                    % element
                    if iscell(obj.MasterGridVector(i).ParentElement)
                        % If parent elements of current grid point belong
                        % to different classes, then put current element
                        % into a cell and add it to the parent elements of
                        % current grid point
                        obj.MasterGridVector(i).ParentElement =...
                            [obj.MasterGridVector(i).ParentElement,...
                            num2cell(obj)];
                    else
                        % If parent elements of current grid point belong
                        % to one single class, then put those and the
                        % current element into a cell array
                        obj.MasterGridVector(i).ParentElement = [num2cell(...
                            obj.MasterGridVector(i).ParentElement),...
                            num2cell(obj)];
                    end
                else
                    % If other parent elements of current grid point
                    % belongs to the same class of the current element,
                    % then add it to parent elements of current grid point
                    obj.MasterGridVector(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% GridMsetVector set method
        function set.GridMsetVector(obj,gridPointsVector)
            obj.GridMsetVector = gridPointsVector;
            for i = 1:length(gridPointsVector)
                if isempty(...
                        obj.GridMsetVector(i).ParentElement)
                    obj.GridMsetVector(i).ParentElement = obj;
                else
                    obj.GridMsetVector(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% Refgrid get method
        function refgrid = get.Refgrid(obj)
            if ~isempty(obj.ReferenceGrid)
                refgrid = obj.ReferenceGrid.Id;
            end
        end
        
        %% Gij get method
        function gij = get.Gij(obj)
            if ~isempty(obj.MasterGridVector)
                gij = [obj.MasterGridVector.Id];
            end
        end
        
        %% Gmi get method
        function gmi = get.Gmi(obj)
            if ~isempty(obj.GridMsetVector)
                gmi = [obj.GridMsetVector.Id];
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % RBE3  EID             REFGRID REFC    WT1     C1      G1,1    G1,2
            %       G1,3    WT2     C2      G2,1    G2,2    -etc.-  WT3     C3
            %       G3,1    G3,2    -etc.-  WT4     C4      G4,1    G4,2    -etc.-
            %       “UM”    GM1     CM1     GM2     CM2     GM3     CM3
            %               GM4     CM4     GM5     CM5     -etc.-
            %       “ALPHA” ALPHA
            % RBE3  14              100     1234    1.0     123     1       3
            %       5       4.7     1       2       4       6       5.2     2
            %       7       8       9       5.1     1       15      16
            %       UM      100     14      5       3       7       2
            %       ALPHA   6.5-6
            for i = 1:length(obj)
                for j = 1:size(obj,2)
                    % Count number of lines needed (assumption: only one
                    % weight specified)
                    nMasterPoints = length(obj(i,j).MasterGridVector);
                    if nMasterPoints <= 2
                        nGridPointEachLine = nMasterPoints;
                    else
                        nLines = ceil((nMasterPoints-2)/8)+1;
                        nGridPointEachLine = [2,repmat(8,1,nLines-2),...
                            nMasterPoints-2-8*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = ['%-8s%-8d%-8s%-8d%-8d%-8.1f%-8d',...
                        repmat('%-8d',1,nGridPointEachLine(1)),'\n'];
                    for k = 2:length(nGridPointEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat('%-8d',1,nGridPointEachLine(k)),'\n'];
                    end
                    % Write to file
                    gijCell = num2cell(obj(i,j).Gij);
                    fprintf(fileID,formatSpec,'RBE3',obj(i,j).Eid,' ',...
                        obj(i,j).Refgrid,obj(i,j).Refc,obj(i,j).Wti,...
                        obj(i,j).Ci,gijCell{:});
                end
            end
        end
    end
end
