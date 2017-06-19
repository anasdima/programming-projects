function h = estMask(x,y)

[MX NX] = size(x);
[MY NY] = size(y);

MH = MY - MX + 1;
NH = NY - NX + 1;

len = floor(sqrt(MH^2+NH^2));
ang = floor(atand(MH/NH));

tests = [0 -1 1];

mine = sum(y);
for i = 1:3
	for j = 1:3
		h_test = fspecial('motion',len+tests(i),ang+tests(j));
		if [MH NH] == size(h_test)
			y_test = conv2(x,h_test);
			e = sum(abs(y-y_test));
			if e < mine
				mine = e;
				blurred = y_test;
				h = h_test;
			end
		end
	end
end

imshow(blurred)


