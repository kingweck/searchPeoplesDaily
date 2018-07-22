%% Query
clearvars;

% names = {'习近平' '李克强' '胡锦涛' '温家宝' '江泽民' '李鹏' '朱镕基'};
% names = {'政治体制改革' , '经济体制改革'};

options = weboptions('Timeout' , 60);

%% Search for title 
% May need to increase number of displayed results or go through all pages
raws = cell(size(names));
for n = 1 : numel(names)
    query = names{n};
    raw = webread(['http://data.people.com.cn/rmrb/s?type=2&qs={"cds":[{"cdr":"AND","cds":[{"fld":"title","cdr":"OR","hlt":"true","vlr":"AND","qtp":"DEF","val":"' , query , '"},{"fld":"subTitle","cdr":"OR","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , query , '"},{"fld":"introTitle","cdr":"OR","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , query , '"}]}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=10000'] , options);
    raws{n} = raw;
    
    disp(query);
    nresults = regexp(raw , '<label id="allDataCount">(\d*)</label>' , 'tokens');
    disp(['Number of results: ' , nresults{1}{1}]);
    dispProgress(n , numel(names) , 1);
end

%% Search for title on front page
raws = cell(size(names));
for n = 1 : numel(names)
    query = names{n};
    raw = webread(['http://data.people.com.cn/rmrb/s?type=2&qs={"cds":[{"fld":"pageNum","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"1"},{"cdr":"AND","cds":[{"fld":"title","cdr":"OR","hlt":"true","vlr":"AND","qtp":"DEF","val":"' , query , '"},{"fld":"subTitle","cdr":"OR","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , query , '"},{"fld":"introTitle","cdr":"OR","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , query , '"}]}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=10000'] , options);
    raws{n} = raw;
    
    disp(query);
    nresults = regexp(raw , '<label id="allDataCount">(\d*)</label>' , 'tokens');
    disp(['Number of results: ' , nresults{1}{1}]);
    dispProgress(n , numel(names) , 1);
end

save(['frontpage_title_' , horzcat(names{:}) , '.mat']);

%% Search for main text
raws = cell(size(names));
for n = 1 : numel(names)
    query = names{n};
    temp = webread(['http://data.people.com.cn/rmrb/s?type=2&qs={"cds":[{"fld":"contentText","cdr":"AND","hlt":"true","vlr":"AND","qtp":"DEF","val":"' , query , '"}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=10'] , options);
    nresults = regexp(temp , '<label id="allDataCount">(\d*)</label>' , 'tokens');
    
    raw = webread(['http://data.people.com.cn/rmrb/s?type=2&qs={"cds":[{"fld":"contentText","cdr":"AND","hlt":"true","vlr":"AND","qtp":"DEF","val":"' , query , '"}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=' , nresults{1}{1}] , options);
    raws{n} = raw;
    
    disp(query);
    nresults = regexp(raw , '<label id="allDataCount">(\d*)</label>' , 'tokens');
    disp(['Number of results: ' , nresults{1}{1}]);
    dispProgress(n , numel(names) , 1);
end

save(['maintext_' , horzcat(names{:}) , '.mat']);

%% Search for main text on front page
raws = cell(size(names));
for n = 1 : numel(names)
    query = names{n};
    temp = webread(['http://data.people.com.cn/rmrb/s?type=2&qs={"cds":[{"fld":"pageNum","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"1"},{"fld":"contentText","cdr":"AND","hlt":"true","vlr":"AND","qtp":"DEF","val":"' query , '"}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=10'] , options);
    nresults = regexp(temp , '<label id="allDataCount">(\d*)</label>' , 'tokens');

    raw = webread(['http://data.people.com.cn/rmrb/s?type=2&qs={"cds":[{"fld":"pageNum","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"1"},{"fld":"contentText","cdr":"AND","hlt":"true","vlr":"AND","qtp":"DEF","val":"' query , '"}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=' , nresults{1}{1}] , options);
    raws{n} = raw;
    
    disp(query);
    nresults = regexp(raw , '<label id="allDataCount">(\d*)</label>' , 'tokens');
    disp(['Number of results: ' , nresults{1}{1}]);
    dispProgress(n , numel(names) , 1);
end

save(['frontpage_maintext_' , horzcat(names{:}) , '.mat']);

%% Plot the probability of mentions (by day, moving average)
% Pooled: mentioned counts

years = 1946 : year(today);
timerange = datenum(years(1) , 1 , 1) : datenum(today);
mentioned = nan(numel(timerange) , numel(names));

for n = 1 : numel(names)
    
    temp = raws{n};
    
    parsed = regexp(temp , '(\d*)年(\d*)月(\d*)日第(\d*)版' , 'tokens');
    instances = vertcat(parsed{:});
    
    dates = cellfun(@(x) str2num(x) , instances , 'un' , 1);
    
%     frontpage = dates(dates(: , 4) == 1 , 1 : 3);
    frontpage = dates(: , 1 : 3);

    frontpage_unique = datenum(unique(frontpage , 'rows'));
    
    mentioned(: , n) = double(arrayfun(@(x) ismember(x , frontpage_unique) , timerange))';
    dispProgress(n , numel(names) , 1);
    
end

% Plot
startyear = years(1);
figurew;
set(gcf , 'position' , [23         570        1863         408]);
hold on;
toplot = 1 : numel(raws);
% toplot = [8, 9 , 11:14];
% h = plot(first_day , months_freq(: , toplot) * 100);
h = plot(timerange , 100 * smoothdata(mentioned(: , toplot) , 1 , 'movmean' , 180) , 'linewidth' , 2);

legend(names , 'box' , 'off' , 'location' , 'northeastoutside' , 'fontsize' , 18);

% colors = cbrewer('qual' , 'Set1' , 3);
% set(h , 'facecolor' , colors(2 , :) , 'facealpha' , 0.5 , 'edgecolor' , 'none');
set(gca , 'color' , [.98 .98 .98] , 'fontsize' , 16 , 'box' , 'on');

set(gca , 'xlim' , [datenum(startyear,1,1) , datenum(year(today),month(today),1)]);% , 'xtick' , [arrayfun(@(x) datenum(x , 1 , 1) , [1949 , 1953 : 5 : 2018])]);
datetick('x' , 'yyyy/mm' , 'keeplimits' , 'keepticks');
set(gca , 'ylim' , [0 100] , 'ytick' , 0 : 20 : 100 , 'yticklabel' , arrayfun(@(x) [num2str(x) , '%'] , 0 : 20 : 100 , 'un' , 0));

%% Plot the number of mentions (moving average)
% Pooled: mentioned counts

% Combine search terms
% raws = {horzcat(raws{:})};

years = 1946 : year(today);
timerange = datenum(years(1) , 1 , 1) : datenum(today);
counts = zeros(numel(timerange) , numel(names));

for n = 1 : numel(raws)
    
    temp = raws{n};
    
    parsed = regexp(temp , '(\d*)年(\d*)月(\d*)日第(\d*)版' , 'tokens');
    instances = vertcat(parsed{:});
    
    dates = cellfun(@(x) str2num(x) , instances , 'un' , 1);
    
    dates = dates(: , 1 : 3);

    [unique_dates , ia , ic] = unique(dates , 'rows');
    unique_datenum = datenum(unique_dates);
    
    % Number of counts in each of the unique dates
    temp_counts = hist(ic , 1 : numel(ia));
    
    counts(arrayfun(@(x) ismember(x , unique_datenum) , timerange) , n) = ...
        temp_counts(arrayfun(@(x) ismember(x , timerange) , unique_datenum))';
    
    dispProgress(n , numel(names) , 1);
    
end

%% Plot
figurew;
set(gcf , 'position' , [23         570        1863         408]);
hold on;

startyear = years(1);
toplot = 1;
% toplot = 1 : numel(raws);
% toplot = [8, 9 , 11:14];
% h = plot(first_day , months_freq(: , toplot) * 100);
windowsize = 60;
h = plot(timerange , smoothdata(counts(: , toplot) , 1 , 'movmean' , windowsize) , 'linewidth' , 2);

% legend(names(toplot) , 'box' , 'off' , 'location' , 'northeastoutside' , 'fontsize' , 18);

% colors = cbrewer('qual' , 'Set1' , 3);
% set(h , 'facecolor' , colors(2 , :) , 'facealpha' , 0.5 , 'edgecolor' , 'none');
set(gca , 'color' , [.98 .98 .98] , 'fontsize' , 16 , 'box' , 'on');

set(gca , 'xlim' , [datenum(startyear,1,1) , datenum(year(today),month(today),1)]);% , 'xtick' , [arrayfun(@(x) datenum(x , 1 , 1) , [1949 , 1953 : 5 : 2018])]);
set(gca , 'xtick' , [arrayfun(@(x) datenum(x , 1 , 1) , [1948:5:2018])]);
% xticks = datenum([1949 10 1 ; 1956 9 1 ; 1966 8 1 ; 1969 4 1 ; 1973 8 1 ; 1976 10 1 ; 1978 12 1 ; 1982 9 1 ; 1987 11 1 ; 1989 6 1 ; 1992 10 1 ; 1997 9 1 ; 2002 11 1 ; 2007 10 1 ; 2012 11 1 ; 2017 10 1]);
% set(gca , 'xtick' , xticks);
datetick('x' , 'yyyy/mm' , 'keeplimits' , 'keepticks');