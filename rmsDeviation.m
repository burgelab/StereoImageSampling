function [RMS,DC] = rmsDeviation(Izro,W,bPreWndw)

% function [RMS DC] = rmsDeviation(Izro,W,bPreWndw)
% 
%   example call: rmsDeviation(Izro)
%                 rmsDeviation(Izro,W)
%                 rmsDeviation(Izro,W,1)
%
% computes rms deviation of a zero mean image (nxn) or vector (1xn)
%
% Izro:     luminance image patch
% W:        window function (to attenuate image with)
% bPreWndw: boolean indicating whether image has been prewindowed
%                         i.e. whether the window has been baked into image
%           1 ->     prewindowed
%           0 -> not prewindowed
%           see ../Proof_WindowingContrastImagesRMScontrast.doc
%%%%%%%%%%%%%%%%%%%%%%%%
% RMS:   rms deviation of input
% DC:    mean of input

% INPUT HANDLING
if ~exist('W','var')        || isempty(W)         W = ones(size(Izro)); end
if ~exist('bPreWndw','var') || isempty(bPreWndw), bPreWndw = 0;         end
if ~isequal([size(Izro)],size(W)) 
    error(['rmsDeviation: size of window W [' num2str(size(W,1)) 'x' num2str(size(W,2)) '] must match size(Izro)=[' num2str(size(Izro,1)) 'x' num2str(size(Izro,2)) ']']); 
end

% AVG LUMINANCE UNDER WINDOW
if bPreWndw == 0
    DC   = sum(Izro(:).*W(:))./sum(W(:));
    % ZERO MEAN IMAGE
    Idev = Izro - DC;
    % RMS DEVIATION COMPUTED FROM MEAN-ZERO IMAGE
    RMS  = sqrt( sum( W(:).*( Idev(:) ).^2 )./sum(W(:)) );
elseif bPreWndw == 1
    [RMS,DC] = rmsDeviationPreWindowed(Izro,W);
end