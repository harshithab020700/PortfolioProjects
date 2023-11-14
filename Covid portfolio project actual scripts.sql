SELECT*
FROM PortfolioProject..['covid deaths$']
order by 3,4
--SELECT*
--FROM PortfolioProject..['covid vaccinations$']
--order by 3,4
--Select the data that we are going to use

Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid deaths$']
order by 1,2

-- we are looking at total cases  vs total deaths also looking for percentage in each country
--shows the likelihood of dying if you  contact covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..['covid deaths$']
where location like '%states%'
order by 1,2

-- looking at the total cases vs the population 
-- shows what percentage of  population got covid
Select Location, date, population,total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..['covid deaths$']
where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compared to population
Select Location,  population, MAX(total_cases) as HighestInfectionCount, (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..['covid deaths$']
--where location like '%India%'
Group by Location ,Population
order by PercentPopulationInfected desc

-- Showing the countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid deaths$']
where continent is not Null 
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- showing the continents with highest death continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid deaths$']
where continent is not Null 
Group by continent
order by TotalDeathCount desc

-- Global Numbers
-- Number of deaths worldwise per date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
From PortfolioProject..['covid deaths$']
where continent is not NULL
Group By date
order by 1,2

-- death perectage worldwide per day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , (CONVERT(float, SUM(cast(new_deaths as int))) / NULLIF(CONVERT(float, SUM(new_cases)), 0))*100 as DeathPercentage
From PortfolioProject..['covid deaths$']
where continent is not NULL
Group By date
order by 1,2

--the overall death percentage 
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , (CONVERT(float, SUM(cast(new_deaths as int))) / NULLIF(CONVERT(float, SUM(new_cases)), 0))*100 as DeathPercentage
From PortfolioProject..['covid deaths$']
where continent is not NULL
--Group By date
order by 1,2

-- joining both tables
Select* 
From PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
 on dea.location=vac.location
 and dea.date=vac.date

 --looking total poulation vs total vaccination

 Select dea.continent, dea.location ,dea.date,dea.population, vac.new_vaccinations
 From PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not Null
order by 1,2,3
--rollingpeoplevaccinated
Select dea.continent, dea.location ,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not Null
order by 2,3

--Using CTE we the percentage of population vaccinated 

with PopvsVac (Continent, location, date ,population , new_vaccinations,RollingPeopleVaccinated)
as
( 
Select dea.continent, dea.location ,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not Null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentpopulaionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentpopulaionVaccinated
Select dea.continent, dea.location ,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not Null

Select*, (RollingPeopleVaccinated/population)*100
From #PercentpopulaionVaccinated

--CREATING VIEW TO STORE DATE FOR LATER VISUALIZATION

Create view PercentpopulaionVaccinated as 
Select dea.continent, dea.location ,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not Null

Select *
From PercentpopulaionVaccinated