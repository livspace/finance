
select 
pt.id_txn,
pt.id_project,
sum(pt.amount) as collected_amount,
pt.pay_method,
case when pt.status = 4 then 'Approved'
	 when pt.status = 5 then 'Rejected'
	 else 'Pending verification' end as payment_status,
case when id_project = 271772 then 'Bangalore'
     when id_project = 263836 then 'Bangalore'
	 when  id_project = 288958 then 'Noida'  
     when id_project = 168024 then 'Chennai'
     when id_project = 3910 then 'Noida'
     when id_project = 74312 then 'Bangalore'
     when id_project = 78730 then 'Bangalore'
     when id_project = 175599 then 'Chennai'
     when id_project = 184809 then 'Mumbai'
     when id_project = 249725 then 'Noida'
     when id_project = 283496 then 'Delhi'
     when id_project = 233704 then 'Hyderabad'
     when id_project = 263836 then 'Bangalore'
     when id_project = 271772 then 'Bangalore'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as Managed_city,
pt.audit_comment,
pt.`comment`,
fp.customer_display_name,
date_format(pt.`date_add`,'%d-%m-%Y') as `date`,
pt.`date_add`,
pt.date_txn as date_txn,
bu3.email as Primary_designer_email,
bu1.email as Primary_CM_email,
bu2.email as Primary_GM_email, 
fp.pincode as project_pincode,
date_format(pt.date_txn,'%Y-%m') as `Transaction_month`

from livspace_v2.ps_transactions pt
left join launchpad_backend.projects fp on fp.id=pt.id_project
 left join launchpad_backend.cities as lbc on lbc.id = fp.city_id
 left join launchpad_backend.project_settings as s on s.project_id = fp.id and s.is_deleted = 0 
left join launchpad_backend.bouncer_users as bu1 on bu1.bouncer_id = s.primary_cm_id  
left join launchpad_backend.bouncer_users as bu2 on bu2.bouncer_id = s.primary_GM_id
left join launchpad_backend.bouncer_users as bu3 on bu3.bouncer_id = s.primary_designer_id
 
where pt.deleted=0 
and pt.entity_type='CUSTOMER' 
and pt.txn_type='CREDIT'
and lower(pt.pay_method)='discount_voucher' 

and pt.date_txn < sysdate()
and pt.id_project   not in ( 25954,30788,	30789,	30790,	262032,	272849,	286720,	18889,	18030,	175093) 

group by 1,2,4,5,6,7,8,9,10,11,12,13,14,15,16,17

