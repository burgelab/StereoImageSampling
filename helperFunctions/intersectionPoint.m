function [A0,B0,A0B0dist,A0B0mean] = intersectionPoint(A1,A2,B1,B2)

% function [A0,B0,A0B0dist,A0B0mean] = intersectionPoint(A1,A2,B1,B2)
%
%   example call: [A0,B0,A0B0dist,A0B0mean] = intersectionPoint([0 0 0],[0 0 1],[0.065 0 0],[-.05 0 1])
%
% find intersection point of two lines, each defined by two points...
% returns if lines do not intersect
%
% A1:       point 1 from line A     [n x 3] or [r x c x 3]
% A2:       point 2 from line A     [n x 3] or [r x c x 3]
% B1:       point 1 from line B     [n x 3] or [r x c x 3]
% B2:       point 2 from line B     [n x 3] or [r x c x 3]
% %%%%%%%%%%%%%%%%%%%%%%%
% A0:       nearest point to B on A 
% B0:       nearest point to A on B 
% A0B0dist: distance between nearest points... distance will be near zero 
%           (i.e. within machine precision) when lines intersect
% A0B0mean: point minimizing distance between two lines

% MAKE SURE POINTS LIVE IN 3-SPACE
% if length(size(A1)) == 3, A1 = reshape(A1,[],3)'; end
% if length(size(A2)) == 3, A2 = reshape(A2,[],3)'; end
% if length(size(B1)) == 3, B1 = reshape(B1,[],3)'; end
% if length(size(B2)) == 3, B2 = reshape(B2,[],3)'; end
% if prod(size(A1)~=size(A2))==0, A1 = repmat(A1,[1 size(A2,2) ]); end
% if prod(size(B1)~=size(B2))==0, B1 = repmat(B1,[1 size(B2,2) ]); end

% COMPUTE INTERSECTION POINT (IF IT EXISTS)
nA = dot(cross(B2-B1,A1-B1),cross(A2-A1,B2-B1));
nB = dot(cross(A2-A1,A1-B1),cross(A2-A1,B2-B1));
d  = dot(cross(A2-A1,B2-B1),cross(A2-A1,B2-B1));
A0 = A1 + (nA/d)*(A2-A1); % nearest point on A to B
B0 = B1 + (nB/d)*(B2-B1); % nearest point on B to A

% COMPUTE DISTANCE BETWEEN LINE A & B NEAREST POINTS
A0B0dist = sqrt(sum(A0 - B0).^2);

% INTERSECTION POINT (OR POINT MINIMIZING DISTANCE IF THEY DON'T)
A0B0mean = mean(cat(3,A0,B0),3);
% PRINT WARNING IF NO INTERSECTION
if roundDec(A0B0dist,1e-8) ~= 0
     disp(['intersectionPoint: WARNING! lines A and B do not intersect. Distance between lines is : ' num2str(A0B0dist,3)]);
end