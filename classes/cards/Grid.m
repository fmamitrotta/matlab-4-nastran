classdef Grid < matlab.mixin.Copyable
    
    %% Properties
    properties
        Id              % Identification number of grid point
        Cp = 0;         % Identification number of coordinate system in which the location of the grid point is defined
        X1              % Location of the grid point in coordinate system CP
        X2
        X3
        Cd = 0;             % Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the grid point
        ParentElement       % Parent element
    end
    
    methods
        %% Constructor
        function obj = Grid(gridStruct)
            %Grid Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(gridStruct);
                obj(m,n) = Grid;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if ~isempty(gridStruct(i,j).xyzVector)
                            obj(i,j).X1 = gridStruct(i,j).xyzVector(1);
                            obj(i,j).X2 = gridStruct(i,j).xyzVector(2);
                            obj(i,j).X3 = gridStruct(i,j).xyzVector(3);
                        end
                        if ~isempty(gridStruct(i,j).id)
                            obj(i,j).Id = gridStruct(i,j).id;
                        end
                    end
                end
            end
        end
        
        %% Get vector of XYZ position
        function xyz = getXyzArray(obj)
            xyz = [[obj.X1]',[obj.X2]',[obj.X3]'];
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % GRID        5155       0  0.7380 -4.1150  0.2630       0
            for i = 1:length(obj)
                formatSpec = '%-8s%-8d%-8d';
                xyz = obj(i).getXyzArray;
                % Check for zeros
                for j = 1:length(xyz)
                    if abs(xyz(j))>=1e2 || abs(xyz(j))<1e-3
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                end
                formatSpec = [formatSpec,'%-8d\n'];
                fprintf(fileID,formatSpec,'GRID',obj(i).Id,obj(i).Cp,...
                    xyz(1),xyz(2),xyz(3),obj(i).Cd);
            end
        end
        
        %% Plot grid
        function plot(obj,varargin)
            % Create an InputParser object
            p = inputParser;
            % Add inputs to the parsing scheme
            c = lines;
            defaultColor = c(1,:);
            defaultMarkertype = 'o';
            addRequired(p,'obj',@(obj)isa(obj,'Grid'));
            addParameter(p,'color',defaultColor)
            addParameter(p,'markertype',defaultMarkertype)
            addParameter(p,'targetAxes',gca)
            % Set properties to adjust parsing
            p.KeepUnmatched = true;
            % Parse the inputs
            parse(p,obj,varargin{:})
            % Plot scattered grid points
            scatter3(p.Results.targetAxes,[obj.X1],[obj.X2],[obj.X3],...
                p.Results.markertype,'MarkerEdgeColor',p.Results.color)
            % Make plot nicer
            specificationStruct = struct('txtXlabel','$x$',...
                'txtYlabel','$y$',...
                'txtZlabel','$z$');
            makePlotNicer(specificationStruct)
        end
    end
end
