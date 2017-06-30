%%
clear all
%%%%%%%%%%%%% 
% LOAD DATA %
%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
% LOAD TEST IMAGE %
%%%%%%%%%%%%%%%%%%%
load('LRSItestImg02.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD LRSI PROJECTION PLANE & DATA ACQUISITION INFO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[LppXm,LppYm]               = LRSIprojPlaneAnchorEye('L');
[RppXm,RppYm]               = LRSIprojPlaneAnchorEye('R');
[CppXm,CppYm,CppZm,~,~,IPDm]= LRSIprojPlaneAnchorEye('C');
IszRC                       = size(LppXm);
pixPerDeg                   = 52;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET SAMPLING PARAMETERS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NUMBER OF CORRESPONDING POINTS
nPts  =  100;
% RANDOMLY CHOOSE ANCHOR EYE: LE OR RE
LorR  = datasample(['L','R'],nPts)'; 
% PATCH SIZE IN DEG
nDeg = 3;
% PIX PER DEG
pixPerDeg = 52;
% PATCH SIZE IN PIX (R)OWS AND (C)OLUMNS
PszRC  = round(nDeg.*pixPerDeg.*ones(1,2));
% PATCH SIZE IN PIX IN X AND Y 
PszXY  = fliplr(PszRC);
% OBTAIN PATCH CENTER COORDINATES
PctrRC = floor(PszRC/2 + 1);
PctrXY = floor(PszXY/2 + 1);
% WINDOW FOR COMPUTING DISPARITY CONTRAST
W      = cosWindow(PszRC);
% SET MINIMUM DISTANCE IN PIXELS BETWEEN SAMPLED LOCATIONS
patchSpacing = 10; 
% EXCLUDE HALF-PATCH-WIDTH BORDER OF IMAGE
bBorderXY    = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANDOM SAMPLE PATCH LOCATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IctrRC       = sampleCandidatePatchCenters(IszRC,PszXY,patchSpacing,nPts,bBorderXY);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CORRESPONDING POINTS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WALL OR CROSS-EYED FUSION IF VISUALIZING
wallORcross = 'wall';
% GET CORRESPONDING POINTS
for k  = 1:nPts
    [LitpRC(k,:),RitpRC(k,:),CitpRC(k,:),LitpRCchk(k,:),RitpRCchk(k,:)] = LRSIcorrespondingPoint(LorR(k),IctrRC(k,:),Limg,Rimg,Lxyz,Rxyz,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,0,wallORcross);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR GOOD CORRESPONDING POINTS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAXIMUM VERGENCE DEMAND DIFFERENCE
vrgErrArcSecMax = 15; 
 
% VERGENCE ERROR FOR EACH CORRESPONDING POINT BY USING IMAGE-POINT LOCATIONS
[vrgErrArcSec,bIndGd] = LRSIcorrespondingPointVet(LitpRC,RitpRC,LitpRCchk,RitpRCchk,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,vrgErrArcSecMax);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT CORRESPONDING POINTS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotLRSIcorrespondingPoints(LitpRC,RitpRC,Limg,Rimg,Lrng,Rrng,bIndGd);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CROP PATCHES CENTERED ON CORRESPONDING POINTS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:size(LitpRC,1)
    % INTERPOLATE AND CROP PATCHES
    bPLOT = 0;
    [LimgCrp(:,:,i), RimgCrp(:,:,i), LxyzCrp(:,:,:,i), RxyzCrp(:,:,:,i)] = LRSIcropStereoPatch(LitpRC(i,:),RitpRC(i,:),Limg,Rimg,Lxyz,Rxyz,PszXY,bPLOT);
    
    % VERGENCE DEMAND IN ARCMIN
    [LvrgCrp(:,:,i)] = 60.*vergenceFromRangeXYZ('L',IPDm,LxyzCrp(:,:,:,i));
    [RvrgCrp(:,:,i)] = 60.*vergenceFromRangeXYZ('R',IPDm,RxyzCrp(:,:,:,i));
    
    % VERGENCE DEMAND IN ARCMIN OF CENTER PIXEL
    LvrgCtr(i,:)  = LvrgCrp(PctrRC(1),PctrRC(2),i);
    RvrgCtr(i,:)  = RvrgCrp(PctrRC(1),PctrRC(2),i);
    
    % GROUNDTRUTH DISPARITY MAPS
    Ldsp(:,:,i)    = LvrgCrp(:,:,i) - LvrgCtr(i,:);
    Rdsp(:,:,i)    = RvrgCrp(:,:,i) - RvrgCtr(i,:);
    
    % DISPARITY CONTRAST (COMPUTED FROM ANCHOR EYE)
    if     strcmp(LorR(i),'L')
    dspRms(i,1)    = rmsDeviation(Ldsp(:,:,i),W);
    elseif strcmp(LorR(i),'R')
	dspRms(i,1)    = rmsDeviation(Rdsp(:,:,i),W);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT CROPPED LUMINANCE AND DISPARITY PATCHES % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:nPts
    % PLOT LUMINANCE AND DISPARITY PATCHES
    plotLRSIimageANDdisparity(LimgCrp(:,:,i),RimgCrp(:,:,i),Ldsp(:,:,i),Rdsp(:,:,i),dspRms(i,1));
    pause(1);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD FIXATION DISPARITY TO EXAMPLE SURFACE POINT % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD TEST IMAGE
load('LRSItestImg02.mat');
wallORcross = 'wall';

% SAMPLED PIXEL LOCATION
IctrRC   = [805 1160];


% DISPARITY TO ADD TO TARGET
dspArcMin= -12;

% FIND CORRESPONDING POINT
bPLOT = 0;
[LitpRC,RitpRC]        = LRSIcorrespondingPoint('R',IctrRC,Limg,Rimg,Lxyz,Rxyz,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,bPLOT,wallORcross);

% ADD DISPARITY TO CORRESPONDING POINT
[LitpRCdsp, RitpRCdsp] = LRSIcorrespondingPointAddDisparity(LitpRC,RitpRC,dspArcMin,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm);

% CROP BINOCULAR PATCH FOR CROP LOCATION WITH ADDED DISPARITY
bPLOT = 0;
[LimgCrp, RimgCrp]     = LRSIcropStereoPatch(LitpRCdsp,RitpRCdsp,Limg,Rimg,Lxyz,Rxyz,PszXY,bPLOT);

% VISUALIZE BINOCULAR PATCH WITH ADDED DISPARITY
plotLRSIimageANDdisparity(LimgCrp,RimgCrp,[],[],[],['\delta =', num2str(dspArcMin), ' arcmin']);
