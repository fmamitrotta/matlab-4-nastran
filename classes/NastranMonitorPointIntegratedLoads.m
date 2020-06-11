classdef NastranMonitorPointIntegratedLoads < matlab.mixin.Copyable
    
    %% Properties
    properties
        MonitorPointName
        Component
        ParentSubcase
        Label
        Cp
        X
        Y
        Z
        Cd
        % Following properties are vectors with 6 elements representing cx,
        % cy, cz, cmx, cmy and cmz
        RigidAir
        ElasticRestrained
        RigidApplied
        RestrainedApplied
        % Following variables are for dynamic analysis
        TimeStep
        Inertial
        External
        FlexibleIncrement
        Gust
        TotalAero
        Total
    end
    
    methods
        %% Constructor
        function obj = NastranMonitorPointIntegratedLoads(...
                monitorPointLoadsStruct)
            %NastranStructuralMonitorPointIntegratedLoad Construct an
            %instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(monitorPointLoadsStruct);
                obj(m,n) = NastranMonitorPointIntegratedLoads;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(monitorPointLoadsStruct,...
                                'monitorPointName')
                            obj(i,j).MonitorPointName =...
                                monitorPointLoadsStruct(i,j...
                                ).monitorPointName;
                        end
                        if isfield(monitorPointLoadsStruct,'component')
                            obj(i,j).Component =...
                                monitorPointLoadsStruct(i,j).component;
                        end
                        if isfield(monitorPointLoadsStruct,'label')
                            obj(i,j).Label =...
                                monitorPointLoadsStruct(i,j).label;
                        end
                        if isfield(...
                                monitorPointLoadsStruct,'cp')
                            obj(i,j).Cp =...
                                monitorPointLoadsStruct(i,j).cp;
                        end
                        if isfield(monitorPointLoadsStruct,'x')
                            obj(i,j).X =...
                                monitorPointLoadsStruct(i,j).x;
                        end
                        if isfield(monitorPointLoadsStruct,'y')
                            obj(i,j).Y =...
                                monitorPointLoadsStruct(i,j).y;
                        end
                        if isfield(monitorPointLoadsStruct,'z')
                            obj(i,j).Z =...
                                monitorPointLoadsStruct(i,j).z;
                        end
                        if isfield(monitorPointLoadsStruct,'cd')
                            obj(i,j).Cd =...
                                monitorPointLoadsStruct(i,j).cd;
                        end
                        if isfield(monitorPointLoadsStruct,'rigidAir')
                            obj(i,j).RigidAir =...
                                monitorPointLoadsStruct(i,j).rigidAir;
                        end
                        if isfield(monitorPointLoadsStruct,...
                                'elasticRestrained')
                            obj(i,j).ElasticRestrained =...
                                monitorPointLoadsStruct(i,j...
                                ).elasticRestrained;
                        end
                        if isfield(monitorPointLoadsStruct,...
                                'rigidApplied')
                            obj(i,j).RigidApplied =...
                                monitorPointLoadsStruct(i,j...
                                ).rigidApplied;
                        end
                        if isfield(monitorPointLoadsStruct,...
                                'restrainedApplied')
                            obj(i,j).RestrainedApplied =...
                                monitorPointLoadsStruct(i,j...
                                ).restrainedApplied;
                        end
                        if isfield(monitorPointLoadsStruct,'timeStep')
                            obj(i,j).TimeStep =...
                                monitorPointLoadsStruct(i,j).timeStep;
                        end
                        if isfield(monitorPointLoadsStruct,'inertial')
                            obj(i,j).Inertial =...
                                monitorPointLoadsStruct(i,j).inertial;
                        end
                        if isfield(monitorPointLoadsStruct,...
                                'flexibleIncrement')
                            obj(i,j).FlexibleIncrement =...
                                monitorPointLoadsStruct(i,j...
                                ).flexibleIncrement;
                        end
                        if isfield(monitorPointLoadsStruct,'gust')
                            obj(i,j).Gust =...
                                monitorPointLoadsStruct(i,j).gust;
                        end
                        if isfield(monitorPointLoadsStruct,'totalAero')
                            obj(i,j).TotalAero =...
                                monitorPointLoadsStruct(i,j).totalAero;
                        end
                        if isfield(monitorPointLoadsStruct,'total')
                            obj(i,j).Total =...
                                monitorPointLoadsStruct(i,j).total;
                        end
                    end
                end
            end
        end
    end
end
