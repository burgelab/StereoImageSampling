function thetaDeg = lawofcosinesSSSd(a,b,c)

% function c = lawofcosinesSSSd(a,b,c)
%
%   example call: lawofcosinesSSSd(3,4,5)
%
% law of cosines: (S)ide (S)ide (S)ide... returns angle in degrees 
%                 between sides 1 and 2 from lengths of all three sides
%
% a:        length of side 1
% b:        length of side 2
% c:        length of side 3
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% thetaDeg: angle between side 1 and 2 (in degrees) 

thetaDeg = acos( (a.^2 + b.^2 - c.^2)./(2.*a.*b)).*180./pi;
