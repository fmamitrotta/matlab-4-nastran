classdef NastranForce < matlab.mixin.Copyable
    
    %% Properties
    properties
        ParentEigenvalue = NastranEigenvalue.empty;   % parent NastranEigenvalue object
        ParentGrid      % parent Grid object
        ParentSubcase   % parent NastranSubcaseResult object
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
        ForceMagnitude
    end
    
    methods
        %% Constructor
        function obj = NastranForce(forceInputStruct)
            %NastranDisplacementVector Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                % Initialize size of object
                [m,n] = size(forceInputStruct);
                obj(m,n) = NastranForce;
                % If input is a structure
                if isstruct(forceInputStruct)
                    % Iterate through the elements of the input structure
                    % and assign properties
                    for i = m:-1:1
                        for j = n:-1:1
                            if isfield(forceInputStruct,...
                                    'parentEigenvalue')
                                obj(i,j).ParentEigenvalue =...
                                    forceInputStruct(i,...
                                    j).parentEigenvalue;
                            end
                            if isfield(forceInputStruct,...
                                    'parentGrid')
                                obj(i,j).ParentGrid =...
                                    forceInputStruct(i,...
                                    j).parentGrid;
                            end
                            if isfield(forceInputStruct,...
                                    'parentSubcase')
                                obj(i,j).ParentSubcase =...
                                    forceInputStruct(i,...
                                    j).parentSubcase;
                            end
                            if isfield(forceInputStruct,'type')
                                obj(i,j).Type =...
                                    forceInputStruct(i,j).type;
                            end
                            if isfield(forceInputStruct,'time')
                                obj(i,j).Time =...
                                    forceInputStruct(i,j).time;
                            end
                            if isfield(forceInputStruct,'t1')
                                obj(i,j).T1 =...
                                    forceInputStruct(i,j).t1;
                            end
                            if isfield(forceInputStruct,'t2')
                                obj(i,j).T2 =...
                                    forceInputStruct(i,j).t2;
                            end
                            if isfield(forceInputStruct,'t3')
                                obj(i,j).T3 =...
                                    forceInputStruct(i,j).t3;
                            end
                            if isfield(forceInputStruct,'r1')
                                obj(i,j).R1 =...
                                    forceInputStruct(i,j).r1;
                            end
                            if isfield(forceInputStruct,'r2')
                                obj(i,j).R2 =...
                                    forceInputStruct(i,j).r2;
                            end
                            if isfield(forceInputStruct,'r3')
                                obj(i,j).R3 =...
                                    forceInputStruct(i,j).r3;
                            end
                        end
                    end
                elseif iscell(forceInputStruct)
                    % If input argument is a cell array, then expect a
                    % vector in each element of the array                    
                    % Iterate through the elements of the input structure
                    for i = m:-1:1
                        for j = n:-1:1
                            obj(i,j).T1 = forceInputStruct{i,j}(1);
                            obj(i,j).T2 = forceInputStruct{i,j}(2);
                            obj(i,j).T3 = forceInputStruct{i,j}(3);
                            obj(i,j).R1 = forceInputStruct{i,j}(4);
                            obj(i,j).R2 = forceInputStruct{i,j}(5);
                            obj(i,j).R3 = forceInputStruct{i,j}(6);
                        end
                    end
                else
                    % If input argument is not a cell array, then expect
                    % only one vector
                    obj.T1 = forceInputStruct(1);
                    obj.T2 = forceInputStruct(2);
                    obj.T3 = forceInputStruct(3);
                    obj.R1 = forceInputStruct(4);
                    obj.R2 = forceInputStruct(5);
                    obj.R3 = forceInputStruct(6);
                end
            end
        end
        
        %% TranslationMagnitude get method
        function translationMagnitude = get.ForceMagnitude(obj)
            % Return norm of displacement
            if ~isempty(obj.T1) && ~isempty(obj.T2) && ~isempty(obj.T3)
                translationMagnitude = vecnorm([obj.T1,obj.T2,obj.T3]')';
            end
        end
    end
end
