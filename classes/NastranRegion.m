classdef NastranRegion < matlab.mixin.Copyable
    %NastranRegion Class for the management of a region of a Nastran model.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        ParentPart              % Parent NastranPart object
        ParentRegion            % Possible parent NastranRegion object, if the region is actually a sub-region
        ElementProperty         % Property of the structural elements of the region
        MaterialPropertyArray   % Material property array linked to the property of the structural elements
        ElementArray            % Array of structural elements
        OverlayRegion           % NastranRegion object that shares the same structural nodes of the present region
        SubRegionArray          % Array of sub-regions of present region
    end
    
    methods
        %% Constructor
        function obj = NastranRegion(nastranRegionStruct)
            %NastranRegion Construct an instance of this class
            
            % If number of input arguments is not zero then initialize the
            % object array with the size of the input structure
            if nargin ~= 0
                [m,n] = size(nastranRegionStruct);
                obj(m,n) = NastranRegion;
                
                % Iterate through the elements of the input structure
                for i = m:-1:1
                    for j = n:-1:1
                        % Assign only properties present in the fields of
                        % the input structure
                        if isfield(nastranRegionStruct,'parentPart')
                            obj(i,j).ParentPart =...
                                nastranRegionStruct(i,j).parentPart;
                        end
                        if isfield(nastranRegionStruct,'parentRegion')
                            obj(i,j).ParentRegion =...
                                nastranRegionStruct(i,j).parentRegion;
                        end
                        if isfield(nastranRegionStruct,'elementProperty')
                            obj(i,j).ElementProperty =...
                                nastranRegionStruct(i,j).elementProperty;
                        end
                        if isfield(nastranRegionStruct,...
                                'materialPropertyArray')
                            obj(i,j).MaterialPropertyArray =...
                                nastranRegionStruct(...
                                i,j).materialPropertyArray;
                        end
                        if isfield(nastranRegionStruct,'overlayRegion')
                            obj(i,j).OverlayRegion =...
                                nastranRegionStruct(i,j).overlayRegion;
                        end
                        if isfield(nastranRegionStruct,'subRegionArray')
                            obj(i,j).SubRegionArray =...
                                nastranRegionStruct(i,j).subRegionArray;
                        end
                    end
                end
            end
        end
                
        %% SubRegionArray set method
        function set.SubRegionArray(obj,subRegionArray)
            % Assign current NastranPart object as parent of all
            % NastranRegion objects in input
            obj.SubRegionArray = subRegionArray;
            parentRegionArray = num2cell(repmat(obj,...
                size(subRegionArray,1),size(subRegionArray,2)));
            [obj.SubRegionArray.ParentRegion] = parentRegionArray{:};
        end
        
        %% Generate element array from overlay region
        function generateElementsFromOverlayRegion(obj,elementId,...
                zOffsetDirection)
            % If the direction of the offset in z is not specified, then
            % take as default one (that is same direction of z axis of
            % structural element)
            if nargin < 3
                zOffsetDirection = 1;
            end
            % Iterate through the the elment array of the overlay region
            for i = size(obj.OverlayRegion.ElementArray,1):-1:1
                for j = size(obj.OverlayRegion.ElementArray,2):-1:1
                    % Generate structure for the element object creation
                    cquad4Struct(i,j).eid = elementId.addId;
                    cquad4Struct(i,j).pid =...
                        obj.ParentRegion.ElementProperty.Pid;
                    cquad4Struct(i,j).gridArray =...
                        obj.OverlayRegion.ElementArray(i,j).GridArray;
                    if zOffsetDirection == -1
                        cquad4Struct(i,j).gridArray = flip(...
                            cquad4Struct(i,j).gridArray);
                    end
                    cquad4Struct(i,j).zoffs = zOffsetDirection*(...
                        obj.ParentRegion.ElementProperty.T+...
                        obj.OverlayRegion.ParentRegion.ElementProperty.T...
                        )/2;
                end
            end
            % Create the element object array
            obj.ElementArray = Cquad4(cquad4Struct);
        end
        
        %% Find boundary grid points of region
        function boundaryGridVector = findBoundaryGridPoints(obj)
            % Retrieve vector with boundary Grid objects of current region
            if iscell(obj.ElementArray)
                if isa(obj.ElementArray{1,end},'Ctria3')
                    g1Vector = cellfun(@(x) x.GridArray(1),...
                        obj.ElementArray(1,1:end-1));
                    g2Vector = obj.ElementArray{1,end}.GridArray(2);
                else
                    g1Vector = cellfun(@(x) x.GridArray(1),...
                        obj.ElementArray(1,:));
                    g2Vector = cellfun(@(x) x.GridArray(2),...
                        obj.ElementArray(:,end));
                end
                if isa(obj.ElementArray{1,1},'Ctria3')
                    g3Vector = cellfun(@(x) x.GridArray(3),...
                        obj.ElementArray(end,2:end));
                    g4Vector = obj.ElementArray{1,1}.GridArray(3);
                else
                    g3Vector = cellfun(@(x) x.GridArray(3),...
                        obj.ElementArray(end,:));
                    g4Vector = cellfun(@(x) x.GridArray(4),...
                        obj.ElementArray(:,1));
                end
            else
                g1Vector = arrayfun(@(x) x.GridArray(1),...
                    obj.ElementArray(1,:));
                g2Vector = arrayfun(@(x) x.GridArray(2),...
                    obj.ElementArray(1,:));
                g3Vector = arrayfun(@(x) x.GridArray(3),...
                    obj.ElementArray(1,:));
                g4Vector = arrayfun(@(x) x.GridArray(4),...
                    obj.ElementArray(1,:));
            end
            boundaryGridVector = [g1Vector';g2Vector';g3Vector';g4Vector'];
        end
        
        %% Find region centroid
        function xyzRegionCentroid = findCentroid(obj)
            % Retrieve vector with boundary Grid objects
            boundaryGridVector = obj.findBoundaryGridPoints;
            % Retrieve xyz coordinates of the boundary points
            xyzBoundaryPointsArray = boundaryGridVector.getXyzArray;
            % Calculate xyz coordinates of centroid as aritmetic mean of
            % coordinates of boundary points
            xyzRegionCentroid = mean(xyzBoundaryPointsArray,1);
        end
        
        %% Get all cquad4 elements
        function cquad4ElementsVector = getAllCquad4Elements(obj)
            % Iterate through the object array
            for i = length(obj):-1:1
                if ~isempty(obj(i).SubRegionArray)
                    % If SubRegionArray is not empty, iterate thorugh the
                    % sub-regions of the current region
                    for j = length(obj(i).SubRegionArray):-1:1
                        if isa(obj(i).SubRegionArray(j).ElementArray,...
                                'Cquad4')
                            % If element array of current sub-region is a
                            % Cquad4 array, then retrive all elements
                            cquad4ElementsArray{i,j} =...
                                obj(i).SubRegionArray(j).ElementArray(:);
                        elseif iscell(...
                                obj(i).SubRegionArray(j).ElementArray)
                            % If element array of current sub-region is a
                            % cell array, then select only the Cquad4
                            % objects within the cell array
                            localCquad4ElementsIndexArray =...
                                cellfun(@(x) isa(x,'Cquad4'),...
                                obj(i).SubRegionArray(j).ElementArray);
                            localCquad4ElementsArray =...
                                obj(i).SubRegionArray(j).ElementArray(...
                                localCquad4ElementsIndexArray);
                            cquad4ElementsArray{i,j} =...
                                [localCquad4ElementsArray{:}]';
                        else
                            % If no Cquad4 elements are present in current
                            % sub-region, then assign an empty element
                            cquad4ElementsArray{i,j} = Cquad4.empty;
                        end
                    end
                else
                    % If there is no sub-region in current region, use
                    % the element array at the region level
                    if isa(obj(i).ElementArray,'Cquad4')
                        % If element array of current sub-region is a
                        % Cquad4 array, then retrive all elements
                        cquad4ElementsArray{i,1} = obj(i).ElementArray(:);
                    elseif iscell(obj(i).ElementArray)
                        % If element array of current sub-region is a
                        % cell array, then select only the Cquad4
                        % objects within the cell array
                        localCquad4ElementsIndexArray =...
                            cellfun(@(x) isa(x,'Cquad4'),...
                            obj(i).ElementArray);
                        localCquad4ElementsArray = obj(i).ElementArray(...
                            localCquad4ElementsIndexArray);
                        cquad4ElementsArray{i,1} =...
                            [localCquad4ElementsArray{:}]';
                    else
                        % If no Ctria4 elements are present in current
                        % sub-region, then assign an empty element
                        cquad4ElementsArray{i,1} = Cquad4.empty;
                    end
                end
            end
            % Concatenate all the Cquad4 objects retrieved
            cquad4ElementsVector = vertcat(cquad4ElementsArray{:});
        end
        
        %% Get all ctria3 elements
        function ctria3ElementsVector = getAllCtria3Elements(obj)
            % Iterate through the object array
            for i = length(obj):-1:1
                if ~isempty(obj(i).SubRegionArray)
                    % If SubRegionArray is not empty, iterate thorugh the
                    % sub-regions of the current region
                    for j = length(obj(i).SubRegionArray):-1:1
                        if isa(obj(i).SubRegionArray(j).ElementArray,...
                                'Ctria3')
                            % If element array of current sub-region is a
                            % Ctria3 array, then retrive all elements
                            ctria3ElementsArray{i,j} =...
                                obj(i).SubRegionArray(j).ElementArray(:);
                        elseif iscell(...
                                obj(i).SubRegionArray(j).ElementArray)
                            % If element array of current sub-region is a
                            % cell array, then select only the Ctria3
                            % objects within the cell array
                            localCtria3ElementsIndexArray =...
                                cellfun(@(x) isa(x,'Ctria3'),...
                                obj(i).SubRegionArray(j).ElementArray);
                            localCtria3ElementsArray =...
                                obj(i).SubRegionArray(j).ElementArray(...
                                localCtria3ElementsIndexArray);
                            ctria3ElementsArray{i,j} =...
                                [localCtria3ElementsArray{:}]';
                        else
                            % If no Ctria3 elements are present in current
                            % sub-region, then assign an empty element
                            ctria3ElementsArray{i,j} = Ctria3.empty;
                        end
                    end
                else
                    % If there is no sub-region in current region, use
                    % the element array at the region level
                    if isa(obj(i).ElementArray,'Ctria3')
                        % If element array of current sub-region is a
                        % Ctria3 array, then retrive all elements
                        ctria3ElementsArray{i,1} = obj(i).ElementArray(:);
                    elseif iscell(obj(i).ElementArray)
                        % If element array of current sub-region is a
                        % cell array, then select only the Ctria3
                        % objects within the cell array
                        localCtria3ElementsIndexArray =...
                            cellfun(@(x) isa(x,'Ctria3'),...
                            obj(i).ElementArray);
                        localCtria3ElementsArray = obj(i).ElementArray(...
                            localCtria3ElementsIndexArray);
                        ctria3ElementsArray{i,1} =...
                            [localCtria3ElementsArray{:}]';
                    else
                        % If no Ctria3 elements are present in current
                        % sub-region, then assign an empty element
                        ctria3ElementsArray{i,1} = Ctria3.empty;
                    end
                end
            end
            % Concatenate all the Ctria3 objects retrieved
            ctria3ElementsVector = vertcat(ctria3ElementsArray{:});
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileId)
            % Write to .bdf file the elements of the whole region
            for i = 1:length(obj)
                if isempty(obj(i).ParentRegion)
                    fprintf(fileId,['$ %s region no %d\n$-------2-----',...
                        '--3-------4-------5-------6-------7-------8--',...
                        '-----9-------\n'],...
                        obj(i).ParentPart.Name,i);
                    obj(i).ElementProperty.write2Bdf(fileId);
                    obj(i).MaterialPropertyArray.write2Bdf(fileId);
                end
                if isempty(obj(i).SubRegionArray)
                    if iscell(obj(i).ElementArray)
                        cellfun(@(x) x.write2Bdf(fileId),...
                            obj(i).ElementArray);
                    else
                        obj(i).ElementArray.write2Bdf(fileId);
                    end
                else
                    obj(i).SubRegionArray.write2Bdf(fileId)
                end
            end
        end
        
        %% Plot structural elements
        function plotElements(obj,varargin)
            % Plot elements of the whole region
            % Iterate through the region array
            for i = 1:length(obj)
                if ~isempty(obj(i).ElementArray)
                    % If ElementArray is not empty check whether it is
                    % composed by a cell array or element objects
                    if iscell(obj(i).ElementArray)
                        cellfun(@(x) x.plot(varargin{:}),...
                            obj(i).ElementArray);
                    else
                        obj.ElementArray.plot(varargin{:})
                    end
                else
                    % If ElementArray is empty then plot the elements in
                    % the sub regions
                    arrayfun(@(x) x.plotElements(varargin{:}),...
                        obj(i).SubRegionArray);
                end
            end
        end
    end
end
