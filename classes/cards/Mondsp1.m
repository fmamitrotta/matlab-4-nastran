classdef Mondsp1 < matlab.mixin.Copyable
    %Mondsp1 Defines a virtual point displacement response at a 
    %user-defined reference location (coordinates and coordinates system)
    %as a weighted average of the motions at a set of grid points.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Name    % Character string of up to 8 characters identifying the monitor point (Character)
        Label   % A string comprising no more than 56 characters (fields 3 through 9) that identifies and labels the monitor point.
        Axes    % Component axes to monitor. (Any unique combination of the integers 1 through 6 with no embedded blanks.)
        Comp    % The name of an AECOMP or AECOMPL entry that defines the set of grid points over which the monitor point is defined.
        Cp = 0; % The identification number of a coordinate system in which the input (x,y,z) coordinates are defined. (Integer > 0; Default = 0)
        X       % The coordinates in the CP coordinate system at which the displacement is to be monitored.
        Y
        Z
        Cd      % The identification number of a coordinate system in which the resulting displacement components are output. (Integer > 0; Default = the coordinate system specified by the CP field)
        Inddof  % Component numbers of all the independent grids from which the derived, dependent, monitor DOF’s are to be computed. (Any unique combination of the integers 1 through 6 with no embedded blanks.) See Remark 3. (Default = 123)
    end
    
    methods
        %% Constructor
        function obj = Mondsp1(mondsp1Struct)
            %Mondsp1 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(mondsp1Struct);
                obj(m,n) = Mondsp1;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj.Name = mondsp1Struct(i,j).name;
                        obj.Label = mondsp1Struct(i,j).label;
                        if isfield(mondsp1Struct(i,j),'axes')
                            obj.Axes = mondsp1Struct(i,j).axes;
                        end
                        if isfield(mondsp1Struct(i,j),'comp')
                            obj.Comp = mondsp1Struct(i,j).comp;
                        end
                        if isfield(mondsp1Struct(i,j),'cp')
                            obj.Cp = mondsp1Struct(i,j).cp;
                        end
                        if isfield(mondsp1Struct(i,j),'x')
                            obj.X = mondsp1Struct(i,j).x;
                        end
                        if isfield(mondsp1Struct(i,j),'y')
                            obj.Y = mondsp1Struct(i,j).y;
                        end
                        if isfield(mondsp1Struct(i,j),'z')
                            obj.Z = mondsp1Struct(i,j).z;
                        end
                        if isfield(mondsp1Struct(i,j),'cd')
                            obj.Cd = mondsp1Struct(i,j).cd;
                        end
                        if isfield(mondsp1Struct(i,j),'inddof')
                            obj.Inddof = mondsp1Struct(i,j).inddof;
                        end
                    end
                end
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % MONDSP1   NAME                      LABEL
            %           AXES    COMP    CP      X   Y       Z       CD      INDDOF
            % MONDSP1            WING195 Wing twist at station 150.
            %           5       WING150 1001    120 150.0   17.0    1002
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set base format specification
                    baseFormatSpec = '%-8s%-8s%-56s\n%-8s%-8d%-8s%-8d';
                    % Set format for the coordinates where the displacement
                    % is monitored
                    % Set format spec for time increment
                    if abs(obj(i,j).X) >= 1e2
                        xFormatSpec = '%-8.1e';
                    else
                        xFormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Y) >= 1e2
                        yFormatSpec = '%-8.1e';
                    else
                        yFormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Z) >= 1e2
                        zFormatSpec = '%-8.1e';
                    else
                        zFormatSpec = '%-8.4f';
                    end
                    % Set format specification for Cd if present
                    if ~isempty(obj(i,j).Cd)
                        cdFormatSpec = '%-8d';
                    else
                        cdFormatSpec = '%-8s';
                    end
                    % Set format specification for Inddof if present
                    if ~isempty(obj(i,j).Inddof)
                        inddofFormatSpec = '%-8d';
                    else
                        inddofFormatSpec = '%-8s';
                    end
                    % Set format specification
                    formatSpec = [baseFormatSpec,xFormatSpec,...
                        yFormatSpec,zFormatSpec,cdFormatSpec,...
                        inddofFormatSpec,'\n'];
                    % Write card
                    fprintf(fileID,formatSpec,'MONDSP1',obj(i,j).Name,...
                        obj(i,j).Label,'',obj(i,j).Axes,obj(i,j).Comp,...
                        obj(i,j).Cp,obj(i,j).X,obj(i,j).Y,obj(i,j).Z,...
                        obj(i,j).Cd,obj(i,j).Inddof);
                end
            end
        end
    end
end
