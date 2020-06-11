classdef Tabdmp1 < handle
    properties
        Tid     % Table identification number
        Type    % Type of damping units
        Fi      % Natural frequency value in cycles per unit time
        Gi      % Damping value
    end
    methods
        %% Constructor
        function obj = Tabdmp1(tabdmp1Struct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(tabdmp1Struct);
                obj(m,n) = Tabdmp1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(tabdmp1Struct,'tid')
                            obj(i,j).Tid = tabdmp1Struct(i,j).tid;
                        end
                        if isfield(tabdmp1Struct,'type')
                            obj(i,j).Type = tabdmp1Struct(i,j).type;
                        end
                        if isfield(tabdmp1Struct,'fi')
                            obj(i,j).Fi = tabdmp1Struct(i,j).fi;
                        end
                        if isfield(tabdmp1Struct,'gi')
                            obj(i,j).Gi = tabdmp1Struct(i,j).gi;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % TABDMP1   TID TYPE
            %           f1  g1      f2  g2      f3      g3 -etc.-
            % TABDMP1   2
            %           2.5 .01057  2.6 .01362  ENDT
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set first line format specification
                    if ~isempty(obj(i,j).Type)
                        firstLineFormatSpec = '%-8s%-8d%-8s\n';
                    else
                        firstLineFormatSpec = '%-8s%-8d\n';
                    end
                    % Count number of lines needed
                    nFrequencies = length(obj(i,j).Fi);
                    nLines = ceil(nFrequencies/4);
                    nFrequenciesEachLine = [repmat(4,1,nLines-1),...
                            nFrequencies-4*(nLines-1)];
                    % Set format specifications for frequencies based on
                    % second frequency in the list
                    if abs(obj(i,j).Fi(2)) >= 1e2
                        frequencyFormatSpec = '%-8.1e';
                    else
                        frequencyFormatSpec = '%-8.4f';
                    end
                    % Set format specifications for frequencies based on
                    % second frequency in the list
                    if abs(obj(i,j).Gi(2)) >= 1e2
                        dampingFormatSpec = '%-8.1e';
                    else
                        dampingFormatSpec = '%-8.4f';
                    end
                    % Set format specification for all lines
                    formatSpec = '';
                    for k=1:length(nFrequenciesEachLine)-1
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat([frequencyFormatSpec,dampingFormatSpec],...
                            1,nFrequenciesEachLine(k)),'\n'];
                    end
                    formatSpec = [firstLineFormatSpec,formatSpec,...
                        repmat(' ',1,8),repmat(...
                        [frequencyFormatSpec,dampingFormatSpec],...
                        1,nFrequenciesEachLine(end)),'%-8s\n'];
                    % Write to file
                    tabdmpCell = num2cell(reshape(...
                        [obj(i,j).Fi;obj(i,j).Gi],1,[]));
                    fprintf(fileId,formatSpec,'TABDMP1',obj(i,j).Tid,...
                        tabdmpCell{:},'ENDT');
                end
            end
        end
    end
end
