classdef Gust < handle
    properties
        Sid         % Gust set identification number
        Dload       % Set identification number of a TLOADi or RLOADi entry
        Wg          % Scale factor (gust velocity/forward velocity) for gust velocity
        X0          % Streamwise location in the aerodynamic coordinate system of the gust reference point
        V           % Velocity of vehicle
    end
     
    methods
        %% Constructor
        function obj = Gust(gustStruct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(gustStruct);
                obj(m,n) = Gust;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(gustStruct,'sid')
                            obj(i,j).Sid = gustStruct(i,j).sid;
                        end
                        if isfield(gustStruct,'dload')
                            obj(i,j).Dload = gustStruct(i,j).dload;
                        end
                        if isfield(gustStruct,'wg')
                            obj(i,j).Wg = gustStruct(i,j).wg;
                        end
                        if isfield(gustStruct,'x0')
                            obj(i,j).X0 = gustStruct(i,j).x0;
                        end
                        if isfield(gustStruct,'v')
                            obj(i,j).V = gustStruct(i,j).v;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % GUST SID DLOAD    WG  X0 V
            % GUST 133 61       1.0 0. 1.+4
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set format specification
                    basicFormatSpec = '%-8s%-8d%-8d';
                    if abs(obj(i,j).Wg) >= 1e2
                        wgFormatSpec = '%-8.1e';
                    else
                        wgFormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).X0) >= 1e2
                        x0FormatSpec = '%-8.1e';
                    else
                        x0FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).V) >= 1e2
                        vFormatSpec = '%-8.1e';
                    else
                        vFormatSpec = '%-8.4f';
                    end
                    formatSpec = [basicFormatSpec,wgFormatSpec,...
                        x0FormatSpec,vFormatSpec,'\n'];
                    % Write to file
                    fprintf(fileId,formatSpec,'GUST',obj(i,j).Sid,...
                        obj(i,j).Dload,obj(i,j).Wg,obj(i,j).X0,obj(i,j).V);
                end
            end
        end
    end
end