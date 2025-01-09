/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



-- 1. checking the data.

Select * from CovidData..CovidDeaths
where continent is not null
order by 3, 5

Select * from CovidData..CovidVaccinations
where continent is not null
order by 3, 5




-- 2. Select data that we are going to be using. 

select location, date, total_cases, new_cases, total_deaths, population
From CovidData..CovidDeaths
where continent is not null
order by 1, 2



-- 3. Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you are affected by Covid-19 in different Countries.

-- in BD
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)* 100) as DeathPercentage
From CovidData..CovidDeaths
where location like 'Bangladesh' AND continent is not null 

order by 1, 2


-- in USA 
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)* 100) as DeathPercentage
From CovidData..CovidDeaths
where location like '%states%'  AND continent is not null 
order by 1, 2


-- in Italy
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)* 100) as DeathPercentage
From CovidData..CovidDeaths
where location like 'Italy'  AND continent is not null 
order by 1, 2

--in China
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)* 100) as DeathPercentage
From CovidData..CovidDeaths
where location like 'China'  AND continent is not null 
order by 1, 2



-- 4. Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid

-- in BD
select location, date,  Population, total_cases, ((total_cases/population)* 100) as CovidInfectionPercentage
From CovidData..CovidDeaths
where location like 'Bangladesh'  AND continent is not null 
order by 1, 2

--in USA
select location, date,  Population, total_cases, ((total_cases/population)* 100) as CovidInfectionPercentage
From CovidData..CovidDeaths
where location like '%states%'  AND continent is not null 
order by 1, 2

--in Italy
select location, date,  Population, total_cases, ((total_cases/population)* 100) as CovidInfectionPercentage
From CovidData..CovidDeaths
where location like 'Italy'  AND continent is not null 
order by 1, 2

--in China
select location, date,  Population, total_cases, ((total_cases/population)* 100) as CovidInfectionPercentage
From CovidData..CovidDeaths
where location like 'China'  AND continent is not null 
order by 1, 2



-- 5. Looking at Countries with Highest Infection Rate compared to Population

select location,  Population,  MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CovidInfectionPercentage
From CovidData..CovidDeaths
Where continent is not null 
group by location,  Population
order by CovidInfectionPercentage desc



--6. Showing Countries with Highest Death count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths
Where continent is not null 
group by location
order by TotalDeathCount desc



-- Breaking the DeathCount by Continent
-- 7. Showing continents with the highest death count per population (Including World)

select location, max(population) , max(cast(total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths
where continent is null and location not like 'International'
group by location
order by TotalDeathCount desc



-- 8. GLOBAL NUMBERS (Death Percentage/Day)

select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100) as DeathPercentage
from CovidData..CovidDeaths
where continent is not null
group by date
order by 1,2



-- 9. GLOBAL NUMBERS (Totatl Death Percentage)

select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as float))/sum(cast(new_cases as int))*100) as DeathPercentage
from CovidData..CovidDeaths
where continent is not null
order by 1,2



-- 10. Joining the Two Tables

Select * 
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	
order by dea.date



-- 11. Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- 12. USING CTE

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
	Join CovidData..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
order by 2,3



-- 13. TEMP TABLE

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

