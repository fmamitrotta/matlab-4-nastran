classdef Rbe2 < matlab.mixin.Copyable
    
    %% Properties
    properties
        Eid                     % Element identification number
        IndependentGrid         % Grid object representing the independent grid point
        Cm                      % Component numbers of the dependent degrees-of-freedom in the global coordinate system at grid points GMi
        DependentGridVector     % Vector of Grid object representing the dependent grid points
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        Gn  % Identification number of grid point to which all six independent degrees-of-freedom for the element are assigned
        Gmi % Grid point identification numbers at which dependent degrees-of-freedom are assigned
    end
    
    methods
        %% Constructor
        function obj = Rbe2(rbe2Struct)
            %Rbe2 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(rbe2Struct);
                obj(m,n) = Rbe2;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj(i,j).Eid = rbe2Struct(i,j).eid;
                        obj(i,j).IndependentGrid =...
                            rbe2Struct(i,j).independentGrid;
                        obj(i,j).Cm = rbe2Struct(i,j).cm;
                        obj(i,j).DependentGridVector =...
                            rbe2Struct(i,j).dependentGridVector;
                    end
                end
            end
        end
        
        %% IndependentGrid set method
        function set.IndependentGrid(obj,gridPoint)
            obj.IndependentGrid = gridPoint;
            % Iterate through the grid point of the element
            for i = 1:length(gridPoint)
                if isempty(obj.IndependentGrid(i).ParentElement)
                    % If current grid point has no parent element, then
                    % assign the current element as parent
                    obj.IndependentGrid(i).ParentElement = obj;
                elseif ~isa(obj,...
                        class(obj.IndependentGrid(i).ParentElement))
                    % If class of other parent elements of current grid
                    % point is different from the class of the current
                    % element
                    if iscell(obj.IndependentGrid(i).ParentElement)
                        % If parent elements of current grid point belong
                        % to different classes, then put current element
                        % into a cell and add it to the parent elements of
                        % current grid point
                        obj.IndependentGrid(i).ParentElement =...
                            [obj.IndependentGrid(i).ParentElement,...
                            num2cell(obj)];
                    else
                        % If parent elements of current grid point belong
                        % to one single class, then put those and the
                        % current element into a cell array
                        obj.IndependentGrid(i).ParentElement =...
                            [num2cell(...
                            obj.IndependentGrid(i).ParentElement),...
                            num2cell(obj)];
                    end
                else
                    % If other parent elements of current grid point
                    % belongs to the same class of the current element,
                    % then add it to parent elements of current grid point
                    obj.IndependentGrid(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% DependentGrid set method
        function set.DependentGridVector(obj,gridPointsVector)
            obj.DependentGridVector = gridPointsVector;
            % Iterate through the grid point of the element
            for i = 1:length(gridPointsVector)
                if isempty(obj.DependentGridVector(i).ParentElement)
                    % If current grid point has no parent element, then
                    % assign the current element as parent
                    obj.DependentGridVector(i).ParentElement = obj;
                elseif ~isa(obj,...
                        class(obj.DependentGridVector(i).ParentElement))
                    % If class of other parent elements of current grid
                    % point is different from the class of the current
                    % element
                    if iscell(obj.DependentGridVector(i).ParentElement)
                        % If parent elements of current grid point belong
                        % to different classes, then put current element
                        % into a cell and add it to the parent elements of
                        % current grid point
                        obj.DependentGridVector(i).ParentElement =...
                            [obj.DependentGridVector(i).ParentElement,...
                            num2cell(obj)];
                    else
                        % If parent elements of current grid point belong
                        % to one single class, then put those and the
                        % current element into a cell array
                        obj.DependentGridVector(i).ParentElement =...
                            [num2cell(...
                            obj.DependentGridVector(i).ParentElement),...
                            num2cell(obj)];
                    end
                else
                    % If other parent elements of current grid point
                    % belongs to the same class of the current element,
                    % then add it to parent elements of current grid point
                    obj.DependentGridVector(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% Gn get method
        function gn = get.Gn(obj)
            if ~isempty(obj.IndependentGrid)
                gn = obj.IndependentGrid.Id;
            end
        end
        
        %% Gmi get method
        function gmi = get.Gmi(obj)
            if ~isempty(obj.DependentGridVector)
                gmi = [obj.DependentGridVector.Id];
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % RBE2  EID GN      CM  GM1     GM2     GM3 GM4 GM5
            %       GM6 GM7     GM8 -etc.-  ALPHA
            % RBE2  9   8       12  10      12      14  15  16
            %       20  6.5-6
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    nGridPoints = length(obj(i,j).Gmi);
                    if nGridPoints <= 5
                        nGridPointEachLine = nGridPoints;
                    else
                        nLines = ceil((nGridPoints-5)/8)+1;
                        nGridPointEachLine = [5,repmat(8,1,nLines-2),...
                            nGridPoints-5-8*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = ['%-8s%-8d%-8d%-8d',...
                        repmat('%-8d',1,nGridPointEachLine(1)),'\n'];
                    for k = 2:length(nGridPointEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat('%-8d',1,nGridPointEachLine(k)),'\n'];
                    end
                    % Write to file
                    gmiCell = num2cell(obj(i,j).Gmi);
                    fprintf(fileID,formatSpec,'RBE2',obj(i,j).Eid,...
                        obj(i,j).Gn,obj(i,j).Cm,gmiCell{:});
                end
            end
        end
    end
end
