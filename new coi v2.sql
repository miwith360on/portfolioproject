select*
from portfolioproject..[ dlo.covidvax]

select*
from portfolioproject..[covid death]
order by 3,4

--select*
--from portfolioproject..[ dlo.covidvax]
--order by 3,4

-- Select Data that we are going to be starting with
select location, date, total_cases,new_cases, total_deaths, population
from portfolioproject..[covid death]
order by 1,2

-- Total Cases vs Total Deaths
-- showing the likelihood of dying if get covid in your country 
Select location, date, total_cases, total_deaths,

(CONVERT (float, total_deaths) /

NULLIF (CONVERT (float, total_cases), 0)) * 100 AS

Deathpercentage

from portfolioproject..[covid death]
where location  like '%states%'
order by 1,2

-- looking at the total cases vs populations 
-- shows what percentage of poplations who got covid

Select location, date, total_cases, population,

(CONVERT (float, total_cases) /

NULLIF (CONVERT (float, population), 0)) * 100 AS

Deathpercentage

from portfolioproject..[covid death]
where location  like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select continent, Population, MAX (total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioproject..[covid death]
--Where location like '%states%'
Group by continent, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject..[covid death]
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject..[covid death]
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
,

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolioproject..[covid death]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM (convert ( bigint,vax.new_vaccinations )) over ( partition by dea.location order by dea.location,dea.date) as rollingpplvax
from portfolioproject..[covid death] dea
join portfolioproject..[ dlo.covidvax] vax
  on  dea. location = vax.location
  and  dea.date = vax.date
  where dea. continent is not null 
  order by 2,3

  -- Using CTE to perform Calculation on Partition By in previous query
  with popvsvax  ( continet, location, date, population,new_vaccinations,rollingpeoplevaccinated)
  as 
  (
  select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM (convert ( bigint,vax.new_vaccinations )) over ( partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portfolioproject..[covid death] dea
join portfolioproject..[ dlo.covidvax] vax
  on  dea. location = vax.location
  and  dea.date = vax.date
  where dea.continent is not null 
 --order by 2,3
  )
  select* , ( rollingpeoplevaccinated/population)*100
  from popvsvax
  

  -- Using Temp Table to perform Calculation on Partition By in previous query
 drop table if exists #percentpopulationvaccinated
 create table  #percentpopulationvaccinated
  (
  contient nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rollingpeoplevaccinated numeric 
  )
  insert into #percentpopulationvaccinated
  select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM (convert ( bigint,vax.new_vaccinations )) over ( partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portfolioproject..[covid death] dea
join portfolioproject..[ dlo.covidvax] vax
  on  dea. location = vax.location
  and  dea.date = vax.date
  where dea.continent is not null 
 --order by 2,3
 select* , ( rollingpeoplevaccinated/population)*100
  from #percentpopulationvaccinated

  -- Creating View to store data for later visualizations

  create view percentpopulationvaccinated as  select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM (convert ( bigint,vax.new_vaccinations )) over ( partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from portfolioproject..[covid death] dea
join portfolioproject..[ dlo.covidvax] vax
  on  dea. location = vax.location
  and  dea.date = vax.date
  where dea.continent is not null 
 -- order by 2,3
 select*
from percentpopulationvaccinated
