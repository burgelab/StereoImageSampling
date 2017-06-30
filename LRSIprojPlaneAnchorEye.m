function [IppX,IppY,IppZ,IppXdeg,IppYdeg,IPD] = LRSIprojPlaneAnchorEye(LorCorR,units,dnK)

% function [IppX,IppY,IppZ,IppXdeg,IppYdeg,IPD] = LRSIprojPlaneAnchorEye(LorCorR,units,dnK)
%
%   example call:  % LOAD PROJECTION PLANE SAMPLES IN LEFT EYE COORDINATES
%                    [LppXm LppYm LppZm LppXdeg LppYdeg] =  LRSIprojPlaneAnchorEye('L',1, 1);
%                   
%                   % LOAD PROJECTION PLANE SAMPLES IN CYCLOPEAN COORDINATES
%                    [CppXm CppYm CppZm CppXdeg CppYdeg] =  LRSIprojPlaneAnchorEye('C',1, 1);
%
%                   % LOAD PROJECTION PLANE SAMPLES IN RIGHT EYE COORDINATES
%                    [RppXm RppYm RppZm RppXdeg RppYdeg] =  LRSIprojPlaneAnchorEye('R',1, 1);
%
% load in details of the (p)rojection (p)lane with which the luminance range images were sampled...
%
% the luminance range image data was projected onto a frontoparallel plane 3 meters from the observer
% the center of the projection plane in cyclopean eye coordinates is      0,0,3
% the center of the projection plane in left      eye coordinates is +IPD/2,0,3
% the center of the projection plane in right     eye coordinates is -IPD/2,0,3
%
% see LumRangeImages_ReadMe.txt in ../Project_ImageDatabases/LumRangeImages/
% 
% LorCorR:   anchor eye... the anchor eye indicates the coordinate system
%            in which projection plane pixel locations are expressed
%            'L' -> left      eye = pixels in LE coordinate system
%            'C' -> cyclopean eye = pixels in CE coordinate system
%            'R' -> right     eye = pixels in RE coordinate system
% units:     units in which to return distance estimates
% dnK:       units in which to return distance estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IppX:       anchor eye x position samples in units
% IppY:       anchor eye y position samples in units
% IppZ:       anchor eye z position of the projection plane in units
% IppXdeg:    anchor eye x position samples in visual deg
% IppYdeg:    anchor eye x position samples in visual deg
% IPD:        inter-pupillary (inter-camera) distance during acquisition

% INPUT HANDLING
if ~exist('units','var') || isempty(units) units = 1; end
if ~exist('dnK','var')   || isempty(dnK)     dnK = 1; end

% STEREO CAMERA IPD IN METERS
IPD     = LRSIcameraIPD(units);
% IMAGE SIZE IN PIXELS
I       = zeros(1080./dnK,1920./dnK);
% SCREEN SIZE IN METERS
screenX = 1.940/units;     %  see the file LumRangeImages_ReadMe.txt in
screenY = 1.118/units;     %  ../Project_ImageDatabases/LumRangeImages

if strcmp(LorCorR,'L')
    K = +IPD/2;
elseif strcmp(LorCorR,'C')
    K = 0;
elseif strcmp(LorCorR,'R')
    K = -IPD/2;
end

% LEFT  EYE PROJECTION SCREEN COORDINATES (3 meters from interocular axis)
IppZ    = LRSIprojPlaneDist(units);
% SAMPLE POSITIONS IN RANGE IMAGES (almost)
IppX    = K + smpPos(size(I,2)./screenX,size(I,2));     %  see the file LumRangeImages_ReadMe.txt in
IppY    =   fliplr(smpPos(size(I,1)./screenY,size(I,1)));    %  ../Project_ImageDatabases/LumRangeImages
% PROJECTION PLANE DIMENSIONS INDICATE PIXEL BORDERS (offset of smpPos.m is needed)
IppX    = IppX + diff(IppX(1:2))/2;
IppY    = IppY - diff(IppY(1:2))/2;
% PIXEL COORDINATES IN METERS
[IppX,IppY] = meshgrid(IppX,IppY);
% ANGULAR POSITION (FICK COORDINATES) OF L SAMPLES IN PROJECTION PLANE
IppXdeg = atand(IppX./IppZ);
IppYdeg = atand(IppY./IppZ);
