clc; clear all; close all;


t = 0:0.1:99;
x = abs(randn(size(t))) + 5*abs(sin(t/10));
size(x)

signal = 3*rectangularPulse((t -50)/0.1);
x = x+ signal;

[hits, threshold] = CFAR(x, 10, 2,2.5);
plot(t, x, t, threshold)
hold on
scatter(t, hits*2, "filled", "red")