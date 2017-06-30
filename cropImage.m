function [P PcrdRC] = cropImage(I,PcrdRC,PszXY,indColorChannels)

% function [P PcrdRC] = cropImage(I,PcrdRC,PszXY,indColorChannels)
%
%   example call: % CROP IMAGE AND VIEW IT
%                 cropImage(I,[475 1625],[128 128]); imagesc(P(:,:,1));
% 
%                 % COMPARE COLOR CHANNELS OF CROPPED IMAGE  
%                 P = cropImage(I,[875 1625],[128 128]); figure('position',[168 185 580 886]); subplot(3,1,[1 2]); imagesc(sqrt(P./max(P(:)))); axis image; subplot(3,2,6); imagesc(sqrt(P(:,:,3))); axis image; title('B'); colormap gray; subplot(3,2,5); imagesc(sqrt(P(:,:,2))); axis image; title('G'); colormap gray;                     
% 
% crops patch from image based input coordinates in row-column form 
% specifying the upper left corner of a patch of size PszXY
%
% I:                full size image or image sequence
%                   [n x m x 1]     -> gray scale image
%                   [n x m x 3]     -> full color image
%                   [n x m x 1 x t] -> gray scale movie
% PcrdRC:           patch coordinates (row, column) of 
%                   upper left hand corner of patch
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
if ~exist('PcrdRC','var') || isempty(PcrdRC)
   PcrdRC(1) = ceil((size(I,1) - PszXY(2))/2 + 1);
   PcrdRC(2) = ceil((size(I,2) - PszXY(1))/2 + 1);
end
if ~exist('indColorChannels','var') || isempty(indColorChannels)
   indColorChannels = 1:size(I,3); 
end

% CROP IMAGE
try
P = I(PcrdRC(1):(PcrdRC(1)+PszXY(2)-1), ...
      PcrdRC(2):(PcrdRC(2)+PszXY(1)-1), ...
      indColorChannels,:);
catch
    error(['cropImage: WARNING! crop size is larger than image to crop from, or crop location is NaN']);
end
