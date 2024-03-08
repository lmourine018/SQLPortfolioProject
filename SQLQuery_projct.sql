select * FROM SQL_Project.dbo.tst Order By 3,4
select * from SQL_Project.dbo.vaccines  Order By 3,4
select Location,date,new_cases,total_deaths,population from SQL_Project..tst order by 1,2
select Location,date,new_cases,population,(total_deaths/population)*100 as
percentage from SQL_Project..tst where location LIKE '%cambodia%'
 
 ----countries with the highest population
select Location,population, MAX(population) as
Max_popu from SQL_Project..tst GROUP by Location, 
population
order by Max_popu desc

--global numbers--
select date,population,(total_deaths/population)*100 as
percentage from SQL_Project..tst 
where continent is not null 
GROUP By date
order by 1,2

Select date, SUM(new_cases) as totalNewCases from SQL_Project..tst
where continent is not null
group by date
order by 1,2

--handling division by 0 we use CASE function------

Select date, SUM(new_cases) as totalNewCases, SUM(cast(new_deaths as int)) as totalNewDeaths, 
CASE 
        WHEN SUM(new_cases) = 0 THEN NULL -- Handle division by zero
        ELSE SUM(cast(new_deaths as int)) * 100.0 / SUM(new_cases)
    END as DeathPercentage
from SQL_Project..tst
where continent is not null
group by date
order by 1,2

--- highest total deaths--
select Location,population,MAX(total_deaths) as HighestInfectionCount
from SQL_Project..tst Group By Location,Population
order by HighestInfectionCount desc
--- highest total deaths per population--
select Location,Max(cast(total_deaths as int)) as TotalDeathCount
from SQL_Project..tst Group By Location
order by TotalDeathCount desc

--continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
 from SQL_Project..tst Group By Continent
 Order By HighestDeathCount

---breaking things down by continent--
select location,continent, MAX(cast(total_deaths as int)) as HighestdeathCount

from SQL_Project..tst where continent is not null
group by location, continent
order by HighestdeathCount desc

---joining two tablees
select * from SQL_Project..tst as tst join SQL_Project..vaccines as vac on
tst.location = vac.location
and tst.date = vac.date

----joining contents of two tables----
select vac.continent, vac.location,vac.date,tst.population
from SQL_Project..tst as tst join SQL_Project..vaccines as vac
on vac.continent = tst.continent
and vac.date = tst.date
where vac.continent is not null
order by 2,3
 ---using partion by function----
 select vac.continent, vac.location,vac.date,tst.population, tst.new_deaths,
Sum(tst.new_deaths) as totalDeaths over (partition by vac.location)
from SQL_Project..tst as tst join SQL_Project..vaccines as vac
on vac.continent = tst.continent
and vac.date = tst.date
where vac.continent is not null
order by 2,3

---using the convert function which is similar to the cast function bt differs in syntax---
 select vac.continent, vac.location,vac.date,tst.population, tst.new_deaths,
Sum(convert(int,tst.new_deaths)) over (partition by vac.location)as totalDeaths 
from SQL_Project..tst as tst join SQL_Project..vaccines as vac
on vac.continent = tst.continent
and vac.date = tst.date
where vac.continent is not null
order by 2,3

-- Shows likelihood of dying if you contract covid in your country

Select location, date,new_cases,total_deaths, (new_cases/total_deaths)*100 As DeathPercentage 
From SQL_Project..tst
Where location Like '%Turkey%'
Order By 1,2
--temp table--
create table #PercentPopulated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_deaths numeric,
totalDeaths numeric)
insert into #PercentPopulated
 select vac.continent, vac.location,vac.date,tst.population, tst.new_deaths,
Sum(convert(int,tst.new_deaths)) over (partition by vac.location)as totalDeaths 
from SQL_Project..tst as tst join SQL_Project..vaccines as vac
on vac.continent = tst.continent
and vac.date = tst.date
where vac.continent is not null
order by 2,3
CREATE TABLE #PercentPopulated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    new_deaths NUMERIC,
    totalDeaths NUMERIC
);

INSERT INTO #PercentPopulated (continent, location, Date, Population, new_deaths, totalDeaths)
SELECT 
    vac.continent,
    vac.location,
    vac.date,
    tst.population,
    tst.new_deaths,
    SUM(CONVERT(INT, tst.new_deaths)) AS totalDeaths
FROM 
    SQL_Project..tst AS tst 
JOIN 
    SQL_Project..vaccines AS vac ON vac.continent = tst.continent AND vac.date = tst.date
WHERE 
    vac.continent IS NOT NULL
GROUP BY 
    vac.continent
ORDER BY   vac.date;
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulation
Create Table #PercentPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_deaths numeric
)
Insert into #PercentPopulation(continent,location,date,population,new_deaths)
Select dea.continent, dea.location, dea.date, dea.population
, SUM(CONVERT(int,vac.new_deaths)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Deaths
--, (RollingPeopleVaccinated/population)*100
From SQL_Project..tst dea
Join SQL_Project..vaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (new_deaths/Population)*100 as deathsperpopulation
From #PercentPopulation


-- Creating View to store data for later visualizations----

Create View PercentPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_deaths
, SUM(CONVERT(int,vac.new_deaths)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as deaths

From SQL_Project..tst dea
Join SQL_Project..vaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 







