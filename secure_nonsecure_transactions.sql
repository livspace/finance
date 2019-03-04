
select B.project_id, B.customer_display_name, B.city, B.canvas_order, B.`secure/non-secure`,B.po_id, pr.id as payout_request_id, pr.transaction_id, 
pr.status as approval_status,
B.Vendor_company_name,
pr.`date_add` as request_date,
pr.`date_upd` as approval_date,
pr.amount as amount

from 
(
	select p.id as project_id, 
	p.customer_display_name, 
	case
     when p.id = 271772 then 'Bangalore'
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
		 ELSE 'Others' end as city,
		 oo.id as canvas_order ,
		oo.source_entity_id as po_id,
		 oo.created_at as order_date,
		ua.company_name as vendor_company_name,
		 case 
				when oo.cash_order = 1 then 'Non-secure' else 'secure' end as 'secure/non-secure'
			 

	From boq_backend.oms_orders as oo
	left join launchpad_backend.projects as p on p.id = oo.project_id
	left join launchpad_backend.cities as lbc on lbc.id = p.city_id 
	left join boq_backend.user_attributes as ua on ua.bouncer_id = oo.fulfiller_entity_id
	
) as B

left join fms_backend.payout_request as pr
on pr.id_project = B.project_id
and pr.source_type_id = B.canvas_order
and pr.deleted = 0 
