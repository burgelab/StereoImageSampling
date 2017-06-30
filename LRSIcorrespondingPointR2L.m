function [RitpRC,LitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg] = LRSIcorrespondingPointR2L(RctrRC,Rxyz,Lxyz,RppXm,RppYm,CppZm,IPDm,bPLOT)
%
% function [RitpRC,LitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg] = LRSIcorrespondingPointR2L(RctrRC,Rxyz,Lxyz,RppXm,RppYm,CppZm,IPDm,bPLOT)
%
% Example call : [RitpRC,LitpRC,CitpRC,CsmpErrDeg,DvrgDffDeg] = LRSIcorrespondingPointR2L(RctrRC,Rxyz,Lxyz,RppXm,RppYm,CppZm,IPDm,bPLOT);
%
% from point in left eye image finds corresponding point in right image ... 
%
% NOTE: all calculations are performed in right eye coordinate frame
%          input Rxyz has coordinates assuming coord system center is RE
%          input Lxyz has coordinates assuming coord system center is LE
%           Thus, at corresponding point Rxyz = Lxyz + [-IPD 0 0];
%
% RctrRC:        coordinates of point in right eye for which to find left eye corresponding point
% Lxyz  :        cartesian coordinates of scene points in LE coord system
% Rxyz  :        cartesian coordinates of scene points in RE coord system
% RppXm :        projection plane pix x-locations      in RE coord system
% RppYm :        projection plane pix y-locations      in RE coord system
% CppZm :         projection plane distance in meters
% IPDm  :         interpupillary distance in meters
% bPLOT :        1 -> plot 
%                0 -> not
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RitpRC:        interpolated corresponding point row-column index in right     eye's image
% LitpRC:        interpolated corresponding point row-column index in left      eye's image
% CitpRC:        interpolated corresponding point row-column index in cyclopean eye's image
% CsmpErrDeg:    vergence error of 'sampled' cyclopean 3D sampled point 
%                   assessed by examining vergence demand differences
%                   between 'sampled' and 'interpolated' cyclopean points 
%                   this error should not exceed the angular spacing of 
%                   the samples in the projection plane
% DvrgDffDeg:    vergence difference between sampled LE and RE points
% 
%                         *** see LRSIcorrespondingPointR2L.m ***

if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end
if mod(RctrRC(1),1) ~= 0 error(['LRSIcorrespondingPointR2L: WARNING! RctrRC(1) must be integer valued']); end
if mod(RctrRC(2),1) ~= 0
    if isequal(Rxyz(:,:,2:3),Lxyz(:,:,2:3)) && length(unique(Rxyz(:,:,3))) == 1 && length(unique(Lxyz(:,:,3))) == 1
        RitpRC = RctrRC; LitpRC = RctrRC; CitpRC = RctrRC; 
        CsmpErrDeg = 0; DvrgDffDeg = 0;
        return
    else 
        error(['LRSIcorrespondingPointR2L: WARNING! non-integer valued RctrRC unhandled for range images that are not flat']);
    end
end
% XYZ COORDINATES OF PROJ PLANE & LEFT/RIGHT/CYCLOPEAN EYE (in left eye coordinate frame)
LxyzEye     = [-IPDm   0 0];
CxyzEye     = [-IPDm/2 0 0];
RxyzEye     = [   0    0 0];


% PROJECTION PLANE (FRONTO PARALEL 3 METERS AWAY)
PrjPln  = createPlane([0 0 CppZm], [1 0 CppZm], [0 1 CppZm]);

% XYZ AT CENTER OF RE SAMPLED PATCH IN 3D
RxyzCtr    = squeeze(Rxyz(RctrRC(1),RctrRC(2),:))';

% EXIT IF CANDIDATE CORRESPONDING POINT IS A NaN
if sum(isnan(RxyzCtr)) > 0
   RitpRC = RctrRC; LitpRC = RctrRC; CitpRC = RctrRC;
   CsmpErrDeg = 100; DvrgDffDeg = 100;
   return
end

RvrgCtrDeg = vergenceFromRangeXYZ('R',IPDm,RxyzCtr);
% LE AND RE LINES OF SIGHT TO LEFT EYE POINT
R2RvctLOS = createLine3d(RxyzEye,RxyzCtr);
R2LvctLOS = createLine3d(LxyzEye,RxyzCtr); 
% INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN L IMAGE  
R2RxyzIPP = intersectLinePlane(R2RvctLOS,PrjPln); % must be    center of pixel location           
R2LxyzIPP = intersectLinePlane(R2LvctLOS,PrjPln); % may not be center of pixel location
% 3D SAMPLED POINT IN RIGHT IMAGE NEAREST THE CORESPONDING POINT (INDEX,ROW,COL)
LctrRC(1) = find( abs(R2LxyzIPP(2) - RppYm(:,1)) == min(abs(R2LxyzIPP(2) - RppYm(:,1))),1,'first');
LctrRC(2) = find( abs(R2LxyzIPP(1) - RppXm(1,:)) == min(abs(R2LxyzIPP(1) - RppXm(1,:))),1,'first');
% CORESPONDING POINTS MUST HAVE SAME VERTICAL VALUE (i.e. THEY LIE IN AN EPIPOLAR PLANE)
if RctrRC(1) ~= LctrRC(1)
    disp(['LRSIcorrespondingPointR2L: WARNING! forcing vertical pixel row to be the same. R-L=' num2str(RctrRC(1)-LctrRC(1))]);
    LctrRC  = [RctrRC(1) LctrRC(2)]; 
end
% XYZ OF RE SAMPLED POINT NEAREST THE TRUE CORESPONDING POINT IN PROJECTION PLANE (in left coordinate frame) 
%     %%% may not be true corresponding point %%%
LxyzCtr = squeeze(Lxyz(LctrRC(1),LctrRC(2),:))' + LxyzEye; % + LxyzEye puts LxyzCtr in LE coordinate system 
LvrgCtrDeg   = vergenceFromRangeXYZ('R',IPDm,LxyzCtr);
% LE AND RE LINES OF SIGHT TO RIGHT EYE POINT
% L2RvctLOS    = createLine3d(RxyzEye,LxyzCtr);
% L2LvctLOS    = createLine3d(LxyzEye,LxyzCtr); 
% INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN R IMAGE
L2RxyzIPP    = intersectLinePlane(createLine3d(RxyzEye,LxyzCtr),PrjPln); % must be    center of pixel location           
L2LxyzIPP    = intersectLinePlane(createLine3d(LxyzEye,LxyzCtr),PrjPln); % may not be center of pixel location
% SAMPLED 3D POINT NEAREST THE CORESPONDING POINT IN 3D (may not correspond to 3D surface)
CxyzCtr      = intersectionPoint(RxyzEye,RxyzCtr,LxyzEye,LxyzCtr);      % 3D coordinates  of   sampled    point
CvrgCtrDeg   = vergenceFromRangeXYZ('R',IPDm,CxyzCtr); % vergence demand of   sampled    point
% INTERPOLATED 'TRUE' POINT (if LE and RE sample are on surface, ITP point should be very near to surface) 
CxyzItp      = intersectionPoint(CxyzEye,CxyzCtr,RxyzCtr,LxyzCtr);      % 3D coordinates  of interpolated point
% ERROR CHECKING... INTERPOLATED POINT CANNOT BE NEARER/FARTHER THAN MIN/MAX DISTANCE     
% if CxyzItp(1) < XminXmax(1) || CxyzItp(1) > XminXmax(2) || CxyzItp(3) < ZminZmax(1) || CxyzItp(3) > ZminZmax(2), 
%     CxyzItp = LxyzCtr; disp(['LRSIcorrespondingPointR2L: WARNING! forcing CxyzItp = LxyzCtr']); 
% end
% VERGENCE ANGLE
CvrgItpDeg   = vergenceFromRangeXYZ('R',IPDm,CxyzItp); % vergence demand of interpolated point

% INTERSECTION OF PROJECTION PLANE (IPP) W. LINES OF SIGHT TO POINT IN LE IMAGE       
C2RxyzIPP    = intersectLinePlane(createLine3d(RxyzEye,CxyzItp),PrjPln);
C2LxyzIPP    = intersectLinePlane(createLine3d(LxyzEye,CxyzItp),PrjPln);
C2CxyzIPP    = intersectLinePlane(createLine3d(CxyzEye,CxyzItp),PrjPln);
% LE AND RE IMAGE SHIFTS IN METERS FOR 'TRUE' INTERPOLATED (ITP) POINT TO NULL EROR IN 3D SAMPLED POINT 
RitpShftXm   = C2RxyzIPP(1) - R2RxyzIPP(1);
LitpShftXm   = C2LxyzIPP(1) - L2LxyzIPP(1);
CitpShftXm   = C2CxyzIPP(1) - R2RxyzIPP(1);
% LE AND RE IMAGE SHIFTS IN PIXELS FOR 'TRUE' INTERPOLATED (ITP) POINT TO NULL EROR IN 3D SAMPLED POINT
pixPerMtr    = size(RppXm,2)./diff([RppXm(1) RppXm(end)]);
RitpShftXpix = RitpShftXm.*pixPerMtr;
LitpShftXpix = LitpShftXm.*pixPerMtr;
CitpShftXpix = CitpShftXm.*pixPerMtr;

% INTERPOLATED LOCATION OF CORRESPONDING POINT (IN PIXELS)
RitpRC    = RctrRC + [0 RitpShftXpix];
LitpRC    = LctrRC + [0 LitpShftXpix];
CitpRC    = RctrRC + [0 CitpShftXpix];

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXATION DISTANCE STATS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISPARITY BETWEEN BEST 3D SAMPLED POINT AND BEST INTERPOLATED 3D POINT
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

    plot3([LxyzEye(1) RxyzEye(1)],[LxyzEye(2) RxyzEye(2)],[LxyzEye(3) RxyzEye(3)],'ko')
    box on; grid on;
    formatFigure('X','Y');
    zlabel('Z');
    % LEFT IS RED, RIGHT IS BLUE
    plot3(LxyzCtr(1),LxyzCtr(2),LxyzCtr(3),'ro','markersize',12,'linewidth',2,'markersize',14)
    plot3(RxyzCtr(1),RxyzCtr(2),RxyzCtr(3),'bo','markersize',12,'linewidth',2,'markersize',14)
    plot3(CxyzCtr(1),CxyzCtr(2),CxyzCtr(3),'ko','markersize',12,'linewidth',2)
    plot3(CxyzItp(1),CxyzItp(2),CxyzItp(3),'mo','markersize',12,'linewidth',2)
    plot3(Rxyz(RctrRC(1)+[-5:5],RctrRC(2)+[-5:5],1)+RxyzEye(1),Rxyz(RctrRC(1)+[-5:5],RctrRC(2)+[-5:5],2),Rxyz(RctrRC(1)+[-5:5],RctrRC(2)+[-5:5],3),'b.')
    plot3(Lxyz(LctrRC(1)+[-5:5],LctrRC(2)+[-5:5],1)+LxyzEye(1),Lxyz(LctrRC(1)+[-5:5],LctrRC(2)+[-5:5],2),Lxyz(LctrRC(1)+[-5:5],LctrRC(2)+[-5:5],3),'r.')

    drawLine3d(createLine3d(LxyzCtr,RxyzEye),'r')
    drawLine3d(createLine3d(LxyzCtr,LxyzEye),'r')
    drawLine3d(createLine3d(RxyzCtr,RxyzEye),'b')
    drawLine3d(createLine3d(RxyzCtr,LxyzEye),'b')
    drawLine3d(createLine3d(CxyzEye,CxyzCtr),'k')
    drawLine3d(createLine3d(RxyzCtr,LxyzCtr),'m')

    % PLOT INTERSECTION WITH PROJECTION PLANE
    plot3(  R2RxyzIPP(1),  R2RxyzIPP(2),  R2RxyzIPP(3),'bo','markersize',12,'linewidth',2)
    plot3(  R2LxyzIPP(1),  R2LxyzIPP(2),  R2LxyzIPP(3),'bo','markersize',12,'linewidth',2)
    plot3(C2RxyzIPP(1),C2RxyzIPP(2),C2RxyzIPP(3),'mo','markersize',12,'linewidth',2)
    plot3(C2LxyzIPP(1),C2LxyzIPP(2),C2LxyzIPP(3),'mo','markersize',12,'linewidth',2)
    drawLine3d(createLine3d(RxyzEye,CxyzItp),'m')
    drawLine3d(createLine3d(LxyzEye,CxyzItp),'m')

    % PROJECTION PLANE LINE AT EYE HEIGHT
    drawLine3d(createLine3d([-1 0 3],[1 0 3]),'k');
    % axis([0.0075 .0275 -.01 .01 3.44  3.5])
    set(gca,'ydir','reverse')
    view([0 0])
    killer = 1;
end