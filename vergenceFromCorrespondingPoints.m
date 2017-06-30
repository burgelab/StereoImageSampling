function vrgArcMin = vergenceFromCorrespondingPoints(LitpRC,RitpRC,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm)
% function vrgArcMin = vergenceFromCorrespondingPoints(LitpRC,RitpRC,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm)
%
% Computes vergence demand at the scene point from corresponding image-points
%
% LitpRC       :  LE corresponding point pixel co-ordinates
% RitpRC       :  RE corresponding point pixel co-ordinates
% dspArcMin    :  Disparity to add (in arcmin)
% LppXm        :  LE x position samples in metres
% LppYm        :  LE y position samples in metres
% RppXm        :  RE x position samples in metres
% RppYm        :  RE y position samples in metres
% CppZm        :  projection plane distance in metres
% IPDm         :  interpupillary distance in metres
% *********
% vrgArcMin    :  vergence demand in arcmin

%% TAKES RE AND LE IMAGE-CENTER PIXEL(R-C) CO-ORDINATES AND RETURNS THEIR X-Y CO-ORDINATES 
% READ OFF XY CO-ORDINATES OF LE AND RE IMAGE (IN THEIR RESPECTIVE CO-ORDINATE SYSTEMS)
% LE
LitpXYm(:,1) = interp1(1:size(LppXm,2),LppXm(1,:),LitpRC(:,2));
LitpXYm(:,2) = interp1(1:size(LppYm,1),LppYm(:,1),LitpRC(:,1));
% RE
RitpXYm(:,1) = interp1(1:size(RppXm,2),RppXm(1,:),RitpRC(:,2));
RitpXYm(:,2) = interp1(1:size(RppYm,1),RppYm(:,1),RitpRC(:,1));

%% TAKES LE AND RE IMAGE-PLANE CO-ORDINATES AND RETURNS CYCLOPEAN CO-ORDINATES IN 3-SPACE

% CONVERT ALL IMAGE CO-ORDINATES TO CE-CENTERED CO-ORDINATES SYSTEM (ASSUMING LE AND RE CO-ORDINATES ARE ANCHORED IN THEIR RESPECTIVE EYES)
L2CitpXYm = LitpXYm + [-(IPDm/2),0];
R2CitpXYm = RitpXYm + [+(IPDm/2),0];  

%% CYCLOPEAN CO-ORDINATES OF SCENE-POINT IN 3-SPACE (USING INTERSECTION POINT) 
tgtXYZm = intersectionPoint([ -(IPDm/2), 0 , 0 ],[ L2CitpXYm(1), L2CitpXYm(2), CppZm ],[ +(IPDm/2), 0 , 0 ],[ R2CitpXYm(1), R2CitpXYm(2), CppZm ]);
tgtXm = tgtXYZm(1);
tgtYm = tgtXYZm(2);
tgtZm = tgtXYZm(3);

%% VERGENCE DEMAND OF SCENE-POINT (IN EPIPOLAR PLANE)
vrgCPdeg   = acosd((tgtXm.^2 + tgtYm.^2 + tgtZm.^2 - (IPDm./2).^2)./((sqrt((tgtXm + (IPDm./2)).^2 + tgtYm.^2 + tgtZm.^2))*(sqrt((tgtXm - (IPDm./2)).^2 + tgtYm.^2 + tgtZm.^2))));

vrgArcMin = 60.*vrgCPdeg;
