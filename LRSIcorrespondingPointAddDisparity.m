function [LitpRCdsp, RitpRCdsp, bIndGdFXN] = LRSIcorrespondingPointAddDisparity(LitpRC,RitpRC,dspArcMin,LppXm,LppYm,RppXm,RppYm,IppZm,IPDm)

% function [LitpRCdsp, RitpRCdsp, bIndGdFXN] =  LRSIcorrespondingPointAddDisparity(LitpRC,RitpRC,dspArcMin,LppXm,LppYm,RppXm,RppYm,IppZm,IPDm)
%
% Takes corresponding LE and RE image co-ordinates and return image co-ordinates for a given disparity addition
%
% example call [LitpRCdsp, RitpRCdsp, bIndGdFXN] = LRSIcorrespondingPointAddDisparity([ 144, 1677.9 ],[ 144, 1711.1 ],-16.875,LppXm,LppYm,RppXm,RppYm,LRSIprojPlaneDist(),LRSIcameraIPD())
%              [LitpRCdsp, RitpRCdsp, bIndGdFXN] = LRSIcorrespondingPointAddDisparity([ 144, 1677.9 ],[ 144, 1711.1  ],+16.875,LppXm,LppYm,RppXm,RppYm,LRSIprojPlaneDist(),LRSIcameraIPD()) 
%
% LitpRC       :  LE corresponding point pixel co-ordinates
% RitpRC       :  RE corresponding point pixel co-ordinates
% dspArcMin    :  Disparity to add (in arcmin)
% LppXm        :  LE x position samples in metres
% LppYm        :  LE y position samples in metres
% RppXm        :  RE x position samples in metres
% RppYm        :  RE y position samples in metres
% IppZm        :  projection plane distance in metres
% IPDm         :  interpupillary distance in metres
% %%%%%%%%%%%%%%%%%%%%%
% LitpRCdsp    :    LE crop-location pixel co-ordinates w. desired disparity
% RitpRCdsp    :    RE crop-location pixel co-ordinates w. desired disparity
% bIndGdFXN    :    boolean indicating if the fixation point is ahead of the eyes
%                   1 : Fixation point is ahead of the eyes
%                   0 : Fixation point is behind the eyes

if abs(LitpRC(1)-RitpRC(1)) ~= 0 , error('LRSIcorrespondingPointAddDisparity: Warning! LE and RE images are at different elevations. Check corresponding point'); end

%% TAKES RE AND LE IMAGE-CENTER PIXEL(R-C) CO-ORDINATES AND RETURNS THEIR X-Y CO-ORDINATES 
% READ OFF XY CO-ORDINATES OF LE AND RE IMAGE (IN THEIR RESPECTIVE CO-ORDINATE SYSTEMS)
% LE
LitpXYm(:,1) = interp1(1:size(LppXm,2),LppXm(1,:),LitpRC(:,2));
LitpXYm(:,2) = interp1(1:size(LppYm,1),LppYm(:,1),LitpRC(:,1));
% RE
RitpXYm(:,1) = interp1(1:size(RppXm,2),RppXm(1,:),RitpRC(:,2));
RitpXYm(:,2) = interp1(1:size(RppYm,1),RppYm(:,1),RitpRC(:,1));

%% TAKES LE AND RE IMAGE-PLANE CO-ORDINATES AND RETURNS CYCLOPEAN CO-ORDINATES IN 3-SPACE

%if abs(LitpXYm(2)-RitpXYm(2)) ~= 0, error('LRSIcorrespondingPointAddDisparity: Warning! LE and RE images are at different elevations. Check corresponding point'); end

% CONVERT ALL IMAGE CO-ORDINATES TO CE-CENTERED CO-ORDINATES SYSTEM (ASSUMING LE AND RE CO-ORDINATES ARE ANCHORED IN THEIR RESPECTIVE EYES)
L2CitpXYm = LitpXYm + [-(IPDm/2),0];
R2CitpXYm = RitpXYm + [+(IPDm/2),0];  

% CYCLOPEAN CO-ORDINATES OF INITIAL TARGET POSITION IN 3-SPACE (USING INTERSECTION POINT) 
tgtXYZm = intersectionPoint([ -(IPDm/2), 0 , 0 ],[ L2CitpXYm(1), L2CitpXYm(2), IppZm ],[ +(IPDm/2), 0 , 0 ],[ R2CitpXYm(1), R2CitpXYm(2), IppZm ]);
tgtXm = tgtXYZm(1);
tgtYm = tgtXYZm(2);
tgtZm = tgtXYZm(3);

% CALCULATE ELEVATION ANGLE
elevDeg = atand(tgtYm/tgtZm);

%% REPORT IF INITIAL TARGET POSITION IS 'OUT-OF-RANGE'
bIndGdFXN = 1;  % SET bIndGdFXN = 1 BY DEFAULT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR CL BEYOND INFINITY %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dspArcMin > 0  % ONLY A POSSIBILITY FOR CROSSED DISPARITIES
   tgtDstMtr = sqrt(sum(tgtXYZm.^2));
   maxDstMtr = (IPDm./2)/(tand((dspArcMin./60)./2));
   % FLAG CASES WHERE FIXATION POINT IS BEHIND THE EYE
    if tgtDstMtr >= maxDstMtr
        bIndGdFXN = 0;
        % disp(['LRSIcorrespondingPointAddDisparity: Warning! Target distance = ', num2str(tgtDstMtr) ' m. For disparity ' num2str(dspArcMin) ' arcmin distance for parallel gaze is ' num2str(maxDstMtr) ' m. Fixation point will be behind the eyes' ]); 
    end
end

%% TAKES INITIAL TARGET POSITION, MOVES TO ADD REQUIRED VERGENCE DEMAND AND RETURNS CYCLOPEAN CO-ORDINATES OF LE AND RE IMAGES
% DISPARITY TO ADD IN DEGREE
dspDeg = dspArcMin/60;

% VERGENCE OF INITIAL TARGET POSITION (IN EPIPOLAR PLANE)
vrgCPdeg   = acosd((tgtXm.^2 + tgtYm.^2 + tgtZm.^2 - (IPDm./2).^2)./((sqrt((tgtXm + (IPDm./2)).^2 + tgtYm.^2 + tgtZm.^2))*(sqrt((tgtXm - (IPDm./2)).^2 + tgtYm.^2 + tgtZm.^2))));

% VERSION ANGLE OF INITIAL TARGET POSITION (IN EPIPOLAR PLANE)
vrsCPdeg = -sign(tgtXm)*acosd(sqrt((tgtYm.^2 + tgtZm.^2)./(tgtXm.^2 + tgtYm.^2 + tgtZm.^2)));

% TOLERANCE FOR CHECKING IF THE VERSION ANGLE  IS CLOSE TO ZERO
tolVrsDeg = 0.001; 
%tolVrgDeg = 18/60;  % 18 arcmin (LINES OF SIGHT FOR A VERGENCE DEMAND OF 18 ARCMIN WILL INTERSECT 12.4125 M AWAY. HENCE ASSUMED PARALLEL)
tolVrgDeg = 1/60;  % 22.5 arcmin (LINES OF SIGHT FOR A VERGENCE DEMAND OF 22.5 ARCMIN WILL INTERSECT 9.9302 M AWAY. HENCE ASSUMED PARALLEL)

% CYLOPEAN  XY CO-ORDINATES OF MOVED TARGET IMAGE (IN THE ORIGINAL SPACE)

if abs(vrgCPdeg - dspDeg) < tolVrgDeg                                                                 % DEALS WITH CASE OF PARALLEL GAZE 
    %[1 vrgCPdeg dspDeg]
    % IF GAZE IS PARALLEL, IMAGE PLANE CO-ORDINATES ARE OBTAINED WITHOUT SOLVING FOR THE NEW FIXATION-POINT CO-ORDINATES IN 3-SPACE
    
    LEclXYceMtr = [ -(IPDm./2) - (IppZm./cosd(elevDeg)).*tand(vrsCPdeg), L2CitpXYm(2)];
    REclXYceMtr = [ +(IPDm./2) - (IppZm./cosd(elevDeg)).*tand(vrsCPdeg), R2CitpXYm(2)];
else % DEALS WITH CASE WHERE FIXATION LOCATION IS AT FINITE RANGE
    %[2 vrgCPdeg dspDeg]
    if abs(vrsCPdeg)<tolVrsDeg % ZERO VERSION ANGLE IN EPIPOLAR PLANE
        XclTrnsMtr = 0;
        ZclTrnsMtr = (IPDm./2)./(tand((vrgCPdeg - dspDeg)./2));
    else          % NONZERO VERSION ANGLE IN EPIPOLAR PLANE
        %XclTrnsMtr = -(1./2).*(sind(2.*vrsCPdeg)).*(IPDm./2).*(cotd(vrgCPdeg - dspDeg)+sqrt((cotd(vrgCPdeg - dspDeg)).^2 + (secd(vrsCPdeg)).^2));
        
        if bIndGdFXN == 1       % TARGET AHEAD OF THE EYES IN THE EPIPOLAR PLANE
          ZclTrnsMtr = ((cosd(vrsCPdeg)).^2).*(IPDm./2)*( cotd(vrgCPdeg - dspDeg) + sqrt( (cotd(vrgCPdeg - dspDeg)).^2+(secd(vrsCPdeg)).^2 ) ); % POSITIVE ROOT IS CHOSEN OF THE QUADRATIC IN ZclTrnsMtr
 
        elseif bIndGdFXN == 0   % TARGET BEHIND THE EYES IN THE EPIPOLAR PLANE
          ZclTrnsMtr = ((cosd(vrsCPdeg)).^2).*(IPDm./2)*( cotd(vrgCPdeg - dspDeg) - sqrt( (cotd(vrgCPdeg - dspDeg)).^2+(secd(vrsCPdeg)).^2 ) ); % NEGATIVE ROOT IS CHOSEN OF THE QUADRATIC IN ZclTrnsMtr

        end
        
        XclTrnsMtr = -tand(vrsCPdeg).*ZclTrnsMtr;
    end
    % display('Moved fixation position in 3-space');
    % [XclTrnsMtr ZclTrnsMtr*sind(elevDeg)  ZclTrnsMtr*cosd(elevDeg) ]
    
    
      %IMAGE PLANE INTERSECTION XY CO-ORDINATES FOR TARGET IN FRONT
      LEclXYceMtr = [ -(IPDm./2) + (IppZm./(ZclTrnsMtr.*cosd(elevDeg))).*(XclTrnsMtr + (IPDm./2))  , L2CitpXYm(2)];
      REclXYceMtr = [ +(IPDm./2) + (IppZm./(ZclTrnsMtr.*cosd(elevDeg))).*(XclTrnsMtr - (IPDm./2))  , R2CitpXYm(2)];
    
end

%% TAKES CYCLOPEAN XY IMAGE CO-ORDINATES AND RETURNS LE AND RE IMAGE CO-ORDINATES FOR THE REQUIRED EYE
LppXYmCL = LEclXYceMtr + [+(IPDm/2),0];
RppXYmCL = REclXYceMtr + [-(IPDm/2),0];  

%% TAKES LE AND RE IMAGE PLANE CO-ORDINATES IN METERS AND RETURNS PIXEL CO-ORDINATES
LitpRCdsp(1,1) = interp1(LppYm(:,1),1:size(LppYm,1),LppXYmCL(2)); 
LitpRCdsp(1,2) = interp1(LppXm(1,:),1:size(LppXm,2),LppXYmCL(1));
RitpRCdsp(1,1) = interp1(RppYm(:,1),1:size(RppYm,1),RppXYmCL(2)); 
RitpRCdsp(1,2) = interp1(RppXm(1,:),1:size(RppXm,2),RppXYmCL(1));
