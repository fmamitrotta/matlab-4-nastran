classdef Tstep < handle
    properties
        Sid         % Set identification number
        Ni          % Number of time steps of value DTi
        Dti         % Time increment
        Noi = 1;    % Skip factor for output
    end
    
    methods
        %% Constructor
        function obj = Tstep(tstepStruct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(tstepStruct);
                obj(m,n) = Tstep;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(tstepStruct,'sid')
                            obj(i,j).Sid = tstepStruct(i,j).sid;
                        end
                        if isfield(tstepStruct,'ni')
                            obj(i,j).Ni = tstepStruct(i,j).ni;
                        end
                        if isfield(tstepStruct,'dti')
                            obj(i,j).Dti = tstepStruct(i,j).dti;
                        end
                        if isfield(tstepStruct,'noi')
                            obj(i,j).Noi = tstepStruct(i,j).noi;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % TSTEP SID     N1      DT1     NO1
            %       N2      DT2     NO2
            %       -etc.-
            % TSTEP 2       10      .001    5
            %       9       0.01    1
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set format specification
                    basicFormatSpec = '%-8s%-8d%-8d';
                    % Set format spec for time increment
                    if abs(obj(i,j).Dti) >= 1e2
                        dtiFormatSpec = '%-8.1e';
                    else
                        dtiFormatSpec = '%-8.4f';
                    end
                    noiFormatSpec = '%-8d';
                    % Set final format specification
                    formatSpec = [basicFormatSpec,dtiFormatSpec,...
                        noiFormatSpec,'\n'];
                    % Write to file
                    fprintf(fileId,formatSpec,'TSTEP',obj(i,j).Sid,...
                        obj(i,j).Ni,obj(i,j).Dti,obj(i,j).Noi);
                end
            end
        end
    end
end
