 Select B.*,cast((datediff/30) as DECIMAL(10,1)) AS TAT
 From (
 select A.project_id,A.city,A.created_month,A.created_year,A.created_date,month(A.converted_date) as converted_month, year(A.converted_date) as converted_year,A.converted_date,
 datediff(A.converted_date,A.created_date) as datediff
from 
 (
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
month(p.created_at) as created_month,
year(p.created_at) as created_year,
 p.created_at as created_date,
 -- p.created_at as created_year,
 coalesce( pa.created_at, pb.created_at, pc.created_at, pd.created_at, pe.created_at, pf.created_at, pg.created_at, ph.created_at, pi.created_at) as Converted_date
 -- coalesce(year(pa.created_at),year(pb.created_at),year(pc.created_at),year(pd.created_at),year(pe.created_at),year(pf.created_at),year(pg.created_at),year(ph.created_at),year(pi.created_at)) as Converted_year
 
 from launchpad_backend.projects as p
 left join launchpad_backend.cities as lbc on lbc.id = p.city_id
 left join launchpad_backend.project_stages as ps on p.stage_id = ps.id
 
  left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(3) 
group by 1 )
as pa on pa.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(4) 
group by 1 )
as pb on pb.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(7) 
group by 1 )
as pc on pc.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(5) 
group by 1 )
as pd on pd.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(14) 
group by 1 )
as pe on pe.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(6) 
group by 1 )
as pf on pf.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(15) 
group by 1 )
as pg on pg.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(16) 
group by 1 )
as ph on ph.project_id = p.id


 left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(10) 
group by 1 )
as pi on pi.project_id = p.id

 
 where month(p.created_at) >= 4 
 and year(p.created_at) >= 2018
 and p.id not in ( 25954,30788,	30789,	30790,	262032,	272849,	286720,	18889,	18030,	175093)
 and p.is_test = 0 
 and ps.weight >= 300
 
 ) as A
 
 ) as B