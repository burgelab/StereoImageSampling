function [vrgErrArcSec,bIndGd] = LRSIcorrespondingPointVet_old(LitpRC,RitpRC,Lxyz,Rxyz,IPDm,vrgErrArcSecMax)
%
% function [vrgErrArcSec,bIndGd] = LRSIcorrespondingPointVet_old(LitpRC,RitpRC,Lxyz,Rxyz,IPDm,vrgErrArcSecMax)
%
% Example call : [vrgErrArcSec,bIndGd] = LRSIcorrespondingPointVet_old(LitpRC,RitpRC,Lxyz,Rxyz,IPDm,10)
%
% Identifies sampled corresponding points whose vergence error (difference in vergence demand between sampled left- and right-eye scene-points) exceeds a specified value
%
% LitpRC         :  interpolated corresponding points' row-column indices in left      eye's image [k x 2]
% RitpRC         :  interpoalted corresponding points' row-column indices in right     eye's image [k x 2]
% Lxyz           :  cartesian coordinates of scene points in LE coord system [N M 3] i.e. 3 maps each for x,y and z coordinates
% Lxyz           :  cartesian coordinates of scene points in RE coord system [N M 3] i.e. 3 maps each for x,y and z coordinates
% IPDm           :  inter-pupillary distance in meters
% vrgErrArcSecMax:  vergence error limit in arcsec
%%%%%%%%%%%%%%%%%%%%%%
% vrgErrArcSec   : measured vergence errors for all the interpolated corresponding-point pairs [k x 1]
% bIndGd         : boolean that is 1 for good corresponding points (with vergence errors within the limit ) and 0 for bad


% CHOOSE A SIZE FOR OBTAINING INTERPOLATED RANGE DATA CENTERED ON SAMPLED POINTS
crpSzXY    = [53 53];

% OBTAIN ROW AND COLUMN INDICES FOR CROPPED PATCH CENTER
crpSzRC    = fliplr(crpSzXY);
crpCtrRC   = floor(crpSzRC/2 + 1);
interpType = 'linear';
bPLOT      = 0;

% COMPUTE VERGENCE ERROR FOR EACH PAIR OF SAMPLED POINTS
for k = 1:size(LitpRC,1)
    
    % OBTAIN INTERPOLATED RANGE DATA CENTERED ON SAMPLED LOCATIONS
    LxyzCrpIntp(:,:,:,k) = cropImageCtrInterp(Lxyz,LitpRC(k,:),crpSzXY,interpType,bPLOT);
    RxyzCrpIntp(:,:,:,k) = cropImageCtrInterp(Rxyz,RitpRC(k,:),crpSzXY,interpType,bPLOT);
    
    % OBTAIN EACH EYE'S VERGENCE DEMAND IN ARCMIN IN THE INTERPOLATED REGION
    LvrgArcMinCrpIntp(:,:,k) = 60.*vergenceFromRangeXYZ('L',IPDm,LxyzCrpIntp(:,:,:,k));
    RvrgArcMinCrpIntp(:,:,k) = 60.*vergenceFromRangeXYZ('R',IPDm,RxyzCrpIntp(:,:,:,k));
    
    % OBTAIN EACH EYE'S VERGENCE DEMAND IN ARCMIN IN THE SAMPLED LOCATION
    LvrgArcMinCtr(k,1) =  LvrgArcMinCrpIntp(crpCtrRC(1),crpCtrRC(2),k);
    RvrgArcMinCtr(k,1) =  RvrgArcMinCrpIntp(crpCtrRC(1),crpCtrRC(2),k);
    
    % VERGENCE ERROR BETWEEN LE AND RE SCENE POINTS
    vrgErrArcSec(k,1) = abs((LvrgArcMinCtr(k,1) -RvrgArcMinCtr(k,1)))*60;
end

bIndGd = abs(vrgErrArcSec) < vrgErrArcSecMax;