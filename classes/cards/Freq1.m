classdef Freq1 < handle
    properties
        Sid     % Set identification number
        F1      % First frequency in set
        Df      % Frequency increment
        Ndf     % Number of frequency increments
    end
    
    methods
        %% Constructor
        function obj = Freq1(freq1Struct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(freq1Struct);
                obj(m,n) = Freq1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(freq1Struct,'sid')
                            obj(i,j).Sid = freq1Struct(i,j).sid;
                        end
                        if isfield(freq1Struct,'f1')
                            obj(i,j).F1 = freq1Struct(i,j).f1;
                        end
                        if isfield(freq1Struct,'df')
                            obj(i,j).Df = freq1Struct(i,j).df;
                        end
                        if isfield(freq1Struct,'ndf')
                            obj(i,j).Ndf = freq1Struct(i,j).ndf;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % FREQ1 SID F1  DF  NDF
            % FREQ1 6   2.9 0.5 13
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set format specification
                    formatSpec = '%-8s%-8d';
                    if abs(obj(i,j).F1) >= 1e2
                        f1FormatSpec = '%-8.1e';
                    else
                        f1FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Df) >= 1e2
                        dfFormatSpec = '%-8.1e';
                    else
                        dfFormatSpec = '%-8.4f';
                    end
                    formatSpec = [formatSpec,f1FormatSpec,dfFormatSpec,...
                        '%-8d\n'];
                    % Write to file
                    fprintf(fileId,formatSpec,'FREQ1',obj(i,j).Sid,...
                        obj(i,j).F1,obj(i,j).Df,obj(i,j).Ndf);
                end
            end
        end
    end
end