resultfilenames = {'Ealgoo','haomiao','joyce','munenori','taewuk_new','Youngtaeg'};


%%
numsubjects = length(resultfilenames);
allvotes = zeros(11);
allorders = cell(1, numsubjects);
for resultfilenum = 1:numsubjects
    resultfilename = resultfilenames{resultfilenum};
    data = load(fullfile(L3Experimentrootpath,'Results',[resultfilename,'.mat']));
    for scenenum=1:length(data.votes)
        allvotes = allvotes + data.votes{scenenum};
    end
    allorders{resultfilenum} = cell2mat(data.orders');
end
imagenames = data.imagenames;
[numscenes, nummethods] = size(imagenames);


%% Make strings to describe each method
methodlabels = cell(1,nummethods);
for methodnum = 1:nummethods
    label = imagenames{1,methodnum};
    slashes = strfind(label,filesep);
    label(1:slashes(end)) = []; % remove folder
    label(end-3:end) = [];  % remove .png    
    methodlabels{methodnum} = label;
end


%% Make strings to describe each scene
scenelabels = cell(1,numscenes);
for scenenum = 1:numscenes
    label = imagenames{scenenum,1};
    slashes = strfind(label,filesep);
    startpt = slashes(end-1)+1;
    endpt = slashes(end)-1;
    scenelabels{scenenum} = label(startpt:endpt);
end

%% Image of Percent of Votes (summed over all scenes)
votepercent = allvotes ./ (allvotes + allvotes');
votepercent(votepercent<.5) = 0;  % ignore percents < .5

figure
imagesc(votepercent)
axis square
colormap(gray)
colorbar
title('% of Votes')
xlabel('Inferior Method')
ylabel('Superior Method')
set(gca, 'XTickLabel', methodlabels)
set(gca, 'YTickLabel', methodlabels)


%% Image of Percent of Votes (summed over all scenes)
votepercent = allvotes ./ (allvotes + allvotes');
votepercent(votepercent<.5) = 0;  % ignore percents < .5

figure
imagesc(votepercent)
axis square
colormap(gray)
colorbar
title('% of Votes')
xlabel('Inferior Method')
ylabel('Superior Method')
set(gca, 'XTickLabel', methodlabels)
set(gca, 'YTickLabel', methodlabels)

%% Image of Net Count of Votes (summed over all scenes) for some methods
selectedmethods = [1,4,2,3,5,11];
votepercent = allvotes ./ (allvotes + allvotes');

figure
imagesc(votepercent(selectedmethods, selectedmethods))
colormap(gray)
colorbar
title('Number of Votes for Superior Method')
xlabel('Inferior Method')
ylabel('Superior Method')
set(gca, 'XTickLabel', methodlabels(selectedmethods))
set(gca, 'YTickLabel', methodlabels(selectedmethods))
axis square

%% Image of Total Votes (summed over all scenes)
figure
imagesc(allvotes+allvotes')
colormap(gray)
colorbar
title('Total Number of Votes')
xlabel('Method 1')
ylabel('Method 2')
set(gca, 'XTickLabel', methodlabels)
set(gca, 'YTickLabel', methodlabels)



%%
originalorder = [11, 3, 2, 5, 1, 4, 9, 7, 8, 6, 10];  
% initial ordering used for study - each entry refers to a method with 1st
% entry as most preferred

votepercent = allvotes ./ (allvotes + allvotes');
votepercentvector = zeros(1,length(originalorder)-1);

for ordernum = 1: (length(originalorder) - 1)
    method1 = originalorder(ordernum);
    method2 = originalorder(ordernum+1);    
    votepercentvector(ordernum) = votepercent(method1, method2);
end

figure
imagesc(votepercentvector)
set(gca, 'XTick', .5: (length(originalorder)-.5))
set(gca, 'XTickLabel', methodlabels(originalorder))
set(gca, 'YTick', [])
colormap(winter)
colorbar
title('% of Times Left Method is Preferred over Right Method')


%% Plot final order as image (different figure for each scene)
for scenenum=1:numscenes
    order1scene = zeros(numsubjects, nummethods);
        
    for subjectnum = 1:numsubjects
        order1scene(subjectnum,:) = allorders{subjectnum}(scenenum,:);
    end
    
    figure
    imagesc(order1scene)
    
    cmap = zeros(nummethods, 3);
    cmap(1:5, 1) = (2:6)/6;  % L3 are red
    cmap(6:10, 3) = (2:6)/6; % basic are blue
    colormap(cmap);
    
    title(scenelabels(scenenum))
    xlabel('Rank (most to least preferred)')
    ylabel('Subject')
    h = colorbar;
    set(h, 'YTickLabel', methodlabels)
end