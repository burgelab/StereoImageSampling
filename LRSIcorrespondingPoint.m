function [LitpRC,RitpRC,CitpRC,LitpRCchk,RitpRCchk] =  LRSIcorrespondingPoint(LorR,IctrRC,Lpht,Rpht,Lxyz,Rxyz,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,bPLOT,wallORcross)

% function [LitpRC,RitpRC,CitpRC,LitpRCchk,RitpRCchk] =  LRSIcorrespondingPoint(LorR,IctrRC,Lpht,Rpht,Lxyz,Rxyz,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,bPLOT,wallORcross)
%
%   example call: load('LRSItestImg02.mat'); load('LRSIprojPlaneData.mat'); 
%                 [LitpRC,RitpRC] = LRSIcorrespondingPoint('R',[805 1160],Limg,Rimg,Lxyz,Rxyz,LppXm,LppYm,RppXm,RppYm,CppZm,IPDm,bPLOT,wallORcross);
%
% interpolate corresponding points in LE and RE images given 
% a candidate sample point in the anchor eye image
%
% LorR:             anchor eye (i.e. image the interpolation procedure is initiated from)
%                   'L' -> left  eye is anchor eye
%                   'R' -> right eye is anchor eye
% IctrRC:           left image patch center ( row, col )  [ 1 x 2 ]
% Lxyz:             cartesian coordinates of scene points in LE coord system
% Rxyz:             cartesian coordinates of scene points in RE coord system
% LppXm:            projection plane pixel x-locations    in LE coord system
% LppYm:            projection plane pixel y-locations    in LE coord system
% RppXm:            projection plane pixel x-locations    in RE coord system
% RppYm:            projection plane pixel y-locations    in RE coord system
% CppZm:            projection plane distance in meters
% IPDm:             interpupillary distance in meters       
% bPLOT:            plot or not 
%                   1 -> plot
%                   0 -> not
% wallORcross:      plot stereo image for wall- or cross-fusing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LitpRC:       interpolated corresponding points' row-column indices in LE image     [k x 2]
% RitpRC:       interpolated corresponding points' row-column indices in RE image     [k x 2]
% CitpRC:        interpolated corresponding point row-column index in cyclopean eye's image
% LitpRCchk:     LE row column index of interpolated patch w. other eye as anchor
% RitpRCchk:     RE row column index of interpolated patch w. other eye as anchor

if ~exist('bPLOT','var')       || isempty(bPLOT)       bPLOT       = 0;      end
if ~exist('wallORcross','var') || isempty(wallORcross) wallORcross = 'wall'; end


%% OBTAIN CORRESPONDING POINT
if     strcmp(LorR,'L')
        % FROM LE POINT GET CORRESPONDING BEST SAMPLED RE POINT AND INTERPOLATION TO REDUCE SAMPLING ERROR
        [LitpRC,   RitpRC, CitpRC] = LRSIcorrespondingPointL2R(      IctrRC, Lxyz,Rxyz,LppXm,LppYm,CppZm,IPDm,0); % row/col
        try 
        [RitpRCchk,LitpRCchk ] = LRSIcorrespondingPointR2L(round(RitpRC),Rxyz,Lxyz,RppXm,RppYm,CppZm,IPDm,0);
        catch 
        LitpRCchk = [NaN NaN]; 
        RitpRCchk = [NaN NaN];
        end
    elseif strcmp(LorR,'R')
        % FROM RE POINT GET CORRESPONDING BEST SAMPLED LE POINT AND INTERPOLATION TO REDUCE SAMPLING ERROR
        [RitpRC,   LitpRC, CitpRC] = LRSIcorrespondingPointR2L(      IctrRC, Rxyz,Lxyz,RppXm,RppYm,CppZm,IPDm,0); % row/col
        try 
        [LitpRCchk,RitpRCchk ] = LRSIcorrespondingPointL2R(round(LitpRC),Lxyz,Rxyz,LppXm,LppYm,CppZm,IPDm,0);
        catch
        LitpRCchk = [NaN NaN]; 
        RitpRCchk = [NaN NaN];
        end
    else error(['LRSIcorrespondingPoint: WARNING! unhandled LorR value: ' LorR]);
end

%% PLOT CORRESPONDING POINT FOR WALL OR CROSS VIEWING
if bPLOT
    if exist('Lpht','var') && exist('Rpht','var')
        figure('position',[85 361 1052 445])
        if strcmp(wallORcross,'wall')
            imagesc([Lpht,Rpht].^.4); axis image; colormap gray; hold on;
            plot(LitpRC(:,2)             ,LitpRC(:,1),'y.','linewidth',2);
            plot(RitpRC(:,2)+size(Lpht,2),RitpRC(:,1),'y.','linewidth',2); 
        elseif strcmp(wallORcross,'cross')
            imagesc([Rpht,Lpht].^.4); axis image; colormap gray; hold on;
            plot(RitpRC(:,2)             ,RitpRC(:,1),'y.','linewidth',2);
            plot(LitpRC(:,2)+size(Lpht,2),LitpRC(:,1),'y.','linewidth',2); 
        end
        formatFigure([],[],[wallORcross '-eyed fusion']);
        axis off;
    else
        disp(['LRSIcorrespondingPoint: WARNING! Lpht and Rpht were not loaded with current call! bPLOT non-functional']);
    end
end

