function [xyzQueryArray] = interp1XyzPoints(xyzArray,queryDirection,...
    queryDistanceVector,xyzFirstPoint)
%interp1XyzPoints Interpolation of points in 3D according to an initial
%succession of points, a query direction and a set of distances along that
%direction.

% Check number of input variables
if nargin < 4
    % If first point for the query is not given, then assume it as the
    % first of the input succession of points
    xyzFirstPoint = xyzArray(1,:);
end
% Check dimension of queryVector
if size(queryDistanceVector,2) > 1
    queryDistanceVector = queryDistanceVector';
end
% Coordinates array of the points along the query line
xyzQueryLineArray = repmat(xyzFirstPoint,length(queryDistanceVector),1) +...
    queryDistanceVector*(queryDirection/norm(queryDirection));
% Set current segment to the first segment defined by the set of initial
% points
currentSegment = 1;
% Itereate through the number of queried points
for i = 1:size(xyzQueryLineArray,1)
    % Look for the intersection between the plane defined by the
    % queried point and the query direction and one of the segments given
    % by the set of initial points
    % Initialize the product between the distances of the two points of the
    % segment and the plane
    distanceProduct = 1;
    % Iterate until the product between the distance is negative or until
    % the number of the current segment exceeds the total number of
    % segments
    while distanceProduct > eps && currentSegment < size(xyzArray,1)
%         if xyzArray(currentSegment,:) == xyzQueryLineArray(i,:)
            % If point on the query line is coincident with point on
            % current segment, then take the same point as queried point
        % Distance between first point of the current segment and the plane
        % related to the query point
        distanceP0Plane = dot(queryDirection,...
            xyzArray(currentSegment,:)-xyzQueryLineArray(i,:));
        % Distance between second point of the current segment and the
        % plane related to the query point
        distanceP1Plane= dot(queryDirection,...
            xyzArray(currentSegment+1,:)-xyzQueryLineArray(i,:));
        % Product between the two distances
        distanceProduct = distanceP0Plane*distanceP1Plane;
        % If product is zero or negative, there is an intersection
        if distanceProduct <= eps
            % Direction of the current segment
            segmentDirection =...
                (xyzArray(currentSegment+1,:)-xyzArray(currentSegment,:))/...
                norm(xyzArray(currentSegment+1,:)-...
                xyzArray(currentSegment,:));
            % Cosine of the angle between the plane normal and the segment
            % direction
            cosTheta = dot(queryDirection,segmentDirection);
            if abs(cosTheta) > eps
                % Calculate coordinates of the intersection point
                xyzQueryArray(i,:) = xyzArray(currentSegment+1,:) -...
                    segmentDirection*(distanceP1Plane/cosTheta);
            else
                % If cosine is zero, then the whole segment is
                % coincident with the plane
                warning(['Point no %d cannot be used for interpolation ',...
                    'because segment no %d lies completely on the plane ',...
                    'of interest'],i,currentSegment)
            end
        else
            % If the distance product is not negative, then switch to the
            % next segment
            currentSegment = currentSegment + 1;
        end
    end
end
% If the result variable has not been generated, return an empty array
if ~exist('xyzQueryArray','var')
    xyzQueryArray = [];
end
end
