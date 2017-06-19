clear all;
load ../images.mat;
clc;

[MX1 NX1] = size(x1);
[MY1 NY1] = size(y1);

x1p = padarray(x1,[MY1-MX1 NY1-NX1], 'pre');

H = fft2(y1)./fft2(x1p);
G = wienerfilter(H,0.1); %arbitrary K

invfilter(fft2(y2),G,false);