classdef NelderMeadSimplex < handle
    % This class is used to implement a singular simplex used in the
    % Nelder-Mead-Simplex algorithm. It is the same as fminsearch
    % https://de.mathworks.com/help/optim/ug/fminsearch-algorithm.html,
    % but allows for more visualization and easier storing of the
    % simplices.
    properties
        vertices; % Vertices of the problem: each row corresponds to one vertex, each column to one decision variable.
        fcn_hdl; % Function handle to the function to be optimized.
        fcn_values; % Function values for each vertex.
        sorted = false; % boolean to evaluate whether the simplex is sorted
        a_in = 0.5;
        a_out = 0.5;
        a_shrink = 0.5;
    end

    methods
        function obj = NelderMeadSimplex(v, fh)
            if size(v,1) == 1
                obj.vertices = v.*ones(size(v,2)+1,1);
                % generate n vertices with 5% higher value in one decision variable
                obj.vertices(2:end, :) = obj.vertices(2:end, :) + diag(0.05*v);
            elseif all(size(v,1) == size(v,2)+1)
                obj.vertices = v;
            else
                error("The number of rows (vertices) must must either be one or one larger than the number of columns " + ...
                    "(decision variables) in order to form an n-simplex.")
            end
            obj.fcn_hdl = fh;
            obj.update_fcn_values();
            obj.sort_vertices; % Step 2.
        end


        function update_fcn_values(obj)
            obj.fcn_values = arrayfun(@(i) obj.fcn_hdl(obj.vertices(i,:)), 1:size(obj.vertices, 1))';
        end
        
        function [next_simplex, action] = do_step(obj)
            [reflection, reflect_fcn] = obj.reflect(); % Step 3.
            if obj.fcn_values(1) <= reflect_fcn && reflect_fcn <= obj.fcn_values(end-1) % Step 4.
                next_simplex = NelderMeadSimplex([obj.vertices(1:end-1,:); reflection], obj.fcn_hdl);
                action = "reflect";
                return

            elseif obj.fcn_values(1) > reflect_fcn % Step 5.
                [expansion, expand_fcn] = obj.expand();
                if expand_fcn < reflect_fcn % Step 5.a
                    next_simplex = NelderMeadSimplex([obj.vertices(1:end-1,:); expansion], obj.fcn_hdl);
                    action = "expand";
                else % Step 5.b
                    next_simplex = NelderMeadSimplex([obj.vertices(1:end-1,:); reflection], obj.fcn_hdl);
                    action = "reflect";
                end
                return

            elseif obj.fcn_values(end-1) <= reflect_fcn % Step 6.
                if reflect_fcn < obj.fcn_values(end) % Step 6.a
                    [contract_out, contract_out_fcn] = obj.contract_outside(reflection);
                    if contract_out_fcn < reflect_fcn
                        next_simplex = NelderMeadSimplex([obj.vertices(1:end-1,:); contract_out], obj.fcn_hdl);
                        action = "Contract outside";
                        return
                    end
                else % Step 6.b
                    [contract_in, contract_in_fcn] = obj.contract_inside();
                    if contract_in_fcn < obj.fcn_values(end)
                        next_simplex = NelderMeadSimplex([obj.vertices(1:end-1,:); contract_in], obj.fcn_hdl);
                        action = "Contract inside";
                        return
                    end
                end
                % Step 7.
                next_simplex = NelderMeadSimplex([obj.vertices(1,:); obj.shrink()], obj.fcn_hdl);
                action = "Shrink";
            else
                error("Please contact your customer support for help (the Optimization Hiwi ;) )")
            end
            
        end
        
        function sort_vertices(obj)
            [obj.fcn_values, order] = sort(obj.fcn_values);
            obj.vertices = obj.vertices(order,:);
            obj.sorted = true;
        end

        function [reflected_point, fcn_reflected] = reflect(obj)
            % For more insight look up the fminsearch algorithm in MATLAB's
            % documentation
            m = obj.get_m();
            reflected_point = 2*m - obj.vertices(end,:);
            fcn_reflected = obj.fcn_hdl(reflected_point);
        end
        
        function [expansion_point, fcn_expansion] = expand(obj)
            m = obj.get_m();
            expansion_point = m + 2*(m - obj.vertices(end, :));
            fcn_expansion = obj.fcn_hdl(expansion_point);
        end
        
        function [contraction_point, fcn_contraction] = contract_outside(obj, reflection_point)
            m = obj.get_m();
            contraction_point = m + (reflection_point - m)*obj.a_in;
            fcn_contraction = obj.fcn_hdl(contraction_point);
        end

        function [contraction_point, fcn_contraction] = contract_inside(obj)
            m = obj.get_m();
            contraction_point = m + (obj.vertices(end,:) - m)*obj.a_out;
            fcn_contraction = obj.fcn_hdl(contraction_point);
        end

        function [shrunk_points] = shrink(obj)
            shrunk_points = obj.vertices(1,:) - (obj.vertices(2:end,:) - obj.vertices(1,:))*obj.a_shrink;
        end

        function m = get_m(obj)
            m = sum(obj.vertices(1:end-1,:),1)/size(obj.vertices,2);
        end

        function vol = get_volume( obj )
            if numel( obj ) == 1
                vol = abs(det(obj.vertices(2:end, :) - obj.vertices(1, :)))/factorial(size(obj.vertices, 2));
            else
                vol = arrayfun(@(x) x.get_volume(), obj);
            end
        end

        function plot2D( obj )          
            if numel(obj) == 1
                % plot connection lines between all vertices
                edge_comb = nchoosek( 1:size(obj.vertices, 1), 2 );
                pts = obj.vertices;
                line1 = plot( pts(edge_comb(1,:),1), pts(edge_comb(1,:),2));
                hold on
                arrayfun(@(i) plot( pts(edge_comb(i,:),1), pts(edge_comb(i,:),2), 'Color', ...
                    line1.Color ), 2:size(edge_comb,1))
            else
                arrayfun(@(x) x.plot2D(), obj);
            end
        end
        
        function plot3D( obj )          
            if numel(obj) == 1
                % plot connection lines between all vertices
                edge_comb = nchoosek( 1:size(obj.vertices, 1), 2 );
                pts = obj.vertices;
                line1 = plot3( pts(edge_comb(1,:),1), pts(edge_comb(1,:),2), obj.fcn_values(edge_comb(1,:)));
                hold on
                arrayfun(@(i) plot3( pts(edge_comb(i,:),1), pts(edge_comb(i,:),2), obj.fcn_values(edge_comb(i,:)), ...
                    'Color', line1.Color ), 2:size(edge_comb,1))
            else
                arrayfun(@(x) x.plot3D(), obj);
            end
        end

        function [x, fcn_val] = get_min(obj)
            x = obj.vertices(1,:);
            fcn_val = obj.fcn_values(1);
        end

        function plotmin( obj )
            if numel(obj) == 1
                plot3( obj.vertices(1,1), obj.vertices(1,2), obj.fcn_values(1), 'o', 'LineWidth', 3 )
            else
                arrayfun(@(x) x.plotmin(), obj);
            end
        end
    end

end