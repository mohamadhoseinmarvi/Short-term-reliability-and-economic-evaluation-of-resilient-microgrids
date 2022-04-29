% Bioenergy
% clc
% clear variables
% load('Simulation_parameter.mat')
% load('results/X_Land.mat')


function E_wood = BioE(filename, n_runs, q, X)
addpath('functions/');

% Forests

Area_F = sum(X(22:24,1,:),1);

factorF = prod(MCrand2(xlsread(filename,'BioE','E16:H20'),n_runs),1); 

Wood_removal = factorF .* Area_F;

f_residues = sum(MCrand2(xlsread(filename,'BioE','E21:H22'),n_runs),1);

Wood_residues = f_residues .* Wood_removal;
Wood_sawn = Wood_removal - Wood_residues;

Wood_to_energy = prod(MCrand2(xlsread(filename,'BioE','E24:H25'),n_runs),1)/(3600*24*365);

eta_th = MCrand2(xlsread(filename,'BioE','E28:H28'),n_runs);

E_wood = eta_th .* Wood_to_energy .* Wood_removal; %Wood_residues;

save('results/E_bio.mat','E_wood');
xlswrite(filename, quantile(E_wood(1,1,:),q),'BioE','C70');

end
%%%