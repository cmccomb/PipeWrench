function pipewrench_gui
%% You should set this information according to what you want
% This is the title that will show at the top of your window
TITLE = 'PipeWrench';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize some other values. This mostly has to do with inputs/outputs.
PIX_SS = get(0,'screensize');
PIX_SS = PIX_SS - [0 -41 0 62];
f = 0;
efj = 0;
efp = 0;
efg = 0;
ha = 0;
button_width = 100;
button_height = 25;
button_spacing = 10;
toolbox_padding = 15;
toolbox_width = 120;
button_padding = (toolbox_width - button_width)/2;
graph = FluidNetwork();
axis_padding = 35;

% Button names
h_pressure = 0;
h_flowrate = 0;
h_pipediam = 0;

h_edit = 0;
h_delete = 0;
h_add = 0;

h_save = 0;
h_load = 0;
h_undo = 0;
h_redo = 0;

h_idj = 0;
h_px = 0;
h_py = 0;
h_pp = 0;
h_fx = 0;

h_idp = 0;
h_dm = 0;
h_fr = 0;

h_dv = 0;
h_lp = 0;
h_cn = 0;

pipe_counter = 0;
junction_counter = 0;
first_junction = -1;
first_junction_handle = -1;
s = 0;
load_count = 0;
load_max = 22;

% Start the GUI
start_up;


% From here down, these are all functions called by the GUI.

    function start_up
        % Init the splashscreen
        s = SplashScreen('PipeWrench', 'splash.png', ...
                         'ProgressBar', 'on', ...
                         'ProgressPosition', 15, ...
                         'ProgressRatio', 0.0);
        s.addText(30, 50, 'PipeWrench', 'FontSize', 30, 'Color', 'b');


        % Make an invisible figure
        f = figure('Visible','off'); progress_flash(s);

        % Reset the position of the figure so it fills the screen
        set(f, 'Position', PIX_SS); progress_flash(s);

        % Clear miscellaneous out, and reset title.
        set(f, 'Numbertitle', 'off'); progress_flash(s);
        set(f, 'MenuBar', 'none'); progress_flash(s);
        set(f,'Name', TITLE); progress_flash(s);

        % Make axes with a grid
        ha = axes('Box', 'On', 'fontsize', 10, 'ticklength', [0.002, 0.002]);
        axis fill;
        set(ha, 'Position', [(toolbox_width + 2*toolbox_padding + axis_padding)/PIX_SS(3), axis_padding/PIX_SS(4), 1-(toolbox_width + 2*toolbox_padding + 2*axis_padding)/PIX_SS(3), 1-2*axis_padding/PIX_SS(4)]);
        set(ha, 'ylim', [0, 40]);
        set(ha, 'xlim', [0, 40]*PIX_SS(3)/PIX_SS(4));
        set(ha, 'xtick', -100:1:100);
        set(ha, 'ytick', -100:1:100);
        set(ha, 'buttondownfcn', {@axis_button_down});
        grid('on');  progress_flash(s);

        % Add buttons for activity modes
        mode_bg =   uibuttongroup('Visible','on', ...
                                  'Units', 'Pixels', ...
                                  'Position', [toolbox_padding, PIX_SS(4) - (3*button_height + 5*button_spacing) - toolbox_padding, toolbox_width, (3*button_height + 5*button_spacing)], ...
                                  'Title', 'Mode', ...
                                  'fontsize', 16, ...
                                  'TitlePosition', 'Centertop'); progress_flash(s);
        h_add =         uicontrol(mode_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'Build', ...
                                  'Value', 1, ...
                                  'Position', [button_padding, 2*button_height+3*button_spacing, button_width, button_height], ...
                                  'HandleVisibility','off'); progress_flash(s);
        h_delete =      uicontrol(mode_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'Delete', ...
                                  'Value', 0, ...
                                  'Position', [button_padding, button_height+2*button_spacing, button_width, button_height], ...
                                  'HandleVisibility','off'); progress_flash(s);
        h_edit =        uicontrol(mode_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'Data', ...
                                  'Value', 0, ...
                                  'Position', [button_padding, button_spacing, button_width, button_height], ...
                                  'HandleVisibility','off'); progress_flash(s);

        % Add buttons for viewing modes
        view_bg =   uibuttongroup('Visible', 'on', ...
                                  'Units', 'Pixels', ...
                                  'Position', [toolbox_padding, PIX_SS(4) - (8*button_height + 12*button_spacing) - toolbox_padding, toolbox_width, (4*button_height + 6*button_spacing)], ...
                                  'Title', 'View', ...
                                  'fontsize', 16, ...
                                  'TitlePosition', 'Centertop'); progress_flash(s);

        h_pressure    = uicontrol(view_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'Pressure', ...
                                  'Position', [button_padding, 3*button_height+4*button_spacing, button_width, button_height], ...
                                  'Value', 0, ...
                                  'HandleVisibility','off', ...
                                   'callback', {@draw_network}); progress_flash(s);
        h_flowrate =    uicontrol(view_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'Flow Rate', ...
                                  'Position', [button_padding, 2*button_height+3*button_spacing, button_width, button_height], ...
                                  'Value', 0, ...
                                  'HandleVisibility','off', ...
                                   'callback', {@draw_network}); progress_flash(s);
        h_pipediam =   uicontrol(view_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'Pipe Diameter', ...
                                  'Position', [button_padding, button_height + 2*button_spacing, button_width, button_height], ...
                                  'Value', 1, ...
                                  'HandleVisibility','off', ...
                                   'callback', {@draw_network}); progress_flash(s);
        h_none =        uicontrol(view_bg, ...
                                  'Style', 'togglebutton', ...
                                  'String', 'None', ...
                                  'Position', [button_padding, button_spacing, button_width, button_height], ...
                                  'Value', 0, ...
                                  'HandleVisibility','off', ...
                                   'callback', {@draw_network}); progress_flash(s);

        % Add buttons for general stuff
        mode_ge =   uibuttongroup('Visible','on', ...
                                  'Units', 'Pixels', ...
                                  'Position', [toolbox_padding, PIX_SS(4) - (12*button_height + 18*button_spacing) - toolbox_padding, toolbox_width, (3*button_height + 5*button_spacing)], ...
                                  'Title', 'General', ...
                                  'fontsize', 16, ...
                                  'TitlePosition', 'Centertop'); progress_flash(s);
        h_save =        uicontrol(mode_ge, ...
                                  'Style', 'pushbutton', ...
                                  'String', 'Save', ...
                                  'Position', [button_padding, 2*button_height+3*button_spacing, button_width, button_height], ...
                                  'HandleVisibility','off', ...
                                   'callback', {@save_make_file}); progress_flash(s);
        h_load =        uicontrol(mode_ge, ...
                                  'Style', 'pushbutton', ...
                                  'String', 'Load', ...
                                  'Position', [button_padding, button_height+2*button_spacing, button_width, button_height], ...
                                  'HandleVisibility','off', ...
                                   'callback', {@load_make_file}); progress_flash(s);
        h_undo =        uicontrol(mode_ge, ...
                                  'Style', 'pushbutton', ...
                                  'String', 'Undo', ...
                                  'Position', [button_padding, button_spacing, 0.5*button_width, button_height], ...
                                  'HandleVisibility','off', ...
                                   'callback', {@undo_move}); progress_flash(s);
        h_redo =        uicontrol(mode_ge, ...
                                  'Style', 'pushbutton', ...
                                  'String', 'Redo', ...
                                  'Position', [button_padding + 0.5*button_width, button_spacing, 0.5*button_width, button_height], ...
                                  'HandleVisibility','off', ...
                                   'callback', {@redo_move}); progress_flash(s);


        make_a_network(); progress_flash(s);

        draw_network(); progress_flash(s);

        delete(s);

        % Make everything visible
        set(f, 'Visible', 'on');

    end

    function make_a_network()
        graph.dynamic_viscosity = 1.3*10^-3;
    end

    function draw_network(~, ~)
        figure(f);
        cla(ha);

        if  get(h_pressure, 'Value') == 1
            hold on;
            x = [];
            y = [];
            p = [];
            for i=1:1:graph.np
                x = [graph.pipe_list(i).initial.x graph.pipe_list(i).terminal.x];
                y = [graph.pipe_list(i).initial.y graph.pipe_list(i).terminal.y];
                p = [graph.pipe_list(i).initial.pressure graph.pipe_list(i).terminal.pressure];
                surface([x; x], [y; y], zeros(size([x; x])), [p; p], 'facecol', 'no', 'edgecol', 'interp', 'linew', 4, 'ButtonDownFcn', {@pipe_button_down}, 'userdata', graph.pipe_names{i});
            end
            hold off;
        end

        if  get(h_flowrate, 'Value') == 1
            hold on;
            x = [];
            y = [];
            p = [];
            for i=1:1:graph.np
                x = [graph.pipe_list(i).initial.x graph.pipe_list(i).terminal.x];
                y = [graph.pipe_list(i).initial.y graph.pipe_list(i).terminal.y];
                p = abs([graph.pipe_list(i).flow_rate graph.pipe_list(i).flow_rate]);
                surface([x; x], [y; y], zeros(size([x; x])), [p; p], 'facecol', 'no', 'edgecol', 'interp', 'linew', 4, 'ButtonDownFcn', {@pipe_button_down}, 'userdata', graph.pipe_names{i});
            end
            hold off;
        end

        if  get(h_pipediam, 'Value') == 1
            hold on;
            d = [];
            for i=1:1:graph.np
                d(i) = graph.pipe_list(i).diameter;
            end

            d = d/max(d);
            d = 10*d;

            for i=1:1:graph.np
                plot([graph.pipe_list(i).initial.x graph.pipe_list(i).terminal.x],[graph.pipe_list(i).initial.y graph.pipe_list(i).terminal.y], 'k', 'linewidth',  d(i), 'ButtonDownFcn', {@pipe_button_down}, 'userdata', graph.pipe_names{i});
            end
            hold off;
        end

        % Plot junctions
        hold on;
        for i=1:1:graph.nj
            x = graph.junction_list(i).x;
            y = graph.junction_list(i).y;
            plot(x, y, 'ok', 'markersize', 25, 'markerfacecolor', 'w', 'ButtonDownFcn', {@junction_button_down}, 'userdata', graph.junction_names{i});
        end
        hold off;

    end

    function junction_button_down(hObject, ~)
        if get(h_add, 'Value') == 1
            if first_junction == -1
                set(hObject, 'markerfacecolor', 'c');
                first_junction = get(hObject, 'userdata');
                first_junction_handle = hObject;
            else
                pipe_counter = pipe_counter+1;
                set(first_junction_handle, 'markerfacecolor', 'w');
                graph.add_pipe(num2str(pipe_counter), first_junction, get(hObject, 'userdata'), 'diameter', 0.05);
                first_junction = -1;

                solve();

                draw_network();
            end
        elseif get(h_edit, 'Value') == 1
            junction_edit_box(get(hObject, 'userdata'));
        elseif get(h_delete, 'Value') == 1
            graph.delete_junction(get(hObject, 'userdata'));

            solve();

            draw_network();

        end
    end

    function axis_button_down(hObject, ~)
        if get(h_add, 'Value') == 1
            xy = get(ha, 'currentpoint');
            if first_junction == -1
                junction_counter = junction_counter + 1;
                graph.add_junction(num2str(junction_counter), xy(1,1), xy(1, 2));
                draw_network();
            else
                id = graph.get(first_junction, 'junction_index');
                first_junction = -1;
                graph.junction_list(id).x = xy(1, 1);
                graph.junction_list(id).y = xy(1, 2);

                % Solve and update
                solve();
                draw_network();
            end
        elseif get(h_edit, 'Value') == 1
            global_edit_box();
        elseif get(h_delete, 'Value') == 1
        end

    end

    function pipe_button_down(hObject, ~)
        if get(h_add, 'Value') == 1
        elseif get(h_edit, 'Value') == 1
            pipe_edit_box(get(hObject, 'userdata'));
        elseif get(h_delete, 'Value') == 1
            graph.delete_pipe(get(hObject, 'userdata'));

            solve();

            draw_network();
        end
    end

    function junction_edit_box(name)
        efj = figure('Visible', 'off');
        pos = get(efj, 'Position');
        set(efj, 'Position', [pos(1) pos(2) button_width*2 + button_padding*3 button_height*6 + button_padding*7]);
        set(efj, 'Numbertitle', 'off');
        set(efj, 'MenuBar', 'none');
        set(efj,'Name', 'Junction');
        uicontrol('Style', 'pushbutton', ...
                  'String', 'Save', ...
                  'Position', [button_padding button_padding button_width button_height], ...
                  'callback', {@save_junction_info});

        uicontrol('Style', 'pushbutton', ...
                  'String', 'Cancel', ...
                  'Position', [button_padding*2 + button_width button_padding button_width button_height], ...
                  'callback', {@close_window});

        uicontrol('Style', 'edit', ...
                  'String', 'Fixed (bool)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 2*button_padding+button_height button_width button_height]);
        if graph.get(name, 'fixed')
            sval = 1;
        else
            sval = 2;
        end
        h_fx = uicontrol('Style', 'popup', ...
                         'String', {'true', 'false'}, ...
                         'Position',[2*button_padding + button_width 2*button_padding+button_height button_width button_height], ...
                         'callback', {@fixed_callback});
        set(h_fx, 'value', sval);

        uicontrol('Style', 'edit', ...
                  'String', 'Pressure (Pa)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 3*button_padding+2*button_height button_width button_height]);
        h_pp = uicontrol('Style', 'edit', ...
                         'String', graph.get(name, 'pressure'), ...
                         'Position',[2*button_padding + button_width 3*button_padding+2*button_height button_width button_height]);
        if sval == 2
            set(h_pp, 'enable', 'off');
        end

        uicontrol('Style', 'edit', ...
                  'String', 'Y pos (m)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 4*button_padding+3*button_height button_width button_height]);
        h_py = uicontrol('Style', 'edit', ...
                         'String', graph.get(name, 'y'), ...
                         'Position',[2*button_padding + button_width 4*button_padding+3*button_height button_width button_height]);

        uicontrol('Style', 'edit', ...
                  'String', 'X Pos (m)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 5*button_padding+4*button_height button_width button_height]);
        h_px = uicontrol('Style', 'edit', ...
                         'String', graph.get(name, 'x'), ...
                         'Position',[2*button_padding + button_width 5*button_padding+4*button_height button_width button_height]);

        uicontrol('Style', 'edit', ...
                  'String', 'Name', ...
                  'enable', 'off', ...
                  'Position', [button_padding 6*button_padding+5*button_height button_width button_height]);
        h_idj = uicontrol('Style', 'edit', ...
                          'String', name, ...
                          'enable', 'off', ...
                          'Position',[2*button_padding + button_width 6*button_padding+5*button_height button_width button_height]);

        set(efj, 'Visible', 'on');
    end

    function pipe_edit_box(name)
        efp = figure('Visible', 'off');
        pos = get(efp, 'Position');
        set(efp, 'Position', [pos(1) pos(2) button_width*2 + button_padding*3 button_height*4 + button_padding*5]);
        set(efp, 'Numbertitle', 'off');
        set(efp, 'MenuBar', 'none');
        set(efp,'Name', 'Pipe');
        uicontrol('Style', 'pushbutton', ...
                  'String', 'Save', ...
                  'Position', [button_padding button_padding button_width button_height], ...
                  'callback', {@save_pipe_info});

        uicontrol('Style', 'pushbutton', ...
                  'String', 'Cancel', ...
                  'Position', [button_padding*2 + button_width button_padding button_width button_height], ...
                  'callback', {@close_window});

        uicontrol('Style', 'edit', ...
                  'String', 'Diameter (m)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 2*button_padding+button_height button_width button_height]);
        h_dm = uicontrol('Style', 'edit', ...
                         'String', num2str(graph.get(name, 'diameter')), ...
                         'Position',[2*button_padding + button_width 2*button_padding+button_height button_width button_height]);

        uicontrol('Style', 'edit', ...
                  'String', 'Flow Rate (m^3/s)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 3*button_padding+2*button_height button_width button_height]);
        h_fr = uicontrol('Style', 'edit', ...
                         'String', num2str(abs(graph.get(name, 'flow_rate'))), ...
                         'enable', 'off', ...
                         'Position',[2*button_padding + button_width 3*button_padding+2*button_height button_width button_height]);

        uicontrol('Style', 'edit', ...
                  'String', 'Name', ...
                  'enable', 'off', ...
                  'Position', [button_padding 4*button_padding+3*button_height button_width button_height]);
        h_idp = uicontrol('Style', 'edit', ...
                         'String', name, ...
                         'enable', 'off', ...
                         'Position',[2*button_padding + button_width 4*button_padding+3*button_height button_width button_height]);

        set(efp, 'Visible', 'on');
    end


    function global_edit_box()
        efg = figure('Visible', 'off');
        pos = get(efg, 'Position');
        set(efg, 'Position', [pos(1) pos(2) button_width*2 + button_padding*3 button_height*4 + button_padding*5]);
        set(efg, 'Numbertitle', 'off');
        set(efg, 'MenuBar', 'none');
        set(efg,'Name', 'Global');
        uicontrol('Style', 'pushbutton', ...
                  'String', 'Save', ...
                  'Position', [button_padding button_padding button_width button_height], ...
                  'callback', {@save_pipe_info});

        uicontrol('Style', 'pushbutton', ...
                  'String', 'Cancel', ...
                  'Position', [button_padding*2 + button_width button_padding button_width button_height], ...
                  'callback', {@close_window});

        uicontrol('Style', 'edit', ...
                  'String', 'Dynamic Viscosity', ...
                  'enable', 'off', ...
                  'Position', [button_padding 2*button_padding+button_height button_width button_height]);
        h_dv = uicontrol('Style', 'edit', ...
                         'String', num2str(graph.dynamic_viscosity), ...
                         'Position',[2*button_padding + button_width 2*button_padding+button_height button_width button_height]);

        uicontrol('Style', 'edit', ...
                  'String', 'Length of pipe (m)', ...
                  'enable', 'off', ...
                  'Position', [button_padding 3*button_padding+2*button_height button_width button_height]);
        L = 0;
        for i=1:1:graph.np
            L = L + graph.pipe_list(i).length;
        end
        h_lp = uicontrol('Style', 'edit', ...
                         'String', num2str(L), ...
                         'enable', 'off', ...
                         'Position',[2*button_padding + button_width 3*button_padding+2*button_height button_width button_height]);

        uicontrol('Style', 'edit', ...
                  'String', 'Reciprocal Condition', ...
                  'enable', 'off', ...
                  'Position', [button_padding 4*button_padding+3*button_height button_width button_height]);
        h_cn = uicontrol('Style', 'edit', ...
                         'String', rcond(graph.global_stiffness), ...
                         'enable', 'off', ...
                         'Position',[2*button_padding + button_width 4*button_padding+3*button_height button_width button_height]);

        set(efg, 'Visible', 'on');
    end

    function progress_flash(s)
        load_count = load_count + 1;
        set(s, 'ProgressRatio', min(1, load_count/load_max));
        pause(0.1);
    end

    function save_junction_info(~, ~)
        name = get(h_idj, 'String');
        idx = graph.get(name, 'junction_index');

        graph.junction_list(idx).set('x', str2double(get(h_px, 'String')));
        graph.junction_list(idx).set('y', str2double(get(h_py, 'String')));
        graph.junction_list(idx).set('pressure', str2double(get(h_pp, 'String')));
        if get(h_fx, 'Value') == 1
            graph.junction_list(idx).set('fixed', true);
        else
            graph.junction_list(idx).set('fixed', false);
        end

        solve();

        draw_network();
        close(efj);
    end



    function save_pipe_info(~, ~)
        name = get(h_idp, 'String');
        idx = graph.get(name, 'pipe_index');

        graph.pipe_list(idx).set('diameter', str2double(get(h_dm, 'String')));

        solve();

        draw_network();
        close(efp);
    end

    function fixed_callback(~, ~)
        if get(h_fx, 'Value') == 1
            set(h_pp, 'Enable', 'On');
        elseif get(h_fx, 'Value') == 2
            set(h_pp, 'Enable', 'Off');
        end
    end

    function solve()
        try
            graph.solve()
        end
    end

    function close_window(~, ~)
        try
            close(efp);
        catch
            try
                close(efj);
            catch
                close(efg);
            end
        end
    end

    function save_make_file(~, ~)
        [file_name, path_name] = uiputfile();
        graph.save([path_name file_name ]);
    end

    function load_make_file(~, ~)
        % Ask teh user what file to load
        [file_name, path_name] = uigetfile('*.m');

        % Get the command name to execute
        [~, file_name, ~] = fileparts(file_name);

        % Load the file
        come_back = pwd();
        cd(path_name);
        graph = eval([file_name '()']);
        solve();
        draw_network();

        % Return to where you need to be
        cd(come_back);
    end

    function undo_move(~, ~)
        % TODO Handle undo with CTRL+Z
    end

    function redo_move(~, ~)
        % TODO Handle redo with CTRL+Y
    end

end
