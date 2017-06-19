function z = myconv2(h,x)

[MX NX] = size(x);
[MH NH] = size(h);
MZ = MX + MH - 1;
NZ = NX + NH - 1;

x = padarray(x,[MH-1 NH-1]);
h = flip(flip(h,2),1);
h = h(:)';

z = zeros(MZ,NZ);

for K1 = 1:MZ
	h_range = K1:((K1-1)+MH);
	for K2 = 1:NZ
		x_range = K2:((K2-1)+NH);
		xs = x(h_range,x_range);
		z(K1,K2) = h*xs(:);
	end
end
