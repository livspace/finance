SELECT 
month(lbc.created_at),
case when lbc.project_id = 288958 then 'Noida'  
     when lbc.project_id = 168024 then 'Chennai'
     when lbc.project_id = 3910 then 'Noida'
     when lbc.project_id = 74312 then 'Bangalore'
     when lbc.project_id = 78730 then 'Bangalore'
     when lbc.project_id = 175599 then 'Chennai'
     when lbc.project_id = 184809 then 'Mumbai'
     when lbc.project_id = 249725 then 'Noida'
     when lbc.project_id = 283496 then 'Delhi'
     when lower(lbc.display_name) like 'bangalore' then 'Bangalore'
	 when lower(lbc.display_name) like 'chennai' then 'Chennai' 
	 when lower(lbc.display_name) in ('delhi','ghaziabad','faridabad','dwarka') then 'Delhi'
	 when lower(lbc.display_name) like 'gurgaon' then 'Gurgaon'
	 when lower(lbc.display_name) like 'hyderabad' then 'Hyderabad'
	 when lower(lbc.display_name) IN  ('mumbai','thane','navi mumbai') then 'Mumbai'
	 when lower(lbc.display_name) IN ('noida') then 'Noida'
	 when lower(lbc.display_name) IN ('pune') then 'Pune'
 ELSE 'Others' end as Managed_city,
 count(lbc.project_id) as count_projects,
 count(ps.project_id) as CM_assigned_projects,
 count(rs.project_id) as DIP_projects
 
 
 
From (


SELECT distinct P.ID AS PROJECT_ID,MONTH(P.created_at)CREATED_MONTH, YEAR(P.CREATED_AT) AS CREATED_YEAR,lbc.DISPLAY_NAME as display_name, P.created_at
FROM launchpad_backend.projects AS P
LEFT JOIN launchpad_backend.cities as lbc ON launchpad_backend.lbc.id = P.city_id
-- where P.status not in ('INACTIVE')
where  P.id not in (8075,	12078,	18030,	21136,	25809,	25954,	30268,	30788,	30789,	30790,	41192,	18889,	0,	67297,	72435,	72482,	7294,	28865,	17951,	895,	14317,	30762,	17076,	44489,	6928,	14335,	21968,	21684,	13019,	2209,	7271,	4465,	14758,	21392,	19368,	48430,	31573,	101834,	87617,	68196,	46582,	45359,	87555,	109016,	117033,	5396,	34153,	30938,	44431,	57144,	47691,	168024,	165084,	175078,	175093,	121023,	181066,	179868,	194085,	119117,	187487,	91169,	190036,	42211,	87047,	72166,	51327,	30241,	109690,	149244,	137170,	172402,	85175,	141853,	181513,	150929,	175101,	199565,	185201,	199099,	118683,	202292,	13948,	286720,	262032,	272849,	287178)

) as lbc

left join( 
select distinct ps.project_id, ps.created_at
from  launchpad_backend.project_events as ps 
where event_type in ('STAGE_UPDATED')
AND new_value = 18)
as ps on ps.project_id = lbc.project_id

left join
( select distinct ps.project_id, ps.created_at
from  launchpad_backend.project_events as ps  
where event_type in ('STAGE_UPDATED')
AND new_value = 4)
as rs on rs.project_id = lbc.project_id

where lbc.created_month >= 1 
and lbc.created_year >= 2018

Group by 1 with rollup