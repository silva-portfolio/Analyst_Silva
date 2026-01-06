select * from crime_scene_report;
select * from drivers_license;
select * from facebook_event_checkin;
select * from get_fit_now_check_in;
select * from get_fit_now_member;
select * from income;
select * from interview;
select * from person;
select * from solution;


-->Retrieving the corresponding data from the crime scence_report data using the date, type & location of the crime:
select * 
from crime_scene_report
where type = 'murder' and date = '20180115' and city = 'SQL City';
--INSIGHTS: Two witnesses were recorded and described; 1 unnamed witness lives at the last house on 'Northernwestern Dr.' and 
			--witness 2 named 'Annabel' who resides near 'Franklin Ave'.



-->LOCATING THE 2 WITNESSES DESCRIBED;
--[W1]: Annabel & address = Franklin Ave
--[W2]: ... & address = Last house near Northwestern Dr
select * from person
where name like '%Annabel%' and address_street_name = 'Franklin Ave'
order by name asc;
--INSIGHT: W1 Annabel Miller with license id = 490173, address no. = 103 & ssn = 318771143

select * from person 
where address_street_name like '%Northwestern Dr%'
order by address_number desc;
--INSIGHT: W2 Morty Schapiro with license id = 118009, address no. = 4919 and ssn = 111564949     


-->REVIEWING INTERVIEWS OF 'Annabel' & 'Morty'

select * from interview
where person_id in (16371, 14887);

--INSIGHT: [W1]; I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". 
				--Only gold members have those bags. The man got into a car with a plate that included "H42W".
		 --[W2]; I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.


--Using crues from the witnesses interviews to identify the suspect (man);

select * from get_fit_now_member
where id like '%48Z%' and membership_status = 'gold';

--INSIGHT: 2 male suspects were identified to match the crues; Joe Germuska [person_id = 28819] with msd on 20160305 & 
		-- Jeremy Bowers [person_id = 67318] with msd on 20160101


select * from get_fit_now_check_in
where membership_id like '%48Z%'
--check_in_date like '%019%';

--INSIGHT: Both suspects Joe [48Z7A]  and Jeremy [48Z55] visited the gym on '20180109'. 
		-- Joe [48Z7A] checked in arround 16:00 & checked out 17:30 (1 hr 30 mins interval).
		-- Jeremy [48Z55] checked in arround 15:30 & checked out 17:00 (1 hr 30 mins interval).

--checking lead on a suspect with silver membership status
select * from get_fit_now_member
where id = '48Z38';

--verifying related gender (male) & car plate no. of the 2 suspects;
select * from drivers_license
where gender = 'male' and plate_number like '%H42W%';

--matching IDs from drivers_license id with license_id from the person table to identify the murderer
select * from person
where license_id in (423327, 664760);
--INSIGHT: Jeremy Bowers matched all crues recorded making him the potential murderer.

--further verification from the gym
select * from get_fit_now_member
where person_id in (51739, 67318);
-- showed that Jeremy Bowers is the murderer.

-->RECORDING SOLVED CASE IN THE solution table;
INSERT INTO solution VALUES (1, 'Jeremy Bowers'); 
SELECT * FROM solution;


--> REVIEWING THE MURDERER INTERVIEW;
select * from interview
where person_id = 67318;
--I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
--She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017. 

--using crues from the murderer interview to find match described female from drivers_license table 
select * from drivers_license
where height between 65 and 67 
	and gender = 'female' 
	and hair_color = 'red'
	and car_make = 'Tesla' 
	and car_model = 'Model S'
--INSIGHT: 68, 65, & 48 yr old female suspects with id = 202298, 291182, & 918773 and plate_no. = 500123, 08CM64, & 917UU3 respectively.


--using the license_ids to identify the person_ids;
select * from person
where license_id = 202298 
	or license_id = 291182
	or license_id = 918773;



select * from income;

select * from facebook_event_checkin fc
where  person_id = 78881 or person_id = 90700 or person_id = 99716 
	and event_name = 'SQL Symphony Concert' 
	and date between 20171201 and 20171231;
--INSIGHT: person_id = 99716 recorded to have visited the SQL Symphony Concert three times in Dec 2017


--identifying the name of the real vallain with person_id = 99716;
select * from person
where id = 99716;
--INSIGHT: Miranda Priestly with ssn = 987756388 identified as the female vallain who hired our murderer

--further investigation into the income of Miranda Priestly (ssn = 987756388);
select * from income --order by annual_income desc;
where ssn = 987756388;
--INSIGHT: Miranda Priestly  have annual income of $310,000 matching what our said '...hired by a woman with a lot of money'.

INSERT INTO solution VALUES (1, 'Miranda Priestly');
SELECT value FROM solution;



