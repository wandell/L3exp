
load(fullfile(L3Experimentrootpath,'Results','Ealgoo.mat'))
% load(fullfile(L3Experimentrootpath,'Results','taewuk4.mat'))


totaltime = rawdata.time(end) - rawdata.time(1);
disp(['Total Time = ',num2str(totaltime)])  % this is wrong
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


%% Plot final order as image
figure
imagesc((cell2mat(orders')))

xlabel('Order (most to least)')
ylabel('Scene')
set(gca, 'YTickLabel', scenelabels)
h = colorbar;
set(h, 'YTickLabel', methodlabels)

%% Plot final order as series of lines
figure
hold on
styles = {'rx-','gx-','bx-','cx-','mx-','yx-','kx-','ro-','go-','bo-','co-','mo-','yo-','ko-'};
for methodnum = 1:nummethods
    style = styles{methodnum};
    plot(sum(cell2mat(orders') == methodnum),style)
end
legend(methodlabels)
xlabel('Order (most to least)')
ylabel('Number of Scenes')

%% Plot average order score for each method
scores = zeros(1,nummethods);
for methodnum = 1:nummethods
    finalranking = sum(cell2mat(orders') == methodnum);    
    scores(methodnum) = mean((1:nummethods) .* finalranking);
end

figure
bar(scores)
xlabel('Method')
% set(gca, 'XTicks', 1:nummethods)
set(gca, 'XTickLabel', methodlabels)
ylabel('Average Order Score')

%% Image of Net Count of Votes (summed over all scenes)
allvotes = votes{1};
for scenenum=2:length(votes)
    allvotes = allvotes + votes{scenenum};
end
allvotes = allvotes - allvotes';
allvotes(allvotes<0) = 0;

figure
imagesc(allvotes)
colormap(gray)
colorbar
title('Number of More Votes for Superior Method')
xlabel('Inferior Method')
ylabel('Superior Method')
set(gca, 'XTickLabel', methodlabels)
set(gca, 'YTickLabel', methodlabels)

%% Image of Percent of Votes (summed over all scenes)
allvotes = votes{1};
for scenenum=2:length(votes)
    allvotes = allvotes + votes{scenenum};
end
votepercent = allvotes ./ (allvotes + allvotes');

figure
imagesc(votepercent)
colormap(gray)
colorbar
title('% of Votes')
xlabel('Inferior Method')
ylabel('Superior Method')
set(gca, 'XTickLabel', methodlabels)
set(gca, 'YTickLabel', methodlabels)
