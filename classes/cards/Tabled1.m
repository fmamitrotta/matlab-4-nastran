classdef Tabled1 < handle
    properties
        Tid         % Table identification number
        Xaxis = ''; % Specifies a linear or logarithmic interpolation for the x-axis
        Yaxis = ''; % Specifies a linear or logarithmic interpolation for the y-axis
        Xi          % Tabular values
        Yi          % Tabular values
    end
     
    methods
        %% Constructor
        function obj = Tabled1(tabled1Struct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(tabled1Struct);
                obj(m,n) = Tabled1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(tabled1Struct,'tid')
                            obj(i,j).Tid = tabled1Struct(i,j).tid;
                        end
                        if isfield(tabled1Struct,'xaxis')
                            obj(i,j).Xaxis = tabled1Struct(i,j).xaxis;
                        end
                        if isfield(tabled1Struct,'yaxis')
                            obj(i,j).Yaxis = tabled1Struct(i,j).yaxis;
                        end
                        if isfield(tabled1Struct,'xi')
                            obj(i,j).Xi = tabled1Struct(i,j).xi;
                        end
                        if isfield(tabled1Struct,'yi')
                            obj(i,j).Yi = tabled1Struct(i,j).yi;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % TABLED1   TID     XAXIS   YAXIS
            %           x1      y1      x2      y2  x3  y3  -etc.- “ENDT”
            % TABLED1   32
            %           -3.0    6.9     2.0     5.6 3.0 5.6 ENDT
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set first line format specification
                    firstLineFormatSpec = '%-8s%-8d%-8s%-8s\n';
                    % Count number of lines needed
                    nPoints = length(obj(i,j).Xi);
                    nLines = ceil(nPoints/4);
                    nPointsEachLine = [repmat(4,1,nLines-1),...
                            nPoints-4*(nLines-1)];
                    % Set format specifications for frequencies based on
                    % second frequency in the list
                    if abs(obj(i,j).Xi(2)) >= 1e2
                        xiFormatSpec = '%-8.1e';
                    else
                        xiFormatSpec = '%-8.4f';
                    end
                    % Set format specifications for frequencies based on
                    % second frequency in the list
                    if abs(obj(i,j).Yi(2)) >= 1e2
                        yiFormatSpec = '%-8.1e';
                    else
                        yiFormatSpec = '%-8.4f';
                    end
                    % Set format specification for all lines
                    formatSpec = '';
                    for k=1:length(nPointsEachLine)-1
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat([xiFormatSpec,yiFormatSpec],...
                            1,nPointsEachLine(k)),'\n'];
                    end
                    if nPointsEachLine(end) == 4
                        formatSpec = [firstLineFormatSpec,formatSpec,...
                            repmat(' ',1,8),repmat(...
                            [xiFormatSpec,yiFormatSpec],1,...
                            nPointsEachLine(end)),'\n',repmat(' ',1,8),...
                            '%-8s\n'];
                    else
                        formatSpec = [firstLineFormatSpec,formatSpec,...
                            repmat(' ',1,8),repmat(...
                            [xiFormatSpec,yiFormatSpec],1,...
                            nPointsEachLine(end)),'%-8s\n'];
                    end
                    % Write to file
                    tabledCell = num2cell(reshape(...
                        [obj(i,j).Xi;obj(i,j).Yi],1,[]));
                    fprintf(fileId,formatSpec,'TABLED1',obj(i,j).Tid,...
                        obj(i,j).Xaxis,obj(i,j).Yaxis,tabledCell{:},...
                        'ENDT');
                end
            end
        end
    end
end
