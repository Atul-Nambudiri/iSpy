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
    
    [x, y] = size(images{i});

    imageSize = size(images{i});  % all the images are the same size

    % Compute the output limits  for each transform
    for i = 1:length(trans_matrices)           
        [xlim(i,:), ylim(i,:)] = outputLimits(trans_matrices(i), [1 imageSize(2)], [1 imageSize(1)]);    
    end

    %%
    % Next, compute the average X limits for each transforms and find the image
    % that is in the center. Only the X limits are used here because the scene
    % is known to be horizontal. If another set of images are used, both the X
    % and Y limits may need to be used to find the center image.

    avgXLim = mean(xlim, 2);

    [~, idx] = sort(avgXLim);

    centerIdx = floor((numel(trans_matrices)+1)/2);

    centerImageIdx = idx(centerIdx);

    %%
    % Finally, apply the center image's inverse transform to all the others.

    Tinv = invert(trans_matrices(centerImageIdx));

    for i = 1:numel(trans_matrices)    
        trans_matrices(i).T = Tinv.T * trans_matrices(i).T;
    end

    %% Step 3 - Initialize the Panorama
    % Now, create an initial, empty, panorama into which all the images are
    % mapped. 
    % 
    % Use the |outputLimits| method to compute the minimum and maximum output
    % limits over all transformations. These values are used to automatically
    % compute the size of the panorama.

    for i = 1:length(trans_matrices)           
        [xlim(i,:), ylim(i,:)] = outputLimits(trans_matrices(i), [1 imageSize(2)], [1 imageSize(1)]);
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
    panorama = zeros([height width 3], 'like', images{1});

    %% Step 4 - Create the Panorama
    % Use |imwarp| to map images into the panorama and use
    % |vision.AlphaBlender| to overlay the images together.

    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');  

    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);

    % Create the panorama.
    for i = 1:length(images);

        I = images{i};

        % Transform I into the panorama.
        warpedImage = imwarp(I, trans_matrices(i), 'OutputView', panoramaView);

        % Overlay the warpedImage onto the panorama.
        panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
    end

    figure
    imshow(panorama)
    
end