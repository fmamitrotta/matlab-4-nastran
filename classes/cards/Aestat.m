classdef Aestat < matlab.mixin.Copyable
    properties
        Id      % Identification number of an aerodynamic trim variable degree-of-freedom
        Label   % An alphanumeric string of up to eight characters used to identify the degree-offreedom
    end
    methods
        %% Constructor from struct input
        function obj = Aestat(aestatStruct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(aestatStruct);
                obj(m,n) = Aestat;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(aestatStruct,'id')
                            obj(i,j).Id = aestatStruct(i,j).id;
                        end
                        if isfield(aestatStruct,'label')
                            obj(i,j).Label = aestatStruct(i,j).label;
                        end
                    end
                end
            end
        end
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % AESTAT ID     LABEL
            % AESTAT 5001   ANGLEA
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    formatSpec = '%-8s%-8d%-8s\n';
                    fprintf(fileID,formatSpec,'AESTAT',obj(i,j).Id,...
                        obj(i,j).Label);
                end
            end
        end
    end
end