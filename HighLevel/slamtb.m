% SLAMTB  An EKF-SLAM algorithm with simulator and graphics.
%
%   This script performs multi-robot, multi-sensor, multi-landmark 6DOF
%   EKF-SLAM with simulation and graphics capabilities.
%
%   Please read slamToolbox.pdf in the root directory thoroughly before
%   using this toolbox.
%
%   - Beginners should not modify this file, just edit USERDATA.M and enter
%   and/or modify the data you wish to simulate.
%
%   - More advanced users should be able to create new landmark models, new
%   initialization methods, and possibly extensions to multi-map SLAM. Good
%   luck!
%
%   - Expert users may want to add code for real-data experiments. 
%
%   See also USERDATA, USERDATAPNT, USERDATALIN.
%
%   Also consult slamToolbox.pdf in the root directory.

%   Created and maintained by
%   Copyright 2008, 2009, 2010 Joan Sola @ LAAS-CNRS.
%   Copyright 2011, 2012, 2013 Joan Sola.
%   Programmers (for parts of the toolbox):
%   Copyright David Marquez and Jean-Marie Codol @ LAAS-CNRS
%   Copyright Teresa Vidal-Calleja @ ACFR.
%   See COPYING.TXT for wull copyright license.

%% OK we start here

% clear workspace and declare globals
clear
global Map          %#ok<NUSED>

%% I. Specify user-defined options - EDIT USER DATA FILE userData.m

userData;           % user-defined data. SCRIPT.
% userDataPnt;        % user-defined data for points. SCRIPT.
% userDataLin;        % user-defined data for lines. SCRIPT.


%% II. Initialize all data structures from user-defined data in userData.m
% SLAM data
[Rob,Sen,Raw,Lmk,Obs,Tim]     = createSlamStructures(...
    Robot,...
    Sensor,...      % all user data
    Time,...
    Opt);

% Simulation data
[SimRob,SimSen,SimLmk,SimOpt] = createSimStructures(...
    Robot,...
    Sensor,...      % all user data
    World,...
    SimOpt);

% Graphics handles
[MapFig,SenFig]               = createGraphicsStructures(...
    Rob, Sen, Lmk, Obs,...      % SLAM data
    SimRob, SimSen, SimLmk,...  % Simulator data
    FigOpt);                    % User-defined graphic options


%% III. Initialize data logging
% TODO: Create source and/or destination files and paths for data input and
% logs.
% TODO: do something here to collect data for post-processing or
% plotting. Think about collecting data in files using fopen, fwrite,
% etc., instead of creating large Matlab variables for data logging.

% Clear user data - not needed anymore
clear Robot Sensor World Time   % clear all user data


%% IV. Main loop
for currentFrame = Tim.firstFrame : Tim.lastFrame
    
    % 1. SIMULATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Simulate robots
    for rob = [SimRob.rob]

        % Robot motion
        SimRob(rob) = simMotion(SimRob(rob),Tim);
        
        % Simulate sensor observations
        for sen = SimRob(rob).sensors

            % Observe simulated landmarks
            Raw(sen) = simObservation(SimRob(rob), SimSen(sen), SimLmk, SimOpt) ;

        end % end process sensors

    end % end process robots

    

    % 2. ESTIMATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Process robots
    for rob = [Rob.rob]

        % Robot motion
        % NOTE: in a regular, non-simulated SLAM, this line is not here and
        % noise just comes from the real world. Here, the estimated robot
        % is noised so that the simulated trajectory can be made perfect
        % and act as a clear reference. The noise is additive to the
        % control input 'u'.
        Rob(rob).con.u = SimRob(rob).con.u + Rob(rob).con.uStd.*randn(size(Rob(rob).con.uStd));

        Rob(rob) = motion(Rob(rob),Tim);

        % Process sensor observations
        for sen = Rob(rob).sensors

            % Observe knowm landmarks
            [Rob(rob),Sen(sen),Lmk,Obs(sen,:)] = correctKnownLmks( ...
                Rob(rob),   ...
                Sen(sen),   ...
                Raw(sen),   ...
                Lmk,        ...   
                Obs(sen,:), ...
                Opt) ;

            % Initialize new landmarks
            [Lmk,Obs(sen,:)] = initNewLmk(...
                Rob(rob),   ...
                Sen(sen),   ...
                Raw(sen),   ...
                Lmk,        ...
                Obs(sen,:), ...
                Opt) ;

        end % end process sensors

    end % end process robots


    % 3. VISUALIZATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if currentFrame == Tim.firstFrame ...
            || currentFrame == Tim.lastFrame ...
            || mod(currentFrame,FigOpt.rendPeriod) == 0
        
        % Figure of the Map:
        MapFig = drawMapFig(MapFig,  ...
            Rob, Sen, Lmk,  ...
            SimRob, SimSen, ...
            FigOpt);
        
        if FigOpt.createVideo
            makeVideoFrame(MapFig, ...
                sprintf('map-%04d.png',currentFrame), ...
                FigOpt, ExpOpt);
        end
        
        % Figures for all sensors
        for sen = [Sen.sen]
            SenFig(sen) = drawSenFig(SenFig(sen), ...
                Sen(sen), Raw(sen), Obs(sen,:), ...
                FigOpt);
            
            if FigOpt.createVideo
                makeVideoFrame(SenFig(sen), ...
                    sprintf('sen%02d-%04d.png', sen, currentFrame),...
                    FigOpt, ExpOpt);
            end
            
        end

        % Do draw all objects
        drawnow;
    end
    


    % 4. DATA LOGGING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO: do something here to collect data for post-processing or
    % plotting. Think about collecting data in files using fopen, fwrite,
    % etc., instead of creating large Matlab variables for data logging.
    

end

%% V. Post-processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter post-processing code here









