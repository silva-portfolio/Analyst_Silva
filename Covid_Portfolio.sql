-->Selecting excel data;
SELECT * FROM dbo.CovidDeaths cd;
SELECT * FROM dbo.CovidVaccinations cv 
ORDER BY 3,4;


-->Loading data
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM dbo.CovidDeaths cd 
ORDER BY 1,2;


SELECT
	location,
	continent,
	date,
	population
FROM dbo.CovidDeaths;


-->Looking at the overall cases observed by location and respective overall deaths recorded;
SELECT 
	location AS Location,
	SUM(CAST(total_cases AS INT)) OVER (PARTITION BY location) AS "Total Cases",
	SUM(CAST(total_deaths AS INT)) OVER (PARTITION BY location) AS "Total Deaths",
	ROUND((SUM(CAST(total_deaths AS INT)) OVER(PARTITION BY location)/
	NULLIF(SUM(total_cases) OVER(PARTITION BY location), 0))*100, 4) AS "Death Percent"
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, total_cases, total_deaths
ORDER BY location;


-->Total Cases and Total Deaths observed and recorded by location;
SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  population, 
  ROUND(CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0), 5) * 100 AS "Death Percent"
FROM dbo.CovidDeaths
WHERE location LIKE '%ghana%'; /* GHANA */

SELECT
	location,
	population,
	date,
	total_cases,
	total_deaths,
	CAST(total_deaths AS INT) / NULLIF(total_cases, 0) * 100 AS "Death Percent"
FROM dbo.CovidDeaths
WHERE location LIKE '%united states%'
ORDER BY [Death Percent] desc; /* US */


-->Infection per location;
SELECT
	location, 
	date, 
	total_cases,  
	population, 
	(CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS "Infection Rate"
FROM dbo.CovidDeaths cd
WHERE continent is not null
ORDER BY [Infection Rate] desc;


-->Country with highest infection rate compared to Population;
SELECT
	location,
	population,
	MAX(CONVERT(INT,total_cases)) AS "Highest Infection Count",
	MAX(CONVERT(INT,total_cases) / NULLIF(population, 0)) * 100 AS "Percent Population Infected"
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Percent Population Infected] desc;


--> Highest Infection Count by Continent;
SELECT
	location,  
	MAX(total_cases) AS "Highest Infection Count",  
	population,
	MAX(CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS "Percent Population Infected"
FROM dbo.CovidDeaths
WHERE continent is null
GROUP BY location, population
ORDER BY "Percent Population Infected" desc;


-->Country with highest death count per population;
SELECT
	Location, 
	Population,
	MAX(cast(total_deaths as FLOAT)) AS "Highest Death Count"
FROM dbo.CovidDeaths cd
WHERE continent is not null
GROUP BY location, population
ORDER BY "Highest Death Count" desc;


-->total cases and total deaths per continent;
SELECT
	continent AS Continent,
	MAX(CAST(total_cases AS FLOAT)) AS "Total Cases",
	MAX(CAST(total_deaths AS FLOAT)) AS "Total Death Counts"
FROM dbo.CovidDeaths cd
WHERE continent is not NULL
GROUP BY continent
ORDER BY [Total Death Counts] DESC;


--> New Cases and New Deaths;
SELECT
	date, new_cases, new_deaths 
FROM dbo.CovidDeaths cd
ORDER BY date DESC;


-->GLOBAL NUMBERS;
--> New Cases and New Deaths recorded & respective Death Percentages as at 2021-04-30;
SELECT 	
	MAX(date) AS Date,
	SUM(CAST(new_cases AS INT)) AS "Total New Cases",
	SUM(CAST(new_deaths AS INT)) AS "Total New Deaths",
	(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT)))*100 AS "Death Percentage"
FROM dbo.CovidDeaths cd
WHERE continent is not NULL 
ORDER BY 1,2;
	

-->Joining CovidDeaths and CovidVaccinations together;
SELECT *
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date;


-->Population Vs New Vaccinations;
SELECT 
	cd.continent, 
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations 
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent is not NULL 
ORDER BY 2,3;

-->Population totally vaccinated;
SELECT 
	cd.continent, 
	cd.location,
	cd.population,
	cd.date,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS FLOAT)) OVER (PARTITION BY cd.location ORDER BY cd.date) as "Rolling Population Vaccinated"
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent is not NULL 
ORDER BY 2,3;


-->Using CTE;
-->Rolling Percentage of People Vaccinated;
WITH PopVsVac (Continent, Location, Population, Date, New_Vaccinations, Rolling_People_Vaccinated)
AS (
SELECT 
	cd.continent, 
	cd.location,
	cd.population,
	cd.date,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS FLOAT)) OVER (PARTITION BY cd.location ORDER BY cd.date) as Rolling_People_Vaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent is not NULL 
)
SELECT *, 
	ROUND((Rolling_People_Vaccinated/ CAST(Population AS FLOAT))*100, 5) AS Percent_Rolling_People_Vaccinated
FROM PopVsVac;


-->Creating a Temp Table;
--DROP TABLE IF EXISTS Percent_Rolling_People_Vaccinated;

CREATE TABLE Percent_Rolling_People_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
select * from Percent_Rolling_People_Vaccinated;
INSERT INTO Percent_Rolling_People_Vaccinated
 SELECT 
	cd.continent, 
	cd.location,
	cd.population,
	cd.date,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS FLOAT)) OVER (PARTITION BY cd.location ORDER BY cd.date) as Rolling_People_Vaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date;
--WHERE cd.continent is not NULL 
SELECT
	*,
	(ROUND((Rolling_People_Vaccinated/ CAST(Population AS FLOAT))*100, 5)) AS _Rolling_People_Vaccinated
FROM Percent_Rolling_People_Vaccinated;


SELECT * 
FROM Percent_Rolling_People_Vaccinated;

-->CREATING VIEW FOR VISUALIZATION LATER;
CREATE VIEW Global_Numbers AS
	SELECT
	continent AS Continent,
	MAX(CAST(total_cases AS FLOAT)) AS "Total Cases",
	MAX(CAST(total_deaths AS FLOAT)) AS "Total Death Counts"
FROM dbo.CovidDeaths cd
WHERE continent is not NULL
GROUP BY continent
--ORDER BY [Total Death Counts] DESC;









