

select  
concat(month,'-',year) as month,  
id_order, 
name,  
id_project,  
delivery_city,  
order_products_wt, 
order_discounts,  
order_handling_fee, 
processed_products_wt,
full_gmv_includes_handling_fee,
processed_gmv_includes_handling_fee,
cogs,
order_type 


from 
	( 
	
		/* OMS TC Start */
		(
			select  
				month(o.date_add) as month, 
				year(o.date_add) as year,  
				o.id_order,  
				osl.name,  /* order state name */ 
				o.id_project,  
				o.delivery_city,  
				round(ifnull(o.total_products_wt, 0),2) order_products_wt, 
				round(ifnull(o.total_discounts, 0),2) order_discounts, 
				round(ifnull(o.handling_fee,0),2) order_handling_fee,  
				round(ifnull(o.total_products_wt, 0),2) processed_products_wt ,  
				round((ifnull(o.total_products_wt, 0) + ifnull(o.handling_fee,0)),2) full_gmv_includes_handling_fee,
				round((ifnull(o.total_products_wt, 0) + ifnull(o.handling_fee,0)),2) processed_gmv_includes_handling_fee,
				round((ifnull(o.total_products_wt, 0) ) * 0.85,2) cogs, 
				"tc" order_type

			from  	
				oms_backend.ps_orders o 
			join 	
				oms_backend.ps_order_history oh on oh.id_order = o.id_order and oh.id_order_history = o.order_state	 
			join
				oms_backend.ps_order_state_lang osl on osl.id_order_state = oh.id_order_state
			where  
				/* turnkey order_type is 10 */ o.order_type = 10 and oh.id_order_state not in (6,35) and o.date_add >= '2017-01-01 00:00:00' 

			group by 
				month(o.date_add), year(o.date_add), o.id_order, osl.name, o.id_project, o.delivery_city   
			order by o.id_order desc
		)   
		/* OMS TC End */		
		
		union
		
		
		/* Canvas TC Start */
		(
			select 
				month(po.created_at) as "month",
				year(po.created_at) as "year",
				po.id as "id_order",
				"canvas_order",
				po.project_id as "id_project",
				p.city_display_name as "delivery_city",
				oo.total_price as "order_products_wt",
				oo.discount as "order_discounts",
				oo.handling_fee as "order_handling_fee",
				oo.total_price as "processed_products_wt",
				oo.total_price + oo.handling_fee as "full_gmv_includes_handling_fee",
				oo.total_price + oo.handling_fee as "processed_gmv_includes_handling_fee",
				oo.total_price * (100-oo.commission_percentage)/100 as "cogs",
				"tc" order_type

			from 
				boq_backend.pf_purchase_order po
			inner join 
				launchpad_backend.projects p
					on p.id = po.project_id
			inner join 
				boq_backend.oms_orders oo
					on po.order_reference = oo.id
			where 
				po.created_at >= "2017-01-01 00:00:00"
				and po.order_system = "CANVASOMS" and po.deleted_at is null
				and po.total_price > 0 and po.order_reference is not null


		)
		/* Canvas TC End */		
		
		
		
		/* OMS PO CHANNEL START */
        
		union  
		(
			select
				ao.month as month,
				ao.year as year,
				ao.id_order as id_order,
				ao.name as name,
				ao.id_project as id_project,
				ao.delivery_city as delivery_city,
				ao.order_products_wt as order_products_wt,
				ao.order_discounts as order_discounts,
				ao.order_handling_fee as order_handling_fee,
				round(ifnull(aop.processed_products_wt,0),2) as processed_products_wt,
				ao.full_gmv_includes_handling_fee as full_gmv_includes_handling_fee,
				round(ifnull(aop.processed_products_wt,0)+ao.order_handling_fee,2) as processed_gmv_includes_handling_fee,   

				aop.cogs as cogs,
				ao.order_type as order_type

			from
				(	
					select  
						month(o.date_add)  as month, 
						year(o.date_add) as year, 
						o.id_order,  
						osl.name,  /* order state name */ 
						o.id_project, 
						o.delivery_city,
						round(ifnull(o.total_products_wt, 0),2) order_products_wt, 
						round(ifnull(o.total_discounts, 0),2) order_discounts, 
						round(ifnull(o.handling_fee,0),2) order_handling_fee,  
					
						round((ifnull(o.total_products_wt, 0) + ifnull(o.handling_fee,0)),2) full_gmv_includes_handling_fee,  /* product_wt + handling fee */    

						"regular" order_type
					from  	
						oms_backend.ps_orders o 
					join 	
						oms_backend.ps_order_history oh on oh.id_order = o.id_order and oh.id_order_history = o.order_state	
					join 	
						oms_backend.ps_order_state_lang osl on osl.id_order_state = oh.id_order_state	 
					join 	
						oms_backend.ps_order_detail od on (od.id_order = o.id_order and od.is_active = 1) 
/*					join 	
						ps_order_detail_mapping odm on ( odm.id_order_detail = od.id_order_detail and odm.is_active = 1)	 
					left join  	
						ls-ims.po_item poi on ( odm.po_item_id = poi.id)	 
					left join  	
						ls-ims.purchase_order po on (po.po_code = poi.po_code)	 
				
					left join 	
						(select facility_id, group_concat(tag ) tags 		from  			vms_backend.vendor_facility_tag 		group by facility_id) 	vft  on ( vft.facility_id = po.id_vendor) 	*/
					where 
						/* turnkey order_type is 10 */ o.order_type != 10 and 
						oh.id_order_state not in (6,35) and 
						o.date_add >= '2017-01-01 00:00:00'   
					group by 
						month(o.date_add), year(o.date_add), o.id_order, osl.name, o.id_project, o.delivery_city   
					order by
						o.id_order desc  
				) ao
			left join 
			(
				/* PO */
				(

					select 
						month(o.date_add)  as month, 
						year(o.date_add) as year, 
						o.id_order, 
						osl.name,  /* order state name */
						o.id_project, 
						o.delivery_city, 
						sum(round((od.product_price * poi.quantity + (od.product_price * poi.quantity * od.tax_rate/100)),2)) processed_products_wt,

						/* PO extra costs should contribute to COGS , pro-rata absorb po extra cost to each item in the po */
						/* if vendor of the PO is tagged as Turnkey , consider 85% of order item cost as cogs - applicable for old TC PO usecase*/
						sum(
							round( 

								if( locate('turnkey',vft.tags) != 0 , ((od.product_price * poi.quantity + (od.product_price * poi.quantity * od.tax_rate/100)) * 85/100) , poi.cost * ifnull(po.total_cost/po.total_item_cost,1) )
							,2)
						) cogs,
						"regular" order_type


					from 
						oms_backend.ps_orders o
					join
						oms_backend.ps_order_history oh on oh.id_order = o.id_order and oh.id_order_history = o.order_state	
					join
						oms_backend.ps_order_state_lang osl on osl.id_order_state = oh.id_order_state	
					join
						oms_backend.ps_order_detail od on (od.id_order = o.id_order and od.is_active = 1)
					join
						oms_backend.ps_order_detail_mapping odm on ( odm.id_order_detail = od.id_order_detail and odm.is_active = 1)	
					join 
						`ls-ims`.po_item poi on ( odm.po_item_id = poi.id)	
					join 
						`ls-ims`.purchase_order po on (po.po_code = poi.po_code)
					left join
						livspace_v2.ps_product p on p.id_product = od.product_id
					left join	
						cms_backend.cms_product_category pc on p.category_sku = pc.id
					left join
						livspace_reports.super_master_product_category mpc on (mpc.id_type = od.product_type)
					left join
						(select facility_id, group_concat("tag") as tags
							from 
								vms_backend.vendor_facility_tag
							group by facility_id)
						vft  on ( vft.facility_id = po.id_vendor)
						
					where  
						/* turnkey order_type is 10 */ o.order_type != 10 
						and /* PO Channel */ (poi.po_code like 'PO%') 
						and oh.id_order_state not in (6,35) 
						and o.date_add >= '2017-01-01 00:00:00'

					group by 
						month, year, o.id_order, osl.name, o.id_project, o.delivery_city
				)
				
				union
				
				(
					select 
						month,
						year,
						id_order,
						name,
						id_project,
						delivery_city,
						sum(processed_products_wt) processed_products_wt,
						sum(cogs) cogs,
						order_type
					from
					(	
					
						select 
							month(o.date_add) as month, 
							year(o.date_add) as year, 
							o.id_order, 
							osl.name,  /* order state name */
							o.id_project, 
							o.delivery_city, 
							sum(round((od.product_price * poi.quantity + (od.product_price * poi.quantity * od.tax_rate/100)),2)) processed_products_wt,
							sum(round( poic.cost/poi.quantity,2)) cogs,
							"regular" order_type
						

						from 
							oms_backend.ps_orders o
						join
							oms_backend.ps_order_history oh on oh.id_order = o.id_order and oh.id_order_history = o.order_state	
						join
							oms_backend.ps_order_state_lang osl on osl.id_order_state = oh.id_order_state	
						join
							oms_backend.ps_order_detail od on (od.id_order = o.id_order and od.is_active = 1)
						join
							oms_backend.ps_order_detail_mapping odm on ( odm.id_order_detail = od.id_order_detail and odm.is_active = 1)	
						join 
							`ls-ims`.po_item poi on ( odm.po_item_id = poi.id)	
						join 
							livspace_v2.poitem_cost poic
								on poic.poitem_id = poi.id
						left join
							livspace_v2.ps_product p on p.id_product = od.product_id
						left join	
							cms_backend.cms_product_category pc on p.category_sku = pc.id
						left join
							livspace_reports.super_master_product_category mpc on (mpc.id_type = od.product_type)
						where  
							o.order_type != 10 and 
							(poi.po_code like 'AS%') and 
							oh.id_order_state not in (6,35) and
							o.date_add >= '2017-01-01 00:00:00'
						group by 
							month(o.date_add), year(o.date_add), o.id_order, osl.name, o.id_project, o.delivery_city
					) t group by month, year, id_order, name, id_project, delivery_city
				)		
	
			) aop
				on 
					ao.month=aop.month and ao.year = aop.year and ao.id_order = aop.id_order and ao.id_project = aop.id_project and ao.delivery_city = aop.delivery_city
		)   
		/* PO CHANNEL END */
		
		
		
		
		
	) t 

order by year, month;

