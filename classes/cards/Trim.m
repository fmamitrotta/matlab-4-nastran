classdef Trim < matlab.mixin.Copyable
    
    %% Properties
    properties
        Sid         % Trim set identification number
        Mach        % Mach number
        Q           % Dynamic pressure
        Labeli      % The label identifying aerodynamic trim variables defined on an AESTAT or AESURF entry
        Uxi         % The magnitude of the aerodynamic extra point degree-of-freedom
        Aeqr = 1;   % Flag to request a rigid trim analysis (Real > 0.0 and < 1.0; Default =1.0). A value of 0.0 provides a rigid trim analysis
    end
    
    methods
        %% Constructor from struct input
        function obj = Trim(trimStruct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(trimStruct);
                obj(m,n) = Trim;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(trimStruct,'sid')
                            obj(i,j).Sid = trimStruct(i,j).sid;
                        end
                        if isfield(trimStruct,'mach')
                            obj(i,j).Mach = trimStruct(i,j).mach;
                        end
                        if isfield(trimStruct,'q')
                            obj(i,j).Q = trimStruct(i,j).q;
                        end
                        if isfield(trimStruct,'labeli')
                            % Assign the Labeli property always as a cell
                            % array
                            if ~iscell(trimStruct(i,j).labeli)
                                trimStruct(i,j).labeli =...
                                    {trimStruct(i,j).labeli};
                            end
                            obj(i,j).Labeli = trimStruct(i,j).labeli;
                        end
                        if isfield(trimStruct,'uxi')
                            obj(i,j).Uxi = trimStruct(i,j).uxi;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % TRIM  SID     MACH    Q       LABEL1  UX1 LABEL2 UX2 AEQR
            %       LABEL3  UX3     -etc.-
            % TRIM  1       0.9     100.    URDD3   1.0 ANGLEA 7.0 0.0
            %       ELEV    0.2
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    nLabels = length(obj(i,j).Labeli);
                    if nLabels <= 2
                        nLabelsEachLine = nLabels;
                    else
                        nLines = ceil((nLabels-2)/4)+1;
                        nLabelsEachLine = [2,...
                            repmat(4,1,nLines-2),nLabels-2-4*(nLines-2)];
                    end
                    % Set format specification
                    if nLabels == 1
                        aeqrFormatSpec = [repmat(' ',1,16),'%-8.1f'];
                    else
                        aeqrFormatSpec = '%-8.1f';
                    end
                    baseFormatSpecFirstLine = '%-8s%-8d';
                    % Set Mach format specification
                    if abs(obj(i,j).Mach)>=1e2 || abs(obj(i,j).Mach)<1e-3
                        machFormatSpec = '%-8.1e';
                    else
                        machFormatSpec = '%-8.4f';
                    end
                    % Set dynamic pressure format specification
                    if abs(obj(i,j).Q)>=1e2 || abs(obj(i,j).Q)<1e-3
                        qFormatSpec = '%-8.1e';
                    else
                        qFormatSpec = '%-8.4f';
                    end
                    % Set format specification of rest of first line
                    restOfLineFormatSpec = '';
                    for k=1:nLabelsEachLine(1)
                        if abs(obj(i,j).Uxi(k))>=1e2 ||...
                                abs(obj(i,j).Uxi(k))<1e-3
                            restOfLineFormatSpec = [restOfLineFormatSpec,...
                                '%-8s%-8.1e'];
                        else
                            restOfLineFormatSpec = [restOfLineFormatSpec,...
                                '%-8s%-8.4f'];
                        end
                    end
                    formatSpecFirstLine = [baseFormatSpecFirstLine,...
                        machFormatSpec,qFormatSpec,restOfLineFormatSpec,...
                        aeqrFormatSpec,'\n'];
                    % If there are more than two Aestat labels, then set
                    % the format specification of the rest of the lines
                    if nLabels > 2
                        for k = length(nLabelsEachLine):-1:2
                            lineFormatSpec = '';
                            for l=1:nLabelsEachLine(k)
                                if abs(obj(i,j).Uxi(2+4*(k-2)+l))>=1e2 ||...
                                        abs(obj(i,j).Uxi(2+4*(k-2)+l))<1e-3
                                    lineFormatSpec = [lineFormatSpec,...
                                        '%-8s%-8.1e'];
                                else
                                    lineFormatSpec = [lineFormatSpec,...
                                        '%-8s%-8.4f'];
                                end
                            end
                            formatSpecArray{k-1} = [lineFormatSpec,'\n'];
                        end
                        formatSpecOtherLine = strcat(formatSpecArray{:});
                    end
                    % Retrieve combined labels and magnitudes
                    uxiCell = num2cell(obj(i,j).Uxi);
                    combinedLabeliUxiCell = [obj(i,j).Labeli;uxiCell];
                    % Write first line
                    fprintf(fileID,formatSpecFirstLine,'TRIM',...
                        obj(i,j).Sid,obj(i,j).Mach,obj(i,j).Q,...
                        combinedLabeliUxiCell{1:nLabelsEachLine(1)*2},...
                        obj(i,j).Aeqr);
                    % Write other lines
                    if nLabels > 2
                        fprintf(fileID,formatSpecOtherLine,...
                            combinedLabeliUxiCell{...
                            nLabelsEachLine(1)*2+1:end});
                    end
                end
            end
        end
    end
end
