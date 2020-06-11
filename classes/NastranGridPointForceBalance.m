classdef NastranGridPointForceBalance < matlab.mixin.Copyable
    
    %% Properties
    properties
        PointId
        ElementId
        Source
        T1
        T2
        T3
        R1
        R2
        R3
    end
    
    methods
        %% Constructor
        function obj = NastranGridPointForceBalance(gpForceBalanceStruct)
            %NastranGridPointForceBalance Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(gpForceBalanceStruct);
                obj(m,n) = NastranGridPointForceBalance;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(gpForceBalanceStruct,'pointId')
                            obj(i,j).PointId =...
                                gpForceBalanceStruct(i,j).pointId;
                        end
                        if isfield(gpForceBalanceStruct,'elementId')
                            obj(i,j).ElementId =...
                                gpForceBalanceStruct(i,j).elementId;
                        end
                        if isfield(gpForceBalanceStruct,'source')
                            obj(i,j).Source =...
                                gpForceBalanceStruct(i,j).source;
                        end
                        if isfield(gpForceBalanceStruct,'t1')
                            obj(i,j).T1 =...
                                gpForceBalanceStruct(i,j).t1;
                        end
                        if isfield(gpForceBalanceStruct,'t2')
                            obj(i,j).T2 =...
                                gpForceBalanceStruct(i,j).t2;
                        end
                        if isfield(gpForceBalanceStruct,'t3')
                            obj(i,j).T3 =...
                                gpForceBalanceStruct(i,j).t3;
                        end
                        if isfield(gpForceBalanceStruct,'r1')
                            obj(i,j).R1 =...
                                gpForceBalanceStruct(i,j).r1;
                        end
                        if isfield(gpForceBalanceStruct,'r2')
                            obj(i,j).R2 =...
                                gpForceBalanceStruct(i,j).r2;
                        end
                        if isfield(gpForceBalanceStruct,'r3')
                            obj(i,j).R3 =...
                                gpForceBalanceStruct(i,j).r3;
                        end
                    end
                end
            end
        end
    end
end
