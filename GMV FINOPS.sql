
Select A.*
From (
select 
order_created_at as Order_date,
year(order_created_at) as 'Year',
month(order_created_at) as 'month',
project_id,
lbp.customer_display_name,
case when lbp.is_business = 1 then 'true' else 'false' end as B2B,
case when project_id = 263836 then 'Bangalore'
	 when project_id = 288958 then 'Noida'  
     when project_id = 168024 then 'Chennai'
     when project_id = 3910 then 'Noida'
     when project_id = 74312 then 'Bangalore'
     when project_id = 78730 then 'Bangalore'
     when project_id = 175599 then 'Chennai'
     when project_id = 184809 then 'Mumbai'
     when project_id = 249725 then 'Noida'
     when project_id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as Managed_city,
	 vmbo.id_order,
	 case when vmbo.parent_order is NULL then "N" else "Y" end as Child_order,
vmbo.order_state,
case when vmbo.order_type = 10 then 'TURNKEY' else 'CATEGORY' end as order_type,
case when cash.is_cash_po = 1 then 'Non-secure' else 'Secure' end as "Secure/Non-Secure",

format(sum(ifnull(order_products_wt,0)/1.145), 2, 'en_IN') Revenue,
format(sum(ifnull(order_discount,0)), 2, 'en_IN') Discounts, 
format(sum(ifnull(order_products_wt,0)), 2, 'en_IN') 'Amount With Tax',
sum(ifnull(vmbo.order_handling_fee,0)) as 'order handling fees',
sum(ifnull(order_products_wt,0) + ifnull(order_handling_fee,0)) GMV,
sum( coalesce(vmbo.order_handling_fee,0) + coalesce(vmbo.order_products_wt,0) - coalesce(vmbo.order_discount,0)) as 'Net Order Value'


 from (select Distinct project_id,id_order,parent_order,order_type,order_state,order_discount,order_products_wt,order_handling_fee, order_created_at
 from livspace_reports2.flat_orders)
 as vmbo
 left join launchpad_backend.projects as lbp on vmbo.project_id = lbp.id
 left join launchpad_backend.cities as lbc on lbc.id = lbp.city_id
 left join ( select id_order,is_cash_po
				from oms_backend.ps_orders
				union 
			select id, cash_order 
			from boq_backend.oms_orders ) as cash
on cash.id_order = vmbo.id_order			
 
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
and vmbo.project_id not in ( 25954,	30788,	30789,	30790,	262032,	272849,	286720,	18889,	18030,	175093)
and vmbo.order_state not in ('Cancelled', 'Blocked') 

group by 1,2,3,4,5,6,7,8,9,10,11,12



) as A