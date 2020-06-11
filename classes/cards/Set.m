classdef Set < matlab.mixin.Copyable
    % Set (Case) class
    
    %% Properties
    properties
        N           % Unique identification number
        GridVector  % Vector of Grid objects representing the structural grid points in the list
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        I     % List of structural grid point or element identification numbers
    end
    
    methods
        %% Constructor
        function obj = Set(setStruct)
            %Set Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(setStruct);
                obj(m,n) = Set;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(setStruct,'n')
                            obj(i,j).N = setStruct(i,j).n;
                        end
                        if isfield(setStruct,'gridVector')
                            obj(i,j).GridVector =...
                                setStruct(i,j).gridVector;
                        end
                    end
                end
            end
        end
        
        %% Idi get method
        function i = get.I(obj)
            if ~isempty(obj.GridVector)
                i = [obj.GridVector.Id];
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % SET n = {i1[,i2, i3, THRU i4, EXCEPT i5, i6, i7, i8, THRU i9]}
            % SET n = {r1 [,r2, r3, r4]}
            % SET = ALL
            % SET n = {i1 ? c1[,i2 ? c2, i3 ? c3, i4 ? c4]}
            % SET n = {l1, [l2, l3]}
            % 
            % SET 77=5
            % SET 88=5, 6, 7, 8, 9, 10 THRU 55 EXCEPT 15, 16, 77, 78, 79, 100 THRU
            % 300
            % SET 99=1 THRU 100000
            % SET 101=1.0, 2.0, 3.0
            % SET 105=1.009, 10.2, 13.4, 14.0, 15.0
            % SET 1001=101/T1, 501/T3, 991/R3
            % SET 2001=M1,M2
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Count number of lines needed
                    nGridPoints = length(obj(i,j).I);
                    if nGridPoints <= 8
                        nGridPointEachLine = nGridPoints;
                    else
                        nLines = ceil((nGridPoints-8)/9)+1;
                        nGridPointEachLine = [8,repmat(9,1,nLines-2),...
                            nGridPoints-8-9*(nLines-2)];
                    end
                    % Set format specification
                    formatSpec = '%s %d = ';
                    for k=1:length(nGridPointEachLine)-1
                        formatSpec = [formatSpec,...
                            repmat('%d, ',1,nGridPointEachLine(k)-1),...
                            '%d,\n'];
                    end
                    formatSpec = [formatSpec,...
                        repmat('%d, ',1,nGridPointEachLine(end)-1),'%d\n'];
                    % Write to file
                    iCell = num2cell(obj(i,j).I);
                    fprintf(fileID,formatSpec,'SET',obj(i,j).N,iCell{:});
                end
            end
        end
    end
end