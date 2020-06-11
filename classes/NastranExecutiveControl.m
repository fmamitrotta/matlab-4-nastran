classdef NastranExecutiveControl < matlab.mixin.Copyable
    %NastranExecutiveControl Class for the management of a Nastran
    %executive control deck.
    %   Detailed explanation goes here
    
    %% Properties
    properties
        Sol     % Specifies the solution sequence or main subDMAP to be executed
    end
    
    
    methods
        %% Constructor
        function obj = NastranExecutiveControl(sol)
            %NastranExecutiveControl Construct an instance of this class
            %   Detailed explanation goes here
            obj.Sol = sol;
        end
        
        %% Write to .bdf file
        function write2Bdf(obj,fileID)
            %write2Bdf Write object to .bdf file.
            %   Detailed explanation goes here
            fprintf(fileID,'$ EXECUTIVE CONTROL DECK\n');
            fprintf(fileID,'SOL %d\n',obj.Sol);
            fprintf(fileID,'CEND\n\n');
        end
    end
end

