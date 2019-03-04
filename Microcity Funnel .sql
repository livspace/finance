Select lbp.id,
lbp.pincode,
lbp.created_at,
 bu.name, 
 lbc.display_name,
-- lbpcl.`scope`,
lbp.lead_medium_id,
lbp.lead_source_id,
count(BR.project_id) as effective_lead,
count(bd.project_id) as Qualified_lead,
count(db.project_id) as Proposal_Presented,
nullif(Count(rs.project_id),0) as DIP,
rs.created_at as conversion_month,
Nullif(count(ra.project_id),0) as DIP1, 
ra.created_at as conversion_month1,
Nullif(count(rb.project_id),0) as DIP2,
rb.created_at as conversion_month2,
Nullif(count(rc.project_id),0) as DIP3,
rc.created_at as conversion_month3



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
 and month(lbp.created_at) >=7
-- and month(lbp.created_at) < 12

group by 1,2,3,4,5,6,7,12,14,16,18