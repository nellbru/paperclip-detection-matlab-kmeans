for i = 1:14
    f = imread(sprintf('Images/trbn%d.jpg',i));
    [h, w, ~] = size(f);
    gap = 10;
    % Reduce image size for export
    coeff = 8;
    h = h/coeff;
    w = w/coeff;
    textSize = 14;
    
    figW = 2*w+3*gap;
    figH = h+4*gap+2*textSize;
    fig = figure('Units','pixels','Position',[0 0 2*w+3*gap h+4*gap+2*textSize]);

    % Show ground truth
    load(sprintf('Images/trbn%d.mat',i));
    ax1 = subplot(1,2,1);
    ax1.Units = 'pixels';
    ax1.Position = [gap 2*gap+textSize w h];
    imshow(f);
    hold('on');
    scatter([reponse.y],[reponse.x],32,'green','filled');
    text([reponse.y]+10,[reponse.x], {reponse.couleur},'FontSize',14);
    hold('off');
    t1 = title('Ground truth', 'FontSize',14);
    set(t1,'Units','normalized','Position',[0.5, 1.02, 0]);

    % Show detection results
    [x, y, c] = detect_paperclips(f);
    ax2 = subplot(1,2,2);
    ax2.Units = 'pixels';
    ax2.Position = [w+2*gap 2*gap+textSize w h];
    imshow(f);
    hold('on');
    scatter(x,y,32,'red','filled');
    text(x,y,c,'FontSize',14);
    hold('off');
    t2 = title('Detection results', 'FontSize',14);
    set(t2,'Units','normalized','Position',[0.5, 1.02, 0]);
    
    % Annotation
    annotation('textbox',[0 2*gap/figH 1 textSize/figH], ...
        'String', sprintf('trbn%d.jpg', i), ...
        'EdgeColor','none', ...
        'HorizontalAlignment','center', ...
        'FontSize',textSize);
    
    % Save results
    print(fig, sprintf('Results/result_trbn%d.png', i), '-dpng', '-r300');
end