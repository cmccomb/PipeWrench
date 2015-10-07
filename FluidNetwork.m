classdef FluidNetwork < handle
    properties
        dynamic_viscosity;
        junction_list;
        pipe_list; 
        junction_names = containers.Map;
        pipe_names = containers.Map;
        nj = 0;
        np = 0;
        R;
        K;
        q;
    end

    methods
        function this = FluidNetwork()
            this.junction_list = Junction();
            this.pipe_list = Pipe();
        end
        
        function add_junction(this, name, x, y, varargin)
            this.nj = this.nj + 1;
            this.junction_list(this.nj) = Junction(x, y);
            this.junction_list(this.nj).id = this.nj;
            this.junction_names(name) = this.nj;
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
            initial = this.junction_list(this.junction_names(init_name));
            terminal = this.junction_list(this.junction_names(term_name));
            this.pipe_list(this.np) = Pipe(initial, terminal);
            this.pipe_names(name) = this.np;
            if nargin > 4
                for i=1:2:length(varargin)
                    if strcmp(varargin{i}, 'diameter')
                        this.pipe_list(end).diameter = varargin{i+1};
                    end
                end
            end
        end
        
        function solve(this)
            % Compute length of every pipe
            for i=1:1:length(this.pipe_list)
                temp1 = [this.pipe_list(i).initial.x this.pipe_list(i).initial.y];
                temp2 = [this.pipe_list(i).terminal.x this.pipe_list(i).terminal.y];
                this.pipe_list(i).length = sqrt(sum((temp1-temp2).^2));
            end
            
            % Define things for use later
            this.R = zeros(1, this.np);
            this.K = zeros(this.nj, this.nj);
            this.q = zeros(1, this.np);
            
            % Define equations for things
            resistance = @(LL, DD, uu) (pi*DD^4)/(128*LL*this.dynamic_viscosity);
            flowrate = @(PP1, PP2, RR) (PP1-PP2)*RR;
            elem = @(R) [R, -R; -R, R]; 

            % Build the global stiffness matrix
            for i=1:1:this.np
                this.R(i) = resistance(this.pipe_list(i).length, this.pipe_list(i).diameter);
                temp = elem(this.R(i));
                ends = [this.pipe_list(i).initial.id, this.pipe_list(i).terminal.id];
                this.K(ends, ends) = this.K(ends, ends) + temp;
            end
            
            % Apply boundary conditions
            temp = zeros(this.nj, 1);
            for i=1:1:this.nj
                if ~isinf(this.junction_list(i).pressure)
                    this.K(i, :) = zeros(1, this.nj);
                    this.K(i, i) = 1;
                    temp(i) = this.junction_list(i).pressure;
                else
                    temp(i) = 0;
                end
            end
                    
            % Solve the matrix and distribute node and elemental information
            size(temp)
            size(this.K)
            temp = (this.K\temp)';
            for i=1:1:this.nj
                this.junction_list(i).pressure = temp(i);
            end
            for i=1:1:this.np
                temp1 = this.pipe_list(i).initial.pressure;
                temp2 = this.pipe_list(i).terminal.pressure;
                this.pipe_list(i).flow_rate = flowrate(temp1, temp2, this.R(i));                     %     Compute the flow rate
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
    end
end