classdef Caero1 < matlab.mixin.Copyable
    properties
        Eid         % Element identification number
        Pid         % Property identification number of a PAERO1 entry; used to specify associated bodies
        Cp = 0;     % Coordinate system for locating points 1 and 4
        Nspan       % Number of spanwise boxes; if a positive value is given NSPAN, equal divisions are assumed; if zero or blank, a list of division points is given at LSPAN, field 7
        Nchord      % Number of chordwise boxes; if a positive value is given NCHORD, equal divisions are assumed; if zero or blank, a list of division points is given at LCHORD, field 8
        Lspan       % ID of an AEFACT entry containing a list of division points for spanwise boxes. Used only if NSPAN, field 5 is zero or blank
        Lchord      % ID of an AEFACT data entry containing a list of division points for chordwise boxes. Used only if NCHORD, field 6 is zero or blank
        Igid = 1;   % Interference group identification; aerodynamic elements with different IGIDs are uncoupled
        X1          % Location of points 1 and 4, in coordinate system CP
        Y1
        Z1
        X12         % Edge chord lengths in aerodynamic coordinate system
        X4
        Y4
        Z4
        X43
    end
    methods
        %% Constructor from struct input
        function obj = Caero1(caero1Struct)
            % Constructor
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(caero1Struct);
                obj(m,n) = Caero1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(caero1Struct,'eid')
                            obj(i,j).Eid = caero1Struct(i,j).eid;
                        end
                        if isfield(caero1Struct,'pid')
                            obj(i,j).Pid = caero1Struct(i,j).pid;
                        end
                        if isfield(caero1Struct,'cp')
                            obj(i,j).Cp = caero1Struct(i,j).cp;
                        end
                        if isfield(caero1Struct,'nspan')
                            obj(i,j).Nspan = caero1Struct(i,j).nspan;
                        end
                        if isfield(caero1Struct,'nchord')
                            obj(i,j).Nchord = caero1Struct(i,j).nchord;
                        end
                        if isfield(caero1Struct,'lspan')
                            obj(i,j).Lspan = caero1Struct(i,j).lspan;
                        end
                        if isfield(caero1Struct,'lchord')
                            obj(i,j).Lchord = caero1Struct(i,j).lchord;
                        end
                        if isfield(caero1Struct,'igid')
                            obj(i,j).Igid = caero1Struct(i,j).igid;
                        end
                        if isfield(caero1Struct,'x1')
                            obj(i,j).X1 = caero1Struct(i,j).x1;
                        end
                        if isfield(caero1Struct,'y1')
                            obj(i,j).Y1 = caero1Struct(i,j).y1;
                        end
                        if isfield(caero1Struct,'z1')
                            obj(i,j).Z1 = caero1Struct(i,j).z1;
                        end
                        if isfield(caero1Struct,'x12')
                            obj(i,j).X12 = caero1Struct(i,j).x12;
                        end
                        if isfield(caero1Struct,'x4')
                            obj(i,j).X4 = caero1Struct(i,j).x4;
                        end
                        if isfield(caero1Struct,'y4')
                            obj(i,j).Y4 = caero1Struct(i,j).y4;
                        end
                        if isfield(caero1Struct,'z4')
                            obj(i,j).Z4 = caero1Struct(i,j).z4;
                        end
                        if isfield(caero1Struct,'x43')
                            obj(i,j).X43 = caero1Struct(i,j).x43;
                        end
                    end
                end
            end
        end
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            % CAERO1    EID     PID     CP  NSPAN   NCHORD  LSPAN   LCHORD  IGID
            %           X1      Y1      Z1  X12     X4      Y4      Z4      X43
            % CAERO1    1000    1           3                       2       1
            %           0.0     0.0     0.0 1.0     0.2     1.0     0.0     0.8
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    initialFormatSpec = '%-8s%-8d%-8d%-8d';
                    if ~isempty(obj(i,j).Nspan)
                        nspanFormatSpec = '%-8d';
                    else
                        nspanFormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).Nchord)
                        nchordFormatSpec = '%-8d';
                    else
                        nchordFormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).Lspan)
                        lspanFormatSpec = '%-8d';
                    else
                        lspanFormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).Lchord)
                        lchordFormatSpec = '%-8d';
                    else
                        lchordFormatSpec = '%-8s';
                    end
                    if ~isempty(obj(i,j).Igid)
                        igidFormatSpec = '%-8d';
                    else
                        igidFormatSpec = '%-8s';
                    end
                    if abs(obj(i,j).X1)>=1e2 || abs(obj(i,j).X1)<1e-3
                        x1FormatSpec = '%-8.1e';
                    else
                        x1FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Y1)>=1e2 || abs(obj(i,j).Y1)<1e-3
                        y1FormatSpec = '%-8.1e';
                    else
                        y1FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Z1)>=1e2 || abs(obj(i,j).Z1)<1e-3
                        z1FormatSpec = '%-8.1e';
                    else
                        z1FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).X12)>=1e2 || abs(obj(i,j).X12)<1e-3
                        x12FormatSpec = '%-8.1e';
                    else
                        x12FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).X4)>=1e2 || abs(obj(i,j).X4)<1e-3
                        x4FormatSpec = '%-8.1e';
                    else
                        x4FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Y4)>=1e2 || abs(obj(i,j).Y4)<1e-3
                        y4FormatSpec = '%-8.1e';
                    else
                        y4FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).Z4)>=1e2 || abs(obj(i,j).Z4)<1e-3
                        z4FormatSpec = '%-8.1e';
                    else
                        z4FormatSpec = '%-8.4f';
                    end
                    if abs(obj(i,j).X43)>=1e2 || abs(obj(i,j).X43)<1e-3
                        x43FormatSpec = '%-8.1e';
                    else
                        x43FormatSpec = '%-8.4f';
                    end
                    formatSpec = [initialFormatSpec,nspanFormatSpec,...
                        nchordFormatSpec,lspanFormatSpec,...
                        lchordFormatSpec,igidFormatSpec,'\n','%-8s',...
                        x1FormatSpec,y1FormatSpec,z1FormatSpec,...
                        x12FormatSpec,x4FormatSpec,y4FormatSpec,...
                        z4FormatSpec,x43FormatSpec,'\n'];
                    fprintf(fileID,formatSpec,'CAERO1',obj(i,j).Eid,...
                        obj(i,j).Pid,obj(i,j).Cp,obj(i,j).Nspan,...
                        obj(i,j).Nchord,obj(i,j).Lspan,obj(i,j).Lchord,...
                        obj(i,j).Igid,'',obj(i,j).X1,obj(i,j).Y1,...
                        obj(i,j).Z1,obj(i,j).X12,obj(i,j).X4,...
                        obj(i,j).Y4,obj(i,j).Z4,obj(i,j).X43);
                end
            end
        end
    end
end