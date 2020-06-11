function proteusNonStructuralMasses2NastranConm2(nastranBulkData,...
    proteusDataStruct)
%proteusNonStructuralMasses2NastranConm2 Generates Conm2 objects from
%Proteus non-structural masses.
%   proteusNonStructuralMasses2NastranConm2(nastranBulkData,...
%   proteusDataStruct,nastranSettingStruct) generates a set of Conm2
%   objects based on the lumped masses present in Proteus design. The Conm2
%   objects are assigned to the input NastranBulkData object.

%% Find indexes of Proteus non structural masses and ribs
nonStructuralMassesIndexVector = find(~strcmp(...
    proteusDataStruct.constant.lumped.type,'Ribs'));
ribsIndex = find(strcmp(...
    proteusDataStruct.constant.lumped.type,'Ribs'));

%% Generate Grid objects related to the non structural masses
for i = length(nonStructuralMassesIndexVector):-1:1
    % Assemble input structure for Grid objects related to the current
    % non-structural mass
    massGridStruct(i).xyzVector =...
        proteusDataStruct.constant.lumped.location{...
        nonStructuralMassesIndexVector(i)};
    massGridStruct(i).id = nastranBulkData.LastGridId.addId;
end
massGridVector = Grid(massGridStruct');
% Add new grid objects to the general grid vector
nastranBulkData.GridArray = [nastranBulkData.GridArray;massGridVector];

%% Generate Conm2 and Rbe3 objects
for i=length(massGridVector):-1:1
    % Assemble input structure for Conm2 objects related to the current
    % non-structural mass
    conm2Struct(i).eid = nastranBulkData.LastElementId.addId;
    conm2Struct(i).grid = massGridVector(i);
    conm2Struct(i).m = proteusDataStruct.constant.lumped.mass{...
        nonStructuralMassesIndexVector(i)};
    % Find indexes of ribs surrounding current mass
    surroundingRibsIndexVector = [find(...
        proteusDataStruct.constant.lumped.location{ribsIndex}(:,2)<...
        proteusDataStruct.constant.lumped.location{...
        nonStructuralMassesIndexVector(i)}(:,2),1,'last'),...
        find(...
        proteusDataStruct.constant.lumped.location{ribsIndex}(:,2)>...
        proteusDataStruct.constant.lumped.location{...
        nonStructuralMassesIndexVector(i)}(:,2),1)];
    % Find boundary grid points of surrounding ribs
    rib1BoundaryGridVector = ...
        nastranBulkData.PartArray(end).RegionArray.SubRegionArray(...
        surroundingRibsIndexVector(1)).findBoundaryGridPoints;
    rib2BoundaryGridVector = ...
        nastranBulkData.PartArray(end).RegionArray.SubRegionArray(...
        surroundingRibsIndexVector(2)).findBoundaryGridPoints;
    boundaryGridVector = [rib1BoundaryGridVector;rib2BoundaryGridVector];
    % Assemble input structure for Rbe3 objects related to the current
    % non-structural mass
    rbe3Struct(i).eid = nastranBulkData.LastElementId.addId;
    rbe3Struct(i).referenceGrid = massGridVector(i);
    rbe3Struct(i).refc = 123456;
    rbe3Struct(i).wti = 1;
    rbe3Struct(i).ci = 123;
    rbe3Struct(i).masterGridVector = boundaryGridVector;
end
% Generate Conm2 object
nastranBulkData.Conm2Array = Conm2(conm2Struct);
% Generate Rbe3 object
rbe3Vector = Rbe3(rbe3Struct');
nastranBulkData.Rbe3Array = [nastranBulkData.Rbe3Array;rbe3Vector];
end
