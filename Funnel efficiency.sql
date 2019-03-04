 Select p.id as project_id,
 case when p.id = 263836 then 'Bangalore'
	 when p.id = 288958 then 'Noida'  
     when p.id = 168024 then 'Chennai'
     when p.id = 3910 then 'Noida'
     when p.id = 74312 then 'Bangalore'
     when p.id = 78730 then 'Bangalore'
     when p.id = 175599 then 'Chennai'
     when p.id = 184809 then 'Mumbai'
     when p.id = 249725 then 'Noida'
     when p.id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
	 
 month(p.created_at) as created_month, case when ps.weight >110 then 1 else 0 end as EL,
 case when ps.weight >= 200 then 1 else 0 end as BD,
 case when ps.weight >= 265 then 1 else 0 end as PS,
 case when ps.weight >= 300 then 1 else 0 end as converted
 from launchpad_backend.projects as p
 left join launchpad_backend.cities as lbc on lbc.id = p.city_id
 left join launchpad_backend.project_stages as ps on ps.id = p.stage_id  
 where month(p.created_at) >= 4 
 and year(p.created_at) >= 2018
 and (p.lead_medium_id = 165 or p.lead_medium_id is NULL)
--  and p.lead_medium_id not in (15,17,18)
 and p.id not in ( 25954,30788,	30789,	30790,	262032,	272849,	286720,	18889,	18030,	175093)
 and p.is_test = 0 