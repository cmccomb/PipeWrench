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
            this.junction_list(this.nj).set('junction_index', this.nj);
            this.junction_names{this.nj} = name;
            if nargin > 4
                for i=1:2:length(varargin)
                    if strcmp(varargin{i}, 'pressure')
                        this.junction_list(this.nj).set('pressure', varargin{i+1});
                        this.junction_list(this.nj).set('fixed', true);
                    end
                end
            end
        end
        
        function add_pipe(this, name, init_name, term_name, varargin)
            this.np = this.np + 1;
            initial = this.junction_list(strcmp(this.junction_names, init_name));
            terminal = this.junction_list(strcmp(this.junction_names, term_name));
            this.pipe_list(this.np) = Pipe(initial, terminal);
            this.pipe_list(this.np).set('pipe_index', this.np);
            this.pipe_list(this.np).set('dynamic_viscosity', this.dynamic_viscosity);
            this.pipe_names{this.np} = name;
            if nargin > 4
                for i=1:2:length(varargin)
                    if strcmp(varargin{i}, 'diameter')
                        this.pipe_list(end).set('diameter', varargin{i+1});
                    end
                end
            end
        end
        
        function delete_pipe(this, name)
            idx = this.get(name, 'pipe_index');
            temp = Pipe();
            counter = 1;
            for i=1:1:(this.np)
                if i ~= idx
                    temp(counter) = this.pipe_list(i);
                    counter = counter+1;
                end
            end
            this.pipe_list = temp;
%             this.pipe_list(idx) = [];
            this.pipe_names(idx) = [];
            this.np = this.np - 1;
            this.compact_names();
        end
        
        function compact_names(this)
            % Update values for all pipes
            for i=1:1:this.np
                this.pipe_list(i).set('pipe_index', i);
            end
            
            % Update values for all junctions
            for i=1:1:this.nj
                this.junction_list(i).set('junction_index', i);
            end
        end
                    
        function delete_junction(this, name)
            % Step through pipes to find connections
            to_delete = {};
            idx = this.get(name, 'junction_index');
            for i=1:1:this.np
                temp = this.pipe_list(i).initial.junction_index;
                if temp == idx
                    to_delete(end+1) = this.pipe_names(this.pipe_list(i).pipe_index);
                end
                temp = this.pipe_list(i).terminal.junction_index;
                if temp == idx
                    to_delete(end+1) = this.pipe_names(this.pipe_list(i).pipe_index);
                end
            end
            
            % Delete pipes as needed
            for i=1:1:length(to_delete)
                this.delete_pipe(to_delete{i});
            end
           
            % Finally, delete the junction
            idx = this.get(name, 'junction_index');
            temp = Junction();
            counter = 1;
            for i=1:1:(this.nj)
                if i ~= idx
                    temp(counter) = this.junction_list(i);
                    counter = counter+1;
                end
            end
            this.junction_list = temp;
            this.junction_names(idx) = [];
            this.nj = this.nj - 1;
            
            this.compact_names();
        end

        function solve(this)
            % Update values for all pipes
            for i=1:1:this.np
                this.pipe_list(i).update();
            end

            % Build the global stiffness matrix
            this.global_stiffness = zeros(this.nj, this.nj);
            for i=1:1:this.np
                ends = [this.pipe_list(i).initial.junction_index, this.pipe_list(i).terminal.junction_index];
                this.global_stiffness(ends, ends) = this.global_stiffness(ends, ends) + this.pipe_list(i).local_stiffness;
            end
            
            % Apply boundary conditions
            temp = zeros(this.nj, 1);
            for i=1:1:this.nj
                if this.junction_list(i).fixed == true
                    this.global_stiffness(i, :) = zeros(1, this.nj);
                    this.global_stiffness(i, i) = 1;
                    temp(i) = this.junction_list(i).pressure;
                else
                    temp(i) = 0;
                end
            end
                    
            % Solve the matrix and distribute node and elemental information
            if rcond(this.global_stiffness) > eps
                temp = (this.global_stiffness\temp)';
                for i=1:1:this.nj
                    this.junction_list(i).set('pressure', temp(i));
                end

                for i=1:1:this.np
                    this.pipe_list(i).compute_flowrate();
                end
            end
        end
        
        function info = get(this, name, variable)
            try
                info = this.pipe_list(strcmp(this.pipe_names, name)).(variable);
            catch
                info = this.junction_list(strcmp(this.junction_names, name)).(variable);
            end
        end
        
        % This function provides teh ability to save a function to create a
        % network
        function save(this, name)
            % Open the file for writing
            fileID = fopen([name '.m'], 'w');
            
            % Initialize the network and set dynamic viscosity
            fprintf(fileID, 'function net = %s()\n', name);
            fprintf(fileID, '\t%%%% Initialize the network\n');
            fprintf(fileID, '\tnet = FluidNetwork();\n');
            fprintf(fileID, '\tnet.dynamic_viscosity = %f;\n\n', this.dynamic_viscosity);

            % Add junctions to the network
            fprintf(fileID, '\t%%%% Add junctions to the network\n');
            for i=1:1:length(this.junction_names)
                this_name = this.junction_names{i};
                if this.get(this_name, 'fixed') == 1
                    fprintf(fileID, '\tnet.add_junction(''%s'', %f, %f, ''pressure'', %f);\n', this_name, this.get(this_name, 'x'), this.get(this_name, 'y'), this.get(this_name, 'pressure'));                    
                else
                    fprintf(fileID, '\tnet.add_junction(''%s'', %f, %f);\n', this_name, this.get(this_name, 'x'), this.get(this_name, 'y'));
                end
            end
            fprintf(fileID, '\n');
            
            % Add pipes
            fprintf(fileID, '\t%%%% Add pipes to connect the junctions\n');
            for i=1:1:length(this.pipe_names)
                this_name = this.pipe_names{i};
                init_junc = this.get(this_name, 'initial');
                init_name = this.junction_names{init_junc.junction_index};
                term_junc = this.get(this_name, 'terminal');
                term_name = this.junction_names{term_junc.junction_index};
                fprintf(fileID, '\tnet.add_pipe(''%s'', ''%s'', ''%s'', ''diameter'', %f);\n', this_name, init_name,  term_name,  this.get(this_name, 'diameter'));
            end
            fprintf(fileID, '\n');
            
            % Close the file
            fprintf(fileID, 'end\n');
            fclose(fileID);
        end
    end
end