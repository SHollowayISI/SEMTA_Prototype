function [cube] = SignalProcessing_SEMTA(scenario)
%SIGNALPROCESSING_SEMTA Performs signal processing for SEMTA
%   Takes scenario struct as input, retuns scenario.cube struct containing
%   processed Range-Doppler cube

%% Unpack Variables

simsetup = scenario.simsetup;

%% Define Constants

c = physconst('LightSpeed');
lambda = c/simsetup.f_c;

%% Perform Range FFTs

% Allocate cube for speed
range_ffts = zeros(simsetup.s_win, simsetup.n_win, simsetup.n_p);

% Split Rx signal into time slices
for r_slice = 1:simsetup.n_win
    
    % Allocate each range window slice
    range_ffts(:,r_slice,:) = scenario.rx_sig( ...
        ((r_slice-1)*simsetup.s_diff + 1):((r_slice-1)*simsetup.s_diff + simsetup.s_win),:);

end

% Calculate FFT size
N_r = 2^ceil(log2(simsetup.s_win));

% Perform FFTs
range_ffts = fft(range_ffts, N_r, 1);

% Set up frequency window variables
f_wind = sort(simsetup.f_wind(:));
cube.range_cube = squeeze(range_ffts(1,1,:))';

% Apply frequency windows
for wind_n = 1:(numel(simsetup.f_wind)-1)
    
    r_slice = ceil(wind_n/2);
    
    if mod(wind_n,2) == 1
        % Take cube values from non-overlapping frequency windows
        cube.range_cube = [cube.range_cube; ...
            squeeze(range_ffts((f_wind(wind_n)+1):(f_wind(wind_n+1)-1),r_slice,:))];
        
    else
        % Average cube values from overlapping frequency windows
        cube.range_cube = [cube.range_cube; ...
            squeeze(mean(range_ffts(f_wind(wind_n):f_wind(wind_n+1), ...
            [r_slice, r_slice+1],:),2))];
        
    end
    
end

% Include final range slice
cube.range_cube = [cube.range_cube; squeeze(range_ffts(end,end,:))'];

%% Perform Doppler FFT

% Calculate FFT size
N_d = 2^ceil(log2(size(cube.range_cube,2)));

% Apply windowing
expression = '(size(cube.range_cube,2))).*cube.range_cube;';
expression = ['transpose(', simsetup.win_type, expression];
cube.rd_cube = eval(expression);

% FFT across slow time dimension
cube.rd_cube = fftshift(fft(cube.rd_cube, N_d, 2), 2);

% Wrap max negative frequency and positive frequency
cube.rd_cube = [cube.rd_cube, cube.rd_cube(:,1)];

%% Calculate Square Power Cube

% Take square magnitude of radar cube
cube.pow_cube = abs(cube.rd_cube).^2;

%% Derive Axes

% Derive Range axis
cube.range_res = (c/2)*(simsetup.f_s/N_r)*(simsetup.t_ch/simsetup.bw);
cube.range_axis = cube.range_res*((f_wind(1):f_wind(end))-1);

% Derive Doppler axis
cube.vel_res = lambda*(simsetup.prf/2)/(2*simsetup.n_p);
% NOTE: PRF divided by two due as it currently stands for chirp rate
cube.vel_axis = -cube.vel_res*((-N_d/2):(N_d/2));

end

