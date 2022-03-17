--This is a sample data analysis project.
--A data exploration was performed on the data made available by the Johns Hopkins University.
--This data deals with confirmed covid-19 cases and deaths in the world

Select * from PortfolioProject.dbo.Covid_Deaths
order by 3,4 

--Select * from PortfolioProject.dbo.Covid_Vaccinations
--order by 3,4 

--Selecting data that is actually going to be used
Select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject.dbo.Covid_Deaths
order by 1,2

--Looking at total deaths v/s total cases
--Shows likelihood of dying if anyone contracted Covid-19
Select location,date,total_cases,total_deaths, 
(total_deaths/total_cases)*100 as "Percentage of people dead from the total number of cases",population 
from PortfolioProject.dbo.Covid_Deaths
order by 1,2

--Total_cases v/s population
--Shows how much percentage of the country's population tested +ve / contracted Covid-19
Select location,date,total_cases,total_deaths, 
(total_cases/population)*100 as "Percentage of people dead from the total number of cases",population 
from PortfolioProject.dbo.Covid_Deaths
order by 1,2

--Finding countries with highest infection rates amongst population

Select location,population, max(total_cases) as "Highest Infection Count", 
max((total_cases/population))*100 as "Max percentage of people infected among population" 
from PortfolioProject.dbo.Covid_Deaths
Group by location,population
order by 4 desc

--Finding the countries with the highest death count per population
Select location,population, max(cast(total_deaths as int)) as "Highest Death Count", 
max((cast(total_deaths as int)/population))*100 as "Maximum percentage of people dead among the population" 
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
Group by location,population
order by "Highest Death Count" desc

--Breaking things down as per continent
Select continent, max(cast(total_deaths as int)) as "Highest Death Count"
--max((cast(total_deaths as int)/population))*100 as "Maximum percentage of people dead among the population" 
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
Group by continent
order by "Highest Death Count" desc

--Global (World) figures
Select sum(new_cases) as "Total cases",sum(cast(new_deaths as int)) as "Total deaths", sum(cast(new_deaths as int)) /sum(new_cases) *100
as "Percentage of people dead from the total number of cases"
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
order by 1,2

--Looking at "Covid Vaccinations" table
select * 
from PortfolioProject.dbo.Covid_Deaths dea
join PortfolioProject.dbo.Covid_Vaccinations vac
on dea.location=vac.location 
and dea.date=vac.date

--Finding the number of people vaccinated per day 
with popvsvac (continent,location,date,population,new_vaccinations,"Rolling people vaccinated")
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as "Rolling people vaccinated"
from PortfolioProject.dbo.Covid_Deaths dea
join PortfolioProject.dbo.Covid_Vaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
)
select *,("Rolling people vaccinated"/population)*100 from popvsvac

--Temporary table creation

drop table if exists populationvaccinated

create table populationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
"Rolling people vaccinated" numeric
)

insert into populationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as "Rolling people vaccinated"
from PortfolioProject.dbo.Covid_Deaths dea
join PortfolioProject.dbo.Covid_Vaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null

select *,("Rolling people vaccinated"/population)*100 from populationvaccinated

--Creating view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as "Rolling people vaccinated"
from PortfolioProject.dbo.Covid_Deaths dea
join PortfolioProject.dbo.Covid_Vaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null

select * from percentpopulationvaccinated