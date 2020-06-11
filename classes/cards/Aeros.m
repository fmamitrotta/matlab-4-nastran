classdef Aeros < matlab.mixin.Copyable
    properties
        Acsid = 0;  % Aerodynamic coordinate system identification
        Rcsid = 0;  % Reference coordinate system identification for rigid body motions
        Refc        % Reference chord length
        Refb        % Reference span
        Refs        % Reference wing area
        Symxz = 0;  % Symmetry key for the aero coordinate x-z plane
        Symxy = 0;  % The symmetry key for the aero coordinate x-y plane can be used to simulate ground effects
    end
    methods
        %% Constructor from struct input
        function obj = Aeros(aerosStruct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(aerosStruct);
                obj(m,n) = Aeros;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(aerosStruct,'acsid')
                            obj(i,j).Acsid = aerosStruct(i,j).acsid;
                        end
                        if isfield(aerosStruct,'rcsid')
                            obj(i,j).Rcsid = aerosStruct(i,j).rcsid;
                        end
                        if isfield(aerosStruct,'refc')
                            obj(i,j).Refc = aerosStruct(i,j).refc;
                        end
                        if isfield(aerosStruct,'refb')
                            obj(i,j).Refb = aerosStruct(i,j).refb;
                        end
                        if isfield(aerosStruct,'refs')
                            obj(i,j).Refs = aerosStruct(i,j).refs;
                        end
                        if isfield(aerosStruct,'symxz')
                            obj(i,j).Symxz = aerosStruct(i,j).symxz;
                        end
                        if isfield(aerosStruct,'symxy')
                            obj(i,j).Symxy = aerosStruct(i,j).symxy;
                        end
                    end
                end
            end
        end
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % AEROS ACSID   RCSID   REFC    REFB REFS   SYMXZ SYMXY
            % AEROS 10      20      10.     100. 1000.  1
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    basicFormatSpec = '%-8s%-8d%-8d';
                    formatSpec = '';
                    if abs(obj(i,j).Refc)>=1e2 || abs(obj(i,j).Refc)<1e-3
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).Refb)>= 1e2 || abs(obj(i,j).Refb)<1e-3
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    if abs(obj(i,j).Refs)>=1e2 || abs(obj(i,j).Refs)<1e-3
                        formatSpec = [formatSpec,'%-8.1e'];
                    else
                        formatSpec = [formatSpec,'%-8.4f'];
                    end
                    formatSpec = [basicFormatSpec,formatSpec,'%-8d%-8d\n'];
                    fprintf(fileID,formatSpec,'AEROS',obj(i,j).Acsid,...
                        obj(i,j).Rcsid,obj(i,j).Refc,obj(i,j).Refb,...
                        obj(i,j).Refs,obj(i,j).Symxz,obj(i,j).Symxy);
                end
            end
        end
    end
end