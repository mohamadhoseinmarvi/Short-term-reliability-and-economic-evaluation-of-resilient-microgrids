% Solar energy
function E_solar = Solar_energy_conversion(filename, n_runs, q, s, LandUse_irr)

% load('results/X_Land.mat')
% load('results/X_irr_Land.mat')
% load('results/LandUse.mat')
[n,~,~,~]=size(LandUse_irr);

addpath('functions/');
% solar energy conversion on built environment

Efficiency_solar_built = MCrand2(xlsread(filename,'SolarE','E4:H8'),n_runs);
eta_built = prod(Efficiency_solar_built,1);     %   overall efficieny as a product of elements within columns

Efficiency_solar_desert = MCrand2(xlsread(filename,'SolarE','E15:H19'),n_runs);
eta_desert = prod(Efficiency_solar_desert,1);     %   overall efficieny as a product of elements within columns

% electricity from solar
E_solar = zeros(n,1,n_runs,s);
for o=1:s
    for i=1:n
        E_solar(i,1,:,o)= eta_built(1,1,:).*LandUse_irr(i,3,:,o);
    end
    
    E_solar(7,1,:,o)= eta_desert(1,1,:).*LandUse_irr(7,3,:,o);
end
E_solar_q = quantile(E_solar,q,3);

% save results
save('results/E_solar.mat','E_solar');

A=zeros(n,size(q,2)); B=A; C=A;
for i=1:n
    A(i,:) = quantile(E_solar(i,1,:,1),q,3);
    B(i,:) = quantile(E_solar(i,1,:,2),q,3);
    C(i,:) = quantile(E_solar(i,1,:,3),q,3);
end

xlswrite(filename, A,'SolarE','C26');
xlswrite(filename, B,'SolarE','J26');
xlswrite(filename, C,'SolarE','Q26');


% display
Y=zeros(3*n,n_runs);
for i=1:n         %Choose the range for the plot, default: 1:n
    Y(i,:)=E_solar(i,1,:,1);
end
for i=(n+1):(2*n)         
    Y(i,:)=E_solar((i-n),1,:,2);
end
for i=(2*n+1):(3*n)         
    Y(i,:)=E_solar((i-2*n),1,:,3);
end
% 
% fig1=figure;         %   appropriable areas as fraction of land biome types
% hold on
% violin(Y')
% xlabel('categories')
% ylabel('electricity [W]')
% %set(gca, 'YScale', 'log')
% %axis([0 10 0 2.5*10^13])
% %line([0 n],[5.23e13 5.23e13]) %   land system change 2015
% %scatter([1:1:10],quantile(Y',0.01),'filled','d')
% for i=1:3*n
%     line([i-0.3 i+0.3],[quantile(Y(i,:),q(2)) quantile(Y(i,:),q(2))])
% end
% hold off
% legend('Location','eastoutside')
% fig1.PaperPositionMode = 'manual';
% orient(fig1,'landscape')
% print(fig1,'display/E_solar_violinplot','-dpdf','-bestfit')


Y2=zeros(6,n_runs);
for i=1:6
    Y2(1,:) = Y2(1,:) + Y(i,:);   % sum of distributions
end
Y2(2,:) = E_solar(7,1,:,1);     %   desert infrastructure
for i=1:6
    Y2(3,:) = Y2(3,:) + Y(i+n,:);
end
Y2(4,:) = E_solar(7,1,:,2);
for i=1:6
    Y2(5,:) = Y2(5,:) + Y(i+2*n,:);
end
Y2(6,:) = E_solar(7,1,:,3);


Y2_limit = zeros(6,1);
for i=1:6
    Y2_limit(1) = Y2_limit(1) + E_solar_q(i,1,2,1); %   sum of 0,01 quantiles of individual distributions
end
Y2_limit(2) = E_solar_q(7,1,2,1);
for i=1:6
    Y2_limit(3) = Y2_limit(3) + E_solar_q(i,1,2,2);
end
Y2_limit(4) = E_solar_q(7,1,2,2);
for i=1:6
    Y2_limit(5) = Y2_limit(5) + E_solar_q(i,1,2,3);
end
Y2_limit(6) = E_solar_q(7,1,2,3);


% fig2=figure;         %   appropriable areas as fraction of land biome types
% hold on
% violin(Y2')
% xlabel('scenarios for infrastructure and desert infrastructure')
% ylabel('electricity [W]')
% set(gca, 'YScale', 'log')
% %axis([0 10 0 2.5*10^13])
% %line([0 n],[5.23e13 5.23e13]) %   land system change 2015
% %scatter([1:1:10],quantile(Y',0.01),'filled','d')
% for i=1:6
%     line([i-0.3 i+0.3],[quantile(Y2(i,:),q(2)) quantile(Y2(i,:),q(2))],'color','r')
%     line([i-0.3 i+0.3],[Y2_limit(i) Y2_limit(i)])
% end
% hold off
% legend('Location','eastoutside')
% fig2.PaperPositionMode = 'manual';
% orient(fig2,'landscape')
% print(fig2,'display/E_solar_violinplot2','-dpdf','-bestfit')


end
%%%