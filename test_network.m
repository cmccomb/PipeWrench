% Initialize a network and set the properties
net = FluidNetwork();
net.dynamic_viscosity = 1.3*10^-3;

% Add junctions to the network
net.add_junction('1',  0, 0, 'pressure', 40000);
net.add_junction('2',  0, 10);
net.add_junction('3', 20, 10);
net.add_junction('4',  0, 20);
net.add_junction('5', 10, 20);
net.add_junction('6', 20, 20);
net.add_junction('7',  0, 30, 'pressure', 0);
net.add_junction('8', 10, 30, 'pressure', 0);
net.add_junction('9', 20, 30, 'pressure', 0);
net.add_junction('10', 2, 2);

% Add pipes to connect the junctions
net.add_pipe('A', '1', '2', 'diameter', 0.1);
net.add_pipe('B', '2', '3', 'diameter', 0.05);
net.add_pipe('C', '2', '4', 'diameter', 0.05);
net.add_pipe('D', '3', '6', 'diameter', 0.05);
net.add_pipe('E', '4', '5', 'diameter', 0.05);
net.add_pipe('F', '5', '6', 'diameter', 0.05);
net.add_pipe('G', '4', '7', 'diameter', 0.05);
net.add_pipe('H', '5', '8', 'diameter', 0.05);
net.add_pipe('I', '6', '9', 'diameter', 0.05);
net.add_pipe('J', '1', '9', 'diameter', 0.05);
net.add_pipe('K', '10', '9', 'diameter', 0.05);

% Test deletions
net.delete_pipe('J');
net.delete_junction('10');


% Solve it
net.solve();

% Check mass conservation
assert(  net.get('A', 'flow_rate') ...
       - net.get('G', 'flow_rate') ...
       - net.get('H', 'flow_rate') ...
       - net.get('I', 'flow_rate') < 2*eps);