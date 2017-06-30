function PindRC = patchCenter2coords(centerRC,PszXY)

% function PindRC = patchCenter2coords(centerRC,PszXY)
%
%   example call: patchCenter2coords([65 65],[128 128])
%
%                 patchCenter2coords([17 65],[128 32])
%
% converts patch center to patch coordinates where 'coordinates' 
% specify the upper / left hand corner of the patch
%
% centerRC: indices of center in row/column       [row col]
% PszXY:    size of patch in pixels               [ x   y ]
% %%%%%%%%%%%%%%
% PindRC:   indices of upper/left corner of patch [row,col]

PindRC = bsxfun(@minus,centerRC,floor(fliplr(PszXY)./2));
