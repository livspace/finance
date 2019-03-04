Select R.project_id, O.id_order, O.product_id, O.product_name, 
O.sku, O.poitem_id_sp, O.poitem_id_sp_wt, O.mapped_discount, O.mapped_handling, N.item_cost, P.super_category
From livspace_reports2.flat_order_items as O
left join (select distinct M.product_id,M.price, M.sku_code,M.super_category
from 
(
Select distinct P.code as sku_code, P.id_product as product_id, P.price, Q.type_sku, Q.category_sku,
O.super_category
from cms_backend.ps_customized_product as P 
left join cms_backend.ps_product as Q ON Q.id_product = P.id_product
left join livspace_reports.super_master_product_category as O on O.id_type = Q.type_sku
) as M
) as P on P.sku_code = O.sku
left join livspace_reports2.flat_orders as R on R.id_order = O.id_order
left join (
			SELECT distinct M.id_order,N.id as PO_ID, N.quantity, N.sku,(N.total_cost/(case when N.quantity = 0 then 1 else N.quantity end)) as item_cost
			From `ls-ims`.purchase_order_item as N 
			left join `ls-ims`.purchase_order as M on M.id = N.id_po
			and N.status != 10
			
			where N.deleted = 0
			) as N 
			on O.id_order = N.id_order
			and N.sku = O.sku

-- where O.id_order = 1811170059
where R.project_id = 301232





