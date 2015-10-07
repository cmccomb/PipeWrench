classdef Pipe < handle
    properties
        diameter = 0;
        length = 0;
        terminal;
        initial;
        resistance;
        flow_rate;
    end

    methods
        function this = Pipe(varargin)
            if nargin==2
                this.initial = varargin{1};
                this.terminal = varargin{2};
            end
        end
    end
end
