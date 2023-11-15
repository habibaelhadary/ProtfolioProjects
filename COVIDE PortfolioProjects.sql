--select *
--from ..CovidDeaths
--order by 3,4
--select *
--from ..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using 
select location ,date,total_cases, new_cases,total_deaths,population
from ProtfolioProject..CovidDeaths
order by 1,2


--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your countrt
select location ,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from ProtfolioProject..CovidDeaths
where location like 'Egypt'
order by 1,2

--looking at Total cases vs Population
--shows what prencentage of population got covid
select location ,date,population ,total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from ProtfolioProject..CovidDeaths
--where location like 'Egypt'
order by 1,2

--looking at countries with highest infection rate compared to population 
select location ,population ,Max(total_cases) as HightestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from ProtfolioProject..CovidDeaths
--where location like 'Egypt'
Group by location,population
order by 4 DESC
--let's Break things down by continent
--showing countries with Highest Death count per population
select continent  ,Max(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths
--where location like 'Egypt'
where continent is not null
Group by continent
order by 2 desc

--showing countries with Highest Death count per population
select location  ,Max(cast(total_cases as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths
--where location like 'Egypt'
where continent is not null 
Group by location
order by 2 desc
-- GLOBAL NUMBERS

Select date ,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

--Total Population vs Vaccintions 
--shows percentage of population has recived

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac


	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--using CTE to perform Calculation on Partition By in previous query

with PopulationvsVac(Continent, Location ,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationvsVac

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac


	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

