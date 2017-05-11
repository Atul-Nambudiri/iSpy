function T = calculateTransformation(u1, v1, u2, v2, errThreshold, inlierThreshold, iterations)
N = iterations;
T = zeros(2, 3);
bestErr = inf;

numInlierThres = length(u1) * inlierThreshold;

for i = 1:N
    sample = randperm(length(u1), 1);
    tempT = calculateTransform(u1(sample), v1(sample), u2(sample), v2(sample));

    checkInd = setdiff(1:length(u1), sample);
    tempErr = calcError(tempT, u1(checkInd), v1(checkInd), u2(checkInd), v2(checkInd));
    
    inliers = checkInd(tempErr < errThreshold);
        
    if length(inliers) > numInlierThres
        samples = cat(2, sample, inliers);
        
        tempT = calculateTransform(u1(samples), v1(samples), u2(samples), v2(samples));
        
        tempErr = sum(calcError(tempT, u1(samples), v1(samples), u2(samples), v2(samples)));
        
        if tempErr < bestErr
            bestErr = tempErr;
            T = tempT;
        end
    end
end

function T = calculateTransform(u1, v1, u2, v2)
    A = zeros(2 * size(u1, 1), 6);
    
    for ii = 1:size(u1, 1)
        A(2*ii-1, 1:3) = [u1(ii) v1(ii) 1];
        A(2*ii, 4:6) = A(2*ii-1, 1:3);
    end
    
    b = zeros(2*size(u2, 1), 1);
    
    for ii = 1:size(u1 ,1)
        b(2*ii-1:2*ii) = [u2(ii) v2(ii)];
    end
    
    T_ = A \ b;
    T = [T_(1:3)' ; T_(4:6)'];


function err = calcError(T, u1, v1, u2, v2)
    pts1 = [u1'; v1'; ones(size(u1))'];
    pts2 = [u2'; v2'];
    
    ptsT = T*pts1;
    ptsDiffSq = (pts2-ptsT).^2;
    ptsDist = sqrt(ptsDiffSq(1, :) + ptsDiffSq(2, :));
    
    err = ptsDist;