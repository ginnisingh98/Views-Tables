--------------------------------------------------------
--  DDL for Package Body MRP_GET_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GET_ONHAND" AS
/* $Header: MRPGEOHB.pls 120.0 2005/05/24 19:18:55 appldev noship $ */

-- =========== Private Functions =============

PROCEDURE LOG_ERROR(
pBUFF   IN  VARCHAR2)
IS
BEGIN
   IF fnd_global.conc_request_id > 0  THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
	ELSE
	  null;
	  --DBMS_OUTPUT.PUT_LINE( pBUFF);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
	  RETURN;
END LOG_ERROR;

PROCEDURE LOG_DEBUG(
pBUFF   IN  VARCHAR2)
IS
BEGIN

   IF (G_MRP_DEBUG = 'Y') THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
	ELSE
	  NULL;
	  --DBMS_OUTPUT.PUT_LINE( pBUFF);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
	  RETURN;
END LOG_DEBUG;

PROCEDURE GET_OH_QTY(item_id IN NUMBER, org_id IN NUMBER,
                        include_nonnet IN NUMBER,
                        x_qoh OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_data OUT NOCOPY VARCHAR2) is


      l_onhand_source     NUMBER := 3;
      l_sysdate           DATE;
      l_vmi_enabled       VARCHAR2(1);
      l_supplier_consigned_enabled VARCHAR2(1);
      l_stmt              VARCHAR2(10000);

   BEGIN

      /* Initialize date stuff  */
        select sysdate
        into l_sysdate
        from sys.dual;


      IF (include_nonnet = 1) THEN

             l_onhand_source := NULL;
      ELSE
             l_onhand_source := 2;
      END IF;

      l_supplier_consigned_enabled := NVL(fnd_profile.value('INV_SUPPLIER_CONSIGNED_ENABLED'),'N');
      l_vmi_enabled := NVL(fnd_profile.value('INV_VMI_ENABLED'),'N');

  if l_supplier_consigned_enabled = 'Y' then

     l_stmt := 'declare '||
                    'x_return_status varchar2(20); '||
                    'x_msg_count number; '||
                    'x_msg_data varchar2(1000); '||
                    'x_planning_qty NUMBER; '||
               'begin '||
                 'INV_CONSIGNED_VALIDATIONS_GRP.GET_PLANNING_QUANTITY( '||
                 '  x_return_status       => x_return_status '||
                 ', x_msg_count          => x_msg_count '||
                 ', x_msg_data           => x_msg_data '||
                 ', P_INCLUDE_NONNET  => :include_nonnet '||
                 ', P_LEVEL           => 1 '||
                 ', P_ORG_ID          => :org_id '||
                 ', P_SUBINV          => NULL '||
                 ', P_ITEM_ID         => :item_id '||
                 ', x_planning_qty    => x_planning_qty '||'); '||
          ' MRP_GET_ONHAND.g_x_return_status := x_return_status; '||
          ' MRP_GET_ONHAND.g_x_msg_data := x_msg_data; '||
          ' MRP_GET_ONHAND.g_x_qoh := x_planning_qty; '||
           'end; ';

      execute immediate l_stmt using include_nonnet, org_id, item_id;

  else


   if l_vmi_enabled = 'N' then  /* if vmi is NOT enabled  */

      -- Calling the clear_quantity_cache procedure

      l_stmt := 'begin '||
                'inv_quantity_tree_grp.clear_quantity_cache; '||
                'end;';

      execute immediate l_stmt;


          l_stmt := 'declare '||
                    'x_return_status varchar2(20); '||
                    'x_msg_count number; '||
                    'x_msg_data varchar2(1000); '||
                    'x_qoh number; '||
                    'x_rqoh number; '||
                    'x_qr number; '||
                    'x_qs number; '||
                    'x_atr number; '||
                    'x_att number; '||
                    'l_is_revision_control BOOLEAN := FALSE; '||
                    'l_is_lot_control BOOLEAN := TRUE; '||
                    'l_is_serial_control BOOLEAN := FALSE; '||
          'begin '||
          'INV_Quantity_Tree_PUB.Query_Quantities ( '||
	    'p_api_version_number  => 1.0 '||
          ', p_init_msg_lst        => ''F'' '||
          ', x_return_status       => x_return_status '||
          ', x_msg_count          => x_msg_count '||
          ', x_msg_data           => x_msg_data '||
          ', p_organization_id    => :org_id '||
          ', p_inventory_item_id  => :item_id '||
   	  ', p_tree_mode          => 2 '||
          ', p_is_revision_control=> l_is_revision_control '||
          ', p_is_lot_control     => l_is_lot_control '||
          ', p_is_serial_control  => l_is_serial_control '||
	  ', p_lot_expiration_date=> :l_sysdate '||
	  ', p_revision           => NULL '||
          ', p_lot_number         => NULL '||
          ', p_subinventory_code  => NULL '||
          ', p_locator_id         => NULL '||
          ', p_onhand_source      => :l_onhand_source '||
          ', x_qoh                =>x_qoh '||
          ', x_rqoh               =>x_rqoh '||
          ', x_qr                 =>x_qr '||
          ', x_qs                 =>x_qs '||
          ', x_att                =>x_att '||
          ', x_atr                =>x_atr '||'); '||
          ' MRP_GET_ONHAND.g_x_return_status := x_return_status; '||
          ' MRP_GET_ONHAND.g_x_msg_data := x_msg_data; '||
          ' MRP_GET_ONHAND.g_x_qoh := x_qoh; '||
           'end; ';

      execute immediate l_stmt using org_id, item_id, l_sysdate, l_onhand_source;


 else


l_stmt := 'begin '||
          'inv_vmi_validations.clear_vmi_cache; '||
          'end;';

 execute immediate l_stmt;

l_stmt :=           'declare '||
                    'x_return_status varchar2(20); '||
                    'x_msg_data varchar2(1000); '||
                    'x_qoh number; '||
                    'x_att number; '||
                    'x_voh number; '||
                    'x_vatt number; '||
          'begin '||
          'inv_vmi_validations.get_available_vmi_quantity '||
            '( x_return_status        => x_return_status '||
            ', x_return_msg           => x_msg_data '||
            ', p_tree_mode            => 2 '||
            ', p_organization_id      => :org_id '||
            ' , p_owning_org_id        => NULL '||
            ', p_planning_org_id      => NULL '||
            ', p_inventory_item_id    => :item_id '||
            ' , p_is_revision_control  => ''FALSE'' '||
            ', p_is_lot_control       => ''TRUE'' '||
            ', p_is_serial_control    => ''FALSE'' '||
            ', p_revision             => NULL '||
            ', p_lot_number           => NULL '||
            ', p_lot_expiration_date  => :l_sysdate '||
            ', p_subinventory_code    => NULL '||
            ', p_locator_id           => NULL '||
            ', p_onhand_source        => :l_onhand_source '||
            ' , p_cost_group_id        => NULL '||
            ', x_qoh                  => x_qoh '||
            ', x_att                  => x_att '||
            ', x_voh                  => x_voh '||
            ', x_vatt                 => x_vatt '||
            '); '||
            'MRP_GET_ONHAND.g_x_return_status := x_return_status; '||
            'MRP_GET_ONHAND.g_x_msg_data := x_msg_data; '||
            'MRP_GET_ONHAND.g_x_qoh := nvl(x_qoh,0) - nvl(x_voh,0); '||
            'end;';

execute immediate l_stmt using org_id, item_id, l_sysdate, l_onhand_source;

end if;  /* end vmi check  */

end if; /* end consigned validations check */

x_return_status := g_x_return_status;
x_msg_data := g_x_msg_data;
x_qoh := g_x_qoh;

end GET_OH_QTY;


/*
** ---------------------------------------------------------------------------
** Procedure    : do_restock
**
** Description  : This procedure is called from MRP's Reorder Point report.
**
**                1) This procedure will be called only when inventory
**                   patchset J or above is installed.
**                   It calls the following Inventory API :
**                      INV_MMX_WRAPPER_PVT.do_restock
**                   The inventory API is called as a Dynamic SQL statement.
**                   This is to avoid compilation errors if this patch is
**                   by a user on Inventory patchset I or below as this
**                   package is not available in that code level.
**
** Input Parameters:
**
**  p_item_id
**         Inventory Item Id of the Item to be replenished.
**  p_mbf
**         Make or Buy Flag of the Item to be replenished.
**  p_handle_repetitive_item
**         Parameter for Repetitive item handling.
**         1- Create Requisition
**         2- Create Discrete Job
**         3- Do not Restock ,ie Report Only.
**  p_repetitive_planned_item
**         Flag indicating whether item has to be planned as repetitive
**         schedule.
**  p_qty
**         Quantity to be replenished.
**  p_fixed_lead_time
**         Fixed portion of the assembly Item's lead time.
**  p_variable_lead_time
**         Variable portion of the assembly Item's lead time.
**  p_buying_lead_time
**         Preprocessing Lead time + Full Lead Time of the Buy Item.
**  p_uom
**         Primary UOM of the Item.
**  p_accru_acct
**         Accrual Account of the Organization/Operating Unit.
**  p_ipv_acct
**         Invoice Process Variable Account.
**  p_budget_acct
**         Budget Account.
**  p_charge_acct
**         Charge Account.
**  p_purch_flag
**         Flag indicating if item may appear on outside operation purchase
**         order.
**  p_order_flag
**         Flag indicating if item is internally orderable.
**  p_transact_flag
**         Flag indicating if item is transactable.
**  p_unit_price
**         Unit list price - purchasing.
**  p_wip_id
**         WIP Batch Id of WIP_JOB_SCHEDULE_INTERFACE.
**  p_user_id
**         Identifier of the User performing the Min Max planning.
**  p_sysd
**         Current System Date.
**  p_organization_id
**         Identifier of organization for which Min Max planning is to be done.
**  p_approval
**         Approval status.
**         1-Incomplete.
**         7-pre-approved.
**  p_build_in_wip
**         Flag indicating if item may be built in WIP.
**  p_pick_components
**         Flag indicating whether all shippable components should be picked.
**  p_src_type
**         Source type for the Item.
**         1-Inventory.
**         2-Supplier.
**         3-Subinventory.
**  p_encum_flag
**         Encumbrance Flag.
**  p_customer_id
**         Customer Id.
**  p_cal_code
**         Calendar Code of the Organization.
**  p_except_id
**         Exception Set Id of the Organization.
**  p_employee_id
**         Identifier of the Employee associated with the User.
**  p_description
**         Description of the Item.
**  p_src_org
**         Organization to source items from.
**  p_src_subinv
**         Subinventory to source items from.
**  p_subinv
**         Subinventory to be replenished.
**  p_location_id
**         Default Delivery To Location Id of the Planning Org.
**  p_po_org_id
**         Operating Unit Id.
**  p_pur_revision
**         Parameter for Purchasing By Revision .
**         Used for Revision controlled items.
**
** Output Parameters:
**
**  x_return_status
**        Return status indicating success, error or unexpected error.
**  x_msg_count
**        Number of messages in the message list.
**  x_msg_data
**        If the number of messages in message list is 1, contains
**        message text.
**
** ---------------------------------------------------------------------------
*/

PROCEDURE do_restock
( x_return_status            OUT  NOCOPY VARCHAR2
, x_msg_count                OUT  NOCOPY NUMBER
, x_msg_data                 OUT  NOCOPY VARCHAR2
, p_item_id                  IN   NUMBER
, p_mbf                      IN   NUMBER
, p_handle_repetitive_item   IN   NUMBER
, p_repetitive_planned_item  IN   VARCHAR2
, p_qty                      IN   NUMBER
, p_fixed_lead_time          IN   NUMBER
, p_variable_lead_time       IN   NUMBER
, p_buying_lead_time         IN   NUMBER
, p_uom                      IN   VARCHAR2
, p_accru_acct               IN   NUMBER
, p_ipv_acct                 IN   NUMBER
, p_budget_acct              IN   NUMBER
, p_charge_acct              IN   NUMBER
, p_purch_flag               IN   VARCHAR2
, p_order_flag               IN   VARCHAR2
, p_transact_flag            IN   VARCHAR2
, p_unit_price               IN   NUMBER
, p_wip_id                   IN   NUMBER
, p_user_id                  IN   NUMBER
, p_sysd                     IN   DATE
, p_organization_id          IN   NUMBER
, p_approval                 IN   NUMBER
, p_build_in_wip             IN   VARCHAR2
, p_pick_components          IN   VARCHAR2
, p_src_type                 IN   NUMBER
, p_encum_flag               IN   VARCHAR2
, p_customer_id              IN   NUMBER
, p_cal_code                 IN   VARCHAR2
, p_except_id                IN   NUMBER
, p_employee_id              IN   NUMBER
, p_description              IN   VARCHAR2
, p_src_org                  IN   NUMBER
, p_src_subinv               IN   VARCHAR2
, p_subinv                   IN   VARCHAR2
, p_location_id              IN   NUMBER
, p_po_org_id                IN   NUMBER
, p_pur_revision             IN   NUMBER
)  IS

l_sql_stmt        VARCHAR2(2000);
BEGIN

   IF (G_MRP_DEBUG = 'Y') THEN

      -- Print the Input parameters
      log_debug ('Input Parameters to mrp_get_onhand.do_restock ..');
      log_debug ('--------------------------------------------------------');
      log_debug ('Item ID: ' || to_char(p_item_id));
      log_debug ('Make/Buy Flag: ' || to_char(p_mbf));
      log_debug ('Handle Repetitive Item: ' ||
                 to_char(p_handle_repetitive_item));
      log_debug ('Repetitive Planned Item : ' ||
                 p_repetitive_planned_item);
      log_debug ('Reorder Quantity: ' || to_char(p_qty));
      log_debug ('Fixed Lead Time: ' || to_char(p_fixed_lead_time));
      log_debug ('Variable Lead Time: ' || to_char(p_variable_lead_time));
      log_debug ('Buying Lead Time: ' || to_char(p_buying_lead_time));
      log_debug ('Unit of Measure: ' || p_uom);
      log_debug ('Accrual Account: ' || to_char(p_accru_acct));
      log_debug ('Invoice Price Variances Account: ' || to_char(p_ipv_acct));
      log_debug ('Budget Account: ' || to_char(p_budget_acct));
      log_debug ('Charge Account: ' || to_char(p_charge_acct));
      log_debug ('Purchase Flag: ' || p_purch_flag);
      log_debug ('Order Flag: ' || p_order_flag);
      log_debug ('Transact Flag: ' || p_transact_flag);
      log_debug ('Unit Price: ' || to_char(p_unit_price));
      log_debug ('WIP ID: ' || to_char(p_wip_id));
      log_debug ('User ID: ' || to_char(p_user_id));
      log_debug ('Current Date: ' || to_char(p_sysd,'DD-MON-RR'));
      log_debug ('Organization ID: ' || to_char(p_organization_id));
      log_debug ('Approval: ' || to_char(p_approval));
      log_debug ('Build in WIP: ' || p_build_in_wip);
      log_debug ('Pick Components Flag: ' || p_pick_components);
      log_debug ('Source Type: ' || to_char(p_src_type));
      log_debug ('Encumberance Flag: ' || p_encum_flag);
      log_debug ('Customer ID: ' || to_char(p_customer_id));
      log_debug ('Calendar Code: ' || p_cal_code);
      log_debug ('Calendar Exception Set ID: ' || to_char(p_except_id));
      log_debug ('Employee ID: ' || to_char(p_employee_id));
      log_debug ('Description: ' || p_description);
      log_debug ('Source Organization ID: ' || to_char(p_src_org));
      log_debug ('Source Sub Inventory: ' || p_src_subinv);
      log_debug ('Supply Sub Inventory: ' || p_subinv);
      log_debug ('Location ID: ' || to_char(p_location_id));
      log_debug ('PO Organization ID: ' || to_char(p_po_org_id));
      log_debug ('Purchasing by revision: ' || to_char(p_pur_revision));
      log_debug ('--------------------------------------------------------');
   END IF;


   l_sql_stmt :=
     'BEGIN  ' ||
     'inv_mmx_wrapper_pvt.do_restock(' ||
     'x_return_status              =>   :x_return_status ' ||
     ',x_msg_count                 =>   :x_msg_count ' ||
     ',x_msg_data                  =>   :x_msg_data ' ||
     ',p_item_id                   =>   :p_item_id ' ||
     ',p_mbf                       =>   :p_mbf ' ||
     ',p_handle_repetitive_item    =>   :p_repetitive_item ' ||
     ',p_repetitive_planned_item   =>   :p_repetitive_planned_item ' ||
     ',p_qty                       =>   :p_reorder_qty ' ||
     ',p_fixed_lead_time           =>   :p_fixed_lead_time ' ||
     ',p_variable_lead_time        =>   :p_variable_lead_time ' ||
     ',p_buying_lead_time          =>   :p_pur_lead_time ' ||
     ',p_uom                       =>   :p_primary_uom ' ||
     ',p_accru_acct                =>   :p_accrual_acct ' ||
     ',p_ipv_acct                  =>   :p_ipv_acct ' ||
     ',p_budget_acct               =>   :p_budget_acct ' ||
     ',p_charge_acct               =>   :p_charge_acct ' ||
     ',p_purch_flag                =>   :p_purch_flag ' ||
     ',p_order_flag                =>   :p_order_flag ' ||
     ',p_transact_flag             =>   :p_transact_flag '  ||
     ',p_unit_price                =>   :p_unit_price ' ||
     ',p_wip_id                    =>   :p_wip_batch_id ' ||
     ',p_user_id                   =>   :p_user_id ' ||
     ',p_sysd                      =>   :p_current_date '||
     ',p_organization_id           =>   :p_org_id ' ||
     ',p_approval                  =>   :p_approval ' ||
     ',p_build_in_wip              =>   :p_build_in_wip ' ||
     ',p_pick_components           =>   :p_pick_components ' ||
     ',p_src_type                  =>   :p_src_type ' ||
     ',p_encum_flag                =>   :p_encum_flag ' ||
     ',p_customer_id               =>   :p_customer_id ' ||
     ',p_cal_code                  =>   :p_cal_code ' ||
     ',p_except_id                 =>   :p_exc_set_id ' ||
     ',p_employee_id               =>   :p_employee_id ' ||
     ',p_description               =>   :p_description ' ||
     ',p_src_org                   =>   :p_src_org ' ||
     ',p_src_subinv                =>   :p_src_subinv ' ||
     ',p_subinv                    =>   :p_subinv ' ||
     ',p_location_id               =>   :p_default_delivery_to ' ||
     ',p_po_org_id                 =>   :p_po_org_id ' ||
     ',p_pur_revision              =>   :p_pur_revision ); ' ||
     'END;';


BEGIN

   EXECUTE IMMEDIATE l_sql_stmt USING
     OUT  x_return_status
     ,OUT x_msg_count
     ,OUT x_msg_data
     , p_item_id
     , p_mbf
     , p_handle_repetitive_item
     , p_repetitive_planned_item
     , p_qty
     , p_fixed_lead_time
     , p_variable_lead_time
     , p_buying_lead_time
     , p_uom
     , p_accru_acct
     , p_ipv_acct
     , p_budget_acct
     , p_charge_acct
     , p_purch_flag
     , p_order_flag
     , p_transact_flag
     , p_unit_price
     , p_wip_id
     , p_user_id
     , p_sysd
     , p_organization_id
     , p_approval
     , p_build_in_wip
     , p_pick_components
     , p_src_type
     , p_encum_flag
     , p_customer_id
     , p_cal_code
     , p_except_id
     , p_employee_id
     , p_description
     , p_src_org
     , p_src_subinv
     , p_subinv
     , p_location_id
     , p_po_org_id
     , p_pur_revision;

EXCEPTION
   WHEN OTHERS THEN
      log_error ('error in mrp_get_onhand.do_restock.');
      log_error (SQLERRM);
      x_return_status := 'E';
      ROLLBACK;
END;

END do_restock;

end MRP_GET_ONHAND;

/
