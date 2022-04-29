% hydro energy
% clc
% clear variables
% load('Simulation_parameter.mat')

function [E_hydro, E_FO, E_tide] = HydroE(filename, n_runs, q)
addpath('functions/');

% Withdrawal boundary
Withdrawal_boundary = MCrand2(xlsread(filename,'HydroE','E16:H16'),n_runs);

% allocation of withdrawal boundary to hydro and FO
hydro_share = MCrand2(xlsread(filename,'HydroE','E17:H17'),n_runs);
FO_share = ones(1,1,n_runs) - hydro_share;

%%% Hydro power
% potential energy in rivers
River_pot = MCrand2(xlsread(filename,'HydroE','E12:H12'),n_runs);

% factors for hydro power
factor_hydro = Withdrawal_boundary .* hydro_share .* prod(MCrand2(xlsread(filename,'HydroE','E18:H20'),n_runs),1);

% electricity from hydro
E_hydro = factor_hydro .* River_pot;

%%% Forward Osmosis
% rivers runoff
River_flow = MCrand2(xlsread(filename,'HydroE','E11:H11'),n_runs);

% mixing free energy of water
mix_E = MCrand2(xlsread(filename,'HydroE','E25:H25'),n_runs);

% factors for forward osmosis
factor_FO = Withdrawal_boundary .* FO_share .* MCrand2(xlsread(filename,'HydroE','E29:H29'),n_runs);

% electricity from FO
E_FO = factor_FO .* mix_E .* River_flow;


%%% tide
% tide energy
Tide = MCrand2(xlsread(filename,'HydroE','E33:H33'),n_runs);
% factors for forward osmosis
factor_tide = prod(MCrand2(xlsread(filename,'HydroE','E34:H37'),n_runs),1);
% electricity from tide
E_tide = factor_tide .* Tide;


save('results/E_hydro.mat','E_hydro','E_FO', 'E_tide');

A=zeros(3,size(q,2));  
    A(1,:) = quantile(E_hydro(1,1,:),q);
    A(2,:) = quantile(E_FO(1,1,:),q);
    A(3,:) = quantile(E_tide(1,1,:),q);

xlswrite(filename, A,'HydroE','C43');


end
%%%