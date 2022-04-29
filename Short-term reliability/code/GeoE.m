% geothermal energy
% clc
% clear variables
% load('Simulation_parameter.mat')
% load('results/X_Land.mat')

function [E_geo, E_OTEC] = GeoE(filename, n_runs, q, X)
addpath('functions/');
%%% Geothermal power

% geothermal heat flux
Geo = MCrand2(xlsread(filename,'GeoE','E4:H4'),n_runs);

% land to total area fraction
f_land = X(2,1,:) ./ X(1,1,:);

% fraction of heat flux with sufficiently high temperature gradient
f_heat = MCrand2(xlsread(filename,'GeoE','E6:H6'),n_runs);

% Carnot efficiency
T = MCrand2(xlsread(filename,'GeoE','E7:H8'),n_runs);
eta_C = 1- T(2,1,:) ./ T(1,1,:);
%histogram(eta_C)

% practical / theroretical efficiency
eta_real = MCrand2(xlsread(filename,'GeoE','E10:H10'),n_runs);

%electricity from geothermal
E_geo = eta_real .* eta_C .* f_heat .* f_land .* Geo;


%Ocean thermal energy conversion
OceanT = MCrand2(xlsread(filename,'GeoE','E14:H14'),n_runs);

% fraction of heat flux technically accessible
f_t = MCrand2(xlsread(filename,'GeoE','E15:H15'),n_runs);

% Carnot efficiency
T = MCrand2(xlsread(filename,'GeoE','E16:H17'),n_runs);
eta_C_OTEC = 1- T(2,1,:) ./ T(1,1,:);


% practical / theroretical efficiency
eta_realOTEC = MCrand2(xlsread(filename,'GeoE','E19:H19'),n_runs);

%electricity from geothermal
E_OTEC = eta_realOTEC .* eta_C_OTEC .* f_t .* OceanT;




save('results/E_geo.mat','E_geo','E_OTEC');
xlswrite(filename, quantile(E_geo(1,1,:),q),'GeoE','C24');
xlswrite(filename, quantile(E_OTEC(1,1,:),q),'GeoE','C25');

end
%%%
