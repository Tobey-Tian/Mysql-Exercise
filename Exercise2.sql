-- Preliminaries
DROP   DATABASE IF EXISTS db_countries;
CREATE DATABASE db_countries;
USE    db_countries;

-- Creating the Entities (Tables)
CREATE TABLE continents(
  id              INT unsigned NOT NULL AUTO_INCREMENT, # Unique ID for the record
  NAME            VARCHAR(100) NOT NULL,                # Name of the continent
  SURFACE         INT                  ,                # Surface of the continent in number of s
  POPULATION      BIGINT               ,                # Number of people. Integer number
  PRIMARY KEY     (id)                                  # Make the id the primary key
);


CREATE TABLE countries(
  ID_COUNTRY      INT unsigned NOT NULL AUTO_INCREMENT, # Unique ID for the record                        
  NAME            VARCHAR(100) NOT NULL,                # NAME OF the country                
  CONTINENT       INT unsigned NOT NULL,                # NAME of the continent where the country is located                                   
  SURFACE         INT,                                  #                                    
  POPULATION      INT,                                  #                                    
  CAPITAL         INT unsigned,                         #                                    
  PRIMARY KEY     (ID_COUNTRY)                          #                            
);


CREATE TABLE cities(
  ID_CITY         INT unsigned NOT NULL AUTO_INCREMENT, #                          
  CITY_NAME_CHAR  VARCHAR(100) NOT NULL,                #                 
  SURFACE         INT,                                  #                  
  POPULATION      INT,                                  #                  
  PRIMARY KEY     (ID_CITY)                             #                  
);


CREATE TABLE attractions(
  id              INT unsigned NOT NULL AUTO_INCREMENT, # 
  name            VARCHAR(100) NOT NULL,                # 
  city            VARCHAR(100) NOT NULL,                # 
  PRIMARY KEY     (id)                                  # 
);


-- Adding Foreign keys
ALTER TABLE countries   ADD CONSTRAINT FK_countriesContinents  FOREIGN KEY (CONTINENT) REFERENCES continents(id);
ALTER TABLE countries   ADD CONSTRAINT FK_citiesCountries      FOREIGN KEY (capital)    REFERENCES cities(ID_CITY);






-- Populating the data using mySQL ROW BY ROW
INSERT   INTO continents(id, NAME, SURFACE, POPULATION)  VALUES ( 1, 'EUROPE',  10180000,  731000000) ,
                                                                ( 2, 'AMERICA', 42330000,  910000000),
                                                                ( 3, 'OCEANIA',  9008458,   38889988),
                                                                ( 4, 'ASIA',    44579000,  4462676731),
                                                                ( 5, 'AFRICA',  30370000,  1225080510);



INSERT   INTO cities(ID_CITY, CITY_NAME_CHAR, SURFACE, POPULATION ) VALUES (1,	'Madrid',	    605.77,	3141991),
                                                                           (2,	'Barcelona',	102.15,	1604555),
                                                                           (3,	'Paris',	     105.4,	2229621),
                                                                           (4,	'Ottawa',	   2778.64, 1083391),
                                                                           (5,	'New York',	      1214,	8491079),
                                                                           (6,	'Berlin',	   891.68 , 3469849),
                                                                           (7,	'Canberra',	   814.2  , 381488);


INSERT   INTO countries(ID_COUNTRY,	NAME,	CONTINENT,	SURFACE,	POPULATION,	CAPITAL) VALUES (1,	'Spain',	1,	505370,	 46438422,	1),
                                                                                                (2,	'France',	1,	643801,  64590000,	3),
                                                                                                (3,	'Canada',	2,	9984670, 36155487,	4),
                                                                                                (4,	'Germany',	1,	357022,	 81770900,	6),
                                                                                                (5,	'Australia',3,	7692024, 23613193,	7);


DESCRIBE continents;
SELECT *                   FROM continents;
use db_countries;
show tables;
select * from countries;
select * from countries_of_the_world;
select country,gdp from countries_of_the_world where country REGEXP '(^A)|(^Den)';
select country, avg(gdp) from countries_of_the_world;



# For each region, can you please tell me what are the countries that are larger than the mean?
select country,region from countries_of_the_world where area > (select avg(area) from countries_of_the_world) order by region;

# Which % of the world`s GDP is created by the 4 richest countries?
select sum(a.gdp_rich/b.total) as per_gdp from
(SELECT (gdp*population) as gdp_rich from countries_of_the_world order by (gdp*population) desc limit 4) as a,
(select sum(gdp*population) as total from countries_of_the_world) as b ; 


# Do the richest 4 countries have a larger Coastline to Area ratio than the average?
select country,(a.ratio - b.avg_ratio) as diff_ratio from
(select country, (coastline/area) as ratio from countries_of_the_world order by (gdp*population) desc limit 4) as a,
(select avg(coastline/area) as avg_ratio from countries_of_the_world)as b;

# How many times is the median country of each region the size of the average country of that region?

drop temporary table if exists t_1;
create temporary table t_1
select a.region,a.area,b.total_of_region from
(select region,area from countries_of_the_world order by region,area) as a
inner join
(select count(*) as total_of_region,region from countries_of_the_world group by region) as b
on a.region = b.region;
select * from t_1;

SET @ROW_NUMBER:=0; 
SET @median_group:='';
SELECT
    @ROW_NUMBER:=CASE
        WHEN @median_group = region THEN @ROW_NUMBER + 1
        ELSE 1
    END AS count_of_group,
    @median_group:=region AS median_group,
    region,
    area,
    total_of_region
FROM t_1;

SET @ROW_NUMBER:=0; 
SET @median_group:='';
select median_group, avg(area) as median_area from
(SELECT
    @ROW_NUMBER:=CASE
        WHEN @median_group = region THEN @ROW_NUMBER + 1
        ELSE 1
    END AS count_of_group,
    @median_group:=region AS median_group,
    region,
    area,
    total_of_region
FROM t_1) as a 
where count_of_group between total_of_region/2 and total_of_region/2 + 1
group by median_group;

SET @ROW_NUMBER:=0; 
SET @median_group:='';
select region, b.median_area/c.avg_area as size_time from
(select median_group, avg(area) as median_area from
(SELECT
    @ROW_NUMBER:=CASE
        WHEN @median_group = region THEN @ROW_NUMBER + 1
        ELSE 1
    END AS count_of_group,
    @median_group:=region AS median_group,
    region,
    area,
    total_of_region
FROM t_1) as a 
where count_of_group between total_of_region/2 and total_of_region/2 + 1
group by median_group) as b
inner join
(select avg(area) as avg_area,region from countries_of_the_world group by region) as c
on b.median_group = c.region;

