function [h, q] = pipe_network(sys)

    %% Break parameters out of structure for ease
    rho = sys.rho;                                         % Density of water, [kg/m^3]
    g = sys.g;                                             % Gravitational constant, [m/s^2]
    u = sys.u;                                             % Dynamic viscosity of water, [Pa-s]
    P = reshape(sys.P, 1, length(sys.P));                  % Known nodal pressures (Inf represents an unknown), [Pa]
    L = sys.L;                                             % Element lengths, [m]
    D = sys.D;                                             % Element diameters, [m]
    A = sys.A;                                             % Nodal adjacency list
    NE = length(D);                						   % Number of elements
    NN = max(A(:));                                        % Number of nodes

    %% Initialize things to be used later
    R = zeros(1,NE);             					       % Element resistances
    K = zeros(NN, NN);                                     % Global stiffness matrix
    h = zeros(1,NE);                                       % Elemental hes
    q = zeros(1,NE);                                       % Flow rate in different elements

    %% Define equations for things
    resistance = @(LL, DD, uu) (pi*DD^4)/(128*LL*uu);      % Resistance, based on https://en.wikipedia.org/wiki/Hagen%E2%80%93Poiseuille_equation
    flowrate = @(PP1, PP2, RR) (PP1-PP2)*RR;               % Flow rate based on pressure and resistance
    elem = @(R) [R, -R; -R, R];                            % Element stiffness matrix
    headloss = @(QQ, RR) QQ/(rho*g*RR);                    % A function to compute the loss in an element

    %% Build the global stiffness matrix and apply boundary conditions
    for i=1:1:NE                                           % Step through every element
        R(i) = resistance(L(i), D(i), u);                  %     Compute the resistance
        temp = elem(R(i));                                 %     Create a temporary elemental stiffness matrix
        K(A(i,:), A(i,:)) = K(A(i,:), A(i,:)) + temp;      %     Add the temporary matrix to the global matrix
    end                                                    %
    for i=1:1:NN                                           % Step through every node
        if ~isinf(P(i))                                    %     If the pressure is known
            K(i,:) = zeros(1, NN);                         %         Zero out that row in the global stiffness matrix
            K(i, i) = 1;                                   %         Place a 1 on the diagonal
        else                                               %     If the pressure is unknown
            P(i) = 0;                                      %         Make it a 0 to prepare for solving the matrix.
        end                                                %
    end                                                    %

    %% Solve the matrix and find the elemental information
    p = (K\P)';                                            % Solve the matrix for all pressure values
    for i=1:1:NE                                           % Step through every element
        p1 = p(A(i,1));                                    %     Pull out the entering pressure
        p2 = p(A(i,2));                                    %     Pull out the exiting pressure
        q(i) = flowrate(p1, p2, R(i));                     %     Compute the flow rate
        h(i) = headloss(q(i), R(i));                       %     Compute the head loss
    end
end
