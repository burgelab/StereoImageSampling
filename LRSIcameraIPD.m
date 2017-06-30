function [IPD] = LRSIcameraIPD(units)

% function [IPD] = LRSIcameraIPD(units)
%
%   exapmle call: IPDmm = LRSIcameraIPD(1e-3);
%
% camera IPD in lum stereo range image (LRSI) database 
%
% units: units to return IPD in
%        1    -> meters
%        1e-3 -> millimeters
%%%%%%%%%%%%%%
% IPD:   interpupillary (i.e. inter-nodal-point) distance in units

if ~exist('units','var') || isempty(units) units = 1; end

IPDm = 0.065;
IPD  = IPDm./units;