create database netflix;
use netflix

select * from [dbo].[netflix_titles_final]

--Bussiness analysis:
--1. Count the Number of Movies vs TV Shows
select type[Type],count(type)[Type Count] 
from [dbo].[netflix_titles_final]
group by type
-- their are more movies in data of netflix then tv shows.

--2. Find the Most Common Rating for Movies and TV Shows

with cte1 as(

select type,rating,count(rating)[ratings]
from [dbo].[netflix_titles_final]
group by type,rating

),cte2 as(

select *,
dense_rank() over(partition by type order by ratings desc)[rn] 
from cte1

)
select * from cte2
where rn=1

--the most common taing for movies and tv shows is TV-MVA.

--3. List All Movies Released in a Specific Year (e.g., 2020)

select type,title,release_year 
from [dbo].[netflix_titles_final]
where type ='Movie' and release_year between 2010 and 2012
order by release_year
-- their are almost 500 movies release in 2010 to 2012 of different genres.

--4. Find the Top 5 Countries with the Most Content on Netflix

select top 5 * from 
(select country,count(*)[content] from [dbo].[netflix_titles_final]
group by country
)x
where country is not null
order by content desc

--United States,India,United Kingdom,Japan,South Korea are the countries with most 
--of the contents on netflix


--5. Identify the Longest Movie

select top 1 * from
(select type,title,
  cast(LEFT(duration, CHARINDEX(' ', duration) - 1)AS INT) AS duration_minutes,
  RIGHT(duration, LEN(duration) - CHARINDEX(' ', duration)) 
  AS duration_unit from
  [dbo].[netflix_titles_final]
where type = 'Movie'
)x
order by duration_minutes desc
--movie Black Mirror: Bandersnatch is the longest movies on netflix 
--with duration of almost 5.2 hrs

--6. Find Content release in the Last 5 Years of present data years
with cte as(
select top 5 * from(
select distinct release_year 
from [dbo].[netflix_titles_final] )x
order by release_year desc

),cte2 as(
select  *  from [dbo].[netflix_titles_final]
where release_year in (select * from cte)
)
select * from cte2 
order by release_year desc

--6. Find Content Added in the Last 5 Years
select  *  from [dbo].[netflix_titles_final]
where 
try_cast(date_added as DATE)>=dateadd(year,-5,getdate())

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

select type,title,director
from [dbo].[netflix_titles_final]
where director like '%Rajiv Chilaka%'
--Rajiv Chilaka direct 22 movies for kids

--8. List All TV Shows with More Than 5 Seasons

select * from [dbo].[netflix_titles_final]
where cast(left(duration,CHARINDEX(' ',duration)-1)as int)>5
and type='TV Show'
--there are 99 tv shows with more than 5 seasons

--9. Count the Number of Content Items in Each Genre

select trim(value) [genre],count(*)[count]
from [dbo].[netflix_titles_final]
cross apply string_split(listed_in ,',')
group by value
order by count(*) desc
--most of the content genre on netflix belongs to International Movies

--10.Find each year and the average numbers of content release in India on netflix.

select country,
release_year,
count (*)[Total Release],
round (count(*)*100/cast((select count(*)from [dbo].[netflix_titles_final] where country like'%India%' )as float),2) [Avg Release]
from [dbo].[netflix_titles_final]
where country like'%India%' 
group by country,release_year


--11. List All Movies that are Documentaries

select * from [dbo].[netflix_titles_final]
where listed_in like '%Documentaries%'
and type like 'Movie'


--12. Find All Content Without a Director

select * from [dbo].[netflix_titles_final]
where director is null

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select * from [dbo].[netflix_titles_final]
where type='Movie' and casts like '%Salman Khan%'
and release_year>=year(dateadd(year,-10,getdate()))

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
with cte as(
select value as Actors,country, count(*)[Appearrance]
from [dbo].[netflix_titles_final]
cross apply string_split(casts ,',')
group by value,country)
select top 10 * from cte 
where country='India'
order by Appearrance desc


--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise.
--Count the number of items in each category.

with cte as(
select *,
case
    when description like '%kill%' or description like '%Violence%' then 'bad'
	else 'good' end as [Category]
from [dbo].[netflix_titles_final]

)
select type,Category,count(*)[content count] from cte 
group by type,Category




