function applyProteusRootClamp(nastranBulkData)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Generate Grid object corresponding to the constraint application point
% (origin)
clampGridPoint = Grid(struct('xyzVector',[0,0,0],...
    'id',nastranBulkData.LastGridId.addId));
% Save Region object associated with root rib
rootRibRegion =...
    nastranBulkData.PartArray(end).RegionArray.SubRegionArray(1);
% Get the id vector of the nodes belonging to the boundary of rib region
dependentGridVector = rootRibRegion.findBoundaryGridPoints;
% Connect constraint application node to the first rib
rbe2 = Rbe2(struct('eid',nastranBulkData.LastElementId.addId,...
    'independentGrid',clampGridPoint,...
    'cm',123456,...
    'dependentGridVector',dependentGridVector));
% Generate Spc1 objcet
spc1 = Spc1(struct('sid',nastranBulkData.LastSetId.addId,...
    'c',123456,...
    'gridVector',clampGridPoint));

%% Assign generated objects to NastranBulkData object
nastranBulkData.GridArray = [nastranBulkData.GridArray;clampGridPoint];
nastranBulkData.Rbe2Array = [nastranBulkData.Rbe2Array;rbe2];
nastranBulkData.Spc1Array = [nastranBulkData.Spc1Array;spc1];
end
