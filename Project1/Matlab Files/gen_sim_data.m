function x = gen_sim_data(m, k, d, x0, dt, N)
    t0 = 0;
    tf = t0 + (dt * N);
    tspan = [t0 tf];
    opts = odeset('InitialStep', dt, 'MaxStep', dt);
    sol = ode45(@(t,x) spring_diff(t,y,m,k,d), tspan, x0, opts);
    t = linspace(t0, tf, N);
    x = deval(sol, t);
end