--------------------------------------------------------
--  DDL for Package Body MTL_CCEOI_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CCEOI_PROCESS_PVT" AS
/* $Header: INVVCCPB.pls 120.5.12010000.6 2010/01/18 07:06:09 ancgupta ship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_CCEOI_PROCESS_PVT';


procedure mdebug(msg in varchar2)
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
    inv_log_util.trace(msg , g_pkg_name || ' ',9);
end;


/* Bug 5721960 -Added the procedure */

   PROCEDURE GET_ITEM_COST(
   p_organization_id IN NUMBER ,
   p_inventory_item_id IN NUMBER ,
   p_locator_id IN NUMBER ,
   p_cost_group_id IN NUMBER,
   x_item_cost OUT NOCOPY NUMBER )

   IS
       l_locator_id NUMBER := p_locator_id ;
       l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   BEGIN

         IF ( l_debug = 1 ) THEN
            mdebug ( '***get_item_cost***' );
         END IF;

         IF ( l_locator_id = -1 ) THEN
            l_locator_id := NULL;
         END IF;

         IF ( l_debug = 1 ) THEN
            mdebug ( 'Value of org_id:'|| p_organization_id );
            mdebug ( 'Value of item_id:'|| p_inventory_item_id );
            mdebug ( 'Value of locator_id:'|| p_locator_id );
            mdebug ( 'Value of cost_group_id:'|| p_cost_group_id );
         END IF;

    BEGIN
            SELECT NVL ( ccicv.item_cost, 0 )
            INTO   x_item_cost
            FROM   cst_cg_item_costs_view ccicv,
                   mtl_parameters mp
            WHERE  l_locator_id IS NULL
            AND    ccicv.organization_id = p_organization_id
            AND    ccicv.inventory_item_id = p_inventory_item_id
            AND    ccicv.organization_id = mp.organization_id
            AND    ccicv.cost_group_id =
                      DECODE ( mp.primary_cost_method,
                               1, 1,
                               NVL ( p_cost_group_id , mp.default_cost_group_id)
                              )
            UNION ALL
            SELECT NVL ( ccicv.item_cost, 0 )
            FROM   mtl_item_locations mil,
                   cst_cg_item_costs_view ccicv,
                   mtl_parameters mp
            WHERE  l_locator_id IS NOT NULL
            AND    mil.organization_id = p_organization_id
            AND    mil.inventory_location_id = l_locator_id
            AND    mil.project_id IS NULL
            AND    ccicv.organization_id = mil.organization_id
            AND    ccicv.inventory_item_id = p_inventory_item_id
            AND    ccicv.organization_id = mp.organization_id
            AND     ccicv.cost_group_id =
                      DECODE ( mp.primary_cost_method,
                               1, 1,
                               NVL ( p_cost_group_id , mp.default_cost_group_id)
                              )
            UNION ALL
            SELECT NVL ( ccicv.item_cost, 0 )
            FROM   mtl_item_locations mil,
                   mrp_project_parameters mrp,
                   cst_cg_item_costs_view ccicv,
                   mtl_parameters mp
            WHERE  l_locator_id IS NOT NULL
            AND    mil.organization_id = p_organization_id
            AND    mil.inventory_location_id = l_locator_id
            AND    mil.project_id IS NOT NULL
            AND    mrp.organization_id = mil.organization_id
            AND    mrp.project_id = mil.project_id
            AND    ccicv.organization_id = mil.organization_id
            AND    ccicv.inventory_item_id = p_inventory_item_id
            AND    ccicv.organization_id = mp.organization_id
            AND    ccicv.cost_group_id =
                      DECODE ( mp.primary_cost_method,
                               1, 1,
                               NVL (  mrp.costing_group_id, 1 )
                             );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_item_cost := 0;
         END;

   END GET_ITEM_COST;
   /* End of fix for Bug 5721960 */


-- compute count due date
-- pre: MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC contains data
--     (call Validate_CountHeader) to fill it out
-- post: returns count due date or throws an exception if date cannot be found
-- because of invalid data in MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC or
-- if anything else goes wrong (e.g end of calendar)
function compute_count_due_date(p_date IN DATE) return  DATE  is
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(240);
  l_return_status VARCHAR2(1);
  l_result_date DATE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   mtl_inv_validate_grp.get_offset_date(
     p_api_version => 0.9,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data,
     x_return_status => l_return_status,
     p_calendar_code =>
     mtl_cceoi_var_pvt.g_cycle_count_header_rec.cycle_count_calendar,
     p_exception_set_id =>
     mtl_cceoi_var_pvt.g_cycle_count_header_rec.calendar_exception_set,
     p_start_date => p_date,
     p_offset_days =>
     mtl_cceoi_var_pvt.g_cycle_count_header_rec.days_until_late,
     x_result_date => l_result_date);

   IF (l_debug = 1) THEN
      mdebug('Due date'||to_char(l_result_date));
   END IF;
   if (l_return_status <> fnd_api.g_ret_sts_success) then
      IF (l_debug = 1) THEN
         mdebug('error in due date computation');
      END IF;
      raise fnd_api.g_exc_unexpected_error;
   end if;

   return l_result_date;

end;

-- this procedure prevents reuse of global variables between calls to
-- the public api done within the same session
PROCEDURE Reset_Global_Vars
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC := null;
   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC := null;
   MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST := false;
   MTL_CCEOI_VAR_PVT.G_SKU_REC := null;
   MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_AMOUNT := null;
   MTL_CCEOI_VAR_PVT.G_ADJ_VARIANCE_PERCENTAGE := null;
   MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := null;
   MTL_CCEOI_VAR_PVT.G_ITEM_COST := null;
   MTL_CCEOI_VAR_PVT.G_STOCK_LOCATOR_CONTROL_CODE := null;
   MTL_CCEOI_VAR_PVT.G_SEQ_NO := null;
   MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID := null;
   MTL_CCEOI_VAR_PVT.G_ITEM_LOCATOR_TYPE := null;
   MTL_CCEOI_VAR_PVT.G_SUB_LOCATOR_TYPE := null;
   MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID := null;
   MTL_CCEOI_VAR_PVT.G_ORIENTATION_CODE := null;
   MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID := null;
   MTL_CCEOI_VAR_PVT.G_LOCATOR_ID := null;
   MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE := null;
   MTL_CCEOI_VAR_PVT.G_UOM_CODE := null;
   MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY := null;
   MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY := null;
   MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID := null;
   MTL_CCEOI_VAR_PVT.G_COUNT_DATE := null;
   MTL_CCEOI_VAR_PVT.G_SUBINVENTORY := null;
   MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID := null;
   MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM := true;
   MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP := null;

   -- BEGIN INVCONV
   MTL_CCEOI_VAR_PVT.G_TRACKING_QUANTITY_IND := null;
   MTL_CCEOI_VAR_PVT.G_SECONDARY_DEFAULT_IND := null;
   MTL_CCEOI_VAR_PVT.G_PROCESS_COSTING_ENABLED_FLAG := null;
   MTL_CCEOI_VAR_PVT.G_PROCESS_ENABLED_FLAG := null;
   MTL_CCEOI_VAR_PVT.G_SECONDARY_UOM_CODE := null;

   MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_UOM := null;
   MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_QUANTITY := null;
   MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY := null;
   MTL_CCEOI_VAR_PVT.G_LPN_ITEM_SEC_SYSTEM_QTY := null;
   MTL_CCEOI_VAR_PVT.G_SEC_ADJUSTMENT_QUANTITY := null;
   -- END INVCONV

END;

--
  --
  -- Copy the current into the prior columns
  PROCEDURE Current_To_Prior
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Current_to_Prior
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- this PROCEDURE SET the current VALUES of the open count request into
    -- the system table mtl_cycle_count_entries to the prior column.
    -- Parameters:
    --     IN    :
    --     OUT   :
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
      dummy integer;
    BEGIN
       ---
       -- SET the current DATE to the pri0r DATE
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_PRIOR:=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_DATE_CURRENT;
       --
       -- SET the current counter to prior
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNTED_BY_EMPLOYEE_ID_CURRENT;
       --
       -- SET the COUNT uom to prior
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_UOM_CURRENT;
       --
       -- SET the current COUNT quantity to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_QUANTITY_CURRENT;
       --
       -- SET the current system quanity to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SYSTEM_QUANTITY_CURRENT;
       --
       -- SET the primary uom quantity
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.PRIMARY_UOM_QUANTITY_CURRENT;
       --
       -- SET the current refernce to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.REFERENCE_CURRENT;
       --

       -- BEGIN INVCONV
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_SECONDARY_UOM_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_SECONDARY_UOM_CURRENT;
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_UOM_QUANTITY_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SECONDARY_UOM_QUANTITY_CURRENT;
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_SYSTEM_QTY_PRIOR :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SECONDARY_SYSTEM_QTY_CURRENT;
       -- END INVCONV

    END;
  END;

  --
  -- Propagates info about first count into updated record
  PROCEDURE Propagate_First
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     -- propagate first count date
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_DATE_FIRST;

     -- propagate id of employee who first counted the record
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNTED_BY_EMPLOYEE_ID_FIRST;

     -- propagate count uom used in thefirst count
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_UOM_FIRST;

     -- propagate count quantity found in the first count
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_QUANTITY_FIRST;

     -- propagate system quantity for the first count
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SYSTEM_QUANTITY_FIRST;

     -- propagate primary uom quantity for the first count
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.PRIMARY_UOM_QUANTITY_FIRST;

     -- propagate reference used in the first count
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.REFERENCE_FIRST;

     -- BEGIN INVCONV
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_SECONDARY_UOM_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_SECONDARY_UOM_FIRST;
     --
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_UOM_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SECONDARY_UOM_QUANTITY_FIRST;
     --
     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_SYSTEM_QTY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SECONDARY_SYSTEM_QTY_FIRST;
     -- END INVCONV
  END;

  --
  -- Current information into first information.
  PROCEDURE Current_To_First(
  p_reference IN VARCHAR2 DEFAULT NULL,
  p_primary_uom_quantity IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Current_to_first
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- this PROCEDURE SET the current VALUES to first. IF this
    -- IS the first time to INSERT an entry.
    -- Parameters:
    --     IN    :
    --  p_reference VARCHAR2(240) (optional)
    --  default NULL
    --
    --  p_primary_uom_quantity IN NUMBER (required)
    --  primary uom quantity
    --
    --     OUT   :
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       dummy integer;
    BEGIN
       ---
       -- SET the current DATE to the first DATE
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_FIRST :=
       MTL_CCEOI_VAR_PVT.G_COUNT_DATE;
       --
       -- SET the current counter to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_FIRST :=
       MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID;
       --
       -- SET the COUNT uom to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_FIRST :=
       MTL_CCEOI_VAR_PVT.G_UOM_CODE;
       --
       -- SET the current COUNT quantity to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY;
       --
       -- SET the current system quanity to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY;
       --
       -- SET the primary uom quantity
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_FIRST :=
       p_primary_uom_quantity;
       --
       -- SET the current refernce to first
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_FIRST :=
       p_reference;
       --

       -- BEGIN INVCONV
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_SECONDARY_UOM_FIRST :=
       MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_UOM;
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_UOM_QUANTITY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_QUANTITY;
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_SYSTEM_QTY_FIRST :=
       MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY;
       -- END INVCONV

    END;
  END;
  -- Puts the entry values into current values.
PROCEDURE entry_to_current(
  p_reference IN VARCHAR2 DEFAULT NULL,
  p_primary_uom_quantity IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Entry_to_Current
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_reference IN VARCHAR2(240) (optional)
    --  default NULL, IS LIKE a note what IS happened
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       dummy integer;
    BEGIN
       --
       -- SET the actual interface COUNT DATE to the current
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_COUNT_DATE;
       --
       -- SET current counter
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID;
       --
       -- SET COUNT uom
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_UOM_CODE;
       --
       -- SET the COUNT quantity
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_CURRENT:=
       MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY;
       --
       -- SET the current system quantity
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_CURRENT:=
       MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY;
       --
       -- SET the primary uom quantity
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_CURRENT :=
       p_primary_uom_quantity;
       --
       -- SET the current reference
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_CURRENT:=
       p_reference;
       --

       -- BEGIN INVCONV
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_SECONDARY_UOM_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_UOM;
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_UOM_QUANTITY_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_QUANTITY;
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SECONDARY_SYSTEM_QTY_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY;
       -- END INVCONV
    END;
  END;
-- Final update logic.
  PROCEDURE Final_Preupdate_Logic(
  p_reference IN VARCHAR2 DEFAULT NULL,
  p_primary_uom_quantity IN NUMBER ,
  p_count_uom IN VARCHAR2 ,
  p_serial_number IN VARCHAR2 ,
  p_subinventory IN VARCHAR2 ,
  p_lot_number IN VARCHAR2 ,
  p_lot_expiration IN date ,
  p_revision IN VARCHAR2 ,
  p_transaction_reason_id IN NUMBER ,
  p_transaction_process_mode IN NUMBER DEFAULT 3,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Final_Update_Logic
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    -- p_reference IN VARCHAR2 (optional)
    -- default NULL
    --
     -- p_primary_uom_quantity IN NUMBER  -- only useful for update of
     -- interface tables
    --
     -- p_count_uom IN VARCHAR2 (required) XXX will not work if count qty
     -- is entered through primary_uomqty
    --
    -- p_subinventory IN VARCHAR2(required)
    --
    -- p_lot_number IN VARCHAR2 (required)
    --
    -- p_lot_expiration_date DATE (required)
    --
    -- p_revision IN VARCHAR2(required)
    --
    -- p_transaction_reasion_id IN NUMBER (required)
    --
    -- p_serial_number IN VARCHAR2 (required)
    --
    -- p_transaction_process_mode IN NUMBER (required-defaulted)
     --  default = 3 (Background processing) this parameter is not really used
     -- since the only way the processing can be done now is in background mode
    --
    -- p_simulate IN VARCHAR2 (defaulted)
    --   default = FND_API.G_FALSE may modify tables other than interface
    --             FND_API.G_TRUE - may modify only interface tables
    --
    --     OUT   :
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_from_uom MTL_CYCLE_COUNT_ENTRIES.COUNT_UOM_CURRENT%type;
       L_txn_uom MTL_CYCLE_COUNT_ENTRIES.COUNT_UOM_CURRENT%type;
       L_txn_header_id NUMBER;
       L_txn_temp_id NUMBER;
       L_serial_prefix MTL_SYSTEM_ITEMS.auto_serial_alpha_prefix%type;
       L_p_uom_qty NUMBER;
       L_number_of_counts NUMBER;
       L_success_flag NUMBER;
       L_org_id MTL_CYCLE_COUNT_ENTRIES.ORGANIZATION_ID%type;
       l_txn_return_status NUMBER; -- 8712932
       l_proc_msg         VARCHAR2(3000);
       l_business_flow_code  NUMBER := 8 ;

       --
    BEGIN
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Process- Inside Final-Pre-update ');
END IF;
       IF MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.entry_status_code = 5 THEN
	  --
	  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_DATE := sysdate;
	  --
       END IF;
       --
       L_number_of_counts :=
       (NVL(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.number_of_counts, 0) + 1);
       --
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NUMBER_OF_COUNTS :=
       L_number_of_counts;
       --
	IF (l_debug = 1) THEN
   	mdebug('Final_Preupdate_Logic: Number of counts => ' ||	  L_number_of_Counts);
	END IF;

       IF L_number_of_counts = 1 THEN
	  --
	  Entry_To_Current(p_reference => p_reference
	    , p_primary_uom_quantity => p_primary_uom_quantity);
	  --
	  Current_To_First(
	     p_reference => p_reference
	     , p_primary_uom_quantity => p_primary_uom_quantity
	  );
	  --
       ELSE
	  --
	  Propagate_First;
	  --
	  Current_To_Prior;
	  --
	  Entry_To_Current(
	    p_reference => p_reference
	    , p_primary_uom_quantity => p_primary_uom_quantity);
	  --
       END IF;
       --
       L_from_uom := p_count_uom;
       L_txn_uom := L_from_uom;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Inside F-P-Update Logic: '|| to_char(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.entry_status_code));
   MDEBUG( 'F-P-U :AdjQty= '||to_char(MTL_CCEOI_VAR_PVT.G_adjustment_quantity));
   MDEBUG( 'F-P-U :SecAdjQty= '||to_char(MTL_CCEOI_VAR_PVT.g_sec_adjustment_quantity)); -- INVCONV
   MDEBUG( 'F-P-U : '||p_simulate);
END IF;

       IF MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.entry_status_code = 5
	  AND MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY <> 0
	  AND NOT FND_API.to_Boolean(p_simulate)
       THEN
	  --
IF (l_debug = 1) THEN
   MDEBUG( 'F-P-U-Inside the If value ');
END IF;
	  SELECT mtl_material_transactions_s.nextval
	  INTO
	     L_txn_header_id
	  FROM
	     dual;
	  --
	  IF(p_serial_number IS NOT NULL) THEN
	     --
	     SELECT mtl_material_transactions_s.nextval
	     INTO
		L_txn_temp_id
	     FROM
		dual;
	     --
	     SELECT auto_serial_alpha_prefix
	     INTO
		L_serial_prefix
	     FROM
		mtl_system_items
	     WHERE
		inventory_item_id = MTL_CCEOI_VAR_PVT.G_inventory_item_id
		AND organization_id =
	       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id;
	     --
	  END IF;
	  --
         L_org_id:= MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id;
--bug 8526579 made the inv_convert call lot specific to honor lot specific conversions
	  L_p_uom_qty := inv_convert.inv_um_convert(
	     item_id => MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID
             ,lot_number=>p_lot_number
	     ,organization_id=>L_org_id
	     , precision => 5
	     , from_quantity => MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY
	     , from_unit => MTL_CCEOI_VAR_PVT.G_UOM_CODE -- L_from_uom
	     , to_unit => MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE
	     , from_name => NULL
	    , to_name => NULL);


	  --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerence:Update Adj Amt  ');
   MDEBUG( 'Account Id '||to_char(MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID));
   MDEBUG( 'Count Dt '||fnd_date.date_to_canonical(MTL_CCEOI_VAR_PVT.g_count_date));
   MDEBUG( 'Subinv '||p_subinventory);
   MDEBUG( 'CountUOM '||p_count_uom);
   MDEBUG( 'CCEId '||to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.cycle_count_entry_id));
   mdebug('serial number='||p_serial_number);
END IF;

IF (l_debug = 1) THEN
   mdebug('Making a transaction. txn_hdr_id='||L_txn_header_id);
   mdebug('Making a transaction. txn_tmp_id='||L_txn_temp_id);
END IF;

	 -- delete record
	 DELETE_RESERVATION (p_subinventory, p_lot_number, p_revision);

	  L_success_flag := mtl_cc_transact_pkg.cc_transact(
	    org_id=>
	     MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id
	    , cc_header_id => MTL_CCEOI_VAR_PVT.G_cc_header_id
	    , item_id => MTL_CCEOI_VAR_PVT.G_inventory_item_id
	    , sub=> p_subinventory
	    , PUOMQty=>L_p_uom_qty
	    , TxnQty=>MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY
	    , TxnUOM=> MTL_CCEOI_VAR_PVT.G_UOM_CODE -- p_count_uom
	    , TxnDate=>MTL_CCEOI_VAR_PVT.G_count_date
	    , TxnAcctId=>MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID
	    , LotNum=>p_lot_number
	    , LotExpDate=>p_lot_expiration
	    , rev=>p_revision
	      , locator_id=>MTL_CCEOI_VAR_PVT.G_locator_id
	      , TxnRef=>p_reference
	      , ReasonId=> p_transaction_reason_id
	      , UserId=> MTL_CCEOI_VAR_PVT.G_userid
	      , cc_entry_id=>
	        MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.cycle_count_entry_id
	      , LoginId => MTL_CCEOI_VAR_PVT.G_LoginId
	      , TxnProcMode => 3 -- p_transaction_process_mode
	      , TxnHeaderId=>L_txn_header_id
	      , SerialNum=>P_serial_number
	      , TxnTempId=>L_txn_temp_id
	      , SerialPrefix=>L_serial_prefix
	      , lpn_id => MTL_CCEOI_VAR_PVT.G_LPN_ID
	      , cost_group_id => MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID
	      -- BEGIN INVCONV
	      , secUOM => MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_UOM
	      , secQty => MTL_CCEOI_VAR_PVT.G_SEC_ADJUSTMENT_QUANTITY
	      -- END INVCONV
	      );
    -- 8712932 Start
    -- Calling the transaction maanger to process the temp records for adjustments to be processed.
    l_txn_return_status :=
               INV_LPN_TRX_PUB.PROCESS_LPN_TRX ( p_trx_hdr_id        => l_txn_header_id,
                                                 x_proc_msg          => l_proc_msg,
                                                 p_business_flow_code => l_business_flow_code
                                               );
            IF ( l_debug = 1 ) THEN
               mdebug ( 'Txn return status: ' || l_txn_return_status );
            END IF;

            IF ( l_txn_return_status <> 0 ) THEN
               -- This 'Transaction Failed' message is set on the java side

              RAISE FND_API.G_EXC_ERROR;
             mdebug ( 'Txn failed');
            END IF;

	  --  8712932 End
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerence:Update Adj Amt Flag '||L_success_flag);
END IF;
	  IF NVL(L_txn_header_id, -1) < 0
	     OR NVL(L_success_flag, -1) < 0 THEN
	     --
	     FND_MESSAGE.SET_NAME('INV', 'INV_ADJ_TXN_FAILED');
	     APP_EXCEPTION.RAISE_EXCEPTION;
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerence : Adj Failed ');
END IF;
	     --
	  END IF;
	  --
	  /* MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_DATE := sysdate;
	  MTL_CCEOI_VAR_PVT.G_COMMIT_STATUS_FLAG := '1';
	  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.INVENTORTY_ADJUST_ACCOUNT :=
	  MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID;
	  */
	  --
       END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerence : End of Adj Qty process ');
END IF;
    END;
  END;
  --
-- in tolerance.
  PROCEDURE in_Tolerance(
  p_reference  VARCHAR2 ,
  p_primary_uom_quantity  NUMBER ,
  p_count_uom  VARCHAR2 ,
  p_subinventory  VARCHAR2 ,
  p_lot_number  VARCHAR2 ,
  p_lot_expiration_date  DATE ,
  p_revision  VARCHAR2 ,
  p_transaction_reason_id  NUMBER ,
  p_serial_number  VARCHAR2 ,
  p_transaction_process_mode  NUMBER ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : In_TOLERANCE
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    -- p_reference IN VARCHAR2 (optional)
    -- default NULL
    --
    -- p_primary_uom_quantity IN NUMBER
    --
    -- p_count_uom IN VARCHAR2 (required)
    --
    -- p_subinventory IN VARCHAR2(required)
    --
    -- p_lot_number IN VARCHAR2 (required)
    --
    -- p_lot_expiration_date DATE (required)
    --
    -- p_revision IN VARCHAR2(required)
    --
    -- p_transaction_reasion_id IN NUMBER (required)
    --
    -- p_serial_number IN VARCHAR2 (required)
    --
    -- p_transaction_process_mode IN NUMBER (required-defaulted)
    --  default = 3 (Background processing)
    --
    --  p_simulate in varchar2 (defaulted FND_API.G_FALSE)
    --    G_FALSE - may modify data in tables other than ccoi interface
    --    G_TRUE - may not modify data in tables othert than ccoi interface

    --     OUT   :
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       dummy integer;
       --
    BEGIN
       IF (MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.approval_option_code = 1
       AND MTL_CCEOI_VAR_PVT.G_LPN_ID IS NULL)
       OR (MTL_CCEOI_VAR_PVT.G_LPN_ID IS NOT NULL
           AND MTL_CCEOI_VAR_PVT.G_CONTAINER_ENABLED_FLAG = 1
           AND (MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION = 2
                OR MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION = 2)
          )
       THEN
	  --
	  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	  --
       ELSE
	  --
	  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
	  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_TYPE := 1;
	  --
       END IF;
       --
       Final_Preupdate_Logic(
	  p_reference => p_reference
	  , p_primary_uom_quantity => p_primary_uom_quantity
	  , p_count_uom => p_count_uom
	  , p_serial_number => p_serial_number
	  , p_subinventory => p_subinventory
	  , p_lot_number => p_lot_number
	  , p_lot_expiration => p_lot_expiration_date
	  , p_revision => p_revision
	  , p_transaction_reason_id => p_transaction_reason_id
	  , p_transaction_process_mode => p_transaction_process_mode
	 , p_simulate => p_simulate);
       --
    END;
  END;
  --
  -- Out of tolerance.
  PROCEDURE Out_Of_Tolerance(
  p_reference  VARCHAR2 ,
  p_primary_uom_quantity  NUMBER ,
  p_count_uom  VARCHAR2 ,
  p_subinventory  VARCHAR2 ,
  p_lot_number  VARCHAR2 ,
  p_lot_expiration_date  DATE ,
  p_revision  VARCHAR2 ,
  p_transaction_reason_id  NUMBER ,
  p_serial_number  VARCHAR2 ,
  p_transaction_process_mode  NUMBER ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : out_OF_TOLERANCE
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    -- p_reference IN VARCHAR2 (optional)
    -- default NULL
    --
    -- p_primary_uom_quantity IN NUMBER
    --
    -- p_count_uom IN VARCHAR2 (required)
    --
    -- p_subinventory IN VARCHAR2(required)
    --
    -- p_lot_number IN VARCHAR2 (required)
    --
    -- p_lot_expiration_date DATE (required)
    --
    -- p_revision IN VARCHAR2(required)
    --
    -- p_transaction_reasion_id IN NUMBER (required)
    --
    -- p_serial_number IN VARCHAR2 (required)
    --
    -- p_transaction_process_mode IN NUMBER (required-defaulted)
    --  default = 3 (Background processing)
    --
    --  p_simulate in varchar2 (defaulted FND_API.G_FALSE)
    --     G_FALSE - may modify data in tables other than cc interface
    --     G_TRUE - may not modify data in tables other than cc interface
    --     OUT   :
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       dummy integer;
       --
    BEGIN
       IF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.automatic_recount_flag <> 1
    THEN
	  IF (MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.approval_option_code = 2
	  AND MTL_CCEOI_VAR_PVT.G_LPN_ID IS NULL)
	  OR (MTL_CCEOI_VAR_PVT.G_LPN_ID IS NOT NULL
              AND MTL_CCEOI_VAR_PVT.G_CONTAINER_ENABLED_FLAG = 1
              AND MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION = 1
              AND MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION = 1)
	  THEN
	     --
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_TYPE := 1;
	     --
	  ELSE
	     --
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	     --
	  END IF;
       ELSE
	  IF NVL(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.NUMBER_OF_COUNTS, 0) <
	     MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.MAXIMUM_AUTO_RECOUNTS THEN
	     --
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 3;

	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DUE_DATE :=
	       Compute_Count_Due_Date(sysdate);
		--
	  ELSE
	     --
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	     --
	  END IF;
       END IF;
       Final_Preupdate_Logic(
	  p_reference => p_reference
	  , p_primary_uom_quantity => p_primary_uom_quantity
	  , p_count_uom => p_count_uom
	  , p_serial_number => p_serial_number
	  , p_subinventory => p_subinventory
	  , p_lot_number => p_lot_number
	  , p_lot_expiration => p_lot_expiration_date
	  , p_revision => p_revision
	  , p_transaction_reason_id => p_transaction_reason_id
	  , p_transaction_process_mode => p_transaction_process_mode
	  , p_simulate => p_simulate);
       --
    END;
  END;
  --
  PROCEDURE Tolerance_Logic(
  p_pos_meas_err IN NUMBER ,
  p_neg_meas_err IN NUMBER ,
  p_app_tol_pos IN NUMBER ,
  p_app_tol_neg IN NUMBER ,
  p_cost_tol_pos IN NUMBER ,
  p_cost_tol_neg IN NUMBER ,
  p_adjustment_value IN NUMBER ,
  p_adjustment_quantity IN NUMBER ,
  p_system_quantity IN NUMBER ,
  p_approval_option_code IN NUMBER ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Tolerance_logic
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_pos_meas_err IN NUMBER (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.POSITIVE_MEASUREMENT_ERROR
    --
    --  p_neg_meas_err IN NUMBER (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.NEGATIVE_MEASUREMENT_ERROR
    --
    --  p_app_tol_pos IN NUMBER  (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.APP_TOL_POS
    --
    --  p_app_tol_neg IN NUMBER  (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.APP_TOL_NEG
    --
    --  p_cost_tol_pos IN NUMBER  (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.COST_TOL_POS
    --
    --  p_cost_tol_neg IN NUMBER  (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.COST_TOL_NEG
    --
    --  p_adjustment_value IN NUMBER (required)
    --  MTL_CYCLE_COUNT_ENTRIES_V.ADJUSTMENT_AMOUNT
    --
    --  p_adjustment_quantity IN NUMBER (required)
    -- get the value FROM the global variable
    -- MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY
    --  MTL_CYCLE_COUNT_ENTRIES.ADJUSTMENT_QUANTITY
    --
    --  p_system_quantity IN NUMBER (required)
    -- gets the value FROM the global variable
    -- MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
    --  MTL_CYCLE_COUNT_ENTRIES.SYSTEM_QUANTITY_CURRENT
    --
    --  p_approval_option_code IN NUMBER (required)
    --  MTL_CYCLE_COUNT_HEADERS.APPROVAL_OPTION_CODE
    --
    -- p_interface_rec IN MTL_CC_ENTRIES_INTERFACE%rowtype
    --
    -- p_simulate IN varchar2 (default)
    --   default = FND_API.G_FALSE - may modify data in other tables
    --       FND_API.G_TRUE modify data only in the interface tables
    --
    --     OUT   :
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       dummy integer;
       l_contianer_enabled_flag  	NUMBER := NULL;
       l_contianer_adjustment_option 	NUMBER := NULL;
       l_container_decrepancy_option 	NUMBER := NULL;
    BEGIN
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerance Logic ');
END IF;

       -- Approval option = Always
       -- p_approval_option_code = 1 is applicable only when lpn_id is null
       -- if lpn_id is not null, check container_adjustment_option = 2
       IF (p_approval_option_code = 1 AND p_interface_rec.parent_lpn_id IS NULL) OR
          ( p_interface_rec.parent_lpn_id IS NOT NULL
            AND MTL_CCEOI_VAR_PVT.G_CONTAINER_ENABLED_FLAG = 1
            AND ( MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION = 2
                  OR MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION = 2 )
          )
       THEN
	  --
	  IF p_adjustment_quantity <> 0 THEN
	     --
	     IF p_system_quantity <> 0 THEN
		--
		IF p_adjustment_quantity < 0 THEN
		   --
		   IF p_neg_meas_err IS NOT NULL AND
		      ABS((p_adjustment_quantity/ p_system_quantity) *100) < p_neg_meas_err THEN
		      --
		      -- No adjustments are required
		      MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
	              MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY := 0;
		      MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := 0;
		      --
                      IF (l_debug = 1) THEN
                         MDEBUG( 'Tol : before final-pre-update-logic');
                      END IF;
		      Final_Preupdate_Logic(
			 p_reference => p_interface_rec.reference
			 , p_primary_uom_quantity =>
			 p_interface_rec.primary_uom_quantity
			 , p_count_uom =>
			 p_interface_rec.count_uom
			 , p_serial_number => p_interface_rec.serial_number
			 , p_subinventory =>p_interface_rec.subinventory
			 , p_lot_number =>p_interface_rec.lot_number
			 , p_lot_expiration =>
			 MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
			 , p_revision =>p_interface_rec.revision
			 , p_transaction_reason_id =>
			 p_interface_rec.transaction_reason_id
			 , p_transaction_process_mode => p_interface_rec.process_mode
			 , p_simulate => p_simulate);
		      --
                   IF (l_debug = 1) THEN
                      MDEBUG( 'Tole : After update logic');
                   END IF;
		   ELSE
		      --
		      -- #### START OUT OF Tolerance
		      IF (l_debug = 1) THEN
   		      MDEBUG( 'Before-Out of Tolerance ');
		      END IF;
		      Out_Of_Tolerance(
			 p_reference => p_interface_rec.reference
			 , p_primary_uom_quantity =>
			 p_interface_rec.primary_uom_quantity
			 , p_count_uom => p_interface_rec.count_uom
			 , p_serial_number => p_interface_rec.serial_number
			 , p_subinventory =>p_interface_rec.subinventory
			 , p_lot_number =>p_interface_rec.lot_number
			 , p_lot_expiration_date =>
			 MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
			 , p_revision =>p_interface_rec.revision
			 , p_transaction_reason_id =>
			 p_interface_rec.transaction_reason_id
			 , p_transaction_process_mode => p_interface_rec.process_mode
			 , p_simulate => p_simulate );
		      -- #### END OUT OF Tolerance
IF (l_debug = 1) THEN
   MDEBUG( 'End of Out-of Tolerance ');
END IF;
		      --
		   END IF;
		   --
		ELSE
		   --
		   IF p_pos_meas_err IS NOT NULL AND
		      ABS((p_adjustment_quantity/p_system_quantity) *100) <
		      p_pos_meas_err THEN
		      --
		      -- No adjustment required
		      MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
	  	      MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY := 0;
		      MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := 0;
		      --
IF (l_debug = 1) THEN
   MDEBUG( 'Before preupdate logic - 2');
END IF;
		      Final_Preupdate_Logic(
			 p_reference => p_interface_rec.reference
			 , p_primary_uom_quantity =>
			 p_interface_rec.primary_uom_quantity
			 , p_count_uom => p_interface_rec.count_uom
			 , p_serial_number => p_interface_rec.serial_number
			 , p_subinventory =>p_interface_rec.subinventory
			 , p_lot_number =>p_interface_rec.lot_number
			 , p_lot_expiration =>
			 MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
			 , p_revision =>p_interface_rec.revision
			 , p_transaction_reason_id =>
			 p_interface_rec.transaction_reason_id
			 , p_transaction_process_mode => p_interface_rec.process_mode
			 , p_simulate => p_simulate );
		      --
IF (l_debug = 1) THEN
   MDEBUG( 'preupdate logic-2 -end ');
END IF;
		   ELSE
		      --
IF (l_debug = 1) THEN
   MDEBUG( 'before start out-of tol -2 ');
END IF;
		      -- ## Start OUT OF TOLERANCE
		      Out_Of_Tolerance(
			 p_reference => p_interface_rec.reference
			 , p_primary_uom_quantity =>
			 p_interface_rec.primary_uom_quantity
			 , p_count_uom =>
			 p_interface_rec.count_uom
			 , p_serial_number => p_interface_rec.serial_number
			 , p_subinventory =>p_interface_rec.subinventory
			 , p_lot_number =>p_interface_rec.lot_number
			 , p_lot_expiration_date =>
			 MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
			 , p_revision =>p_interface_rec.revision
			 , p_transaction_reason_id =>
			 p_interface_rec.transaction_reason_id
			 , p_transaction_process_mode => p_interface_rec.process_mode
			 , p_simulate => p_simulate );
		      -- ## END OUT OF TOLERANCE
		      --
IF (l_debug = 1) THEN
   MDEBUG( 'After out-of-tol- end-2');
END IF;
		   END IF;
		END IF;
		-- System quantity = 0
	     ELSE
		--
IF (l_debug = 1) THEN
   MDEBUG( 'Process-: Out of tol - 3');
END IF;
		Out_Of_Tolerance(
		   p_reference => p_interface_rec.reference
		   , p_primary_uom_quantity =>
		   p_interface_rec.primary_uom_quantity
		   , p_count_uom =>
		   p_interface_rec.count_uom
		   , p_serial_number => p_interface_rec.serial_number
		   , p_subinventory =>p_interface_rec.subinventory
, p_lot_number =>p_interface_rec.lot_number
                   , p_lot_expiration_date =>
                   MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                   , p_revision =>p_interface_rec.revision
                   , p_transaction_reason_id =>
                   p_interface_rec.transaction_reason_id
                   , p_transaction_process_mode => p_interface_rec.process_mode
                   , p_simulate => p_simulate );
                --
IF (l_debug = 1) THEN
   MDEBUG( 'Out of Tol-3 -end');
END IF;
             END IF;
             -- if adjustment_qty = 0
          ELSE
             --
             MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
             MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY := 0;
             MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := 0;
             --
IF (l_debug = 1) THEN
   MDEBUG( 'Before preupdate - 4');
END IF;
             Final_Preupdate_Logic(
                p_reference => p_interface_rec.reference
                , p_primary_uom_quantity =>
                p_interface_rec.primary_uom_quantity, p_count_uom =>
                p_interface_rec.count_uom
                , p_serial_number => p_interface_rec.serial_number
                , p_subinventory =>p_interface_rec.subinventory
                , p_lot_number =>p_interface_rec.lot_number
                , p_lot_expiration =>
                MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                , p_revision =>p_interface_rec.revision
                , p_transaction_reason_id =>
                p_interface_rec.transaction_reason_id
                , p_transaction_process_mode => p_interface_rec.process_mode
                , p_simulate => p_simulate );
             --
IF (l_debug = 1) THEN
   MDEBUG( 'End of pre-update - 4');
END IF;
          END IF;

	  -- if optional_option = required if out of tolerance
	  -- approval option = 2 (never) or approval_option = 3 (out_of_toler)
	  -- p_approval_option_code = 1 is applicable only when lpn_id is null
          -- if lpn_id is not null, check container_adjustment_option = 2
       ELSE
          --
          IF p_adjustment_quantity <> 0 THEN
             --
             IF p_system_quantity <> 0 THEN
                --
                IF p_adjustment_quantity < 0 THEN
                   --
                   IF p_neg_meas_err IS NOT NULL
                      AND ABS((p_adjustment_quantity/p_system_quantity) *100) < p_neg_meas_err THEN
                      --
                      MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
          	      MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY := 0;
                      MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := 0;
                      --
IF (l_debug = 1) THEN
   MDEBUG( 'before pre-update logic - 5');
END IF;
                      Final_Preupdate_Logic(
                         p_reference => p_interface_rec.reference
                         , p_primary_uom_quantity =>
                         p_interface_rec.primary_uom_quantity
                         , p_count_uom => p_interface_rec.count_uom
                         , p_serial_number => p_interface_rec.serial_number
                         , p_subinventory =>p_interface_rec.subinventory
                         , p_lot_number =>p_interface_rec.lot_number
                         , p_lot_expiration =>
                         MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                         , p_revision =>p_interface_rec.revision
                         , p_transaction_reason_id =>
                         p_interface_rec.transaction_reason_id
                         , p_transaction_process_mode => p_interface_rec.process_mode
                         , p_simulate => p_simulate );
                      --
IF (l_debug = 1) THEN
   MDEBUG( 'before pre-update logic -end - 5');
END IF;
                   ELSE
                      --
                      IF(p_app_tol_neg IS NOT NULL AND
                        ABS((p_adjustment_quantity / p_system_quantity) * 100)>p_app_tol_neg) THEN
                         --
IF (l_debug = 1) THEN
   MDEBUG( 'Out of tol if neg tol is not null ');
END IF;
                         Out_Of_Tolerance(
                            p_reference => p_interface_rec.reference
                            , p_primary_uom_quantity =>
                            p_interface_rec.primary_uom_quantity
                            , p_count_uom => p_interface_rec.count_uom
                            , p_serial_number => p_interface_rec.serial_number
                            , p_subinventory =>p_interface_rec.subinventory
                            , p_lot_number =>p_interface_rec.lot_number
                            , p_lot_expiration_date =>
                            MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                            , p_revision =>p_interface_rec.revision
                            , p_transaction_reason_id =>
                            p_interface_rec.transaction_reason_id
                         , p_transaction_process_mode => p_interface_rec.process_mode
                         , p_simulate => p_simulate );
                         --
IF (l_debug = 1) THEN
   MDEBUG( 'end of tol - if negtol is not null');
END IF;
                      ELSE
                         --
                         IF((p_cost_tol_neg IS NOT NULL) AND
			   (ABS(p_adjustment_value) > p_cost_tol_neg))
			   THEN
                            --
                            Out_Of_Tolerance(
                               p_reference => p_interface_rec.reference
                               , p_primary_uom_quantity =>
                               p_interface_rec.primary_uom_quantity, p_count_uom =>
                               p_interface_rec.count_uom
                               , p_serial_number => p_interface_rec.serial_number
                               , p_subinventory =>p_interface_rec.subinventory
                               , p_lot_number =>p_interface_rec.lot_number
                               , p_lot_expiration_date =>
                               MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                               , p_revision =>p_interface_rec.revision
                               , p_transaction_reason_id =>
                               p_interface_rec.transaction_reason_id
                              , p_transaction_process_mode => p_interface_rec.process_mode
                              , p_simulate => p_simulate );
                            --
                         ELSE
                            --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerence-In');
END IF;
                            in_Tolerance(
                               p_reference => p_interface_rec.reference
                               , p_primary_uom_quantity =>
                               p_interface_rec.primary_uom_quantity
                               , p_count_uom => p_interface_rec.count_uom
                               , p_serial_number => p_interface_rec.serial_number
                               , p_subinventory =>p_interface_rec.subinventory
                               , p_lot_number =>p_interface_rec.lot_number
                               , p_lot_expiration_date =>
                               MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                               , p_revision =>p_interface_rec.revision
                               , p_transaction_reason_id =>
                               p_interface_rec.transaction_reason_id
                              , p_transaction_process_mode => p_interface_rec.process_mode
                              , p_simulate => p_simulate );
                            --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Tolerance -In -End ');
END IF;
                         END IF;
                      END IF;
                   END IF;
                   -- p_adjustment_quantity >= 0
                ELSE
                   --
                   IF p_pos_meas_err IS NOT NULL AND
                      ABS((p_adjustment_quantity/p_system_quantity) *100) < p_pos_meas_err THEN
                      --
                      MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY := 0;
                      MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := 0;
                      --
IF (l_debug = 1) THEN
   MDEBUG( 'before final preupdate logic - err is not null');
END IF;
                      Final_Preupdate_Logic(
                         p_reference => p_interface_rec.reference
                         , p_primary_uom_quantity =>
                         p_interface_rec.primary_uom_quantity, p_count_uom =>
                         p_interface_rec.count_uom
                         , p_serial_number => p_interface_rec.serial_number
                         , p_subinventory =>p_interface_rec.subinventory
                         , p_lot_number =>p_interface_rec.lot_number
                         , p_lot_expiration =>
                         MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                         , p_revision =>p_interface_rec.revision
                         , p_transaction_reason_id =>
                         p_interface_rec.transaction_reason_id
                         , p_transaction_process_mode => p_interface_rec.process_mode
                         , p_simulate => p_simulate );
                      --
IF (l_debug = 1) THEN
   MDEBUG( 'end of preupdate logic - err is not null');
END IF;
                   ELSE
                      --
                      IF(p_app_tol_pos IS NOT NULL AND
			ABS((p_adjustment_quantity / p_system_quantity) * 100) > p_app_tol_pos)

                       THEN
                         --
                         Out_Of_Tolerance(
                            p_reference => p_interface_rec.reference
                            , p_primary_uom_quantity =>
                            p_interface_rec.primary_uom_quantity
                            , p_count_uom => p_interface_rec.count_uom
                            , p_serial_number => p_interface_rec.serial_number
                            , p_subinventory =>p_interface_rec.subinventory
                            , p_lot_number =>p_interface_rec.lot_number
                            , p_lot_expiration_date =>
                            MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                            , p_revision =>p_interface_rec.revision
                            , p_transaction_reason_id =>
                            p_interface_rec.transaction_reason_id
                         , p_transaction_process_mode => p_interface_rec.process_mode
                         , p_simulate => p_simulate );
                         --
                      ELSE
                         --
                         IF(p_cost_tol_pos IS NOT NULL AND
                               (ABS(p_adjustment_value)
			   > p_cost_tol_pos))
			 THEN
                            --
                            Out_Of_Tolerance(
                               p_reference => p_interface_rec.reference
                               , p_primary_uom_quantity =>
                               p_interface_rec.primary_uom_quantity
                               , p_count_uom => p_interface_rec.count_uom
                               , p_serial_number => p_interface_rec.serial_number
                               , p_subinventory =>p_interface_rec.subinventory
                               , p_lot_number =>p_interface_rec.lot_number
                               , p_lot_expiration_date =>
                               MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                               , p_revision =>p_interface_rec.revision
                               , p_transaction_reason_id =>
                               p_interface_rec.transaction_reason_id
                              , p_transaction_process_mode => p_interface_rec.process_mode
                              , p_simulate => p_simulate );
                            --
                         ELSE
                            --
                            in_Tolerance(
                               p_reference => p_interface_rec.reference
                               , p_primary_uom_quantity =>
                               p_interface_rec.primary_uom_quantity, p_count_uom =>
                               p_interface_rec.count_uom
                               , p_serial_number => p_interface_rec.serial_number
                               , p_subinventory =>p_interface_rec.subinventory
                               , p_lot_number =>p_interface_rec.lot_number
                               , p_lot_expiration_date =>
                               MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                               , p_revision =>p_interface_rec.revision
                               , p_transaction_reason_id =>
                               p_interface_rec.transaction_reason_id
                              , p_transaction_process_mode => p_interface_rec.process_mode
                              , p_simulate => p_simulate );
                            --
                         END IF;
                      END IF;
                   END IF;
                END IF;
                -- system quantity = 0
             ELSE
                --
                IF (p_app_tol_pos IS NOT NULL AND
		  ABS((p_adjustment_quantity)*100) >p_app_tol_pos)
		THEN
         --             ABS((p_adjustment_quantity/p_system_quantity) * 100) >p_app_tol_pos) THEN
                   --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Out of tolerance ');
END IF;
                   out_Of_Tolerance(
                      p_reference => p_interface_rec.reference
                      , p_primary_uom_quantity =>
                      p_interface_rec.primary_uom_quantity, p_count_uom =>
                      p_interface_rec.count_uom
                      , p_serial_number => p_interface_rec.serial_number
                      , p_subinventory =>p_interface_rec.subinventory
                      , p_lot_number =>p_interface_rec.lot_number
                      , p_lot_expiration_date =>
                      MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                      , p_revision =>p_interface_rec.revision
                      , p_transaction_reason_id =>
                      p_interface_rec.transaction_reason_id
                      , p_transaction_process_mode => p_interface_rec.process_mode
                      , p_simulate => p_simulate );
                   --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-End of Out of Tolerance');
END IF;
                ELSE
                   --
                   IF((p_cost_tol_pos IS NOT NULL) AND
		     (ABS(p_adjustment_value) > p_cost_tol_pos))
		    THEN
                      --
                      Out_Of_Tolerance(
                         p_reference => p_interface_rec.reference
                         , p_primary_uom_quantity =>
                         p_interface_rec.primary_uom_quantity, p_count_uom =>
                         p_interface_rec.count_uom
                         , p_serial_number => p_interface_rec.serial_number
                         , p_subinventory =>p_interface_rec.subinventory
                         , p_lot_number =>p_interface_rec.lot_number
                         , p_lot_expiration_date =>
                         MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                         , p_revision =>p_interface_rec.revision
                         , p_transaction_reason_id =>
                         p_interface_rec.transaction_reason_id
                         , p_transaction_process_mode => p_interface_rec.process_mode
                         , p_simulate => p_simulate );
                      --
                   ELSE
                      --
                      in_Tolerance(
                         p_reference => p_interface_rec.reference
                         , p_primary_uom_quantity =>
                         p_interface_rec.primary_uom_quantity
                         , p_count_uom => p_interface_rec.count_uom
                         , p_serial_number => p_interface_rec.serial_number
                         , p_subinventory =>p_interface_rec.subinventory
                         , p_lot_number =>p_interface_rec.lot_number
                         , p_lot_expiration_date =>
                         MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                         , p_revision =>p_interface_rec.revision
                         , p_transaction_reason_id =>
                         p_interface_rec.transaction_reason_id
                         , p_transaction_process_mode => p_interface_rec.process_mode
                         , p_simulate => p_simulate );
                      --
                   END IF;
                END IF;
             END IF;
             -- adjustment qty = 0
          ELSE
             --
             MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
             MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY := 0;
             MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := 0;
             --
             Final_Preupdate_Logic(
                p_reference => p_interface_rec.reference
                , p_primary_uom_quantity =>
                p_interface_rec.primary_uom_quantity
                , p_count_uom => p_interface_rec.count_uom
                , p_serial_number => p_interface_rec.serial_number
                , p_subinventory =>p_interface_rec.subinventory
                , p_lot_number =>p_interface_rec.lot_number
                , p_lot_expiration =>
                MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date
                , p_revision =>p_interface_rec.revision
                , p_transaction_reason_id =>
                p_interface_rec.transaction_reason_id
                , p_transaction_process_mode => p_interface_rec.process_mode
                , p_simulate => p_simulate );
             --
          END IF;
       END IF;
       --
    END;
  END;
  --
  -- Zero count logic. count_type_code
  PROCEDURE Zero_Count_Logic(
  p_reference IN VARCHAR2 DEFAULT NULL,
  p_primary_uom_quantity IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Zero_Count_logic
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- this porcedure IS according to the count_type_code=4
    -- (zero COUNT) information without validation INTO
    -- temp data source OF cycle COUNT entries
    -- MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC_TMP
    -- Parameters:
    --     IN    :
    --  p_reference IN VARCHAR2(240) (optional)
    --  default NULL, LIKE a note what IS happened
    --
    --  p_primary_uom_quantity IN NUMBER (required)
    --  primary uom quantity
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       dummy integer;
    BEGIN
       -- SET the system quantity to 0
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_CURRENT := 0;
       -- SET the NUMBER OF counts to 0
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NUMBER_OF_COUNTS := 1;
       --SET the entry status code to completed
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
       -- SET approval TYPE to automatic
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_TYPE := 1;
       -- SET the employee id
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_CURRENT :=
       MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID;
       -- SET the approval DATE
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_DATE := SYSDATE;
       -- SET the COUNT TYPE CODE TO ZEROCOUNT
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_TYPE_CODE := 4;
       --
       MTL_CCEOI_PROCESS_PVT.Entry_to_Current
	 (p_reference => p_reference
	 , p_primary_uom_quantity => p_primary_uom_quantity );
       --
       MTL_CCEOI_PROCESS_PVT.Current_to_first
       (p_reference => p_reference
          , p_primary_uom_quantity => p_primary_uom_quantity
       );
       --
    END;
  END;
  --
  -- Calculates adjustments for Step 4
  PROCEDURE Calculate_Adjustment(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_inventory_item_id IN NUMBER ,
  p_organization_id IN NUMBER ,
  p_lpn_id IN NUMBER ,
  p_subinventory IN VARCHAR2 ,
  p_count_quantity IN NUMBER ,
  p_revision IN VARCHAR2 DEFAULT NULL,
  p_locator_id IN NUMBER DEFAULT NULL,
  p_lot_number IN VARCHAR2 DEFAULT NULL,
  p_serial_number IN VARCHAR2 DEFAULT NULL,
  p_serial_number_control_code IN NUMBER ,
  p_serial_count_option IN NUMBER ,
  p_system_quantity IN NUMBER DEFAULT NULL,
  p_secondary_system_quantity IN NUMBER DEFAULT NULL -- INVCONV
  )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Calculate_Adjustment
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE calculates
    --  the Adjustment amount, Adjustment Variance percentage AND
    -- Adjustment quantity AND store the VALUES INTO the package
    -- variables G_ADJUSTMENT_AMOUNT,
    -- G_ADJUSTMENT_VARIANCE_PERCENTAGE,
    -- G_ADJUSTMENT_QUANTITY OF the package
    -- The system quantity IS stored INTO the package variable
    -- MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
    -- MTL_CCEOI_VAR_PVZ
    --
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_inventory_item_id IN NUMBER (required)
    --  ID OF the inventory item
    --
    --  p_organization_id IN NUMBER (required)
    --  ID OF the organization
    --
    --  p_subinventory IN VARCHAR2 (required)
    --
    --  p_revision IN VARCHAR2 (optional - defaulted)
    --  default = NULL
    --  revision code OF the item, required IF it IS under revision control
    --
    --  p_locator_id IN NUMBER (optional - defaulted)
    --  default = NULL
    --  ID OF the locator, required IF it IS under locator control
    --
    --  p_lot_number IN VARCHAR2 (optional - defaulted)
    --  default = NULL
    --  Lot NUMBER, required IF it IS under lot control
    --
    --  p_serial_number IN VARCHAR2 (optional - defaulted)
    --  default = NULL
    --  Serial NUMBER, required IF this item IN under serial control
    --
    --  p_count_quantity IN NUMBER (required)
    --  Quantity OF the current COUNT FOR teh specific item
    --
    --  p_serial_number_control_code IN NUMBER (required)
    --  FROM TABLE MTL_SYSTEM_ITEMS
    --
    --  p_serial_count_option IN NUMBER (required)
    --  FROM TABLE MTL_CYCLE_COUNT_HEADERS
    --
    --  p_system_quantity in number (required - defaulted)
    --  default null
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --   18 = no system quantity FOR serial controlled item
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_primary_uom_adj_qty NUMBER := 0;
       L_item_cost NUMBER := 0;
       L_counter integer := 0;
       L_system_quantity NUMBER:= 0;
       L_secondary_system_quantity NUMBER := 0; -- INVCONV
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Calculate_Adjustment';
       l_cost_group_id NUMBER;
       l_cost_group VARCHAR2(10);
       l_return_status VARCHAR2(1);
       l_msg_count NUMBER;
       l_msg_data VARCHAR2(1000);
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Calculate_Adjustment;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY := 0;
       MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY := 0; -- INVCONV
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Inside Calc-Adj Qty');
   MDEBUG( 'Count Qty is = '||to_char(p_count_quantity));
END IF;
       -- API body
       -- Get the system_quantity
       -- Calculate system quantity always even if you have the
       -- sys qty from entry table
       --if (p_system_quantity is NULL ) THEN
        --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-InsideAdjQty- SysQty is null');
   MDEBUG( 'Org '||to_char(p_organization_id));
   MDEBUG( 'item '||to_char(p_inventory_item_id));
   MDEBUG( 'lpnid'||to_char(MTL_CCEOI_VAR_PVT.G_LPN_ID));
   MDEBUG( 'Sub '||p_subinventory);
   MDEBUG( 'Lot '||p_lot_number);
   MDEBUG( 'Locator '||to_char(p_locator_id));
   MDEBUG( 'SerlNo '||p_serial_number);
   MDEBUG( 'SerlNoCtrlCd '||to_char(p_serial_number_control_code));
   MDEBUG( 'SerlCntOption '||to_char(p_serial_count_option));
END IF;

  /* Bug #2650761
   * If the cost_group_id is not stamped in the interface record, then
   * obtain cost group from the cost group API
  */
  IF MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID IS NOT NULL THEN
    l_cost_group_id := MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID;
  ELSE
    BEGIN
      inv_cost_group_pvt.get_cost_group(
          x_cost_group_id     =>  l_cost_group_id,
          x_cost_group        =>  l_cost_group,
          x_return_status     =>  l_return_status,
          x_msg_count         =>  l_msg_count,
          x_msg_data          =>  l_msg_data,
          p_organization_id   =>  p_organization_id,
          p_lpn_id            =>  p_lpn_id,
          p_inventory_item_id =>  p_inventory_item_id,
          p_revision          =>  p_revision,
          p_subinventory_code =>  p_subinventory,
          p_locator_id        =>  p_locator_id,
          p_lot_number        =>  p_lot_number,
          p_serial_number     =>  p_serial_number);
    EXCEPTION
      WHEN OTHERS THEN
        l_cost_group_id := NULL;
    END;
  END IF;

  IF (l_debug = 1) THEN
     mdebug('cost group id returned is: ' || l_cost_group_id);
  END IF;

-- Bug 2823976
  IF (p_system_quantity is NULL ) THEN
	-- IF p_lpn_id IS NOT NULL THEN
	IF MTL_CCEOI_VAR_PVT.G_LPN_ID IS NOT NULL THEN -- 8300310
          IF p_inventory_item_id IS NOT NULL THEN
            -- Looking for a quanitity for an item withing a specific container.
            MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty
	 	(
			p_api_version		=> 0.9
		, 	p_init_msg_lst		=> fnd_api.g_true
		,	p_commit		=> fnd_api.g_true
		, 	x_return_status		=> x_return_status
		, 	x_msg_count		=> x_msg_count
		, 	x_msg_data		=> x_msg_data
		,  	p_organization_id    	=> p_organization_id
		-- ,	p_lpn_id		=> p_lpn_id
		,       p_lpn_id                => MTL_CCEOI_VAR_PVT.G_LPN_ID   -- 8300310
		,	p_inventory_item_id	=> p_inventory_item_id
		,	p_lot_number		=> p_lot_number
		,	p_revision		=> p_revision
		,	p_serial_number		=> p_serial_number
    ,	p_cost_group_id		=> l_cost_group_id
		--,	p_cost_group_id		=> MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID
		,	x_lpn_systemqty 	=> L_system_quantity
		,       x_lpn_sec_systemqty     => L_secondary_system_quantity -- INVCONV
		);

		   IF (l_debug = 1) THEN
 	           mdebug('MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty :' || L_system_quantity);
 	          END IF;


	  ELSE
	         IF (l_debug = 1) THEN
 	            mdebug('No Item given use MTL_CCEOI_VAR_PVT.G_LPN_ITEM_SYSTEM_QTY :' || L_system_quantity);
 	         END IF;
	       -- No item id given, thus system quantity will be same as count quantity
	       L_system_quantity := MTL_CCEOI_VAR_PVT.G_LPN_ITEM_SYSTEM_QTY;
	       L_secondary_system_quantity := MTL_CCEOI_VAR_PVT.G_LPN_ITEM_SEC_SYSTEM_QTY; -- INVCONV
	  END IF;
	ELSE

	-- No container given, regulare system quantity requested
        MTL_INV_UTIL_GRP.Calculate_Systemquantity
          (p_api_version => 0.9
          ,x_return_status => x_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data =>  x_msg_data
          ,p_organization_id =>  p_organization_id
          ,p_inventory_item_id => p_inventory_item_id
          ,p_subinventory => p_subinventory
          ,p_lot_number => p_lot_number
          ,p_revision => p_revision
          ,p_locator_id => p_locator_id
          ,	p_cost_group_id		=> l_cost_group_id
          --,p_cost_group_id => MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID
          ,p_serial_number => p_serial_number
          ,p_serial_number_control =>  p_serial_number_control_code
          ,p_serial_count_option => p_serial_count_option
          ,x_system_quantity => L_system_quantity
	  ,x_sec_system_quantity => L_secondary_system_quantity -- INVCONV
	  );

	      IF (l_debug = 1) THEN
 	         mdebug('MTL_INV_UTIL_GRP.Calculate_Systemquantity :' || L_system_quantity);
 	      END IF;

	END IF;

          -- in G_UOM_CODE UOM
          MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY :=
           L_system_quantity;

	  MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY := L_secondary_system_quantity; -- INVCONV
  ELSE

         MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY := p_system_quantity;
         MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY := p_secondary_system_quantity; -- INVCONV
  END IF; --End Bug 2823976

  -- BEGIN INVCONV
  IF MTL_CCEOI_VAR_PVT.G_TRACKING_QUANTITY_IND <> 'PS' THEN
     MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY := NULL;
  END IF;
  -- END INVCONV

IF (l_debug = 1) THEN
   MDEBUG( 'Process-InsideCSysQty '||to_char(MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY));
   MDEBUG( 'Process-CalQty '||to_char( L_system_quantity));
END IF;
          --
/* not reqd due to removal of if statement
       else
         --
          MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY :=
           p_system_quantity;
         --
IF (l_debug = 1) THEN
   MDEBUG(
END IF;
 'Process-InsidePSysQty '||to_char(MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY));

       END IF;
*/
       --
       -- Different UOMs THEN  convert
IF (l_debug = 1) THEN
   MDEBUG( 'PUOM UOM '||MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE||' - '||MTL_CCEOI_VAR_PVT.G_UOM_CODE );
END IF;
       IF MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE <>
          MTL_CCEOI_VAR_PVT.G_UOM_CODE THEN
          --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-Calc.PUOM AdjQty');
END IF;
          -- Calculate the primary uom adjustement quantity
          -- changes made to convert system qty back to prim.uom qty
          --bug 8526579 made the inv_convert call lot specific to honor lot specific conversions
          L_primary_uom_adj_qty :=
          nvl(INV_CONVERT.inv_um_convert(
             item_id =>p_inventory_item_id
             ,lot_number=> p_lot_number
	     ,organization_id=>p_organization_id
             , precision => 2
             , from_quantity => p_count_quantity
             , from_unit => MTL_CCEOI_VAR_PVT.G_UOM_CODE
             , to_unit => MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE
             , from_name => NULL
             , to_name => NULL
          ),0) -
            nvl( INV_CONVERT.inv_um_convert(
             item_id =>p_inventory_item_id
             ,lot_number=> p_lot_number
	     ,organization_id=>p_organization_id
             , precision => 2
             , from_quantity => MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
             , from_unit => MTL_CCEOI_VAR_PVT.G_UOM_CODE
             , to_unit => MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE
             , from_name => NULL
             , to_name => NULL
          ),0);

          --
IF (l_debug = 1) THEN
   MDEBUG( 'CalAdjQty : '||to_char(L_primary_uom_adj_qty));
   MDEBUG( 'Process-Calc.AdjQty in Count UOM ');
END IF;
          -- Calculate Adjustment quantity IN count_UOM
-- System qty is already calculated in Count UOM Code
-- calculation of adjqty changed by suresh - 10/2/98
          MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY :=
          p_count_quantity - nvl(MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY,0);
            /*
            nvl( INV_CONVERT.inv_um_convert(
             item_id =>p_inventory_item_id
             , precision => 2
             , from_quantity => MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
             , from_unit => MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE
             , to_unit => MTL_CCEOI_VAR_PVT.G_UOM_CODE
             , from_name => NULL
             , to_name => NULL
          ),0);
          */
IF (l_debug = 1) THEN
   MDEBUG( 'AdjQty-2 '||to_char(MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY));
END IF;
          --
       ELSE
          -- Calculate the primary uom adjustement quantity
          L_primary_uom_adj_qty :=
          nvl(p_count_quantity,0) - nvl(MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY,0);
          --
          -- Calculate Adjustment quantity IN count_UOM
          MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY :=
          nvl(p_count_quantity,0) - nvl(MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY,0);
          --
IF (l_debug = 1) THEN
   MDEBUG( 'AdjQty-3 '||to_char(L_primary_uom_adj_qty));
END IF;
       END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Process-GetItemCost ');
END IF;

  /* Bug 5409309 -Commenting out the following call to get the item cost.
                   Using the new local procedure get_item_cost
                   to fetch the item cost
       MTL_INV_UTIL_GRP.Get_Item_Cost(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_organization_id => p_organization_id,
          p_inventory_item_id => p_inventory_item_id,
          p_locator_id => p_locator_id,
          x_item_cost => L_item_cost); */

       --Item Cost

          Get_Item_Cost(
           p_organization_id => p_organization_id,
           p_inventory_item_id => p_inventory_item_id,
           p_locator_id => p_locator_id,
           p_cost_group_id => l_cost_group_id,
           x_item_cost =>l_item_cost)  ;

   /* End of fix for Bug 5721960*/


       --
       -- Adjustment Amount
IF (l_debug = 1) THEN
   MDEBUG( 'Process-GetItemCost U Cost'||to_char(L_item_cost));
   MDEBUG( 'Process-GetItemCost AdjQty'||to_char(L_primary_uom_adj_qty));
END IF;
       MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_AMOUNT :=
       L_primary_uom_adj_qty * L_item_cost;
       --
       MTL_CCEOI_VAR_PVT.G_ITEM_COST :=   L_item_cost;
       --
       IF MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY > 0 THEN
          MTL_CCEOI_VAR_PVT.G_ADJ_VARIANCE_PERCENTAGE :=
          100 *(MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY/
             MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY);
       ELSE
          MTL_CCEOI_VAR_PVT.G_ADJ_VARIANCE_PERCENTAGE := NULL;
       END IF;
       --
/*
       -- Commenting out by suresh to not to execute this code for testing
       -- item IS NOT under serial control
       -- AND system quantity IS 0 error OUT
       IF p_serial_number IS NOT NULL
          AND MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY = 0 THEN
          --
          x_errorcode := 17;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_ADJCALC_NO_SERIAL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
          --
       END IF;
*/
       --
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Calculate_Adjustment;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Calculate_Adjustment;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Calculate_Adjustment;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Calculate Tolerance
  PROCEDURE Calculate_Tolerance(
  p_item_app_tol_pos IN NUMBER ,
  p_item_app_tol_neg IN NUMBER ,
  p_class_app_tol_pos IN NUMBER ,
   p_class_app_tol_neg IN NUMBER ,
  p_class_cost_tol_pos IN NUMBER ,
  p_class_cost_tol_neg IN NUMBER ,
  p_head_app_tol_pos IN NUMBER ,
  p_head_app_tol_neg IN NUMBER ,
   p_head_cost_tol_pos IN NUMBER ,
  p_head_cost_tol_neg IN NUMBER ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Calculate_Tolerance
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- this PROCEDURE get the pos AND neg approval tolerance
    -- AND currency tolerance according to the presedence WHERE
    -- it IS defined, begining with the highest level.
    -- ITEM > CLASS > HEADER
    --  After calculating the tolerances the tolerance logic IS called.
    -- Parameters:
    --     IN    :
    --
    -- p_item_app_tol_pos IN NUMBER (required)
    -- MTL_CYCLE_COUNT_ENTRIES_V.APPROVAL_TOLERANCE_POSITIVE
    --
    -- p_item_app_tol_neg IN NUMBER (required)
    -- MTL_CYCLE_COUNT_ENTRIES_V.APPROVAL_TOLERANCE_NEGATIVE
    --
    -- p_class_app_tol_pos IN NUMBER (required)
    -- MTL_CYCLE_COUNT_ENTRIES_V.CLASS_APP_TOL_POS
    --
    -- p_class_app_tol_neg IN NUMBER (required)
    -- MTL_CYCLE_COUNT_ENTRIES_V.CLASS_APP_TOL_NEG
    --
    -- p_class_cost_tol_pos IN NUMBER (required)
    -- MTL_CYCLE_COUNT_ENTRIES_V.CLASS_COST_TOL_POS
    --
    -- p_class_cost_tol_neg IN NUMBER (required)
    -- MTL_CYCLE_COUNT_ENTRIES_V.CLASS_COST_TOL_NEG
    --
    -- p_head_app_tol_pos IN NUMBER (required)
    -- MTL_CYCLE_COUNT_HEADERS.APPROVAL_TOLERANCE_POSITIVE
    --
    -- p_head_app_tol_neg IN NUMBER (required)
    -- MTL_CYCLE_COUNT_HEADERS.APPROVAL_TOLERANCE_NEGATIVE
    --
    -- p_head_cost_tol_pos IN NUMBER (required)
    -- MTL_CYCLE_COUNT_HEADERS.COST_TOLERANCE_POSITIVE
    --
    -- p_head_cost_tol_neg IN NUMBER (required)
    -- MTL_CYCLE_COUNT_HEADERS.COST_TOLERANCE_NEGATIVE
    --
    --  p_simulate NUMBER (default = FND_API.G_FALSE)
    --  G_FALSE = allow changes to tables other than interface tables
    --  G_TRUE = no changes will be made to any outside tables
    --     OUT   :
    --
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       CURSOR L_ItemErrMeas_Csr (itemid in number, org in number) is
       select
         positive_measurement_error
       , negative_measurement_error
       from mtl_system_items
       where inventory_item_id = itemid
       and organization_id = org;
       --
       L_positive_measurement_error number;
       L_negative_measurement_error number;
       L_app_tol_pos NUMBER;
       L_app_tol_neg NUMBER;
       L_cost_tol_pos NUMBER;
       L_cost_tol_neg NUMBER;
    BEGIN
   IF (l_debug = 1) THEN
      MDEBUG( 'Inside Calculate Tol ');
   END IF;
       --
       IF p_item_app_tol_pos IS NULL THEN
          --
          IF p_class_app_tol_pos IS NULL THEN
             --
             L_app_tol_pos := p_head_app_tol_pos;
             --
          ELSE
             --
             L_app_tol_pos := p_class_app_tol_pos;
             --
          END IF;
          --
       ELSE
          --
          L_app_tol_pos := p_item_app_tol_pos;
          --
       END IF;
       --
       IF p_item_app_tol_neg IS NULL THEN
          --
          IF p_class_app_tol_neg IS NULL THEN
             --
             L_app_tol_neg :=p_head_app_tol_neg;
             --
          ELSE
             --
             L_app_tol_neg := p_class_app_tol_neg;
             --
          END IF;
          --
       ELSE
          --
          L_app_tol_neg := p_item_app_tol_neg;
          --
       END IF;
       --
       IF p_class_cost_tol_pos IS NULL THEN
          --
          L_cost_tol_pos := p_head_cost_tol_pos;
          --
       ELSE
          --
          L_cost_tol_pos := p_class_cost_tol_pos;
          --
       END IF;
       --
       IF p_class_cost_tol_neg IS NULL THEN
          --
          L_cost_tol_neg := p_head_cost_tol_neg;
          --
       ELSE
          --
          L_cost_tol_neg := p_class_cost_tol_neg;
          --
       END IF;
       --
   IF (l_debug = 1) THEN
      MDEBUG( 'Inside Calculate Tol '|| to_char(MTL_CCEOI_VAR_PVT.G_inventory_item_id)||' - '||to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID));
   END IF;

IF (l_debug = 1) THEN
   MDEBUG( 'Cal Tol-AdjQty '||to_char(MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY));
END IF;
       for c_rec in   L_ItemErrMeas_Csr (
         MTL_CCEOI_VAR_PVT.G_inventory_item_id,
         MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID) LOOP
		 --
         L_positive_measurement_error := c_rec.positive_measurement_error;
         L_negative_measurement_error := c_rec.negative_measurement_error;
		 --
       END LOOP;
       --
       Tolerance_Logic(
	        p_pos_meas_err =>L_positive_measurement_error
          , p_neg_meas_err =>  L_negative_measurement_error
          , p_app_tol_pos => L_app_tol_pos
          , p_app_tol_neg => L_app_tol_neg
          , p_cost_tol_pos =>L_cost_tol_pos
          , p_cost_tol_neg => L_cost_tol_neg
          , p_adjustment_value => MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_AMOUNT
          --MTL_CCEOI_VAR_PVT.G_ADJ_VARIANCE_PERCENTAGE
          , p_adjustment_quantity =>
          MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY
          , p_system_quantity =>
          MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
          , p_approval_option_code =>
          MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.APPROVAL_OPTION_CODE
          , p_interface_rec => p_interface_rec
          , p_simulate => p_simulate
       );
       --
    END;
  END;
  --
  -- Deletes entries in the interface tables
  PROCEDURE Delete_CCIEntry(
  p_cc_entry_interface_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Delete_CCEOIEntry
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE delete the entry from the interface table.
    -- Parameters:
    --     IN    :
    --  p_cc_entry_interface_id      IN  NUMBER (required)
    --  ID of the interface record/Entry
    --
    -- END OF comments
    DECLARE
       --
       dummy integer;
       --
    BEGIN
       --
       begin
         delete from mtl_cc_entries_interface
         where cc_entry_interface_id = p_cc_entry_interface_id;
       exception when others then
         null;
       end;
       --
    END;
  END;
  --
  -- Delete records from the cycle count interface error table
  PROCEDURE Delete_CCEOIError(
  p_cc_entry_interface_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Delete_CCEOIError
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE delete the errors of an interface entry
    -- Parameters:
    --     IN    :
    --  p_cc_entry_interface_id      IN  NUMBER (required)
    --  ID of the interface record/Entry
    --
    -- END OF comments
    DECLARE
       --
       dummy integer;
       --
    BEGIN
       --
       begin
         delete from mtl_cc_interface_errors
         where cc_entry_interface_id = p_cc_entry_interface_id;
       exception when others then
         null;
       end;
       --
    END;
  END;

  --
  --
  -- Insert the record into the application tables
  /*
  Pre-reqs:

 INVENTORY_ITEM_ID		 NOT NULL
 SUBINVENTORY			 NOT NULL
 ORGANIZATION_ID		 NOT NULL

  */
  PROCEDURE Insert_CCEntry(
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Insert_CCEntry
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- inserts the RECORD INTO MTL_CYCLE_COUNT_ENTRIES TABLE
    -- Parameters:
    --     IN    :
    -- p_interface_rec    IN  CCEOI_Rec_Type (required)
    -- complete interface RECORD
    -- END OF comments
    DECLARE
       L_CCEntryId NUMBER;
       l_count_due_date DATE;

    BEGIN
       SELECT
          MTL_CYCLE_COUNT_ENTRIES_S.nextval
       INTO
          L_CCEntryId
       FROM
          dual;
       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID := L_CCEntryId;
       IF (l_debug = 1) THEN
          MDEBUG( 'New CCId :  '||to_char(L_CCEntryId));
       END IF;

       l_count_due_date := Compute_Count_Due_Date(sysdate);
       --
       IF (l_debug = 1) THEN
          mdebug('date due:'||to_char(l_count_due_date));
       END IF;

       INSERT INTO MTL_CYCLE_COUNT_ENTRIES
          (     COST_GROUP_ID
             ,  PARENT_LPN_ID
             , OUTERMOST_LPN_ID
             , CYCLE_COUNT_ENTRY_ID
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , CREATION_DATE
             , CREATED_BY
             , LAST_UPDATE_LOGIN
             , COUNT_LIST_SEQUENCE
             , COUNT_DATE_FIRST
             , COUNT_DATE_CURRENT
             , COUNT_DATE_PRIOR
             , COUNT_DATE_DUMMY
             , COUNTED_BY_EMPLOYEE_ID_FIRST
             , COUNTED_BY_EMPLOYEE_ID_CURRENT
             , COUNTED_BY_EMPLOYEE_ID_PRIOR
             , COUNTED_BY_EMPLOYEE_ID_DUMMY
             , COUNT_UOM_FIRST
             , COUNT_UOM_CURRENT
             , COUNT_UOM_PRIOR
             , COUNT_QUANTITY_FIRST
             , COUNT_QUANTITY_CURRENT
             , COUNT_QUANTITY_PRIOR
             , INVENTORY_ITEM_ID
             , SUBINVENTORY
             , ENTRY_STATUS_CODE
             , COUNT_DUE_DATE
             , ORGANIZATION_ID
             , CYCLE_COUNT_HEADER_ID
             , NUMBER_OF_COUNTS
             , LOCATOR_ID
             , ADJUSTMENT_QUANTITY
             , ADJUSTMENT_DATE
             , ADJUSTMENT_AMOUNT
             , ITEM_UNIT_COST
             , INVENTORY_ADJUSTMENT_ACCOUNT
             , APPROVAL_DATE
             , APPROVER_EMPLOYEE_ID
             , REVISION
             , LOT_NUMBER
             , LOT_CONTROL
             , SYSTEM_QUANTITY_FIRST
             , SYSTEM_QUANTITY_CURRENT
             , SYSTEM_QUANTITY_PRIOR
             , REFERENCE_FIRST
             , REFERENCE_CURRENT
             , REFERENCE_PRIOR
             , PRIMARY_UOM_QUANTITY_FIRST
             , PRIMARY_UOM_QUANTITY_CURRENT
             , PRIMARY_UOM_QUANTITY_PRIOR
             , COUNT_TYPE_CODE
              , TRANSACTION_REASON_ID
             , REQUEST_ID
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , PROGRAM_UPDATE_DATE
             , APPROVAL_TYPE
             , ATTRIBUTE_CATEGORY
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , ATTRIBUTE9
             , ATTRIBUTE10
             , ATTRIBUTE11
             , ATTRIBUTE12
             , ATTRIBUTE13
             , ATTRIBUTE14
             , ATTRIBUTE15
             , SERIAL_NUMBER
             , SERIAL_DETAIL
             , APPROVAL_CONDITION
             , NEG_ADJUSTMENT_QUANTITY
             , NEG_ADJUSTMENT_AMOUNT
             , EXPORT_FLAG
             -- BEGIN INVCONV
             , SECONDARY_UOM_QUANTITY_FIRST
             , SECONDARY_UOM_QUANTITY_CURRENT
             , SECONDARY_UOM_QUANTITY_PRIOR
             , COUNT_SECONDARY_UOM_FIRST
             , COUNT_SECONDARY_UOM_CURRENT
             , COUNT_SECONDARY_UOM_PRIOR
             , SECONDARY_SYSTEM_QTY_FIRST
             , SECONDARY_SYSTEM_QTY_CURRENT
             , SECONDARY_SYSTEM_QTY_PRIOR
             , SECONDARY_ADJUSTMENT_QUANTITY
             -- END INVCONV
          )
       VALUES
          (    /* Bug 7517428-Passing the cost group id to insert in MCCE*/
	       MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID
             , MTL_CCEOI_VAR_PVT.G_LPN_ID    -- 8300310
             , MTL_CCEOI_VAR_PVT.G_LPN_ID
             , L_CCEntryId
             , sysdate
             , MTL_CCEOI_VAR_PVT.G_UserID
             , sysdate
             , MTL_CCEOI_VAR_PVT.G_UserID
             , MTL_CCEOI_VAR_PVT.G_UserID
             , nvl(p_interface_rec.COUNT_LIST_SEQUENCE,MTL_CCEOI_VAR_PVT.G_Seq_No)
           --  , p_interface_rec.count_list_sequence
             , NULL -- MTL_CCEOI_VAR_PVT.G_COUNT_DATE
             , NULL -- MTL_CCEOI_VAR_PVT.G_COUNT_DATE
             , NULL
             , NULL
             , NULL -- MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID
             , NULL -- MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID
             , NULL
             , NULL
             , NULL -- MTL_CCEOI_VAR_PVT.G_UOM_CODE
             , NULL -- MTL_CCEOI_VAR_PVT.G_UOM_CODE
             , NULL
             , NULL -- MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY
             , NULL -- MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY
             , NULL
             , MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID
             , MTL_CCEOI_VAR_PVT.G_SUBINVENTORY
             , 1
             , l_count_due_date
             , p_interface_rec.ORGANIZATION_ID
             , MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID
	     , NULL -- 0  XXX number of counts (null for new entries)
	     , MTL_CCEOI_VAR_PVT.G_LOCATOR_ID
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL --MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID
             , NULL
             , NULL
             , MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION   -- NULL  --Revision
             , MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER  -- NULL  --Lot Number
	 , decode(MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE, 1, null,
	 MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE)
             , NULL -- MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
             , NULL -- MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
             , NULL
             , NULL -- p_interface_rec.REFERENCE
             , NULL -- p_interface_rec.REFERENCE
             , NULL
             , NULL
             , NULL
             , NULL
             , 2     -- UNSCHEDULED COUNT
             , NULL
             , MTL_CCEOI_VAR_PVT.G_RequestID
             , MTL_CCEOI_VAR_PVT.G_ProgramAppID
             , MTL_CCEOI_VAR_PVT.G_ProgramID
             , sysdate
             , NULL -- DECODE(
              --  MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.APPROVAL_OPTION_CODE,
              --  1, 2, 2, 1, 3, 2, NULL)
             , p_interface_rec.ATTRIBUTE_CATEGORY
             , p_interface_rec.ATTRIBUTE1
             , p_interface_rec.ATTRIBUTE2
             , p_interface_rec.ATTRIBUTE3
             , p_interface_rec.ATTRIBUTE4
             , p_interface_rec.ATTRIBUTE5
             , p_interface_rec.ATTRIBUTE6
             , p_interface_rec.ATTRIBUTE7
             , p_interface_rec.ATTRIBUTE8
             , p_interface_rec.ATTRIBUTE9
             , p_interface_rec.ATTRIBUTE10
             , p_interface_rec.ATTRIBUTE11
             , p_interface_rec.ATTRIBUTE12
             , p_interface_rec.ATTRIBUTE13
             , p_interface_rec.ATTRIBUTE14
             , p_interface_rec.ATTRIBUTE15
             , p_interface_rec.SERIAL_NUMBER
             , NULL
             , NULL
             , NULL
             , NULL
             , 1 --  exported... do not forget to unexport
             -- BEGIN INVCONV
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             -- END INVCONV
          );
IF (l_debug = 1) THEN
   MDEBUG( 'End of New CCId :  '||to_char(L_CCEntryId));
END IF;
    EXCEPTION
        when others then
IF (l_debug = 1) THEN
   MDEBUG( 'Exception Error while Inserting..');
   	  MDEBUG( 'Error: ' || sqlerrm);
END IF;
	  raise fnd_api.g_exc_unexpected_error;
    END;
  END;
  --
  -- Insert the given record into MTL_CC_ENTRIES_INTERFACE
  PROCEDURE Insert_CCIEntry(
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ,
  x_return_status OUT NOCOPY VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Insert_CCIEntry
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- inserts the exported RECORD INTO MTL_CC_ENTRIESINTERFACE TABLE
    -- Parameters:
    --     IN    :
    -- p_interface_rec    IN  CCEOI_Rec_Type (required)
    -- complete interface RECORD
    --
    --  OUT :
    --  x_return_status VARCHAR2
    -- END OF comments
    DECLARE
       L_CCEOIId NUMBER :=  p_interface_rec.cc_entry_interface_id;
    BEGIN
       IF (l_debug = 1) THEN
          MDEBUG( 'Insert_CCIEntry: Before creation of new seq id');
       END IF;

       X_return_status := FND_API.G_RET_STS_SUCCESS;
       --

       IF p_interface_rec.cc_entry_interface_id IS NULL THEN
         BEGIN
          SELECT
             MTL_CC_ENTRIES_INTERFACE_S1.nextval
          INTO
             L_CCEOIId
          FROM
             dual;
        EXCEPTION
           WHEN OTHERS THEN
	IF (l_debug = 1) THEN
   	mdebug('id creation failed failed');
	END IF;
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END;
       END IF;
       --
       BEGIN
       --
       -- Calculate the system quantity
       NULL;
       --
	IF (l_debug = 1) THEN
   	mdebug('Insert_CCIEntry: ' || L_CCEOIId);
	END IF;
       INSERT INTO MTL_CC_ENTRIES_INTERFACE
        (  cost_group_name
         , cost_group_id
         , parent_lpn_id
         , outermost_lpn_id
         , CC_ENTRY_INTERFACE_ID
         , organization_id
         , last_update_date
         , last_updated_by
         , creation_date
         , created_by
         , last_update_login
         , CC_ENTRY_INTERFACE_GROUP_ID
         , CYCLE_COUNT_ENTRY_ID
         , action_code
	 , cycle_count_header_id
	 , cycle_count_header_name
	 , count_list_sequence
	 , inventory_item_id
	 , item_segment1
	 , item_segment2
	 , item_segment3
	 , item_segment4
	 , item_segment5
	 , item_segment6
	 , item_segment7
	 , item_segment8
	 , item_segment9
	 , item_segment10
	 , item_segment11
	 , item_segment12
	 , item_segment13
	 , item_segment14
	 , item_segment15
	 , item_segment16
	 , item_segment17
	 , item_segment18
	 , item_segment19
	 , item_segment20
         , revision
         , subinventory
	 , locator_id
	 , locator_segment1
	 , locator_segment2
	 , locator_segment3
	 , locator_segment4
	 , locator_segment5
	 , locator_segment6
	 , locator_segment7
	 , locator_segment8
	 , locator_segment9
	 , locator_segment10
	 , locator_segment11
	 , locator_segment12
	 , locator_segment13
	 , locator_segment14
	 , locator_segment15
	 , locator_segment16
	 , locator_segment17
	 , locator_segment18
	 , locator_segment19
	 , locator_segment20
         , lot_number
         , serial_number
         , primary_uom_quantity
	 , count_uom
	 , count_unit_of_measure
	 , count_quantity
	 , system_quantity
	 , adjustment_account_id
	 , account_segment1
	 , account_segment2
	 , account_segment3
	 , account_segment4
	 , account_segment5
	 , account_segment6
	 , account_segment7
	 , account_segment8
	 , account_segment9
	 , account_segment10
	 , account_segment11
	 , account_segment12
	 , account_segment13
	 , account_segment14
	 , account_segment15
	 , account_segment16
	 , account_segment17
	 , account_segment18
	 , account_segment19
	 , account_segment20
	 , account_segment21
	 , account_segment22
	 , account_segment23
	 , account_segment24
	 , account_segment25
	 , account_segment26
	 , account_segment27
	 , account_segment28
	 , account_segment29
	 , account_segment30
	 , count_date
	 , employee_id
	 , employee_full_name
	 , reference
	 , transaction_reason_id
	 , transaction_reason
         , request_id
         , program_application_id
         , program_id
         , program_update_date
         , lock_flag
         , process_flag
         , process_mode
	 , valid_flag
	 , delete_flag
	 , status_flag
	 , error_flag
	 , attribute_category
	 , attribute1
	 , attribute2
	 , attribute3
	 , attribute4
	 , attribute5
	 , attribute6
	 , attribute7
	 , attribute8
	 , attribute9
	 , attribute10
	 , attribute11
	 , attribute12
	 , attribute13
	 , attribute14
	 , attribute15
	 , project_id
	 , task_id
	 -- BEGIN INVCONV
	 , secondary_uom
	 , secondary_unit_of_measure
	 , secondary_count_quantity
	 , secondary_system_quantity
	 -- END INVCONV
          )
         VALUES
        (  p_interface_rec.cost_group_name
         , p_interface_rec.cost_group_id
         , p_interface_rec.parent_lpn_id
         , p_interface_rec.outermost_lpn_id
         , L_CCEOIId
         , p_interface_rec.organization_id
         , sysdate
         , MTL_CCEOI_VAR_PVT.G_UserID
         , sysdate
         , MTL_CCEOI_VAR_PVT.G_UserID
         , MTL_CCEOI_VAR_PVT.G_LoginID
         , P_interface_rec.CC_ENTRY_INTERFACE_GROUP_ID
	 , P_interface_rec.CYCLE_COUNT_ENTRY_ID
	 --- was always insert g_process. BUG??
	 , nvl(p_interface_rec.action_code, MTL_CCEOI_VAR_PVT.G_PROCESS)
	 , p_interface_rec.cycle_count_header_id
	 , p_interface_rec.cycle_count_header_name
	 , nvl(p_interface_rec.COUNT_LIST_SEQUENCE,MTL_CCEOI_VAR_PVT.G_Seq_No)
	 , p_interface_rec.inventory_item_id
	 , p_interface_rec.item_segment1
	 , p_interface_rec.item_segment2
	 , p_interface_rec.item_segment3
	 , p_interface_rec.item_segment4
	 , p_interface_rec.item_segment5
	 , p_interface_rec.item_segment6
	 , p_interface_rec.item_segment7
	 , p_interface_rec.item_segment8
	 , p_interface_rec.item_segment9
	 , p_interface_rec.item_segment10
	 , p_interface_rec.item_segment11
	 , p_interface_rec.item_segment12
	 , p_interface_rec.item_segment13
	 , p_interface_rec.item_segment14
	 , p_interface_rec.item_segment15
	 , p_interface_rec.item_segment16
	 , p_interface_rec.item_segment17
	 , p_interface_rec.item_segment18
	 , p_interface_rec.item_segment19
	 , p_interface_rec.item_segment20
         , p_interface_rec.revision
         , p_interface_rec.subinventory
	 , p_interface_rec.locator_id
	 , p_interface_rec.locator_segment1
	 , p_interface_rec.locator_segment2
	 , p_interface_rec.locator_segment3
	 , p_interface_rec.locator_segment4
	 , p_interface_rec.locator_segment5
	 , p_interface_rec.locator_segment6
	 , p_interface_rec.locator_segment7
	 , p_interface_rec.locator_segment8
	 , p_interface_rec.locator_segment9
	 , p_interface_rec.locator_segment10
	 , p_interface_rec.locator_segment11
	 , p_interface_rec.locator_segment12
	 , p_interface_rec.locator_segment13
	 , p_interface_rec.locator_segment14
	 , p_interface_rec.locator_segment15
	 , p_interface_rec.locator_segment16
	 , p_interface_rec.locator_segment17
	 , p_interface_rec.locator_segment18
	 , p_interface_rec.locator_segment19
	 , p_interface_rec.locator_segment20
         , p_interface_rec.lot_number
         , p_interface_rec.serial_number
         , p_interface_rec.primary_uom_quantity
	 , p_interface_rec.count_uom
	 , p_interface_rec.count_unit_of_measure
	 , p_interface_rec.count_quantity
	 , p_interface_rec.system_quantity --MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY
	 , p_interface_rec.adjustment_account_id
	 , p_interface_rec.account_segment1
	 , p_interface_rec.account_segment2
	 , p_interface_rec.account_segment3
	 , p_interface_rec.account_segment4
	 , p_interface_rec.account_segment5
	 , p_interface_rec.account_segment6
	 , p_interface_rec.account_segment7
	 , p_interface_rec.account_segment8
	 , p_interface_rec.account_segment9
	 , p_interface_rec.account_segment10
	 , p_interface_rec.account_segment11
	 , p_interface_rec.account_segment12
	 , p_interface_rec.account_segment13
	 , p_interface_rec.account_segment14
	 , p_interface_rec.account_segment15
	 , p_interface_rec.account_segment16
	 , p_interface_rec.account_segment17
	 , p_interface_rec.account_segment18
	 , p_interface_rec.account_segment19
	 , p_interface_rec.account_segment20
	 , p_interface_rec.account_segment21
	 , p_interface_rec.account_segment22
	 , p_interface_rec.account_segment23
	 , p_interface_rec.account_segment24
	 , p_interface_rec.account_segment25
	 , p_interface_rec.account_segment26
	 , p_interface_rec.account_segment27
	 , p_interface_rec.account_segment28
	 , p_interface_rec.account_segment29
	 , p_interface_rec.account_segment30
	 , p_interface_rec.count_date
	 , p_interface_rec.employee_id
	 , p_interface_rec.employee_full_name
	 , p_interface_rec.reference
	 , p_interface_rec.transaction_reason_id
	 , p_interface_rec.transaction_reason
         , MTL_CCEOI_VAR_PVT.G_RequestID
         , MTL_CCEOI_VAR_PVT.G_ProgramAppID
         , MTL_CCEOI_VAR_PVT.G_ProgramID
         , sysdate
         , p_interface_rec.lock_flag
         , 1 --p_interface_rec.process_flag
         , p_interface_rec.process_mode
	 , p_interface_rec.valid_flag
	 , p_interface_rec.delete_flag
	 , p_interface_rec.status_flag
	 , p_interface_rec.error_flag
	 , p_interface_rec.ATTRIBUTE_CATEGORY
	 , p_interface_rec.attribute1
	 , p_interface_rec.attribute2
	 , p_interface_rec.attribute3
	 , p_interface_rec.attribute4
	 , p_interface_rec.attribute5
	 , p_interface_rec.attribute6
	 , p_interface_rec.attribute7
	 , p_interface_rec.attribute8
	 , p_interface_rec.attribute9
	 , p_interface_rec.attribute10
	 , p_interface_rec.attribute11
	 , p_interface_rec.attribute12
	 , p_interface_rec.attribute13
	 , p_interface_rec.attribute14
	 , p_interface_rec.attribute15
	 , p_interface_rec.project_id
	 , p_interface_rec.task_id
	 -- BEGIN INVCONV
	 , p_interface_rec.secondary_uom
         , p_interface_rec.secondary_unit_of_measure
         , p_interface_rec.secondary_count_quantity
         , p_interface_rec.secondary_system_quantity
         -- END INVCONV
          );
	IF (l_debug = 1) THEN
   	mdebug('Insert_CCIEntry: Entry Inserted' || L_CCEOIId);
	END IF;
       	MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID := L_CCEOIId;
	MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM := TRUE;
        EXCEPTION
	  WHEN OTHERS THEN
	    if p_interface_rec.organization_id is null then
    	       x_return_status := fnd_api.g_ret_sts_error;
	    else
	       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    end if;
	    IF (l_debug = 1) THEN
   	    mdebug('Insert_CCIEntry: ' || sqlerrm);
	    END IF;
        END;
    END;
  END;
  --
  -- Insert record into Cycle Count Interface error table
  PROCEDURE Insert_CCEOIError(
  p_cc_entry_interface_id IN NUMBER ,
  p_error_column_name IN VARCHAR2 ,
  p_error_table_name IN VARCHAR2 ,
  p_message_name IN VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  :insert_CCEOIError
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- inserts error information INTO the interface error TABLE
    -- Parameters
    -- IN:
    -- p_cc_entry_interface_id IN NUMBER (required)
    -- ID OF the interface RECORD
    --
    -- p_error_column_name IN VARCHAR2 (required)
    -- Columnname OF the errorvalue
    --
    -- p_error_table_name IN VARCHAR2 (required)
    -- tablename OF the errorvalue
    --
    -- p_message_name IN VARCHAR2 (required)
    -- name OF the message
    --
    -- END OF COMMENT
    DECLARE
       L_interface_error_id NUMBER;
    BEGIN
       IF (l_debug = 1) THEN
          MDEBUG('Insert error: ' || FND_MESSAGE.GET_STRING('INV', p_message_name));
       END IF;
       --
       SELECT MTL_CC_INTERFACE_ERRORS_S.nextval
       INTO
          L_interface_error_id
       FROM
          dual;
       --
       INSERT INTO mtl_cc_interface_errors(
             interface_error_id,
             cc_entry_interface_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             error_message,
             error_column_name,
             error_table_name,
             message_name
          )
       VALUES
          (L_interface_error_id,
             p_cc_entry_interface_id,
             sysdate,
             MTL_CCEOI_VAR_PVT.G_UserID,
             sysdate,
             MTL_CCEOI_VAR_PVT.G_UserID,
             MTL_CCEOI_VAR_PVT.G_LoginID,
             MTL_CCEOI_VAR_PVT.G_RequestID,
             MTL_CCEOI_VAR_PVT.G_ProgramAppID,
             MTL_CCEOI_VAR_PVT.G_ProgramID,
             sysdate,
             FND_MESSAGE.GET_STRING('INV', p_message_name),
             p_error_column_name,
             p_error_table_name,
             p_message_name);
       --
    EXCEPTION
       WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
   	 MDEBUG('Insert_CCEOIError - Exception: ' || sqlerrm);
	 END IF;
    END;
  END;

  --
  -- This code was derived from INVATCEN.pld and is full of strange stuff
  -- Needs thorough review/rewrite
  -- Existing Serial number - checks existance of serial number
  -- in a given location and then runs adjustment transaction if necessary
  PROCEDURE Existing_Serial_Number(
  p_reference IN VARCHAR2 DEFAULT NULL,
  p_primary_uom_quantity IN NUMBER ,
  p_count_uom IN VARCHAR2 ,
  p_serial_number IN VARCHAR2 ,
  p_subinventory IN VARCHAR2 ,
  p_lot_number IN VARCHAR2 ,
  p_lot_expiration IN date ,
  p_revision IN VARCHAR2 ,
  p_transaction_reason_id IN NUMBER ,
  p_transaction_process_mode IN NUMBER DEFAULT 3,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Existing_Serial_number
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    -- p_reference IN VARCHAR2 (optional)
    -- default NULL
    --
    -- p_primary_uom_quantity IN NUMBER
    --
    -- p_count_uom IN VARCHAR2 (required)
    --
    -- p_subinventory IN VARCHAR2(required)
    --
    -- p_lot_number IN VARCHAR2 (required)
    --
    -- p_lot_expiration_date DATE (required)
    --
    -- p_revision IN VARCHAR2(required)
    --
    -- p_transaction_reasion_id IN NUMBER (required)
    --
    -- p_serial_number IN VARCHAR2 (required)
    --
    -- p_transaction_process_mode IN NUMBER (required-defaulted)
    --  default = 3 (Background processing)
    --
    --  p_simulate IN VARCHAR2 (defaulted)
    --   default = FND_API.G_FALSE - may update data in any tables
    --    FND_API.G_TRUE - may only update data in the interface tables
    --     OUT   :
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_success BOOLEAN;
       L_issue VARCHAR2(1) := 'I';
       L_Receipt VARCHAR2(1) := 'R';
       --
    BEGIN
       --
       --
       IF (l_debug = 1) THEN
          MDEBUG( 'Inside Existing_Serial_Number');
       END IF;


       -- XXX there used to be a check for serial detail being 2 (qty only)
       -- it is unclear what role serial_detail field plays in 1 serial/entry
       -- and therefore i am removing it
       -- if the s/n is shown on the system, but was count as missing
       IF(MTL_CCEOI_VAR_PVT.G_adjustment_quantity = -1) THEN
	  -- Adjust if possible
	  IF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.serial_adjustment_option = 1 THEN
	     --
	     -- Issue
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
	     l_success := MTL_CCEOI_PROCESS_PVT.check_serial_location(L_issue);

	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NEG_ADJUSTMENT_QUANTITY := 1;
	     --
	     IF(L_success = FALSE) THEN
		MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION := 1;
		MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	     END IF;
	     --
	     -- if serial adjustment option is "review all adjustments",
	     -- THEN send to approval
	  ELSIF
	    (MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.serial_adjustment_option = 2) THEN

	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NEG_ADJUSTMENT_QUANTITY := 1;
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION := 3;

	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	     --
	  END IF;
             -- if the s/n is missing on the system, but was count as present
       ELSIF
	 (MTL_CCEOI_VAR_PVT.G_adjustment_quantity = 1) THEN
	  --
	  IF(
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.serial_adjustment_option = 1) THEN
	     -- Receipt
	     L_success := MTL_CCEOI_PROCESS_PVT.check_serial_location(L_Receipt);
	     --
-- in case of failure just send for manual approval for now
	     IF (L_success = TRUE) THEN

		MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
	     ELSE
		-- send it for further manual approval
		MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION := 1;
		MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	     END IF;

                --
                -- if serial adjustment option is "review all adjustments",
                -- then send to approval
             ELSIF
	       MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.serial_adjustment_option=2 THEN


                MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION := 3;
                MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
                --
             END IF;
             -- all other cases considered as no problem, no adjustment required
	  ELSE
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NEG_ADJUSTMENT_QUANTITY := NULL;
	     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION := NULL;


             MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 5;
             --
		--
       END IF;
             Final_Preupdate_Logic(
                p_reference => p_reference
                , p_primary_uom_quantity => p_primary_uom_quantity
                , p_count_uom => p_count_uom
                , p_serial_number => p_serial_number
                , p_subinventory => p_subinventory
                , p_lot_number => p_lot_number
                , p_lot_expiration => p_lot_expiration
                , p_revision => p_revision
                , p_transaction_reason_id => p_transaction_reason_id
                , p_transaction_process_mode => p_transaction_process_mode
                , p_simulate => p_simulate);

       --
    END;
  END;
  --
  -- Set the export flag in the table MTL_CYCLE_COUNT_ENTRIES
  PROCEDURE Set_CCExport(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_cycle_count_entry_id IN NUMBER ,
  p_export_flag IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Set_CCExport
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- SET export flag to orginal RECORD IN the MTL_CYCLE_COUNT_ENTRIES TABLE
    -- Parameters:
    --     IN    :
    -- p_api_version      IN  NUMBER (required)
    -- API Version of this procedure
    --
    -- p_init_msg_list   IN  VARCHAR2 (optional)
    -- DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    -- DEFAULT = FND_API.G_FALSE,
    --
    -- p_validation_level IN  NUMBER (optional)
    -- DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_cycle_count_entry_id    IN  NUMBER (required)
    -- cycle COUNT entry id
    --
    -- P_export_flag IN NUMBER (required)
    -- 1 = Yes it is exported
    -- 2 = No it is not exported
    --  value OF the export flag to be SET
    --     OUT   :
    -- X_return_status    OUT NUMBER
    -- Result of all the operations
    -- x_msg_count        OUT NUMBER,
    -- x_msg_data         OUT VARCHAR2,
    -- RETURN value OF the Error status
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Set_CCExport';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Set_CCExport;
       --
       -- Standard Call to check for call compatibility
IF (l_debug = 1) THEN
   MDEBUG( 'SetCCExport : Before API');
END IF;
       IF NOT FND_API.Compatible_API_Call(
             l_api_version, p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'SetCCExport : After API');
END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'SetCCExport : After Init');
END IF;
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   MDEBUG( 'SetCCExport : Before Update CCEId '||to_char(p_cycle_count_entry_id) ||' to '|| to_char(p_export_flag));
END IF;

       UPDATE mtl_cycle_count_entries
       SET
          export_flag = p_export_flag
          , last_update_date = sysdate
          , last_updated_by = MTL_CCEOI_VAR_PVT.G_UserID
          , last_update_login = MTL_CCEOI_VAR_PVT.G_LoginID
          , request_id = MTL_CCEOI_VAR_PVT.G_RequestID
          , program_application_id = MTL_CCEOI_VAR_PVT.G_ProgramAppID
          , program_id = MTL_CCEOI_VAR_PVT.G_ProgramID
          , program_update_date = sysdate
       WHERE
          cycle_Count_entry_id = p_cycle_count_entry_id;
IF (l_debug = 1) THEN
   MDEBUG( 'SetCCExport : After Update');
END IF;
       --
       IF SQL%ROWCOUNT <> 1 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'SetCCExport : Error Update');
END IF;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_COULD_NOT_LOCK');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       --   --
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Set_CCExport;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Set_CCExport;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Set_CCExport;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Set the Flags in the interface table.
  PROCEDURE Set_CCEOIFlags(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_cc_entry_interface_id IN NUMBER ,
  p_flags IN VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Set_CCEOIFlags
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- SET all the flags IN the interface TABLE
    -- mtl_cc_entries_interface
    -- Parameters:
    --     IN    :
    -- p_api_version      IN  NUMBER (required)
    -- API Version of this procedure
    --
    -- p_init_msg_list   IN  VARCHAR2 (optional)
    -- DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    -- DEFAULT = FND_API.G_FALSE,
    --
    -- p_validation_level IN  NUMBER (optional)
    -- DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_cc_entry_interface_id    IN  NUMBER (required)
    -- cycle COUNT entry interface id
    --
    -- P_flags IN VARCHAR2(4) (required)
    --  value OF the flags. IF one letter IS $, this means
    --  that the value OF the column IS NOT changed
    --  1. Letter = Error_flag
    --  2. Letter = delete_flag
    --  3. Letter = status_flag
    --  4. Letter = valid_flag
    --
    --     OUT   :
    -- X_return_status    OUT NUMBER
    -- Result of all the operations
    -- x_msg_count        OUT NUMBER,
    -- x_msg_data         OUT VARCHAR2,
    -- RETURN value OF the Error status
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Set_CCEOIFlag';
       L_error NUMBER;
       L_valid NUMBER;
       L_status NUMBER;
       L_delete NUMBER;
    BEGIN

       -- Standard start of API savepoint
       SAVEPOINT SET_CCEOIVALID;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(
             l_api_version, p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;

       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
       -- UPDATE the flags according to the parameter
       --

--MDEBUG( 'Process:Setsflag : IFace ID'||to_char( p_cc_entry_interface_id));

IF (l_debug = 1) THEN
   MDEBUG( 'Process:Setsflag-Delete '||p_flags);
END IF;

       UPDATE mtl_cc_entries_interface
       SET
             last_update_date = sysdate
             , last_updated_by = MTL_CCEOI_VAR_PVT.G_UserID
             , last_update_login = MTL_CCEOI_VAR_PVT.G_LoginID
             , request_id = MTL_CCEOI_VAR_PVT.G_RequestID
             , program_application_id = MTL_CCEOI_VAR_PVT.G_ProgramAppID
             , program_id = MTL_CCEOI_VAR_PVT.G_ProgramID
             , program_update_date = sysdate
             , error_flag = DECODE(SUBSTR(p_flags, 1, 1), '$', error_flag, SUBSTR(p_flags, 1, 1))
             , delete_flag = DECODE(SUBSTR(p_flags, 2, 1), '$', delete_flag, SUBSTR(p_flags, 2, 1))
             , status_flag = DECODE(SUBSTR(p_flags, 3, 1), '$', status_flag, SUBSTR(p_flags, 3, 1))
             , valid_flag = decode ( SUBSTR(p_flags, 1, 1),'1','2',DECODE(SUBSTR(p_flags, 4, 1), '$', valid_flag, SUBSTR(p_flags, 4, 1)))
       --      , cycle_count_entry_id = nvl(cycle_count_entry_id,MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID)
       WHERE
          cc_entry_interface_id = p_cc_entry_interface_id;

       --
       IF SQL%ROWCOUNT <> 1 THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_COULD_NOT_LOCK');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       --   --
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
	IF (l_debug = 1) THEN
   	mdebug('Error in Set_CCEOIFlags');
	END IF;
       ROLLBACK TO Set_CCEOIValid;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
	IF (l_debug = 1) THEN
   	mdebug('Unexpected Error in Set_CCEOIFlags');
	END IF;
       ROLLBACK TO Set_CCEOIValid;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
	IF (l_debug = 1) THEN
   	mdebug('Other Error in Set_CCEOIFlags');
	END IF;
       ROLLBACK TO SET_CCEOIVALID;
	IF (l_debug = 1) THEN
   	mdebug('After Rollback for Other Error in Set_CCEOIFlags');
	END IF;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates the cycle count header
  PROCEDURE Validate_CHeader(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_cycle_count_header_id IN NUMBER ,
  p_cycle_count_header_name IN VARCHAR2 DEFAULT NULL)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CHeader
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the cycle COUNT header information.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_cycle_count_header_id IN  NUMBER default NULL (required - defaulted NULL)
    --   Cycle COUNT header ID
    --
    --   p_cycle_count_header_name IN VARCHAR2 (optional)
    --   Default = NULL
    --   cycle COUNT header name, only IF ID IS missing
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CHeader';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CHeader;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       IF (l_debug = 1) THEN
          mdebug('Process: In Validate_CHeader ' || to_char(p_cycle_count_header_id));
       END IF;

       -- Validate the cycle COUNT header
       MTL_INV_VALIDATE_GRP.Validate_CountHeader(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          X_ErrorCode => x_errorcode,
          p_cycle_count_header_id => p_cycle_count_header_id,
          p_cycle_count_header_name => p_cycle_count_header_name
       );
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_CHeader return'||x_return_status);
END IF;
       -- Write INTO interface error TABLE
       IF x_errorcode = 2 THEN
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id =>
             MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID, p_error_column_name =>
             'CYCLE_COUNT_HEADER_ID'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_INVALID_HEADER'
          );
       ELSIF
          x_errorcode = 1 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'CYCLE_COUNT_HEADER_ID'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_NO_HEADER'
          );
       ELSIF
          x_errorcode = 45 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'CYCLE_COUNT_HEADER_ID'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_MULT_HEADER'
          );
       ELSIF x_errorcode = 0 THEN
          -- Get stock_locator_control
          MTL_INV_VALIDATE_GRP.Get_StockLocatorControlCode(
             MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id);
	  IF (l_debug = 1) THEN
   	  mdebug('Process: In Validate_CHeader derive stock locator ='||to_char(MTL_CCEOI_VAR_PVT.G_STOCK_LOCATOR_CONTROL_CODE));
	  END IF;

	  -- derive adjustment account info
	  MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID :=
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.INVENTORY_ADJUSTMENT_ACCOUNT;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate the count list sequence of the cycle count entry
  PROCEDURE Validate_CountListSeq(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY  NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_cycle_count_header_id IN NUMBER ,
  p_cycle_count_entry_id IN NUMBER ,
  p_count_list_sequence IN NUMBER ,
  p_organization_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountListSeq
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the cycle COUNT list sequence for the specified
    -- header information.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --      0 = FOR Export validation
    --
    --   p_cycle_count_header_id IN  NUMBER (required -)
    --   Cycle COUNT header ID
    --
    --   p_count_list_sequence IN NUMBER (required)
    --   COUNT list sequence
    --
    --  p_organization_id IN NUMBER (required)
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountListSeq';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountListSeq;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_CountListSequence ' || to_char(p_count_list_sequence));
END IF;
       MTL_INV_VALIDATE_GRP.Validate_CountListSequence(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          X_ErrorCode => x_errorcode,
          p_cycle_count_header_id => p_cycle_count_header_id,
          p_cycle_count_entry_id => p_cycle_count_entry_id,
          p_count_list_sequence => p_count_list_sequence,
          p_organization_id =>  p_organization_id
       );
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_CountListSequence Return='||x_return_status || ' ' || to_char(x_errorcode));
END IF;
       --
       IF x_errorcode = 46 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'CYCLE_COUNT_HEADER_ID'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_UNMATCH_LISTSEQ'
          );
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_errorcode in (65,66) THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validate Seq for Unsch.'||to_char(x_errorcode));
END IF;
          -- Get all the item information to store IN package var
          MTL_INV_VALIDATE_GRP.Get_Item_SKU(
             MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC);
       ELSIF
          x_errorcode = 3 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'CYCLE_COUNT_HEADER_ID'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_MULT_MATCH_REQ'
          );
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          x_errorcode = 0 THEN
          IF (l_debug = 1) THEN
             mdebug('Process: In Validate_CountListSequence Derive ItemSKU');
          END IF;
          -- Get all the item information to store IN package var
          MTL_INV_VALIDATE_GRP.Get_Item_SKU(
             MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC);
       END IF;
       --
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- validate item and sku information
  PROCEDURE Validate_ItemSKU(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_cycle_count_header_id IN NUMBER ,
  p_inventory_item_rec IN MTL_CCEOI_VAR_PVT.Inv_Item_rec_type ,
  p_sku_rec IN MTL_CCEOI_VAR_PVT.Inv_SKU_Rec_Type ,
  p_subinventory IN VARCHAR2 ,
  p_locator_rec IN MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE ,
  p_organization_id IN number,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_ItemSKU
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the item AND SKU information.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_cycle_count_header_id IN NUMBER (required)
    -- Cycle COUNT header id
    --
    -- p_inventory_item_rec MTL_CCEOI_VAR_PVT.INV_ITEM_REC_TYPE (required)
    -- Item information with segements
    --
    -- p_sku_rec MTL_CCEOI_VAR_PVT.INV_SKU_REC_TYPE (required)
    -- Item SKU information
    --
    -- p_subinventory IN VARCHAR2 (required)
    -- Item Subinventory
    --
    -- p_locator_rec MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE (required)
    -- Item locator information
    --
    -- p_organization_id IN NUMBER (required)
    -- organization_id
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       L_message_name VARCHAR2(100);
       L_table_name VARCHAR2(30);
       L_column_name VARCHAR2(32);
       L_counter integer := 0;
       L_P_inventory_item_id NUMBER ;
       L_P_locator_id NUMBER ;
       L_is_Unscheduled_Request boolean;
       --
       L_lot INV_Validate.LOT;
       L_org INV_Validate.ORG;
       L_item INV_Validate.ITEM;
       L_sub INV_Validate.SUB;
       L_serial INV_Validate.SERIAL;
       L_loc INV_Validate.LOCATOR;
       --
       --Begin changes 3904722
       l_ret_value NUMBER;
       l_to_serial VARCHAR2(30);
       l_msg_data  VARCHAR2(2000);
       l_serial_quantity NUMBER;
       --End changes 3904722
        l_count      NUMBER;   --8300310
       CURSOR L_CCEntry_Csr(itemid IN NUMBER, lpnid IN NUMBER, subinv IN VARCHAR2,
             org IN NUMBER, header IN NUMBER, loc IN NUMBER, rev IN VARCHAR2,
             ser IN VARCHAR2, lot IN VARCHAR2, cost IN NUMBER)
          IS SELECT
          *
          FROM mtl_cycle_count_entries
       WHERE
          cycle_count_header_id = header
          AND organization_id = org
          AND inventory_item_id = itemid
          AND NVL(parent_lpn_id, -1) = NVL(lpnid, -1)
          AND NVL(cost_group_id, -1) = NVL(cost, -1)
          AND subinventory = subinv
          AND entry_status_code IN(1, 2, 3)
          AND(loc IS NULL OR
             locator_id = loc)
          AND(rev IS NULL OR
             revision = rev)
          AND(lot IS NULL OR
             lot_number = lot)
          AND(ser IS NULL OR
             serial_number =ser);
       --
       L_check_locator NUMBER;
       L_control_level NUMBER;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_ItemSKU';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_ItemSKU;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU');
END IF;
       --
     /* Validate  API Implementation for Item validation
        This is implemented in called function */
       MTL_INV_VALIDATE_GRP.Validate_Item(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          x_errorcode => x_errorcode,
          p_inventory_item_rec => p_inventory_item_rec,
          p_organization_id => p_organization_id,
          p_cycle_count_header_id => p_cycle_count_header_id);

IF (l_debug = 1) THEN
   MDEBUG( 'Validate_Item Return='||x_return_status);
   MDEBUG( 'Validate_Item Return x_errorcode='||x_errorcode);
   mdebug('Process: In Validate_ItemSKU Return='||x_return_status);	       --
END IF;
       IF x_errorcode >0 THEN
          IF x_errorcode = 4 THEN
             L_message_name := 'INV_CCEOI_NO_ITEM';
             L_table_name := 'MTL_SYSTEM_ITEMS';
             L_column_name := 'INVENTORY_ITEM AND ITEM_SEGMENTS';
          ELSIF
             x_errorcode = 5 THEN
             L_message_name := 'INV_CCEOI_INVALID_ITEM';
             L_table_name := 'MTL_CYCLE_COUNT_ITEMS';
             L_column_name := 'INVENTORY_ITEM_ID';
	  END IF;

          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => L_column_name
             , p_error_table_name => L_table_name
             , p_message_name => L_message_name
						 );
          --
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          x_errorcode < 0 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'unexpected error'
             , p_error_table_name => 'unexpected error'
             , p_message_name => 'unexpected error'
          );
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Subinv ');
   MDEBUG( 'Validate_Sub Inv');
END IF;
       -- Validate Subinventory
       /* Validate  API Implementation for Subinv validation
          This is introduced in called API */
       MTL_INV_VALIDATE_GRP.Validate_Subinv(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          x_errorcode => x_errorcode,
          p_subinventory => p_subinventory,
          p_organization_id => p_organization_id,
          p_orientation_code =>
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORIENTATION_CODE,
          p_cycle_count_header_id => p_cycle_count_header_id);

IF (l_debug = 1) THEN
   MDEBUG( 'Validate_Item Subinv Return='||x_return_status);
END IF;

       --
       IF x_errorcode >0 THEN
          IF x_errorcode = 7 THEN
             L_message_name := 'INV_CCEOI_INVALID_SUB';
             L_table_name := 'MTL_CC_SUBINVENTORIES';
             L_column_name := 'SUBINVENTORY';
          ELSIF
             x_errorcode = 6 THEN
             L_message_name := 'INV_CCEOI_NO_SUB';
             L_table_name := 'No TABLE';
             L_column_name := 'No column';
          ELSIF
             x_errorcode = 8 THEN
             L_message_name := 'INV_CCEOI_NON_QTY_TRKD_SUB';
             L_table_name := 'MTL_SECONDARY_INVENTORIES';
             L_column_name := 'QUANTITY_TRACKED';
          END IF;
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => L_column_name
             , p_error_table_name => L_table_name
             , p_message_name => L_message_name
          );
          --
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          x_errorcode < 0 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'unexpected error'
             , p_error_table_name => 'unexpected error'
             , p_message_name => 'unexpected error'
          );
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- IS item under locator control
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Locator Control');
END IF;
       MTL_INV_VALIDATE_GRP.Locator_Control(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_org_control => MTL_CCEOI_VAR_PVT.G_STOCK_LOCATOR_CONTROL_CODE,
          p_sub_control => MTL_CCEOI_VAR_PVT.G_SUB_LOCATOR_TYPE,
	  p_item_control => MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE,
	 -- G_ITEM_LOCATOR_TYPE, -- XXX never set
          x_locator_control => L_check_locator,
          x_level => L_control_level
       );
IF (l_debug = 1) THEN
   MDEBUG( 'Validate_Item  Locator Control Return='||x_return_status);
   MDEBUG( 'Validate_Ctrl Rev : '||p_sku_rec.revision);
   MDEBUG( 'Validate_Ctrl Loc : '||to_char(p_locator_rec.locator_id));
END IF;
       --
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Val_Ctrol ');
END IF;
       -- Validate Control information
       MTL_INV_VALIDATE_GRP.Validate_Ctrol(
          p_api_version => 0.9,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          x_errorcode => x_errorcode,
          p_inventory_item_id => MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID,
          p_organization_id => p_organization_id,
          p_locator_rec => p_locator_rec,
          p_lot_number => p_sku_rec.lot_number,
          p_revision => p_sku_rec.revision,
          p_serial_number => p_sku_rec.serial_number,
          p_locator_control => L_check_locator
       );
IF (l_debug = 1) THEN
   MDEBUG( 'Validate_Item  call Val_Ctrol Return='||x_return_status);
   mdebug('Process: In Validate_ItemSKU call Val_Ctrol Return='||x_return_status);
END IF;
       --
       IF x_errorcode >0 THEN
          L_table_name := 'MTL_SYSTEM_ITEMS';
          IF x_errorcode = 9 THEN
             L_message_name := 'INV_CCEOI_NO_LOC';
             L_column_name := 'LOCATION_CONTROL_CODE';
          ELSIF x_errorcode = 11 THEN
             L_message_name := 'INV_CCEOI_NO_REV';
             L_column_name := 'REVISION_QTY_CONTROL_CODE';
          ELSIF x_errorcode = 13 THEN
             L_message_name := 'INV_CCEOI_NO_LOT';
             L_column_name := 'LOT_CONTROL_CODE';
          ELSIF x_errorcode = 15 THEN
             L_message_name := 'INV_CCEOI_NO_SERIAL';
             L_column_name := 'SERIAL_NUMBER_CONTROL_CODE';
          END IF;
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => L_column_name
             , p_error_table_name => L_table_name
             , p_message_name => L_message_name
          );
          --
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          x_errorcode < 0 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'unexpected error'
             , p_error_table_name => 'unexpected error'
             , p_message_name => 'unexpected error'
          );
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --

       -- XXX big mess here (locator check should be based on a control level
       -- derived based on control code of org/sub/item not just item )
       -- we do not check restricted locator lists
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validate Loc Chk: '||to_char(MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE));
END IF;
       IF L_check_locator IN(2, 3) THEN
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Val_Locator');
   MDEBUG( 'Validate Loc : '||to_char(p_locator_rec.locator_id));
END IF;
          -- Validate Locator
          /* Validate  API Implementation done in called procedure
             since it has multiple call for Locator validation */

          MTL_INV_VALIDATE_GRP.Validate_Locator(
	    p_api_version => 0.9,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    x_errorcode => x_errorcode,
	    p_locator_rec => p_locator_rec,
	    p_organization_id => p_organization_id,
	    p_subinventory => p_subinventory,
	    p_inventory_item_id => p_inventory_item_rec.inventory_item_id,
	    p_locator_control => L_check_locator,
	    p_control_level => L_control_level,
	    p_restrict_control =>
	    MTL_CCEOI_VAR_PVT.G_SKU_REC.RESTRICT_LOCATORS_CODE,
	    p_simulate => p_simulate);
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Val_Locator Return='||x_return_status);
END IF;
          --
          IF x_errorcode >0 THEN
             IF x_errorcode = 10 THEN
                L_table_name := 'MTL_ITEM_LOCATIONS_KFV';
                L_message_name := 'INV_CCEOI_INVALID_LOC';
                L_column_name := 'INVENTORY_LOCATION_ID';
             ELSIF
                x_errorcode = 47 THEN
                L_table_name := 'MTL_SECONDARY_LOCATORS';
                L_message_name := 'INV_CCEOI_LOC_NOT_IN_LIST';
                L_column_name := 'SECONDARY_LOCATOR';
             END IF;
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => L_column_name
                , p_error_table_name => L_table_name
                , p_message_name => L_message_name
						    );
		RAISE FND_API.G_EXC_ERROR;
          ELSIF
             x_errorcode < 0 THEN
             --
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'unexpected error'
                , p_error_table_name => 'unexpected error'
                , p_message_name => 'unexpected error'
             );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
	  -- location contorl code is either no locator control, determined at
	  -- subinv level or determined at item level
	 ELSE
	    MTL_CCEOI_VAR_PVT.G_LOCATOR_ID := NULL; -- XXX not sure about that
	 END IF;
       --
       -- IS item under revision control
       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE = 2 THEN
          -- Validate Revision
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Val_revision ');
END IF;
          /* Validate  API Implementation for Revision validation */
          --
          l_org.organization_id := p_organization_id;
          l_item.inventory_item_id := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
          --
          IF p_sku_rec.revision is null then
             x_errorcode := 12 ;
          ELSIF INV_Validate.Revision(p_sku_rec.revision,
                                        L_org,
                                        L_item
                                        ) = INV_Validate.T then
             MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION := p_sku_rec.revision;
             x_errorcode := 0;
          ELSE
             x_errorcode := 12;
          END IF;
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Val_revision Return='||x_return_status);
END IF;
          --
          IF x_errorcode >0 THEN
             L_table_name := 'MTL_ITEM_REVISIONS';
             L_column_name := 'REVISION';
             IF x_errorcode = 11 THEN
                L_message_name := 'INV_CCEOI_NO_REV';
             ELSIF x_errorcode = 12 THEN
                L_message_name := 'INV_CCEOI_LOC_INVALID_REV';
             END IF;
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => L_column_name
                , p_error_table_name => L_table_name
                , p_message_name => L_message_name
						    );
		RAISE FND_API.G_EXC_ERROR;
          ELSIF
             x_errorcode < 0 THEN
             --
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'unexpected error'
                , p_error_table_name => 'unexpected error'
                , p_message_name => 'unexpected error'
             );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
       END IF;
       --
       -- IS the item under lot control
       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE = 2 THEN
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_ItemSKU call Val_Lot');
   MDEBUG( 'Process: In Validate_ItemSKU call Val_Lot');
END IF;
          /* Validate  API Implementation for lot validation */
          --
          l_org.organization_id := p_organization_id;
          l_sub.secondary_inventory_name := p_subinventory;
          l_item.inventory_item_id := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
          l_loc.inventory_location_id := MTL_CCEOI_VAR_PVT.G_LOCATOR_ID;
          l_lot.lot_number := p_sku_rec.lot_number ;
          --
          IF p_sku_rec.lot_number is null then
             x_errorcode := 13 ;
          /* Bug 4735473-Calling the Lot_Number api passing only lot, org and item to
                           make the behaviour in sync with that on the desktop.
          ELSIF INV_Validate.Lot_Number(L_lot,
                                        L_org,
                                        L_item,
                                        L_sub,
                                        L_loc,
                                        p_sku_rec.revision
                                        ) = INV_Validate.T then */

             ELSIF INV_Validate.Lot_Number(L_lot,
                                           L_org,
                                           L_item
                                         ) = INV_Validate.T THEN
            /* End of fix for Bug 4735473 */

             MTL_CCEOI_VAR_PVT.G_SKU_REC.Lot_Number := l_lot.lot_number;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.expiration_date := l_lot.expiration_date;

             x_errorcode := 0;
          ELSE
             x_errorcode := 14;
          END IF;
          -- Validate Lot
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call Val_Lot Stat'||x_return_status||' - '||to_char(x_errorcode));
   mdebug('Process: In Validate_ItemSKU call Val_Lot Return='||x_return_status);
END IF;
          --
          IF x_errorcode >0 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call Val_Lot Error > 0');
END IF;
             L_table_name := 'MTL_LOT_NUMBERS';
             L_column_name := 'LOT_NUMBER';
             IF x_errorcode = 13 THEN
                L_message_name := 'INV_CCEOI_NO_LOT';
             ELSIF
	       x_errorcode = 14 THEN
                L_message_name := 'INV_CCEOI_INVALID_LOT'; --changes 3904722
             END IF;
             -- Write INTO interface error TABLE
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call Val_Lot Msg '||L_message_name);
END IF;
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => L_column_name
                , p_error_table_name => L_table_name
                , p_message_name => L_message_name
						    );
	     RAISE FND_API.G_EXC_ERROR;
          ELSIF
             x_errorcode < 0 THEN
             --
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call Val_Lot Error < 0');
END IF;
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'unexpected error'
                , p_error_table_name => 'unexpected error'
                , p_message_name => 'unexpected error'
             );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
       --
       -- IS the item under serial control
IF (l_debug = 1) THEN
   MDEBUG( 'Before call Validate_Serial-1');
END IF;
       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE IN (2,5) THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Before call Validate_Serial-2');
END IF;
--Begin changes 3904722
         SELECT COUNT_QUANTITY INTO l_serial_quantity
	   FROM MTL_CC_ENTRIES_INTERFACE
          WHERE CC_ENTRY_INTERFACE_ID = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID;
--End changes 3904722
          -- Validate Serial
         /* Validate  API Implementation for Serial validation */
          l_org.organization_id := p_organization_id;
          l_sub.secondary_inventory_name := p_subinventory;
          l_serial.serial_number := p_sku_rec.serial_number ;
          l_item.inventory_item_id := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
          l_loc.inventory_location_id := MTL_CCEOI_VAR_PVT.G_LOCATOR_ID;
          l_lot.lot_number := p_sku_rec.lot_number ;
          l_item.SERIAL_NUMBER_CONTROL_CODE :=  MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE; --9113242
          --
          IF (MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.SERIAL_COUNT_OPTION = 3) THEN
              x_errorcode := 102;
          ELSIF (MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.SERIAL_COUNT_OPTION = 1) THEN
              x_errorcode := 103;
          ELSIF p_sku_rec.serial_number is null then
             x_errorcode := 15 ;
          ELSIF INV_Validate.validate_serial(l_serial,
                                             L_org,
                                             L_item,
                                             L_sub,
                                             L_lot,
                                             L_loc,
                                             p_sku_rec.revision
                                             ) = INV_Validate.T then
             -- needs to be checked whether we should store or not
             MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER := l_serial.serial_number;
             x_errorcode := 0;
--Begin changes 3904722
          ELSIF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE = 5 AND
	        MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER IS NULL AND
	        l_serial_quantity = 1 THEN
                l_ret_value := inv_serial_number_pub.validate_serials(
                         p_org_id                     => p_organization_id
                       , p_item_id                    => p_inventory_item_rec.inventory_item_id
                       , p_qty                        => l_serial_quantity
                       , p_rev                        => p_sku_rec.revision
                       , p_lot                        => p_sku_rec.lot_number
                       , p_start_ser                  => p_sku_rec.serial_number
                       , p_trx_src_id                 => 9
                       , p_trx_action_id              => 4
                       , p_subinventory_code          => p_subinventory
                       , p_locator_id                 => MTL_CCEOI_VAR_PVT.G_LOCATOR_ID
                       , p_issue_receipt              => 'R'
                       , x_end_ser                    => l_to_serial
                       , x_proc_msg                   => l_msg_data);
                IF l_ret_value = 1 THEN
                       x_errorcode := 16;
                ELSE
		   MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER := l_to_serial;
		   x_errorcode := 0;
                END IF;
          ELSIF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE in (2,5) THEN
             x_errorcode := 16;
          END IF;
--End changes 3904722
IF (l_debug = 1) THEN
   MDEBUG( 'After Serial Validation Cd-Stat '||to_char(x_errorcode)||x_return_status);
END IF;
          --
          IF x_errorcode >0 THEN
             L_table_name := 'MTL_SERIAL_NUMBERS';
             L_column_name := 'SERIAL_NUMBER';
             IF x_errorcode = 15 THEN
                L_message_name := 'INV_CCEOI_NO_SERIAL';
             ELSIF x_errorcode = 16 THEN
		L_message_name := 'INV_CCEOI_INVALID_SERIAL';
	     ELSIF x_errorcode = 102 THEN
		L_message_name := 'INV_CCEOI_MULT_COUNT_SERIAL';
	     ELSIF x_errorcode = 103 THEN
	        L_message_name := 'INV_CCEOI_SERIAL_NOT_ALLOWED';
	     END IF;
             --
             FND_MESSAGE.SET_NAME('INV',L_message_name);
             FND_MSG_PUB.Add;
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => L_column_name
                , p_error_table_name => L_table_name
                , p_message_name => L_message_name
						    );
		RAISE FND_API.G_EXC_ERROR;
          ELSIF
             x_errorcode < 0 THEN
             --
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'unexpected error'
                , p_error_table_name => 'unexpected error'
                , p_message_name => 'unexpected error'
             );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'After call Validate_Serial Error Routine');
END IF;
       END IF;

       -- deduce whether this is a new unscheduled count request or not
       -- by knowing the fact that validate_countlistseq would find this
       -- record already
       l_is_Unscheduled_Request := FALSE;
       if MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID is null then
	  l_is_Unscheduled_Request := TRUE;
       end if;
       --

 -- Bug : 8300310 Start
        SELECT COUNT(1)
          INTO l_count
          FROM MTL_CYCLE_COUNT_ENTRIES
         WHERE organization_id = p_organization_id
           AND subinventory = p_subinventory
           AND locator_id = MTL_CCEOI_VAR_PVT.G_LOCATOR_ID
           AND inventory_item_id = p_inventory_item_rec.inventory_item_id
           AND NVL(parent_lpn_id,-1) = NVL(MTL_CCEOI_VAR_PVT.G_LPN_ID,-1)
           AND NVL(lot_number, '@') = NVL(p_sku_rec.lot_number, '@')
           AND NVL(revision, '@') = NVL(p_sku_rec.revision, '@')
           AND NVL(serial_number, '@') = NVL(p_sku_rec.serial_number, '@')
           AND entry_status_code IN (1, 3)
           AND cycle_count_header_id = MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID;

            IF (l_debug = 1) THEN
               MDEBUG('l_count : '|| l_count);
            END IF;

           IF l_count = 1 THEN
              l_is_Unscheduled_Request := FALSE;
              mdebug('row exists in mcce, l_in_cc_entries returns true');
           END IF;

        -- Bug : 8300310 End
       --

       -- IS there an OPEN request

IF (l_debug = 1) THEN
   MDEBUG( 'item : '||to_char(MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID));
   MDEBUG( 'lpnid: '||to_char(MTL_CCEOI_VAR_PVT.G_LPN_ID));
   MDEBUG( 'Subinv : '||p_subinventory);
   MDEBUG( 'Org :'||to_char(p_organization_id));
   MDEBUG( 'Header :'||to_char(p_cycle_count_header_id));
   MDEBUG( 'Locator :'||to_char(MTL_CCEOI_VAR_PVT.G_LOCATOR_ID));
   MDEBUG( 'Rev :'||p_sku_rec.revision);
   MDEBUG( 'Serial :'||p_sku_rec.serial_number);
   MDEBUG( 'Lot :'||p_sku_rec.lot_number);
   MDEBUG( 'costid: '||to_char(MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID));
END IF;
       L_P_locator_id := MTL_CCEOI_VAR_PVT.G_LOCATOR_ID;
       L_P_inventory_item_id := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
       MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST := FALSE;
       FOR c_rec IN L_CCEntry_Csr(
             L_P_inventory_item_id, MTL_CCEOI_VAR_PVT.G_LPN_ID,
             p_subinventory, p_organization_id, p_cycle_count_header_id,
             L_P_locator_id, p_sku_rec.revision,
             p_sku_rec.serial_number, p_sku_rec.lot_number, MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID) LOOP
          --
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call-1 Open Request');
END IF;
          MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC := c_rec;
          MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST := TRUE;
          L_counter := L_counter + 1;
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call-2 Open Request');
   mdebug('Process: In Validate_ItemSKU call Open Request');
END IF;
          --
       END LOOP;
        IF (l_debug = 1) THEN
           mdebug(' l_counter: ' || to_char(l_counter));
   MDEBUG( 'Process: In Validate_ItemSKU call-3 ');
        END IF;
       --
       IF L_counter < 1 AND MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.UNSCHEDULED_COUNT_ENTRY=2 THEN
IF (l_debug = 1) THEN
   MDEBUG('Process: In Validate_ItemSKU Unsched not Allowed');
END IF;
          x_errorcode := 48;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_CCENTRY');
          FND_MSG_PUB.Add;
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => '*'
             , p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES'
             , p_message_name => 'INV_CCEOI_NO_CCENTRY'
          );
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
	 L_counter > 1 OR (L_counter = 1 AND l_is_Unscheduled_Request) THEN
	  -- XXX it is impossible to have multiple open
	  -- requests existing for the same item/location
	  -- it feels that we should have checked presense of request
	  -- with a different count list sequence in case of 1 count (err=27)
          x_errorcode := 49;

IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call-4 ');
END IF;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_MULT_REQUESTS');
          FND_MSG_PUB.Add;
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => '*'
             , p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES'
             , p_message_name => 'INV_CCEOI_MULT_REQUESTS'
          );
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call-5 ');
END IF;
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call-6 ');
END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
IF (l_debug = 1) THEN
   MDEBUG( 'Process: In Validate_ItemSKU call-7 ');
END IF;
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'ItemSKU-Error');
END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF (l_debug = 1) THEN
   MDEBUG( 'ItemSKU-Unexp Error');
END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF (l_debug = 1) THEN
   MDEBUG( 'ItemSKU-Others Error');
END IF;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate the UOM and quantity information
  PROCEDURE Validate_UOMQuantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_primary_uom_quantity IN NUMBER DEFAULT NULL,
  p_count_uom IN VARCHAR2 DEFAULT NULL,
  p_count_unit_of_measure IN VARCHAR2 DEFAULT NULL,
  p_organization_id IN NUMBER ,
  p_lpn_id IN NUMBER DEFAULT NULL,
  p_inventory_item_id IN NUMBER ,
  p_count_quantity IN NUMBER ,
  p_serial_number IN VARCHAR2 DEFAULT NULL,
  p_subinventory IN VARCHAR2 ,
  p_revision IN VARCHAR2 DEFAULT NULL,
  p_lot_number IN VARCHAR2 ,
  p_system_quantity IN NUMBER,
  p_secondary_system_quantity IN NUMBER -- INVCONV
  )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_UOMQuantity
    -- TYPE      : Private
    -- Pre-reqs  : G_PRIMARY_UOM_CODE, G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_primary_uom_quantity IN NUMBER (required - default)
    --  default NULL
    --  Quantity within the primary unit OF measure OF the item
    --
    --  p_count_uom IN VARCHAR2 (required - default)
    --  default = NULL
    --  Unit OF measure OF the current cycle COUNT entry
    --
    --  p_count_unit_of_measure IN VARCHAR2 (optional - defaulted)
    --  default = NULL
    --  unit OF measure name OF the current COUNT
    --
    --  p_organization_id IN NUMBER (required)
    -- ID OF the organization
    --
    --  p_inventory_item_id IN NUMBER (required)
    --  ID OF the current inventory item
    --
    --  p_count_quantity IN NUMBER (required)
    --  COUNT quantity
    --
    --  p_serial_number IN NUMBER (required - defaulted)
    --  default = NULL
    --  Serial NUMBER, IF the item IS under serial control
    --
    -- p_subinventory in number (required)
    -- subinventory of the item
    --
    -- p_revision in varchar2 (required- defaulted)
    -- default = null
    --  revision of the item
    --
    -- p_lot_number in varchar2 (required- defaulted)
    -- default = null
    --  lot number
    --
    -- p_system_quantity in number (required- defaulted)
    -- default = null
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
  -- Notes  :
  -- this function validates presense of count quantity and uom info
  -- it also computes adjustment quantity, adjustment amount, item cost,
  -- and adjustment variance percentage
  -- Sets: G_UOM_CODE (count unit of measure), G_COUNT_QUANTITY (in count UOM)
  -- G_ADJUSTMENT_QUANTITY, G_ADJUSTMENT_AMOUNT, G_ITEM_COST,
  -- G_ADJ_VARIANCE_PERCENTAGE, G_SYSTEM_QUANTITY
    -- END OF comments
    DECLARE
       L_table_name VARCHAR2(100);
       L_column_name VARCHAR2(100);
       L_message_name VARCHAR2(30);
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_UOMQuantity';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_UOMQuantity;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
       IF (l_debug = 1) THEN
          MDEBUG( 'Validate_UOMQuantity call. count_type_code ='||nvl(to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE), 'NULL'));
       END IF;
       --
       -- comment released by suresh for testing

       -- count type code 4 means dummy count - ignore it
       IF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE = 4 THEN
	  -- todo: reset count and uom globals to null ? (put 0's ?)
	  MTL_CCEOI_VAR_PVT.G_UOM_CODE := NULL;
	  MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY := NULL;
	  MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY := NULL;
	  MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY := NULL;
	  MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_AMOUNT := NULL;
	  MTL_CCEOI_VAR_PVT.G_ADJ_VARIANCE_PERCENTAGE := NULL;
	  MTL_CCEOI_VAR_PVT.G_ITEM_COST := NULL;

       -- if scheduled(1), unscheduled(2), control(3) count derive UOM/Qty
       ELSIF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE
	 IN (1, 2, 3)
	 OR
	 MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE IS NULL
       THEN

	  IF (l_debug = 1) THEN
   	  mdebug('Process: In Validate_UOMQuantity call Validate_PrimaryUOMQty');
	  END IF;
	  MTL_INV_VALIDATE_GRP.Validate_PrimaryUomQuantity
	    (p_api_version => 0.9,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    x_errorcode => x_errorcode,
	    p_primary_uom_quantity => p_primary_uom_quantity,
	    p_primary_uom_code => MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE);

	  IF (l_debug = 1) THEN
   	  mdebug('Process: In Validate_UOMQuantity call Validate_PrimaryUOMQty Return='||x_return_status);
   	  mdebug('Errorcode :'||to_char(x_errorcode));
	  END IF;

	  IF x_errorcode < 0 THEN

	     MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
	       p_cc_entry_interface_id =>
	         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
	       , p_error_column_name => 'unexpected error'
	       , p_error_table_name => 'unexpected error'
	       , p_message_name => 'unexpected error');
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	  ELSIF x_errorcode = 22 THEN
	     MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
	       p_cc_entry_interface_id =>
	         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
	       , p_error_column_name => 'COUNT_QUANTITY'
	       , p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES'
	       , p_message_name => 'INV_CCEOI_NEG_QTY');
	     RAISE FND_API.G_EXC_ERROR;

	  ELSIF  x_errorcode = 60 THEN
	     MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
	       p_cc_entry_interface_id =>
	         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
	       , p_error_column_name => 'COUNT_QUANTITY'
	       , p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES'
	       , p_message_name =>  'INV_SERIAL_QTY_MUST_BE_1');
	     RAISE FND_API.G_EXC_ERROR;

	  ELSIF  x_errorcode = 61 THEN
	     MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
	       p_cc_entry_interface_id =>
	         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
	       , p_error_column_name => 'COUNT_QUANTITY'
	       , p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES'
	       , p_message_name =>  'INV_GREATER_EQUAL_ZERO');
	     RAISE FND_API.G_EXC_ERROR;

	     --
       -- primary uom quantity IS NOT populated, THEN validate COUNT uom
	  ELSIF x_errorcode = 19 THEN
	     IF (l_debug = 1) THEN
   	     mdebug('Process: In Validate_UOMQuantity call Validate_CountUOM: ' || p_count_uom);
	     END IF;

	     MTL_INV_VALIDATE_GRP.Validate_CountUOM(p_api_version => 0.9
	       , x_msg_count => x_msg_count
	       , x_msg_data => x_msg_data
	       , x_return_status => x_return_status
	       , x_errorcode => x_errorcode
	       , p_count_uom => p_count_uom
	       , p_count_unit_of_measure => p_count_unit_of_measure
	       , p_organization_id => p_organization_id
	       , p_inventory_item_id => p_inventory_item_id );

	     IF (l_debug = 1) THEN
   	     MDEBUG( 'After Validate CntUOM Stat '||to_char(x_errorcode)||' - '||x_return_status);
	     END IF;

             IF x_errorcode = 19 THEN

                -- Write INTO interface error TABLE
                MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                   p_cc_entry_interface_id =>
                   MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                   , p_error_column_name =>
                   'UOM_CODE/UNIT_OF_MEASURE'
                   , p_error_table_name => 'MTL_ITEM_UOMS_VIEW'
                   , p_message_name => 'INV_CCEOI_NO_UOM'
                );
		RAISE FND_API.G_EXC_ERROR;

	     ELSIF x_errorcode = 20 THEN
                MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                   p_cc_entry_interface_id =>
                   MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                   , p_error_column_name =>
                   'UOM_CODE/UNIT_OF_MEASURE'
                   , p_error_table_name => 'MTL_ITEM_UOMS_VIEW'
                   , p_message_name => 'INV_CCEOI_INVALID_UOM'
                );
		RAISE FND_API.G_EXC_ERROR;

	     ELSIF x_errorcode < 0 THEN

		MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
		  p_cc_entry_interface_id =>
  		    MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
		  , p_error_column_name => 'unexpected error'
		  , p_error_table_name => 'unexpected error'
		  , p_message_name => 'unexpected error');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	     END IF;

	     --mdebug('Process: In Validate_UOMQuantity call Validate_CountQty ');
	     MTL_INV_VALIDATE_GRP.Validate_CountQuantity(p_api_version => 0.9
	       , x_return_status => x_return_status
	       , x_msg_count => x_msg_count
	       , x_msg_data => x_msg_data
	       , x_errorcode => x_errorcode
	       , p_count_quantity => p_count_quantity
							);
	     --MDEBUG( 'ValidateCQty :Stat= '||x_errorcode);
	     --MDEBUG( 'ValidateCQty :Ctype= '||to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE));

	     --mdebug('Process: In Validate_UOMQuantity call Validate_CountQty Return='||x_return_status);


             IF x_errorcode = 22 THEN

		MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
		  p_cc_entry_interface_id =>
                    MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
		  , p_error_column_name => 'COUNT_QUANTITY'
		  , p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES'
		  , p_message_name => 'INV_CCEOI_NEG_QTY');

                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_errorcode = 60 THEN

                MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                   p_cc_entry_interface_id =>
                     MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                   , p_error_column_name => 'COUNT_QUANTITY'
                   , p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE'
                   , p_message_name => 'INV_SERIAL_QTY_MUST_BE_1');

                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_errorcode = 61 THEN

                MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
		  p_cc_entry_interface_id =>
                    MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
		  , p_error_column_name => 'COUNT_QUANTITY'
		  , p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE'
		  , p_message_name => 'INV_GREATER_EQUAL_ZERO');

                RAISE FND_API.G_EXC_ERROR;

	     ELSIF x_errorcode < 0 THEN
                -- Write INTO interface error TABLE
		MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
		  p_cc_entry_interface_id =>
		    MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
		  , p_error_column_name => 'unexpected error'
		  , p_error_table_name => 'unexpected error'
		  , p_message_name => 'unexpected error');

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;

	  END IF;


	  IF (l_debug = 1) THEN
   	  mdebug('Process: In Validate_UOMQuantity call Validate_Calculate_Adj');
	  END IF;
          MTL_CCEOI_PROCESS_PVT.Calculate_Adjustment
          (p_api_version => 0.9
             , x_return_status => x_return_status
             , x_msg_count => x_msg_count
             , x_msg_data => x_msg_data
             , x_errorcode => x_errorcode
             , p_inventory_item_id => p_inventory_item_id
             , p_organization_id => p_organization_id
             , p_lpn_id => p_lpn_id
             , p_subinventory => p_subinventory
             , p_revision => p_revision
             , p_locator_id => MTL_CCEOI_VAR_PVT.G_LOCATOR_ID
             , p_lot_number => p_lot_number
             , p_serial_number => p_serial_number
             , p_count_quantity => MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY
             , p_serial_number_control_code =>
             MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE
            , p_serial_count_option =>
           MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.SERIAL_COUNT_OPTION
            , p_system_quantity => p_system_quantity
	    , p_secondary_system_quantity => p_secondary_system_quantity -- INVCONV
          );
          IF (l_debug = 1) THEN
             mdebug('Process: In Validate_UOMQuantity call Validate_Calculate_Adj Return='||x_return_status);
          END IF;
          --
          IF x_errorcode = 17 THEN   -- XXX this code is disabled in CalcAdj()
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'TRANSACTION_QUANTITY'
                , p_error_table_name => 'MTL_ONHAND_QUANTITIES'
                , p_message_name => 'INV_CCEOI_ADJCALC_NO_SERIAL'
             );
             --
             RAISE FND_API.G_EXC_ERROR;
          ELSIF
             x_errorcode < 0 THEN
             -- Write INTO interface error TABLE
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'unexpected error'
                , p_error_table_name => 'unexpected error'
                , p_message_name => 'unexpected error'
             );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

       ELSE -- XXX this is just a precaution (should never happen)
	  IF (l_debug = 1) THEN
   	  MDEBUG('Invalid count_type_code');
	  END IF;
             MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
                p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
                , p_error_column_name => 'unexpected error'
                , p_error_table_name => 'unexpected error'
                , p_message_name => 'unexpected error'
             );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate count date and counter
  PROCEDURE Validate_CDate_Counter(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_employee_id IN NUMBER ,
  p_employee_name IN VARCHAR2 DEFAULT NULL,
  p_count_date IN DATE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CDate_Counter
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_employee_id IN NUMBER (required)
    --  EmployeeID OF the counter
    --
    --  p_employee_name IN VARCHAR2 (optional - defaulted)
    --  default = NULL
    --  Name OF the counter
    --
    --  p_count_date IN DATE (required)
    --  DATE OF the COUNT
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_message_name VARCHAR2(100);
       --
       L_org INV_Validate.ORG;
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CDate_Counter';
       L_emp_id NUMBER := p_employee_id;
       L_emp_name VARCHAR2(60) := p_employee_name;
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CDate_Counter;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_CDate_Counter call Validate Countdate');
END IF;
       MTL_INV_VALIDATE_GRP.Validate_CountDate
       -- Prozedur
       (p_api_version => 0.9
          , x_return_status => x_return_status
          , x_msg_count => x_msg_count
          , x_msg_data => x_msg_data
          , x_errorcode => x_errorcode
          , p_count_date => p_count_date
       );
IF (l_debug = 1) THEN
   MDEBUG( 'ValidateDate Stat '||to_char(x_errorcode)||'-'||x_return_status);
   mdebug('Process: In Validate_CDate_Counter call Validate Countdate Return='||x_return_status);
END IF;
       --
       IF x_errorcode = 23 THEN
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'COUNT_DATE'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_COUNT_DATE_FUTURE'
          );
          --
          RAISE FND_API.G_EXC_ERROR;
          --
       ELSIF x_errorcode = 59 THEN   -- New errorcode ( existing one )
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'COUNT_DATE'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_COUNT_DATE_FUTURE'
          );
          --
	  RAISE FND_API.G_EXC_ERROR;
       ELSIF x_errorcode = 24 THEN
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'COUNT_DATE'
             , p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS'
             , p_message_name => 'INV_CCEOI_NO_OPEN_ADJ_PRD'
          );
          --
	  RAISE FND_API.G_EXC_ERROR;

       ELSIF
          x_errorcode < 0 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'unexpected error'
             , p_error_table_name => 'unexpected error'
             , p_message_name => 'unexpected error'
          );
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_CDate_Counter call Validate_Employee');
END IF;
/* Validate  API Implementation for Empoloyee validation */
          l_org.organization_id := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id;
          --
          IF l_emp_id is null and l_emp_name is null then
             IF (l_debug = 1) THEN
                mdebug('all null');
             END IF;
             x_errorcode := 25 ;
          ELSIF INV_Validate.Employee(l_emp_id,
                                      l_emp_name,
                                      l_emp_name,
                                      l_org
                                      ) = INV_Validate.T then
             MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID := l_emp_id;
             x_errorcode := 0;
          ELSE
             x_errorcode := 26;
          END IF;
IF (l_debug = 1) THEN
   mdebug('Process: In Validate_CDate_Counter call Validate_Employee Return='||x_return_status);
   mdebug('Process: In Validate_CDate_Counter call Validate_Employee Code='||x_errorcode);
END IF;
       --
       IF x_errorcode > 0 THEN
          IF x_errorcode = 25 THEN
             L_message_name := 'INV_CCEOI_NO_COUNTER';
          ELSIF
             x_errorcode = 26 THEN
	     L_message_name := 'INV_CCEOI_INVALID_COUNTER';
	  ELSIF x_errorcode = 101 THEN
	     L_message_name := 'INV_CCEOI_NOT_UNIQUE_COUNTER';
          END IF;
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'EMPLOYEE_ID/NAME'
             , p_error_table_name => 'MTL_EMPLOYEES_CURRENT_VIEW'
             , p_message_name => L_message_name
          );
          --
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          x_errorcode < 0 THEN
          -- Write INTO interface error TABLE
          MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID
             , p_error_column_name => 'unexpected error'
             , p_error_table_name => 'unexpected error'
             , p_message_name => 'unexpected error'
          );
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- .
  --
  -- Updates the application tables
  PROCEDURE Update_CCEntry(
  p_cycle_count_entry_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Update_CCEntry
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- UPDATES THE CYCLE COUNT ENTRIES TABLE
    -- ITH VALUES FROM THE GLOBAL VARIABLES
    -- Parameters:
    --     IN    :
    -- p_cycle_count_entry_idc    IN  NUMBER (required)
    -- END OF comments
    DECLARE
      l_count_due_date DATE;
    BEGIN
IF (l_debug = 1) THEN
   MDEBUG( 'Updating CC Entry Id '||to_char(p_cycle_count_entry_id));
   MDEBUG( 'Updating CC Entry Stat Cd'||to_char(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE));
   MDEBUG( 'Updating CC Entry emp id'||to_char(MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID));
   MDEBUG( 'Updating CC Entry CntDt'||to_char(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_CURRENT));
   MDEBUG( 'Updating CC Entry CntQty'||to_char(MTL_CCEOI_VAR_PVT.G_COUNT_Quantity));
   MDEBUG( 'Updating CC Entry CntQtyPrior'||to_char(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_PRIOR));
END IF;

l_count_due_date :=
  nvl(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DUE_DATE,
  nvl(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_DUE_DATE,
  compute_count_due_date(sysdate)));

       UPDATE MTL_CYCLE_COUNT_ENTRIES
       SET
	 last_update_date =
	 sysdate
	 , last_updated_by =
	 MTL_CCEOI_VAR_PVT.G_UserID
	 , last_update_login =
	 MTL_CCEOI_VAR_PVT.G_LoginID
	 , count_date_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_FIRST
	 ,count_date_prior =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_PRIOR
          , count_date_current =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_DATE_CURRENT
	 , counted_by_employee_id_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_FIRST
          , counted_by_employee_id_current=
	 MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID
	 , counted_by_employee_id_prior =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_PRIOR
	  , counted_by_employee_id_dummy=
	 MTL_CCEOI_VAR_PVT.G_EMPLOYEE_ID
	  , count_uom_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_FIRST
	 , count_uom_current=
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_CURRENT
	 , count_uom_prior=
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_UOM_PRIOR
	 , count_quantity_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_FIRST
	 , count_quantity_current=
	 MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY
	 , count_quantity_prior=
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_QUANTITY_PRIOR
	 , entry_status_code =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE
	 , count_due_date =
	    l_count_due_date
	 , number_of_counts=
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NUMBER_OF_COUNTS
	 , locator_id =
	 MTL_CCEOI_VAR_PVT.G_LOCATOR_ID
	 , adjustment_quantity =
	 --MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ADJUSTMENT_QUANTITY
	 MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_QUANTITY
	 , adjustment_date =
	 MTL_CCEOI_VAR_PVT.G_COUNT_DATE
	 , adjustment_amount =
	 MTL_CCEOI_VAR_PVT.G_ADJUSTMENT_AMOUNT
          , inventory_adjustment_account=
            decode(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE, 5, MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID, NULL)
          , approval_date =
           MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_DATE
          , approver_employee_id = null
--	 decode( MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_DATE, null,
--	 null,
--	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNTED_BY_EMPLOYEE_ID_CURRENT)
          , revision=
          MTL_CCEOI_VAR_PVT.G_SKU_REC.revision
          , lot_number=
          MTL_CCEOI_VAR_PVT.G_SKU_REC.lot_number
          , lot_control =
	 decode(MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE, 1, null,
	 MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE)
	 , system_quantity_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_FIRST
          , system_quantity_current=
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_CURRENT,
          system_quantity_prior=
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SYSTEM_QUANTITY_PRIOR
	 , reference_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_FIRST
          , reference_current=
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_CURRENT
          , reference_prior=
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.REFERENCE_PRIOR
	 , primary_uom_quantity_first =
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_FIRST
          , primary_uom_quantity_prior=
         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_PRIOR
          , primary_uom_quantity_current=
         MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.PRIMARY_UOM_QUANTITY_CURRENT
          , count_type_code =
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_TYPE_CODE
          , transaction_reason_id=
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.TRANSACTION_REASON_ID
          , request_id =
          MTL_CCEOI_VAR_PVT.G_RequestID
          , program_application_id=
          MTL_CCEOI_VAR_PVT.G_ProgramAppID
          , program_id =
          MTL_CCEOI_VAR_PVT.G_ProgramID
          , program_update_date =
          sysdate
          , approval_type =
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_TYPE
          , serial_number =
          MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER
          , serial_detail =
	 decode(MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER, NULL,
	 0,  -- put 0 instead of NULL to be comliant with existing form
	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SERIAL_DETAIL)
          , approval_condition =
	 nvl(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION,0)
	 -- added nvl(x,0) to have the same output as forms
          , neg_adjustment_quantity=
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NEG_ADJUSTMENT_QUANTITY
          , neg_adjustment_amount =
          MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.NEG_ADJUSTMENT_AMOUNT
          , ITEM_UNIT_COST =
          MTL_CCEOI_VAR_PVT.G_ITEM_COST
	  -- BEGIN INVCONV
	  , Count_Secondary_Uom_First      = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Count_Secondary_Uom_First
	  , Count_Secondary_Uom_Current    = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Count_Secondary_Uom_Current
	  , Count_Secondary_Uom_Prior      = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Count_Secondary_Uom_Prior
	  , Secondary_Uom_Quantity_First   = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Secondary_Uom_Quantity_First
	  , Secondary_Uom_Quantity_Current = MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_QUANTITY
	  , Secondary_Uom_Quantity_Prior   = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Secondary_Uom_Quantity_Prior
	  , Secondary_System_Qty_First     = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Secondary_System_Qty_First
	  , Secondary_System_Qty_Current   = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Secondary_System_Qty_Current
	  , Secondary_System_Qty_Prior     = MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.Secondary_System_Qty_Prior
	  , Secondary_Adjustment_Quantity  = MTL_CCEOI_VAR_PVT.G_SEC_ADJUSTMENT_QUANTITY
	  -- END INVCONV
       WHERE
          cycle_count_entry_id = P_cycle_count_entry_id;
IF (l_debug = 1) THEN
   MDEBUG( 'End of Update CC entry');
END IF;
    END;
  END;

  -- Processed the interface record
  -- This function will prepare record for being updated into
  -- mtl_cycle_count_entries and will also perform a transaction
  -- if necessary
  -- The logic which handles serial numbers is copied from INVATCEN.pld
  -- and will need further review/rewrite
  PROCEDURE Process_Data(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Process_Data
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- process data porcessed the interface RECORD according to the
    -- cycle COUNT entries form. this PROCEDURE can only be called
    -- BY the PROCEDURE MTL_CCEOI_PROCESS_PVT.Process_Data
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --
    --     DEFAULT = FND_API.G_FALSE
    -- p_validation_level IN NUMBER (optional)
    --     DEFAULT = FND_API.G_VALID_LEVEL_FULL
    --  currently unused
    --
    --  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE
    --  G_TRUE - skip any updates/inserts to any non-cc-interface tables
    --  G_FALSE - update any tables necessary
    --
    --  p_interface_rec MTL_CC_ENTRIES_INTERFACE%rowtype (required)
    --  interface RECORD parameter
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --

       L_success NUMBER := 1;
       --
       --
        CURSOR L_TolItemClass_Csr(cheader IN NUMBER,
                                  item in number) IS
           select
            i.APPROVAL_TOLERANCE_POSITIVE ITEM_TOL_POS
           ,i.APPROVAL_TOLERANCE_NEGATIVE ITEM_TOL_NEG
           ,c.APPROVAL_TOLERANCE_POSITIVE CLASS_TOL_POS
           ,c.APPROVAL_TOLERANCE_NEGATIVE CLASS_TOL_NEG
           ,c.COST_TOLERANCE_POSITIVE CLASS_COST_POS
           ,c.COST_TOLERANCE_NEGATIVE CLASS_COST_NEG
           FROM MTL_CYCLE_COUNT_ITEMS i
              , MTL_CYCLE_COUNT_CLASSES c
           WHERE i.cycle_count_Header_id = cheader
           AND i.inventory_item_id = item
           AND c.abc_class_id = i.abc_class_id
           AND c.cycle_count_header_id = i.cycle_count_Header_id;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Process_Data';
    BEGIN

       IF (l_debug = 1) THEN
          MDEBUG( 'Begin process:Count Qty '|| to_char(p_interface_rec.count_quantity));
       END IF;

       IF (l_debug = 1) THEN
          MDEBUG( 'Process Data: Begin ');
   MDEBUG( 'Item-CC header -> '||to_char(MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID)|| ' - '||to_char(MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID));
       END IF;

       -- Standard start of API savepoint
       SAVEPOINT Process_Data;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
IF (l_debug = 1) THEN
   MDEBUG('Process: In Process_Data');
END IF;

       --
       -- zero cycle COUNT
       -- SET the current RECORD AND the first to current
       -- AND THEN SET the entr_status_code to =5 (completed)
       IF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE = 4 THEN
          --
IF (l_debug = 1) THEN
   MDEBUG( 'Process Data:  call Zero count');
END IF;
          Zero_Count_Logic(
             p_reference => p_interface_rec.reference
             , p_primary_uom_quantity => p_interface_rec.primary_uom_quantity
          );


       ELSE
	  -- non zero-count logic

	  -- propagate count type code
	  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.COUNT_TYPE_CODE :=
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE;

          -- without serial control
          IF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE
             IN(1, 6) THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Process Data: without serial');
   MDEBUG( to_char(MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID)||' - '||to_char(MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID));
END IF;
             --

                For c_rec in L_TolItemClass_Csr (
                    MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID,
                    MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID)
                LOOP

                   --
IF (l_debug = 1) THEN
   MDEBUG( 'Process Data: W/o Sl# Calculate_tol ');
END IF;

                   Calculate_Tolerance(
                    p_item_app_tol_pos => c_rec.ITEM_TOL_POS
                   , p_item_app_tol_neg => c_rec.ITEM_TOL_NEG
                   , p_class_app_tol_pos => c_rec.CLASS_TOL_POS
                   , p_class_app_tol_neg => c_rec.CLASS_TOL_NEG
                   , p_class_cost_tol_pos => c_rec.CLASS_COST_POS
                   , p_class_cost_tol_neg => c_rec.CLASS_COST_NEG
                   , p_head_app_tol_pos =>
                   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.APPROVAL_TOLERANCE_POSITIVE
                   , p_head_app_tol_neg =>
                   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.APPROVAL_TOLERANCE_NEGATIVE
                   , p_head_cost_tol_pos =>
                   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.COST_TOLERANCE_POSITIVE
                   , p_head_cost_tol_neg =>
                   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.COST_TOLERANCE_NEGATIVE
                   , p_interface_rec => p_interface_rec
                   , p_simulate =>  p_simulate
                   );
               END LOOP;
             --
             -- with serial control
	  ELSIF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE IN(2, 5)
	  THEN
	     IF (l_debug = 1) THEN
   	     MDEBUG( 'Process Data: with serial'||mtl_cceoi_var_pvt.g_sku_rec.serial_number);
	     END IF;

             --
             -- One ROW per request

             IF(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.serial_count_option = 2)
             THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Process Data: with serial one per request');
END IF;

                --
                MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SERIAL_DETAIL:= 2;
                --

		IF MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY <> MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY THEN
		   IF (l_debug = 1) THEN
   		   MDEBUG( 'Process Data: Not equal sys and count qties');
   		   MDEBUG( 'Process Data: level '||to_char(p_validation_level));
		   END IF;
      --
		   IF NOT FND_API.to_Boolean(p_simulate) THEN
		      --
		      IF (l_debug = 1) THEN
   		      MDEBUG( 'Process Data:  mark RECORD as locked ');
   		      MDEBUG( 'Process Data: Sl# '||p_interface_rec.serial_number);
   		      MDEBUG( 'Process Data: Item# '||to_char(MTL_CCEOI_VAR_PVT.G_inventory_item_id));
   		      MDEBUG( 'Process Data: Org '|| to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID));
   		      MDEBUG( 'Process Data: CCHid '|| to_char(MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID));
   		      MDEBUG( 'Process Data: CCEid '|| to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID));
		      END IF;

		      -- mark RECORD as locked
		      serial_check.inv_mark_serial(
			from_serial_number => p_interface_rec.serial_number
			, to_serial_number => p_interface_rec.serial_number
			, item_id => MTL_CCEOI_VAR_PVT.G_inventory_item_id
			, org_id =>  MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID
			, hdr_id => MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID
			, temp_id => MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID
			, lot_temp_id => NULL
			, success => L_success);
		      --
		      IF(L_success < 0) THEN
                      --
			 IF (l_debug = 1) THEN
   			 MDEBUG( 'Process Data: INV_SERIAL_UNAVAILABLE ');
			 END IF;
			 FND_MESSAGE.SET_NAME('INV', 'INV_SERIAL_UNAVAILABLE');
			 FND_MESSAGE.SET_TOKEN('FIRST-SERIAL',
			   p_interface_rec.serial_number);
			 FND_MSG_PUB.Add;
			 --x_errorcode := -1;
			 x_errorcode := 70;
			 --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			 RAISE FND_API.G_EXC_ERROR;
                      --
		      END IF;
		   END IF;
                   --
                END IF;
                --
		IF (l_debug = 1) THEN
   		MDEBUG( 'Process Data:serial one per request call Existing_Serial');
   		mdebug('Process: In Process_Data with serial one per request call Existing_Serial');
		END IF;
                Existing_Serial_Number(
                   p_reference => p_interface_rec.reference
                   , p_primary_uom_quantity=> p_interface_rec.primary_uom_quantity
                   , p_count_uom => p_interface_rec.count_uom
                   , p_subinventory =>p_interface_rec.subinventory
                   , p_lot_number => p_interface_rec.lot_number
                   , p_lot_expiration => MTL_CCEOI_VAR_PVT.G_SKU_REC.EXPIRATION_DATE
				   , p_revision =>  p_interface_rec.revision
                   , p_transaction_reason_id => p_interface_rec.transaction_reason_id
                   , p_serial_number => p_interface_rec.serial_number
                   , p_transaction_process_mode => p_interface_rec.process_mode
                   , p_simulate => p_simulate
                );

                --
                -- IF RECORD completed processed OR marked FOR recounting
                IF(MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE
                      IN(3, 5)) THEN
                   --
IF (l_debug = 1) THEN
   MDEBUG( 'Process : with serial one per request Completed');
END IF;

IF (l_debug = 1) THEN
   mdebug('Process: In Process_Data with serial one per request Completed');
END IF;

                --   if p_validation_level = 1 THEN
                   if p_simulate = FND_API.G_FALSE THEN
                   serial_check.inv_unmark_serial(
                      from_serial_number => p_interface_rec.serial_number
                      , to_serial_number => p_interface_rec.serial_number
                      , serial_code => MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE
                      , hdr_id => MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID
                      , temp_id =>  MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID
		      , lot_temp_id => NULL);
                      --

                   END IF;
                   --
                END IF;
             END IF;
          END IF;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Process_Data;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Process_Data;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Process_Data;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  --
  -- updates interface record information
  PROCEDURE Update_CCIEntry(
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ,
  x_return_status OUT NOCOPY VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Update_CCIEntry
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- this PROCEDURE will UPDATE all columns OF the interface TABLE
    -- with the VALUES OF the parameter p_interface_rec. IF this RECORD
    -- have p_interface_rec.cycle_count_entry_id IS NOT NULL that means
    -- that the RECORD IS exported, THEN only the unexported columns
    -- can be updated.
    -- Parameters:
    --     IN    :
    --  p_interface_rec MTL_CC_ENTRIES_INTERFACE%ROWTYPE (required)
    --  the interface RECORD
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       dummy integer;

    BEGIN
       X_return_status := FND_API.G_RET_STS_SUCCESS;
       -- update RECORD to be successful
       --
    BEGIN
       --
       -- An exported RECORD
       IF (l_debug = 1) THEN
          mdebug('updating iface rcord with cc_entry_interface_id='||p_interface_rec.cc_entry_interface_id);
       END IF;
       IF p_interface_rec.cycle_count_entry_id IS NOT NULL THEN
          --
          --
          UPDATE MTL_CC_ENTRIES_INTERFACE
          SET
             last_update_date = sysdate
             , last_updated_by = MTL_CCEOI_VAR_PVT.G_UserID
             , last_update_login = MTL_CCEOI_VAR_PVT.G_LoginID
             , request_id = MTL_CCEOI_VAR_PVT.G_RequestID
             , program_application_id = MTL_CCEOI_VAR_PVT.G_ProgramAppID
             , program_id = MTL_CCEOI_VAR_PVT.G_ProgramID
             , program_update_date = sysdate
             , primary_uom_quantity = p_interface_rec.primary_uom_quantity
             , count_uom = p_interface_rec.count_uom
             , count_unit_of_measure = p_interface_rec.count_unit_of_measure
             , count_quantity = p_interface_rec.count_quantity
             , count_date =p_interface_rec.count_date
             , employee_id = p_interface_rec.employee_id
             , employee_full_name = p_interface_rec.employee_full_name
             , reference = p_interface_rec.reference
             , transaction_reason_id = p_interface_rec.transaction_reason_id
             , transaction_reason = p_interface_rec.transaction_reason
             , project_id = p_interface_rec.project_id
             , task_id = p_interface_rec.task_id
             --This code modification done for the bug2311404 by aapaul
	     , system_quantity = decode(MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY,NULL,
                                        system_quantity,MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY)
	     , lock_flag = p_interface_rec.lock_flag
             -- BEGIN INVCONV
             , secondary_uom = p_interface_rec.secondary_uom
             , secondary_unit_of_measure = p_interface_rec.secondary_unit_of_measure
             , secondary_count_quantity = p_interface_rec.secondary_count_quantity
	     , secondary_system_quantity = decode(MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY,NULL,
                             secondary_system_quantity,MTL_CCEOI_VAR_PVT.G_SECONDARY_SYSTEM_QUANTITY)
             -- END INVCONV
          WHERE
             cc_entry_interface_id = p_interface_rec.cc_entry_interface_id;
          --
       ELSE
	  --
          UPDATE MTL_CC_ENTRIES_INTERFACE
          SET  cost_group_name = p_interface_rec.cost_group_name
             , cost_group_id = p_interface_rec.cost_group_id
             , parent_lpn_id = p_interface_rec.parent_lpn_id
             , outermost_lpn_id = p_interface_rec.outermost_lpn_id
             , organization_id = p_interface_rec.organization_id
             , last_update_date = sysdate
             , last_updated_by = MTL_CCEOI_VAR_PVT.G_UserID
             , last_update_login = MTL_CCEOI_VAR_PVT.G_LoginID
             , action_code = p_interface_rec.action_code
             , cycle_count_header_id = p_interface_rec.cycle_count_header_id
             , cycle_count_header_name = p_interface_rec.cycle_count_header_name
             , count_list_sequence = p_interface_rec.count_list_sequence
             , inventory_item_id = p_interface_rec.inventory_item_id
    --         , inventory_item = p_interface_rec.inventory_item
             , item_segment1 = p_interface_rec.item_segment1
             , item_segment2 = p_interface_rec.item_segment2
             , item_segment3 = p_interface_rec.item_segment3
             , item_segment4 = p_interface_rec.item_segment4
             , item_segment5 = p_interface_rec.item_segment5
             , item_segment6 = p_interface_rec.item_segment6
             , item_segment7 = p_interface_rec.item_segment7
             , item_segment8 = p_interface_rec.item_segment8
             , item_segment9 = p_interface_rec.item_segment9
             , item_segment10 = p_interface_rec.item_segment10
             , item_segment11 = p_interface_rec.item_segment11
             , item_segment12 = p_interface_rec.item_segment12
             , item_segment13 = p_interface_rec.item_segment13
             , item_segment14 = p_interface_rec.item_segment14
             , item_segment15 = p_interface_rec.item_segment15
             , item_segment16 = p_interface_rec.item_segment16
             , item_segment17 = p_interface_rec.item_segment17
             , item_segment18 =p_interface_rec.item_segment18
             , item_segment19 = p_interface_rec.item_segment19
             , item_segment20 = p_interface_rec.item_segment20
             , revision = p_interface_rec.revision
             , subinventory = p_interface_rec.subinventory
             , locator_id = p_interface_rec.locator_id
    --         , locator = p_interface_rec.locator
             , locator_segment1 = p_interface_rec.locator_segment1
             , locator_segment2 = p_interface_rec.locator_segment2
             , locator_segment3 = p_interface_rec.locator_segment3
             , locator_segment4 = p_interface_rec.locator_segment4
             , locator_segment5 = p_interface_rec.locator_segment5
             , locator_segment6 = p_interface_rec.locator_segment6
             , locator_segment7 = p_interface_rec.locator_segment7
             , locator_segment8 = p_interface_rec.locator_segment8
             , locator_segment9 = p_interface_rec.locator_segment9
             , locator_segment10 = p_interface_rec.locator_segment10
             , locator_segment11 = p_interface_rec.locator_segment11
             , locator_segment12 = p_interface_rec.locator_segment12
             , locator_segment13 = p_interface_rec.locator_segment13
             , locator_segment14 = p_interface_rec.locator_segment14
             , locator_segment15 = p_interface_rec.locator_segment15
             , locator_segment16 = p_interface_rec.locator_segment16
             , locator_segment17 = p_interface_rec.locator_segment17
             , locator_segment18 = p_interface_rec.locator_segment18
             , locator_segment19 = p_interface_rec.locator_segment19
             , locator_segment20 = p_interface_rec.locator_segment20
             , lot_number = p_interface_rec.lot_number
             , serial_number = p_interface_rec.serial_number
             , primary_uom_quantity = p_interface_rec.primary_uom_quantity
             , count_uom = p_interface_rec.count_uom
             , count_unit_of_measure = p_interface_rec.count_unit_of_measure
             , count_quantity = p_interface_rec.count_quantity
             , adjustment_account_id = p_interface_rec.adjustment_account_id
    --         , adjustment_account = p_interface_rec.adjustment_account
             , account_segment1 = p_interface_rec.account_segment1
             , account_segment2 = p_interface_rec.account_segment2
             , account_segment3 = p_interface_rec.account_segment3
             , account_segment4 = p_interface_rec.account_segment4
             , account_segment5 = p_interface_rec.account_segment5
             , account_segment6 = p_interface_rec.account_segment6
             , account_segment7 = p_interface_rec.account_segment7
             , account_segment8 = p_interface_rec.account_segment8
             , account_segment9 = p_interface_rec.account_segment9
             , account_segment10 = p_interface_rec.account_segment10
             , account_segment11 = p_interface_rec.account_segment11
             , account_segment12 = p_interface_rec.account_segment12
             , account_segment13 = p_interface_rec.account_segment13
             , account_segment14 = p_interface_rec.account_segment14
             , account_segment15 = p_interface_rec.account_segment15
             , account_segment16 = p_interface_rec.account_segment16
             , account_segment17 = p_interface_rec.account_segment17
             , account_segment18 = p_interface_rec.account_segment18
             , account_segment19 = p_interface_rec.account_segment19
             , account_segment20 = p_interface_rec.account_segment20
             , account_segment21 = p_interface_rec.account_segment21
             , account_segment22 = p_interface_rec.account_segment22
             , account_segment23 = p_interface_rec.account_segment23
             , account_segment24 = p_interface_rec.account_segment24
             , account_segment25 = p_interface_rec.account_segment25
             , account_segment26 = p_interface_rec.account_segment26
             , account_segment27 = p_interface_rec.account_segment27
             , account_segment28 = p_interface_rec.account_segment28
             , account_segment29 = p_interface_rec.account_segment29
             , account_segment30 = p_interface_rec.account_segment30
             , count_date =p_interface_rec.count_date
             , employee_id = p_interface_rec.employee_id
             , employee_full_name = p_interface_rec.employee_full_name
             , reference = p_interface_rec.reference
             , transaction_reason_id = p_interface_rec.transaction_reason_id
             , transaction_reason = p_interface_rec.transaction_reason
             , request_id = MTL_CCEOI_VAR_PVT.G_RequestID
             , program_application_id = MTL_CCEOI_VAR_PVT.G_ProgramAppID
             , program_id = MTL_CCEOI_VAR_PVT.G_ProgramID
             , program_update_date = sysdate
             , attribute_category = p_interface_rec.attribute_category
             , attribute1 = p_interface_rec.attribute1
             , attribute2 = p_interface_rec.attribute2
             , attribute3 = p_interface_rec.attribute3
             , attribute4 = p_interface_rec.attribute4
             , attribute5 = p_interface_rec.attribute5
             , attribute6 = p_interface_rec.attribute6
             , attribute7 = p_interface_rec.attribute7
             , attribute8 = p_interface_rec.attribute8
             , attribute9 = p_interface_rec.attribute9
             , attribute10 = p_interface_rec.attribute10
             , attribute11 = p_interface_rec.attribute11
             , attribute12 = p_interface_rec.attribute12
             , attribute13 = p_interface_rec.attribute13
             , attribute14 = p_interface_rec.attribute14
             , attribute15 = p_interface_rec.attribute15
             , project_id = p_interface_rec.project_id
             , task_id = p_interface_rec.task_id
	    , lock_flag = p_interface_rec.lock_flag
             -- BEGIN INVCONV
             , secondary_uom = p_interface_rec.secondary_uom
             , secondary_unit_of_measure = p_interface_rec.secondary_unit_of_measure
             , secondary_count_quantity = p_interface_rec.secondary_count_quantity
             -- END INVCONV
          WHERE
             cc_entry_interface_id = p_interface_rec.cc_entry_interface_id;
          --
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
    END;
  END;




  --
  -- calls mtl_serial_check.inv_qtybetwn
  -- to validate serial location and check whether a serial number
  -- can be issued or received
  --
  -- pre: it is necessary to call all validation routines that would have
  -- computed system quantity, count quantity and derive internal variables
  -- containing item, org, subinv, locator, etc.
  --
  -- post:
  --
       FUNCTION check_serial_location(
				      P_issue_receipt IN VARCHAR2,
				      p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE )
				      return BOOLEAN
  IS
     l_return_status VARCHAR2(1);
     l_errorcode NUMBER;
     l_msg_data VARCHAR2(240);
     l_msg_count NUMBER;
     l_serial_number_type NUMBER;
     l_prefix VARCHAR2(30);
     l_quantity NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     SELECT SERIAL_NUMBER_TYPE
       INTO l_serial_number_type
       FROM  MTL_PARAMETERS
       WHERE organization_id = MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID;

     mtl_serial_check.inv_qtybetwn(
       p_api_version => 0.9,
       x_errorcode => l_errorcode,
       x_return_status => l_return_status,
       x_msg_count => l_msg_count,
       x_msg_data => l_msg_data,
       p_item_id => MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID,
       p_organization_id => MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID,
       p_subinventory => MTL_CCEOI_VAR_PVT.G_SUBINVENTORY,
       p_locator_id => MTL_CCEOI_VAR_PVT.G_LOCATOR_ID,
       p_revision => MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION,
       p_lot_number =>  MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER,
       p_from_serial_number => MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER,
       p_to_serial_number => MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER,
       p_serial_control => MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE,
       p_serial_number_type => l_serial_number_type,
       p_transaction_action_id => 4,
       p_transaction_source_type_id => 9,
       x_prefix => l_prefix,
       x_quantity => l_quantity,
       p_receipt_issue_flag => p_issue_receipt,
       p_simulate => p_simulate);


     if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
	return (FALSE);
     end if;


     return (TRUE);
  end;

       /*
       u1 VARCHAR2(30);
      u2 VARCHAR2(30);
      u3 NUMBER;
      u4 VARCHAR2(30);
      u5 NUMBER;
      u6 NUMBER;
      u7  NUMBER;
      u8 NUMBER;
      u9 NUMBER;
      u10 NUMBER;
      u11 VARCHAR2(3);
      u12 VARCHAR2(30);
      u13 VARCHAR2(10);
      u14 NUMBER;
      u15 VARCHAR2(1);
      L_serial_count    NUMBER;
      --
      v_serial_count_option number  := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.SERIAL_COUNT_OPTION ;
      v_serial_number_type number := 1;
      v_org_id number := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID;
      v_serial_number VARCHAR2(30):= MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER ;

      v_serial_detail number := MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.SERIAL_DETAIL;
      v_serial_discrepancy number := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.SERIAL_DISCREPANCY_OPTION;
      v_item_id number := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID ;
      v_subinv varchar2(10):= MTL_CCEOI_VAR_PVT.G_SUBINVENTORY;
      v_revision varchar2(3) := MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      v_lot_number VARCHAR2(80):= MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER;
      v_msn_serial_number varchar2(30);
      v_msn_item_id number;
      v_msn_org_id number;
      v_msn_subinv varchar2(10);
      v_msn_lot_number number;
      v_msn_locator_id number;
      v_msn_revision varchar2(3);
      v_current_status number;
      --
      P_api_version NUMBER := 0.9;
      P_INIT_MSG_LIST               VARCHAR2(30) DEFAULT FND_API.G_FALSE;
      P_COMMIT                      VARCHAR2(30) DEFAULT FND_API.G_FALSE;
      P_VALIDATION_LEVEL            NUMBER := 1;
    --  P_VALIDATION_LEVEL            NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL;
      X_RETURN_STATUS               VARCHAR2(90);
      X_MSG_COUNT                   NUMBER;
      X_MSG_DATA                    VARCHAR2(90);
      X_ERRORCODE                   NUMBER;
      --
      L_serial_status BOOLEAN := TRUE;
      L_ret_value BOOLEAN := TRUE ;
  BEGIN
IF (l_debug = 1) THEN
   MDEBUG( 'Process- witihin check-serial');
END IF;
   IF  (MTL_CCEOI_VAR_PVT.G_SYSTEM_QUANTITY  = 1 AND MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY = 1
       AND  MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.SERIAL_COUNT_OPTION = 2) then
        L_ret_value := TRUE;
   else
        if(v_org_id IS NOT NULL) then
             SELECT SERIAL_NUMBER_TYPE
               INTO v_serial_number_type
               FROM  MTL_PARAMETERS
              WHERE  ORGANIZATION_ID = v_org_id;
        end if;
        u1 := v_serial_number ;
        u2 := v_serial_number ;
        u3 := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SYSTEM_QUANTITY_CURRENT;
        u4 := NULL;
        u5 := v_item_id;
        u6 := v_org_id;
        u7 := v_serial_number_type;
        u8 := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID;
        u9 := to_char(9);
        u10:= MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE;
        u11:= v_revision;
        u12:= v_lot_number;
        u13:= v_subinv;
        u14:= MTL_CCEOI_VAR_PVT.G_LOCATOR_ID;
        u15:= P_issue_receipt;
        --
IF (l_debug = 1) THEN
   MDEBUG( 'Process- within serial no type ='||to_char(u7));
   MDEBUG( 'Process- within item ='||to_char(u5));
   MDEBUG( 'Process- within org ='||to_char(u6));
   MDEBUG( 'Process- within SerlNoCtrlCd ='||to_char(u10));
   MDEBUG( 'Process- within Locator ='||to_char(u14));
   MDEBUG( 'Process- within serial  ='||u1);
   MDEBUG( 'Process- within Lot  ='||u12);
   MDEBUG( 'Process- within rev  ='||u11);
   MDEBUG( 'Process- within Rec-Issue  ='||u15);
   MDEBUG( 'Process- within subinv  ='||u13);
   MDEBUG( 'Process- within check-serial before call qtybetwn');
END IF;
--
--
        MTL_SERIAL_CHECK.INV_QTYBETWN
          ( P_API_VERSION=>p_api_version ,
            P_INIT_MSG_LIST =>p_init_msg_list,
            P_COMMIT        =>p_commit,
            P_VALIDATION_LEVEL =>p_validation_level,
            X_RETURN_STATUS    =>x_return_status,
            X_MSG_COUNT        =>x_msg_count,
            X_MSG_DATA         =>x_msg_data,
            X_ERRORCODE       =>x_errorcode,
            P_FROM_SERIAL_NUMBER=>u1,
            P_TO_SERIAL_NUMBER =>u2,
            P_QUANTITY         =>u3,
            P_PREFIX           =>u4,
            P_ITEM_ID          =>u5,
            P_ORGANIZATION_ID  =>u6,
            P_SERIAL_NUMBER_TYPE=>u7,
            P_TRANSACTION_ACTION_ID =>u8,
            P_TRANSACTION_SOURCE_TYPE_ID=>u9,
            P_SERIAL_CONTROL           =>u10,
            P_REVISION                 =>u11,
            P_LOT_NUMBER               =>u12,
            P_SUBINVENTORY             =>u13,
            P_LOCATOR_ID               =>u14,
            P_RECEIPT_ISSUE_FLAG       =>u15,
            P_VALIDATE => 'Y'
         );
      --L_serial_status := MTL_INV_UTIL_GRP.CHECK_SERIAL_NUMBER_LOCATION (u1,u5,u6,u7,u10,u11,u12,u13,u14,u15);
--

IF (l_debug = 1) THEN
   MDEBUG( 'Process- within check-serial after call qtybetwn='||x_return_status);
END IF;

          if (x_return_status <> 'S' AND P_issue_receipt = 'R') then
            SELECT COUNT(*)
              INTO L_serial_count
              FROM MTL_SERIAL_NUMBERS
             WHERE SERIAL_NUMBER = v_serial_number AND
                   INVENTORY_ITEM_ID = v_item_id   AND
                   CURRENT_ORGANIZATION_ID = v_org_id   AND
                   CURRENT_STATUS = 3;
            if(L_serial_count = 1 AND v_serial_discrepancy = 1 ) then
               MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.APPROVAL_CONDITION := 1;
               MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE := 2;
	       fnd_message.set_name('INV', 'INV_CC_SERIAL_MULTI_TRANSACT2');
	       fnd_message.set_token('SERIAL', v_serial_number);
	       fnd_msg_pub.add;

	       L_ret_value := TRUE;
            else
	       IF (l_debug = 1) THEN
   	       MDEBUG( 'Process- within check-serial-1-INV_CC_SERIAL_DISCREPANCY' );
	       END IF;
	       fnd_message.set_name('INV', 'INV_CC_SERIAL_DISCREPANCY');
	       fnd_msg_pub.add;

	       L_ret_value := FALSE;
            end if;
         elsif x_return_status <> 'S' then
IF (l_debug = 1) THEN
   MDEBUG( 'Process- within check-serial-2-INV_CC_SERIAL_DISCREPANCY' );
END IF;
	    fnd_message.set_name('INV', 'INV_CC_SERIAL_DISCREPANCY');
	    fnd_msg_pub.add;
           L_ret_value := FALSE;
         end if;
    end if;
    return (L_ret_value);
  END ;
  --
  */


PROCEDURE DELETE_RESERVATION (
  p_subinventory IN VARCHAR2 ,
  p_lot_number IN VARCHAR2 ,
  p_revision IN VARCHAR2
)
IS
  l_mtl_reservation_rec     INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
                            :=INV_CC_RESERVATIONS_PVT.Define_Reserv_Rec_Type;
  l_init_msg_lst            varchar2(1);
  l_error_code              NUMBER;
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(240);
  lmsg                      varchar2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  /* passing input variable */
  /* delete only cycle count reservation */
   l_mtl_reservation_rec.demand_source_type_id := 9;
   l_mtl_reservation_rec.organization_id := MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id;
   l_mtl_reservation_rec.inventory_item_id := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
   l_mtl_reservation_rec.subinventory_code := p_subinventory;
   l_mtl_reservation_rec.revision := p_revision;
   l_mtl_reservation_rec.locator_id := MTL_CCEOI_VAR_PVT.G_LOCATOR_ID;
   l_mtl_reservation_rec.lot_number := p_lot_number;
   l_mtl_reservation_rec.lpn_id := MTL_CCEOI_VAR_PVT.G_LPN_ID;
   --
   INV_CC_RESERVATIONS_PVT.Delete_All_Reservation
   (
      p_api_version_number    => 1.0
   ,  p_init_msg_lst          => l_init_msg_lst
   ,  p_mtl_reservation_rec   => l_mtl_reservation_rec
   ,  x_error_code            => l_error_code
   ,  x_return_status         => l_return_status
   ,  x_msg_count             => l_msg_count
   ,  x_msg_data              => l_msg_data
   );
  IF l_return_status <> 'S' then
     IF (l_debug = 1) THEN
        mdebug('error in delete all reservations');
     END IF;
     --FND_MESSAGE.ERROR;
     --RAISE FORM_TRIGGER_FAILURE;
  END IF;
END DELETE_RESERVATION;

-- BEGIN INVCONV
PROCEDURE validate_secondaryuomqty (
   p_api_version                 IN         NUMBER
 , p_init_msg_list               IN         VARCHAR2 DEFAULT fnd_api.g_false
 , p_commit                      IN         VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_level            IN         NUMBER DEFAULT fnd_api.g_valid_level_full
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 , x_errorcode                   OUT NOCOPY NUMBER
 , p_organization_id             IN         NUMBER
 , p_inventory_item_id           IN         NUMBER
 , p_lpn_id                      IN         NUMBER DEFAULT NULL
 , p_serial_number               IN         VARCHAR2 DEFAULT NULL
 , p_subinventory                IN         VARCHAR2
 , p_revision                    IN         VARCHAR2 DEFAULT NULL
 , p_lot_number                  IN         VARCHAR2
 , p_secondary_uom               IN         VARCHAR2
 , p_secondary_unit_of_measure   IN         VARCHAR2
 , p_secondary_count_quantity    IN         NUMBER
 , p_secondary_system_quantity   IN         NUMBER
 , p_tracking_quantity_ind       IN         VARCHAR2
 , p_secondary_default_ind       IN         VARCHAR2) IS
   --
   l_debug                  NUMBER         := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   l_api_version   CONSTANT NUMBER         := 0.9;
   l_api_name      CONSTANT VARCHAR2 (30)  := 'Validate_SecondaryUOMQty';
   l_table_name             VARCHAR2 (100);
   l_column_name            VARCHAR2 (100);
   l_message_name           VARCHAR2 (30);
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT validate_uomquantity;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.compatible_api_call (l_api_version
                                     , p_api_version
                                     , l_api_name
                                     , g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialisize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   x_errorcode := 0;

   --
   IF (l_debug = 1) THEN
      mdebug (   'Validate_SecondaryUOMQty call. count_type_code = '
              || NVL (TO_CHAR (mtl_cceoi_var_pvt.g_cycle_count_entry_rec.count_type_code), 'NULL'));
      mdebug ('Tracking Quantity Ind ' || p_tracking_quantity_ind);
      mdebug ('Secondary Default Ind ' || p_secondary_default_ind);
   END IF;

   IF    mtl_cceoi_var_pvt.g_cycle_count_entry_rec.count_type_code = 4
      OR p_tracking_quantity_ind <> 'PS' THEN
      mtl_cceoi_var_pvt.g_secondary_count_uom := NULL;
      mtl_cceoi_var_pvt.g_secondary_count_quantity := NULL;
      mtl_cceoi_var_pvt.g_secondary_system_quantity := NULL;
      mtl_cceoi_var_pvt.g_lpn_item_sec_system_qty := NULL;
      mtl_cceoi_var_pvt.g_sec_adjustment_quantity := NULL;
   ELSIF     (   mtl_cceoi_var_pvt.g_cycle_count_entry_rec.count_type_code IN (1, 2, 3)
              OR mtl_cceoi_var_pvt.g_cycle_count_entry_rec.count_type_code IS NULL)
         AND p_tracking_quantity_ind = 'PS' THEN
      IF (l_debug = 1) THEN
         mdebug (   'Process: In Validate_SecondaryUOMQty call Validate_SecondaryCountUOM: '
                 || p_secondary_uom);
      END IF;

      mtl_inv_validate_grp.validate_secondarycountuom
                                        (p_api_version => 0.9
                                       , x_msg_count => x_msg_count
                                       , x_msg_data => x_msg_data
                                       , x_return_status => x_return_status
                                       , x_errorcode => x_errorcode
                                       , p_organization_id => p_organization_id
                                       , p_inventory_item_id => p_inventory_item_id
                                       , p_secondary_uom => p_secondary_uom
                                       , p_secondary_unit_of_measure => p_secondary_unit_of_measure
                                       , p_tracking_quantity_ind => p_tracking_quantity_ind);

      IF (l_debug = 1) THEN
         mdebug ('After Validate Secondary UOM ' || TO_CHAR (x_errorcode) || ' - '
                 || x_return_status);
      END IF;

      IF x_errorcode = 20 THEN
         -- Write INTO interface error TABLE
         mtl_cceoi_process_pvt.insert_cceoierror
                             (p_cc_entry_interface_id => mtl_cceoi_var_pvt.g_cc_entry_interface_id
                            , p_error_column_name => 'SECONDARY_UOM_CODE'
                            , p_error_table_name => 'MTL_SYSTEM_ITEMS'
                            , p_message_name => 'INV_INCORRECT_SECONDARY_UOM');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
         mdebug (   'Process: In Validate_SecondaryUOMQty call Validate_SecondaryCountQty: '
                 || p_secondary_count_quantity);
      END IF;

      -- Validate Secondary count quantity
      -- Need to handle conversions and defaulting
      mtl_inv_validate_grp.validate_secondarycountqty
                                           (p_api_version => 0.9
                                          , x_return_status => x_return_status
                                          , x_msg_count => x_msg_count
                                          , x_msg_data => x_msg_data
                                          , x_errorcode => x_errorcode
                                          , p_organization_id => p_organization_id
                                          , p_inventory_item_id => p_inventory_item_id
					  , p_lot_number => p_lot_number
					  , p_count_uom => MTL_CCEOI_VAR_PVT.G_UOM_CODE
					  , p_count_quantity => MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY
					  , p_secondary_uom => MTL_CCEOI_VAR_PVT.g_secondary_count_uom
                                          , p_secondary_quantity => p_secondary_count_quantity
                                          , p_tracking_quantity_ind => p_tracking_quantity_ind
					  , p_secondary_default_ind => p_secondary_default_ind
					  );

      IF (l_debug = 1) THEN
         mdebug ('After Validate Secondary Qty ' || TO_CHAR (x_errorcode) || ' - '
                 || x_return_status);
      END IF;

      IF x_errorcode = 50 THEN
         -- Write INTO interface error TABLE
         mtl_cceoi_process_pvt.insert_cceoierror
                             (p_cc_entry_interface_id => mtl_cceoi_var_pvt.g_cc_entry_interface_id
                            , p_error_column_name => 'SECONDARY_COUNT_QUANTITY'
                            , p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE'
                            , p_message_name => 'INV_NO_CONVERSION_ERR');
         RAISE fnd_api.g_exc_error;
      ELSIF x_errorcode = 51 THEN
         -- Write INTO interface error TABLE
         mtl_cceoi_process_pvt.insert_cceoierror
                             (p_cc_entry_interface_id => mtl_cceoi_var_pvt.g_cc_entry_interface_id
                            , p_error_column_name => 'SECONDARY_COUNT_QUANTITY'
                            , p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE'
                            , p_message_name => 'INV_DEVIATION_CHECK_ERR');
         RAISE fnd_api.g_exc_error;
      ELSIF x_errorcode = 52 THEN
         -- Write INTO interface error TABLE
         mtl_cceoi_process_pvt.insert_cceoierror
                             (p_cc_entry_interface_id => mtl_cceoi_var_pvt.g_cc_entry_interface_id
                            , p_error_column_name => 'SECONDARY_COUNT_QUANTITY'
                            , p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE'
                            , p_message_name => 'INV_CCEOI_NEG_QTY');
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Calculate secondary adjustment quantity
      MTL_CCEOI_VAR_PVT.g_sec_adjustment_quantity :=
          nvl(MTL_CCEOI_VAR_PVT.g_secondary_count_quantity,0) - nvl(MTL_CCEOI_VAR_PVT.g_secondary_system_quantity,0);

   ELSE   -- count type code
      IF (l_debug = 1) THEN
         mdebug ('Invalid count_type_code');
      END IF;

      mtl_cceoi_process_pvt.insert_cceoierror
                              (p_cc_entry_interface_id => mtl_cceoi_var_pvt.g_cc_entry_interface_id
                             , p_error_column_name => 'unexpected error'
                             , p_error_table_name => 'unexpected error'
                             , p_message_name => 'unexpected error');
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;   -- count type code

   -- Standard check of p_commit
   IF fnd_api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_secondarycountuom;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_secondarycountuom;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_errorcode := -1;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO validate_secondarycountuom;
      x_errorcode := -1;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END validate_secondaryuomqty;
-- END INVCONV

END MTL_CCEOI_PROCESS_PVT;

/
