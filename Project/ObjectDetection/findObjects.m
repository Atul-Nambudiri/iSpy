scene2 = imresize(imread('scene/untitled.jpg'), 1.0);
panorama = load('scene/panorama_attempt1.mat');
scene3 = imresize(imread('scene/scene2.jpg'), 1.0);
% scene_chair = imresize(imread('scene/scene_chair.jpg'), 0.3);

% im_size = size(scene2);

% scene = scene2(:, 1:im_size(2)/2, :);
scene = scene3;
% scene = scene3;
scene_n = single(rgb2gray(scene));

obj2a = imresize(imread('objects/obj2a.jpg'), 0.5);
temp_size = size(scene);
% obj2b = imresize(imread('objects/obj2c.jpg'), temp_size(1:2));
% obj_waldo = imresize(imread('objects/waldo.png'), 1.0);
% obj_chair = imresize(imread('objects/obj_chair.jpg'), 0.3);
% obj_eraser = imresize(imread('objects/obj_eraser.jpg'), 0.3);

target = obj2a;

target_n = single(rgb2gray(target));

% [f1, d1] = vl_sift(target_n, 'PeakThresh', 5);
% [f2, d2] = vl_sift(scene_n, 'PeakThresh', 5);

%%
close all;

[f1, d1] = vl_sift(target_n, 'PeakThresh', 5);
[f2, d2] = vl_sift(scene_n, 'PeakThresh', 5);

[matches, scores] = vl_ubcmatch(d1, d2, 2) ;

% matches = matches(:, scores > 20000);

showMatchedFeatures(target, scene, f1(1:2, matches(1, :))', f2(1:2, matches(2, :))', 'montage');

%%
[f1, d1] = vl_sift(target_n, 'PeakThresh', 3);
[f2, d2] = vl_sift(scene_n, 'PeakThresh', 3);

[matches, scores] = vl_ubcmatch(d1, d2, 2) ;
% matches = matches(:, scores > 20000);
T = alignShape(f1(1:2, matches(1, :)), f2(1:2, matches(2, :)));
% showMatchedFeatures(target, scene, iTarget, iScene, 'montage');

%%
close all;

[x, y] = getBoundingBox(f1(1, :), f1(2, :));
pts_ = [x; y; ones(size(x))];
pts = T * pts_;

imagesc(target);
hold on;
% h1 = vl_plotframe(f1(:,matches(1,:)));
plot(x, y, 'LineWidth', 2, 'Color', 'r');

figure;
imagesc(scene);
hold on;
% h2 = vl_plotframe(f2(:,matches(2,:)));
plot(pts(1, :), pts(2, :), 'LineWidth', 2, 'Color', 'r');

pts_case = pts;

% testpts = T*[f1(1:2, matches(1, :)); ones(1, size(f1(1:2, matches(1, :)), 2))];
% plot(testpts(1, :), testpts(2, :), 'r+');

%%
figure;
imagesc(scene);
hold on;
iptsetpref('ImshowBorder','tight');
set(gca,'position',[0 0 1 1],'units','normalized')
% h2 = vl_plotframe(f2(:,matches(2,:)));
plot(pts_binder(1, :), pts_binder(2, :), 'LineWidth', 2, 'Color', 'r');
plot(pts_cards(1, :), pts_cards(2, :), 'LineWidth', 2, 'Color', 'g');
plot(pts_case(1, :), pts_case(2, :), 'LineWidth', 2, 'Color', 'b');
plot(pts_gum(1, :), pts_gum(2, :), 'LineWidth', 2, 'Color', 'c');
plot(pts_passport(1, :), pts_passport(2, :), 'LineWidth', 2, 'Color', 'm');
