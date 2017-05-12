% img_path = strcat('images/test_', num2str(img_idx), '.jpg');
% im1 = imread('images/closeup1.jpg');
% im2 = imread('images/closeup2.jpg');
% im3 = imread('images/closeup3.jpg');

im1 = imresize(imread('images/eceb1.jpg'), .3);
im2 = imresize(imread('images/eceb2.jpg'), .3);

% im4 = imresize(imread('images/rso4.jpg'), .3);
% im5 = imresize(imread('images/rso5.jpg'), .3);
% im6 = imresize(imread('images/rso6.jpg'), .3);

images = cell(2,1);

images{1} = im1;
images{2} = im2;
% images{3} = im3;
% images{4} = im4;
% images{5} = im5;
% images{6} = im6;

[x, y, z] = size(im1);

HSV1 = rgb2hsv(im1);
HSV2 = rgb2hsv(im2);
v_avg1 = 0;
v_avg2 = 0;
for j = 1:y
    for i = 1:x
        v_avg1 = v_avg1 + HSV1(i, j, 3);
        v_avg2 = v_avg2 + HSV2(i, j, 3);
    end
end

v_avg1 = v_avg1/(x*y);
v_avg2 = v_avg2/(x*y);

v_add = v_avg1 - v_avg2;

for j = 1:y
    for i = 1:x
        HSV2(i, j, 3) = HSV2(i, j, 3) + v_add;
    end
end

im2 = im2uint8(hsv2rgb(HSV2));
images{2} = im2;

pan1 = image_stich_a(images);

figure(5)
imshow(pan1);