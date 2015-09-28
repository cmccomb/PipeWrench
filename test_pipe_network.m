%% Finite Element Analysis, Theory and Application with ANSYS

%% The fluid system
%
%   (#) Indicates a node
%   [#] Indicates an element
%
%	   |(1)
%      │
%      │[1]
%      │
%      │(2)        [2]
%      ├───────────────────┐(3)
%      │                   │
%      │                   │
%      │                   │
%      │[3]                │[4]
%      │                   │
%      │                   │
%      │   [5] (5)    [6]  │
%   (4)├────────┬──────────┤
%	   │        │       (6)│      
%      │        │          │      
%   [7]│     [8]│       [9]│      
%      │        │          │      
%      │(7)     │(8)       │(9)

%% Define parameters
system.rho = 1000;                                          % Density of water, [kg/m^3]
system.g = 9.81;                                            % Gravitational constant, [m/s^2]
system.u = 1.3*10^-3;                                       % Dynamic viscosity of water, [Pa-s]
system.P = [39182, Inf, Inf, Inf, Inf, Inf, 0, 0, 0];       % External nodal pressures (Inf represents an unknown), [Pa]
system.L = [10, 10, 10, 10, 10, 10, 10, 10, 10];            % Element lengths, [m]
system.D = [5, 5, 5, 5, 5, 5, 5, 5, 5]/100;                 % Element diameters, [m]
system.A = [1 2; 2 3; 2 4; 3 6; 4 5; 5 6; 4 7; 5 8; 6 9];   % Nodal adjacency list

[h, q] = pipe_network(system);

%% Verify the results 
assert(h(2) + h(4) - h(6) - h(5) - h(3) <= 2*eps);          % Check energy conservation around the loop
assert(q(1) - q(2) - q(3) <= 2*eps);                        % Check mass conservation at a junction
assert(q(3) - q(5) - q(7) <= 2*eps);                        % Check mass conservation at a junction
assert(q(5) - q(6) - q(8) <= 2*eps);                        % Check mass conservation at a junction
assert(q(4) + q(6) - q(9) <= 2*eps);                        % Check mass conservation at a junction
assert(q(1) - q(7) - q(8) - q(9) <= 2*eps);                 % Check mass conservation for the whole system

