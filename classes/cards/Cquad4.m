classdef Cquad4 < matlab.mixin.Copyable
    
    %% Properties
    properties
        Eid         % Element identification number
        Pid         % Property identification number of a PSHELL, PCOMP, PCOMPG or PLPLANE entry
        GridArray   % Array of Grid objects
        Theta = 0;  % Material property orientation angle in degrees. THETA is ignored for hyperelastic elements. Or material coordinate system identification number
        Zoffs = 0;  % Offset from the surface of grid points to the element reference plane. ZOFFS is ignored for hyperelastic elements
        Stress      % StressInElement object
        Strain      % StrainInElement object
        ParentPart
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        G1  % Grid point identification numbers of connection points
        G2
        G3
        G4
    end
    
    methods
        %% Constructor
        function obj = Cquad4(cquad4Struct)
            %Cquad4 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(cquad4Struct);
                obj(m,n) = Cquad4;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(cquad4Struct,'eid')
                            obj(i,j).Eid = cquad4Struct(i,j).eid;
                        end
                        if isfield(cquad4Struct,'pid')
                            obj(i,j).Pid = cquad4Struct(i,j).pid;
                        end
                        if isfield(cquad4Struct,'gridArray')
                            obj(i,j).GridArray =...
                                cquad4Struct(i,j).gridArray;
                        end
                        if isfield(cquad4Struct,'theta')
                            obj(i,j).Theta = cquad4Struct(i,j).theta;
                        end
                        if isfield(cquad4Struct,'zoffs')
                            obj(i,j).Zoffs = cquad4Struct(i,j).zoffs;
                        end
                    end
                end
            end
        end
        
        %% GridArray set method
        function set.GridArray(obj,gridPointArray)
            obj.GridArray = gridPointArray;
            % Iterate through the grid point of the element
            for i = 1:length(gridPointArray)
                if isempty(obj.GridArray(i).ParentElement)
                    % If current grid point has no parent element, then
                    % assign the current element as parent
                    obj.GridArray(i).ParentElement = obj;
                elseif ~isa(obj,class(obj.GridArray(i).ParentElement))
                    % If class of other parent elements of current grid
                    % point is different from the class of the current
                    % element
                    if iscell(obj.GridArray(i).ParentElement)
                        % If parent elements of current grid point belong
                        % to different classes, then put current element
                        % into a cell and add it to the parent elements of
                        % current grid point
                        obj.GridArray(i).ParentElement =...
                            [obj.GridArray(i).ParentElement,num2cell(obj)];
                    else
                        % If parent elements of current grid point belong
                        % to one single class, then put those and the
                        % current element into a cell array
                        obj.GridArray(i).ParentElement = [num2cell(...
                            obj.GridArray(i).ParentElement),num2cell(obj)];
                    end
                else
                    % If other parent elements of current grid point
                    % belongs to the same class of the current element,
                    % then add it to parent elements of current grid point
                    obj.GridArray(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% Stress set method
        function set.Stress(obj,stress)
            obj.Stress = stress;
            % Assign current Cquad4 object as parent of all
            % NastranStressInElement object in input
            parentElementArray = num2cell(repmat(obj,...
                size(stress,1),size(stress,2)));
            [obj.Stress.ParentElement] = parentElementArray{:};
        end
        
        %% Strain set method
        function set.Strain(obj,strain)
            obj.Strain = strain;
            % Assign current Cquad4 object as parent of all
            % NastranStrainInElement object in input
            parentElementArray = num2cell(repmat(obj,...
                size(strain,1),size(strain,2)));
            [obj.Strain.ParentElement] = parentElementArray{:};
        end
        
        %% G1 get method
        function g1 = get.G1(obj)
            if ~isempty(obj.GridArray)
                g1 = obj.GridArray(1).Id;
            end
        end
        
        %% G2 get method
        function g2 = get.G2(obj)
            if ~isempty(obj.GridArray)
                g2 = obj.GridArray(2).Id;
            end
        end
        
        %% G3 get method
        function g3 = get.G3(obj)
            if ~isempty(obj.GridArray)
                g3 = obj.GridArray(3).Id;
            end
        end
        
        %% G4 get method
        function g4 = get.G4(obj)
            if ~isempty(obj.GridArray)
                g4 = obj.GridArray(4).Id;
            end
        end
        
        %% findElementCoordinateSystem method
        function [localOrigin,localAxes] = findElementCoordinateSystem(obj)
            %findElementCoordinateSystem Finds the origin and the axes of
            %the coordinate system of the CQUAD4 element.
            %   [localOrigin,localAxes] = findElementCoordinateSystem(obj)
            %   returns the origin and the axes of the coordinate system of
            %   the CQUAD4 elements in the global reference frame. If more
            %   than one CQUAD4 element is considered, the function returns
            %   both localOrigin and localAxes as cell array, with each
            %   cell containing the information related to each element.
            if ~isempty(obj)
                % If object is not empty, iterate through element array
                for i = size(obj,1):-1:1
                    for j = size(obj,2):-1:1
                        % Retrieve the coordinates of the element's points
                        xyzPointsArray = obj(i,j).GridArray.getXyzArray;
                        % Find origin of the element's coordinate system
                        % Intersection of element diagonals is found
                        % through the technique explained at the following
                        % link:
                        % https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
                        p = xyzPointsArray(1,:);
                        q = xyzPointsArray(4,:);
                        r = xyzPointsArray(3,:)-p;
                        s = xyzPointsArray(2,:)-q;
                        t = cross((q-p),s)/cross(r,s);
                        localOrigin{i,j} = (p+t*r);
                        % Find element coordinate system axes x direction
                        % is found through the bisector relation:
                        % c = |b|a +|a|b
                        a = r;
                        b = s;
                        localXAxis = (norm(b)*a+norm(a)*b)/...
                            norm(norm(b)*a+norm(a)*b);
                        localZAxis = cross(localXAxis,...
                            ((xyzPointsArray(3,:)+xyzPointsArray(4,:))/2-...
                            localOrigin{i,j}))/norm(cross(localXAxis,...
                            (xyzPointsArray(3,:)+xyzPointsArray(4,:))/2-...
                            localOrigin{i,j}));
                        localAxes{i,j} = [localXAxis;...
                            cross(localZAxis,localXAxis);...
                            localZAxis];
                    end
                end
                if size(obj,1)==1 && size(obj,2)==1
                    % If only one element is considered then return doubles
                    localOrigin = localOrigin{1,1};
                    localAxes = localAxes{1,1};
                end
            else
                % If object is emtpy, then assign empty cells
                localOrigin = {};
                localAxes = {};
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % CQUAD4    EID     PID     G1      G2      G3  G4  THETA   ZOFFS
            %                   TFLAG   T1      T2      T3  T4
            % CQUAD4    111     203     31      74      75  32  2.6     0.3
            %           1.77    2.04    2.09    1.80
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    baseFormatSpec = '%-8s%-8d%-8d%-8d%-8d%-8d%-8d%-8.1f';
                    if abs(obj(i,j).Zoffs)>=1e2 || abs(obj(i,j).Zoffs)<1e-3
                        zoffsFormatSpec = '%-8.1e';
                    else
                        zoffsFormatSpec = '%-8.4f';
                    end
                    formatSpec = [baseFormatSpec,zoffsFormatSpec,'\n'];
                    fprintf(fileID,formatSpec,'CQUAD4',obj(i,j).Eid,...
                        obj(i,j).Pid,obj(i,j).G1,obj(i,j).G2,obj(i,j).G3,...
                        obj(i,j).G4,obj(i,j).Theta,obj(i,j).Zoffs);
                end
            end
        end
        
        %% Method for plotting of the element
        function plot(obj,varargin)
            % Create an InputParser object
            p = inputParser;
            % Add inputs to the parsing scheme
            c = lines;
            defaultColor = c(1,:);
            defaultLineStyle = [];
            defaultDisplayCoordinateSystemFlag = true;
            addRequired(p,'obj',@(obj)isa(obj,'Cquad4'));
            addParameter(p,'color',defaultColor)
            addParameter(p,'linestyle',defaultLineStyle)
            addParameter(p,'displayCoordinateSystemFlag',...
                defaultDisplayCoordinateSystemFlag,@islogical)
            addParameter(p,'targetAxes',gca)
            % Set properties to adjust parsing
            p.KeepUnmatched = true;
            % Parse the inputs
            parse(p,obj,varargin{:})
            % Iterate through the object array
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Initialize array of xyz coordinates
                    xyzPointsArray = zeros(4,3);
                    % Retrieve the coordinates of the element's points
                    xyzPointsArray(1:4,:) = obj(i,j).GridArray.getXyzArray;
                    % If coordinate system of the element has to be
                    % displayed or if an offset is present, find the
                    % element's origin and coordinate system
                    if p.Results.displayCoordinateSystemFlag ||...
                            obj(i,j).Zoffs ~= 0
                        % Find element's origin and axes
                        [localOrigin,localAxes] =...
                            obj(i,j).findElementCoordinateSystem;
                    end
                    % If element has an offset from the surface of the grid
                    % points, then include it in the coordinates shown in
                    % the plot
                    if obj(i,j).Zoffs ~= 0
                        % Transform global coordiantes of grid points of
                        % current element to elment coordinates
                        localCoord = global2localcoord(...
                            xyzPointsArray','rr',localOrigin',localAxes')';
                        % Add z offset to grid points in element
                        % coordinates
                        localCoord = localCoord+repmat(...
                            [0,0,obj(i,j).Zoffs],4,1);
                        % Transform back grid points coordinates to global
                        % coordinates
                        xyzPointsArray = local2globalcoord(localCoord',...
                            'rr',localOrigin',localAxes')';
                    end
                    % Add the first grid point as last point to plot in
                    % order to obtain a closed element in the plot
                    xyzPointsArray(5,:) = xyzPointsArray(1,:);
                    % Plot the element
                    h = plot3(p.Results.targetAxes,xyzPointsArray(:,1),...
                        xyzPointsArray(:,2),xyzPointsArray(:,3));
                    % Set line color if desired
                    if ~isempty(p.Results.color)
                        set(h,'Color',p.Results.color);
                    end
                    % Set line style if desired
                    if ~isempty(p.Results.linestyle)
                        set(h,'LineStyle',p.Results.linestyle);
                    end
                    % Local axes
                    if p.Results.displayCoordinateSystemFlag
                        scaleFactor = norm(xyzPointsArray(1,:)-...
                            localOrigin);
                        scaledLocalAxes = localAxes*scaleFactor;
                        hold on
                        plot3([localOrigin(1),...
                            localOrigin(1)+scaledLocalAxes(1,1)],...
                            [localOrigin(2),...
                            localOrigin(2)+scaledLocalAxes(1,2)],...
                            [localOrigin(3),...
                            localOrigin(3)+scaledLocalAxes(1,3)],...
                            'Color',[1,0,0],'Tag','Local-X-Axis');
                        plot3([localOrigin(1),...
                            localOrigin(1)+scaledLocalAxes(2,1)],...
                            [localOrigin(2),...
                            localOrigin(2)+scaledLocalAxes(2,2)],...
                            [localOrigin(3),...
                            localOrigin(3)+scaledLocalAxes(2,3)],...
                            'Color',[0,1,0],'Tag','Local-Y-Axis');
                        plot3([localOrigin(1),...
                            localOrigin(1)+scaledLocalAxes(3,1)],...
                            [localOrigin(2),...
                            localOrigin(2)+scaledLocalAxes(3,2)],...
                            [localOrigin(3),...
                            localOrigin(3)+scaledLocalAxes(3,3)],...
                            'Color',[0,0,1],'Tag','Local-Z-Axis');
                    end
                end
            end
            % Make plot nicer
            specificationStruct = struct('txtXlabel','$x$',...
                'txtYlabel','$y$',...
                'txtZlabel','$z$');
            makePlotNicer(specificationStruct)
        end
    end
end
