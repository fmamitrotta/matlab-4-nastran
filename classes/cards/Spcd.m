classdef Spcd < matlab.mixin.Copyable
    %Spcd Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Sid % Set identification number of the SPCD entry.
        GridVector  % Vector of grid points where the displacement is applied
        Ci  % Component numbers. See Remark 10. (0 < Integer < 6; any unique combination of Integers 1 through 6 with no embedded blanks for grid points; Integer 0, 1 or blank for scalar points)
        Di  % Value of enforced motion for components Gi at grid Ci.
    end
    
    %% Dependent properties
    properties (Dependent=true,SetAccess=private)
        Gi   % Grid or scalar point identification number
    end
    
    methods
        %% Constructor
        function obj = Spcd(spcdStruct)
            %Eigrl Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(spcdStruct);
                obj(m,n) = Spcd;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(spcdStruct,'sid')
                            obj.Sid = spcdStruct(i,j).sid;
                        end
                        if isfield(spcdStruct,'gridVector')
                            obj.GridVector = spcdStruct(i,j).gridVector;
                        end
                        if isfield(spcdStruct,'ci')
                            obj.Ci = spcdStruct(i,j).ci;
                        end
                        if isfield(spcdStruct,'di')
                            obj.Di = spcdStruct(i,j).di;
                        end
                    end
                end
            end
        end
        
        %% G get method
        function gi = get.Gi(obj)
            if ~isempty(obj.GridVector)
                gi = [obj.GridVector.Id];
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % SPCD SID G1 C1    D1      G2 C2   D2
            % SPCD 100 32 3     -2.6    5       2.9
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    baseFormatSpec = '%-8s%-8d%-8d%-8d';
                    if obj(i,j).Di(1) >= 1e2
                        diFormatSpec = '%-8.1e';
                    else
                        diFormatSpec = '%-8.4f';
                    end
                    formatSpec = [baseFormatSpec,diFormatSpec,'\n'];
                    fprintf(fileId,formatSpec,'SPCD',obj(i,j).Sid,...
                        obj(i,j).Gi(1),obj(i,j).Ci(1),obj(i,j).Di(1));
                end
            end
        end
    end
end
