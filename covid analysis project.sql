select *
from Portfolioproject.dbo.Covidvaccination
 order by 3,4
 select *
from Portfolioproject.dbo.Coviddeathsfinal

-- select data that we are going to use 

Select location, date, total_cases , new_cases , total_deaths , population
from Portfolioproject.dbo.Coviddeathsfinal
 order by 1,2

 -- looking at total cases vs total deaths
 -- shows probability of dying to some extent

 Select location, date, total_cases , total_deaths , ( total_deaths / total_cases)* 100 as Deathpercentage
from Portfolioproject.dbo.Coviddeathsfinal
Where location like '%states' 
 order by 1,2

 -- total cases vs population  -- population that got covid 
 Select location, date, population , total_cases , ( total_cases /  population)* 100 as cases_percentage_perpopulation
from Portfolioproject.dbo.Coviddeathsfinal
-- Where location like '%states' AND population is NOT null 
 Where population is NOT null 
order by 1,2

-- countries with highest infection rate 
Select location, population , MAX(total_cases) as highestInfectioncount , MAX(( total_cases /  population))* 100 as percentpopulationinfected
from Portfolioproject.dbo.Coviddeathsfinal 
 Where population is NOT null 
 group by location , population 
order by 4 desc

--  showing  where max people died 
Select location,  MAX(Cast(total_deaths as int )) as totaldeathcount
from Portfolioproject.dbo.Coviddeathsfinal 
 Where continent is not null 
group by location 
order by 2 desc

-- Breaking down by continent 
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject.dbo.Coviddeathsfinal 

Where continent is not  null 
Group by continent
order by 2 desc

-- GLOBAL NUMBERS
-- Without using the date we have got teh table number and with the date we got data per day  

Select  /*date*/ SUM(new_cases) as totalnumberof_cases , SUM(cast(new_deaths as int)) as totalnumberofdeaths , (SUM(cast(new_deaths as int)) / SUM(new_cases) )* 100 as Deathpercentage
from Portfolioproject.dbo.Coviddeathsfinal
Where continent is not null 
-- group by date
 order by 1,2


 -- total population vs the vaccination

 select (death.continent) , death.location, death.population , vacci.new_vaccinations 
 from Portfolioproject.dbo.Coviddeathsfinal  death
 JOIN  Portfolioproject.dbo.Covidvaccination vacci on 
 death.location = vacci.location
 and 
 death.date = vacci.date
 where death.continent is not null 

 order by 2,3


 -- Using temp tables or the CTE to find out rolling populations 
 -- we found the rooling people vaccination count i.e. count of almost toal vaccination 


 select (death.continent) , death.location, death.population , vacci.new_vaccinations 
 ,SUM(Convert(int, vacci.new_vaccinations )) OVER (PARTITION BY death.location order by death.location , death.date ) as rolllingpeoplevaccinated

 from Portfolioproject.dbo.Coviddeathsfinal  death
 JOIN  Portfolioproject.dbo.Covidvaccination vacci on 
 death.location = vacci.location
 and 
 death.date = vacci.date
 where death.continent is not null AND  death.population is not null

 order by 2,3

 --use CTE

 With populationVsVaccination (continent , location , date , population ,new_vaccinations , rollingpeoplevaccinated )
 as
  (
Select (death.continent) , death.location,death.date , death.population , vacci.new_vaccinations 
 ,SUM(Convert(int, vacci.new_vaccinations )) OVER (PARTITION BY death.location order by death.location , death.date ) as rolllingpeoplevaccinated

 from Portfolioproject.dbo.Coviddeathsfinal  death
 JOIN  Portfolioproject.dbo.Covidvaccination vacci on 
 death.location = vacci.location
 and 
 death.date = vacci.date
 where death.continent is not null AND  death.population is not null
 )

 Select *,(rollingpeoplevaccinated/population) * 100 as vaccinationpercentage
 from populationVsVaccination

 -- Using Temp Table to perform Calculation on Partition By in previous query

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
Select death.continent, death.location, death.date, death.population, vacci.new_vaccinations
, SUM(CONVERT(int,vacci.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolioproject.dbo.Coviddeathsfinal  death
 JOIN  Portfolioproject.dbo.Covidvaccination vacci on 
 death.location = vacci.location
	and death.date = vacci.date
where death.continent is not null AND  death.population is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select death.continent, death.location, death.date, death.population, vacci.new_vaccinations
, SUM(CONVERT(int,vacci.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolioproject.dbo.Coviddeathsfinal  death
 JOIN  Portfolioproject.dbo.Covidvaccination vacci on 
 death.location = vacci.location
	and death.date = vacci.date
where death.continent is not null AND  death.population is not null
--order by 2,3

--END
select *
from  PercentPopulationVaccinated