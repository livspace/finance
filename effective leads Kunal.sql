Select year_month(created_at) as year_month, count(id) as total_leads, sum(effective_leads) as Effective_leads
From 
(
Select lbp.id,
lbp.created_at,
 bu.name, 
 lbc.display_name,
lbp.lead_medium_id,
lbp.lead_source_id,
count(BR.project_id) as effective_lead,
count(bd.project_id) as Qualified_lead,
BR.created_at as Effective_date,
count(db.project_id) as Proposal_Presented,
nullif(Count(rs.project_id),0) as DIP,
rs.created_at as conversion_month,
Nullif(count(ra.project_id),0) as DIP1, 
ra.created_at as conversion_month1,
Nullif(count(rb.project_id),0) as DIP2,
rb.created_at as conversion_month2,
Nullif(count(rc.project_id),0) as DIP3,
rc.created_at as conversion_month3,

case when lbp.id = 271772 then 'Bangalore'
	 when lbp.id = 263836 then 'Bangalore'
	 when lbp.id = 288958 then 'Noida'  
     when lbp.id = 168024 then 'Chennai'
     when lbp.id = 3910 then 'Noida'
     when lbp.id = 74312 then 'Bangalore'
     when lbp.id = 78730 then 'Bangalore'
     when lbp.id = 175599 then 'Chennai'
     when lbp.id = 184809 then 'Mumbai'
     when lbp.id = 249725 then 'Noida'
     when lbp.id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city


from launchpad_backend.projects as lbp
left join launchpad_backend.project_settings as lbps on lbps.project_id = lbp.id
left join launchpad_backend.bouncer_users bu on bu.bouncer_id = lbps.primary_gm_id
left join launchpad_backend.cities as lbc on lbc.id = lbp.city_id
-- left join launchpad_backend.ps_customer_leads as lbpcl on lbpcl.project_id = lbp.id 



-- Effective leads
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value = 17
group by 1 )
as BR on BR.project_id = lbp.id

-- Qualified_lead
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value = 9
group by 1 )
as bd on bd.project_id = lbp.id

-- Proposal presented

left join 
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value = 21
group by 1 )
as db on db.project_id = lbp.id

-- Conversion
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (4) 
group by 1 ) 
as rs on rs.project_id = lbp.id

-- Awaiting 50%
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (7) 
group by 1 )
as ra on ra.project_id = lbp.id

-- POC
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (5) 
group by 1 )
as rb on rb.project_id = lbp.id

-- FOC
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (14) 
group by 1 )
as rc on rc.project_id = lbp.id

where lbp.is_test = 0
and year(lbp.created_at) >= 2018
 and month(lbp.created_at) >=4
-- and month(lbp.created_at) < 12

group by 1,2,3,4,5,6,9,12,14,16,18,19
)

Group by 1 