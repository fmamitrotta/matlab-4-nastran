classdef Mkaero1 < handle
    properties
        Mi  % List of from 1 to 8 Mach numbers
        Kj  % List of from 1 to 8 reduced frequencies
    end
    
    methods
        %% Constructor
        function obj = Mkaero1(mkaeroStruct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(mkaeroStruct);
                obj(m,n) = Mkaero1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(mkaeroStruct,'mi')
                            obj(i,j).Mi = mkaeroStruct(i,j).mi;
                        end
                        if isfield(mkaeroStruct,'kj')
                            obj(i,j).Kj = mkaeroStruct(i,j).kj;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % MKAERO1   m1 m2 m3 m4 m5 m6 m7 m8
            %           k1 k2 k3 k4 k5 k6 k7 k8
            % MKAERO1   .1 .7
            %           .3 .6 1.0
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set format specification for card name
                    basicFormatSpec = '%-8s';
                    % Set format specification for Mach numbers
                    machFormatSpec = '';
                    for k=1:length(obj(i,j).Mi)
                        if abs(obj(i,j).Mi(k)) >= 1e2
                            machFormatSpec = [machFormatSpec,'%-8.1e'];
                        else
                            machFormatSpec = [machFormatSpec,'%-8.4f'];
                        end
                    end
                    machFormatSpec = [machFormatSpec,'\n'];
                    % Set format specification for reduced frequencies
                    reducedFrequenciesFormatSpec = '';
                    for k=1:length(obj(i,j).Kj)
                        if abs(obj(i,j).Kj(k)) >= 1e2
                            reducedFrequenciesFormatSpec =...
                                [reducedFrequenciesFormatSpec,'%-8.1e'];
                        else
                            reducedFrequenciesFormatSpec =...
                                [reducedFrequenciesFormatSpec,'%-8.4f'];
                        end
                    end
                    reducedFrequenciesFormatSpec =...
                        [reducedFrequenciesFormatSpec,'\n'];
                    % Set final format specification
                    formatSpec = [basicFormatSpec,machFormatSpec,...
                        repmat(' ',1,8),reducedFrequenciesFormatSpec];
                    miCell = num2cell(obj(i,j).Mi);
                    kjCell = num2cell(obj(i,j).Kj);
                    % Write to file
                    fprintf(fileId,formatSpec,'MKAERO1',miCell{:},...
                        kjCell{:});
                end
            end
        end
    end
end
