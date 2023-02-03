select * 
from [Portfolio Project].dbo.CovidDeaths
order by 3, 4

select * 
from [Portfolio Project].dbo.['Covid vaccinations]
order by 3, 4

--#Selecting Data to use
select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project].dbo.CovidDeaths
order by 1, 2

--total cases vrs total deaths in Africa
select location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths 
where location = 'Africa'
order by 1, 2

--total cases vrs total population in Africa with Covid
select location,date,population,total_cases, (total_cases/population)* 100 as PercentPopulationsInfected
from [Portfolio Project].dbo.CovidDeaths 
where location ='Africa'
order by 1, 2

--Countries with highest Infection rate compared to population
select location,population, Max (total_cases) as HighInfestionCount , MAX ((total_cases/population)) *100 as PercentPopulationsInfected
from [Portfolio Project].dbo.CovidDeaths 
group by population,location
order by PercentPopulationsInfected desc

--Countries with highest death count per population
select location, Max (Cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc

--Covid Death around the Continent
select continent, Max (Cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc

--Continent with the highest death count per population
select continent,population , Max (Cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths 
where continent is not null
group by continent,population
order by TotalDeathCount desc

--Global Numbers
Select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
where continent is not null 
Group By date
order by 1,2

--Join 2 tables 
select * from 
[Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.['Covid vaccinations] as Vac
on dea.location = vac.location
and dea.date = vac.date

--Total Population vrs Vaccinations
select dea.continent,dea.location,dea.date,dea.population ,Vac.new_vaccinations
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.['Covid vaccinations] as Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Percentage of Population that has atleast one covid Vaccination
select dea.continent,dea.location,dea.date,dea.population ,Vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.['Covid vaccinations] as Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--, (RollingPeopleVaccinated/population)*100


--- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.['Covid vaccinations] as Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


 --Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths as dea
join [Portfolio Project].dbo.['Covid vaccinations] as Vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create a View for Data Visualizations

	Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.['Covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 