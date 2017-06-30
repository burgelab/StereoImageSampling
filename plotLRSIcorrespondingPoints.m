function plotLRSIcorrespondingPoints(LitpRC,RitpRC,Limg,Rimg,Lrng,Rrng,bIndGd)

% function plotLRSIcorrespondingPoints(LitpRC,RitpRC,Limg,Rimg,Lrng,Rrng,bIndGd)
%
% sampled corresponding points on stereo-image and range images 
% yellow dots -> good points; red dots -> bad points
%
% LitpRC:        interpolated corresponding point row-column index in left      eye's image
% RitpRC:        interpoalted corresponding point row-column index in right     eye's image
% Limg:          left  eye image
% Rimg:          right eye image
% Lrng:          left  eye range-map
% Rrng:          right eye range-map
% bIndGd:        boolean with 1 for good corresponding points, 0 for bad
% IszRC:         image size in rows and columns

if ~exist('bIndGd','var') || isempty(bIndGd) bIndGd = [1:size(LitpRC,1)]; end

% IMAGE SIZE
IszRC = size(Limg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OVERLAY SAMPLED POINTS ON LUMINANCE IMAGES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('Limg','var') & exist('Rimg','var') & ~isempty(Limg) & ~isempty(Rimg)
    figure('position',[42 599 1256 280]);
    % PLOT STEREO-IMAGE
    imagesc([Limg Rimg Limg].^.4); axis image; set(gca,'xtick',[]); set(gca,'ytick',[]); colormap gray(256); hold on;
    % PLOT GOOD POINTS
    plot([LitpRC( bIndGd,2) RitpRC( bIndGd,2)+IszRC(2) LitpRC( bIndGd,2)+2*IszRC(2)],[LitpRC( bIndGd,1) RitpRC( bIndGd,1) LitpRC( bIndGd,1)],'y.');
    % PLOT BAD  POINTS
    plot([LitpRC(~bIndGd,2) RitpRC(~bIndGd,2)+IszRC(2) LitpRC(~bIndGd,2)+2*IszRC(2)],[LitpRC(~bIndGd,1) RitpRC(~bIndGd,1) LitpRC(~bIndGd,1)],'r.');
    title('Luminance'); xlabel('LE');
else
   disp(['plotLRSIcorrespondingPoints: WARNING! luminance data not entered...']) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OVERLAY SAMPLED POINTS ON RANGE IMAGES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('Lrng','var') & exist('Rrng','var') & ~isempty(Lrng) & ~isempty(Rrng)
    figure('position',[42 193 1256 279]);
    % PLOT RANGE-IMAGE
    imagesc(-log([Lrng Rrng Lrng])); axis image; set(gca,'xtick',[]); set(gca,'ytick',[]); colormap gray(256); hold on;
    % PLOT GOOD POINTS
    plot([LitpRC( bIndGd,2) RitpRC( bIndGd,2)+IszRC(2) LitpRC( bIndGd,2)+2*IszRC(2)],[LitpRC( bIndGd,1) RitpRC( bIndGd,1) LitpRC( bIndGd,1)],'y.');
    % PLOT BAD  POINTS
    plot([LitpRC(~bIndGd,2) RitpRC(~bIndGd,2)+IszRC(2) LitpRC(~bIndGd,2)+2*IszRC(2)],[LitpRC(~bIndGd,1) RitpRC(~bIndGd,1) LitpRC(~bIndGd,1)],'r.');
    title('Range'); xlabel('LE');
else
   disp(['plotLRSIcorrespondingPoints: WARNING! range data not entered...']) 
end