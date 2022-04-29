

function [A] = MCrand(A_min, A_mode, A_max, A_d ,n_runs)

[n1, n2] = size(A_min);


A = zeros(n1,n2,n_runs);

for j=1:n2
    for i=1:n1
%         if i==j
%             A(i,j,:)=1;
%         else
        if(A_d(i,j)==1) % beta-PERT distribution
            if(A_min(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            elseif (A_max(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            else
                A(i,j,:)= A_min(i,j)+(A_max(i,j)-A_min(i,j))*betarnd((4*A_mode(i,j)+A_max(i,j)-5*A_min(i,j))/(A_max(i,j)-A_min(i,j)),(5*A_max(i,j)-A_min(i,j)-4*A_mode(i,j))/(A_max(i,j)-A_min(i,j)),n_runs,1);
            end
        end

        if (A_d(i,j)==2) % triangular distribution
            if(A_min(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            elseif (A_max(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            else
            A(i,j,:)= random(makedist('Triangular','a',A_min(i,j),'b',A_mode(i,j),'c',A_max(i,j)),n_runs,1);
            end
        end

        if (A_d(i,j)==3) % normal distribution
            if(A_min(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            elseif (A_max(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            else
            A(i,j,:)= normrnd(A_mode(i,j),((A_max(i,j)-A_mode(i,j))/3),n_runs,1);
            end
        end

        if (A_d(i,j)==4) % lognormal distribution
            if(A_min(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            elseif (A_max(i,j)==A_mode(i,j))
                A(i,j,:)=A_mode(i,j);
            else
            A(i,j,:)= lognrnd(log(A_mode(i,j)),((log(A_max(i,j))-log(A_mode(i,j)))/3),n_runs,1);
            end
        end

        if (A_d(i,j)==5) % rectangular distribution
            if(A_min(i,j)==A_max(i,j))
                A(i,j,:)=A_min(i,j);
            else
            A(i,j,:)= random(makedist('Uniform','lower',A_min(i,j),'upper',A_max(i,j)),n_runs,1);
            end
        end
    end
    for i=1:n1
        if (A_d(i,j)==6) % balance check variable
            for k=1:n_runs
                if sum(A(:,j,k))<1
                    A(i,j,k)= 1 - sum(A(:,j,k));
                else
                    A(i,j,k)= 0;
                end
            end
        end
    end
end

end
