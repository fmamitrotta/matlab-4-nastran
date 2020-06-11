classdef NastranDisplacement < matlab.mixin.Copyable
    
    %% Properties
    properties
        ParentEigenvalue = NastranEigenvalue;   % parent NastranEigenvalue object
        ParentGrid  % parent Grid object
        ParentSubcase = NastranSubcaseResult;   % parent NastranSubcaseResult object
        Type    % type of displacement: G = grid, M = modal
        Time    % time instant
        T1      % x translation
        T2      % y translation
        T3      % z translation
        R1      % x rotation
        R2      % y rotation
        R3      % z rotation
    end
    
    %% Dependent properties
    properties (Dependent=true,SetAccess=private)
        TranslationMagnitude
        DisplacedX1
        DisplacedX2
        DisplacedX3
    end
    
    methods
        %% Constructor
        function obj = NastranDisplacement(displacementInputStruct)
            %NastranDisplacementVector Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                % Initialize size of object
                [m,n] = size(displacementInputStruct);
                obj(m,n) = NastranDisplacement;
                % If input is a structure
                if isstruct(displacementInputStruct)
                    % Iterate through the elements of the input structure
                    % and assign properties
                    for i = m:-1:1
                        for j = n:-1:1
                            if isfield(displacementInputStruct,...
                                    'parentEigenvalue')
                                obj(i,j).ParentEigenvalue =...
                                    displacementInputStruct(i,...
                                    j).parentEigenvalue;
                            end
                            if isfield(displacementInputStruct,...
                                    'parentGrid')
                                obj(i,j).ParentGrid =...
                                    displacementInputStruct(i,...
                                    j).parentGrid;
                            end
                            if isfield(displacementInputStruct,...
                                    'parentSubcase')
                                obj(i,j).ParentSubcase =...
                                    displacementInputStruct(i,...
                                    j).parentSubcase;
                            end
                            if isfield(displacementInputStruct,'type')
                                obj(i,j).Type =...
                                    displacementInputStruct(i,j).type;
                            end
                            if isfield(displacementInputStruct,'time')
                                obj(i,j).Time =...
                                    displacementInputStruct(i,j).time;
                            end
                            if isfield(displacementInputStruct,'t1')
                                obj(i,j).T1 =...
                                    displacementInputStruct(i,j).t1;
                            end
                            if isfield(displacementInputStruct,'t2')
                                obj(i,j).T2 =...
                                    displacementInputStruct(i,j).t2;
                            end
                            if isfield(displacementInputStruct,'t3')
                                obj(i,j).T3 =...
                                    displacementInputStruct(i,j).t3;
                            end
                            if isfield(displacementInputStruct,'r1')
                                obj(i,j).R1 =...
                                    displacementInputStruct(i,j).r1;
                            end
                            if isfield(displacementInputStruct,'r2')
                                obj(i,j).R2 =...
                                    displacementInputStruct(i,j).r2;
                            end
                            if isfield(displacementInputStruct,'r3')
                                obj(i,j).R3 =...
                                    displacementInputStruct(i,j).r3;
                            end
                        end
                    end
                elseif iscell(displacementInputStruct)
                    % If input argument is a cell array, then expect a
                    % vector in each element of the array                    
                    % Iterate through the elements of the input structure
                    for i = m:-1:1
                        for j = n:-1:1
                            obj(i,j).T1 = displacementInputStruct{i,j}(1);
                            obj(i,j).T2 = displacementInputStruct{i,j}(2);
                            obj(i,j).T3 = displacementInputStruct{i,j}(3);
                            obj(i,j).R1 = displacementInputStruct{i,j}(4);
                            obj(i,j).R2 = displacementInputStruct{i,j}(5);
                            obj(i,j).R3 = displacementInputStruct{i,j}(6);
                        end
                    end
                else
                    % If input argument is not a cell array, then expect
                    % only one vector
                    obj.T1 = displacementInputStruct(1);
                    obj.T2 = displacementInputStruct(2);
                    obj.T3 = displacementInputStruct(3);
                    obj.R1 = displacementInputStruct(4);
                    obj.R2 = displacementInputStruct(5);
                    obj.R3 = displacementInputStruct(6);
                end
            end
        end
        
        %% TranslationMagnitude get method
        function translationMagnitude = get.TranslationMagnitude(obj)
            % Return norm of displacement
            if ~isempty(obj.T1) && ~isempty(obj.T2) && ~isempty(obj.T3)
                translationMagnitude = vecnorm([obj.T1;obj.T2;obj.T3]);
            end
        end
        
        %% DisplacedX1 get method
        function displacedX1 = get.DisplacedX1(obj)
            % Return value of displaced x1 coordiante of parent Grid object
            if ~isempty(obj.T1)
                displacedX1 = [obj.ParentGrid.X1]+[obj.T1];
            end
        end
        
        %% DisplacedX2 get method
        function displacedX2 = get.DisplacedX2(obj)
            % Return value of displaced x1 coordiante of parent Grid object
            if ~isempty(obj.T2)
                displacedX2 = [obj.ParentGrid.X2]+[obj.T2];
            end
        end
        
        %% DisplacedX3 get method
        function displacedX3 = get.DisplacedX3(obj)
            % Return value of displaced x1 coordiante of parent Grid object
            if ~isempty(obj.T3)
                displacedX3 = [obj.ParentGrid.X3]+[obj.T3];
            end
        end
    end
end
