classdef Pipe < handle
    properties
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

        function set_diameter(this, d)
            this.diameter = d;
        end

        function update(this)
            % Update the length
            temp1 = [this.initial.x  this.initial.y];
            temp2 = [this.terminal.x this.terminal.y];
            this.length = sqrt(sum((temp1-temp2).^2));

            % Compute the resistance
            this.resistance = (pi*this.diameter^4)/(128*this.length*this.dynamic_viscosity);
            this.local_stiffness = this.resistance*[1 -1; -1 1];
        end

        function compute_flowrate(this)
            this.flow_rate = (this.initial.pressure - this.terminal.pressure)*this.resistance;
        end

    end
end
