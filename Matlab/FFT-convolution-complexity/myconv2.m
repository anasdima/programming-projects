function z = myconv2(h,x)

[MX NX] = size(x);
[MH NH] = size(h);
MZ = MX + MH - 1;
NZ = NX + NH - 1;

x = padarray(x,[MH-1 NH-1]);
[MXP NXP] = size(x);
h = h';
h = fliplr(h(:)');

% generate xp index base vectors
xpC = 1:MXP:((NH-1)*MXP+1);
xpCE = bsxfun(@plus,xpC(:),0:(MH-1)); % periodically extended column
xpR = 0:MXP:((NZ-1)*MXP);
xpRE = bsxfun(@plus,xpR(:),0:(MZ-1)); % periodically extended row

% generate xp index grid from the base vectors
xpIDX = bsxfun(@plus,xpCE(:),xpRE(:)');

z = vec2mat(h*x(xpIDX),NZ);
