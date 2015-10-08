classdef Junction < handle
    properties
        pressure = Inf;
        x = NaN;
        y = NaN;
        id = NaN;
    end

    methods
        function this = Junction(varargin)
            if nargin==2
                this.x = varargin{1};
                this.y = varargin{2};
            end
        end
        
    end
end