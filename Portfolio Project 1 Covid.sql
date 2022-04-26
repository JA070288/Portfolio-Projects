-- Testing if data sets were imported properly
SELECT *
FROM [Portfolio Project 1 Covid]..Covid_Deaths

SELECT *
FROM [Portfolio Project 1 Covid]..Covid_Vaccinations

-- Looking at "Covid_Deaths" Table
SELECT Location
	, DATE
	, Total_Cases
	, New_Cases
	, Total_Deaths
	, Population
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Mortality Rate
SELECT Location
	, DATE
	, Total_Cases
	, Total_Deaths
	, (Total_Deaths / Total_Cases) * 100 AS "Covid Mortality Percentage"
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Infection Rate
SELECT Location
	, DATE
	, Population
	, Total_Cases
	, (Total_Cases / Population) * 100 AS "Covid Infection Percentage"
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate vs their Population v Total Deaths
SELECT Location
	, Population
	, MAX(Total_Cases) AS "Highest Infected Count"
	, MAX((Total_Cases / Population)) * 100 AS "Population Infected"
	, MAX(CAST(Total_Deaths AS INT)) AS "Total Deaths"
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NOT NULL
GROUP BY Location
	, Population
ORDER BY 'Population Infected' DESC

-- Showing Continents with the highest amounts of deaths related to Covid
SELECT Location
	, MAX(CAST(Total_Deaths AS INT)) AS "Total Deaths"
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NULL
GROUP BY Location
ORDER BY 'Total Deaths' DESC

-- Global Covid Totals
SELECT Date
	, SUM(New_Cases) AS "Daily Cases"
	, SUM(CAST(New_Deaths AS INT)) AS "Daily Deaths"
	, SUM(CAST(New_Deaths AS INT)) / SUM(New_Cases) * 100 AS "Daily Percentage of Deaths"
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NOT NULL
GROUP BY DATE
ORDER BY 1, 2

-- Total Cases and Deaths Globally
SELECT SUM(New_Cases) AS "Total Cases"
	, SUM(CAST(New_Deaths AS INT)) AS "Total Deaths"
	, SUM(CAST(New_Deaths AS INT)) / SUM(New_Cases) * 100 AS "Death Percentage"
FROM [Portfolio Project 1 Covid]..Covid_Deaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2

-- Joining the "Covid_Vaccinations" Table
SELECT *
FROM [Portfolio Project 1 Covid]..Covid_Deaths DTH
JOIN [Portfolio Project 1 Covid]..Covid_Vaccinations VAC
	ON DTH.Location = VAC.Location
		AND DTH.DATE = VAC.DATE

-- Looking at Total Population vs Vaccinations
WITH PopulationVSVaccination (
	Continent
	, Location
	, DATE
	, Population
	, "New Vaccinations"
	, "Vaccination Count"
	)
AS (
	SELECT DTH.Continent
		, DTH.Location
		, DTH.DATE
		, DTH.Population
		, VAC.New_Vaccinations AS "New Vaccinations"
		, SUM(CONVERT(BIGINT, VAC.New_Vaccinations)) OVER (
			PARTITION BY DTH.Location ORDER BY DTH.Location
				, DTH.DATE ROWS UNBOUNDED PRECEDING
			) AS "Vaccination Count"
	FROM [Portfolio Project 1 Covid]..Covid_Deaths DTH
	JOIN [Portfolio Project 1 Covid]..Covid_Vaccinations VAC
		ON DTH.Location = VAC.Location
			AND DTH.DATE = VAC.DATE
	WHERE DTH.Continent IS NOT NULL
	)
SELECT *
	, (CAST("Vaccination Count" AS FLOAT) / CAST(Population AS FLOAT)) * 38.3 AS "Population Vaccination Percentage"
FROM PopulationVSVaccination

	-- Note on the Vaccination Calculation above:
	-- As of this typing 66.5% of the USA is fully vaccinated. That is why I used 38.3% in the formula.
	-- Due to the above I will not be using the data retreived.