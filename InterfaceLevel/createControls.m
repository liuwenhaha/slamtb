function Con = createControls(Robot)

% CREATECONTROLS  Create controls structure Con.
%   Con = CREATECONTROLS(ROBOT) generates a control structure Con. This
%   structure depends on the robot's motion model, which contains the
%   fields:
%       .u      nominal value of control
%       .uStd   Standard deviation of control noise
%       .U      Covariances matrix
%
%   The resulting structure needs to be updated during execution time with
%   data from one of these origins:
%       1. read from odometry sensors
%       2. generated by a control software
%       3. generated by the simulator.
%
%   See also CREATEROBOTS.

%   Copyright 2008-2009 Joan Sola @ LAAS-CNRS.

switch Robot.motion

    case {'constVel'}

        Con.u    = [Robot.dv;deg2rad(Robot.dwDegrees)];
        Con.uStd = [Robot.dvStd;deg2rad(Robot.dwStd)];
        Con.U    = diag(Con.uStd.^2);

    case {'odometry'}

        Con.u    = [Robot.dx;deg2rad(Robot.daDegrees)];
        Con.uStd = [Robot.dxStd;deg2rad(Robot.daStd)];
        Con.U    = diag(Con.uStd.^2);

    otherwise
        error('Unknown motion model %s from robot %d.',Robot.motion,Robot.id);
end










