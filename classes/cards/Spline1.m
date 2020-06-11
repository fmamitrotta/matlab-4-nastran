classdef Spline1 < matlab.mixin.Copyable
    properties
        Eid     % Unique spline identification number
        Caero   % Aero-element (CAEROi entry ID) that defines the plane of the spline
        Box1    % First and last box with motions that are interpolated using this spline
        Box2
        Setg    % Refers to the SETi entry that lists the structural grid points to which the spline is attached
        Dz = 0; % Linear attachment flexibility
    end
    methods
        %% Constructor from struct input
        function obj = Spline1(spline1Struct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(spline1Struct);
                obj(m,n) = Spline1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(spline1Struct,'eid')
                            obj(i,j).Eid = spline1Struct(i,j).eid;
                        end
                        if isfield(spline1Struct,'caero')
                            obj(i,j).Caero = spline1Struct(i,j).caero;
                        end
                        if isfield(spline1Struct,'box1')
                            obj(i,j).Box1 = spline1Struct(i,j).box1;
                        end
                        if isfield(spline1Struct,'box2')
                            obj(i,j).Box2 = spline1Struct(i,j).box2;
                        end
                        if isfield(spline1Struct,'setg')
                            obj(i,j).Setg = spline1Struct(i,j).setg;
                        end
                        if isfield(spline1Struct,'dz')
                            obj(i,j).Dz = spline1Struct(i,j).dz;
                        end
                    end
                end
            end
        end
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % SPLINE1   EID     CAERO   BOX1    BOX2    SETG    DZ METH USAGE
            %           NELEM   MELEM
            % SPLINE1   3       111     115     122     14      0.
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    formatSpec = '%-8s%-8d%-8d%-8d%-8d%-8d%-8.2f\n';
                    fprintf(fileID,formatSpec,'SPLINE1',obj(i,j).Eid,...
                        obj(i,j).Caero,obj(i,j).Box1,obj(i,j).Box2,...
                        obj(i,j).Setg,obj(i,j).Dz);
                end
            end
        end
    end
end
