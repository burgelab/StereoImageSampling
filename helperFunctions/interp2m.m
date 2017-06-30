function Vq = interp2m(varargin)

% function Vq = interp2m(varargin)
%
% wrapper function for interp2 that handles matrix inputs
% especially useful for interpolating RGB images

if     nargin == 3
    V  = varargin{1};
    Xq = varargin{2};
    Yq = varargin{3};    
    % INTERPOLATED VALUES
    for d = 1:size(V,3)
    Vq(:,:,d) = interp2(V(:,:,d),Xq,Yq);
    end
elseif nargin == 4
    V  = varargin{1};    
    Xq = varargin{2};
    Yq = varargin{3};
    interpType = varargin{4};
    % INTERPOLATED VALUES
    for d = 1:size(V,3)
    Vq(:,:,d) = interp2(V(:,:,d),Xq,Yq,interpType);
    end
elseif nargin == 5
    X  = varargin{1};
    Y  = varargin{2};
    V  = varargin{3};    
    Xq = varargin{4};
    Yq = varargin{5};    
    % INTERPOLATED VALUES
    for d = 1:size(V,3)
    Vq(:,:,d) = interp2(X,Y,V(:,:,d),Xq,Yq);
    end
elseif nargin == 6
    X  = varargin{1};
    Y  = varargin{2};
    V  = varargin{3};    
    Xq = varargin{4};
    Yq = varargin{5};
    interpType = varargin{6};
    % INTERPOLATED VALUES
    for d = 1:size(V,3)
    Vq(:,:,d) = interp2(X,Y,V(:,:,d),Xq,Yq,interpType);
    end
else
   error(['interp2m: WARNING! unhandled number of input arguments: ' num2str(nargin)]); 
end