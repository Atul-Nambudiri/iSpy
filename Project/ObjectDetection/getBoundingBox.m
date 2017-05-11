function [x, y] = getBoundingBox(ptsX, ptsY)
    x1 = min(ptsX);
    x2 = max(ptsX);
    
    y1 = min(ptsY);
    y2 = max(ptsY);
    
    x = [x1, x1, x2, x2, x1];
    y = [y1, y2, y2, y1, y1];
end