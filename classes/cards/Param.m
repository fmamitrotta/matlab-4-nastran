classdef Param < matlab.mixin.Copyable
    %PARAM Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        N
        V1
        V2
    end
    
    methods
        %% Constructor
        function obj = Param(paramStruct)
            %PARAM Construct an instance of this class
            %   Detailed explanation goes here
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(paramStruct);
                obj(m,n) = Param;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(paramStruct,'n')
                            obj(i,j).N = paramStruct(i,j).n;
                        end
                        if isfield(paramStruct,'v1')
                            obj(i,j).V1 = paramStruct(i,j).v1;
                        end
                        if isfield(paramStruct,'v2')
                            obj(i,j).V2 = paramStruct(i,j).v2;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % PARAM N       V1 V2
            % PARAM IRES    1
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    baseFormatSpec = '%-8s%-8s';
                    if isempty(obj(i,j).V1) || ischar(obj(i,j).V1)
                        v1Format = '%-8s';
                    elseif mod(obj(i,j).V1,1) == 0
                        v1Format = '%-8d';
                    elseif abs(obj(i,j).V1) >= 1e2
                        v1Format = '%-8.1e';
                    else
                        v1Format = '%-8.4f';
                    end
                    if isempty(obj(i,j).V2) || ischar(obj(i,j).V2)
                        v2Format = '%-8s';
                    elseif mod(obj(i,j).V2,1) == 0
                        v2Format = '%-8d';
                    elseif abs(obj(i,j).V2) >= 1e2
                        v2Format = '%-8.1e';
                    else
                        v2Format = '%-8.4f';
                    end
                    formatSpec = [baseFormatSpec,v1Format,v2Format,'\n'];
                    fprintf(fileId,formatSpec,'PARAM',obj(i,j).N,...
                        obj(i,j).V1,obj(i,j).V2);
                end
            end
        end
    end
end
