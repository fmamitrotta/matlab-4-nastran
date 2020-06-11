function [timeVector,gustVelocityVector,gustDelay,solutionPeriod] =...
    generateNastranGustSignal(referenceVelocity,gustFrequency,gustType)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
switch gustType
    case 1  % 1-cosine
        gustHalfLength = referenceVelocity/(2*gustFrequency);
        gustDelay = 0.2;    % [s]
        timeVector = linspace(0,2*gustHalfLength/referenceVelocity);
        gustVelocityVector = 1/2*(1-cos(pi*timeVector*referenceVelocity/...
            gustHalfLength));
        % Mirror gust for Nastran Fourier analysis
        gustVelocityVector = [zeros(1,length(gustVelocityVector)/2),...
            gustVelocityVector,...
            zeros(1,length(gustVelocityVector)),...
            -2*gustVelocityVector,...
            zeros(1,length(gustVelocityVector)),...
            gustVelocityVector,...
            zeros(1,length(gustVelocityVector)/2)];
        timeVector = linspace(0,2*gustHalfLength/referenceVelocity*6,...
            length(gustVelocityVector));
        solutionPeriod = timeVector(end)*2;
    case 2  % sine
        gustDelay = 0;    % [s]
        timeVector = linspace(0,1/gustFrequency);
        gustVelocityVector = sin(2*pi*gustFrequency*timeVector);
        solutionPeriod = timeVector(end);
    otherwise
        error('Wrong gust type. Choose between 1 and 2.')
end
end
