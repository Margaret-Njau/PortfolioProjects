select *
From [Portfolio Project].dbo.CovidDeaths
order by 3,4

--select *
--From dbo.CovidVaccinations$
--order by 3,4



select Location, date, total_cases, new_cases,total_deaths,population
From dbo.CovidDeaths
order by 1,2

--Looking at the total_cases vs total_deaths
--shows the likelihood of dying if you get Covid in the listed countries

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
where location like '%italy%'
order by 1,2


--Looking at the total cases vs the population
--showing what percentage of the population got covid in Italy

select Location, date, population,total_cases,(total_cases/population)*100 as PopulationPercentage
From dbo.CovidDeaths
where location like '%italy%'
order by 1,2

--what country had the highest infection rate compared to  population?

SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS highestinfectioncount, 
    MAX((total_cases / Population) * 100) AS PopulationPercentage
FROM 
    dbo.CovidDeaths
--where location like '%italy%'
GROUP BY 
    Location, 
    Population
ORDER BY PopulationPercentage desc
   

--This is showing countries with the highest deathcount per population
SELECT 
    Location, 
    MAX(cast(total_deaths as int) )as TotalDeathCount
FROM 
    dbo.CovidDeaths
--where location like '%italy%'
GROUP BY 
    Location
ORDER BY  
    MAX(total_deaths) DESC; 


	SELECT 
    continent, 
    MAX(cast(total_deaths as int) )as TotalDeathCount
FROM 
    dbo.CovidDeaths
--where location like '%italy%'
where continent IS NOT NULL
GROUP BY 
    Continent
ORDER BY  
  TotalDeathCount DESC

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2



select *
From [Portfolio Project].dbo.CovidDeaths as dea
join  [Portfolio Project].dbo.CovidVaccinations as vac
      on dea.location= vac.location
	  and dea.date = vac.date

--looking at the total populationn vs vaccinations



With popVsvac(Continent,location,date, population,new_vaccinations, rollingpeoplevaccinated)
as (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date)
 as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population )* 100
From [Portfolio Project].dbo.CovidDeaths as dea
join  [Portfolio Project].dbo.CovidVaccinations as vac
      on dea.location= vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  --order by 2,3
)

select *, (rollingpeoplevaccinated/population)*100
from popVsvac


--Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric

)
insert into #percentpopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date)
 as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population )* 100
From [Portfolio Project].dbo.CovidDeaths as dea
join  [Portfolio Project].dbo.CovidVaccinations as vac
      on dea.location= vac.location
	  and dea.date = vac.date
	  --where dea.continent is not null
	  --order by 2,3

	  select *, (rollingpeoplevaccinated/population)*100
	  from #percentpopulationvaccinated


--creating view to store date for later visualizations

CREATE VIEW  percentpopulationvaccinated  AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date)
 as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population )* 100
From [Portfolio Project].dbo.CovidDeaths as dea
join  [Portfolio Project].dbo.CovidVaccinations as vac
      on dea.location= vac.location
	  and dea.date = vac.date
	  --where dea.continent is not null
	  --order by 2,3

	  select *
	  from percentpopulationvaccinated

