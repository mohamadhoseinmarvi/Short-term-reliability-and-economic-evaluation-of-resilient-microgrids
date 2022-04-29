
function XE = Solar_MC(filename, n_runs, q)

addpath('functions/');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading and Preparing Data
% Reading input data from the Excelsheet

%Transfer coefficient matrix
AE_min = xlsread(filename,'Solar','C27:F30');
AE_min(isnan(AE_min)) = 0; % converting all NaN to 0

AE_mode = xlsread(filename,'Solar','C36:F39');
AE_mode(isnan(AE_mode)) = 0; % converting all NaN to 0

AE_max = xlsread(filename,'Solar','C45:F48');
AE_max(isnan(AE_max)) = 0; % converting all NaN to 0

AE_d = xlsread(filename,'Solar','C54:F57');
AE_d(isnan(AE_d)) = 0; % converting all NaN to 0

n = size(AE_min,1);

AE = MCrand(AE_min, AE_mode, AE_max, AE_d, n_runs);

for k=1:n_runs % balance check to rescale to 1
    for j=1:n
        s=sum(AE(:,j,k));
        if ne(s,0)
            for i=1:n
                AE(i,j,k)=AE(i,j,k)/s;
            end
%         else
%             A(:,j,k)=A(:,j,k);
        end
    end
end

%Input vector
IE_min = xlsread(filename,'Solar','C61:C64');
IE_min(isnan(IE_min)) = 0; % converting all NaN to 0

IE_mode = xlsread(filename,'Solar','D61:D64');
IE_mode(isnan(IE_mode)) = 0; % converting all NaN to 0

IE_max = xlsread(filename,'Solar','E61:E64');
IE_max(isnan(IE_max)) = 0; % converting all NaN to 0

IE_d = xlsread(filename,'Solar','F61:F64');
IE_d(isnan(IE_d)) = 0; % converting all NaN to 0

IE = MCrand(IE_min, IE_mode, IE_max, IE_d, n_runs);

%solving [W]
XE=zeros(n,1,n_runs);
for k=1:n_runs
    XE(:,1,k) = (eye(n)-AE(:,:,k))\IE(:,1,k);
end

%quantiles of solution
XE_q=zeros(n,size(q,2));
for i=1:n
    XE_q(i,:) = quantile(XE(i,1,:),q);
end

%save data
xlswrite(filename, q, 'Solar','C67');
xlswrite(filename, XE_q, 'Solar','C69');

save('results/X_solar.mat','XE');

end
%%%
