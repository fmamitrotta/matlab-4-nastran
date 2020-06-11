classdef NastranBulkData < matlab.mixin.Copyable
    %NastranBulkData Class for the management of the bulk data section of a
    %Nastran input file.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        PartArray                       % Array of children NastranPart objects
        GridArray = Grid.empty;         % Array of Grid objects
        AecompArray = Aecomp.empty;     % Array of Aecomp objects
        AeroArray = Aero.empty;         % Array of Aero objects
        AerosArray = Aeros.empty;       % Array of Aeros objects
        AestatArray = Aestat.empty;     % Array of Aestat objects
        Caero1Array = Caero1.empty;     % Array of Caero1 objects
        Conm2Array = Conm2.empty;       % Array of Conm2 objects
        Cord2rArray = Cord2r.empty;     % Array of Cordr2 objects
        DareaArray = Darea.empty;       % Array of Darea objects
        EigrlArray = Eigrl.empty;       % Array of Eigrl objects
        ForceArray = Force.empty;       % Array of Force objects
        Freq1Array = Freq1.empty;       % Array of Freq1 objects
        GustArray = Gust.empty;         % Array of Gust objects
        LoadArray = Load.empty;         % Array of Load objects
        Mkaero1Array = Mkaero1.empty;   % Array of Mkaero1 objects
        Mondsp1Array = Mondsp1.empty;   % Array of Mondsp1 objects
        NlparmArray = Nlparm.empty;     % Array of Nlparm objects
        Paero1Array = Paero1.empty;     % Array of Paero1 objects
        ParamArray = Param(struct(...
            'n','POST','v1',0));        % Array of Param objects
        Rbe2Array = Rbe2.empty;         % Array of Rbe2 objects
        Rbe3Array = Rbe3.empty;         % Array of Rbe3 objects
        Set1Array = Set1.empty;         % Array of Set1 objects
        Spc1Array = Spc1.empty;         % Array of Spc1 objects
        SpcdArray = Spcd.empty;         % Array of Spcd objects
        Spline1Array = Spline1.empty;   % Array of Spline1 objects
        Tabdmp1Array = Tabdmp1.empty;   % Array of Tabdmp1 objects
        Tabled1Array = Tabled1.empty;   % Array of Tabled1 objects
        Tload1Array = Tload1.empty;     % Array of Tload1 objects
        TrimArray = Trim.empty;         % Array of Trim objects
        TstepArray = Tstep.empty;       % Array of Tstep objects
        LastGridId
        LastElementId
        LastPropertyId
        LastMaterialId
        LastSetId
        LastCoordinateId
        LastTableId
    end
    
    methods
        %% Constructor
        function obj = NastranBulkData(nastranBulkDataStruct)
            %NastranBulkData Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(nastranBulkDataStruct);
                obj(m,n) = NastranBulkData;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(nastranBulkDataStruct,'partArray')
                            obj(i,j).PartArray =...
                                nastranBulkDataStruct(i,j).partArray;
                        end
                        if isfield(nastranBulkDataStruct,'gridArray')
                            obj(i,j).GridArray =...
                                nastranBulkDataStruct(i,j).gridArray;
                        end
                        if isfield(nastranBulkDataStruct,'conm2Array')
                            obj(i,j).Conm2Array =...
                                nastranBulkDataStruct(i,j).conm2Array;
                        end
                        if isfield(nastranBulkDataStruct,'forceArray')
                            obj(i,j).ForceArray =...
                                nastranBulkDataStruct(i,j).forceArray;
                        end
                        if isfield(nastranBulkDataStruct,'loadArray')
                            obj(i,j).LoadArray =...
                                nastranBulkDataStruct(i,j).loadArray;
                        end
                        if isfield(nastranBulkDataStruct,'rbe2Array')
                            obj(i,j).Rbe2Array =...
                                nastranBulkDataStruct(i,j).rbe2Array;
                        end
                        if isfield(nastranBulkDataStruct,'spc1Array')
                            obj(i,j).Spc1Array =...
                                nastranBulkDataStruct(i,j).spc1Array;
                        end
                        if isfield(nastranBulkDataStruct,'lastGridId')
                            obj(i,j).LastGridId =...
                                nastranBulkDataStruct(i,j).lastGridId;
                        end
                        if isfield(nastranBulkDataStruct,'lastElementId')
                            obj(i,j).LastElementId =...
                                nastranBulkDataStruct(i,j).lastElementId;
                        end
                        if isfield(nastranBulkDataStruct,'lastPropertyId')
                            obj(i,j).LastPropertyId =...
                                nastranBulkDataStruct(i,j).lastPropertyId;
                        end
                        if isfield(nastranBulkDataStruct,'lastMaterialId')
                            obj(i,j).LastMaterialId =...
                                nastranBulkDataStruct(i,j).lastMaterialId;
                        end
                        if isfield(nastranBulkDataStruct,'lastSetId')
                            obj(i,j).LastSetId =...
                                nastranBulkDataStruct(i,j).lastSetId;
                        end
                        if isfield(nastranBulkDataStruct,'lastCoordinateId')
                            obj(i,j).LastCoordinateId =...
                                nastranBulkDataStruct(i,j).lastCoordinateId;
                        end
                        if isfield(nastranBulkDataStruct,'lastTableId')
                            obj(i,j).LastTableId =...
                                nastranBulkDataStruct(i,j).lastTableId;
                        end
                    end
                end
            end
        end
        
        %% Part Array set method
        function set.PartArray(obj,partArray)
            % When NastranPart are assigned to the bulk data as children
            % part, update their parent region
            obj.PartArray = partArray;
            for i = length(obj.PartArray):-1:1
                obj.PartArray(i).ParentBulkData = obj;
            end
        end
        
        %% Get all cquad4 elements
        function cquad4ElementsVector = getAllCquad4Elements(obj)
            cquad4ElementsVector = obj.PartArray.getAllCquad4Elements;
        end
        
        %% Get all ctria3 elements
        function ctria3ElementsVector = getAllCtria3Elements(obj)
            ctria3ElementsVector = obj.PartArray.getAllCtria3Elements;
        end
        
        %% Generate static aeroelastic load cases
        function nastranSubcaseVector =...
                generateStaticAeroelasticLoadCases(obj,mach,...
                dynamicPressure,independentAestatVector,...
                trimmingConstraintVector,dependentAestatVector)
            %generateStaticAeroelasticLoadCases Generate new load cases
            %specifying constraints for aeroelastic trim variables.
            %   nastranSubcaseVector =...
            %   generateStaticAeroelasticLoadCases(obj,mach,...
            %   dynamicPressure,independentAestatVector,...
            %   trimmingConstraintVector,dependentAestatVector) assigns a
            %   vector of Trim objects to the TrimArray property and
            %   returns a vector of NastranSubcase objects of the same
            %   length. mach and dynamicPressure are scalars if only one
            %   load case is generated, otherwise they are vectors for
            %   generation of multiple load cases. independentAestatVector
            %   and dependentAestatVector include Aestat objects defining
            %   repsectively the constrained and free trim parameters. Both
            %   are vectors of Aestat objects in case of a single load case
            %   and cell arrays for the definition of multiple load cases.
            %   trimmingConstraintVector includes the values of the
            %   constrained parameter, it is a vector for a single load
            %   case or a cell array for multiple load cases.
            % Concatenate independent and dependent Aestat objects
            if nargin==6
                if ~iscell(independentAestatVector)
                    % If only one load case is generated, concatenate
                    % vectors
                    aestatVector = [independentAestatVector;...
                        dependentAestatVector];
                else
                    % If more than one load case is generated, generate
                    % array of Aestat objects with no repetitions
                    % considering the objects of all load cases
                    aestatVector = [independentAestatVector{:};...
                        dependentAestatVector{:}];
                    [~,aestatIndexVector,~] = unique([aestatVector.Id]);
                    aestatVector = aestatVector(aestatIndexVector);
                end
            else
                % If only independent Aestat objects are indicated consider
                % only those
                aestatVector = [independentAestatVector{:}];
                [~,aestatIndexVector,~] = unique([aestatVector.Id]);
                aestatVector = aestatVector(aestatIndexVector);
            end
            % Assign Aestat objects to Aestat property
            obj.AestatArray = aestatVector;
            % Create input structure for Trim object
            trimStruct = struct('sid',num2cell(obj.LastSetId.IdNo+1:...
                obj.LastSetId.addId(length(independentAestatVector)))',...
                'mach',num2cell(mach),...
                'q',num2cell(dynamicPressure),...
                'labeli',cellfun(@(x) {x.Label},independentAestatVector,...
                'UniformOutput',false),...
                'uxi',trimmingConstraintVector);
            % Generate Trim object vector
            obj.TrimArray = Trim(trimStruct);
            % Update case control
            nastranSubcaseVector = NastranSubcase(struct(...
                'trim',num2cell(obj.TrimArray)));
        end
        
        %% Generate gust aeroelastic load case
        function generateGustAeroelasticLoadCases(obj,acsid,velocity,...
                refChord,refAltitude,cutOffFrequency,gustFrequency,...
                gustAmplitude,solutionPeriod)
            % Find reference speed of sound and air density corresponding
            % to input reference altitude
            [~,refSpeedOfSound,~,refRho] = atmosisa(refAltitude);
            % Generate Aero object with aerodynamic physical data
            obj.AeroArray = Aero(struct('acsid',acsid,...
                'velocity',velocity,...
                'refc',refChord,...
                'rhoref',refRho));
            % Generate Tabdmp1 object for definition of structural damping,
            % included as modal structural damping. A realistic value of 
            % g = 0.02 is assumed to be constant in the frequency range
            % from zero to the input cut-off frequency
            obj.Tabdmp1Array = Tabdmp1(struct(...
                'tid',obj.LastTableId.addId,...
                'fi',[0,cutOffFrequency],...
                'gi',[0.02,0.02]));
            % Define time-dependent gust signal
            % Find gust half length from velocity and gust frequency
            gustHalfLength = velocity/(2*gustFrequency);
            % Define a delay of 0.2 s for the application of the gust
            gustDelay = 0.2;    % [s]
            % Define the time vector taking 100 linearly distributed time
            % instants between zero and the gust period
            timeVector = linspace(0,1/gustFrequency);
            % Define gust velocity according to 1-cosine formula
            gustVelocityVector = 1/2*(1-cos(pi*timeVector*...
                velocity/gustHalfLength));
            % Genereate Tabled1 object for the tabular function
            % corresponding to the gust signal
            obj.Tabled1Array = Tabled1(struct(...
                'tid',obj.LastTableId.addId,...
                'xi',timeVector,...
                'yi',gustVelocityVector));
            % Generate dummy Darea object for the Tload1 card
            obj.DareaArray = Darea(struct(...
                'sid',obj.LastSetId.addId,...
                'pi',1,...
                'ci',1,...
                'ai',0));
            % Genereate Tload1 object for the definition of time-dependent
            % dynamic load
            obj.Tload1Array = Tload1(struct(...
                'sid',obj.LastSetId.addId,...
                'excited',obj.DareaArray.Sid,...
                'tid',obj.Tabled1Array.Tid));
            % Generate Gust object for the definition of a stationary
            % vertical gust
            obj.GustArray = Gust(struct(...
                'sid',obj.LastSetId.addId,...
                'dload',obj.Tload1Array.Sid,...
                'wg',tand(gustAmplitude),...
                'x0',-gustDelay*velocity,...
                'v',velocity));
            % Define set of frequencies for the frequency response solution
            % Define solution period as multiple of the gust period
            frequencyStep = 1/solutionPeriod;
            obj.Freq1Array = Freq1(struct(...
                'sid',obj.LastSetId.addId,...
                'f1',1e-5,...
                'df',frequencyStep,...
                'ndf',ceil(cutOffFrequency/frequencyStep)));
            % Use 40 time steps for the time interval corresponding to the
            % gust period
            noTimeStepGustPeriod = 40;
            % Define total number of time steps multiplying the number of
            % time step for each gust period for the ratio between the
            % solution period and the gust period
            noTimeStep = ceil(solutionPeriod/(1/gustFrequency)*...
                noTimeStepGustPeriod);
            % Define time step based on solution period and total number of
            % times steps
            timeStep = solutionPeriod/noTimeStep;
            % Generate Tstep object for the definition of time step
            % intervals at which solution is generated in transiet analysis
            obj.TstepArray = Tstep(struct(...
                'sid',obj.LastSetId.addId,...
                'ni',noTimeStep,...
                'dti',timeStep,...
                'noi',1));
            % Define Param cards relative to the gust
            % Mach number
            mach = velocity/refSpeedOfSound;
            % Dynamic pressure
            dynamicPressure = 0.5*refRho*velocity^2;
            % Solution parameters: harmonic gust aerodynamic
            % coefficients, flight conditions amd number of modes used in
            % the analysis
            paramVector = Param(struct(...
                'n',{'GUSTAERO','LMODES','MACH','Q'},...
                'v1',{-1,obj.EigrlArray.Nd,mach,dynamicPressure}));
            % Assign Param objects to ParamArray property, checking whether
            % already existing parameters are present. In that case
            % substitute old parameter with new one.
            for param = paramVector
                if any(strcmp(param.N,{obj.ParamArray.N}))
                    obj.ParamArray(strcmp(param.N,{obj.ParamArray.N})) =...
                        param;
                else
                    obj.ParamArray = [obj.ParamArray,param];
                end
            end
            % Define reduced frequencies for calculation of aerodynamic
            % matrices
            % Calculate max reduced frequency taking into account the gust
            % frequency
            maxReducedFrequency = 2*pi*gustFrequency*...
                obj.AeroArray.Refc/(2*obj.AeroArray.Velocity);
            % Mach Numbers and reduced frequencies used in generating the
            % aerodynamic matrices
            kj = logspace(log10(0.001),...
                log10(ceil(maxReducedFrequency*10)*0.1),5);
            obj.Mkaero1Array = Mkaero1(struct(...
                'mi',mach,...
                'kj',kj));
        end
        
        %% Write to .bdf file the elements of the whole region
        function write2Bdf(obj,fileId)
            fprintf(fileId,'\n$ INPUT BULK DATA DECK\n');
            fprintf(fileId,['$-------2-------3-------4-------5-------6',...
                '-------7-------8-------9-------\n']);
            obj.AecompArray.write2Bdf(fileId);
            obj.Conm2Array.write2Bdf(fileId);
            obj.Cord2rArray.write2Bdf(fileId);
            obj.EigrlArray.write2Bdf(fileId);
            obj.ForceArray.write2Bdf(fileId);
            obj.LoadArray.write2Bdf(fileId);
            obj.Mondsp1Array.write2Bdf(fileId);
            obj.NlparmArray.write2Bdf(fileId);
            obj.ParamArray.write2Bdf(fileId);
            obj.Rbe2Array.write2Bdf(fileId);
            obj.Rbe3Array.write2Bdf(fileId);
            obj.Spc1Array.write2Bdf(fileId);
            obj.SpcdArray.write2Bdf(fileId);
            fprintf(fileId,'\n$ Structural elements\n');
            obj.PartArray.write2Bdf(fileId);
            fprintf(fileId,['\n$ Nodes\n$-------2-------3-------4',...
                '-------5-------6-------7-------8-------9-------\n']);
            obj.GridArray.write2Bdf(fileId);
            fprintf(fileId,['\n$ Aerodynamic model and splining\n$----',...
                '---2-------3-------4-------5-------6-------7-------8-',...
                '------9-------\n']);
            obj.AerosArray.write2Bdf(fileId);
            obj.Paero1Array.write2Bdf(fileId);
            obj.Caero1Array.write2Bdf(fileId);
            obj.Set1Array.write2Bdf(fileId);
            obj.Spline1Array.write2Bdf(fileId);
            obj.AestatArray.write2Bdf(fileId);
            obj.TrimArray.write2Bdf(fileId);
            % Gust
            obj.AeroArray.write2Bdf(fileId);
            obj.DareaArray.write2Bdf(fileId);
            obj.Freq1Array.write2Bdf(fileId);
            obj.GustArray.write2Bdf(fileId);
            obj.Mkaero1Array.write2Bdf(fileId);
            obj.Tabdmp1Array.write2Bdf(fileId);
            obj.Tabled1Array.write2Bdf(fileId);
            obj.Tload1Array.write2Bdf(fileId);
            obj.TstepArray.write2Bdf(fileId);
            fprintf(fileId,'ENDDATA\n');
        end
    end
end
