# Netlix-Movies-and-Tv-Shows-Analysis
![Netflix Logo](https://github.com/Rujab21/Netlix-Movies-and-Tv-Shows-Analysis/blob/main/download.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)


## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select type[Type],count(type)[Type Count] 
from [dbo].[netflix_titles_final]
group by type
-- their are more movies in data of netflix then tv shows.
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql

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

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select type,title,release_year 
from [dbo].[netflix_titles_final]
where type ='Movie' and release_year between 2010 and 2012
order by release_year
-- their are almost 500 movies release in 2010 to 2012 of different genres.
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select top 5 * from 
(select country,count(*)[content] from [dbo].[netflix_titles_final]
group by country
)x
where country is not null
order by content desc
--United States,India,United Kingdom,Japan,South Korea are the countries with most 
--of the contents on netflix
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
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
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select  *  from [dbo].[netflix_titles_final]
where 
try_cast(date_added as DATE)>=dateadd(year,-5,getdate())
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql

select type,title,director
from [dbo].[netflix_titles_final]
where director like '%Rajiv Chilaka%'
--Rajiv Chilaka direct 22 movies for kids
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select * from [dbo].[netflix_titles_final]
where cast(left(duration,CHARINDEX(' ',duration)-1)as int)>5
and type='TV Show'
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select trim(value) [genre],count(*)[count]
from [dbo].[netflix_titles_final]
cross apply string_split(listed_in ,',')
group by value
order by count(*) desc
--most of the content genre on netflix belongs to International Movies
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
select country,
release_year,
count (*)[Total Release],
round (count(*)*100/cast((select count(*)from [dbo].[netflix_titles_final]
where country like'%India%' )as float),2) [Avg Release]
from [dbo].[netflix_titles_final]
where country like'%India%' 
group by country,release_year
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select * from [dbo].[netflix_titles_final]
where listed_in like '%Documentaries%'
and type like 'Movie'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * from [dbo].[netflix_titles_final]
where director is null
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select * from [dbo].[netflix_titles_final]
where type='Movie' and casts like '%Salman Khan%'
and release_year>=year(dateadd(year,-10,getdate()))
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
with cte as(
select value as Actors,country, count(*)[Appearrance]
from [dbo].[netflix_titles_final]
cross apply string_split(casts ,',')
group by value,country)
select top 10 * from cte 
where country='India'
order by Appearrance desc
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
with cte as(
select *,
case
    when description like '%kill%' or description like '%Violence%' then 'bad'
	else 'good' end as [Category]
from [dbo].[netflix_titles_final]

)
select type,Category,count(*)[content count] from cte 
group by type,Category
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.








