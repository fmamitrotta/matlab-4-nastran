classdef Mat2 < matlab.mixin.Copyable
    % Class for the handling of the Nastran MAT2 entry.
    
    %% Properties
    properties
        Mid     % Material identification number
        G11     % The material property matrix
        G12
        G13
        G22
        G23
        G33
        Rho     % Mass density
    end
    
    methods
        %% Constructor
        function obj = Mat2(mat2Struct)
            %Mat2 Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(mat2Struct);
                obj(m,n) = Mat2;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(mat2Struct,'mid')
                            obj.Mid(i,j) = mat2Struct(i,j).mid;
                        end
                        if isfield(mat2Struct,'gMatrix')
                            obj(i,j).G11 = mat2Struct(i,j).gMatrix(1,1);
                            obj(i,j).G12 = mat2Struct(i,j).gMatrix(1,2);
                            obj(i,j).G13 = mat2Struct(i,j).gMatrix(1,3);
                            obj(i,j).G22 = mat2Struct(i,j).gMatrix(2,2);
                            obj(i,j).G23 = mat2Struct(i,j).gMatrix(2,3);
                            obj(i,j).G33 = mat2Struct(i,j).gMatrix(3,3);
                        end
                        if isfield(mat2Struct,'rho')
                            obj(i,j).Rho = mat2Struct(i,j).rho;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % Write to .bdf file
            
            % MAT2  MID     G11     G12     G13     G22     G23     G33     RHO
            %       A1      A2      A3      TREF    GE      ST      SC      SS
            %       MCSID
            % MAT2  13      6.2+3                   6.2+3           5.1+3   0.056
            %       6.5-6   6.5-6           -500.0  0.002   20.+5
            %       1003
            for i = 1:length(obj)
                formatSpec = '%-8s%-8d';
                gij = [obj(i).G11,obj(i).G12,obj(i).G13,obj(i).G22,...
                    obj(i).G23,obj(i).G33];
                for j = 1:length(gij)
                    if abs(gij(j))>=1e2 || abs(gij(j))<1e-3
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                end
                if abs(obj(i).Rho)>=1e2 || abs(obj(i).Rho)<1e-3
                    rhoFormatSpec = '%-8.1e';
                else
                    rhoFormatSpec = '%-8.4f';
                end
                formatSpec = [formatSpec,rhoFormatSpec,'\n'];
                fprintf(fileID,formatSpec,'MAT2',obj(i).Mid,obj(i).G11,...
                    obj(i).G12,obj(i).G13,obj(i).G22,obj(i).G23,...
                    obj(i).G33,obj(i).Rho);
            end
        end
    end
end
