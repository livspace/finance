select
pro.pid as project_id,
case when pro.fid = 1 then '10%_Stage'
	 when pro.fid = 2 then '50%_stage'
	 when pro.fid = 3 then '100%_stage'
	 else 'stage_unknown' end as stage_type,
ps.customer_display_name  as Customer_Name,
bu.name as DP_Name,
bu1.name as CM_Name,
bu2.name as GM_Name,
case when pro.pid = 288958 then 'Noida'  
     when pro.pid = 168024 then 'Chennai'
     when pro.pid = 3910 then 'Noida'
     when pro.pid = 74312 then 'Bangalore'
     when pro.pid = 78730 then 'Bangalore'
     when pro.pid = 263836 then 'Bangalore'
     when pro.pid = 175599 then 'Chennai'
     when pro.pid = 184809 then 'Mumbai'
     when pro.pid = 249725 then 'Noida'
     when pro.pid = 283496 then 'Delhi'
     when lower(c.display_name) like 'bangalore' then 'Bangalore'
	 when lower(c.display_name) like 'chennai' then 'Chennai' 
	 when lower(c.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(c.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(c.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(c.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(c.display_name) IN ('noida') then 'Noida'
	 when lower(c.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
cast(lc.display_name as DECIMAL(10,0)) as Rating,
month(lr.created_at) as month_of_submission,
year(lr.created_at) as year_of_submission
from (select distinct(dbz.context_id) as pid, dbz.lsf_form_id as fid, max(dbz.batch) 
from launchpad_backend.lsf_responses as dbz
where dbz.question_id = 13 
and dbz.lsf_form_id in (1,2,3)
group by 1,2) as pro
-- Left join to user_profiles to cities to get city name
left join launchpad_backend.projects ps on pro.pid = ps.id 
left join launchpad_backend.cities c on ps.city_id = c.id


left join (select lr.lsf_form_id as fid, lr.context_id, lr.question_id, max(lr.created_at) as created_at
, lr.option_id, max(lr.batch)
from launchpad_backend.lsf_responses lr
group by 1,2,3,5) as lr on pro.pid = lr.context_id 
and lr.question_id = 13
and lr.fid = pro.fid
left join launchpad_backend.lsf_components lc on lc.id = lr.option_id  
 
left join launchpad_backend.project_to_collaborators ptc on pro.pid = ptc.project_id and ptc.is_primary = 1 and ptc.is_deleted = 0
left join launchpad_backend.bouncer_users bu on bu.bouncer_id = ptc.collaborator_id 
-- and bu.tag = 'INTERIOR_DESIGNER'

-- Left join to project_to_collaborators to bouncer_users with COMMUNITY_MANAGER
left join launchpad_backend.project_to_collaborators ptc1 on pro.pid = ptc1.project_id and ptc1.is_primary_cm =1 and ptc1.is_deleted = 0
left join launchpad_backend.bouncer_users bu1 on bu1.bouncer_id = ptc1.collaborator_id 
-- and bu1.tag = 'COMMUNITY_MANAGER'

-- Left join to project_to_collaborators to bouncer_users with GENERAL_MANAGER
left join launchpad_backend.project_to_collaborators ptc2 on pro.pid = ptc2.project_id and ptc2.is_primary_gm =1 and ptc2.is_deleted = 0
left join launchpad_backend.bouncer_users bu2 on bu2.bouncer_id = ptc2.collaborator_id 
-- and bu2.tag = 'GENERAL_MANAGER'

where pro.fid in (1,2,3)
 -- and pro.pid = 297362
and month(lr.created_at) >= 4
and year(lr.created_at) >= 2018
and pro.pid not in (25954,30788,30789,30790,262032,272849,286720,18889,18030,175093)

order by pro.pid asc

