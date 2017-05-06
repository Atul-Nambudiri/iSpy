function [ims] = other_method(left_orig, right_orig)
% left_orig = imresize(imread('images/test_1.jpg'), [459, 816]);

% for img_idx = 2:3   
%     img_path = strcat('images/test_', num2str(img_idx), '.jpg');
% %     left_orig = imresize(imread('images/left.jpg'), .3);
%     [row, col, chan] = size(left_orig);
%     right_orig = imresize(imread(img_path), [row, col]);

    left_s = single(rgb2gray(left_orig));
    right_s = single(rgb2gray(right_orig));

    [f_left,d_left] = vl_sift(left_s);
    [f_right,d_right] = vl_sift(right_s);
    [matches, scores] = vl_ubcmatch(d_left, d_right);

    matches = matches';
    r1 = f_left(2, :);
    c1 = f_left(1, :);
    r2 = f_right(2, :);
    c2 = f_right(1, :);

    h = 1;

    r1_old = r1;
    c1_old = c1;
    r2_old = r2;
    c2_old = c2;

    mean1Y = mean(r1);
    mean1X = mean(c1);
    mean2Y = mean(r2);
    mean2X = mean(c2);

    std1Y = std(r1);
    std1X = std(c1);
    std2Y = std(r2);
    std2X = std(c2);

    t1 = [1 0 -mean1X; 0 1 -mean1Y; 0 0 1];
    t2 = [1/std1X 0 0; 0 1/std1Y 0; 0 0 1];
    t3 = [1/std2X 0 0; 0 1/std2Y 0; 0 0 1];
    t4 = [1 0 -mean2X; 0 1 -mean2Y; 0 0 1];

    %Create the normalization matrices to normalize the coordinates
    T1 = t2 * t1;
    T2 = t3 * t4;

    %Normalize the coordinates
    for r = 1:length(c1)
        n_point = T1 * vertcat(c1(r), r1(r), 1);
        c1(r) = n_point(1);
        r1(r) = n_point(2);
    end

    for c = 1:length(c2)
        n_point = T2 * vertcat(c2(c), r2(c), 1);
        c2(c) = n_point(1);
        r2(c) = n_point(2);
    end

    [n, k] = size(matches);
    best_number_in_threshold = 0;
    best_dist = 0;
    threshold = 3;
    best_set = zeros(1);
    best_H = zeros(1);

    best_inliers = [];
    best_outliers = [];

    for t = 1:2000
        set = randperm(n, 4);

        inliers = [];
        outliers = [];

        points1 = ones(4, 3);
        points2 = ones(4, 3);

        A = zeros(8, 9);

        for i = 1:4
            pos1 = matches(set(i), 1);
            pos2 = matches(set(i), 2);

            u1 = c1(pos1);
            v1 = r1(pos1);
            u2 = c2(pos2);
            v2 = r2(pos2);

            A(2*(i-1) + 1, :) = [-u1, -v1, -1, 0, 0, 0, u1 * u2, v1 * u2, u2];
            A(2*(i-1) + 2, :) = [0, 0, 0, -u1, -v1, -1, u1 * v2, v1 * v2, v2];
        end

        [U, S, V] = svd(A);
        h = V(:, end);
        H = reshape(h, [3 3])';

        %Normalize this H for future calculations
        norm_H = inv(T2) * H * T1;

        number_in_threshold = 0;
        dist_sum = 0;

        % Calculate I for each point, normalize it, and then check to see if 
        % its in the threshold
        for i = 1:n
            u = c1_old(matches(i, 1));
            v = r1_old(matches(i, 1));
            u2 = c2_old(matches(i, 2));
            v2 = r2_old(matches(i, 2));

            I = norm_H * vertcat(u, v, 1);
            I(1) = I(1)/I(3);
            I(2) = I(2)/I(3);
            distance = sqrt((I(1) - u2)^2 + (I(2) - v2)^2);

            if distance < threshold
                number_in_threshold = number_in_threshold + 1;
                dist_sum = dist_sum + distance;
                inliers = [inliers; i];
            else
                outliers = [outliers; i];
            end
        end
        if number_in_threshold >= best_number_in_threshold
            best_set = set;
            best_H = H;
            best_number_in_threshold = number_in_threshold;
            best_dist = dist_sum;
            best_inliers = inliers;
            best_outliers = outliers;
        end
    end

    % Unnormalize H
    % H = inv(T2) * best_H * T1;
    % 
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get a tranformation and apply it to the left image - This part does not work
    % tform = projective2d(H);
    % new_im = imwarp(double(left), tform);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display the best matching points
    pos1 = matches(best_set, 1);
    pos2 = matches(best_set, 2);

    u1 = c1_old(pos1);
    v1 = r1_old(pos1);
    u2 = c2_old(pos2);
    v2 = r2_old(pos2);
    % 
    T = maketform('projective',[u2' v2'],[u1' v1']);
    % [new_im, x, y] = imtransform(left_orig, T);
    % 
    % x_size = [min(1, x(1)), max(right_orig, 2), x(2))];
    % y_size = [min(1, y(1)), max(right_orig, 1), y(2))];

    % im1 = imtransorm(

    % figure()
    % subplot(121);
    % imagesc(left_orig); hold on; axis image; axis off;
    % subplot(122);
    % imagesc(new_im); hold on; axis image; axis off;


    [im2t,xcoord,ycoord] = imtransform(right_orig,T);

    ycombo(1, 1) = min(1,ycoord(1));
    ycombo(1, 2) = max(size(left_orig,1),ycoord(2));

    I3 = zeros(3);
    for i = 1:3
        I3(i, i) = 1;
    end

    xcombo(1, 1) = min(1,xcoord(1));
    xcombo(1, 2) = max(size(left_orig,2),xcoord(2));

    im2t = imtransform(right_orig,T,'XData',xcombo,'YData',ycombo);
    im1t = imtransform(left_orig,maketform('affine',I3),'XData',xcombo,'YData',ycombo);

    ims=max(im1t,im2t);
%     imshow(ims);
%     left_orig = imresize(ims, [459, 816]);\
%     left_orig = ims;
% end
end