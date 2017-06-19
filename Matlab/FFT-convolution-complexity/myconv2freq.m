function z = myconv2freq(h,x)

[MX NX] = size(x);
[MH NH] = size(h);

hp = padarray(h,[MX-MH NX-NH], 'post');

M = MX;
N = NX;

u1n1 = (0:(M-1))'*(0:(M-1));
u2n2 = (0:(N-1))'*(0:(N-1));
WN1 = exp(i*(2*pi*u1n1)/M);
WN2 = exp(i*(2*pi*u2n2)/N);
X = (WN1)'*(x)*conj(WN2);
H = (WN1)'*(hp)*conj(WN2);

Z = X.*H;
z = (1/(M*N))*WN1*(Z)*((WN2).');