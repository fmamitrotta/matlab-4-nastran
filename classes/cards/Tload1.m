classdef Tload1 < handle
    properties
        Sid         % Set identification number
        Excited     % Identification number of a static load set or a DAREA or SPCD entry set
        Delay = ''; % Identification number of DELAY Bulk Data entry that defines time delay or Value of time delay that will be used for all degrees-of-freedom that are excited by this dynamic load entry
        Type = '';  % Defines the type of the dynamic excitation
        Tid         % Identification number of TABLEDi entry that gives F(t)
        Us0         % Factor for initial displacements of the enforced degrees-of-freedom
        Vs0         % Factor for initial velocities of the enforced degrees-of-freedom
    end
    
    methods
        %% Constructor
        function obj = Tload1(tload1Struct)
            if nargin ~= 0
                % Initialise object array
                [m,n] = size(tload1Struct);
                obj(m,n) = Tload1;
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(tload1Struct,'sid')
                            obj(i,j).Sid = tload1Struct(i,j).sid;
                        end
                        if isfield(tload1Struct,'excited')
                            obj(i,j).Excited = tload1Struct(i,j).excited;
                        end
                        if isfield(tload1Struct,'delay')
                            obj(i,j).Delay = tload1Struct(i,j).delay;
                        end
                        if isfield(tload1Struct,'type')
                            obj(i,j).Type = tload1Struct(i,j).type;
                        end
                        if isfield(tload1Struct,'tid')
                            obj(i,j).Tid = tload1Struct(i,j).tid;
                        end
                        if isfield(tload1Struct,'us0')
                            obj(i,j).Us0 = tload1Struct(i,j).us0;
                        end
                        if isfield(tload1Struct,'vs0')
                            obj(i,j).Vs0 = tload1Struct(i,j).vs0;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % TLOAD1 SID    EXCITEID    DELAYI/DELAYR   TYPE    TID/F US0 VS0
            % TLOAD1 5      7           15              LOAD    13
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    % Set format specification
                    basicFormatSpec = '%-8s%-8d%-8d';
                    if isempty(obj(i,j).Delay)
                        delayFormatSpec = '%-8s';
                    else
                        delayFormatSpec = '%-8d';
                    end
                    typeFormatSpec = '%-8s';
                    tidFormatSpec = '%-8d';
                    formatSpec = [basicFormatSpec,delayFormatSpec,...
                        typeFormatSpec,tidFormatSpec,'\n'];
                    % Write to file
                    fprintf(fileId,formatSpec,'TLOAD1',obj(i,j).Sid,...
                        obj(i,j).Excited,obj(i,j).Delay,obj(i,j).Type,...
                        obj(i,j).Tid);
                end
            end
        end
    end
end
