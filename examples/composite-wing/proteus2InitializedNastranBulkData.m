function initializedNastranBulkData = proteus2InitializedNastranBulkData(...
    proteusDataStruct,nastranSettingStruct)
%initializedNastranBulkData Initialize a NastranBulkData object.
%   initializedNastranBulkData = proteus2InitializedNastranBulkData(...
%   proteusDataStruct,nastranSettingStruct) generates a NastranBulkData
%   object based on the input arguments representing the data coming from
%   the Proteus model and the settings that determine the characteristic of
%   the final Nastran model. The initialization consists in the definition
%   of the parts, regions and materials of the nastran model.

%% Initialize Top Skin
% Iterate through laminates of top skin
for i = length(proteusDataStruct.constant.lam.TopID):-1:1
    % Save laminate id
    laminateId = proteusDataStruct.constant.lam.TopID{i};
    % Retrieve laminate thickness
    laminateThickness = proteusDataStruct.designVector(9*laminateId);
    % Generate Mat2 array with membrane and bending material property
    materialPropertyArray{i} = proteusLaminationParameters2NastranMat2(...
        proteusDataStruct,nastranSettingStruct,laminateId);
    % Generate Pshell object
    elementPropertyArray{i} = Pshell(struct(...
        'pid',nastranSettingStruct.lastPropertyId.addId,...
        'mid1',materialPropertyArray{i}(1).Mid,...
        't',laminateThickness,...
        'mid2',materialPropertyArray{i}(2).Mid));
end
% Create initial structure for the generation of the NastranRegion object
topSkinRegionStructArray = struct('elementProperty',elementPropertyArray,...
    'materialPropertyArray',materialPropertyArray);

%% Initialize Bottom Skin
% Iterate through laminates of bottom skin
for i = length(proteusDataStruct.constant.lam.BotID):-1:1
    % Save laminate id
    laminateId = proteusDataStruct.constant.lam.BotID{i};
    % Retrieve laminate thickness
    laminateThickness = proteusDataStruct.designVector(9*laminateId);
    % Generate Mat2 array with membrane and bending material property
    materialPropertyArray{i} = proteusLaminationParameters2NastranMat2(...
        proteusDataStruct,nastranSettingStruct,laminateId);
    % Generate Pshell object
    elementPropertyArray{i} = Pshell(struct(...
        'pid',nastranSettingStruct.lastPropertyId.addId,...
        'mid1',materialPropertyArray{i}(1).Mid,...
        't',laminateThickness,...
        'mid2',materialPropertyArray{i}(2).Mid));
end
% Create initial structure for the generation of the NastranRegion object
bottomSkinRegionStructArray = struct(...
    'elementProperty',elementPropertyArray,...
    'materialPropertyArray',materialPropertyArray);

%% Initialize Spars
% Iterate through laminates of spar
for i = length(proteusDataStruct.constant.lam.SparID):-1:1
    % Iterate through the spars present in current laminate region
    for j = 1:length(proteusDataStruct.constant.lam.SparID{i})
        % Identify spar number
        sparNo = proteusDataStruct.constant.lam.SparNum{i}(j);
        % Save laminate id of current spar
        laminateId = proteusDataStruct.constant.lam.SparID{i}(j);
        % Retrieve laminate thickness
        laminateThickness = proteusDataStruct.designVector(9*laminateId);
        % Generate Mat2 array with membrane and bending material property
        materialPropertyArray{sparNo,i} =...
            proteusLaminationParameters2NastranMat2(...
            proteusDataStruct,nastranSettingStruct,laminateId);
        % Generate Pshell object
        elementPropertyArray{sparNo,i} = Pshell(struct(...
            'pid',nastranSettingStruct.lastPropertyId.addId,...
            'mid1',materialPropertyArray{sparNo,i}(1).Mid,...
            't',laminateThickness,...
            'mid2',materialPropertyArray{sparNo,i}(2).Mid));
        % Determine the x location of the spar
        sparXLocation =...
            proteusDataStruct.constant.lam.coord{laminateId}(1,1);
        % Determine the vector with the x boundary of the top skin
        topSkinXBoundaryVector =...
            [proteusDataStruct.constant.lam.coord{...
            proteusDataStruct.constant.lam.TopID{i}}(1,1),...
            proteusDataStruct.constant.lam.coord{...
            proteusDataStruct.constant.lam.TopID{i}}(2,1)];
        
        % Determine the sub-regions given by the presence of the spar
        % flange
        if nastranSettingStruct.flangeSize>0
            % If the spar has flanges, then there will be 3 skin subregions
            % across it
            nSubRegionsAcrossSpar = 3;
        else
            % If the spar does not have flanges, then there will be only
            % subregions across it
            nSubRegionsAcrossSpar = 2;
            % If no flange size is specified in the excel input file, then
            % fill the sub-region array for spar with empty cells.
            sparSubRegionArray{sparNo,i} = [];
        end
        % If a flange size is specified in the excel input file,
        % distinguish whether spar falls in between the skin boundaries
        % or right at one of the boundaries
        if sparXLocation > topSkinXBoundaryVector(1) &&...
                sparXLocation < topSkinXBoundaryVector(2)
            % If the spar falls in between the skin boundaries
            % distinguish whether the current laminate region of the
            % skin has already other sub-regions
            if ~isfield(topSkinRegionStructArray,'subRegionArray') ||...
                    isempty(topSkinRegionStructArray(i).subRegionArray)
                % If current current laminate region of the skin
                % does not have other sub-regions then assign 3
                % sub-regions to the skins and 3 sub-regions to the
                % spar. Indicate that the first and last sub-region of
                % the spar overlay with the second sub-region of the
                % bottom and top skin respectively.
                topSkinRegionStructArray(i).subRegionArray =...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar)));
                bottomSkinRegionStructArray(i).subRegionArray =...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar)));
                if nastranSettingStruct.flangeSize>0
                    sparSubRegionArray{sparNo,i} = NastranRegion(struct(...
                        'overlayRegion',{bottomSkinRegionStructArray(...
                        i).subRegionArray(2),[],...
                        topSkinRegionStructArray(i).subRegionArray(2)}));
                end
            else
                % If current current laminate region of the skin
                % has other sub-regions then add 2 sub-regions to the
                % skins and assign 3 sub-regions to the spar. Indicate
                % that the first and last sub-region of the spar
                % overlay with the second to last sub-region of the
                % bottom and top skin respectively.
                topSkinRegionStructArray(i).subRegionArray =...
                    [topSkinRegionStructArray(i).subRegionArray,...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar-1)))];
                bottomSkinRegionStructArray(i).subRegionArray =...
                    [bottomSkinRegionStructArray(i).subRegionArray,...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar-1)))];
                if nastranSettingStruct.flangeSize>0
                    sparSubRegionArray{sparNo,i} = NastranRegion(struct(...
                        'overlayRegion',{bottomSkinRegionStructArray(...
                        i).subRegionArray(end-1),[],...
                        topSkinRegionStructArray(i).subRegionArray(...
                        end-1)}));
                end
            end
        elseif sparXLocation == topSkinXBoundaryVector(1) ||...
                sparXLocation == topSkinXBoundaryVector(2)
            % If the spar falls at one of the skin boundaries
            % distinguish whether the current laminate region of the
            % skin has already other sub-regions
            if ~isfield(topSkinRegionStructArray,'subRegionArray') ||...
                    isempty(topSkinRegionStructArray(i).subRegionArray)
                % If current current laminate region of the skin
                % does not have other sub-regions then assign 2
                % sub-regions to the skins and 2 sub-regions to the
                % spar. Indicate that the first and last sub-region of
                % the spar overlay with the first sub-region of the
                % bottom and top skin respectively.
                topSkinRegionStructArray(i).subRegionArray =...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar-1)));
                bottomSkinRegionStructArray(i).subRegionArray =...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar-1)));
                if nastranSettingStruct.flangeSize>0
                    sparSubRegionArray{sparNo,i} = NastranRegion(struct(...
                        'overlayRegion',{bottomSkinRegionStructArray(...
                        i).subRegionArray(1),[],...
                        topSkinRegionStructArray(i).subRegionArray(1)}));
                end
            else
                % If current current laminate region of the skin
                % has other sub-regions then add 1 sub-regions to the
                % skins and assign 3 sub-regions to the spar. Indicate
                % that the first and last sub-region of the spar
                % overlay with the last sub-region of the bottom and
                % top skin respectively.
                topSkinRegionStructArray(i).subRegionArray =...
                    [topSkinRegionStructArray(i).subRegionArray,...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar-2)))];
                bottomSkinRegionStructArray(i).subRegionArray =...
                    [bottomSkinRegionStructArray(i).subRegionArray,...
                    NastranRegion(struct('dummy',cell(1,...
                    nSubRegionsAcrossSpar-2)))];
                if nastranSettingStruct.flangeSize>0
                    sparSubRegionArray{sparNo,i} = NastranRegion(struct(...
                        'overlayRegion',{bottomSkinRegionStructArray(...
                        i).subRegionArray(end),[],...
                        topSkinRegionStructArray(i).subRegionArray(end)}));
                end
            end
        else
            % If spar falls out of the skin boundaries, then prompt an
            % error, because that means that there is no closed cross
            % section.
            error(['Spar falls out of the skin boundaries. ',...
                'Cross section is not closed.'])
        end
    end
end
% Assemble the region structure array for the spars
% Iterate through the number of spars
for i = size(materialPropertyArray,1):-1:1
    if any(cellfun(@length,sparSubRegionArray(i,:)))
        % If at least one laminate region of current spar has sub-regions,
        % then create structure array with subRegionArray field
        sparRegionStructArray(i,:) = struct(...
            'elementProperty',elementPropertyArray(i,:),...
            'materialPropertyArray',materialPropertyArray(i,:),...
            'subRegionArray',sparSubRegionArray(i,:));
    else
        % If no laminate region of current spar has sub-regions, then
        % create sutrcture array without subRegionArray field
        sparRegionStructArray(i,:) = struct(...
            'elementProperty',elementPropertyArray(i,:),...
            'materialPropertyArray',materialPropertyArray(i,:));
    end
end

%% Initialize Ribs
% Generate Laminate object using information from excel input file
ribLaminate = Laminate(nastranSettingStruct.ribsModelling);
% Generate Mat2 array with membrane and bending material property
materialPropertyArray =...
    abdMatrices2NastranMat2(ribLaminate.Ahat,ribLaminate.Dhat,...
    nastranSettingStruct.ribsModelling.rho,nastranSettingStruct);
% Generate Pshell object
elementPropertyArray = Pshell(struct(...
    'pid',nastranSettingStruct.lastPropertyId.addId,...
    'mid1',materialPropertyArray(1).Mid,...
    't',ribLaminate.TotalThickness,...
    'mid2',materialPropertyArray(2).Mid));
% Determine number of ribs
ribsIndex = strcmp('Ribs',proteusDataStruct.constant.lumped.type);
nRibs = length(proteusDataStruct.constant.lumped.mass{ribsIndex});
% Initialize the sub-region array for the ribs region (each rib constitutes
% a sub-region)
ribsSubRegionArray(1,nRibs) = NastranRegion;
% Create structure for the generation of the NastranRegion object
ribsRegionStructArray = struct(...
    'elementProperty',elementPropertyArray,...
    'materialPropertyArray',materialPropertyArray,...
    'subRegionArray',ribsSubRegionArray);

%% Generate NastranRegion objects
topSkinRegionArray = NastranRegion(topSkinRegionStructArray);
bottomSkinRegionArray = NastranRegion(bottomSkinRegionStructArray);
sparRegionArray = NastranRegion(sparRegionStructArray);
ribsRegionArray = NastranRegion(ribsRegionStructArray);

%% Generate NastranPart objects
topSkinPart = NastranPart(struct('name','Top Skin',...
    'regionArray',topSkinRegionArray));
bottomSkinPart = NastranPart(struct('name','Bottom Skin',...
    'regionArray',bottomSkinRegionArray));
% Iterate through number of spars
for i = size(sparRegionArray,1):-1:1
    sparPartArray(i) = NastranPart(struct('name',sprintf('Spar %d',i),...
        'regionArray',sparRegionArray(i,:)));
end
ribsPart = NastranPart(struct('name','Ribs',...
    'regionArray',ribsRegionArray));

%% Generate NastranBulkData object
initializedNastranBulkData = NastranBulkData(struct(...
    'partArray',[topSkinPart,bottomSkinPart,sparPartArray,ribsPart],...
    'lastGridId',nastranSettingStruct.lastGridId,...
    'lastElementId',nastranSettingStruct.lastElementId,...
    'lastPropertyId',nastranSettingStruct.lastPropertyId,...
    'lastMaterialId',nastranSettingStruct.lastMaterialId,...
    'lastSetId',nastranSettingStruct.lastSetId,...
    'lastCoordinateId',nastranSettingStruct.lastCoordinateId,...
    'lastTableId',nastranSettingStruct.lastTableId));
end

%% proteusLaminationParameters2NastraMat2 function
function mat2Array = proteusLaminationParameters2NastranMat2(...
    proteusDataStruct,nastranSettingStruct,laminateId)
%proteusLaminationParameters2NastranMat2 Generates the Mat2 objects
%corresponding to the lamination parameters of a Proteus' laminate.
%   mat2Array = proteusLaminationParameters2NastranMat2(...
%   proteusDataStruct,nastranSettingStruct,laminateId) generates an array
%   of two Mat2 objects representing the lamination parameters of a
%   laminate in Proteus. The id of the considered laminate is specified
%   with input argument laminateId.

% Retrieve lamination parameters
v1a = proteusDataStruct.designVector((laminateId-1)*9+1);
v2a = proteusDataStruct.designVector((laminateId-1)*9+2);
v3a = proteusDataStruct.designVector((laminateId-1)*9+3);
v4a = proteusDataStruct.designVector((laminateId-1)*9+4);
v1d = proteusDataStruct.designVector((laminateId-1)*9+5);
v2d = proteusDataStruct.designVector((laminateId-1)*9+6);
v3d = proteusDataStruct.designVector((laminateId-1)*9+7);
v4d = proteusDataStruct.designVector((laminateId-1)*9+8);

% Retrieve laminate thickness
% laminateThickness = proteusDataStruct.designVector(9*laminateId);

% Retrieve ply properties
el = proteusDataStruct.constant.mat.E11(...
    proteusDataStruct.constant.lam.matID(laminateId));
et = proteusDataStruct.constant.mat.E22(...
    proteusDataStruct.constant.lam.matID(laminateId));
nult = proteusDataStruct.constant.mat.nu12(...
    proteusDataStruct.constant.lam.matID(laminateId));
glt = proteusDataStruct.constant.mat.G12(...
    proteusDataStruct.constant.lam.matID(laminateId));
rho = proteusDataStruct.constant.mat.rho;

% Determine the reduced laminate stiffnesses
nu21 = nult/el*et;
denominator = 1/(1-nult*nu21);
q11 = el*denominator;
q22 = et*denominator;
q12 = nult*et*denominator;
q66 = glt;

% Determine the lamination invariants
u1 = (3*q11+3*q22+2*q12+4*q66)/8;
u2 = (q11-q22)/2;
u3 = (q11+q22-2*q12-4*q66)/8;
u4 = (q11+q22+6*q12-4*q66)/8;
u5 = (q11+q22-2*q12+4*q66)/8;

% Determine the stiffness invariants
c0 = [u1,u4,0;...
    u4,u1,0;...
    0,0,u5];
c1 = [u2,0,0;...
    0,-u2,0;...
    0,0,0];
c2 = [0,0,u2/2;...
    0,0,u2/2;...
    u2/2,u2/2,0];
c3 = [u3,-u3,0;...
    -u3,u3,0;...
    0,0,-u3];
c4 = [0,0,u3;...
    0,0,-u3;...
    u3,-u3,0];

% Determine normalized A and D matrices
a = (c0+v1a*c1+v2a*c2+v3a*c3+v4a*c4);
d = (c0+v1d*c1+v2d*c2+v3d*c3+v4d*c4);

% Generate the Mat2 array
mat2Array = abdMatrices2NastranMat2(a,d,rho,nastranSettingStruct);
end

function mat2Array = abdMatrices2NastranMat2(a,d,rho,nastranSettingStruct)
%abdMatrices2NastranMat2 Generates the Mat2 objects corresponding to the
%input ABD matrices.
%   mat2Array = abdMatrices2NastranMat2(a,d,rho,nastranSettingStruct)
%   generates an array of two Mat2 objects representing the input ABD
%   matrices and laminate density.

% Generate Mat2 objects for membrane and bending material properties
membraneMaterialProperty = Mat2(struct(...
    'mid',nastranSettingStruct.lastMaterialId.addId,...
    'gMatrix',a,...
    'rho',rho));
bendingMaterialProperty = Mat2(struct(...
    'mid',nastranSettingStruct.lastMaterialId.addId,...
    'gMatrix',d,...
    'rho',rho));

% Assemble output Mat2 array
mat2Array = [membraneMaterialProperty,bendingMaterialProperty];
end
