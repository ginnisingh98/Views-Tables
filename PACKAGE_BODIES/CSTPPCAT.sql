--------------------------------------------------------
--  DDL for Package Body CSTPPCAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPCAT" AS
/* $Header: CSTPPCAB.pls 120.1.12010000.2 2008/11/13 12:19:26 smsasidh ship $ */

PROCEDURE CSTPCCAT (
  I_INVENTORY_ITEM_ID    IN  NUMBER,
  I_ORGANIZATION_ID      IN  NUMBER,
  I_LAST_UPDATED_BY      IN  NUMBER,
  I_COST_TYPE_ID         IN  NUMBER,
  I_ITEM_TYPE            IN  NUMBER,
  I_LOT_SIZE             IN  NUMBER,
  I_SHRINKAGE_RATE       IN  NUMBER,

  O_RETURN_CODE          OUT NOCOPY NUMBER,
  O_RETURN_ERR           OUT NOCOPY VARCHAR2
) IS
  row_count              NUMBER;
  p_cost_method          MTL_PARAMETERS.PRIMARY_COST_METHOD%TYPE;
  p_avg_rates_cost_type  MTL_PARAMETERS.AVG_RATES_COST_TYPE_ID%TYPE; --Added for 7237799
  retval                 NUMBER;
  retmsg                 VARCHAR(100);
BEGIN

/*
 * get the primary cost method.  the primary cost method matches
 * the code for the valuation cost type for that method.
 *
 * 1 = Standard costing/Frozen cost type
 * 2 = Average costing/Average cost type
 */
  select primary_cost_method, avg_rates_cost_type_id
  into p_cost_method, p_avg_rates_cost_type
  from mtl_parameters
  where organization_id = I_ORGANIZATION_ID;

/*
 * Added the below ELSE condition or bug 7237799
 */
IF p_cost_method = 1 THEN
/*
 * check if previous-level costs exist, or if this-level
 * "non-material overhead" costs exist for the item in the
 * valuation cost type.
 */
  select count(*)
  into row_count
  from cst_item_cost_details
  where organization_id = I_ORGANIZATION_ID
  and inventory_item_id = I_INVENTORY_ITEM_ID
  and cost_type_id = p_cost_method
  and (level_type = 2
       OR
        cost_element_id <> 2)
   and ROWNUM < 2;   -- Added for 7237799

  if (row_count > 0) then
    return;
  end if;
ELSE
   /*
    * In Average, LIFO and FIFO Costing Organizations Default MOH Check.
    * Check if previous-level costs exist, or if this-level
    * "non-material overhead" costs exist for the item in the
    * average rates cost type.
    */
   select count(*)
   into row_count
   from cst_item_cost_details
   where organization_id = I_ORGANIZATION_ID
   and inventory_item_id = I_INVENTORY_ITEM_ID
   and cost_type_id = p_avg_rates_cost_type
   and NOT (level_type = 1
            AND (cost_element_id = 2
                OR (cost_element_id = 1
                    AND item_cost = 0)))
   and ROWNUM < 2;   -- Added for 7237799

   if (row_count > 0) then
     return;
   end if;
   /*
    * Added for bug 7237799
    * check if there is any cst_quantiry_layers for this item
    */
   select count(*)
   into row_count
   from cst_quantity_layers
   where organization_id = I_ORGANIZATION_ID
   and inventory_item_id = I_INVENTORY_ITEM_ID
   and ROWNUM < 2;

   if (row_count > 0) then
     return;
   end if;

END IF;

/*
  * Added for bug 7237799
  * check if any On Hand Quantities are there for this item
  */
  select count(*)
  into row_count
  from mtl_onhand_quantities
  where organization_id = I_ORGANIZATION_ID
  and inventory_item_id = I_INVENTORY_ITEM_ID
  and ROWNUM < 2;

  if (row_count > 0) then
    return;
  end if;

/*
 * check if any WIP transactions have been performed on the item
 */
 /* Commented for bug 7237799
  select count(*)
  into row_count
  from wip_transactions
  where organization_id = I_ORGANIZATION_ID
  and primary_item_id = I_INVENTORY_ITEM_ID;

  if (row_count > 0) then
    return;
  end if;

  select count(*)
  into row_count
  from wip_move_transactions
  where organization_id = I_ORGANIZATION_ID
  and primary_item_id = I_INVENTORY_ITEM_ID;

  if (row_count > 0) then
    return;
  end if;
*/

/*
 * check if any material transactions have been performed on the item
 */
  select count(*)
  into row_count
  from mtl_material_transactions
  where organization_id = I_ORGANIZATION_ID
  and inventory_item_id = I_INVENTORY_ITEM_ID
  and ROWNUM < 2;  -- Added for 7237799

  if (row_count > 0) then
    return;
  end if;


/*
 * delete all previously existing costs
 */
  delete
  from cst_item_cost_details
  where organization_id = I_ORGANIZATION_ID
  and inventory_item_id = I_INVENTORY_ITEM_ID
  and cost_type_id = p_cost_method;

 /*
 * Bug FP 5218221: The previously existing costs were not being deleted from the
 * Summary table - CST_ITEM_COSTS, causing discrepancy between CIC and CICD.
 */
UPDATE cst_item_costs
   SET pl_material = 0, pl_material_overhead = 0,
       pl_resource = 0, pl_outside_processing = 0,
       pl_overhead = 0, tl_material = 0,
       tl_material_overhead = 0, tl_resource = 0,
       tl_outside_processing = 0, tl_overhead = 0,
       material_cost = 0, material_overhead_cost = 0,
       resource_cost = 0, outside_processing_cost = 0,
       overhead_cost = 0, pl_item_cost = 0,
       tl_item_cost = 0, item_cost = 0,
       unburdened_cost = 0, burden_cost = 0,
       last_update_date = SYSDATE,
       last_updated_by = i_last_updated_by
 WHERE inventory_item_id = i_inventory_item_id
   AND organization_id = i_organization_id
   AND cost_type_id = p_cost_method;


/*
 * now call the function to assign material overhead defaults
 * (CSTPIDIO)
 */
  CSTPIDIC.CSTPIDIO(I_INVENTORY_ITEM_ID,
           I_ORGANIZATION_ID,
           I_LAST_UPDATED_BY,
           I_COST_TYPE_ID,
           I_ITEM_TYPE,
           I_LOT_SIZE,
           I_SHRINKAGE_RATE,
           retval,
           retmsg);


  O_RETURN_CODE := retval;
  O_RETURN_ERR := retmsg;

End CSTPCCAT;

End CSTPPCAT;

/
