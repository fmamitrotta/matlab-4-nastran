classdef NastranStrainInElement < matlab.mixin.Copyable
    
    %% Properties
    properties
        ParentEigenvalue = NastranEigenvalue;
        ParentElement
        ParentSubcase = NastranSubcaseResult;
        Time
        % Stresses in element coordinate system
        NormalX
        NormalY
        ShearXy
        % Principal stresses (zero shear)
        Angle
        Major
        Minor
        MaxShear
        % Curvatures
        XCurvature
        YCurvature
        XyCurvature
        AngleCurvature
        MajorCurvature
        MinorCurvature
        MaxShearCurvature
    end
    
    methods
        %% Constructor
        function obj = NastranStrainInElement(strainStruct)
            %StrainInElement Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(strainStruct);
                obj(m,n) = NastranStrainInElement;
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        % Assign properties
                        if isfield(strainStruct,'parentElement')
                            obj(i,j).ParentElement =...
                                strainStruct(i,j).parentElement;
                        end
                        if isfield(strainStruct,'time')
                            obj(i,j).Time =...
                                strainStruct(i,j).time;
                        end
                        if isfield(strainStruct,'strainData')
                            % If strainData field is present expect
                            % properties stored in double array
                            obj(i,j).NormalX =...
                                strainStruct(i,j).strainData(1,3);
                            obj(i,j).NormalY =...
                                strainStruct(i,j).strainData(1,4);
                            obj(i,j).ShearXy =...
                                strainStruct(i,j).strainData(1,5);
                            obj(i,j).Angle =...
                                strainStruct(i,j).strainData(1,6);
                            obj(i,j).Major =...
                                strainStruct(i,j).strainData(1,7);
                            obj(i,j).Minor =...
                                strainStruct(i,j).strainData(1,8);
                            obj(i,j).MaxShear =...
                                strainStruct(i,j).strainData(1,9);
                            obj(i,j).XCurvature =...
                                strainStruct(i,j).strainData(2,3);
                            obj(i,j).YCurvature =...
                                strainStruct(i,j).strainData(2,4);
                            obj(i,j).XyCurvature =...
                                strainStruct(i,j).strainData(2,5);
                            obj(i,j).AngleCurvature =...
                                strainStruct(i,j).strainData(2,6);
                            obj(i,j).MajorCurvature =...
                                strainStruct(i,j).strainData(2,7);
                            obj(i,j).MinorCurvature =...
                                strainStruct(i,j).strainData(2,8);
                            obj(i,j).MaxShearCurvature =...
                                strainStruct(i,j).strainData(2,9);
                        else
                            % If strainData field is not present expect
                            % properties stored in the fields of the input
                            % struct
                            if isfield(strainStruct,'normalX')
                                obj(i,j).NormalX =...
                                    strainStruct(i,j).normalX;
                            end
                            if isfield(strainStruct,'normalY')
                                obj(i,j).NormalY =...
                                    strainStruct(i,j).normalY;
                            end
                            if isfield(strainStruct,'shearXy')
                                obj(i,j).ShearXy =...
                                    strainStruct(i,j).shearXy;
                            end
                            if isfield(strainStruct,'angle')
                                obj(i,j).Angle = strainStruct(i,j).angle;
                            end
                            if isfield(strainStruct,'major')
                                obj(i,j).Major = strainStruct(i,j).major;
                            end
                            if isfield(strainStruct,'minor')
                                obj(i,j).Minor = strainStruct(i,j).minor;
                            end
                            if isfield(strainStruct,'maxShear')
                                obj(i,j).MaxShear =...
                                    strainStruct(i,j).maxShear;
                            end
                            if isfield(strainStruct,'xCurvature')
                                obj(i,j).XCurvature =...
                                    strainStruct(i,j).xCurvature;
                            end
                            if isfield(strainStruct,'yCurvature')
                                obj(i,j).YCurvature =...
                                    strainStruct(i,j).yCurvature;
                            end
                            if isfield(strainStruct,'xyCurvature')
                                obj(i,j).XyCurvature =...
                                    strainStruct(i,j).xyCurvature;
                            end
                            if isfield(strainStruct,'angleCurvature')
                                obj(i,j).AngleCurvature =...
                                    strainStruct(i,j).angleCurvature;
                            end
                            if isfield(strainStruct,'majorCurvature')
                                obj(i,j).MajorCurvature =...
                                    strainStruct(i,j).majorCurvature;
                            end
                            if isfield(strainStruct,'minorCurvature')
                                obj(i,j).MinorCurvature =...
                                    strainStruct(i,j).minorCurvature;
                            end
                            if isfield(strainStruct,'maxShearCurvature')
                                obj(i,j).MaxShearCurvature =...
                                    strainStruct(i,j).maxShearCurvature;
                            end
                        end
                    end
                end
            end
        end
    end
end
