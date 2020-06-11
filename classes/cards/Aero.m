classdef Aero < matlab.mixin.Copyable
    properties
        Acsid = 0;  % Aerodynamic coordinate system identification
        Velocity    % Velocity for aerodynamic force data recovery and to calculate the BOV parameter
        Refc        % Reference length for reduced frequency
        Rhoref      % Reference density
        Symxz = 0;  % Symmetry key for the aero coordinate x-z plane
        Symxy = 0;  % The symmetry key for the aero coordinate x-y plane can be used to simulate ground effect
    end
    
    methods
        %% Constructor
        function obj = Aero(aeroStruct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(aeroStruct);
                obj(m,n) = Aero;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(aeroStruct,'acsid')
                            obj(i,j).Acsid = aeroStruct(i,j).acsid;
                        end
                        if isfield(aeroStruct,'velocity')
                            obj(i,j).Velocity = aeroStruct(i,j).velocity;
                        end
                        if isfield(aeroStruct,'refc')
                            obj(i,j).Refc = aeroStruct(i,j).refc;
                        end
                        if isfield(aeroStruct,'rhoref')
                            obj(i,j).Rhoref = aeroStruct(i,j).rhoref;
                        end
                        if isfield(aeroStruct,'symxz')
                            obj(i,j).Symxz = aeroStruct(i,j).symxz;
                        end
                        if isfield(aeroStruct,'symxy')
                            obj(i,j).Symxy = aeroStruct(i,j).symxy;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % AERO ACSID    VELOCITY    REFC RHOREF SYMXZ   SYMXY
            % AERO 3        1.3+4       100. 1.-5   1       -1
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    basicFormatSpec = '%-8s%-8d';
                    formatSpec = '';
                    if abs(obj(i,j).Velocity) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).Refc) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).Rhoref) >= 1e2
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    formatSpec = [basicFormatSpec,formatSpec,'%-8d%-8d\n'];
                    fprintf(fileID,formatSpec,'AERO',obj(i,j).Acsid,...
                        obj(i,j).Velocity,obj(i,j).Refc,obj(i,j).Rhoref,...
                        obj(i,j).Symxz,obj(i,j).Symxy);
                end
            end
        end
    end
end
