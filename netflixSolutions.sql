drop table if exists netflix;
create table netflix(
show_id	varchar(6),
type	varchar(10),
title	varchar(150),
director  varchar(208),	
casts	varchar(1000),
country  varchar(150),
date_added	varchar(150),
release_year	int,
rating	varchar(10),
duration  varchar(15),	
listed_in	varchar(100),
description  varchar(250)
);

select * from netflix;

15 business problems and their solutions

1. count the number of movies and tv shows

select type, count(*) from netflix 
group by type;

2. Find the most common rating for movies and TV shows

select type,
      rating
from
 (select type,rating,count(*),
 rank()over(partition by type order by count(*) desc) as ranking
 from netflix
 group by 1,2) as t1
 where  ranking =1;
 
3. List all movies realeased in a specific year (e.g, 2020)

select * from netflix
where type='Movie' and release_year=2020;

4. Find the top 5 countries with the most content on netflix

select 
 unnest(string_to_array(country,',')) as new_country,
 count(show_id) as total_content
 from netflix
 group by 1 order by 2 desc limit 5;

5. Identify the longest movie or TV show duration

select * from netflix 
where
  type='Movie'
  and 
  duration=(select max(duration) from netflix);
6. Find the content added in the last 5 years

select * from netflix
where 
to_date(date_added,'Month DD, YYYY')>= current_date - interval '5 years';

7. Find all the movies/TV shows by director 'Rajiv Chilaka'

select * from netflix
where director like '%Rajiv Chilaka%';

8. List all TV shows with more than 5 seasons

 select *
 from netflix
 where 
 type= 'TV Show' and  split_part(duration,' ',1)::numeric> 5 ;
 
9. count the number of content items in each genre

select 
 unnest(string_to_array(listed_in,',')) as genre,
 count(show_id) as total_content
from netflix
group by 1;

10. Find each year and the average numbers of content release by Indua on netflix
return top 5 years with highest avg content release !

select 
extract(year from to_date(date_added,'Month DD, YYYY')) as year,
count(*) as yearly_content,
round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric * 100 ,2)as avg_content_per_year
from netflix where country='India'
group by 1 order by avg_content_per_year desc limit 5; 


11. List all the movies that are documentaries

select * from netflix
where listed_in ilike '%documentaries%'


12. Find all content without a director

select * from netflix where director is null;


13. Find how many movies actor 'salman khan' appeared in last 10 years

select * from netflix
where casts ilike '%salman Khan%'
 and
release_year>extract(year from current_date)-10;

14 Find the top 10 actors who have appeared in the highest number of movies produced in
india

select 
unnest(string_to_array(casts,',')) as actors,
count(*) as total_count
from netflix 
where country ilike '%India%'
group by 1  order by 2 desc limit 10;

15.
  Categorize the content based on the presence of the keywords 'kill' and 'violence'
  in the description field . Label content containing these keywords as 'bad' and all other 
  content as 'good' . count how many items fall into each category.

with new_table as
(select 
*,
  case
  when description ilike '%kill%' or 
  description ilike '%violence%' then 'bad_content'
  else 'good_content'
  end category
from netflix) 
select 
  category,
  count(*) as total_content
  from new_table
  group by 1 order by 1 desc;

