function z = myconv2(h,x)

[MX NX] = size(x);
[MH NH] = size(h);
MZ = MX + MH - 1;
NZ = NX + NH - 1;

h = padarray(h,[MX-1 NX-1]);
x = flip(flip(x,2),1);

z = zeros(MZ,NZ);

for K1 = 1:MZ
	x_range = ((K1-1)+1):((K1-1)+MX);
	for K2 = 1:NZ
		h_range = ((K2-1)+1):((K2-1)+NX);
		z(K1,K2) = sum(sum(x.*h(x_range,h_range)));
	end
end


