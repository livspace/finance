
Select coalesce(C.Managed_city,'Total') as Managed_city,
format(C.Apr,0,'en_IN')  Apr,
format(C.May,0,'en_IN') May,
format(C.Jun,0,'en_IN') Jun,
format(C.Jul,0,'en_IN') Jul,
format(C.Aug,0,'en_IN') Aug,
format(C.Sep,0,'en_IN') Sep,
format(C.Oct,0,'en_IN')  Oct,
format(C.Nov,0,'en_IN') Nov,
format(C.Total,0,'en_IN') Total
from
(
SELECT
B.Managed_city,
ifnull(sum(case when B.month = 4 then B.gmv end),0) as Apr,
ifnull(sum(case when B.month = 5 then B.gmv end),0) as May,
ifnull(sum(case when B.month = 6 then B.gmv end),0) as Jun,
ifnull(sum(case when B.month = 7 then B.gmv end),0) as Jul,
ifnull(sum(case when B.month = 8 then B.gmv end),0) as Aug,
ifnull(sum(case when B.month = 9 then B.gmv end),0) as Sep,
ifnull(sum(case when B.month = 10 then B.gmv end),0) as 'Oct',
ifnull(sum(case when B.month = 11 then B.gmv end),0) as 'Nov',
ifnull(sum(B.gmv),0) as Total
from
(
Select A.*
From (
select 
year(order_created_at) as 'Year',
month(order_created_at) as 'month',
project_id,
case when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as Managed_city,
	 
vmbo.order_state,
format(sum(ifnull(order_products_wt,0)/1.145), 2, 'en_IN') Revenue,
format(sum(ifnull(order_discount,0)), 2, 'en_IN') Discounts, 
format(sum(ifnull(order_products_wt,0)), 2, 'en_IN') 'Amount With Tax',
sum(ifnull(vmbo.order_handling_fee,0)) as 'order handling fees',
sum(ifnull(order_products_wt,0) + ifnull(order_handling_fee,0)) GMV,
sum( coalesce(vmbo.order_handling_fee,0) + coalesce(vmbo.order_products_wt,0) - coalesce(vmbo.order_discount,0)) as 'Net Order Value'


 from livspace_reports2.flat_orders as vmbo
 left join launchpad_backend.projects as lbp on vmbo.project_id = lbp.id
 left join launchpad_backend.cities as lbc on lbc.id = lbp.city_id
 
 where order_created_at > '2016-04-01'
 and order_created_at < sysdate()
 
 -- removing migrated orders from February to March 
and vmbo.id_order not in (1803210096,1803210159,1803210109,1803210083,1803210110,1803210169,1803210221,1803210196,1803210227,1803210205,1803210117,1803210139,1803210113,1803210153,1803210154,1803210224,1803210091,
1803210092,1803210093,1803210095,1803210098,1803210210,1803210107,1803210215,1803210194,1803210202,1803210203,1803210229,1803210207,1803210212,1803210213,1803210088,1803210108,1803210143,1803210178,1803210176,
1803210177,1803210184,1803210191,1803210180,1803210200,1803210085,1803210100,1803210208,1803210209,1803210105,1803210115,1803210211,1803210129,1803210130,1803210156,1803210163,1803210164,1803210219,1803210171,
1803210187,1803210195,1803210198,1803210094,1803210119,1803210166,1803210111,1803210116,1803210142,1803210150,1803210157,1803210172,1803210226,1803210145,1803210161,1803210183,1803210185,1803210186,1803210188,
1803210190,1803210147,1803210149,1803210182,1803210197,1803210087,1803210102,1803210103,1803210204,1803210089,1803210155,1803210168,1803210174,1803210123,1803210124,1803210125,1803210126,1803210127,1803210128,
1803210199,1803210106,1803210138,1803210104,1803210220,1803210084,1803210158,1803210120,1803210167,1803210189,1803210193,1803210090,1803210097,1803210118,1803210160,1803210165,1803210192,1803210082,1803210099,
1803210179,1803210225,1803210101,1803210086,1803210114,1803210131,1803210132,1803210140,1803210146,1803210216,1803210217,1803210175,1803210133,1803210170,1803210201,1803210206,1803210162,1803210222,1803210121,
1803210148,1803210151,1803210152,1803210218,1803210112,1803210122,1803210214,1803210141,1803210173,1803210223,1803210181,1803210134,1803210135,1803210136,1803210137,1803210144,1803210228)
--  end
and vmbo.project_id not in ( 18030, 25954, 30788, 30789, 30790, 18889 ) 
and vmbo.order_state not in ('Cancelled', 'Blocked') 

group by 1,2,3,4,5



) as A

where A.year >= 2018
and A.month >= 4

) as B

group by 1 with rollup 
) as C 
 
 
								Union ALL -- Total Cash collection 
 
 
Select ifnull(C.Managed_city,'Total') as Managed_city,
format(C.Apr,0,'en_IN')  Apr,
format(C.May,0,'en_IN') May,
format(C.Jun,0,'en_IN') Jun,
format(C.Jul,0,'en_IN') Jul,
format(C.Aug,0,'en_IN') Aug,
format(C.Sep,0,'en_IN') Sep,
format(C.Oct,0,'en_IN')  Oct,
format(C.Nov,0,'en_IN') Nov,
format(C.Total,0,'en_IN') Total
from
(
SELECT
B.Managed_city,
ifnull(sum(case when B.month = 4 then B.collected_amount end),0) as Apr,
ifnull(sum(case when B.month = 5 then B.collected_amount end),0) as May,
ifnull(sum(case when B.month = 6 then B.collected_amount end),0) as Jun,
ifnull(sum(case when B.month = 7 then B.collected_amount end),0) as Jul,
ifnull(sum(case when B.month = 8 then B.collected_amount end),0) as Aug,
ifnull(sum(case when B.month = 9 then B.collected_amount end),0) as Sep,
ifnull(sum(case when B.month = 10 then B.collected_amount end),0) as 'Oct',
ifnull(sum(case when B.month = 11 then B.collected_amount end),0) as 'Nov',
ifnull(sum(B.collected_amount),0) as Total
From 
(
SELECT A.* from 
(
select 
pt.id_project,
case when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
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
and pt.date_txn <= sysdate()-1

group by 1,2,3,4,5,6
) as A

where A.month >= 4
and A.year >= 2018 

) as B

where B.pay_method != 'DISCOUNT_VOUCHER'

group by 1 with rollup

) AS C
 
								Union All -- Full cash collection 
 
 
Select ifnull(C.Managed_city,'Total') as Managed_city,
format(C.Apr,0,'en_IN')  Apr,
format(C.May,0,'en_IN') May,
format(C.Jun,0,'en_IN') Jun,
format(C.Jul,0,'en_IN') Jul,
format(C.Aug,0,'en_IN') Aug,
format(C.Sep,0,'en_IN') Sep,
format(C.Oct,0,'en_IN')  Oct,
format(C.Nov,0,'en_IN') Nov,
format(C.Total,0,'en_IN') Total
from
(
SELECT
B.Managed_city,
ifnull(sum(case when B.month = 4 then B.collected_amount end),0) as Apr,
ifnull(sum(case when B.month = 5 then B.collected_amount end),0) as May,
ifnull(sum(case when B.month = 6 then B.collected_amount end),0) as Jun,
ifnull(sum(case when B.month = 7 then B.collected_amount end),0) as Jul,
ifnull(sum(case when B.month = 8 then B.collected_amount end),0) as Aug,
ifnull(sum(case when B.month = 9 then B.collected_amount end),0) as Sep,
ifnull(sum(case when B.month = 10 then B.collected_amount end),0) as 'Oct',
ifnull(sum(case when B.month = 11 then B.collected_amount end),0) as 'Nov',
ifnull(sum(B.collected_amount),0) as Total
From 
(
SELECT A.* from 
(
select 
pt.id_project,
case when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
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
and pt.date_txn <= sysdate()-1

group by 1,2,3,4,5,6
) as A

where A.month >= 4
and A.year >= 2018 

) as B

where B.pay_method != 'DISCOUNT_VOUCHER'
and B.payment_stage IN ('FULL' )

group by 1 with rollup

) AS C

									Union All -- 50% cash collection 


Select ifnull(C.Managed_city,'Total') as Managed_city,
format(C.Apr,0,'en_IN')  Apr,
format(C.May,0,'en_IN') May,
format(C.Jun,0,'en_IN') Jun,
format(C.Jul,0,'en_IN') Jul,
format(C.Aug,0,'en_IN') Aug,
format(C.Sep,0,'en_IN') Sep,
format(C.Oct,0,'en_IN')  Oct,
format(C.Nov,0,'en_IN') Nov,
format(C.Total,0,'en_IN') Total
from
(
SELECT
B.Managed_city,
ifnull(sum(case when B.month = 4 then B.collected_amount end),0) as Apr,
ifnull(sum(case when B.month = 5 then B.collected_amount end),0) as May,
ifnull(sum(case when B.month = 6 then B.collected_amount end),0) as Jun,
ifnull(sum(case when B.month = 7 then B.collected_amount end),0) as Jul,
ifnull(sum(case when B.month = 8 then B.collected_amount end),0) as Aug,
ifnull(sum(case when B.month = 9 then B.collected_amount end),0) as Sep,
ifnull(sum(case when B.month = 10 then B.collected_amount end),0) as 'Oct',
ifnull(sum(case when B.month = 11 then B.collected_amount end),0) as 'Nov',
ifnull(sum(B.collected_amount),0) as Total
From 
(
SELECT A.* from 
(
select 
pt.id_project,
case when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
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
and pt.date_txn <= sysdate()-1

group by 1,2,3,4,5,6
) as A

where A.month >= 4
and A.year >= 2018 

) as B

where B.pay_method != 'DISCOUNT_VOUCHER'
and B.payment_stage = 'FIFTY_PERCENT'

group by 1 with rollup

) AS C

									Union All -- 10% cash collection 


Select ifnull(C.Managed_city,'Total') as Managed_city,
format(C.Apr,0,'en_IN')  Apr,
format(C.May,0,'en_IN') May,
format(C.Jun,0,'en_IN') Jun,
format(C.Jul,0,'en_IN') Jul,
format(C.Aug,0,'en_IN') Aug,
format(C.Sep,0,'en_IN') Sep,
format(C.Oct,0,'en_IN')  Oct,
format(C.Nov,0,'en_IN') Nov,
format(C.Total,0,'en_IN') Total
from
(
SELECT
B.Managed_city,
ifnull(sum(case when B.month = 4 then B.collected_amount end),0) as Apr,
ifnull(sum(case when B.month = 5 then B.collected_amount end),0) as May,
ifnull(sum(case when B.month = 6 then B.collected_amount end),0) as Jun,
ifnull(sum(case when B.month = 7 then B.collected_amount end),0) as Jul,
ifnull(sum(case when B.month = 8 then B.collected_amount end),0) as Aug,
ifnull(sum(case when B.month = 9 then B.collected_amount end),0) as Sep,
ifnull(sum(case when B.month = 10 then B.collected_amount end),0) as 'Oct',
ifnull(sum(case when B.month = 11 then B.collected_amount end),0) as 'Nov',
ifnull(sum(B.collected_amount),0) as Total
From 
(
SELECT A.* from 
(
select 
pt.id_project,
case when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
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
and pt.date_txn <= sysdate()-1

group by 1,2,3,4,5,6
) as A

where A.month >= 4
and A.year >= 2018 

) as B

where B.pay_method != 'DISCOUNT_VOUCHER'
and B.payment_stage IN ('TEN_PERCENT', 'PRE_TEN_PERCENT')

group by 1 with rollup

) AS C