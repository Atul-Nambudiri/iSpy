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
        trans_matrices(i) = trans_matrices(i-1).T * T.T;
    end
    
    XPos = zeros(length(images), 2);
    [x, y, z] = size(images{i});

    for i = 1:length(trans_matrices)           
        [XPos(i, :), ~] = outputLimits(trans_matrices(i), [1 y], [1 x]);    
    end

    [~, ind] = sort(mean(XPos, 2));
    center = floor((length(trans_matrices)+1)/2);
    center_idx = ind(center);

    for i = 1:length(trans_matrices)    
        trans_matrices(i).T = inv(trans_matrices(center_idx).T) * trans_matrices(i).T;
    end

    for i = 1:length(trans_matrices)           
        [xPos(i,:), ~] = outputLimits(trans_matrices(i), [1 y], [1 x]);
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
    
    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');
    panorama = zeros([round(yMax - yMin) round(xMax - xMin) 3], 'like', images{1});
    pan_ref = imref2d([round(yMax - yMin) round(xMax - xMin)], [xMin xMax], [yMin yMax]);
    
    for t = 1:length(images);
        [warpedImage, RA] = imwarp(images{t}, trans_matrices(t), 'OutputView', pan_ref);
        panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
    end
    
end