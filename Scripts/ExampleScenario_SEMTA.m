%% SEMTA Radar System - Example Scenario Initialization File
%{

    Sean Holloway
    SEMTA Init File
    
    This file specifies all parameters of a radar simulation test for the
    SEMTA project. 

    Use script 'FullSystem_AutomatedSimulation.m' to run scenarios.
    
%}

%% Housekeeping

% Initialize class
scenario = RadarScenario;
scenario.flags.sim_rate = sim_rate;

%% Multistatic Scenario Setup

% Number of frames and receivers to simulate
scenario.multi.n_fr = 60;
scenario.multi.n_re = 3;

% Allocate data structures
multiSetup(scenario);

% Locations of radar units
% scenario.multi.radar_pos = ...
%     [-0.5 * nm * ones(1,scenario.multi.n_re); ...       % Constant x location
%     0.25 * nm * ((0:(scenario.multi.n_re-1))); ...       % Incremental y distance
%     0 * nm * ones(1,scenario.multi.n_re)];          % Constant z elevation

scenario.multi.radar_pos = ...
    [-500, -500, -500; -250, 0, 250; 0, 0, 0];

% Multistatic processing method
%   Method of deciding which units to use for multilateration each frame
scenario.multi.method = 'SNR';                  % 'SNR' or 'Range'
scenario.multi.track_method = 'Moving Average'; % 'Moving Average' or 'None'

%% Target RCS Setup

% Options setup
scenario.rcs = struct( ...
    ...
    ... % RCS options
    'rcs_model',    'constant', ...        % Set 'model' or 'constant'
    'ave_rcs',      0, ...            % Target RCS in dBm^2
    ...
    ... % Model options
    'dim',      [6; 3; 0], ...          % [x; y; z] size of target
    'n_sc',     50, ...                 % Number of point scatterers
    'res_a',    0.1, ...                % Angle resolution in degrees
    'freq',     10.4e9:10e6:10.5e9);    % Frequency range to model

% Run RCS model
scenario.rcs = TargetRCSModel(scenario.rcs);

% View RCS results
% viewRCSFreq(scenario);
% viewRCSAng(scenario);

%% Target Trajectory Setup

% Options setup
scenario.traj = struct( ...
    ...
    ... % Trajectory options
    'alt',      0, ...                  % Altitude in meters
    'yvel',     10, ...                 % Along track velocity in m/s
    'exc',      -100, ...               % Excursion distance in meters
    'per',      0.1, ...                % Excursion period (Nominally 0.05 to 0.2)
    ...
    ... % Model options
    'model',    'model', ...            % Set 'static' or 'model'
    'time',     0 : 50e-6 : 10.24);     % Time of simulation in seconds
% NOTE: Set time step to PRI

% Run Trajectory model
scenario.traj = TrajectoryModel(scenario.traj);

% View Trajectory
% viewTraj(scenario);

%% Simulation Setup

% Radar simulation and processing setup
scenario.simsetup = struct( ...
    ...
    ... % Waveform Properties
    'f_c',      10.45e9, ...            % Operating frequency in Hz
    'f_s',      125e6, ...              % ADC sample frequency in Hz
    't_ch',     25e-6, ...              % Chirp duration in seconds
    'bw',       50e6, ...               % Chirp bandwidth in Hz
    't_tx',     5e-6, ...               % Transmit time during chirp in seconds
    't_rx_on',  5.6e-6, ...             % Time to begin receiving in seconds
    't_rx_off', 23e-6, ...              % Time to end receiving in second
    'prf',      40e3, ...               % Pulse repetition frequency in Hz
    ...                                            % NOTE: Uses chirp pulse rate,
    ...                                            % to save time in simulation
    ...                                            % as ramp low samples are dumped
    'n_p',      2048, ...               % Number of pulses to simulate
    ...
    ... % Transceiver Properties
    'n_ant',        4, ...              % Number of elements in antenna array
    'tx_pow',       3, ...              % Transmit power in Watts
    'tx_ant_gain',  0, ...             % Tx antenna gain in dBi (N/A?)
    'rx_sys_gain',  0, ...              % Rx system gain in dB (N/A?)
    'rx_nf',        3, ...              % Rx noise figure in dB
    'rx_ant_gain',  16, ...             % Rx antenna gain in dBi (N/A?)
    ...
    ... % Processing Properties
    'n_win',        5, ...              % Number of range windows
    's_win',        875, ...            % Number of samples per range window
    's_diff',       325, ...            % Shift in each range window
    'f_wind',       [49, 108, 150, 193, 235; ...
                     125, 167, 210, 252, 311], ...
    ...                                 % Bin mins and maxes for frequency window
    'win_type',     'hanning', ...      % Window for doppler processing
    ...
    ... % Detection Properties
    'thresh',       10, ...             % Detection threshold above noise power in dB
...
    ... % Tracking Properties
    'wind_size',    [3; 3]);            % Size of averaging window in [x;y] direction 
    

% Set up Phased Array Toolbox system objects
scenario.sim = PhasedSetup_SEMTA(scenario);