function G = wienerfilter(H,K)

G = conj(H)./((abs(H).^2)+1/K);
