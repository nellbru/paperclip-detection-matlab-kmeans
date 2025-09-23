function [x, y, c] = detect_paperclips(image)
    % RGB components
    R = image(:, :, 1);
    G = image(:, :, 2);
    B = image(:, :, 3);

    % HSV components
    imageHSV = rgb2hsv(image);
    H = imageHSV(:, :, 1);
    S = imageHSV(:, :, 2);
    V = imageHSV(:, :, 3);

    % Segmentation based on each color
    red = (H > 0 & H < 0.1) & R > 70 & G < 40 & B < 40;
    green = (H > 0.35 & H < 0.45) & S > 0.25;
    blue = (H > 0.5 & H < 0.6) & S > 0.25;
    purple = (H > 0.68 & H < 0.74) & S > 0.25;
    pink = (H > 0.9 & H < 1) & S > 0.25;
    yellow = (H > 0.12 & H < 0.15) & S > 0.25;
    white = imdilate(V,strel('disk', 15))-imerode(V,strel('disk', 15));
    white = white > 0.25;
    white = imclose(white,strel('disk', 15));
    
    % Arrays
    colors = {red, green, blue, purple, pink, yellow, white};
    colorList = {'rouge', 'vert', 'bleu', 'mauve', 'rose', 'jaune', 'blanc'};

    for i = 1:length(colors)-1
        % Morphological operations
        colors{i} = imdilate(imopen(colors{i}, strel('disk', 5)),strel('disk', 70));
        
        % Remove regions with area smaller than 50000 pixels
        colors{i} = bwareaopen(colors{i}, 50000);
        colors{i} = colors{i}-bwareaopen(colors{i}, 400000); % To remove false positives due to the background
    end
    
    % White paperclip detection
    colors{6} = imdilate(colors{6},strel('disk', 20));
    mask = colors{1} | colors{2} | colors{3} | colors{4} | colors{5} | colors{6};
    colors{7} = colors{7} & ~mask;
    colors{7} = imdilate(colors{7},strel('disk', 55));
    colors{7} = bwareaopen(colors{7}, 40000);
    colors{7} = colors{7}-bwareaopen(colors{7}, 300000); % To remove paper lines

    % Initialization of output variables
    x = [];
    y = [];
    c = {};

    for i = 1:length(colors)
        
        % Connected regions
        connComp = bwconncomp(colors{i});
        stats = regionprops(connComp, 'Area');
        areas = [stats.Area];

       % Number of connected regions based on area
        mean_area = mean(areas); % Average area of regions
        k = 0; % Initialization of the number of regions

        for area = areas 
            if(area > 1.2*mean_area || (length(areas) == 1 && area > 300000))
                k = k+2; % Count 2 regions for large regions
            else
                k = k+1;
            end
        end
            
        if(k ~= 0)
            [X, Y] = find(colors{i});

            % k-means
            rng(2); % Fix random state for k-means
            [idx, C] = kmeans([X, Y], k);

            % Save coordinates and colors
            for j = 1:size(C, 1)
                x = [x, C(j, 2)];
                y = [y, C(j, 1)];
                c = [c, colorList{i}];
            end
        end
    end
end