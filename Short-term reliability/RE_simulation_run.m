
tic

n_runs = 100000;
filename = 'SM_Renewable_energy_calculation.xlsx';
q = [0.00135 0.01 0.25 0.5 0.75 0.99 0.99865];      %   +-3 sigma; 1% as cut off criteria, quartile, median
s = 3;

addpath('code');

% calculating energy flow through the earth system
X_solar = Solar_MC(filename, n_runs, q);

% calculating maximum sustainable land system change
[X_land, X_irr_land] = Landsystem_change_MC(filename, n_runs, q, X_solar);

% dividing land to land use scenarios
[LandUse, LandUse_irr, LandScenarios] = LandUseScenario(filename, n_runs, q, s, X_land, X_irr_land);

% Energy conversion

% solar energy
E_solar = Solar_energy_conversion(filename, n_runs, q, s, LandUse_irr);

% Bio energy
%X_forest = Forest_MC(filename, n_runs, q, X_land);
E_bio = BioE(filename, n_runs, q, X_land);

% geothermal and ocean thermal energy
[E_geo, E_OTEC] = GeoE(filename, n_runs, q, X_land);

% hydro, tide and forward osmosis energy
[E_hydro, E_FO, E_tide] = HydroE(filename, n_runs, q);

% on/offshore wind and wave energy
[E_wind, E_wave] = WindE(filename, n_runs, q, s, X_land, LandUse, LandUse_irr);

E_total = sum(E_solar(:,1,:,3),1) + E_bio + E_geo + E_OTEC + E_hydro + E_FO + E_tide + sum(E_wind(:,1,:,3),1) + E_wave;

E_total_wo_desert = sum(E_solar(1:6,1,:,3),1) + E_bio + E_geo + E_OTEC + E_hydro + E_FO + E_tide + sum(E_wind(1:6,1,:,3),1)+sum(E_wind(8:end,1,:,3),1) + E_wave;

% world population prospect in 2100
N_2100 = MCrand2(xlsread(filename,'results','C110:F110'),n_runs);
% per capita electricity provision potential
e_total = E_total ./ N_2100;
e_total_wo_desert = E_total_wo_desert ./ N_2100;

save('results/e_per_capita.mat','e_total','e_total_wo_desert');

e_total_99(1,:) = quantile(e_total,q,3);
e_total_wo_desert_99(1,:) = quantile(e_total_wo_desert,q,3);

xlswrite(filename, e_total_99,'results','C112');
xlswrite(filename, e_total_wo_desert_99,'results','C113');


toc
