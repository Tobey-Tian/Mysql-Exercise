use db_countries;
show tables;
select * from intl_football;
describe intl_football;

drop table if exists intl;
create temporary table intl
    select *, str_to_date(date,'%Y-%m-%d') as date_correct
    from intl_football;
describe intl;

select * from intl;
select country, dayofweek(date_correct) from intl order by country;
select curdate() as today,date_correct as day_game,datediff(curdate(),date_correct) from intl;


-- q1) prob distribution of games played by day of the week for every country.
-- q2) how long is the largest time window between two games played by Italy as a visitor without scoring more than two goals. 
-- That is the answer should allow you to state that Italy has never been more than xxx days as a visitor without score 3 goals or more.
-- q3) What is the most effective team in the world playing as local, and as a visitor? NOT DONE YET
-- q4) How many goals per day did every country in the world scored since the second world war?

use db_countries;
show tables;
 
select * from intl_football;
DROP TABLE IF EXISTS intl;
CREATE TEMPORARY TABLE intl
	SELECT * , STR_TO_DATE(date,'%Y-%m-%d') as date_correct
    FROM intl_football;
select * from intl;

-- q1) prob distribution of games played by day of the week for every country.
SELECT * FROM intl;
DROP TABLE IF EXISTS intl_2;
CREATE TEMPORARY TABLE intl_2 
	SELECT date_correct as date, home_team as team FROM intl;

DROP TABLE IF EXISTS intl_3;
CREATE TEMPORARY TABLE intl_3
	SELECT date_correct as date, away_team as team FROM intl;

SELECT *  FROM intl_2 
UNION ALL
SELECT *  FROM intl_3 order by date;

SELECT *, weekday(date), 1 as one
from(
	SELECT *  FROM intl_2 
	UNION ALL
	SELECT *  FROM intl_3 order by date ) as t;

SELECT *, weekday(date) as day_of_the_week, sum(1) as sum_by_team_day_of_the_week
from(
	SELECT *  FROM intl_2 
	UNION ALL
	SELECT *  FROM intl_3 order by date ) as t group by team, day_of_the_week order by team, day_of_the_week;

SELECT *, weekday(date) as day_of_the_week, sum(1) as sum_by_team
from(
	SELECT *  FROM intl_2 
	UNION ALL
	SELECT *  FROM intl_3 order by date ) as t group by team order by team;


DROP TABLE IF EXISTS intl_4;
CREATE TEMPORARY TABLE intl_4
	(SELECT team, weekday(date) as day_of_the_week, sum(1) as sum_by_team_day_of_the_week
	from(
		SELECT *  FROM intl_2 
		UNION ALL
		SELECT *  FROM intl_3 order by date ) as t group by team,day_of_the_week order by team, day_of_the_week);
select * from intl_4;
DROP TABLE IF EXISTS intl_5;
CREATE TEMPORARY TABLE intl_5
	(SELECT team, sum(1) as sum_by_team
	from(
		SELECT *  FROM intl_2 
		UNION ALL
		SELECT *  FROM intl_3 order by date ) as t group by team order by team);
select * from intl_5;
SELECT A.team, A.day_of_the_week,round(sum_by_team_day_of_the_week/B.sum_by_team,3)
FROM    
	intl_4 AS A
		INNER JOIN
	intl_5 AS B
			ON A.team = B.team;


     


-- q2) how long is the largest time window between two games played by Italy as a visitor without scoring more than two goals. 
SELECT * FROM intl WHERE away_team='Italy'order by date_correct;

DROP TABLE IF EXISTS intl_2;
CREATE TEMPORARY TABLE intl_2
	SELECT * FROM intl WHERE away_team='Italy' and away_score>2 order by date_correct;

select * from intl_2;
DROP TABLE IF EXISTS intl_3;
CREATE TEMPORARY TABLE intl_3
	SELECT *, ROW_NUMBER() OVER (ORDER BY date_correct ) AS ID  FROM intl_2 order by date_correct;
    
DROP TABLE IF EXISTS intl_4;
CREATE TEMPORARY TABLE intl_4
	SELECT *, 1 + ID AS ID_2 FROM intl_3 order by date_correct;

SELECT * FROM intl_2;
SELECT * FROM intl_3;
SELECT * FROM intl_4;
SELECT    A.home_team     as home_team_0  , 
          A.away_team     as away_team_0  , 
          A.home_score    as home_score_0 , 
          A.away_score    as away_score_0 , 
          A.date_correct  as date_0       , 
          A.country       as country_0    , 
          A.tournament    as tournament_0 , 
          B.home_team     as home_team_1  , 
          B.away_team     as away_team_1  , 
          B.date_correct  as date_1       ,
          B.home_score    as home_score_1 , 
          B.away_score    as away_score_1 ,
          B.country       as country_1  ,
          B.tournament    as tournament_1, 
          datediff(B.date_correct  ,A.date_correct) AS TIME_WINDOW_SIZE
FROM    
	intl_4 AS A
	INNER  JOIN
	intl_3 AS B
	ON     A.ID_2 = B.ID;






-- q3) What is the most effective team in the world playing as local, and as a visitor?
DROP TABLE IF EXISTS intl_2;
DROP TABLE IF EXISTS intl_3;
DROP TABLE IF EXISTS intl_4;


-- q4) How many goals per day did every country in the world scored since the second world war?
--     Second world war ended
DROP TABLE IF EXISTS intl_2;
CREATE TEMPORARY TABLE intl_2
	SELECT *, STR_TO_DATE('1945-09-02','%Y-%m-%d') AS  SECOND_WORLD_WAR_DATE FROM intl;


SELECT *FROM intl_2;
SELECT date_correct  as date , SECOND_WORLD_WAR_DATE FROM intl_2;
DROP TABLE IF EXISTS intl_3;
CREATE TEMPORARY TABLE intl_3 
	SELECT date_correct  as date , 
			home_team    as team ,
            home_score   as goals,
            SECOND_WORLD_WAR_DATE 
            FROM intl_2;
select * from intl_3;

SELECT date_correct  as date , SECOND_WORLD_WAR_DATE FROM intl_2;

DROP TABLE IF EXISTS intl_4;
CREATE TEMPORARY TABLE intl_4
		SELECT date_correct  as date , 
				away_team    as team ,
				away_score   as goals,
				SECOND_WORLD_WAR_DATE 
            FROM intl_2;
select * from intl_4;
select * ,t.date>t.SECOND_WORLD_WAR_DATE 
from (
	SELECT *  FROM intl_3
	UNION ALL
	SELECT *  FROM intl_4 order by date) as t;

select t.team,sum((t.date>t.SECOND_WORLD_WAR_DATE)*goals)
from (
	SELECT *  FROM intl_3
	UNION ALL
	SELECT *  FROM intl_4 order by date) as t group by t.team;


select team ,sum((t.date>t.SECOND_WORLD_WAR_DATE)*goals) as 'Goals since 2WW'
from (
	SELECT *  FROM intl_3
	UNION ALL
	SELECT *  FROM intl_4 order by date) as t group by t.team;



-- Function			Description
-- CURDATE	 		Returns the current date.
-- DATEDIFF			Calculates the number of days between two DATE values.
-- DAY				Gets the day of the month of a specified date.
-- DATE_ADD			Adds a time value to date value.
-- DATE_SUB			Subtracts a time value from a date value.
-- DATE_FORMAT		Formats a date value based on a specified date format.
-- DAYNAME			Gets the name of a weekday for a specified date.
-- DAYOFWEEK		Returns the weekday index for a date.
-- EXTRACT			Extracts a part of a date.
-- LAST_DAY			Returns the last day of the month of a specified date
-- NOW				Returns the current date and time at which the statement executed.
-- MONTH			Returns an integer that represents a month of a specified date.
-- STR_TO_DATE		Converts a string into a date and time value based on a specified format.
-- SYSDATE			Returns the current date.
-- TIMEDIFF			Calculates the difference between two TIME or DATETIME values.
-- TIMESTAMPDIFF	Calculates the difference between two DATE or DATETIME values.
-- WEEK				Returns a week number of a date.
-- WEEKDAY			Returns a weekday index for a date.
-- YEAR				Return the year for a specified date
