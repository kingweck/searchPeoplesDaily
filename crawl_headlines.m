%% All titles, year by year
clearvars;
options = weboptions('timeout' , 30);

blocksize = 5000;
pooled = [];

for year = 1947 : 2018
    query = ['http://data.people.com.cn/rmrb/s?qs={"cds":[{"fld":"dataTime.start","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , num2str(year) , '-01-01"},{"fld":"dataTime.end","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , num2str(year) , '-12-31"},{"fld":"pageNum","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF"}],"obs":[{"fld":"dataTime","drt":"ASC"}]}&tr=A&ss=1&pageNo=1&pageSize=1000'];
    raw = webread(query , weboptions);
    nresults = regexp(raw , '<label id="allDataCount">(\d*)</label>' , 'tokens');
    
    if numel(nresults) == 0
        continue;
    end
    
    nloops = ceil(str2double(nresults{1}{1}) / blocksize);
    
    for n = 1 : nloops
        query_n = ['http://data.people.com.cn/rmrb/s?qs={"cds":[{"fld":"dataTime.start","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , num2str(year) , '-01-01"},{"fld":"dataTime.end","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , num2str(year) , '-12-31"},{"fld":"pageNum","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF"}],"obs":[{"fld":"dataTime","drt":"ASC"}]}&tr=A&ss=1&pageNo=' , num2str(n) , '&pageSize=' , num2str(blocksize)];
        raw = webread(query_n , options);
        titles = getTitle(raw);
        pooled = [pooled ; titles];
        disp(year);
        dispProgress(n , nloops , 1);
        disp(size(titles , 1));
    end
    
end
    