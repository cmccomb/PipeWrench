classdef FluidNetwork < handle
    properties
        dynamic_viscosity = NaN;
        junction_list = Junction();
        pipe_list = Pipe(); 
        junction_names = {};
        pipe_names = {};
        nj = 0;
        np = 0;
        global_stiffness = [];
    end

    methods
        function this = FluidNetwork()
            % Something could go here, but does it really need to?
        end
        
        function add_junction(this, name, x, y, varargin)
            this.nj = this.nj + 1;
            this.junction_list(this.nj) = Junction(x, y);
            % this.junction_list(this.nj).id = this.nj;
            this.junction_names{this.nj} = name;
            if nargin > 4
                for i=1:2:length(varargin)
                    if strcmp(varargin{i}, 'pressure')
                        this.junction_list(this.nj).pressure = varargin{i+1};
                    end
                end
            end
        end
        
        function add_pipe(this, name, init_name, term_name, varargin)
            this.np = this.np + 1;
            initial = this.junction_list(strcmp(this.junction_names, init_name));
            terminal = this.junction_list(strcmp(this.junction_names, term_name));
            this.pipe_list(this.np) = Pipe(initial, terminal);
            this.pipe_list(this.np).dynamic_viscosity = this.dynamic_viscosity;
            this.pipe_names{this.np} = name;
            if nargin > 4
                for i=1:2:length(varargin)
                    if strcmp(varargin{i}, 'diameter')
                        this.pipe_list(end).diameter = varargin{i+1};
                    end
                end
            end
        end
        
        function solve(this)
            % Update values for all pipes
            for i=1:1:length(this.pipe_list)
                this.pipe_list(i).update();
            end

            % Build the global stiffness matrix
            this.global_stiffness = zeros(this.nj, this.nj);
            for i=1:1:this.np
                ends = [this.pipe_list(i).initial.id, this.pipe_list(i).terminal.id];
                this.global_stiffness(ends, ends) = this.global_stiffness(ends, ends) + this.pipe_list(i).local_stiffness;
            end
            
            % Apply boundary conditions
            temp = zeros(this.nj, 1);
            for i=1:1:this.nj
                if ~isinf(this.junction_list(i).pressure)
                    this.global_stiffness(i, :) = zeros(1, this.nj);
                    this.global_stiffness(i, i) = 1;
                    temp(i) = this.junction_list(i).pressure;
                else
                    temp(i) = 0;
                end
            end
                    
            % Solve the matrix and distribute node and elemental information
            temp = (this.global_stiffness\temp)';
            for i=1:1:this.nj
                this.junction_list(i).pressure = temp(i);
            end

            for i=1:1:this.np
                this.pipe_list(i).compute_flowrate();
            end
            
        end
        
        function info = get(this, name, variable)
            try
                info = this.pipe_list(strcmp(this.pipe_names, name)).(variable);
            catch
                info = this.junction_list(strcmp(this.junction_names, name)).(variable);
            end
        end
        
        function plot_network(this)  
            hold on;
            for i=1:1:length(this.pipe_list)
                p1 = [this.pipe_list(i).initial.x this.pipe_list(i).terminal.x];
                p2 = [this.pipe_list(i).initial.y this.pipe_list(i).terminal.y];
                plot(p1, p2, 'ks-', 'linewidth', 3, 'markersize', 15);
            end
            axis square;
            hold off;
        end
        
        function plot_pressure(this)  
            for i=1:1:length(this.pipe_list)
                p1 = [this.pipe_list(i).initial.x this.pipe_list(i).terminal.x];
                p2 = [this.pipe_list(i).initial.y this.pipe_list(i).terminal.y];
                p3 = [this.pipe_list(i).initial.pressure this.pipe_list(i).terminal.pressure];
                plot3(p1, p2, p3, 'k');  
                hold on;
            end
            axis square;
            hold off;
        end
    end
end