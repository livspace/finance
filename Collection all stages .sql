select 
pt.id_project,
case when pt.project_id = 288958 then 'Noida'  
     when pt.project_id = 168024 then 'Chennai'
     when pt.project_id = 3910 then 'Noida'
     when pt.project_id = 74312 then 'Bangalore'
     when pt.project_id = 78730 then 'Bangalore'
     when pt.project_id = 175599 then 'Chennai'
     when pt.project_id = 184809 then 'Mumbai'
     when pt.project_id = 249725 then 'Noida'
     when pt.project_id = 283496 then 'Delhi'
     when lower(C.display_name) like 'bangalore' then 'Bangalore'
	 when lower(C.display_name) like 'chennai' then 'Chennai' 
	 when lower(C.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(C.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(C.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(C.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(C.display_name) IN ('noida') then 'Noida'
	 when lower(C.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
fp.general_manager,fp.project_designer, fp.design_manager ,DATE_FORMAT(pt.date_txn, '%Y, %M') as `month`,
SUM(CASE WHEN pt.payment_stage IN ('TEN_PERCENT', 'PRE_TEN_PERCENT') AND pt.pay_method!='DISCOUNT_VOUCHER' THEN pt.amount else 0.0 END ) AS ten_percent_collection,
SUM(CASE WHEN pt.payment_stage IN ('FIFTY_PERCENT') AND pt.pay_method!='DISCOUNT_VOUCHER' THEN pt.amount else 0.0 END ) AS fifty_percent_collection,
SUM(CASE WHEN pt.payment_stage IN ('FULL' )  AND pt.pay_method!='DISCOUNT_VOUCHER' THEN pt.amount else 0.0 END ) AS full_collection,
sum(case when pt.txn_type = 'DEBIT' AND pt.PAY_METHOD =  'CUSTOMER_REFUND' THEN pt.amount else 0 end) as refunds,
SUM(CASE WHEN pt.payment_stage IS NULL THEN pt.amount else 0.0 END ) AS unknown_collection,
SUM(CASE WHEN pt.pay_method!='DISCOUNT_VOUCHER' THEN pt.amount else 0.0 END) AS total_cash_collections,
SUM(CASE WHEN pt.pay_method='DISCOUNT_VOUCHER' THEN pt.amount else 0.0 END ) AS discount_voucher

from livspace_v2.ps_transactions pt
left join livspace_reports2.flat_projects fp on fp.project_id=pt.id_project
left join launchpad_backend.projects P on fp.project_id = P.id
left join launchpad_backend.cities as C on C.id = P.city_id
where pt.deleted=0 and pt.`status`=4 and pt.entity_type='CUSTOMER' and pt.txn_type='CREDIT'
and pt.pay_method in ('payu','paytm','OTHER','CHEQUE','WIRE_TRANSFER','CARD','DEMAND_DRAFT','Cash','DISCOUNT_VOUCHER','AUTO_BANK_TRANSFER','RAZOR_PAY') and pt.deleted=0 
and month(pt.date_txn) >= 4 
and year(pt.date_txn) >= 2018
group by pt.id_project, fp.parent_city,fp.general_manager,fp.project_designer, fp.design_manager, DATE_FORMAT(pt.date_txn, '%Y, %M')
order by pt.date_txn desc;

