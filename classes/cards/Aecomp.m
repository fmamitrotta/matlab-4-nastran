classdef Aecomp < matlab.mixin.Copyable
    %Aecomp Defines a component for use in monitor point definition or
    %external splines.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Name        % A character string of up to eight characters identifying the component. (Character)
        Listtype    % One of CAERO, AELIST or CMPID for aerodynamic components and SET1 for structural components. Aerodynamic components are defined on the aerodynamic ks-set mesh while the structural components are defined on the gset mesh.
        Listidi     % The identification number of either SET1, AELIST or CAEROi entries that define the set of grid points that comprise the component.
    end
    
    methods
        %% Constructor from struct input
        function obj = Aecomp(aecompStruct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(aecompStruct);
                obj(m,n) = Aecomp;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(aecompStruct,'name')
                            obj(i,j).Name = aecompStruct(i,j).name;
                        end
                        if isfield(aecompStruct,'listtype')
                            obj(i,j).Listtype = aecompStruct(i,j).listtype;
                        end
                        if isfield(aecompStruct,'listidi')
                            obj(i,j).Listidi = aecompStruct(i,j).listidi;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % AECOMP NAME       LISTTYPE    LISTID1 LISTID2 LISTID3 LISTID4 LISTID5 LISTID6
            %        LISTID7    -etc.-
            % AECOMP WING       AELIST      1001    1002
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    noIds = length(obj(i,j).Listidi);
                    if noIds <= 6
                        noIdsEachLine = noIds;
                    else
                        noLines = ceil((noIds-6)/8)+1;
                        noIdsEachLine = [6,...
                            repmat(8,1,noLines-2),noIds-6-8*(noLines-2)];
                    end
                    % Set format specification
                    formatSpec = ['%-8s%-8s%-8s',...
                        repmat('%-8d',1,noIdsEachLine(1)),'\n'];
                    for k = 2:length(noIdsEachLine)
                        formatSpec = [formatSpec,repmat(' ',1,8),...
                            repmat('%-8d',1,noIdsEachLine(k)),'\n'];
                    end
                    % Write to file
                    idsCell = num2cell(obj(i,j).Listidi);
                    fprintf(fileID,formatSpec,'AECOMP',...
                        obj(i,j).Name,obj(i,j).Listtype,idsCell{:});
                end
            end
        end
    end
end