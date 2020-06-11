classdef Pshell < matlab.mixin.Copyable
    % Class for the handling of the Nastran PSHELL entry.
    
    %% Properties
    properties
        Pid                         % Property identification number
        Mid1                        % Material identification number for the membrane
        T                           % Default membrane thickness for Ti on the connection entry
        Mid2                        % Material identification number for bending
        BendingMomentOfInertiaRatio % Bending moment of inertia ratio, 12I ? T^3. Ratio of the actual bending moment inertia of the shell, I, to the bending moment of inertia of a homogeneous shell, T^3 ? 12. The default value is for a homogeneous shell. (Real > 0.0; Default = 1.0)
        Mid3                        % Material identification number for transverse shear
    end
    
    methods
        %% Constructor
        function obj = Pshell(pshellStruct)
            %Pshell Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(pshellStruct);
                obj(m,n) = Pshell;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(pshellStruct,'pid')
                            obj.Pid(i,j) = pshellStruct(i,j).pid;
                        end
                        if isfield(pshellStruct,'mid1')
                            obj.Mid1(i,j) = pshellStruct(i,j).mid1;
                        end
                        if isfield(pshellStruct,'t')
                            obj.T(i,j) = pshellStruct(i,j).t;
                        end
                        if isfield(pshellStruct,'mid2')
                            obj.Mid2(i,j) = pshellStruct(i,j).mid2;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            %write2Bdf Write bulk data entry to the specified .bdf file.
            
            % PSHELL    PID MID1 T MID2 12I/T**3 MID3 TS/T NSM
            % Z1        Z2  MID4
            for i = 1:length(obj)
                baseFormatSpec = '%-8s%-8d%-8d';
                if abs(obj(i).T)>=1e2 || abs(obj(i).T)<1e3
                    tFormatSpec = '%-8.1e';
                else
                    tFormatSpec = '%-8.4f';
                end
                formatSpec = [baseFormatSpec,tFormatSpec,'%-8d\n'];
                fprintf(fileID,formatSpec,'PSHELL',obj(i).Pid,obj(i).Mid1,...
                    obj(i).T,obj(i).Mid2);
            end
        end
    end
end
