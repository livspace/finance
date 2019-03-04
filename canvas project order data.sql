select 
	t.*
-- 	sum(t.Total_Order_Value)
from 
( 
(
select 
    concat("",pi.project_id) as "Project_ID", 
    concat(c.firstname, " ", c.lastname) as "Customer_Name", 
    concat("",purchase_order_id) as canvas_order_id, 
    if(po.b2b, "Yes","No") as "B2B", 
    po.order_system, 
    CASE WHEN oo.order_type IS NULL THEN pot.type ELSE oo.order_type END as order_type,
     if(po.order_system='CANVASOMS',po.order_reference,spo.ID_ORDER) as "Parent_Order_ID", 
--  po.order	_reference as parent_order_id,
    CASE WHEN spo.PARENT_ORDER IS NOT NULL  THEN concat("",spo.id_order) ELSE NULL END as "Child_Order_ID",
    DATE_FORMAT(po.date_created, "%d-%b-%Y") as "Create_Date",
    if(po.order_system = "CANVASOMS",oos.display_name, sposl.name) as "Status",
    if(po.order_system='CANVASOMS',sum(pi.selling_price * pi.quantity),spo.`total_products`) as "Items_Post_Tax_Price", 
    if(po.order_system='CANVASOMS',sum(pi.handling_fee * pi.quantity),spo.`handling_fee`) as "Handling_Fee", 
    if(po.order_system='CANVASOMS',sum(pi.discount),spo.`total_discounts`) as "Discount", 
    ( case 
		when 
			po.order_system='CANVASOMS' then sum(pi.quantity * (pi.selling_price + pi.handling_fee) - pi.discount)
		else 
			(spo.`handling_fee`+ spo.`total_products_wt`) - spo.`total_discounts`
	end) as "Total_Order_Value",
    if(po.order_system='CANVASOMS',sum(pi.amount_paid),spo.`total_paid_real`) as "Amount_Claimed_on_Items_from_Customer_Wallet",
    oo.total_price - oo.total_price * (oo.commission_percentage/100) as "Vendor_Amount_After_Commission",
    (oo.paid_so_far) as "Amount_Paid_to_Vendor",
    (case 
        when po.`vendor_type`='STARMS_VENDOR' then ve.`display_name`
        when po.`vendor_type`='CANVAS_VENDOR' then canvas_ven.`display_name` end) as vendor_name
from 
    boq_backend.pf_product_item pi
join 
    boq_backend.pf_purchase_order po on pi.purchase_order_id = po.id
join 
    launchpad_backend.projects p on pi.project_id = p.id
join 
    livspace_v2.ps_customer c on p.customer_id = c.id_customer
left join
    boq_backend.oms_orders oo on oo.id = po.order_reference and po.order_system = "CANVASOMS"
left join
    boq_backend.oms_order_status oos on oo.order_status_id = oos.id
left join
    livspace_v2.ps_orders spo on spo.id_order = po.order_reference and po.order_system = "LSOMS"
left join
    livspace_v2.ps_order_type pot on spo.order_type=pot.id 
left join
    (
        select 
            *   
        from
            livspace_v2.`ps_order_history` poh
            where (id_order, date_add) IN (select id_order, max(date_add) from livspace_v2.`ps_order_history` group by id_order)
    ) spoh on spo.id_order=spoh.id_order  
left join
    livspace_v2.ps_order_state_lang sposl on sposl.id_order_state = spoh.id_order_state
left join
    `vms_backend`.`vendor` ve on po.`vendor_id`=ve.`id` and po.`vendor_type`='STARMS_VENDOR'
left join
    `boq_backend`.`temp_canvas_starms_vendor_mapping` can on po.`vendor_id`=can.`canvas_vendor_id` and po.`vendor_type`='CANVAS_VENDOR'
left join
    `vms_backend`.`vendor` canvas_ven on can.`starms_vendor_id`=canvas_ven.`id`
where 
    pi.purchase_order_id is not null and 
    pi.quantity > 0 and 
    pi.parent_group_item is null and 
    pi.deleted_at is null
	-- and pi.project_id = 271772
	
    [[and pi.project_id={{project_id}}]]
group by 
    pi.purchase_order_id   
order by 
    pi.project_id, pi.purchase_order_id   
) 
union 
(
select 
    concat("",pi.project_id) as "Project_ID", 
    concat(c.firstname, " ", c.lastname) as "Customer_Name", 
    concat("",purchase_order_id) as canvas_order_id, 
    if(po.b2b, "Yes","No") as "B2B", 
    po.order_system, 
    CASE WHEN oo.order_type IS NULL THEN pot.type ELSE oo.order_type END as order_type,
    child.parent_order as "Parent_Order_ID", 
-- 	po.order_reference as parent_order_id,
    concat("",child.id_order) as "Child_Order_ID",
    DATE_FORMAT(po.date_created, "%d-%b-%Y") as "Create_Date",
    childsl.name as "Status",
    child.`total_products` as "Items_Post_Tax_Price", 
    child.`handling_fee` as "Handling_Fee", 
    child.`total_discounts` as "Discount", 
    (child.`handling_fee`+ child.`total_products_wt`) - child.`total_discounts` as "Total_Order_Value",
    child.total_paid_real as "Amount_Claimed_on_Items_from_Customer_Wallet",
    (oo.total_price - oo.total_price * (oo.commission_percentage/100)) as "Vendor_Amount_After_Commission",
    (oo.paid_so_far) as "Amount_Paid_to_Vendor",
    (case 
    	when po.`vendor_type`='STARMS_VENDOR' then ve.`display_name`
    	when po.`vendor_type`='CANVAS_VENDOR' then canvas_ven.`display_name` end) as vendor_name
from 
    boq_backend.pf_product_item pi
join 
    boq_backend.pf_purchase_order po on pi.purchase_order_id = po.id
join 
    launchpad_backend.projects p on pi.project_id = p.id
join 
    livspace_v2.ps_customer c on p.customer_id = c.id_customer
left join
    boq_backend.oms_orders oo on oo.id = po.order_reference and po.order_system = "CANVASOMS"
left join
    boq_backend.oms_order_status oos on oo.order_status_id = oos.id
join   
    livspace_v2.ps_orders child on child.parent_order = po.order_reference and po.order_system = "LSOMS"
left join
    livspace_v2.ps_order_type pot on child.order_type=pot.id 
left join
	(
		select 
			*	
		from
			livspace_v2.`ps_order_history` poh
			where (id_order, date_add) IN (select id_order, max(date_add) from livspace_v2.`ps_order_history` group by id_order)
	) childh on child.id_order=childh.id_order  
left join
    livspace_v2.ps_order_state_lang childsl on childsl.id_order_state = childh.id_order_state
left join
	`vms_backend`.`vendor` ve on po.`vendor_id`=ve.`id` and po.`vendor_type`='STARMS_VENDOR'
left join
	`boq_backend`.`temp_canvas_starms_vendor_mapping` can on po.`vendor_id`=can.`canvas_vendor_id` and po.`vendor_type`='CANVAS_VENDOR'
left join
	`vms_backend`.`vendor` canvas_ven on can.`starms_vendor_id`=canvas_ven.`id`
where 
    pi.purchase_order_id is not null and 
    pi.quantity > 0 and 
    pi.parent_group_item is null and 
    pi.deleted_at is null
 -- and pi.project_id = 271772
   [[and pi.project_id={{project_id}}]]

group by 
    pi.project_id,
    child.`parent_order`,
    child.id_order,
    pi.purchase_order_id   
	order by 
    pi.project_id, pi.purchase_order_id
) 
) t