--------------------------------------------------------
--  DDL for Package Body MSC_UI_PEG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_UI_PEG_UTIL" AS
/*  $Header: MSCPEGUB.pls 120.5 2007/12/06 01:34:59 cnazarma ship $ */

procedure  get_disposition_id(p_demand_id IN NUMBER,
                               x_disposition_id   OUT NOCOPY NUMBER,
                               x_origination_type OUT NOCOPY NUMBER,
                               p_sr_instance_id   IN  NUMBER,
                               p_organization_id  IN  NUMBER,
                               p_plan_id          IN  NUMBER)  IS

cursor origination_22 is
select origination_type, disposition_id
from msc_demands
where demand_id = p_demand_id
and plan_id = p_plan_id
and organization_id = p_organization_id
and sr_instance_id  = p_sr_instance_id;


begin

open origination_22;
fetch origination_22 into x_origination_type, x_disposition_id;
close origination_22;

exception when others THEN
raise;
end get_disposition_id;

Procedure get_suptree_sup_values(p_plan_id		IN NUMBER,
                            p_demand_id			IN NUMBER,
                            p_sr_instance_id		IN NUMBER,
                            p_organization_id		IN NUMBER,
                            p_prev_peg_id		IN NUMBER,
                            x_itemorg_pegnode_rec	OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                            p_supply_pegging  IN NUMBER DEFAULT 0 , -- demand pegging ( peg up)
			    p_show_item_desc  IN NUMBER DEFAULT 2)
IS
l_disposition_id   NUMBER;
l_origination_type NUMBER;
l_prev_peg_id      NUMBER;
i                  NUMBER;

 cursor cur1(p_disposition_id_1 number , l_show_item_desc number) is
 select  decode(l_show_item_desc, 1, substrb(nvl(mis.description,mis.item_name),1,80)||'/'||msc_get_name.org_code(ms.organization_id,ms.sr_instance_id)
         ,substrb(mis.item_name,1,80)||'/'||msc_get_name.org_code(ms.organization_id,ms.sr_instance_id) ) item_org,
          ms.new_order_quantity supply_qty,
          ms.new_schedule_date  supply_date,
          msc_get_name.lookup_meaning( 'MRP_ORDER_TYPE',
                                     ms.order_type) order_name,
          null  pegging_id,
          null  prev_pegging_id,
          ms.transaction_id,
          p_demand_id demand_id,
          ms.new_order_quantity pegged_qty,
          ms.inventory_item_id,
          ms.order_type,
          null  disposition
 from    msc_system_items mis,
          msc_supplies ms
  where   mis.inventory_item_id = ms.inventory_item_id
  and     mis.sr_instance_id = ms.sr_instance_id
  and     mis.organization_id = ms.organization_id
  and     mis.plan_id = ms.plan_id
  and     ms.transaction_id     = p_disposition_id_1
  and     ms.plan_id            = p_plan_id
  and     ms.organization_id    = p_organization_id
  and     ms.sr_instance_id     = p_sr_instance_id;
  --5523978 bugfix, msc_items changed to msc_system_items

 cursor cur2(l_show_item_desc number) is
  select distinct
          decode(l_show_item_desc ,1,item_desc_org,item_org) item_org,
          supply_qty,
          supply_date,
          order_name,
          pegging_id,
          prev_pegging_id,
          transaction_id,
          demand_id,
          pegged_qty,
          inventory_item_id,
          order_type,
          disposition
  from msc_flp_demand_supply_v3
  where plan_id = p_plan_id
  and pegging_id = p_prev_peg_id
  order by item_org, supply_date;

  cursor cur3(l_prev_peg_id_1 number , l_show_item_desc number) is
  select distinct decode(l_show_item_desc ,1,item_desc_org,item_org) item_org ,
                 supply_qty,
                 supply_date,
                 order_name,
                 pegging_id,
                 prev_pegging_id,
                 transaction_id,
                 demand_id,
                 pegged_qty,
                 inventory_item_id,
                 order_type,
                 disposition
  from      msc_flp_demand_supply_v3
  where     plan_id = p_plan_id
        and prev_pegging_id = l_prev_peg_id_1
        and demand_id = p_demand_id
        and order_type not in (15,16,28)
        order by item_org, supply_date;

BEGIN
    get_disposition_id(p_demand_id,
                       l_disposition_id,
                       l_origination_type,
                       p_sr_instance_id,
                       p_organization_id,
                       p_plan_id);
-- this case is for Demand Pegging ( peg up from children to parents)
 IF  p_supply_pegging  = 0 THEN  -- Demand Pegging ( peg up)
  -- This case is when you are on Production Forecast and you expand a Demand Tree meaning
  -- u are  pegging up so the next node should be Product Family Planned Order
   IF l_origination_type = 22  THEN
	  i := 1;
	  open cur1(l_disposition_id , p_show_item_desc);
	  loop
	    exit when cur1%notfound;
	    fetch cur1 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_Date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).Order_type,
	       x_itemorg_pegnode_rec(i).Disposition;
	    i := i + 1;
	  end loop;
	  close cur1;
	  i := 0;
  ELSE
	  i := 1;
	  open cur2(p_show_item_desc);
	  loop
	    exit when cur2%notfound;
	    fetch cur2 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_Date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).Order_type,
	       x_itemorg_pegnode_rec(i).Disposition;
	    i := i + 1;
	  end loop;
	  close cur2;
	  i := 0;
   END IF;

-- This case if for Supply Pegging ( peg down from demand node of parent item to supply node of child)
 ELSIF p_supply_pegging = 1 THEN
-- This case if when you are on Production Forecast Node and it is Supply Pegging
-- so the next node should be Planned order of the Member item
   IF  l_origination_type = 22 and p_prev_peg_id is NULL THEN
       l_prev_peg_id := -1 ;
   ELSE
       l_prev_peg_id := p_prev_peg_id;
   END IF;
	  i := 1;
	  open cur3(l_prev_peg_id , p_show_item_desc);
	  loop
	    exit when cur3%notfound;
	    fetch cur3 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_Date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).Order_type,
	       x_itemorg_pegnode_rec(i).Disposition;
	    i := i + 1;
	  end loop;
	  close cur3;
	  i := 0;
END IF;

END get_suptree_sup_values;

Procedure get_suptree_dem_values(p_plan_id	IN NUMBER,
                      p_transaction_id		IN NUMBER,
                      x_itemorg_pegnode_rec	OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                      p_item_id			IN NUMBER,
                      p_pegging_id		IN NUMBER,
                      p_instance_id		IN NUMBER,
                      p_trigger_node_type	IN NUMBER DEFAULT 2,
                      p_condense_supply_oper	IN NUMBER DEFAULT 0,
                      p_hide_oper		IN NUMBER DEFAULT 0,
                      p_organization_id		IN NUMBER DEFAULT NULL,
                      p_supply_pegging  IN NUMBER DEFAULT 0 ,
		      p_show_item_desc  IN NUMBER DEFAULT 2) IS

cursor bom_item_type (p_inventory_item_id in NUMBER) IS
select bom_item_type
from   msc_system_items
where  inventory_item_id = p_inventory_item_id
and    plan_id           = p_plan_id
and    sr_instance_id    = p_instance_id;

-- Sometimes after button Supply Pegging is clicked  pld is not sending  item_id
cursor inventory_item_id IS
select inventory_item_id,
       decode(order_type, 13, disposition_id, transaction_id)
from msc_supplies
where transaction_id = p_transaction_id
and   plan_id        = p_plan_id
and   sr_instance_id = p_instance_id
and   organization_id = p_organization_id;

l_bom_item_type NUMBER;
PARENT          NUMBER :=1 ;
l_item_id       NUMBER;
i               NUMBER;
l_transaction_id       NUMBER;

cursor cur1(l_show_item_desc number) is
select  decode(l_show_item_desc, 1, item_desc_org, item_org) item_org,
         demand_qty,
         demand_date,
         origination_name,
         prev_pegging_id,
         demand_id,
         sum(pegged_qty) pegged_qty,
         item_id,
         order_type,
         end_disposition order_number,
         null pegging_id ,
         null transaction_id,
         null end_demand_class
from msc_flp_supply_demand_v3
    where plan_id = p_plan_id
    and prev_pegging_id in ( select pegging_id
				  from msc_full_pegging
				  where plan_id       = p_plan_id
				  and transaction_id  = l_transaction_id
				  and sr_instance_id  = p_instance_id
				  and allocated_quantity > 0)  ------ = p_pegging_id
    and item_id not in (SELECT msi.inventory_item_id
                        FROM msc_resource_requirements req,
                        msc_routings rout,
                        msc_routing_operations op,
                        msc_operation_components moc,
                        msc_bom_components mbc,
                        msc_system_items msi
                        WHERE req.plan_id = rout.plan_id
                        AND req.sr_instance_id = rout.sr_instance_id
                        AND nvl(req.routing_sequence_id,-23453) = decode(nvl(req.routing_sequence_id,-23453), -23453,-23453, rout.routing_sequence_id)
                        AND req.plan_id = op.plan_id
                        AND req.sr_instance_id = op.sr_instance_id
                        AND nvl(req.routing_sequence_id,-23453) = decode(nvl(req.routing_sequence_id,-23453), -23453, -23453, op.routing_sequence_id)
                        AND req.operation_sequence_id = op.operation_sequence_id
                        AND nvl(req.parent_id,2) = 2
                        and moc.plan_id = req.plan_id
                        and moc.sr_instance_id = req.sr_instance_id
                        and moc.operation_sequence_id = req.operation_sequence_id
                        and nvl(req.routing_sequence_id,-23453) = decode(nvl(req.routing_sequence_id,-23453), -23453, -23453, moc.routing_sequence_id)
                        and moc.plan_id  = mbc.plan_id
                        and moc.sr_instance_id = mbc.sr_instance_id
                        and moc.organization_id = mbc.organization_id
                        and moc.component_sequence_id    = mbc.component_sequence_id
                        and moc.bill_sequence_id   = mbc.bill_sequence_id
                        and mbc.plan_id = msi.plan_id
                        and mbc.sr_instance_id = msi.sr_instance_id
                        and mbc.organization_id = msi.organization_id
                        and mbc.inventory_item_id = msi.inventory_item_id
                        and req.plan_id = p_plan_id
                        and req.sr_instance_id = p_instance_id
                        and req.organization_id = p_organization_id
                        and req.supply_id = p_transaction_id
                        and 0 = nvl(p_condense_supply_oper,0)
                        and 0 = nvl(p_hide_oper,0))
    group by demand_qty, demand_date,
        origination_name, prev_pegging_id, demand_id,
        item_id, item_org,item_desc_org, order_type, end_disposition
  order by item_org, demand_date;

cursor cur2(l_show_item_desc number) is
select decode(l_show_item_desc, 1, substrb(nvl(mis.description,mis.item_name),1,80)||'/'||msc_get_name.org_code(dm.organization_id,dm.sr_instance_id)
         ,substrb(mis.item_name,1,80)||'/'||msc_get_name.org_code(dm.organization_id,dm.sr_instance_id) ) item_org,
	 dm.using_requirement_quantity demand_qty,
	 dm.using_assembly_demand_date demand_date,
	 msc_get_name.lookup_meaning( 'MSC_DEMAND_ORIGINATION',
				     dm.origination_type) origination_name,
	 null prev_pegging_id,
	 dm.demand_id  demand_id,
	 dm.using_requirement_quantity pegged_qty,
	 mis.inventory_item_id item_id,
	 dm.origination_type,
	 null order_number,
	 null pegging_id,
	 null transaction_id,
	 null end_demand_class
from  msc_system_items mis,
	msc_demands dm
	where mis.inventory_item_id = dm.inventory_item_id
        and   mis.sr_instance_id = dm.sr_instance_id
        and   mis.organization_id = dm.organization_id
        and   mis.plan_id = dm.plan_id
	and   dm.disposition_id     = p_transaction_id
	and   dm.plan_id               = p_plan_id
	and   dm.organization_id       = p_organization_id
	and   dm.sr_instance_id        = p_instance_id;

cursor cur3(l_show_item_desc number) is
select distinct
		decode(l_show_item_desc, 1, item_desc_org, item_org) item_org,
		pegging_id,
		prev_pegging_id,
		demand_qty,
		demand_date,
		origination_name,
		demand_id,
		transaction_id,
		item_id,
		pegged_qty,
		end_disposition order_number,
		order_type,
		end_demand_class
from msc_flp_supply_demand_v3
	where plan_id =      p_plan_id
	and transaction_id = p_transaction_id
	order by item_org, demand_date;

cursor cur4(l_show_item_desc number) is
 select distinct
		decode(l_show_item_desc, 1, item_desc_org, item_org) item_org,
		pegging_id,
		prev_pegging_id,
		demand_qty,
		demand_date,
		origination_name,
		demand_id,
		transaction_id,
		item_id,
		pegged_qty,
		end_disposition order_number,
		order_type,
		end_demand_class
from msc_flp_supply_demand_v3
where plan_id = p_plan_id
and  pegging_id  = p_pegging_id
order by item_org, demand_date;


BEGIN
l_transaction_id := p_transaction_id;
if p_item_id is NULL then
open inventory_item_id;
fetch inventory_item_id INTO l_item_id, l_transaction_id;
close inventory_item_id;
else
l_item_id := p_item_id;
end if;

open bom_item_type(l_item_id);
fetch bom_item_type INTO l_bom_item_type;
close bom_item_type;

 -- A user is on Supply Tree and button Supply Pegging has been used
 IF p_supply_pegging = 1 and l_bom_item_type <> 5   then
        i := 1;
	  open cur1(p_show_item_desc);
	  loop
	    exit when cur1%notfound;
	    fetch cur1 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur1;
	  i := 0;

 ELSIF  p_supply_pegging = 1 and l_bom_item_type = 5  then
-- this case is for Product Family , we need to display the Product Forecast nodes when node is expanded

           i := 1;
	  open cur2(p_show_item_desc);
	  loop
	    exit when cur2%notfound;
	    fetch cur2 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur2;
	  i := 0;
 ELSIF  p_supply_pegging <> 1  then

  IF l_bom_item_type = 5 OR p_trigger_node_type = PARENT THEN

           i := 1;
	  open cur3(p_show_item_desc);
	  loop
	    exit when cur3%notfound;
	    fetch cur3 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_Date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).demand_id,
	       x_itemorg_pegnode_rec(i).transaction_id,
	       x_itemorg_pegnode_rec(i).item_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur3;
	  i := 0;

ELSE

           i := 1;
	  open cur4(p_show_item_desc);
	  loop
	    exit when cur4%notfound;
	    fetch cur4 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).transaction_id,
	       x_itemorg_pegnode_rec(i).item_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur4;
	  i := 0;
END IF;
end if;

EXCEPTION WHEN others THEN
raise;
END  get_suptree_dem_values;


Procedure get_suptree_dem_values_rep(p_plan_id	IN NUMBER,
                      p_transaction_id		IN NUMBER,
                      x_itemorg_pegnode_rec	OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                      p_instance_id		IN NUMBER,
                      p_supply_pegging  IN NUMBER DEFAULT 0 ,
		      p_show_item_desc  IN NUMBER DEFAULT 2,
		      p_show_ss_demands IN NUMBER DEFAULT 1) IS
 cursor cur1 is
select  decode(p_show_item_desc, 1, item_desc_org, item_org) item_org,
         demand_qty,
         demand_date,
         origination_name,
         prev_pegging_id,
         demand_id,
         sum(pegged_qty) pegged_qty,
         item_id,
         order_type,
         end_disposition order_number,
         null pegging_id ,
         null transaction_id,
         null end_demand_class
from msc_flp_supply_demand_v3
    where plan_id = p_plan_id
    and  prev_pegging_id in ( select  mfp.pegging_id
				 from msc_full_pegging mfp,
                                      msc_supplies ms
				 where ms.plan_id         = p_plan_id
				 and ms.transaction_id    = p_transaction_id
				 and ms.sr_instance_id    = p_instance_id
                                 and mfp.plan_id = ms.plan_id
                                 and mfp.transaction_id = ms.disposition_id
				 and mfp.allocated_quantity > 0 )
    group by demand_qty, demand_date,
        origination_name, prev_pegging_id, demand_id,
        item_id, item_org,item_desc_org, order_type, end_disposition
  order by item_org, demand_date;

cursor cur3 is
select distinct
		decode(p_show_item_desc, 1, item_desc_org, item_org) item_org,
		pegging_id,
		prev_pegging_id,
		demand_qty,
		demand_date,
		origination_name,
		demand_id,
		transaction_id,
		item_id,
		pegged_qty,
		end_disposition order_number,
		order_type,
		end_demand_class
from msc_flp_supply_demand_rep_v
	where plan_id =      p_plan_id
	and transaction_id = p_transaction_id
	order by item_org, demand_date;

  i number;
BEGIN
  i := 1;
  IF p_supply_pegging = 1 then
	  open cur1;
	  loop
	    exit when cur1%notfound;
	    fetch cur1 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur1;
   else
	  open cur3;
	  loop
	    exit when cur3%notfound;
	    fetch cur3 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_Date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).demand_id,
	       x_itemorg_pegnode_rec(i).transaction_id,
	       x_itemorg_pegnode_rec(i).item_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur3;
   end if;

END get_suptree_dem_values_rep;

Procedure get_demtree_dem_values( p_plan_id                IN NUMBER,
                                  p_transaction_id         IN NUMBER,
                                  x_itemorg_pegnode_rec    OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                                  p_instance_id            IN NUMBER,
				  p_organization_id        IN NUMBER,
                                  p_bom_item_type        IN NUMBER,
				  p_show_item_desc       IN NUMBER DEFAULT 2) IS
i number;

Cursor cur1(l_show_item_desc number) is
  select decode(l_show_item_desc, 1, substrb(nvl(mis.description,mis.item_name),1,80)||'/'||msc_get_name.org_code(dm.organization_id,dm.sr_instance_id)
         ,substrb(mis.item_name,1,80)||'/'||msc_get_name.org_code(dm.organization_id,dm.sr_instance_id)) item_org,
         dm.using_requirement_quantity demand_qty,
         dm.using_assembly_demand_date demand_date,
         msc_get_name.lookup_meaning( 'MSC_DEMAND_ORIGINATION',
                                     dm.origination_type) origination_name,
         null prev_pegging_id,
         dm.demand_id  demand_id,
         dm.using_requirement_quantity pegged_qty,
         mis.inventory_item_id item_id,
         dm.origination_type,
         null order_number,
         null pegging_id,
         null transaction_id,
         null end_demand_class
  from  msc_system_items mis,
        msc_demands dm
  where mis.inventory_item_id = dm.inventory_item_id
        and   mis.sr_instance_id = dm.sr_instance_id
        and   mis.organization_id = dm.organization_id
        and   mis.plan_id = dm.plan_id
  and   dm.disposition_id     = p_transaction_id
  and   dm.plan_id               = p_plan_id
  and   dm.organization_id       = p_organization_id
  and   dm.sr_instance_id        = p_instance_id
  and   dm.origination_type   = 22;

BEGIN
 IF p_bom_item_type in (1, 2)  THEN  -- this means we just want to get Prod.Forecast of Options when we

                               -- drill down from ATO Model with Forecast control set to NONE

         i := 1;
	  open cur1(p_show_item_desc);
	  loop
	    exit when cur1%notfound;
	    fetch cur1 into
	       x_itemorg_pegnode_rec(i).Item_Org,
	       x_itemorg_pegnode_rec(i).Qty,
	       x_itemorg_pegnode_rec(i).Peg_date,
	       x_itemorg_pegnode_rec(i).Order_name,
	       x_itemorg_pegnode_rec(i).Prev_pegging_id,
	       x_itemorg_pegnode_rec(i).Demand_id,
	       x_itemorg_pegnode_rec(i).Pegged_qty,
	       x_itemorg_pegnode_rec(i).Item_id,
	       x_itemorg_pegnode_rec(i).order_type,
	       x_itemorg_pegnode_rec(i).order_number,
	       x_itemorg_pegnode_rec(i).Pegging_id,
	       x_itemorg_pegnode_rec(i).Transaction_id,
	       x_itemorg_pegnode_rec(i).end_demand_class;
	    i := i + 1;
	  end loop;
	  close cur1;
	  i := 0;
END IF;
END get_demtree_dem_values;


Procedure get_label_and_nodevalue(Item_org             IN VARCHAR2,
                                  Qty                  IN NUMBER,
                                  Pegged_qty           IN NUMBER,
                                  Peg_date             IN DATE,
                                  Order_name           IN VARCHAR2,
                                  end_demand_class     IN VARCHAR2,
                                  order_type           IN NUMBER,
                                  Disposition          IN NUMBER,
                                  Pegging_id           IN NUMBER,
                                  Prev_pegging_id      IN NUMBER,
                                  Demand_id            IN NUMBER,
                                  Transaction_id       IN NUMBER,
                                  Item_id              IN NUMBER,
                                  x_node_value          OUT NOCOPY VARCHAR2,
                                  x_node_label          OUT NOCOPY VARCHAR2,
                                  p_tmp                 IN  NUMBER,
                                  p_supply_org_id       IN  NUMBER,
                                  pvt_so_number         IN  VARCHAR2,
                                  pvt_l_node_number     IN  NUMBER,
                                  p_constr_label        IN  BOOLEAN default FALSE,
                                  p_node_type           IN  NUMBER  default 1,
                                  p_calling_module      IN  NUMBER  default 1 ,
				  p_prev_pegging_value  IN  NUMBER default null  )

-- p_calling_modele : 1- Planner WB, 2 - Allocation WB.

-- p_type_node 1 - Demand, 2-Supply
IS
BEGIN


IF p_constr_label THEN
   -- Constructing the label for demand nodes

   fnd_message.set_name('MSC','MSC_PEGGING_LABEL2');
   fnd_message.set_token('ITEM_ORG',Item_org);
   fnd_message.set_token('QTY',nvl(Qty,0));
   fnd_message.set_token('PEGGED_QTY',nvl(Pegged_qty,0));
   fnd_message.set_token('DATE',fnd_date.date_to_chardt(Peg_date));

   null;
  if p_node_type = 1  then -- Demand
    if ( p_tmp in (6,30) )   then
     -- 6 sales orders mds
     -- 30 sales order
     if p_calling_module = 1 then
     fnd_message.set_token('ORDER_TYPE',Order_name||' '||
                                        pvt_so_number);
     else
     null;
       fnd_message.set_token('ORDER_TYPE',Order_name||' '||
                                        pvt_so_number||end_demand_class);
     end if;
    elsif ( p_tmp in (8,29) ) then
      -- 8 manual mds
      -- 29 forecast
     if p_calling_module = 1 then

     fnd_message.set_token('ORDER_TYPE',Order_name||' '||
                                       pvt_so_number);
     else

        fnd_message.set_token('ORDER_TYPE',Order_name||' '||
                                        pvt_so_number||end_demand_class);
     end if;

    else
     fnd_message.set_token('ORDER_TYPE',Order_name);
    end if;
  else  -- Supply
     if order_type in ( 1,2,3, 73,74,86,75) THEN
      fnd_message.set_token('ORDER_TYPE',Order_name||' '||
                                pvt_so_number);
     else
       fnd_message.set_token('ORDER_TYPE',Order_name);
     end if;
  end if;
   x_node_label := fnd_message.get;
ELSE
   x_node_label := NULL;
END IF;
   IF p_calling_module  = 1 then
 -- Constructing the node value

     x_node_value := to_char(nvl(Pegging_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(Prev_pegging_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(Demand_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(Transaction_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(p_supply_org_id,-111))
                    ||fnd_global.local_chr(58)|| to_char(nvl(Pegging_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(Prev_pegging_id,-111));


     if p_node_type = 1  then  -- demand

      x_node_value := x_node_value
                    ||fnd_global.local_chr(58)||to_char(nvl(Demand_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(Item_id,-111))
                    ||fnd_global.local_chr(58)||' -111 '||fnd_global.local_chr(58)||to_char(pvt_l_node_number + 1);


     else
      x_node_value := x_node_value
                    ||fnd_global.local_chr(58)||to_char(nvl(Transaction_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(Item_id,-111))
                    ||fnd_global.local_chr(58)||to_char(nvl(p_prev_pegging_value ,-111))||fnd_global.local_chr(58)||to_char(pvt_l_node_number + 1);
---bug #3556405
    end if;
  ELSE
    if p_node_type  = 1 then -- expanding to demands nodes
     x_node_value :=   to_char(nvl(pegging_id,-111))
                ||' '||to_char(nvl(prev_pegging_id,-111))
                ||' '||to_char(nvl(demand_id,-111))
                ||' '||to_char(nvl(item_id,-111))
                ||' -111 '||pvt_l_node_number;
   else
     x_node_value := to_char(nvl(pegging_id,-111))||' '||
                     to_char(nvl(prev_pegging_id,-111))||' '||
                     to_char(nvl(transaction_id,-111))||' '||
                     to_char(nvl(item_id,-111))||' ';
   end if;

 END IF;

end get_label_and_nodevalue;

END MSC_UI_PEG_UTIL ;

/
