classdef Conm2 < matlab.mixin.Copyable
    %CONM2 Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Eid         % Element identification number
        Grid        % Grid object
        Cid = 0;    % Coordinate system identification number. (Integer > 0; Default = 0)
        M           % Mass value
        X1          % Offset distances from the grid point to the center of gravity of the mass in the coordinate system defined in field 4, unless CID = -1, in which case X1, X2, X3 are the coordinates, not offsets, of the center of gravity of the mass in the basic coordinate system. (Real).
        X2
        X3
        I11         % Mass moments of inertia measured at the mass center of gravity in the coordinate system defined by field 4. If CID = -1, the basic coordinate system is implied. (Real).
        I21
        I22
        I31
        I32
        I33
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        G  % Grid point identification number
    end
    
    methods
        %% Constructor
        function obj = Conm2(conm2Struct)
            %CONM2 Construct an instance of this class
            %   Detailed explanation goes here
            if nargin ~= 0
            % Initialise object array
                [m,n] = size(conm2Struct);
                obj(m,n) = Conm2;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(conm2Struct,'eid')
                            obj(i,j).Eid = conm2Struct(i,j).eid;
                        end
                        if isfield(conm2Struct,'grid')
                            obj(i,j).Grid = conm2Struct(i,j).grid;
                        end
                        if isfield(conm2Struct,'cid')
                            obj(i,j).Cid = conm2Struct(i,j).cid;
                        end
                        if isfield(conm2Struct,'m')
                            obj(i,j).M = conm2Struct(i,j).m;
                        end
                        if isfield(conm2Struct,'x1')
                            obj(i,j).X1 = conm2Struct(i,j).x1;
                        end
                        if isfield(conm2Struct,'x2')
                            obj(i,j).X2 = conm2Struct(i,j).x2;
                        end
                        if isfield(conm2Struct,'x3')
                            obj(i,j).X3 = conm2Struct(i,j).x3;
                        end
                        if isfield(conm2Struct,'i11')
                            obj(i,j).I11 = conm2Struct(i,j).i11;
                        end
                        if isfield(conm2Struct,'i21')
                            obj(i,j).I21 = conm2Struct(i,j).i21;
                        end
                        if isfield(conm2Struct,'i22')
                            obj(i,j).I22 = conm2Struct(i,j).i22;
                        end
                        if isfield(conm2Struct,'i31')
                            obj(i,j).I31 = conm2Struct(i,j).i31;
                        end
                        if isfield(conm2Struct,'i32')
                            obj(i,j).I32 = conm2Struct(i,j).i32;
                        end
                        if isfield(conm2Struct,'i33')
                            obj(i,j).I33 = conm2Struct(i,j).i33;
                        end
                    end
                end
            end
        end
        
        %% Grid set method
        function set.Grid(obj,gridPoint)
            obj.Grid = gridPoint;
            % Iterate through the grid point of the element
            for i = 1:length(gridPoint)
                if isempty(obj.Grid(i).ParentElement)
                    % If current grid point has no parent element, then
                    % assign the current element as parent
                    obj.Grid(i).ParentElement = obj;
                elseif ~isa(obj,...
                        class(obj.Grid(i).ParentElement))
                    % If class of other parent elements of current grid
                    % point is different from the class of the current
                    % element
                    if iscell(obj.Grid(i).ParentElement)
                        % If parent elements of current grid point belong
                        % to different classes, then put current element
                        % into a cell and add it to the parent elements of
                        % current grid point
                        obj.Grid(i).ParentElement =...
                            [obj.Grid(i).ParentElement,...
                            num2cell(obj)];
                    else
                        % If parent elements of current grid point belong
                        % to one single class, then put those and the
                        % current element into a cell array
                        obj.Grid(i).ParentElement =...
                            [num2cell(...
                            obj.Grid(i).ParentElement),...
                            num2cell(obj)];
                    end
                else
                    % If other parent elements of current grid point
                    % belongs to the same class of the current element,
                    % then add it to parent elements of current grid point
                    obj.Grid(i).ParentElement(end+1) = obj;
                end
            end
        end
        
        %% G get method
        function g = get.G(obj)
            if ~isempty(obj.Grid)
                g = obj.Grid.Id;
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % CONM2 EID     G   CID     M       X1  X2  X3
            %       I11     I21 I22     I31     I32 I33
            % CONM2 2       15  6       49.7
            %       16.2        16.2                7.8
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    basicFormatSpec = '%-8s%-8d%-8d%-8d';
                    if abs(obj(i,j).M)>=1e2 || abs(obj(i,j).M)<1e-3
                        massFormatSpec = '%-8.1e';
                    else
                        massFormatSpec = '%-8.4f';
                    end
                    if ~isempty(obj(i,j).X1)
                        if abs(obj(i,j).X1)>=1e2 || abs(obj(i,j).X1)<1e-3
                            x1FormatSpec = '%-8.1e';
                        else
                            x1FormatSpec = '%-8.4f';
                        end
                        if abs(obj(i,j).X2)>=1e2 || abs(obj(i,j).X2)<1e-3
                            x2FormatSpec = '%-8.1e';
                        else
                            x2FormatSpec = '%-8.4f';
                        end
                        if abs(obj(i,j).X3)>=1e2 || abs(obj(i,j).X3)<1e-3
                            x3FormatSpec = '%-8.1e';
                        else
                            x3FormatSpec = '%-8.4f';
                        end
                        x1x2x3FormatSpec = [x1FormatSpec,x2FormatSpec,...
                            x3FormatSpec,'\n'];
                    else
                        x1x2x3FormatSpec = '%-8s%-8s%-8s\n';
                    end
                    if ~isempty(obj(i,j).I11)
                        if abs(obj(i,j).I11)>=1e2 || abs(obj(i,j).I11)<1e-3
                            i11FormatSpec = '%-8.1e';
                        else
                            i11FormatSpec = '%-8.4f';
                        end
                    else
                        i11FormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).I21)
                        if abs(obj(i,j).I21)>=1e2 || abs(obj(i,j).I21)<1e-3
                            i21FormatSpec = '%-8.1e';
                        else
                            i21FormatSpec = '%-8.4f';
                        end
                    else
                        i21FormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).I22)
                        if abs(obj(i,j).I22)>=1e2 || abs(obj(i,j).I22)<1e-3
                            i22FormatSpec = '%-8.1e';
                        else
                            i22FormatSpec = '%-8.4f';
                        end
                    else
                        i22FormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).I31)
                        if abs(obj(i,j).I31)>=1e2 || abs(obj(i,j).I31)<1e-3
                            i31FormatSpec = '%-8.1e';
                        else
                            i31FormatSpec = '%-8.4f';
                        end
                    else
                        i31FormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).I32)
                        if abs(obj(i,j).I32)>=1e2 || abs(obj(i,j).I32)<1e-3
                            i32FormatSpec = '%-8.1e';
                        else
                            i32FormatSpec = '%-8.4f';
                        end
                    else
                        i32FormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).I33)
                        if abs(obj(i,j).I33)>=1e2 || abs(obj(i,j).I33)<1e-3
                            i33FormatSpec = '%-8.1e';
                        else
                            i33FormatSpec = '%-8.4f';
                        end
                    else
                        i33FormatSpec = '%-8s';
                    end
                    formatSpec = [basicFormatSpec,massFormatSpec,...
                        x1x2x3FormatSpec,'%-8s',i11FormatSpec,...
                        i21FormatSpec,i22FormatSpec,i31FormatSpec,...
                        i32FormatSpec,i33FormatSpec,'\n'];
                    fprintf(fileID,formatSpec,'CONM2',obj(i,j).Eid,...
                        obj(i,j).G,obj(i,j).Cid,obj(i,j).M,obj(i,j).X1,...
                        obj(i,j).X2,obj(i,j).X3,'',obj(i,j).I11,...
                        obj(i,j).I21,obj(i,j).I22,obj(i,j).I31,...
                        obj(i,j).I32,obj(i,j).I33);
                end
            end
        end
    end
end

