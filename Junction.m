classdef Junction < handle
    properties
        pressure = Inf;
        fixed = false;
        x = NaN;
        y = NaN;
        junction_index = NaN;
    end

    methods
        function this = Junction(varargin)
            if nargin==2
                this.x = varargin{1};
                this.y = varargin{2};
            end
        end

        function set(this, name, val)
            this.(name) = val;
        end

        function val = get(this, name)
            val = this.(name);
        end
    end
end