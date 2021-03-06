

select 
	gmv.`project_id` as project_id,
case 
	 when gmv.project_id = 271772 then 'Bangalore'
	 when gmv.project_id = 263836 then 'Bangalore'
	 when gmv.project_id = 288958 then 'Noida'  
     when gmv.project_id = 168024 then 'Chennai'
     when gmv.project_id = 3910 then 'Noida'
     when gmv.project_id = 74312 then 'Bangalore'
     when gmv.project_id = 78730 then 'Bangalore'
     when gmv.project_id = 175599 then 'Chennai'
     when gmv.project_id = 184809 then 'Mumbai'
     when gmv.project_id = 249725 then 'Noida'
     when gmv.project_id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as Managed_city,
	pr.`customer_display_name` as customer_name,
	bu1.name as primary_cm,
	bu2.name as primary_gm,
	bu3.name as primary_gm,
	date_format(gmv.`added_at`,'%Y-%m') as gmv_month,
	gmv.`amount` as booking_gmv_amount
		
from
	`launchpad_backend`.`project_gmv_ledger` gmv	
left join
	`livspace_reports2`.`flat_projects` pr on gmv.`project_id`=pr.`project_id`
left join 
	 launchpad_backend.projects as p on p.id = pr.project_id and p.is_test = 0
left join   
	 launchpad_backend.cities as lbc on lbc.id = p.city_id 

left join 
(
select ps.Project_id, bu.name, bu.email
from launchpad_backend.project_settings as ps 
left join launchpad_backend.bouncer_users as bu on bu.bouncer_id = ps.primary_cm_id
where ps.is_deleted = 0 
) as bu1 on bu1.project_id = gmv.project_id

left join 
(
select ps.Project_id, bu.name, bu.email
from launchpad_backend.project_settings as ps 
left join launchpad_backend.bouncer_users as bu on bu.bouncer_id = ps.primary_gm_id
where ps.is_deleted = 0 
) as bu2 on bu2.project_id = gmv.project_id

left join 
(
select ps.Project_id, bu.name, bu.email
from launchpad_backend.project_settings as ps 
left join launchpad_backend.bouncer_users as bu on bu.bouncer_id = ps.primary_designer_id
where ps.is_deleted = 0 
) as bu3 on bu3.project_id = gmv.project_id