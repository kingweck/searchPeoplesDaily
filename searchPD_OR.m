function raw = searchPD_OR(input)
% OR gate search for titles on front page

raw = [];
options = weboptions('Timeout' , 60);

% Structure from website query
pooled_queries = [];

for n = 1 : numel(input)
    query = input{n};
    searchTerm = [...
    '{"fld":"title","cdr":"OR","hlt":"true","vlr":"AND","qtp":"DEF","val":"' , query , '"},',...
    '{"fld":"subTitle","cdr":"OR","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , query , '"},',...
    '{"fld":"introTitle","cdr":"OR","hlt":"false","vlr":"AND","qtp":"DEF","val":"' , query , '"}'];
    
    disp(query);
    
    if n > 1
        pooled_queries = [pooled_queries , ','];
    end
    
    pooled_queries = [pooled_queries , searchTerm];
end

webquery = ['http://data.people.com.cn/rmrb/s?qs={"cds":[{"fld":"pageNum","cdr":"AND","hlt":"false","vlr":"AND","qtp":"DEF","val":"1"},{"cdr":"AND","cds":[' , pooled_queries , ']}],"obs":[{"fld":"dataTime","drt":"DESC"}]}&tr=A&ss=1&pageNo=1&pageSize=10000'];
webquery = horzcat(webquery);
raw = webread(webquery , options);
nresults = regexp(raw , '<label id="allDataCount">(\d*)</label>' , 'tokens');
disp(['Number of results: ' , nresults{1}{1}]);