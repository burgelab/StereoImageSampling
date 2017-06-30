function Icrp = cropImageCtrInterp(I,PctrRC,PszXY,interpType,bPLOT)

% function Icrp = cropImageCtrInterp(I,PctrRC,PszXY,interpType,bPLOT)
%
%   example call: I    = cropImageCtr(loadLRSIimage(8,1,0,'PHT','img'),[],[15 15]);
%                 Icrp = cropImageCtrInterp(I,[8.5 8.25],[9 9],[],1);
%
% crop image at real-valued (instead of integer-valued) pixel locations 
% via interpolation of specified type
% 
% I:          image of size                   [ n x m ] or [ n x m x 3 ]
% PctrRC:     patch center location in pixels [ 1 x 2 ]     
%             expressed in row/column form  
% PszXY:      patch size in pixels            [ 1 x 2 ]
% interpType: interpolation method 
%             'none'   -> no     interpolation
%             'linear' -> linear interpolation (default)
%             'spline' -> spline interpolation
%%%%%%%%%%%%%%%%%%%%%%
% Icrp:       cropped interpolated image

if ~exist('interpType','var') || isempty(interpType) interpType = 'linear'; end
if ~exist('bPLOT','var')      || isempty(bPLOT)      bPLOT      =         0; end

if strcmp(interpType,'none')
    Icrp     = cropImageCtr(I,round(PctrRC),PszXY);
elseif strcmp(interpType,'linear')
    % BUFFER SIZE STRIP
    BszXY   = PszXY + [1+ceil(abs(rem(PctrRC(2),1)))  2 ];
    % XY PIXEL COORDINATES IN STRIP
    [XbffPix,YbffPix]=meshgrid(1:BszXY(1),1:BszXY(2));
    % INTERPOLATE IMAGE; FOR SPEED: i)   CROP IMAGE W. BUFFER
    %                               ii)  INTERPOLATE IMAGE 
    %                               iii) CROP TO FINAL SIZE ( *** see LRSIcorrespondingPointL2R.m *** )
    try
    Icrp  = cropImageCtr( interp2m( cropImageCtr(I, fix(PctrRC),BszXY), XbffPix+rem(PctrRC(2),1),YbffPix,interpType), [],PszXY);
    catch
       killer = 1; 
    end
else
    error(['cropImageCtrInterp: WARNING! unhandled interpType: ' interpType '. Write code?']);
end

%%%%%%%%%%%%%%
% PLOT STUFF %
%%%%%%%%%%%%%%
if bPLOT
   figure('position',[65 339 1184 467])
   % PLOT ORIGINAL IMAGE WITH CROP
   subplot(1,3,1);
   imagesc(I.^.4); hold on;
   plot(    PctrRC(1,2) ,    PctrRC(1,1) ,'yo','linewidth',1);
   plot(    PctrRC(1,2) ,    PctrRC(1,1) ,'y.','linewidth',0.25);
   plot(fix(PctrRC(1,2)),fix(PctrRC(1,1)),'y.','linewidth',0.25);
   plotSquare(    fliplr(PctrRC) ,PszXY,'y',1)
   plotSquare(fix(fliplr(PctrRC)),PszXY,'y',.25)
   formatFigure([],[],['IszRC=[' num2str(size(I,1)) ' ' num2str(size(I,2)) '], crpSz=[' num2str(size(Icrp,1)) ' ' num2str(size(Icrp,2)) ']' ]);
   axis image; axis off
   cax = caxis;
   
   % PLOT REAL-VALUED    CROP LOCATION
   subplot(1,3,2); 
   imagesc(Icrp.^.4); colormap gray; axis image;
   formatFigure([],[],['ctrRC=[' num2str(PctrRC(1,1),'%.2f') ' ' num2str(PctrRC(1,2),'%.2f') ']'])
   axis off; caxis(cax)
   
   % PLOT INTEGER-VALUED CROP LOCATION
   subplot(1,3,3); 
   imagesc(cropImageCtr(I,fix(PctrRC),PszXY).^.4); colormap gray; axis image;
   formatFigure([],[],['ctrRC=[' num2str(fix(PctrRC(1,1)),'%0d') ' ' num2str(fix(PctrRC(1,2)),'%0d') ']'])
   axis off; caxis(cax)
end