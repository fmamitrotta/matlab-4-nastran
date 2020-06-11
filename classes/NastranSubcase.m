classdef NastranSubcase
    %NastranSubcase Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Disp
        Load
        Method
        Spc
        Strain
        Stress
        Trim
    end
    
    methods
        %% Constructor
        function obj = NastranSubcase(subcaseStruct)
            %NastranSubcase Construct an instance of this class
            %   Detailed explanation goes here
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(subcaseStruct);
                obj(m,n) = NastranSubcase;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        if isfield(subcaseStruct,'disp')
                            obj(i,j).Disp = subcaseStruct(i,j).disp;
                        end
                        if isfield(subcaseStruct,'load')
                            obj(i,j).Load = subcaseStruct(i,j).load;
                        end
                        if isfield(subcaseStruct,'method')
                            obj(i,j).Method = subcaseStruct(i,j).method;
                        end
                        if isfield(subcaseStruct,'spc')
                            obj(i,j).Spc = subcaseStruct(i,j).spc;
                        end
                        if isfield(subcaseStruct,'strain')
                            obj(i,j).Strain = subcaseStruct(i,j).strain;
                        end
                        if isfield(subcaseStruct,'stress')
                            obj(i,j).Stress =...
                                subcaseStruct(i,j).stress;
                        end
                        if isfield(subcaseStruct,'trim')
                            obj(i,j).Trim = subcaseStruct(i,j).trim;
                        end
                    end
                end
            end
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            %write2Bdf Write object to .bdf file.
            %   Detailed explanation goes here
            
            for i=1:length(obj)
                fprintf(fileId,'SUBCASE %d\n',i);
                if ~isempty(obj(i).Disp)
                    fprintf(fileId,'\tDISP = %s\n',obj(i).Disp);
                end
                if ~isempty(obj(i).Load)
                    fprintf(fileId,'\tLOAD = %d\n',obj(i).Load.Sid);
                end
                if ~isempty(obj(i).Method)
                    fprintf(fileId,'\tMETHOD = %d\n',obj(i).Method.Sid);
                end
                if ~isempty(obj(i).Spc)
                    fprintf(fileId,'\tSPC = %d\n',obj(i).Spc.Sid);
                end
                if ~isempty(obj(i).Strain)
                    fprintf(fileId,'\tSTRAIN(%s) = %s\n',obj(i).Strain{:});
                end
                if ~isempty(obj(i).Stress)
                    fprintf(fileId,'\tSTRESS(%s) = %s\n',obj(i).Stress{:});
                end
                if ~isempty(obj(i).Trim)
                    fprintf(fileId,'\tTRIM = %d\n',obj(i).Trim.Sid);
                end
            end
        end
    end
end
