classdef Force < matlab.mixin.Copyable
    %Force Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Sid         % Load set identification number
        GridPoint   % Grid object representing the force application point
        Cid = 0;    % Coordinate system identification number. (Integer > 0; Default = 0)
        F           % Scale factor
        Ni          % Components of a vector measured in coordinate system defined by CID. (Real; at least one Ni ? 0.0. unless F is zero)
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        G   % Grid point identification number
    end
    
    methods
        %% Constructor
        function obj = Force(forceStruct)
            %Force Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(forceStruct);
                obj(m,n) = Force;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj(i,j).Sid = forceStruct(i,j).sid;
                        obj(i,j).GridPoint = forceStruct(i,j).gridPoint;
                        obj(i,j).F = forceStruct(i,j).f;
                        obj(i,j).Ni = forceStruct(i,j).ni;
                    end
                end
            end
        end
        
        %% G get method
        function g = get.G(obj)
            if ~isempty(obj.GridPoint)
                g = obj.GridPoint.Id;
            end
        end
        
        %% Write entry to .bdf file
        function write2Bdf(obj,fileID)
            % FORCE SID G CID   F   N1  N2  N3
            % FORCE 2   5 6     2.9 0.0 1.0 0.0
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    if obj(i,j).F >= 1e2
                        scaleFactorFormat = '%-8.1e';
                    else
                        scaleFactorFormat = '%-8.4f';
                    end
                    formatSpec = ['%-8s%-8d%-8d%-8d',scaleFactorFormat,...
                        repmat('%-8.2f',1,3),'\n'];
                    niCell = num2cell(obj(i,j).Ni);
                    fprintf(fileID,formatSpec,'FORCE',obj(i,j).Sid,...
                        obj(i,j).G,obj(i,j).Cid,obj(i,j).F,niCell{:});
                end
            end
        end
    end
end
