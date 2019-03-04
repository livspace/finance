Select p.id as project_id, PDP.Primary_DP as 'Primary_DP/ID', PCM.Primary_CM, PGM.Primary_GM

From launchpad_backend.projects	as p 
 left join (
 select project_id, primary_cm_id , bu.name as Primary_CM
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_cm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as PCM on PCM.Project_id = p.id
        
  
 left join (
 select project_id, primary_GM_id , bu.name as Primary_GM
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_gm_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as PGM on PGM.Project_id = p.id
        
  left join (
 select project_id, primary_GM_id , bu.name as Primary_DP
				From launchpad_backend.project_settings  as ps 
				left join launchpad_backend.bouncer_users as bu on ps.primary_designer_id = bu.bouncer_id
				        where ps.is_deleted = 0 
        ) as PDP on PDP.Project_id = p.id