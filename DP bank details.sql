
Select t.bouncer_id, t.name, t.Livspace_email,t.status,t.CM_bouncer_id, bu.display_name as CM_name, t.date_of_onboarding,t.phone, t.city, t.account_number, t.branch_name,
t.bank_name,t.ifsc_code 
from 
(
Select cu.login_id as bouncer_id,  cu.name,cu.bouncer_email as Livspace_email, bu.manager_id as CM_bouncer_id,
to_char(bu.created_at,'dd-mm-yyyy') as date_of_onboarding, cu.phone, cu.city,
-- lbc.display_name as city,
ba.account_number, ba.branch_name
,ba.bank_name, ba.ifsc_code, bu.status

from (select * from community.user) as cu
left join bouncer_web.users as bu on bu.id = cu.login_id
left join launchpad_backend.cities as lbc on lbc.id = bu.city_id 
left join community.bank_account as ba on ba.owner_id = cu.account_id
) as t
left join bouncer_web.users as bu on bu.id = t.CM_bouncer_id