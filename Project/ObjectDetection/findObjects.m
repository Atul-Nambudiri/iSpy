obj2a = imresize(imread('objects/obj2a.jpg'), 0.3);
obj2b = imresize(imread('objects/obj2c.jpg'), 0.3);

target = obj2b;

target_n = single(rgb2gray(target));

scene = imresize(imread('scene/scene2.jpg'), 0.3);
scene_n = single(rgb2gray(scene));

[f1, d1] = vl_sift(target_n, 'PeakThresh', 5);
[f2, d2] = vl_sift(scene_n, 'PeakThresh', 5);

%%
close all;
[matches, scores] = vl_ubcmatch(d1, d2, 2) ;

T = alignShape(f1(1:2, matches(1, :)), f2(1:2, matches(2, :)));

[x, y] = getBoundingBox(f1(1, :), f1(2, :));
pts_ = [x; y; ones(size(x))];
pts = T * pts_;

imagesc(target);
hold on;
h1 = vl_plotframe(f1(:,matches(1,:)));
plot(x, y, 'LineWidth', 2, 'Color', 'r');

figure;
imagesc(scene);
hold on;
h2 = vl_plotframe(f2(:,matches(2,:)));
plot(pts(1, :), pts(2, :), 'LineWidth', 2, 'Color', 'r');

testpts = T*[f1(1:2, matches(1, :)); ones(1, size(f1(1:2, matches(1, :)), 2))];
plot(testpts(1, :), testpts(2, :), 'r+');