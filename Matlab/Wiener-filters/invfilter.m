function x2hat = invfilter(y2,h,isMask)

if isMask == true
	[MY2 NY2] = size(y2);
	[MH NH] = size(h);

	hp = padarray(h,[MY2-MH NY2-NH], 'post');

	M = MY2;
	N = NY2;

	u1n1 = (0:(M-1))'*(0:(M-1));
	u2n2 = (0:(N-1))'*(0:(N-1));
	WN1 = exp(i*(2*pi*u1n1)/M);
	WN2 = exp(i*(2*pi*u2n2)/N);
	Y2 = (WN1)'*(y2)*conj(WN2);
	H = (WN1)'*(hp)*conj(WN2);
	Z = Y2./H;
	x = real((1/(M*N))*WN1*(Z)*((WN2).'));
	x2hat = x(1:(MY2-MH+1),1:(NY2-NH+1));

	imshow(x2hat)
else
	x2hat = ifft2(y2*h);
	imshow(x2hat)
end