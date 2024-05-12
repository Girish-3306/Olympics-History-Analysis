use namastesql;

Select * from athlete_events;

Select * from athletes;

Select MIN(year) as min_year, MAX(year) as max_year from athlete_events;

Select DISTINCT(sport) from athlete_events;

Select DISTINCT(medal) from athlete_events;

--1 which team has won the maximum gold medals over the years.
Select * from athlete_events;
Select * from athletes;

Select TOP 1 team, COUNT(distinct(event)) as ccnt
from athlete_events ae
inner join athletes ath on ath.id = ae.athlete_id
where medal = 'Gold'
group by team
order by ccnt desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
Select * from athlete_events;
Select * from athletes;

WITH CTE as (
Select team,year,count(distinct event) as silver_medals,
RANK() over (partition by team order by count(distinct event) desc) as rn
from  athlete_events ath
inner join athletes ae on ath.athlete_id = ae.id
where medal = 'Silver'
group by team,year)

Select team,SUM(silver_medals) as total_silver_medals,
MAX(case when rn=1 then year end) as year_max_silver
from CTE
group by team

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
Select * from athlete_events;
Select * from athletes;

with cte as (
select name,medal
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id)

select top 1 name , count(1) as no_of_gold_medals
from cte 
where name not in (select distinct name from cte where medal in ('Silver','Bronze'))
and medal='Gold'
group by name
order by no_of_gold_medals desc
/*
WITH CTE as(
Select name,year,count(*) as gold_medals,
RANK() over (partition by name order by count(distinct event)) as rnk
from  athlete_events ath
inner join athletes ae on ath.athlete_id = ae.id
where medal = 'Gold' and medal not in ('Silver','Bronze')
group by name,year )

Select TOP 1 name,year,SUM(gold_medals) as total_gold_medals
from CTE
group by name,year
order by total_gold_medals desc */

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as (
select year,name,COUNT(*) as gold_medals
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal = 'Gold'
group by year,name)
,CTE2 as (
Select *,
RANK() over(partition by year order by gold_medals desc) as rn
from cte)

Select year,gold_medals,STRING_AGG(name,',') as players
from CTE2 
where rn=1
group by year,gold_medals

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

select distinct * from (
select medal,year,event,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1

--6 find players who won gold medal in summer and winter olympics both.
select a.name  
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by a.name having count(distinct season)=2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal != 'NA'
group by year,name having count(distinct medal)=3

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4




