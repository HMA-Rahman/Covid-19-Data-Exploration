/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Type Casting.

*/



-- 1. checking the data.

Select *, location from CovidData..CovidDeaths
where continent is not null 
order by 1,4

Select * from CovidData..CovidVaccinations
where continent is not null
order by 1, 4 



-- 2. Select data that we are going to use.

select  location, date, total_cases, new_cases, total_deaths, population
From CovidData..CovidDeaths
where continent is not null and iso_code not like 'OWID_CYN' and iso_code not like 'JEY'
order by 1,3


--
select  location, Max(cast(total_cases as float)) total_cases, Max (cast(total_deaths as float)) total_deaths, Max(population) as Country_Pop,
Max (cast(total_deaths as float))/Max(cast(total_cases as float))*100
From CovidData..CovidDeaths
where continent is not null and iso_code not like 'OWID_CYN' and iso_code not like 'JEY'
group by location
order by 1
--



-- 3. Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you are affected by Covid-19 in different Countries.

select iso_code, location, date, total_cases, total_deaths, ((total_deaths/total_cases)* 100) as DeathPercentage
From CovidData..CovidDeaths
where  continent is not null  and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
order by  1,3




-- 4. Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid
 
-- in World
select iso_code, location, date,  Population, total_cases, ((total_cases/population)* 100) as CovidInfectionPercentage
From CovidData..CovidDeaths
where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
order by 1, 3



-- 5. Looking at Countries with Highest Infection Rate compared to Population [subquery]

--no null
select iso_code, location, population, HighestInfectionCount, CovidInfectionPercentage 
from
(select iso_code, location,  population,  MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CovidInfectionPercentage
From CovidData..CovidDeaths
 where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
group by iso_code, location,  Population
) as CovidInfectionPercentageNoNull
where HighestInfectionCount is not null and CovidInfectionPercentage is not null 
order by CovidInfectionPercentage desc


--has null values
select iso_code, location,  population,  MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CovidInfectionPercentage
From CovidData..CovidDeaths
 where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
group by iso_code, location,  Population
order by iso_code asc



--6. Showing Countries with Highest Death count per Population

--no null
select iso_code, location, population, TotalDeathCount, DeathPercentage
from (select iso_code, location, population, Max(cast(total_deaths as int)) as TotalDeathCount,  Max(cast(total_deaths as int))/population*100 as DeathPercentage
From CovidData..CovidDeaths
 where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
group by iso_code, location, population) as a
where TotalDeathCount is not null and DeathPercentage is not null
order by TotalDeathCount desc


-- has null values
select iso_code, location, population, Max(cast(total_deaths as int)) as TotalDeathCount,  Max(cast(total_deaths as int))/population*100 as DeathPercentage
From CovidData..CovidDeaths
 where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
group by iso_code, location, population
order by iso_code asc




--Ranking them using window function

use CovidData
go
create view Top_Death_Count as 
select iso_code, location, Max(cast(total_deaths as int)) as TotalDeathCount 
From CovidData..CovidDeaths
 where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'
group by iso_code, location

select *, dense_rank() over(order by TotalDeathCount desc) as Ranking
from Top_Death_Count



-- Breaking the DeathCount by Continent
-- 7. Showing continents with the highest death count per population (Including World)

select location, max(cast(population as float)) as population , max(cast(total_deaths as int)) as TotalDeathCount, 
max(cast(total_deaths as int))/max(cast(population as float)) * 100 as DeathPercentage
From CovidData..CovidDeaths
where continent is null and  iso_code not like 'JEY' and location not like 'International'   and location not like 'European Union' and location not like 'World'
group by location
order by TotalDeathCount desc




-- 8. GLOBAL NUMBERS (Totatl Death Percentage)

select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100) as DeathPercentage
from CovidData..CovidDeaths
where continent is not null and iso_code not like 'OWID_CYN'  and iso_code not like 'JEY'



-- 9. Joining the Two Tables

Select  dea.location, dea.date, dea.total_cases, dea.new_cases, dea.total_deaths, dea.population,  vac.continent,  vac.new_tests, vac.total_tests, vac.new_vaccinations, vac.people_vaccinated, vac.total_vaccinations

--dea.iso_code, dea.continent, dea.date
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and dea.iso_code not like 'OWID_CYN'  and dea.iso_code not like 'JEY'

order by dea.location, date



-- 10. Looking at Total Population vs Vaccinations

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.iso_code not like 'OWID_CYN' and dea.iso_code not like 'JEY'
order by 2, 3



-- 11. USING CTE

With PopvsVac 
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentPeopleVaccinated
from PopvsVac
order by 2,3


-- 12. TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated





-- Creating View to Store data for later viz

use CovidData
go
Create view PercentPopulationVaccinated2 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

drop view PercentPopulationVaccinated2



-- Creating another view
use CovidData
go
create view testview2 as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3