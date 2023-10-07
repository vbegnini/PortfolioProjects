-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID19 in your country

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where location = 'Canada'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population from a certain location got COVID19

Select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectionPercentage
From [dbo].[CovidDeaths]
Where location = 'Brazil'
Order by 1,2

-- Showing countries with highest Death Count per population
-- Now used the cast() function to play with the possibilities and implement different options
-- 'Where continent is not null' to get rid of invalid/incomplete values

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Showing CONTINENTS with highest Death Count per population
-- Now used the cast() function to play with the possibilities and implement different options
-- 'Where continent is not null' to get rid of invalid/incomplete values

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccination

-- With JOIN:

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

-- With PARTITION BY and CTE:
-- SUM() exceeding the maximum 'int' (overflowed). Needed to use 'bigint' instead

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
Select *,
From PopvsVac


-- With TEMP TABLE:

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccionations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *
From #PercentPopulationVaccinated


-- Creating VIEW to store data for later visualizations

Create View GlobalNumbers as
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated
Where location = 'Brazil'