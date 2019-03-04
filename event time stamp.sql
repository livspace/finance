SELECT A.*
from 
(
Select p.id as project_id, 
case when p.id = 271772 then 'Bangalore'
                when p.id = 263836 then 'Bangalore'
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
                ELSE 'Others' end as Managed_city,
                p.created_at as lead_creation_date,
                ps.created_at as effective_date,
                pz.created_at as prospective_date,
                bd.created_at as briefing_done_date,
                pp.created_at as proposal_presented_date,
                ic.created_at as 'conversion1_date',
                rs.created_at as 'conversion2_date',
                ra.created_at as 'conversion3_date',
                rb.created_at as 'conversion4_date',
                rc.created_at as 'conversion5_date',
                PCM.Primary_CM,
                PGM.primary_gm,
                PDP.primary_dp
                
                 

from launchpad_backend.projects as p 
left join launchpad_backend.cities as lbc on lbc.id = p.city_id
left join (
select project_id, primary_cm_id , bu.name as Primary_CM
                                                                From launchpad_backend.project_settings  as ps 
                                                                left join launchpad_backend.bouncer_users as bu on ps.primary_cm_id = bu.bouncer_id
                                                                        where ps.is_deleted = 0 
        ) as PCM on PCM.project_id = p.id
        
  
 left join (
select project_id, primary_GM_id , bu.name as Primary_GM
                                                                From launchpad_backend.project_settings  as ps 
                                                                left join launchpad_backend.bouncer_users as bu on ps.primary_gm_id = bu.bouncer_id
                                                                        where ps.is_deleted = 0 
        ) as PGM on PGM.project_id = p.id
        
  left join (
select project_id, primary_GM_id , bu.name as Primary_DP
                                                                From launchpad_backend.project_settings  as ps 
                                                                left join launchpad_backend.bouncer_users as bu on ps.primary_designer_id = bu.bouncer_id
                                                                        where ps.is_deleted = 0 
        ) as PDP on PDP.project_id = p.id
                                
-- Effective lead (GM Assigned)
left join( 
select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps 
where event_type in ('STAGE_UPDATED')
AND new_value = 17
group by 1 )
as ps on ps.project_id = p.id

-- Prospective lead
left join( 
select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps 
where event_type in ('STAGE_UPDATED')
AND new_value = 13
group by 1 )
as pz on pz.project_id = p.id

-- briefing done
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value = 9
group by 1 )
as bd on bd.project_id = p.id

-- Proposal created (pitch sent)
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(19) 
group by 1 )
as pp on pp.project_id = p.id

-- 10% proposal WIP (pitch sent)
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(11) 
group by 1 )
as pa on pa.project_id = p.id

-- proposal ready (pitch sent)
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(20) 
group by 1 )
as pb on pb.project_id = p.id

-- proposal presented (pitch sent)
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in(21) 
group by 1 )
as pc on pc.project_id = p.id

-- 10% collected
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (3) 
group by 1 ) 
as ic on ic.project_id = p.id

-- order confirmation or lead conversion (DIP)
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (4) 
group by 1 ) 
as rs on rs.project_id = p.id


-- Awaiting 50%
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (7) 
group by 1 )
as ra on ra.project_id = p.id

-- POC
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (5) 
group by 1 )
as rb on rb.project_id = p.id

-- FOC
left join
( select distinct ps.project_id, min(ps.created_at) as created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value in (14) 
group by 1 )
as rc on rc.project_id = p.id
) as A

where date_format(coalesce(A.conversion1_date,A.conversion2_date,A.conversion3_date,A.conversion4_date,A.conversion5_date),'%Y-%d') >= '2018-01'
