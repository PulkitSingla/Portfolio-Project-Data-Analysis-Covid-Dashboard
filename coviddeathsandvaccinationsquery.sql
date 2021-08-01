-- Loading the Data
-- SELECT * FROM PortfolioProject..CovidDeaths ORDER BY 3,4

-- SELECT * FROM PortfolioProject..CovidVaccinations ORDER BY 3,4

-- Selecting the data which we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL ORDER BY 1, 2

-- Looking at Total cases vs Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL ORDER BY 1, 2

-- likelihood of dying, if you get covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage FROM PortfolioProject..CovidDeaths WHERE location LIKE '%states%' AND continent IS NOT NULL ORDER BY 1, 2

-- Looking at Total cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infectedpercentage FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at countries with highest Infection Rate compared to Population
SELECT location, MAX(total_cases) as highestinfectioncount, population, MAX((total_cases/population))*100 AS highestinfectedpercentage FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highestinfectedpercentage desc

-- Looking at countries with highest Death count compared to Population
SELECT location, MAX(CAST(total_deaths AS int)) as totaldeathcount FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY totaldeathcount desc

-- Looking at continents with highest Death count compared to Population
SELECT continent, MAX(CAST(total_deaths AS int)) as totaldeathcount FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount desc

-- Looking at countries with highest Death count compared to Population for countires who have their continent column as null
SELECT location, MAX(CAST(total_deaths AS int)) as totaldeathcount FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY totaldeathcount desc

-- GLOBAL NUMBERS

-- Looking at total cases and total deaths each day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2

-- Looking at total cases and total deaths overall
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS deathpercentage 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- Joining the two data of deaths and vaccinations
-- Looking at Total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinationseveryday
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE (Common Table Expression)
WITH PopsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationsEveryDay)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinationseveryday
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (VaccinationsEveryDay/Population)*100
FROM PopsVac

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, VaccinationsEveryDay numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinationseveryday
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (VaccinationsEveryDay/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinationseveryday
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated