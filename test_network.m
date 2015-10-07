% Initialize a network and set the properties
N = FluidNetwork();
N.dynamic_viscosity = 1.3*10^-3;

% Add junctions to the network
N.add_junction('1',  0, 0, 'pressure', 40000);
N.add_junction('2',  0, 10);
N.add_junction('3', 20, 10);
N.add_junction('4',  0, 20);
N.add_junction('5', 10, 20);
N.add_junction('6', 20, 20);
N.add_junction('7',  0, 30, 'pressure', 0);
N.add_junction('8', 10, 30, 'pressure', 0);
N.add_junction('9', 20, 30, 'pressure', 0);

% Add pipes to connect the junctions
N.add_pipe('A', '1', '2', 'diameter', 0.05);
N.add_pipe('B', '2', '3', 'diameter', 0.05);
N.add_pipe('C', '2', '4', 'diameter', 0.05);
N.add_pipe('D', '3', '6', 'diameter', 0.05);
N.add_pipe('E', '4', '5', 'diameter', 0.05);
N.add_pipe('F', '5', '6', 'diameter', 0.05);
N.add_pipe('G', '4', '7', 'diameter', 0.05);
N.add_pipe('H', '5', '8', 'diameter', 0.05);
N.add_pipe('I', '6', '9', 'diameter', 0.05);

% Solve it
N.solve();
N.plot_network();