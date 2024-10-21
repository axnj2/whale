clc; clear all; close all hidden;

alpha_r = 0.4;
alpha_d = 0.5;
d_m = 0.15; %m
d_d = 0.05; %m
v = 340; %m/s

tau_r = 2*d_m/v;
tau_d = d_d/v;
delta_tau = tau_r - tau_d;

transfertFunction = @(f) alpha_r*exp(1i*2*pi*f*tau_r) + alpha_d*exp(1i*2*pi*f*tau_d);
transfertFunctionNorm = @(f) sqrt(alpha_r^2 + alpha_d^2 + 2*alpha_r*alpha_d*cos(2*pi*f*delta_tau));

f = linspace(-24000, 24000,48000);
plot(f, 20*log(abs(transfertFunctionNorm(f))), f, 20*log((transfertFunctionNorm(f))));
xlabel('f [Db]');
ylabel('H(f)');
ylim([-100, 0]);

figure;
ifft_results = ifft(transfertFunction(f));
plot(ifft_results)

