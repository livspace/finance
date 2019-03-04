select P.ID, case when P.id = 288958 then 'Noida'  
     when P.id = 168024 then 'Chennai'
     when P.id = 3910 then 'Noida'
     when P.id = 74312 then 'Bangalore'
     when P.id = 78730 then 'Bangalore'
     when P.id = 175599 then 'Chennai'
     when P.id = 184809 then 'Mumbai'
     when P.id = 249725 then 'Noida'
     when P.id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city

from launchpad_backend.projects as P 
left join launchpad_backend.cities as lbc on lbc.id = P.city_id