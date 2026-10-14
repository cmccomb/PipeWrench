classdef Pipe < handle
    properties
        pipe_index = NaN;
        diameter = NaN;
        length = NaN;
        terminal = NaN;
        initial = NaN;
        resistance = NaN;
        flow_rate = NaN;
        dynamic_viscosity = NaN;
        local_stiffness = [NaN];
    end

    methods
        function this = Pipe(varargin)
            if nargin==2
                this.initial = varargin{1};
                this.terminal = varargin{2};
            end
        end

        function set(this, name, val)
            this.(name) = val;
        end

        function val = get(this, name)
            val = this.(name);
        end

        function update(this)
            if ~isnumeric(this.diameter) || ~isreal(this.diameter) || ...
                    ~isscalar(this.diameter) || ~isfinite(this.diameter) || this.diameter <= 0
                error('Pipe diameter must be a positive finite number.');
            end
            if ~isnumeric(this.dynamic_viscosity) || ~isreal(this.dynamic_viscosity) || ...
                    ~isscalar(this.dynamic_viscosity) || ...
                    ~isfinite(this.dynamic_viscosity) || this.dynamic_viscosity <= 0
                error('Dynamic viscosity must be a positive finite number.');
            end

            % Update the length
            temp1 = [this.initial.x  this.initial.y];
            temp2 = [this.terminal.x this.terminal.y];
            this.length = sqrt(sum((temp1-temp2).^2));
            if ~isfinite(this.length) || this.length <= 0
                error('Pipe endpoints must have distinct finite coordinates.');
            end

            % Historical property name: this is hydraulic conductance,
            % Q/delta-P, from the Hagen-Poiseuille relation.
            this.resistance = (pi*this.diameter^4)/(128*this.length*this.dynamic_viscosity);
            this.local_stiffness = this.resistance*[1 -1; -1 1];
        end

        function compute_flowrate(this)
            p_init = this.initial.pressure;
            p_term = this.terminal.pressure;
            this.flow_rate = (p_init - p_term)*this.resistance;
        end

    end
end
