select *
from [Portfolio Project]..covidDeaths
order by 3,4

--select *
--from [Portfolio Project]..covidVaccinations
--order by 3,4

--select Data that we are going to using

select Location,date,Total_cases,new_cases,total_deaths,population_density
from [Portfolio Project]..covidDeaths
order by 1,2

--total cases to toal deaths
--shows likelihood of dying
select Location,date,Total_cases,total_deaths,(total_deaths/Total_cases)*100 as DeathPercentage
from [Portfolio Project]..covidDeaths
where continent='Asia'
order by 1,2

--looking at total cases vs the population
--shows what % of population got covid
select Location,date,Total_cases,population_density,(total_deaths/population_density)*100 as CovidPercentage
from [Portfolio Project]..covidDeaths
where continent='Asia'
order by 1,2

select Location,date,Total_cases,total_deaths,(total_deaths/Total_cases)*100 as covidPercentage
from [Portfolio Project]..covidDeaths
--where continent='Asia'
order by 1,2

--looking at countries with highest infecton rate
select Location,population_density,max(Total_cases) as HighestInfection,max((total_deaths/Total_cases))*100 as covidPercentage
from [Portfolio Project]..covidDeaths
--where continent='Asia'
group by location,population_density
order by covidPercentage desc

--showing countries with highest death counts per population
select Location,max(cast(total_deaths as int)) as TotalDeaths
from [Portfolio Project]..covidDeaths
--where continent='Asia'
where continent is null
group by location
order by TotalDeaths desc

select Location,max(cast(total_deaths as int)) as TotalDeaths
from [Portfolio Project]..covidDeaths
--where continent='Asia'
where continent is not null
group by location
order by TotalDeaths desc

--LET'S DRILL DOWN TO CONTINENTS
select Continent,max(cast(total_deaths as int)) as TotalDeaths
from [Portfolio Project]..covidDeaths
--where continent='Asia'
where continent is null
group by continent
order by TotalDeaths desc

--showing continents with highest deathcounts
select Continent,max(cast(total_deaths as int)) as TotalDeaths
from [Portfolio Project]..covidDeaths
--where continent='Asia'
where continent is not null
group by continent
order by TotalDeaths desc

--GLOBAL NUMBERS
select date,sum(new_cases) as totalCases,sum(cast(new_deaths as int))as totalDeaths--,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..covidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalCases,sum(cast(new_deaths as int))as totalDeaths--,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..covidDeaths
where continent is not null
--group by date
order by 1,2

select * 
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..[covidVaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date

--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolllingPeopleVaccinated
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..[covidVaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE

with popvsvac(continent,location,date,population_density,new_vaccinations,rollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolllingPeopleVaccinated
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..[covidVaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population_density)*100
from popvsvac

--temp table
drop table if exists PercentpopulationVaccinated
create table PercentpopulationVaccinated
(continent nvarchar(255),
Locationn nvarchar(255),
Date datetime,
popupaltion numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into PercentpopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolllingPeopleVaccinated
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..[covidVaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingPeopleVaccinated/PercentpopulationVaccinated.popupaltion)*100
from PercentpopulationVaccinated

--creating view to store data for later visualization
create view PopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolllingPeopleVaccinated
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..[covidVaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * 
from PopulationVaccinated