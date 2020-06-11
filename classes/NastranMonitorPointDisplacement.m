classdef NastranMonitorPointDisplacement < matlab.mixin.Copyable
    
    %% Properties
    properties
        MonitorPointName
        Component
        ParentSubcase   % parent NastranSubcaseResult object
        Label
        Cp
        X
        Y
        Z
        Cd
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
        function obj = NastranMonitorPointDisplacement(...
                displacementInputStruct)
            %NastranMonitorPointDisplacement Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                % Initialize size of object
                [m,n] = size(displacementInputStruct);
                obj(m,n) = NastranMonitorPointDisplacement;
                % Iterate through the elements of the input structure
                % and assign properties
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(displacementInputStruct,...
                                'monitorPointName')
                            obj(i,j).MonitorPointName =...
                                displacementInputStruct(i,j...
                                ).monitorPointName;
                        end
                        if isfield(displacementInputStruct,'component')
                            obj(i,j).Component =...
                                displacementInputStruct(i,j).component;
                        end
                        if isfield(displacementInputStruct,'label')
                            obj(i,j).Label =...
                                displacementInputStruct(i,j).label;
                        end
                        if isfield(...
                                displacementInputStruct,'cp')
                            obj(i,j).Cp =...
                                displacementInputStruct(i,j).cp;
                        end
                        if isfield(displacementInputStruct,'x')
                            obj(i,j).X =...
                                displacementInputStruct(i,j).x;
                        end
                        if isfield(displacementInputStruct,'y')
                            obj(i,j).Y =...
                                displacementInputStruct(i,j).y;
                        end
                        if isfield(displacementInputStruct,'z')
                            obj(i,j).Z =...
                                displacementInputStruct(i,j).z;
                        end
                        if isfield(displacementInputStruct,'cd')
                            obj(i,j).Cd =...
                                displacementInputStruct(i,j).cd;
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
            end
        end
        
        %% TranslationMagnitude get method
        function translationMagnitude = get.TranslationMagnitude(obj)
            % Return norm of displacement
            if ~isempty(obj.T1) && ~isempty(obj.T2) && ~isempty(obj.T3)
                translationMagnitude = vecnorm([obj.T1,obj.T2,obj.T3]')';
            end
        end
        
        %% DisplacedX1 get method
        function displacedX1 = get.DisplacedX1(obj)
            % Return value of displaced x1 coordiante of parent Grid object
            if ~isempty(obj.T1)
                displacedX1 = obj.X+[obj.T1];
            end
        end
        
        %% DisplacedX2 get method
        function displacedX2 = get.DisplacedX2(obj)
            % Return value of displaced x1 coordiante of parent Grid object
            if ~isempty(obj.T2)
                displacedX2 = obj.Y+[obj.T2];
            end
        end
        
        %% DisplacedX3 get method
        function displacedX3 = get.DisplacedX3(obj)
            % Return value of displaced x1 coordiante of parent Grid object
            if ~isempty(obj.T3)
                displacedX3 = obj.Z+[obj.T3];
            end
        end
    end
end
