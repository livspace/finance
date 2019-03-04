
Select project_id, bu.name as Primary_cm, bu1.name as Primary_gm
From
(
select p.id as Project_id, ps.primary_cm_id, ps.primary_gm_id
from launchpad_backend.projects as p
left join launchpad_backend.project_settings as ps on ps.id = p.id and ps.is_deleted = 0
where p.status = 'ACTIVE') as a
Left join launchpad_backend.bouncer_users as bu on bu.bouncer_id = a.primary_cm_id
left join launchpad_backend.bouncer_users as bu1 on bu1.bouncer_id = a.primary_gm_id