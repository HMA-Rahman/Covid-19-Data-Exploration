SELECT [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[RollingPeopleVaccinated]
  FROM [CovidData].[dbo].[testview2]
  order by 2,3