%% Search terms
clearvars;
names = {'毛泽东' '华国锋' '邓小平' '胡耀邦' '赵紫阳' '江泽民' '胡锦涛' '习近平'};
legendnames = {'毛泽东 Mao Zedong' '华国锋 Hua Guofeng' '邓小平 Deng Xiaoping' '胡耀邦 Hu Yaobang' '赵紫阳 Zhao Ziyang' '江泽民 Jiang Zemin' '胡锦涛 Hu Jintao' '习近平 Xi Jinping'};

queries = {{'毛泽东' '毛主席'} , {'华国锋' '华主席' '华总理'} , {'邓小平' '邓副总理' '邓副主席' '邓副委员长'} , {'胡耀邦'} , {'赵紫阳'} , {'江泽民' '江总书记' '江主席'} , {'胡锦涛'} , {'习近平' '习总书记' '习主席'}};

%% Search frontpage titles
raws = cell(size(names));
for n = 1 : numel(names)
    query = queries{n};
    
    raws{n} = searchPD_OR(query);
    dispProgress(n , numel(names) , 1);
end

save(['frontpage_title_' , horzcat(names{:}) , '.mat']);

%% Mao quotations
mao_quotations = searchPD_OR({'毛主席语录'});

years = 1946 : year(today);
timerange = datenum(years(1) , 1 , 1) : datenum(today);
mao_quotation_counts = zeros(numel(timerange) , 1);

temp = mao_quotations;
parsed = regexp(temp , '(\d*)年(\d*)月(\d*)日第(\d*)版' , 'tokens');
instances = vertcat(parsed{:});

dates = cellfun(@(x) str2num(x) , instances , 'un' , 1);

dates = dates(: , 1 : 3);

[unique_dates , ia , ic] = unique(dates , 'rows');
unique_datenum = datenum(unique_dates);
    
% Number of counts in each of the unique dates
temp_counts = hist(ic , 1 : numel(ia));

mao_quotation_counts = [unique_datenum , temp_counts'];

%% Plot the number of mentions (moving average)
load('frontpage_articles_counts.mat');

years = 1946 : year(today);
timerange = datenum(years(1) , 1 , 1) : datenum(today);
counts = zeros(numel(timerange) , numel(names));
counts_normalized = counts;


for n = 1 : numel(raws)
    
    temp = raws{n};
    
    parsed = regexp(temp , '(\d*)年(\d*)月(\d*)日第(\d*)版' , 'tokens');
    instances = vertcat(parsed{:});
    
    dates = cellfun(@(x) str2num(x) , instances , 'un' , 1);
    
    dates = dates(: , 1 : 3);

    [unique_dates , ia , ic] = unique(dates , 'rows');
    unique_datenum = datenum(unique_dates);
    
    % Find in total number of articles
    [~ , idx] = ismember(unique_datenum , frontpage_articles(: , 1));
    total_counts = frontpage_articles(idx , 2);
    
    % Number of counts in each of the unique dates
    temp_counts = hist(ic , 1 : numel(ia));
    mao_counts = zeros(size(temp_counts));
    
    % Take out Mao quotations
    if n == 1
        [hit , idx] = ismember(unique_datenum , mao_quotation_counts(: , 1));
        mao_counts(hit) = mao_quotation_counts(idx(hit) , 2);
        temp_counts = temp_counts - mao_counts;
    end
     
    temp_counts_normalized = temp_counts ./ total_counts';
    temp_counts_normalized(temp_counts_normalized > 1) = 1;
    
    counts(arrayfun(@(x) ismember(x , unique_datenum) , timerange) , n) = ...
        temp_counts(arrayfun(@(x) ismember(x , timerange) , unique_datenum))';
    
    counts_normalized(arrayfun(@(x) ismember(x , unique_datenum) , timerange) , n) = ...
        temp_counts_normalized(arrayfun(@(x) ismember(x , timerange) , unique_datenum))';
    
    dispProgress(n , numel(names) , 1);
    
end

%% Plot
figurew;
set(gcf , 'position' , [23         570        1863         408]);
hold on;

startyear = years(1);
% toplot = 1;
toplot = 1 : numel(raws);
% toplot = [8, 9 , 11:14];
% h = plot(first_day , months_freq(: , toplot) * 100);
windowsize = 180;
% h = plot(timerange , smoothdata(counts(: , toplot) , 1 , 'movmean' , windowsize) , 'linewidth' , 2);
h = plot(timerange , smoothdata(counts_normalized(: , toplot) , 1 , 'movmean' , windowsize) , 'linewidth' , 2);

legend(legendnames(toplot) , 'box' , 'off' , 'location' , 'northeastoutside' , 'fontsize' , 18);

% colors = cbrewer('qual' , 'Set1' , 3);
% set(h , 'facecolor' , colors(2 , :) , 'facealpha' , 0.5 , 'edgecolor' , 'none');
set(gca , 'color' , [.95 .95 .95] , 'fontsize' , 16 , 'box' , 'on');

set(gca , 'xlim' , [datenum(startyear,1,1) , datenum(year(today),month(today),1)]);% , 'xtick' , [arrayfun(@(x) datenum(x , 1 , 1) , [1949 , 1953 : 5 : 2018])]);
% set(gca , 'xtick' , [arrayfun(@(x) datenum(x , 1 , 1) , [1948:5:2018])]);
xticks = datenum([1946 1 1 ; 1951 1 1 ; 1956 9 1 ; 1961 1 1 ; 1966 1 1 ; 1971 1 1 ; 1976 10 1 ; 1981 6 1 ; 1987 1 1 ; 1992 10 1 ; 1997 9 1 ; 2002 11 1 ; 2007 10 1 ; 2012 11 1 ; 2017 10 1]);
set(gca , 'xtick' , xticks);
datetick('x' , 'yyyy/mm' , 'keeplimits' , 'keepticks');