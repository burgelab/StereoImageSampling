function [LimgCrp, RimgCrp, LxyzCrp, RxyzCrp] = LRSIcropStereoPatch(LitpRC,RitpRC,Limg,Rimg,Lxyz,Rxyz,PszXY,bPLOT)
%
% function [LimgCrp, RimgCrp, LxyzCrp, RxyzCrp] = LRSIcropStereoPatch(LitpRC,RitpRC,Limg,Rimg,Lxyz,Rxyz,PszXY,bPLOT)
%
% Example call:  load('LRSItestImg02.mat'); LRSIcropStereoPatch([805 1119],[805 1160],Limg,Rimg,Lxyz,Rxyz,[250 250],1);
%
% Crops local patch of specified size at specified location from stereo-image and distance maps
%
% LitpRC         :  interpolated corresponding point row-column index in left      eye's image
% RitpRC         :  interpoalted corresponding point row-column index in right     eye's image
% Limg           :  left  eye   image of size [N M]
% Rimg           :  right eye  image  of size [N M]
% Lxyz           :  cartesian coordinates of scene points in LE coord system [N M 3] i.e. 3 maps each for x,y and z coordinates
% Lxyz           :  cartesian coordinates of scene points in RE coord system [N M 3] i.e. 3 maps each for x,y and z coordinates
% PszXY          :  patch size [y x]
% bPLOT:            plot or not 
%                   1 -> plot
%                   0 -> not                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LimgCrp        :  left  eye image-patch with specied center cropped to specified size [y x]
% LimgCrp        :  right eye image-patch with specied center cropped to specified size [y x]
% LxyzCrp        :  left  eye cartesian coordinate map patches with speciedcenter cropped to specified size [y x 3]
% LxyzCrp        :  right eye cartesian coordinate map patches with specied center cropped to specified size [y x 3]

interpType = 'linear';

% CROP IMAGE
LimgCrp  = cropImageCtrInterp(Limg , LitpRC, PszXY, interpType); % IMAGE
RimgCrp  = cropImageCtrInterp(Rimg , RitpRC, PszXY, interpType);

% CROP CARTESIAN COORDINATE MAPS
LxyzCrp = cropImageCtrInterp(Lxyz , LitpRC, PszXY, interpType); % XYZ
RxyzCrp = cropImageCtrInterp(Rxyz , RitpRC, PszXY, interpType);

if bPLOT
    
    % OBTAIN XY COORDINATES OF PATCH-CENTER
    PctrXY = floor(PszXY/2 + 1);
    
    figure('position',[831   597   625   282])
    % LE
    subplot(1,6,[1 2 ]);
    imagesc(LimgCrp.^.4); colormap(gca,'gray');  
    xlabel(['LE']); set(gca,'xtick',[],'ytick',[]); hold on; axis square;
    plot(PctrXY(1),PctrXY(2),'.','color','y','MarkerSize',2); hold on;
    plot(PctrXY(1),PctrXY(2),'s','color','y','MarkerSize',10); 
    % RE
    subplot(1,6,[3 4]);
    imagesc(RimgCrp.^.4); colormap(gca,'gray'); axis square;  hold on; xlabel(['RE']); set(gca,'xtick',[],'ytick',[]);
    plot(PctrXY(1),PctrXY(2),'.','color','y','MarkerSize',2); hold on;
    plot(PctrXY(1),PctrXY(2),'s','color','y','MarkerSize',10); 
    % LE
    subplot(1,6,[5 6]);
    imagesc(LimgCrp.^.4); colormap(gca,'gray'); 
    xlabel(['LE']); set(gca,'xtick',[],'ytick',[]); hold on; axis square;
    plot(PctrXY(1),PctrXY(2),'.','color','y','MarkerSize',2); hold on;
    plot(PctrXY(1),PctrXY(2),'s','color','y','MarkerSize',10); 

end