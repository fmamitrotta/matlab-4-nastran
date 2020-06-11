classdef Darea < handle
    properties
        Sid     % Identification number
        Pi = 1; % Grid, extra, or scalar point identification number
        Ci = 1; % Component number
        Ai = 0; % Scale (area) factor
    end
    
    methods
        %% Constructor
        function obj = Darea(dareaStruct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(dareaStruct);
                obj(m,n) = Darea;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(dareaStruct,'sid')
                            obj(i,j).Sid = dareaStruct(i,j).sid;
                        end
                        if isfield(dareaStruct,'pi')
                            obj(i,j).Pi = dareaStruct(i,j).pi;
                        end
                        if isfield(dareaStruct,'ci')
                            obj(i,j).Ci = dareaStruct(i,j).ci;
                        end
                        if isfield(dareaStruct,'ai')
                            obj(i,j).Ai = dareaStruct(i,j).ai;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % DAREA SID P1 C1 A1    P2 C2   A2
            % DAREA 3   6   2 8.2   15 1    10.1
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set format specification
                    formatSpec = '%-8s%-8d%-8d%-8d%-8.1f\n';
                    % Write to file
                    fprintf(fileId,formatSpec,'DAREA',obj(i,j).Sid,...
                        obj(i,j).Pi,obj(i,j).Ci,obj(i,j).Ai);
                end
            end
        end
    end
end
