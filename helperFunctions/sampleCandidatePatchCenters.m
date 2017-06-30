function IctrRC = sampleCandidatePatchCenters(IszRC,PszXY,patchSpacing,numPatches,bBorderXY)
%
% function IctrRC = sampleCandidatePatchCenters(IszRC,PszXY,patchSpacing,numPatches,bBorderXY)
% 
% example call: % TO RETURN ALL CENTERS WITH 128 SPACING BETWEEN THEM
%                 IctrRC = sampleCandidatePatchCenters(IszRC,PszXY,128)
%
%               % TO RETURN TEN CENTERS SAMPLED FROM ALL PATCHES WITH 128 PIXEL SPACING     
%                 IctrRC = sampleCandidatePatchCenters(PszXY,PszXY,128,10)
% 
% returns row and column indices of patch centers
% 
% IszRC:        image size
% PszXY:        patch size where patchSize(1) - > Xsize
%               patch size where patchSize(2) - > Ysize
% patchSpacing: patch spacing in pixels
% numPatches:   number of candidate patch centers to sample from the image
%               []    -> defaults to all possible patch-centers
% bBorderXY:    1     -> do     exclude half-patch width border 
%               0     -> do not exclude half-patch width border (default)
%               [x y] -> border width of size x on both left and right &
%                               width of size y on both top  and bottom
%%%%%%%%%%%%%
% IctrRC:    row and column indices corresponding to candidate points

if isempty(PszXY),            PszXY = fliplr(IszRC);              end
if isempty(patchSpacing)      patchSpacing = PszXY;               end
if length(patchSpacing) == 1, patchSpacing(2) = patchSpacing;     end
if ~exist('bBorderXY','var') || isempty(bBorderXY) bBorderXY = 0; end

% HALF-PATCH BORDER OR NOT?
if bBorderXY == 0 % 
    PctrRlims = [ceil((PszXY(2))/2) IszRC(1)-floor(PszXY(2)/2)] + 1*mod(PszXY(2)+1,2);
    PctrClims = [ceil((PszXY(1))/2) IszRC(2)-floor(PszXY(1)/2)] + 1*mod(PszXY(1)+1,2);
elseif bBorderXY == 1 % 1/2 patch width zone in which images are not selected
    PctrRlims = [1+PszXY(2) 1+IszRC(1)-PszXY(2)];
    PctrClims = [1+PszXY(1) 1+IszRC(2)-PszXY(1)];
elseif (length(bBorderXY) > 1 ) || (length(bBorderXY) == 1)
    if length(bBorderXY) == 1, bBorderXY(2) = bBorderXY; end
    PctrRlims = [ceil((PszXY(2))/2) IszRC(1)-floor(PszXY(2)/2)] + 1*mod(PszXY(2)+1,2);
    PctrClims = [ceil((PszXY(1))/2) IszRC(2)-floor(PszXY(1)/2)] + 1*mod(PszXY(1)+1,2);
    PctrRlims = PctrRlims + [floor(bBorderXY(2)) -floor(bBorderXY(2))];
    PctrClims = PctrClims + [floor(bBorderXY(1)) -floor(bBorderXY(1))];
end

% GET COLUMNS AND ROWS (X AND Y)
[PctrC,PctrR] = meshgrid(PctrClims(1):patchSpacing(1):PctrClims(2), ...
                         PctrRlims(1):patchSpacing(2):PctrRlims(2));

% PATCH COORDINATES                       
IctrRC = [PctrR(:) PctrC(:)];

if exist('numPatches','var') && ~isempty(numPatches)
   indP   = randsample(size(IctrRC,1),numPatches); 
   IctrRC = IctrRC(indP,:);
end