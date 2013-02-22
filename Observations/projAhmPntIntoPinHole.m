function [u,s,U_s,U_pk,U_pd,U_ahm]  = projAhmPntIntoPinHole(Sf, Spk, Spd, ahm)

% PROJAHMPNTINTOPINHOLE Project AHM pnt into pinhole camera.
%    [U,S] = PROJAHMPNTINTOPINHOLE(RF, SF, SPK, SPD, L) projects 3D
%    Anchored Homogeneous points into a pin-hole camera, providing also the
%    non-measurable depth. The input parameters are:
%       SF : pin-hole sensor frame
%       SPK: pin-hole intrinsic parameters [u0 v0 au av]'
%       SPD: radial distortion parameters [K2 K4 K6 ...]'
%       L  : 3D anchored homog. point [x y z vx vy vz rho]'
%    The output parameters are:
%       U  : 2D pixel [u v]'
%       S  : non-measurable depth
%
%    The function accepts an ahm points matrix L = [L1 ... Ln] as input.
%    In this case, it returns a pixels matrix U = [U1 ... Un] and a depths
%    row-vector S = [S1 ... Sn].
%
%    [U,S,U_S,U_K,U_D,U_L] = ... gives also the jacobians of the
%    observation U wrt all input parameters. Note that this only works for
%    single points.
%
%    See also PINHOLE, PY2VEC, PROJIDPPNTINTOPINHOLEONROB.

%   Copyright 2008-2009 Joan Sola @ LAAS-CNRS.

p0 = ahm(1:3,:);   % origin
m  = ahm(4:6,:);   % pitch and roll
r  = ahm(7,:);     % inverse depth

t = Sf.t; % frame things
q = Sf.q;

if nargout <= 2  % No Jacobians requested

    v = m - (t-p0).*r;  % vector from sensor
    w = Rtp(q,v);       % in sensor frame
    u = pinHole(w, Spk, Spd); % pixel
    
    e = w./r;   % euclidean in sensor frame
    s = e(3,:); % depth

else            % Jacobians requested

    if size(idp,2) == 1

        % function calls
        v        = m - (t-p0)*r;  % vector from sensor
        V_m      = 1;
        V_p0     = r;  %  r*eye(3);
        V_t      = -r; % -r*eye(3);
        V_r      = p0-t;
        [w, W_q, W_v] = Rtp(q,v);
        [u, ~, U_w, U_pk, U_pd] = pinHole(w, Spk, Spd); % pixel
        
        e = w/r;   % euclidean
        s = e(3);  % depth of point


        % chain rule
        U_v  = U_w*W_v;
        U_p0 = U_v*V_p0;
        U_m  = U_v*V_m;
        U_r  = U_v*V_r;
        
        U_t  = U_v*V_t;
        U_q  = U_w*W_q;
        
        % Full jacobians
        U_ahm = [U_p0 U_m U_r];
        U_s   = [U_t U_q];

    else
        error('??? Jacobians not available for multiple IDP points.')

    end

end

return
 
%% jac
syms x y z a b c d real
syms au av u0 v0 real
syms d1 d2 d3 real
syms x0 y0 z0 p y r real

Sf = [x;y;z;a;b;c;d];
Spk = [u0;v0;au;av];
Spd = [d1;d2;d3];
idp = [x0;y0;z0;p;y;r];

[u,s,U_s,U_pk,U_pd,U_idp]  = projIdpPntIntoPinHole(Sf, Spk, Spd, idp);
u,s  = projIdpPntIntoPinHole(Sf, Spk, Spd, idp);

simplify(U_pk  - jacobian(u,Spk))
simplify(U_pd  - jacobian(u,Spd))
simplify(U_idp - jacobian(u,idp))







