function alpha = armijo_alphak(f, grad_f, x_k, s_k)
% Function for calculating the step length for line search based on the
% armijo condition.
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