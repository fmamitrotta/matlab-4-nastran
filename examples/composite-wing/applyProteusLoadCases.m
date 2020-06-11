function staticAeroelasticSubcaseVector = applyProteusLoadCases(...
    nastranBulkData,proteusDataStruct)
%applyProteusLoadCases Applies the load cases of Proteus model to the
%Nastran model.
%   staticAeroelasticSubcaseVector = applyProteusLoadCases(...
%   nastranBulkData,proteusDataStruct) retrieves the load cases parameters
%   of the input Proteus model and uses those to generate an array of Trim
%   objects and an array of NastranSubcase objects.
% Find density of air at altitude prescribed in Proteus
[~,~,~,rhoVector] = atmosisa(proteusDataStruct.loadcase.H);
% Generate Aestat object for angle of attack
alphaAestat = Aestat(struct('id',nastranBulkData.LastGridId.addId,...
    'label','ANGLEA'));
% Input variables for generation of load cases
machVector = proteusDataStruct.loadcase.M;
dynamicPressureVector = 0.5*rhoVector'.*proteusDataStruct.loadcase.EAS.^2;
independentAestatArray = repmat({alphaAestat},length(machVector),1);
trimmingConstraintArray = num2cell(deg2rad(...
    proteusDataStruct.loadcase.alpha0));
% Generate aeroelastic load cases for the NastranBulkData object
staticAeroelasticSubcaseVector =...
    nastranBulkData.generateStaticAeroelasticLoadCases(machVector,...
    dynamicPressureVector,independentAestatArray,trimmingConstraintArray);
end
