
function [LandUse, LandUse_irr, LandScenarios]=LandUseScenario(filename, n_runs, q, s, X, X_irr)

% load('results/X_Land.mat')
% load('results/X_irr_Land.mat')

addpath('functions/');

LandScenario1 = xlsread(filename,'LandUse','M4:O12');
LandScenario1(isnan(LandScenario1)) = 0; % converting all NaN to 0

LandScenario2 = xlsread(filename,'LandUse','M34:O42');
LandScenario2(isnan(LandScenario2)) = 0; % converting all NaN to 0

LandScenario3 = xlsread(filename,'LandUse','M51:O59');
LandScenario3(isnan(LandScenario3)) = 0; % converting all NaN to 0

[n,m]=size(LandScenario1);


% LandScenarios(biome, land use type, 1, scenario)
LandScenarios(:,:,1,1)= LandScenario1;
LandScenarios(:,:,1,2)= LandScenario2;
LandScenarios(:,:,1,3)= LandScenario3;

% appropriable values in row 13 to 21
X_appr = X(13:21,:,:);
X_irr_appr = X_irr(13:21,:,:);

% division into cropland, pasture and infrastructure
% LandUse(biome, land use type, n_runs, scenario)
LandUse = zeros(n,m,n_runs ,s);
LandUse_irr = zeros(n,m,n_runs ,s);
for o=1:s
    for i=1:m
         LandUse(:,i,:,o) = LandScenarios(:,i,1,o).*X_appr;
    end
end
for o=1:s
    for i=1:m
         LandUse_irr(:,i,:,o) = LandScenarios(:,i,1,o).*X_irr_appr;
    end
end

% LandUse_q(biome, land use type, qunatiles, scenario)
LandUse_q = zeros(n,m,size(q,2),s);
LandUse_irr_q = zeros(n,m,size(q,2),s);
for o=1:s
    for i=1:n
        for j=1:m
            LandUse_q(i,j,:,o) = quantile(LandUse(i,j,:,o),q);
        end
    end
end
for o=1:s
    for i=1:n
        for j=1:m
            LandUse_irr_q(i,j,:,o) = quantile(LandUse_irr(i,j,:,o),q);
        end
    end
end

save('results/LandUse.mat','LandUse','LandUse_irr', 'LandScenarios')

end
%%%
