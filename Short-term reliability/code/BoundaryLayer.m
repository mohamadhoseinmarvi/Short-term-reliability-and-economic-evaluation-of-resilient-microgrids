


function [f] = BoundaryLayer(Input ,n_runs)

%Tower height [m]
H = MCrand(Input(1,1),Input(1,2),Input(1,3),Input(1,4),n_runs);

%rotor diameter [m]
D = MCrand(Input(2,1),Input(2,2),Input(2,3),Input(2,4),n_runs);

%Boundary layer thickness [m]
delta = MCrand(Input(3,1),Input(3,2),Input(3,3),Input(3,4),n_runs);

% surface roughness [m]
z_0 = MCrand(Input(4,1),Input(4,2),Input(4,3),Input(4,4),n_runs);

%upper and lower rotor height
a = H-D./2;
b = H+D./2;

% power factor = power in roter sept area / power in boundary layer
for i=1:n_runs
    fun = @(z) (log(z/z_0(:,:,i))).^3;           % log is the function for ln!
    f(1,1,i) = abs(integral(fun,a(:,:,i),b(:,:,i))/integral(fun,0,delta(:,:,i)));
end

end
