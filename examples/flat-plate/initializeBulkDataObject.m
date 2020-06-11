function flatPlateBulkData =...
    initializeBulkDataObject(flatPlateSettingStruct)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Generate NastranRegion object
% Generate Mat1 object
materialProperty =...
    Mat1(struct('mid',flatPlateSettingStruct.lastMaterialId.addId,...
    'e',flatPlateSettingStruct.e,...
    'g',flatPlateSettingStruct.g,...
    'nu',flatPlateSettingStruct.nu,...
    'rho',flatPlateSettingStruct.rho));
% Generate Pshell object
elementProperty = Pshell(struct(...
    'pid',flatPlateSettingStruct.lastPropertyId.addId,...
    'mid1',materialProperty.Mid,...
    't',flatPlateSettingStruct.thickness,...
    'mid2',materialProperty.Mid,...
    'mid3',materialProperty.Mid));
% Generate input structure
flatPlateRegionStruct = struct(...
    'elementProperty',elementProperty,...
    'materialPropertyArray',materialProperty);
% Generate NastranRegion object
flatPlateRegion = NastranRegion(flatPlateRegionStruct);

%% Generate NastranPart object
flatPlatePart = NastranPart(struct('name','FlatPlate',...
    'regionArray',flatPlateRegion));

%% Generate NastranBulkData object
flatPlateBulkData = NastranBulkData(struct(...
    'partArray',flatPlatePart,...
    'lastGridId',flatPlateSettingStruct.lastGridId,...
    'lastElementId',flatPlateSettingStruct.lastElementId,...
    'lastPropertyId',flatPlateSettingStruct.lastPropertyId,...
    'lastMaterialId',flatPlateSettingStruct.lastMaterialId,...
    'lastSetId',flatPlateSettingStruct.lastSetId,...
    'lastCoordinateId',flatPlateSettingStruct.lastCoordinateId,...
    'lastTableId',flatPlateSettingStruct.lastTableId));
end