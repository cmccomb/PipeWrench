classdef Junction < handle
    properties
        pressure;
        x;
        y;
        id;
    end

    methods
        function this = Junction(varargin)
            this.pressure = Inf;
            if nargin==2
                this.x = varargin{1};
                this.y = varargin{2};
            end
        end
        
    end
end