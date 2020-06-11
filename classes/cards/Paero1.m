classdef Paero1 < matlab.mixin.Copyable
    properties
        Pid  % Property identification number referenced by a CAERO1 entry
        Bi   % Identification number of CAERO2 entries for associated bodies. Embedded blanks are not allowed
    end
    methods
        %% Constructor from struct input
        function obj = Paero1(paero1Struct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(paero1Struct);
                obj(m,n) = Paero1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(paero1Struct,'pid')
                            obj(i,j).Pid = paero1Struct(i,j).pid;
                        end
                        if isfield(paero1Struct,'bi')
                            obj(i,j).Bi = paero1Struct(i,j).bi;
                        end
                    end
                end
            end
        end
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % PAERO1 PID    B1 B2 B3 B4 B5 B6
            % PAERO1 1      3
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    nBodies = length(obj(i,j).Bi);
                    if nBodies <= 6
                        nBodiesEachLine = nBodies;
                    else
                        nLines = ceil((nBodies-6)/8)+1;
                        nBodiesEachLine = [6,...
                            repmat(8,1,nLines-2),nBodies-6-8*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = ['%-8s%-8d',...
                        repmat('%-8d',1,nBodiesEachLine(1)),'\n'];
                    for k = 2:length(nBodiesEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat('%-8d',1,nBodiesEachLine(k)),'\n'];
                    end
                    % Write to file
                    biCell = num2cell(obj(i,j).Bi);
                    fprintf(fileID,formatSpec,'PAERO1',obj(i,j).Pid,...
                        biCell{:});
                end
            end
        end
    end
end