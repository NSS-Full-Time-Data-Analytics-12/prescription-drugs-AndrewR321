----1. How many npi numbers appear in the prescriber table but not in the prescription table?

(SELECT npi
FROM prescriber)
EXCEPT
(SELECT npi
FROM prescription);
---- Answer 4458

----2a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT generic_name, SUM(total_claim_count)
FROM (SELECT npi, total_claim_count, drug_name
		FROM prescription 
		INNER JOIN prescriber USING (npi)
		WHERE specialty_description = 'Family Practice')AS npi_tcc
INNER JOIN drug USING (drug_name)
GROUP BY generic_name 
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;
---LEVOTHYROXINE SODIUM, 406547
---LISINOPRIL, 311506
---ATORVASTATIN CALCIUM, 308523
---AMLODIPINE BESYLATE, 304343
---OMEPRAZOLE, 273570

----2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

SELECT generic_name, SUM(total_claim_count)
FROM prescriber INNER JOIN prescription USING (npi)
				INNER JOIN drug USING (drug_name) 
WHERE specialty_description = 'Cardiology' 
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

---ATORVASTATIN CALCIUM, 120662
---CARVEDILOL, 106812
---METOPROLOL TARTRATE, 93940
---CLOPIDOGREL BISULFATE, 87025
---AMLODIPINE BESYLATE, 86928

----2c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? 
----Combine what you did for parts a and b into a single query to answer this question.

SELECT generic_name, SUM(total_claim_count)
FROM prescriber INNER JOIN prescription USING (npi)
				INNER JOIN drug USING (drug_name) 
WHERE specialty_description = 'Cardiology' OR specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

---ATORVASTATIN CALCIUM, 429185
---LEVOTHYROXINE SODIUM, 415476
---AMLODIPINE BESYLATE, 391271
---LISINOPRIL, 387799
---FUROSEMIDE, 318196

----3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
----3a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. 
----Report the npi, the total number of claims, and include a column showing the city.

SELECT npi, SUM(total_claim_count), nppes_provider_city
FROM prescriber INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'	
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

----3b. Now, report the same for Memphis.

SELECT npi, SUM(total_claim_count), nppes_provider_city
FROM prescriber INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'	
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

----3c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

(SELECT npi, SUM(total_claim_count), nppes_provider_city
FROM prescriber INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'	
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5)
UNION
(SELECT npi, SUM(total_claim_count), nppes_provider_city
FROM prescriber INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'	
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5)
UNION
(SELECT npi, SUM(total_claim_count), nppes_provider_city
FROM prescriber INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'KNOXVILLE'	
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5)
UNION
(SELECT npi, SUM(total_claim_count), nppes_provider_city
FROM prescriber INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'CHATTANOOGA'	
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5)
ORDER BY nppes_provider_city;

----4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

SELECT CAST(fipscounty AS INT)
FROM fips_county;

SELECT overdose_deaths, fips_county.county, year
FROM overdose_deaths
INNER JOIN fips_county ON CAST(fips_county.fipscounty AS INT) = overdose_deaths.fipscounty
WHERE overdose_deaths >(SELECT AVG(overdose_deaths)
						FROM overdose_deaths);
----82 counties over 12.6 average deaths from 2015-2018						

----5a. Write a query that finds the total population of Tennessee.			

SELECT SUM(population) AS total_tn_pop
FROM population;

-----6597381

----5b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.


SELECT county, population,  population/(SELECT SUM(population) FROM population)*100 AS perc
FROM population INNER JOIN fips_county USING (fipscounty)

