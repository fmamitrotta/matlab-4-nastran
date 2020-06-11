classdef Cord2r < matlab.mixin.Copyable
    %CONM2 Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Cid         % Coordinate system identification number
        Rid = 0;    % Identification number of a coordinate system that is defined independently from this coordinate system. (Integer > 0; Default = 0; which is the basic coordinate system.)
        A1          % Coordinates of three points given with respect to the coordinate system defined by RID. (Real)
        A2
        A3
        B1
        B2
        B3
        C1
        C2
        C3
    end
    
    methods
        %% Constructor
        function obj = Cord2r(cord2rStruct)
            %CONM2 Construct an instance of this class
            %   Detailed explanation goes here
            if nargin ~= 0
            % Initialise object array
                [m,n] = size(cord2rStruct);
                obj(m,n) = Cord2r;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(cord2rStruct,'cid')
                            obj(i,j).Cid = cord2rStruct(i,j).cid;
                        end
                        if isfield(cord2rStruct,'rid')
                            obj(i,j).Rid = cord2rStruct(i,j).rid;
                        end
                        if isfield(cord2rStruct,'a1')
                            obj(i,j).A1 = cord2rStruct(i,j).a1;
                        end
                        if isfield(cord2rStruct,'a2')
                            obj(i,j).A2 = cord2rStruct(i,j).a2;
                        end
                        if isfield(cord2rStruct,'a3')
                            obj(i,j).A3 = cord2rStruct(i,j).a3;
                        end
                        if isfield(cord2rStruct,'b1')
                            obj(i,j).B1 = cord2rStruct(i,j).b1;
                        end
                        if isfield(cord2rStruct,'b2')
                            obj(i,j).B2 = cord2rStruct(i,j).b2;
                        end
                        if isfield(cord2rStruct,'b3')
                            obj(i,j).B3 = cord2rStruct(i,j).b3;
                        end
                        if isfield(cord2rStruct,'c1')
                            obj(i,j).C1 = cord2rStruct(i,j).c1;
                        end
                        if isfield(cord2rStruct,'c2')
                            obj(i,j).C2 = cord2rStruct(i,j).c2;
                        end
                        if isfield(cord2rStruct,'c3')
                            obj(i,j).C3 = cord2rStruct(i,j).c3;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % CORD2R    CID RID A1      A2  A3  B1  B2  B3
            %           C1  C2  C3
            % CORD2R    3   17  -2.9    1.0 0.0 3.6 0.0 1.0
            %           5.2 1.0 -2.9
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    basicFormatSpec = '%-8s%-8d%-8d';
                    formatSpec = '';
                    if abs(obj(i,j).A1) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).A2) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).A3) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).B1) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).B2) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).B3) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e\n%-8s'];
                    else
                        formatSpec = [formatSpec,'%-8.4f\n%-8s'];
                    end
                    if abs(obj(i,j).C1) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).C2) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).C3) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    formatSpec = [basicFormatSpec,formatSpec,'\n'];
                    fprintf(fileID,formatSpec,'CORD2R',obj(i,j).Cid,...
                        obj(i,j).Rid,obj(i,j).A1,obj(i,j).A2,obj(i,j).A3,...
                        obj(i,j).B1,obj(i,j).B2,obj(i,j).B3,' ',...
                        obj(i,j).C1,obj(i,j).C2,obj(i,j).C3);
                end
            end
        end
    end
end
