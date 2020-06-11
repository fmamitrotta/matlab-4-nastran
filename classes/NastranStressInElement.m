classdef NastranStressInElement < matlab.mixin.Copyable
    
    %% Properties
    properties
        ParentEigenvalue
        ParentElement
        ParentSubcase
        Time
        FiberDistance
        % Stresses in element coordinate system
        NormalX
        NormalY
        ShearXy
        % Principal stresses (zero shear)
        Angle
        Major
        Minor
        MaxShear
    end
    
    %% Dependent properties
    properties (Dependent=true,SetAccess=private)
        MeanNormalX
        MeanNormalY
        MeanShearXy
        MeanMajor
        MeanMinor
        MeanMaxShear
    end
    
    methods
        %% Constructor
        function obj = NastranStressInElement(stressStruct)
            %StressInElement Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(stressStruct);
                obj(m,n) = NastranStressInElement;
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        % Assign properties
                        if isfield(stressStruct,'parentElement')
                            obj(i,j).ParentElement =...
                                stressStruct(i,j).parentElement;
                        end
                        if isfield(stressStruct,'time')
                            obj(i,j).Time =...
                                stressStruct(i,j).time;
                        end
                        if isfield(stressStruct,'stressData')
                            % If stressData field is present expect
                            % properties stored in double array
                            obj(i,j).FiberDistance =...
                                stressStruct(i,j).stressData(:,2);
                            obj(i,j).NormalX =...
                                stressStruct(i,j).stressData(:,3);
                            obj(i,j).NormalY =...
                                stressStruct(i,j).stressData(:,4);
                            obj(i,j).ShearXy =...
                                stressStruct(i,j).stressData(:,5);
                            obj(i,j).Angle =...
                                stressStruct(i,j).stressData(:,6);
                            obj(i,j).Major =...
                                stressStruct(i,j).stressData(:,7);
                            obj(i,j).Minor =...
                                stressStruct(i,j).stressData(:,8);
                            obj(i,j).MaxShear =...
                                stressStruct(i,j).stressData(:,9);
                        else
                            % If stressData field is not present expect
                            % properties stored in the fields of the input
                            % struct
                            if isfield(stressStruct,'fiberDistance')
                                obj(i,j).FiberDistance =...
                                    stressStruct(i,j).fiberDistance;
                            end
                            if isfield(stressStruct,'normalX')
                                obj(i,j).NormalX =...
                                    stressStruct(i,j).normalX;
                            end
                            if isfield(stressStruct,'normalY')
                                obj(i,j).NormalY =...
                                    stressStruct(i,j).normalY;
                            end
                            if isfield(stressStruct,'shearXy')
                                obj(i,j).ShearXy =...
                                    stressStruct(i,j).shearXy;
                            end
                            if isfield(stressStruct,'angle')
                                obj(i,j).Angle = stressStruct(i,j).angle;
                            end
                            if isfield(stressStruct,'major')
                                obj(i,j).Major = stressStruct(i,j).major;
                            end
                            if isfield(stressStruct,'minor')
                                obj(i,j).Minor = stressStruct(i,j).minor;
                            end
                            if isfield(stressStruct,'maxShear')
                                obj(i,j).MaxShear =...
                                    stressStruct(i,j).maxShear;
                            end
                        end
                    end
                end
            end
        end
        
        %% MeanNormalX get method
        function meanNormalX = get.MeanNormalX(obj)
            if ~isempty(obj.NormalX)
                meanNormalX = mean(obj.NormalX);
            end
        end
        
        %% MeanNormalY get method
        function meanNormalY = get.MeanNormalY(obj)
            if ~isempty(obj.NormalY)
                meanNormalY = mean(obj.NormalY);
            end
        end
        
        %% MeanShearXy get method
        function meanShearXy = get.MeanShearXy(obj)
            if ~isempty(obj.ShearXy)
                meanShearXy = mean(obj.ShearXy);
            end
        end
        
        %% MeanMajor get method
        function meanMajor = get.MeanMajor(obj)
            if ~isempty(obj.Major)
                meanMajor = mean(obj.Major);
            end
        end
        
        %% MeanMinor get method
        function meanMinor = get.MeanMinor(obj)
            if ~isempty(obj.Minor)
                meanMinor = mean(obj.Minor);
            end
        end
        
        %% MeanMaxShear get method
        function meanMaxShear = get.MeanMaxShear(obj)
            if ~isempty(obj.MaxShear)
                meanMaxShear = mean(obj.MaxShear);
            end
        end
    end
end
