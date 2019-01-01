# searchPeoplesDaily
Search for query terms in People's Daily

searchPD.m contains syntax for different kind of searches: headline/text/front-page/all pages etc.
searchPD_OR.m does OR gates

For historical headline data: 

crawl_headlines.m crawls through http://data.people.com.cn/rmrb/ site for all historical headlines

all_titles_split.zip contains raw data
*.txt: every single headline in People's Daily since 1946
*.txt_parsed.txt: titles segmented by Boson NLP's tag tool, and tagged with part of speech (see http://docs.bosonnlp.com/tag_rule.html)
