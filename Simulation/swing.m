function wstruct = swing(wsize,color,ax)

% SWING  Create a graphics structure with a wing shape.
%   WSTRUCT = SWING(WSIZE,COLR,AX) creates a structure for a 'patch'
%   graphic object correspoinding to a wing of size WSIZE, color COLR, in
%   axes AX.
%
%   See also WING, PATCH.

%   Copyright 2008-2009 Joan Sola @ LAAS-CNRS.

if nargin < 3
    ax = gca;
end

wstruct = wing(wsize);
wstruct.handle = patch(...
    'parent'   ,ax,...
    'vertices' ,wstruct.vert,...
    'faces'    ,wstruct.faces,...
    'linewidth',2,...
    'facecolor','none',...
    'edgecolor',color,...
    'visible'  ,'on'); 









