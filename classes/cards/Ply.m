classdef Ply < matlab.mixin.Copyable
    %Ply Ply class.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        ParentLaminate  % Parent Laminate object
        El          % Young modulus along longitudinal axis [Pa]
        Et          % Young modulus along transverse axis [Pa]
        Glt         % Shear modulus [Pa]
        Nult        % Major Poisson's ratio
        Theta       % Ply orientation [deg]
        Thickness   % Ply thickness [m]
        Z = 0;      % Z-coordinate of ply mid-plane [m]
    end
    
    %% Dependent properties
    properties (Dependent=true)
        Nutl    % Minor Poisson's ratio
        Qxx     % Components of the stiffness matrix in ply axes
        Qxy
        Qyy
        Qss
        Q11     % Components of the stiffness matrix in laminate axes
        Q12
        Q16
        Q22
        Q26
        Q66
    end
    
    %% Private dependent properties
    properties (Dependent=true,Access=private)
        M   % cosine of theta
        N   % sine of theta
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = Ply(plyStruct)
            %Ply Construct an instance of this class
            %   Assignation of all the basic variables for calculation of
            %   stiffness matrices of the ply
            
            % If number of input variable is not zero
            if nargin ~= 0
                % Check whether all mandatory fields are present in the
                % input structure
                mandatoryFieldArray = {'el','et','glt','nult','theta',...
                    'thickness'};
                inputFieldArray = fieldnames(plyStruct);
                missingFieldArray = setdiff(mandatoryFieldArray,...
                    inputFieldArray);
                if ~isempty(missingFieldArray)
                    % If one or more mandatory fields are absent, give an
                    % error reporting the fields that are missing
                    formatSpec = repmat('%s ',1,length(missingFieldArray));
                    error(['Mandatory field ',formatSpec,...
                        'missing from input structure'],...
                        missingFieldArray{:});
                end
                % Initialize the object giving it the same size of the
                % input structure
                [m,n] = size(plyStruct);
                obj(m,n) = Ply;
                % Iterate through the row and columns of the input
                % structure
                for i = m:-1:1
                    for j = n:-1:1
                        obj(i,j).El = plyStruct(i,j).el;
                        obj(i,j).Et = plyStruct(i,j).et;
                        obj(i,j).Glt = plyStruct(i,j).glt;
                        obj(i,j).Nult = plyStruct(i,j).nult;
                        obj(i,j).Theta = plyStruct(i,j).theta;
                        obj(i,j).Thickness = plyStruct(i,j).thickness;
                        if isfield(plyStruct,'z')
                            obj(i,j).Z = plyStruct(i,j).z;
                        end
                    end
                end
            end
        end
        
        %% Nutl get method
        function nutl = get.Nutl(obj)
            %get.Nutl Calculates the minor Poisson's ratio.
            nutl = obj.Nult*obj.Et/obj.El;
        end
        
        %% Qxx get method
        function qxx = get.Qxx(obj)
            %get.Qxx Calculates Qxx for the single ply plane stress stiffness matrix.
            qxx = obj.El/(1-obj.Nult*obj.Nutl);
        end
        
        %% Qxy get method
        function qxy = get.Qxy(obj)
            %get.Qxy Calculates Qxy for the single ply plane stress stiffness matrix.
            qxy = obj.Nult*obj.Et/(1-obj.Nult*obj.Nutl);
        end
        
        %% Qyy get method
        function qyy = get.Qyy(obj)
            %get.Qyy Calculates Qyy for the single ply plane stress stiffness matrix.
            qyy = obj.Et/(1-obj.Nult*obj.Nutl);
        end
        
        %% Qss get method
        function qss = get.Qss(obj)
            %get.Qss Calculates Qss for the single ply plane stress stiffness matrix.
            qss = obj.Glt;
        end
        
        %% Q11 get method
        function q11 = get.Q11(obj)
            %get.Q11 Calculates Q11 for the sinle ply plane stress stiffness matrix, rotated by an angle theta.
            q11 = obj.M^4*obj.Qxx+...
                obj.N^4*obj.Qyy+...
                2*obj.M^2*obj.N^2*obj.Qxy+...
                4*obj.M^2*obj.N^2*obj.Qss;
        end
        
        %% Q12 get method
        function q12 = get.Q12(obj)
            %get.Q12 Calculates Q12 for the sinle ply plane stress stiffness matrix, rotated by an angle theta.
            q12 = obj.M^2*obj.N^2*obj.Qxx+...
                obj.M^2*obj.N^2*obj.Qyy+...
                (obj.M^4+obj.N^4)*obj.Qxy-...
                4*obj.M^2*obj.N^2*obj.Qss;
        end
        
        %% Q16 get method
        function q16 = get.Q16(obj)
            %get.Q16 Calculates Q16 for the sinle ply plane stress stiffness matrix, rotated by an angle theta.
            q16 = obj.M^3*obj.N*obj.Qxx-...
                obj.M*obj.N^3*obj.Qyy+...
                (obj.M*obj.N^3-obj.M^3*obj.N)*obj.Qxy+...
                2*(obj.M*obj.N^3-obj.M^3*obj.N)*obj.Qss;
        end
        
        %% Q22 get method
        function q22 = get.Q22(obj)
            %get.Q22 Calculates Q22 for the sinle ply plane stress stiffness matrix, rotated by an angle theta.
            q22 = obj.N^4*obj.Qxx+...
                obj.M^4*obj.Qyy+...
                2*obj.M^2*obj.N^2*obj.Qxy+...
                4*obj.M^2*obj.N^2*obj.Qss;
        end
        
        %% Q26 get method
        function q26 = get.Q26(obj)
            %get.Q26 Calculates Q26 for the sinle ply plane stress stiffness matrix, rotated by an angle theta.
            q26 = obj.M*obj.N^3*obj.Qxx-...
                obj.M^3*obj.N*obj.Qyy+...
                (obj.M^3*obj.N-obj.M*obj.N^3)*obj.Qxy+...
                2*(obj.M^3*obj.N-obj.M*obj.N^3)*obj.Qss;
        end
        
        %% Q66 get method
        function q66 = get.Q66(obj)
            %get.Q66 Calculates Q66 for the sinle ply plane stress stiffness matrix, rotated by an angle theta.
            q66 = obj.M^2*obj.N^2*obj.Qxx+...
                obj.M^2*obj.N^2*obj.Qyy-...
                2*obj.M^2*obj.N^2*obj.Qxy+...
                (obj.M^2-obj.N^2)^2*obj.Qss;
        end
        
        %% M get method
        function m = get.M(obj)
            %get.M Calculates the cosine of the ply angle theta.
            % Theta is flipped because the transformation is from the ply
            % axes to the laminate axes and not viceversa.
            theta = obj.Theta;
            m = cosd(theta);
        end
        
        %% N get method
        function n = get.N(obj)
            %get.N Calculates the sine of the ply angle theta.
            % Theta is flipped because the transformation is from the ply
            % axes to the laminate axes and not viceversa.
            theta = obj.Theta;
            n = sind(theta);
        end
        
        %% StiffnessMatrixPlyAxes method
        function e = StiffnessMatrixPlyAxes(obj)
            %StiffnessMatrixPlyAxes Assembles the stiffness matrix in ply axes.
            e = [obj.Qxx,obj.Qxy,0;...
                obj.Qxy,obj.Qyy,0;...
                0,0,obj.Qss];
        end
        %% StiffnessMatrixLaminateAxes method
        function e = StiffnessMatrixLaminateAxes(obj)
            %StiffnessMatrixLaminateAxes Assembles the stiffness matrix in laminate axes.
            e = [obj.Q11,obj.Q12,obj.Q16;...
                obj.Q12,obj.Q22,obj.Q26;...
                obj.Q16,obj.Q26,obj.Q66];
        end
    end
end
