function [panorama] = image_stich_a(images)
    I3 = zeros(3);
    for i = 1:3
        I3(i, i) = 1;
    end
    
    for i = 1:length(images)
        trans_matrices(i) = projective2d(I3);
    end
    
    for i = 2:length(images)
        T = getTForm(images{i}, images{i-1});
        trans_matrices(i) = T;
    end
    
    XPos = zeros(length(images), 2);
    [x, y] = size(images{i});

    for i = 1:length(images) 
        [~, RB] = imwarp(images{i}, trans_matrices(i));
        [xcoord, ycoord] = outputLimits(trans_matrices(i), [1 y], [1 x]);   
    end
    
    [~, index] = sort(mean(XPos, 2));
    center = floor((length(trans_matrices)+1)/2);

    center_idx = index(center);

    Tinv = invert(trans_matrices(center_idx));

    for i = 1:length(trans_matrices)    
        trans_matrices(i).T = Tinv.T * trans_matrices(i).T;
    end

    
    xMin = 1;
    yMin = 1;
    
    yMax = 1;
    xMax = 1;
    
    for i = 1:length(images) 
        [xcoord, ycoord] = outputLimits(trans_matrices(i), [1 y], [1 x]);
        xMin = min([xMin, xcoord(1)]);
        yMin = min([yMin, ycoord(1)]);
        xMax = max([xMax, xcoord(2)]);
        yMax = max([yMax, ycoord(2)]);
    end
    
    panorama = zeros([round(yMax - yMin) round(xMax - xMin) 3], 'like', images{1});

    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');  

    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    [p_rows, p_cols, ~] = size(panorama);
    panoramaView = imref2d([p_rows p_cols], xLimits, yLimits);

    for i = 1:length(images)
        I = images{i};
        curr_projection = trans_matrices(i);
        warpedImage = imwarp(I, curr_projection, 'OutputView', panoramaView);
        panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
    end

    figure
    imshow(panorama)
    
end