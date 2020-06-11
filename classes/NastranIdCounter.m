classdef NastranIdCounter < matlab.mixin.Copyable
    %NastranIdCounter Class for the management of the numeration of the
    %various id types of a Nastran model.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        IdNo = 0;   % default first id is 0
    end
    
    methods
        %% Constructor
        function obj = NastranIdCounter(firstId)
            %NastranIdCounter Construct an instance of this class
            %   Default first id is 0, unless the constructor is provided
            %   with an input specifiying the number of the first id.
            if nargin ~= 0
                obj.IdNo = firstId;
            end
        end
        
        %% Add Id
        function newIdNo = addId(obj,idsQuantity)
            %AddId Increase the value of the current id.
            %   newIdNo = AddId(obj,idsQuantity) increases the value of the
            %   IdNo property by the value specified by idsQuantity. If
            %   nothing is specified, the default increase is 1. The method
            %   returns the new value of the id.
            if nargin == 1
                idsQuantity = 1;
            end
            obj.IdNo = obj.IdNo+idsQuantity;
            newIdNo = obj.IdNo;
        end
    end
end

