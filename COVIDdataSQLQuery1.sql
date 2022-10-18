Select *
From
PortofolioProject..CovidDeaths
order by 3,4

--Select *
--From
--PortofolioProject..CovidVaccinations
--order by 3,4

--Select the DAta that we are going to be using 
Select Location, date, total_cases,new_cases, total_deaths, population
From
PortofolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total deaths in Mexico
--Shows the Likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From
PortofolioProject..CovidDeaths
Where location like '%mexico%'
order by 1,2


--Lookin total cases vs Population
--Shows what percentage of population got covid 
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentageofCases
From
PortofolioProject..CovidDeaths
--Where location like '%mexico%'
order by 1,2


--Looking at Contries with highes infections rate compared to population 

Select Location,MAx(total_cases) as HighestInfectiioncount, population, Max(total_cases/population)*100 as PercentPopulationinfected
From
PortofolioProject..CovidDeaths
--Where location like '%mexico%'
Group by location, population
order by PercentPopulationinfected desc	

--Showing the contries with the highest death count per population 

--Lets break things down by continent 
Select location, MAX( cast(total_deaths as int)) as totaldeathcount
From
PortofolioProject..CovidDeaths
--Where location like '%mexico%'
Where continent is  null 
Group by location
order by totaldeathcount desc	

--Global Numbers 

Select SUM(new_cases) as totalcases , SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From
PortofolioProject..CovidDeaths
--Where location like '%mexico%'
where continent is not null 
--Group by date
order by 1,2

--Looking at total population vs Vavccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table 
DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later vizualizations 
Create View PercentPopulationVacccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
FROM PercentPopulationVacccinated
