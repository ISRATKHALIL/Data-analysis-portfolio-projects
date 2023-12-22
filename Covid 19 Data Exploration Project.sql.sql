/*
Covid 19 Data Exploration Project

Skills used:  Windows Functions, Aggregate Functions, Joins, CTE's, Creating Views, Converting Data Types and many more

*/



use portfolioproject;


-- Exploring Covid deaths file data 

select * from coviddeaths;

alter table coviddeaths rename column date to dates;

select location, dates,total_cases,new_cases,total_deaths, population  from coviddeaths;



-- total cases vs population

select location,dates,total_cases,population,(total_cases/population)*100 as infectionrate
from coviddeaths where location = 'Canada';


-- countries with highest infectionrate compared to population

select location, population, max(total_cases) as highestinfectioneachcountry, max((total_cases/population))*100 as infectionrate
from coviddeaths
group by location,population
order by 4 desc;


-- total death vs total cases 
select location,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathrate 
from coviddeaths where location = 'Austria' ;


-- countries with highest deathcount compared to population and population is constant so not mentioning in this query; just looking at the deaths

select location, max(cast(total_deaths as signed int)) as highestdeatheachcountry, max((total_deaths/total_cases))*100 as deathrate
from coviddeaths
where continent is not null
group by location, total_cases
order by 3 desc;


-- breakdown by continent

select continent,max(cast(total_deaths as signed int)) as highestdeatheachcountry
from coviddeaths
where continent is not null
group by continent
order by 2 desc;


-- Exploring global numbers

select dates, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths) / sum(new_cases)*100 as deathspercases
from coviddeaths
where continent is not null
group by 1
order by 2;


select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths) / sum(new_cases)*100 as deathspercases
from coviddeaths
where continent is not null
order by 1;



-- Merging deaths data and vaccination data using join - Total Population vs Vaccinations

Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.dates = vac.date
where dea.continent is not null 
order by 2;



-- Using CTE for further calculation on partition by from previous query:


With PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.dates = vac.date
where dea.continent is not null 
-- order by 2;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationvsVaccination;



-- Creating View to store data for later visualizations


Create View PopulationvsVaccination as
Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.dates = vac.date
where dea.continent is not null 












