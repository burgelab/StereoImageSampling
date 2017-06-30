function IppZ = LRSIprojPlaneDist(units)

% function LppZ = LRSIprojPlaneDist(units)
%
%   example call: LppZm = LRSIprojPlaneDist;
% 
% LRSI projection plane distance in units

if ~exist('units','var') || isempty(units) units = 1; end

IppZ = 3./units;