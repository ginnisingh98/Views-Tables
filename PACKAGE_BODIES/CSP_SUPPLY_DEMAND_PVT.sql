--------------------------------------------------------
--  DDL for Package Body CSP_SUPPLY_DEMAND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_SUPPLY_DEMAND_PVT" AS
/* $Header: cspvpsdb.pls 120.6 2006/11/08 00:18:33 hhaugeru noship $ */
/* $Header: cspvpsdb.pls 120.6 2006/11/08 00:18:33 hhaugeru noship $ */
G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_SUPPLY_DEMAND_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30):='cspvpsdb.pls';

PROCEDURE get_onhand IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 moq.inventory_item_id,
	     moq.organization_id,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
         moq.subinventory_code,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(csi.condition_type,'B',moq.transaction_quantity,null)),
		 sum(decode(csi.condition_type,'G',moq.transaction_quantity,null))
  from   mtl_onhand_quantities moq,
         csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where  csi.organization_id = moq.organization_id
  and    csi.secondary_inventory_name = moq.subinventory_code
  and    moq.inventory_item_id > 0
  and	 csi.organization_id = cpp.organization_id (+)
  and	 csi.secondary_inventory_name = cpp.secondary_inventory (+)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
         moq.organization_id,
         moq.subinventory_code,
         moq.inventory_item_id,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;

  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cssdt.parts_loop_id,
		 cssdt.hierarchy_node_id,
		 mmtt.subinventory_code,
		 cssdt.planning_parameters_id,
         cssdt.level_id,
		 sum(decode(cssdt.onhand_good,null,mmtt.primary_quantity,0)),
		 sum(decode(cssdt.onhand_bad,null,mmtt.primary_quantity,0))
  from 	 mtl_material_transactions_temp mmtt,
  	   	 csp_sup_dem_sub_temp cssdt,
		 csp_planning_parameters cpp
  where  mmtt.inventory_item_id = cssdt.inventory_item_id
  and 	 mmtt.organization_id = cssdt.organization_id
  and 	 mmtt.subinventory_code = cssdt.subinventory_code
  and 	 mmtt.posting_flag = 'Y'
  and 	 mmtt.subinventory_code IS NOT NULL
  and 	 nvl(mmtt.transaction_status,0) <> 2
  and 	 mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
  and 	 cpp.organization_id (+) = mmtt.organization_id
  and  	 cpp.secondary_inventory (+) = mmtt.subinventory_code
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cssdt.parts_loop_id,
		 cssdt.hierarchy_node_id,
		 mmtt.subinventory_code,
		 cssdt.planning_parameters_id,
		 cssdt.level_id;

END get_onhand;

PROCEDURE get_onhand2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 moq.inventory_item_id,
	     moq.organization_id,
         moq.subinventory_code,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(csi.condition_type,'B',moq.transaction_quantity,null)),
		 sum(decode(csi.condition_type,'G',moq.transaction_quantity,null))
  from   mtl_onhand_quantities moq,
         csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where  csi.organization_id = moq.organization_id
  and    csi.secondary_inventory_name = moq.subinventory_code
  and    moq.inventory_item_id > 0
  and	 csi.organization_id = cpp.organization_id
  and	 csi.secondary_inventory_name = cpp.secondary_inventory
  and    cpp.level_id like g_level_id||'%'
  group by
         moq.organization_id,
         moq.subinventory_code,
         moq.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;

  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 mmtt.subinventory_code,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(csi.condition_type,'B',mmtt.primary_quantity,0)),
		 sum(decode(csi.condition_type,'G',mmtt.primary_quantity,0))
  from 	 mtl_material_transactions_temp mmtt,
  	   	 csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where    mmtt.organization_id = csi.organization_id
  and 	 mmtt.subinventory_code = csi.secondary_inventory_name
  and 	 mmtt.posting_flag = 'Y'
  and 	 mmtt.subinventory_code IS NOT NULL
  and 	 nvl(mmtt.transaction_status,0) <> 2
  and 	 mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
  and 	 cpp.organization_id = mmtt.organization_id
  and  	 cpp.secondary_inventory = mmtt.subinventory_code
  and      cpp.level_id like g_level_id||'%'
  group by
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 mmtt.subinventory_code,
		 cpp.planning_parameters_id,
		 cpp.level_id;

END get_onhand2;

PROCEDURE get_onhand_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_good)
  select
		 moq.inventory_item_id,
	     moq.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(moq.transaction_quantity)
  from   mtl_onhand_quantities moq,
		 csp_planning_parameters cpp
  where  moq.inventory_item_id > 0
  and	 cpp.organization_id = moq.organization_id
  and    cpp.organization_type = 'W'
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
		 moq.inventory_item_id,
	     moq.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;

  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_good)
  select
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(mmtt.primary_quantity,0))
  from 	 mtl_material_transactions_temp mmtt,
  	   	 csp_planning_parameters cpp
  where  mmtt.organization_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and 	 mmtt.posting_flag = 'Y'
  and 	 mmtt.subinventory_code IS NOT NULL
  and 	 nvl(mmtt.transaction_status,0) <> 2
  and 	 mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_onhand_wh;

PROCEDURE get_onhand_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_good)
  select
		 moq.inventory_item_id,
	     moq.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(moq.transaction_quantity)
  from   mtl_onhand_quantities moq,
		 csp_planning_parameters cpp
  where  cpp.organization_id = moq.organization_id
  and    cpp.node_type = 'ORGANIZATION_WH'
  and    cpp.organization_type = 'W'
  and    cpp.level_id like g_level_id||'%'
  group by
		 moq.inventory_item_id,
	     moq.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;

  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_good)
  select
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(mmtt.primary_quantity,0))
  from 	 mtl_material_transactions_temp mmtt,
  	   	 csp_planning_parameters cpp
  where  mmtt.organization_id = cpp.organization_id
  and    cpp.node_type = 'ORGANIZATION_WH'
  and	 cpp.organization_type = 'W'
  and 	 mmtt.posting_flag = 'Y'
  and 	 mmtt.subinventory_code IS NOT NULL
  and 	 nvl(mmtt.transaction_status,0) <> 2
  and 	 mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
  and    cpp.level_id like g_level_id||'%'
  group by
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_onhand_wh2;

PROCEDURE get_defective_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 moq.inventory_item_id,
	     moq.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(moq.transaction_quantity),
		 sum(moq.transaction_quantity)*-1
  from   mtl_onhand_quantities moq,
         csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where  csi.organization_id = moq.organization_id
  and    csi.secondary_inventory_name = moq.subinventory_code
  and	 csi.condition_type = 'B'
  and    moq.inventory_item_id > 0
  and	 csi.organization_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
         moq.organization_id,
         moq.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;

  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(mmtt.primary_quantity,0)),
		 sum(nvl(mmtt.primary_quantity,0)) * -1
  from 	 mtl_material_transactions_temp mmtt,
  		 csp_sec_inventories csi,
  	   	 csp_planning_parameters cpp
  where  mmtt.organization_id = cpp.organization_id
  and 	 cpp.organization_type = 'W'
  and	 csi.condition_type = 'B'
  and	 csi.organization_id = cpp.organization_id
  and 	 mmtt.posting_flag = 'Y'
  and 	 mmtt.subinventory_code = csi.secondary_inventory_name
  and 	 nvl(mmtt.transaction_status,0) <> 2
  and 	 mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
	  cpp.level_id;
END get_defective_wh;

PROCEDURE get_defective_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 moq.inventory_item_id,
	     moq.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(moq.transaction_quantity),
		 sum(moq.transaction_quantity)*-1
  from   mtl_onhand_quantities moq,
         csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where  csi.organization_id = moq.organization_id
  and    csi.secondary_inventory_name = moq.subinventory_code
  and	 csi.condition_type = 'B'
  and    moq.inventory_item_id > 0
  and	 csi.organization_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    cpp.node_type = 'ORGANIZATION_WH'
  and    cpp.level_id like g_level_id||'%'
  group by
         moq.organization_id,
         moq.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;

  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 onhand_bad,
      	 onhand_good)
  select
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(mmtt.primary_quantity,0)),
		 sum(nvl(mmtt.primary_quantity,0)) * -1
  from 	 mtl_material_transactions_temp mmtt,
  		 csp_sec_inventories csi,
  	   	 csp_planning_parameters cpp
  where  mmtt.organization_id = cpp.organization_id
  and    mmtt.subinventory_code = csi.secondary_inventory_name
  and	 csi.organization_id = cpp.organization_id
  and	 csi.condition_type = 'B'
  and 	 cpp.organization_type = 'W'
  and    cpp.node_type = 'ORGANIZATION_WH'
  and 	 mmtt.posting_flag = 'Y'
  and 	 nvl(mmtt.transaction_status,0) <> 2
  and 	 mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
		 mmtt.inventory_item_id,
		 mmtt.organization_id,
		 cpp.planning_parameters_id,
	  cpp.level_id;
END get_defective_wh2;

PROCEDURE get_supply IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 purchase_orders,
      	 interorg_transf_in,
		 requisitions,
		 intransit_move_orders)
  select
		 ms.item_id,
       	 ms.to_organization_id,
		 csi.parts_loop_id,
		 csi.hierarchy_node_id,
		 ms.to_subinventory,
	 	 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(ms.supply_type_code,'PO',to_org_primary_quantity,'RECEIVING',to_org_primary_quantity,0)) purchase_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(prha.transferred_to_oe_flag,'Y',decode(prha.type_lookup_code,'INTERNAL',to_org_primary_quantity),0),0)) internal_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(nvl(prha.transferred_to_oe_flag,'N'),'N',to_org_primary_quantity,0),0)) requisitions,
		 sum(decode(ms.supply_type_code,'SHIPMENT',to_org_primary_quantity,0)) interorg_transfer
from   	 mtl_supply ms,
       	 po_requisition_headers_all prha,
       	 csp_sec_inventories csi,
       	 csp_planning_parameters cpp
where  	 ms.req_header_id = prha.requisition_header_id(+)
and    	 ms.to_organization_id = csi.organization_id
and    	 ms.to_subinventory = csi.secondary_inventory_name
and    	 cpp.organization_id (+) = csi.organization_id
and    	 cpp.secondary_inventory (+) = csi.secondary_inventory_name
and    	 nvl(cpp.level_id,'%') like g_level_id||'%'
group by
         ms.item_id,
       	 ms.to_organization_id,
       	 ms.to_subinventory,
       	 csi.parts_loop_id,
       	 csi.hierarchy_node_id,
       	 cpp.planning_parameters_id,
		 cpp.level_id;
end get_supply;

PROCEDURE get_supply2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 purchase_orders,
      	 interorg_transf_in,
		 requisitions,
		 intransit_move_orders)
  select
		 ms.item_id,
       	 ms.to_organization_id,
		 ms.to_subinventory,
	 	 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(ms.supply_type_code,'PO',to_org_primary_quantity,'RECEIVING',to_org_primary_quantity,0)) purchase_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(prha.transferred_to_oe_flag,'Y',decode(prha.type_lookup_code,'INTERNAL',to_org_primary_quantity),0),0)) internal_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(nvl(prha.transferred_to_oe_flag,'N'),'N',to_org_primary_quantity,0),0)) requisitions,
		 sum(decode(ms.supply_type_code,'SHIPMENT',to_org_primary_quantity,0)) interorg_transfer
from   	 mtl_supply ms,
       	 po_requisition_headers_all prha,
       	 csp_planning_parameters cpp
  where  ms.req_header_id = prha.requisition_header_id(+)
  and    ms.to_organization_id = cpp.organization_id
  and    ms.to_subinventory = cpp.secondary_inventory
  and    cpp.level_id like g_level_id||'%'
  group by
         ms.item_id,
       	 ms.to_organization_id,
       	 ms.to_subinventory,
       	 cpp.planning_parameters_id,
		 cpp.level_id;
end get_supply2;

PROCEDURE get_supply_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 purchase_orders,
      	 interorg_transf_in,
		 requisitions,
		 intransit_move_orders)
  select
		 ms.item_id,
       	 ms.to_organization_id,
	 	 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(ms.supply_type_code,'PO',to_org_primary_quantity,'RECEIVING',to_org_primary_quantity,0)) purchase_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(prha.transferred_to_oe_flag,'Y',decode(prha.type_lookup_code,'INTERNAL',to_org_primary_quantity),0),0)) internal_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(nvl(prha.transferred_to_oe_flag,'N'),'N',to_org_primary_quantity,0),0)) requisitions,
		 sum(decode(ms.supply_type_code,'SHIPMENT',to_org_primary_quantity,0)) interorg_transfer
from   	 mtl_supply ms,
       	 po_requisition_headers_all prha,
       	 csp_planning_parameters cpp
where  	 ms.req_header_id = prha.requisition_header_id(+)
and    	 cpp.organization_id = ms.to_organization_id
and		 cpp.organization_type = 'W'
and		 ms.item_id > 0
and    	 nvl(cpp.level_id,'%') like g_level_id||'%'
group by
		 ms.item_id,
       	 ms.to_organization_id,
	 	 cpp.planning_parameters_id,
		 cpp.level_id;
end get_supply_wh;

PROCEDURE get_supply_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 purchase_orders,
      	 interorg_transf_in,
		 requisitions,
		 intransit_move_orders)
  select
		 ms.item_id,
       	 ms.to_organization_id,
	 	 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(ms.supply_type_code,'PO',to_org_primary_quantity,'RECEIVING',to_org_primary_quantity,0)) purchase_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(prha.transferred_to_oe_flag,'Y',decode(prha.type_lookup_code,'INTERNAL',to_org_primary_quantity),0),0)) internal_orders,
		 sum(decode(ms.supply_type_code,'REQ',decode(nvl(prha.transferred_to_oe_flag,'N'),'N',to_org_primary_quantity,0),0)) requisitions,
		 sum(decode(ms.supply_type_code,'SHIPMENT',to_org_primary_quantity,0)) interorg_transfer
from   	 mtl_supply ms,
       	 po_requisition_headers_all prha,
       	 csp_planning_parameters cpp
where  	 ms.req_header_id = prha.requisition_header_id(+)
and    	 ms.to_organization_id = cpp.organization_id
and		 ms.item_id > 0
and		 cpp.organization_type = 'W'
and      cpp.node_type = 'ORGANIZATION_WH'
and    	 cpp.level_id like g_level_id||'%'
group by
		 ms.item_id,
       	 ms.to_organization_id,
	 	 cpp.planning_parameters_id,
		 cpp.level_id;
end get_supply_wh2;

PROCEDURE get_internal_orders_out_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 interorg_transf_out)
  select
		 ms.item_id,
       	 ms.from_organization_id,
	 	 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(ms.supply_type_code,'REQ',decode(prha.transferred_to_oe_flag,'Y',decode(prha.type_lookup_code,'INTERNAL',to_org_primary_quantity),0),0))
from   	 mtl_supply ms,
       	 po_requisition_headers_all prha,
       	 csp_planning_parameters cpp
where  	 ms.req_header_id = prha.requisition_header_id
and    	 cpp.organization_id = ms.from_organization_id
and		 cpp.organization_type = 'W'
and		 ms.item_id > 0
and    	 nvl(cpp.level_id,'%') like g_level_id||'%'
group by
		 ms.item_id,
       	 ms.from_organization_id,
	 	 cpp.planning_parameters_id,
		 cpp.level_id;
end get_internal_orders_out_wh;

PROCEDURE get_internal_orders_out_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 interorg_transf_out)
  select
		 ms.item_id,
       	 ms.from_organization_id,
	 	 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(decode(ms.supply_type_code,'REQ',decode(prha.transferred_to_oe_flag,'Y',decode(prha.type_lookup_code,'INTERNAL',to_org_primary_quantity),0),0))
from   	 mtl_supply ms,
       	 po_requisition_headers_all prha,
       	 csp_planning_parameters cpp
where  	 prha.requisition_header_id = ms.req_header_id
and      prha.transferred_to_oe_flag= 'Y'
and      prha.type_lookup_code = 'INTERNAL'
and    	 ms.from_organization_id = cpp.organization_id
and      ms.supply_type_code = 'REQ'
and		 cpp.organization_type = 'W'
and      cpp.node_type = 'ORGANIZATION_WH'
and    	 cpp.level_id like g_level_id||'%'
group by
		 ms.item_id,
       	 ms.from_organization_id,
	 	 cpp.planning_parameters_id,
		 cpp.level_id;
end get_internal_orders_out_wh2;

PROCEDURE get_open_work_orders IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 work_orders)
  select
         wdj.primary_item_id,
         wdj.organization_id,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
         csi.secondary_inventory_name,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(start_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped, 0))
  from   wip_discrete_jobs wdj,
         wip_entities we,
         csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where  wdj.status_type = 3
  and    we.wip_entity_id = wdj.wip_entity_id
  and    we.entity_type <> 6
  and    wdj.completion_subinventory = csi.secondary_inventory_name
  and    wdj.organization_id = csi.organization_id
  and	 csi.organization_id = cpp.organization_id (+)
  and	 csi.secondary_inventory_name = cpp.secondary_inventory (+)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  and    wdj.primary_item_id > 0
  group by
  		 wdj.primary_item_id,
         wdj.organization_id,
         csi.secondary_inventory_name,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_open_work_orders;

PROCEDURE get_open_work_orders2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 work_orders)
  select
         wdj.primary_item_id,
         wdj.organization_id,
         cpp.secondary_inventory,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(start_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped, 0))
  from   wip_discrete_jobs wdj,
         wip_entities we,
		 csp_planning_parameters cpp
  where  wdj.status_type = 3
  and    we.wip_entity_id = wdj.wip_entity_id
  and    we.entity_type <> 6
  and    wdj.completion_subinventory = cpp.secondary_inventory
  and    wdj.organization_id = cpp.organization_id
  and    cpp.level_id like g_level_id||'%'
  and    wdj.primary_item_id > 0
  group by
  		 wdj.primary_item_id,
         wdj.organization_id,
         cpp.secondary_inventory,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_open_work_orders2;

PROCEDURE get_open_work_orders_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 work_orders)
  select
         wdj.primary_item_id,
         wdj.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(start_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped, 0))
  from   wip_discrete_jobs wdj,
         wip_entities we,
         csp_planning_parameters cpp
  where  wdj.status_type = 3
  and    we.wip_entity_id = wdj.wip_entity_id
  and    we.entity_type <> 6
  and    wdj.organization_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  and    wdj.primary_item_id > 0
  group by
  		 wdj.primary_item_id,
         wdj.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_open_work_orders_wh;

PROCEDURE get_open_work_orders_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 work_orders)
  select
         wdj.primary_item_id,
         wdj.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(start_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped, 0))
  from   wip_discrete_jobs wdj,
         wip_entities we,
         csp_planning_parameters cpp
  where  wdj.status_type = 3
  and    we.wip_entity_id = wdj.wip_entity_id
  and    we.entity_type <> 6
  and    wdj.organization_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    cpp.node_type = 'ORGANIZATION_WH'
  and    cpp.level_id like g_level_id||'%'
  and    wdj.primary_item_id > 0
  group by
  		 wdj.primary_item_id,
         wdj.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_open_work_orders_wh2;

PROCEDURE get_move_orders_in IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 move_orders_in)
  select
         mtrl.inventory_item_id,
		 csi.organization_id,
		 csi.parts_loop_id,
		 csi.hierarchy_node_id,
		 csi.secondary_inventory_name,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
                                        greatest(greatest(nvl(mtrl.quantity_detailed,0),nvl(mtrl.quantity,0))-nvl(mtrl.quantity_delivered,0),0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null))
  from  mtl_txn_request_lines mtrl,
        csp_sec_inventories csi,
        mtl_system_items_b msib,
		csp_planning_parameters cpp
  where mtrl.organization_id        = csi.organization_id
  and   mtrl.organization_id        = msib.organization_id
  and   mtrl.inventory_item_id      = msib.inventory_item_id
  and   mtrl.to_subinventory_code   = csi.secondary_inventory_name
  and   mtrl.line_status            in (3,7)
  and	csi.organization_id = cpp.organization_id (+)
  and	csi.secondary_inventory_name = cpp.secondary_inventory (+)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by csi.organization_id,
        csi.secondary_inventory_name,
        mtrl.inventory_item_id,
        csi.parts_loop_id,
        csi.hierarchy_node_id,
	   cpp.planning_parameters_id,
 	   cpp.level_id;
END get_move_orders_in;

PROCEDURE get_move_orders_in2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 move_orders_in)
  select
         mtrl.inventory_item_id,
		 cpp.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
								greatest(greatest(nvl(mtrl.quantity_detailed,0),nvl(mtrl.quantity,0))-nvl(mtrl.quantity_delivered,0),0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null))
  from  mtl_txn_request_lines mtrl,
        mtl_system_items_b msib,
		csp_planning_parameters cpp
  where mtrl.to_organization_id      = cpp.organization_id
  and   mtrl.to_subinventory_code    = cpp.secondary_inventory
  and   mtrl.line_status             in (3,7)
  and   msib.organization_id         = cpp.organization_id
  and   msib.inventory_item_id       = mtrl.inventory_item_id
  and   cpp.level_id like g_level_id||'%'
  group by cpp.organization_id,
        cpp.secondary_inventory,
        mtrl.inventory_item_id,
	    cpp.planning_parameters_id,
 	    cpp.level_id;
END get_move_orders_in2;

PROCEDURE get_move_orders_out IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 move_orders_out)
  select
         mtrl.inventory_item_id,
		 csi.organization_id,
		 csi.parts_loop_id,
		 csi.hierarchy_node_id,
		 csi.secondary_inventory_name,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
                                        greatest(greatest(nvl(mtrl.quantity_detailed,0),nvl(mtrl.quantity,0))-nvl(mtrl.quantity_delivered,0),0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null))
  from  mtl_txn_request_lines mtrl,
        csp_sec_inventories csi,
        mtl_system_items_b msib,
		csp_planning_parameters cpp
  where mtrl.organization_id        = csi.organization_id
  and   mtrl.organization_id        = msib.organization_id
  and   mtrl.inventory_item_id      = msib.inventory_item_id
  and   mtrl.from_subinventory_code   = csi.secondary_inventory_name
  and   mtrl.line_status            in (3,7)
  and	csi.organization_id = cpp.organization_id (+)
  and	csi.secondary_inventory_name = cpp.secondary_inventory (+)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by csi.organization_id,
        csi.secondary_inventory_name,
        mtrl.inventory_item_id,
        csi.parts_loop_id,
        csi.hierarchy_node_id,
		cpp.planning_parameters_id,
		cpp.level_id;
END get_move_orders_out;

PROCEDURE get_move_orders_out2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 move_orders_out)
  select
         mtrl.inventory_item_id,
		 cpp.organization_id,
		 cpp.secondary_inventory,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
								greatest(greatest(nvl(mtrl.quantity_detailed,0),nvl(mtrl.quantity,0))-nvl(mtrl.quantity_delivered,0),0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null))
  from  mtl_txn_request_lines mtrl,
        mtl_system_items_b msib,
		csp_planning_parameters cpp
  where mtrl.organization_id        = cpp.organization_id
  and   mtrl.organization_id        = msib.organization_id
  and   mtrl.inventory_item_id      = msib.inventory_item_id
  and   mtrl.from_subinventory_code   = cpp.secondary_inventory
  and   mtrl.line_status            in (3,7)
  and   cpp.level_id like g_level_id||'%'
  group by cpp.organization_id,
        cpp.secondary_inventory,
        mtrl.inventory_item_id,
		cpp.planning_parameters_id,
		cpp.level_id;
END get_move_orders_out2;

PROCEDURE get_move_orders_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 move_orders_in,
		 move_orders_out)
  select
         mtrl.inventory_item_id,
		 cpp.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
                                        nvl(mtrl.quantity,0)-nvl(mtrl.quantity_delivered,0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null)),
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
                                        nvl(mtrl.quantity,0)-nvl(mtrl.quantity_delivered,0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null))
  from  mtl_txn_request_lines mtrl,
        mtl_system_items_b msib,
		csp_planning_parameters cpp
  where mtrl.organization_id        = cpp.organization_id
  and   mtrl.organization_id        = msib.organization_id
  and   mtrl.inventory_item_id      = msib.inventory_item_id
  and   mtrl.line_status            in (3,7)
  and	cpp.organization_type = 'W'
  and   nvl(cpp.level_id,'%') like g_level_id||'%'
  group by cpp.organization_id,
        mtrl.inventory_item_id,
		cpp.planning_parameters_id,
		cpp.level_id;
END get_move_orders_wh;

PROCEDURE get_move_orders_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 move_orders_in,
		 move_orders_out)
  select
         mtrl.inventory_item_id,
		 cpp.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
                                        nvl(mtrl.quantity,0)-nvl(mtrl.quantity_delivered,0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null)),
		 sum(inv_convert.inv_um_convert(mtrl.inventory_item_id,
                                        null,
                                        nvl(mtrl.quantity,0)-nvl(mtrl.quantity_delivered,0),
                                        mtrl.uom_code,
                                        msib.primary_uom_code,
                                        null,
                                        null))
  from  mtl_txn_request_lines mtrl,
        mtl_system_items_b msib,
		csp_planning_parameters cpp
  where mtrl.organization_id        = cpp.organization_id
  and   mtrl.organization_id        = msib.organization_id
  and   mtrl.inventory_item_id      = msib.inventory_item_id
  and   mtrl.line_status            in (3,7)
  and   cpp.node_type = 'ORGANIZATION_WH'
  and	cpp.organization_type = 'W'
  and   cpp.level_id like g_level_id||'%'
  group by cpp.organization_id,
        mtrl.inventory_item_id,
		cpp.planning_parameters_id,
		cpp.level_id;
END get_move_orders_wh2;

PROCEDURE get_orders_out IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 sales_orders,
		 interorg_transf_out)
  select
         ola.inventory_item_id,
		 csi.organization_id,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
         csi.secondary_inventory_name,
		 cpp.planning_parameters_id,
         cpp.level_id,
	decode(ola.order_source_id,10,0,
		  sum(nvl(ola.ordered_quantity,0) -
		      nvl(ola.cancelled_quantity,0) -
			 nvl(ola.shipped_quantity,0))) sales_orders,
	decode(ola.order_source_id,10,
		  sum(nvl(ola.ordered_quantity,0) -
		      nvl(ola.cancelled_quantity,0) -
			 nvl(ola.shipped_quantity,0)),0) internal_orders_out
  from   oe_order_lines_all              ola,
         csp_sec_inventories             csi,
		 csp_planning_parameters		 cpp
  where  ola.ship_from_org_id  =  csi.organization_id
  and    ola.subinventory      =  csi.secondary_inventory_name
  and    ola.open_flag         =  'Y'
  and	 csi.organization_id = cpp.organization_id (+)
  and	 csi.secondary_inventory_name = cpp.secondary_inventory (+)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
         csi.organization_id,
         csi.secondary_inventory_name,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
         ola.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id,
		 ola.order_source_id;
END get_orders_out;

PROCEDURE get_orders_out2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 sales_orders,
		 interorg_transf_out)
  select
         ola.inventory_item_id,
		 cpp.organization_id,
         cpp.secondary_inventory,
		 cpp.planning_parameters_id,
         cpp.level_id,
	decode(ola.order_source_id,10,0,
		  sum(nvl(ola.ordered_quantity,0) -
		      nvl(ola.cancelled_quantity,0) -
			 nvl(ola.shipped_quantity,0))) sales_orders,
	decode(ola.order_source_id,10,
		  sum(nvl(ola.ordered_quantity,0) -
		      nvl(ola.cancelled_quantity,0) -
			 nvl(ola.shipped_quantity,0)),0) internal_orders_out
  from   oe_order_lines_all              ola,
		 csp_planning_parameters		 cpp
  where  ola.ship_from_org_id  =  cpp.organization_id
  and    ola.subinventory      =  cpp.secondary_inventory
  and    ola.open_flag         =  'Y'
  and    cpp.level_id like g_level_id||'%'
  group by
         cpp.organization_id,
         cpp.secondary_inventory,
         ola.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id,
		 ola.order_source_id;
END get_orders_out2;

PROCEDURE get_excess IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
      	 excess_quantity)
  select
         cel.inventory_item_id,
         cel.organization_id,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
         cel.subinventory_code,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(excess_quantity,0))
  from   csp_excess_lists cel,
         csp_sec_inventories csi,
		 csp_planning_parameters cpp
  where  cel.condition_code = 'G'
  and    cel.excess_status = 'O'
  and    cel.subinventory_code = csi.secondary_inventory_name
  and    cel.organization_id = csi.organization_id
  and	 csi.organization_id = cpp.organization_id (+)
  and	 csi.secondary_inventory_name = cpp.secondary_inventory (+)
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
  		 cel.inventory_item_id,
         cel.organization_id,
         cel.subinventory_code,
         csi.parts_loop_id,
         csi.hierarchy_node_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_excess;

PROCEDURE get_excess_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 excess_quantity)
  select
         cel.inventory_item_id,
         cel.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
         sum(cel.excess_quantity)
  from   csp_excess_lists cel,
         csp_planning_parameters cpp
  where  cel.condition_code = 'G'
  and    cel.excess_status = 'O'
  and    cel.subinventory_code is null
  and    cel.organization_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
  		 cel.inventory_item_id,
         cel.organization_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_excess_wh;


PROCEDURE get_open_sales_orders_wh IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 sales_orders)
  select
         ola.inventory_item_id,
		 cpp.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(ola.ordered_quantity,0) -
		     nvl(ola.cancelled_quantity,0) -
			 nvl(ola.shipped_quantity,0))
  from   oe_order_lines_all              ola,
		 csp_planning_parameters		 cpp
  where  ola.ship_from_org_id  =  cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    ola.open_flag         =  'Y'
  and    nvl(ola.order_source_id,0) <> 10
  and    nvl(cpp.level_id,'%') like g_level_id||'%'
  group by
         cpp.organization_id,
         ola.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_open_sales_orders_wh;

PROCEDURE get_open_sales_orders_wh2 IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
	  	 planning_parameters_id,
         level_id,
      	 sales_orders)
  select
         ola.inventory_item_id,
		 cpp.organization_id,
		 cpp.planning_parameters_id,
         cpp.level_id,
		 sum(nvl(ola.ordered_quantity,0) -
		     nvl(ola.cancelled_quantity,0) -
			 nvl(ola.shipped_quantity,0))
  from   oe_order_lines_all              ola,
		 csp_planning_parameters		 cpp
  where  ola.ship_from_org_id = cpp.organization_id
  and	 cpp.organization_type = 'W'
  and    cpp.node_type = 'ORGANIZATION_WH'
  and    ola.open_flag = 'Y'
  and    nvl(ola.order_source_id,0) <> 10
  and    cpp.level_id like g_level_id||'%'
  group by
         cpp.organization_id,
         ola.inventory_item_id,
		 cpp.planning_parameters_id,
		 cpp.level_id;
END get_open_sales_orders_wh2;

PROCEDURE mv_to_temp IS
begin
  insert into csp_sup_dem_sub_temp(
      	 inventory_item_id,
      	 organization_id,
      	 parts_loop_id,
      	 hierarchy_node_id,
      	 subinventory_code,
	  	 planning_parameters_id,
         level_id,
         purchase_orders,
         sales_orders,
         requisitions,
         interorg_transf_in,
         onhand_good,
         onhand_bad,
         intransit_move_orders,
         interorg_transf_out,
         move_orders_in,
         move_orders_out,
         work_orders,
         excess_quantity)
  select
         inventory_item_id,
         organization_id,
         parts_loop_id,
         hierarchy_node_id,
         subinventory_code,
         planning_parameters_id,
         level_id,
         purchase_orders,
         sales_orders,
         requisitions,
         interorg_transf_in,
         onhand_good,
         onhand_bad,
         intransit_move_orders,
         interorg_transf_out,
         move_orders_in,
         move_orders_out,
         work_orders,
         excess_quantity
  from   csp_sup_dem_sub_mv
  where  nvl(level_id,'a') not like g_level_id||'%';
end mv_to_temp;

--------------------------------------------------------------------

/*  update_hierarchy    */

--------------------------------------------------------------------

PROCEDURE update_hierarchy IS
  l_level                       number := 1;
begin
  l_level := 1;
--subinventories to parent
  insert into csp_sup_dem_rh_temp(
         level_id,
         organization_id,
      	 inventory_item_id,
      	 hierarchy_node_id,
      	 purchase_orders,
      	 sales_orders,
		 requisitions,
		 interorg_transf_in,
		 onhand_good,
		 onhand_bad,
		 intransit_move_orders,
		 interorg_transf_out,
		 move_orders_in,
		 move_orders_out,
		 work_orders)
  select l_level,
         min(organization_id),
		 inventory_item_id,
		 hierarchy_node_id,
		 sum(nvl(purchase_orders,0)),
		 sum(nvl(sales_orders,0)),
		 sum(nvl(requisitions,0)),
		 sum(nvl(interorg_transf_in,0)),
		 sum(nvl(onhand_good,0)),
		 sum(nvl(onhand_bad,0)),
		 sum(nvl(intransit_move_orders,0)),
		 sum(nvl(interorg_transf_out,0)),
		 sum(nvl(move_orders_in,0)),
		 sum(nvl(move_orders_out,0)),
		 sum(nvl(work_orders,0))
  from	 csp_sup_dem_sub_mv
  where  hierarchy_node_id > 0
  group by
		 inventory_item_id,
		 hierarchy_node_id;
  loop
-- node to parent
      insert into csp_sup_dem_rh_temp(
             level_id,
             organization_id,
          	 inventory_item_id,
          	 hierarchy_node_id,
          	 purchase_orders,
          	 sales_orders,
    		 requisitions,
    		 interorg_transf_in,
    		 onhand_good,
    		 onhand_bad,
    		 intransit_move_orders,
    		 interorg_transf_out,
    		 move_orders_in,
    		 move_orders_out,
    		 work_orders)
      select l_level+1,
             min(ctsd.organization_id),
    		 inventory_item_id,
    		 parent_node_id,
    		 sum(nvl(purchase_orders,0)),
    		 sum(nvl(sales_orders,0)),
    		 sum(nvl(requisitions,0)),
    		 sum(nvl(interorg_transf_in,0)),
    		 sum(nvl(onhand_good,0)),
    		 sum(nvl(onhand_bad,0)),
    		 sum(nvl(intransit_move_orders,0)),
    		 sum(nvl(interorg_transf_out,0)),
    		 sum(nvl(move_orders_in,0)),
    		 sum(nvl(move_orders_out,0)),
    		 sum(nvl(work_orders,0))
      from	 csp_sup_dem_rh_temp ctsd,
             csp_rep_hierarchies crh
      where  level_id = l_level
      and    crh.hierarchy_node_id = ctsd.hierarchy_node_id
      and    crh.parent_node_id > 0
      group by
    		 inventory_item_id,
    		 parent_node_id;
      if sql%notfound then
        exit;
      end if;
      l_level := l_level+1;
  end loop;
  dbms_snapshot.refresh('csp_sup_dem_rh_mv','C');

end update_hierarchy;

procedure summarize_information is
begin
  dbms_snapshot.refresh('csp_sup_dem_sub_mv','C');
end summarize_information;

PROCEDURE update_parts_loop IS
begin
  dbms_snapshot.refresh('csp_sup_dem_pl_mv','C',atomic_refresh => false);
end update_parts_loop;

procedure update_planning_nodes is
begin
  dbms_snapshot.refresh('csp_sup_dem_pn_mv','C',atomic_refresh => false);
end update_planning_nodes;


-----------------------------------------------------------------
PROCEDURE main
(
    errbuf                  OUT nocopy VARCHAR2,
    retcode                 OUT nocopy NUMBER,
    p_api_version           IN  NUMBER,
    p_organization_id	    IN  NUMBER,
	p_level_id				IN	VARCHAR2 default null
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'main';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_cursor                      NUMBER;
  l_ddl_string                  VARCHAR2(100);

BEGIN
  g_level_id := p_level_id;

  if g_level_id is null then
--    get_excess;
--    get_excess_wh;
    get_onhand;
    get_onhand_wh;
    get_defective_wh;
    get_supply;
    get_supply_wh;
    get_internal_orders_out_wh;
    get_move_orders_in;
    get_move_orders_out;
	get_move_orders_wh;
    get_orders_out;
    get_open_sales_orders_wh;
    get_open_work_orders;
    get_open_work_orders_wh;
    summarize_information;
    update_parts_loop;
    update_hierarchy;
    update_planning_nodes;
  else
    mv_to_temp;
    get_onhand2;
    get_onhand_wh2;
    get_defective_wh2;
    get_supply2;
    get_supply_wh2;
    get_internal_orders_out_wh2;
    get_move_orders_in2;
    get_move_orders_out2;
	get_move_orders_wh2;
    get_orders_out2;
    get_open_sales_orders_wh2;
    get_open_work_orders2;
    get_open_work_orders_wh2;
    summarize_information;
    update_planning_nodes;
  end if;

  commit;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       null;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       null;
    WHEN OTHERS THEN
        retcode := 3;
        errbuf := sqlerrm;
        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME  ,
                        l_api_name
                );
        END IF;
END main;
END CSP_SUPPLY_DEMAND_PVT;

/
