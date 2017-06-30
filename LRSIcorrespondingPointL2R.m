function [LitpRC,RitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg] = LRSIcorrespondingPointL2R(LctrRC,Lxyz,Rxyz,LppXm,LppYm,CppZm,IPDm,bPLOT)
%
% function [LitpRC,RitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg] = LRSIcorrespondingPointL2R(LctrRC,Lxyz,Rxyz,LppXm,LppYm,CppZm,IPDm,bPLOT)
%
% Example call : [LitpRC,RitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg] = LRSIcorrespondingPointL2R(LctrRC,Lxyz,Rxyz,LppXm,LppYm,CppZm,IPDm,bPLOT);
%
% from point in LE image, finds corresponding point in RE image ...
% bad points are returned equal to RitpRC = LctrRC
%
% NOTE: all calculations are performed in left eye coordinate frame
%           Lxyz has coordinates assuming coord system center is LE
%           Rxyz has coordinates assuming coord system center is RE
%           Thus, at corresponding point Lxyz = Rxyz + [IPD 0 0];

% LctrRC:         coordinates of point in left eye for which to find right eye corresponding point
% Lxyz  :         cartesian coordinates of scene points in LE coord system
% Rxyz  :         cartesian coordinates of scene points in RE coord system
% LppXm :         projection plane pix x-locations      in LE coord system
% LppYm :         projection plane pix y-locations      in LE coord system
% CppZm :         projection plane distance in meters
% IPDm  :         interpupillary distance in meters
% bPLOT :         1 -> plot
%                 0 -> not
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LitpRC:        interpolated corresponding point row-column index in left      eye's image
% RitpRC:        interpoalted corresponding point row-column index in right     eye's image
% CitpRC:        interpolated corresponding point row-column index in cyclopean eye's image
% CsmpErrDeg:    vergence error of 'sampled' cyclopean 3D sampled point
%                   assessed by examining vergence demand differences
%                   between 'sampled' and 'interpolated' cyclopean points
%                   this error should not exceed the angular spacing of
%                   the samples in the projection plane
% DvrgDffDeg:    vergence difference between sampled LE and RE points
%
%                     *** see LRSIcorrespondingPointR2L.m ***

if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end
if mod(LctrRC(1),1) ~= 0 error(['LRSIcorrespondingPointL2R: WARNING! LctrRC(1) must be integer valued']); end
if mod(LctrRC(2),1) ~= 0
    if isequal(Lxyz(:,:,2:3),Rxyz(:,:,2:3)) && length(unique(Lxyz(:,:,3))) == 1 && length(unique(Rxyz(:,:,3))) == 1
        LitpRC = LctrRC; RitpRC = LctrRC; CitpRC = LctrRC;
        CsmpErrDeg = 0; DvrgDffDeg = 0;
        disp(['LRSIcorrespondingPointL2R: WARNING! non-integer valued LctrRC unhandled for range images that are not flat']);
        return
    else
        error(['LRSIcorrespondingPointL2R: WARNING! non-integer valued LctrRC unhandled for range images that are not flat']);
    end
end

% XYZ COORDINATES OF PROJ PLANE & LEFT/RIGHT/CYCLOPEAN EYE (in left eye coordinate frame)
LxyzEye     = [0       0 0];
CxyzEye     = [+IPDm/2 0 0];
RxyzEye     = [+IPDm   0 0];

% PROJECTION PLANE (FRONTO PARALLEL 3 METERS AWAY)
PrjPln  = createPlane([0 0 CppZm], [1 0 CppZm], [0 1 CppZm]);

% XYZ AT CENTER OF LE SAMPLED PATCH IN 3D
LxyzCtr    = squeeze(Lxyz(LctrRC(1),LctrRC(2),:))';

% EXIT IF CANDIDATE CORRESPONDING POINT IS A NaN
if sum(isnan(LxyzCtr)) > 0
    LitpRC = LctrRC; RitpRC = LctrRC; CitpRC = LctrRC;
    CsmpErrDeg = 100; DvrgDffDeg = 100;
   return
end
% VERGENCE ANGLE AT SAMPLED SCENE POINT
LvrgCtrDeg = vergenceFromRangeXYZ('L',IPDm,LxyzCtr);
% LE AND RE LINES OF SIGHT TO LEFT EYE POINT
L2LvctLOS = createLine3d(LxyzEye,LxyzCtr);
L2RvctLOS = createLine3d(RxyzEye,LxyzCtr);
% INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN L IMAGE
L2LxyzIPP = intersectLinePlane(L2LvctLOS,PrjPln); % must be    center of pixel location
L2RxyzIPP = intersectLinePlane(L2RvctLOS,PrjPln); % may not be center of pixel location
% 3D SAMPLED POINT IN RIGHT IMAGE NEAREST THE CORRESPONDING POINT (INDEX,ROW,COL)
RctrRC(1) = find( abs(L2RxyzIPP(2) - LppYm(:,1)) == min(abs(L2RxyzIPP(2) - LppYm(:,1))),1,'first');
RctrRC(2) = find( abs(L2RxyzIPP(1) - LppXm(1,:)) == min(abs(L2RxyzIPP(1) - LppXm(1,:))),1,'first');
% CORRESPONDING POINTS MUST HAVE SAME VERTICAL VALUE (i.e. THEY LIE IN AN EPIPOLAR PLANE)
if LctrRC(1) ~= RctrRC(1)
    disp(['LRSIcorrespondingPointL2R: WARNING! forcing vertical pixel row to be the same. L-R=' num2str(LctrRC(1)-RctrRC(1))]);
    RctrRC  = [LctrRC(1) RctrRC(2)];
end
% XYZ OF RE SAMPLED POINT NEAREST THE TRUE CORRESPONDING POINT IN PROJECTION PLANE (in left coordinate frame)
%     %%% may not be true corresponding point %%%
RxyzCtr = squeeze(Rxyz(RctrRC(1),RctrRC(2),:))' + RxyzEye; % + RxyzEye puts RxyzCtr in LE coordinate system
RvrgCtrDeg   = vergenceFromRangeXYZ('L',IPDm,reshape(RxyzCtr,[1 1 3]));
% LE AND RE LINES OF SIGHT TO RIGHT EYE POINT
% R2LvctLOS    = createLine3d(LxyzEye,RxyzCtr);
% R2RvctLOS    = createLine3d(RxyzEye,RxyzCtr);
% INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN R IMAGE
R2LxyzIPP    = intersectLinePlane(createLine3d(LxyzEye,RxyzCtr),PrjPln); % must be    center of pixel location
R2RxyzIPP    = intersectLinePlane(createLine3d(RxyzEye,RxyzCtr),PrjPln); % may not be center of pixel location
% SAMPLED 3D POINT NEAREST THE CORRESPONDING POINT IN 3D (may not correspond to 3D surface)
CxyzCtr      = intersectionPoint(LxyzEye,LxyzCtr,RxyzEye,RxyzCtr);      % 3D coordinates  of   sampled    point
CvrgCtrDeg   = vergenceFromRangeXYZ('L',IPDm,reshape(CxyzCtr,[1 1 3])); % vergence demand of   sampled    point
% INTERPOLATED 'TRUE' POINT (if LE and RE sample are on surface, ITP point should be very near to surface)
CxyzItp      = intersectionPoint(CxyzEye,CxyzCtr,LxyzCtr,RxyzCtr);      % 3D coordinates  of interpolated point
% ERROR CHECKING... INTERPOLATED POINT CANNOT BE NEARER/FARTHER THAN MIN/MAX DISTANCE
% if CxyzItp(1) < XminXmax(1) || CxyzItp(1) > XminXmax(2) || CxyzItp(3) < ZminZmax(1) || CxyzItp(3) > ZminZmax(2),
%     CxyzItp = RxyzCtr; disp(['LRSIcorrespondingPointL2R: WARNING! forcing CxyzItp = RxyzCtr']);
% end
%% VERGENCE ANGLE
CvrgItpDeg   = vergenceFromRangeXYZ('L',IPDm,reshape(CxyzItp,[1 1 3])); % vergence demand of interpolated point

% INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT FROM LE, RE, CE TO INTERPOLATED CYCLOPEAN POINT
C2LxyzIPP    = intersectLinePlane(createLine3d(LxyzEye,CxyzItp),PrjPln);
C2RxyzIPP    = intersectLinePlane(createLine3d(RxyzEye,CxyzItp),PrjPln);
C2CxyzIPP    = intersectLinePlane(createLine3d(CxyzEye,CxyzItp),PrjPln);
% LE AND RE IMAGE SHIFTS IN METERS FOR 'TRUE' INTERPOLATED (ITP) POINT TO NULL ERROR IN 3D SAMPLED POINT
LitpShftXm   = C2LxyzIPP(1) - L2LxyzIPP(1);
RitpShftXm   = C2RxyzIPP(1) - R2RxyzIPP(1);
CitpShftXm   = C2CxyzIPP(1) - L2LxyzIPP(1);
% LE AND RE IMAGE SHIFTS IN PIXELS FOR 'TRUE' INTERPOLATED (ITP) POINT TO NULL ERROR IN 3D SAMPLED POINT
pixPerMtr    = size(LppXm,2)./diff([LppXm(1) LppXm(end)]);
LitpShftXpix = LitpShftXm.*pixPerMtr;
RitpShftXpix = RitpShftXm.*pixPerMtr;
CitpShftXpix = CitpShftXm.*pixPerMtr;

% INTERPOLATED LOCATION OF CORRESPONDING POINT (IN PIXELS)
LitpRC    = LctrRC + [0 LitpShftXpix];
RitpRC    = RctrRC + [0 RitpShftXpix];
CitpRC    = LctrRC + [0 CitpShftXpix];

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXATION DISTANCE STATS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPARITY BETWEEN BEST 3D SAMPLED POINT AND BEST INTERPOLATED 3D POINT
CsmpErrDeg = ( CvrgItpDeg - CvrgCtrDeg );
% SAMPLED FIXATION DISTANCE (from cyclopean eye
CdstErrM   = norm(CxyzItp - CxyzEye);

%%%%%%%%%%%%%%%%%%%
% QUALITY CONTROL %
%%%%%%%%%%%%%%%%%%%
% VERGENCE DIFFERENCE BETWEEN NEAREST SAMPLED POINTS (SHOULD BE TINY)
DvrgDffDeg = LvrgCtrDeg - RvrgCtrDeg;

% PLOT
if bPLOT == 1
    %%
    figure(11111);
    set(gcf,'position',[120    15   615   627]); hold on
    % axis([max([abs(minmax([2*[-IPDm + IPDm] + minmax(LxyzCrp(:,:,1))]))  abs(minmax([0 + minmax(LxyzCrp(:,:,2))]))])*[-1 1 -1 1] minmax([0 minmax(LxyzCrp(:,:,3))])])
    % axis([-.1 .1 -.1 .1 0  10.5])

    plot3([0 IPDm],[0 0],[ 0 0],'ko')
    box on; grid on;
    formatFigure('X','Y');
    zlabel('Z');
    % LEFT IS RED, RIGHT IS BLUE
    plot3(LxyzCtr(1),LxyzCtr(2),LxyzCtr(3),'ro','markersize',12,'linewidth',2)
    plot3(RxyzCtr(1),RxyzCtr(2),RxyzCtr(3),'bo','markersize',12,'linewidth',2)
    plot3(CxyzCtr(1),CxyzCtr(2),CxyzCtr(3),'ko','markersize',12,'linewidth',2)
    plot3(CxyzItp(1),CxyzItp(2),CxyzItp(3),'mo','markersize',12,'linewidth',2)
    plot3(Lxyz(LctrRC(1)+[-5:5],LctrRC(2)+[-5:5],1),     Lxyz(LctrRC(1)+[-5:5],LctrRC(2)+[-5:5],2),Lxyz(LctrRC(1)+[-5:5],LctrRC(2)+[-5:5],3),'r.')
    plot3(Rxyz(RctrRC(1)+[-5:5],RctrRC(2)+[-5:5],1)+IPDm,Rxyz(RctrRC(1)+[-5:5],RctrRC(2)+[-5:5],2),Rxyz(RctrRC(1)+[-5:5],RctrRC(2)+[-5:5],3),'b.')

    drawLine3d(createLine3d(LxyzCtr,LxyzEye),'r')
    drawLine3d(createLine3d(LxyzCtr,RxyzEye),'r')
    drawLine3d(createLine3d(RxyzCtr,LxyzEye),'b')
    drawLine3d(createLine3d(RxyzCtr,RxyzEye),'b')
    drawLine3d(createLine3d(CxyzEye,CxyzCtr),'k')
    drawLine3d(createLine3d(LxyzCtr,RxyzCtr),'m')

    % PLOT INTERSECTION WITH PROJECTION PLANE
    plot3(  L2LxyzIPP(1),  L2LxyzIPP(2),  L2LxyzIPP(3),'ro','markersize',12,'linewidth',2)
    plot3(  L2RxyzIPP(1),  L2RxyzIPP(2),  L2RxyzIPP(3),'ro','markersize',12,'linewidth',2)
    plot3(C2LxyzIPP(1),C2LxyzIPP(2),C2LxyzIPP(3),'mo','markersize',12,'linewidth',2)
    plot3(C2RxyzIPP(1),C2RxyzIPP(2),C2RxyzIPP(3),'mo','markersize',12,'linewidth',2)
    drawLine3d(createLine3d(LxyzEye,CxyzItp),'m')
    drawLine3d(createLine3d(RxyzEye,CxyzItp),'m')

    % PROJECTION PLANE LINE AT EYE HEIGHT
    drawLine3d(createLine3d([-1 0 3],[1 0 3]),'k');
    % axis([0.0075 .0275 -.01 .01 3.44  3.5])
    set(gca,'ydir','reverse')
    view([0 0])
    killer = 1;
end
