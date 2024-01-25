/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

Use PortfolioProject;

Select *
From CovidDeaths
order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population 
From CovidDeaths;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where Location like '%States%'
order by 1,2;

-- Total Cases vs Population
-- Shows the percentage of population infected with covid in United States
Select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectionRate
From CovidDeaths
Where Location like '%States%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as HighestInfectionRate
From CovidDeaths
Group by Location, Population
order by HighestInfectionRate;

-- Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Group by Location
order by TotalDeathCount;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) 
OVER (Partition by d.location Order by d.location, d.date) as CummulativeVaccinations
from CovidDeaths d
Join CovidVaccinations v
On d.Location = v.Location
and d.date = v.date
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeVaccinations)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) 
OVER (Partition by d.Location Order by d.location, d.Date) as CummulativeVaccinations
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
)
Select *, (CummulativeVaccinations/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(50),
    Location VARCHAR(50),
    Date DATE,
    Population INT,
    New_vaccinations INT,
    CummulativeVaccinations INT
);

INSERT INTO PercentPopulationVaccinated
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.location, d.Date) AS CummulativeVaccinations
FROM
    CovidDeaths d
JOIN CovidVaccinations v ON d.location = v.location AND d.date = v.date;

SELECT *, (CummulativeVaccinations / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations)
 OVER (Partition by d.Location Order by d.location, d.Date) as CummulativeVaccinations
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date;percentpopulationvaccinated
    