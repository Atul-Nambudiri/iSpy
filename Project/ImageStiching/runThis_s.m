% img_path = strcat('images/test_', num2str(img_idx), '.jpg');

% % Premade panorama cut
% pan = imread('images/pan_full.jpeg');
% im1 = pan(:, 1:2000, :);
% im2 = pan(:, 1001:3000, :);
% im3 = pan(:, 2001:4000, :);
% im4 = pan(:, 3001:5000, :);
% pan1 = image_stich(im1, im2);
% pan2 = image_stitch(im3, im4);
% pan3 = image_stitch(pan1, pan2);

im1 = imresize(imread('images/rso1.jpg'), .25);
im2 = imresize(imread('images/rso2.jpg'), .25);
im3 = imresize(imread('images/rso3.jpg'), .25);
im4 = imresize(imread('images/rso4.jpg'), .25);
im5 = imresize(imread('images/rso5.jpg'), .25);
im6 = imresize(imread('images/rso6.jpg'), .25);

% pan1 = image_stitch(im1, im2);
% pan2 = image_stitch(im3, im4);

tforms(1) = projective2d(eye(3));
T2 = get_tforms(im1, im2);
tforms(2).T = T2.tdata.T * tforms(1).T;
T3 = get_tforms(im1, im3);
tforms(3).T = T3.tdata.T * tforms(2).T;
T4 = get_tforms(im1, im4);
tforms(4).T = T4.tdata.T * tforms(3).T;
% T5 = get_tforms(im1, im5);
% tforms(5).T = T5.tdata.T * tforms(4).T;

imageSize = size(im1);

for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

avgXLim = mean(xlim, 2);
[~, idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);


Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = Tinv.T * tforms(i).T;
end


for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', im1);


blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:4

    I = imresize(imread(strcat('images/rso', num2str(i), '.jpg')), .25);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);

    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)


%[row, col, chan] = size(pan1);
% pan2 = image_stich(im3, im4);
% pan2 = imresize(pan2, [row, col]);

% pan3 = image_stich(pan1(200:700, 1:600, :), pan2(200:700, 1:600, :));

% figure(1)
% imshow(pan1);
% figure(1)
% imshow(pan2);