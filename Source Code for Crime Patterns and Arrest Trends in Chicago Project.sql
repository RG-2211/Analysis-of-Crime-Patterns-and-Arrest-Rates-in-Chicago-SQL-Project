

-- Objective:
-- To analyze crime patterns across community areas and identify trends in arrest rates.


-- Introducing our data:

-- 1)  Number of communities in Chicago
SELECT COUNT(DISTINCT(COMMUNITY_AREA_NUMBER)) AS `Number of Communities` FROM CENSUS;
-- Answer: 77


-- 2) Total Crimes reported in Chicago
SELECT COUNT(ID) AS `Total Crimes` FROM CRIME;
-- These are the total number of crimes committed in Chicago in those 77 communities during from 2001 to 2018.


-- 3) Number of Crimes throughout the Years
 SELECT YEAR(DATE) AS `Years`, COUNT(*) AS `Number of Crimes` FROM CRIME GROUP BY `Years` ORDER BY `Years`;
  -- This is how the crimes are spread out through out the years
  -- We can see the number of crimes between from 2002 - 2009 increased being in the average range of 20-35, 
  -- reaching the the highest number in 2009 with 35 crimes, which accounts for 9.9% of total crime between the period 2001 - 2018
-- There is a slight descrease in crime after 2009 mostly being in the average range of 10 - 25  except few years and it continues till 2018 years.


 -- 4) Total Crimes by each type
 SELECT PRIMARY_TYPE, COUNT(PRIMARY_TYPE) AS `Number of Crimes`
 FROM CRIME GROUP BY PRIMARY_TYPE ORDER BY `Number of Crimes` DESC; 
 -- Lets see the distribution of crime as per the types.
 -- We can see that THEFT is the highest type of crime committed in Chicago.
 -- Theft alone is responsible for 28% of total crimes, 
 -- followed by CRIMINAL DAMAGE at 15% of crimes and NARCOTICS at 14% of all crimes. 
 -- Just these three types of crimes comprise 58.35% of total crimes.


-- 5) Timeline of Type of Crimes
SELECT YEAR(DATE) AS `Years`, PRIMARY_TYPE, COUNT(ID) AS `Number of Crimes` 
FROM CRIME GROUP BY `Years`, PRIMARY_TYPE
ORDER BY `Years`, `Number of Crimes` DESC;
-- Lets look at the yearly trend of crimes reported across various communities
-- In each year, crimes related to THEFT, CRIMINAL DAMAGE, and NARCOTICS consistently appear at higher rates compared to other offenses.
-- 2009 recorded the highest number of THEFTs, along with high occurrences of CRIMINAL DAMAGE, NARCOTICS, and BURGLARY.


-- 6) Total Crimes in Each Community
 SELECT CS.COMMUNITY_AREA_NAME, COUNT(CR.ID) AS `Number of Recorded Crimes Per Area` 
 FROM CENSUS AS CS JOIN CRIME AS CR 
 ON CS.COMMUNITY_AREA_NUMBER = CR.COMMUNITY_AREA_NUMBER 
 GROUP BY CS.COMMUNITY_AREA_NAME ORDER BY `Number of Recorded Crimes Per Area` DESC;
 -- Now lets look at the number of crimes reported across the communities
-- The output shows top 15 communitnies arranged on the basis of number of crimes reported in their community
-- Austin has the highest crime rate, accounting for 7% of all crimes, followed by Humboldt at 3.9%, 
-- Englewood at 3.68%, and both Near West Side and Near North Side at approximately 3.40% each.
-- These top 5 communities contribute to 21.8% of total crime committed in Chicago.


 -- 7) Timeline of total crimes according to communities
 SELECT YEAR(CR.DATE) AS `Years`, CS.COMMUNITY_AREA_NAME, COUNT(CR.ID) AS `Number of Crimes` 
 FROM CENSUS AS CS JOIN CRIME AS CR 
 ON CS.COMMUNITY_AREA_NUMBER = CR.COMMUNITY_AREA_NUMBER 
 GROUP BY CS.COMMUNITY_AREA_NAME, `Years` ORDER BY `Years`, `Number of Crimes` DESC;
-- Answers : 
-- Let's examine how crime has developed across communities over the years to understand the possible disproportionalities better.
-- When we look at the yearly occurrence of crimes in each community, we see that most communities report only 1 to 2 crimes per year, with a few exceptions.
-- Even among the top 5 communities crime per year is distributed evenly. 
-- However, Austin stands out with consistently higher crime rates compared to other areas throughout the years. 
-- Like it reported 4 crimes in the year 2009 and 3 crimes in 2013


-- 8) Type and Number of Crimes Across Communities 
SELECT CS.COMMUNITY_AREA_NAME, CPT.PRIMARY_TYPE, COUNT(CR.ID) AS `Number of Crimes`
 FROM CENSUS AS CS CROSS JOIN (SELECT DISTINCT PRIMARY_TYPE FROM CRIME) AS CPT LEFT JOIN CRIME AS CR ON 
 CS.COMMUNITY_AREA_NUMBER = CR.COMMUNITY_AREA_NUMBER AND CR.PRIMARY_TYPE = CPT.PRIMARY_TYPE
 GROUP BY CS.COMMUNITY_AREA_NAME, CPT.PRIMARY_TYPE
 HAVING `Number of Crimes` > 0
 ORDER BY CS.COMMUNITY_AREA_NAME, `Number of Crimes` DESC;
 -- Lets see if the disproportionalities have any connection to amount of distribution of different types of crimes within each community
 -- THEFT and NARCOTICS offenses occur in a higher number in most areas compared to other types of crimes and THEFTs and NARCOTICS related crimes also appear in more communities as compared to other crimes.
-- Like most communities, this pattern is also true for our top 5 communities.
 -- THEFT and NARCOTICS-related crimes are notably higher, than other types of crimes in Austin. 
 -- With there being 8 THEFTS and 7 NARCOTICS cases in Austin. 
 
 
 -- 9) Which communities are contributing to such high number of Narcotics and THEFTS 
SELECT CR.PRIMARY_TYPE, CS.COMMUNITY_AREA_NAME, COUNT(CR.ID) AS `Number of Crimes`, 
       SUM(COUNT(CR.ID)) OVER (PARTITION BY CR.PRIMARY_TYPE) AS `Total Crimes by Type`
FROM CRIME AS CR
JOIN CENSUS AS CS ON CR.COMMUNITY_AREA_NUMBER = CS.COMMUNITY_AREA_NUMBER
GROUP BY CR.PRIMARY_TYPE, CS.COMMUNITY_AREA_NAME
HAVING COUNT(CR.ID) > 0
ORDER BY `Total Crimes by Type` DESC, `Number of Crimes` DESC;
-- The output shows top 5 communities that contribute the top 3 most recurring crimes: THEFT, CRIMINAL DAMAGE and NARCOTICS.
-- Upon examining the output we can confirm that Austin not only has the highest occurrences of THEFT and NARCOTICS-related crimes but also BURGLARY.
-- *THEFT is particularly frequent in Austin, Near West Side, and Englewood, with 18% of thefts happening in these three areas, and Austin leading with 8 incidents.
-- CRIMINAL DAMAGE is slightly more concentrated in West Town and Brighton Park, which together account for about 13% of these offenses, while other cases are spread across various communities.
-- NARCOTICS crimes are also high in Austin, as well as in Humboldt Park and Uptown, where 30% of such offenses took place. 
 
 
 ----- Analysing Arrests
 -- Now lets look at the situation of arrests across these communities
 
 -- 10) Number of Arrests
 SELECT COUNT(ARREST) AS `Total Arrests` FROM CRIME WHERE ARREST = "TRUE";
 -- Only 108 arrests out of 353 crimes committed
 
 
 -- 11)  Timeline of Arrests Rate
 WITH year_arrest AS
 (SELECT YEAR(DATE) AS `Years`, COUNT(ID) AS `Number of Crimes`, 
 SUM(CASE WHEN ARREST = "TRUE" THEN 1 ELSE 0 END) AS `Number of Arrests` FROM CRIME GROUP BY `Years` ORDER BY `Years`, `Number of Arrests` DESC)
 SELECT year_arrest.`Years`, `Number of Crimes`, `Number of Arrests`, ROUND((`Number of Arrests` / `Number of Crimes`) * 100 ,2)
AS `Rate of Arrests` FROM year_arrest ORDER BY `Years`, `Rate of Arrests` DESC;
-- Lets look at the distribution of arrests in comparision with crime more closely throughout the years.
-- We observe a slight increase in the number of arrests corresponding with the rise in crime rates up to 2009.
-- However, after 2009, the number of arrests begins to decline relative to the number of crimes committed, with a noticeable drop in the arrest percentage.
-- This downward trend continues through to 2018.


-- 12) Number of Crimes and Arrest Per Community Per Year
 SELECT YEAR(CR.DATE) AS `Years`, CS.COMMUNITY_AREA_NAME, COUNT(CR.ID) AS `Number of Crimes`, 
 SUM(CASE WHEN CR.ARREST = 'TRUE' THEN 1 ELSE 0 END) AS `Number of Arrests` 
 FROM CENSUS AS CS JOIN CRIME AS CR ON CS.COMMUNITY_AREA_NUMBER = CR.COMMUNITY_AREA_NUMBER
 GROUP BY `Years`, CS.COMMUNITY_AREA_NAME ORDER BY `Years`, `Number of Crimes` DESC;
 -- Generally, the number of arrests per year in each community is much lower than the number of crimes committed, 
 -- with many years showing zero arrests even when 1-2 crimes were recorded.
-- For instance, in 2002, only Lakeview and Douglas reported arrests, 
-- while other communities with recorded crimes had none.
-- This trend could be influenced by the slow pace of the justice system, 
-- where processing and assessing crimes often takes more than a year, delaying arrests.


-- 13. view)
CREATE VIEW comm_crime AS
 (SELECT CS.COMMUNITY_AREA_NAME, COUNT(CR.ID) AS `Number of Crimes`, SUM(CASE WHEN CR.ARREST = 'TRUE' THEN 1 ELSE 0 END) 
 AS `Number of Arrests`FROM CENSUS AS CS JOIN CRIME AS CR ON CS.COMMUNITY_AREA_NUMBER = CR.COMMUNITY_AREA_NUMBER
 GROUP BY CS.COMMUNITY_AREA_NAME ORDER BY `Number of Crimes` DESC);

-- 13) Percentage Arrests in Each Community
 SELECT COMMUNITY_AREA_NAME, `Number of Crimes`, `Number of Arrests`, 
 ROUND((`Number of Arrests`/ `Number of Crimes`),2)* 100 AS `Rate of Arrests`
 FROM comm_crime ORDER BY `Rate of Arrests` DESC;
 -- To understand it better, lets look at percentage of arrests in each community
 -- To enhance readability, the output focuses on communities with an arrest rate of 50% or higher.
 -- The communities that can be seen with a high rate of arrest also have crimes below 5. 
-- This trend is evident in areas like East Garfield Park, Uptown, Hegewisch, and other locations with low crime numbers.
-- Notably, Hegewisch recorded only one crime, which resulted in an arrest, making it the community with the lowest crime count and a 100% arrest rate.


-- 14) Communities with most number of arrests
SELECT COMMUNITY_AREA_NAME, `Number of Crimes`, `Number of Arrests`, 
 ROUND((`Number of Arrests`/ `Number of Crimes`),2)* 100 AS `Rate of Arrests`
 FROM comm_crime ORDER BY `Number of Crimes` DESC;
 -- Now, we also look at the trend of arrests in case of communities which have recorded a higher number of crimes
 -- In communities with more than 10 crimes, arrest rates are generally low. 
 -- Near North Side is the exception, standing out as the only community with an arrest rate as high as 50%.
-- * In contrast, other communities with similar crime levels, such as Austin, Humboldt Park, Englewood, and Near West Side, have much lower arrest rates.
-- From previous analysis, we found that these specific communities have a notably higher occurrence of THEFT and NARCOTICS compared to other areas.


 -- 15 view) View which contains Percentage of Arrests per Type of Crime
CREATE VIEW crime_percent AS
(SELECT PRIMARY_TYPE, COUNT(PRIMARY_TYPE) AS `Number of Crimes`, 
SUM(CASE WHEN ARREST = 'TRUE' THEN 1 ELSE 0 END) AS `Number of Arrests`
FROM CRIME GROUP BY PRIMARY_TYPE 
ORDER BY `Number of Crimes` DESC);

-- 15) Types of Crimes with Accoring to Arrest Rate
 SELECT PRIMARY_TYPE, `Number of Crimes`, `Number of Arrests`, ROUND((`Number of Arrests` / `Number of Crimes`) * 100, 2) 
AS `Rate of Arrests` FROM crime_percent ORDER BY `Number of Arrests` DESC;
-- To further explore this connection, we will now examine numbers of arrests made for specific crime types, including theft and narcotics.
-- To understand which types have the best (highest) number of arrest rate
-- The output shows only those types of crimes with more than 1 arrests.
-- We can see that 98% of NARCOTICS-related crimes result in arrests, so a community having NARCOTICS wont lower its arrest rate. .
-- Among crime types with more than 10 incidents, only NARCOTICS and CRIMINAL TRESPASS have notable arrest rates, both exceeding 70%.


-- 16) Arrest Rates Ordered by number of Crimes
SELECT PRIMARY_TYPE, `Number of Crimes`, `Number of Arrests`, ROUND((`Number of Arrests` / `Number of Crimes`) * 100,2 )
AS `Rate of Arrests` FROM crime_percent ORDER BY `Number of Crimes` DESC;
-- In contrast, other crimes of similar frequency, such as 
-- Lets try reordering the output of the previous slide, by the number of crimes committed in each type to understand the arrest rates for the crimes occuring in the highest frequency
-- The output shows the top 10 most types of crimes as per number of reports.  
-- THEFT, CRIMINAL DAMAGE, BURGLARY, and MOTOR VEHICLE THEFT have arrest rates in the range of 0%-11% which is very low given thier crime counts is greater than 20
-- * With THEFT having only 11% rate of arrest even though it is the most frequently occuring type of crime, having a crime count of 100. 


-- 17) Displaying only THEFT high communities 
SELECT CS.COMMUNITY_AREA_NAME, CPT.PRIMARY_TYPE, COUNT(CR.ID) AS `Number of Crimes`
 FROM CENSUS AS CS CROSS JOIN (SELECT DISTINCT PRIMARY_TYPE FROM CRIME) AS CPT LEFT JOIN CRIME AS CR ON 
 CS.COMMUNITY_AREA_NUMBER = CR.COMMUNITY_AREA_NUMBER AND CR.PRIMARY_TYPE = CPT.PRIMARY_TYPE
 WHERE COMMUNITY_AREA_NAME IN ("Austin", "Near West Side", "Englewood", "Humboldt Park")
 GROUP BY CS.COMMUNITY_AREA_NAME, CPT.PRIMARY_TYPE 
 HAVING `Number of Crimes` > 0
 ORDER BY CS.COMMUNITY_AREA_NAME, `Number of Crimes` DESC;
 -- Let’s now focus on the communities where this pattern is most pronounced, showing a disproportionate relationship between crime frequency and arrest rates.
 -- It is clear that Austin, Near West Side, and Humboldt Park consistently report THEFT as their highest-ranking crime.
-- In Austin, THEFT accounts for 30.76% of all reported crimes.
-- Englewood has an even higher proportion, with THEFT making up 38.46% of its total crimes.
-- In Humboldt Park, THEFT constitutes 28.57% of the crimes reported in that community.
-- Near West Side has the highest percentage, with THEFT representing 41.67% of its total crimes.


-- Observations:
-- For these communities their most frequent crime, THEFT has an arrest percentage of 11% 
-- Since THEFT is in such high numbers within these communities with an arrest rate of 11%,
-- it explains why we can see a decline in their overall arrest rate as well.
-- This tells us that the arrest rate of a community is highly influenced by the types of crimes prevelant in that community.


-- CONCLUSION: 
-- The analysis shows that specific community areas have a disproportionately higher number of crime like Austin, especially for THEFT and NARCOTICS. 
-- We could also see that THEFT was the most recorded crime with 100 records and a relatively weak arrest rate of 11%. 
-- This leads to a decline in overall arrest rate for the communities it appears in a higher number.
-- Also such a low arrest rate may be one of the factors contributing to THEFT being repeated in many communities in Chicago at such a high number.
-- Increasing surveillance or policing in these areas along with treating crimes with arrests may help reduce crime rates and improve public safety.


 ----------------------------------------------------- 	Thank You! -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 
 
 
 
 