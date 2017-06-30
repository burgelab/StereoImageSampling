function [IvrgDeg] = vergenceFromRangeXYZ(LorCorR,IPDm,Ixyz)

% function [IvrgDeg] = vergenceFromRangeXYZ(LorCorR,IPDm,Ixyz)
%
%   example call: vergenceFromRangeXYZ('L',0.065,Lxyz)
%
% vergence angle in the epipolar plane in deg given a range xyz image and an interpupillary distance
%
% NOTE! if LorCorR -> 'L' Ixyz is expressed in a coordinate system centered at the LE nodal point
%       if LorCorR -> 'R' Ixyz is expressed in a coordinate system centered at the RE nodal point
%       if LorCorR -> 'C' Ixyz is expressed in a coordinate system centered at the CE nodal point
%
% LorCorR:      left,right or cyclopean co-ordinate system to use
%            'L' -> left      image used   as reference
%            'R' -> right     image used   as reference
%          ? 'C' -> cyclopean image ?
% IPDm:      inter-ocular distance to simulate
% Ixyz:      range data in cartesian coordinates [ r x c x 3 ]
%            Ixyz(:,:,1) -> x-values
%            Ixyz(:,:,2) -> y-values
%            Ixyz(:,:,3) -> z-values
%            NOTE: If size(Ixyz) = [1 3], automatically resized to [1 1 3]
%%%%%%%%%%%%%%%%%%%%%%%
% IvrgDeg:   vergence angle to point

if size(Ixyz,1) == 1 && size(Ixyz,2) == 3, Ixyz = reshape(Ixyz,[1 1 3]); end
if size(Ixyz,3) ~= 3, error(['vergenceFromRangeXYZ: WARNING! size(Ixyz,3) = ' num2str(size(Ixyz,3)) ' instead of 3']); end

if strcmp(LorCorR,'L')
    LxyzEye = [   0 0 0];
    RxyzEye = [+IPDm 0 0];
  % BINOCULAR ANGLE TO EACH XYZ POINT FOR LEFT  EYE
    IvrgDeg = lawofcosinesSSSd(sqrt(sum(Ixyz.^2,3)), sqrt(sum(bsxfun(@minus,Ixyz,reshape(RxyzEye,[1 1 3])).^2,3)),IPDm  );
  % LangDeg = lawofcosinesSSSd(sqrt(sum(Lxyz.^2,3)), sqrt(sum(bsxfun(@minus,Lxyz,reshape(RxyzEye,[1 1 3])).^2,3)),IPDm  );
elseif strcmp(LorCorR,'R')
    LxyzEye = [-IPDm 0 0];
    RxyzEye = [    0 0 0];
  % BINOCULAR ANGLE TO EACH XYZ POINT FOR RIGHT EYE
    IvrgDeg = lawofcosinesSSSd(sqrt(sum(Ixyz.^2,3)), sqrt(sum(bsxfun(@minus,Ixyz,reshape(LxyzEye,[1 1 3])).^2,3)),IPDm  );
  % RangDeg = lawofcosinesSSSd(sqrt(sum(Rxyz.^2,3)), sqrt(sum(bsxfun(@minus,Rxyz,reshape(LxyzEye,[1 1 3])).^2,3)),IPDm  );
elseif strcmp(LorCorR,'C')
    LxyzEye = [-IPDm/2 0 0];
    RxyzEye = [ IPDm/2 0 0];
  % BINOCULAR ANGLE TO EACH XYZ POINT FOR RIGHT EYE
    IvrgDeg = lawofcosinesSSSd(sqrt(sum(bsxfun(@minus,Ixyz,reshape(LxyzEye,[1 1 3])).^2,3)), ...
                               sqrt(sum(bsxfun(@minus,Ixyz,reshape(RxyzEye,[1 1 3])).^2,3)),IPDm  );
  % RangDeg = lawofcosinesSSSd(sqrt(sum(Rxyz.^2,3)), sqrt(sum(bsxfun(@minus,Rxyz,reshape([-IPDm 0 0],[1 1 3])).^2,3)),IPDm  );
else
    error(['vergenceAngleFromRangeXYZ: WARNING! unhandled LorCorR string: ' LorCorR])
end
