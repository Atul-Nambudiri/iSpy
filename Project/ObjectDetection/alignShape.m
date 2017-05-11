function T = alignShape(pts0, pts1)

x0 = pts0(1, :)';
y0 = pts0(2, :)';

x1 = pts1(1, :)';
y1 = pts1(2, :)';

ux0 = mean(x0);
uy0 = mean(y0);

ux1 = mean(x1);
uy1 = mean(y1);

sdx0 = std(x0);
sdy0 = std(y0);

sdx1 = std(x1);
sdy1 = std(y1);

nx0 = (x0 - ux0) / sdx0;
ny0 = (y0 - uy0) / sdy0;

nx1 = (x1 - ux1) / sdx1;
ny1 = (y1 - uy1) / sdy1;

ts0 = [1/sdx0 0 0;
       0 1/sdy0 0;
       0 0      1];
tt0 = [1 0 -ux0;
       0 1 -uy0;
       0 0    1];

ts1 = [1/sdx1 0 0;
       0 1/sdy1 0;
       0 0      1];
tt1 = [1 0 -ux1;
       0 1 -uy1;
       0 0    1];

t0 = ts0 * tt0;
t1 = ts1 * tt1;

T_ = calculateTransformation(nx0, ny0, nx1, ny1, 0.2, 0.2, 1000);
T_ = [T_; 0 0 1];

T = inv(t1) * T_ * t0;