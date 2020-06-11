classdef NastranCaseControl < matlab.mixin.Copyable
    %NastranExecutiveControl Class for the management of a Nastran
    %case control deck.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        ParentAnalysis = NastranAnalysis.empty;
        Title
        Subti
        Aerof = 'ALL';
        Apres = 'ALL';
        Disp = 'ALL';
        Dload
        Echo = 'BOTH';
        Force = 'ALL';
        Freq
        Gpforce
        Gust
        Label
        Line = 2e6;
        Load
        Method
        Monitor
        Nlparm
        Sdamp
        Sdisp
        Set
        Spc
        Spcforces
        Strain = {'SHEAR','ALL'};
        Stress = {'SHEAR','ALL'};
        Tstep
        SubcaseArray
    end
    
    methods
        %% Constructor
        function obj = NastranCaseControl(nastranCaseControlStruct)
            %NastranCaseControl Construct an instance of this class
            %   Detailed explanation goes here
            
            % Assign only properties present in the fields of the input 
            % structure
            if isfield(nastranCaseControlStruct,'title')
                obj.Title = nastranCaseControlStruct.title;
            end
            if isfield(nastranCaseControlStruct,'subti')
                obj.Subti = nastranCaseControlStruct.subti;
            end
            if isfield(nastranCaseControlStruct,'label')
                obj.Label = nastranCaseControlStruct.label;
            end
            if isfield(nastranCaseControlStruct,'echo')
                obj.Echo = nastranCaseControlStruct.echo;
            end
            if isfield(nastranCaseControlStruct,'line')
                obj.Line = nastranCaseControlStruct.line;
            end
            if isfield(nastranCaseControlStruct,'load')
                obj.Load = nastranCaseControlStruct.load;
            end
            if isfield(nastranCaseControlStruct,'method')
                obj.Method = nastranCaseControlStruct.method;
            end
            if isfield(nastranCaseControlStruct,'monitor')
                obj.Monitor = nastranCaseControlStruct.monitor;
            end
            if isfield(nastranCaseControlStruct,'set')
                obj.Set = nastranCaseControlStruct.set;
            end
            if isfield(nastranCaseControlStruct,'spc')
                obj.Spc = nastranCaseControlStruct.spc;
            end
            if isfield(nastranCaseControlStruct,'sdisp')
                obj.Sdisp = nastranCaseControlStruct.sdisp;
            end
            if isfield(nastranCaseControlStruct,'disp')
                obj.Disp = nastranCaseControlStruct.disp;
            end
            if isfield(nastranCaseControlStruct,'nlparm')
                obj.Nlparm = nastranCaseControlStruct.nlparm;
            end
            if isfield(nastranCaseControlStruct,'strain')
                obj.Strain = nastranCaseControlStruct.strain;
            end
            if isfield(nastranCaseControlStruct,'stress')
                obj.Stress = nastranCaseControlStruct.stress;
            end
            if isfield(nastranCaseControlStruct,'force')
                obj.Force = nastranCaseControlStruct.force;
            end
            if isfield(nastranCaseControlStruct,'gpforce')
                obj.Gpforce = nastranCaseControlStruct.gpforce;
            end
            if isfield(nastranCaseControlStruct,'spcforces')
                obj.Spcforces = nastranCaseControlStruct.spcforces;
            end
            if isfield(nastranCaseControlStruct,'aerof')
                obj.Aerof = nastranCaseControlStruct.aerof;
            end
            if isfield(nastranCaseControlStruct,'apres')
                obj.Apres = nastranCaseControlStruct.apres;
            end
            if isfield(nastranCaseControlStruct,'sdamp')
                obj.Sdamp = nastranCaseControlStruct.sdamp;
            end
            if isfield(nastranCaseControlStruct,'gust')
                obj.Gust = nastranCaseControlStruct.gust;
            end
            if isfield(nastranCaseControlStruct,'dload')
                obj.Dload = nastranCaseControlStruct.dload;
            end
            if isfield(nastranCaseControlStruct,'freq')
                obj.Freq = nastranCaseControlStruct.freq;
            end
            if isfield(nastranCaseControlStruct,'tstep')
                obj.Tstep = nastranCaseControlStruct.tstep;
            end
            if isfield(nastranCaseControlStruct,'subcaseArray')
                obj.SubcaseArray = nastranCaseControlStruct.subcaseArray;
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            %write2Bdf Write object to .bdf file.
            %   Detailed explanation goes here
            fprintf(fileId,'$ CASE CONTROL DECK\n');
            if ~isempty(obj.Title)
                fprintf(fileId,'TITLE = %s\n',obj.Title);
            end
            if ~isempty(obj.Subti)
                fprintf(fileId,'SUBTI = %s\n',obj.Subti);
            end
            if ~isempty(obj.Label)
                fprintf(fileId,'LABEL = %s\n',obj.Label);
            end
            if ~isempty(obj.Echo)
                fprintf(fileId,'ECHO = %s\n',obj.Echo);
            end
            if ~isempty(obj.Line)
                fprintf(fileId,'LINE = %d\n',obj.Line);
            end
            if ~isempty(obj.Load)
                fprintf(fileId,'LOAD = %d\n',obj.Load.Sid);
            end
            if ~isempty(obj.Method)
                fprintf(fileId,'METHOD = %d\n',obj.Method.Sid);
            end
            if ~isempty(obj.Monitor)
                fprintf(fileId,'MONITOR = %s\n',obj.Monitor);
            end
            if ~isempty(obj.Set)
                obj.Set.write2Bdf(fileId);
            end
            if ~isempty(obj.Spc)
                fprintf(fileId,'SPC = %d\n',obj.Spc.Sid);
            end
            if ~isempty(obj.Disp)
                if ischar(obj.Disp)
                    fprintf(fileId,'DISP = %s\n',obj.Disp);
                else
                    fprintf(fileId,'DISP = %d\n',obj.Disp);
                end
            end
            if ~isempty(obj.Sdisp)
                if ischar(obj.Sdisp)
                    fprintf(fileId,'SDISP = %s\n',obj.Sdisp);
                else
                    fprintf(fileId,'SDISP = %d\n',obj.Sdisp);
                end
            end
            if ~isempty(obj.Nlparm)
                fprintf(fileId,'NLPARM = %d\n',obj.Nlparm.Id);
            end
            if ~isempty(obj.Strain)
                if iscell(obj.Strain)
                    fprintf(fileId,'STRAIN(%s) = %s\n',obj.Strain{:});
                else
                    fprintf(fileId,'STRAIN = %s\n',obj.Strain);
                end
            end
            if ~isempty(obj.Stress)
                if iscell(obj.Stress)
                    fprintf(fileId,'STRESS(%s) = %s\n',obj.Stress{:});
                else
                    fprintf(fileId,'STRESS = %s\n',obj.Stress);
                end
            end
            if ~isempty(obj.Force)
                fprintf(fileId,'FORCE = %s\n',obj.Force);
            end
            if ~isempty(obj.Gpforce)
                fprintf(fileId,'GPFORCE = %d\n',obj.Gpforce);
            end
            if ~isempty(obj.Spcforces)
                if ischar(obj.Spcforces)
                    fprintf(fileId,'SPCFORCES = %s\n',obj.Spcforces);
                else
                    fprintf(fileId,'SPCFORCES = %d\n',obj.Spcforces);
                end
            end
            if ~isempty(obj.Aerof)
                fprintf(fileId,'AEROF = %s\n',obj.Aerof);
            end
            if ~isempty(obj.Apres)
                fprintf(fileId,'APRES = %s\n',obj.Apres);
            end
            if ~isempty(obj.Sdamp)
                fprintf(fileId,'SDAMP = %d\n',obj.Sdamp);
            end
            if ~isempty(obj.Gust)
                fprintf(fileId,'GUST = %d\n',obj.Gust);
            end
            if ~isempty(obj.Dload)
                fprintf(fileId,'DLOAD = %d\n',obj.Dload);
            end
            if ~isempty(obj.Freq)
                fprintf(fileId,'FREQ = %d\n',obj.Freq);
            end
            if ~isempty(obj.Tstep)
                fprintf(fileId,'TSTEP = %d\n',obj.Tstep);
            end
            if ~isempty(obj.SubcaseArray)
                obj.SubcaseArray.write2Bdf(fileId);
            end
            fprintf(fileId,'BEGIN BULK\n');
        end
    end
end
