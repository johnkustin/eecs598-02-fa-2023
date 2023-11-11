clear all;

u_int = readmatrix('u.txt');
u_in1 = size(3000);
lms_int = readmatrix('lms_out.txt');
w = zeros(32, 3000);
w_out = zeros(32, 3000);

for i = 1:3000
    for j = 1:10
        if (u_int(i,j) > 0 || u_int(i,j) <= 0)
            u_in1(i) = u_int(i,j);
        end
    end
end

u_in = transpose(u_in1);
u_in_fixed_point = u_in * 2^31;

for i1 = 1:2000
    w_out(1:32, i1) = conv(w(1:32, i1), u_in(i1));
    w(1:32, i1+1) = w(1:32, i1) + lms_int(32*i1-31: 32*i1);
end

