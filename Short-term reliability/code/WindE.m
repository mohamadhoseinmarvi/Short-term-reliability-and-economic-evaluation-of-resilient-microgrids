
% clc
% clear variables
% load('Simulation_parameter.mat')
% load('results/X_Land.mat')
% load('results/LandUse.mat')

function [E_wind, E_wave] = WindE(filename, n_runs, q, s, X, LandUse, LandUse_irr)
[n,~,~,~]=size(LandUse_irr);

addpath('functions/');

% wind power in atmosphere
Wind_atm = MCrand2(xlsread(filename,'WindE','E4:H4'),n_runs);

% accessible ocean surface
Coastal_area = prod(MCrand2(xlsread(filename,'WindE','E7:H8'),n_runs),1);     %   coastline * accessible distance offshore

Area_appr = sum(LandUse(:,1:2,:,:),2); % summing the land use types: pasture + cropland
for o=1:s
    Area_appr(n+1,1,:,o) = Coastal_area;
end
n2 = size(Area_appr,1);

% area useable for wind parks
Park_area_factor = MCrand2(xlsread(filename,'WindE','E12:H21'),n_runs);

Park_area = zeros(n2,1,n_runs,s);
for o=1:s
    Park_area(:,1,:,o) = Park_area_factor .*Area_appr(:,:,:,o);
end

Wind_park = zeros(n2,1,n_runs,s);
for o=1:s % wind on park area = park area/total surface area * wind in atmosphere
    for i=1:n2
        Wind_park(i,1,:,o) = Park_area(i,1,:,o)./X(1,1,:).*Wind_atm(1,1,:);
    end
end

% boundary layer factor onshore and offshore
f_BL_on = BoundaryLayer(xlsread(filename,'WindE','E24:H27'),n_runs);
f_BL_off = BoundaryLayer(xlsread(filename,'WindE','E33:H36'),n_runs);

%overall efficiency = power fraction in boundary layer * aerodynamic
%efficiency * electric & mechanic efficiency
eta_wind = prod(MCrand2(xlsread(filename,'WindE','E42:H44'),n_runs),1);

% electricity from wind
E_wind = zeros(n2,1,n_runs,s);
for o=1:s
    for i=1:n
        E_wind(i,1,:,o) = eta_wind(1,1,:) .* f_BL_on(1,1,:) .* Wind_park(i,1,:,o);
    end
    E_wind(n2,1,:,o) = eta_wind(1,1,:) .* f_BL_off(1,1,:) .* Wind_park(n2,1,:,o);
end


%%% wave
% fraction of wave / wind energy total
Wave = MCrand2(xlsread(filename,'WindE','E52:H52'),n_runs);
eta_wave = prod(MCrand2(xlsread(filename,'WindE','E53:H55'),n_runs),1);

E_wave = eta_wave .* Wave;



save('results/E_wind.mat','E_wind','E_wave');

A=zeros(n,size(q,2)); B=A; C=A;
for i=1:n2
    A(i,:) = quantile(E_wind(i,1,:,1),q,3);
    B(i,:) = quantile(E_wind(i,1,:,2),q,3);
    C(i,:) = quantile(E_wind(i,1,:,3),q,3);
end

xlswrite(filename, A,'WindE','C61');
xlswrite(filename, B,'WindE','J61');
xlswrite(filename, C,'WindE','Q61');
xlswrite(filename, quantile(E_wave(1,1,:),q),'WindE','C75');

end
%%%
