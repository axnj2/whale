clc; clear all; close all hidden;

alpha_r = 0.1;
alpha_d = 0.5;
d_m = 0.5; %m
d_d = 0.05; %m
v = 340; %m/s

tau_r = 2*d_m/v;
tau_d = d_d/v;
delta_tau = tau_r - tau_d;

transfertFunctionNorm = @(f) sqrt(alpha_r^2 + alpha_d^2 + 2*alpha_r*alpha_d*cos(2*pi*f*delta_tau));

f = linspace(2000, 3000, 4000);
plot(f, 20*log(transfertFunctionNorm(f)));
xlabel('f [Db]');
ylabel('H(f)');
ylim([-20, 0]);