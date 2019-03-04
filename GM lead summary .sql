Select a.gm_name, a.city, a.`year_month`, a.lead_medium_source, count(a.id) as Total_leads,
sum(a.qualified_leads) as qualified_leads, sum(proposal_presented) as proposal_presented,sum(a.converted_leads) as converted_leads,sum(a.effective_leads) as effective_leads
From
(select p.id,
case
     when lower(c.display_name) like 'bangalore' then 'Bangalore'
	 when lower(c.display_name) like 'chennai' then 'Chennai' 
	 when lower(c.display_name) in ('delhi') then 'Delhi'
	  when lower(c.display_name) in ('ghaziabad') then 'Ghaziabad'
	   when lower(c.display_name) in ('faridabad') then 'Faridabad'
	    when lower(c.display_name) in ('dwarka') then 'Dwarka'
	 when lower(c.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(c.display_name) like 'hyderabad' then 'Hyderabad'
   when c.id = 5 and lower(bu2.email) like '%navim%' then 'M_navi'
	 when c.id = 14 and lower(bu2.email) like '%navim%' then 'T_navi'
	 when lower(c.display_name) IN  ('mumbai') then 'Mumbai'
	 when lower(c.display_name) like '%thane%' then 'Thane'
	 when lower(c.display_name) like '%navi mumbai%' then 'Navi mumbai'
	 when lower(c.display_name) IN ('noida') then 'Noida'
	 when lower(c.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
   bu.name,
   bu2.name as gm_name,
   date_format(p.created_at,'%Y-%m') as 'year_month',
case when stage_id = 1 then 1 else 0 end as "unassigned	to Cms",
case when p.lead_source_id in (15,164) then "Direct_referral"
	 when p.lead_source_id in ( 163,162,161) then "Affiliates"
	 else 'online' end as lead_medium_source,
	 case when ps.weight >= 120 then 1 else 0 end as effective_leads,
   case when ps.weight >= 250 then 1 else 0 end as qualified_leads,
   case when ps.weight >= 270 then 1 else 0 end as Proposal_presented,
	 case when ps.weight >= 400 then 1 else 0 end as converted_leads 


From launchpad_backend.projects as p
left join launchpad_backend.cities as c on p.city_id = c.id 
left join launchpad_backend.project_settings as s on s.project_id = p.id and s.is_deleted = 0 
left join launchpad_backend.bouncer_users as bu on bu.bouncer_id = s.primary_cm_id  
left join launchpad_backend.bouncer_users as bu2 on bu2.bouncer_id = s.primary_GM_id
left join launchpad_backend.project_stages as ps on ps.id = p.stage_id

where date_format(p.created_at,'%Y-%m') >= '2018-04'
)
as a

group by 1,2,3,4

order by a.name desc
