classdef Laminate < matlab.mixin.Copyable
    %Laminate Laminate class.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        PlyArray = Ply.empty;       % Array of children Ply objects
        IsSymmetric = true;         % Logical that determines whether the laminate is symmetric
        CentrePlySymmetry = false;  % Logical that determines whether the symmetry of the laminate is about the centre ply
    end
    
    %% Dependent properties
    properties (Dependent=true)
        ContractedThicknessVector   % Vector indicating the half thickness distribution among the plies, only for symmetric laminates; if symmetry is about the centre ply, then also the centre plane is included (from bottom to top) [m]
        FullThicknessVector         % Vector indicating the full thickness distribution among the plies (from bottom to top) [m]
        TotalThickness              % Laminate total thickness
        ContractedOrientationVector % Vector indicating the half angle distribution among the plies, only for symmetric laminates; if symmetry is about the centre ply, then also the centre plane is included (from bottom to top) [deg]
        FullOrientationVector       % Vector indicating the full angle distribution among the plies (from bottom to top) [m]
        A                   % A matrix
        B                   % B matrix
        D                   % D matrix
        Ahat                % Normalized A matrix
        Bhat                % Normalized B matrix
        Dhat                % Normalized D matrix
        Va                  % Lamination parameters of matrix A
        Vb                  % Lamination parameters of matrix B
        Vd                  % Lamination parameters of matrix D
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = Laminate(laminateStruct)
            %Laminate Construct an instance of this class
            
            % If number of input variable is not zero
            if nargin ~= 0
                % Check whether all mandatory fields are present in the
                % input structure
                mandatoryFieldArray = {'el','et','glt','nult',...
                    'orientationVector','thickness'};
                inputFieldArray = fieldnames(laminateStruct);
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
                [m,n] = size(laminateStruct);
                obj(m,n) = Laminate;
                % Iterate through the row and columns of the input
                % structure
                for i = m:-1:1
                    for j = n:-1:1
                        % Assign optional properties
                        if isfield(laminateStruct,'isSymmetric')
                            obj.IsSymmetric =...
                                laminateStruct(i,j).isSymmetric;
                        end
                        if isfield(laminateStruct,'centrePlySymmetry')
                            obj.CentrePlySymmetry =...
                                laminateStruct(i,j).centrePlySymmetry;
                        end
                        % Check that angle vector is a column vector and in
                        % case it is not make it a column vector
                        if size(laminateStruct(i,j).orientationVector,2)>1
                            laminateStruct(i,j).orientationVector =...
                                laminateStruct(i,j).orientationVector';
                        end
                        % Determine number of plies as indicated in the
                        % angle vector (vector giving the orientation angle
                        % of the plies). If laminate is symmetric nPlies
                        % does not indicate the total number of plies
                        nPlies =...
                            length(laminateStruct(i,j).orientationVector);
                        % Define vector containing the z positions (ply
                        % mid-plane) of the plies within the laminate. This
                        % vector goes always top to bottom
                        if obj(i,j).IsSymmetric
                            % If laminate is symmetric only half of the
                            % vector containing the z positions is
                            % calculated
                            if obj(i,j).CentrePlySymmetry
                                % If laminate has centre ply symmetry, then
                                % z position of centre ply is 0 and the z
                                % position of the top ply corresponds to
                                % the ply thickness multiplied by the
                                % number of plies minus 1
                                zVector = (laminateStruct(i,j).thickness*...
                                    (nPlies-1):...
                                    -laminateStruct(i,j).thickness:0)';
                            else
                                % If laminate does not have centre ply
                                % symmetry, then the z position of the top
                                % ply corresponds to the ply thickness
                                % times the number of plies minus half ply
                                % thickness (z position indicates the ply
                                % mid-plane) and the other z positions are
                                % separated by a length equal to the ply
                                % thickness
                                zVector = (laminateStruct(i,j).thickness*...
                                    nPlies-laminateStruct(i,j).thickness/2:...
                                    -laminateStruct(i,j).thickness:0)';
                            end
                        else
                            % If laminate is not symmetric, then the full
                            % vector containing the z positions is
                            % calculated. The z position of the top ply is
                            % given by the ply thickness times half the
                            % number of plies minus half ply thickness and
                            % the z position of the bottom ply is given by
                            % the opposite of that. The z positions of the
                            % plies are separated by a distance equal to
                            % the ply thickness
                            zVector = (laminateStruct(i,j).thickness*...
                                nPlies/2-laminateStruct(i,j).thickness/2:...
                                -laminateStruct(i,j).thickness:...
                                -(laminateStruct(i,j).thickness*...
                                nPlies/2-laminateStruct(i,j).thickness/2))';
                        end
                        % Define structure for the generation of the Ply
                        % objects
                        plyStruct = struct('el',num2cell(...
                            laminateStruct(i,j).el*ones(nPlies,1)),...
                            'et',num2cell(...
                            laminateStruct(i,j).et*ones(nPlies,1)),...
                            'glt',num2cell(...
                            laminateStruct(i,j).glt*ones(nPlies,1)),...
                            'nult',num2cell(...
                            laminateStruct(i,j).nult*ones(nPlies,1)),...
                            'theta',num2cell(...
                            laminateStruct(i,j).orientationVector),...
                            'thickness',num2cell(...
                            laminateStruct(i,j).thickness*ones(nPlies,1)),...
                            'z',num2cell(zVector));
                        % Generate the Ply objects. If laminate is
                        % symmetric, not all plies are generated
                        obj(i,j).PlyArray = Ply(plyStruct);
                    end
                end
            end
        end
        
        %% ContractedThicknessVector get method
        function contractedThicknessVector =...
                get.ContractedThicknessVector(obj)
            % Get the contracted thickness vector only in case of a
            % symmetric laminate
            if obj.IsSymmetric
                % Collect the thicknesses from the generated Ply objects
                contractedThicknessVector = [obj.PlyArray.Thickness];
            else
                contractedThicknessVector = [];
            end
        end
        
        %% FullThicknessVector get method
        function fullThicknessVector = get.FullThicknessVector(obj)
            if obj.IsSymmetric
                % If laminate is symmetric
                if obj.CentrePlySymmetry
                    % If laminate has centre ply symmetry then collect the
                    % thicknesses from the generated Ply objects and
                    % concatenate with the same flipped thickness excluding
                    % the centre ply
                    fullThicknessVector = [obj.PlyArray.Thickness,...
                        flip([obj.PlyArray(1:end-1).Thickness])];
                else
                    % If laminate does not have centre ply symmetry, then 
                    % collect the thicknesses from the generated Ply
                    % objects and concatenate with the same flipped
                    % thickness
                    fullThicknessVector = [obj.PlyArray.Thickness,...
                        flip([obj.PlyArray.Thickness])];
                end
            else
                % If laminate is not symmetric, then collect the
                % thicknesses from the generated Ply objects
                fullThicknessVector = [obj.PlyArray.Thickness];
            end
        end
        
        %% Total thickness get method
        function totalThickness = get.TotalThickness(obj)
            totalThickness = sum(obj.FullThicknessVector);
        end
        
        %% ContractedOrientationVector get method
        function ContractedOrientationVector = get.ContractedOrientationVector(obj)
            % Get the contracted angle vector only in case of a
            % symmetric laminate
            if obj.IsSymmetric
                % Collect the angles from the generated Ply objects
                ContractedOrientationVector = [obj.PlyArray.Theta];
            else
                ContractedOrientationVector = [];
            end
        end
        
        %% FullOrientationVector get method
        function FullOrientationVector =...
                get.FullOrientationVector(obj)
            if obj.IsSymmetric
                % If laminate is symmetric
                if obj.CentrePlySymmetry
                    % If laminate has centre ply symmetry then collect the
                    % angles from the generated Ply objects and
                    % concatenate with the same flipped angles excluding
                    % the centre ply
                    FullOrientationVector = [obj.PlyArray.Theta,...
                        flip([obj.PlyArray(1:end-1).Theta])];
                else
                    % If laminate does not have centre ply symmetry, then 
                    % collect the angles from the generated Ply
                    % objects and concatenate with the same flipped angles
                    FullOrientationVector = [obj.PlyArray.Theta,...
                        flip([obj.PlyArray.Theta])];
                end
            else
                % If laminate is not symmetric, then collect the angles
                % from the generated Ply objects
                FullOrientationVector = [obj.PlyArray.Theta];
            end
        end
        
        %% A matrix get method
        function a = get.A(obj)
            % A_{ij} = sum(Q_{ij}*(z_k-z_{k-1})
            [q11Vector,q12Vector,q16Vector,q22Vector,q26Vector,q66Vector] =...
                obj.fullQVectors;
            a11 = sum(q11Vector.*obj.FullThicknessVector);
            a12 = sum(q12Vector.*obj.FullThicknessVector);
            a16 = sum(q16Vector.*obj.FullThicknessVector);
            a22 = sum(q22Vector.*obj.FullThicknessVector);
            a26 = sum(q26Vector.*obj.FullThicknessVector);
            a66 = sum(q66Vector.*obj.FullThicknessVector);
            a = [a11,a12,a16;...
                a12,a22,a26;...
                a16,a26,a66];
        end
        
        %% B matrix get method
        function b = get.B(obj)
            % B_{ij} = sum(Q_{ij}/2*({z_k}^2-{z_{k-1}}^2)
            [q11Vector,q12Vector,q16Vector,q22Vector,q26Vector,q66Vector] =...
                obj.fullQVectors;
            zVector = obj.fullZVector;
            b11 = sum(q11Vector/2.*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2));
            b12 = sum(q12Vector/2.*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2));
            b16 = sum(q16Vector/2.*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2));
            b22 = sum(q22Vector/2.*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2));
            b26 = sum(q26Vector/2.*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2));
            b66 = sum(q66Vector/2.*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2));
            b = [b11,b12,b16;...
                b12,b22,b26;...
                b16,b26,b66];
        end
        
        %% D matrix get method
        function d = get.D(obj)
            % D_{ij} = sum(Q_{ij}/3*({z_k}^3-{z_{k-1}}^3)
            [q11Vector,q12Vector,q16Vector,q22Vector,q26Vector,q66Vector] =...
                obj.fullQVectors;
            zVector = obj.fullZVector;
            d11 = sum(q11Vector/3.*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3));
            d12 = sum(q12Vector/3.*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3));
            d16 = sum(q16Vector/3.*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3));
            d22 = sum(q22Vector/3.*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3));
            d26 = sum(q26Vector/3.*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3));
            d66 = sum(q66Vector/3.*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3));
            d = [d11,d12,d16;...
                d12,d22,d26;...
                d16,d26,d66];
        end
        
        %% Normalized A matrix get method
        function ahat = get.Ahat(obj)
            % Ahat = A/h
            ahat = obj.A/obj.TotalThickness;
        end
        
        %% Normalized B matrix get method
        function bhat = get.Bhat(obj)
            % Bhat = B*4/h^2
            bhat = obj.B*4/(obj.TotalThickness)^2;
        end
        
        %% Normalized D matrix get method
        function dhat = get.Dhat(obj)
            % Dhat = D*12/h^3
            dhat = obj.D*12/(obj.TotalThickness)^3;
        end
        
        %% A matrix lamination parameters get method
        function va = get.Va(obj)
            % (V1A,V2A,V3A,V4A) = 1/h*int_{-h/2}^{h/2}(cos2?,sin2?,cos4?,sin4?)dz
            v1a = 1/obj.TotalThickness*...
                sum(cosd(2*obj.FullOrientationVector).*obj.FullThicknessVector);
            v2a = 1/obj.TotalThickness*...
                sum(sind(2*obj.FullOrientationVector).*obj.FullThicknessVector);
            v3a = 1/obj.TotalThickness*...
                sum(cosd(4*obj.FullOrientationVector).*obj.FullThicknessVector);
            v4a = 1/obj.TotalThickness*...
                sum(sind(4*obj.FullOrientationVector).*obj.FullThicknessVector);
            va = [v1a,v2a,v3a,v4a];
        end
        
        %% B matrix lamination parameters get method
        function vb = get.Vb(obj)
            % (V1B,V2B,V3B,V4B) = 4/h^2*int_{-h/2}^{h/2}z(cos2?,sin2?,cos4?,sin4?)dz
            zVector = obj.fullZVector;
            v1b = 4/(obj.TotalThickness)^2*...
                sum(cosd(2*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2)/2);
            v2b = 4/(obj.TotalThickness)^2*...
                sum(sind(2*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2)/2);
            v3b = 4/(obj.TotalThickness)^2*...
                sum(cosd(4*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2)/2);
            v4b = 4/(obj.TotalThickness)^2*...
                sum(sind(4*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^2-...
                (zVector-obj.FullThicknessVector/2).^2)/2);
            vb = [v1b,v2b,v3b,v4b];
        end
        
        %% D matrix lamination parameters get method
        function vd = get.Vd(obj)
            % (V1D,V2D,V3D,V4D) = 12/h^3*int_{-h/2}^{h/2}z^2(cos2?,sin2?,cos4?,sin4?)dz
            zVector = obj.fullZVector;
            v1d = 12/(obj.TotalThickness)^3*...
                sum(cosd(2*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3)/3);
            v2d = 12/(obj.TotalThickness)^3*...
                sum(sind(2*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3)/3);
            v3d = 12/(obj.TotalThickness)^3*...
                sum(cosd(4*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3)/3);
            v4d = 12/(obj.TotalThickness)^3*...
                sum(sind(4*obj.FullOrientationVector).*(...
                (zVector+obj.FullThicknessVector/2).^3-...
                (zVector-obj.FullThicknessVector/2).^3)/3);
            vd = [v1d,v2d,v3d,v4d];
        end
        
        %% Get full q vectors
        function [q11Vector,q12Vector,q16Vector,q22Vector,q26Vector,...
                q66Vector] = fullQVectors(obj)
            %fullQVectors Retrieve the stifness components Q_{ij} from all
            %the plies of the laminate.
            % [q11Vector,q12Vector,q16Vector,q22Vector,q26Vector,...
            % q66Vector] = fullQVectors(obj) returns the 6 vectors
            % containing the Q_{ij} values from all plies of the lamniate,
            % such that length(qijVector) = number of plies. The function
            % returns the full vector of Q_{ij} also for symmetric
            % laminates (so the entire laminate is always considered).
            
            if obj.IsSymmetric
                % If laminate is symmetric
                if obj.CentrePlySymmetry
                    % If laminate has centre ply symmetry, then obtain the
                    % full Q_{ij} vectors collecting the Q_{ij} terms from
                    % the Ply objects and concatenating them with the
                    % same flipped terms excluding the centre ply
                    q11Vector = [obj.PlyArray.Q11,...
                        flip([obj.PlyArray(1:end-1).Q11])];
                    q12Vector = [obj.PlyArray.Q12,...
                        flip([obj.PlyArray(1:end-1).Q12])];
                    q16Vector = [obj.PlyArray.Q16,...
                        flip([obj.PlyArray(1:end-1).Q16])];
                    q22Vector = [obj.PlyArray.Q22,...
                        flip([obj.PlyArray(1:end-1).Q22])];
                    q26Vector = [obj.PlyArray.Q26,...
                        flip([obj.PlyArray(1:end-1).Q26])];
                    q66Vector = [obj.PlyArray.Q66,...
                        flip([obj.PlyArray(1:end-1).Q66])];
                else
                    % If laminate does not have centre ply symmetry, then
                    % obtain the full Q_{ij} vectors collecting the Q_{ij} 
                    % terms from the Ply objects and concatenating them 
                    % with the same flipped terms
                    q11Vector = [obj.PlyArray.Q11,...
                        flip([obj.PlyArray.Q11])];
                    q12Vector = [obj.PlyArray.Q12,...
                        flip([obj.PlyArray.Q12])];
                    q16Vector = [obj.PlyArray.Q16,...
                        flip([obj.PlyArray.Q16])];
                    q22Vector = [obj.PlyArray.Q22,...
                        flip([obj.PlyArray.Q22])];
                    q26Vector = [obj.PlyArray.Q26,...
                        flip([obj.PlyArray.Q26])];
                    q66Vector = [obj.PlyArray.Q66,...
                        flip([obj.PlyArray.Q66])];
                end
            else
                % If laminate is not symmetric, collect the Q_{ij} terms
                % from the Ply objects
                q11Vector = [obj.PlyArray.Q11];
                q12Vector = [obj.PlyArray.Q12];
                q16Vector = [obj.PlyArray.Q16];
                q22Vector = [obj.PlyArray.Q22];
                q26Vector = [obj.PlyArray.Q26];
                q66Vector = [obj.PlyArray.Q66];
            end
        end
        
        %% Get full z vector
        function zVector = fullZVector(obj)
            %fullZVector gets the full vector of z positions of the plies
            %(ply mid-plane)
            %
            if obj.IsSymmetric
                % If laminate is symmetric
                if obj.CentrePlySymmetry
                    % If laminate has centre ply symmetry, obtain z vector
                    % collecting the z positions of the Ply objects and
                    % concatenating them with the same flipped vector
                    % excluding the mid ply
                    zVector = [obj.PlyArray.Z,...
                        -flip([obj.PlyArray(1:end-1).Z])];
                else
                    % If laminate does not have centre ply symmetry, obtain
                    % z vector collecting the z positions of the Ply
                    % objects and concatenating them with the same flipped
                    % vector
                    zVector = [obj.PlyArray.Z,...
                        -flip([obj.PlyArray.Z])];
                end
            else
                % If laminate is not symmetric, obtain z vector collecting 
                % the z positions of the Ply objects
                zVector = [obj.PlyArray.Z];
            end
        end
        
        %% Membrane Stiffness Visualization
        function fig = plotMembraneStiffness(obj)
            %membraneStiffnessVisualization Polar plot of the thickness
            %normalized membrane engineering modulus of elasticity E_m11 of
            %the laminate.
            %
            % Angle distribution
            theta = 0:.01:2*pi;
            % Function for the calculation of the transformation matrix T
            transformation = @(x) inv([cos(x)^2,sin(x)^2,2*cos(x)*sin(x);...
                sin(x)^2,cos(x)^2,-2*cos(x)*sin(x);...
                -cos(x)*sin(x),cos(x)*sin(x),cos(x)^2-sin(x)^2]);
            % Iterate through the angle distribution
            for t = length(theta):-1:1
                % Calculate the thickness normalized engineering modulus of
                % elasticity along the current angle
                AhatInverseTheta = transformation(theta(t))'/obj.Ahat*...
                    transformation(theta(t));
                Ehat11Theta(t) = 1/AhatInverseTheta(1,1);
            end
            % Plot
            fig = figure;
            % Further nondimensionalization of the engineering modulus of
            % elasticity with the value of the single ply
            polarplot(theta,Ehat11Theta/obj.PlyArray(1).El,'r',...
                'LineWidth',2)
            rlim([0, 1])
            rticks([0.5, 1])
        end
        
        %% Flexural Stiffness Visualization
        function fig = plotFlexuralStiffness(obj)
            %flexuralStiffnessVisualization Polar plot of the thickness
            %normalized flexural engineering modulus of elasticity E_f11 of
            %the laminate.
            %
            % Angle distribution
            theta = 0:.01:2*pi;
            % Function for the calculation of the transformation matrix T
            transformation = @(x) inv([cos(x)^2, sin(x)^2, 2*cos(x)*sin(x);...
                sin(x)^2, cos(x)^2, -2*cos(x)*sin(x);...
                -cos(x)*sin(x), cos(x)*sin(x), cos(x)^2 - sin(x)^2]);
            % Iterate through the angle distribution
            for t = length(theta):-1:1
                % Calculate the thickness normalized engineering modulus of
                % elasticity along the current angle
                DhatInverseTheta = transformation(theta(t))'/obj.Dhat*...
                    transformation(theta(t));
                Ehat11Theta(t) = 1/DhatInverseTheta(1,1);
            end
            % Plot
            fig = figure;
            % Further nondimensionalization of the engineering modulus of
            % elasticity with the value of the single ply
            polarplot(theta, Ehat11Theta/obj.PlyArray(1).El,'r',...
                'LineWidth',2)
            rlim([0, 1])
            rticks([0.5, 1])
        end
    end
end
