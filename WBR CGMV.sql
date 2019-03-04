SELECT A.* from 
(
select 
pt.id_project,
case when  id_project = 288958 then 'Noida'  
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
pt.payment_stage,
pt.pay_method,
week(pt.date_txn) as week,
month(pt.date_txn) as `month`,
year(pt.date_txn) as 'year',
sum(pt.amount) as collected_amount

from livspace_v2.ps_transactions pt
left join launchpad_backend.projects fp on fp.id=pt.id_project
 left join launchpad_backend.cities as lbc on lbc.id = fp.city_id

where pt.deleted=0 
and pt.`status`=4 
and pt.entity_type='CUSTOMER' 
and pt.txn_type='CREDIT'
and pt.pay_method in ('payu','paytm','OTHER','CHEQUE','WIRE_TRANSFER','CARD','DEMAND_DRAFT','Cash','DISCOUNT_VOUCHER','AUTO_BANK_TRANSFER','RAZOR_PAY') 
and pt.deleted=0 
-- and pt.pay_method!='DISCOUNT_VOUCHER' 

and pt.date_txn < sysdate()
and pt.id_project   not in ( 25954,30788,	30789,	30790,	262032,	272849,	286720,	18889,	18030,	175093) 

group by 1,2,3,4,5,6,7
) as A

where A.month >= 4
and A.year >= 2018 
and A.week >= week(sysdate) -1
