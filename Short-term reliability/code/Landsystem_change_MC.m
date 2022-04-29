
function [X, X_irr] = Landsystem_change_MC(filename, n_runs, q, XE)

addpath('functions/');
range = 'C5:AF34';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading and Preparing Data
% Reading input data from the Excelsheet

% Mapping matrix for radiation on biome
M = xlsread(filename,'M','C5:L34');
M(isnan(M))=0;

%Transfer coefficient matrix
A_min = xlsread(filename,'A_min',range);
A_min(isnan(A_min)) = 0; % converting all NaN to 0

A_mode = xlsread(filename,'A_mode',range);
A_mode(isnan(A_mode)) = 0; % converting all NaN to 0

A_max = xlsread(filename,'A_max',range);
A_max(isnan(A_max)) = 0; % converting all NaN to 0

A_d = xlsread(filename,'A_d',range);
A_d(isnan(A_d)) = 0; % converting all NaN to 0

A = MCrand(A_min, A_mode, A_max, A_d, n_runs);

n = size(A_min,1);

for k=1:n_runs % balance check to rescale to 1
    for j=1:n
        s=sum(A(:,j,k));
        if ne(s,0)
            for i=1:n
                A(i,j,k)=A(i,j,k)/s;
            end
%         else
%             A(:,j,k)=A(:,j,k);
        end
    end
end

% Input vector
I_in = xlsread(filename,'Input','C5:F34');
I_in(isnan(I_in)) = 0; % converting all NaN to 0
I = MCrand(I_in(:,1), I_in(:,2), I_in(:,3), I_in(:,4), n_runs);



%solving [m�]
X = zeros(n,1,n_runs);
for k=1:n_runs
    X(:,1,k) = (eye(n)-A(:,:,k))\I(:,1,k);
end
X1 = X;     %keeping the original solution with dimension n

%Summing appropriable land
for j=1:n_runs
    Xa=0;
   for i=13:21
    Xa = Xa + X(i,1,j);
   end
   X(n+1,1,j)=Xa;
end
%Summing remaining land
for j=1:n_runs
    Xa=0;
   for i=22:n
    Xa = Xa + X(i,1,j);
   end
   X(n+2,1,j)=Xa;
end
%quantiles of solution
X_q = zeros(n+2,size(q,2));
for i=1:n+2
    X_q(i,:) = quantile(X(i,1,:),q);
end
%
% %display:
% Y=zeros(n,n_runs);
% for i=1:n+2         %Choose the range for the plot, default: 1:n
%     Y(i,:)=X(i,1,:);
% end
% [~,names,~] = xlsread(filename,'A_min','A5:A34');
%
% fig1=figure;         %   appropriable areas as fraction of land biome types
% hold on
% violin(Y(4:12,:)')
% violin(Y(13:21,:)')
% xlabel('categories')
% ylabel('area [m�]')
% %set(gca, 'YScale', 'log')
% axis([0 10 0 2.5*10^13])
% %line([0 n],[5.23e13 5.23e13]) %   land system change 2015
% %scatter([1:1:10],quantile(Y',0.01),'filled','d')
% for i=13:21
%     line([i-12-0.3 i-12+0.3],[quantile(Y(i,:),q(2)) quantile(Y(i,:),q(2))])
% end
% hold off
% legend('Location','eastoutside')
% fig1.PaperPositionMode = 'manual';
% orient(fig1,'landscape')
% print(fig1,'display/X_Land_violinplot','-dpdf','-bestfit')
%
% fig4=figure;         %   appropriable areas as fraction of total
% hold on
% Y1(1,:) = Y(1,:);    % total
% Y1(2,:) = Y(2,:) ;   % land
% Y1(3,:) = Y(31,:) ;  % appropriable land
% violin(Y1')
% xlabel('categories')
% ylabel('area [m�]')
% %set(gca, 'YScale', 'log')
% axis([0 4 0 6*10^14])
% line([0 4],[5.23e13 5.23e13]) %   land system change 2015
% line([3-0.3 3+0.3],[quantile(Y1(3,:),q(2)) quantile(Y1(3,:),q(2))])
% hold off
% legend('Location','eastoutside')
% fig4.PaperPositionMode = 'manual';
% %orient(fig4,'landscape')
% print(fig4,'display/X_Land_from total_violinplot','-dpdf','-bestfit')
%
%
% % fig3=figure;
% % boxplot(Y(4:n,:)',names(4:n),'PlotStyle','compact')
% % xlabel('categories')
% % ylabel('area [m�]')
% % %surf(peaks)
% % fig3.PaperPositionMode = 'manual';
% % %orient(fig3,'landscape')
% % print(fig3,'display/X_Land_boxplot','-dpdf','-fillpage')
%
% fig2=figure;
% for i=1:30
%     ah(i)=subplot(5,6,i);
%     histogram(Y(i,:))
%     xlabel(names(i))
% end
% %surf(peaks)
% fig2.PaperPositionMode = 'manual';
% orient(fig2,'landscape')
% print(fig2,'display/X_Land_histogramplot','-dpdf','-bestfit')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%translation into irradiation [W]

G_in = xlsread(filename,'G','C5:C14');
G_in(isnan(G_in)) = 0; % converting all NaN to 0
G = zeros(10,1,n_runs);
for i=1:10
    G(i,1,:)=G_in(i)*XE(4,1,:)/(1.28e14); % solar factor * radiation on surface / cross section area of earth [m�]
end
for i=1:n_runs
    Ma(:,:,i) = M(:,:)*G(:,:,i);        %    mapping vector
end

X_irr = Ma .* X1;

%Summing appropriable land
for j=1:n_runs
    Xa=0;
   for i=13:21
    Xa = Xa + X_irr(i,1,j);
   end
   X_irr(n+1,1,j)=Xa;
end
%Summing remaining land
for j=1:n_runs
    Xa=0;
   for i=22:n
    Xa = Xa + X_irr(i,1,j);
   end
   X_irr(n+2,1,j)=Xa;
end

X_q_irr = zeros(n+2,size(q,2));
for i=1:n+2
    X_q_irr(i,:) = quantile(X_irr(i,1,:),q);
end

%
% %display
% Y=zeros(n+2,n_runs);
% for i=1:n+2         %Choose the range for the plot, default: 1:n
%     Y(i,:)=X_irr(i,1,:);
% end
% [~,names,~] = xlsread(filename,'X_irr','A5:A36');
%
% fig4=figure;
% boxplot(Y(4:n,:)',names(4:n),'OutlierSize',0.1,'Symbol','+','PlotStyle','compact')
% xlabel('categories')
% ylabel('irradiation [W]')
% fig4.PaperPositionMode = 'manual';
% %orient(fig3,'landscape')
% print(fig4,'display/X_irr_Land_boxplot','-dpdf','-fillpage')

%save data
xlswrite(filename, q, 'X','C3');
xlswrite(filename, q, 'X_irr','C3');
xlswrite(filename, X_q, 'X','C5');
xlswrite(filename, X_q_irr, 'X_irr','C5');

save('results/X_Land.mat','X');
save('results/X_irr_Land.mat','X_irr');

end
%%%
