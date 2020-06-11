function generateNastranLoadReferenceAxis(nastranBulkData,...
    proteusDataStruct)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Generate Grid objects related to reference point, leading and trailing edge
% Iterate through the number of ribs
for i=length(nastranBulkData.PartArray(end).RegionArray.SubRegionArray):...
        -1:1
    % Save Region object associated with current rib
    currentRibRegion =...
        nastranBulkData.PartArray(end).RegionArray.SubRegionArray(i);
    % Retrieve vector with boundary Grid objects of current rib
    boundaryGridVector{i} = currentRibRegion.findBoundaryGridPoints;
    % Retrieve centroid coordinates of current rib
    xyzRibCentroid = currentRibRegion.findCentroid;
    % Assemble input structure for Grid objects related to the reference
    % points of the load reference axis
    referenceGridStruct(i).xyzVector = xyzRibCentroid;
    referenceGridStruct(i).id = nastranBulkData.LastGridId.addId;
    % Assemble input structure for Grid objects related to the leading edge
    % points
    leadingEdgeGridStruct(i).xyzVector = interp1XyzPoints(...
        proteusDataStruct.constant.Coord3D.Wing_TE_xyz,[0,1,0],...
        xyzRibCentroid(2));
    leadingEdgeGridStruct(i).id = nastranBulkData.LastGridId.addId;
    % Assemble input structure for Grid objects related to the trailing
    % edge points
    trailingEdgeGridStruct(i).xyzVector = interp1XyzPoints(...
        proteusDataStruct.constant.Coord3D.Wing_LE_xyz,[0,1,0],...
        xyzRibCentroid(2));
    trailingEdgeGridStruct(i).id = nastranBulkData.LastGridId.addId;
end
% Generate objects
referenceGridVector = Grid(referenceGridStruct');
leadingEdgeGridVector = Grid(leadingEdgeGridStruct');
traililngEdgeGridVector = Grid(trailingEdgeGridStruct');

%% Generate RBE3 and RBE2 elements of load reference axis
for i=length(referenceGridVector):-1:1
    % Assemble input structure for Rbe3 objects related to the connection
    % of the reference points to the ribs contour
    rbe3Struct(i).eid = nastranBulkData.LastElementId.addId;
    rbe3Struct(i).referenceGrid = referenceGridVector(i);
    rbe3Struct(i).refc = 123456;
    rbe3Struct(i).wti = 1;
    rbe3Struct(i).ci = 123;
    rbe3Struct(i).masterGridVector = boundaryGridVector{i};
    % Assemble input structure for Rbe2 objects related to the connection
    % of the reference points to the leading and trailing edge points
    rbe2Struct(i).eid = nastranBulkData.LastElementId.addId;
    rbe2Struct(i).independentGrid = referenceGridVector(i);
    rbe2Struct(i).cm = 123456;
    rbe2Struct(i).dependentGridVector = [leadingEdgeGridVector(i),...
        traililngEdgeGridVector(i)];
end
% Generate objects
rbe3Vector = Rbe3(rbe3Struct');
rbe2Vector = Rbe2(rbe2Struct');

%% Generate Set1 object to group the structural points to be splined
set1 = Set1(struct('sid',nastranBulkData.LastSetId.addId,...
    'gridVector',[referenceGridVector;leadingEdgeGridVector;...
    traililngEdgeGridVector]));

%% Assign generated objects to NastranBulkData object
nastranBulkData.GridArray = [nastranBulkData.GridArray;referenceGridVector;...
    leadingEdgeGridVector;traililngEdgeGridVector];
nastranBulkData.Rbe2Array = [nastranBulkData.Rbe2Array;rbe2Vector];
nastranBulkData.Rbe3Array = [nastranBulkData.Rbe3Array;rbe3Vector];
nastranBulkData.Set1Array = [nastranBulkData.Set1Array;set1];
end
