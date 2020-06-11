classdef Nlparm < matlab.mixin.Copyable
    %Nlparm Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Id      % Identification number
        Ninc    % Number of increments
        Dt      % Incremental time interval for creep analysis. See Remark 3. (Real > 0.0; Default = 0.0 for no creep.)
        Kmethod % Method for controlling stiffness updates. See Remark 4. (Character = “AUTO”, “ITER”, “SEMI”, “FNT”, or “PFNT”; Default = “AUTO” for SOL 106, “AUTO” for SOL 400 with non-contact analysis, and “FNT” for SOL 400 with contact analysis.)
        Kstep   % Number of iterations before the stiffness update for ITER method. See Remarks 5. For the FNT and PFNT usage of KSTEP, please see Remark 19. (Integer > -1; Default = 5 for SOL 106 and 10 for SOL 400)
        Maxiter % Limit on number of iterations for each load increment. See Remark 6. (Integer 0; Default = 25)
        Conv    % Flags to select convergence criteria. See Remarks 7., 21., and 22. (Character = “U”, “P”, “W”, “V”, “N”, “A” or any combination; Default = “PW”. (See Remark 4 for additional default comment.)
        Intout  % Intermediate output flag. See Remark 8. (Character = “YES”, “NO”, “ALL” or Integer > 0 for SOL 400 only; Default = NO)
        Epsu    % Error tolerance for displacement (U) criterion. See Remarks 4., 16., 17. and 20. (Real > 0.0; Default = 1.0E-2)
        Epsp    % Error tolerance for load (P) criterion. See Remarks 4., 16. and 17. (Real > 0.0; Default = 1.0E-2)
        Epsw    % Error tolerance for work (W) criterion. See Remarks 4., 16., 17. and 20. (Real > 0.0; Default = 1.0E-2)
        Maxdiv  % Limit on probable divergence conditions per iteration before the solution is assumed to diverge. See Remark 9. (Integer 0; Default = 3)
        Maxqn   % Maximum number of quasi-Newton correction vectors to be saved on the database. See Remark 10. (Integer > 0; Default = MAXITER for all methods except PFNT. For PFNT, Default = 0)
        Maxls   % Maximum number of line searches allowed for each iteration. See Remark 11. (Integer > 0; Default = 4 for all methods except PFNT. For PFNT, Default = 0)
        Fstress % Fraction of effective stress used to limit the subincrement size in the material routines. See Remark 12. (0.0 < Real < 1.0; Default = 0.2)
        Lstol   % Line search tolerance. See Remark 12. (0.01 < Real < 0.9; Default = 0.5)
        Maxbis  % Maximum number of bisections allowed for each load increment. See Remark 13. (-10 <MAXBIS < 10; Default = 5 except for MAXITER < 0; Default = 0 if MAXITER < 0)
        Maxr    % Maximum ratio for the adjusted arc-length increment relative to the initial value. See Remark 14. (1.0 < MAXR < 40.0; Default = 20.0)
        Rtolb   % Maximum value of incremental rotation (in degrees) allowed per iteration to activate bisection. See Remark 15. (Real > 2.0; Default = 20.0)
        Miniter % Minimum number of iterations for each increment, SOL 101 with contact and SOL 400 only. (Integer > 0; Default = 1; In contact analysis, Default = 2) When high accuracy is required, it is also recommended to set MINITER = 2.
    end
    
    methods
        %% Constructor
        function obj = Nlparm(nlparmStruct)
            %Eigrl Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(nlparmStruct);
                obj(m,n) = Nlparm;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(nlparmStruct,'id')
                            obj.Id = nlparmStruct(i,j).id;
                        end
                        if isfield(nlparmStruct,'ninc')
                            obj.Ninc = nlparmStruct(i,j).ninc;
                        end
                        if isfield(nlparmStruct,'dt')
                            obj.Dt = nlparmStruct(i,j).dt;
                        end
                        if isfield(nlparmStruct,'kmethod')
                            obj.Kmethod = nlparmStruct(i,j).kmethod;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % NLPARM    ID      NINC    DT      KMETHOD KSTEP MAXITER   CONV    INTOUT
            %           EPSU    EPSP    EPSW    MAXDIV  MAXQN MAXLS     FSTRESS LSTOL
            %           MAXBIS  MAXR    RTOLB   MINITER
            % NLPARM    15      5               ITER
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    baseFormatSpec = '%-8s%-8d%-8d';
                    if ~isempty(obj(i,j).Dt)
                        if obj(i,j).F >= 1e2
                            dtFormatSpec = '%-8.1e';
                        else
                            dtFormatSpec = '%-8.4f';
                        end
                    else
                        dtFormatSpec = '%-8s';
                    end
                    kmethodFormatSpec = '%-8s';
                    formatSpec = [baseFormatSpec,dtFormatSpec,...
                        kmethodFormatSpec,'\n'];
                    fprintf(fileId,formatSpec,'NLPARM',obj(i,j).Id,...
                        obj(i,j).Ninc,obj(i,j).Dt,obj(i,j).Kmethod);
                end
            end
        end
    end
end
