SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL

---Rough caculation of DEATH % GERMANY
SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%Germany%'
order by 1,2

---What COUNTRIES POPULATION %  got Covid
SELECT Location, date, population, total_cases, (total_cases/NULLIF(population, 0))*100 AS PercentagePopulationINfected 
FROM CovidDeaths

--Looking at COUNTRIES with HIGHEST INFECTION campared to POPULATION
SELECT location, population, MAX(total_cases) AS HighestInfections, 
							MAX((total_cases/NULLIF(population, 0))*100) 
							AS PercentagePopulationINfected
FROM CovidDeaths
GROUP BY location, population
Order by PercentagePopulationINfected DESC


--Showing countries with the highest death count per population
Select location, MAX(total_deaths) AS TotalDeathCOunt
FROM CovidDeaths
WHERE location is NOT NULL
GROUP BY location
ORDER BY TotalDeathCOunt DESC

--Showing the CONTINENTS with the HIGHEST DEATH COUNT
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent = ''
--WHERE continent IS NULL
Group by location
Order by TotalDeathCOunt desc;


--GLOBAL NUMBERS
SELECT SUM(new_cases) as Total_cases, 
		SUM(new_deaths) as Total_deaths,
		SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM CovidDeaths
Where continent != ''
order by 1,2

----
---Print colums in CovidVaccinations
--SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CovidVaccinations'

----

Select * from CovidVaccinations



--Looking at TOTAL POPULATIO vs VACCINATIONS 
---CTE---
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccination)
as
(
Select death.continent, death.location, death.date, death.population, 
	vaccine.new_vaccinations,
	sum(vaccine.new_vaccinations) OVER (Partition by death.location Order by death.location, 
		     death.date) as RollingPeopleVaccination
	--(RollingPeopleVaccination/population)*100

From CovidDeaths death
JOIN CovidVaccinations vaccine
ON death.location = vaccine.location and death.Date = vaccine.date
Where death.continent != ''
--Order by 2, 3
)

SELECT *, (RollingPeopleVaccination/Nullif(Population, 0))*100
FROM PopvsVac

---or using TEMP TABLE---

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, 
	vaccine.new_vaccinations,
	sum(vaccine.new_vaccinations) OVER (Partition by death.location Order by death.location, 
		     death.date) as RollingPeopleVaccination
	--(RollingPeopleVaccination/population)*100

From CovidDeaths death
JOIN CovidVaccinations vaccine
ON death.location = vaccine.location and death.Date = vaccine.date
Where death.continent != ''
--Order by 2, 3

SELECT *, (RollingPeopleVaccination/Nullif(Population, 0))*100
FROM #PercentPopulationVaccinated


---***Creating View to store data for later Visualizaion***---
CREATE VIEW PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, 
	vaccine.new_vaccinations,
	sum(vaccine.new_vaccinations) OVER (Partition by death.location Order by death.location, 
		     death.date) as RollingPeopleVaccination
	--(RollingPeopleVaccination/population)*100

From CovidDeaths death
JOIN CovidVaccinations vaccine
ON death.location = vaccine.location and death.Date = vaccine.date
Where death.continent != ''
--Order by 2, 3
SELECT * 
FROM PercentPopulationVaccinated





