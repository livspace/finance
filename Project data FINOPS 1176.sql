Select p.id, p.customer_display_name as customer_name, psa.pan_number as Pan_card, psa.name as pan_card_name,
ps.display_name as stage, pe.created_at as stage_change_date, 
p.estimated_value,p.estimated_discount,
case
   when lower(c.display_name) like 'bangalore' then 'Bangalore'
	 when lower(c.display_name) like 'chennai' then 'Chennai' 
	 when lower(c.display_name) in ('delhi') then 'Delhi'
	 when lower(c.display_name) in ('ghaziabad') then 'Ghaziabad'
	 when lower(c.display_name) in ('faridabad') then 'Faridabad'
	 when lower(c.display_name) in ('dwarka') then 'Dwarka'
	 when lower(c.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(c.display_name) like 'hyderabad' then 'Hyderabad'
   when lower(c.display_name) IN  ('mumbai') then 'Mumbai'
	 when lower(c.display_name) like '%thane%' then 'Thane'
	 when lower(c.display_name) like '%navi mumbai%' then 'Navi mumbai'
	 when lower(c.display_name) IN ('noida') then 'Noida'
	 when lower(c.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
   
   bu1.name as Primary_CM,
   bu2.name as Primary_GM,
   bu3.name as Primary_designer  
   

from 
launchpad_backend.projects as p 
left join launchpad_backend.project_stages as ps on ps.id = p.stage_id

left join (select * from launchpad_backend.project_events   
            where event_type = 'STAGE_UPDATED' 
            AND is_deleted = 0 ) as pe on pe.project_id = p.id and pe.new_value = p.stage_id
            
left join launchpad_backend.cities as c on c.id = p.city_id

left join launchpad_backend.project_settings as s on s.project_id = p.id and s.is_deleted = 0 
left join launchpad_backend.bouncer_users as bu1 on bu1.bouncer_id = s.primary_cm_id  
left join launchpad_backend.bouncer_users as bu2 on bu2.bouncer_id = s.primary_GM_id
left join launchpad_backend.bouncer_users as bu3 on bu3.bouncer_id = s.primary_designer_id
left join (select * from livspace_v2.ps_shared_attachment 
			where object_type = 'CUSTOMER') as psa on psa.`object_id` = p.customer_id 

where p.is_test = 0 
and p.status = 'ACTIVE'