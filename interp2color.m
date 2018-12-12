function J = interp2color(I, X,Y,varargin);

if (size(I,3)==1)
    % grayscale image
    J = interp2(I, X,Y,varargin{:});
elseif (size(I,3)==3)
    % color image
    J=zeros([size(X), 3]);
    J(:,:,1) = interp2(I(:,:,1), X,Y,varargin{:});
    J(:,:,2) = interp2(I(:,:,2), X,Y,varargin{:});
    J(:,:,3) = interp2(I(:,:,3), X,Y,varargin{:});
else
    error('Image format not supported');
end