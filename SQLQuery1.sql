SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--looking at Total cases vs Total Deaths
--shows the likelihood of dying from covvid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--looking at Total Cases vs Population
--Shows what percenteage of the population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--looking at Countries with highest infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationIntected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationIntected DESC



--Showing the Countries with the Highest Death Count per Population

SELECT location, MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continent with highest death count per population

SELECT continent, MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccination



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated)*100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



---USE CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)*100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, ( RollingPeopleVaccinated/population) *100
FROM PopvsVac



--USE TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)*100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, ( RollingPeopleVaccinated/population) *100
FROM #PercentPopulationVaccinated


--creating view to store data for later visualizations

CREATE VIEW PercentagePopulatonvaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)*100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentagePopulatonvaccinated2