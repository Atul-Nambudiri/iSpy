% img_path = strcat('images/test_', num2str(img_idx), '.jpg');
im1 = imresize(imread('images/rso1.jpg'), .3);
im2 = imresize(imread('images/rso2.jpg'), .3);
im3 = imresize(imread('images/rso3.jpg'), .3);
im4 = imresize(imread('images/rso4.jpg'), .3);
im5 = imresize(imread('images/rso5.jpg'), .3);
im6 = imresize(imread('images/rso6.jpg'), .3);

images = cell(6,1);

images{1} = im1;
images{2} = im2;
images{3} = im3;
images{4} = im4;
images{5} = im5;
images{6} = im6;

pan1 = image_stich_a(images);

figure(1)
imshow(pan1);