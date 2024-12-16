clc; clear all; close all hidden;

alpha_r = 0.1;
alpha_d = 0.9;
d_m = 1; %m
d_d = 0.15; %m
v = 340; %m/s

tau_r = 2*d_m/v;
tau_d = d_d/v;
delta_tau = tau_r - tau_d;

transfertFunction = @(f) alpha_r*exp(1i*2*pi*f*tau_r) + alpha_d*exp(1i*2*pi*f*tau_d);
transfertFunctionNorm = @(f) sqrt(alpha_r^2 + alpha_d^2 + 2*alpha_r*alpha_d*cos(2*pi*f*delta_tau));
figure;
f = linspace(-24000, 24000,48000);
plot(f, 20*log(abs(transfertFunctionNorm(f))));
xlabel('f [Hz]');
ylabel('|H(f)| [dB]');
ylim([-100, 0]);


