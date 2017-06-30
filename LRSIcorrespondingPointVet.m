function [vrgDffArcSec,bIndGd] = LRSIcorrespondingPointVet(LitpRC,RitpRC,LitpRCchk,RitpRCchk,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,vrgDffArcSecMax)

% function [vrgDffArcSec,bIndGd] = LRSIcorrespondingPointVet(LitpRC,RitpRC,LitpRCchk,RitpRCchk,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,vrgDffArcSecMax)
%
%   example call:
%
% identifies good interpolated corresponding points by ensuring that the 
% vergence demand difference between scene points specified by LE and RE 
% corresponding points obtained with both eyes as anchor eyes
%
% LitpRC:          interpolated corresponding points' row-column indices in LE image     [k x 2]
% RitpRC:          interpolated corresponding points' row-column indices in RE image     [k x 2]
% LitpRCchk:       interpolated corresponding points' row-column indices in LE image     [k x 2]
%                  with other eye as anchor eye
% RitpRCchk:       interpolated corresponding points' row-column indices in RE image     [k x 2]
%                  with other eye as anchor eye
% LppXm:           projection plane pixel x-locations in LE coord system
% LppYm:           projection plane pixel y-locations in LE coord system
% RppXm:           projection plane pixel x-locations in RE coord system
% RppYm:           projection plane pixel y-locations in RE coord system
% CppZm:           projection plane distance in meters
% IPDm:            interpupillary distance in meters
% vrgDffArcSecMax: max acceptable vergence demand difference in arcsec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vrgDffArcSec:    vergence demand differences for all interpolated corresponding-points [k x 1]
% bIndGd:          indices of good and bad corresponding points 
%                  1 -> good
%                  0 -> bad
%
%                     *** see LRSIcorrespondingPoint.m ***

for k = 1:size(LitpRC,1)
    
    % OBTAIN VERGENCE DEMAND FOR ANCHOR EYE CORRESPONDING POINTS
    vrgArcMin(k,1) = vergenceFromCorrespondingPoints(LitpRC(k,:),RitpRC(k,:),LppXm,LppYm,RppXm,RppYm,CppZm,IPDm);
    
    % OBTAIN VERGENCE DEMAND FOR CHECK CORRESPONDING POINTS
    vrgArcMinChk(k,1) = vergenceFromCorrespondingPoints(LitpRCchk(k,:),RitpRCchk(k,:),LppXm,LppYm,RppXm,RppYm,CppZm,IPDm);
    
    % COMPUTE VERGENCE ERROR
    vrgDffArcSec(k,1) = 60.*abs(vrgArcMin(k,1) - vrgArcMinChk(k,1));
    
end

% INDICES OF GOOD POINTS
bIndGd = abs(vrgDffArcSec) < vrgDffArcSecMax;