function [multi] = TargetTracking_SEMTA(scenario)
%TARGETTRACKING_SEMTA Performs radar target tracking for SEMTA project
%   Takes radar scenario object as input, returns modified scenario.multi
%   as output.

%% Unpack Variables

multi = scenario.multi;
simsetup = scenario.simsetup;

%% Apply Tracking

switch multi.track_method
    
    case 'Moving Average'
        % Moving Average Filter Smoothing
        for dim = 1:2
            multi.track_points(dim,:) = movmean(multi.lat_points(dim,:), simsetup.wind_size(dim));
        end
        
    case 'None'
        % No Track Filter Applied
        multi.track_points = multi.lat_points;
end

end

