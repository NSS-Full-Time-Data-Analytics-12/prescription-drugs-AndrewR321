

----1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC;

---1881634483, 99707

----1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, total_claim
FROM (SELECT npi, SUM(total_claim_count)AS total_claim
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC)AS total_number_of_claims
INNER JOIN prescriber ON prescriber.npi = total_number_of_claims.npi
ORDER BY total_claim DESC;

----BRUCE PENDLEY, Family Practice, 99707

----2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim)
FROM (SELECT npi, SUM(total_claim_count)AS total_claim
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC)AS total_number_of_claims
INNER JOIN prescriber ON prescriber.npi = total_number_of_claims.npi
GROUP BY specialty_description
ORDER BY SUM(total_claim) DESC;

----Family Practice, 9752347

----2b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count) 
FROM(SELECT drug_name, opioid_drug_flag
		FROM drug
		WHERE opioid_drug_flag = 'Y')AS opioid_drug
INNER JOIN prescription ON prescription.drug_name = opioid_drug.drug_name
INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY  specialty_description
ORDER BY SUM(total_claim_count) DESC;

----Nurse Practitioner, 900845

----2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description
FROM prescriber
LEFT JOIN prescription USING (npi)
GROUP BY specialty_description
EXCEPT
SELECT specialty_description
FROM prescription
INNER JOIN prescriber USING (npi)
GROUP BY specialty_description;

--Marriage & Family Therapist
--Contractor
--Physical Therapist in Private Practice
--Radiology Practitioner Assistant
--Developmental Therapist
--Hospital
--Chiropractic
--Specialist/Technologist, Other
--Occupational Therapist in Private Practice
--Licensed Practical Nurse
--Midwife
--Medical Genetics
--Physical Therapy Assistant
--Ambulatory Surgical Center
--Undefined Physician type

----2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?


----3a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost)
FROM(SELECT drug_name, generic_name
FROM drug)AS gen_drug
INNER JOIN prescription AS p ON p.drug_name = gen_drug.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC;

---INSULIN GLARGINE, HUM.REC.ANLOG, 104264066.35

----3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, SUM(total_drug_cost)/SUM(total_day_supply) AS total_cost_per_day
FROM prescription
INNER JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day DESC;

--C1 ESTERASE INHIBITOR, 3495.219

----4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name, CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
						WHEN antibiotic_drug_flag = 'Y' THEN 'anitbiotic'
						ELSE 'neither' END AS drug_type
FROM drug;


----4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics.
----Hint: Format the total costs as MONEY for easier comparision.

SELECT drug_type, SUM(total_drug_cost)::money
FROM(SELECT drug_name, CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
						WHEN antibiotic_drug_flag = 'Y' THEN 'anitbiotic'
						ELSE 'neither' END AS drug_type
	  FROM drug)
INNER JOIN prescription USING (drug_name)
GROUP BY drug_type;

----opioids, 105080626.37

----5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT *
FROM cbsa
WHERE cbsaname ILIKE '%TN';

SELECT COUNT(DISTINCT cbsa)
FROM cbsa
WHERE cbsaname ILIKE '%TN';

--33 or 6 without doups

----5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsaname, cbsa, SUM(population) AS total_pop
FROM population
INNER JOIN fips_county USING (fipscounty)
INNER JOIN cbsa USING (fipscounty)
GROUP BY cbsaname, cbsa
ORDER BY SUM(population) DESC;

----Nashville-Davidson-Murfreesboro-Franklin, TN pop = 1830410, Morristown, TN pop = 116352

----5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT * 
FROM population
INNER JOIN fips_county USING (fipscounty)
LEFT JOIN cbsa USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC;

----SEVEIR county pop = 95523

-----6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

--OXYCODONE HCL, 4538
--LISINOPRIL, 3655
--GABAPENTIN, 3531
--HYDROCODONE-ACETAMINOPHEN, 3376
--LEVOTHROXINE SODIUM, 3138
--LEVOTHROXINE SODIUM, 3101
--MIRTAZAPINE, 3085
--FUROSEMIDE, 3085
--LEVOTHROXINE SODIUM, 3023

----6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

--OXYCODONE HCL, 4538, Y
--LISINOPRIL, 3655, N
--GABAPENTIN, 3531, N
--HYDROCODONE-ACETAMINOPHEN, 3376, Y
--LEVOTHROXINE SODIUM, 3138, N
--LEVOTHROXINE SODIUM, 3101, N
--MIRTAZAPINE, 3085, N
--FUROSEMIDE, 3085, N
--LEVOTHROXINE SODIUM, 3023, N

----6c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name, total_claim_count, opioid_drug_flag, nppes_provider_first_name||' '|| nppes_provider_last_org_name AS prescriber_name
FROM (SELECT npi, drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000) AS claim3000
LEFT JOIN prescriber USING (npi)
ORDER BY total_claim_count DESC;

--OXYCODONE HCL, 4538, Y, DAVID COFFEY
--LISINOPRIL, 3655, N, BRUCE PENDLEY
--GABAPENTIN, 3531, N, BRUCE PENDLEY
--HYDROCODONE-ACETAMINOPHEN, 3376, Y, DAVID COFFEY
--LEVOTHROXINE SODIUM, 3138, N, DEAVER SHATTUCK
--LEVOTHROXINE SODIUM, 3101, N, ERIC HASEMEIER
--MIRTAZAPINE, 3085, N, BRUCE PENDLEY
--FUROSEMIDE, 3085, N, MICHAEL COX
--LEVOTHROXINE SODIUM, 3023, N, BRUCE PENDLEY

----7a. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. 
---nppes_provider_city, specialty_description, opioid_drug_flag

SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
ORDER BY npi;

----7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
---You should report the npi, the drug name, and the number of claims (total_claim_count). 

WITH opioid AS (SELECT npi, drug_name
	  			FROM prescriber
	 		 	CROSS JOIN drug
	 		 	WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
	  			ORDER BY npi)
SELECT npi, drug_name, total_claim_count
FROM opioid
LEFT JOIN prescription USING (npi, drug_name);


----7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

WITH opioid AS (SELECT npi, drug_name
	  			FROM prescriber
	 		 	CROSS JOIN drug
	 		 	WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
	  			ORDER BY npi)
SELECT npi, drug_name, COALESCE(total_claim_count, '0')
FROM opioid
LEFT JOIN prescription USING (npi, drug_name);
