function [vrgErrArcSec,bIndGd] = LRSIcorrespondingPointVet(LitpRC,RitpRC,LitpRCchk,RitpRCchk,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,vrgErrArcSecMax)
% function [vrgErrArcSec,bIndGd] = LRSIcorrespondingPointVet(LitpRC,RitpRC,LitpRCchk,RitpRCchk,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,vrgErrArcSecMax)
%
% Identifies sampled corresponding points whose vergence error (difference in vergence demand between sampled left- and right-eye scene-points) exceeds a specified value
%
% LitpRC         :  interpolated corresponding points' row-column indices in left      eye's image [k x 2]
% RitpRC         :  interpoalted corresponding points' row-column indices in right     eye's image [k x 2]
% LitpRCchk      :  LE row column index of interpolated patch w. other eye as anchor
% RitpRCchk      :  RE row column index of interpolated patch w. other eye as anchor
% LppXm:            projection plane pix x-locations      in LE coord system
% LppYm:            projection plane pix y-locations      in LE coord system
% RppXm:            projection plane pix x-locations      in RE coord system
% RppYm:            projection plane pix y-locations      in RE coord system
% CppZm:            projection plane distance in meters
% IPDm:             interpupillary distance in meters
% vrgErrArcSecMax:  vergence error limit in arcsec
%%%%%%%%%%%%%%%%%%%%%%
% vrgErrArcSec   : measured vergence errors for all the interpolated corresponding-point pairs [k x 1]
% bIndGd         : boolean that is 1 for good corresponding points (with vergence errors within the limit ) and 0 for bad

for k = 1:size(LitpRC,1)
    
    % OBTAIN VERGENCE DEMAND FOR ANCHOR EYE CORRESPONDING POINTS
    vrgArcminAnc(k,1) = vergenceFromCorrespondingPoints(LitpRC(k,:),RitpRC(k,:),LppXm,LppYm,RppXm,RppYm,CppZm,IPDm);
    
    % OBTAIN VERGENCE DEMAND FOR CHECK CORRESPONDING POINTS
    vrgArcminChk(k,1) = vergenceFromCorrespondingPoints(LitpRCchk(k,:),RitpRCchk(k,:),LppXm,LppYm,RppXm,RppYm,CppZm,IPDm);
    
    % COMPUTE VERGENCE ERROR
    vrgErrArcSec(k,1) = abs(vrgArcminAnc(k,1) - vrgArcminChk(k,1))*60;
    
end

bIndGd = abs(vrgErrArcSec) < vrgErrArcSecMax;