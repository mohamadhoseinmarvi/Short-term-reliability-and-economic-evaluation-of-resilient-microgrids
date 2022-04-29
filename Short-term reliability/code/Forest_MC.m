
% clc
% clear variables
% load('results/X_Land.mat');
% load('Simulation_parameter.mat')

function XF = Forest_MC(filename, n_runs, q, X)
addpath('functions/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading and Preparing Data
% Reading input data from the Excelsheet

%Transfer coefficient matrix
F_min = xlsread(filename,'SusForest','C41:I47');
F_min(isnan(F_min)) = 0; % converting all NaN to 0

F_mode = xlsread(filename,'SusForest','C53:I59');
F_mode(isnan(F_mode)) = 0; % converting all NaN to 0

F_max = xlsread(filename,'SusForest','C65:I71');
F_max(isnan(F_max)) = 0; % converting all NaN to 0

F_d = xlsread(filename,'SusForest','C77:I83');
F_d(isnan(F_d)) = 0; % converting all NaN to 0

F = MCrand(F_min, F_mode, F_max, F_d, n_runs);


%Creating an input vector from Landsystem change MC result
n = size(F_min,1);
IF=zeros(n,1,n_runs);
IF(1,1,:) = X(22,1,:)+X(23,1,:)+X(24,1,:);



%solving [W]
XF = zeros(n,1,n_runs);
for k=1:n_runs
    XF(:,1,k) = (eye(n)-F(:,:,k))\IF(:,1,k);
end

%quantiles of solution
XF_q = zeros(n,size(q,2));
for i=1:n
    XF_q(i,:) = quantile(XF(i,1,:),q);
end

%save data
xlswrite(filename, q, 'SusForest','C88');
xlswrite(filename, XF_q, 'SusForest','C90');
save('results/X_Forest.mat','XF');

end
%%%%
