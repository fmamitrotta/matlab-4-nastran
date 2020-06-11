classdef Eigrl < matlab.mixin.Copyable
    %Eigrl Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Sid     % Set identification number
        V1      % For vibration analysis: frequency range of interest. For buckling analysis: eigenvalue range of interest. See Remark 4. (Real or blank, –5 × 1016 ? V1 < V2 ? 5. × 1016)
        V2      
        Nd      % Number of roots desired. See Remark 4. (Integer > 0 or blank)
        Msglvl  % Diagnostic level. (0 < Integer < 4; Default = 0)
        Maxset  % Number of vectors in block or set. Default is machine dependent. See Remark 14.
        Shfscl  % Estimate of the first flexible mode natural frequency. See Remark 10. (Real or blank)
        Norm    % Method for normalizing eigenvectors (Character: “MASS” or “MAX”)
                % MASS Normalize to unit value of the generalized mass. Not available for buckling analysis. (Default for normal modes analysis.)
                % MAX Normalize to unit value of the largest displacement in the analysis set. Displacements not in the analysis set may be larger than unity. (Default for buckling analysis.)
    end
    
    %% Dependent properties
    properties (Dependent=true, SetAccess=private)
        G   % Grid point identification number
    end
    
    methods
        %% Constructor
        function obj = Eigrl(eigrlStruct)
            %Eigrl Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(eigrlStruct);
                obj(m,n) = Eigrl;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(eigrlStruct,'sid')
                            obj.Sid = eigrlStruct(i,j).sid;
                        end
                        if isfield(eigrlStruct,'v1')
                            obj.V1 = eigrlStruct(i,j).v1;
                        end
                        if isfield(eigrlStruct,'v2')
                            obj.V2 = eigrlStruct(i,j).v2;
                        end
                        if isfield(eigrlStruct,'nd')
                            obj.Nd = eigrlStruct(i,j).nd;
                        end
                        if isfield(eigrlStruct,'msglvl')
                            obj.Msglvl = eigrlStruct(i,j).msglvl;
                        end
                        if isfield(eigrlStruct,'maxset')
                            obj.Maxset = eigrlStruct(i,j).maxset;
                        end
                        if isfield(eigrlStruct,'shfscl')
                            obj.Shfscl = eigrlStruct(i,j).shfscl;
                        end
                        if isfield(eigrlStruct,'norm')
                            obj.Norm = eigrlStruct(i,j).norm;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % EIGRL     SID     V1  V2      ND    MSGLVL     MAXSET  SHFSCL   NORM
            %                     option_1 = value_1 option_2 = value_2, etc.
            % EIGRL     1       0.1 3.2     10
            %                            NORM=MAX NUMS=2
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    baseFormatSpec = '%-8s%-8d';
                    if isempty(obj(i,j).V1)
                        v1Format = '%-8s';
                    else
                        v1Format = '%-8f';
                    end
                    if isempty(obj(i,j).V2)
                        v2Format = '%-8s';
                    else
                        v2Format = '%-8f';
                    end
                    formatSpec =...
                        [baseFormatSpec,v1Format,v2Format,'%-8d\n'];
                    fprintf(fileId,formatSpec,'EIGRL',obj(i,j).Sid,...
                        obj(i,j).V1,obj(i,j).V2,obj(i,j).Nd);
                end
            end
        end
    end
end
