classdef Mat1 < matlab.mixin.Copyable
    % Class for the handling of the Nastran MAT1 entry.
    properties
        Mid     % Material identification number
        E       % Young’s modulus
        G       % Shear modulus
        Nu      % Poisson’s ratio
        Rho     % Mass density
    end
    methods
        %% Constructor from struct input
        function obj = Mat1(mat1Struct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                obj(size(mat1Struct,1),1) = Mat1;
                for i = size(mat1Struct,1):-1:1
                    obj(i).Mid = mat1Struct(i).mid;
                    obj(i).E = mat1Struct(i).e;
                    obj(i).G = mat1Struct(i).g;
                    obj(i).Nu = mat1Struct(i).nu;
                    obj(i).Rho = mat1Struct(i).rho;
                end
            end
        end
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % MAT1  MID E   G   NU      RHO A TREF GE
            %       ST  SC  SS  MCSID
            for i = 1:length(obj)
                formatSpec = '%-8s%-8d%-8.1e%-8.1e%-8.2f%-8.3f\n';
                fprintf(fileID,formatSpec,'MAT1',obj(i).Mid,obj(i).E,...
                    obj(i).G,obj(i).Nu,obj(i).Rho);
            end
        end
    end
end