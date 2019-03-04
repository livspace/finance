Select Final.* from 
(
select main.project_id,
main.city,
main.DP_Name,
main.CM_Name,
main.GM_Name,
main.stage,
 case when stage = 1 then "Y" 
	   when stage = 2 then "Y"
	   when stage = 3 then "Y" end as Survey_sent,
	   case when stage = 1 and nps.stages = 1 then "Y"
			    when stage = 2 and nps1.stages = 2 then "Y"
			    when stage = 3 and nps2.stages = 3 then "Y" else "N" end as Survey_responded,
	   case when stage = 1 then cast(nps.score AS DECIMAL(10,0))
			    when stage = 2 then CAST(nps1.score AS DECIMAL(10,0))
			    when stage = 3 then CAST(nps2.score AS DECIMAL(10,0))  end as score,
		case  when stage = 1 then coalesce(nps.survey_received_month, main.survey_sent_month)
			    when stage = 2 then coalesce(nps1.survey_received_month, main.survey_sent_month)
			    when stage = 3 then coalesce(nps2.survey_received_month, main.survey_sent_month) end as survey_month,
		case  when stage = 1 then coalesce(nps.survey_received_year, main.survey_sent_year)
			    when stage = 2 then coalesce(nps1.survey_received_year, main.survey_sent_year)
			    when stage = 3 then coalesce(nps2.survey_received_year, main.survey_sent_year) end as survey_year	 
From (
Select A.id as project_id, case WHEN B.new_value = 4 then 1
                  when B.new_value = 14 then 2
                  when B.new_value = 10 then 3 END as stage, 
                  case when A.id = 288958 then 'Noida'  
     when A.id = 168024 then 'Chennai'
     when A.id = 3910 then 'Noida'
     when A.id = 74312 then 'Bangalore'
     when A.id = 78730 then 'Bangalore'
     when A.id = 263836 then 'Bangalore'
     when A.id = 175599 then 'Chennai'
     when A.id = 184809 then 'Mumbai'
     when A.id = 249725 then 'Noida'
     when A.id = 283496 then 'Delhi'
     when lower(c.display_name) like 'bangalore' then 'Bangalore'
	 when lower(c.display_name) like 'chennai' then 'Chennai' 
	 when lower(c.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(c.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(c.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(c.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(c.display_name) IN ('noida') then 'Noida'
	 when lower(c.display_name) IN ('pune') then 'Pune'
	 ELSE 'Others' end as city,
	 bu.name as DP_Name,
	 bu1.name as CM_Name,
	 bu2.name as GM_Name,
	 date_format(B.created_at,'%Y-%m') as survey_sent_month,
	 year(B.created_at) as survey_sent_year

from launchpad_backend.projects as A
left join launchpad_backend.cities as c ON c.id = A.city_id
left join launchpad_backend.project_events as B on B.project_id = A.id

-- Interior designer
  left join (
 select project_id, primary_GM_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_designer_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu on bu.project_id = A.id

-- community manager
 left join (
 select project_id, primary_cm_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_cm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu1 on bu1.project_id = A.id

-- General manager
 left join (
 select project_id, primary_GM_id , bu.name
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_gm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as bu2 on bu2.project_id = A.id


-- where A.id in (297362)
where A.id not in (25954,30788,30789,30790,262032,272849,286720,18889,18030,175093)
and B.new_value in (4,14,10)
/* and month(B.created_at) >= 4
and year(B.created_at) >= 2018  */


) as main 

Left join 
(
Select nps.project_id, date_format(nps.created_at,'%Y-%m') as survey_received_month, year(nps.created_at) as survey_received_year,
case when nps.fid = 1 then 1 
     when nps.FID = 2 then 2 
     when nps.fid = 3 then 3 end as stages,
     nps.score
From (
select distinct L.context_id as project_id, max(L.batch) as batch, max(L.created_at) as created_at, lsf_form_id as FID, M.display_name as score
from launchpad_backend.lsf_responses L
left join launchpad_backend.lsf_components as M ON M.id = L.option_id
where L.question_id = 13
and L.lsf_form_id in (1)
-- and L.context_id = 40888 
-- and str_to_date(L.created_at,'%d/%m/%y') >= '01/04/2018'

group by 1,4
) as nps

) as nps on nps.project_id = main.project_id


Left join 
(
Select nps1.project_id, date_format(nps1.created_at,'%Y-%m') as survey_received_month, year(nps1.created_at) as survey_received_year,
case when nps1.fid = 1 then 1 
     when nps1.FID = 2 then 2 
     when nps1.fid = 3 then 3 end as stages,
     nps1.score
From (
select distinct L.context_id as project_id, max(L.batch) as batch, max(L.created_at) as created_at, lsf_form_id as FID, M.display_name as score
from launchpad_backend.lsf_responses L
left join launchpad_backend.lsf_components as M ON M.id = L.option_id
where L.question_id = 13
and L.lsf_form_id in (2)
-- and L.context_id = 40888 
-- and str_to_date(L.created_at,'%d/%m/%y') >= '01/04/2018'

group by 1,4
) as nps1

) as nps1 on nps1.project_id = main.project_id


Left join 
(
Select nps2.project_id, date_format(nps2.created_at,'%Y-%m') as survey_received_month, year(nps2.created_at) as survey_received_year,
case when nps2.fid = 1 then 1 
     when nps2.FID = 2 then 2 
     when nps2.fid = 3 then 3 end as stages,
     nps2.score
From (
select distinct L.context_id as project_id, max(L.batch) as batch, max(L.created_at) as created_at, lsf_form_id as FID, M.display_name as score
from launchpad_backend.lsf_responses L
left join launchpad_backend.lsf_components as M ON M.id = L.option_id
where L.question_id = 13
and L.lsf_form_id in (3)
-- and str_to_date(L.created_at,'%d/%m/%y') >= '01/04/2018'
-- and L.context_id = 40888 

group by 1,4
) as nps2

) as nps2 on nps2.project_id = main.project_id

) as Final
where Final.survey_year >= 2018
--

