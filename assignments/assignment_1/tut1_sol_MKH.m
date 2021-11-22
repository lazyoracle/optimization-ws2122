do_task_1 = 0;
do_task_2 = 1;

if do_task_1
    clearvars
    syms x [1 2] real

    x_k = [-5 -4]; % initial guess
    
    % Problem parameters
    a = 5;
    b = 3;
    gamma = 3;
    
    % function to be minimized
    f_(x) = 0.5*((x(1)-a)/gamma)^2+0.5*(x(2)-b)^2;

    % get function handles fpr function value and gradients (not necessary
    % but faster to compute
    grad_f_ = gradient(f_, x);
    f       = matlabFunction(f_,'Vars',{x});
    f_plot  = matlabFunction(f_,'Vars',{x1, x2});
    grad_f  = matlabFunction(grad_f_,'Vars',{x});

    while 1
        s_k = -grad_f(x_k(end,:))';
        x_k(end+1,:) = x_k(end,:) + armijo_alphak(f, grad_f, x_k(end,:), s_k)*s_k;
        if norm(double(x_k(end-1,:) - x_k(end,:))) <= 0.01
            break;
        end
    end

    fcontour(f_plot,[-7,20,-10, 10])
    hold on
    plot(x_k(:,1), x_k(:,2))

    figure
    plot(f(x_k))
end

if do_task_2
    min_x_nograd = [];
    % options for function without gradient output
    options_nograd = optimoptions('fminunc','Algorithm', 'quasi-newton', 'Display', 'off');
    min_x_grad = [];
    % options when gradient is explicitly given
    options_grad = optimoptions(options_nograd, 'SpecifyObjectiveGradient',true);
    
    % do this optimization 50 times for better estimation of timings
    for i = 1:5e1
        initial = randi([-10 10], 1, 2);
        %% a
        tic
        % minimize without gradient information
        min_x_nograd(i,:) = fminunc(@rosenbrock, initial, options_nograd);
        t_nograd(i) = toc;

        %% c
        tic
        %minimize with gradient information
        min_x_grad(i,:) = fminunc(@rosenbrock_grad, initial, options_grad);
        t_grad(i) = toc;
    end
    %% d
    mean(t_nograd - t_grad)
    std(t_nograd - t_grad)
    
    f_nograd = arrayfun(@(i) rosenbrock(min_x_nograd(i,:)), 1:size(min_x_nograd,1));
    f_grad = arrayfun(@(i) rosenbrock_grad(min_x_grad(i,:)), 1:size(min_x_grad,1));
    mean(f_nograd - f_grad)
    std(f_nograd - f_grad)
end

%%
function alpha = armijo_alphak(f, grad_f, x_k, s_k)

% f: Function handle to the function f(x)
% grad_f: Function handle to the gradient of f(x)
% x_k: current iteration's x
% s_k: search direction

alpha = 10;
c = 0.1;
while f(x_k+alpha*s_k) > f(x_k) + c*alpha*s_k*grad_f(x_k)
    alpha = alpha*0.5;
    if alpha <= 1e-3
        break
    end
end

end

%%
function [f] = rosenbrock(x)
f = 100*(x(2)-x(1)^2)^2+(x(1)-1)^2;

end

function [f,g] = rosenbrock_grad(x)
f = rosenbrock(x);

if nargout > 1
    g = [-400*x(1)*(x(2)-x(1)^2) + 2*(x(1)-1) 200*(x(2)-x(1)^2)];
end

end
