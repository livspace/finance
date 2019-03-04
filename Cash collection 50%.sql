
	Select coalesce(C.Managed_city,'Total') as city,
	format(C.`Apr_May_Jun_Q1`,0,'en_IN')  'Apr_May_Jun_Q1',
	format(C.Jul_Aug_Sep_Q2,0,'en_IN') Jul_Aug_Sep_Q2,
	-- format(C.Aug,0,'en_IN') Aug,
	-- format(C.Sep,0,'en_IN') Sep,
	format(C.Oct_Nov_Dec_Q3,0,'en_IN') Oct_Nov_Dec_Q3,
	-- format(C.Oct,0,'en_IN')  Oct,
	-- format(C.Nov,0,'en_IN') Nov,
	-- format(C.Dec,0,'en_IN') 'Dec',
	format(C.Jan,0,'en_IN') 'Jan',
	format(C.Feb,0,'en_IN') 'Feb',
	format(C.Mar,0,'en_IN') 'Mar',
	format(C.Total,0,'en_IN') Total,
	format(C.Mar_projection,0,'en_IN') 'Mar Projection',
	concat(format(((C.Mar_projection - C.Feb)/C.Feb)*100,1,'en_IN'),'%') as 'MOM%'

	from
	(
	SELECT
	B.Managed_city,
	ifnull(sum(case when B.month in(4,5,6) then (B.collected_amount/100000) end),0) as 'Apr_May_Jun_Q1',
	ifnull(sum(case when B.month in (7,8,9) then (B.collected_amount/100000) end),0) as Jul_Aug_Sep_Q2,
	--  ifnull(sum(case when B.month = 8 then (B.collected_amount/100000) end),0) as Aug,
	 -- ifnull(sum(case when B.month = 9 then (B.collected_amount/100000) end),0) as Sep,
	 ifnull(sum(case when B.month in (10,11,12) then (B.collected_amount/100000) end),0) as Oct_Nov_Dec_Q3,
	-- ifnull(sum(case when B.month = 10 then (B.collected_amount/100000) end),0) as 'Oct',
	-- ifnull(sum(case when B.month = 11 then (B.collected_amount/100000) end),0) as 'Nov',
	-- ifnull(sum(case when B.month = 12 then (B.collected_amount/100000) end),0) as 'Dec',
	ifnull(sum(case when B.month = 1 and B.year = 2019 then (B.collected_amount/100000) end),0) as 'Jan',
	ifnull(sum(case when B.month = 2 and B.year = 2019 then (B.collected_amount/100000) end),0) as 'Feb',
	ifnull(sum(case when B.month = 3 and B.year = 2019 then (B.collected_amount/100000) end),0) as 'Mar',
	ifnull(sum((B.collected_amount/100000)),0) as Total,
	ifnull(sum(case when B.month = 3 and B.year = 2019 then ((B.collected_amount)/(day(sysdate())-1)*31)/100000 end ),0) as 'Mar_Projection'

	From 
	(
	SELECT A.* from 
	(
	select 
	pt.id_project,
	case when id_project = 267117 then 'Delhi'
		 when id_project = 271772 then 'Bangalore'
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
	pt.payment_stage,
	pt.pay_method,
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
	and date_format(pt.date_txn,'%Y-%m') >= '2018-04'
	and pt.date_txn < sysdate()
	and pt.id_project   not in ( 25954,30788,	30789,	30790,	262032,	272849,	286720,	18889,	18030,	175093,330301) 

	group by 1,2,3,4,5,6
	) as A

	-- where A.month >= 4
	where A.year >= 2018 

	) as B

	where B.pay_method != 'DISCOUNT_VOUCHER'
	-- and B.payment_stage = 'FIFTY_PERCENT'

	group by 1 with rollup

	) AS C