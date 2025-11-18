 -->DATA CLEANING PROCESS:
-->Renaming table names: [patients] -> [Hospital_Patients], [staff] -> [Hospital_Staff], [staff_schedules] -> [Hospital_Staff_Schedules], 
					 -- [services_weekly] -> [Hospital_Services_Weekly]
	
-->Updating [Service] data; capitalizing inputs for consistency and easy analysis, e.g. emergency -> Emergency:
UPDATE Hospital_Patients
SET Service =
		CASE
			WHEN Service = 'emergency' THEN 'Emergency'
			WHEN Service = 'general_medicine' THEN 'General Medicine'
			WHEN Service = 'surgery' THEN 'Surgery'
			ELSE Service
		END;

-->Loading updated [Service] column:
SELECT DISTINCT(Service) FROM Hospital_Patients;


-->Updating [Service] & [Event] column of Hopital_Services_Weekly table; capitalizing inputs e.g. emergency -> Emergency & none -> None:
UPDATE Hospital_Services_Weekly
SET Service =
		CASE
			WHEN Service = 'emergency' THEN 'Emergency'
			WHEN Service = 'general_medicine' THEN 'General Medicine'
			WHEN Service = 'surgery' THEN 'Surgery'
			ELSE Service
		END;

UPDATE Hospital_Services_Weekly
SET Event =
			CASE
				WHEN Event = 'none' THEN 'None'
				WHEN Event = 'flu' THEN 'Flu'
				WHEN Event = 'donation' THEN 'Donation'
				WHEN Event = 'strike' THEN 'Strike'
				ELSE Event
			END;

-->Loading updated columns:
SELECT 
	DISTINCT(Service)
FROM Hospital_Services_Weekly;

SELECT 
	DISTINCT(Event)
FROM Hospital_Services_Weekly;


-->DATA OVERVIEW:
-->List of all hospital personnel
SELECT
	staff_id,
	staff_name,
	role,
	service
FROM Hospital_Staff;

--> Records of patients that visited the hospital:
SELECT * FROM Hospital_Patients hp;

-->Weekly operational data for each service:
SELECT * FROM Hospital_Services_Weekly;

--> Weekly attendance records for staff ([Present]: 1 = 'present' and 0 = 'absent'):
SELECT * FROM Hospital_staff_schedule;




--> DATA EXPLORATION:
--Goal: To familiarize myself with the dataset (structures):

-->Total number of staff members employed by the hospital:
SELECT
	COUNT(staff_id) AS Total_Staff
FROM Hospital_Staff;
-->INSIGHT: Total number of 110 staff


-->Distinct job roles present across the hospital staff:
SELECT
	DISTINCT(role) AS Available_Role
FROM Hospital_Staff;
-->INSIGHT: There are three(3) distinct roles; Doctor, Nurse and Nursing Assistant

select * from Hospital_Staff;
select * from Hospital_Patients;
select * from Hospital_Staff_Schedule;
select * from Hospital_Services_Weekly;

-->Total Staff in the Hospital(KPI):
--CREATE VIEW "Total Staff (KPI)" AS
SELECT 
	Count(*) AS "Total Staff"
FROM Hospital_Staff;


-->List of all services and the number of staff in each:
--CREATE VIEW "Number of Staff Across Services" AS
SELECT 
	Service,
	COUNT(staff_id) AS "Total Staff"
FROM Hospital_Staff
GROUP BY Service;
-->INSIGHT: ICU have the highest number of assigned staff (32) while Surgery have the lowest (22)


-->Average Staff Morale Across Services:
--CREATE VIEW "Average Staff Morale" as
SELECT
	Service,
	CAST(AVG(Staff_Morale)AS decimal(10,2)) as "Average Staff Morale"
FROM Hospital_Services_Weekly 
GROUP BY Service
ORDER BY service DESC;



-->All Nursing Assistants assigned to the 'Emergency' service:
SELECT 
	Staff_Name,
	Role
FROM Hospital_Staff
WHERE Service = 'Emergency' AND Role = 'Nursing Assistant';
-->INSIGHT: Five Nursing Assistants were assigned to the Emergency service

-->Staff Distribution by Role:
CREATE VIEW "Staff Role Distribution" AS
SELECT
	Role,
	COUNT(*) AS "Total Staff",
	CAST(COUNT(*) * 100 / (SUM(COUNT(*)) OVER ()) AS decimal(5,2)) AS "Percentage of Staff Distribution"
FROM hospital_staff
GROUP BY ROLE;

-->Calculate each patient's length of stay in days:
SELECT  
    Patient_ID,
	Name,
    Arrival_Date, 
    Departure_Date, 
    DATEDIFF(DAY,arrival_date,departure_date) AS "Length_of_Stay(Day)"
FROM hospital_patients
ORDER BY [Length_of_Stay(Day)] DESC;


-->Maximum and Average length of stay for patients administered to the hospital:
SELECT  
	MAX(DATEDIFF(DAY,arrival_date,departure_date)) AS "Max_Length_of_Stay(Day)",
	MIN(DATEDIFF(DAY,arrival_date,departure_date)) AS "Min_Length_of_Stay(Day)",
    AVG(DATEDIFF(DAY,arrival_date,departure_date)) AS "Average_Length_of_Stay(Day)"
FROM hospital_patients;
-->INSIGHT: Maximum, minimum and average length of stay for patients admitted to the hospital are 14, 1, & 7 respectively


-->Average Patient Stay Per Service:
SELECT
	Service,
	ROUND(AVG(DATEDIFF(DAY, Arrival_Date, Departure_date)), 2) AS Average_Length_Stay
FROM Hospital_Patients
GROUP BY Service
ORDER BY Average_Length_Stay DESC; 
-->INSIGHT: Emergency, Surgery, and ICU recored 7 days as average length of stay admitted in each service. General Medicine recorded 6 days


-->Flag patients with unusually long stays (over 10 days stay):
SELECT  
    Patient_ID,
	Name,
    Arrival_Date, 
    Departure_Date, 
    DATEDIFF(DAY,arrival_date,departure_date) AS "Length_of_Stay(Day)"
FROM hospital_patients
WHERE DATEDIFF(DAY,arrival_date,departure_date) >= 10  
ORDER BY [Length_of_Stay(Day)] DESC;
-->INSIGHT: 337 Patients were found to have stay at the hospital for over 10 days



-->Average Satisfaction Score of Age Group Patients that were served at the hospital:
-->STEP: Create age groups (caps) and calculate the average satisfaction per group:
CREATE VIEW "Age Cap Distribution in the Hospital" AS
SELECT
	CASE
		WHEN Age BETWEEN 0 and 17 THEN '0-17 (Children)'
		WHEN Age BETWEEN 18 and 35 THEN '18-35 (Young Adults)'
		WHEN Age BETWEEN 36 and 55 THEN '36-55 (Adults)'
		WHEN Age BETWEEN 56 and 75 THEN '56-75 (Seniors)'
		ELSE '76+ (Elderly)'
	END AS Age_Group,
	COUNT(*) AS Patient_Count,
	COUNT(*) * 100 / CAST(SUM(COUNT(*)) OVER () AS float) AS Percentage_Total_Patients,
	CAST(AVG(Satisfaction_Score) AS decimal(10,2)) AS Average_Satisfaction_Score
FROM Hospital_Patients
WHERE Satisfaction_Score IS NOT NULL
GROUP BY 
	CASE
		WHEN Age BETWEEN 0 and 17 THEN '0-17 (Children)'
		WHEN Age BETWEEN 18 and 35 THEN '18-35 (Young Adults)'
		WHEN Age BETWEEN 36 and 55 THEN '36-55 (Adults)'
		WHEN Age BETWEEN 56 and 75 THEN '56-75 (Seniors)'
		ELSE '76+ (Elderly)'
	END
ORDER BY Average_Satisfaction_Score DESC;
-->INSIGHT: Children (0-17) felt satisfied with the services provided by the hospital unlike the Seniors and Elderly (major % of Patients that are admitted to the hospital) with a drop in satisfaction score maybe due..


 -->Average patient satisfaction score for every service to identify top and bottom performers:
SELECT 
	Service,
	CAST(AVG(Satisfaction_Score) AS decimal(10,2)) AS Average_Satisfaction_Score
FROM Hospital_Patients hp
GROUP BY Service
ORDER BY Average_Satisfaction_Score DESC;
-->INSIGHT: All four(4) services maintained over 70+ average patient satisfaction score


SELECT * FROM Hospital_Patients;
SELECT * FROM Hospital_Services_Weekly;
SELECT * FROM Hospital_Staff;
SELECT * FROM Hospital_Staff_Schedule;


-->Top 3 Weeks with the highest patient request volume for each individual service:
SELECT 
	Service,
	Week,
	Patients_Request 
	FROM (SELECT Service, Week, Patients_Request,
	ROW_NUMBER() OVER(PARTITION BY Service ORDER BY Patients_Request DESC) AS rn
FROM Hospital_Services_Weekly) AS Ranked_Weeks
WHERE rn <= 3;

-->Correlation between weekly staff morale and the average patient satisfaction for corresponding service:
SELECT
	hsw.Week, 
	hsw.Service,
	hsw.Staff_Morale,
	CAST(AVG(Satisfaction_Score) AS decimal(10,2)) AS Average_Patient_Satisfaction
FROM Hospital_Services_Weekly hsw
JOIN Hospital_Patients hp ON
hsw.Service = hp.Service
GROUP BY hsw.Week, hsw.Service, hsw.Staff_Morale
ORDER BY hsw.Staff_Morale DESC;

-->Joining staff and services data staff info to create a "Workload Summary" table:
SELECT  
	hsw.service Service, 
	hsw.week Week,
	SUM(staff_count) AS Total_Staff, 
	SUM(hsw.Patients_Admitted) AS Total_Admissions, 
ROUND(AVG(Available_Beds), 2) AS Avg_Bed_Utilization 
 FROM Hospital_Services_Weekly hsw 
JOIN ( 
		SELECT 
			service AS Service, 
			COUNT(staff_id) AS staff_count 
		FROM hospital_staff hs
		GROUP BY service) AS staff_summary 
ON hsw.service = staff_summary.service
GROUP BY hsw.service, hsw.week 
ORDER BY hsw.Week ASC;

--Monthly overview of hospital servicess; 
--how many patients were requested, admitted, refused and the available number of beds:
SELECT
	Month,
	Service,
	SUM(Patients_Request) AS Total_Requests,
	SUM(Available_Beds) AS Total_Beds,
	SUM(Patients_Admitted) AS Total_Admissions,
	SUM(Patients_Refused) AS Total_Refusals
FROM Hospital_Services_Weekly
GROUP BY Service, Month
ORDER BY Month, Service;
-->INSIGHTS: Tracked monthly service ultilizzation. Found that in December(12), General Medicine...


SELECT * FROM Hospital_Patients;
SELECT * FROM Hospital_Services_Weekly;
SELECT * FROM Hospital_Staff;
SELECT * FROM Hospital_Staff_Schedule;


-->Patient Flow - admissions and discharges:
SELECT
	DATETRUNC(Week, arrival_date) AS Week_Start,
	COUNT(Patient_ID) AS Total_Admissions,
	sum(CASE WHEN departure_date IS NOT NULL THEN 1 ELSE 0 END) AS Total_Discharges
FROM Hospital_Patients
GROUP BY DATETRUNC(Week, arrival_date)
ORDER BY Week_Start;
-->INSIGHTS: Perfect patient flow with all patients admitted weekly discharged.


-->Weekly Admission trends across all services:
SELECT 
	service,
	DATETRUNC(WEEK,arrival_date) as Week_Start,
	COUNT(patient_id) as Total_Admissions
FROM Hospital_Patients
GROUP BY service, DATETRUNC(WEEK,arrival_date)
ORDER BY Week_Start ASC, Total_Admissions DESC;

--Calculate Capacity Ultilization Rate:
SELECT 
	Service,
	Week,
	CAST(100 * SUM(Patients_Admitted) / NULLIF(SUM(Available_Beds), 0) AS decimal(10,2)) AS Bed_Ultilization_Rate,
	ROUND(100* SUM(Patients_Admitted) / NULLIF(SUM(Patients_Request), 0) ,2) AS Admission_Success_Rate
FROM Hospital_Services_Weekly
GROUP BY Service, Week
ORDER BY Bed_Ultilization_Rate DESC;

--INSIGHT: 

--Identify overloaded services (threshold alert):
SELECT
	Service,
	Week,
	Available_Beds,
	Patients_Admitted,
	CASE
		WHEN Patients_Admitted >= 0.9 * Available_Beds THEN 'Over Capacity'
		ELSE 'Within Capacity'
	END AS Capacity_Status
FROM Hospital_Services_Weekly
ORDER BY Week, Service;
--INSIGHT: Detected steady 'overcapacity' in Emergency and General Services with slight differences in some weeks (e.g. week 18), indicating potential staffing and bed shortage risk. 
--Also, in several weeks ICU and Surgery were noted to be 'within capacity'.


SELECT 
	Service,
	CAST(100 * SUM(Patients_Refused) / NULLIF(SUM(Patients_Request),0)AS decimal(10,2)) AS Refusal_Rate,
	ROUND(AVG(Available_Beds),0) as Average_Beds_Available
FROM Hospital_Services_Weekly
GROUP BY Service
ORDER BY Refusal_Rate DESC;
--INSIGHT: ICU had lowest refusal rate despite lowest bed capacity and General Medicine had moderate refusal rate  despite highest bed capacity...


--Trend Analysis Over Time: how requests, admissions and refusals evolve weekly (Line Chart):
CREATE VIEW "Trend Analysis Over Time" AS
SELECT
	Week,
	SUM(Patients_Request) as Total_Request,
	SUM(Patients_Admitted) as Total_Admitted,
	SUM(Patients_Refused) as Total_Refused
FROM Hospital_Services_Weekly
GROUP BY Week
--ORDER BY Week;


select * from Hospital_Patients;
select * from Hospital_Services_Weekly;
select * from Hospital_Staff;
select * from Hospital_Staff_Schedule;



-->DATA VISUALIZATION:
-->1.OPERATIONS DASHBOARD:
	--Goal: Monitor overall service workload, patient demand, and weekly trends

	/* Weekly Service Summary */
CREATE VIEW Weekly_Service_Summary AS
SELECT
	Service,
	Week,
	SUM(Available_Beds) AS Total_Beds,
	SUM(Patients_Request) AS Total_Patients_Request,
	SUM(Patients_Admitted) as Total_Admissions,
	SUM(Patients_Refused) as Total_Refused
FROM Hospital_Services_Weekly
GROUP BY service, week
--ORDER BY week, service;


	/* Capacity (Beds) Ultilization by Service across weeks */
	--Goal: Calculate the % of available beds that were used. 
CREATE VIEW Capacity_Ultilization_by_Service AS
SELECT 
	Service,
	Week,
	CAST(100 * SUM(Patients_Admitted) / NULLIF(SUM(Available_Beds), 0) AS decimal(10,2)) AS "Bed_Ultilization_Rate(%)"
FROM Hospital_Services_Weekly
GROUP BY Service, Week
--ORDER BY [Bed_Ultilization_Rate(%)] DESC;
--Chart: Line Chart

	/* Refusal Rate by Service*/
	--Goal: Identify where patient requests are most frequently refused. 
CREATE VIEW  Refusal_Rate_by_Service AS
SELECT
	Service,
	ROUND(100 * SUM(patients_refused) / NULLIF(SUM(patients_request),0), 2) AS "Refusal_Rate(%)"
FROM Hospital_Services_Weekly
GROUP BY Service
--ORDER BY [Refusal_Rate(%)] DESC;
--Chart: HeatMap	

	/* Trends: Weekly operations */
	--Goal: Track total patient requests, admissions, and refusals over time. 
SELECT  
	Week, 
	SUM(patients_request) AS Total_Requests, 
	SUM(patients_admitted) AS Total_Admitted, 
	SUM(patients_refused) AS Total_Refused 
FROM hospital_services_weekly 
GROUP BY week 
--ORDER BY week;
--Chart: Line Chart

	/* Services Performance Overview */
	--Goal: Combine multiple operational indicators into one summary. 
CREATE VIEW Services_Performance AS
SELECT  
	Service, 
	SUM(patients_request) AS Total_Requests, 
	SUM(patients_admitted) AS Total_Admitted, 
	SUM(patients_refused) AS Total_Refused,
	ROUND(100* SUM(Patients_Admitted) / NULLIF(SUM(Patients_Request), 0) ,2) AS "Admission_Rate(%)",
	CAST(100 * SUM(Patients_Admitted) / NULLIF(SUM(Available_Beds), 0) AS decimal(10,2)) AS "Bed_Ultilization_Rate(%)"
FROM hospital_services_weekly 
GROUP BY service 
--ORDER BY [Admission_Rate(%)];
--Chart: KPI Cards


-->2.PATIENTS DASHBOARD:
	--Understand patient demographics, satisfaction, and length of stay trends

	/* Average Length of Stay by Service */
CREATE VIEW "Average Length of Stay by Service" AS
SELECT
	Service,
	ROUND(AVG(DATEDIFF(DAY, Arrival_Date, Departure_date)), 2) AS Average_Length_Stay
FROM Hospital_Patients
GROUP BY Service;
--Chart: Bar Chart

	/* Patient Age Distribution */
CREATE VIEW "Age Cap Distribution" AS
SELECT
	CASE
		WHEN Age BETWEEN 0 and 17 THEN '0-17' --(Children)
		WHEN Age BETWEEN 18 and 35 THEN '18-35' --(Young Adults)
		WHEN Age BETWEEN 36 and 55 THEN '36-55' --(Adults)
		WHEN Age BETWEEN 56 and 75 THEN '56-75' --(Seniors)
		ELSE '76+' --(Elderly)
	END AS Age_Group,
	COUNT(*) AS Patient_Count,
	COUNT(*) * 100 / CAST(SUM(COUNT(*)) OVER () AS float) AS Percentage_Total_Patients,
	CAST(AVG(Satisfaction_Score) AS decimal(10,2)) AS Average_Satisfaction_Score
FROM Hospital_Patients
WHERE Satisfaction_Score IS NOT NULL
GROUP BY 
	CASE
		WHEN Age BETWEEN 0 and 17 THEN '0-17'
		WHEN Age BETWEEN 18 and 35 THEN '18-35'
		WHEN Age BETWEEN 36 and 55 THEN '36-55'
		WHEN Age BETWEEN 56 and 75 THEN '56-75'
		ELSE '76+'
	END
--ORDER BY Average_Satisfaction_Score DESC;
--Charts: Pie(Donut) for percentage age distribution & Column Chart for satisfaction score by age group


	/* Relationship between satisfaction and stay length */
CREATE VIEW "Long-Stay Outlier Patients (Top 5%)" AS
WITH StayLength AS ( 
    SELECT  
        patient_id, 
        service, 
        DATEDIFF(day, arrival_date, departure_date) AS stay_days 
    FROM hospital_patients 
), 
Percentile AS ( 
    SELECT  
        PERCENTILE_CONT(0.95)  
        WITHIN GROUP (ORDER BY stay_days)  
        OVER() AS stay_threshold 
    FROM StayLength 
) 
SELECT  
    s.patient_id, 
    s.service, 
s.stay_days 
FROM StayLength s 
CROSS JOIN Percentile p 
WHERE s.stay_days >= p.stay_threshold 
--ORDER BY s.stay_days DESC;
--Chart: Scatter Plot for Relationship between satisfaction and stay length


	/* Satisfaction by Service  */
CREATE VIEW "Satisfaction by Service" AS
SELECT  
	Service, 
	CAST(AVG(satisfaction_score) AS decimal(10,2)) AS Avg_Satisfaction, 
	COUNT(*) AS Total_Patients 
FROM hospital_patients 
GROUP BY service 
--ORDER BY Avg_Satisfaction DESC; 
--Chart: Stacked bar chart



-->3.BED MANAGEMENT DASHBOARD:
	--Goal: Analyze hospital bed usage, turnover, and capacity alerts

	/*  Weekly Bed Availability vs Requests per week */
CREATE VIEW " Weekly Bed Availability vs Requests" AS
SELECT  
	Service, 
	Week, 
	SUM(available_beds) AS Total_Beds, 
	SUM(patients_request) AS Total_Requests 
FROM hospital_services_weekly 
GROUP BY service, week 
--ORDER BY week, service; 
--Chart: Dual-Axis Line Char

	/* Bed Ultilization Over Time */
CREATE VIEW "Bed Ultilization Over Time" AS
SELECT  
	Week, 
	ROUND(100.0 * SUM(patients_admitted) / NULLIF(SUM(available_beds), 0), 2) AS "Bed_Utilization_Rate(%)" 
FROM Hospital_Services_Weekly 
GROUP BY week 
--ORDER BY week; 
--Chart:  Line Chart

	/* Bed Turnover rate by service */
CREATE VIEW "Bed Turnover rate by service" AS
SELECT  
	Service, 
	ROUND(1.0 * SUM(patients_admitted) / NULLIF(SUM(available_beds), 0), 2) AS 
Bed_Turnover_Rate 
FROM Hospital_Services_Weekly 
GROUP BY service 
--ORDER BY Bed_Turnover_Rate DESC;
--Chart: Horizontal Bar Chart for Bed utilization rate by service

	
	/* Overcapacity Alerts */
CREATE VIEW "Overcapacity Alerts" AS
SELECT  
	Service, 
	Week, 
	Available_Beds, 
	Patients_Admitted, 
	CASE  
		WHEN patients_admitted > 0.9 * available_beds THEN 'Over Capacity' 
		ELSE 'Normal' 
	END AS "Capacity_Status" 
FROM Hospital_Services_Weekly 
--ORDER BY week, service; 
--Chart: Conditional Table for Flag overcapacity (>90% utilization)


/*SELECT  
service, 
ROUND(100.0 * SUM(patients_admitted) / NULLIF(SUM(available_beds), 0), 2) AS 
utilization, 
ROUND(100.0 * SUM(patients_refused) / NULLIF(SUM(patients_request), 0), 2) AS 
refusal_rate, 
ROUND((100.0 * SUM(patients_admitted) / NULLIF(SUM(available_beds), 0))  - (100.0 * SUM(patients_refused) / NULLIF(SUM(patients_request), 0)), 2) AS 
bed_efficiency_index 
FROM Hospital_Services_Weekly 
GROUP BY service 
ORDER BY bed_efficiency_index DESC;*/




-->4.KPIs
	--Goal: Present high-level metrics for executives to assess overall hospital efficiency.
	
	/* Admission Rate */
CREATE VIEW "Admission Rate" AS
SELECT  
	ROUND(100.0 * SUM(patients_admitted) / NULLIF(SUM(patients_request), 0), 2) AS "Admission Rate(%)" 
FROM Hospital_Services_Weekly; 

	/* Average Bed Utilization */
CREATE VIEW "Average Bed Utilization" AS
SELECT  
	ROUND(100.0 * SUM(patients_admitted) / NULLIF(SUM(available_beds), 0), 2) AS "Bed Ultilization Rate(%)" 
FROM Hospital_Services_Weekly; 


	/* Average Length of Stay */
CREATE VIEW "Average Length of Stay" AS
SELECT  
	ROUND(AVG(DATEDIFF(day, arrival_date, departure_date)), 2) AS "Average Stay Days"
FROM Hospital_Patients; 


/* Average Satisfaction */
CREATE VIEW "Average Satisfaction" AS
SELECT  
	CAST(AVG(satisfaction_score) AS decimal(10,2)) AS "Average Patient Satisfaction"
FROM hospital_patients 
WHERE satisfaction_score IS NOT NULL;  

	/* Refusal Rate  */
CREATE VIEW "Refusal Rate" AS
SELECT  
	ROUND(100.0 * SUM(patients_refused) / NULLIF(SUM(patients_request), 0), 2) AS "Refusal Rate(%)"
FROM Hospital_Services_Weekly;


	/* Weekly KPI Trends */
CREATE VIEW "Weekly KPI Trends" AS
SELECT  
	Week, 
	ROUND(100.0 * SUM(patients_admitted) / NULLIF(SUM(patients_request), 0), 2) AS Admission_Rate, 
	ROUND(100.0 * SUM(patients_admitted) / NULLIF(SUM(available_beds), 0), 2) AS Bed_Utilization_Rate, 
	ROUND(100.0 * SUM(patients_refused) / NULLIF(SUM(patients_request), 0), 2) AS Refusal_Rate 
FROM Hospital_Services_Weekly 
GROUP BY week 
--ORDER BY week; 