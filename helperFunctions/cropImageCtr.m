function [P,PctrRC] = cropImageCtr(I,PctrRC,PszXY,indColorChannels)

% function [P PcrdRC] = cropImageCtr(I,PctrRC,PszXY,indColorChannels)
%
%   example call: % CROP IMAGE AND VIEW IT
%                 P = cropImageCtr(I,[475 1625],[128 128]); imagesc(P(:,:,1));
%
%                 % COMPARE COLOR CHANNELS OF CROPPED IMAGE  
%                 P = cropImageCtr(I,[875 1625],[128 128]); figure('position',[168 185 580 886]); subplot(3,1,[1 2]); imagesc(sqrt(P./max(P(:)))); axis image; subplot(3,2,6); imagesc(sqrt(P(:,:,3))); axis image; title('B'); colormap gray; subplot(3,2,5); imagesc(sqrt(P(:,:,2))); axis image; title('G'); colormap gray;                     
%
% crops patch of size PszXY from image given patch center 
% coordinates specified in row-column form 
%
% I:                full size image or image sequence
%                   [n x m x 1]     -> gray scale image
%                   [n x m x 3]     -> full color imagegr
%                   [n x m x 1 x t] -> gray scale movie
% PctrRC:           patch coordinates (row, column) of 
%                   center of patch
% PszXY:            patch size in pixels [1x2] vector storing X,Y sizes
% indColorChannels: color channel index; if empty, selects all channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P:                image patch
% PcrdRC:           patch coordinates

if ~exist('PszXY','var') || isempty(PszXY)
   PszXY = [size(I,2) size(I,1)];
end
if length(PszXY) == 1
    PszXY = [PszXY PszXY];
end
if ~exist('PctrRC','var') || isempty(PctrRC)
   PctrRC(1) = floor((size(I,1))/2 + 1);
   PctrRC(2) = floor((size(I,2))/2 + 1);
end
if ~exist('indColorChannels','var') || isempty(indColorChannels)
   indColorChannels = 1:size(I,3); 
end

P = cropImage(I,patchCenter2coords(PctrRC,PszXY),PszXY,indColorChannels);