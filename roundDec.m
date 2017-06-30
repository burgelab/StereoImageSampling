function R = roundDec(X,dec)

% function R = roundDec(X,dec)
%
%   example call: roundDec([.22 .43 .65 1.13],.1)
%
% rounds input values to specified nearest decimal
%
% X:    input values
% dec:  thing to round to
%%%%%%%%%%%%%%%%%%
% R:    rounded values


R = round(X./dec).*dec;

