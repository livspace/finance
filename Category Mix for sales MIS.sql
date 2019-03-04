
SELECT C.Primary_GM,C.Primary_CM,C.city,C.order_year_month,C.super_category,sum(C.GMV) as GMV
FROM(

SELECT B.project_id, B.primary_GM, B.Primary_CM, B.managed_city as city, B.order_year_month,B.super_category,
sum(B.Total_price_wt + B.handling_fees ) as GMV
from 
(
SELECT A.Project_ID,
bu1.name as Primary_GM,
bu2.name as Primary_CM,
case when A.project_id = 263836 then 'Bangalore'
	 when A.project_id = 288958 then 'Noida'  
     when A.project_id = 168024 then 'Chennai'
     when A.project_id = 3910 then 'Noida'
     when A.project_id = 74312 then 'Bangalore'
     when A.project_id = 78730 then 'Bangalore'
     when A.project_id = 175599 then 'Chennai'
     when A.project_id = 184809 then 'Mumbai'
     when A.project_id = 249725 then 'Noida'
     when A.project_id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as Managed_city,
 A.super_category, 
 date_format(A.order_created_date,'%Y-%m') as Order_year_month,
 sum(A.product_price*A.quantity) as Total_price_wt,
 sum((A.product_price*A.quantity)*0.08) as handling_fees
from 
(
select p.id as Project_ID,
p1.delivery_city,
p2.id_order,
p2.sku_code,
p2.product_name,
sum(p2.product_quantity) as Quantity,
p2.group_name,
p2.product_type,
p2.product_category,
pt.display_name prod_type,
pc.display_name category,
p2.product_price,
p.created_at as Project_Create_Date,
p2.create_time as Order_Created_date,
smpc.super_category,
p.city_id

from launchpad_backend.projects p

left join oms_backend.ps_orders p1 on p.id = p1.id_project
join oms_backend.ps_order_history as poh on p1.order_state = poh.id_order_history
left join oms_backend.ps_order_detail p2 on p1.id_order = p2.id_order 
left join livspace_v2.ps_cms_product_category pc on pc.id = p2.product_category
left join livspace_v2.ps_cms_product_type pt on pt.id = p2.product_type
left join livspace_reports.super_master_product_category as smpc on smpc.id_type = p2.product_type

   -- where p.id = 70364
 where date_format(p2.create_time,'%Y-%m') >= '2018-04'
 and poh.id_order_state != 6

group by 1,2,3,4,5,7,8,9,10,11,12,13,14,15,16

) as A 

left join launchpad_backend.cities as lbc on lbc.id = A.city_id
	  left join (
 select project_id, primary_cm_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_cm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu2 on bu2.project_id = A.project_id
        
  
 left join (
 select project_id, primary_GM_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_gm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu1 on bu1.project_id = A.project_id

-- where month(A.order_created_date) = 4
-- and year(A.order_created_date) >= 2018

group by 1,2,3,4,5,6

) as B

Group by 1,2,3,4,5,6

Union

Select    oo.Project_id,
	bu1.name as Primary_GM,
	bu2.name as Primary_CM,
case when oo.Project_id = 263836 then 'Bangalore'
	 when oo.Project_id = 288958 then 'Noida'  
     when oo.Project_id = 168024 then 'Chennai'
     when oo.Project_id = 3910 then 'Noida'
     when oo.Project_id = 74312 then 'Bangalore'
     when oo.Project_id = 78730 then 'Bangalore'
     when oo.Project_id = 175599 then 'Chennai'
     when oo.Project_id = 184809 then 'Mumbai'
     when oo.Project_id = 249725 then 'Noida'
     when oo.Project_id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
	 date_format(oo.created_at,'%Y-%m') as order_year_month,
	 "Services" as super_category,
	 sum(oo.total_price + oo.handling_fee) as GMV
	 
	 from boq_backend.oms_orders as oo
	 join launchpad_backend.projects p on p.id = oo.project_id
	 left join launchpad_backend.cities as lbc on lbc.id = p.city_id
	 
	  left join (
 select project_id, primary_cm_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_cm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu2 on bu2.project_id = oo.project_id
        
  
 left join (
 select project_id, primary_GM_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_gm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu1 on bu1.project_id = oo.project_id
	 
	 where oo.is_deleted = 0 
	 -- and id_project = 70364
	 and date_format(oo.created_at,'%Y-%m') >= '2018-04'
	 
	 group by 1,2,3,4,5,6
	 
	 ) as C
	 
	 Group by 1,2,3,4,5