--------------------------------------------------------
--  DDL for Package Body WMS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_PVT" AS
  /* $Header: WMSVPPRB.pls 120.39.12010000.37 2010/05/06 11:05:36 abasheer ship $ */
  --
  -- File        : WMSVPPRB.pls
  -- Content     : WMS_Rule_PVT package body
  -- Description : wms rule private API's
  -- Notes       :
  -- Modified    : 02/08/99 mzeckzer created
  --               03/29/99 bitang modified
  --     01/17/99 jcearley added GenerateRulePackage function,
  --             changed Apply to call stored function
  --               02/11/00 lezhang added AssignTT procedures for task type
  --                        assignment. Added CalcRuleWeight for this
  --                        functionality. Also modified GenerateRulePackage and
  --                        BuildRuleSQL.
  --
  --               06/30/02 grao added procedures to call pick, putaway, task,
  --                        label rules statically. open cursor, fetch cursor and
  --                        cursor calls affected. All the current dynamic calls
  --                        to handle rules are disabled and not used any more.
  --                        APPLY(), AssignTT(), ASSIGNLABEL()
  --                        fetchcursor(), fetchPutaway() are modified.
  --
  --               07/11/02 grao Modified the Rules package generating code to
  --                        conver all global variables in the rules packages to
  --                        local variables and defined Pick and Putaway cursors
  --                        as ref cursor, which is passed from the
  --                        WMS_RULE_PVT as a ref Cursor. Also modified the open,
  --                        fetch and close calls for Pick and Putaway rules
  --               10/15/09 Bug 8638386 Pushkar
  --                        Reorganize/extend fix 8665496 - for lot conversion + deviation
  --

  --
  -- Package global variable that stores the package name
  g_pkg_name             CONSTANT VARCHAR2(30)                                            := 'WMS_Rule_PVT';
  --
  -- API versions used within this API
  g_qty_tree_api_version CONSTANT NUMBER                                                  := 1.0; -- INV_Quantity_Tree_PVT
  --
  -- Caching locator record in DoProjectCheck
  g_locator_id    NUMBER;
  g_locator       INV_VALIDATE.locator;
  g_transaction_type_id 	NUMBER;
  g_organization_id 	NUMBER;
  g_inventory_item_id 	NUMBER;
  g_subinventory_code 	WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%TYPE;
  g_allowed 	        VARCHAR2(1);
  g_st_locator_id    NUMBER;
  g_lpn_controlled_flag 	NUMBER;

  --g_serial_objects_used NUMBER ;

  -- Caching in function getconversionrate
  g_gcr_organization_id    NUMBER;
  g_gcr_inventory_item_id  NUMBER;
  g_gcr_uom_code           VARCHAR2(3);
  g_gcr_conversion_rate    NUMBER;

  g_debug                  NUMBER;
  --
  -- constants and global variables needed for dynamic SQL
  --

  /* LG. need to talk to gopal, for all the non restircted loc, should do an outter join*/
  g_put_base_no_restrict          LONG
  := '
 select  msei.secondary_inventory_name subinventory_code               --changed
        ,mil.inventory_location_id locator_id
        ,msei.organization_id organization_id                          --changed
        ,mil.project_id project_id
        ,mil.task_id task_id
        ,g_inventory_item_id inventory_item_id
        ,mil.location_current_units location_current_units
        ,mil.inventory_item_id locator_inventory_item_id
        ,mil.empty_flag empty_flag
        ,mil.mixed_items_flag mixed_items_flag
        ,mil.LAST_UPDATE_DATE
        ,mil.LAST_UPDATED_BY
        ,mil.CREATION_DATE
        ,mil.CREATED_BY
        ,mil.LAST_UPDATE_LOGIN
        ,mil.DESCRIPTION
        ,mil.DESCRIPTIVE_TEXT
        ,mil.DISABLE_DATE
        ,mil.INVENTORY_LOCATION_TYPE
        ,mil.PICKING_ORDER
        ,mil.PHYSICAL_LOCATION_CODE
        ,mil.LOCATION_MAXIMUM_UNITS
        ,mil.LOCATION_WEIGHT_UOM_CODE
        ,mil.MAX_WEIGHT
        ,mil.VOLUME_UOM_CODE
        ,mil.MAX_CUBIC_AREA
        ,mil.X_COORDINATE
        ,mil.Y_COORDINATE
        ,mil.Z_COORDINATE
        ,mil.INVENTORY_ACCOUNT_ID
        ,mil.SEGMENT1
        ,mil.SEGMENT2
        ,mil.SEGMENT3
        ,mil.SEGMENT4
        ,mil.SEGMENT5
        ,mil.SEGMENT6
        ,mil.SEGMENT7
        ,mil.SEGMENT8
        ,mil.SEGMENT9
        ,mil.SEGMENT10
        ,mil.SEGMENT11
        ,mil.SEGMENT12
        ,mil.SEGMENT13
        ,mil.SEGMENT14
        ,mil.SEGMENT15
        ,mil.SEGMENT16
        ,mil.SEGMENT17
        ,mil.SEGMENT18
        ,mil.SEGMENT19
        ,mil.SEGMENT20
        ,mil.SUMMARY_FLAG
        ,mil.ENABLED_FLAG
        ,mil.START_DATE_ACTIVE
        ,mil.END_DATE_ACTIVE
        ,mil.ATTRIBUTE_CATEGORY
        ,mil.ATTRIBUTE1
        ,mil.ATTRIBUTE2
        ,mil.ATTRIBUTE3
        ,mil.ATTRIBUTE4
        ,mil.ATTRIBUTE5
        ,mil.ATTRIBUTE6
        ,mil.ATTRIBUTE7
        ,mil.ATTRIBUTE8
        ,mil.ATTRIBUTE9
        ,mil.ATTRIBUTE10
        ,mil.ATTRIBUTE11
        ,mil.ATTRIBUTE12
        ,mil.ATTRIBUTE13
        ,mil.ATTRIBUTE14
        ,mil.ATTRIBUTE15
        ,mil.REQUEST_ID
        ,mil.PROGRAM_APPLICATION_ID
        ,mil.PROGRAM_ID
        ,mil.PROGRAM_UPDATE_DATE
        ,mil.PHYSICAL_LOCATION_ID
        ,mil.PICK_UOM_CODE
        ,mil.DIMENSION_UOM_CODE
        ,mil.LENGTH
        ,mil.WIDTH
        ,mil.HEIGHT
        ,mil.LOCATOR_STATUS
        ,mil.STATUS_ID
        ,mil.CURRENT_CUBIC_AREA
        ,mil.AVAILABLE_CUBIC_AREA
        ,mil.CURRENT_WEIGHT
        ,mil.AVAILABLE_WEIGHT
        ,mil.LOCATION_AVAILABLE_UNITS
        ,mil.SUGGESTED_CUBIC_AREA
        ,mil.SUGGESTED_WEIGHT
        ,mil.LOCATION_SUGGESTED_UNITS
        ,mil.rowid
   from MTL_ITEM_LOCATIONS mil
       ,MTL_SECONDARY_INVENTORIES msei
  where mil.organization_id(+) = msei.organization_id
    and mil.subinventory_code(+) = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.ORGANIZATION_ID = g_organization_id
'; --8467209.added org_id above
  g_put_base_sub_restrict         LONG
  := '
 select  msei.secondary_inventory_name subinventory_code            -- changed
        ,mil.inventory_location_id locator_id
        ,msei.organization_id organization_id                       -- changed
        ,mil.project_id project_id
        ,mil.task_id task_id
        ,g_inventory_item_id inventory_item_id
        ,mil.location_current_units location_current_units
        ,mil.inventory_item_id locator_inventory_item_id
        ,mil.empty_flag empty_flag
        ,mil.mixed_items_flag mixed_items_flag
        ,mil.LAST_UPDATE_DATE
        ,mil.LAST_UPDATED_BY
        ,mil.CREATION_DATE
        ,mil.CREATED_BY
        ,mil.LAST_UPDATE_LOGIN
        ,mil.DESCRIPTION
        ,mil.DESCRIPTIVE_TEXT
        ,mil.DISABLE_DATE
        ,mil.INVENTORY_LOCATION_TYPE
        ,mil.PICKING_ORDER
        ,mil.PHYSICAL_LOCATION_CODE
        ,mil.LOCATION_MAXIMUM_UNITS
        ,mil.LOCATION_WEIGHT_UOM_CODE
        ,mil.MAX_WEIGHT
        ,mil.VOLUME_UOM_CODE
        ,mil.MAX_CUBIC_AREA
        ,mil.X_COORDINATE
        ,mil.Y_COORDINATE
        ,mil.Z_COORDINATE
        ,mil.INVENTORY_ACCOUNT_ID
        ,mil.SEGMENT1
        ,mil.SEGMENT2
        ,mil.SEGMENT3
        ,mil.SEGMENT4
        ,mil.SEGMENT5
        ,mil.SEGMENT6
        ,mil.SEGMENT7
        ,mil.SEGMENT8
        ,mil.SEGMENT9
        ,mil.SEGMENT10
        ,mil.SEGMENT11
        ,mil.SEGMENT12
        ,mil.SEGMENT13
        ,mil.SEGMENT14
        ,mil.SEGMENT15
        ,mil.SEGMENT16
        ,mil.SEGMENT17
        ,mil.SEGMENT18
        ,mil.SEGMENT19
        ,mil.SEGMENT20
        ,mil.SUMMARY_FLAG
        ,mil.ENABLED_FLAG
        ,mil.START_DATE_ACTIVE
        ,mil.END_DATE_ACTIVE
        ,mil.ATTRIBUTE_CATEGORY
        ,mil.ATTRIBUTE1
        ,mil.ATTRIBUTE2
        ,mil.ATTRIBUTE3
        ,mil.ATTRIBUTE4
        ,mil.ATTRIBUTE5
        ,mil.ATTRIBUTE6
        ,mil.ATTRIBUTE7
        ,mil.ATTRIBUTE8
        ,mil.ATTRIBUTE9
        ,mil.ATTRIBUTE10
        ,mil.ATTRIBUTE11
        ,mil.ATTRIBUTE12
        ,mil.ATTRIBUTE13
        ,mil.ATTRIBUTE14
        ,mil.ATTRIBUTE15
        ,mil.REQUEST_ID
        ,mil.PROGRAM_APPLICATION_ID
        ,mil.PROGRAM_ID
        ,mil.PROGRAM_UPDATE_DATE
        ,mil.PHYSICAL_LOCATION_ID
        ,mil.PICK_UOM_CODE
        ,mil.DIMENSION_UOM_CODE
        ,mil.LENGTH
        ,mil.WIDTH
        ,mil.HEIGHT
        ,mil.LOCATOR_STATUS
        ,mil.STATUS_ID
        ,mil.CURRENT_CUBIC_AREA
        ,mil.AVAILABLE_CUBIC_AREA
        ,mil.CURRENT_WEIGHT
        ,mil.AVAILABLE_WEIGHT
        ,mil.LOCATION_AVAILABLE_UNITS
        ,mil.SUGGESTED_CUBIC_AREA
        ,mil.SUGGESTED_WEIGHT
        ,mil.LOCATION_SUGGESTED_UNITS
  ,mil.rowid
from MTL_ITEM_LOCATIONS mil
       ,MTL_SECONDARY_INVENTORIES msei
       ,MTL_ITEM_SUB_INVENTORIES misi
  where mil.organization_id(+) = msei.organization_id
    and mil.organization_id=g_organization_id ---bug8425620 8665549
    and mil.subinventory_code(+) = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
';
  g_put_base_loc_restrict         LONG
  := '
 select  mil.subinventory_code subinventory_code
        ,mil.inventory_location_id locator_id
        ,mil.organization_id organization_id
        ,mil.project_id project_id
        ,mil.task_id task_id
        ,g_inventory_item_id inventory_item_id
        ,mil.location_current_units location_current_units
        ,mil.inventory_item_id locator_inventory_item_id
        ,mil.empty_flag empty_flag
        ,mil.mixed_items_flag mixed_items_flag
        ,mil.LAST_UPDATE_DATE
        ,mil.LAST_UPDATED_BY
        ,mil.CREATION_DATE
        ,mil.CREATED_BY
        ,mil.LAST_UPDATE_LOGIN
        ,mil.DESCRIPTION
        ,mil.DESCRIPTIVE_TEXT
        ,mil.DISABLE_DATE
        ,mil.INVENTORY_LOCATION_TYPE
        ,mil.PICKING_ORDER
        ,mil.PHYSICAL_LOCATION_CODE
        ,mil.LOCATION_MAXIMUM_UNITS
        ,mil.LOCATION_WEIGHT_UOM_CODE
        ,mil.MAX_WEIGHT
        ,mil.VOLUME_UOM_CODE
        ,mil.MAX_CUBIC_AREA
        ,mil.X_COORDINATE
        ,mil.Y_COORDINATE
        ,mil.Z_COORDINATE
        ,mil.INVENTORY_ACCOUNT_ID
        ,mil.SEGMENT1
        ,mil.SEGMENT2
        ,mil.SEGMENT3
        ,mil.SEGMENT4
        ,mil.SEGMENT5
        ,mil.SEGMENT6
        ,mil.SEGMENT7
        ,mil.SEGMENT8
        ,mil.SEGMENT9
        ,mil.SEGMENT10
        ,mil.SEGMENT11
        ,mil.SEGMENT12
        ,mil.SEGMENT13
        ,mil.SEGMENT14
        ,mil.SEGMENT15
        ,mil.SEGMENT16
        ,mil.SEGMENT17
        ,mil.SEGMENT18
        ,mil.SEGMENT19
        ,mil.SEGMENT20
        ,mil.SUMMARY_FLAG
        ,mil.ENABLED_FLAG
        ,mil.START_DATE_ACTIVE
        ,mil.END_DATE_ACTIVE
        ,mil.ATTRIBUTE_CATEGORY
        ,mil.ATTRIBUTE1
        ,mil.ATTRIBUTE2
        ,mil.ATTRIBUTE3
        ,mil.ATTRIBUTE4
        ,mil.ATTRIBUTE5
        ,mil.ATTRIBUTE6
        ,mil.ATTRIBUTE7
        ,mil.ATTRIBUTE8
        ,mil.ATTRIBUTE9
        ,mil.ATTRIBUTE10
        ,mil.ATTRIBUTE11
        ,mil.ATTRIBUTE12
        ,mil.ATTRIBUTE13
        ,mil.ATTRIBUTE14
        ,mil.ATTRIBUTE15
        ,mil.REQUEST_ID
        ,mil.PROGRAM_APPLICATION_ID
        ,mil.PROGRAM_ID
        ,mil.PROGRAM_UPDATE_DATE
        ,mil.PHYSICAL_LOCATION_ID
        ,mil.PICK_UOM_CODE
        ,mil.DIMENSION_UOM_CODE
        ,mil.LENGTH
        ,mil.WIDTH
        ,mil.HEIGHT
        ,mil.LOCATOR_STATUS
        ,mil.STATUS_ID
        ,mil.CURRENT_CUBIC_AREA
        ,mil.AVAILABLE_CUBIC_AREA
        ,mil.CURRENT_WEIGHT
        ,mil.AVAILABLE_WEIGHT
        ,mil.LOCATION_AVAILABLE_UNITS
        ,mil.SUGGESTED_CUBIC_AREA
        ,mil.SUGGESTED_WEIGHT
        ,mil.LOCATION_SUGGESTED_UNITS
        ,mil.rowid
   from MTL_ITEM_LOCATIONS mil
       ,MTL_SECONDARY_INVENTORIES msei
       ,MTL_ITEM_SUB_INVENTORIES misi
       ,MTL_SECONDARY_LOCATORS msl
  where mil.organization_id = msei.organization_id
    and mil.organization_id=g_organization_id ---bug8425620 8665549
    and mil.subinventory_code = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
    and mil.organization_id = msl.organization_id
    and mil.inventory_location_id = msl.secondary_locator
    and msl.inventory_item_Id = g_inventory_item_id
';
  g_put_base             CONSTANT LONG
        := '
 select  x.organization_id
        ,x.inventory_item_id
        ,x.subinventory_code
        ,x.locator_id
  from (
  -- subs not restricted and locator controlled
  select msi.ORGANIZATION_ID    ORGANIZATION_ID
        ,msi.INVENTORY_ITEM_ID    INVENTORY_ITEM_ID
        ,msei.SECONDARY_INVENTORY_NAME  SUBINVENTORY_CODE
        ,mil.INVENTORY_LOCATION_ID  LOCATOR_ID
        ,mil.PROJECT_ID     PROJECT_ID
        ,mil.TASK_ID      TASK_ID
    from MTL_ITEM_LOCATIONS                      mil
        ,MTL_SECONDARY_INVENTORIES               msei
        ,MTL_PARAMETERS                          mp
        ,MTL_SYSTEM_ITEMS                        msi
   where nvl(msi.RESTRICT_SUBINVENTORIES_CODE,2) = 2
     and nvl(msi.RESTRICT_LOCATORS_CODE,2)       = 2
     and mp.ORGANIZATION_ID                      = msi.ORGANIZATION_ID
     and msei.ORGANIZATION_ID                    = msi.ORGANIZATION_ID
     and nvl(msei.DISABLE_DATE,sysdate+1)        > sysdate
     and decode(mp.STOCK_LOCATOR_CONTROL_CODE,
                4,decode(msei.LOCATOR_TYPE,
                         5,nvl(msi.LOCATION_CONTROL_CODE,1),
                         nvl(msei.LOCATOR_TYPE,1)),
                mp.STOCK_LOCATOR_CONTROL_CODE)   > 1
     and mil.INVENTORY_LOCATION_ID               > 0  -- force U1 to be used
     and mil.ORGANIZATION_ID                     = msei.ORGANIZATION_ID
     and mil.SUBINVENTORY_CODE                   = msei.SECONDARY_INVENTORY_NAME
     and nvl(mil.DISABLE_DATE,sysdate+1)         > sysdate
  union all
  -- subs restricted and locator controlled
  select msi.ORGANIZATION_ID
        ,msi.INVENTORY_ITEM_ID
        ,misi.SECONDARY_INVENTORY
        ,mil.INVENTORY_LOCATION_ID
        ,mil.PROJECT_ID
        ,mil.TASK_ID
    from MTL_ITEM_LOCATIONS                      mil
        ,MTL_SECONDARY_INVENTORIES               msei
        ,MTL_ITEM_SUB_INVENTORIES                misi
        ,MTL_PARAMETERS                          mp
        ,MTL_SYSTEM_ITEMS                        msi
   where nvl(msi.RESTRICT_SUBINVENTORIES_CODE,2) = 1
     and nvl(msi.RESTRICT_LOCATORS_CODE,2)       = 2
     and mp.ORGANIZATION_ID                      = msi.ORGANIZATION_ID
     and misi.ORGANIZATION_ID                    = msi.ORGANIZATION_ID
     and misi.INVENTORY_ITEM_ID                  = msi.INVENTORY_ITEM_ID
     and msei.ORGANIZATION_ID                    = misi.ORGANIZATION_ID
     and msei.SECONDARY_INVENTORY_NAME           = misi.SECONDARY_INVENTORY
     and nvl(msei.DISABLE_DATE,sysdate+1)        > sysdate
     and decode(mp.STOCK_LOCATOR_CONTROL_CODE,
                4,decode(msei.LOCATOR_TYPE,
                         5,nvl(msi.LOCATION_CONTROL_CODE,1),
                         nvl(msei.LOCATOR_TYPE,1)),
                mp.STOCK_LOCATOR_CONTROL_CODE)   > 1
     and mil.INVENTORY_LOCATION_ID               > 0  -- force U1 to be used
     and mil.ORGANIZATION_ID                     = misi.ORGANIZATION_ID
     and mil.SUBINVENTORY_CODE                   = misi.SECONDARY_INVENTORY
     and nvl(mil.DISABLE_DATE,sysdate+1)         > sysdate
  union all
  -- locators restricted
  select msi.ORGANIZATION_ID
        ,msi.INVENTORY_ITEM_ID
        ,misi.SECONDARY_INVENTORY
        ,msl.SECONDARY_LOCATOR
        ,mil.PROJECT_ID
        ,mil.TASK_ID
    from MTL_ITEM_LOCATIONS                      mil
        ,MTL_SECONDARY_LOCATORS                  msl
        ,MTL_SECONDARY_INVENTORIES               msei
        ,MTL_ITEM_SUB_INVENTORIES                misi
        ,MTL_PARAMETERS                          mp
        ,MTL_SYSTEM_ITEMS                        msi
   where nvl(msi.RESTRICT_SUBINVENTORIES_CODE,2) = 1
     and nvl(msi.RESTRICT_LOCATORS_CODE,2)       = 1
     and mp.ORGANIZATION_ID                      = msi.ORGANIZATION_ID
     and misi.ORGANIZATION_ID                    = msi.ORGANIZATION_ID
     and misi.INVENTORY_ITEM_ID                  = msi.INVENTORY_ITEM_ID
     and msei.ORGANIZATION_ID                    = misi.ORGANIZATION_ID
     and msei.SECONDARY_INVENTORY_NAME           = misi.SECONDARY_INVENTORY
     and nvl(msei.DISABLE_DATE,sysdate+1)        > sysdate
     and msl.ORGANIZATION_ID                     = misi.ORGANIZATION_ID
     and msl.INVENTORY_ITEM_ID                   = misi.INVENTORY_ITEM_ID
     and msl.SUBINVENTORY_CODE                   = misi.SECONDARY_INVENTORY
     and mil.ORGANIZATION_ID                     = msl.ORGANIZATION_ID
     and mil.INVENTORY_LOCATION_ID               = msl.SECONDARY_LOCATOR
     and nvl(mil.DISABLE_DATE,sysdate+1)         > sysdate
  ) x
  group by x.organization_id
         , x.inventory_item_id
         , x.subinventory_code
         , x.locator_id
  ';
  -- /*LPN Status Project*/
  g_pick_base_serial_detail              LONG
  := '
   select  msn.current_organization_id organization_id
    ,msn.inventory_item_id
    ,msn.revision
    ,msn.lot_number
    ,lot.expiration_date lot_expiration_date
    ,msn.current_subinventory_code subinventory_code
    ,msn.current_locator_id locator_id
    ,msn.cost_group_id
    ,msn.status_id   --added status_id
    ,msn.serial_number
    ,msn.initialization_date date_received
    ,1 primary_quantity
    ,null secondary_quantity                            -- new
    ,lot.grade_code grade_code                          -- new
    ,sub.reservable_type
    ,nvl(loc.reservable_type,1)  locreservable          -- Bug 6719290
    ,nvl(lot.reservable_type,1)  lotreservable          -- Bug 6719290
    ,nvl(loc.pick_uom_code, sub.pick_uom_code) uom_code
    ,WMS_Rule_PVT.GetConversionRate(
         nvl(loc.pick_uom_code, sub.pick_uom_code)
        ,msn.current_organization_id
        ,msn.inventory_item_id) conversion_rate
    ,msn.lpn_id lpn_id
    ,loc.project_id project_id
    ,loc.task_id task_id
          ,NULL locator_inventory_item_id
          ,NULL empty_flag
          ,NULL location_current_units
   from  mtl_serial_numbers msn
    ,mtl_secondary_inventories sub
    ,mtl_item_locations loc
    ,mtl_lot_numbers lot
   where msn.current_status = 3
      and decode(g_unit_number, ''-9999'', ''a'', ''-7777'', nvl(msn.end_item_unit_number, ''-7777''), msn.end_item_unit_number) =
      decode(g_unit_number, ''-9999'', ''a'', g_unit_number)
      and (msn.group_mark_id IS NULL or msn.group_mark_id = -1)
      --and (g_detail_serial IN ( 1,2)
        and ( g_detail_any_serial = 2   or   (g_detail_any_serial = 1
            and g_from_serial_number <= msn.serial_number
            and lengthb(g_from_serial_number) = lengthb(msn.serial_number)
            and g_to_serial_number >=  msn.serial_number
            and lengthb(g_to_serial_number) = lengthb(msn.serial_number))
             or ( g_from_serial_number is null or g_to_serial_number is null)
          )
      and sub.organization_id = msn.current_organization_id
      and sub.secondary_inventory_name = msn.current_subinventory_code
      and loc.organization_id (+)= msn.current_organization_id
      and loc.inventory_location_id (+)= msn.current_locator_id
      and lot.organization_id (+)= msn.current_organization_id
      and lot.inventory_Item_id (+)= msn.inventory_item_id
      and lot.lot_number (+)= msn.lot_number
     ';

 /*LPN Status Project*/
  g_pick_base_serial              LONG
        := '
         select  msn.current_organization_id organization_id
          ,msn.inventory_item_id
          ,msn.revision
          ,msn.lot_number
          ,lot.expiration_date lot_expiration_date
          ,msn.current_subinventory_code subinventory_code
          ,msn.current_locator_id locator_id
          ,msn.cost_group_id
	   ,msn.status_id   --added status_id
          ,msn.serial_number
          ,msn.initialization_date date_received
          ,1 primary_quantity
          ,null secondary_quantity                            -- new
          ,lot.grade_code grade_code                          -- new
          ,sub.reservable_type
          ,nvl(loc.reservable_type,1)  locreservable          -- Bug 6719290
          ,nvl(lot.reservable_type,1)  lotreservable          -- Bug 6719290
          ,nvl(loc.pick_uom_code, sub.pick_uom_code) uom_code
          ,WMS_Rule_PVT.GetConversionRate(
               nvl(loc.pick_uom_code, sub.pick_uom_code)
              ,msn.current_organization_id
              ,msn.inventory_item_id) conversion_rate
          ,msn.lpn_id lpn_id
          ,loc.project_id project_id
          ,loc.task_id task_id
                ,NULL locator_inventory_item_id
                ,NULL empty_flag
                ,NULL location_current_units
           from  mtl_serial_numbers msn
          ,mtl_secondary_inventories sub
          ,mtl_item_locations loc
          ,mtl_lot_numbers lot
          where msn.current_status = 3
            and decode(g_unit_number, ''-9999'', ''a'', ''-7777'', nvl(msn.end_item_unit_number, ''-7777''), msn.end_item_unit_number) =
            decode(g_unit_number, ''-9999'', ''a'', g_unit_number)
            and (msn.group_mark_id IS NULL or msn.group_mark_id = -1)
            and (g_detail_serial = 4
                OR(g_detail_any_serial = 1
             OR (g_from_serial_number <= msn.serial_number
                AND lengthb(g_from_serial_number) = lengthb(msn.serial_number)
                AND g_to_serial_number >=  msn.serial_number
                      AND lengthb(g_to_serial_number) = lengthb(msn.serial_number)
                )))
            and sub.organization_id = msn.current_organization_id
            and sub.secondary_inventory_name = msn.current_subinventory_code
            and loc.organization_id (+)= msn.current_organization_id
            and loc.inventory_location_id (+)= msn.current_locator_id
            and lot.organization_id (+)= msn.current_organization_id
            and lot.inventory_Item_id (+)= msn.inventory_item_id
            and lot.lot_number (+)= msn.lot_number
             ';
 -------------------------------------------------
/*LPN Status Project*/
 --- Added the following query to validate the serial status inside the rules package
   g_pick_base_serial_v              LONG
   := '
    select  msn.current_organization_id organization_id
     ,msn.inventory_item_id
     ,msn.revision
     ,msn.lot_number
     ,lot.expiration_date lot_expiration_date
     ,msn.current_subinventory_code subinventory_code
     ,msn.current_locator_id locator_id
     ,msn.cost_group_id
     ,msn.status_id	--added status_id
     ,msn.serial_number
     ,msn.initialization_date date_received
     ,1 primary_quantity
     ,null secondary_quantity                            -- new
     ,lot.grade_code grade_code                          -- new
     ,sub.reservable_type
     ,nvl(loc.reservable_type,1)   locreservable                -- Bug 6719290
     ,nvl(lot.reservable_type,1)   lotreservable                -- Bug 6719290
     ,nvl(loc.pick_uom_code, sub.pick_uom_code) uom_code
     ,WMS_Rule_PVT.GetConversionRate(
          nvl(loc.pick_uom_code, sub.pick_uom_code)
         ,msn.current_organization_id
         ,msn.inventory_item_id) conversion_rate
     ,msn.lpn_id lpn_id
     ,loc.project_id project_id
     ,loc.task_id task_id
           ,NULL locator_inventory_item_id
           ,NULL empty_flag
           ,NULL location_current_units
      from  mtl_serial_numbers msn
     ,mtl_secondary_inventories sub
     ,mtl_item_locations loc
     ,mtl_lot_numbers lot
    where msn.current_status = 3
       and decode(g_unit_number, ''-9999'', ''a'', ''-7777'', nvl(msn.end_item_unit_number, ''-7777''), msn.end_item_unit_number) =
       decode(g_unit_number, ''-9999'', ''a'', g_unit_number)
       and (msn.group_mark_id IS NULL or msn.group_mark_id = -1)
       and (g_detail_serial = 3
           OR(g_detail_any_serial = 1
        OR (g_from_serial_number <= msn.serial_number
           AND lengthb(g_from_serial_number) = lengthb(msn.serial_number)
           AND g_to_serial_number >=  msn.serial_number
                 AND lengthb(g_to_serial_number) = lengthb(msn.serial_number)
           )))
       and sub.organization_id = msn.current_organization_id
       and sub.secondary_inventory_name = msn.current_subinventory_code
       and loc.organization_id (+)= msn.current_organization_id
       and loc.inventory_location_id (+)= msn.current_locator_id
       and lot.organization_id (+)= msn.current_organization_id
       and lot.inventory_Item_id (+)= msn.inventory_item_id
       and lot.lot_number (+)= msn.lot_number
       and inv_detail_util_pvt.is_serial_trx_allowed(
                                        g_transaction_type_id
                                        ,msn.current_organization_id
                                        ,msn.inventory_item_id
                                        ,msn.status_id) = ''Y'' ';
 /*LPN Status Project*/
 -- Bug #3697741 modified the base query to get the project_id and task_id from mtl_inventory_locations
  g_pick_base_lpn_only   CONSTANT LONG
        := '
   select  x.organization_id
          ,x.inventory_item_id
          ,x.revision
          ,x.lot_number
          ,lot.expiration_date lot_expiration_date
          ,x.subinventory_code
          ,sub.reservable_type
	  ,nvl(x.reservable_type,1) locreservable             -- Bug 6719290
	  ,nvl(lot.reservable_type,1) lotreservable           -- Bug 6719290
          ,x.locator_id
          ,x.cost_group_id
	  ,x.status_id		--added status_id
          ,x.date_received date_received
          ,x.primary_quantity primary_quantity
          ,x.secondary_quantity       secondary_quantity            -- new
          ,lot.grade_code             grade_code                    -- new
          ,x.lpn_id lpn_id
          ,x.project_id project_id
          ,x.task_id task_id
     from
          (SELECT
             moq.organization_id
            ,moq.inventory_item_id
            ,moq.revision
            ,moq.lot_number
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.cost_group_id
	    ,moq.status_id		--added status_id
	    ,mils.reservable_type                                  -- Bug 6719290
            ,min(NVL(moq.orig_date_received,
                 moq.date_received)) date_received
            ,sum(moq.primary_transaction_quantity) primary_quantity
            ,sum(moq.secondary_transaction_quantity) secondary_quantity   -- new
            ,moq.lpn_id lpn_id
            ,mils.project_id project_id
            ,mils.task_id task_id
          FROM
              mtl_onhand_quantities_detail  moq
            , mtl_item_locations            mils
          WHERE
               moq.organization_id = g_organization_id
           AND moq.inventory_item_id = g_inventory_item_id
           AND moq.organization_id = mils.organization_id
           AND moq.subinventory_code = mils.subinventory_code
           AND moq.locator_id = mils.inventory_location_id
           AND moq.lpn_id IS NOT NULL
           AND NOT EXISTS(
                select lpn_id
                from wms_license_plate_numbers wlpn1
                where wlpn1.parent_lpn_id = moq.lpn_id)
           AND
               1 = (select count(distinct(moq1.inventory_item_id))
               from mtl_onhand_quantities_detail moq1
               where   moq1.organization_id = moq.organization_id
                    and moq1.subinventory_code = moq.subinventory_code
                    and moq1.locator_id = moq.locator_id
                    and moq1.lpn_id = moq.lpn_id)
           GROUP BY
               moq.organization_id, moq.inventory_item_id
	      ,moq.date_received --bug 6648984
              ,moq.revision, moq.lot_number
              ,moq.subinventory_code, moq.locator_id   --added status_id
              ,moq.cost_group_id,moq.status_id,mils.reservable_type,moq.lpn_id       -- Bug 6719290
              ,mils.project_id, mils.task_id
	   HAVING
	       sum(moq.primary_transaction_quantity) > 0 -- high volume project 8546026
          ) x
          ,mtl_secondary_inventories sub
          ,mtl_lot_numbers lot
    where
--      x.primary_quantity > 0 and  -- high volume project 8546026
          x.organization_id = sub.organization_id
      and x.subinventory_code = sub.secondary_inventory_name
      and x.organization_id = lot.organization_id (+)
      and x.inventory_item_id = lot.inventory_item_id (+)
      and x.lot_number = lot.lot_number (+)
';
 /*LPN Status Project*/
-- Bug #3697741 modified the base query to get the project_id and task_id from mtl_inventory_locations
-- LG convergence, for this bug, an item is not locator controlled may not have
-- any records in mils. so the join will fail. put decode and outter join
-- need to talk to grao about this.
  g_pick_base_lpn_loose  CONSTANT LONG
        := '
   select  x.organization_id
          ,x.inventory_item_id
          ,x.revision
          ,x.lot_number
          ,lot.expiration_date lot_expiration_date
          ,x.subinventory_code
          ,sub.reservable_type
	  ,nvl(x.reservable_type,1)   locreservable                          -- Bug 6719290
	  ,nvl(lot.reservable_type,1) lotreservable                          -- Bug 6719290
          ,x.locator_id
          ,x.cost_group_id
	  ,x.status_id		--added status_id
          ,x.date_received date_received
          ,x.primary_quantity primary_quantity
          ,x.secondary_quantity       secondary_quantity            -- new
          ,lot.grade_code             grade_code                    -- new
          ,x.lpn_id lpn_id
          ,x.project_id project_id
          ,x.task_id task_id
     from
          (SELECT
             moq.organization_id
            ,moq.inventory_item_id
            ,moq.revision
            ,moq.lot_number
            ,moq.subinventory_code
            ,moq.locator_id
            ,moq.cost_group_id
	    ,moq.status_id		--added status_id
	    ,mils.reservable_type                                  -- Bug 6719290
            ,min(NVL(moq.orig_date_received,
                 moq.date_received)) date_received
            ,sum(moq.primary_transaction_quantity) primary_quantity
            ,sum(moq.secondary_transaction_quantity) secondary_quantity   -- new
            ,moq.lpn_id lpn_id
            ,decode(mils.project_id, mils.project_id, moq.project_id) project_id
            ,decode(mils.task_id, mils.task_id, moq.task_id) task_id
          FROM
            mtl_onhand_quantities_detail moq,mtl_item_locations mils
          WHERE
               moq.organization_id = g_organization_id
           AND moq.inventory_item_id = g_inventory_item_id
           AND moq.organization_id = mils.organization_id (+)
           AND moq.subinventory_code = mils.subinventory_code (+)
           AND moq.locator_id = mils.inventory_location_id (+)
          GROUP BY
               moq.organization_id, moq.inventory_item_id
	      ,moq.date_received --bug 6648984
              ,moq.revision, moq.lot_number
              ,moq.subinventory_code, moq.locator_id		--added status_id
              ,moq.cost_group_id,moq.status_id, mils.reservable_type, moq.lpn_id         -- Bug 6719290
              ,decode(mils.project_id, mils.project_id, moq.project_id)
              ,decode(mils.task_id, mils.task_id, moq.task_id)
	  HAVING
	       sum(moq.primary_transaction_quantity) > 0 -- high volume project 8546026
          ) x
          ,mtl_secondary_inventories sub
          ,mtl_lot_numbers lot
    where
--    x.primary_quantity > 0 and   -- high volume project 8546026
          x.organization_id = sub.organization_id
      and x.subinventory_code = sub.secondary_inventory_name
      and x.organization_id = lot.organization_id (+)
      and x.inventory_item_id = lot.inventory_item_id (+)
      and x.lot_number = lot.lot_number (+)
';
  g_pick_base                     LONG;
  --
  g_base_table_alias              wms_db_objects.table_alias%TYPE;
  g_input_table_alias             wms_db_objects.table_alias%TYPE;
  g_base_select                   LONG;
  g_base_group_by                 LONG;
  g_rule_select                   LONG;
  g_rule_select_serial            LONG;
  g_rule_group_by                 LONG;
  g_base_from                     LONG;
  g_base_from_serial              LONG; --used if item is lot controlled
  g_base_from_serial_v            LONG; --used for serial controlled item / Validation required
  g_base_from_serial_detail       LONG; -- New
  g_rule_from                     LONG;
  g_input_where                   LONG;
  g_rule_where                    LONG;
  g_rule_order                    LONG;
  g_stmt                          LONG;
  g_stmt_task_type                LONG; --used for task type assignment  TTA
  g_stmt_serial                   LONG;
  g_stmt_serial_validate          LONG;
  g_stmt_serial_detail            LONG;
  g_stmt_serial_detail_new        LONG;
  g_build_package_row             NUMBER;
  g_build_package_tbl             DBMS_SQL.varchar2s;
  g_default_pick_task_type_id     NUMBER;
  g_default_putaway_task_type_id  NUMBER;
  g_default_cc_task_type_id       NUMBER;
  g_default_repl_task_type_id     NUMBER;
  g_default_moxfer_task_type_id   NUMBER;
  g_default_moissue_task_type_id  NUMBER;
  g_default_operation_plan_id     NUMBER;
  g_current_organization_id       NUMBER;
  --
  g_line_feed            CONSTANT VARCHAR2(1)                                             := '
';
  --global values for allocation mode
  g_alloc_lpn_only                NUMBER                                                  := 1;
  g_alloc_lpn_loose               NUMBER                                                  := 2;
  g_alloc_no_lpn                  NUMBER                                                  := 3;
  g_alloc_pick_uom                NUMBER                                                  := 4;

  -- Added for R12.1 Replenishment Project - 6681109
  g_alloc_strict_pick_uom         NUMBER                                                  := 5;

  --Used for storing both the current record being dealt with and a
  -- a variety of stored records.  This represents a single row returned
  -- by the FetchCursor function, which gets the row from the Rule.
  -- This records are stored in an array, but are accessed like linked
  -- lists.  Each record contains the index of the next record
  -- that should be looked at (next_rec).
  TYPE t_location_rec IS RECORD(
    revision                      wms_transactions_temp.revision%TYPE
  , lot_number                    wms_transactions_temp.lot_number%TYPE
  , lot_expiration_date           wms_transactions_temp.lot_expiration_date%TYPE
  , subinventory_code             wms_transactions_temp.from_subinventory_code%TYPE
  , locator_id                    wms_transactions_temp.from_locator_id%TYPE
  , cost_group_id                 wms_transactions_temp.from_cost_group_id%TYPE
  , uom_code                      VARCHAR2(3)
  , lpn_id                        NUMBER
  , serial_number                 VARCHAR2(30)
  , quantity                      wms_transactions_temp.primary_quantity%TYPE
  , secondary_quantity            wms_transactions_temp.secondary_quantity%TYPE
  , grade_code                    wms_transactions_temp.grade_code%TYPE
  , secondary_uom_code            VARCHAR2(3)
  , consist_string                VARCHAR2(1000)
  , order_by_string               VARCHAR2(1000)
  , next_rec                      NUMBER);

  TYPE t_location_table IS TABLE OF t_location_rec
    INDEX BY BINARY_INTEGER;

  --these arrays store location recs in sequential order. However, when
  -- the records are read from the array, they are read in the order
  -- dictated by the pointer in the location_rec (next_rec)
  g_locs                          t_location_table; -- array of all locators read from cursor
  g_locs_index                    NUMBER                                                  := 0;

  -- Bug 8247123: Table to keep track of secondary qty to be allocated,
  -- per reservation.  RESERVATION_ID is used as the index.
  -- Added for bug 8665496
  TYPE t_qty_tbl IS TABLE OF NUMBER INDEX BY LONG;
  g_sec_alloc_qty                 t_qty_tbl;

  -- Added for bug 8665496 - to track qty to be allocated per reservation.
  g_alloc_qty                     t_qty_tbl;

  -- This record is used to store information about a consistency group.
  -- A consistency group consists of all records which share the same
  -- consist_string.  The consist_string is the concatenation of each
  -- record's values for the columns which are defined as a rule's
  -- consistencies.  For example, if a rule's consistency restrictions
  -- are lot number and locator_id, then the consist string would
  -- lot_number||locator_id.  Each record could have different
  -- values for the consist string, like LOTA123, or LOTB1000.
  -- For creating pick suggestions for rules that have consistency
  -- restrictions, we need to keep track of the quantity available
  -- for each consistency group.
  -- 2/26/02
  -- Group record altered to support LPNs
  TYPE t_group_rec IS RECORD(
    consist_string                VARCHAR2(1000)
  , lpn_id                        NUMBER
  , quantity                      NUMBER
  , total_quantity                NUMBER
  , secondary_quantity            NUMBER                               -- new
  , secondary_total_quantity      NUMBER                               -- new
  , grade_code                    VARCHAR2(150)                        -- new
  , order_by_rank                 NUMBER
  , first_rec                     NUMBER
  , last_rec                      NUMBER
  , prev_group                    NUMBER
  , next_group                    NUMBER
  , prev_consist_lpn_id           NUMBER
  , next_consist_lpn_id           NUMBER
  , parent_consist_group          NUMBER);

  TYPE t_group_table IS TABLE OF t_group_rec
    INDEX BY BINARY_INTEGER;

  g_consists                      t_group_table;
  g_lpns                          t_group_table;
  g_first_order_by_rank           NUMBER                                                  := NULL;
  g_first_consist_group           NUMBER                                                  := 0;
  g_last_consist_group            NUMBER;
  g_first_lpn_group               NUMBER;
  g_last_lpn_group                NUMBER;
  g_trace_recs                    wms_search_order_globals_pvt.pre_suggestions_record_tbl;

  PROCEDURE FetchCursorRows(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_cursor              IN            wms_rule_pvt.cv_pick_type
  , p_rule_id             IN            NUMBER
  );

  -- =============================================
  -- Procedure to log message for Label Printing
  -- =============================================
  PROCEDURE TRACE(p_message IN VARCHAR2) IS
  BEGIN
    inv_log_util.TRACE(p_message, 'RULE_ENGINE', 4);
  END TRACE;

  --Procedures for logging messages
  PROCEDURE log_event(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
   /* fnd_log.STRING(log_level => fnd_log.level_event, module => l_module, message => p_message);
    inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_message); */
  END log_event;

  PROCEDURE log_error(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9); /*
    fnd_log.STRING(log_level => fnd_log.level_error, module => l_module, message => p_message);
    inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_message); */
  END log_error;

  PROCEDURE log_error_msg(p_api_name VARCHAR2, p_label VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace('err:', l_module, 9); /*
    fnd_log.message(log_level => fnd_log.level_error, module => l_module, pop_message => FALSE);
    inv_log_util.trace('err:', l_module, 9);
    gmi_reservation_util.println(p_label); */
  END log_error_msg;

  PROCEDURE log_procedure(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);/*
    fnd_log.STRING(log_level => fnd_log.level_procedure, module => l_module, message => p_message);
    inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_message); */
  END log_procedure;

  PROCEDURE log_statement(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);/*
    fnd_log.STRING(log_level => fnd_log.level_statement, module => l_module, message => p_message);
    inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_label||' '||p_message);*/
  END log_statement;
  ----
  ---- Function to check if Restriction , Sort-criteria and Consistency was defined for a given picking rule
  ---- using serial object

  FUNCTION IsSerialObjectUsed( p_organization_id  NUMBER )
  RETURN BOOLEAN IS
  l_serial_object_used          NUMBER ;
  BEGIN
    /* Trace( ' Start IsSerialObjectUsed');
     Trace( ' Start IsSerialObjectUsed p_organization_id '|| to_char(p_organization_id));
     Trace( ' Start IsSerialObjectUsed g_serial_objects_used ' || to_char( g_serial_objects_used));
     */

    l_serial_object_used  := 0 ;
  IF ( wms_rule_pvt.g_serial_objects_used IS NULL )   THEN
     --Trace( ' IsSerialObjectUsed -- If condition is true ');
     SELECT count( DISTINCT p.object_id)
       INTO l_serial_object_used
       FROM wms_selection_criteria_txn wsc,
            wms_strategies_b wsb,
            wms_strategy_members wsm,
            wms_rules_b wrb,
            wms_restrictions r,
            wms_sort_criteria s,
            wms_rule_consistencies c,
            wms_parameters_b p
      WHERE wsc.rule_type_code = 2
        AND wsc.enabled_flag = 1
        AND wsc.return_type_code = 'S'
        AND wsc.from_organization_id = p_organization_id
        AND wsc.return_type_id = wsb.strategy_id
        AND wsb.strategy_id = wsm.strategy_id
        AND wsm.rule_id = wrb.rule_id
        AND (
             ( wrb.rule_id = r.rule_id AND ((r.parameter_id = p.parameter_id ) OR (r.operand_parameter_id = p.parameter_id)))
                OR (wrb.rule_id = s.rule_id AND s.parameter_id = p.parameter_id)                OR (wrb.rule_id = c.rule_id AND c.parameter_id = p.parameter_id)              )
        AND wrb.organization_id IN (p_organization_id, -1)
        AND p.object_id = 26; --- 26 is Serial object

        wms_rule_pvt.g_serial_objects_used := l_serial_object_used;

        --Trace( ' IsSerialObjectUsed -- l_serial_object_used ' || wms_rule_pvt.g_serial_object_used);
  ELSE
    l_serial_object_used  := wms_rule_pvt.g_serial_objects_used;
  END IF;

  If l_serial_object_used  >= 1  THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

  EXCEPTION WHEN OTHERS THEN
     RETURN FALSE;
  END IsSerialObjectUsed;

  --
  -- Name        : FreeGlobals
  -- Function    : Initializes global variables.
  -- Notes       : privat procedure for internal use only
  --
  PROCEDURE freeglobals IS
  BEGIN
    g_base_select         := NULL;
    g_rule_select         := NULL;
    g_rule_select_serial  := NULL;
    g_base_from           := NULL;
    g_base_from_serial    := NULL;
    g_base_from_serial_v  := NULL;
    g_base_from_serial_detail := NULL;
    g_rule_from           := NULL;
    g_input_where         := NULL;
    g_rule_where          := NULL;
    g_rule_order          := NULL;
    g_base_group_by       := NULL;
    g_rule_group_by       := NULL;
    g_stmt                := NULL;
    g_stmt_serial         := NULL;
    g_stmt_serial_detail  := NULL;
    g_stmt_serial_detail_new  := NULL;
    g_pick_base           := NULL;
    -- clean up the serial number detailing table
    -- Commenting out for Bug 5251221
    --inv_detail_util_pvt.init_output_serial_rows;
    -- clean up the bind variables table
    inv_sql_binding_pvt.initbindtables;
  END freeglobals;

  ----
  ----

  --------------
  --- Build Rules List
  ---  Generate all static rule list package  for diffrent rule types.
  ---- Total of  15 packages will be generated
  ---- WMS_RULE_PICK_PKG, WMS_RULE_PICK_PKG1, WMS_RULE_PICK_PKG2
  PROCEDURE buildrulespkg(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    l_rule_id       NUMBER;
    l_error_string  VARCHAR2(240);
  BEGIN

    --
    -- kkoothan  Bug Fix:2561401
    -- Initialized the value of X_RETURN_STATUS to Success
    -- at the start of the procedure and set its value accordingly
    -- when the procedure returns Failure/Error.
    --
    X_RETURN_STATUS := fnd_api.g_ret_sts_success;

    --- Updates  the table wms_rule_list_package ,
    --- for all rule type package counter with value 3
    --- so that all three "rules list packages" for all type of
    ----Rules will be generated.

    UPDATE wms_rule_list_package
       SET package_name_count = 3;

    wms_rule_gen_pkgs.generateruleexecpkgs(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_true
    , p_validation_level           => fnd_api.g_valid_level_full
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_pick_code                  => 2
    , p_put_code                   => 1
    , p_task_code                  => 3
    , p_label_code                 => 4
    , p_cg_code                    => 5
    , p_op_code                    => 7
    , p_pkg_type                   => 'B'
    );

    IF (l_return_status = fnd_api.g_ret_sts_success) THEN
      FND_FILE.put_line(FND_FILE.LOG, 'Success from GenerateRuleExecPkgs');
    ELSE
      FND_FILE.put_line(FND_FILE.LOG, 'Error from GenerateRuleExecPkgs:');
      X_RETURN_STATUS :=  fnd_api.g_ret_sts_error; -- Expected Error
      retcode  := 1;

      FOR i IN 1 .. l_msg_count LOOP
        --fnd_file.put_line(fnd_file.LOG, 'Error:');
        l_error_string  := fnd_message.get;
        --fnd_file.put_line(fnd_file.LOG, l_error_string);
        errbuf          := errbuf || ' Error: GenerateRuleExecPkgs ' || l_error_string;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := fnd_api.g_ret_sts_unexp_error; -- Unexpecetd Error
      retcode  := 2;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'BuildRulePkg');
      END IF;

      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      --fnd_file.put_line(fnd_file.LOG, 'Exception');
      --fnd_file.put_line(fnd_file.LOG, l_msg_data);
      errbuf   := errbuf || 'Error in BuildRulesPkg:' || l_msg_data;
  END buildrulespkg;

  --
  -- Name        : GetConversionRate
  -- Function    : Finds the conversion rate between the given UOM and
  --    the base UOM of the class which contains the
  --    item's primary UOM. Support interclass and intraclass
  --    conversions.
  -- Notes       : private procedure for internal use only;
  --               Similar to inv_convert.inv_um_converstion, but no
  --     Used to order locations returned from rule package
  FUNCTION getconversionrate(p_uom_code VARCHAR2, p_organization_id NUMBER, p_inventory_item_id NUMBER)
    RETURN NUMBER IS
    l_conversion_rate NUMBER;
    l_from_class      VARCHAR2(10);
    l_to_class        VARCHAR2(10);
    l_class_rate      NUMBER;

    --get conversion rate between given uom and that uom class's
    -- base uom
    CURSOR c_conversion_rate IS
      SELECT   conversion_rate
             , uom_class
          FROM mtl_uom_conversions
         WHERE uom_code = p_uom_code
           AND inventory_item_id IN (p_inventory_item_id, 0)
           AND NVL(disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE)
      ORDER BY inventory_item_id DESC;

    -- find the uom class for the item's primary uom
    CURSOR c_primary_uom_class IS
      SELECT uom_class
        FROM mtl_units_of_measure muom, mtl_system_items msi
       WHERE msi.organization_id = p_organization_id
         AND msi.inventory_item_id = p_inventory_item_id
         AND muom.uom_code = msi.primary_uom_code;

    -- find the conversion rate between the base uoms of two classes
    CURSOR c_class_conversion_rate IS
      SELECT   conversion_rate
          FROM mtl_uom_class_conversions
         WHERE from_uom_class = l_from_class
           AND to_uom_class = l_to_class
           AND inventory_item_id IN (p_inventory_item_id, 0)
           AND NVL(disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE)
      ORDER BY inventory_item_id DESC;
  BEGIN
    IF (p_uom_code IS NULL) THEN
      RETURN 0;
    END IF;

    IF (nvl(g_gcr_organization_id,-1) = p_organization_id
      AND nvl(g_gcr_inventory_item_id,-1) = p_inventory_item_id
      AND nvl(g_gcr_uom_code,'-1') = p_uom_code) THEN
      l_conversion_rate := g_gcr_conversion_rate;
    ELSE
      OPEN c_conversion_rate;
      --Cursor returns 0, 1, or 2 records
      -- Because the results are ordered by item_id desc, the results
      -- are also ordered from specific (item_Id > 0) to default (item_id = 0);
      --So, we only have to fetch one record
      FETCH c_conversion_rate INTO l_conversion_rate, l_to_class;

      IF (c_conversion_rate%NOTFOUND) THEN
        --don't raise error. Instead, just return 1
        l_conversion_rate  := 0;
      END IF;

      CLOSE c_conversion_rate;

      IF l_conversion_rate <> 0 THEN
        OPEN c_primary_uom_class;
        FETCH c_primary_uom_class INTO l_from_class;

        IF (c_primary_uom_class%NOTFOUND) THEN
          l_from_class       := NULL;
          l_conversion_rate  := 0;
        END IF;

        CLOSE c_primary_uom_class;

        -- check to see if interclass conversion - if so, get conversion
        -- between 2 classes
        IF  l_from_class IS NOT NULL
            AND l_to_class IS NOT NULL
            AND l_from_class <> l_to_class THEN
          OPEN c_class_conversion_rate;
          FETCH c_class_conversion_rate INTO l_class_rate;

          IF c_class_conversion_rate%NOTFOUND THEN
            l_class_rate  := 0;
          END IF;

          l_conversion_rate  := l_conversion_rate * l_class_rate;
        END IF;
      END IF;
      g_gcr_organization_id := p_organization_id;
      g_gcr_inventory_item_id := p_inventory_item_id;
      g_gcr_uom_code := p_uom_code;
      g_gcr_conversion_rate := l_conversion_rate;
    END IF;

    RETURN l_conversion_rate;
  END getconversionrate;

  --
  -- Name        : BuildBaseSQL
  -- Function    : Builds the base part of a pick or put away rule representing
  --               dynamic SQL cursor text.
  -- Notes       : privat procedure for internal use only
  --
  PROCEDURE buildbasesql(
    x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_type_code          IN            NUMBER
  , p_allocation_mode_id IN            NUMBER
  ) IS
    l_api_name             VARCHAR2(30)                      := 'BuildBaseSQL';
    l_return_status        VARCHAR2(1)                       := fnd_api.g_ret_sts_success;
    --
    -- variables needed for dynamic SQL
    l_identifier           VARCHAR2(10);
    -- variables for the base and input representing DB objects
    l_input_table_name     wms_db_objects.table_name%TYPE;
    l_type_dependent_alias wms_db_objects.table_alias%TYPE;

    --
    -- cursor for the base and input representing DB objects
    CURSOR baseinp IS
      SELECT wdo1.table_alias
           , wdo2.table_name
           , wdo2.table_alias
        FROM wms_db_objects wdo1, wms_db_objects wdo2
       WHERE wdo1.db_object_id = 1
         AND wdo2.db_object_id = 2;
  --
  BEGIN
    --
    -- Initialize API return status to success
    x_return_status     := fnd_api.g_ret_sts_success;

    --
    -- debugging portion
    -- can be commented ut for final code
    log_procedure(l_api_name, 'start', 'Start BuildBaseSql');
    log_statement(l_api_name, 'type_code', 'type_code: ' || p_type_code);
    -- end of debugging section
    --


    -- get names and aliases of the base and input representing DB objects
    OPEN baseinp;
    FETCH baseinp INTO g_base_table_alias, l_input_table_name, g_input_table_alias;

    IF baseinp%NOTFOUND THEN
      CLOSE baseinp;
      log_statement(l_api_name, 'no_base_input', 'No base input found');
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE baseinp;

    --
    -- Build 'select' skeleton
    IF p_type_code = 1 THEN -- put away:
      l_type_dependent_alias  := g_input_table_alias; -- rev and lot from input
    ELSIF p_type_code = 2 THEN -- pick:
      l_type_dependent_alias  := g_base_table_alias; -- rev and lot from basis
    END IF;

    --
    --2/21/02 - remove all columns but sub and loc from picking query
    IF p_type_code = 2 THEN
      g_base_select  :=    l_type_dependent_alias
                        || '.REVISION'
                        || g_line_feed
                        || ','
                        || l_type_dependent_alias
                        || '.LOT_NUMBER'
                        || g_line_feed
                        || ','
                        || l_type_dependent_alias
                        || '.LOT_EXPIRATION_DATE'
                        || g_line_feed
                        || ','
                        || g_base_table_alias
                        || '.SUBINVENTORY_CODE'
                        || g_line_feed
                        || ','
                        || g_base_table_alias
                        || '.LOCATOR_ID'
                        || g_line_feed;
    ELSE
      g_base_select  := g_base_table_alias
                       || '.SUBINVENTORY_CODE'
                       || g_line_feed || ','
                       || g_base_table_alias
                       || '.LOCATOR_ID'
                       || g_line_feed;
    END IF;

    -- added to suport PJM
    IF p_type_code = 1 THEN
      g_base_select  := g_base_select
                       || ','
                       || g_base_table_alias
                       || '.PROJECT_ID'
                       || g_line_feed;
      g_base_select  := g_base_select
                       || ','
                       || g_base_table_alias
                       || '.TASK_ID'
                       || g_line_feed;
    END IF;

    --added to support Picking by UOM.
    --UOM only matters in picking
    IF p_type_code = 2 THEN --pick
      g_base_select  := g_base_select
                       || ','
                       || g_base_table_alias
                       || '.COST_GROUP_ID'
                       || g_line_feed;
      g_base_select  := g_base_select
                       || ','
                       || g_base_table_alias
                       || '.UOM_CODE'
                       || g_line_feed;

      IF p_allocation_mode_id IN (g_alloc_lpn_only, g_alloc_lpn_loose) THEN
        g_base_select  := g_base_select
                       || ','
                       || g_base_table_alias
                       || '.LPN_ID'
                       || g_line_feed;
      ELSE
        g_base_select  := g_base_select
                       || ',decode(g_lpn_id, -9999, NULL, g_lpn_id) LPN_ID'
                       || g_line_feed;
      END IF;
    /* 2/21/02 - no longer need these args, since put and pick packages
     * are not build differently
     * else  --put away
     *  --for put, get cost group from wms_transactions_temp,
     *  --  not input table (wms_trx_details_tmp_v)
     *  g_base_select := g_base_select ||',NULL cost_group_id'
     *                                 || g_line_feed;
     *  g_base_select := g_base_select ||',NULL uom_code'
     *                                 || g_line_feed;
     */
    END IF;

    --
    -- Build type code independent 'from' skeleton
    g_base_from                 := l_input_table_name || ' ' || g_input_table_alias || g_line_feed;
    g_base_from_serial          := l_input_table_name || ' ' || g_input_table_alias || g_line_feed;
    g_base_from_serial_v        := l_input_table_name || ' ' || g_input_table_alias || g_line_feed;
    g_base_from_serial_detail   := l_input_table_name || ' ' || g_input_table_alias || g_line_feed;

    --
    -- Add type code dependent part to 'from' skeleton
    -- We need to build 9 different putaway cursors using 3 different put
    -- bases.  So, here we insert a place holder (:g_put_base) which we will
    -- replace in GenerateRulePackage with the appropriate base
    IF p_type_code = 1 THEN -- put away
      g_base_from  := g_base_from || ',(:g_put_base)' || g_base_table_alias || g_line_feed;
    ELSIF p_type_code = 2 THEN -- pick
      --need to generate 2 pick bases - one for non-serial controlled,
      --and one for serial control, since we won't know whether
      -- the inventory item is serial controlled until the stored
      -- procedure is run.
      IF p_allocation_mode_id = g_alloc_lpn_only THEN
        g_pick_base  := g_pick_base_lpn_only;
      ELSIF p_allocation_mode_id = g_alloc_lpn_loose THEN
        g_pick_base  := g_pick_base_lpn_loose;
      ELSE
        /**
         *Bug 2310403
         *Errors allocating for LPN putaway move orders.
         *The problem occurs because we should only pick material
         *from a certain LPN, but the base returned by build_sql
         *does not have an LPN_ID.  So now, we'll use the lpn_loose
         *base, and add a group_by statement on the outermost query
         *so that we only get one rec per rev/lot/sub/loc when we
         *aren't allocating LPNs
               *--build non-serial controlled pick base
               *log_statement(l_api_name, 'build_sql_no_serial',
               *  'Calling inv_detail_util_pvt.build_sql for base');
               *inv_detail_util_pvt.build_sql
         *( x_return_status       => l_return_status    ,
         *  x_sql_statement       => g_pick_base
         *  );
               *IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               *  log_statement(l_api_name, 'err_build_sql',
               *      'Error in inv_detail_util_pvt.build_sql');
               *  RAISE fnd_api.g_exc_unexpected_error;
               *ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               *  log_statement(l_api_name, 'unexp_err_build_sql',
               *    'Unexp. error in inv_detail_util_pvt.build_sql');
               *  RAISE fnd_api.g_exc_error;
               *END IF;
               *log_statement(l_api_name, 'success_build_sql',
               *      'Inv_detail_util_pvt.build_sql successful');

               *-- replace the bind variables used in the base sql
               *-- with the global variables in the stored rule procedure
               *g_pick_base :=
         *   REPLACE(g_pick_base,':organization_id','g_organization_id');
               *g_pick_base :=
         *   REPLACE(g_pick_base,':inventory_item_id','g_inventory_item_id');
         */
        g_pick_base  := g_pick_base_lpn_loose;
      END IF;

	 /*LPN Status Project*/
      -- The conversion_rate (found using GetConversionRate) is used
      --  to order picking locations from largest Pick UOM to smallest.
      -- The API call to is_sub_loc_lot_trx_allowed checks the status
      --  of the subinventory, locator, and lot to make sure that we can
      --  pick from this location
      g_pick_base         :=    g_line_feed
                 || 'SELECT x.organization_id       organization_id     '
                                       || g_line_feed
                 || '  ,x.inventory_item_id         inventory_item_id   '
                                       || g_line_feed
                 || '  ,x.revision                  revision            '
                                       || g_line_feed
                 || '  ,x.lot_number                lot_number          '
                                       || g_line_feed
                 || '  ,x.lot_expiration_date       lot_expiration_date '
                                       || g_line_feed
                 || '  ,x.subinventory_code         subinventory_code   '
                 || g_line_feed
                 || '  ,x.locator_id                locator_id          '
                                       || g_line_feed
                 || '  ,x.cost_group_id             cost_group_id       '
                                       || g_line_feed
		 || '  ,x.status_id                 status_id       '   --added status_id
                              || g_line_feed
                 || '  ,NULL                        serial_number       '
                                       || g_line_feed
                 || '  ,x.lpn_id                    lpn_id              '
                                       || g_line_feed
                 || '  ,x.project_id                project_id          '
                                       || g_line_feed
                 || '  ,x.task_id                   task_id             '
                                       || g_line_feed
                 || '  ,x.date_received             date_received       '
                                       || g_line_feed
                 || '  ,x.primary_quantity          primary_quantity    '
                                       || g_line_feed
                 || '  ,x.secondary_quantity          secondary_quantity    '         -- new
                                       || g_line_feed                                 -- new
                 || '  ,x.grade_code                  grade_code            '         -- new
                                       || g_line_feed                                 -- new
                 || '  ,x.reservable_type           reservable_type     '
                                       || g_line_feed
                 || '  ,x.locreservable             locreservable '              -- Bug 6719290 Start
                                       || g_line_feed
                 || '  ,x.lotreservable             lotreservable '
                                       || g_line_feed                            -- Bug 6719290 End
                 || '  ,NVL(loc.pick_uom_code,sub.pick_uom_code) uom_code'
                                       || g_line_feed
                 || '  ,WMS_Rule_PVT.GetConversionRate(                 '
                                       || g_line_feed
                 || '       NVL(loc.pick_uom_code, sub.pick_uom_code)   '
                                       || g_line_feed
                 || '       ,x.organization_id            '
                                       || g_line_feed
                 || '       ,x.inventory_item_id) conversion_rate       '
                                       || g_line_feed
                 || '  ,NULL locator_inventory_item_id                  '
                                       || g_line_feed
                 || '  ,NULL empty_flag                                 '
                                       || g_line_feed
                 || '  ,NULL location_current_units                     '
                                       || g_line_feed
                 || 'FROM ('
                 || g_pick_base
                  --extra line feed?                  || g_line_feed
                 || '     ) x                                           '
                                       || g_line_feed
                 || '    ,mtl_secondary_inventories sub                 '
                                       || g_line_feed
                 || '    ,mtl_item_locations loc                        '
                                       || g_line_feed
                 || 'WHERE x.organization_id = loc.organization_id (+)  '
                                       || g_line_feed
                 || '   AND x.locator_id = loc.inventory_location_id (+)'
                                       || g_line_feed
                 || '   AND sub.organization_id = x.organization_id     '
                                       || g_line_feed
                 || '   AND sub.secondary_inventory_name = x.subinventory_code '
                                       || g_line_feed; /*
                 || '   AND inv_detail_util_pvt.is_sub_loc_lot_trx_allowed('
                                       || g_line_feed
                 || '       g_transaction_type_id,          '
                                       || g_line_feed
                 || '       x.organization_id,            '
                                       || g_line_feed
                 || '       x.inventory_item_id,            '
                                       || g_line_feed
                 || '       x.subinventory_code,            '
                                       || g_line_feed
                 || '       x.locator_id,             '
                                      || g_line_feed
                || '       x.lot_number)=''Y''                   '
                                      || g_line_feed;    */
      --

      -- finally apply the corrections to the basis SQL
      g_base_from         := g_base_from || ',(' || g_pick_base || ') '
                          || g_base_table_alias || g_line_feed;
      --Construct the base for the serial cursor
      g_base_from_serial  := g_base_from_serial || ',(' || g_pick_base_serial;
      g_base_from_serial_v  := g_base_from_serial_v || ',(' || g_pick_base_serial_v;
      g_base_from_serial_detail  := g_base_from_serial_detail || ',(' || g_pick_base_serial_detail;

      --need to add restrictions to serial base if we are allocating
      -- entire LPNs only
      --bug 2943552
      --  previoulsy, we were adding the new clause directly to
      --  g_pick_base_serial.  However, g_pick_base_serial is a global
      --  constant string that never gets cleared.  As a result, all
      --  subsequent serial sql statements would get this restriction.
      --  Now, we add the entire lpn only clause to g_base_from_serial.
      --bug 3064635 - after above fix, we were missing initial
      -- parantheses, because we were concatenating clause with
      -- g_pick_base_serial.  Now, we concatenate clause with
      -- g_base_from_serial
      IF p_allocation_mode_id = g_alloc_lpn_only THEN
        g_base_from_serial  := g_base_from_serial
                         || 'and msn.lpn_id IS NOT NULL
                             and not exists(
                                  select lpn_id
                                  from wms_license_plate_numbers wlpn1
                                  where wlpn1.parent_lpn_id = msn.lpn_id)
                                     and
                                        1 = (select count(distinct(moq1.inventory_item_id))
                                             from mtl_onhand_quantities_detail moq1
                                             where moq1.organization_id = msn.current_organization_id
                             and moq1.subinventory_code = msn.current_subinventory_code
                             and moq1.locator_id = msn.current_locator_id
                             and moq1.lpn_id = msn.lpn_id)
                            ';
      -- END IF;
    /* g_base_from_serial := g_base_from_serial || ')' || g_base_table_alias
                       || g_line_feed; */

    ---
    g_base_from_serial_v  :=
                   g_base_from_serial_v
                || ' and msn.lpn_id IS NOT NULL
          and not exists(
        select lpn_id
        from wms_license_plate_numbers wlpn1
        where wlpn1.parent_lpn_id = msn.lpn_id)
          and
             1 = (select count(distinct(moq1.inventory_item_id))
                   from mtl_onhand_quantities_detail moq1
                   where moq1.organization_id = msn.current_organization_id
         and moq1.subinventory_code = msn.current_subinventory_code
         and moq1.locator_id = msn.current_locator_id
         and moq1.lpn_id = msn.lpn_id)
         ';

    ---
    g_base_from_serial_detail  :=
                   g_base_from_serial_detail
                || ' and msn.lpn_id IS NOT NULL
          and not exists(
        select lpn_id
        from wms_license_plate_numbers wlpn1
        where wlpn1.parent_lpn_id = msn.lpn_id)
          and
             1 = (select count(distinct(moq1.inventory_item_id))
                   from mtl_onhand_quantities_detail moq1
                   where moq1.organization_id = msn.current_organization_id
         and moq1.subinventory_code = msn.current_subinventory_code
         and moq1.locator_id = msn.current_locator_id
         and moq1.lpn_id = msn.lpn_id)
         ';

      END IF;

        g_base_from_serial := g_base_from_serial || ')' || g_base_table_alias
                || g_line_feed;
        g_base_from_serial_v := g_base_from_serial_v || ')' || g_base_table_alias
                || g_line_feed;

        g_base_from_serial_detail := g_base_from_serial_detail || ')' || g_base_table_alias
                || g_line_feed;

    --
    END IF;

    --currently used only for serial controlled item, when you aren't
    -- detailing serial numbers
    g_base_group_by     :=    g_base_table_alias
                           || '.ORGANIZATION_ID'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.INVENTORY_ITEM_ID'
                           || g_line_feed
                           || ','
                           || l_type_dependent_alias
                           || '.REVISION'
                           || g_line_feed
                           || ','
                           || l_type_dependent_alias
                           || '.LOT_NUMBER'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.LOT_EXPIRATION_DATE'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.SUBINVENTORY_CODE'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.LOCATOR_ID'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.COST_GROUP_ID'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.PROJECT_ID'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.TASK_ID'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.UOM_CODE'
                           || g_line_feed
                           || ','                                               --new
                           || g_base_table_alias                                --new
                           || '.GRADE_CODE'                                     --new
                           || g_line_feed;                                      --new

    --
    -- group by the base lpn id only if the lpn id is in the select statement
    IF p_allocation_mode_id IN (g_alloc_lpn_only, g_alloc_lpn_loose) THEN
      g_base_group_by  := g_base_group_by || ',' || g_base_table_alias || '.LPN_ID' || g_line_feed;
    END IF;

    -- debugging portion
    -- can be commented ut for final code
    log_procedure(l_api_name, 'end', 'End BuildBaseSql');
  -- end of debugging section
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);

    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);

  END buildbasesql;

  --
  -- Name        : BuildRuleSQL
  -- Function    : Builds the rule dependent part of the rule's sql statement
  -- Notes       : private procedure for internal use only
  PROCEDURE buildrulesql(
    x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_rule_id            IN            NUMBER
  , p_type_code          IN            NUMBER
  , p_allocation_mode_id IN            NUMBER
  ) IS
    --
    l_api_name                   VARCHAR2(30)                                              := 'BuildRuleSQL';
    -- variables needed for dynamic SQL
    l_identifier                 VARCHAR2(10);
    -- other variables
    l_db_object_id               wms_db_objects.db_object_id%TYPE;
    l_table_name                 wms_db_objects.table_name%TYPE;
    l_table_alias                wms_db_objects.table_alias%TYPE;
    l_context_dependent_flag     wms_db_objects.context_dependent_flag%TYPE;
    l_parent_table_alias         wms_db_objects.table_alias%TYPE;
    l_parameter_type_code        wms_parameters_b.parameter_type_code%TYPE;
    l_column_name                wms_parameters_b.column_name%TYPE;
    l_expression                 wms_parameters_b.expression%TYPE;
    l_data_type_code             wms_parameters_b.data_type_code%TYPE;
    l_parent_parameter_type_code wms_parameters_b.parameter_type_code%TYPE;
    l_parent_column_name         wms_parameters_b.column_name%TYPE;
    l_parent_expression          wms_parameters_b.expression%TYPE;
    l_parent_data_type_code      wms_parameters_b.data_type_code%TYPE;
    l_operand_type_code          wms_restrictions.operand_type_code%TYPE;
    l_operand_constant_number    wms_restrictions.operand_constant_number%TYPE;
    l_operand_constant_character wms_restrictions.operand_constant_character%TYPE;
    l_operand_constant_date      wms_restrictions.operand_constant_date%TYPE;
    l_operand_expression         wms_restrictions.operand_expression%TYPE;
    l_operand_flex_value_set_id  wms_restrictions.operand_flex_value_set_id%TYPE;
    l_bracket_open               wms_restrictions.bracket_open%TYPE;
    l_bracket_close              wms_restrictions.bracket_close%TYPE;
    l_validation_type            fnd_flex_value_sets.validation_type%TYPE;
    l_id_column_name             fnd_flex_validation_tables.id_column_name%TYPE;
    l_value_column_name          fnd_flex_validation_tables.value_column_name%TYPE;
    l_application_table_name     fnd_flex_validation_tables.application_table_name%TYPE;
    l_additional_where_clause    fnd_flex_validation_tables.additional_where_clause%TYPE;
    l_left_part_conv_fct         VARCHAR2(40);
    l_right_part_conv_fct        VARCHAR2(40);
    l_outer_join                 VARCHAR2(4);
    l_logical_operator           mfg_lookups.meaning%TYPE;
    l_asc_desc                   mfg_lookups.meaning%TYPE;
    l_operator                   mfg_lookups.meaning%TYPE;
    l_restriction_exist          BOOLEAN                                                   := FALSE;
    l_rule_id                    NUMBER;
    l_sequence_number            NUMBER;
    l_flex_column_name           fnd_flex_validation_tables.id_column_name%TYPE;
    l_order_by_string            VARCHAR2(1000);
    l_new_constant_character     VARCHAR2(500);
    --l_new_expression      VARCHAR2(4100);
    l_consist_string             VARCHAR2(1000);

    -- cursor for all DB objects used within the rule.
    -- Most objects found using this query correspond to a database table
    -- which must be added to the from clause.
    -- DB Objects 1 and 2 are always included in the from clause, so
    --  we don't need to get them with this query.
    --
    -- 2/21/02 - remove quantity function objects from this query.  For
    -- putaway, we check quantity function in the Apply function.
    -- For picking, the quantity function object is "base", which is always
    -- included
    CURSOR objects IS
      -- 1. all single referenced DB objects
      SELECT   wdo.db_object_id
             , wdo.table_name
             , wdo.table_alias
             , wdo.context_dependent_flag
          FROM wms_db_objects wdo
             , wms_parameters_b wpb
             , (SELECT wsc.parameter_id
                  FROM wms_sort_criteria wsc
                 WHERE wsc.rule_id = p_rule_id
                UNION
                SELECT wr.parameter_id
                  FROM wms_restrictions wr
                 WHERE wr.rule_id = p_rule_id
                UNION
                SELECT wr.operand_parameter_id
                  FROM wms_restrictions wr
                 WHERE wr.rule_id = p_rule_id
                   AND wr.operand_type_code = 4
                UNION
                SELECT wrc.parameter_id
                  FROM wms_rule_consistencies wrc
                 WHERE wrc.rule_id = p_rule_id) x
         WHERE wpb.parameter_id = x.parameter_id
           AND wpb.db_object_ref_type_code = 1
           AND wdo.db_object_id = wpb.db_object_id
           AND wdo.db_object_id NOT IN (1, 2)
      UNION
      -- 2. all parents of single referenced DB objects
      SELECT   wdo.db_object_id
             , wdo.table_name
             , wdo.table_alias
             , wdo.context_dependent_flag
          FROM wms_db_objects wdo
             , (SELECT     wdop.parent_db_object_id
                      FROM wms_db_objects_parents wdop
                     WHERE wdop.type_code = p_type_code
                CONNECT BY wdop.db_object_id = PRIOR wdop.parent_db_object_id
                START WITH wdop.db_object_id IN (SELECT wdod.db_object_id
                                                   FROM wms_db_objects wdod
                                                      , wms_parameters_b wpbd
                                                      , (SELECT wscd.parameter_id
                                                           FROM wms_sort_criteria wscd
                                                          WHERE wscd.rule_id = p_rule_id
                                                         UNION
                                                         SELECT wrd.parameter_id
                                                           FROM wms_restrictions wrd
                                                          WHERE wrd.rule_id = p_rule_id
                                                         UNION
                                                         SELECT wrd.operand_parameter_id
                                                           FROM wms_restrictions wrd
                                                          WHERE wrd.rule_id = p_rule_id
                                                            AND wrd.operand_type_code = 4
                                                         UNION
                                                         SELECT wrcd.parameter_id
                                                           FROM wms_rule_consistencies wrcd
                                                          WHERE wrcd.rule_id = p_rule_id) xd
                                                  WHERE wpbd.parameter_id = xd.parameter_id
                                                    AND wpbd.db_object_ref_type_code = 1
                                                    AND wdod.db_object_id = wpbd.db_object_id)) x
         WHERE wdo.db_object_id = x.parent_db_object_id
           AND wdo.db_object_id NOT IN (1, 2)
      -- 3. all multi referenced DB objects
      UNION
      SELECT   wdo.db_object_id
             , wdo.table_name
             , NVL(wdorm.table_alias, wdo.table_alias)
             , wdo.context_dependent_flag
          FROM wms_db_objects wdo
             , wms_db_obj_ref_members wdorm
             , wms_db_object_references wdor
             , wms_parameters_b wpb
             , (SELECT wsc.parameter_id
                  FROM wms_sort_criteria wsc
                 WHERE wsc.rule_id = p_rule_id
                UNION
                SELECT wr.parameter_id
                  FROM wms_restrictions wr
                 WHERE wr.rule_id = p_rule_id
                UNION
                SELECT wr.operand_parameter_id
                  FROM wms_restrictions wr
                 WHERE wr.rule_id = p_rule_id
                   AND wr.operand_type_code = 4
                UNION
                SELECT wrc.parameter_id
                  FROM wms_rule_consistencies wrc
                 WHERE wrc.rule_id = p_rule_id) x
         WHERE wpb.parameter_id = x.parameter_id
           AND wpb.db_object_ref_type_code = 2
           AND wdor.db_object_reference_id = wpb.db_object_reference_id
           AND wdorm.db_object_reference_id = wdor.db_object_reference_id
           AND wdo.db_object_id = wdorm.db_object_id
           AND wdo.db_object_id NOT IN (1, 2)
      UNION
      -- 4. all parents of multi referenced DB objects
      SELECT   wdo.db_object_id
             , wdo.table_name
             , wdo.table_alias
             , wdo.context_dependent_flag
          FROM wms_db_objects wdo
             , (SELECT     wdop.parent_db_object_id
                      FROM wms_db_objects_parents wdop
                     WHERE wdop.type_code = p_type_code
                CONNECT BY wdop.db_object_id = PRIOR wdop.parent_db_object_id
                START WITH wdop.db_object_id IN (SELECT wdoi.db_object_id
                                                   FROM wms_db_objects wdoi
                                                      , wms_db_obj_ref_members wdormi
                                                      , wms_db_object_references wdori
                                                      , wms_parameters_b wpbi
                                                      , (SELECT wsc.parameter_id
                                                           FROM wms_sort_criteria wsc
                                                          WHERE wsc.rule_id = p_rule_id
                                                         UNION
                                                         SELECT wr.parameter_id
                                                           FROM wms_restrictions wr
                                                          WHERE wr.rule_id = p_rule_id
                                                         UNION
                                                         SELECT wr.operand_parameter_id
                                                           FROM wms_restrictions wr
                                                          WHERE wr.rule_id = p_rule_id
                                                            AND wr.operand_type_code = 4
                                                         UNION
                                                         SELECT wrc.parameter_id
                                                           FROM wms_rule_consistencies wrc
                                                          WHERE wrc.rule_id = p_rule_id) xi
                                                  WHERE wpbi.parameter_id = xi.parameter_id
                                                    AND wpbi.db_object_ref_type_code = 2
                                                    AND wdori.db_object_reference_id = wpbi.db_object_reference_id
                                                    AND wdormi.db_object_reference_id = wdori.db_object_reference_id
                                                    AND wdoi.db_object_id = wdormi.db_object_id)) x
         WHERE wdo.db_object_id = x.parent_db_object_id
           AND wdo.db_object_id NOT IN (1, 2)
      ORDER BY 1;

    --
    -- Finds the join conditions to join a DB object to it's parent
    --  DB object.  This is used to build the where clause for the rule.
    CURSOR conditions IS
      SELECT wpb.parameter_type_code
           , wpb.column_name
           , wpb.expression
           , wpb.data_type_code
           , wpbp.parameter_type_code
           , wpbp.column_name
           , wpbp.expression
           , wpbp.data_type_code
           , wdop.table_alias -- alias n.a. for multi object based parameters
        FROM wms_db_objects wdop, wms_parameters_b wpbp, wms_parameters_b wpb, wms_db_object_joins wdoj
       WHERE wdoj.db_object_id = l_db_object_id
         AND wdoj.type_code = p_type_code
         AND wpb.parameter_id = wdoj.parameter_id
         AND wpbp.parameter_id = wdoj.parent_parameter_id
         AND wdop.db_object_id(+) = wpbp.db_object_id;

    --
    -- cursor for the quantity function parameter of the actual rule.
    -- Used only for picking and putaway
    CURSOR qtyfnct IS
      SELECT wpb.parameter_type_code
           , wpb.column_name
           , wpb.expression
           , wpb.data_type_code
           , wdo.table_alias -- alias n.a. for multi object based parameters
        FROM wms_db_objects wdo, wms_parameters_b wpb, wms_rules_b wrb
       WHERE wrb.rule_id = p_rule_id
         AND wpb.parameter_id = wrb.qty_function_parameter_id
         AND wdo.db_object_id(+) = wpb.db_object_id;

    --
    -- Finds the restrictions defined in the rule.
    --  Each restriction becomes part of the where clause.
    CURSOR RESTRICT IS
      SELECT   wpbl.parameter_type_code
             , wpbl.column_name
             , wpbl.expression
             , wpbl.data_type_code
             , wdol.table_alias -- alias n.a. for multi object based parameters
             , DECODE(
                 wr.operator_code
               , 1, '>'
               , 2, '<'
               , 3, '='
               , 4, '<>'
               , 5, '>='
               , 6, '<='
               , 7, 'IN'
               , 8, 'NOT IN'
               , 9, 'LIKE'
               , 10, 'NOT LIKE'
               , 11, 'IS NULL'
               , 12, 'IS NOT NULL'
               , NULL
               )
             , wr.operand_type_code
             , wr.operand_constant_number
             , wr.operand_constant_character
             , wr.operand_constant_date
             , wr.operand_expression
             , wr.operand_flex_value_set_id
             , DECODE(wr.logical_operator_code, 1, 'and', 2, 'or', NULL)
             , wr.bracket_open
             , wr.bracket_close
             , wpbr.parameter_type_code
             , wpbr.column_name
             , wpbr.expression
             , DECODE(
                 wr.operand_type_code
               , 4, wpbr.data_type_code
               , 5, wpbl.data_type_code
               , 6, DECODE(ffvs.format_type, 'N', 1, 'C', 2, 3)
               , 7, NULL
               , wr.operand_type_code
               )
             , wdor.table_alias -- alias n.a. for multi object based parameters
             , ffvs.validation_type -- only 'independent' and 'table' are supported
             , ffvt.id_column_name
             , ffvt.value_column_name
             , ffvt.application_table_name
             , ffvt.additional_where_clause
             , wr.rule_id
             , wr.sequence_number
          FROM fnd_flex_validation_tables ffvt
             , fnd_flex_value_sets ffvs
             , wms_db_objects wdor
             , wms_parameters_b wpbr
             , wms_db_objects wdol
             , wms_parameters_b wpbl
             , wms_restrictions wr
         WHERE wr.rule_id = p_rule_id
           AND wpbl.parameter_id = wr.parameter_id
           AND wdol.db_object_id(+) = wpbl.db_object_id
           AND wpbr.parameter_id(+) = wr.operand_parameter_id
           AND wdor.db_object_id(+) = wpbr.db_object_id
           AND ffvs.flex_value_set_id(+) = wr.operand_flex_value_set_id
           AND ffvt.flex_value_set_id(+) = wr.operand_flex_value_set_id
      ORDER BY wr.rule_id, wr.sequence_number -- order is important
                                             ;

    --
    -- Finds the Sort criteria entries for this rule.  Each sort criterion
    -- becomes a part of the order by clause of the sql statement.
    CURSOR sortcrit IS
      SELECT   wpb.parameter_type_code
             , wpb.column_name
             , wpb.expression
             , wpb.data_type_code
             , wdo.table_alias -- alias n.a. for multi object based parameters
             , wms_parameter_pvt.getflexdatatypecode(
                 wpb.data_type_code
               , wpb.db_object_ref_type_code
               , wpb.parameter_type_code
               , wpb.flexfield_usage_code
               , wpb.flexfield_application_id
               , wpb.flexfield_name
               , wpb.column_name
               )
             , DECODE(wsc.order_code, 1, 'asc', 2, 'desc', NULL)
             , wsc.rule_id
             , wsc.sequence_number
          FROM wms_db_objects wdo, wms_parameters_b wpb, wms_sort_criteria wsc
         WHERE wsc.rule_id = p_rule_id
           AND wpb.parameter_id = wsc.parameter_id
           AND wdo.db_object_id(+) = wpb.db_object_id
      ORDER BY wsc.rule_id, wsc.sequence_number;

    --
    -- Used to find all the consistency restrictions for the rule.
    -- Used to build portions of the Select and order by clauses.
    CURSOR consistencies IS
      SELECT wpb.parameter_type_code
           , wpb.column_name
           , wpb.expression
           , wdo.table_alias
        FROM wms_rule_consistencies wrc, wms_parameters_b wpb, wms_db_objects wdo
       WHERE wrc.rule_id = p_rule_id
         AND wpb.parameter_id = wrc.parameter_id
         AND wdo.db_object_id(+) = wpb.db_object_id;
  BEGIN
    -- Initialize API return status to success
    x_return_status    := fnd_api.g_ret_sts_success;

    log_procedure(l_api_name, 'start', 'Start BuildRuleSql');
    log_statement(l_api_name, 'rule_id', 'rule_id: ' || p_rule_id);
    log_statement(l_api_name, 'type_code', 'type_code: ' || p_type_code);

    -- end of debugging section
    --
    --If no rule, build default rule
    IF p_rule_id IS NULL THEN
      log_statement(l_api_name, 'null_rule_id', 'Rule id is NULL');

      -- if no rule and strategy is defined
      -- hardcoded this section
      IF p_type_code = 2 THEN
        g_rule_select  := 'NULL serial_number
                          ,nvl(base.primary_quantity,0)
                          ,nvl(base.secondary_quantity,0)              -- new
                          ,base.grade_code,                            -- new
                          ,NULL consist_string,
                          ,NULL order_by_string';
        g_rule_from    := ' mtl_system_items msi, ';
        g_rule_where   :=
                         ' and msi.ORGANIZATION_ID = mptdtv.FROM_ORGANIZATION_ID
                           and msi.INVENTORY_ITEM_ID = mptdtv.inventory_item_id ';
      ELSE
        g_rule_select  := 'NULL serial_number
                          ,nvl(WMS_Parameter_PVT.GetAvailableUnitCapacity
                                (  mptdtv.TO_ORGANIZATION_ID
                                   ,base.SUBINVENTORY_CODE
                                   ,base.LOCATOR_ID
                                   ,mil.LOCATION_MAXIMUM_UNITS
                                )
                               ,0)
                          ,NULL consist_string
                          ,NULL order_by_string';
        g_rule_from    := ' mtl_item_locations mil , ';
        g_rule_where   := ' and mil.ORGANIZATION_ID (+) = base.ORGANIZATION_ID
                            and mil.INVENTORY_LOCATION_ID (+) = base.locator_id ';
      END IF;

      g_rule_order     := NULL;
      --
      x_return_status  := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    -- Find all DB objects referenced within the rule and add them to the
    -- from clause.
    log_statement(l_api_name, 'start_objects', 'start objects loop');
    OPEN objects;

    WHILE TRUE LOOP
      FETCH objects INTO l_db_object_id, l_table_name, l_table_alias, l_context_dependent_flag;
      EXIT WHEN objects%NOTFOUND;
      log_statement(l_api_name, 'db_object_id', 'db_object_id: ' || l_db_object_id);

      --
      -- Add DB objects to the from clause

      -- For TTA, if g_rule_from is NULL, do no add ','
      -- Don't add a comma for the first table in the from clause
      IF  (g_rule_from IS NULL)
          AND (p_type_code IN (3, 4, 5, 7)) THEN -- brach for TTA
        g_rule_from  := l_table_name || ' ' || l_table_alias;
      ELSE
        g_rule_from  := l_table_name || ' ' || l_table_alias || g_line_feed || ',' || g_rule_from;
      END IF; -- end TTA branch

      -- Find each join condition joining current db object to its
      -- parent db object.  Add these conditions to the where clause.
      log_statement(l_api_name, 'start_conditions', 'start conditions loop');
      OPEN conditions;

      WHILE TRUE LOOP
        FETCH conditions INTO l_parameter_type_code
                            , l_column_name
                            , l_expression
                            , l_data_type_code
                            , l_parent_parameter_type_code
                            , l_parent_column_name
                            , l_parent_expression
                            , l_parent_data_type_code
                            , l_parent_table_alias;
        EXIT WHEN conditions%NOTFOUND;
        --
        log_statement(l_api_name, 'param_type_code', 'param_type_code: ' || l_parameter_type_code);
        log_statement(l_api_name, 'column_name', 'column_name: ' || l_column_name);
        log_statement(l_api_name, 'expression', 'expression: ' || l_expression);
        log_statement(l_api_name, 'data_type_code', 'data_type_code: ' || l_data_type_code);
        log_statement(l_api_name, 'parent_param_type_code', 'parent_param_type_code: ' || l_parent_parameter_type_code);
        log_statement(l_api_name, 'parent_column_name', 'parent_column_name: ' || l_parent_column_name);
        log_statement(l_api_name, 'parent_expression', 'parent_expression: ' || l_parent_expression);
        log_statement(l_api_name, 'parent_data_type_code', 'parent_data_type_code: ' || l_parent_data_type_code);
        log_statement(l_api_name, 'parent_table_alias', 'parent_table_alias: ' || l_parent_table_alias);
        -- find out, if data type conversion is needed
        inv_sql_binding_pvt.getconversionstring(l_data_type_code, l_parent_data_type_code, l_left_part_conv_fct, l_right_part_conv_fct);

        --
        -- find out, if outer join has to be used
        IF l_context_dependent_flag = 'Y' THEN
          l_outer_join  := ' (+)';
        ELSIF l_context_dependent_flag = 'N' THEN
          l_outer_join  := NULL;
        ELSE
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('WMS', 'WMS_BAD_CONTEXT_DEPT_FLAG');
            fnd_message.set_token('CONTEXT_DEPENDENT_FLAG', l_context_dependent_flag);
            log_error_msg(l_api_name, 'bad_context_depend_flag');
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        --
        -- add join conditions to where clause
        -- first, build the left side of the join
        g_rule_where  := g_rule_where || 'and ';

        IF l_parameter_type_code = 1 THEN -- based on column in table
          --g_rule_where  := g_rule_where || l_table_alias || '.' || l_column_name || l_outer_join;
          IF l_column_name = 'EFFECTIVITY_DATE' THEN   -- Bug 8212802

	    IF l_parent_parameter_type_code = 1 THEN
                g_rule_where  := g_rule_where || ' NVL(' || l_table_alias || '.' || l_column_name || ','||  l_left_part_conv_fct || l_parent_table_alias || '.' || l_parent_column_name|| l_right_part_conv_fct || ') ';
            ELSIF l_parent_parameter_type_code = 2 THEN
                g_rule_where  := g_rule_where || ' NVL(' || l_table_alias || '.' || l_column_name || ','||  l_left_part_conv_fct || l_parent_expression|| l_right_part_conv_fct || ') ';
            ELSE
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                    fnd_message.set_name('WMS', 'WMS_BAD_PARENT_PARA_TYPE');
                    fnd_message.set_token('PARENT_PARAMETER_TYPE_CODE', l_parent_parameter_type_code);
                    log_error_msg(l_api_name, 'bad_parent_param_type_joins');
                    fnd_msg_pub.ADD;
                END IF;
                RAISE fnd_api.g_exc_error;
            END IF;

          ELSE
              g_rule_where  := g_rule_where || l_table_alias || '.' || l_column_name || l_outer_join;
          END IF;

	ELSIF l_parameter_type_code = 2 THEN -- based on expression
          --g_rule_where  := g_rule_where || l_expression || l_outer_join;
          g_rule_where  := g_rule_where || l_expression ;    -- || l_outer_join; --Bug #3719043
        ELSE
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('WMS', 'WMS_BAD_PARAMETER_TYPE_CODE');
            fnd_message.set_token('PARAMETER_TYPE_CODE', l_parameter_type_code);
            log_error_msg(l_api_name, 'bad_param_type_code_joins');
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_column_name = 'EFFECTIVITY_DATE' THEN   -- Bug 8212802
        g_rule_where  := g_rule_where || ' <= ' || l_left_part_conv_fct;
        ELSE
        g_rule_where  := g_rule_where || ' = ' || l_left_part_conv_fct;
        END IF;

        -- now, build right side of join condition
        IF l_parent_parameter_type_code = 1 THEN
          g_rule_where  := g_rule_where || l_parent_table_alias || '.' || l_parent_column_name;
        ELSIF l_parent_parameter_type_code = 2 THEN
          g_rule_where  := g_rule_where || l_parent_expression;
        ELSE
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('WMS', 'WMS_BAD_PARENT_PARA_TYPE');
            fnd_message.set_token('PARENT_PARAMETER_TYPE_CODE', l_parent_parameter_type_code);
            log_error_msg(l_api_name, 'bad_parent_param_type_joins');
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        g_rule_where  := g_rule_where || l_right_part_conv_fct || g_line_feed;
      END LOOP;

      CLOSE conditions;
      log_statement(l_api_name, 'end_conditions', 'end of conditions loop');
    END LOOP;

    CLOSE objects;
    log_statement(l_api_name, 'end_objects', 'end of objects loop');

    -- Add qty function parameter
    -- added by jcearley on 12/8/99
    -- qtyfunction should be added only for picking or putaway
    -- 2/21/02 - we no longer add the quantity function to the putaway
    -- sql statement.  Instead, we check capacity in Apply.
    -- old code: IF (p_type_code IN (1,2)) THEN
    IF (p_type_code = 2) THEN
      -- Add serial number to select statement.  If item is serial controlled,
      -- and we are detailing it, then get serial number from base.  Otherwise,
      -- set serial number to NULL
      IF p_type_code = 2 THEN
        g_rule_select  := g_rule_select || ',' || g_base_table_alias || '.SERIAL_NUMBER' || g_line_feed;
      ELSE
        g_rule_select  := g_rule_select || ',NULL SERIAL_NUMBER' || g_line_feed;
      END IF;

      -- Used when we are detailing a serial controlled item but
      -- not detailing serial numbers.
      g_rule_select_serial  := g_rule_select_serial || ',NULL SERIAL_NUMBER' || g_line_feed;
      log_statement(l_api_name, 'qty_func', 'finding qty function');
      OPEN qtyfnct;
      FETCH qtyfnct INTO l_parameter_type_code, l_column_name, l_expression, l_data_type_code, l_table_alias;

      IF qtyfnct%NOTFOUND THEN
        CLOSE qtyfnct;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_QTY_FUNC_NOT_FOUND');
          log_error_msg(l_api_name, 'qty_func_not_found');
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE qtyfnct;
      --
      log_statement(l_api_name, 'param_type_code_qty', 'param_type_code: ' || l_parameter_type_code);
      log_statement(l_api_name, 'column_name_qty', 'column_name: ' || l_column_name);
      log_statement(l_api_name, 'expression_qty', 'expression: ' || l_expression);
      log_statement(l_api_name, 'data_type_code_qty', 'data_type_code: ' || l_data_type_code);
      log_statement(l_api_name, 'table_alias_qty', 'table_alias: ' || l_table_alias);

      IF l_data_type_code <> 1 THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_BAD_QTY_FUNC_DATA_TYPE');
          fnd_message.set_token('DATATYPE', l_data_type_code);
          log_error_msg(l_api_name, 'bad_qty_func_data_type');
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      --

      -- Add qty function parameter to select clause
      IF l_parameter_type_code = 1 THEN
        g_rule_select         := g_rule_select || ',nvl(' || l_table_alias || '.' || l_column_name || ',0)' || g_line_feed;
        g_rule_select_serial  := g_rule_select_serial || ',sum(nvl(' || l_table_alias || '.' || l_column_name || ',0))' || g_line_feed;
      ELSIF l_parameter_type_code = 2 THEN
        -- Important Detail !!!
        -- Since the only quantity used by the engine internally
        -- for picking is the primary quantity,
        -- the expression from the parameter is ignored here.
        -- Instead, we only look at the primary quantity from the
        -- base.
        -- The next line is commented out and replaced with the
        -- line followed.

        --updated by jcearley on 12/7/99
        -- primary quantity is only useful for picking. Thus, I'm adding a check
        -- on the type_code.  If it's picking, use primary qty.  If it's put away,
        -- use the previously commented out line.
        IF (p_type_code = 1) THEN --put away
          g_rule_select         := g_rule_select
                                   || ',nvl(' || l_expression || ',0)'
                                   || g_line_feed;
          g_rule_select_serial  := g_rule_select_serial
                                   || ',sum(nvl(' || l_expression || ',0))'
                                   || g_line_feed;
        ELSIF (p_type_code = 2) THEN
          g_rule_select         := g_rule_select
                                || ',base.primary_quantity ' || g_line_feed
                                || ',base.secondary_quantity ' || g_line_feed         -- new
                                || ',base.grade_code ' || g_line_feed;                -- new
          g_rule_select_serial  := g_rule_select_serial
                                || ',sum(base.primary_quantity) ' || g_line_feed
                                || ',sum(base.secondary_quantity) ' || g_line_feed         -- new
                                || ',base.grade_code ' || g_line_feed;                -- new
        END IF;
      ELSE
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_BAD_PARAMETER_TYPE_CODE');
          fnd_message.set_token('PARAMETER_TYPE_CODE', l_parameter_type_code);
          log_error_msg(l_api_name, 'bad_param_type_code_qty');
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF; -- parameter type code = 1
    END IF; -- type code in 1,2

    --
    log_statement(l_api_name, 'start_restrictions', 'start restrictions loop');
    -- Add restrictions
    OPEN RESTRICT;

    --
    --  Loop through all the restrictions, adding them to where clause
    WHILE TRUE LOOP
      FETCH RESTRICT INTO l_parameter_type_code
                        , l_column_name
                        , l_expression
                        , l_data_type_code
                        , l_table_alias
                        , l_operator
                        , l_operand_type_code
                        , l_operand_constant_number
                        , l_operand_constant_character
                        , l_operand_constant_date
                        , l_operand_expression
                        , l_operand_flex_value_set_id
                        , l_logical_operator
                        , l_bracket_open
                        , l_bracket_close
                        , l_parent_parameter_type_code
                        , l_parent_column_name
                        , l_parent_expression
                        , l_parent_data_type_code
                        , l_parent_table_alias
                        , l_validation_type
                        , l_id_column_name
                        , l_value_column_name
                        , l_application_table_name
                        , l_additional_where_clause
                        , l_rule_id
                        , l_sequence_number;
      EXIT WHEN RESTRICT%NOTFOUND;
      --
      log_statement(l_api_name, 'sequence_num', 'sequence_num: ' || l_sequence_number);

      -- For first restriction, add 'and (' before adding the restrictions.
      -- Needed to join restrictions and other join statements already in
      -- the where clause.
      IF l_restriction_exist = FALSE THEN
        l_restriction_exist  := TRUE;
        g_rule_where         := g_rule_where || 'and (' || g_line_feed;
      END IF;

      --
      -- find out, if data type conversion is needed
      inv_sql_binding_pvt.getconversionstring(l_parent_data_type_code, l_data_type_code, l_left_part_conv_fct, l_right_part_conv_fct);
      log_statement(l_api_name, 'left_part', 'add left part of res');

      -- add left part of the restrictions
      IF l_parameter_type_code = 1 THEN -- parameter is table.column
        g_rule_where  :=    g_rule_where
                         || l_logical_operator
                         || l_bracket_open
                         || ' '
                         || l_left_part_conv_fct
                         || l_table_alias
                         || '.'
                         || l_column_name
                         || l_right_part_conv_fct
                         || ' '
                         || l_operator
                         || ' ';
      ELSIF l_parameter_type_code = 2 THEN -- parameter is an expression
        g_rule_where  :=    g_rule_where
                         || l_logical_operator
                         || l_bracket_open
                         || ' '
                         || l_left_part_conv_fct
                         || l_expression
                         || l_right_part_conv_fct
                         || ' '
                         || l_operator
                         || ' ';
      ELSE
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_BAD_PARAMETER_TYPE_CODE');
          fnd_message.set_token('PARAMETER_TYPE_CODE', l_parameter_type_code);
          log_error_msg(l_api_name, 'bad_param_type_code_left_rest');
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      --
      log_statement(l_api_name, 'right_part', 'add right part of res');

      -- add right part of the restrictions

      IF l_operand_type_code = 1 THEN -- right side = const. number
        g_rule_where  := g_rule_where || l_operand_constant_number || l_operand_expression || l_bracket_close || g_line_feed;
      ELSIF l_operand_type_code = 2 THEN -- right side = const. character
        --need to insert escape character of any apostrophes already in
        -- character field

        --first case - string of length one
        IF LENGTH(l_operand_constant_character) = 1 THEN
          --if the one character is an apostrophe, provide escape
          -- character, then add single quotes
          IF l_operand_constant_character = '''' THEN
            l_new_constant_character  := '''''';
          END IF;

          l_new_constant_character  := '''' || l_operand_constant_character || '''';
        -- second case - length > 2 - treat any single quote which is not
        -- the first or last character as an apostrophe, and ecape the
        -- character
        ELSIF LENGTH(l_operand_constant_character) > 2 THEN
          --    get the string minus the first and last characters
          --    (we take care of first and last characters later)
          l_new_constant_character  := SUBSTR(l_operand_constant_character, 2, LENGTH(l_operand_constant_character) - 2);
          --    replace all apostrophes with two apostrophes
          l_new_constant_character  := REPLACE(l_new_constant_character, '''', '''''');
          --    recontstruct the original string
          l_new_constant_character  :=
                         SUBSTR(l_operand_constant_character, 1, 1)
                         || l_new_constant_character
                         || SUBSTR( l_operand_constant_character , -1 , 1 );
        -- third case - Length 2 - treat any single quote like a single
        -- quote.  we deal with quotes at the beginning and end of the string
        -- below.
        ELSE
          l_new_constant_character  := l_operand_constant_character;
        END IF;

        IF LENGTH(l_new_constant_character) > 1 THEN
          --check to see if string already has single quotes around it
          --if not, add the quotes.
          --this process checks both sides. if there is an initial quote but not
          -- a trailing quote, only the trailing quote is added.
          IF (SUBSTR(l_new_constant_character, 1, 1) <> '''') THEN
            l_new_constant_character  := '''' || l_new_constant_character;
          END IF;

          IF (SUBSTR(l_new_constant_character, -1, 1) <> '''') THEN
            l_new_constant_character  := l_new_constant_character || '''';
          END IF;
        END IF;

        g_rule_where  := g_rule_where || l_new_constant_character || l_bracket_close || g_line_feed;
      ELSIF l_operand_type_code = 3 THEN -- right side = const. date
        --l_identifier := inv_sql_binding_pvt.InitBindVar(l_operand_constant_date);
        --Bug #2611142 - Add quotes before and after l_operand_constant_date
        g_rule_where  := g_rule_where
                       || ''''
                       || l_operand_constant_date
                       || ''''
                       || ' '
                       || l_operand_expression
                       || l_bracket_close
                       || g_line_feed;
      ELSIF l_operand_type_code = 4 THEN -- right side = parameter
        IF l_parent_parameter_type_code = 1 THEN -- table.column
          g_rule_where  :=
                g_rule_where || l_parent_table_alias
                             || '.'
                             || l_parent_column_name
                             || l_operand_expression
                             || l_bracket_close
                             || g_line_feed;
        ELSIF l_parent_parameter_type_code = 2 THEN -- expression
          g_rule_where  := g_rule_where
                          || l_parent_expression
                          || l_operand_expression
                          || l_bracket_close
                          || g_line_feed;
        ELSE
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('WMS', 'WMS_BAD_PARENT_PARA_TYPE');
            fnd_message.set_token('PARENT_PARAMETER_TYPE_CODE', l_parent_parameter_type_code);
            log_error_msg(l_api_name, 'bad_parent_param_type_right_rest');
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_operand_type_code = 5 THEN -- right side = expression
        --changed by jcearley on 12/8/99 - automatically put expression
        -- in parentheses - prevents syntax error during rule generation
        g_rule_where  := g_rule_where
                       || '(' || l_operand_expression || ')'
                       || l_bracket_close
                       || g_line_feed;
      ELSIF l_operand_type_code = 6 THEN -- right side = flex value set
        IF l_validation_type = 'F' THEN -- > validation type 'table'
          IF (l_id_column_name IS NULL) THEN
            l_flex_column_name  := l_value_column_name;
          ELSE
            l_flex_column_name  := l_id_column_name;
          END IF;

          g_rule_where  :=    g_rule_where
                           || '( select '
                           || l_flex_column_name
                           || ' from '
                           || l_application_table_name
                           || ' '
                           || l_additional_where_clause
                           || ')'
                           || l_bracket_close
                           || g_line_feed;
        ELSIF l_validation_type = 'I' THEN -- > validation type 'independent'
          --l_identifier := inv_sql_binding_pvt.initbindvar
           -- (l_operand_flex_value_set_id);
          g_rule_where  :=    g_rule_where
                           || '( select FLEX_VALUE from '
                           || 'FND_FLEX_VALUES_VL where FLEX_VALUE_SET_ID = '
                           || l_operand_flex_value_set_id
                           || ' and ENABLED_FLAG = ''Y'' and sysdate between nvl('
                           || 'START_DATE_ACTIVE,sysdate-1) and nvl('
                           || 'END_DATE_ACTIVE,sysdate+1) )'
                           || l_bracket_close
                           || g_line_feed;
        ELSE
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('WMS', 'WMS_BAD_REF_FLEXVSET_DATA');
            fnd_message.set_token('DATATYPE', l_validation_type);
            log_error_msg(l_api_name, 'bad_ref_flexvset_data');
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_operand_type_code = 7 THEN -- right side = nothing
        g_rule_where  := g_rule_where || l_bracket_close || g_line_feed;
      ELSE
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_BAD_OPERAND_TYPE_CODE');
          fnd_message.set_token('OPERAND_TYPE_CODE', l_operand_type_code);
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    CLOSE RESTRICT;
    --
    log_statement(l_api_name, 'end_restrictions', 'end restrictions loop');

    -- Insert bracket after adding the additional restriction clauses
    IF l_restriction_exist = TRUE THEN
      g_rule_where  := g_rule_where || ')' || g_line_feed;
    END IF;

    --

    l_order_by_string  := NULL;
    log_statement(l_api_name, 'alloc_mode', 'alloc_mode: ' || p_allocation_mode_id);
    log_statement(l_api_name, 'start_sort_crit', 'start sort crit loop');
    -- Add sort criteria
    OPEN sortcrit;

    --
    -- Loop through all sort criteria, adding them to Order By clause
    WHILE TRUE LOOP
      FETCH sortcrit INTO l_parameter_type_code
                        , l_column_name
                        , l_expression
                        , l_data_type_code
                        , l_table_alias
                        , l_parent_data_type_code
                        , l_asc_desc
                        , l_rule_id
                        , l_sequence_number;
      EXIT WHEN sortcrit%NOTFOUND;
      --
      log_statement(l_api_name, 'seq_number_sort', 'seq_number sort:' || l_sequence_number);
      -- find out, if data type conversion is needed
      inv_sql_binding_pvt.getconversionstring(l_parent_data_type_code
                                            , l_data_type_code
                                            , l_left_part_conv_fct
                                            , l_right_part_conv_fct);

      -- initialize  order by clause
      IF g_rule_order IS NOT NULL THEN
        g_rule_order  := g_rule_order || ',';
      END IF;

      --
      -- add sort criterion to order by clause
      IF l_parameter_type_code = 1 THEN -- table.column
        g_rule_order  :=    g_rule_order
                         || l_left_part_conv_fct
                         || l_table_alias
                         || '.'
                         || l_column_name
                         || l_right_part_conv_fct
                         || ' '
                         || l_asc_desc
                         || g_line_feed;

        --added support for Picking by UOM
        --build the order_by_string for the select stmt;
        --this string is a concatenation of all the columns in the
        -- order by clause.
        -- order by string only matters for picking - set to NULL
        -- if not picking
        -- Needed in Apply procedure.
        IF (p_type_code = 2) THEN --pick
          IF (l_order_by_string IS NULL) THEN
            l_order_by_string  := l_left_part_conv_fct
                                || l_table_alias || '.' || l_column_name
                                || l_right_part_conv_fct;
          ELSE
            -- need to hard code in '||' so string is concatenated at
            -- run time
            l_order_by_string  :=
                            l_order_by_string
                            || '||'
                            || l_left_part_conv_fct
                            || l_table_alias || '.' || l_column_name
                            || l_right_part_conv_fct;
          END IF;

          -- include sort criteria in the group by clause, so that
                --  we can preserve the sort order.  Used only when
                --  detailing serial controlled items but not detailing serial
                --  numbers.
          g_rule_group_by  := g_rule_group_by || ',' || l_table_alias || '.' || l_column_name;
        END IF;
      ELSIF l_parameter_type_code = 2 THEN -- expression
        g_rule_order  := g_rule_order
                       || l_left_part_conv_fct
                       || l_expression
                       || l_right_part_conv_fct
                       || ' '
                       || l_asc_desc
                       || g_line_feed;

        --build the order_by_string for the select stmt
        IF (p_type_code = 2) THEN --pick
          IF (l_order_by_string IS NULL) THEN
            l_order_by_string  := l_left_part_conv_fct || l_expression || l_right_part_conv_fct;
          ELSE
            l_order_by_string  := l_order_by_string
                                   || '||'
                                   || l_left_part_conv_fct
                                   || l_expression
                                   || l_right_part_conv_fct;
          END IF;

          g_rule_group_by  := g_rule_group_by || ',' || l_expression;
        END IF;
      ELSE
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_BAD_PARAMETER_TYPE_CODE');
          fnd_message.set_token('OPERAND_TYPE_CODE', l_parameter_type_code);
          log_error_msg(l_api_name, 'bad_param_type_code_sort');
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    CLOSE sortcrit;
    log_statement(l_api_name, 'end_sort_crit', 'end sort crit loop');

    --Pick UOM and Rule Consistencies are supported only for picking rules
    IF (p_type_code = 2) THEN
      l_consist_string  := NULL;
      --Get consistencies from cursor;
      -- These consistencies are concatenated together to form one
      --  string. This string is added to the select and order by for the
      --  rule sql, and are used in the Apply function.
      OPEN consistencies;

      LOOP
        FETCH consistencies INTO l_parameter_type_code, l_column_name, l_expression, l_table_alias;
        EXIT WHEN consistencies%NOTFOUND;

        -- if parameter is a db column
        IF l_parameter_type_code = 1 THEN
          IF l_consist_string IS NULL THEN
            l_consist_string  := l_table_alias || '.' || l_column_name;
          ELSE
            --parameter is expression
            l_consist_string  := l_consist_string
                                || '||'
                                || l_table_alias || '.' || l_column_name;
          END IF;

          -- include consistencies in the group by clause, so that
                --  we can preserve them.  Used only when
                --  detailing serial controlled items but not detailing serial
                --  numbers.
          g_rule_group_by  := g_rule_group_by
                             || ','
                             || l_table_alias || '.' || l_column_name
                             || g_line_feed;
        -- if parameter is an expression
        ELSIF l_parameter_type_code = 2 THEN
          IF l_consist_string IS NULL THEN
            l_consist_string  := l_expression;
          ELSE
            l_consist_string  := l_consist_string || '||' || l_expression;
          END IF;

          g_rule_group_by  := g_rule_group_by || ',' || l_expression || g_line_feed;
        ELSE
          fnd_message.set_name('WMS', 'WMS_BAD_PARAMETER_TYPE_CODE');
          fnd_message.set_token('OPERAND_TYPE_CODE', l_parameter_type_code);
          log_error_msg(l_api_name, 'bad_param_type_code_consist');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;

      --add consist_string to the select clause
      -- Used in Apply procedure
      IF l_consist_string IS NOT NULL THEN
        IF g_rule_order IS NULL THEN
          g_rule_order  := l_consist_string || g_line_feed;
        ELSE
          g_rule_order  := g_rule_order || ',' || l_consist_string || g_line_feed;
        END IF;

        /* No longer added consist_string to order_by_string
          IF l_order_by_string IS NULL THEN
             l_order_by_string := l_consist_string;
    ELSE
             l_order_by_string:=l_order_by_string || '||' || l_consist_string;
          END IF;
        */
        g_rule_select         := g_rule_select
                                || ','
                                || l_consist_string
                                || ' consist_string'
                                || g_line_feed;
        g_rule_select_serial  := g_rule_select_serial
                                || ','
                                || l_consist_string
                                || ' consist_string'
                                || g_line_feed;
        g_rule_group_by       := g_rule_group_by
                                || ','
                                || l_consist_string
                                || g_line_feed;
      -- if no consistencies, don't add anything to order by
      ELSE
        g_rule_select         := g_rule_select || ',NULL consist_string' || g_line_feed;
        g_rule_select_serial  := g_rule_select_serial || ',NULL consist_string' || g_line_feed;
      END IF;

      --Add conversion_rate to sort criteria
      --if efficient pick flag is set, add conversion rate to front of order by;
      --otherwise, add to end of order by
      -- Bug#6802143: Serial Number is added in the order by and group by clause for Picking.
      IF (g_rule_order IS NULL) THEN
        -- conversion rate is only order by
        g_rule_order  := g_rule_order
	                  || g_base_table_alias
                          || '.SERIAL_NUMBER asc'
                          || ','
                          || g_base_table_alias
                          || '.CONVERSION_RATE desc'
                          || g_line_feed;
      ELSIF (p_allocation_mode_id IN (g_alloc_pick_uom, g_alloc_strict_pick_uom)) THEN
        g_rule_order  := g_base_table_alias
                          || '.CONVERSION_RATE desc'
                          || g_line_feed
                          || ','
			  || g_base_table_alias
                          || '.SERIAL_NUMBER asc'
                          || ','
                          || g_rule_order;
      ELSE
        g_rule_order  := g_rule_order
                          || ','
			  || g_base_table_alias
                          || '.SERIAL_NUMBER asc'
                          || ','
                          || g_base_table_alias
                          || '.CONVERSION_RATE desc'
                          || g_line_feed;
      END IF;

      g_rule_group_by   := g_rule_group_by
                          || ','
			  || g_base_table_alias
                          || '.SERIAL_NUMBER'
                          || ','
                          || g_base_table_alias
                          || '.CONVERSION_RATE'
                          || g_line_feed;

      -- Add the order_by_string to the select and group by clauses.
      -- This string is used in the Apply procedure.
      IF (l_order_by_string IS NOT NULL) THEN
        g_rule_select         := g_rule_select
                                || ','
                                || l_order_by_string
                                || ' order_by_string'
                                || g_line_feed;
        g_rule_select_serial  := g_rule_select_serial
                                || ','
                                || l_order_by_string
                                || ' order_by_string'
                                || g_line_feed;
        g_rule_group_by       := g_rule_group_by || ',' || l_order_by_string || g_line_feed;
      ELSE
        g_rule_select         := g_rule_select || ',NULL order_by_string' || g_line_feed;
        g_rule_select_serial  := g_rule_select_serial || ',NULL order_by_string' || g_line_feed;
      END IF;
    ELSE --order by and consist string only useful in picking
      --3/13/02 added for PJM support
      -- Add project and task to sort criteria
      IF p_type_code = 1 THEN
        IF (g_rule_order IS NULL) THEN
          -- project and task  are only order by
          g_rule_order  :=
                     g_rule_order  || g_base_table_alias
                                   || '.PROJECT_ID' || g_line_feed
                                   || ',' || g_base_table_alias
                                   || '.TASK_ID' || g_line_feed;
        ELSE
          --bug 2983185 - g_rule_order was getting concatenated twice
          g_rule_order  :=    g_rule_order
                           || ','
                           || g_base_table_alias
                           || '.PROJECT_ID'
                           || g_line_feed
                           || ','
                           || g_base_table_alias
                           || '.TASK_ID'
                           || g_line_feed;
        END IF;
      END IF;

      g_rule_select         := g_rule_select || ',NULL consist_string' || g_line_feed;
      g_rule_select_serial  := g_rule_select_serial || ',NULL consist_string' || g_line_feed;
      g_rule_select         := g_rule_select || ',NULL order_by_string' || g_line_feed;
      g_rule_select_serial  := g_rule_select_serial || ',NULL order_by_string' || g_line_feed;
    END IF;

    --
    -- Save the pointers, which mark the end of the rule sourced bind variables
    --inv_sql_binding_pvt.SaveBindPointers;
    --
    log_procedure(l_api_name, 'end', 'End BuildRuleSql');
  -- end of debugging section
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);

    WHEN OTHERS THEN
      IF objects%ISOPEN THEN
        CLOSE objects;
      END IF;

      IF conditions%ISOPEN THEN
        CLOSE conditions;
      END IF;

      IF qtyfnct%ISOPEN THEN
        CLOSE qtyfnct;
      END IF;

      IF RESTRICT%ISOPEN THEN
        CLOSE RESTRICT;
      END IF;

      IF sortcrit%ISOPEN THEN
        CLOSE sortcrit;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
  --
  END buildrulesql;

  --
  -- Name        : BuildInputSQL
  -- Function    : Adds the SQL to the where clause to handle
  --     input parameters
  -- Notes       : privat procedure for internal use only
  --
  PROCEDURE buildinputsql(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_type_code     IN            NUMBER
  ) IS
    -- variables needed for dynamic SQL
    l_identifier VARCHAR2(10);
    l_api_name   VARCHAR2(30) := 'BuildIputSQL';
    l_is_mat_status_used  NUMBER := NVL(FND_PROFILE.VALUE('INV_MATERIAL_STATUS'), 2);
  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    log_procedure(l_api_name, 'start', 'Start BuildInputSql');
    -- end of debugging section
    --
    --
    -- Add type code independent input parameters to where clause
    -- Notes: For picking, the sql statement already bound organization_id
    -- and inventory_item_id in BuildBaseSQL, so here it is redundant but
    -- no harm anyway
    g_input_where    := g_base_table_alias || '.ORGANIZATION_ID = ' || 'g_organization_id' || g_line_feed;
    g_input_where    := g_input_where || 'and ' || g_base_table_alias || '.INVENTORY_ITEM_ID = ' || 'g_inventory_item_id' || g_line_feed;

    -- the move order line can specify the subinventory, locator, revision,
    -- and/or lot number to use for the pick or put away. To allow for a
    -- generic sql cursor regardless of input values, we use the decode statments
    -- in the where clause.
    -- When Rule.Apply is called, it will look at these four input values. For
    -- all the input values which are Null, the Apply function will set those
    -- values to -9999 (or -99 for Revision). Then inside the cursor in the
    -- stored rule function, these decode statements make a check on the value
    -- of the inputs.  If the inputs = -9999 or -99 (i.e. Null), the decode
    -- statements create a line which always evaluate to true: a=a or 1=1.
    -- If the input has a non -9999 value, then that value is compared to the
    -- appropriate column.

    -- 2/21/02 - We no longer add subinventory code and locator id to the
    -- where clause here. for putaway.
    --The decode statements prevent the subinventory/locator indices from
    -- being used.  Instead, we add subinventory and locator to the where clause
    -- in GenerateRulePackage for cursors that are called only when those
    -- values are passed.
    IF (p_type_code = 2) THEN --picking only
      g_input_where  :=    g_input_where
                        || ' and '
                        || 'decode(g_subinventory_code, ''-9999'', ''a'', '
                        || g_base_table_alias
                        || '.SUBINVENTORY_CODE)'
                        || ' = '
                        || 'decode(g_subinventory_code, ''-9999'', ''a'', g_subinventory_code)'
                        || g_line_feed;
      --bug #1252345
      --if subinventory is null, we have to make sure we don't pick from
      --  non-reservable sub
      -- # 6917190
      -- 7280339 added check for status_id is null
      -- high volume project 8546026
     IF l_is_mat_status_used = 1 THEN
      g_input_where  :=    g_input_where
                        || ' and '
                        || ' ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null ) '
			|| ' AND exists(select 1 from mtl_material_statuses where status_id = '
			|| g_base_table_alias
			|| '.STATUS_ID'
			|| ' AND RESERVABLE_TYPE = 1)) OR '
			|| '((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL) '
                        || ' or '
			|| g_base_table_alias
			|| '.STATUS_ID IS NULL)'
			|| ' and '
			|| 'decode(g_subinventory_code, ''-9999'', '
                        || g_base_table_alias
                        || '.RESERVABLE_TYPE, 1)'
                        || ' = 1))'
                        || g_line_feed;

      ELSE
	  g_input_where  :=    g_input_where
                        || ' and '
                        || 'decode(g_subinventory_code, ''-9999'', '
                        || g_base_table_alias
                        || '.RESERVABLE_TYPE, 1)'
                        || ' = 1'
                        || g_line_feed;
      END IF;

      g_input_where  :=    g_input_where
                        || ' and '
                        || 'decode(g_locator_id, -9999, 1, '
                        || g_base_table_alias
                        || '.locator_id)'
                        || ' = '
                        || 'decode(g_locator_id,-9999, 1, g_locator_id)'
                        || g_line_feed;
      -- Bug 6719290, 6917190
      IF l_is_mat_status_used = 1 THEN
         g_input_where  :=    g_input_where
                          || ' and '
			  || ' ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null ) '
			  || ' AND exists(select 1 from mtl_material_statuses where status_id = '
			  || g_base_table_alias
			  || '.STATUS_ID'
			  || ' AND RESERVABLE_TYPE = 1)) OR '
			  || '((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL) '
			  || 'or '
			  || g_base_table_alias
			  || '.STATUS_ID IS NULL)'
			  || ' and '
                          || 'decode(g_locator_id, -9999, '
                          || g_base_table_alias
                          || '.locreservable, 1)'
                          || ' = 1))'
                          || g_line_feed;
      END IF ;

    END IF;

     IF (p_type_code = 2) THEN
        g_input_where  :=    g_input_where
                          || ' and '
                          || 'decode(g_revision, ''-99'', ''a'', '
                          || g_base_table_alias
                          || '.REVISION)'
                          || ' = '
                          || 'decode(g_revision, ''-99'', ''a'', g_revision)'
                          || g_line_feed;
        g_input_where  :=    g_input_where
                          || ' and '
                          || 'decode(g_lot_number, ''-9999'', ''a'', '
                          || g_base_table_alias
                          || '.LOT_NUMBER)'
                          || ' = '
                          || 'decode(g_lot_number, ''-9999'', ''a'', g_lot_number)'
                          || g_line_feed;
       -- Bug 6719290, 6917190
      IF l_is_mat_status_used = 1 THEN
         g_input_where  :=    g_input_where
                            || ' and '
			    || ' ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null ) '
			    || ' AND exists(select 1 from mtl_material_statuses where status_id = '
			    || g_base_table_alias
			    || '.STATUS_ID'
			    || ' AND RESERVABLE_TYPE = 1)) OR '
			    || '((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL) '
			    || 'or '
                            || g_base_table_alias
                            || '.STATUS_ID IS NULL)'
			    || ' and '
                            || 'decode(g_lot_number, ''-9999'', '
			    || 'decode (INV_Pick_Release_PVT.g_pick_nonrsv_lots,1,1,' --8719074
                            || g_base_table_alias
                            || '.lotreservable), 1)'
                            || ' = 1))'
                            || g_line_feed;
      END IF ;

        g_input_where  :=    g_input_where
                          || ' and '
                          || 'decode(g_lpn_id, -9999, 1, '
                          || g_base_table_alias
                          || '.lpn_id)'
                          || ' = '
                          || 'decode(g_lpn_id, -9999, 1, g_lpn_id)'
                          || g_line_feed;
        --cost group doesn't affect finding put away locations,
        -- so only check input for pick
        g_input_where  :=    g_input_where
                          || ' and '
                          || 'decode(g_cost_group_id, -9999, 1, '
                          || g_base_table_alias
                          || '.cost_group_id)'
                          || ' = '
                          || 'decode(g_cost_group_id, -9999, 1, g_cost_group_id)'
                          || g_line_feed;
        -- Adding project_id and task_id to support PJM
        g_input_where  :=    g_input_where
                          || ' and '
                          || '(decode(g_project_id, -9999, -1, '
                          || g_base_table_alias
                          || '.project_id)'
                          || ' = '
                          || 'decode(g_project_id, -9999, -1, g_project_id)'
                          || ' OR '
                          || '( g_project_id = -7777 '
                          || ' and '
                          || g_base_table_alias
                          || '.project_id IS NULL)) '
                          || g_line_feed;
        -- If Allow Cross Project Pick is set to NO then task must be exactly equal even if NULL
        g_input_where  :=    g_input_where
                          || ' and '
                          || '(g_project_id = -9999'
                          || ' OR '
                          || 'nvl('
                          || g_base_table_alias
                          || '.task_id, -9999)'
                          || ' = '
                          || 'g_task_id'
                          || ' OR '
                          || '(g_task_id = -7777'
                          || ' and '
                          || g_base_table_alias
                          || '.task_id IS NULL))'
                          || g_line_feed;
    END IF;

    IF (p_type_code = 1) THEN
      -- Adding project_id and task_id to support PJM
      g_input_where  :=    g_input_where
                        || ' and ('
                        || 'g_project_id = '
                        || g_base_table_alias
                        || '.project_id OR '
                        || g_base_table_alias
                        || '.project_id IS NULL)'
                        || g_line_feed;
      g_input_where  :=    g_input_where
                        || ' and ('
                        || 'g_task_id = '
                        || g_base_table_alias
                        || '.task_id OR '
                        || g_base_table_alias
                        || '.task_id IS NULL)'
                        || g_line_feed;
    END IF;

    -- always join to the input table
    g_input_where    :=
                      g_input_where || ' and ' || g_input_table_alias || '.PP_TRANSACTION_TEMP_ID = ' || 'g_pp_transaction_temp_id' || g_line_feed;

    -- end of debugging section
    log_procedure(l_api_name, 'end', 'End BuildInputSql');
  --
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
  --
  END buildinputsql;

  FUNCTION isruledebugon(p_simulation_mode IN NUMBER)
    RETURN BOOLEAN IS
    l_return_value BOOLEAN;
    l_debug NUMBER;
  BEGIN
   IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
    l_debug := g_debug;
    IF p_simulation_mode <> wms_engine_pvt.g_no_simulation THEN
      l_return_value  := TRUE;
    ELSIF  p_simulation_mode = wms_engine_pvt.g_no_simulation THEN
      if l_debug = 1 THEN
         l_return_value  := TRUE;
      ELSE
         l_return_value  := FALSE;
      END IF;
    ELSE
      null;
      --l_return_value  := fnd_log.test(log_level => fnd_log.level_unexpected, module => 'wms.plsql.' || g_pkg_name || '.' || 'Apply.test');
    END IF;

    IF l_return_value THEN
      if l_debug = 1 THEN
       log_statement('IsRuleDebugOn', 'true', 'Debug is on');
      END IF;
    ELSE
      IF l_debug = 1 THEN
         log_statement('IsRuleDebugOn', 'false', 'Debug is off');
      END IF;
    END IF;

    RETURN l_return_value;
  END isruledebugon;

  --
  -- Name        : FetchCursor
  -- Function    : Fetches one record at a time from the Rule's
  --     SQL statement, using the rule API
  -- Pre-reqs    : cursor has to be parsed and executed already.
  -- Notes       : private procedure for internal use only
  --
  PROCEDURE fetchcursor(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_cursor              IN            wms_rule_pvt.cv_pick_type
  , p_rule_id             IN            NUMBER
  , x_revision            OUT NOCOPY    VARCHAR2
  , x_lot_number          OUT NOCOPY    VARCHAR2
  , x_lot_expiration_date OUT NOCOPY    DATE
  , x_subinventory_code   OUT NOCOPY    VARCHAR2
  , x_locator_id          OUT NOCOPY    NUMBER
  , x_cost_group_id       OUT NOCOPY    NUMBER
  , x_uom_code            OUT NOCOPY    VARCHAR2
  , x_lpn_id              OUT NOCOPY    NUMBER
  , x_serial_number       OUT NOCOPY    VARCHAR2
  , x_possible_quantity   OUT NOCOPY    NUMBER
  , x_sec_possible_quantity  OUT NOCOPY NUMBER
  , x_grade_code             OUT NOCOPY VARCHAR2
  , x_consist_string      OUT NOCOPY    VARCHAR2
  , x_order_by_string     OUT NOCOPY    VARCHAR2
  , x_rows                OUT NOCOPY    NUMBER
  ) IS
    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);

    l_list_pkg     VARCHAR2(30);

    l_api_name     VARCHAR2(30)  := 'FetchCursor';
    l_rows         NUMBER;
    l_func_sql     VARCHAR(1000);
    l_cursor       NUMBER;
    l_dummy        NUMBER;
    l_package_name VARCHAR2(128);
    l_ctr          NUMBER        := 0;

    l_debug        NUMBER;

  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    --get package name based on rule id
    getpackagename(p_rule_id, l_package_name);
    --- calling the static fetch cursor. The name of the rule package will be
    --- determined based on the rule_id
    --- If the ctr is 1 then there is no subscript ,
    --- if ctr = 2 then subscript = 1
    --- and if ctr = 3 then subscript = 2, this script is added to the package
    --- name.


    l_ctr := wms_rule_pvt.g_rule_list_pick_ctr;
    l_list_pkg   :=  'wms_rule_pick_pkg' || l_ctr ;

    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF l_debug = 1  THEN
       log_procedure(l_api_name, 'start', 'Start FetchCursor');
    END IF;

    IF (l_ctr = 1) THEN

      wms_rule_pick_pkg1.execute_fetch_rule(
        p_cursor
      , p_rule_id
      , x_revision
      , x_lot_number
      , x_lot_expiration_date
      , x_subinventory_code
      , x_locator_id
      , x_cost_group_id
      , x_uom_code
      , x_lpn_id
      , x_serial_number
      , x_possible_quantity
      , x_sec_possible_quantity
      , x_grade_code
      , x_consist_string
      , x_order_by_string
      , x_rows
      );
    ELSIF (l_ctr = 2) THEN

      wms_rule_pick_pkg2.execute_fetch_rule(
        p_cursor
      , p_rule_id
      , x_revision
      , x_lot_number
      , x_lot_expiration_date
      , x_subinventory_code
      , x_locator_id
      , x_cost_group_id
      , x_uom_code
      , x_lpn_id
      , x_serial_number
      , x_possible_quantity
      , x_sec_possible_quantity
      , x_grade_code
      , x_consist_string
      , x_order_by_string
      , x_rows
      );
    ELSIF (l_ctr = 3) THEN
      wms_rule_pick_pkg3.execute_fetch_rule(
        p_cursor
      , p_rule_id
      , x_revision
      , x_lot_number
      , x_lot_expiration_date
      , x_subinventory_code
      , x_locator_id
      , x_cost_group_id
      , x_uom_code
      , x_lpn_id
      , x_serial_number
      , x_possible_quantity
      , x_sec_possible_quantity
      , x_grade_code
      , x_consist_string
      , x_order_by_string
      , x_rows
      );
    END IF;

    l_rows           := x_rows;

    IF l_rows = 0 THEN --no row found
      x_revision             := NULL;
      x_lot_number           := NULL;
      x_lot_expiration_date  := NULL;
      x_subinventory_code    := NULL;
      x_locator_id           := NULL;
      x_cost_group_id        := NULL;
      x_uom_code             := NULL;
      x_lpn_id               := NULL;
      x_serial_number        := NULL;
      x_possible_quantity    := 0;
      x_consist_string       := NULL;
      x_order_by_string      := NULL;


      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_PICK_NO_ROWS'  ;

      IF l_debug = 1 THEN
         log_event(l_api_name, 'no_rows_found', 'No more rows for rule ' || p_rule_id);
	 log_event(l_api_name, 'no_rows_found', 'No more rows for rule ' || WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE);
       END IF;

    END IF;

    x_rows := l_rows;
    --

    IF l_debug = 1 THEN
         log_procedure(l_api_name, 'end', 'End FetchCursor');
    END IF;
  --
  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'execute_fetch_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
  END fetchcursor;

  --
  -- Name        : FetchPutAway
  -- Function    : Fetches one record at a time from the Rule's
  --     SQL statement, using the rule API. Called from putaway
  -- Pre-reqs    : cursor has to be parsed and executed already.
  -- Notes       : private procedure for internal use only
  --
  PROCEDURE fetchputaway(
    x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , p_cursor            IN            wms_rule_pvt.cv_put_type
  , p_rule_id           IN            NUMBER
  , x_subinventory_code OUT NOCOPY    VARCHAR2
  , x_locator_id        OUT NOCOPY    NUMBER
  , x_project_id        OUT NOCOPY    NUMBER
  , x_task_id           OUT NOCOPY    NUMBER
  , x_rows              OUT NOCOPY    NUMBER
  ) IS
    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);

    l_list_pkg     VARCHAR2(30);

    l_api_name     VARCHAR2(30)  := 'FetchPutaway';
    l_rows         NUMBER;
    l_func_sql     VARCHAR(1000);
    l_cursor       NUMBER;
    l_dummy        NUMBER;
    l_package_name VARCHAR2(128);
    l_ctr          NUMBER        := 0;

    l_debug        NUMBER;


  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

   IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;
   l_debug := g_debug;

   IF l_debug = 1 THEN
      log_procedure(l_api_name, 'start', 'Start FetchPutaway');
      log_procedure(l_api_name, 'start', 'Putaway rule id '||p_rule_id);
   END IF;

    --get package name based on rule id
    getpackagename(p_rule_id, l_package_name);
    l_ctr            := wms_rule_pvt.g_rule_list_put_ctr;
    l_list_pkg :=  'wms_rule_put_pkg' || l_ctr ;

    IF (l_ctr = 1) THEN
      wms_rule_put_pkg1.execute_fetch_rule
                    (p_cursor
                    , p_rule_id
                    , x_subinventory_code
                    , x_locator_id
                    , x_project_id
                    , x_task_id
                    , x_rows);
    ELSIF (l_ctr = 2) THEN
      wms_rule_put_pkg2.execute_fetch_rule
                    (p_cursor
                    , p_rule_id
                    , x_subinventory_code
                    , x_locator_id
                    , x_project_id
                    , x_task_id
                    , x_rows);
    ELSIF (l_ctr = 3) THEN
      wms_rule_put_pkg3.execute_fetch_rule
                    (p_cursor
                    , p_rule_id
                    , x_subinventory_code
                    , x_locator_id
                    , x_project_id
                    , x_task_id
                    , x_rows);
    END IF;

    --------
    --l_rows           := x_rows;
    IF l_debug = 1 THEN
       log_event(l_api_name, '*************************', '');
       log_event(l_api_name, 'x_subinventory_code', x_subinventory_code);
       log_event(l_api_name, 'x_locator_id', x_locator_id);
     END IF;


    IF  l_rows  = 0 THEN --no row found
      x_subinventory_code  := NULL;
      x_locator_id         := NULL;
      x_project_id         := NULL;
      x_task_id            := NULL;

      -- Bug # 3185073
      --WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_PUT_NO_ROWS';

      IF l_debug = 1 THEN
         log_event(l_api_name, 'no_rows_found', 'No more rows for rule ' || p_rule_id);
      END IF;

      IF ( WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE = 'WMS_PICK_NO_ROWS' or
           WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE = NULL) then

           WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_PUT_NO_ROWS';
      END IF;

       IF l_debug = 1 THEN
          log_event(l_api_name, 'no_rows_found', 'No more rows for rule ' || WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE);
       END IF;

    END IF;
    --x_rows           := l_rows;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'put_sub',
                'Subinventory: ' || x_subinventory_code);
             log_statement(l_api_name, 'put_loc',
                'Locator: ' || x_locator_id);
             log_statement(l_api_name, 'put_proj',
                'Project: ' || x_project_id);
             log_statement(l_api_name, 'put_task',
                'Task: ' || x_task_id);
             log_statement(l_api_name, 'rows',
                'Rows Returned: ' || x_rows);
          END IF;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End FetchPutaway');
    END IF;
  --
  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;

      IF l_debug = 1 THEN
         log_error(l_api_name, 'execute_fetch_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
  END fetchputaway;

  ------------
  ---
  ---  Procedures to handle the static calls to open, fetch and close cursor
  ---  based on the Rule_id. The name of the API_call is decided based on the the
  ---  flag retrived from the table.
  ---
  --- For Pick rules

  PROCEDURE pick_open_rule(
    p_cursor                 IN OUT NOCOPY wms_rule_pvt.cv_pick_type
  , p_rule_id                IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_inventory_item_id      IN            NUMBER
  , p_transaction_type_id    IN            NUMBER
  , p_revision               IN            VARCHAR2
  , p_lot_number             IN            VARCHAR2
  , p_subinventory_code      IN            VARCHAR2
  , p_locator_id             IN            NUMBER
  , p_cost_group_id          IN            NUMBER
  , p_pp_transaction_temp_id IN            NUMBER
  , p_serial_controlled      IN            NUMBER
  , p_detail_serial          IN            NUMBER
  , p_detail_any_serial      IN            NUMBER
  , p_from_serial_number     IN            VARCHAR2
  , p_to_serial_number       IN            VARCHAR2
  , p_unit_number            IN            VARCHAR2
  , p_lpn_id                 IN            NUMBER
  , p_project_id             IN            NUMBER
  , p_task_id                IN            NUMBER
  , x_result                 OUT NOCOPY    NUMBER
  ) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);

    l_list_pkg     VARCHAR2(30);
    l_package_name VARCHAR2(128);
    l_ctr NUMBER := 0;

    l_debug        NUMBER;

  BEGIN

    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF wms_rule_pvt.g_rule_list_pick_ctr IS NULL THEN
       wms_rule_pvt.g_rule_list_pick_ctr :=  wms_rule_gen_pkgs.get_count_no_lock('PICK');
    END IF;
    l_ctr := wms_rule_pvt.g_rule_list_pick_ctr;

    l_list_pkg :=  'wms_rule_pick_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN

         IF l_debug = 1 THEN
            log_statement(l_api_name, ' wms_rule_pick_pkg1.execute_open_rule', l_ctr);
         END IF;
      wms_rule_pick_pkg1.execute_open_rule(
        p_cursor
      , p_rule_id
      , p_organization_id
      , p_inventory_item_id
      , p_transaction_type_id
      , p_revision
      , p_lot_number
      , p_subinventory_code
      , p_locator_id
      , p_cost_group_id
      , p_pp_transaction_temp_id
      , p_serial_controlled
      , p_detail_serial
      , p_detail_any_serial
      , p_from_serial_number
      , p_to_serial_number
      , p_unit_number
      , p_lpn_id
      , p_project_id
      , p_task_id
      , x_result
      );
    ELSIF (l_ctr = 2) THEN

        IF l_debug = 1 THEN
           log_statement(l_api_name, ' wms_rule_pick_pkg2.execute_open_rule', l_ctr);
        END IF;

      wms_rule_pick_pkg2.execute_open_rule(
        p_cursor
      , p_rule_id
      , p_organization_id
      , p_inventory_item_id
      , p_transaction_type_id
      , p_revision
      , p_lot_number
      , p_subinventory_code
      , p_locator_id
      , p_cost_group_id
      , p_pp_transaction_temp_id
      , p_serial_controlled
      , p_detail_serial
      , p_detail_any_serial
      , p_from_serial_number
      , p_to_serial_number
      , p_unit_number
      , p_lpn_id
      , p_project_id
      , p_task_id
      , x_result
      );
    ELSIF (l_ctr = 3) THEN
       IF l_debug = 1 THEN
          log_statement(l_api_name, ' wms_rule_pick_pkg3.execute_open_rule', l_ctr);
       END IF;

      wms_rule_pick_pkg3.execute_open_rule(
        p_cursor
      , p_rule_id
      , p_organization_id
      , p_inventory_item_id
      , p_transaction_type_id
      , p_revision
      , p_lot_number
      , p_subinventory_code
      , p_locator_id
      , p_cost_group_id
      , p_pp_transaction_temp_id
      , p_serial_controlled
      , p_detail_serial
      , p_detail_any_serial
      , p_from_serial_number
      , p_to_serial_number
      , p_unit_number
      , p_lpn_id
      , p_project_id
      , p_task_id
      , x_result
      );
    END IF;

  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      x_result := 0;
      wms_rule_pvt.g_rule_list_pick_ctr :=  wms_rule_gen_pkgs.get_count_no_lock('PICK');

      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;

      IF l_debug = 1 THEN
         log_error(l_api_name, 'execute_open_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);

      END IF;
  END pick_open_rule;

  ---
  ---  Procedure Fetchcursor() is modified to handle static call to fetch a row from the
  ---  opened picking cursor

  ----------------

  PROCEDURE put_open_rule(
    p_cursor                 IN OUT NOCOPY wms_rule_pvt.cv_put_type
  , p_rule_id                IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_inventory_item_id      IN            NUMBER
  , p_transaction_type_id    IN            NUMBER
  , p_subinventory_code      IN            VARCHAR2
  , p_locator_id             IN            NUMBER
  , p_pp_transaction_temp_id IN            NUMBER
  , p_restrict_subs_code     IN            NUMBER
  , p_restrict_locs_code     IN            NUMBER
  , p_project_id             IN            NUMBER
  , p_task_id                IN            NUMBER
  , x_result                 OUT NOCOPY    NUMBER
  ) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);

    l_list_pkg     VARCHAR2(30);
    l_package_name VARCHAR2(128);
    l_ctr NUMBER := 0;

    l_debug       NUMBER;

  BEGIN

    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
           g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    if wms_rule_pvt.g_rule_list_put_ctr is null then
       wms_rule_pvt.g_rule_list_put_ctr  :=  wms_rule_gen_pkgs.get_count_no_lock('PUTAWAY');
    end if;
    l_ctr := wms_rule_pvt.g_rule_list_put_ctr;

    l_list_pkg :=  'wms_rule_put_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN
      wms_rule_put_pkg1.execute_open_rule(
        p_cursor
      , p_rule_id
      , p_organization_id
      , p_inventory_item_id
      , p_transaction_type_id
      , p_subinventory_code
      , p_locator_id
      , p_pp_transaction_temp_id
      , p_restrict_subs_code
      , p_restrict_locs_code
      , p_project_id
      , p_task_id
      , x_result
      );
    ELSIF (l_ctr = 2) THEN
      wms_rule_put_pkg2.execute_open_rule(
        p_cursor
      , p_rule_id
      , p_organization_id
      , p_inventory_item_id
      , p_transaction_type_id
      , p_subinventory_code
      , p_locator_id
      , p_pp_transaction_temp_id
      , p_restrict_subs_code
      , p_restrict_locs_code
      , p_project_id
      , p_task_id
      , x_result
      );
    ELSIF (l_ctr = 3) THEN
      wms_rule_put_pkg3.execute_open_rule(
        p_cursor
      , p_rule_id
      , p_organization_id
      , p_inventory_item_id
      , p_transaction_type_id
      , p_subinventory_code
      , p_locator_id
      , p_pp_transaction_temp_id
      , p_restrict_subs_code
      , p_restrict_locs_code
      , p_project_id
      , p_task_id
      , x_result
      );
    END IF;

  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      x_result := 0;
      wms_rule_pvt.g_rule_list_put_ctr :=  wms_rule_gen_pkgs.get_count_no_lock('PUTAWAY');

      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;

      IF l_debug = 1 THEN
         log_error(l_api_name, 'execute_open_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);
      END IF;
  END put_open_rule;

  -----------------
  ---  Procedure FetchPutaway() is modified to handle static call to fetch a row from the
  ---  opened Putaway cursor

  PROCEDURE execute_op_rule(p_rule_id IN NUMBER, p_task_id IN NUMBER, x_return_status OUT NOCOPY NUMBER) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);
    l_list_pkg      VARCHAR2(30);
    l_package_name  VARCHAR2(128);
    l_ctr 	    NUMBER := 0;

  BEGIN
    if wms_rule_pvt.g_rule_list_op_ctr is null then
       wms_rule_pvt.g_rule_list_op_ctr :=  wms_rule_gen_pkgs.get_count_no_lock('OPERATION_PLAN');
    end if;
    l_ctr := wms_rule_pvt.g_rule_list_op_ctr;

    l_list_pkg :=  'wms_rule_op_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN
      wms_rule_op_pkg1.execute_op_rule(p_rule_id, p_task_id, x_return_status);
    ELSIF (l_ctr = 2) THEN
      wms_rule_op_pkg2.execute_op_rule(p_rule_id, p_task_id, x_return_status);
    ELSIF (l_ctr = 3) THEN
      wms_rule_op_pkg3.execute_op_rule(p_rule_id, p_task_id, x_return_status);
    END IF;
    IF x_return_status  IS NULL THEN
           x_return_status := 1;
    END IF;
  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
       --x_return_status := 0;
       x_return_status := -1 ;
      wms_rule_pvt.g_rule_list_op_ctr :=   wms_rule_gen_pkgs.get_count_no_lock('OPERATION_PLAN');
      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      /*log_error(l_api_name, 'execute_op_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name); */
  END execute_op_rule;

  ----- Open cursor and fetch cursor for task rules

  PROCEDURE execute_task_rule(p_rule_id IN NUMBER, p_task_id IN NUMBER, x_return_status OUT NOCOPY NUMBER) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);

    l_list_pkg     VARCHAR2(30);
    l_package_name VARCHAR2(128);

    l_ctr NUMBER := 0;


  BEGIN
     if wms_rule_pvt.g_rule_list_task_ctr is null then
        wms_rule_pvt.g_rule_list_task_ctr :=   wms_rule_gen_pkgs.get_count_no_lock('TASK');
     end if;
     l_ctr := wms_rule_pvt.g_rule_list_task_ctr;

    l_list_pkg :=  'wms_rule_task_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN
      wms_rule_task_pkg1.execute_task_rule(p_rule_id, p_task_id, x_return_status);
    ELSIF (l_ctr = 2) THEN
      wms_rule_task_pkg2.execute_task_rule(p_rule_id, p_task_id, x_return_status);
    ELSIF (l_ctr = 3) THEN
      wms_rule_task_pkg3.execute_task_rule(p_rule_id, p_task_id, x_return_status);
    END IF;
    IF x_return_status  IS NULL THEN
       x_return_status := 1;
    END IF;
  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      --x_return_status := 0;
      x_return_status := -1 ;
      wms_rule_pvt.g_rule_list_task_ctr :=   wms_rule_gen_pkgs.get_count_no_lock('TASK');
      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      /*log_error(l_api_name, 'execute_task_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name); */

  END execute_task_rule;

  ---

  ----- Open cursor and fetch cursor for task rules

  PROCEDURE execute_label_rule(p_rule_id IN NUMBER, p_label_request_id IN NUMBER, x_return_status OUT NOCOPY NUMBER) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);

    l_list_pkg     VARCHAR2(30);
    l_package_name VARCHAR2(128);
    l_ctr NUMBER := 0;

  BEGIN

    if wms_rule_pvt.g_rule_list_label_ctr is null then
       wms_rule_pvt.g_rule_list_label_ctr := wms_rule_gen_pkgs.get_count_no_lock('LABEL');
    end if;
    l_ctr := wms_rule_pvt.g_rule_list_label_ctr;

    l_list_pkg :=  'wms_rule_label_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN
      wms_rule_label_pkg1.execute_label_rule(p_rule_id, p_label_request_id, x_return_status);
    ELSIF (l_ctr = 2) THEN
      wms_rule_label_pkg2.execute_label_rule(p_rule_id, p_label_request_id, x_return_status);
    ELSIF (l_ctr = 3) THEN
      wms_rule_label_pkg3.execute_label_rule(p_rule_id, p_label_request_id, x_return_status);
    END IF;

    IF x_return_status  IS NULL THEN
           x_return_status := 1;
    END IF;
  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      --x_return_status := 0;
      x_return_status := -1 ;
      wms_rule_pvt.g_rule_list_label_ctr := wms_rule_gen_pkgs.get_count_no_lock('LABEL');
      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      /*log_error(l_api_name, 'execute_label_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name); */

  END execute_label_rule;

  ---  Procedure to Close Pick rule Cursor --
  ---

  PROCEDURE close_pick_rule(p_rule_id IN NUMBER, p_cursor IN OUT NOCOPY wms_rule_pvt.cv_pick_type) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);

    l_list_pkg     VARCHAR2(30);
    l_package_name VARCHAR2(128);

    l_ctr NUMBER := 0;

  BEGIN

    l_ctr := wms_rule_pvt.g_rule_list_pick_ctr;
    l_list_pkg :=  'wms_rule_pick_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN
      wms_rule_pick_pkg1.execute_close_rule(p_rule_id, p_cursor);
    ELSIF (l_ctr = 2) THEN
      wms_rule_pick_pkg2.execute_close_rule(p_rule_id, p_cursor);
    ELSIF (l_ctr = 3) THEN
      wms_rule_pick_pkg3.execute_close_rule(p_rule_id, p_cursor);
    END IF;

  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
    /* -- WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      log_error(l_api_name, 'execute_close_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name); */
       RAISE fnd_api.g_exc_unexpected_error;
  END close_pick_rule;

  -- Procedure to close Putaway rule Cursor ---
  --
  PROCEDURE close_put_rule(p_rule_id IN NUMBER, p_cursor IN OUT NOCOPY wms_rule_pvt.cv_put_type) IS

    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_api_name      VARCHAR2(30);
    l_list_pkg     VARCHAR2(30);
    l_package_name VARCHAR2(128);
    l_ctr NUMBER := 0;
  BEGIN
    l_ctr := wms_rule_pvt.g_rule_list_put_ctr;
    l_list_pkg :=  'wms_rule_put_pkg' || l_ctr ;
    getpackagename(p_rule_id, l_package_name);

    IF (l_ctr = 1) THEN
      wms_rule_put_pkg1.execute_close_rule(p_rule_id, p_cursor);
    ELSIF (l_ctr = 2) THEN
      wms_rule_put_pkg2.execute_close_rule(p_rule_id, p_cursor);
    ELSIF (l_ctr = 3) THEN
      wms_rule_put_pkg3.execute_close_rule(p_rule_id, p_cursor);
    END IF;

  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
     /*WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'Invalid Package, Contact your DBA - '|| l_list_pkg || ' / ' || l_package_name;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      log_error(l_api_name, 'execute_close_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);*/
      RAISE fnd_api.g_exc_unexpected_error;
  END close_put_rule;

  --------------
  --
  -- Name        : Rollback_Capacity_Update
  -- Function    : Used in Apply for Put Away rules.
  --     In Apply, the update_loc_suggested_capacity procedure gets
  --     called to update the capacity for a locator.  This
  --     procedure is an autonomous transaction, so it issues
  --     a commit.  If some sort of error occurs in Apply, we need to
  --     undo those changes.  We call revert_loc_suggested_capacity
  --     to decrement the suggested capacity field.  The procedure
  --     is also a autonomous transaction
  -- Pre-reqs    : cursor has to be parsed and executed already.
  -- Notes       : private procedure for internal use only
  --
  PROCEDURE rollback_capacity_update(
    x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , p_organization_id   IN            NUMBER
  , p_inventory_item_id IN            NUMBER
  ) IS
    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(240);
    l_msg_count     NUMBER;
    l_no_error      BOOLEAN;
    l_api_name      VARCHAR2(30)  := 'rollback_capacity_update';

    l_debug         NUMBER;

    -- gets all of the put away suggestions already created;
    -- The locator capacity would have been updated for each of these
    -- records
    -- type_code 1 = put away; line_type_code 2 = output
    CURSOR l_output_lines IS
      SELECT   to_locator_id
             , SUM(primary_quantity) quantity
          FROM wms_transactions_temp
         WHERE type_code = 1
           AND line_type_code = 2
      GROUP BY to_locator_id;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    If l_debug  = 1 THEN
       log_procedure(l_api_name, 'start', 'Start rollback_capacity_update');
    END IF;

    l_return_status  := fnd_api.g_ret_sts_success;
    l_no_error       := TRUE;

    FOR l_line IN l_output_lines LOOP
      -- We don't track capacity at Subinventory level, so no need
      -- to update if locator_id is null
      IF l_line.to_locator_id IS NOT NULL THEN

        IF l_debug = 1 THEN
           log_statement(l_api_name, 'calling_revert', 'Calling inv_loc_wms_utils.revert_loc_suggested_capacity');
           log_statement(l_api_name, 'revert_org', 'Org: ' || p_organization_id);
           log_statement(l_api_name, 'revert_item', 'Item: ' || p_inventory_item_id);
           log_statement(l_api_name, 'revert_loc', 'Loc: ' || l_line.to_locator_id);
           log_statement(l_api_name, 'revert_qty', 'Qty: ' || l_line.quantity);
        END IF;
        inv_loc_wms_utils.revert_loc_suggested_capacity(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_organization_id
        , p_inventory_location_id      => l_line.to_locator_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_primary_uom_flag           => 'Y'
        , p_transaction_uom_code       => NULL
        , p_quantity                   => l_line.quantity
        );

        --return only the first error message
        IF  l_no_error
            AND l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status  := l_return_status;
          x_msg_count      := l_msg_count;
          x_msg_data       := l_msg_data;
          l_no_error       := FALSE;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'first_error', 'Error in inv_loc_wms_utils.revert_loc_suggested_capacity');
          END IF;
       END IF;
     END IF;
    END LOOP;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End rollback_capacity_update');
    END IF;

   EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;
   END rollback_capacity_update;

  -- Bug# 4099907 -- Modifying the fix done in the Bug 3609380
  -- Pass the value for transfer_to_sub incase of Subinventory transfer
  -- allocations (i.e. with transaction action as 2)
  -- Private function
  FUNCTION chk_for_passing_xfer_sub
               (   p_transaction_temp_id   IN  NUMBER
                 , p_to_subinventory_code  IN  VARCHAR2
               )
  RETURN VARCHAR2
  IS
   l_to_subinventory_code     MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE := NULL ;
   l_transaction_action_id    NUMBER := 0 ;
   l_debug                    NUMBER := g_debug ;
   l_api_name                 VARCHAR2(30) := 'chk_for_passing_xfer_sub';
   l_transaction_type_id      NUMBER := 0 ;

  BEGIN

    IF inv_cache.set_mol_rec(p_transaction_temp_id) THEN
     l_transaction_type_id  := inv_cache.mol_rec.transaction_type_id;
    END IF;

    IF l_transaction_type_id <> 0 THEN
     IF inv_cache.set_mtt_rec(l_transaction_type_id) THEN
       l_transaction_action_id := inv_cache.mtt_rec.transaction_action_id;
     END IF;
    END IF;

    IF l_transaction_action_id = 2 THEN
      l_to_subinventory_code := p_to_subinventory_code;
    END IF;

    IF l_debug = 1  THEN
      log_statement(l_api_name, 'l_transaction_action_id', 'l_transaction_action_id : ' || l_transaction_action_id );
      log_statement(l_api_name, 'l_to_subinventory_code', 'l_to_subinventory_code: ' || l_to_subinventory_code);
    END IF;

    RETURN l_to_subinventory_code ;

  END chk_for_passing_xfer_sub ;
  -- End of function definition for fixing Bug 4099907

  PROCEDURE validate_and_insert(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_record_id              IN            NUMBER
  , p_needed_quantity        IN            NUMBER
  , p_use_pick_uom           IN            BOOLEAN
  , p_organization_id        IN            NUMBER
  , p_inventory_item_id      IN            NUMBER
  , p_to_subinventory_code   IN            VARCHAR2
  , p_to_locator_id          IN            NUMBER
  , p_to_cost_group_id       IN            NUMBER
  , p_primary_uom            IN            VARCHAR2
  , p_transaction_uom        IN            VARCHAR2
  , p_transaction_temp_id    IN            NUMBER
  , p_type_code              IN            NUMBER
  , p_rule_id                IN            NUMBER
  , p_reservation_id         IN            NUMBER
  , p_tree_id                IN            NUMBER
  , p_debug_on               IN            BOOLEAN
  , p_needed_sec_quantity    IN            NUMBER                        -- new
  , p_secondary_uom          IN            VARCHAR2                      -- new
  , p_grade_code             IN            VARCHAR2                      -- new
  , x_inserted_record        OUT NOCOPY    BOOLEAN
  , x_allocated_quantity     OUT NOCOPY    NUMBER
  , x_remaining_quantity     OUT NOCOPY    NUMBER
  , x_sec_allocated_quantity OUT NOCOPY    NUMBER                         -- new
  , x_sec_remaining_quantity OUT NOCOPY    NUMBER                         -- new
  ) IS
    l_api_name                  VARCHAR2(30) := 'validate_and_insert';
    l_qoh                       NUMBER;
    l_rqoh                      NUMBER;
    l_qr                        NUMBER;
    l_qs                        NUMBER;
    l_att                       NUMBER;
    l_atr                       NUMBER;
    l_allocation_quantity       NUMBER;
    l_sqoh                      NUMBER;
    l_srqoh                     NUMBER;
    l_sqr                       NUMBER;
    l_sqs                       NUMBER;
    l_satt                      NUMBER;
    l_satr                      NUMBER;
    l_sallocation_quantity      NUMBER;
    l_orig_allocation_quantity  NUMBER;
    l_sorig_allocation_quantity NUMBER;
    l_found                     BOOLEAN;
    l_possible_uom_qty          NUMBER;
    l_possible_trx_qty          NUMBER;
    l_sec_possible_trx_qty      NUMBER;
    l_serial_index              NUMBER;
    l_lot_divisible_flag        VARCHAR2(1);
    l_lot_control_code          NUMBER;
    l_to_locator_id             NUMBER;
    l_dual_uom_ctl              NUMBER;
    l_rsv_id                    NUMBER;
    -- Added for bug 8665496
    l_rsv_lot_number            VARCHAR2(80);
    l_rsv_qty                   NUMBER;
    l_rsv_dtl_qty               NUMBER;
    l_rsv_uom                   VARCHAR2(3);
    l_sec_rsv_qty               NUMBER;
    l_sec_dtl_qty               NUMBER;

    l_debug                   NUMBER;
    l_indiv_lot_allowed       VARCHAR2(1);


    -- Added for Bug 8570601 start
    l_to_subinventory_code       VARCHAR2(10);
    l_transaction_type_id        NUMBER;
    l_transaction_action_id      NUMBER;
    l_transaction_source_type_id NUMBER;
    -- Added for Bug 8570601 end

    --
    -- start bug 8638386
    l_lot_sallocation_quantity   NUMBER;
    l_pri_res_qty                NUMBER;
    lot_conv_factor_flag         PLS_INTEGER;
    l_are_qties_valid            PLS_INTEGER;

    CURSOR check_if_lot_conv_exists IS
    SELECT count(*)
      FROM mtl_lot_uom_class_conversions
     WHERE lot_number        = g_locs(p_record_id).lot_number
       AND inventory_item_id = p_inventory_item_id
       AND organization_id   = p_organization_id
       AND (disable_date IS NULL or disable_date > sysdate);
    --
    -- end bug 8638386

    -- 8809951 commented the below cursor
   /* CURSOR C_item_info IS
      SELECT lot_divisible_flag
          ,  lot_control_code
          ,  dual_uom_control
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;*/

    CURSOR c_detailed_reservation IS
      SELECT reservation_id
      -- Added for bug 8665496
           , lot_number
           , reservation_quantity
           , detailed_quantity
           , reservation_uom_code
           , secondary_reservation_quantity
           , secondary_detailed_quantity
        FROM mtl_reservations
       WHERE reservation_id = p_reservation_id;
      -- and lot_number = g_locs(p_record_id).lot_number; -- Bug 7587155 - the reservation could be
                                                          -- high level rather than detail.

  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    x_return_status             := fnd_api.g_ret_sts_success;
    l_allocation_quantity       := p_needed_quantity;
    l_sallocation_quantity      := p_needed_sec_quantity;
    l_to_locator_id             := p_to_locator_id;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'validate and insert', 'Start Validate_And_Insert');
    END IF;

    /*
    Open C_item_info;
    Fetch C_item_info
    Into l_lot_divisible_flag
      ,  l_lot_control_code
      ,  l_dual_uom_ctl
      ;
    Close C_item_info;
    */
     -- [ Added the following code and commented the above item cursor
     l_lot_divisible_flag  	:= inv_cache.item_rec.lot_divisible_flag;
     l_lot_control_code    	:= inv_cache.item_rec.lot_control_code;
     l_dual_uom_ctl             := inv_cache.item_rec.dual_uom_control;
     l_rsv_id                   := 0;
     -- ]
    /* lot specific conversion  3986955*/
    IF (l_dual_uom_ctl > 1 AND inv_cache.item_rec.tracking_quantity_ind = 'PS')
    -- Bug 7587155 - item could be PS but not lot controlled!
    -- and nvl(g_locs(p_record_id).lot_number,'-9999') <> '-9999'
    THEN --
      /* bug 5441849, if detailed reservation exist, meaning that user has made the
       * correct 2nd qty either by system defaults on the lot
       * or manually changed it with the appropriate value, this value on the reservation
       * should be carried over to the allocation
       */

       -- Bug 8247123: check if sec qty already allocated.  This can happen
       -- either from other locators for the current pick rule, or from previous rules.
       IF g_sec_alloc_qty.EXISTS(p_reservation_id) THEN
          l_rsv_id := p_reservation_id;
       ELSE
          OPEN c_detailed_reservation;
          FETCH c_detailed_reservation
           INTO l_rsv_id
              , l_rsv_lot_number
              , l_rsv_qty
              , l_rsv_dtl_qty
              , l_rsv_uom
              , l_sec_rsv_qty
              , l_sec_dtl_qty;
          CLOSE c_detailed_reservation;
          IF NVL(l_rsv_id,0) > 0 THEN
             IF l_debug = 1 THEN
                log_statement(l_api_name,'reservation exists for dual UOM item.','');
                log_statement(l_api_name,'l_rsv_id        ', l_rsv_id);
                log_statement(l_api_name,'l_rsv_lot_number', l_rsv_lot_number);
                log_statement(l_api_name,'l_rsv_qty       ', l_rsv_qty);
                log_statement(l_api_name,'l_rsv_dtl_qty   ', l_rsv_dtl_qty);
                log_statement(l_api_name,'l_rsv_uom       ', l_rsv_uom);
                log_statement(l_api_name,'l_sec_rsv_qty   ', l_sec_rsv_qty);
                log_statement(l_api_name,'l_sec_dtl_qty   ', l_sec_dtl_qty);
             END IF;
             -- Added for bug 8665496
             IF l_rsv_uom <> p_primary_uom THEN
                l_pri_res_qty := inv_convert.inv_um_convert
 	                                      ( item_id          => p_inventory_item_id
 	                                      , lot_number       => l_rsv_lot_number
 	                                      , organization_id  => p_organization_id
 	                                      , precision        => NULL
 	                                      , from_quantity    => l_rsv_qty -- only rsv qty is in rsv uom bug 8638386.
 	                                      , from_unit        => l_rsv_uom
 	                                      , to_unit          => p_primary_uom
 	                                      , from_name        => NULL
 	                                      , to_name          => NULL
 	                                      );
                IF (l_pri_res_qty = -99999) THEN
                   IF l_debug = 1 THEN
                      log_statement(l_api_name, '(1)lot uom conversion error','');
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                   fnd_msg_pub.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF l_debug = 1 THEN
                   log_statement(l_api_name,'l_pri_res_qty   ', l_pri_res_qty);
                END IF;
             ELSE
                l_pri_res_qty          := l_rsv_qty;
 	     END IF;
 	     g_alloc_qty(l_rsv_id)     := l_pri_res_qty - NVL(l_rsv_dtl_qty,0);
             g_sec_alloc_qty(l_rsv_id) := l_sec_rsv_qty - NVL(l_sec_dtl_qty,0);
          ELSE
             l_rsv_id := 0;
          END IF;
       END IF; -- end of g_sec_alloc_qty.EXISTS(p_reservation_id)

       -- bug 8638386 - Start - reorganize/extend fix 8665496 - for lot conversion + deviation
       IF l_rsv_id > 0 THEN -- {
          IF l_debug = 1 THEN
             log_statement(l_api_name,'p_needed_quantity                 ', p_needed_quantity);
             log_statement(l_api_name,'p_needed_sec_quantity             ', p_needed_sec_quantity);
             log_statement(l_api_name,'remaining pri [g_alloc_qty(l_rsv_id)]    ', g_alloc_qty(l_rsv_id));
             log_statement(l_api_name,'remaining sec [g_sec_alloc_qty(l_rsv_id)]', g_sec_alloc_qty(l_rsv_id));
             log_statement(l_api_name,'l_rsv_lot_number                  ', l_rsv_lot_number);
          END IF;
          --
          -- see if the reservation is high level or detailed at lot level.
          --
          IF (l_rsv_lot_number IS NOT NULL) THEN
             --
             -- lot level reservation exists
             --   may or may not have a lot specific conversion
             --     user may or may not have played with the deviation on top.
             --
             IF g_alloc_qty(l_rsv_id) > p_needed_quantity THEN
                -- distribute sec in the same ratio as primary
 	        l_sallocation_quantity :=
 	           ROUND((p_needed_quantity/g_alloc_qty(l_rsv_id)) * g_sec_alloc_qty(l_rsv_id),5);
             ELSIF g_alloc_qty(l_rsv_id) = p_needed_quantity THEN
                l_sallocation_quantity := g_sec_alloc_qty(l_rsv_id);
             ELSE
                l_sallocation_quantity := p_needed_sec_quantity;
             END IF;

             IF l_debug = 1 THEN
                log_statement(l_api_name,'(1)l_sallocation_quantity   ', l_sallocation_quantity);
             END IF;
          ELSE -- (l_rsv_lot_number IS NULL)
             --
             -- No lot level reservation exists (high level/partial)
             --   the candidate lot may or may not have a lot specific conversion
             --     user may or may not have played with the deviation.
             --
             log_statement(l_api_name,'g_locs(p_record_id).lot_number ', g_locs(p_record_id).lot_number);

             OPEN  check_if_lot_conv_exists;
             FETCH check_if_lot_conv_exists into lot_conv_factor_flag;
             CLOSE check_if_lot_conv_exists;

             IF l_debug = 1 THEN
                log_statement(l_api_name, 'lot_conv_factor_flag           ', lot_conv_factor_flag);
                log_statement(l_api_name, 'l_lot_control_code             ', l_lot_control_code);
             END IF;

             IF (l_lot_control_code = 2 AND lot_conv_factor_flag > 0 ) THEN
                --
                -- use lot specific conversion
                l_lot_sallocation_quantity  := inv_convert.inv_um_convert(
                            Item_id          => p_inventory_item_id
                          , Lot_number       => g_locs(p_record_id).lot_number
                          , Organization_id  => p_organization_id
                          , Precision        => null
                          , From_quantity    => l_allocation_quantity
                          , From_unit        => p_primary_uom
                          , To_unit          => p_secondary_uom
                          , from_name        => NULL
                          , to_name          => NULL
                           );
                IF (l_lot_sallocation_quantity = -99999) THEN
                   IF l_debug = 1 THEN
                      log_statement(l_api_name, '(2)lot uom conversion error','');
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                   fnd_msg_pub.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF l_debug = 1 THEN
                   log_statement(l_api_name,'(1)l_lot_sallocation_quantity ', l_lot_sallocation_quantity);
                END IF;

                IF (g_sec_alloc_qty(l_rsv_id) <> l_lot_sallocation_quantity) THEN
                   --
                   -- if user played with the deviation on top of the lot specific
                   --
                   l_are_qties_valid := INV_CONVERT.within_deviation(
                          p_organization_id     => p_organization_id
                        , p_inventory_item_id   => p_inventory_item_id
                        , p_lot_number          => g_locs(p_record_id).lot_number
                        , p_precision           => NULL
                        , p_quantity            => l_allocation_quantity
                        , p_uom_code1           => p_primary_uom
                        , p_quantity2           => g_sec_alloc_qty(l_rsv_id)
                        , p_uom_code2           => p_secondary_uom
                        , p_unit_of_measure1    => NULL
                        , p_unit_of_measure2    => NULL);

                   IF (l_are_qties_valid = 0) THEN
                      --
                      -- outside deviation
                      l_sallocation_quantity := l_lot_sallocation_quantity;
                   ELSE
                      l_sallocation_quantity := g_sec_alloc_qty(l_rsv_id);
                   END IF;
                END IF;

                IF l_debug = 1 THEN
                   log_statement(l_api_name,'(with lot conv)l_sallocation_quantity  ', l_sallocation_quantity);
                END IF;
             ELSE
                --
                -- no lot specific conversion but accomodate user playing with deviation
                IF g_alloc_qty(l_rsv_id) > p_needed_quantity THEN
                   -- distribute sec in the same ratio as primary
                   l_sallocation_quantity :=
                      ROUND((p_needed_quantity/g_alloc_qty(l_rsv_id)) * g_sec_alloc_qty(l_rsv_id),5);
 	        ELSIF g_alloc_qty(l_rsv_id) = p_needed_quantity THEN
                   l_sallocation_quantity := g_sec_alloc_qty(l_rsv_id);
                ELSE
                   l_sallocation_quantity := p_needed_sec_quantity;
                END IF;
                IF l_debug = 1 THEN
                   log_statement(l_api_name,'(no lot conv)l_sallocation_quantity  ', l_sallocation_quantity);
                END IF;
             END IF;
          END IF;
         --}
       ELSE
         --{
             -- Bug 8665496- sec allocation qty should always be
             -- equal to requested quantity by user.
             l_sallocation_quantity := p_needed_sec_quantity;
       END IF; -- l_rsv_id > 0 }
    END IF; -- l_dual_uom_ctl > 1
    -- bug 8638386 - end

    IF l_dual_uom_ctl = 1 THEN
       l_sallocation_quantity := NULL;
    END IF;

    IF l_debug = 1 THEN
       log_statement(l_api_name, 'p_record_id            ', p_record_id);
       log_statement(l_api_name, 'lot_divisible_flag     ', l_lot_divisible_flag);
       log_statement(l_api_name, 'needed quantity        ', p_needed_quantity);
       log_statement(l_api_name, 'sec_needed quantity    ', p_needed_sec_quantity);
       log_statement(l_api_name, 'l_allocation_quantity  ', l_allocation_quantity);
       log_statement(l_api_name, '(2)l_sallocation_quantity ', l_sallocation_quantity);
       log_statement(l_api_name, 'g_locs(p_record_id).quantity           ', g_locs(p_record_id).quantity);
       log_statement(l_api_name, 'g_locs(p_record_id).secondary_quantity ', g_locs(p_record_id).secondary_quantity);
    END IF;
    /* bug 3972784, remove locator_id if no locator control */
    IF (  wms_engine_pvt.g_org_loc_control in (1,4)                   -- no loc ctl org level
         AND ( wms_engine_pvt.g_sub_loc_control = 1                  -- no loc ctl sub level
            OR (wms_engine_pvt.g_sub_loc_control = 5
                   AND wms_engine_pvt.g_item_loc_control = 1           -- no loc ctl item level
               )
             )
       )
    THEN
        l_to_locator_id := null;
        log_statement(l_api_name, 'non locator controled',' Non locator controled');
    END IF;
    IF l_lot_divisible_flag = 'N' and l_lot_control_code <> 1  AND  g_locs(p_record_id).quantity  <= l_allocation_quantity  THEN -- lot ctl and indivisible
        l_allocation_quantity   := g_locs(p_record_id).quantity;
        l_sallocation_quantity  := g_locs(p_record_id).secondary_quantity;

    ELSE
      IF l_allocation_quantity > g_locs(p_record_id).quantity THEN
        l_allocation_quantity  := g_locs(p_record_id).quantity;
        l_sallocation_quantity := g_locs(p_record_id).secondary_quantity;

      END IF;
    END IF;
    -- BUG 3609380 :  Removing p_to_subinevntory_code.
    --query quantity tree
    IF l_debug = 1  THEN
       log_statement(l_api_name, 'p_revision                                  ', g_locs(p_record_id).revision);
       log_statement(l_api_name, 'p_lot_number                                ', g_locs(p_record_id).lot_number);
       log_statement(l_api_name, 'p_subinventory                              ', g_locs(p_record_id).subinventory_code);
       log_statement(l_api_name, 'record quantity (l_allocation_quantity)     ', l_allocation_quantity);
       log_statement(l_api_name, 'sec_record_quantity (l_sallocation_quantity)', l_sallocation_quantity);
       log_statement(l_api_name, 'query_tree', 'calling Query Tree');
       log_statement(l_api_name, 'tree_id                                     ', p_tree_id);
    END IF;

    --Added for Bug 8570601 start
     IF l_debug = 1  THEN
      log_statement(l_api_name, 'p_transaction_temp_id', 'p_transaction_temp_id: ' || p_transaction_temp_id);
      log_statement(l_api_name, 'p_type_code', 'p_type_code: ' || p_type_code);
     END IF;
     IF inv_cache.set_mol_rec(p_transaction_temp_id) THEN
        l_transaction_type_id  := inv_cache.mol_rec.transaction_type_id;
     END IF;
     IF l_debug = 1  THEN
      log_statement(l_api_name, 'l_transaction_type_id', 'l_transaction_type_id: ' || l_transaction_type_id);
     END IF;
     IF l_transaction_type_id <> 0 THEN
        IF inv_cache.set_mtt_rec(l_transaction_type_id) THEN
          l_transaction_action_id := inv_cache.mtt_rec.transaction_action_id;
          l_transaction_source_type_id := inv_cache.mtt_rec.transaction_source_type_id;
        END IF;
     END IF;
     l_to_subinventory_code := chk_for_passing_xfer_sub ( TO_NUMBER(p_transaction_temp_id) ,
							   p_to_subinventory_code );

    IF l_debug = 1  THEN
      log_statement(l_api_name, 'l_to_subinventory_code', 'l_to_subinventory_code: ' || l_to_subinventory_code);
      log_statement(l_api_name, 'p_to_subinventory_code', 'p_to_subinventory_code: ' || p_to_subinventory_code);
      log_statement(l_api_name, 'l_transaction_action_id', 'l_transaction_action_id: ' || l_transaction_action_id);
      log_statement(l_api_name, 'l_transaction_action_id', 'l_transaction_source_type_id: ' || l_transaction_source_type_id);
      log_statement(l_api_name, 'p_type_code', 'p_type_code: ' || p_type_code);
      log_statement(l_api_name, 'g_locs(p_record_id).subinventory_code', 'g_locs(p_record_id).subinventory_code: ' || g_locs(p_record_id).subinventory_code);
    END IF;

     IF (
         l_transaction_action_id = INV_GLOBALS.G_ACTION_SUBXFR AND
	 l_transaction_source_type_id = INV_GLOBALS.G_SOURCETYPE_MOVEORDER AND
	 l_to_subinventory_code IS NULL) THEN
	 /*For MO XFER Putaway , we will use the src sub as dest sub*/
         l_to_subinventory_code := g_locs(p_record_id).subinventory_code;
     END IF;

    IF l_debug = 1  THEN
      log_statement(l_api_name, 'l_to_subinventory_code', 'l_to_subinventory_code: ' || l_to_subinventory_code);
    END IF;
    --Added for Bug 8570601 end

     inv_quantity_tree_pvt.query_tree
           (
                p_api_version_number         =>   g_qty_tree_api_version
              , p_init_msg_lst               =>   fnd_api.g_false -- p_init_msg_lst
              , x_return_status              =>   x_return_status
              , x_msg_count                  =>   x_msg_count
              , x_msg_data                   =>   x_msg_data
              , p_tree_id                    =>   p_tree_id
              , p_revision                   =>   g_locs(p_record_id).revision
              , p_lot_number                 =>   g_locs(p_record_id).lot_number
              , p_subinventory_code          =>   g_locs(p_record_id).subinventory_code
              , p_locator_id                 =>   g_locs(p_record_id).locator_id
              , x_qoh                        =>   l_qoh
              , x_sqoh                       =>   l_sqoh
              , x_rqoh                       =>   l_rqoh
              , x_srqoh                      =>   l_srqoh
              , x_qr                         =>   l_qr
              , x_sqr                        =>   l_sqr
              , x_qs                         =>   l_qs
              , x_sqs                        =>   l_sqs
              , x_att                        =>   l_att
              , x_satt                       =>   l_satt
              , x_atr                        =>   l_atr
              , x_satr                       =>   l_satr
              , p_transfer_subinventory_code =>   l_to_subinventory_code --Modified for Bug 8570601
              , p_cost_group_id              =>   g_locs(p_record_id).cost_group_id
              , p_lpn_id                     =>   g_locs(p_record_id).lpn_id
           );
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF l_debug = 1 THEN
         log_statement(l_api_name, 'uerr_qty_tree', 'Unexpected error in inv_quantity_tree_Pvt.query_tree');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug = 1 THEN
         log_statement(l_api_name, 'err_qty_tree', 'Error in inv_quantity_tree_Pvt.query_tree');
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_debug = 1 THEN
         log_statement(l_api_name, 'att_qty', 'Available quantity = ' || l_att);
         log_statement(l_api_name, 'satt_qty', 'Secondary Available quantity = ' || l_satt);
         log_statement(l_api_name, 'grade_code', 'grade_code = ' || p_grade_code);
      END IF;
      -- [ LOT_INDIV
      -- Checking ,
      -- a. If the pre suggestion record fetched from the rule is greater than the max qty allowed
      --    after adjusting the for upper tolerance .
      -- b. If ATT qty is equal to ON hand Qty to that of the pre suggestions record qty.
      --    It may be different due to partial reservations.
      -- The pre suggestions record will be skipped, if any of the above condition is false
      -- and fetch the next rec
      -- ]
      IF l_lot_divisible_flag = 'N' and l_lot_control_code <> 1 AND g_locs(p_record_id).quantity  <= l_allocation_quantity  THEN  -- lot ctl and indivisible

         IF  ((l_att = g_locs(p_record_id).quantity)  and ( l_qoh = l_att)) THEN
	       l_indiv_lot_allowed := 'Y';
         Else
	    l_indiv_lot_allowed := 'N';
	    IF l_debug = 1 THEN
	       log_statement(l_api_name, '', 'All the material is not available for this rec.');
	    END IF;
         End if;
      Else
	 l_indiv_lot_allowed := 'N' ;
      END IF;

    --update record quantity
   IF l_lot_divisible_flag = 'N' and l_lot_control_code <> 1  THEN  -- lot ctl and indivisible
       IF  l_indiv_lot_allowed = 'Y' THEN
           g_locs(p_record_id).quantity  := l_att;
           g_locs(p_record_id).secondary_quantity  := l_satt;
           g_locs(p_record_id).grade_code  := p_grade_code;
           --update possible allocate quantity
           l_allocation_quantity  := l_att;
           l_sallocation_quantity  := l_satt;
        ELSE
           l_allocation_quantity   := 0;
           l_sallocation_quantity  := 0;
        END IF;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'Lot Indiv', ' lot IS NOT divisible -- indivsible' );
           log_statement(l_api_name, 'Lot Indiv', 'New possible qty: ' || l_allocation_quantity);
        END IF;
    ELSE
        IF l_att < g_locs(p_record_id).quantity THEN
           g_locs(p_record_id).quantity  := l_att;
           g_locs(p_record_id).secondary_quantity  := l_satt;
           g_locs(p_record_id).grade_code  := p_grade_code;
        END IF;
        --update possible allocate quantity
        IF l_att < l_allocation_quantity THEN
           l_allocation_quantity  := l_att;
           l_sallocation_quantity  := l_satt;
        END IF;
    END IF;
    IF l_debug = 1 THEN
        log_statement(l_api_name, 'tree_qty', 'ATT < possible quantity.  New possible qty: ' || g_locs(p_record_id).quantity);
    END IF;


    --if no available quantity, return
    IF l_allocation_quantity <= 0 THEN
      --if reading from table, go to next record
      IF l_debug = 1 THEN
         log_event(l_api_name, 'zero_tree_qty', 'Available quantity ' || 'returned from quantity tree is zero');
      END IF;
      IF p_debug_on THEN
        g_trace_recs(p_record_id).att_qty                  := l_att;
        g_trace_recs(p_record_id).secondary_att_qty        := l_satt;
        g_trace_recs(p_record_id).att_qty_flag             := 'N';
      END IF;
      x_allocated_quantity  := 0;
      x_remaining_quantity  := 0;
      x_inserted_record     := FALSE;
      RETURN;
    END IF;

    IF p_debug_on THEN
      g_trace_recs(p_record_id).att_qty                  := l_att;
      g_trace_recs(p_record_id).secondary_att_qty        := l_satt;
      g_trace_recs(p_record_id).att_qty_flag             := 'Y';
    END IF;

    --check to see if serial number has already been used
    IF (g_locs(p_record_id).serial_number IS NOT NULL
        And g_locs(p_record_id).serial_number <> FND_API.G_MISS_CHAR)
    THEN
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'search_sn', 'Calling Search Serial Numbers');
      END IF;

      inv_detail_util_pvt.search_serial_numbers(
        p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_serial_number              => g_locs(p_record_id).serial_number
      , x_found                      => l_found
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'uerr_search_sn', 'Unexpected error in search_serial_numbers');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'err_search_sn', 'Error in search_serial_numbers');
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_found THEN
        IF p_debug_on THEN
          g_trace_recs(p_record_id).serial_number_used_flag  := 'N';
        END IF;
        IF l_debug = 1 THEN
           log_event(l_api_name, 'sn_used', 'Serial Number has been used');
        END IF;
        g_locs(p_record_id).quantity  := 0;
        x_allocated_quantity          := 0;
        x_remaining_quantity          := 0;
        x_inserted_record             := FALSE;
        RETURN;
      END IF;

      IF p_debug_on THEN
        g_trace_recs(p_record_id).serial_number_used_flag  := 'Y';
      END IF;
    END IF;

    --If we are factoring in Pick UOM, convert quantity into Pick UOM.
    --Then, find the the largest non-decimal quantity in Pick UOM.  Convert
    --back to primary UOM
    -- if Uom code is null, than use primary uom
    -- if pick uom = primary uom, skip conversions

    l_orig_allocation_quantity  := l_allocation_quantity;
    l_sorig_allocation_quantity := l_sallocation_quantity;

    IF  p_use_pick_uom
        AND g_locs(p_record_id).uom_code IS NOT NULL
        AND g_locs(p_record_id).uom_code <> p_primary_uom THEN

      --convert from primary uom to pick uom
      -- 8809951 calling uom_convert from wms_cache
      l_possible_uom_qty  := wms_cache.uom_convert(
                                                   p_inventory_item_id
                                                 , NULL
                                                 , l_allocation_quantity
                                                 , p_primary_uom
                                                 , g_locs(p_record_id).uom_code
                                                 );

     IF l_debug = 1 THEN
 	          log_statement(l_api_name, 'start_uom_conversion', 'Pick UOM possible qty: ' || l_possible_uom_qty);
 	          log_statement(l_api_name, 'start_uom_conversion', 'Pick UOM: ' || g_locs(p_record_id).uom_code);
     END IF;

      --if no conversion defined or some error in conversion,
      --inv_um_convert returns -99999.  In this case, don't carry
      --out any more conversion functions.  possible quantity
      --remains unchanged
      IF (l_possible_uom_qty <> -99999) THEN
        --don't want to pick fractional amounts of pick uom
        l_possible_uom_qty     := FLOOR(l_possible_uom_qty);

        IF l_debug = 1 THEN
             log_statement(l_api_name, 'to_primary_uom', 'Pick UOM qty after rounding down: ' || l_possible_uom_qty);
        END IF;
        --convert back to primary uom
        -- 8809951 calling uom_convert from wms_cache
	l_allocation_quantity  := wms_cache.uom_convert(
                                                        p_inventory_item_id
                                                      , NULL
                                                      , l_possible_uom_qty
                                                      , g_locs(p_record_id).uom_code
                                                      , p_primary_uom
                                                      );
         -- Added for bug 8665496
         l_sallocation_quantity :=
	            ROUND(((l_allocation_quantity/l_orig_allocation_quantity) * l_sorig_allocation_quantity),5);

        IF l_debug = 1 THEN
            log_statement(l_api_name, 'after_pick_uom_convert', 'l_allocation_quantity: ' || l_allocation_quantity);
 	    log_statement(l_api_name, 'after_pick_uom_convert', 'l_sallocation_quantity: ' || l_sallocation_quantity);
        END IF;
      END IF;
    END IF;

    --populate remaining quantity
    x_remaining_quantity        := l_orig_allocation_quantity - l_allocation_quantity;
    x_sec_remaining_quantity    := l_sorig_allocation_quantity - l_sallocation_quantity;
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'rem_qty', 'remaining quantity : ' || x_remaining_quantity);
       log_statement(l_api_name, 'rem_qty', 'remaining sec qty : ' || x_sec_remaining_quantity);
    END IF;

    IF l_allocation_quantity <= 0 THEN
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'no_alloc_qty', 'Quantity remaining to allocate.  Exiting.');
      END IF;
      x_allocated_quantity      := 0;
      x_sec_allocated_quantity  := 0;
      x_inserted_record         := FALSE;
      RETURN;
    END IF;

    --Lock Serial number, so that no other detailing process
    -- can use it.
    IF (g_locs(p_record_id).serial_number IS NOT NULL
        And g_locs(p_record_id).serial_number <> FND_API.G_MISS_CHAR)
    THEN
      l_found  := inv_detail_util_pvt.lock_serial_number(p_inventory_item_id, g_locs(p_record_id).serial_number);

      IF l_found = FALSE THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'lock_sn', 'Could not lock Serial Number. Exiting.');
        END IF;

        IF p_debug_on THEN
          g_trace_recs(p_record_id).serial_number_used_flag  := 'N';
        END IF;

        x_remaining_quantity  := g_locs(p_record_id).quantity;
        x_allocated_quantity  := 0;
        x_sec_remaining_quantity  := null;
        x_sec_allocated_quantity  := null;
        x_inserted_record     := FALSE;
        RETURN;
      END IF;

      -- add serial number to pl/sql table of detailed serials
      inv_detail_util_pvt.add_serial_number(p_inventory_item_id, p_organization_id, g_locs(p_record_id).serial_number, l_serial_index);
    END IF;

    -- Update quantity tree for this suggested quantity
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'update_tree', 'Updating qty tree');
    END IF;

    inv_quantity_tree_pvt.update_quantities
           (
                p_api_version_number         => g_qty_tree_api_version
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_tree_id                    => p_tree_id
              , p_revision                   => g_locs(p_record_id).revision
              , p_lot_number                 => g_locs(p_record_id).lot_number
              , p_subinventory_code          => g_locs(p_record_id).subinventory_code
              , p_locator_id                 => g_locs(p_record_id).locator_id
              , p_primary_quantity           => l_allocation_quantity
              , p_secondary_quantity         => l_sallocation_quantity                             -- INVCONV
              , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
              , x_qoh                        => l_qoh
              , x_rqoh                       => l_rqoh
              , x_qr                         => l_qr
              , x_qs                         => l_qs
              , x_att                        => l_att
              , x_atr                        => l_atr
              , x_sqoh                       => l_sqoh                                             -- INVCONV
              , x_srqoh                      => l_srqoh                                            -- INVCONV
              , x_sqr                        => l_sqr                                              -- INVCONV
              , x_sqs                        => l_sqs                                              -- INVCONV
              , x_satt                       => l_satt                                             -- INVCONV
              , x_satr                       => l_satr                                             -- INVCONV
              , p_transfer_subinventory_code => p_to_subinventory_code
              , p_cost_group_id              => g_locs(p_record_id).cost_group_id
              , p_lpn_id                     => g_locs(p_record_id).lpn_id
           );

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'uerr_update_qty', 'Unexpected error in inv_quantity_tree_pvt.update_quantities');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
       IF l_debug = 1 THEN
         log_statement(l_api_name, 'err_update_qty', 'Error in inv_quantity_tree_pvt.update_quantities');
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    --If quantity remaining to allocate is greater than 0, update the
    --quantity tree and insert the record into WTT
    IF p_transaction_uom = p_primary_uom THEN
      l_possible_trx_qty  := l_allocation_quantity;
    ELSE
      l_possible_trx_qty  :=
                 wms_cache.uom_convert(p_inventory_item_id, NULL, l_allocation_quantity, p_primary_uom, p_transaction_uom);

    END IF;
    l_sec_possible_trx_qty  := l_sallocation_quantity;

    IF l_debug = 1 THEN
       log_statement(l_api_name, 'insert_wtt_rec', 'Inserting wtt recs. Trx Qty: ' || l_possible_trx_qty);
       log_statement(l_api_name, 'insert_wtt_rec', 'Inserting wtt recs. Sec Trx Qty: ' || l_sec_possible_trx_qty);
    END IF;
    -- insert temporary suggestion
    INSERT INTO wms_transactions_temp
                (
                pp_transaction_temp_id
              , transaction_temp_id
              , type_code
              , line_type_code
              , transaction_quantity
              , primary_quantity
              , secondary_quantity
              , grade_code
              , revision
              , lot_number
              , lot_expiration_date
              , from_subinventory_code
              , from_locator_id
              , rule_id
              , reservation_id
              , serial_number
              , to_subinventory_code
              , to_locator_id
              , from_cost_group_id
              , to_cost_group_id
              , lpn_id
                )
         VALUES (
                wms_transactions_temp_s.NEXTVAL
              , p_transaction_temp_id
              , p_type_code
              , 2 -- line type code is output
              , l_possible_trx_qty
              , l_allocation_quantity
              , l_sallocation_quantity
              , g_locs(p_record_id).grade_code
              , g_locs(p_record_id).revision
              , g_locs(p_record_id).lot_number
              , g_locs(p_record_id).lot_expiration_date
              , g_locs(p_record_id).subinventory_code
              , g_locs(p_record_id).locator_id
              , p_rule_id
              , p_reservation_id
              , g_locs(p_record_id).serial_number
              , p_to_subinventory_code
              , l_to_locator_id
              , g_locs(p_record_id).cost_group_id
              , p_to_cost_group_id
              , g_locs(p_record_id).lpn_id
                );
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'finish_insert_wtt', 'Finished inserting wtt recs.');
       log_statement(l_api_name, 'alloc_qty', 'Alloc qty: ' || l_allocation_quantity);
       log_statement(l_api_name, 'sec_alloc_qty', 'sec_Alloc qty: ' || l_sallocation_quantity);
    END IF;

    -- Bug 8665496: update remaining qty to allocate
    IF l_rsv_id > 0 AND g_alloc_qty.EXISTS(l_rsv_id) AND g_sec_alloc_qty.EXISTS(l_rsv_id) THEN
         g_alloc_qty(l_rsv_id) := g_alloc_qty(l_rsv_id) - l_allocation_quantity;
         g_sec_alloc_qty(l_rsv_id) := g_sec_alloc_qty(l_rsv_id) - l_sallocation_quantity;
       IF l_debug = 1 THEN
            log_statement(l_api_name, 'g_alloc_qty', 'Remaining alloc qty: '
                            || g_alloc_qty(l_rsv_id));
           log_statement(l_api_name, 'g_sec_alloc_qty', 'Remaining rsv sec alloc qty: '
                         || g_sec_alloc_qty(l_rsv_id));
       END IF;
    END IF;

    IF p_debug_on THEN
      g_trace_recs(p_record_id).suggested_qty  := l_allocation_quantity;
      g_trace_recs(p_record_id).secondary_suggested_qty  := l_sallocation_quantity;
    END IF;

    x_inserted_record           := TRUE;
    x_allocated_quantity        := l_allocation_quantity;
    x_sec_allocated_quantity    := l_sallocation_quantity;
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'alloc_qty', 'Allocated quantity: ' || x_allocated_quantity);
       log_statement(l_api_name, 'sec_alloc_qty', 'sec_Allocated quantity: ' || x_sec_allocated_quantity);
       log_procedure(l_api_name, 'end', 'End Validate_and_Insert');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;

  END validate_and_insert;
  --- Added the following procedure for bug #4006426

  -- This procedure is used to get the quantity available to transact
  -- for a sub-transfer from a non-reservable subinventory.
  -- It assumed that pending transactions only exist at locator and lpn level
  -- The quantity is calculated with onhand quantity from
  -- MTL_ONHAND_QUANTITIES_DETAIL and pending transactions from
  -- MTL_MATERIAL_TRANSACTIONS_TEMP
  -- First get onhand and pending transactions at LPN level
  -- If LPN level availability > 0 then get pending transactions at Locator level
  -- return onhand less pending transactions
  -- NOTES :-
  -- 1) The quantities calculated do not include suggestions
  -- 2) Transfer SUB and locator are not needed in this query as this should be used
  --    only to get availability in a locator controlled SUB.
  -- 3) LOT expiration dates are not considered as this is to be used only for inventory moves

 PROCEDURE  GET_AVAIL_QTY_FOR_XFER
 (   p_organization_id        IN  NUMBER
    ,  p_inventory_item_id    IN  NUMBER
    ,  p_revision             IN  VARCHAR2
    ,  p_lot_number           IN  VARCHAR2
    ,  p_subinventory_code    IN  VARCHAR2
    ,  p_locator_id           IN  NUMBER
    ,  p_lpn_id               IN  NUMBER
    ,  x_qoh                  OUT NOCOPY NUMBER
    ,  x_att                  OUT NOCOPY NUMBER
    ,  x_return_status        OUT NOCOPY VARCHAR2
    ,  x_msg_count            OUT NOCOPY NUMBER
    ,  x_msg_data             OUT NOCOPY VARCHAR2
 )
 AS
 l_qoh     NUMBER;
 l_att     NUMBER;
 l_lpn_qoh   NUMBER;
 l_lpn_att   NUMBER;
 l_loc_qoh   NUMBER;
 l_loc_att   NUMBER;
 l_moq_qty   NUMBER;
 l_mmtt_qty_src  NUMBER;
 l_mmtt_qty_dest  NUMBER;

 l_debug  NUMBER := 1;

 BEGIN

   IF(l_debug=1) THEN
      inv_log_util.trace('Inside :GET_AVAIL_QTY_FOR_XFER '  , 'Start', 9);
      inv_log_util.trace('GET_AVAIL_QTY_FOR_XFER '  , 'p_organization_id :'||p_organization_id, 9);
      inv_log_util.trace('GET_AVAIL_QTY_FOR_XFER '  , 'p_inventory_item_id :'||p_inventory_item_id, 9);
      inv_log_util.trace('GET_AVAIL_QTY_FOR_XFER '  , 'p_revision :'||p_revision, 9);
      inv_log_util.trace('GET_AVAIL_QTY_FOR_XFER '  , 'p_subinventory_code :'||p_subinventory_code, 9);
      inv_log_util.trace('GET_AVAIL_QTY_FOR_XFER '  , 'p_lot_number :'||p_lot_number, 9);
       inv_log_util.trace('GET_AVAIL_QTY_FOR_XFER '  , 'p_lpn_id :'||p_lpn_id, 9);
  END IF;

   IF p_lpn_id IS NOT NULL THEN
     -- LPN level
       SELECT SUM(moq.primary_transaction_quantity)
       INTO   l_moq_qty
       FROM   mtl_onhand_quantities_detail moq
       WHERE  moq.organization_id = p_organization_id
       AND    moq.inventory_item_id = p_inventory_item_id
       AND    nvl(moq.revision,'@@') = nvl(p_revision,'@@')
       AND    moq.subinventory_code = p_subinventory_code
       AND    decode(p_lot_number,null,'@@',moq.lot_number) = nvl(p_lot_number,'@@')
       AND    moq.locator_id = p_locator_id
       AND    moq.lpn_id = p_lpn_id;

       IF(l_debug=1) THEN
         inv_log_util.trace('Total MOQ quantity LPN Level: ' || to_char(l_moq_qty), 'GET_AVAIL_QTY_FOR_XFER', 9);
       END IF;

       SELECT SUM(Decode(mmtt.transaction_status, 2, 1,
                 Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
                       Sign(mmtt.primary_quantity)))
               * round(Abs(mmtt.primary_quantity),5))
       INTO   l_mmtt_qty_src
       FROM   mtl_material_transactions_temp mmtt
       WHERE  mmtt.organization_id = p_organization_id
       AND    mmtt.inventory_item_id = p_inventory_item_id
       AND    nvl(mmtt.revision,'@@') = nvl(p_revision,'@@')
       AND    mmtt.subinventory_code = p_subinventory_code
       AND    mmtt.locator_id = p_locator_id
       AND    NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) = p_lpn_id
       AND    mmtt.posting_flag = 'Y'
       AND    mmtt.subinventory_code IS NOT NULL
       AND (Nvl(mmtt.transaction_status,0) <> 2 OR
               Nvl(mmtt.transaction_status,0) = 2 AND
               mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
              )
       AND    mmtt.transaction_action_id NOT IN (5,6,24,30);

       IF(l_debug=1) THEN
           inv_log_util.trace('Total MMTT Trx quantity Source Org Sub : ' || to_char(l_mmtt_qty_src), 'GET_AVAIL_QTY_FOR_XFER', 9);
       END IF;

       SELECT SUM(Abs(mmtt.primary_quantity))
       INTO   l_mmtt_qty_dest
       FROM   mtl_material_transactions_temp mmtt
       WHERE  decode(mmtt.transaction_action_id,3,
               mmtt.transfer_organization,mmtt.organization_id) = p_organization_id
       AND    mmtt.inventory_item_id = p_inventory_item_id
       AND    nvl(mmtt.revision,'@@') = nvl(p_revision,'@@')
       AND    mmtt.transfer_subinventory = p_subinventory_code
       AND    mmtt.transfer_to_location = p_locator_id
       AND    NVL(mmtt.content_lpn_id,mmtt.transfer_lpn_id) = p_lpn_id
       AND    mmtt.posting_flag = 'Y'
       AND    Nvl(mmtt.transaction_status,0) <> 2
       AND    mmtt.transaction_action_id  in (2,28,3)
       AND    mmtt.wip_supply_type IS NULL;

       IF(l_debug=1) THEN
           inv_log_util.trace('Total MMTT Trx quantity Dest Org Sub : ' || to_char(l_mmtt_qty_dest), 'GET_AVAIL_QTY_FOR_XFER', 9);
       END IF;

       l_lpn_qoh :=  nvl(l_moq_qty,0);
       l_lpn_att :=  nvl(l_moq_qty,0) + nvl(l_mmtt_qty_src,0) + nvl(l_mmtt_qty_dest,0);

    END IF;

    -- Only check onhand and pending at locator level if there is availability at LPN
    -- or no lpn passed in
    IF (nvl(l_lpn_att,0) > 0)  OR (p_lpn_id IS NULL) THEN

       SELECT SUM(Decode(mmtt.transaction_status, 2, 1,
                 Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
                       Sign(mmtt.primary_quantity)))
               * round(Abs(mmtt.primary_quantity),5))
       INTO   l_mmtt_qty_src
       FROM   mtl_material_transactions_temp mmtt
       WHERE  mmtt.organization_id = p_organization_id
       AND    mmtt.inventory_item_id = p_inventory_item_id
       AND    nvl(mmtt.revision,'@@') = nvl(p_revision,'@@')
       AND    mmtt.subinventory_code = p_subinventory_code
       AND    mmtt.locator_id = p_locator_id
       AND    mmtt.posting_flag = 'Y'
       AND    mmtt.subinventory_code IS NOT NULL
       AND (Nvl(mmtt.transaction_status,0) <> 2 OR
               Nvl(mmtt.transaction_status,0) = 2 AND
               mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
              )
       AND    mmtt.transaction_action_id NOT IN (5,6,24,30);

       IF(l_debug=1) THEN
           inv_log_util.trace('Total MMTT Trx quantity Source Org Sub : ' || to_char(l_mmtt_qty_src), 'GET_AVAIL_QTY_FOR_XFER', 9);
       END IF;

       SELECT SUM(moq.primary_transaction_quantity)
       INTO   l_moq_qty
       FROM   mtl_onhand_quantities_detail moq
       WHERE  moq.organization_id = p_organization_id
       AND    moq.inventory_item_id = p_inventory_item_id
       AND    nvl(moq.revision,'@@') = nvl(p_revision,'@@')
       AND    moq.subinventory_code = p_subinventory_code
       AND    decode(p_lot_number,null,'@@',moq.lot_number) = nvl(p_lot_number,'@@')
       AND    moq.locator_id = p_locator_id;

       IF(l_debug=1) THEN
         inv_log_util.trace('Total MOQ quantity LPN Level: ' || to_char(l_moq_qty), 'GET_AVAIL_QTY_FOR_XFER', 9);
       END IF;

       SELECT SUM(Decode(mmtt.transaction_status, 2, 1,
                 Decode(mmtt.transaction_action_id,1,-1,2,-1,28,-1,3,-1,
                       Sign(mmtt.primary_quantity)))
               * round(Abs(mmtt.primary_quantity),5))
       INTO   l_mmtt_qty_src
       FROM   mtl_material_transactions_temp mmtt
       WHERE  mmtt.organization_id = p_organization_id
       AND    mmtt.inventory_item_id = p_inventory_item_id
       AND    nvl(mmtt.revision,'@@') = nvl(p_revision,'@@')
       AND    mmtt.subinventory_code = p_subinventory_code
       AND    mmtt.locator_id = p_locator_id
       AND    mmtt.posting_flag = 'Y'
       AND    mmtt.subinventory_code IS NOT NULL
       AND (Nvl(mmtt.transaction_status,0) <> 2 OR
               Nvl(mmtt.transaction_status,0) = 2 AND
               mmtt.transaction_action_id IN (1,2,28,3,21,29,32,34)
              )
       AND    mmtt.transaction_action_id NOT IN (5,6,24,30);
       l_loc_qoh :=  nvl(l_moq_qty,0);
       l_loc_att :=  nvl(l_moq_qty,0) + nvl(l_mmtt_qty_src,0) + nvl(l_mmtt_qty_dest,0);
    END IF;


    -- Quantity available for transfer is the minimum of availability at LPN and locator levels
    IF p_lpn_id IS NULL THEN
        x_qoh := l_loc_qoh;
        x_att := l_loc_att;
    ELSE
      x_qoh := l_lpn_qoh;
      IF nvl(l_lpn_att,0) > nvl(l_loc_att,0) THEN
         x_att := l_loc_att;
      ELSE
         x_att := l_lpn_att;
      END IF;
    END IF;

    IF(l_debug=1) THEN
        inv_log_util.trace('Total quantity on-hand: ' || to_char(l_qoh), 'GET_AVAIL_QTY_FOR_XFER', 9);
    END IF;
 END GET_AVAIL_QTY_FOR_XFER;


  ---
   PROCEDURE ValidNinsert(
        x_return_status        OUT NOCOPY    VARCHAR2
      , x_msg_count            OUT NOCOPY    NUMBER
      , x_msg_data             OUT NOCOPY    VARCHAR2
      , p_record_id            IN            NUMBER
      , p_needed_quantity      IN            NUMBER
      , p_use_pick_uom         IN            BOOLEAN
      , p_organization_id      IN            NUMBER
      , p_inventory_item_id    IN            NUMBER
      , p_to_subinventory_code IN            VARCHAR2
      , p_to_locator_id        IN            NUMBER
      , p_to_cost_group_id     IN            NUMBER
      , p_primary_uom          IN            VARCHAR2
      , p_transaction_uom      IN            VARCHAR2
      , p_transaction_temp_id  IN            NUMBER
      , p_type_code            IN            NUMBER
      , p_rule_id              IN            NUMBER
      , p_reservation_id       IN            NUMBER
      , p_tree_id              IN            NUMBER
      , p_debug_on             IN            BOOLEAN
      , x_inserted_record      OUT NOCOPY    BOOLEAN
      , x_allocated_quantity   OUT NOCOPY    NUMBER
      , x_remaining_quantity   OUT NOCOPY    NUMBER
      ) IS
        l_api_name                 VARCHAR2(30) := 'validate_N_insert';
        l_att                      NUMBER;
        l_qoh                      NUMBER;
        l_allocation_quantity      NUMBER;
        l_orig_allocation_quantity NUMBER;
        l_found                    BOOLEAN;
        l_possible_uom_qty         NUMBER;
        l_possible_trx_qty         NUMBER;
        l_serial_index             NUMBER;

        l_debug                   NUMBER;

      BEGIN
        IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
           g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        END IF;
        l_debug := g_debug;

        x_return_status             := fnd_api.g_ret_sts_success;
        l_allocation_quantity       := p_needed_quantity;

        IF l_debug = 1 THEN
           log_procedure(l_api_name, 'start', 'Start Validate_N_Insert');
           log_statement(l_api_name, 'needed_quantity', 'needed quantity: ' || p_needed_quantity);
           log_statement(l_api_name, 'rec_id', 'p_record_id: ' || p_record_id);
        END IF;

         IF l_allocation_quantity > g_locs(p_record_id).quantity THEN
          l_allocation_quantity  := g_locs(p_record_id).quantity;
          log_statement(l_api_name, 'record_quantity', 'record quantity: ' || l_allocation_quantity);
        END IF;

       GET_AVAIL_QTY_FOR_XFER(
                p_organization_id     	=> p_organization_id
	     ,  p_inventory_item_id   	=> p_inventory_item_id
	     ,  p_revision 		=> g_locs(p_record_id).revision
	     ,  p_lot_number  		=> g_locs(p_record_id).lot_number
	     ,  p_subinventory_code  	=> g_locs(p_record_id).subinventory_code
	     ,  p_locator_id   		=> g_locs(p_record_id).locator_id
	     ,  p_lpn_id     		=> g_locs(p_record_id).lpn_id
	     ,  x_qoh         		=> l_qoh
	     ,  x_att  			=> l_att
	     ,  x_return_status         => x_return_status
	     ,  x_msg_count             => x_msg_count
    	     ,  x_msg_data              => x_msg_data   );


        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
	      IF l_debug = 1 THEN
	         log_statement(l_api_name, 'uerr_qty_tree', 'Unexpected error in inv_quantity_tree_Pvt.query_tree');
	      END IF;
	      RAISE fnd_api.g_exc_unexpected_error;
	    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
	      IF l_debug = 1 THEN
	         log_statement(l_api_name, 'err_qty_tree', 'Error in inv_quantity_tree_Pvt.query_tree');
	      END IF;
	      RAISE fnd_api.g_exc_error;
        END IF;

        IF l_debug = 1 THEN
          log_statement(l_api_name, 'att_qty', 'Available quantity = ' || l_att);
        END IF;
        --update record quantity
        IF l_att < g_locs(p_record_id).quantity THEN
          g_locs(p_record_id).quantity  := l_att;
        END IF;

        --update possible allocate quantity
        IF l_att < l_allocation_quantity THEN
          l_allocation_quantity  := l_att;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'tAvailable_qty', 'ATT < possible quantity.  New possible qty: ' || g_locs(p_record_id).quantity);
          END IF;
        END IF;

        --if no available quantity, return
        IF l_allocation_quantity <= 0 THEN
          --if reading from table, go to next record
          IF l_debug = 1 THEN
             log_event(l_api_name, 'zero_tree_qty', 'Available quantity ' || 'returned from quantity tree is zero');
          END IF;

          IF p_debug_on THEN
            g_trace_recs(p_record_id).att_qty       := l_att;
            g_trace_recs(p_record_id).att_qty_flag  := 'N';
          END IF;

          x_allocated_quantity  := 0;
          x_remaining_quantity  := 0;
          x_inserted_record     := FALSE;
          RETURN;
        END IF;

        IF p_debug_on THEN
          g_trace_recs(p_record_id).att_qty       := l_att;
          g_trace_recs(p_record_id).att_qty_flag  := 'Y';
        END IF;

        --check to see if serial number has already been used
        IF g_locs(p_record_id).serial_number IS NOT NULL THEN
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'search_sn', 'Calling Search Serial Numbers');
          END IF;

          inv_detail_util_pvt.search_serial_numbers(
            p_organization_id            => p_organization_id
          , p_inventory_item_id          => p_inventory_item_id
          , p_serial_number              => g_locs(p_record_id).serial_number
          , x_found                      => l_found
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'uerr_search_sn', 'Unexpected error in search_serial_numbers');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'err_search_sn', 'Error in search_serial_numbers');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_found THEN
            IF p_debug_on THEN
              g_trace_recs(p_record_id).serial_number_used_flag  := 'N';
            END IF;
            IF l_debug = 1 THEN
               log_event(l_api_name, 'sn_used', 'Serial Number has been used');
            END IF;
            g_locs(p_record_id).quantity  := 0;
            x_allocated_quantity          := 0;
            x_remaining_quantity          := 0;
            x_inserted_record             := FALSE;
            RETURN;
          END IF;

          IF p_debug_on THEN
            g_trace_recs(p_record_id).serial_number_used_flag  := 'Y';
          END IF;
        END IF;

        --If we are factoring in Pick UOM, convert quantity into Pick UOM.
        --Then, find the the largest non-decimal quantity in Pick UOM.  Convert
        --back to primary UOM
        -- if Uom code is null, than use primary uom
        -- if pick uom = primary uom, skip conversions

        l_orig_allocation_quantity  := l_allocation_quantity;

        IF  p_use_pick_uom
            AND g_locs(p_record_id).uom_code IS NOT NULL
            AND g_locs(p_record_id).uom_code <> p_primary_uom THEN

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'start_uom_conversion', 'Converting from primary uom to pick uom');
          END IF;
          --convert from primary uom to pick uom
          l_possible_uom_qty  := inv_convert.inv_um_convert(
                                   p_inventory_item_id
                                 , NULL
                                 , l_allocation_quantity
                                 , p_primary_uom
                                 , g_locs(p_record_id).uom_code
                                 , NULL
                                 , NULL
                                 );

          --if no conversion defined or some error in conversion,
          --inv_um_convert returns -99999.  In this case, don't carry
          --out any more conversion functions.  possible quantity
          --remains unchanged
          IF (l_possible_uom_qty <> -99999) THEN
            --don't want to pick fractional amounts of pick uom
            l_possible_uom_qty     := FLOOR(l_possible_uom_qty);

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'to_primary_uom', 'Converting from pick uom to primary uom');
            END IF;
            --convert back to primary uom
            l_allocation_quantity  := inv_convert.inv_um_convert(
                                        p_inventory_item_id
                                      , NULL
                                      , l_possible_uom_qty
                                      , g_locs(p_record_id).uom_code
                                      , p_primary_uom
                                      , NULL
                                      , NULL
                                      );
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'after_pick_uom_convert', 'Possible quantity after conversion for pick uom: ' || l_allocation_quantity);
            END IF;
          END IF;
        END IF;

        --populate remaining quantity
        x_remaining_quantity        := l_orig_allocation_quantity - l_allocation_quantity;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'rem_qty', 'remaining_quantity : ' || x_remaining_quantity);
        END IF;

        IF l_allocation_quantity <= 0 THEN
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'no_alloc_qty', 'Quantity remaining to allocate.  Exiting.');
          END IF;
          x_allocated_quantity  := 0;
          x_inserted_record     := FALSE;
          RETURN;
        END IF;

        --Lock Serial number, so that no other detailing process
        -- can use it.
        IF g_locs(p_record_id).serial_number IS NOT NULL THEN
          l_found  := inv_detail_util_pvt.lock_serial_number(p_inventory_item_id, g_locs(p_record_id).serial_number);

          IF l_found = FALSE THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'lock_sn', 'Could not lock Serial Number. Exiting.');
            END IF;

            IF p_debug_on THEN
              g_trace_recs(p_record_id).serial_number_used_flag  := 'N';
            END IF;

            x_remaining_quantity  := g_locs(p_record_id).quantity;
            x_allocated_quantity  := 0;
            x_inserted_record     := FALSE;
            RETURN;
          END IF;

          -- add serial number to pl/sql table of detailed serials
          inv_detail_util_pvt.add_serial_number(p_inventory_item_id, p_organization_id, g_locs(p_record_id).serial_number, l_serial_index);
        END IF;

        --If quantity remaining to allocate is greater than 0, update the
        --quantity tree and insert the record into WTT
        IF p_transaction_uom = p_primary_uom THEN
          l_possible_trx_qty  := l_allocation_quantity;
        ELSE
          l_possible_trx_qty  :=
                     inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_allocation_quantity, p_primary_uom, p_transaction_uom, NULL, NULL);
        END IF;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'insert_wtt_rec', 'Inserting wtt recs. Trx Qty: ' || l_possible_trx_qty);
        END IF;
        -- insert temporary suggestion
        INSERT INTO wms_transactions_temp
                    (
                    pp_transaction_temp_id
                  , transaction_temp_id
                  , type_code
                  , line_type_code
                  , transaction_quantity
                  , primary_quantity
                  , revision
                  , lot_number
                  , lot_expiration_date
                  , from_subinventory_code
                  , from_locator_id
                  , rule_id
                  , reservation_id
                  , serial_number
                  , to_subinventory_code
                  , to_locator_id
                  , from_cost_group_id
                  , to_cost_group_id
                  , lpn_id
                    )
             VALUES (
                    wms_transactions_temp_s.NEXTVAL
                  , p_transaction_temp_id
                  , p_type_code
                  , 2 -- line type code is output
                  , l_possible_trx_qty
                  , l_allocation_quantity
                  , g_locs(p_record_id).revision
                  , g_locs(p_record_id).lot_number
                  , g_locs(p_record_id).lot_expiration_date
                  , g_locs(p_record_id).subinventory_code
                  , g_locs(p_record_id).locator_id
                  , p_rule_id
                  , p_reservation_id
                  , g_locs(p_record_id).serial_number
                  , p_to_subinventory_code
                  , p_to_locator_id
                  , g_locs(p_record_id).cost_group_id
                  , p_to_cost_group_id
                  , g_locs(p_record_id).lpn_id
                    );
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'finish_insert_wtt', 'Finished inserting wtt recs.');
           log_statement(l_api_name, 'alloc_qty', 'Alloc qty: ' || l_allocation_quantity);
        END IF;

        IF p_debug_on THEN
          g_trace_recs(p_record_id).suggested_qty  := l_allocation_quantity;
        END IF;

        x_inserted_record           := TRUE;
        x_allocated_quantity        := l_allocation_quantity;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'alloc_qty', 'Allocated quantity: ' || x_allocated_quantity);
           log_procedure(l_api_name, 'end', 'End Validate_and_Insert');
        END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          x_return_status  := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
          --
          IF l_debug = 1 THEN
             log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
          END IF;

        WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
          IF l_debug = 1 THEN
             log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
          END IF;

        WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;

          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
          END IF;

          fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
          IF l_debug = 1 THEN
             log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
          END IF;

  END ValidNinsert;

  -- End of bug #4006426 ---


  PROCEDURE rollback_consist_allocations(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_group_id      IN            NUMBER
  , p_tree_id       IN            NUMBER
  , p_type_code     IN            NUMBER
  , p_first_uom_rec IN            NUMBER
  , p_last_uom_rec  IN            NUMBER
  , p_prev_rec      IN            NUMBER
  , p_next_rec      IN            NUMBER
  , p_debug_on      IN            BOOLEAN
  ) IS
    l_api_name    VARCHAR2(30) := 'rollback_consist_allocations';
    l_current_loc NUMBER;
    l_next_rec    NUMBER;

    l_debug       NUMBER;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;
    l_debug := g_debug;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'Start', 'Start Rollback_Consist_Allocations');
       -- rollback the changes we've made
       log_statement(l_api_name, 'consist_not_enough_qty', 'Not enough quantity in this consistency group. ' || 'Rolling back suggestions');
       log_statement(l_api_name, 'restore_tree', 'Calling restore_tree');
    END IF;
    inv_quantity_tree_pvt.restore_tree(x_return_status => x_return_status, p_tree_id => p_tree_id);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF l_debug = 1 THEN
         log_error(l_api_name, 'uerr_restore_tree', 'Unexpected error in restore_tree');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      IF l_debug = 1  THEN
         log_error(l_api_name, 'err_restore_tree', 'Error in restore_tree');
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    --put pick UOM records back into the list;
    --we need to put this records between after the last
    --record that has the current order by string, since
    --these recs have the same order by string.  The last rec
    --with the same order by string is stored in l_prev_rec,
    --and the first rec with the next order by string is l_loc_id
    --We only do this is the pick uom list is populated
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'p_first_uom_rec', 'first_uom_rec: ' || p_first_uom_rec);
       log_statement(l_api_name, 'p_next_rec', 'next_rec: ' || p_next_rec);
       log_statement(l_api_name, 'p_prev_rec', 'prev_rec: ' || p_prev_rec);
    END IF;
    IF p_first_uom_rec <> 0 THEN
      IF p_next_rec IS NULL THEN
        l_next_rec  := p_prev_rec;

        LOOP
          EXIT WHEN NVL(l_next_rec, 0) = 0;
          EXIT WHEN g_locs(l_next_rec).order_by_string <> g_locs(p_prev_rec).order_by_string;
          l_next_rec  := g_locs(l_next_rec).next_rec;
        END LOOP;
      ELSE
        l_next_rec  := p_next_rec;
      END IF;

      IF p_prev_rec = 0 THEN
        g_consists(p_group_id).first_rec  := p_first_uom_rec;
      ELSE
        g_locs(p_prev_rec).next_rec  := p_first_uom_rec;
      END IF;

      g_locs(p_last_uom_rec).next_rec  := l_next_rec;
    END IF;

    --loop through trace recs, updating recs for this consist
    -- group to change consist_string_flag from Y to N
    -- and to set suggested quantity back to 0
    IF p_debug_on THEN

      l_current_loc  := g_consists(p_group_id).first_rec;
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'trace', 'Updating trace records');
         log_statement(l_api_name, 'first_loc', 'First rec to update: ' || l_current_loc);
      END IF ;

      --loop through each record in this consist group
      LOOP
        EXIT WHEN NVL(l_current_loc, 0) = 0;
        --update the trace records
        g_trace_recs(l_current_loc).consist_string_flag  := 'N';
        g_trace_recs(l_current_loc).suggested_qty        := 0;
        l_current_loc                                    := g_locs(l_current_loc).next_rec;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'current_loc', 'Current rec: ' || l_current_loc);
        END IF ;
      END LOOP;
    END IF;

    DELETE FROM wms_transactions_temp
          WHERE line_type_code = 2
            AND type_code = p_type_code;
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'finish_delete_sugs', 'Finished deleting suggestions and restored quantity tree');
       log_procedure(l_api_name, 'End', 'End Rollback_Consist_Allocations');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;

  END rollback_consist_allocations;

  PROCEDURE allocate_consist_group(
    x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_group_id             IN            NUMBER
  , p_needed_quantity      IN            NUMBER
  , p_use_pick_uom         IN            BOOLEAN
  , p_organization_id      IN            NUMBER
  , p_inventory_item_id    IN            NUMBER
  , p_to_subinventory_code IN            VARCHAR2
  , p_to_locator_id        IN            NUMBER
  , p_to_cost_group_id     IN            NUMBER
  , p_primary_uom          IN            VARCHAR2
  , p_transaction_uom      IN            VARCHAR2
  , p_transaction_temp_id  IN            NUMBER
  , p_type_code            IN            NUMBER
  , p_rule_id              IN            NUMBER
  , p_reservation_id       IN            NUMBER
  , p_tree_id              IN            NUMBER
  , p_debug_on             IN            BOOLEAN
  , p_needed_sec_quantity  IN            NUMBER                        -- new
  , p_secondary_uom        IN            VARCHAR2                      -- new
  , p_grade_code           IN            VARCHAR2                      -- new
  , p_lot_divisible_flag   IN            VARCHAR2                      -- new
  , x_success              OUT NOCOPY    BOOLEAN
  ) IS
    l_api_name                 VARCHAR2(30)   := 'allocate_consist_group';
    l_loc_id                   NUMBER;
    l_current_order_by_string  VARCHAR2(1000) := NULL;
    l_first_rec_uom            NUMBER         := 0;
    l_last_rec_uom             NUMBER         := 0;
    l_last_rec_cur_uom         NUMBER         := 0;
    l_uom_loc_id               NUMBER;
    l_needed_quantity          NUMBER;
    l_inserted_record          BOOLEAN;
    l_allocated_quantity       NUMBER;
    l_remaining_quantity       NUMBER;
    l_expected_quantity        NUMBER;
    l_sec_needed_quantity      NUMBER;                  -- new
    l_sec_allocated_quantity   NUMBER;                  -- new
    l_sec_remaining_quantity   NUMBER;                  -- new
    l_sec_expected_quantity    NUMBER;                  -- new
    l_current_loc              NUMBER;
    l_prev_rec                 NUMBER         := 0;
    l_original_needed_quantity NUMBER;
    l_uom_index                NUMBER;
     l_lot_control_code         NUMBER         :=inv_cache.item_rec.lot_control_code; -- added for bug7267861
    l_insert                   NUMBER    := 0;  --bug# 8270806
    l_debug                    NUMBER;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'Start', 'Start Allocate_Consist_Group');
    END IF;
    l_needed_quantity           := p_needed_quantity;
    l_original_needed_quantity  := p_needed_quantity;
    l_loc_id                    := g_consists(p_group_id).first_rec;
    x_success                   := FALSE;

    --for each record in the consistency group
    LOOP
      EXIT WHEN l_loc_id = 0;
      l_insert  := 0;  --bug# 8270806,reseting the value to l_insert
      --Allocation from pick UOM list if this rec's order string is not
      -- equal to previous rec's order string and we are using pick UOM
      -- and the pick UOM list is not empty
      IF  NVL(l_current_order_by_string, '@@@') <> NVL(g_locs(l_loc_id).order_by_string, '@@@')
          AND p_use_pick_uom
          AND l_first_rec_uom <> 0 THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'pick_uom', 'Allocating pick UOM records');
        END IF;

        l_uom_loc_id  := l_first_rec_uom;

        --for each record in Pick UOM table
        LOOP
          EXIT WHEN l_uom_loc_id = 0;
          l_expected_quantity  := g_locs(l_uom_loc_id).quantity;

          --validate_and_insert will allocation no more than needed quantity
          IF l_needed_quantity < l_expected_quantity THEN
            l_expected_quantity  := l_needed_quantity;
          END IF;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'exp_qty', 'Expected Qty: ' || l_expected_quantity);
             log_statement(l_api_name, 'val_insert', 'Calling Validate and Insert');
          END IF;
        --call helper procedure to validate and insert record
          validate_and_insert(
            x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_record_id                  => l_uom_loc_id
          , p_needed_quantity            => l_needed_quantity
          , p_use_pick_uom               => FALSE
          , p_organization_id            => p_organization_id
          , p_inventory_item_id          => p_inventory_item_id
          , p_to_subinventory_code       => p_to_subinventory_code
          , p_to_locator_id              => p_to_locator_id
          , p_to_cost_group_id           => p_to_cost_group_id
          , p_primary_uom                => p_primary_uom
          , p_transaction_uom            => p_transaction_uom
          , p_transaction_temp_id        => p_transaction_temp_id
          , p_type_code                  => p_type_code
          , p_rule_id                    => p_rule_id
          , p_reservation_id             => p_reservation_id
          , p_tree_id                    => p_tree_id
          , p_debug_on                   => p_debug_on
          , p_needed_sec_quantity        => l_sec_needed_quantity
          , p_secondary_uom              => p_secondary_uom
          , p_grade_code                 => p_grade_code
          , x_inserted_record            => l_inserted_record
          , x_allocated_quantity         => l_allocated_quantity
          , x_remaining_quantity         => l_remaining_quantity
          , x_sec_allocated_quantity     => l_sec_allocated_quantity
          , x_sec_remaining_quantity     => l_sec_remaining_quantity
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;

          --If function did not insert full quantity, decrease group qty
          IF l_expected_quantity > l_allocated_quantity THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'did_not_alloc_full', 'Not all of the expected quantity was allocated');
            END IF;
            g_consists(p_group_id).quantity  := g_consists(p_group_id).quantity - (l_expected_quantity - l_allocated_quantity);
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'new_group_qty', 'New group quantity: ' || g_consists(p_group_id).quantity);
            END IF;
            g_locs(l_uom_loc_id).quantity    := l_allocated_quantity;
            g_locs(l_uom_loc_id).secondary_quantity    := l_sec_allocated_quantity;

            --If group qty is now less than needed qty, rollback and return
            IF g_consists(p_group_id).quantity < l_original_needed_quantity THEN
              IF l_debug = 1 THEN
              log_statement(
                l_api_name
              , 'rollback_consist'
              , 'Not enough quantity in consist group. Calling ' || 'rollback consist allocations.'
              );

              END IF;

              rollback_consist_allocations(
                x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_group_id                   => p_group_id
              , p_tree_id                    => p_tree_id
              , p_type_code                  => p_type_code
              , p_first_uom_rec              => l_first_rec_uom
              , p_last_uom_rec               => l_last_rec_uom
              , p_prev_rec                   => l_prev_rec
              , p_next_rec                   => l_loc_id
              , p_debug_on                   => p_debug_on
              );

              IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF l_debug = 1 THEN
                   log_error(l_api_name, 'uerr_rollback_consist', 'Unexpected error in rollback_consist_allocations');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                IF l_debug = 1 THEN
                   log_error(l_api_name, 'err_rollback_consist', 'Error in rollback_consist_allocations');
                END IF;
                RAISE fnd_api.g_exc_error;
              END IF;
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'after_rollback_consist', 'Rolled back the allocations.  Exiting');
              END IF;
              x_success  := FALSE;
              RETURN;
            END IF;
          END IF;

          IF p_debug_on THEN
            g_trace_recs(l_uom_loc_id).consist_string_flag  := 'Y';
          END IF;

          --Decrease remaining qty to be allocated
          l_needed_quantity    := l_needed_quantity - l_allocated_quantity;
          l_sec_needed_quantity    := l_sec_needed_quantity - l_sec_allocated_quantity;

          --if no qty left to detail, exit pick UOM loop
          IF l_needed_quantity <= 0 THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'no_more_qty', 'Allocated all the needed quantity.  Exiting.');
            END IF;
            x_success  := TRUE;
            RETURN;
          END IF;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'need_qty', 'New needed quantity: ' || l_needed_quantity);
          END IF;
          l_uom_loc_id         := g_locs(l_uom_loc_id).next_rec;
        END LOOP;
      END IF;

      l_current_order_by_string  := g_locs(l_loc_id).order_by_string;
      -- Call validate_and_insert on current record
      -- If group qty is now less than needed qty, rollback and return
      -- If remaining qty > 0 and use Pick UOM, add new record to pick uom table
      -- decrease remaining qty to be allocated
      -- exit when no more qty left to detail
      l_expected_quantity        := g_locs(l_loc_id).quantity;

      --validate_and_insert will allocation no more than needed quantity
      IF l_needed_quantity < l_expected_quantity THEN
       l_insert :=1;  --bug# 8270806
       l_expected_quantity  := l_needed_quantity;
      END IF;
      IF l_debug = 1 THEN
      	 log_statement(l_api_name, 'exp_qty', 'Expected Qty: ' || l_expected_quantity);
      	 log_statement(l_api_name, 'val_insert', 'Calling Validate and Insert');
      END IF;
      -- Added the following  restriction - 5258131
     IF  (l_needed_quantity >= l_expected_quantity AND l_insert =0 AND  p_lot_divisible_flag  = 'N')
        OR  ((NVL(p_lot_divisible_flag, 'Y')  = 'Y') OR nvl(l_lot_control_code,1) = 1)  THEN --added for bug7261861
       validate_and_insert(
        x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_record_id                  => l_loc_id
      , p_needed_quantity            => l_needed_quantity
      , p_use_pick_uom               => p_use_pick_uom
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_to_subinventory_code       => p_to_subinventory_code
      , p_to_locator_id              => p_to_locator_id
      , p_to_cost_group_id           => p_to_cost_group_id
      , p_primary_uom                => p_primary_uom
      , p_transaction_uom            => p_transaction_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_type_code                  => p_type_code
      , p_rule_id                    => p_rule_id
      , p_reservation_id             => p_reservation_id
      , p_tree_id                    => p_tree_id
      , p_debug_on                   => p_debug_on
      , p_needed_sec_quantity        => l_sec_needed_quantity
      , p_secondary_uom              => p_secondary_uom
      , p_grade_code                 => p_grade_code
      , x_inserted_record            => l_inserted_record
      , x_allocated_quantity         => l_allocated_quantity
      , x_remaining_quantity         => l_remaining_quantity
      , x_sec_allocated_quantity     => l_sec_allocated_quantity
      , x_sec_remaining_quantity     => l_sec_remaining_quantity
      );

       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
        END IF;
        RAISE fnd_api.g_exc_error;
       END IF;
      END IF; -- End of If 5258131
      --If function did not insert full quantity, decrease group qty
      IF l_expected_quantity > l_allocated_quantity THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'did_not_alloc_full', 'Not all of the expected quantity was allocated');
        END IF;
        g_consists(p_group_id).quantity  := g_consists(p_group_id).quantity - (l_expected_quantity - l_allocated_quantity);
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'new_group_qty', 'New group quantity: ' || g_consists(p_group_id).quantity);
        END IF;
        g_locs(l_loc_id).quantity        := l_allocated_quantity;
        g_locs(l_loc_id).secondary_quantity        := l_sec_allocated_quantity;

        --If group qty is now less than needed qty, rollback and return
        IF g_consists(p_group_id).quantity < l_original_needed_quantity THEN
          --out of records with cur_consist_string;
          -- rollback the changes we've made
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'rollback_consist', 'Not enough quantity in consist group. Calling ' || 'rollback consist allocations.');
          END IF;
         rollback_consist_allocations(
            x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_group_id                   => p_group_id
          , p_tree_id                    => p_tree_id
          , p_type_code                  => p_type_code
          , p_first_uom_rec              => l_first_rec_uom
          , p_last_uom_rec               => l_last_rec_uom
          , p_prev_rec                   => l_loc_id
          , p_next_rec                   => NULL
          , p_debug_on                   => p_debug_on
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF l_debug = 1 THEN
               log_error(l_api_name, 'uerr_rollback_consist', 'Unexpected error in rollback_consist_allocations');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF l_debug = 1 THEN
               log_error(l_api_name, 'err_rollback_consist', 'Error in rollback_consist_allocations');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'after_rollback_consist', 'Rolled back the allocations.  Exiting');
          END IF;
          x_success  := FALSE;
          RETURN;
        END IF;
      END IF;

      IF p_debug_on THEN
        g_trace_recs(l_loc_id).consist_string_flag  := 'Y';
      END IF;

      --Decrease remaining qty to be allocated
      l_needed_quantity          := l_needed_quantity - l_allocated_quantity;
      l_sec_needed_quantity          := l_sec_needed_quantity - l_sec_allocated_quantity;

      --if no qty left to detail, exit loop
      IF l_needed_quantity <= 0 THEN
        x_success  := TRUE;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'no_more_qty', 'Allocated all the needed quantity.  Exiting.');
        END IF;
        RETURN;
      END IF;
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'need_qty', 'New needed quantity: ' || l_needed_quantity);
      END IF;
      --handle pick UOM
      IF  l_remaining_quantity > 0
          AND p_use_pick_uom THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'create_pick_uom', 'Create a pick UOM record.Remaining quantity:' || l_remaining_quantity);
        END IF;

        --create new record if necessary
        IF l_remaining_quantity < g_locs(l_loc_id).quantity THEN
          g_locs_index                   := g_locs_index + 1;
          g_locs(g_locs_index)           := g_locs(l_loc_id);
          g_locs(g_locs_index).quantity  := l_remaining_quantity;
          g_locs(l_loc_id).quantity      := g_locs(l_loc_id).quantity - l_remaining_quantity;
          l_uom_index                    := g_locs_index;
          l_prev_rec                     := l_loc_id;
        ELSE
          --if  could not be allocated, remove record from
          --current linked list
          IF l_prev_rec <> 0 THEN
            g_locs(l_prev_rec).next_rec  := g_locs(l_loc_id).next_rec;
          ELSE
            g_consists(p_group_id).first_rec  := g_locs(l_loc_id).next_rec;
          END IF;

          l_uom_index  := l_loc_id;
        --if rec is removed from link list, prev_rec does not change
        END IF;

        --set pointers
        -- new record is first record in table
        IF l_first_rec_uom = 0 THEN
          l_first_rec_uom               := l_uom_index;
          l_last_rec_cur_uom            := l_uom_index;
          l_last_rec_uom                := l_uom_index;
          g_locs(l_uom_index).next_rec  := 0;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'first_rec', 'The saved uom record is the first record in table');
          END IF;
        -- new record is first record with that uom code
        ELSIF g_locs(l_first_rec_uom).uom_code <> g_locs(l_uom_index).uom_code THEN
          g_locs(l_uom_index).next_rec  := l_first_rec_uom;
          l_first_rec_uom               := l_uom_index;
          l_last_rec_cur_uom            := l_uom_index;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'first_rec_uom', 'The saved uom record is the first record for uom in table');
          END IF;
        -- records with this uom code already exist in table
        ELSE
          g_locs(l_uom_index).next_rec         := g_locs(l_last_rec_cur_uom).next_rec;
          g_locs(l_last_rec_cur_uom).next_rec  := l_uom_index;
          l_last_rec_cur_uom                   := l_uom_index;

          IF g_locs(l_uom_index).next_rec = 0 THEN
            l_last_rec_uom  := l_uom_index;
          END IF;
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'not_first_rec_uom', 'The saved record is not first record for uom in table');
          END IF;
        END IF;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'saving_loc', 'Storing record in uom table');
        END IF;

        IF p_debug_on THEN
          --determine if we created a new record or not
          IF l_uom_index = g_locs_index THEN
            g_trace_recs(g_locs_index)                := g_trace_recs(l_loc_id);
            g_trace_recs(l_loc_id).quantity           := g_trace_recs(l_loc_id).quantity - l_remaining_quantity;
            g_trace_recs(g_locs_index).quantity       := l_remaining_quantity;
            g_trace_recs(l_loc_id).pick_uom_flag      := 'P';
            g_trace_recs(g_locs_index).pick_uom_flag  := 'N';
          ELSE
            g_trace_recs(l_loc_id).pick_uom_flag  := 'N';
          END IF;
        END IF;
      ELSE
        l_prev_rec  := l_loc_id;
      END IF;

      l_loc_id                   := g_locs(l_loc_id).next_rec;
    END LOOP;

    IF l_needed_quantity <= 0 THEN
      x_success  := TRUE;
    ELSE
      --some sort of error occurred in our calculations;
      --we thought that there was enough material in the consistency
      --group, but we've allocated all the location records, but we have
      --not fulfilled all of the needed quantity;
      --Rollback the changes.
      IF l_debug = 1 THEN
      log_statement(
        l_api_name
      , 'rollback_consist'
      ,    'Quantity value on consist group was wrong.  There is not enough '
        || 'quantity to allocate in this consist group.. Calling '
        || 'rollback consist allocations.'
      );
      END IF;
      rollback_consist_allocations(
        x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_group_id                   => p_group_id
      , p_tree_id                    => p_tree_id
      , p_type_code                  => p_type_code
      , p_first_uom_rec              => 0
      , p_last_uom_rec               => 0
      , p_prev_rec                   => 0
      , p_next_rec                   => 0
      , p_debug_on                   => p_debug_on
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF l_debug = 1 THEN
           log_error(l_api_name, 'uerr_rollback_consist', 'Unexpected error in rollback_consist_allocations');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug = 1 THEN
           log_error(l_api_name, 'err_rollback_consist', 'Error in rollback_consist_allocations');
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      x_success  := FALSE;
    END IF;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End Allocate_Consist_Group');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_success        := FALSE;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_success        := FALSE;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_success        := FALSE;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;

  END allocate_consist_group;

  PROCEDURE insert_consist_record(
    x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_record_id            IN            NUMBER
  , p_needed_quantity      IN            NUMBER
  , p_use_pick_uom         IN            BOOLEAN
  , p_organization_id      IN            NUMBER
  , p_inventory_item_id    IN            NUMBER
  , p_to_subinventory_code IN            VARCHAR2
  , p_to_locator_id        IN            NUMBER
  , p_to_cost_group_id     IN            NUMBER
  , p_primary_uom          IN            VARCHAR2
  , p_transaction_uom      IN            VARCHAR2
  , p_transaction_temp_id  IN            NUMBER
  , p_type_code            IN            NUMBER
  , p_rule_id              IN            NUMBER
  , p_reservation_id       IN            NUMBER
  , p_tree_id              IN            NUMBER
  , p_debug_on             IN            BOOLEAN
  , p_order_by_rank        IN            NUMBER
  , p_needed_sec_quantity  IN            NUMBER                        -- new
  , p_secondary_uom        IN            VARCHAR2                      -- new
  , p_grade_code           IN            VARCHAR2                      -- new
  , x_finished             OUT NOCOPY    BOOLEAN
  , x_remaining_quantity   OUT NOCOPY    NUMBER
  ) IS
    l_api_name               VARCHAR2(30) := 'insert_consist_record';
    l_cur_group              NUMBER;
    l_hash_size              NUMBER;
    l_possible_quantity      NUMBER;
    l_needed_quantity        NUMBER;
    l_possible_uom_qty       NUMBER;
    l_sec_possible_quantity  NUMBER;                 -- new
    l_sec_needed_quantity    NUMBER;                 -- new
    l_sec_possible_uom_qty   NUMBER;                 -- new

    l_debug             NUMBER;

  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start Insert Consist Record');
    END IF;

    x_finished       := FALSE;
    -- used in get_hash_value.  That procedure works best if
    -- hashsize is power of 2
    l_hash_size      := POWER(2, 15);
    --get hash index for this consist string
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'get_hash_value', 'Calling get_hash_value');
    END IF;
    l_cur_group      := DBMS_UTILITY.get_hash_value(NAME => g_locs(p_record_id).consist_string, base => 1, hash_size => l_hash_size);

    --Because the hash function can return the same index for different
    -- consist strings, we have to check to see if the group at the index
    -- returned above has the same consist string as the current record.
    -- If not, look at the next record.  Continue on until we find the
    -- correct consist group or determine that the group has not been defined
    -- yet
    LOOP
      EXIT WHEN NOT g_consists.EXISTS(l_cur_group);
      EXIT WHEN NVL(g_consists(l_cur_group).consist_string, '-9999') = NVL(g_locs(p_record_id).consist_string, '-9999');
      l_cur_group  := l_cur_group + 1;
    END LOOP;

    --If we need to take Pick UOM into consideration, we need to determine
    -- how much of this record is needed
    IF p_use_pick_uom THEN
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'pick_uom', 'Handle Pick UOM');
      END IF;

      IF p_needed_quantity < g_locs(p_record_id).quantity THEN
        l_possible_quantity  := p_needed_quantity;
      ELSE
        l_possible_quantity  := g_locs(p_record_id).quantity;
      END IF;

      IF g_consists.EXISTS(l_cur_group) THEN
        l_needed_quantity  := p_needed_quantity - g_consists(l_cur_group).quantity;
        l_sec_needed_quantity  := p_needed_sec_quantity - g_consists(l_cur_group).secondary_quantity;

        IF l_possible_quantity > l_needed_quantity THEN
          l_possible_quantity  := l_needed_quantity;
        END IF;
      END IF;

      IF NVL(g_locs(p_record_id).uom_code, p_primary_uom) <> p_primary_uom THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'start_uom_conversion', 'Converting from primary uom to pick uom');
        END IF;
        --convert from primary uom to pick uom
        l_possible_uom_qty  := inv_convert.inv_um_convert(
                                 p_inventory_item_id
                               , NULL
                               , l_possible_quantity
                               , p_primary_uom
                               , g_locs(p_record_id).uom_code
                               , NULL
                               , NULL
                               );

        --if no conversion defined or some error in conversion,
        --inv_um_convert returns -99999.  In this case, don't carry
        --out any more conversion functions.  possible quantity
        --remains unchanged
        IF (l_possible_uom_qty <> -99999) THEN
          --don't want to pick fractional amounts of pick uom
          l_possible_uom_qty   := FLOOR(l_possible_uom_qty);
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'to_primary_uom', 'Converting from pick uom to primary uom');
          END IF;
          --convert back to primary uom
          l_possible_quantity  := inv_convert.inv_um_convert(
                                    p_inventory_item_id
                                  , NULL
                                  , l_possible_uom_qty
                                  , g_locs(p_record_id).uom_code
                                  , p_primary_uom
                                  , NULL
                                  , NULL
                                  );
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'after_pick_uom_convert', 'Possible quantity after conversion for pick uom: ' || l_possible_quantity);
          END IF;
        END IF;
      END IF;

      x_remaining_quantity  := g_locs(p_record_id).quantity - l_possible_quantity;
    --don't update the g_loc.quantity here.  It'll get updated in Apply.
    ELSE
      x_remaining_quantity  := 0;
      l_possible_quantity   := g_locs(p_record_id).quantity;
    END IF;

    IF l_possible_quantity <= 0 THEN
      x_finished  := FALSE;
      RETURN;
    END IF;

    --If group does exist
    IF g_consists.EXISTS(l_cur_group) THEN
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'group_exists', 'The consist group already exists');
      END IF;
      --set pointer values
      --Bug#4361016.Addedthe below IF Block to make sure that no node has next_rec
      --pointer pointing to itself because this causes infinite loop.
      IF (g_consists(l_cur_group).last_rec = p_record_id) THEN
        g_locs(g_consists(l_cur_group).last_rec).next_rec  := 0;
      ELSE
        g_locs(g_consists(l_cur_group).last_rec).next_rec  := p_record_id;
      END IF;
      g_consists(l_cur_group).last_rec                   := p_record_id;
      --increase group quantity
      g_consists(l_cur_group).quantity                   := g_consists(l_cur_group).quantity + l_possible_quantity;
    --If group does not exist
    ELSE
      IF l_debug =1 THEN
         log_statement(l_api_name, 'new_group', 'Creating a new consist group');
      END IF;
      --create new group
      g_consists(l_cur_group).consist_string  := g_locs(p_record_id).consist_string;
      g_consists(l_cur_group).first_rec       := p_record_id;
      g_consists(l_cur_group).last_rec        := p_record_id;
      g_consists(l_cur_group).next_group      := 0;
      g_consists(l_cur_group).quantity        := l_possible_quantity;
      g_consists(l_cur_group).order_by_rank   := p_order_by_rank;

      IF g_first_consist_group = 0 THEN
        g_first_consist_group  := l_cur_group;
      ELSE
        g_consists(g_last_consist_group).next_group  := l_cur_group;
      END IF;

      g_last_consist_group                    := l_cur_group;
    END IF;

    --If group quantity >= needed qty and the consist group in the first
    --  set of records by sort criteria
    IF  g_consists(l_cur_group).quantity >= p_needed_quantity
        AND g_consists(l_cur_group).order_by_rank = g_first_order_by_rank THEN
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'alloc_group', 'The consist group has enough quantity to allocation. ' || 'Calling allocate_consist_group.');
      END IF;
     --call allocate_consist_group
      allocate_consist_group(
        x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_group_id                   => l_cur_group
      , p_needed_quantity            => p_needed_quantity
      , p_use_pick_uom               => p_use_pick_uom
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_to_subinventory_code       => p_to_subinventory_code
      , p_to_locator_id              => p_to_locator_id
      , p_to_cost_group_id           => p_to_cost_group_id
      , p_primary_uom                => p_primary_uom
      , p_transaction_uom            => p_transaction_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_type_code                  => p_type_code
      , p_rule_id                    => p_rule_id
      , p_reservation_id             => p_reservation_id
      , p_tree_id                    => p_tree_id
      , p_debug_on                   => p_debug_on
      , p_needed_sec_quantity        => l_sec_needed_quantity
      , p_secondary_uom              => p_secondary_uom
      , p_grade_code                 => p_grade_code
      , p_lot_divisible_flag         => inv_cache.item_rec.lot_divisible_flag
      , x_success                    => x_finished
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF l_debug = 1 THEN
           log_error(l_api_name, 'uerr_alloc_consist_group', 'Unexpected error in allocate_consist_group');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug = 1 THEN
           log_error(l_api_name, 'err_alloc_consist_group', 'Error in allocate_consist_group');
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End Insert_Consist_Record');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error - ' || x_msg_data);
      END IF;
     --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;

  END insert_consist_record;

  PROCEDURE invalidate_lpn_group(p_lpn_id IN NUMBER) IS
    l_api_name   VARCHAR2(30) := 'invalidate_lpn_group';
    l_prev_group NUMBER;
    l_next_group NUMBER;
    l_debug      NUMBER;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start Invalidate_Lpn_Group');
       log_statement(l_api_name, 'lpn', 'Invalidating LPN: ' || p_lpn_id);
    END IF;
    g_lpns(p_lpn_id).total_quantity  := -1;
    l_prev_group                     := g_lpns(p_lpn_id).prev_group;
    l_next_group                     := g_lpns(p_lpn_id).next_group;
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'prev', 'Prev LPN: ' || l_prev_group);
       log_statement(l_api_name, 'next', 'Next LPN: ' || l_next_group);
    END IF;

    IF l_prev_group <> 0 THEN
      g_lpns(l_prev_group).next_group  := l_next_group;
    END IF;

    IF l_next_group <> 0 THEN
      g_lpns(l_next_group).prev_group  := l_prev_group;
    END IF;

    IF p_lpn_id = g_first_lpn_group THEN
      g_first_lpn_group  := l_next_group;

      IF g_first_lpn_group = 0 THEN
        g_first_order_by_rank  := NULL;
      ELSE
        g_first_order_by_rank  := g_lpns(g_first_lpn_group).order_by_rank;
      END IF;
    END IF;

    IF g_last_lpn_group = p_lpn_id THEN
      g_last_lpn_group  := l_next_group;
    END IF;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End Invalidate_Lpn_Group');
    END IF;
  END invalidate_lpn_group;

  --bug 2349283 - the INV_Validate function updates the locator table,
  --thus locking the table.  The UpdateLocCapacity function called in
  --Apply for putaway rules also updates the locator table, but in a
  -- different session.  It tries to get a lock on the table, but
  --can't.  So, we get a deadlock.  To resolve this, we make this
  -- function a autonomous transaction, and issue a commit at the end.
  FUNCTION doprojectcheck(
    x_return_status  OUT NOCOPY    VARCHAR2
  , p_locator_id     IN            NUMBER
  , p_project_id     IN            NUMBER
  , p_task_id        IN            NUMBER
  , x_new_locator_id IN OUT NOCOPY NUMBER
  , x_exist_locator_id	OUT NOCOPY NUMBER --Added bug3237702
  )
    RETURN BOOLEAN IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    /*l_locator inv_validate.LOCATOR;
    l_org     inv_validate.org;
    l_sub     inv_validate.sub;*/
    success   NUMBER;
    retval    BOOLEAN;
  BEGIN
   x_exist_locator_id := NULL;
    -- If the current locator doesn't have the project and task segments
    -- populated, then check if another there is a logical locator for this
    -- one with the required
    -- project and task and return FALSE. If none exists then create one and
    -- return TRUE. If the locator has a project and task that is not equal
    -- to the required then return FALSE.
    /*SELECT *
      INTO l_locator
      FROM mtl_item_locations
     WHERE inventory_location_id = p_locator_id; Commented bug3237702*/
     -- Cache for better performance
    if nvl(g_locator_id,-9999) <> p_locator_id THEN
       SELECT *
       INTO g_locator
       FROM MTL_ITEM_LOCATIONS
       WHERE inventory_location_id = p_locator_id;
    end if;
   --Added bug3237702 ends

    --bug 2797980 - added NVL to handle case where task is NULL
   IF (g_locator.project_id = p_project_id AND
      NVL(g_locator.task_id,-1) = NVL(p_task_id,-1)) THEN
     x_new_locator_id := p_locator_id;
     RETURN TRUE;
  ELSE
	IF g_locator.project_id IS NOT NULL THEN
           RETURN FALSE;
	END IF;
  END IF;

  g_locator.inventory_location_id := null;
  g_locator.physical_location_id := p_locator_id;
  g_locator.project_id := p_project_id;
  g_locator.task_id := p_task_id;
  g_locator.segment19 := p_project_id;
  g_locator.segment20 := p_task_id;

  -- Cache for better performance
  retval := inv_cache.set_org_rec(g_locator.organization_id);
/*
  select *
  into l_org
  from mtl_parameters
  where organization_id = l_locator.organization_id;
*/
  retval := inv_cache.set_tosub_rec(g_locator.organization_id, g_locator.subinventory_code);
/*  select *
  into l_sub
  from mtl_secondary_inventories
  where secondary_inventory_name = l_locator.subinventory_code
  and organization_id = l_locator.organization_id;
*/
  success := INV_Validate.ValidateLocator(
                 p_locator => g_locator,
                 p_org => inv_cache.org_rec,
                 p_sub => inv_cache.tosub_rec,
                 p_validation_mode => INV_Validate.EXISTS_OR_CREATE,
                 p_value_or_id => 'I');

  COMMIT;

  x_new_locator_id := g_locator.inventory_location_id;
  if( success = INV_Validate.T and FND_FLEX_KEYVAL.new_combination) then
     return TRUE;
  END IF;

  x_exist_locator_id := g_locator.inventory_location_id;
  -- Locator with project segments already exists
  return FALSE;
END DoProjectCheck;

  --
  -- API name    : Apply
  -- Type        : Private
  -- Function    : Applies a wms rule to the given transaction
  --               input parameters and creates recommendations
  -- Pre-reqs    : Record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
  --               identified by parameters p_transaction_temp_id and
  --               p_type_code ( base table for the view is
  --               MTL_MATERIAL_TRANSACTIONS_TEMP );
  --               At least one transaction detail record in
  --               WMS_TRX_DETAILS_TMP_V identified by line type code = 1
  --               and parameters p_transaction_temp_id and p_type_code
  --               ( base tables are MTL_MATERIAL_TRANSACTIONS_TEMP and
  --               WMS_TRANSACTIONS_TEMP, respectively );
  --               Rule record has to exist in WMS_RULES_B uniquely
  --               identified by parameter p_rule_id;
  --     Package WMS_RULE_(RULEID) must exist;
  --               If picking, quantity tree has to exist, created through
  --               INV_Quantity_Tree_PVT.Create_Tree and uniquely identified
  --               by parameter p_tree_id
  -- Parameters  :
  --   p_api_version          Standard Input Parameter
  --   p_init_msg_list        Standard Input Parameter
  --   p_commit               Standard Input Parameter
  --   p_validation_level     Standard Input Parameter
  --   p_rule_id              Identifier of the rule to apply
  --   p_type_code            Type code of the rule
  --   p_partial_success_allowed_flag
  --            'Y' or 'N'
  --   p_transaction_temp_id  Identifier for the record in view
  --            wms_strategy_mat_txn_tmp_v that represents
  --            the request for detailing
  --   p_organization_id      Organization identifier
  --   p_inventory_item_id    Inventory item identifier
  --   p_transaction_uom      Transaction UOM code
  --   p_primary_uom          Primary UOM code
  --   p_tree_id              Identifier for the quantity tree
  --
  -- Output Parameters
  --   x_return_status        Standard Output Parameter
  --   x_msg_count            Standard Output Parameter
  --   x_msg_data             Standard Output Parameter
  --   x_finished             whether the rule has found enough quantity to
  --                          find a location that completely satisfy
  --                          the requested quantity (value is 'Y' or 'N')
  --
  -- Version
  --   Currently version is 1.0
  --
  -- Notes       : Calls API's of WMS_Common_PVT and INV_Quantity_Tree_PVT
  --               This API must be called internally by
  --               WMS_Strategy_PVT.Apply only !
  --APPLY
  PROCEDURE apply(
    p_api_version                  IN            NUMBER
  , p_init_msg_list                IN            VARCHAR2
  , p_commit                       IN            VARCHAR2
  , p_validation_level             IN            NUMBER
  , x_return_status                OUT NOCOPY    VARCHAR2
  , x_msg_count                    OUT NOCOPY    NUMBER
  , x_msg_data                     OUT NOCOPY    VARCHAR2
  , p_rule_id                      IN            NUMBER
  , p_type_code                    IN            NUMBER
  , p_partial_success_allowed_flag IN            VARCHAR2
  , p_transaction_temp_id          IN            NUMBER
  , p_organization_id              IN            NUMBER
  , p_inventory_item_id            IN            NUMBER
  , p_transaction_uom              IN            VARCHAR2
  , p_primary_uom                  IN            VARCHAR2
  , p_secondary_uom                IN            VARCHAR2                 -- new
  , p_grade_code                   IN            VARCHAR2                 -- new
  , p_transaction_type_id          IN            NUMBER
  , p_tree_id                      IN            NUMBER
  , x_finished                     OUT NOCOPY    VARCHAR2
  , p_detail_serial                IN            BOOLEAN
  , p_from_serial                  IN            VARCHAR2
  , p_to_serial                    IN            VARCHAR2
  , p_detail_any_serial            IN            NUMBER
  , p_unit_volume                  IN            NUMBER
  , p_volume_uom_code              IN            VARCHAR2
  , p_unit_weight                  IN            NUMBER
  , p_weight_uom_code              IN            VARCHAR2
  , p_base_uom_code                IN            VARCHAR2
  , p_lpn_id                       IN            NUMBER
  , p_unit_number                  IN            VARCHAR2
  , p_simulation_mode              IN            NUMBER
  , p_project_id                   IN            NUMBER
  , p_task_id                      IN            NUMBER
  , p_wave_simulation_mode         IN   VARCHAR2 DEFAULT 'N'
  ) IS
    -- API standard variables
    l_api_version   CONSTANT NUMBER                                              := 1.0;
    l_api_name      CONSTANT VARCHAR2(30)                                        := 'Apply';
    -- variables needed for dynamic SQL
    l_cursor                 INTEGER;
    l_rows                   INTEGER;
    -- rule dynamic SQL input variables
    l_pp_transaction_temp_id wms_transactions_temp.pp_transaction_temp_id%TYPE;
    l_revision               wms_transactions_temp.revision%TYPE;
    l_lot_number             wms_transactions_temp.lot_number%TYPE;
    l_lot_expiration_date    wms_transactions_temp.lot_expiration_date%TYPE;
    l_from_subinventory_code wms_transactions_temp.from_subinventory_code%TYPE;
    l_to_subinventory_code   wms_transactions_temp.to_subinventory_code%TYPE;
    l_subinventory_code      wms_transactions_temp.to_subinventory_code%TYPE;
    l_from_locator_id        wms_transactions_temp.from_locator_id%TYPE;
    l_to_locator_id          wms_transactions_temp.to_locator_id%TYPE;
    l_locator_id             wms_transactions_temp.to_locator_id%TYPE;
    l_from_cost_group_id     wms_transactions_temp.from_cost_group_id%TYPE;
    l_to_cost_group_id       wms_transactions_temp.to_cost_group_id%TYPE;
    l_cost_group_id          wms_transactions_temp.to_cost_group_id%TYPE;
    l_lpn_id                 wms_transactions_temp.lpn_id%TYPE;
    l_initial_pri_quantity   wms_transactions_temp.primary_quantity%TYPE;
    -- rule dynamic SQL output variables
    l_orevision              wms_transactions_temp.revision%TYPE;
    l_olot_number            wms_transactions_temp.lot_number%TYPE;
    l_olot_expiration_date   wms_transactions_temp.lot_expiration_date%TYPE;
    l_osubinventory_code     wms_transactions_temp.from_subinventory_code%TYPE;
    l_olocator_id            wms_transactions_temp.from_locator_id%TYPE;
    l_olocator_id_prev       wms_transactions_temp.from_locator_id%TYPE;
    l_olocator_id_new        wms_transactions_temp.from_locator_id%TYPE;
    l_ocost_group_id         wms_transactions_temp.from_cost_group_id%TYPE;
    l_olpn_id                wms_transactions_temp.lpn_id%TYPE;
    l_possible_quantity      wms_transactions_temp.primary_quantity%TYPE;
    l_possible_trx_qty       wms_transactions_temp.transaction_quantity%TYPE;
    l_sec_possible_quantity  wms_transactions_temp.secondary_quantity%TYPE;
    l_sec_possible_trx_qty   wms_transactions_temp.transaction_quantity%TYPE;
    l_reservation_id         wms_transactions_temp.reservation_id%TYPE;
    -- variables needed for qty tree
    l_qoh                    NUMBER;
    l_rqoh                   NUMBER;
    l_qr                     NUMBER;
    l_qs                     NUMBER;
    l_att                    NUMBER;
    l_atr                    NUMBER;
    l_sqoh                   NUMBER;
    l_srqoh                  NUMBER;
    l_sqr                    NUMBER;
    l_sqs                    NUMBER;
    l_satt                   NUMBER;
    l_satr                   NUMBER;
    --
    l_rule_func_sql          LONG;
    l_rule_result            NUMBER;
    l_dummy                  NUMBER;
    l_pack_exists            NUMBER;
    l_serial_control_code    NUMBER;
    l_is_serial_control      NUMBER;
    l_package_name           VARCHAR2(128);
    l_msg_data               VARCHAR2(240);
    l_msg_count              NUMBER;
    l_rule_id                NUMBER;
    l_unit_number            VARCHAR2(30);
    --variables related to pick by UOM
    l_uom_code               VARCHAR2(3);
    l_order_by_string        VARCHAR2(1000);
    l_consist_string         VARCHAR2(1000);
    l_cur_order_by_string    VARCHAR2(1000)                                      := '-9999999';
    l_default_pick_rule      NUMBER;
    l_default_put_rule       NUMBER;
    l_allowed                VARCHAR2(1);
    l_loc_avail_units        NUMBER;
    l_capacity_updated       BOOLEAN;
    l_consider_staging_capacity   BOOLEAN; --Added bug3237702
    l_return_status          VARCHAR2(1);
    l_consist_exists         BOOLEAN;
    l_comingle               VARCHAR2(1);
    l_serial_number          VARCHAR2(30);
    l_detail_serial          NUMBER;
    l_found                  BOOLEAN;
    l_first_serial           NUMBER;
    l_locs_index             NUMBER; --index to v_locs table
    l_debug_on               BOOLEAN;
    l_uom_index              NUMBER;
    l_lpn_controlled_flag    NUMBER;
    l_check_cg               BOOLEAN;
    l_restrict_subs_code     NUMBER;
    l_restrict_locs_code     NUMBER;
    l_quantity_function      NUMBER;
    v_current_row            t_location_rec;
    --added to support allocation mode
    l_cur_lpn_group          NUMBER;
    l_cur_lpn_rec            NUMBER;
    l_inserted_record        BOOLEAN;
    l_needed_quantity        NUMBER;
    l_expected_quantity      NUMBER;
    l_allocated_quantity     NUMBER;
    l_remaining_quantity     NUMBER;
    l_allocation_mode        NUMBER;
    l_sec_needed_quantity    NUMBER;                          -- new
    l_sec_expected_quantity  NUMBER;                          -- new
    l_sec_allocated_quantity NUMBER;                          -- new
    l_sec_remaining_quantity NUMBER;                          -- new
    l_grade_code             VARCHAR2(150);                   -- new
    l_cur_uom_rec            NUMBER;
    l_first_uom_rec          NUMBER;
    l_last_uom_rec           NUMBER;
    l_finished               BOOLEAN;
    l_cur_consist_group      NUMBER;
    l_use_pick_uom           BOOLEAN;
    l_order_by_rank          NUMBER                                              := 0;
    l_cur_rec                NUMBER;
    l_prev_rec               NUMBER;
    l_next_rec               NUMBER;
    l_hash_size              NUMBER;
    l_sub_rsv_type	     NUMBER;

    --added to support pjm
    l_project_id             NUMBER;
    l_oproject_id            NUMBER;
    l_task_id                NUMBER;
    l_otask_id               NUMBER;
    l_input_lpn_id           NUMBER;
    --- Initilization of Ref cursors for Pick and putaway rules
    -- Added to pass into DoProjectCheck new parameter used in other apply procedure  Bug3237702
    l_dummy_loc              NUMBER;
    v_pick_cursor            wms_rule_pvt.cv_pick_type;
    v_put_cursor             wms_rule_pvt.cv_put_type;
    l_debug                  NUMBER;   -- 1 for debug is on , 0 for debug is off
    l_progress               VARCHAR2(10);  -- local variable to track program progress,
                                            -- especially useful when exception occurs
    l_rule_counter           INTEGER;

    ---- Mat Status Check Variables
    l_serial_trx_allowed        VARCHAR2(1);
    l_sub_loc_lot_trx_allowed   VARCHAR2(1);
    l_serial_status_id          NUMBER;

    ---

    l_serial_status   INV_CACHE.ITEM_REC.serial_status_enabled%TYPE;
    l_lot_status      INV_CACHE.ITEM_REC.lot_status_enabled%TYPE;

    ---- End Mat Status Var

    l_lot_divisible_flag       VARCHAR2(1);

    l_rule_override_flag       VARCHAR2(1);
    l_lot_control_code         NUMBER;
    l_revision_control_code    NUMBER;
    l_grade_control_flag       VARCHAR2(1);
    l_reservation_is_detailed  VARCHAR2(1);
    l_sl_rsv_is_detailed       VARCHAR2(1);

    l_return_value             BOOLEAN; -- [ Added ]
   ---
    l_allocate_serial_flag     VARCHAR2(1);
    l_custom_select_serials    INV_DETAIL_UTIL_PVT.g_serial_row_table_rec;
    l_custom_serial_index      NUMBER;

    -- [ Lot Indivisible Var
    l_indiv_lot_allowed        VARCHAR2(1); -- [ Added ]
    l_max_tolerance 	       NUMBER;
    l_min_tolerance            NUMBER;

    -- LPN Status Project
    l_onhand_status_trx_allowed VARCHAR2(1);
    l_default_status_id        NUMBER ;
    -- LPN Status Project
    l_default_inv_pick_rule  NUMBER;      --added for bug8310188
    l_wms_enabled_flag         VARCHAR2(1); --added for bug8310188

    --cursor used to determine if suggestions should be minimized
    -- for this rule.  This flag affects how the Pick UOM functionality
    -- works.
    CURSOR c_allocation_mode IS
      SELECT allocation_mode_id
           , qty_function_parameter_id
        FROM wms_rules_b
       WHERE rule_id = l_rule_id;

    --cursor used to determine if rule has any consistency requirements
    CURSOR l_consist IS
      SELECT consistency_id
        FROM wms_rule_consistencies
       WHERE rule_id = l_rule_id;

    --cursor to get the total quantity for the LPN
    CURSOR c_lpn_quantity IS
      SELECT SUM(primary_transaction_quantity)
        FROM mtl_onhand_quantities_detail
       WHERE lpn_id = v_current_row.lpn_id;

    --Bug 5251221, cursor to get the serials which are allocated for the current rule
    CURSOR l_get_serial IS
       SELECT serial_number FROM wms_transactions_temp
       WHERE rule_id = l_rule_id;


  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    l_progress := 10;

    -- debugging portion
    -- can be commented ut for final code
    if (nvl(inv_cache.is_pickrelease, FALSE) OR p_wave_simulation_mode = 'Y') THEN
      If (l_debug = 1) then
       log_event(l_api_name, 'Check if Pick Release', 'True');
      End if;
      l_consider_staging_capacity := FALSE;
    else
      If (l_debug = 1) then
       log_event(l_api_name, 'Check if Pick Release', 'False');
      End if;
      l_consider_staging_capacity := TRUE;
    end if;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start wms_rule_pvt.Apply');
       log_event(l_api_name, 'Apply ', 'org_id '||p_organization_id);
       log_event(l_api_name, 'Apply ', 'item_id '||p_inventory_item_id);
    END IF;
    -- end of debugging section
    --
    -- Standard start of API savepoint
    SAVEPOINT applyrulesp;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

  -- LPN Status Project
    if (inv_cache.set_org_rec(p_organization_id)) then
       l_default_status_id :=  nvl(inv_cache.org_rec.default_status_id,-1);
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'Value of l_default_status_id: ', l_default_status_id);
       END IF;
    end if;
   -- LPN Status Project

    --
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    --
    -- Initialize functional return status to completed
    x_finished       := fnd_api.g_true;

    --
    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    IF p_validation_level <> fnd_api.g_valid_level_none THEN
      IF p_type_code IS NULL
         OR p_type_code = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_RULE_TYPE_CODE_MISSING');
          fnd_msg_pub.ADD;

          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'type_code_missing');
          END IF;

        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      /* get the org defaults */
      IF l_debug = 1 THEN
         log_statement(l_api_name,'no_rule','Getting default rule at org level');
      END IF;
      -- 8809951 start, removed cursors and using INV CACHE
       IF (INV_CACHE. set_org_rec(p_organization_id) ) THEN
			l_default_pick_rule         := inv_cache.org_rec.default_wms_picking_rule_id;
			l_default_put_rule          := inv_cache.org_rec.default_put_away_rule_id;
			l_rule_override_flag        := inv_cache.org_rec.rules_override_lot_reservation;
			l_default_inv_pick_rule   := inv_cache.org_rec.default_picking_rule_id;
			l_wms_enabled_flag       := inv_cache.org_rec.wms_enabled_flag;
       END If;

         -- 8809951 end
      --changed by jcearley on 11/22/99, b/c a null rule_id is now allowed
      --  if rule_id is null, use default rule (0 for put away, 1 for pick)
      IF p_rule_id IS NULL
         OR p_rule_id = fnd_api.g_miss_num THEN
        --query org parameters to get user's default rule
        --if default rule not defined, use default seeded rule
        IF p_type_code = 1 THEN --put away
          l_rule_id  := l_default_put_rule;
          IF l_rule_id IS NULL THEN
             IF l_debug = 1 THEN
                log_statement(l_api_name, 'no_org_rule_put',
                             'Did not find org default put away rule');
             END IF;
            l_rule_id  := 10;
          END IF;
        ELSE --pick
           --start adding code for bug8310188
	      IF l_wms_enabled_flag ='Y' THEN
               l_rule_id  := l_default_pick_rule;
	      ELSE
               l_rule_id  := l_default_inv_pick_rule;
	      END IF ;
          --end adding code for bug8310188
          IF l_rule_id IS NULL THEN
             IF l_debug = 1 THEN
                log_statement(l_api_name, 'no_org_rule_put',
                                'Did not find org default put away rule');
          END IF;
            l_rule_id  := 2;
          END IF;
        END IF;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'default_rule',
                                'Rule being used: ' || l_rule_id);
        END IF;
      ELSE
        l_rule_id  := p_rule_id;
      END IF;

      IF p_partial_success_allowed_flag IS NULL
         OR p_partial_success_allowed_flag = fnd_api.g_miss_char THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_PARTIAL_SUCC_FLAG_MISS');
           IF l_debug = 1 THEN
              log_error_msg(l_api_name, 'partial_succ_flag_missing');
           END IF;
          fnd_msg_pub.ADD;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_transaction_temp_id IS NULL
         OR p_transaction_temp_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_TRX_REQ_LINE_ID_MISS');
          fnd_msg_pub.ADD;
           IF l_debug = 1 THEN
              log_error_msg(l_api_name, 'trx_req_line_id_missing');
           END IF;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_organization_id IS NULL
         OR p_organization_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('INV', 'INV_NO_ORG_INFORMATION');
          fnd_msg_pub.ADD;
          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'org_id_missing');
          END IF;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_inventory_item_id IS NULL
         OR p_inventory_item_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('INV', 'INV_ITEM_ID_REQUIRED');
          fnd_msg_pub.ADD;
          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'item_id_missing');
          END IF;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF  p_type_code = 2
          AND (p_tree_id IS NULL
               OR p_tree_id = fnd_api.g_miss_num
              ) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('INV', 'INV_QTY_TREE_ID_MISSING');
          fnd_msg_pub.ADD;
          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'qty_tree_id_missing');
          END IF;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --inv_pp_debug.send_message_to_pipe('finished validations and qty tree init');
    --
    -- backup qty tree
    IF p_type_code = 2 THEN
       IF l_debug = 1 THEN
          log_statement(l_api_name, 'PICK','PICK');
          log_statement(l_api_name, 'backup_tree',
                       'Calling inv_quantity_tree_pvt.backup_tree');
       END IF;
      inv_quantity_tree_pvt.backup_tree(x_return_status, p_tree_id);
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
       IF l_debug = 1 THEN
          log_statement(l_api_name, 'backup_tree_unexp_err',
                       'Unexpected error from inv_quantity_tree_pvt.backup_tree');
       END IF;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'backup_tree_err',
                       'Error from inv_quantity_tree_pvt.backup_tree');
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
      --does the rule have any consistency restrictions?
      OPEN l_consist;
      FETCH l_consist INTO l_dummy;
      IF l_consist%NOTFOUND THEN
        l_consist_exists  := FALSE;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'consist_exist_false',
                       'Consistencies do not exist');
        END IF;
      ELSE
        l_consist_exists  := TRUE;
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'consist_exist_true', 'Cosistencies exist');
         END IF;
      END IF;
      CLOSE l_consist;
    END IF;
    --log_statement(l_api_name, 'allocation_mode', 'consist done');
    --
    --Get allocation mode
    OPEN c_allocation_mode;
    FETCH c_allocation_mode INTO l_allocation_mode, l_quantity_function;

    --log_statement(l_api_name, 'allocation_mode', 'allocation_mode '||l_allocation_mode);

    IF c_allocation_mode%NOTFOUND
       OR l_allocation_mode IS NULL THEN
      --by default, make allocation mode 3
      l_allocation_mode  := 3;
    END IF;

    CLOSE c_allocation_mode;


    IF l_allocation_mode IN (3, 4, 5) THEN --value = 5 added for R12.1 replenishment project
      l_use_pick_uom  := TRUE;
    ELSE
      l_use_pick_uom  := FALSE;
    END IF;

    -- make sure, everything is clean
    freeglobals;
    wms_parameter_pvt.clearcache;
    --log_statement(l_api_name, 'apply', 'all cache cleared ');
    --
    g_trace_recs.DELETE;
    l_debug_on       := isruledebugon(p_simulation_mode);
    -- - [
    --query items table to see if item is serial controlled (picking) or if it
    --restricts subs or locators (putaway)

  /*  OPEN l_cur_serial;
    FETCH l_cur_serial
    INTO l_serial_control_code
       , l_restrict_subs_code
       , l_restrict_locs_code
       , l_lot_divisible_flag
       , l_lot_control_code
       , l_revision_control_code
       , l_grade_control_flag
       ;

    log_statement(l_api_name, 'apply', 'fecth iitem info done ');
    IF l_cur_serial%NOTFOUND THEN
      l_serial_control_code  := 1;
      l_restrict_subs_code   := 2;
      l_restrict_locs_code   := 2;
    END IF;

    CLOSE l_cur_serial;  */


    -- Removed the above code and added the following variables for performances

      l_return_value := INV_CACHE.set_item_rec(
				   p_organization_id,
				   p_inventory_item_id);
      If NOT l_return_value Then
	If l_debug = 1 then
	   log_statement(l_api_name, '-', 'Error setting from sub cache');
	end if;
	RAISE fnd_api.g_exc_unexpected_error;
      End If;

      l_serial_control_code 	:= NVL(inv_cache.item_rec.serial_number_control_code,1);
      l_restrict_subs_code  	:= NVL(inv_cache.item_rec.restrict_subinventories_code, 2);
      l_restrict_locs_code  	:= NVL(inv_cache.item_rec.restrict_locators_code, 2);
      l_lot_divisible_flag  	:= inv_cache.item_rec.lot_divisible_flag;
      l_lot_control_code    	:= inv_cache.item_rec.lot_control_code;
      l_revision_control_code 	:= inv_cache.item_rec.revision_qty_control_code;
      l_grade_control_flag 	:= inv_cache.item_rec.grade_control_flag;

    -- ]

    -- Only detail serial numbers if they are prespecified or entered
    -- at inventory receipt for this item.
    IF p_type_code = 2 THEN --pick
      IF l_serial_control_code IN (2, 5) THEN
         l_is_serial_control  := 1;
      ELSE
         l_is_serial_control  := 0;
      END IF;
    ELSE
      l_is_serial_control  := 0;
    END IF;

    IF p_detail_serial = TRUE THEN
      l_detail_serial  := 1;
    ELSE
      l_detail_serial  := 0;
    END IF;
    ------------ Added new code -----


       -- Logic to improve the performance for Material Status Checks
       -- Getting Values from  INV CACHE  and setting the l_detail_serial flag based on the following algoritham
       -- Based on the l_detail_falg, Serial_material status would be checked inside the Rule packages or
       -- Rules Engine API.
       -- ** Serial Mat.Status Check inside Rule Sql(R) / Engine (E)
       /*------------------------------------------------------------------------------------------------
        Serial   Serial   Serial      MSN          Group By         Serial Mat.Status     l_detail_serial
        Allowed  Status   Rule Objs   to be used   LOT/SUb/Loc  Required    Check in RuleSql
        -------------------------------------------------------------------------------------------------
        Y          Y       Y           Y             N            Y		Engine			1
        Y          Y       N           Y             N            Y  		Engine			1
        Y          N       Y           Y             N            N		-			2
        Y          N       N           Y             N            N		-			2
        --------------------------------------------------------------------------------------------------
        N          Y       Y           Y             Y            Y		Rule			3
        N          Y       N           Y             Y            Y  		Rule			3
        N          N       Y           Y             Y            N		-			4
        N          N       N           N(MOQD)       N            N		-			0
       --------------------------------------------------------------------------------------------------*/
   IF l_is_serial_control  = 1 THEN
       l_serial_status      := INV_CACHE.ITEM_REC.serial_status_enabled;
       --l_serial_status_id := INV_CACHE.ITEM_REC.serial_status_id;
       l_lot_status       := INV_CACHE.ITEM_REC.lot_status_enabled;

       IF l_detail_serial = 1 THEN
          IF  NVL(l_serial_status, 'N')  = 'Y'  THEN
               l_detail_serial := 1;
          ELSE
               l_detail_serial := 2;
          END IF;
       ELSE
          IF NVL(l_serial_status, 'N')  = 'Y'  THEN
               l_detail_serial := 3;
	  ELSE
	       l_detail_serial := 0;
          END IF;
      END IF;

    --- Checking, if any Serial object based attributes used by any Picking rules
    IF l_detail_serial =  0  THEN
      IF IsSerialObjectUsed( p_organization_id ) THEN
         l_detail_serial := 4;
      END IF;
     END IF;
    END IF;
    --
    -- [ If the org level flag is set to use Custom logic for Serial numbers,
    -- the MSNT is used but grouped by sub/loc
    If p_type_code = 2  THEN
       l_allocate_serial_flag := inv_cache.org_rec.allocate_serial_flag;
    END IF;

    IF  l_allocate_serial_flag = 'C' Then
       l_detail_serial := 4;
    End If;
     -- ]
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'l_detail_serial', l_detail_serial);
       log_statement(l_api_name, 'input_proj', 'Project: ' || p_project_id);
       log_statement(l_api_name, 'input_task', 'Task: ' || p_task_id);
    END IF;
    /*
    --- Bug      5504458
    --- Added the following code to handle the entire LPN mode as 'loose   LPN'
    --- for serial controlled item with serial allocation on
    --- Not sure if it correct or not because I don't see the business case.
    IF l_detail_serial  in (1,2) and l_allocation_mode = 1  THEN
       l_allocation_mode := 2;
    End if;

    --- End of 5504458
   */

    --get the name of the rule package
    getpackagename(l_rule_id, l_package_name);
    -- Initialize the pointer to the first trx detail input line
    wms_re_common_pvt.initinputpointer;
    --
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'start_input_loop',
                    'Starting loop through input lines');
    END IF;
    -- Loop through all the trx detail input lines
    WHILE TRUE LOOP
      --
      l_max_tolerance := 0;
      -- Get the next trx detail input line
      wms_re_common_pvt.getnextinputline(
        l_pp_transaction_temp_id
      , l_revision
      , l_lot_number
      , l_lot_expiration_date
      , l_from_subinventory_code
      , l_from_locator_id
      , l_from_cost_group_id
      , l_to_subinventory_code
      , l_to_locator_id
      , l_to_cost_group_id
      , l_needed_quantity
      , l_sec_needed_quantity
      , l_grade_code
      , l_reservation_id
      , l_serial_number -- [ new code ]
      , l_lpn_id
      );
      EXIT WHEN l_pp_transaction_temp_id IS NULL;
      -- [ roll up the rem_tol_qty for Lot inadvisable items  ,   for picking
      --   This logic is not implemented . To be implemented in feature  ]

      IF l_debug = 1 THEN
        log_statement(l_api_name, 'input_rec', 'Got next input line');
        log_statement(l_api_name, 'input_rev', 'rev:' || l_revision);
        log_statement(l_api_name, 'input_lot', 'lot:' || l_lot_number);
        log_statement(l_api_name, 'input_serial', 'serial number:' || l_serial_number);
        log_statement(l_api_name, 'input_sub', 'sub:' || l_from_subinventory_code);
        log_statement(l_api_name, 'input_loc', 'loc:' || l_from_locator_id);
        log_statement(l_api_name, 'input_cg', 'cg:'   || l_from_cost_group_id);
        log_statement(l_api_name, 'input_tsub', 'tsub:' || l_to_subinventory_code);
        log_statement(l_api_name, 'input_tloc', 'tloc:' || l_to_locator_id);
        log_statement(l_api_name, 'input_tcg', 'tcg:' || l_to_cost_group_id);
        log_statement(l_api_name, 'input_lpn', 'lpn:' || l_lpn_id);
        log_statement(l_api_name, 'input_qty', 'qty:' || l_needed_quantity);
        log_statement(l_api_name, 'input_qty', 'sec_qty:' || l_sec_needed_quantity);

      END IF;
      -- [ compute line level tolerances for lot indivisible item for non-reserved lines
      --   and the l_needed qty is adjusted to max allowed qty based on the max tol Qty
      --   If the tol qty is zero, then the l_needed qty remains unchanged. ]
      IF    l_lot_divisible_flag = 'N'
        and l_lot_control_code <> 1
        and p_type_code = 2
        --and l_reservation_id is null -- Commented code to account for manual reservations
	THEN
          l_max_tolerance   :=  g_max_tolerance   ;
          l_needed_quantity :=  l_needed_quantity + l_max_tolerance;
      ELSIF p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
          IF g_max_tolerance < 0 THEN
               l_max_tolerance   := g_max_tolerance;
               l_needed_quantity := l_needed_quantity + l_max_tolerance;
          ELSIF l_allocation_mode in (1, 5) THEN
               l_max_tolerance   := g_max_tolerance;
               l_needed_quantity := l_needed_quantity + l_max_tolerance;
          ELSE
               l_max_tolerance   := 0;
          END IF;
      ELSE
          l_max_tolerance   := 0;
      END IF;
      IF l_debug = 1 THEN
          log_statement(l_api_name, 'New Needed Qty with tolerance ', 'qty:' || l_needed_quantity);
      END IF;

      IF ((p_project_id IS NOT NULL) AND (l_to_locator_id IS NOT NULL) AND (p_type_code = 1)) THEN
        --bug 2400549 - for WIP backflush transfer putaway,
        --always use the locator specified on the move order line, even
        --if that locator is from common stock (not project)
        --Bug 2666620: BackFlush MO Type Removed. It is now 5. Moreover Txn Action ID is 2 which is
        --already handled.
        IF NOT (wms_engine_pvt.g_move_order_type = 5 AND wms_engine_pvt.g_transaction_action_id = 2) THEN
           IF l_debug = 1 THEN
              log_statement(l_api_name, 'do_project1', 'Calling do project check');
           END IF;
          IF doprojectcheck(l_return_status, l_to_locator_id, p_project_id, p_task_id, l_to_locator_id, l_dummy_loc) THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'do_project1_success', 'Do Project Check passed');
            END IF;
            NULL;
          END IF;
        END IF;
      END IF;

      --
      -- Save the initial input qty for later usage
      l_initial_pri_quantity  := l_needed_quantity;
      l_input_lpn_id          := l_lpn_id;

      IF p_type_code = 2 THEN
        --check for null values.  NULL produces error in stored procedure,
        --  so we treat -9999 as NULL;
        -- since revision is varchar(3), use -99
        -- we only want to overwrite revision and lot for pick rules, since
        -- we use these values in putaway.
        IF (l_revision IS NULL) THEN
          l_revision  := '-99';
        END IF;
        IF (l_lot_number IS NULL) THEN
          l_lot_number  := '-9999';
        END IF;
      END IF;

      IF (p_type_code = 2) THEN --pick
        l_subinventory_code  := l_from_subinventory_code;
        l_locator_id         := l_from_locator_id;
        l_cost_group_id      := l_from_cost_group_id;
      ELSE --put away
        l_subinventory_code  := l_to_subinventory_code;
        l_locator_id         := l_to_locator_id;
        l_cost_group_id      := l_to_cost_group_id;
      END IF;

      IF (l_subinventory_code IS NULL) THEN
        l_subinventory_code  := '-9999';
      END IF;

      IF (l_locator_id IS NULL) THEN
        l_locator_id  := -9999;
      END IF;

      IF (l_cost_group_id IS NULL) THEN
        l_cost_group_id  := -9999;
      END IF;

      IF (l_lpn_id IS NULL) THEN
        l_lpn_id  := -9999;
      END IF;

      IF (p_project_id IS NULL) THEN
        l_project_id  := -9999;
      ELSE
        l_project_id  := p_project_id;
      END IF;

      IF (p_task_id IS NULL) THEN
        l_task_id  := -9999;
      ELSE
        l_task_id  := p_task_id;
      END IF;

      IF (p_unit_number IS NULL) THEN
        l_unit_number  := '-9999';
      ELSE
        l_unit_number  := p_unit_number;
      END IF;

      IF l_debug = 1 THEN
           log_statement(l_api_name, 'Set value for l_sl_rsv_is_detailed', 'if serial number is reserved');
           log_statement(l_api_name, 'l_serial_number',  l_serial_number);
           log_statement(l_api_name, 'l_rule_id',  l_rule_id);
           log_statement(l_api_name, 'l_reservation_id',  l_reservation_id);

      END IF;
      -- [ new code to check the serial number reservation ]

      l_sl_rsv_is_detailed := 'N' ;
      IF NVL(l_serial_number, '-999') <> '-999'  AND (  NVL(l_rule_id, 777)  = -999 or  NVL(l_reservation_id , 999) <> 999 ) THEN
         l_sl_rsv_is_detailed := 'Y' ;
      END IF;


      /* LG. Check the txn dtl lines with the control flags, then check the override rule flag
       * from the mtl_parameters, allocate directly if res is fully detailed.
       */
       --[
       -- If the Serial Number is reserved, Rules are not called and following code is called
       --]
      IF ( l_rule_override_flag = 'Y' OR  l_sl_rsv_is_detailed = 'Y' )  and p_type_code = 2 THEN
        IF l_debug = 1 THEN
           log_statement(l_api_name,'detailed', 'Rule Override flag is set ');
        END IF;
        -- Validate the txn detail
        l_reservation_is_detailed := 'Y';

	IF l_debug = 1 THEN
 	               log_statement(l_api_name,'detailed', 'Subinventory should be there '|| l_subinventory_code);
 	         END IF;

 	         IF Nvl(l_subinventory_code, '-9999') = '-9999' THEN
 	           l_reservation_is_detailed := 'N';
 	         END IF;

        IF (wms_engine_pvt.g_org_loc_control IN (2, 3)                 -- org level
                OR wms_engine_pvt.g_sub_loc_control IN (2, 3)          -- sub level
                OR (wms_engine_pvt.g_sub_loc_control = 5               -- item level
                       AND wms_engine_pvt.g_item_loc_control IN (2, 3)
                   )
           )
        THEN
           IF l_debug = 1 THEN
              log_statement(l_api_name,'detailed', 'Locator should be there '|| l_locator_id);
           END IF;
           IF nvl(l_locator_id,-9999) = -9999 THEN
              l_reservation_is_detailed := 'N';
           END IF;
        END IF;

        IF l_lot_control_code <> 1 THEN -- lot controlled
           IF l_debug = 1 THEN
              log_statement(l_api_name,'detailed', 'Lot should be there'|| l_lot_number);
           END IF;
           IF nvl(l_lot_number,'-9999') = '-9999' THEN
              l_reservation_is_detailed := 'N';
           END IF;
        END IF;

        IF l_revision_control_code <> 1 THEN   -- revision controlled
           IF l_debug = 1 THEN
              log_statement(l_api_name,'detailed', 'Revision should be there'|| l_Revision);
           END IF;
           IF nvl(l_revision,'-99') = '-99' THEN
              l_reservation_is_detailed := 'N';
           END IF;
        END IF;
        /*IF l_grade_control_flag = 'Y'  THEN   -- grade controlled
           IF l_debug = 1 THEN
              log_statement(l_api_name,'detailed', 'Grade should be there'|| l_grade_code);
           END IF;
           IF nvl(l_grade_code,'-9999') = '-9999' THEN
              l_reservation_is_detailed := 'N';
           END IF;
        END IF;*/

        IF ( l_reservation_is_detailed = 'Y' OR  l_sl_rsv_is_detailed = 'Y' ) THEN
           IF l_debug = 1 THEN
              log_statement(l_api_name,'detailed', 'Reservation is fully detailed, validate and insert');
           END IF;

           -- [Checking the material status for serial /lots
           --  OPM Convergence project missed the mat-status check
           -- Logic : if the lot or serial number's material status is not allowed for transactions
           --         even though there is detailed reservations exist in the system, rule engine will
           --         ignore the record
           --         The mat-status is applicable for serial reserved items too ]

                l_sub_loc_lot_trx_allowed 	:= 'Y';
	        l_serial_trx_allowed		:= 'Y';
	        l_serial_status_id 	 	:= 0;
	        IF ((l_serial_number  IS NOT NULL)  AND  (NVL(l_serial_status, 'N')  = 'Y'))  THEN
	           select status_id
	             into l_serial_status_id
	             from mtl_serial_numbers
	            where inventory_item_id        = p_inventory_item_id
	              and current_organization_id  = p_organization_id
	              and serial_number            = l_serial_number;

	             l_serial_trx_allowed := inv_detail_util_pvt.is_serial_trx_allowed(
	                                          p_transaction_type_id
	                                         ,p_organization_id
	                                         ,p_inventory_item_id
	                                         ,l_serial_status_id) ;
	        END IF;
               -- Bug 4756156
	       -- IF  ((l_lot_number IS NOT NULL)  AND (nvl(l_lot_status, 'Y') = 'Y'))  THEN
	            l_sub_loc_lot_trx_allowed :=   inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(
	                                          p_transaction_type_id
	                                         ,p_organization_id
	                                         ,p_inventory_item_id
	                                         ,l_subinventory_code
	                                         ,l_locator_id
	                                         ,l_lot_number);
	       -- END IF;
	        If  ( l_serial_trx_allowed <> 'Y' and l_sub_loc_lot_trx_allowed <> 'Y' ) THEN
	             --   skip the input record and go to next rec , because mat status is not allowed
	            IF l_debug = 1 THEN
		       log_statement(l_api_name, 'Mat Status Check failed', 'Skipping the input rec');
	            END IF;
	            GOTO nextINputrecord;
	        END IF;
           -- End of mat status check ]

           -- [ Allocating this line based on reservation without calling rules
           --   Make sure all the following values are either NULL or have some
           --   real values but not the defaulted values  eg '-99' or '-9999' etc..
           --   The  default values '-99', '-9999' may cause issues with Qty tree
           --   May have to default the value for Project, Task , unit
           --   This only applicable for line based on detailed reservation
           -- ]

           IF l_revision = '-99' THEN
              l_revision := NULL;
           END IF;

           IF l_subinventory_code = '-9999' THEN
              l_subinventory_code := NULL;
           END IF;

           IF l_locator_id  = -9999 THEN
              l_locator_id := NULL;
           END IF;

           IF  l_cost_group_id  = -9999 THEN
	       l_cost_group_id := NULL;
	   END IF;

	   IF l_lpn_id = -9999 THEN
	      l_lpn_id := NULL;
	   END IF;

	  IF (l_lot_number =  '-9999' ) THEN
	      l_lot_number  := NULL;
          END IF;

           g_locs(1).revision               := l_revision;
           g_locs(1).lot_number             := l_lot_number;
           g_locs(1).subinventory_code      := l_subinventory_code;
           g_locs(1).locator_id             := l_locator_id;
           g_locs(1).quantity               := l_needed_quantity;
           g_locs(1).secondary_quantity     := l_sec_needed_quantity;
           g_locs(1).serial_number          := l_serial_number; -- [ new code ]
           g_locs(1).lpn_id                 := l_lpn_id; --8722417


           validate_and_insert(
             x_return_status              => x_return_status
           , x_msg_count                  => x_msg_count
           , x_msg_data                   => x_msg_data
           , p_record_id                  => 1
           , p_needed_quantity            => l_needed_quantity
           , p_use_pick_uom               => FALSE
           , p_organization_id            => p_organization_id
           , p_inventory_item_id          => p_inventory_item_id
           , p_to_subinventory_code       => l_to_subinventory_code
           , p_to_locator_id              => l_to_locator_id
           , p_to_cost_group_id           => l_to_cost_group_id
           , p_primary_uom                => p_primary_uom
           , p_transaction_uom            => p_transaction_uom
           , p_transaction_temp_id        => p_transaction_temp_id
           , p_type_code                  => p_type_code
           , p_rule_id                    => l_rule_id
           , p_reservation_id             => l_reservation_id
           , p_tree_id                    => p_tree_id
           , p_debug_on                   => l_debug_on
           , p_needed_sec_quantity        => l_sec_needed_quantity
           , p_secondary_uom              => p_secondary_uom
           , p_grade_code                 => p_grade_code
           , x_inserted_record            => l_inserted_record
           , x_allocated_quantity         => l_allocated_quantity
           , x_remaining_quantity         => l_remaining_quantity
           , x_sec_allocated_quantity     => l_sec_allocated_quantity
           , x_sec_remaining_quantity     => l_sec_remaining_quantity
           );
           IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
             IF l_debug = 1 THEN
                log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
             END IF;
             RAISE fnd_api.g_exc_unexpected_error;
           ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
             IF l_debug = 1 THEN
                log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
             END IF;
             RAISE fnd_api.g_exc_error;
           END IF;
           /* done with this res go to the next */
           GOTO nextINputrecord;
        END IF;
      END IF;

      IF l_debug = 1 THEN
        IF p_type_code = 1 THEN
           log_statement(l_api_name, 'Input Rec :Calling rule with following value of type -', 'Putaway');
        ELSE
           log_statement(l_api_name, 'Input Rec :Calling rule with following value of type -', 'Picking');
        END IF;
        log_statement(l_api_name, 'Input Rec :l_rule_id', 		l_rule_id);
        log_statement(l_api_name, 'Input Rec :p_organization_id', 	p_organization_id);
        log_statement(l_api_name, 'Input Rec :p_inventory_item_id',  	p_inventory_item_id);
        log_statement(l_api_name, 'Input Rec :p_transaction_type_id',  	p_transaction_type_id);
        log_statement(l_api_name, 'Input Rec :l_revision',  		l_revision);
        log_statement(l_api_name, 'Input Rec :l_lot_number',  		l_lot_number);
        log_statement(l_api_name, 'Input Rec :l_subinventory_code',  	l_subinventory_code);
        log_statement(l_api_name, 'Input Rec :l_locator_id',  		l_locator_id);
        log_statement(l_api_name, 'Input Rec :l_cost_group_id',  	l_cost_group_id);
        log_statement(l_api_name, 'Input Rec :l_pp_transaction_temp_id',l_pp_transaction_temp_id);
        log_statement(l_api_name, 'Input Rec :l_is_serial_control', 	l_is_serial_control);
        log_statement(l_api_name, 'Input Rec :l_detail_serial',  	l_detail_serial);
        log_statement(l_api_name, 'Input Rec :p_detail_any_serial',  	p_detail_any_serial);
        log_statement(l_api_name, 'Input Rec :p_from_serial', 		p_from_serial);
        log_statement(l_api_name, 'Input Rec :p_to_serial', 		p_to_serial);
        log_statement(l_api_name, 'Input Rec :l_unit_number',  		l_unit_number);
        log_statement(l_api_name, 'Input Rec :l_lpn_id',  		l_lpn_id);
        log_statement(l_api_name, 'Input Rec :l_project_id',  		l_project_id);
        log_statement(l_api_name, 'Input Rec :l_task_id',  		l_task_id);
        log_statement(l_api_name, 'Input Rec :l_rule_result ',		l_rule_result);
        log_statement(l_api_name, 'Input Rec :l_restrict_subs_code ',  	l_restrict_subs_code);
        log_statement(l_api_name, 'Input Rec :l_restrict_locs_code ',	l_restrict_locs_code);
      END IF;

      For l_rule_counter IN 1..2  LOOP
         IF p_type_code = 2 THEN
           --pick_open_curs
           pick_open_rule(
              v_pick_cursor
            , l_rule_id
            , p_organization_id
            , p_inventory_item_id
            , p_transaction_type_id
            , l_revision
            , l_lot_number
            , l_subinventory_code
            , l_locator_id
            , l_cost_group_id
            , l_pp_transaction_temp_id
            , l_is_serial_control
            , l_detail_serial
            , p_detail_any_serial
            , p_from_serial
            , p_to_serial
            , l_unit_number
            , l_lpn_id
            , l_project_id
            , l_task_id
            , l_rule_result
            );
         ELSIF  p_type_code = 1  then
            put_open_rule(
              v_put_cursor
            , l_rule_id
            , p_organization_id
            , p_inventory_item_id
            , p_transaction_type_id
            , l_subinventory_code
            , l_locator_id
            , l_pp_transaction_temp_id
            , l_restrict_subs_code
            , l_restrict_locs_code
            , l_project_id
            , l_task_id
            , l_rule_result
            );
         END IF;

         IF l_rule_result  = 1 then
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'Open Cursor package called ' , l_rule_counter);
               log_statement(l_api_name, 'rule_id ' , l_rule_id);
            END IF;
            EXIT;
         END IF;
         --log_statement(l_api_name, ' Before  =  l_rule_result ' , l_rule_result );
         --log_statement(l_api_name, ' Before  = wms_rule_pvt.g_rule_list_pick_ctr ' , wms_rule_pvt.g_rule_list_pick_ctr);
         IF (l_rule_result = 0) and l_rule_counter   = 2 THEN --error
           IF l_debug = 1 THEN
              log_statement(l_api_name, 'open_curs_err', 'Error calling open_curs');
              log_error_msg(l_api_name, 'rule_package_missing');
              log_statement(l_api_name, 'pack_name', 'Package name: ' || l_package_name);
           END IF;
           fnd_message.set_name('WMS', 'WMS_PACKAGE_MISSING');
           fnd_message.set_token('RULEID', l_rule_id);
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;

      IF (p_type_code = 2) THEN --pick
        g_locs_index           := 0;
        g_locs.DELETE;
        g_consists.DELETE;
        g_lpns.DELETE;
        g_first_order_by_rank  := NULL;
        g_first_consist_group  := 0;
        g_last_consist_group   := 0;
        l_order_by_rank        := 0;
      END IF;

      --If type code = 2 and allocation mode = 1
      --ENTIRE LPN
      IF  p_type_code = 2
          AND l_allocation_mode = 1 THEN
        l_cur_lpn_group    := 0;
        g_first_lpn_group  := 0;
        g_last_lpn_group   := 0;
        l_cur_lpn_rec      := 0;

        l_allocate_serial_flag := inv_cache.org_rec.allocate_serial_flag;

        IF l_debug = 1 THEN
           log_statement(l_api_name, 'alloc_lpns', 'Allocating Entire LPNs');
           log_statement(l_api_name, 'allocate_serial_flag', 'allocate_serial_flag = '||l_allocate_serial_flag);
        END IF;

        --for each record from rules cursor
        LOOP
           --Get record from rules cursor
           IF l_debug = 1 THEN
              log_statement(l_api_name, 'fetch_cursor', 'Getting rec from rule with FetchCursor');
           END IF;
           --  Added for Mat Stat check
           LOOP
           if l_debug = 1 THEN
              log_statement(l_api_name, 'fetch_cursor', 'inside Mat Stat check LOOP');
           END IF;
           -- For custom serial
           IF  ( l_allocate_serial_flag = 'C' ) AND (nvl(l_custom_serial_index,-1) < nvl(l_custom_select_serials.serial_number.LAST,-1)) THEN
              -- next record should be next serial from custom API
              l_custom_serial_index := l_custom_serial_index + 1;
              v_current_row.serial_number := l_custom_select_serials.serial_number(l_custom_serial_index);
              v_current_row.quantity := 1;
           ELSE
           --- Mat Stat checking --
             fetchcursor(
               x_return_status
             , x_msg_count
             , x_msg_data
             , v_pick_cursor
             , l_rule_id
             , v_current_row.revision
             , v_current_row.lot_number
             , v_current_row.lot_expiration_date
             , v_current_row.subinventory_code
             , v_current_row.locator_id
             , v_current_row.cost_group_id
             , v_current_row.uom_code
             , v_current_row.lpn_id
             , v_current_row.serial_number
             , v_current_row.quantity
             , v_current_row.secondary_quantity               -- new
             , v_current_row.grade_code                       -- new
             , v_current_row.consist_string
             , v_current_row.order_by_string
             , l_rows
             );

           EXIT WHEN  nvl(l_rows, 0)  = 0 ;  -- [ Added to to exit , if the rule is not returning any rows
           IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_error(l_api_name, 'uerr_fetch_cursor', 'Unexpected error in FetchCursor');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
           ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_error(l_api_name, 'fetch_cursor ', 'Error in FetchCursor');
              END IF;
              RAISE fnd_api.g_exc_error;
           END IF;

           IF l_debug = 1 THEN
              log_statement(l_api_name, 'Serial Status - l_detail_serial ', l_detail_serial);
              log_statement(l_api_name, 'fetch_cursor - l_rows ', l_rows);
              log_statement(l_api_name, 'fetch_cursor - v_current_row.lot_number ', v_current_row.lot_number);
              log_statement(l_api_name, 'fetch_cursor - v_current_row.serial_number ', v_current_row.serial_number);
           END IF;

              IF  ( l_allocate_serial_flag = 'C' ) THEN
                     INV_DETAIL_SERIAL_PUB.Get_User_Serial_Numbers (
                   x_return_status           => x_return_status
                 , x_msg_count               => x_msg_count
                 , x_msg_data                => x_msg_data
                 , p_organization_id         => p_organization_id
                 , p_inventory_item_id       => p_inventory_item_id
                 , p_revision                => v_current_row.revision
                 , p_lot_number              => v_current_row.lot_number
                 , p_subinventory_code       => v_current_row.subinventory_code
                 , p_locator_id              => v_current_row.locator_id
                 , p_required_sl_qty         => v_current_row.quantity
                 , p_from_range              => p_from_serial
                 , p_to_range                => p_to_serial
                 , p_unit_number             => l_unit_number
                 , p_cost_group_id           => l_cost_group_id
                 , p_transaction_type_id     => NULL --p_transaction_type_id
                 , p_demand_source_type_id   => NULL --p_demand_source_type_id
                 , p_demand_source_header_id => NULL --p_demand_source_header_id
                 , p_demand_source_line_id   => NULL --p_demand_source_line_id
                 , x_serial_numbers          => l_custom_select_serials );

                IF ( x_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
                   IF ( l_debug = 1 ) THEN
                      log_error(l_api_name, 'uerr_Get_User_Serial_Numbers', 'Unexpected error in Get_User_Serial_Numbers');
                   END IF;
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSIF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
                   IF ( l_debug = 1 ) THEN
                      log_error(l_api_name, 'Get_User_Serial_Numbers', 'Error in Get_User_Serial_Numbers');
                   END IF;
                   RAISE fnd_api.g_exc_error;
                END IF;

                l_custom_serial_index := l_custom_select_serials.serial_number.FIRST;
                v_current_row.serial_number := l_custom_select_serials.serial_number(l_custom_serial_index);
                v_current_row.quantity := 1;
              END IF;
           END IF; -- custom serial
           ------ is_serial_trx_allowed is_sub_loc_lot_trx_allowed
           -- EXIT WHEN l_rows = 0 ;
           l_sub_loc_lot_trx_allowed 	:= 'Y';
           l_serial_trx_allowed		:= 'Y';
           l_serial_status_id 	 	:= 0;

           IF v_current_row.serial_number IS NOT NULL  THEN
             IF l_detail_serial = 1 THEN
                 select status_id
                 into l_serial_status_id
                 from mtl_serial_numbers
                 where inventory_item_id        = p_inventory_item_id
                    and current_organization_id = p_organization_id
                    and serial_number           = v_current_row.serial_number;

                 l_serial_trx_allowed := inv_detail_util_pvt.is_serial_trx_allowed(
                                       p_transaction_type_id
                                      ,p_organization_id
                                      ,p_inventory_item_id
                                      ,l_serial_status_id) ;
             END IF;
             IF l_debug = 1 THEN
              log_statement(l_api_name, 'Serial Status - p_transaction_type_id ', p_transaction_type_id);
              log_statement(l_api_name, 'Serial Status - p_organization_id ', p_organization_id);
              log_statement(l_api_name, 'Serial Status -p_transaction_type_id ', p_organization_id);
              log_statement(l_api_name, 'Serial Status - p_inventory_item_id ', p_inventory_item_id);
              log_statement(l_api_name, 'Serial Status - serial_number ', v_current_row.serial_number);
              log_statement(l_api_name, 'Serial Status - l_serial_status_id ', l_serial_status_id);
              log_statement(l_api_name, 'Serial Status - l_serial_trx_allowed ', l_serial_trx_allowed);
             END IF;
           END IF;
           -- Bug 4756156
           -- IF  ((v_current_row.lot_number IS NOT NULL)  AND (nvl(l_lot_status, 'Y')  = 'Y'))  THEN
           -- LPN Status Project

               l_onhand_status_trx_allowed := 'Y';

               IF l_default_status_id = -1 THEN
                 IF l_debug = 1 THEN
                     log_statement(l_api_name, 'before calling trx_allowed: ', l_sub_loc_lot_trx_allowed);
                 END IF;

			 l_onhand_status_trx_allowed := 'N';
                         l_sub_loc_lot_trx_allowed :=   inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(
                                       p_transaction_type_id
                                      ,p_organization_id
                                      ,p_inventory_item_id
                                      ,v_current_row.subinventory_code
                                      ,v_current_row.locator_id
                                      ,v_current_row.lot_number);

                       IF l_debug = 1 THEN
	                        log_statement(l_api_name, 'fetch_cursor - l_sub_loc_lot_trx_allowed ', l_sub_loc_lot_trx_allowed);
                       END IF;
               ELSE --  IF l_default_status_id = -1 THEN

                         l_sub_loc_lot_trx_allowed:='N';
                        IF (inv_cache.item_rec.serial_number_control_code in (1,6)) THEN
			 l_onhand_status_trx_allowed := inv_detail_util_pvt.is_onhand_status_trx_allowed(
                                         p_transaction_type_id
                                        ,p_organization_id
                                        ,p_inventory_item_id
                                        ,v_current_row.subinventory_code
                                        ,v_current_row.locator_id
                                        ,v_current_row.lot_number
		                                    , v_current_row.lpn_id);
                        END IF;
	 	          IF l_debug = 1 THEN
	                         log_statement(l_api_name, 'fetch_cursor - l_onhand_status_trx_allowed ', l_onhand_status_trx_allowed);
                           END IF;
              END IF;

           -- END IF;
           --- ]
           EXIT WHEN  (    l_serial_trx_allowed      = 'Y'
                       and (l_sub_loc_lot_trx_allowed = 'Y' OR l_onhand_status_trx_allowed='Y'));
           -- >> Else fetch next record from the rule cursor --
           END LOOP;
       -- End of Mat Stat Check --
       -- LPN Status Project

          --initialize pointer to next rec
          v_current_row.next_rec  := 0;
          --if no more records
          IF l_rows  = 0 THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'no_more_rec', 'No more records from rule');
            END IF;
            IF l_consist_exists THEN
              --loop through consist groups, looking for groups where quantity = needed quantity
              l_cur_consist_group  := g_first_consist_group;
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'first_consist_group', 'First Consist Group in list: ' || l_cur_consist_group);
              END IF;
              LOOP
                --EXIT WHEN l_needed_quantity <= 0;
                IF g_over_allocation = 'N'
                OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
                OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
                  EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
                ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
                  IF l_max_tolerance  >= 0 THEN
                     EXIT WHEN (l_needed_quantity <= l_max_tolerance)
                     OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
                  ELSE
                     EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
                  END IF;
                END IF;
                EXIT WHEN l_cur_consist_group = 0;
                --IF g_consists(l_cur_consist_group).quantity = l_needed_quantity THEN
		IF (g_consists(l_cur_consist_group).quantity BETWEEN (l_needed_quantity - l_max_tolerance) AND l_needed_quantity) THEN
                  --for each LPN in lpn array
                  l_cur_lpn_group  := g_consists(l_cur_consist_group).first_rec;
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'first_lpn', 'First LPN in list: ' || l_cur_lpn_group);
                  END IF;
                  LOOP --loop through lpn in consist group
                    EXIT WHEN l_cur_lpn_group = 0;
                    --if lpn quantity is less than or equal to the needed quantity
                    -- and the LPN has been entirely allocated, use it
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'alloc_stored_lpn', 'Allocating LPN. id: ' || l_cur_lpn_group);
                    END IF;
                    -- for each record in LPN
                    l_cur_lpn_rec      := g_lpns(l_cur_lpn_group).first_rec;
                    LOOP
                      EXIT WHEN l_cur_lpn_rec = 0;
                      g_trace_recs(l_cur_lpn_rec).entire_lpn_flag  := 'Y';
                      --call validate and insert
                      l_expected_quantity                          := g_locs(l_cur_lpn_rec).quantity;
                      validate_and_insert(
                        x_return_status              => x_return_status
                      , x_msg_count                  => x_msg_count
                      , x_msg_data                   => x_msg_data
                      , p_record_id                  => l_cur_lpn_rec
                      , p_needed_quantity            => l_needed_quantity
                      , p_use_pick_uom               => FALSE
                      , p_organization_id            => p_organization_id
                      , p_inventory_item_id          => p_inventory_item_id
                      , p_to_subinventory_code       => l_to_subinventory_code
                      , p_to_locator_id              => l_to_locator_id
                      , p_to_cost_group_id           => l_to_cost_group_id
                      , p_primary_uom                => p_primary_uom
                      , p_transaction_uom            => p_transaction_uom
                      , p_transaction_temp_id        => p_transaction_temp_id
                      , p_type_code                  => p_type_code
                      , p_rule_id                    => l_rule_id
                      , p_reservation_id             => l_reservation_id
                      , p_tree_id                    => p_tree_id
                      , p_debug_on                   => l_debug_on
                      , p_needed_sec_quantity        => l_sec_needed_quantity
                      , p_secondary_uom              => p_secondary_uom
                      , p_grade_code                 => p_grade_code
                      , x_inserted_record            => l_inserted_record
                      , x_allocated_quantity         => l_allocated_quantity
                      , x_remaining_quantity         => l_remaining_quantity
                      , x_sec_allocated_quantity     => l_sec_allocated_quantity
                      , x_sec_remaining_quantity     => l_sec_remaining_quantity
                      );

                      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        IF l_debug = 1 THEN
                           log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
                        END IF;
                       RAISE fnd_api.g_exc_unexpected_error;
                      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                       IF l_debug = 1 THEN
                          log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
                       END IF;
                        RAISE fnd_api.g_exc_error;
                      END IF;
                      --if returns false
                      IF l_inserted_record = FALSE
                         OR l_allocated_quantity < l_expected_quantity THEN
                        IF l_debug = 1 THEN
                           log_statement(l_api_name, 'insert_failed', 'Record failed to allocation.  Rolling back and ' || 'invalidating LPN');
                           -- rollback quantity tree
                           log_statement(l_api_name, 'restore_tree', 'Calling restore_tree');
                        END IF;
                        inv_quantity_tree_pvt.restore_tree(x_return_status => x_return_status, p_tree_id => p_tree_id);
                        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                          IF l_debug = 1 THEN
                             log_error(l_api_name, 'uerr_restore_tree', 'Unexpected error in restore_tree');
                          END IF;
                         RAISE fnd_api.g_exc_unexpected_error;
                        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                          IF l_debug = 1 THEN
                             log_error(l_api_name, 'err_restore_tree', 'Error in restore_tree');
                          END IF;
                         RAISE fnd_api.g_exc_error;
                        END IF;
                        -- delete allocations
                        DELETE FROM wms_transactions_temp
                              WHERE line_type_code = 2
                                AND type_code = p_type_code;
                        IF l_debug_on THEN
                          l_cur_rec  := g_lpns(l_cur_lpn_group).first_rec;
                          LOOP
                            g_trace_recs(l_cur_rec).entire_lpn_flag  := 'N';
                            g_trace_recs(l_cur_rec).suggested_qty    := 0;
                            EXIT WHEN l_cur_rec = l_cur_lpn_rec;
                            l_cur_rec                                := g_locs(l_cur_rec).next_rec;
                          END LOOP;
                        END IF;
                        IF l_debug = 1 THEN
                           log_statement(l_api_name, 'finish_delete_sugs', 'Finished deleting suggestions and restored quantity tree');
                        END IF;
                        -- Exit loop for each rec in this LPN
                        EXIT;
                      END IF; -- didn't allocate as much as expected
                      IF l_debug_on THEN
                        g_trace_recs(l_cur_lpn_rec).consist_string_flag  := 'Y';
                      END IF;
                      --decrease quantity needed
                      IF l_debug = 1 THEN
                         log_statement(l_api_name, 'need_qty', 'New needed quantity: ' || l_needed_quantity);
                      END IF;
                      l_cur_lpn_rec                                := g_locs(l_cur_lpn_rec).next_rec;
                      EXIT WHEN l_cur_lpn_rec = 0;
                    --end loop through lpn recs
                    END LOOP; -- loop through recs w/in LPN

                    -- if no more quantity needed, exit LPN loop
                    l_needed_quantity  := l_needed_quantity - g_lpns(l_cur_lpn_group).quantity;
                    l_sec_needed_quantity  := l_sec_needed_quantity - g_lpns(l_cur_lpn_group).secondary_quantity;

		    IF l_debug = 1 THEN
			log_statement(l_api_name, 'need_qty', 'New needed quantity: ' || l_needed_quantity);
		    END IF;

                  --EXIT WHEN l_needed_quantity <= 0; -- consist loop
                    IF g_over_allocation = 'N'
		    OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
		    OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
			EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
		    ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
			IF l_max_tolerance  >= 0 THEN
				EXIT WHEN (l_needed_quantity <= l_max_tolerance)
				OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			ELSE
				EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			END IF;
                    END IF;
                    l_cur_lpn_group    := g_lpns(l_cur_lpn_group).next_consist_lpn_id;
                    EXIT WHEN l_cur_lpn_group = 0;

                     IF l_debug = 1 THEN
                        log_statement(l_api_name, 'next_lpn', 'Next LPN in list: ' || l_cur_lpn_group);
                     END IF;

                  END LOOP; --lpns in consist group

                  -- if no more quantity needed, exit LPN loop
                 --EXIT WHEN l_needed_quantity <= 0; -- consist loop
                   IF g_over_allocation = 'N'
                   OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
                   OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
			EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
		   ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
			IF l_max_tolerance  >= 0 THEN
				EXIT WHEN (l_needed_quantity <= l_max_tolerance)
				OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			ELSE
				EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			END IF;
                   END IF;
                END IF; -- enough quantity to allocate

                -- end loop through consist groups
                l_cur_consist_group  := g_consists(l_cur_consist_group).next_group;

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'next_consist_group', 'Next Consist Group in list: ' || l_cur_consist_group);
                END IF;

              END LOOP;

              --exit outermost loop
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'lpn_alloc_finished', 'Finished checking all LPNS.  Exit LPN allocation.');
               END IF;

              EXIT; --outermost loop
            ELSE -- no consists
              --for each LPN in lpn array
              l_cur_lpn_group  := g_first_lpn_group;

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'first_lpn', 'First LPN in list: ' || g_first_lpn_group);
              END IF;

              LOOP
                --EXIT WHEN l_needed_quantity <= 0;
                IF g_over_allocation = 'N'
                OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
                OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
                  EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
                ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
                  IF l_max_tolerance  >= 0 THEN
                     EXIT WHEN (l_needed_quantity <= l_max_tolerance)
                     OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
                  ELSE
                     EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
                  END IF;
                END IF;
                EXIT WHEN l_cur_lpn_group = 0;

                --if lpn quantity is less than or equal to the needed quantity
                -- and the LPN has been entirely allocated, use it
                IF  g_lpns(l_cur_lpn_group).quantity <= l_needed_quantity
                    AND g_lpns(l_cur_lpn_group).total_quantity <> -1
                    AND g_lpns(l_cur_lpn_group).quantity = g_lpns(l_cur_lpn_group).total_quantity THEN

                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'alloc_stored_lpn', 'Allocating LPN. id: ' || l_cur_lpn_group);
                  END IF;
                  -- for each record in LPN
                  l_cur_lpn_rec  := g_lpns(l_cur_lpn_group).first_rec;

                  LOOP
                    EXIT WHEN l_cur_lpn_rec = 0;
                    g_trace_recs(l_cur_lpn_rec).entire_lpn_flag  := 'Y';
                    --call validate and insert
                    l_expected_quantity                          := g_locs(l_cur_lpn_rec).quantity;
                    validate_and_insert(
                      x_return_status              => x_return_status
                    , x_msg_count                  => x_msg_count
                    , x_msg_data                   => x_msg_data
                    , p_record_id                  => l_cur_lpn_rec
                    , p_needed_quantity            => l_needed_quantity
                    , p_use_pick_uom               => FALSE
                    , p_organization_id            => p_organization_id
                    , p_inventory_item_id          => p_inventory_item_id
                    , p_to_subinventory_code       => l_to_subinventory_code
                    , p_to_locator_id              => l_to_locator_id
                    , p_to_cost_group_id           => l_to_cost_group_id
                    , p_primary_uom                => p_primary_uom
                    , p_transaction_uom            => p_transaction_uom
                    , p_transaction_temp_id        => p_transaction_temp_id
                    , p_type_code                  => p_type_code
                    , p_rule_id                    => l_rule_id
                    , p_reservation_id             => l_reservation_id
                    , p_tree_id                    => p_tree_id
                    , p_debug_on                   => l_debug_on
                    , p_needed_sec_quantity        => l_sec_needed_quantity
                    , p_secondary_uom              => p_secondary_uom
                    , p_grade_code                 => p_grade_code
                    , x_inserted_record            => l_inserted_record
                    , x_allocated_quantity         => l_allocated_quantity
                    , x_remaining_quantity         => l_remaining_quantity
                    , x_sec_allocated_quantity     => l_sec_allocated_quantity
                    , x_sec_remaining_quantity     => l_sec_remaining_quantity
                    );

                    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                       IF l_debug = 1 THEN
                          log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
                       END IF;
                      RAISE fnd_api.g_exc_unexpected_error;
                    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                      IF l_debug = 1 THEN
                         log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
                      END IF;
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    --if returns false
                    IF l_inserted_record = FALSE
                       OR l_allocated_quantity < l_expected_quantity THEN
                      IF l_debug = 1 THEN
                         log_statement(l_api_name, 'insert_failed', 'Record failed to allocation.  Rolling back and ' || 'invalidating LPN');
                         -- rollback quantity tree
                         log_statement(l_api_name, 'restore_tree', 'Calling restore_tree');
                      END IF;

                      inv_quantity_tree_pvt.restore_tree(x_return_status => x_return_status, p_tree_id => p_tree_id);

                      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        IF l_debug = 1 THEN
                           log_error(l_api_name, 'uerr_restore_tree', 'Unexpected error in restore_tree');
                        END IF;
                        RAISE fnd_api.g_exc_unexpected_error;
                      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                        IF l_debug = 1 THEN
                           log_error(l_api_name, 'err_restore_tree', 'Error in restore_tree');
                        END IF;
                        RAISE fnd_api.g_exc_error;
                      END IF;

                      -- set lpn quantity to -1
                      --no need to call invalidate, since we'll never see this
                      -- LPN record again

                      -- delete allocations
                      DELETE FROM wms_transactions_temp
                            WHERE line_type_code = 2
                              AND type_code = p_type_code;

                      IF l_debug_on THEN
                        l_cur_rec  := g_lpns(l_cur_lpn_group).first_rec;
                        LOOP
                          g_trace_recs(l_cur_rec).entire_lpn_flag  := 'N';
                          g_trace_recs(l_cur_rec).suggested_qty    := 0;
                          EXIT WHEN l_cur_rec = l_cur_lpn_rec;
                          l_cur_rec                                := g_locs(l_cur_rec).next_rec;
                        END LOOP;
                      END IF;

                      IF l_debug = 1 THEN
                         log_statement(l_api_name, 'finish_delete_sugs', 'Finished deleting suggestions and restored quantity tree');
                      END IF;

                      -- Exit loop for each rec in this LPN
                      EXIT;
                    END IF; -- didn't allocate as much as expected

                    --decrease quantity needed
                    l_needed_quantity                            := l_needed_quantity - l_allocated_quantity;
                    l_sec_needed_quantity                        := l_sec_needed_quantity - l_sec_allocated_quantity;

                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'need_qty', 'New needed quantity: ' || l_needed_quantity);
                       log_statement(l_api_name, 'need_qty', 'New sec needed quantity: ' || l_sec_needed_quantity);
                    END IF;

                  --EXIT WHEN l_needed_quantity <= 0;
                    IF g_over_allocation = 'N'
                   OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
                   OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
			EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
		   ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
			IF l_max_tolerance  >= 0 THEN
				EXIT WHEN (l_needed_quantity <= l_max_tolerance)
				OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			ELSE
				EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			END IF;
                   END IF;
                    l_cur_lpn_rec                                := g_locs(l_cur_lpn_rec).next_rec;
                  --end loop through lpn recs

                  END LOOP; -- loop through recs w/in LPN

                  -- if no more quantity needed, exit LPN loop
                --EXIT WHEN l_needed_quantity <= 0;
                  IF g_over_allocation = 'N'
                  OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
                  OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
			EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
		  ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
			IF l_max_tolerance  >= 0 THEN
				EXIT WHEN (l_needed_quantity <= l_max_tolerance)
				OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			ELSE
				EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			END IF;
                  END IF;
                END IF; --needed qty > lpn.quantity

                l_cur_lpn_group  := g_lpns(l_cur_lpn_group).next_group;

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'next_lpn', 'Next LPN in list: ' || l_cur_lpn_group);
                END IF;

             -- end loop through lpn groups
              END LOOP;

              --exit outermost loop
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'lpn_alloc_finished', 'Finished checking all LPNS.  Exit LPN allocation.');
              END IF;

              EXIT;
            END IF; --consists exist
          END IF; --if no more records

          --add record to table
          g_locs_index            := g_locs_index + 1;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'loc_index', 'loc index: ' || g_locs_index);
          END IF;

          g_locs(g_locs_index)    := v_current_row;

          --initialize trace records
          IF l_debug_on THEN
            log_statement(l_api_name, 'init_trace', 'Init trace record');
            g_trace_recs(g_locs_index).revision                 := v_current_row.revision;
            g_trace_recs(g_locs_index).lot_number               := v_current_row.lot_number;
            g_trace_recs(g_locs_index).lot_expiration_date      := v_current_row.lot_expiration_date;
            g_trace_recs(g_locs_index).subinventory_code        := v_current_row.subinventory_code;
            g_trace_recs(g_locs_index).locator_id               := v_current_row.locator_id;
            g_trace_recs(g_locs_index).cost_group_id            := v_current_row.cost_group_id;
            g_trace_recs(g_locs_index).lpn_id                   := v_current_row.lpn_id;
            g_trace_recs(g_locs_index).uom_code                 := v_current_row.uom_code;
            g_trace_recs(g_locs_index).quantity                 := v_current_row.quantity;
            g_trace_recs(g_locs_index).secondary_qty            := v_current_row.secondary_quantity;
            g_trace_recs(g_locs_index).grade_code               := v_current_row.grade_code;
            g_trace_recs(g_locs_index).secondary_uom_code       := v_current_row.secondary_uom_code;
            g_trace_recs(g_locs_index).serial_number            := v_current_row.serial_number;
            --set LPN flag to no
            g_trace_recs(g_locs_index).consist_string_flag      := 'V';
            g_trace_recs(g_locs_index).partial_pick_flag        := 'Y';
            g_trace_recs(g_locs_index).order_string_flag        := 'V';
            g_trace_recs(g_locs_index).pick_uom_flag            := 'V';
            g_trace_recs(g_locs_index).serial_number_used_flag  := 'V';
            g_trace_recs(g_locs_index).entire_lpn_flag          := 'N';
            --write to log file
           log_statement(l_api_name, 'rev', 'revision: ' || v_current_row.revision);
           log_statement(l_api_name, 'lot', 'lot: ' || v_current_row.lot_number);
           log_statement(l_api_name, 'sub', 'sub:' || v_current_row.subinventory_code);
           log_statement(l_api_name, 'loc', 'loc: ' || v_current_row.locator_id);
           log_statement(l_api_name, 'cg', 'cg: ' || v_current_row.cost_group_id);
           log_statement(l_api_name, 'lpn', 'lpn: ' || v_current_row.lpn_id);
           log_statement(l_api_name, 'sn', 'sn: ' || v_current_row.serial_number);
           log_statement(l_api_name, 'qty', 'quantity: ' || v_current_row.quantity);
           log_statement(l_api_name, 'sqty', 'secondary_quantity: ' || v_current_row.secondary_quantity);
           log_statement(l_api_name, 'uom', 'uom_code: ' || v_current_row.uom_code);
           log_statement(l_api_name, 'suom', 'secondary_uom_code: ' || v_current_row.secondary_uom_code);
           log_statement(l_api_name, 'ord', 'order:' || v_current_row.order_by_string);
           log_statement(l_api_name, 'con', 'consist:' || v_current_row.consist_string);
         END IF;

          --if lpn already exists
          IF g_lpns.EXISTS(v_current_row.lpn_id) THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'lpn_exists', 'This LPN group already exists');
            END IF;
            --if lpn consist string is different than rec's consist string,
            --this LPN will never be allocated entirely. Remove LPN from list.
            IF g_lpns(v_current_row.lpn_id).total_quantity < 0 THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'invalid_lpn', 'This LPN is invalid');
              END IF;
              GOTO nextoutputrecord;
            ELSIF  l_consist_exists
                   AND g_lpns(v_current_row.lpn_id).consist_string <> v_current_row.consist_string THEN

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'no_consist', 'This record has a ' || 'different consist string than its LPN.  Invalidating LPN');
              END IF;

              invalidate_lpn_group(v_current_row.lpn_id);

              IF l_debug_on THEN
                g_trace_recs(g_locs_index).consist_string_flag  := 'N';
                l_cur_rec                                       := g_lpns(v_current_row.lpn_id).first_rec;

                LOOP
                  EXIT WHEN l_cur_rec = 0;
                  g_trace_recs(l_cur_rec).consist_string_flag  := 'N';
                  l_cur_rec                                    := g_locs(l_cur_rec).next_rec;
                END LOOP;
              END IF;

              GOTO nextoutputrecord;
            --bug 2356370 - need to recheck the LPN total quantity to make
            -- sure it doesn't exceed the needed quantity.
            ELSIF g_lpns(v_current_row.lpn_id).total_quantity > l_needed_quantity THEN

              IF l_debug = 1 THEN
                 log_statement(
                 l_api_name
               , 'bad_tot_qty2'
               , 'The total quantity for' || ' this LPN exceeds the needed quantity.  Invalidating LPN.'
                );
              END IF;

              invalidate_lpn_group(v_current_row.lpn_id);
              --goto next output record
              GOTO nextoutputrecord;
            END IF;

            --increase LPN quantity
            g_lpns(v_current_row.lpn_id).quantity                   := g_lpns(v_current_row.lpn_id).quantity
                                                                       + v_current_row.quantity;
            g_lpns(v_current_row.lpn_id).secondary_quantity         := g_lpns(v_current_row.lpn_id).secondary_quantity
                                                                       + v_current_row.secondary_quantity;
            --set pointers
            g_locs(g_lpns(v_current_row.lpn_id).last_rec).next_rec  := g_locs_index;
            g_lpns(v_current_row.lpn_id).last_rec                   := g_locs_index;
          --else lpn does not already exist
          ELSE

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'new_lpn', 'Creating a new LPN group');
            END IF;

            g_lpns(v_current_row.lpn_id).lpn_id                := v_current_row.lpn_id;
            g_lpns(v_current_row.lpn_id).first_rec             := g_locs_index;
            g_lpns(v_current_row.lpn_id).last_rec              := g_locs_index;
            g_lpns(v_current_row.lpn_id).quantity              := v_current_row.quantity;
            g_lpns(v_current_row.lpn_id).secondary_quantity    := v_current_row.secondary_quantity;
            g_lpns(v_current_row.lpn_id).grade_code            := v_current_row.grade_code;
            g_lpns(v_current_row.lpn_id).prev_group            := 0;
            g_lpns(v_current_row.lpn_id).next_group            := 0;
            g_lpns(v_current_row.lpn_id).prev_consist_lpn_id   := 0;
            g_lpns(v_current_row.lpn_id).next_consist_lpn_id   := 0;
            g_lpns(v_current_row.lpn_id).parent_consist_group  := 0;
            g_lpns(v_current_row.lpn_id).consist_string        := v_current_row.consist_string;
            --query total quantity for LPN
            OPEN c_lpn_quantity;
            FETCH c_lpn_quantity INTO g_lpns(v_current_row.lpn_id).total_quantity;

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'tot_qty', 'Total quantity for this LPN: ' || g_lpns(v_current_row.lpn_id).total_quantity);
            END IF;

            --IF total quantity > quantity needed
            IF c_lpn_quantity%NOTFOUND
               OR g_lpns(v_current_row.lpn_id).total_quantity IS NULL
               OR g_lpns(v_current_row.lpn_id).total_quantity <= 0
               OR g_lpns(v_current_row.lpn_id).total_quantity > l_needed_quantity THEN
              CLOSE c_lpn_quantity;

              IF l_debug = 1 THEN
                 log_statement(
                 l_api_name
                 , 'bad_tot_qty'
                 , 'The total quantity for' || ' this LPN keeps it from being allocated.  Invalidating LPN.'
                 );
              END IF;

              invalidate_lpn_group(v_current_row.lpn_id);
              --goto next output record
              GOTO nextoutputrecord;
            END IF;

            CLOSE c_lpn_quantity;

            IF NVL(l_cur_order_by_string, '@@@') <> NVL(v_current_row.order_by_string, '@@@') THEN
              l_order_by_rank        := l_order_by_rank + 1;
              l_cur_order_by_string  := v_current_row.order_by_string;

              IF g_first_order_by_rank IS NULL THEN
                g_first_order_by_rank  := l_order_by_rank;
              END IF;
            END IF;

            g_lpns(v_current_row.lpn_id).order_by_rank         := l_order_by_rank;
            --initialize record in LPN array
            g_lpns(v_current_row.lpn_id).prev_group            := g_last_lpn_group;

            IF g_first_lpn_group = 0 THEN
              g_first_lpn_group  := v_current_row.lpn_id;
            ELSE
              g_lpns(g_last_lpn_group).next_group  := v_current_row.lpn_id;
            END IF;

            g_last_lpn_group                                   := v_current_row.lpn_id;
          END IF; --if lpn already exists

          --validate from/to sub/loc
          --if fail, invalidate LPN and goto next output record
          --first check to make sure picking from dest sub is not allowed;
          --then, based on type code, compare src sub to dest sub;
          --next, check to see if sub and item are locator controlled;
          --if loc control, go to next record only if src loc = dest loc;
          --if not loc control, go to next records (since subs are equal);
          --all of the global variables are set in
          --wms_engine_pvt.create_suggestions
          IF (wms_engine_pvt.g_dest_sub_pick_allowed = 0
              AND v_current_row.subinventory_code = l_to_subinventory_code
             ) THEN
            IF (wms_engine_pvt.g_org_loc_control IN (2, 3)
                OR wms_engine_pvt.g_sub_loc_control IN (2, 3)
                OR (wms_engine_pvt.g_sub_loc_control = 5
                    AND (wms_engine_pvt.g_item_loc_control IN (2, 3))
                   )
               ) THEN
              IF (v_current_row.locator_id = l_to_locator_id) THEN

                IF l_debug = 1 THEN
                   log_event(
                     l_api_name
                    , 'sub_loc_same'
                    , 'Cannot use this ' || 'location since source subinventory and locator are' || ' same as destination subinventory and locator'
                    );
                 END IF;

                IF l_debug_on THEN
                  g_trace_recs(g_locs_index).same_subinv_loc_flag  := 'N';
                END IF;

                invalidate_lpn_group(v_current_row.lpn_id);
                GOTO nextoutputrecord;
              END IF;
            ELSE

              IF l_debug = 1 THEN
                 log_event(
                   l_api_name
                   , 'sub_same'
                   , 'Cannot use this ' || 'location since source subinventory is ' || 'same as destination subinventory'
                  );
               END IF;

              IF l_debug_on THEN
                g_trace_recs(g_locs_index).same_subinv_loc_flag  := 'N';
              END IF;

              invalidate_lpn_group(v_current_row.lpn_id);
              GOTO nextoutputrecord;
            END IF;
          END IF;

          IF l_debug_on THEN
            g_trace_recs(g_locs_index).same_subinv_loc_flag  := 'Y';
          END IF;

          --query quantity tree
          --If att < rec quantity, invalidate LPN and goto next output record

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'query tree', 'Calling Query Tree');
          END if;
           -- BUG 3609380
           -- Allocation was being treated as a subinventory transfer, and hence not honoring
           -- reservations alredy made on any level higher than SUB. Changes to treat as Issue
           -- by removing l_to_subinevntory_code.
          inv_quantity_tree_pvt.query_tree
                 (
                     p_api_version_number         =>    g_qty_tree_api_version
                   , p_init_msg_lst               =>    fnd_api.g_false -- p_init_msg_lst
                   , x_return_status              =>    x_return_status
                   , x_msg_count                  =>    x_msg_count
                   , x_msg_data                   =>    x_msg_data
                   , p_tree_id                    =>    p_tree_id
                   , p_revision                   =>    v_current_row.revision
                   , p_lot_number                 =>    v_current_row.lot_number
                   , p_subinventory_code          =>    v_current_row.subinventory_code
                   , p_locator_id                 =>    v_current_row.locator_id
                   , x_qoh                        =>   l_qoh
                   , x_sqoh                       =>   l_sqoh
                   , x_rqoh                       =>   l_rqoh
                   , x_srqoh                      =>   l_srqoh
                   , x_qr                         =>   l_qr
                   , x_sqr                        =>   l_sqr
                   , x_qs                         =>   l_qs
                   , x_sqs                        =>   l_sqs
                   , x_att                        =>   l_att
                   , x_satt                       =>   l_satt
                   , x_atr                        =>   l_atr
                   , x_satr                       =>   l_satr
                   , p_transfer_subinventory_code =>    chk_for_passing_xfer_sub ( p_transaction_temp_id , l_to_subinventory_code) -- Bug# 4099907
                   , p_cost_group_id              =>    v_current_row.cost_group_id
                   , p_lpn_id                     =>    v_current_row.lpn_id
                 );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'uerr_qty_tree', 'Unexpected error in inv_quantity_tree_Pvt.query_tree');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'err_qty_tree', 'Error in inv_quantity_tree_Pvt.query_tree');
            END if;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'att_qty', 'Available quantity = ' || l_att);
          END IF;

          --If not all of the record is available, then we can't allocate
          --the entire LPN
          IF l_att < v_current_row.quantity THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'not_enough_att', 'Not all the material is available for this rec. Skipping this LPN');
            END IF;
            IF l_debug_on THEN
              g_trace_recs(g_locs_index).att_qty                 := l_att;
              g_trace_recs(g_locs_index).secondary_att_qty       := l_satt;
              g_trace_recs(g_locs_index).att_qty_flag            := 'N';
            END IF;
            invalidate_lpn_group(v_current_row.lpn_id);
            GOTO nextoutputrecord;
          END IF;

          IF l_debug_on THEN
            g_trace_recs(g_locs_index).att_qty                 := l_att;
            g_trace_recs(g_locs_index).secondary_att_qty       := l_satt;
            g_trace_recs(g_locs_index).att_qty_flag            := 'Y';
          END IF;

          --If LPN is not in first order by group OR
            --goto next output record
          IF g_lpns(v_current_row.lpn_id).quantity < g_lpns(v_current_row.lpn_id).total_quantity THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'not_enough_lpn_qty', 'Not enough quantity allocated for this LPN. Getting next record');
            END IF;
            -- Bug #5345736
            --invalidate_lpn_group(v_current_row.lpn_id); --bug 6831349
            GOTO nextoutputrecord;
          END IF;

          IF l_consist_exists THEN
            --find consist group
            -- used in get_hash_value.  That procedure works best if
              -- hashsize is power of 2
            l_hash_size                                        := POWER(2, 15);
            --get hash index for this consist string
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'get_hash_value', 'Calling get_hash_value for consist string');
            END IF;
            l_cur_consist_group                                :=
            DBMS_UTILITY.get_hash_value(NAME => g_lpns(v_current_row.lpn_id).consist_string, base => 1, hash_size => l_hash_size);
            --Because the hash function can return the same index for different
            -- consist strings, we have to check to see if the group at the index
            -- returned above has the same consist string as the current record.
            -- If not, look at the next record.  Continue on until we find the
            -- correct consist group or determine that the group has not been
            -- defined yet
            LOOP
              EXIT WHEN NOT g_consists.EXISTS(l_cur_consist_group);
              EXIT WHEN g_consists(l_cur_consist_group).consist_string = g_lpns(v_current_row.lpn_id).consist_string;
              l_cur_consist_group  := l_cur_consist_group + 1;
            END LOOP;

            --see if consist group already exists
            --If group does exist
            IF g_consists.EXISTS(l_cur_consist_group) THEN

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'group_exists', 'The consist group already exists');
              END IF;

              --if lpn quantity would exceed needed quantity, invalidate lpn
              IF g_consists(l_cur_consist_group).quantity + g_lpns(v_current_row.lpn_id).quantity > l_needed_quantity THEN

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'too_much_qty', 'LPN quantity would exceed quantity needed.');
                END IF;

                invalidate_lpn_group(v_current_row.lpn_id);
                GOTO nextoutputrecord;
              END IF;

              --set pointer values
              g_lpns(v_current_row.lpn_id).prev_consist_lpn_id                      := g_consists(l_cur_consist_group).last_rec;
              g_lpns(g_consists(l_cur_consist_group).last_rec).next_consist_lpn_id  := v_current_row.lpn_id;
              g_consists(l_cur_consist_group).last_rec                              := v_current_row.lpn_id;
              --increase group quantity
              --g_consists(l_cur_consist_group).quantity                              :=
               --                                                               g_consists(l_cur_consist_group).quantity + l_possible_quantity;
	       g_consists(l_cur_consist_group).quantity				:= g_consists(l_cur_consist_group).quantity + g_lpns(v_current_row.lpn_id).quantity;
            --If group does not exist
            ELSE

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'new_group', 'Creating a new consist group');
              END IF;

              --create new group
              g_consists(l_cur_consist_group).consist_string            := g_lpns(v_current_row.lpn_id).consist_string;
              g_consists(l_cur_consist_group).first_rec                 := v_current_row.lpn_id;
              g_consists(l_cur_consist_group).last_rec                  := v_current_row.lpn_id;
              g_consists(l_cur_consist_group).next_group                := 0;
              g_consists(l_cur_consist_group).quantity                  := v_current_row.quantity;
              g_consists(l_cur_consist_group).secondary_quantity        := v_current_row.secondary_quantity;
              g_consists(l_cur_consist_group).grade_code                := v_current_row.grade_code;
              g_consists(l_cur_consist_group).order_by_rank             := g_lpns(v_current_row.lpn_id).order_by_rank;

              IF g_first_consist_group = 0 THEN
                g_first_consist_group  := l_cur_consist_group;
              ELSE
                g_consists(g_last_consist_group).next_group  := l_cur_consist_group;
              END IF;

              g_last_consist_group                            := l_cur_consist_group;
            END IF;

            g_lpns(v_current_row.lpn_id).parent_consist_group  := l_cur_consist_group;

            --only allocate a consist group if the quantity = needed quantity
            --exactly
            --IF g_consists(l_cur_consist_group).quantity <> l_needed_quantity THEN
	    IF g_consists(l_cur_consist_group).quantity < l_needed_quantity - l_max_tolerance THEN

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'not_enough_qty', 'Not enough quantity to allocate consist group');
              END IF;

              GOTO nextoutputrecord;
            END IF;

            IF g_consists(l_cur_consist_group).order_by_rank <> g_first_order_by_rank THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'consist_order_by', 'Consist group is not first based on sort criteria');
              END IF;
              GOTO nextoutputrecord;
            END IF;

            l_lpn_id                                           := g_consists(l_cur_consist_group).first_rec;
          -- no consists
          ELSIF g_lpns(v_current_row.lpn_id).order_by_rank <> g_first_order_by_rank THEN

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'not_first_order_by', 'Not first LPN based on sort criteria.  Getting next record.');
            END IF;
            GOTO nextoutputrecord;
          ELSE
            l_lpn_id  := v_current_row.lpn_id;
          END IF;

          LOOP -- loop through LPNS
            --Allocation process.  If consist exists, we loop through all
            -- the lpns in the consist group.  If no consistency restrictions,
            -- we exit the loop after allocating the first lpn

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'alloc_lpn', 'Allocation lpn: ' || l_lpn_id);
            END IF;

           --Allocate the LPN, since the LPN is in the first order by group
            --  and the LPN has all possible suggestions
            --For each record in LPN
            l_cur_lpn_rec      := g_lpns(l_lpn_id).first_rec;

            LOOP
              EXIT WHEN l_cur_lpn_rec = 0;

              --Call validate and insert
              IF l_debug_on THEN
                g_trace_recs(l_cur_lpn_rec).consist_string_flag  := 'Y';
                g_trace_recs(l_cur_lpn_rec).entire_lpn_flag      := 'Y';
              END IF;

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'val_insert', 'Calling validate_and_insert');
              END IF;

              validate_and_insert(
                x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_record_id                  => l_cur_lpn_rec
              , p_needed_quantity            => l_needed_quantity
              , p_use_pick_uom               => FALSE
              , p_organization_id            => p_organization_id
              , p_inventory_item_id          => p_inventory_item_id
              , p_to_subinventory_code       => l_to_subinventory_code
              , p_to_locator_id              => l_to_locator_id
              , p_to_cost_group_id           => l_to_cost_group_id
              , p_primary_uom                => p_primary_uom
              , p_transaction_uom            => p_transaction_uom
              , p_transaction_temp_id        => p_transaction_temp_id
              , p_type_code                  => p_type_code
              , p_rule_id                    => l_rule_id
              , p_reservation_id             => l_reservation_id
              , p_tree_id                    => p_tree_id
              , p_debug_on                   => l_debug_on
              , p_needed_sec_quantity        => l_sec_needed_quantity
              , p_secondary_uom              => p_secondary_uom
              , p_grade_code                 => p_grade_code
              , x_inserted_record            => l_inserted_record
              , x_allocated_quantity         => l_allocated_quantity
              , x_remaining_quantity         => l_remaining_quantity
              , x_sec_allocated_quantity     => l_sec_allocated_quantity
              , x_sec_remaining_quantity     => l_sec_remaining_quantity
              );

              IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF x_return_status = fnd_api.g_ret_sts_error THEN

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
                END IF;

                RAISE fnd_api.g_exc_error;
              END IF;

              --If this fails
              IF l_inserted_record = FALSE
                 OR l_allocated_quantity < g_locs(l_cur_lpn_rec).quantity THEN

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'insert_fail', 'Record failed to insert.' || 'Invalidating LPN');
                END IF;

                --invalidate LPN
                IF l_consist_exists THEN
                  l_cur_consist_group                       := g_lpns(l_lpn_id).parent_consist_group;
                  l_prev_rec                                := g_lpns(l_lpn_id).prev_consist_lpn_id;
                  l_next_rec                                := g_lpns(l_lpn_id).next_consist_lpn_id;
                  g_consists(l_cur_consist_group).quantity  := g_consists(l_cur_consist_group).quantity - g_lpns(l_lpn_id).quantity;
                  g_consists(l_cur_consist_group).secondary_quantity  :=
                                      g_consists(l_cur_consist_group).secondary_quantity - g_lpns(l_lpn_id).secondary_quantity;

                  IF g_consists(l_cur_consist_group).first_rec = l_lpn_id THEN
                    g_consists(l_cur_consist_group).first_rec      := l_next_rec;
                    g_consists(l_cur_consist_group).order_by_rank  := g_lpns(l_next_rec).order_by_rank;
                  END IF;

                  IF g_consists(l_cur_consist_group).last_rec = l_lpn_id THEN
                    g_consists(l_cur_consist_group).last_rec  := l_prev_rec;
                  END IF;

                  g_lpns(l_next_rec).prev_consist_lpn_id    := l_prev_rec;
                  g_lpns(l_prev_rec).next_consist_lpn_id    := l_next_rec;
                END IF;

                invalidate_lpn_group(l_lpn_id);
                --restore quantity tree

                IF l_debug = 1 THEN
                  log_statement(l_api_name, 'restore_tree', 'Calling restore_tree');
                END IF;

                inv_quantity_tree_pvt.restore_tree(x_return_status => x_return_status, p_tree_id => p_tree_id);

                IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN

                  IF l_debug = 1 THEN
                     log_error(l_api_name, 'uerr_restore_tree', 'Unexpected error in restore_tree');
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
                ELSIF x_return_status = fnd_api.g_ret_sts_error THEN

                  IF l_debug = 1 THEN
                     log_error(l_api_name, 'err_restore_tree', 'Error in restore_tree');
                  END IF;

                  RAISE fnd_api.g_exc_error;
                END IF;

                --delete allocations
                --is this okay?? what if multiple input lines?
                DELETE FROM wms_transactions_temp
                      WHERE line_type_code = 2
                        AND type_code = p_type_code;

                IF l_debug_on THEN
                  l_cur_rec  := g_lpns(l_lpn_id).first_rec;

                  LOOP
                    g_trace_recs(l_cur_rec).entire_lpn_flag  := 'N';
                    g_trace_recs(l_cur_rec).suggested_qty    := 0;
                    EXIT WHEN l_cur_rec = l_cur_lpn_rec;
                    l_cur_rec                                := g_locs(l_cur_rec).next_rec;
                  END LOOP;
                END IF;

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'finish_delete_sugs', 'Finished deleting suggestions and restored quantity tree');
                END IF;

               -- With this LPN invalidated, go get next record
                GOTO nextoutputrecord;
              END IF;

              l_cur_lpn_rec  := g_locs(l_cur_lpn_rec).next_rec;
            --end loop (each rec in lpn)
            END LOOP;

            --decrease quantity needed
            l_needed_quantity  := l_needed_quantity - g_lpns(l_lpn_id).quantity;
            l_sec_needed_quantity  := l_sec_needed_quantity - g_lpns(l_lpn_id).secondary_quantity;

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'need_qty', 'New Needed Quantity: ' || l_needed_quantity);
               log_statement(l_api_name, 'need_qty', 'New sec Needed Quantity: ' || l_sec_needed_quantity);
            END IF;

            --EXIT WHEN l_needed_quantity = 0;
            IF g_over_allocation = 'N'
            OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
            OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
              EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
            ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
              IF l_max_tolerance  >= 0 THEN
                 EXIT WHEN (l_needed_quantity <= l_max_tolerance)
                 OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
              ELSE
                 EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
              END IF;
            END IF;

            --Once LPN has been allocated, remove it from the LPN list
            IF l_consist_exists THEN
              l_lpn_id  := g_lpns(l_lpn_id).next_consist_lpn_id;
              EXIT WHEN l_lpn_id = 0;
            ELSE
              invalidate_lpn_group(l_lpn_id);
              EXIT;
            END IF;
          END LOOP; -- loop through LPNS

         -- EXIT WHEN l_needed_quantity <= 0;
          IF g_over_allocation = 'N'
            OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
            OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
              EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
            ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
              IF l_max_tolerance  >= 0 THEN
                 EXIT WHEN (l_needed_quantity <= l_max_tolerance)
                 OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
              ELSE
                 EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
              END IF;
            END IF;

          <<nextoutputrecord>>
          NULL;
        --End outermost loop
        END LOOP;
      --else if type code = 2
      --PICK
      ELSIF p_type_code = 2 THEN
        l_cur_uom_rec          := 0;
        l_first_uom_rec        := 0;
        l_last_uom_rec         := 0;
        l_cur_consist_group    := 0;
        g_first_consist_group  := 0;

        IF l_debug = 1 THEN
           log_statement(l_api_name, 'start_alloc', 'Start allocation process');
        END IF;

        --for each record returned from cursor
        LOOP --Get record from rules cursor
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'fetch_cursor', 'Getting rec from rule with FetchCursor');
          END IF;
          -- Added the loop for Mat Stat check --
          LOOP
           if l_debug = 1 THEN
              log_statement(l_api_name, 'fetch_cursor', 'inside Mat Stat check LOOP');
           END IF;
           --  Mat Stat --
              fetchcursor(
                x_return_status
              , x_msg_count
              , x_msg_data
              , v_pick_cursor
              , l_rule_id
              , v_current_row.revision
              , v_current_row.lot_number
              , v_current_row.lot_expiration_date
              , v_current_row.subinventory_code
              , v_current_row.locator_id
              , v_current_row.cost_group_id
              , v_current_row.uom_code
              , v_current_row.lpn_id
              , v_current_row.serial_number
              , v_current_row.quantity
              , v_current_row.secondary_quantity               -- new
              , v_current_row.grade_code                       -- new
              , v_current_row.consist_string
              , v_current_row.order_by_string
              , l_rows
              );

              IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF l_debug = 1 THEN
                   log_error(l_api_name, 'uerr_fetch_cursor', 'Unexpected error in FetchCursor');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                IF l_debug = 1 THEN
                   log_error(l_api_name, 'err_fetch_cursor', 'Error in FetchCursor');
                END IF;
                RAISE fnd_api.g_exc_error;
              END IF;

           --  is_serial_trx_allowed is_sub_loc_lot_trx_allowed
            EXIT WHEN  nvl(l_rows, 0)  = 0 ;  -- [ Added to to exit , if the rule is not returning any rows
            l_sub_loc_lot_trx_allowed   := 'Y';
            l_serial_trx_allowed        := 'Y';
            l_serial_status_id   := 0;

           IF l_debug = 1 THEN
              log_statement(l_api_name, 'Serial Status - l_detail_serial ', l_detail_serial);
              log_statement(l_api_name, 'fetch_cursor - l_rows ', l_rows);
              log_statement(l_api_name, 'fetch_cursor - v_current_row.lot_number ', v_current_row.lot_number);
              log_statement(l_api_name, 'fetch_cursor - v_current_row.serial_number ', v_current_row.serial_number);
           END IF;
            IF v_current_row.serial_number IS NOT NULL  THEN

               IF l_detail_serial = 1 THEN
                 select status_id
                   into l_serial_status_id
                   from mtl_serial_numbers
                  where inventory_item_id       = p_inventory_item_id
                    and current_organization_id = p_organization_id
                    and serial_number           = v_current_row.serial_number;

                   l_serial_trx_allowed := inv_detail_util_pvt.is_serial_trx_allowed(
                                                                 p_transaction_type_id
                                                                ,p_organization_id
                                                                ,p_inventory_item_id
                                                                ,l_serial_status_id) ;
                END IF;
                IF l_debug = 1 THEN

                   log_statement(l_api_name, 'Serial Status - p_transaction_type_id ', p_transaction_type_id);
                   log_statement(l_api_name, 'Serial Status - p_organization_id ', p_organization_id);
                   log_statement(l_api_name, 'Serial Status - p_inventory_item_id ', p_inventory_item_id);
                   log_statement(l_api_name, 'Serial Status - serial_number ', v_current_row.serial_number);
                   log_statement(l_api_name, 'Serial Status - l_serial_status_id ', l_serial_status_id);
                   log_statement(l_api_name, 'Serial Status - l_serial_trx_allowed ', l_serial_trx_allowed);

                END IF;
            END IF;
            -- Bug 4756156
            -- IF  ((v_current_row.lot_number IS NOT NULL)  AND (l_lot_status  = 'Y'))  THEN
             -- LPN Status Project
               l_onhand_status_trx_allowed := 'Y';
               IF l_default_status_id = -1 THEN
                      l_onhand_status_trx_allowed := 'N';
	              l_sub_loc_lot_trx_allowed := inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(
			                         p_transaction_type_id
				                ,p_organization_id
					        ,p_inventory_item_id
	                                        ,v_current_row.subinventory_code
		                                ,v_current_row.locator_id
			                        ,v_current_row.lot_number);

					/*log_statement(l_api_name, 'Stasus', 'Before calling my method-Amrita);
	                          	l_sub_loc_lot_trx_allowed := inv_detail_util_pvt.is_onhand_status_trx_allowed(
                                           p_transaction_type_id
                                        ,p_organization_id
                                        ,p_inventory_item_id
                                        ,v_current_row.subinventory_code
                                        ,v_current_row.locator_id
                                        ,v_current_row.lot_number);*/
                                 IF l_debug = 1 THEN
                                      log_statement(l_api_name, 'fetch_cursor - l_sub_loc_lot_trx_allowed: ', l_sub_loc_lot_trx_allowed);
                                END IF;

	      ELSE
		    l_sub_loc_lot_trx_allowed:='N';
		    if (inv_cache.item_rec.serial_number_control_code in (1,6)) then
                    l_onhand_status_trx_allowed := inv_detail_util_pvt.is_onhand_status_trx_allowed(
		               	        p_transaction_type_id
                                        ,p_organization_id
                                        ,p_inventory_item_id
                                        ,v_current_row.subinventory_code
                                        ,v_current_row.locator_id
                                        ,v_current_row.lot_number
		                        , v_current_row.lpn_id);
		    end if;
		        IF l_debug = 1 THEN
	                     log_statement(l_api_name, 'fetch_cursor - l_onhand_status_trx_allowed ', l_onhand_status_trx_allowed);
                        END IF;
	      END IF;

                   -- END IF;
           EXIT WHEN  (    l_serial_trx_allowed      = 'Y'
                       and (l_sub_loc_lot_trx_allowed = 'Y' OR l_onhand_status_trx_allowed='Y'));

           -- >> Else fetch next record from the rule cursor --
         END LOOP;
         -- End of Mat Stat Check --
	-- LPN Status Project

          v_current_row.next_rec  := 0;

          --if no more records
          IF l_rows = 0 THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'no_recs', 'No more records from cursor');
            END IF;


	    -- (FOR R12.1 REPLENISHMENT PROJECT - 6681109) STARTS ---
	    -- IN R12 BRANCH , the code will not do any harm as the allocation mode = 5 value
	    -- is only available in R12 Main Line code and the logic in contained WITH value =  here

	    -- if allocation mode = 5
	    IF  l_allocation_mode = 5
	      AND l_first_uom_rec <> 0 and l_needed_quantity > 0 THEN
	       -- After all location-based records (from where there was possibility of getting allocation in the
	       -- first round of scan) gets exhausted, it comes here for the second round of scan. At that point,
	       -- we know the final unallocated qty after the first round of scan and that is the qty which are
	       -- candidate for replenishment

	       IF l_debug = 1 THEN
		  log_statement(l_api_name, 'exit_final_unallocated_qty',
		'Can not allocate any further with pick UOM for current input RECORD - COMING out of the outer loop');
	       END IF;

	       EXIT; -- Can not allocate any further; so come out of the outer loop

	       -- (FOR R12.1 REPLENISHMENT PROJECT - 6681109) ENDS ---

	       --if allocation mode IN 3,4
	     ELSIF  l_allocation_mode IN (3, 4)
	       AND l_first_uom_rec <> 0 THEN
	       --for each record in pick uom list
	       IF l_debug = 1 THEN
		  log_statement(l_api_name, 'pick_uom', 'Allocate pick UOM table');
	       END IF;
	       LOOP
		  l_cur_uom_rec                   := l_first_uom_rec;
		  EXIT WHEN l_cur_uom_rec = 0;
		  --remove rec from list
		  l_first_uom_rec                 := g_locs(l_cur_uom_rec).next_rec;
		  g_locs(l_cur_uom_rec).next_rec  := 0;

		  --If consist restrictions
		  IF l_consist_exists THEN

                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'insert_consist', 'Calling Insert_Consist_Record');
                  END IF;

                  --call insert consist record
                  insert_consist_record(
                    x_return_status              => x_return_status
                  , x_msg_count                  => x_msg_count
                  , x_msg_data                   => x_msg_data
                  , p_record_id                  => l_cur_uom_rec
                  , p_needed_quantity            => l_needed_quantity
                  , p_use_pick_uom               => FALSE
                  , p_organization_id            => p_organization_id
                  , p_inventory_item_id          => p_inventory_item_id
                  , p_to_subinventory_code       => l_to_subinventory_code
                  , p_to_locator_id              => l_to_locator_id
                  , p_to_cost_group_id           => l_to_cost_group_id
                  , p_primary_uom                => p_primary_uom
                  , p_transaction_uom            => p_transaction_uom
                  , p_transaction_temp_id        => p_transaction_temp_id
                  , p_type_code                  => p_type_code
                  , p_rule_id                    => l_rule_id
                  , p_reservation_id             => l_reservation_id
                  , p_tree_id                    => p_tree_id
                  , p_debug_on                   => l_debug_on
                  , p_order_by_rank              => l_order_by_rank
                  , p_needed_sec_quantity        => l_sec_needed_quantity
                  , p_secondary_uom              => p_secondary_uom
                  , p_grade_code                 => p_grade_code
                  , x_finished                   => l_finished
                  , x_remaining_quantity         => l_remaining_quantity
                  );

                  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'uerr_insert_consist', 'Unexpected error in insert_consist_record');
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'err_insert_consist', 'Error in insert_consist_record');
                    END IF;
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  --if allocated a consist group, exit pick uom loop
                  IF l_finished THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'consist_finished', 'Allocated all needed quantity with consist group');
                    END IF;
                    l_needed_quantity  := 0;
                    l_sec_needed_quantity  := 0;
                    EXIT;
                  END IF;
                --else no consist restrictions
                ELSE
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'validate_insert', 'Calling Validate_and_Insert');
                  END IF;
                  --call Validate and insert
                  validate_and_insert(
                    x_return_status              => x_return_status
                  , x_msg_count                  => x_msg_count
                  , x_msg_data                   => x_msg_data
                  , p_record_id                  => l_cur_uom_rec
                  , p_needed_quantity            => l_needed_quantity
                  , p_use_pick_uom               => FALSE
                  , p_organization_id            => p_organization_id
                  , p_inventory_item_id          => p_inventory_item_id
                  , p_to_subinventory_code       => l_to_subinventory_code
                  , p_to_locator_id              => l_to_locator_id
                  , p_to_cost_group_id           => l_to_cost_group_id
                  , p_primary_uom                => p_primary_uom
                  , p_transaction_uom            => p_transaction_uom
                  , p_transaction_temp_id        => p_transaction_temp_id
                  , p_type_code                  => p_type_code
                  , p_rule_id                    => l_rule_id
                  , p_reservation_id             => l_reservation_id
                  , p_tree_id                    => p_tree_id
                  , p_debug_on                   => l_debug_on
                  , p_needed_sec_quantity        => l_sec_needed_quantity
                  , p_secondary_uom              => p_secondary_uom
                  , p_grade_code                 => p_grade_code
                  , x_inserted_record            => l_inserted_record
                  , x_allocated_quantity         => l_allocated_quantity
                  , x_remaining_quantity         => l_remaining_quantity
                  , x_sec_allocated_quantity     => l_sec_allocated_quantity
                  , x_sec_remaining_quantity     => l_sec_remaining_quantity
                  );

                  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
                    END IF;
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  --If returns true, decrease needed quantity
                  IF l_inserted_record THEN
                    l_needed_quantity  := l_needed_quantity - l_allocated_quantity;
                    l_sec_needed_quantity  := l_sec_needed_quantity - l_sec_allocated_quantity;
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'need_qty', 'New Needed quantity: ' || l_needed_quantity);
                       log_statement(l_api_name, 'sec need_qty', 'sec New Needed quantity: ' || l_sec_needed_quantity);
                    END IF;
                  END IF;
                END IF; -- consist records

                --exit pick UOM loop when needed qty = 0
                --EXIT WHEN l_needed_quantity = 0;
                IF g_over_allocation = 'N'
                OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
                OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
			EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
                ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
			IF l_max_tolerance  >= 0 THEN
				EXIT WHEN (l_needed_quantity <= l_max_tolerance)
				OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			ELSE
				EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			END IF;
                END IF;
                --end loop (pick UOM)
                l_cur_uom_rec                   := g_locs(l_cur_uom_rec).next_rec;
              END LOOP; --pick UOM

              --if needed qty = 0, exit outer loop
            --EXIT WHEN l_needed_quantity = 0;
              IF g_over_allocation = 'N'
              OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
              OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
			EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
	      ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
			IF l_max_tolerance  >= 0 THEN
				EXIT WHEN (l_needed_quantity <= l_max_tolerance)
				OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			ELSE
				EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
			END IF;
              END IF;
            END IF; --allocation mode in 3,4

            --if consist restrictions
            IF l_consist_exists THEN

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'consist', 'Reading from consist groups');
              END IF;
              --for each record in consist group
              l_cur_consist_group  := g_first_consist_group;

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'first_consist', 'First consist group:' || g_first_consist_group);
              END IF;

              LOOP
                EXIT WHEN l_cur_consist_group = 0;

                --if group alloc qty > needed qty
                IF g_consists(l_cur_consist_group).quantity >= l_needed_quantity THEN
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'alloc_consist', 'Found a consist group to allocate');
                  END IF;
                  --call allocate_consist_group
                  allocate_consist_group(
                    x_return_status              => x_return_status
                  , x_msg_count                  => x_msg_count
                  , x_msg_data                   => x_msg_data
                  , p_group_id                   => l_cur_consist_group
                  , p_needed_quantity            => l_needed_quantity
                  , p_use_pick_uom               => FALSE
                  , p_organization_id            => p_organization_id
                  , p_inventory_item_id          => p_inventory_item_id
                  , p_to_subinventory_code       => l_to_subinventory_code
                  , p_to_locator_id              => l_to_locator_id
                  , p_to_cost_group_id           => l_to_cost_group_id
                  , p_primary_uom                => p_primary_uom
                  , p_transaction_uom            => p_transaction_uom
                  , p_transaction_temp_id        => p_transaction_temp_id
                  , p_type_code                  => p_type_code
                  , p_rule_id                    => l_rule_id
                  , p_reservation_id             => l_reservation_id
                  , p_tree_id                    => p_tree_id
                  , p_debug_on                   => l_debug_on
                  , p_needed_sec_quantity        => l_sec_needed_quantity
                  , p_secondary_uom              => p_secondary_uom
                  , p_grade_code                 => p_grade_code
                  , p_lot_divisible_flag         => inv_cache.item_rec.lot_divisible_flag
                  , x_success                    => l_finished
                  );

                  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'uerr_allocate_consist', 'Unexpected error in allocate_consist_group');
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'err_allocate_consist', 'Error in allocate_consist_group');
                    END IF;
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  --if finished = true
                  --exit consist restrictions loop
                  IF l_finished THEN
                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'allocated_consist', 'Successfully allocated consistency group');
                    END IF;
                    l_needed_quantity  := 0;
                    l_sec_needed_quantity  := 0;
                    EXIT;
                  END IF;
                END IF;

                --end consist loop
                l_cur_consist_group  := g_consists(l_cur_consist_group).next_group;

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'next_consist', 'Next consist group: ' || l_cur_consist_group);
                END IF;

             END LOOP;
            --Exit outermost loop
            END IF; -- consist records

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'end_alloc', 'No more pick UOM or ' || 'consistecy records to Allocate.');
            END IF;

            EXIT;
          END IF; --no more record

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'order_string', 'Checking order string');
          END IF;

          --if allocation mode = 3 and record has different order by string
          IF  l_allocation_mode = 3
              AND l_first_uom_rec <> 0
              AND v_current_row.order_by_string <> l_cur_order_by_string THEN

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'change string', 'The order_by_string has changed.  Reading from pick UOM list');
            END IF;

            l_cur_uom_rec    := l_first_uom_rec;

            LOOP
              EXIT WHEN l_cur_uom_rec = 0;

              --If consist restrictions
              IF l_consist_exists THEN

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'insert_consist', 'Calling insert consist record from pick UOM list');
                END IF;

                --call insert consist record
                insert_consist_record(
                  x_return_status              => x_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_record_id                  => l_cur_uom_rec
                , p_needed_quantity            => l_needed_quantity
                , p_use_pick_uom               => FALSE
                , p_organization_id            => p_organization_id
                , p_inventory_item_id          => p_inventory_item_id
                , p_to_subinventory_code       => l_to_subinventory_code
                , p_to_locator_id              => l_to_locator_id
                , p_to_cost_group_id           => l_to_cost_group_id
                , p_primary_uom                => p_primary_uom
                , p_transaction_uom            => p_transaction_uom
                , p_transaction_temp_id        => p_transaction_temp_id
                , p_type_code                  => p_type_code
                , p_rule_id                    => l_rule_id
                , p_reservation_id             => l_reservation_id
                , p_tree_id                    => p_tree_id
                , p_debug_on                   => l_debug_on
                , p_order_by_rank              => l_order_by_rank
                , p_needed_sec_quantity        => l_sec_needed_quantity
                , p_secondary_uom              => p_secondary_uom
                , p_grade_code                 => p_grade_code
                , x_finished                   => l_finished
                , x_remaining_quantity         => l_remaining_quantity
                );

                IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'uerr_insert_consist', 'Unexpected error in insert_consist_record');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'err_insert_consist', 'Error in insert_consist_record');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                END IF;

                --if allocated a consist group, exit pick uom loop
                IF l_finished THEN

                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'finish_consist', 'Successfully allocated a consistency group');
                  END IF;

                  l_needed_quantity  := 0;
                  l_sec_needed_quantity  := 0;
                  EXIT;
                END IF;
              --else no consist restrictions
              ELSE

                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'validate_insert', 'Calling Validate_and_insert for pick uom list');
                END IF;

               --call Validate and insert
                validate_and_insert(
                  x_return_status              => x_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_record_id                  => l_cur_uom_rec
                , p_needed_quantity            => l_needed_quantity
                , p_use_pick_uom               => FALSE
                , p_organization_id            => p_organization_id
                , p_inventory_item_id          => p_inventory_item_id
                , p_to_subinventory_code       => l_to_subinventory_code
                , p_to_locator_id              => l_to_locator_id
                , p_to_cost_group_id           => l_to_cost_group_id
                , p_primary_uom                => p_primary_uom
                , p_transaction_uom            => p_transaction_uom
                , p_transaction_temp_id        => p_transaction_temp_id
                , p_type_code                  => p_type_code
                , p_rule_id                    => l_rule_id
                , p_reservation_id             => l_reservation_id
                , p_tree_id                    => p_tree_id
                , p_debug_on                   => l_debug_on
                , p_needed_sec_quantity        => l_sec_needed_quantity
                , p_secondary_uom              => p_secondary_uom
                , p_grade_code                 => p_grade_code
                , x_inserted_record            => l_inserted_record
                , x_allocated_quantity         => l_allocated_quantity
                , x_remaining_quantity         => l_remaining_quantity
                , x_sec_allocated_quantity     => l_sec_allocated_quantity
                , x_sec_remaining_quantity     => l_sec_remaining_quantity
                );

                IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                END IF;

                --If returns true, decrease needed quantity
                IF l_inserted_record THEN
                  l_needed_quantity  := l_needed_quantity - l_allocated_quantity;
                  l_sec_needed_quantity  := l_sec_needed_quantity - l_sec_allocated_quantity;

                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'success_validate', 'Successfully inserted record.  New needed quantity: ' || l_needed_quantity);
                     log_statement(l_api_name, 'success_validate', 'Successfully inserted record.  sec New needed quantity: ' || l_sec_needed_quantity);
                  END IF;

                END IF;
              END IF; -- consist records

              --exit pick UOM loop when needed qty = 0
            --EXIT WHEN l_needed_quantity = 0;
              IF g_over_allocation = 'N'
              OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
              OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
		EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
              ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
		IF l_max_tolerance  >= 0 THEN
			EXIT WHEN (l_needed_quantity <= l_max_tolerance)
			OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
		ELSE
			EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
		END IF;
              END IF;
              l_cur_uom_rec  := g_locs(l_cur_uom_rec).next_rec;
            --end loop (pick UOM)
            END LOOP; --pick UOM

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'end_pick_uom', 'End Pick UOM loop');
            END IF;

            l_first_uom_rec  := 0;
            l_cur_uom_rec    := 0;
            l_last_uom_rec   := 0;
          END IF;

        --EXIT WHEN l_needed_quantity = 0;
          IF g_over_allocation = 'N'
          OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
          OR  WMS_Engine_PVT.g_move_order_type <> 3 THEN
              EXIT WHEN l_needed_quantity <= 0 or l_needed_quantity <= l_max_tolerance;
          ELSIF g_over_allocation = 'Y' AND p_type_code = 2 AND WMS_Engine_PVT.g_move_order_type = 3 THEN
              IF l_max_tolerance  >= 0 THEN
                 EXIT WHEN (l_needed_quantity <= l_max_tolerance)
                 OR (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
              ELSE
                 EXIT WHEN (l_initial_pri_quantity - l_needed_quantity >= WMS_RULE_PVT.g_min_qty_to_allocate);
              END IF;
          END IF;

          IF NVL(l_cur_order_by_string, '@@@') <> NVL(v_current_row.order_by_string, '@@@') THEN

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'order_rank', 'Setting order rank');
            END IF;

            l_order_by_rank        := l_order_by_rank + 1;
            l_cur_order_by_string  := v_current_row.order_by_string;

            IF g_first_order_by_rank IS NULL THEN
              log_statement(l_api_name, 'first_order', 'Setting first order rank');
              g_first_order_by_rank  := l_order_by_rank;
            END IF;
          END IF;

          g_locs_index            := g_locs_index + 1;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'loc_index', 'New loc index: ' || g_locs_index);
          END IF;

          g_locs(g_locs_index)    := v_current_row;

          --initialize trace records
          IF l_debug_on THEN

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'trace_init', 'Init Trace Record');
            END IF;

            g_trace_recs(g_locs_index).revision                 := v_current_row.revision;
            g_trace_recs(g_locs_index).lot_number               := v_current_row.lot_number;
            g_trace_recs(g_locs_index).lot_expiration_date      := v_current_row.lot_expiration_date;
            g_trace_recs(g_locs_index).subinventory_code        := v_current_row.subinventory_code;
            g_trace_recs(g_locs_index).locator_id               := v_current_row.locator_id;
            g_trace_recs(g_locs_index).cost_group_id            := v_current_row.cost_group_id;
            g_trace_recs(g_locs_index).lpn_id                   := v_current_row.lpn_id;
            g_trace_recs(g_locs_index).uom_code                 := v_current_row.uom_code;
            g_trace_recs(g_locs_index).quantity                 := v_current_row.quantity;
            g_trace_recs(g_locs_index).secondary_qty            := v_current_row.secondary_quantity;
            g_trace_recs(g_locs_index).grade_code               := v_current_row.grade_code;
            g_trace_recs(g_locs_index).serial_number            := v_current_row.serial_number;
            g_trace_recs(g_locs_index).consist_string_flag      := 'V';
            g_trace_recs(g_locs_index).partial_pick_flag        := 'Y';
            g_trace_recs(g_locs_index).order_string_flag        := 'Y';
            g_trace_recs(g_locs_index).pick_uom_flag            := 'V';
            g_trace_recs(g_locs_index).serial_number_used_flag  := 'V';
            g_trace_recs(g_locs_index).entire_lpn_flag          := 'V';
            --write to log file

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'rev', 'revision: ' || v_current_row.revision);
               log_statement(l_api_name, 'lot', 'lot: ' || v_current_row.lot_number);
               log_statement(l_api_name, 'sub', 'sub:' || v_current_row.subinventory_code);
               log_statement(l_api_name, 'loc', 'loc: ' || v_current_row.locator_id);
               log_statement(l_api_name, 'cg', 'cg: ' || v_current_row.cost_group_id);
               log_statement(l_api_name, 'lpn', 'lpn: ' || v_current_row.lpn_id);
               log_statement(l_api_name, 'sn', 'sn: ' || v_current_row.serial_number);
               log_statement(l_api_name, 'qty', 'quantity: ' || v_current_row.quantity);
               log_statement(l_api_name, 'sqty', 'sec_quantity: ' || v_current_row.secondary_quantity);
               log_statement(l_api_name, 'grade', 'grade_code: ' || v_current_row.grade_code);
               log_statement(l_api_name, 'uom', 'uom_code: ' || v_current_row.uom_code);
               log_statement(l_api_name, 'suom', 'sec_uom_code: ' || v_current_row.secondary_uom_code);
               log_statement(l_api_name, 'ord', 'order:' || v_current_row.order_by_string);
               log_statement(l_api_name, 'con', 'consist:' || v_current_row.consist_string);
            END IF;

          END IF;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'valid_sub', 'Validating sub');
          END IF;

          --validate from/to sub/loc
          --if fail, goto next output record
          --first check to make sure picking from dest sub is not allowed;
          --then, based on type code, compare src sub to dest sub;
          --next, check to see if sub and item are locator controlled;
          --if loc control, go to next record only if src loc = dest loc;
          --if not loc control, go to next records (since subs are equal);
          --all of the global variables are set in
          --wms_engine_pvt.create_suggestions
          IF (wms_engine_pvt.g_dest_sub_pick_allowed = 0
              AND v_current_row.subinventory_code = l_to_subinventory_code
             ) THEN
             IF (wms_engine_pvt.g_org_loc_control IN (2, 3)
                 OR wms_engine_pvt.g_sub_loc_control IN (2, 3)
                 OR (wms_engine_pvt.g_sub_loc_control = 5
                     AND (wms_engine_pvt.g_item_loc_control IN (2, 3))
                   )
               ) THEN
              IF (v_current_row.locator_id = l_to_locator_id) THEN

                IF l_debug = 1 THEN
                   log_event(
                     l_api_name
                     ,  'sub_loc_same'
                     , 'Cannot use this ' || 'location since source subinventory and locator are' || ' same as destination subinventory and locator'
                    );
                END IF;

                IF l_debug_on THEN
                  g_trace_recs(g_locs_index).same_subinv_loc_flag  := 'N';
                END IF;

                GOTO nextoutputrecord2;
              END IF;
            ELSE

              IF l_debug = 1 THEN
                 log_event(
                 l_api_name
                 , 'sub_same'
                 , 'Cannot use this ' || 'location since source subinventory is ' || 'same as destination subinventory'
                 );
              END IF;

              IF l_debug_on THEN
                g_trace_recs(g_locs_index).same_subinv_loc_flag  := 'N';
              END IF;

              GOTO nextoutputrecord2;
            END IF;
          END IF;

          IF l_debug_on THEN
            g_trace_recs(g_locs_index).same_subinv_loc_flag  := 'Y';
          END IF;

          --If consistency restrictions
          IF l_consist_exists THEN

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'query_tree', 'Querying the quantity tree' || ' to find availability for consist record');
            END IF;
            -- BUG 3609380 :  Removing l_to_subinevntory_code.
            --Validate available quantity
            inv_quantity_tree_pvt.query_tree
                 (
                     p_api_version_number         =>     g_qty_tree_api_version
                   , p_init_msg_lst               =>     fnd_api.g_false -- p_init_msg_lst
                   , x_return_status              =>     x_return_status
                   , x_msg_count                  =>     x_msg_count
                   , x_msg_data                   =>     x_msg_data
                   , p_tree_id                    =>     p_tree_id
                   , p_revision                   =>     v_current_row.revision
                   , p_lot_number                 =>     v_current_row.lot_number
                   , p_subinventory_code          =>     v_current_row.subinventory_code
                   , p_locator_id                 =>     v_current_row.locator_id
                   , x_qoh                        =>   l_qoh
                   , x_sqoh                       =>   l_sqoh
                   , x_rqoh                       =>   l_rqoh
                   , x_srqoh                      =>   l_srqoh
                   , x_qr                         =>   l_qr
                   , x_sqr                        =>   l_sqr
                   , x_qs                         =>   l_qs
                   , x_sqs                        =>   l_sqs
                   , x_att                        =>   l_att
                   , x_satt                       =>   l_satt
                   , x_atr                        =>   l_atr
                   , x_satr                       =>   l_satr
                   , p_transfer_subinventory_code =>     chk_for_passing_xfer_sub ( p_transaction_temp_id , l_to_subinventory_code) -- Bug# 4099907
                   , p_cost_group_id              =>     v_current_row.cost_group_id
                   , p_lpn_id                     =>     v_current_row.lpn_id
                 );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_qty_tree', 'Unexpected error in inv_quantity_tree_Pvt.query_tree');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_qty_tree', 'Error in inv_quantity_tree_Pvt.query_tree');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'att', 'ATT : ' || l_att);
            END IF;

            --If att<=0, goto next output rec
            IF l_att <= 0 THEN

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'no_att', 'No ATT for this record. ' || 'Getting next record');
              END IF;

              IF l_debug_on THEN
                g_trace_recs(g_locs_index).att_qty                 := l_att;
                g_trace_recs(g_locs_index).secondary_att_qty       := l_satt;
                g_trace_recs(g_locs_index).att_qty_flag            := 'N';
              END IF;

              GOTO nextoutputrecord2;
            END IF;

            IF l_debug_on THEN
              g_trace_recs(g_locs_index).att_qty                 := l_att;
              g_trace_recs(g_locs_index).secondary_att_qty       := l_satt;
              g_trace_recs(g_locs_index).att_qty_flag            := 'Y';
            END IF;

            IF l_att < v_current_row.quantity THEN

              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'less_att', 'ATT is less than onhand ' || 'quantity. Reducing quantity');
              END IF;

              g_locs(g_locs_index).quantity  := l_att;
            END IF;

             IF l_debug = 1 THEN
               --Insert_consist_record
               log_statement(l_api_name, 'insert_consist', 'Calling Insert_Consist_Record');
             END IF;

            --init consist flag to N.  It gets set to yes in Alloc. Consist. Group
            IF l_debug_on THEN
              g_trace_recs(g_locs_index).consist_string_flag  := 'N';
            END IF;

            insert_consist_record(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_record_id                  => g_locs_index
            , p_needed_quantity            => l_needed_quantity
            , p_use_pick_uom               => l_use_pick_uom
            , p_organization_id            => p_organization_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_to_subinventory_code       => l_to_subinventory_code
            , p_to_locator_id              => l_to_locator_id
            , p_to_cost_group_id           => l_to_cost_group_id
            , p_primary_uom                => p_primary_uom
            , p_transaction_uom            => p_transaction_uom
            , p_transaction_temp_id        => p_transaction_temp_id
            , p_type_code                  => p_type_code
            , p_rule_id                    => l_rule_id
            , p_reservation_id             => l_reservation_id
            , p_tree_id                    => p_tree_id
            , p_debug_on                   => l_debug_on
            , p_order_by_rank              => l_order_by_rank
            , p_needed_sec_quantity        => l_sec_needed_quantity
            , p_secondary_uom              => p_secondary_uom
            , p_grade_code                 => p_grade_code
            , x_finished                   => l_finished
            , x_remaining_quantity         => l_remaining_quantity
            );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_insert_consist', 'Unexpected error in insert_consist_record');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_insert_consist', 'Error in insert_consist_record');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

            --if finished, needed qty = 0
            IF l_finished THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'finished', 'Successfully allocated ' || 'consistency group');
              END IF;
              l_needed_quantity  := 0;
              l_sec_needed_quantity  := 0;
              EXIT;
            END IF;
          --else no consist
          ELSE
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'validate_insert', 'Calling Validate_and_insert');
            END IF;
            --call validate and insert
            validate_and_insert(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_record_id                  => g_locs_index
            , p_needed_quantity            => l_needed_quantity
            , p_use_pick_uom               => l_use_pick_uom
            , p_organization_id            => p_organization_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_to_subinventory_code       => l_to_subinventory_code
            , p_to_locator_id              => l_to_locator_id
            , p_to_cost_group_id           => l_to_cost_group_id
            , p_primary_uom                => p_primary_uom
            , p_transaction_uom            => p_transaction_uom
            , p_transaction_temp_id        => p_transaction_temp_id
            , p_type_code                  => p_type_code
            , p_rule_id                    => l_rule_id
            , p_reservation_id             => l_reservation_id
            , p_tree_id                    => p_tree_id
            , p_debug_on                   => l_debug_on
            , p_needed_sec_quantity        => l_sec_needed_quantity
            , p_secondary_uom              => p_secondary_uom
            , p_grade_code                 => p_grade_code
            , x_inserted_record            => l_inserted_record
            , x_allocated_quantity         => l_allocated_quantity
            , x_remaining_quantity         => l_remaining_quantity
            , x_sec_allocated_quantity     => l_sec_allocated_quantity
            , x_sec_remaining_quantity     => l_sec_remaining_quantity
            );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_validate_insert', 'Unexpected error in validate_and_insert');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

            --if returns true, decrease needed qty
            IF l_inserted_record THEN
              l_needed_quantity  := l_needed_quantity - l_allocated_quantity;
              l_sec_needed_quantity  := l_sec_needed_quantity - l_sec_allocated_quantity;
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'inserted_rec', 'Inserted record.  New needed quantity: ' || l_needed_quantity);
		 log_statement(l_api_name, 'inserted_rec', 'Inserted record.  sec New needed quantity: ' || l_sec_needed_quantity);
              END IF;
            END IF;
          END IF; -- no consist restrictions

	  -- Just comment here for R12.1 replenishment project, no code change here
	  -- In case of allocation_mode= 5 we do not need to keep track of left out qty at locations because
	  -- we will not be using them in the next round. We strictly pick based on the pick UOM code and we
	  -- do not break. So we do not need to add anything in the following code.


	  --If remaining qty >0 and allocation mode in 3,4
          IF  l_allocation_mode IN (3, 4)
              AND l_remaining_quantity > 0 THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'remain_qty', 'Remaining quantity: ' || l_remaining_quantity || '.  Creating pick UOM rec');
            END IF;
            l_cur_rec  := g_locs_index;

            IF l_remaining_quantity < g_locs(g_locs_index).quantity THEN
              --create new location record for remaining quantity
              g_locs_index                   := g_locs_index + 1;
              g_locs(g_locs_index)           := g_locs(l_cur_rec);
              g_locs(g_locs_index).quantity  := l_remaining_quantity;
              g_locs(l_cur_rec).quantity     := g_locs(l_cur_rec).quantity - l_remaining_quantity;
              l_cur_uom_rec                  := g_locs_index;
            ELSE
              l_cur_uom_rec  := l_cur_rec;
            END IF;

            -- new record is first record in table
            IF l_first_uom_rec = 0 THEN
              l_first_uom_rec                 := l_cur_uom_rec;
              l_last_uom_rec                  := l_cur_uom_rec;
              g_locs(l_cur_uom_rec).next_rec  := 0;
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'first_rec', 'The saved uom record is the first record in table');
              END IF;
            -- new record is first record with that uom code
            ELSIF g_locs(l_first_uom_rec).uom_code <> g_locs(l_cur_uom_rec).uom_code THEN
              g_locs(l_cur_uom_rec).next_rec  := l_first_uom_rec;
              l_first_uom_rec                 := l_cur_uom_rec;
              l_last_uom_rec                  := l_cur_uom_rec;
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'first_rec_uom', 'The saved uom record is the first record for uom in table');
              END IF;
            -- records with this uom code already exist in table
            ELSE
              g_locs(l_cur_uom_rec).next_rec   := g_locs(l_last_uom_rec).next_rec;
              g_locs(l_last_uom_rec).next_rec  := l_cur_uom_rec;
              l_last_uom_rec                   := l_cur_uom_rec;
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'not_first_rec_uom', 'The saved record is not first record for uom in table');
              END IF;
            END IF;

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'saving_loc', 'Storing record in uom table');
            END IF;

            IF l_debug_on THEN
              --determine if we created a new record or not
              IF l_cur_uom_rec = g_locs_index THEN
                g_trace_recs(g_locs_index)                := g_trace_recs(l_cur_rec);
                g_trace_recs(l_cur_rec).quantity          := g_trace_recs(l_cur_rec).quantity - l_remaining_quantity;
                g_trace_recs(g_locs_index).quantity       := l_remaining_quantity;
                g_trace_recs(g_locs_index).suggested_qty  := 0;
                g_trace_recs(l_cur_rec).pick_uom_flag     := 'P';
                g_trace_recs(g_locs_index).pick_uom_flag  := 'N';
              ELSE
                g_trace_recs(l_cur_rec).pick_uom_flag  := 'N';
              END IF;
            END IF;
          ELSE
            IF l_debug_on THEN
              g_trace_recs(g_locs_index).pick_uom_flag  := 'Y';
            END IF;
          END IF; --allocation mode in 3,4

          --if needed qty = 0 , exit outermost loop
          --IF l_needed_quantity <= 0 THEN
          IF l_needed_quantity >= 0 and l_needed_quantity <= l_max_tolerance THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'finished_alloc', 'The requested quantity has been allocated.  Exiting loop.');
            END IF;
            EXIT;
          END IF;

          <<nextoutputrecord2>>
          NULL;
        --end outermost loop
        END LOOP;
      --PUT AWAY
      ELSIF (p_type_code = 1) THEN --put away
        l_capacity_updated  := FALSE;
        l_locs_index        := 0;

        --Loop through each record from the Rule cursor
        WHILE TRUE LOOP
          IF l_debug = 1 THEN
             log_event(l_api_name, 'Loop through each record  putaway from the Rule cursor ', 'Start ' || WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE);
          END IF;
          --l_locs_index        := l_locs_index + 1; --bug3673962 moving this assignment as when no rows are returned by fetchputaway
                                                     --the index gets incremented unncessarily and fails in WMSSOGBB.pls
          fetchputaway(
            x_return_status
          , x_msg_count
          , x_msg_data
          , v_put_cursor
          , l_rule_id
          , l_osubinventory_code
          , l_olocator_id
          , l_oproject_id
          , l_otask_id
          , l_rows
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'uerr_fetch_cursor',
                          'Unexpected error in FetchCursor');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name,'err_fetch_cursor','Error in FetchCursor');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- Exit if no more records from rule cursor
          EXIT WHEN  nvl(l_rows, 0)  = 0 ;  -- [ Added to to exit , if the rule is not returning any rows

          l_locs_index        := l_locs_index + 1; --bug3673962
          log_statement(l_api_name, 'org_loc_ctl ', 'org: ' ||wms_engine_pvt.g_org_loc_control);
          log_statement(l_api_name, 'sub_loc_ctl ', 'org: ' ||wms_engine_pvt.g_sub_loc_control);
          log_statement(l_api_name, 'itm_loc_ctl ', 'org: ' ||wms_engine_pvt.g_item_loc_control);
          /* bug 3972784, remove locator_id if no locator control */
          IF (  wms_engine_pvt.g_org_loc_control in (1,4)                   -- no loc ctl org level
               AND ( wms_engine_pvt.g_sub_loc_control = 1                  -- no loc ctl sub level
                  OR (wms_engine_pvt.g_sub_loc_control = 5
                         AND wms_engine_pvt.g_item_loc_control = 1           -- no loc ctl item level
                     )
                   )
             )
          THEN
              l_olocator_id := null;
              log_statement(l_api_name, 'non locator controled',' Non locator controled');
          END IF;

          IF l_debug = 1 THEN
            log_statement(l_api_name, 'put_sub', 'Subinventory: ' || l_osubinventory_code);
             log_statement(l_api_name, 'put_loc', 'Locator: ' || l_olocator_id);
             log_statement(l_api_name, 'put_proj', 'Project: ' || l_oproject_id);
             log_statement(l_api_name, 'put_task', 'Task: ' || l_otask_id);
          END IF;

          IF l_debug_on THEN
            g_trace_recs(l_locs_index).revision             := l_revision;
            g_trace_recs(l_locs_index).lot_number           := l_lot_number;
            g_trace_recs(l_locs_index).lot_expiration_date  := l_lot_expiration_date;
            g_trace_recs(l_locs_index).subinventory_code    := l_osubinventory_code;
            g_trace_recs(l_locs_index).locator_id           := l_olocator_id;
            g_trace_recs(l_locs_index).cost_group_id        := l_to_cost_group_id;
            g_trace_recs(l_locs_index).uom_code             := NULL;
            g_trace_recs(l_locs_index).lpn_id               := l_input_lpn_id;
            g_trace_recs(l_locs_index).quantity             := NULL;
            g_trace_recs(l_locs_index).serial_number        := l_serial_number;
            --init to 0, in case of error
            g_trace_recs(l_locs_index).suggested_qty        := 0;
          END IF;


          --bug 2589499
          --if reservation exists for WIP assembly completion, put away
          --   to reservable sub only;
          --we know if sub has to be reservable based on global value set in
          --  create_suggestions
          IF wms_engine_pvt.g_reservable_putaway_sub_only THEN
             -- 8809951 removed curosr and using INV CACHE
	     IF (inv_cache. set_tosub_rec(p_organization_id, l_osubinventory_code) )	THEN
		        	l_lpn_controlled_flag  := inv_cache.tosub_rec.lpn_controlled_flag;
		        	l_sub_rsv_type         := inv_cache.tosub_rec.reservable_type;
	     END IF;

             If l_sub_rsv_type <> 1 Then
               IF l_debug = 1 THEN
                  log_statement(l_api_name, 'non_rsv_dest_sub',
                    'This material cannot be putaway in a non-reservable sub. ' ||
                    'Getting next record');
               END IF;
               --set trace flag
               GOTO NextOutputRecord;
             End If;
          END IF;



          --3/13/02 - To support PJM, check project and task if supplied.
          -- Case 1) Project and Task not supplied do nothing
          --      2) Project and Task Supplied and current record has same
          --     project and task continue processing.
          --      3) Project and Task supplied, not in current record
          --     then create a new entry in MTL_ITEM_LOCATIONS with
          --     properties of current record but with require project and task
          --  <This assumes that the results are ordered by Project and Task>
          IF p_project_id IS NOT NULL THEN
            IF NVL(l_oproject_id, -9999) <> p_project_id
               OR NVL(l_otask_id, -9999) <> nvl(p_task_id,-9999) THEN
              --bug 2400549 - for WIP backflush transfer putaway,
              --always use the locator specified on the move order line, even
              --if that locator is from common stock (not project)
              -- Bug 2666620: BackFlush MO Type Removed. It is now 5.
              -- Moreover Txn Action ID is 2  which is already handled.
             IF NOT (wms_engine_pvt.g_move_order_type = 5 AND
                 wms_engine_pvt.g_transaction_action_id = 2) THEN
                 IF l_debug = 1 THEN
                   log_statement(l_api_name, 'do_project2', 'Calling do project check');
                 END IF;
                IF doprojectcheck(l_return_status,
                                  l_olocator_id,
                                  p_project_id,
                                  p_task_id,
                                  l_olocator_id_new,l_dummy_loc) THEN
                   IF l_debug = 1 THEN
                     log_statement(l_api_name, 'do_project_success', 'Do project check returned new locator');
                   END IF;
                   l_olocator_id_prev  := l_olocator_id;
                   l_olocator_id       := l_olocator_id_new;
                ELSE
                  -- Current locator does not have required project/task
                              -- but it exists
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'do_project_fail', 'Do project check failed. Getting next record.');
                  END IF;
                  GOTO nextoutputrecord;
                END IF; --do project check
              END IF; -- not wip backflush
            END IF; -- allocated project <> needed project
          END IF; -- needed project <> -9999

                --2/21/02 - Now check available capacity in here in the Pl/Sql
          --instead of calling the APIs from the rule sql.  This is to
          --improve performance.  If there are 10000 eligible locators, you
          --don't want to check capacity for all of them.  You only want to
          --check capacity on the one or two that you'll end up allocating
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'qty_function', 'qty function code: ' || l_quantity_function);
          END IF;
       IF l_consider_staging_capacity THEN --Added bug3237702
          IF l_quantity_function = 530003 THEN
            l_possible_quantity  := wms_parameter_pvt.getavailableunitcapacity(
                                      p_organization_id            => p_organization_id
                                    , p_subinventory_code          => l_osubinventory_code
                                    , p_locator_id                 => l_olocator_id
                                    );
          ELSIF l_quantity_function = 530007 THEN
            l_possible_quantity  := wms_parameter_pvt.getavailablevolumecapacity(
                                      p_organization_id            => p_organization_id
                                    , p_subinventory_code          => l_osubinventory_code
                                    , p_locator_id                 => l_olocator_id
                                    , p_inventory_item_id          => p_inventory_item_id
                                    , p_unit_volume                => p_unit_volume
                                    , p_unit_volume_uom_code       => p_volume_uom_code
                                    , p_primary_uom                => p_primary_uom
                                    , p_transaction_uom            => p_transaction_uom
                                    , p_base_uom                   => p_base_uom_code
                                    );
          ELSIF l_quantity_function = 530011 THEN
            l_possible_quantity  := wms_parameter_pvt.getavailableweightcapacity(
                                      p_organization_id            => p_organization_id
                                    , p_subinventory_code          => l_osubinventory_code
                                    , p_locator_id                 => l_olocator_id
                                    , p_inventory_item_id          => p_inventory_item_id
                                    , p_unit_weight                => p_unit_weight
                                    , p_unit_weight_uom_code       => p_weight_uom_code
                                    , p_primary_uom                => p_primary_uom
                                    , p_transaction_uom            => p_transaction_uom
                                    , p_base_uom                   => p_base_uom_code
                                    );
          ELSIF l_quantity_function = 530015 THEN
            l_possible_quantity  := wms_parameter_pvt.getminimumavailablevwcapacity(
                                      p_organization_id            => p_organization_id
                                    , p_subinventory_code          => l_osubinventory_code
                                    , p_locator_id                 => l_olocator_id
                                    , p_inventory_item_id          => p_inventory_item_id
                                    , p_unit_volume                => p_unit_volume
                                    , p_unit_volume_uom_code       => p_volume_uom_code
                                    , p_unit_weight                => p_unit_weight
                                    , p_unit_weight_uom_code       => p_weight_uom_code
                                    , p_primary_uom                => p_primary_uom
                                    , p_transaction_uom            => p_transaction_uom
                                    , p_base_uom                   => p_base_uom_code
                                    );
          ELSIF l_quantity_function = 530019 THEN
            l_possible_quantity  := wms_parameter_pvt.getminimumavailableuvwcapacity(
                                      p_organization_id            => p_organization_id
                                    , p_subinventory_code          => l_osubinventory_code
                                    , p_locator_id                 => l_olocator_id
                                    , p_inventory_item_id          => p_inventory_item_id
                                    , p_unit_volume                => p_unit_volume
                                    , p_unit_volume_uom_code       => p_volume_uom_code
                                    , p_unit_weight                => p_unit_weight
                                    , p_unit_weight_uom_code       => p_weight_uom_code
                                    , p_primary_uom                => p_primary_uom
                                    , p_transaction_uom            => p_transaction_uom
                                    , p_base_uom                   => p_base_uom_code
                                    );
          ELSIF l_quantity_function = 530023 THEN
            l_possible_quantity  := wms_re_custom_pub.getavailablelocationcapacity(
                                      p_organization_id            => p_organization_id
                                    , p_subinventory_code          => l_osubinventory_code
                                    , p_locator_id                 => l_olocator_id
                                    , p_inventory_item_id          => p_inventory_item_id
                                    , p_transaction_quantity       => l_needed_quantity
                                    , p_transaction_uom            => p_transaction_uom
                                    );
          ELSE
            l_possible_quantity  := 0;
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'bad_qtyf', 'Invalid Quantity Function');
            END IF;
          --raise error message!!!
          END IF;
       ELSE
          -- capacity should not be considered
          l_possible_quantity := 1e125;
          l_sec_possible_quantity := 1e125;
       END IF;

       IF l_debug = 1 THEN
             log_statement(l_api_name, 'capacity', 'avail. capacity: ' || l_possible_quantity);
       END IF;

       --bug 2778814
       --For serial controlled items, we should not suggest the putaway
       --  of decimal quantities
       IF wms_engine_pvt.g_serial_number_control_code > 1 THEN
         l_possible_quantity := floor(l_possible_quantity);
         IF l_debug = 1 THEN
            log_statement(l_api_name, 'no_decimals',
                'Cannot putaway a decimal quantity on a serial controlled item.'||
                ' New available capacity: ' || l_possible_quantity);
         END IF;
       END IF;

          IF l_debug_on THEN
            g_trace_recs(l_locs_index).quantity  := l_possible_quantity;
          --g_trace_recs(l_locs_index).secondary_quantity  := l_sec_possible_quantity;
          END IF;

         -- [LOT_INDIV
	 --  For lot indiv item, check if entire line qty can be dropped
	 --  If not skip the current locator and go to next available locator
	 --
	 --  Default behavior is to split the qty and drop the partially
         --  and  go to the next locator for the remaining qty.

           IF l_lot_divisible_flag = 'N' and l_lot_control_code <> 1 and p_type_code = 1 THEN
              IF l_possible_quantity < l_needed_quantity THEN
                 IF l_debug = 1 THEN
                    log_event(l_api_name, 'Required Capacity  = ', l_needed_quantity);
                    log_event(l_api_name, 'Available capacity =',  l_possible_quantity);
                    log_event(l_api_name, 'Capacity check for Lot indiv item', 'Capacity is not enough !');
                 END IF;
              GOTO nextoutputrecord;
              END IF;
           END IF;
          -- If no quantity for this record, get next record
          IF l_possible_quantity <= 0 OR l_possible_quantity IS NULL THEN
            IF l_debug = 1 THEN
               log_event(l_api_name, 'no_rec_qty_put', 'No available capacity in putaway location');
            END IF;
            --
            -- Patchset 'J' error_message
            WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_LOC_CAPACITY_FULL' ;
            --
            --
            GOTO nextoutputrecord;
          END IF;

          --check to see if from sub/loc = to sub/loc
          --this is okay if pick wave move order.
          --if not pick wave move order and src = dest,
          -- skip results

          --first check to make sure picking from dest sub is not allowed;
          --then, based on type code, compare src sub to dest sub;
          --next, check to see if sub and item are locator controlled;
          --if loc control, go to next record only if src loc = dest loc
          --if not loc control, go to next records (since subs are equal)
                --all of the global variables are set in
          --wms_engine_pvt.create_suggestions
          IF (wms_engine_pvt.g_dest_sub_pick_allowed = 0
              AND l_osubinventory_code = l_from_subinventory_code
             ) THEN
            IF (wms_engine_pvt.g_org_loc_control IN (2, 3)
                OR wms_engine_pvt.g_sub_loc_control IN (2, 3)
                OR (wms_engine_pvt.g_sub_loc_control = 5
                    AND (wms_engine_pvt.g_item_loc_control IN (2, 3))
                   )
               ) THEN
              IF (l_olocator_id = l_from_locator_id) THEN

                IF l_debug = 1 THEN
                   log_event(
                     l_api_name
                   , 'same_sub_loc_put'
                   ,    'Destination '
                  || 'subinventory and locator for this record are the '
                  || 'same as the source subinventory and locator. '
                  || 'Using next record'
                  );
                END IF;

                IF l_debug_on THEN
                  g_trace_recs(l_locs_index).same_subinv_loc_flag  := 'N';
                END IF;

                --
                -- Patchset 'J' error_message
                WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_SAME_SUB_LOC' ;
                --
                --
                GOTO nextoutputrecord;
              END IF; -- from loc = to loc
            ELSE -- not loc controlled
              IF l_debug = 1 THEN
                 log_event(
                    l_api_name
                    , 'same_sub_put'
                    , 'Destination ' || 'subinventory for this record is the ' || 'same as the source subinventory. ' || 'Using next record'
                   );
               END IF;

              IF l_debug_on THEN
                g_trace_recs(l_locs_index).same_subinv_loc_flag  := 'N';
              END IF;

              GOTO nextoutputrecord;
            END IF;
          END IF;

          IF l_debug_on THEN
            g_trace_recs(l_locs_index).same_subinv_loc_flag  := 'Y';
          END IF;

          --check status to see if putting away to this location is allowed
          -- for this transaction type
          -- This API checks the status for the subinventory, locator,
          -- and lot
          IF l_debug = 1 THEN
             log_statement(l_api_name, 'checking_status', 'calling is_sub_loc_lot_trx_allowed to check status');
          END IF;

          --Bug Number :3457530(cheking for a transaction_type_id)

          IF ( p_transaction_type_id <> 64) THEN
          l_allowed           := inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(
                                   p_transaction_type_id        => p_transaction_type_id
                                 , p_organization_id            => p_organization_id
                                 , p_inventory_item_id          => p_inventory_item_id
                                 , p_subinventory_code          => l_osubinventory_code
                                 , p_locator_id                 => l_olocator_id
                                 , p_lot_number                 => l_lot_number
                                 );
          END IF;

          IF l_allowed <> 'Y' THEN

            IF l_debug = 1 THEN
               log_event(
                  l_api_name
                  , 'bad_status'
                  , 'This transaction type is not allowed by the status ' || 'for the subinventory, locator, or lot. Using ' || 'next record.'
                   );
             END IF;

            IF l_debug_on THEN
              g_trace_recs(l_locs_index).material_status_flag  := 'N';
            END IF;
	    --
	    -- Patchset 'J' error_message
	    WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_MAT_STATUS_NOT_ALLOWED' ;
	    --
	    --
            GOTO nextoutputrecord;
          END IF;

          IF l_debug_on THEN
            g_trace_recs(l_locs_index).material_status_flag  := 'Y';
          END IF;

          /* Bug 4544717 -Converted l_possible_quantity to primary uom before comparing with
                         l_needed_quantity which is in primary uom if the transaction uom and
                         primary uom were different */

          IF l_debug = 1 THEN
               log_statement(l_api_name, 'poss_put_qty', 'Value of p_transaction_uom:'|| p_transaction_uom);
               log_statement(l_api_name, 'poss_put_qty', 'Value of p_primary_uom'|| p_primary_uom);
          END IF;

          IF p_transaction_uom <> p_primary_uom THEN
             IF l_debug = 1 THEN
               log_statement(l_api_name, 'poss_put_qty', 'In the condition for transaction_uom and primary uom different');
             END IF;
             l_possible_quantity := inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_possible_quantity, p_transaction_uom, p_primary_uom , NULL, NULL);
          END IF;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'poss_put_qty', 'Value of l_possible_quantity' || l_possible_quantity);
             log_statement(l_api_name, 'poss_put_qty', 'Value of l_needed_quantity' || l_needed_quantity);
          END IF;

          /* End of fix for Bug 4544717 */


          -- correct possible quantity to what is really requested
          IF l_possible_quantity > l_needed_quantity THEN
            l_possible_quantity  := l_needed_quantity;
            l_sec_possible_quantity  := l_sec_needed_quantity;
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'poss_put_qty', 'Possible quantity > needed quantity. New poss qty:' || l_possible_quantity);
            END IF;
          END IF;

          --

                --Determine if putaway sub is LPN controlled.  If it is not,
          --then we need to check cost group commingling always;
                -- Check cost group if
          -- Cost group is not null AND
                -- (sub is not lpn controlled OR
                --  No lpn on move order line OR
            --  not a staging transfer)
                --Never suggest comingling of cost groups, unless we are
          -- putting away a LPN.
          --When putting away an LPN, we assume that user is putting away
          -- whole LPN, which means there will never be comingling.
          --bug 1570597 - staging transfers are always put away in an LPN,
          -- so we don't need to check for comingling.
          --bug 2161565 - need to check for cg commingling if
          -- to subinventory is not LPN controlled.
          --bug 2492526 - putting away to a project controlled locator
          -- will always change the CG.  So no need to worry about CG
          -- commingling if the dest. loc is project controlled.
          IF l_to_cost_group_id IS NULL THEN
            l_check_cg  := FALSE;
          ELSIF l_oproject_id IS NOT NULL THEN
            l_check_cg  := FALSE;
          ELSIF (p_lpn_id IS NOT NULL
                 OR p_transaction_type_id IN (52, 53)
                ) THEN

            --only execute query if we did not already find lpn_controlled_flag
            -- when determining if sub is reservable
            If l_lpn_controlled_flag IS NULL Then
              --8809951 Removed cursor and using INV CACHE
	      IF (inv_cache. set_tosub_rec(p_organization_id, l_osubinventory_code) )	THEN
			         l_lpn_controlled_flag  := inv_cache.tosub_rec.lpn_controlled_flag;
			         l_sub_rsv_type         := inv_cache.tosub_rec.reservable_type;
	      END IF;
            End If;

            IF l_lpn_controlled_flag = 1 THEN
              l_check_cg  := FALSE;
            ELSE
              l_check_cg  := TRUE;
            END IF;
          ELSE
            l_check_cg  := TRUE;
          END IF;

          --Check to see if putaway would comingle cost groups.
          IF l_check_cg THEN
            inv_comingling_utils.comingle_check(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , x_comingling_occurs          => l_comingle
            , x_count                      => l_dummy
            , p_organization_id            => p_organization_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_revision                   => l_revision
            , p_lot_number                 => l_lot_number
            , p_subinventory_code          => l_osubinventory_code
            , p_locator_id                 => l_olocator_id
            , p_lpn_id                     => NULL
            , p_cost_group_id              => l_to_cost_group_id
            );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_comingle_check', 'Unexpected error in comingle_check');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_comingle_check', 'Error in comingle_check');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

            -- Skip record if it would cause comingling
            IF l_comingle = 'Y' THEN
              IF l_debug = 1 THEN
                 log_event(l_api_name, 'comingle_putaway', 'Putaway to this location would comingle cost groups. ' || 'Using next record');
              END IF;
              IF l_debug_on THEN
                g_trace_recs(l_locs_index).cg_comingle_flag  := 'N';
              END IF;
               --
	       -- Patchset 'J' error_message
	       WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_COST_GROUP_COMINGLE' ;
              GOTO nextoutputrecord;
            END IF;

            IF l_debug_on THEN
              g_trace_recs(l_locs_index).cg_comingle_flag  := 'Y';
            END IF;
          END IF;

          -- Update locator capacity to reflect quantity we are putting
          -- away.  This API executes an autonomous commit.  Thus,
          -- if any sort of error occurs, we have to explicitly undo
          -- this update (we can't just do a rollback).
          IF (l_olocator_id IS NOT NULL) AND l_consider_staging_capacity THEN  --Added bug3237702
          --IF l_olocator_id IS NOT NULL THEN Commented bug3237702
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'update_capacity', 'Updating suggested capacity');
             END IF;
            inv_loc_wms_utils.update_loc_suggested_capacity(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_organization_id            => p_organization_id
            , p_inventory_location_id      => l_olocator_id
            , p_inventory_item_id          => p_inventory_item_id
            , p_primary_uom_flag           => 'Y'
            , p_transaction_uom_code       => NULL
            , p_quantity                   => l_possible_quantity
            );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_update_capacity', 'Unexpected error in update_loc_suggested_capacity');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_update_capacity', 'Error in update_loc_suggested_capacity');
              END IF;
              RAISE fnd_api.g_exc_error;
            ELSE
              l_capacity_updated  := TRUE;
            END IF;
          END IF;

          IF l_debug_on THEN
            g_trace_recs(l_locs_index).suggested_qty  := l_possible_quantity;
            g_trace_recs(l_locs_index).secondary_suggested_qty  := l_sec_possible_quantity;
          END IF;

          -- no detail for serial numbers
          -- get the transaction quantity
          IF p_transaction_uom = p_primary_uom THEN
            l_possible_trx_qty  := l_possible_quantity;
          ELSE
            l_possible_trx_qty  :=
                   inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_possible_quantity, p_primary_uom, p_transaction_uom, NULL, NULL);
          END IF;

          IF l_debug = 1 THEN
            log_statement(l_api_name, 'insert_put_wtt_recs', 'Before insert values of l_possible_trx_qty'|| l_possible_trx_qty);
            log_statement(l_api_name, 'insert_put_wtt_recs', 'Before insert values of l_possible_quantity'|| l_possible_quantity);
          END IF;

          IF l_debug = 1 THEN
             log_statement(l_api_name, 'insert_put_wtt_recs', 'Inserting putaway records in wtt');
          END IF;
          -- insert temporary suggestion
          INSERT INTO wms_transactions_temp
                      (
                      pp_transaction_temp_id
                    , transaction_temp_id
                    , type_code
                    , line_type_code
                    , transaction_quantity
                    , primary_quantity
                    , secondary_quantity
                    , grade_code
                    , revision
                    , lot_number
                    , lot_expiration_date
                    , from_subinventory_code
                    , from_locator_id
                    , rule_id
                    , reservation_id
                    , to_subinventory_code
                    , to_locator_id
                    , from_cost_group_id
                    , to_cost_group_id
                    , lpn_id
                      )
               VALUES (
                      wms_transactions_temp_s.NEXTVAL
                    , p_transaction_temp_id
                    , p_type_code
                    , 2 -- line type code is output
                    , l_possible_trx_qty
                    , l_possible_quantity
                    , l_sec_possible_quantity
                    , l_grade_code
                    , l_revision
                    , l_lot_number
                    , l_lot_expiration_date
                    , l_from_subinventory_code
                    , l_from_locator_id
                    , l_rule_id
                    , l_reservation_id
                    , l_osubinventory_code
                    , l_olocator_id
                    , l_from_cost_group_id
                    , l_to_cost_group_id
                    , l_input_lpn_id
                      );

          --
          l_capacity_updated  := FALSE;
          --END IF;

          IF l_debug = 1 THEN
             log_event(l_api_name, 'putaway_loc_found', 'Found put away location for quantity ' || l_possible_quantity);
          END IF;

          -- keep track of the remaining transaction quantity
          IF l_needed_quantity > l_possible_quantity THEN
            l_needed_quantity  := l_needed_quantity - l_possible_quantity;
            l_sec_needed_quantity  := l_sec_needed_quantity - l_sec_possible_quantity;
          ELSE
            l_needed_quantity  := 0;
            l_sec_needed_quantity  := 0;
            IF l_debug = 1 THEN
               log_event(l_api_name, 'finished_putaway', 'Found put away locations for all quantity in this input record');
            END IF;
          END IF;

          --
          <<nextoutputrecord>>
          EXIT WHEN l_needed_quantity = 0;
        END LOOP; -- output records
      END IF; -- type_code = 1

      -- finally close the rule cursor
      IF l_debug = 1 THEN
         log_statement(l_api_name, 'close_curs', 'Calling close_curs');
      END IF;

      -- Bug# 4738161: Close the putaway cursors after each line is allocated if necessary
      IF p_type_code = 1 THEN
         close_put_rule(l_rule_id, v_put_cursor);
      ELSE
         close_pick_rule(l_rule_id, v_pick_cursor);
      END IF;

      IF l_debug = 1 THEN
         log_statement(l_api_name, 'finish_close_curs', 'Finished close_curs');
      END IF;

      IF ((g_over_allocation = 'N'
         OR (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
         OR WMS_Engine_PVT.g_move_order_type <> 3 or p_type_code <> 2)
        AND (l_needed_quantity > 0 OR l_needed_quantity > l_max_tolerance)
       )
    OR
       (g_over_allocation = 'Y' AND NOT (p_type_code = 2 AND l_lot_divisible_flag = 'N' and l_lot_control_code <> 1)
        AND WMS_Engine_PVT.g_move_order_type = 3 and  p_type_code = 2
        AND ((l_max_tolerance >= 0 AND (l_needed_quantity > l_max_tolerance)
              AND (l_initial_pri_quantity - l_needed_quantity < WMS_RULE_PVT.g_min_qty_to_allocate))
             OR (l_max_tolerance < 0
                 AND l_initial_pri_quantity - l_needed_quantity < WMS_RULE_PVT.g_min_qty_to_allocate)
            )
       )
    THEN
        -- notice, that at least one input record couldn't get satisfied
        x_finished  := fnd_api.g_false;

        IF l_needed_quantity = l_initial_pri_quantity THEN
           -- Bug #3396532
           IF WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE IS NULL THEN
             WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_PUT_NO_ROWS';
           END IF;
           IF l_debug = 1 THEN
              log_event(l_api_name, 'no_success', 'Found no locations for this rule');
           END IF;
        ELSE
          IF l_debug = 1 THEN
             log_event(l_api_name, 'partial_success', 'Successfully allocated some of the transaction ' || 'quantity with this rule.');
          END IF;
        END IF;

        -- if partials are not allowed, exit after rolling back everything
        IF p_partial_success_allowed_flag = 'N' THEN
          -- restore qty tree
          IF l_debug = 1 THEN
             log_event(l_api_name, 'no_partials_allowed', 'Partial success is not allowed for this rule - rolling back');
          END IF;
          IF p_type_code = 2 THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'restore_tree', 'Calling restore_tree');
            END IF;
            inv_quantity_tree_pvt.restore_tree(x_return_status, p_tree_id);

	    /*Start of fix for Bug 5251221 */

	    OPEN l_get_serial;
	    LOOP
	    FETCH l_get_serial INTO l_serial_number;
                IF l_get_serial%NOTFOUND THEN
                   IF l_debug = 1 THEN
                      inv_log_util.trace('Serial not found', 'delete_serial_numbers', 9);
                   END IF;
  	           exit;
                ELSE
        	   IF (inv_detail_util_pvt.g_serial_tbl_ptr > 0) THEN
		       IF l_debug = 1 THEN
                          inv_log_util.trace('Org: ' || p_organization_id, 'delete_serial_numbers', 9);
	                  inv_log_util.trace('Item: ' || p_inventory_item_id, 'delete_serial_numbers', 9);
	                  inv_log_util.trace('Serial: ' || l_serial_number, 'delete_serial_numbers', 9);
			  inv_log_util.trace('inv_detail_util_pvt.g_serial_tbl_ptr ' || inv_detail_util_pvt.g_serial_tbl_ptr, 'delete_serial_numbers', 9);
                       END IF;

		       FOR i IN 1..inv_detail_util_pvt.g_serial_tbl_ptr LOOP
		           IF (inv_detail_util_pvt.g_output_serial_rows(i).inventory_item_id = p_inventory_item_id) AND
                              (inv_detail_util_pvt.g_output_serial_rows(i).organization_id   = p_organization_id)   AND
                              (inv_detail_util_pvt.g_output_serial_rows(i).serial_number     = l_serial_number) THEN

		      	      IF (inv_detail_util_pvt.g_serial_tbl_ptr > 1) THEN
                                  inv_detail_util_pvt.g_output_serial_rows(i).organization_id := inv_detail_util_pvt.g_output_serial_rows(inv_detail_util_pvt.g_serial_tbl_ptr).organization_id;
		                  inv_detail_util_pvt.g_output_serial_rows(i).inventory_item_id := inv_detail_util_pvt.g_output_serial_rows(inv_detail_util_pvt.g_serial_tbl_ptr).inventory_item_id;
			          inv_detail_util_pvt.g_output_serial_rows(i).serial_number := inv_detail_util_pvt.g_output_serial_rows(inv_detail_util_pvt.g_serial_tbl_ptr).serial_number;

			          inv_detail_util_pvt.g_output_serial_rows.DELETE(inv_detail_util_pvt.g_serial_tbl_ptr);
			          inv_detail_util_pvt.g_serial_tbl_ptr := inv_detail_util_pvt.g_serial_tbl_ptr-1;
			          IF l_debug = 1 THEN
				     inv_log_util.trace('inv_detail_util_pvt.g_serial_tbl_ptr ' || inv_detail_util_pvt.g_serial_tbl_ptr, 'delete_serial_numbers', 9);
			          END IF;

                              ELSE
			         inv_detail_util_pvt.g_output_serial_rows.delete;
				 inv_detail_util_pvt.g_serial_tbl_ptr := inv_detail_util_pvt.g_serial_tbl_ptr-1;
			         IF l_debug = 1 THEN
                                    inv_log_util.trace('Array cleared', 'delete_serial_numbers', 9);
			         END IF;

                              END IF;--End of IF (inv_detail_util_pvt.g_serial_tbl_ptr > 1)
			      exit; --if a serial has been deleted, needn't check other serials present in g_output_serial_rows
                          END IF; --End of  IF (inv_detail_util_pvt.g_output_serial_rows(i).inventory_item_id = p_inventory_item_id)
                        END LOOP; --End of FOR loop
                    END IF;--End of IF (inv_detail_util_pvt.g_serial_tbl_ptr > 0)
                END IF;-- End of IF l_get_serial%NOTFOUND
	    END LOOP;--End of LOOP for CURSOR
	    CLOSE l_get_serial;
	    /*End of fix for Bug 5251221 */


            --
            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_restore_tree', 'Unexpected error in restore_tree');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_restore_tree', 'Error in restore_tree');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE --for put away, restore capacity
            --this function reduces the suggested units in the location
            -- for each record inserted in wms_transaction_temp as a
            -- putaway output record
            rollback_capacity_update(
              x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_organization_id            => p_organization_id
            , p_inventory_item_id          => p_inventory_item_id
            );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'uerr_rollback_cap', 'Unexpected error in rollback_capacity_update');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'err_rollback_cap', 'Error in rollback_capacity_update');
              END IF;
              RAISE fnd_api.g_exc_error;
            END IF;

            --if error occurred after capacity got updated but before
            -- insertion into WTT, fix the capacity for that record
            IF l_capacity_updated THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'revert_capacity', 'Calling revert_loc_suggested_capacity');
              END IF;
              inv_loc_wms_utils.revert_loc_suggested_capacity(
                x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_organization_id            => p_organization_id
              , p_inventory_location_id      => l_olocator_id
              , p_inventory_item_id          => p_inventory_item_id
              , p_primary_uom_flag           => 'Y'
              , p_transaction_uom_code       => NULL
              , p_quantity                   => l_possible_quantity
              );

              IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'uerr_revert_capacity', 'Unexpected error in revert_loc_suggested_capacity');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'err_revert_capacity', 'Error in revert_loc_suggested_capacity');
                END IF;
                RAISE fnd_api.g_exc_error;
              END IF;

              l_capacity_updated  := FALSE;
            END IF;
          END IF;

          --needs to set the trace flag for partial pick to N.
          IF l_debug_on THEN
            --first record in g_trace_recs always at index 1
            l_cur_rec  := 1;

            LOOP
              EXIT WHEN NOT g_trace_recs.EXISTS(l_cur_rec);

              IF g_trace_recs(l_cur_rec).suggested_qty > 0 THEN
                g_trace_recs(l_cur_rec).suggested_qty      := 0;
                g_trace_recs(l_cur_rec).partial_pick_flag  := 'N';
              END IF;

              l_cur_rec  := l_cur_rec + 1;
            END LOOP;

            wms_search_order_globals_pvt.insert_trace_lines(
              p_api_version                => 1.0
            , p_init_msg_list              => fnd_api.g_false
            , p_validation_level           => fnd_api.g_valid_level_full
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_header_id                  => wms_engine_pvt.g_trace_header_id
            , p_rule_id                    => l_rule_id
            , p_pre_suggestions            => g_trace_recs
            );
          END IF;

          --
          ROLLBACK TO applyrulesp;
          EXIT;
        ELSE
          IF l_needed_quantity <> l_initial_pri_quantity THEN
            IF l_debug = 1 THEN
               log_statement(l_api_name, 'updating_input_rec', 'Updating the input line in WTT and pl/sql table');
            END IF;

            l_needed_quantity := l_needed_quantity - l_max_tolerance;
	    UPDATE wms_transactions_temp
               SET primary_quantity = l_needed_quantity
                ,  secondary_quantity = l_sec_needed_quantity
             WHERE pp_transaction_temp_id = l_pp_transaction_temp_id;

            wms_re_common_pvt.updateinputline(l_needed_quantity,l_sec_needed_quantity);
          END IF;
        END IF;
      ELSE
        x_finished  := fnd_api.g_true;
        -- if input line could get satisfied
        -- delete the input line in the wms_transactions_temp table
        IF l_debug = 1 THEN
           log_statement(l_api_name, 'deleting_input_rec', 'Deleting the input line in WTT and pl/sql table');
        END IF;

        DELETE FROM wms_transactions_temp
              WHERE pp_transaction_temp_id = l_pp_transaction_temp_id;

        --
        -- and delete input record in PL/SQL table, too
        wms_re_common_pvt.deleteinputline;

	 -- start of 8744417
 	          IF l_debug = 1 THEN
 	             log_statement(l_api_name, 'Wms_re_common_pvt.GetCountInputLines ' , Wms_re_common_pvt.GetCountInputLines  );
 	          END IF;
 	            If p_type_code = 1 and Wms_re_common_pvt.GetCountInputLines > 0
 	                          and x_finished = fnd_api.g_true  THEN
 	                                 x_finished  := fnd_api.g_false;
 	                     IF l_debug = 1 THEN
 	                       log_statement(l_api_name, 'After   x_finished :' ,  'False'   );
 	                     END IF;
 	           elsif  p_type_code = 1 and Wms_re_common_pvt.GetCountInputLines = 0
 	                          and x_finished  =    fnd_api.g_false then
 	                                 x_finished  := fnd_api.g_true;
 	             IF l_debug = 1 THEN
 	                log_statement(l_api_name, 'GetCountInputLines = 0 /    x_finished  :' ,  'True'   );
 	             END IF;
 	           end if;
 	 -- end of 8744417

      END IF;

      IF l_debug_on THEN
        wms_search_order_globals_pvt.insert_trace_lines(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_validation_level           => fnd_api.g_valid_level_full
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_header_id                  => wms_engine_pvt.g_trace_header_id
        , p_rule_id                    => l_rule_id
        , p_pre_suggestions            => g_trace_recs
        );
      END IF;

     <<NextINputRecord>>
     NULL;
    END LOOP; -- input records

    --
    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- end of debugging section
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End Apply');
    END IF;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --
      --if l_pack_exists <>2, then open_curs was never called, so no need to
      --   close the cursor
      IF (l_pack_exists = 2) THEN
        close_pick_rule(l_rule_id, v_pick_cursor);
      END IF;

      --this function reduces the suggested units in the location
      -- for each record inserted in wms_transaction_temp as a
      -- putaway output record
      rollback_capacity_update(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      );

      --if error occurred after capacity got updated but before
      -- insertion into WTT, fix the capacity for that record
      IF l_capacity_updated THEN
        inv_loc_wms_utils.revert_loc_suggested_capacity(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_organization_id
        , p_inventory_location_id      => l_olocator_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_primary_uom_flag           => 'Y'
        , p_transaction_uom_code       => NULL
        , p_quantity                   => l_possible_quantity
        );
        l_capacity_updated  := FALSE;
      END IF;

      ROLLBACK TO applyrulesp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Expected error - ' || x_msg_data);
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      --if l_pack_exists <>2, then open_curs was never called, so no need to
      --   close the cursor
      IF (l_pack_exists = 2) THEN
        close_put_rule(l_rule_id, v_put_cursor);
      END IF;

      --this function reduces the suggested units in the location
      -- for each record inserted in wms_transaction_temp as a
      -- putaway output record
      rollback_capacity_update(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      );

      --if error occurred after capacity got updated but before
      -- insertion into WTT, fix the capacity for that record
      IF l_capacity_updated THEN
        inv_loc_wms_utils.revert_loc_suggested_capacity(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_organization_id
        , p_inventory_location_id      => l_olocator_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_primary_uom_flag           => 'Y'
        , p_transaction_uom_code       => NULL
        , p_quantity                   => l_possible_quantity
        );
        l_capacity_updated  := FALSE;
      END IF;

      ROLLBACK TO applyrulesp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
      END IF;
    --
    WHEN OTHERS THEN
      --if l_pack_exists <>2, then open_curs was never called, so no need to
      --   close the cursor
      IF (l_pack_exists = 2) THEN
        close_put_rule(l_rule_id, v_put_cursor);
      END IF;

      --this function reduces the suggested units in the location
      -- for each record inserted in wms_transaction_temp as a
      -- putaway output record
      rollback_capacity_update(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      );

      --if error occurred after capacity got updated but before
      -- insertion into WTT, fix the capacity for that record
      IF l_capacity_updated THEN
        inv_loc_wms_utils.revert_loc_suggested_capacity(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_organization_id
        , p_inventory_location_id      => l_olocator_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_primary_uom_flag           => 'Y'
        , p_transaction_uom_code       => NULL
        , p_quantity                   => l_possible_quantity
        );
        l_capacity_updated  := FALSE;
      END IF;

      ROLLBACK TO applyrulesp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
      END IF;
  END apply;


  --
  -- --------------------------------------------------------------------------
  -- What does it do:
  -- Determines final location control based on location controls defined at
  -- organization, subinventory and item level.
  -- --------------------------------------------------------------------------
  --
  FUNCTION loc_control
    ( p_org_control      IN    NUMBER
     ,p_sub_control      IN    NUMBER
     ,p_item_control     IN    NUMBER DEFAULT NULL
     ,x_return_status    OUT   NOCOPY VARCHAR2
     ,x_msg_count        OUT   NOCOPY NUMBER
     ,x_msg_data         OUT   NOCOPY VARCHAR2
     ) RETURN NUMBER
    IS
        --
        -- constants
        l_api_name        CONSTANT VARCHAR(30) := 'loc_control';
        --
        -- return variable
        l_locator_control NUMBER;
        --
        -- exception
        invalid_loc_control_exception EXCEPTION;
        --
  BEGIN
     IF (p_org_control = 1) THEN
         l_locator_control := 1;
      ELSIF (p_org_control = 2) THEN
         l_locator_control := 2;
      ELSIF (p_org_control = 3) THEN
         l_locator_control := 2 ;
      ELSIF (p_org_control = 4) THEN
        IF (p_sub_control = 1) THEN
           l_locator_control := 1;
        ELSIF (p_sub_control = 2) THEN
           l_locator_control := 2;
        ELSIF (p_sub_control = 3) THEN
           l_locator_control := 2;
        ELSIF (p_sub_control = 5) THEN
          IF (p_item_control = 1) THEN
             l_locator_control := 1;
          ELSIF (p_item_control = 2) THEN
             l_locator_control := 2;
          ELSIF (p_item_control = 3) THEN
             l_locator_control := 2;
          ELSIF (p_item_control IS NULL) THEN
             l_locator_control := p_sub_control;
          ELSE
            RAISE invalid_loc_control_exception;
          END IF;
        ELSE
            RAISE invalid_loc_control_exception;
        END IF;
      ELSE
            RAISE invalid_loc_control_exception;
      END IF;
      --
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN l_locator_control;
  EXCEPTION
     WHEN invalid_loc_control_exception THEN
        fnd_message.set_name('INV','INV_INVALID_LOC_CONTROL');
        fnd_msg_pub.ADD;
        --
        x_return_status := fnd_api.g_ret_sts_error ;
        l_locator_control := -1 ;
        RETURN l_locator_control ;
        --
     WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error ;
        l_locator_control := -1 ;
        RETURN l_locator_control ;
        --
     WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error ;
          l_locator_control := -1 ;
          RETURN l_locator_control ;
          --
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        --
        IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        --
        l_locator_control := -1 ;
        RETURN l_locator_control ;
        --
  END loc_control;
  --
  -- --------------------------------------------------------------------------
  -- What does it do:
  -- Fetches default putaway sub/locations.
  -- they are retained as putaway sub/locations
  -- The following call will be used for Non WMS enabled org where default putaway rules
  -- are not used and If the input sub/loc are not null,
  -- This Procedure called from Applydef()
  -- --------------------------------------------------------------------------
  --
  PROCEDURE get_putaway_defaults
    ( p_organization_id           IN  NUMBER,
      p_inventory_item_id         IN  NUMBER,
      p_to_subinventory_code      IN  VARCHAR2,
      p_to_locator_id             IN  NUMBER,
      p_to_cost_group_id		IN  NUMBER,
      p_org_locator_control_code  IN  NUMBER,
      p_item_locator_control_code IN  NUMBER,
      p_transaction_type_id	IN  NUMBER,
      x_putaway_sub          	OUT NOCOPY VARCHAR2,
      x_putaway_loc          	OUT NOCOPY NUMBER,
      x_putaway_cost_group_id    	OUT NOCOPY NUMBER,
      x_return_status        	OUT NOCOPY VARCHAR2,
      x_msg_count            	OUT NOCOPY NUMBER,
      x_msg_data             	OUT NOCOPY VARCHAR2
     )
    IS
       -- constants
       l_api_name          CONSTANT VARCHAR(30) := 'get_putaway_defaults';
       l_return_status     VARCHAR2(1) :=  fnd_api.g_ret_sts_success;
       --
       -- variable
       l_sub_loc_control   NUMBER;
       l_loc_control       NUMBER;
       l_putaway_sub       VARCHAR2(30);
       l_putaway_loc       NUMBER;
       l_putaway_cg	 NUMBER := NULL;
       l_putaway_cg_org	 NUMBER;
       l_inventory_item_id NUMBER;
       l_organization_id   NUMBER;
       l_sub_status	 NUMBER;
       l_loc_status	 NUMBER;
       l_allowed		 VARCHAR2(1);
       l_primary_cost_method NUMBER;
       l_sub_found	 BOOLEAN;

       l_debug NUMBER;
       --
       CURSOR l_subinventory_code_csr IS
          SELECT  subinventory_code
            FROM  mtl_item_sub_defaults
            WHERE inventory_item_id = l_inventory_item_id
              AND organization_id   = l_organization_id
              AND default_type      = 3;  -- default transfer order sub

       CURSOR l_locator_status_csr IS
          SELECT  status_id
            FROM  mtl_item_locations
            WHERE inventory_location_id = l_putaway_loc
              AND organization_id  = l_organization_id ;
       --
       CURSOR l_locator_csr IS
          SELECT  locator_id
            FROM  mtl_item_loc_defaults mtld,
                  mtl_item_locations mil
            WHERE mtld.locator_id        = mil.inventory_location_id
              AND mtld.organization_id   = mil.organization_id
              AND mtld.inventory_item_id = l_inventory_item_id
              AND mtld.organization_id   = l_organization_id
              AND mtld.subinventory_code = l_putaway_sub
              AND mtld.default_type      = 3
              AND nvl(mil.disable_date,sysdate + 1) > sysdate;


  BEGIN
     l_organization_id   := p_organization_id;
     l_inventory_item_id := p_inventory_item_id;

     IF  g_debug IS NOT NULL  THEN
          g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;
     l_debug := g_debug;

     IF l_debug = 1  THEN
           log_procedure(l_api_name, 'start', 'Start get_putaway_defaults');
     END IF;

     -- search for default sub if to_sub in input row is null
     IF p_to_subinventory_code IS NULL THEN
        OPEN l_subinventory_code_csr;
        FETCH l_subinventory_code_csr INTO l_putaway_sub;
        IF l_subinventory_code_csr%notfound OR
       	   l_putaway_sub IS NULL  THEN
  	   CLOSE l_subinventory_code_csr;
           fnd_message.set_name('INV','INV_NO_DEFAULT_SUB');
  	   fnd_msg_pub.ADD;
  	   RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE l_subinventory_code_csr;
      ELSE
        l_putaway_sub := p_to_subinventory_code ;
     END IF;

     l_sub_found := INV_CACHE.set_tosub_rec(l_organization_id, l_putaway_sub);

     -- now get the locator control and then determine if
     -- default locator needs to be selected from item defaults
     --
    IF NOT l_sub_found THEN
        fnd_message.set_name('INV','INV_NO_SUB_LOC_CONTROL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
     END if;

     l_sub_loc_control := INV_CACHE.tosub_rec.locator_type;

     IF l_debug = 1  THEN
        log_statement(l_api_name, 'p_org_locator_control_code',  p_org_locator_control_code);
        log_statement(l_api_name, 'l_sub_loc_control '        ,  l_sub_loc_control);
        log_statement(l_api_name, 'p_item_locator_control_code'    ,  p_item_locator_control_code);
     END IF;

     -- find out the real locator control

     l_loc_control := loc_control
       ( p_org_locator_control_code
        ,l_sub_loc_control
        ,p_item_locator_control_code
        ,l_return_status
        ,x_msg_count
        ,x_msg_data);

     IF l_debug = 1  THEN
         log_statement(l_api_name, 'l_sub_loc_control ',  l_sub_loc_control);
         log_statement(l_api_name, 'l_loc_control '    ,  l_loc_control);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error ;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

    --
    IF l_loc_control = 2 THEN -- has locator control
        -- if no to_loc was supplied then get from defaults
        IF p_to_locator_id IS NULL THEN
           OPEN l_locator_csr;
           FETCH l_locator_csr INTO l_putaway_loc;
           IF l_locator_csr%notfound OR l_putaway_loc IS NULL THEN
              CLOSE l_locator_csr;
              fnd_message.set_name('INV','INV_NO_DEFAULT_LOC');
              fnd_msg_pub.ADD;

             RAISE fnd_api.g_exc_error;
           END IF;
         ELSE
           l_putaway_loc := p_to_locator_id ;
           IF l_debug = 1  THEN
	      log_statement(l_api_name, 'l_putaway_loc'    ,  l_putaway_loc);
            END IF;
        END IF;

     END IF;

     -- Now get the cost group.  If the to_cost_group is specified
     -- on the move order, then use that.  If not, query the default
     -- cost group for the subinventory if in a standard costing org.
     -- If not defined there, or if avg. costing org
     -- try to get the default cost group from the organization

     IF p_to_cost_group_id IS NULL THEN
        IF INV_CACHE.set_org_rec(l_organization_id) THEN
           l_primary_cost_method := INV_CACHE.org_rec.primary_cost_method;
           l_putaway_cg_org := INV_CACHE.org_rec.default_cost_group_id;
        ELSE
  	 l_primary_cost_method := 2;
  	 l_putaway_cg_org := NULL;
        End If;

        If l_primary_cost_method = 1 Then
  	 IF l_sub_found THEN
  	    l_putaway_cg := INV_CACHE.tosub_rec.default_cost_group_id;
           ELSE
  	    l_putaway_cg := NULL;
           end if;
        End If;

        If l_putaway_cg IS NULL Then
           l_putaway_cg := l_putaway_cg_org;
  	 if l_putaway_cg IS NULL then
              fnd_message.set_name('INV','INV_NO_DEFAULT_COST_GROUP');
  	    fnd_msg_pub.ADD;
  	    RAISE fnd_api.g_exc_error;
  	 end if;
        End If;
      ELSE
        l_putaway_cg := p_to_cost_group_id;
     END IF;

     x_putaway_sub 		:= l_putaway_sub;
     x_putaway_loc 		:= l_putaway_loc;
     x_putaway_cost_group_id 	:= l_putaway_cg;
     x_return_status 		:= l_return_status;
     /*
     IF l_putaway_loc is NULL THEN
        x_return_status   := 'N' ;
     END IF;
     */

     If l_debug = 1  THEN
        log_statement(l_api_name, 'Default Putaway values l_putaway_sub ', l_putaway_sub);
        log_statement(l_api_name, 'Default Putaway values l_putaway_loc ', l_putaway_loc);
        log_statement(l_api_name, 'Default Putaway values l_putaway_cg ',  l_putaway_cg);
        log_statement(l_api_name, 'Default Putaway values l_return_status ',  l_return_status);
     END IF;


  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error ;
          x_putaway_loc   := NULL;
          x_putaway_sub   := NULL;
          x_putaway_cost_group_id := NULL;
          --
     WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error ;
          x_putaway_loc   := NULL;
          x_putaway_sub   := NULL;
          x_putaway_cost_group_id := NULL;
          --
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
          x_putaway_loc   := NULL;
          x_putaway_sub   := NULL;
          x_putaway_cost_group_id := NULL;
          --
          IF (fnd_msg_pub.check_msg_level
              (fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
             fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
          END IF;
  --

END get_putaway_defaults ;
--
-- API name    : ApplyDefLoc
-- Type        : Private
-- Function    : Verifies a Putaway location with the given transaction
--               input parameters and creates recommendations
--               This API does not utlize the rules and should only be
--               called when the Inventory Locator is specified on
--               the input transaction and there is no requirement
--               to check capacity.
-- Pre-reqs    :
--
-- Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_commit               Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   p_transaction_temp_id  Identifier for the record in view
--                          wms_strategy_mat_txn_tmp_v that represents
--                          the request for detailing
--   p_organization_id      Organization identifier
--   p_inventory_item_id    Inventory item identifier
--   p_transaction_uom      Transaction UOM code
--   p_primary_uom          Primary UOM code
--   p_project_id           Project associated with transaction
--   p_task_id              Task associated with transaction
--
-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter
--   x_finished             whether the rule has found enough quantity to
--                          find a location that completely satisfy
--                          the requested quantity (value is 'Y' or 'N')
--
-- Version
--   Currently version is 1.0
--
-- Notes       : Calls API's of WMS_Common_PVT and INV_Quantity_Tree_PVT
--               This API must be called internally by
--               WMS_Strategy_PVT.Apply only !
--APPLY
PROCEDURE applydefloc(
   p_api_version                  IN   NUMBER   ,
   p_init_msg_list                IN   VARCHAR2 ,
   p_commit                       IN   VARCHAR2 ,
   p_validation_level             IN   NUMBER   ,
   x_return_status                OUT NOCOPY VARCHAR2 ,
   x_msg_count                    OUT NOCOPY NUMBER   ,
   x_msg_data                     OUT NOCOPY VARCHAR2 ,
   p_transaction_temp_id          IN   NUMBER   ,
   p_organization_id              IN   NUMBER   ,
   p_inventory_item_id            IN   NUMBER   ,
   p_subinventory_code            IN   VARCHAR2 ,
   p_locator_id                   IN   NUMBER   ,
   p_transaction_uom              IN   VARCHAR2 ,
   p_primary_uom                  IN   VARCHAR2 ,
   p_transaction_type_id          IN   NUMBER   ,
   x_finished                     OUT NOCOPY VARCHAR2 ,
   p_lpn_id                       IN   NUMBER   ,
   p_simulation_mode              IN   NUMBER   ,
   p_project_id                   IN   NUMBER   ,
   p_task_id                      IN   NUMBER
  )
  IS

  -- API standard variables
  l_api_version          constant number       := 1.0;
  l_api_name             constant varchar2(30) := 'ApplyDefLoc';
  -- variables needed for dynamic SQL
  l_cursor               integer;
  l_rows                 integer;
  -- rule dynamic SQL input variables
  l_pp_transaction_temp_id
                         WMS_TRANSACTIONS_TEMP.PP_TRANSACTION_TEMP_ID%TYPE;
  l_revision             WMS_TRANSACTIONS_TEMP.REVISION%TYPE;
  l_lot_number           WMS_TRANSACTIONS_TEMP.LOT_NUMBER%TYPE;
  l_lot_expiration_date  WMS_TRANSACTIONS_TEMP.LOT_EXPIRATION_DATE%TYPE;
  l_from_subinventory_code WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%TYPE;
  l_to_subinventory_code WMS_TRANSACTIONS_TEMP.TO_SUBINVENTORY_CODE%TYPE;
  l_from_locator_id      WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE;
  l_to_locator_id        WMS_TRANSACTIONS_TEMP.TO_LOCATOR_ID%TYPE;
  l_from_cost_group_id   WMS_TRANSACTIONS_TEMP.FROM_COST_GROUP_ID%TYPE;
  l_to_cost_group_id     WMS_TRANSACTIONS_TEMP.TO_COST_GROUP_ID%TYPE;
  l_lpn_id               WMS_TRANSACTIONS_TEMP.LPN_ID%TYPE;
  l_initial_pri_quantity WMS_TRANSACTIONS_TEMP.PRIMARY_QUANTITY%TYPE;
  -- rule dynamic SQL output variables
  l_osubinventory_code   WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%TYPE;
  l_olocator_id          WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE;
  l_olocator_id_prev     WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE;
  l_olocator_id_new      WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE;
  l_olocator_id_exist    WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE;
  l_possible_quantity    WMS_TRANSACTIONS_TEMP.PRIMARY_QUANTITY%TYPE;
  l_possible_trx_qty     WMS_TRANSACTIONS_TEMP.TRANSACTION_QUANTITY%TYPE;
  l_sec_possible_quantity    WMS_TRANSACTIONS_TEMP.PRIMARY_QUANTITY%TYPE;
  l_sec_possible_trx_qty     WMS_TRANSACTIONS_TEMP.TRANSACTION_QUANTITY%TYPE;
  l_reservation_id       WMS_TRANSACTIONS_TEMP.RESERVATION_ID%TYPE;
  l_grade_code           VARCHAR2(150);

  l_needed_quantity     NUMBER;
  l_sec_needed_quantity NUMBER;
  l_locs_index          NUMBER;
  l_return_status       VARCHAR2(1);
  l_allowed             VARCHAR2(1);
  l_debug_on            BOOLEAN;
  l_check_cg            BOOLEAN;
  l_lpn_controlled_flag NUMBER;
  l_comingle            VARCHAR2(1);
  l_dummy               NUMBER;

  --added to support pjm
  l_project_id          NUMBER;
  l_task_id             NUMBER;
  l_input_lpn_id        NUMBER;
  l_debug               NUMBER;
  l_serial_number       NUMBER; -- [ new code ]
  use_supplied_loc      BOOLEAN;

  l_locator_type        NUMBER;
  x_subinventory_code   WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%TYPE;
  x_locator_id          WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE;
  x_cost_group_id       WMS_TRANSACTIONS_TEMP.FROM_COST_GROUP_ID%TYPE;

   --cursor to get lpn controlled flag from subinventory
   CURSOR l_lpn_controlled IS
        SELECT lpn_controlled_flag
          FROM mtl_secondary_inventories
         WHERE organization_id = p_organization_id
           AND secondary_inventory_name = l_osubinventory_code;


BEGIN

  IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
     g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;
  l_debug := g_debug;

  If (l_debug = 1) then
    log_procedure(l_api_name, 'start', 'Start ApplyDefLoc');
  End if;
  -- end of debugging section

  -- Standard start of API savepoint
  SAVEPOINT ApplyRuleSP;
  --


  -- Standard call to check for call compatibility
  IF NOT fnd_api.compatible_api_call( l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name ) THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF fnd_api.to_boolean( p_init_msg_list ) THEN
    fnd_msg_pub.initialize;
  END IF;
  --
  -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  --
  -- Initialize functional return status to completed
  x_finished := fnd_api.g_true;
  --
  -- Validate input parameters and pre-requisites, if validation level
  -- requires this
  IF p_validation_level <> fnd_api.g_valid_level_none THEN
    IF p_transaction_temp_id IS NULL OR
       p_transaction_temp_id = fnd_api.g_miss_num  THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('WMS','WMS_TRX_REQ_LINE_ID_MISS');
        If (l_debug = 1) then
          log_error_msg(l_api_name, 'trx_req_line_id_missing');
        End if;
        fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;
    IF p_organization_id IS NULL OR
       p_organization_id = fnd_api.g_miss_num  THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('INV','INV_NO_ORG_INFORMATION');
        If (l_debug = 1) then
          log_error_msg(l_api_name, 'org_id_missing');
        End if;
        fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;
    IF p_inventory_item_id IS NULL OR
       p_inventory_item_id = fnd_api.g_miss_num  THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('INV','INV_ITEM_ID_REQUIRED');
        If (l_debug = 1) then
          log_error_msg(l_api_name, 'item_id_missing');
        End if;
        fnd_msg_pub.add;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;
  --inv_pp_debug.send_message_to_pipe('finished validations');

  --
  -- make sure, everything is clean
  FreeGlobals;
  wms_parameter_pvt.ClearCache;
  --
  g_trace_recs.DELETE;
  l_debug_on := IsRuleDebugOn(p_simulation_mode);

  if (l_debug = 1) then
    log_statement(l_api_name, 'input_proj', 'Project: ' || p_project_id);
    log_statement(l_api_name, 'input_task', 'Task: ' || p_task_id);
  End if;

  -- Initialize the pointer to the first trx detail input line
  wms_re_common_pvt.InitInputPointer;
  --
  If (l_debug = 1) then
    log_statement(l_api_name, 'start_input_loop',
       'Starting loop through input lines');
  End if;

  -- Set the output locator and Sub to the supplied parameters
  l_osubinventory_code := p_subinventory_code;
  l_olocator_id        := p_locator_id;

-- Loop through all the trx detail input lines
-- Bug # 4637357
 use_supplied_loc := TRUE;
 WHILE use_supplied_loc LOOP
    If (l_debug = 1) then
         log_statement(l_api_name, 'getting input line',
           'calling wms_re_common_pvt.GetNextInputLine to get input line');
    End if;

         --
         -- Get the next trx detail input line
         wms_re_common_pvt.GetNextInputLine ( l_pp_transaction_temp_id
                                             ,l_revision
                                             ,l_lot_number
                                             ,l_lot_expiration_date
                                             ,l_from_subinventory_code
                                             ,l_from_locator_id
                                             ,l_from_cost_group_id
                                             ,l_to_subinventory_code
                                             ,l_to_locator_id
                                             ,l_to_cost_group_id
                                             ,l_needed_quantity
                                             ,l_sec_needed_quantity
                                             ,l_grade_code
                                             ,l_reservation_id
                                             ,l_serial_number -- [ new code ]
                                             ,l_lpn_Id);
         EXIT WHEN l_pp_transaction_temp_id IS NULL;


         IF  ( p_subinventory_code is NULL  AND  p_locator_id is NULL ) THEN
                -- Set the output locator and Sub to the inlput line sub/loc
	        l_osubinventory_code := l_to_subinventory_code;
                l_olocator_id        := l_to_locator_id;

         END IF;


         If (l_debug = 1) then
           log_statement(l_api_name, 'input_rec', 'Got next input line');
           log_statement(l_api_name, 'input_rev', 'rev:' || l_revision);
           log_statement(l_api_name, 'input_lot', 'lot:' || l_lot_number);
           log_statement(l_api_name, 'input_sub', 'sub:' || l_from_subinventory_code);
           log_statement(l_api_name, 'input_loc', 'loc:' || l_from_locator_id);
           log_statement(l_api_name, 'input_cg',  'cg:'  || l_from_cost_group_id);
           log_statement(l_api_name, 'input_tsub','tsub:'|| l_to_subinventory_code);
           log_statement(l_api_name, 'input_tloc','tloc:'|| l_to_locator_id);
           log_statement(l_api_name, 'input_tcg', 'tcg:' || l_to_cost_group_id);
           log_statement(l_api_name, 'input_lpn', 'lpn:' || l_lpn_id);
           log_statement(l_api_name, 'input_qty', 'qty:' || l_needed_quantity);
           log_statement(l_api_name, 'input_sec_qty', 'sec qty:' || l_sec_needed_quantity);
     End if;
    --- Bug#4729564
    --- Populate default dest. loct for non-wms org if it is null and raise error if locator is null for dynamic loc controlled.

    get_putaway_defaults ( p_organization_id ,
  			   p_inventory_item_id,
  			   l_to_subinventory_code,
  			   l_to_locator_id,
  			   l_to_cost_group_id,
  			   inv_cache.org_rec.stock_locator_control_code,
  			   inv_cache.item_rec.location_control_code,
  			   p_transaction_type_id,
  			   x_subinventory_code ,
  			   x_locator_id,
  			   x_cost_group_id,
  			   x_return_status,
  			   x_msg_count,
  			   x_msg_data );

    -- log_statement(l_api_name, 'Default Putaway values l_return_status ',  l_return_status);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error ;
         -- log_statement(l_api_name, 'ApplyDef()', 'Dest Loct is NUll' );
         -- GOTO NextOutputRecord;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

   --log_statement(l_api_name, 'l_to_locator_id',nvl(l_to_locator_id, -9999) );
   IF  (l_osubinventory_code is NULL AND x_subinventory_code is not NULL ) then
       l_osubinventory_code := x_subinventory_code;
       If (l_debug = 1 ) then
          log_statement(l_api_name, 'Setting default SUB ',  l_osubinventory_code);
       End if;
   END IF;

   IF (l_olocator_id is NULL and x_locator_id is not NULL) THEN
       l_osubinventory_code := x_subinventory_code;
       l_olocator_id := x_locator_id;
       If (l_debug = 1 ) then
          log_statement(l_api_name, 'Setting default SUB / LOC ',  l_osubinventory_code);
          log_statement(l_api_name, 'Setting default LOC ',  l_olocator_id);
       End if;
   END IF;

   IF (l_to_cost_group_id is NULL and x_cost_group_id is NOT NULL ) THEN
       l_to_cost_group_id :=  x_cost_group_id;
   END IF;
   -- Bug 5682045 Changed l_to_locator_id to l_olocator_id
   IF l_olocator_id  is NULL THEN
      l_locator_type := NULL;

     -- log_statement(l_api_name, 'p_organization_id :', p_organization_id);
        log_statement(l_api_name, 'To check dynamic loc : l_to_subinventory_code', l_to_subinventory_code);

      select locator_type into l_locator_type
        from mtl_secondary_inventories
       where organization_id = p_organization_id
         and SECONDARY_INVENTORY_NAME  = l_to_subinventory_code;

      -- log_statement(l_api_name, 'l_locator_type' , l_locator_type);

      IF l_locator_type = 3 or l_locator_type = 2 THEN  -- Dynamic / Prespecified Loc Control
          If (l_debug = 1 ) then
            log_statement(l_api_name, 'Default Putaway values l_return_status ',  l_return_status);
            log_statement(l_api_name, 'ApplyDef()', 'Dest Loct is NUll / Go to Next record ' );
          End if;

         GOTO NextOutputRecord;
      END if;
  END IF;
  -- end of Bug#4729564
  --

  -- use_supplied_loc := TRUE;
  -- To support PJM, check project and task if supplied.
  -- Case 1) Project and Task not supplied do nothing
  --      2) Project and Task Supplied and current record has same
  --         project and task continue processing.
  --      3) Project and Task supplied, not in current record
  --         then create a new entry in MTL_ITEM_LOCATIONS with
  --         properties of current record but with require project and task
  --      <This assumes that the results are ordered by Project and Task>
  IF p_project_id IS NOT NULL THEN

      --bug 2400549 - for WIP backflush transfer putaway,
      --always use the locator specified on the move order line, even
      --if that locator is from common stock (not project)
      IF NOT(wms_engine_pvt.g_move_order_type = 7 and
         wms_engine_pvt.g_transaction_action_id = 2) THEN
        If (l_debug = 1) then
          log_statement(l_api_name, 'do_project2',
              'Calling do project check');
        End if;
        IF DoProjectCheck(l_return_status, l_olocator_id,
                  p_project_id, p_task_id, l_olocator_id_new, l_olocator_id_exist)
        THEN
          If (l_debug = 1) then
            log_statement(l_api_name, 'do_project_success',
              'Do project check returned new locator');
          End if;
          l_olocator_id_prev := l_olocator_id;
          l_olocator_id := l_olocator_id_new;
        ELSE
          -- Current locator does not have required project/task
          -- If it exists use it
          If l_olocator_id_exist IS NOT NULL THEN
             l_olocator_id := l_olocator_id_exist;
          ELSE
             use_supplied_loc := false;
             x_finished := fnd_api.g_false;
             If (l_debug = 1) then
               log_statement(l_api_name, 'do_project_fail',
                 'Do project check failed. Cannot use supplied locator with this Project and Task.');
             End if;
          End if;
        END IF; --do project check
      END IF;  -- not wip backflush
  END IF; -- needed project <> -9999


  --check status to see if putting away to this location is allowed
  -- for this transaction type
  -- This API checks the status for the subinventory, locator,
  -- and lot

  -- Pass in NULL for lot number as this was checked during Pick
  If (l_debug = 1) then
       log_statement(l_api_name, 'checking_status',
         'calling is_sub_loc_lot_trx_allowed to check status');
  End if;
  If g_transaction_type_id = p_transaction_type_id AND
     g_organization_id = p_organization_id AND
     g_inventory_item_id = p_inventory_item_id AND
     g_subinventory_code = l_osubinventory_code AND
     g_st_locator_id = l_olocator_id  THEN
     l_allowed := g_allowed;
  ELSE

     l_allowed := inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(
              p_transaction_type_id  => p_transaction_type_id
             ,p_organization_id      => p_organization_id
             ,p_inventory_item_id    => p_inventory_item_id
             ,p_subinventory_code    => l_osubinventory_code
             ,p_locator_id           => l_olocator_id
             ,p_lot_number           => NULL);


     -- When changing SUB value set lpn_controlled_flag to null
     IF (g_organization_id = p_organization_id) OR (g_subinventory_code <> l_osubinventory_code) THEN
        g_lpn_controlled_flag := NULL;
     END IF;

     g_transaction_type_id := p_transaction_type_id;
     g_organization_id := p_organization_id;
     g_inventory_item_id := p_inventory_item_id;
     g_subinventory_code := l_osubinventory_code;
     g_st_locator_id := l_olocator_id;
     g_allowed := l_allowed;
   END IF;

   IF l_allowed <> 'Y' THEN
      use_supplied_loc := false;
      x_finished := fnd_api.g_false;
      If (l_debug = 1) then
         log_event(l_api_name, 'bad_status',
             'This transaction type is not allowed by the status ' ||
             'for the subinventory, locator. ');
      GOTO NextOutputRecord; --added for bug8533610
      End if;
   END IF;

/* Commented and moved the following code above
   Check the tag  bug # 4637357

  -- Loop through all the trx detail input lines
  WHILE use_supplied_loc LOOP
     If (l_debug = 1) then
       log_statement(l_api_name, 'getting input line',
         'calling wms_re_common_pvt.GetNextInputLine to get input line');
     End if;

     --
     -- Get the next trx detail input line
     wms_re_common_pvt.GetNextInputLine ( l_pp_transaction_temp_id
                                         ,l_revision
                                         ,l_lot_number
                                         ,l_lot_expiration_date
                                         ,l_from_subinventory_code
                                         ,l_from_locator_id
                                         ,l_from_cost_group_id
                                         ,l_to_subinventory_code
                                         ,l_to_locator_id
                                         ,l_to_cost_group_id
                                         ,l_needed_quantity
                                         ,l_sec_needed_quantity
                                         ,l_grade_code
                                         ,l_reservation_id
                                         ,l_serial_number -- [ new code ]
                                         ,l_lpn_Id);
     EXIT WHEN l_pp_transaction_temp_id IS NULL;

     If (l_debug = 1) then
       log_statement(l_api_name, 'input_rec', 'Got next input line');
       log_statement(l_api_name, 'input_rev', 'rev:' || l_revision);
       log_statement(l_api_name, 'input_lot', 'lot:' || l_lot_number);
       log_statement(l_api_name, 'input_sub', 'sub:' || l_from_subinventory_code);
       log_statement(l_api_name, 'input_loc', 'loc:' || l_from_locator_id);
       log_statement(l_api_name, 'input_cg',  'cg:'  || l_from_cost_group_id);
       log_statement(l_api_name, 'input_tsub','tsub:'|| l_to_subinventory_code);
       log_statement(l_api_name, 'input_tloc','tloc:'|| l_to_locator_id);
       log_statement(l_api_name, 'input_tcg', 'tcg:' || l_to_cost_group_id);
       log_statement(l_api_name, 'input_lpn', 'lpn:' || l_lpn_id);
       log_statement(l_api_name, 'input_qty', 'qty:' || l_needed_quantity);
       log_statement(l_api_name, 'input_sec_qty', 'sec qty:' || l_sec_needed_quantity);
     End if;
*/
     -- Save the initial input qty for later usage
     l_initial_pri_quantity := l_needed_quantity;
     --
     l_input_lpn_id := l_lpn_id;

     l_locs_index := 0;

     IF l_debug_on THEN
          g_trace_recs(l_locs_index).revision := l_revision;
          g_trace_recs(l_locs_index).lot_number := l_lot_number;
          g_trace_recs(l_locs_index).lot_expiration_date := l_lot_expiration_date;
          g_trace_recs(l_locs_index).subinventory_code := l_osubinventory_code;
          g_trace_recs(l_locs_index).locator_id := l_olocator_id;
          g_trace_recs(l_locs_index).cost_group_id := l_to_cost_group_id;
          g_trace_recs(l_locs_index).uom_code := NULL;
          g_trace_recs(l_locs_index).lpn_id := l_input_lpn_id;
          g_trace_recs(l_locs_index).quantity := NULL;
          --init to 0, in case of error
          g_trace_recs(l_locs_index).suggested_qty := 0;
          g_trace_recs(l_locs_index).Material_status_flag := 'Y';

          log_statement(l_api_name, 'fetch_put_sub',
               'Subinventory: ' || l_osubinventory_code);
          log_statement(l_api_name, 'fetch_put_loc',
               'Locator: ' || l_olocator_id);
          log_statement(l_api_name, 'fetch_put_proj',
               'Project: ' || l_project_id);
          log_statement(l_api_name, 'fetch_put_task',
               'Task: ' || l_task_id);


     END IF;

     --Determine if putaway sub is LPN controlled.  If it is not,
     --then we need to check cost group commingling always;
     -- Check cost group if
     -- Cost group is not null AND
     -- (sub is not lpn controlled OR
     --  No lpn on move order line OR
     --  not a staging transfer)
     --Never suggest comingling of cost groups, unless we are
     -- putting away a LPN.
     --When putting away an LPN, we assume that user is putting away
     -- whole LPN, which means there will never be comingling.
     --bug 1570597 - staging transfers are always put away in an LPN,
     -- so we don't need to check for comingling.
     --bug 2161565 - need to check for cg commingling if
     -- to subinventory is not LPN controlled.
     --bug 2492526 - putting away to a project controlled locator
     -- will always change the CG.  So no need to worry about CG
     -- commingling if the dest. loc is project controlled.
     If (l_debug = 1) then
       log_statement(l_api_name, 'Check LPN Controlled',
         'Check if cost group or project supplied and lpn controlled');
     End if;
     IF l_to_cost_group_id IS NULL THEN
        l_check_cg := FALSE;
     ELSIF l_project_id IS NOT NULL THEN
        l_check_cg := FALSE;
     ELSIF (p_lpn_id IS NOT NULL OR
        p_transaction_type_id IN (52,53)) THEN

        If (nvl(g_subinventory_code,'-9999') <> l_osubinventory_code OR
             g_lpn_controlled_flag IS NULL) THEN
           OPEN l_lpn_controlled;
           FETCH l_lpn_controlled INTO g_lpn_controlled_flag;
           g_subinventory_code := l_osubinventory_code;

           -- by default, assume sub is lpn controlled
           If l_lpn_controlled%notfound OR
             g_lpn_controlled_flag IS NULL OR
             g_lpn_controlled_flag NOT IN (1,2) Then
                g_lpn_controlled_flag := 1;
           End If;
           CLOSE l_lpn_controlled;
        End If;
        l_lpn_controlled_flag := g_lpn_controlled_flag;

        If (l_debug = 1) then
           log_statement(l_api_name, 'Check LPN Controlled',
            'lpn_control_flag : ' || l_lpn_controlled_flag);
        End if;

        If l_lpn_controlled_flag = 1 Then
           l_check_cg := FALSE;
        Else
           l_check_cg := TRUE;
        End If;
     ELSE
        l_check_cg := TRUE;
     END IF;
     --Check to see if putaway would comingle cost groups.
     IF l_check_cg THEN
        If (l_debug = 1) then
          log_statement(l_api_name, 'Check comingling',
             'calling inv_comingling_utils.comingle_check');
        End if;
        inv_comingling_utils.comingle_check(
              x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data  => x_msg_data
             ,x_comingling_occurs => l_comingle
             ,x_count     => l_dummy
             ,p_organization_id => p_organization_id
             ,p_inventory_item_id => p_inventory_item_id
             ,p_revision => l_revision
             ,p_lot_number => l_lot_number
             ,p_subinventory_code => l_osubinventory_code
             ,p_locator_id => l_olocator_id
             ,p_lpn_id => NULL
             ,p_cost_group_id => l_to_cost_group_id
          );
        if x_return_status = fnd_api.g_ret_sts_unexp_error then
          If (l_debug = 1) then
            log_statement(l_api_name, 'uerr_comingle_check',
              'Unexpected error in comingle_check');
          End if;
          RAISE fnd_api.g_exc_unexpected_error;
        elsif x_return_status = fnd_api.g_ret_sts_error then
          If (l_debug = 1) then
            log_statement(l_api_name, 'err_comingle_check',
              'Error in comingle_check');
          End if;
          RAISE fnd_api.g_exc_error;
        end if;

        -- Skip record if it would cause comingling
        if l_comingle = 'Y' then
          If (l_debug = 1) then
            log_event(l_api_name, 'comingle_putaway',
              'Putaway to this location would comingle cost groups. ');
          End if;
          if l_debug_on then
             g_trace_recs(l_locs_index).CG_comingle_flag := 'N';
          end if;
          GOTO NextOutputRecord;
        end if;

        if l_debug_on then
             g_trace_recs(l_locs_index).CG_comingle_flag := 'Y';
        end if;

     END IF;

     l_possible_quantity := l_needed_quantity;
     l_sec_possible_quantity := l_sec_needed_quantity;

     IF l_debug_on THEN
        g_trace_recs(l_locs_index).suggested_qty := l_possible_quantity;
     END IF;

     -- get the transaction quantity
     IF p_transaction_uom = p_primary_uom THEN
        l_possible_trx_qty := l_possible_quantity;
      ELSE
        l_possible_trx_qty :=
             inv_convert.inv_um_convert(
                                        p_inventory_item_id
                                        ,NULL
                                        ,l_possible_quantity
                                        ,p_primary_uom
                                        ,p_transaction_uom
                                        ,NULL
                                        ,NULL);
     END IF;
     l_sec_possible_trx_qty := l_sec_possible_quantity;
     If (l_debug = 1) then
        log_statement(l_api_name, 'insert_put_wtt_recs',
         'Inserting putaway records in wtt');
     End if;
     -- insert temporary suggestion
     INSERT
       INTO WMS_TRANSACTIONS_TEMP
       ( PP_TRANSACTION_TEMP_ID
        ,TRANSACTION_TEMP_ID
        ,TYPE_CODE
        ,LINE_TYPE_CODE
        ,TRANSACTION_QUANTITY
        ,PRIMARY_QUANTITY
        ,SECONDARY_QUANTITY
        ,GRADE_CODE
        ,REVISION
        ,LOT_NUMBER
        ,LOT_EXPIRATION_DATE
        ,FROM_SUBINVENTORY_CODE
        ,FROM_LOCATOR_ID
        ,RULE_ID
        ,RESERVATION_ID
        ,TO_SUBINVENTORY_CODE
        ,TO_LOCATOR_ID
        ,FROM_COST_GROUP_ID
        ,TO_COST_GROUP_ID
        ,LPN_ID
        ) VALUES
       ( wms_transactions_temp_s.NEXTVAL
        ,p_transaction_temp_id
        ,1      -- p_type_code
        ,2             -- line type code is output
        ,l_possible_trx_qty
        ,l_possible_quantity
        ,l_sec_possible_quantity
        ,l_grade_code
        ,l_revision
        ,l_lot_number
        ,l_lot_expiration_date
        ,l_from_subinventory_code
        ,l_from_locator_id
        ,NULL   -- l_rule_id
        ,l_reservation_id
        ,l_osubinventory_code
        ,l_olocator_id
        ,l_from_cost_group_id
        ,l_to_cost_group_id
        ,l_input_lpn_id
         );

     If (l_debug = 1) then
       log_event(l_api_name, 'putaway_loc_found',
          'Found put away location for quantity ' || l_possible_quantity);
     End if;

     l_needed_quantity := 0;

     <<NextOutputRecord>>



     -- if input line couldn't get satisfied ...
     IF l_needed_quantity > 0 THEN
         -- notice, that at least one input record couldn't get satisfied
         x_finished := fnd_api.g_false;
         If (l_debug = 1) then
           log_event(l_api_name, 'no_success',
               'Locator supplied could not be used');
         End if;

     ELSE
         x_finished := fnd_api.g_true;
         -- if input line could get satisfied
         -- delete the input line in the wms_transactions_temp table
         If (l_debug = 1) then
          log_statement(l_api_name, 'deleting_input_rec',
              'Deleting the input line in WTT and pl/sql table');
         End if;
         DELETE
           FROM WMS_TRANSACTIONS_TEMP
           WHERE pp_transaction_temp_id = l_pp_transaction_temp_id;
         --
         -- and delete input record in PL/SQL table, too
         wms_re_common_pvt.DeleteInputLine;
     END IF;
     IF l_debug_on THEN
        wms_search_order_globals_pvt.insert_trace_lines(
           p_api_version => 1.0
          ,p_init_msg_list => fnd_api.g_false
          ,p_validation_level => fnd_api.g_valid_level_full
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_header_id => wms_engine_pvt.g_trace_header_id
          ,p_rule_id => null
          ,p_pre_suggestions => g_trace_recs
         );
     END IF;

  END LOOP;         -- input records
  --
  -- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit) THEN
     COMMIT WORK;
  END IF;
  --
  If (l_debug = 1) then
    log_procedure(l_api_name, 'end', 'End Apply');
  End if;
  l_debug := NULL;
  --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN

    ROLLBACK TO ApplyRuleSP;
    FreeGlobals;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                               ,p_data  => x_msg_data );
    If (l_debug = 1) then
      log_error(l_api_name, 'error', 'Expected error - ' || x_msg_data);
    End if;
    l_debug := NULL;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO ApplyRuleSP;
    FreeGlobals;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );
    If (l_debug = 1) then
      log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
    End if;
    l_debug := NULL;
   --
   WHEN OTHERS THEN

    ROLLBACK TO ApplyRuleSP;
    FreeGlobals;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                               ,p_data  => x_msg_data );
    If (l_debug = 1) then
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
    End if;
    l_debug := NULL;

END applydefloc;



  --
  --
  -- API name    : CheckSyntax
  -- Type        : Private
  -- Function    : This wrapper on Generate_Rule_Package is
  --     called from the WMS_RULES form
  -- Pre-reqs    : one record in WMS_RULES_B uniquely identified by parameter
  --                p_rule_id
  -- Input Parameters  :
  --   p_api_version       Standard Input Parameter
  --   p_init_msg_list     Standard Input Parameter
  --   p_validation_level  Standard Input Parameter
  --   p_rule_id           Identifier of the rule to check
  --
  -- Output Parameters  :
  --   x_return_status     Standard Output Parameter
  --   x_msg_count         Standard Output Parameter
  --   x_msg_data          Standard Output Parameter
  --
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       : calls API's of WMS_RE_Common_PVT
  --
  PROCEDURE checksyntax(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2
  , p_validation_level IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_rule_id          IN            NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- API standard variables
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CheckSyntax';
  --
  --
  BEGIN
     --
    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    generaterulepackage(p_api_version, p_init_msg_list, p_validation_level, x_return_status, x_msg_count, x_msg_data, p_rule_id);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --
    WHEN OTHERS THEN
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  --
  END checksyntax;

  --
  -- API name    : Find_Rule
  -- Type        : Private
  -- Function    : find a rule by id
  -- Input Parameters  :
  --   p_api_version     Standard Input Parameter
  --   p_init_msg_list   Standard Input Parameter
  --   p_rule_id         Identifier of the rule
  --
  -- Output Parameters:
  --   x_return_status   Standard Output Parameter
  --   x_msg_count       Standard Output Parameter
  --   x_msg_data        Standard Output Parameter
  --   x_found           true if found ; else false
  --   x_rule_rec        info of the rule if found

  -- Version     :
  --   Current version 1.0
  --
  -- Notes       : calls API's of WMS_RE_Common_PVT
  --
  PROCEDURE find_rule(
    p_api_version   IN            NUMBER
  , p_init_msg_list IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_rule_id       IN            NUMBER
  , x_found         OUT NOCOPY    BOOLEAN
  , x_rule_rec      OUT NOCOPY    rule_rec
  ) IS
    -- API standard variables
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'Find_Rule';

    --
    CURSOR l_cur IS
      SELECT rule_id
           , organization_id
           , type_code
           , NAME
           , description
           , qty_function_parameter_id
           , enabled_flag
           , user_defined_flag
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
        FROM wms_rules_vl
       WHERE rule_id = p_rule_id;

    --
    l_rule_rec             rule_rec;
  BEGIN
    OPEN l_cur;
    FETCH l_cur INTO l_rule_rec;

    --
    IF l_cur%NOTFOUND THEN
      x_found  := FALSE;
    ELSE
      x_found     := TRUE;
      x_rule_rec  := l_rule_rec;
    END IF;

    CLOSE l_cur;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  --
  END find_rule;

  --GetPackageName
  --
  --This function establishes the naming standard for the rule packages.
  --Currently, the naming standard is WMS_RULE_## , where ## is rule id
  PROCEDURE getpackagename(p_rule_id IN NUMBER, x_package_name OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_package_name  := 'WMS_RULE_' || p_rule_id;
  END getpackagename;

  -- InitBuildPackage
  --    Called from GenerateRulePackage. Initializes
  -- the global variables needed to dynamically build the
  -- rule package.
  PROCEDURE initbuildpackage IS
  BEGIN
    g_build_package_row  := 0;
    g_build_package_tbl.DELETE;
  END initbuildpackage;

  --Build Package
  --This API takes a VARCHAR of undetermined length
  -- and breaks it up into varchars of length 255.  These
  -- smaller strings are stored in the g_build_package_tbl,
  -- and compose the sql statement to create the
  -- Rules package.
  PROCEDURE buildpackage(p_package_string IN VARCHAR2) IS
    l_cur_start      NUMBER;
    l_package_length NUMBER;
    l_num_chars      NUMBER := 255;
    l_row            NUMBER;
  BEGIN
    l_cur_start          := 1;
    -- get last filled row of table
    l_row                := g_build_package_row;
    l_package_length     := LENGTH(p_package_string);
    inv_log_util.trace( l_package_length ,'l_package_length' , 9);
    inv_log_util.trace( p_package_string ,'p_package_string' , 9);
    -- return if string is null
    IF l_package_length IS NULL
       OR l_package_length = 0 THEN
      RETURN;
    END IF;

    --Loop through string, reading off l_num_chars bytes at a time
    LOOP
      --When at end of varchar, exit loop;
      EXIT WHEN l_cur_start > l_package_length;
      l_row                       := l_row + 1;
      --Get substring from package_string
      g_build_package_tbl(l_row)  := SUBSTR(p_package_string, l_cur_start, l_num_chars);
      --Call build package to add row
      -- We may need to call this API for AOL standards.
      --ad_ddl.build_package(l_cur_string, l_row);

      --increment pointers
      l_cur_start                 := l_cur_start + l_num_chars;

      IF l_cur_start + l_num_chars > l_package_length THEN
        l_num_chars  := l_package_length - l_cur_start + 1;
      END IF;
    END LOOP;

    g_build_package_row  := l_row;
  END buildpackage;

  --CreatePackage
  -- This API calls dynamic SQL to build the package
  -- currently sitting in the g_build_package_tbl.
  --   p_package_body = TRUE if the package to be created is a body
  PROCEDURE createpackage(x_return_status OUT NOCOPY VARCHAR2, p_package_name IN VARCHAR2, p_package_body IN BOOLEAN) IS
    l_schema     VARCHAR2(30);
    l_status     VARCHAR2(1);
    l_industry   VARCHAR2(1);
    l_comp_error VARCHAR2(40);
    l_return     BOOLEAN;
    l_cursor     INTEGER;
    l_error      VARCHAR2(10);

    CURSOR c_package_status IS
      SELECT status
      FROM   user_objects
      WHERE  object_name = UPPER(p_package_name)
      AND    object_type='PACKAGE'
      AND    status <> 'VALID'
      AND    rownum = 1;

    CURSOR c_package_body_status IS
      SELECT status
      FROM   user_objects
      WHERE  object_name = UPPER(p_package_name)
      AND    object_type = 'PACKAGE BODY'
      AND    status <> 'VALID'
      AND    rownum = 1;

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_unexp_error;
    --open cursor
    l_cursor         := DBMS_SQL.open_cursor;
    --parse cursor
    DBMS_SQL.parse(l_cursor, g_build_package_tbl, 1, g_build_package_row, FALSE, DBMS_SQL.native);
    --close cursor
    DBMS_SQL.close_cursor(l_cursor);

    /* We may need to call this API for AOL standards
       --get schema info
       l_return := fnd_installation.get_app_info(
       application_short_name => 'FND'
      ,status => l_status
      ,industry => l_industry
      ,oracle_schema => l_schema
           );
       IF l_return = FALSE THEN
      RAISE fnd_api.g_exc_error;
       END IF;

       --Call create package
       ad_ddl.create_plsql_object(
      applsys_schema => l_schema
           ,application_short_name => 'WMS'
           ,object_name => p_package_name
           ,lb      => 1
           ,ub      => g_build_package_row
           ,insert_newlines => 'FALSE'
           ,comp_error => l_comp_error
           );

       IF l_comp_error = 'TRUE' THEN
      RAISE fnd_api.g_exc_error;
       END IF;
    */
       --Check status, return error if package that was created
       --  is invalid
    IF p_package_body THEN
      OPEN c_package_body_status;
      FETCH c_package_body_status INTO l_error;

      IF c_package_body_status%FOUND THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ELSE
        x_return_status  := fnd_api.g_ret_sts_success;
      END IF;

      CLOSE c_package_body_status;
    ELSE
      OPEN c_package_status;
      FETCH c_package_status INTO l_error;

      IF c_package_status%FOUND THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ELSE
        x_return_status  := fnd_api.g_ret_sts_success;
      END IF;

      CLOSE c_package_status;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END createpackage;

  -- API name    : GenerateRulePackage
  -- Type        : Private
  -- Function    : generate a package for a rule that can be used in
  --      picking and put away
  -- Input Parameters  :
  --   p_api_version     Standard Input Parameter
  --   p_init_msg_list   Standard Input Parameter
  --   p_validation_level Standard Input Parameter
  --   p_rule_id         Identifier of the rule
  --
  -- Output Parameters:
  --   x_return_status   Standard Output Parameter
  --   x_msg_count       Standard Output Parameter
  --   x_msg_data        Standard Output Parameter
  --
  --  Called by the WMS Rules form (WMSRULEF.fmb), this function
  --  creates a package for the given rule.  The package has three
  --  functions, open_curs, fetch_one_row, and close_curs.  Open_curs
  --  opens the cursor used by picking/put away to find locations for
  --  transactions.  Fetch_one_row returns the next set of results from
  --  the cursor. Close_curs closes the cursor.  Much of this function is
  --  devoted to building the necessary cursors.  For picking, there are
  --  three cursors - one for detailing serials, one for serial controlled
  --  items when not detailing, and one for non-serial items.
  --  For put away, task type, label, and cost group rules,
  --  there is only one cursor



  PROCEDURE generaterulepackage(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2
  , p_validation_level IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_rule_id          IN            NUMBER
  ) IS
    -- API standard variables
    l_api_version CONSTANT NUMBER                                              := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                                        := 'GenerateRulePackage';
    --
    -- variables needed for dynamic SQL
    l_cursor               INTEGER;
    l_rows                 INTEGER;
    --
    -- rule dynamic SQL output variables
    l_revision             wms_transactions_temp.revision%TYPE;
    l_lot_number           wms_transactions_temp.lot_number%TYPE;
    l_lot_expiration_date  wms_transactions_temp.lot_expiration_date%TYPE;
    l_subinventory_code    wms_transactions_temp.from_subinventory_code%TYPE;
    l_locator_id           wms_transactions_temp.from_locator_id%TYPE;
    l_cost_group_id        wms_transactions_temp.from_cost_group_id%TYPE;
    l_possible_quantity    wms_transactions_temp.primary_quantity%TYPE;
    --
    -- other variables
    l_type_code            wms_rules_b.type_code%TYPE;
    l_package_name         VARCHAR2(128);
    l_pack_sql             VARCHAR2(32000);
    l_pack_body_sql        VARCHAR2(32000);
    --
    l_subinventory_where   VARCHAR2(100);
    l_locator_where        VARCHAR2(100);
    l_stmt                 LONG;
    l_allocation_mode_id   NUMBER;

    l_rest_sql             VARCHAR2(32000);
    -- cursor for validation of input parameters and pre-requisites
    CURSOR rule IS
      SELECT type_code
           , allocation_mode_id
        FROM wms_rules_b mpr
       WHERE mpr.rule_id = p_rule_id;
  --
  BEGIN
     --
    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    log_procedure(l_api_name, 'start', 'Start GenerateRulePackage');

    -- end of debugging section
    --
    -- Validate input parameter, if validation level requires this
    IF p_validation_level <> fnd_api.g_valid_level_none THEN
      IF p_rule_id IS NULL
         OR p_rule_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_RULE_ID_MISSING');
          log_error_msg(l_api_name, 'rule_id_missing');
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --
    -- Get type code of the rule
    OPEN rule;
    FETCH rule INTO l_type_code, l_allocation_mode_id;

    IF rule%NOTFOUND THEN
      CLOSE rule;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE rule;
    --

    -- clean up the global variables holding dynamic SQL text
    freeglobals;

    --

    /* For Task type rule (TTA) and label rule, calculate initial rule weight*/
    --  We don't want to pre-calculate rule weight any more, because
    --  of the uniqueness check on rule weight
    /*
    IF l_type_code = 3 OR l_type_code = 4 THEN
       calcRuleWeight(p_rule_id);
    END IF;
    */



    --For pick and put away rules, build the Base and Input portions
    -- of the SQL statement.  Not used in task type, label, and cost group
    -- rules
    IF l_type_code = 1
       OR l_type_code = 2 THEN
      -- Build the base part of the SQL statement
      buildbasesql(x_return_status, x_msg_count, x_msg_data, l_type_code, l_allocation_mode_id);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- Build the input parameter dependent part of the SQL statement
      buildinputsql(x_return_status, x_msg_count, x_msg_data, l_type_code);

      --
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Build the rule dependent part of the SQL statement.
    -- Happens for rules of all type
    buildrulesql(x_return_status, x_msg_count, x_msg_data, p_rule_id, l_type_code, l_allocation_mode_id);

    --
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --


    --inv_pp_debug.send_long_to_pipe(g_base_from_serial);

    --build the sql portion of the cursor for lot-controlled items
    IF (l_type_code = 2) THEN --pick only
      g_stmt_serial         :=    'select '
                               || g_base_select
                               || g_rule_select_serial
                               || ' from '
                               || g_rule_from
                               || g_base_from_serial
                               || ' where '
                               || g_input_where
                               || g_rule_where
                               || ' group by '
                               || g_base_group_by
                               || g_rule_group_by;

      g_stmt_serial_validate :=    'select '
                               || g_base_select
                               || g_rule_select_serial
                               || ' from '
                               || g_rule_from
                               || g_base_from_serial_v
                               || ' where '
                               || g_input_where
                               || g_rule_where
                               || ' group by '
                               || g_base_group_by
                               || g_rule_group_by;

      g_stmt_serial_detail  :=    'select '
                               || g_base_select
                               || g_rule_select
                               || ' from '
                               || g_rule_from
                               || g_base_from_serial
                               || ' where '
                               || g_input_where
                               || g_rule_where;

     g_stmt_serial_detail_new  :=    'select '
                               || g_base_select
                               || g_rule_select
                               || ' from '
                               || g_rule_from
                               || g_base_from_serial_detail
                               || ' where '
                               || g_input_where
                               || g_rule_where;

      IF g_rule_order IS NOT NULL THEN
        g_stmt_serial           := g_stmt_serial || ' order by ' || g_rule_order;
        g_stmt_serial_validate  := g_stmt_serial_validate || ' order by ' || g_rule_order;
        g_stmt_serial_detail    := g_stmt_serial_detail || ' order by ' || g_rule_order;
        g_stmt_serial_detail_new := g_stmt_serial_detail_new || ' order by ' || g_rule_order;
      END IF;
    --    inv_pp_debug.send_long_to_pipe(g_stmt_serial);
    --    inv_pp_debug.send_long_to_pipe(g_stmt_serial_detail);

    ELSE
      --if not pick, we don't need these cursors, so we set them to
      -- dummy values.  Used only so package will compile.
      g_stmt_serial          := 'select 1,1,sysdate,1,1,1,1,1,1,1,1,1 from dual';
      g_stmt_serial_validate := 'select 1,1,sysdate,1,1,1,1,1,1,1,1,1 from dual';
      g_stmt_serial_detail   := 'select 1,1,sysdate,1,1,1,1,1,1,1,1,1 from dual';
      g_stmt_serial_detail_new   := 'select 1,1,sysdate,1,1,1,1,1,1,1,1,1 from dual';
    END IF;

    --get the package name
    getpackagename(p_rule_id, l_package_name);
    -- Initialize the global variables needed to build package
    initbuildpackage;

    -- Generate Package for Label Rules
    IF (l_type_code = 4) THEN
      g_stmt           :=    'select count(*) '
                          || '  from '
                          || NVL(g_rule_from, 'WMS_LABEL_REQUESTS wlr')
                          || ' where wlr.label_request_id = p_label_request_id '
                          || g_rule_where;
      --assemble create package statement
      l_pack_sql       :=
             'CREATE OR REPLACE PACKAGE '
          || l_package_name
          || ' AS
                   procedure Get_label_format (
                   p_label_request_id           IN NUMBER,
                   x_return_status              OUT NOCOPY NUMBER);

                end '
          || l_package_name
          || ';';
      --inv_pp_debug.send_long_to_pipe(l_pack_sql);
      --open cursor
      --l_cursor := dbms_sql.open_cursor;
      --parse cursor
      --dbms_sql.parse(l_cursor, l_pack_sql, dbms_sql.native);
      --close cursor
      --dbms_sql.close_cursor(l_cursor);
      buildpackage(l_pack_sql);
      --create the package spec
      createpackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --re initialize global variables
      initbuildpackage;
      --inv_pp_debug.send_long_to_pipe(g_stmt);

      --assemble the dynamic package creation statment
      l_pack_body_sql  :=
             'CREATE OR REPLACE PACKAGE BODY '
          || l_package_name
          || ' AS
     PROCEDURE Get_Label_Format (
        p_label_request_id        IN NUMBER,
        x_return_status           OUT NOCOPY NUMBER) IS

        CURSOR get_label_rule_curs IS
     ';
      buildpackage(l_pack_body_sql);
      buildpackage(g_stmt);
      l_pack_body_sql  :=
             ';

  BEGIN
           x_return_status := 0;
           OPEN get_label_rule_curs;
           FETCH get_label_rule_curs into x_return_status;
           CLOSE get_label_rule_curs;

        END Get_Label_Format;

   END '
          || l_package_name
          || ';';
    ELSIF (l_type_code = 7) THEN
      -- Generate package for Operation Plan Rules
      g_stmt           :=    'select count(*) '
                          || '  from '
                          || NVL(g_rule_from, 'MTL_MATERIAL_TRANSACTIONS_TEMP mmtt')
                          || ' where mmtt.transaction_temp_id = p_pp_transaction_temp_id '
                          || g_rule_where;
      --assemble create package statement
      l_pack_sql       :=
             'CREATE OR REPLACE PACKAGE '
          || l_package_name
          || ' AS
                    procedure Get_OP (
                    p_pp_transaction_temp_id     IN NUMBER,
                    x_return_status              OUT NOCOPY NUMBER);

 end '
          || l_package_name
          || ';';
      --inv_pp_debug.send_long_to_pipe(l_pack_sql);
      --open cursor
      --l_cursor := dbms_sql.open_cursor;
      --parse cursor
      --dbms_sql.parse(l_cursor, l_pack_sql, dbms_sql.native);
      --close cursor
      --dbms_sql.close_cursor(l_cursor);
      buildpackage(l_pack_sql);
      createpackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      initbuildpackage;
      --inv_pp_debug.send_long_to_pipe(g_stmt);

      --assemble the dynamic package creation statment
      l_pack_body_sql  :=
             'CREATE OR REPLACE PACKAGE BODY '
          || l_package_name
          || ' AS
      PROCEDURE Get_OP (
          p_pp_transaction_temp_id IN  NUMBER,
          x_return_status          OUT NOCOPY NUMBER) IS

          CURSOR g_operation_plan_curs IS
       ';
      buildpackage(l_pack_body_sql);
      buildpackage(g_stmt);
      l_pack_body_sql  :=
             ';  -- for OP

       BEGIN
          x_return_status := 0;
          OPEN g_operation_plan_curs;
          FETCH g_operation_plan_curs  INTO x_return_status;
          CLOSE g_operation_plan_curs;
      END Get_OP;

END '
          || l_package_name
          || ';';
    ELSIF (l_type_code = 3) THEN
      -- Generate package for Task Type Rules
      g_stmt           :=    'select count(*) '
                          || '  from '
                          || NVL(g_rule_from, 'MTL_MATERIAL_TRANSACTIONS_TEMP mmtt')
                          || ' where (MMTT.PARENT_LINE_ID = p_pp_transaction_temp_id or MMTT.TRANSACTION_TEMP_ID = p_pp_transaction_temp_id) '   -- Bug Fix 5560849, 8546026(High vol project)
                          || g_rule_where;
      --assemble create package statement
      l_pack_sql       :=
             'CREATE OR REPLACE PACKAGE '
          || l_package_name
          || ' AS
                procedure Get_Task (
                   p_pp_transaction_temp_id     IN NUMBER,
                   x_return_status              OUT NOCOPY NUMBER);

 end '
          || l_package_name
          || ';';
      --inv_pp_debug.send_long_to_pipe(l_pack_sql);
      --open cursor
      --l_cursor := dbms_sql.open_cursor;
      --parse cursor
      --dbms_sql.parse(l_cursor, l_pack_sql, dbms_sql.native);
      --close cursor
      --dbms_sql.close_cursor(l_cursor);
      buildpackage(l_pack_sql);
      createpackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      initbuildpackage;
      --inv_pp_debug.send_long_to_pipe(g_stmt);

      --assemble the dynamic package creation statment
      l_pack_body_sql  :=
             'CREATE OR REPLACE PACKAGE BODY '
          || l_package_name
          || ' AS
     PROCEDURE Get_Task (
         p_pp_transaction_temp_id IN  NUMBER,
         x_return_status          OUT NOCOPY NUMBER) IS

         CURSOR g_task_type_curs IS
      ';
      buildpackage(l_pack_body_sql);
      buildpackage(g_stmt);
      l_pack_body_sql  :=
             ';  -- for TTA

      BEGIN
         x_return_status := 0;
         OPEN g_task_type_curs;
         FETCH g_task_type_curs INTO x_return_status;
         CLOSE g_task_type_curs;
      END Get_Task;

END '
          || l_package_name
          || ';';
    -- Call CreatePackage after IF statement

    ELSIF (l_type_code = 5) THEN
      -- Build package for Cost Group Rules
      g_stmt           :=    'select count(*) '
                          || '  from '
                          || NVL(g_rule_from, 'WMS_COST_GROUPS_INPUT_V wcgiv')
                          || ' where wcgiv.line_id = g_line_id '
                          || g_rule_where;
      --assemble create package statement
      l_pack_sql       :=
             'CREATE OR REPLACE PACKAGE '
          || l_package_name
          || ' AS

                   PROCEDURE Get_CostGroup(
                       p_line_id        IN NUMBER,
                       x_return_status  OUT NOCOPY NUMBER);

    end '
          || l_package_name
          || ';';
      --inv_pp_debug.send_long_to_pipe(l_pack_sql);
      --open cursor
      --l_cursor := dbms_sql.open_cursor;
      --parse cursor
      --dbms_sql.parse(l_cursor, l_pack_sql, dbms_sql.native);
      --close cursor
      --dbms_sql.close_cursor(l_cursor);
      buildpackage(l_pack_sql);
      createpackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      initbuildpackage;
      --inv_pp_debug.send_long_to_pipe(g_stmt);

      --assemble the dynamic package creation statment
      l_pack_body_sql  :=
             'CREATE OR REPLACE PACKAGE BODY '
          || l_package_name
          || ' AS
         PROCEDURE Get_CostGroup(
                  p_line_id IN  NUMBER,
                  x_return_status OUT NOCOPY NUMBER) IS

           g_line_id  NUMBER;

                 CURSOR g_cursor_cost_group IS
                 ';
      buildpackage(l_pack_body_sql);
      buildpackage(g_stmt);
      l_pack_body_sql  :=
             ';

             BEGIN
                   g_line_id := p_line_id;

             OPEN g_cursor_cost_group;

             IF g_cursor_cost_group%isopen THEN

                FETCH g_cursor_cost_group INTO
                x_return_status;

             ELSE
                x_return_status := 0;
             END IF;

             IF(g_cursor_cost_group%isopen) THEN

                CLOSE g_cursor_cost_group;

             END IF;

              END Get_CostGroup;
  END '
          || l_package_name
          || ';';
    ELSIF l_type_code = 1 THEN
      -- Build for Put Away
      l_subinventory_where  := g_base_table_alias || '.subinventory_code = g_subinventory_code' || g_line_feed;
      l_locator_where       := g_base_table_alias || '.locator_id = g_locator_id' || g_line_feed;
      --build the sql portion of the cursor for non-serial-controlled items
       log_procedure(l_api_name, '=>', '*********************   200');
      g_stmt                :=
                              'select ' || g_base_select || ' from ' || g_rule_from || g_base_from || ' where ' || g_input_where || g_rule_where;
      --inv_pp_debug.send_long_to_pipe('g_base_from : ' || g_base_from);

     log_procedure(l_api_name, '=>', '*********************   199');

      --assemble create package statement
      l_pack_sql            :=
             'CREATE OR REPLACE PACKAGE '
          || l_package_name
          || ' AS
                   procedure open_curs (
                   p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.CV_PUT_TYPE,
                   p_organization_id            IN NUMBER,
                   p_inventory_item_id          IN NUMBER,
       p_transaction_type_id        IN NUMBER,
                   p_subinventory_code          IN VARCHAR2,
                   p_locator_id                 IN NUMBER,
                   p_pp_transaction_temp_id     IN NUMBER,
       p_restrict_subs_code   IN NUMBER,
       p_restrict_locs_code   IN NUMBER,
       p_project_id     IN NUMBER,
       p_task_id      IN NUMBER,
                   x_result                     OUT NOCOPY NUMBER);

                   PROCEDURE fetch_one_row  (
                      p_cursor              IN  WMS_RULE_PVT.CV_PUT_TYPE,
                      x_subinventory_code   OUT NOCOPY VARCHAR2,
                      x_locator_id          OUT NOCOPY NUMBER,
                      x_project_id          OUT NOCOPY NUMBER,
                      x_task_id             OUT NOCOPY NUMBER,
                      x_return_status       OUT NOCOPY NUMBER);

                   PROCEDURE close_curs(p_cursor IN  WMS_RULE_PVT.CV_PUT_TYPE );

    end '
          || l_package_name
          || ';';
     log_procedure(l_api_name, '=>', '*********************   198');
      --inv_pp_debug.send_long_to_pipe(l_pack_sql);
      --open cursor
      --l_cursor := dbms_sql.open_cursor;
      --parse cursor
      --dbms_sql.parse(l_cursor, l_pack_sql, dbms_sql.native);
      --close cursor
      --dbms_sql.close_cursor(l_cursor);
      buildpackage(l_pack_sql);
      createpackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      initbuildpackage;
      --   inv_pp_debug.send_long_to_pipe(g_stmt_serial_detail);
       --  inv_pp_debug.send_long_to_pipe(g_stmt_serial);
         --assemble the dynamic package creation statment
       log_procedure(l_api_name, '=>', '*********************  197');
      l_pack_body_sql       :=
             'CREATE OR REPLACE PACKAGE BODY '
          || l_package_name
          || ' AS

     PROCEDURE open_curs (
                p_cursor                 IN OUT NOCOPY WMS_RULE_PVT.cv_put_type,
    p_organization_id   IN NUMBER,
    p_inventory_item_id   IN NUMBER,
    p_transaction_type_id   IN NUMBER,
    p_subinventory_code IN VARCHAR2,
    p_locator_id    IN NUMBER,
    p_pp_transaction_temp_id IN NUMBER,
    p_restrict_subs_code  IN NUMBER,
    p_restrict_locs_code  IN NUMBER,
    p_project_id    IN NUMBER,
    p_task_id   IN NUMBER,
    x_result    OUT NOCOPY NUMBER) IS

                g_organization_id           NUMBER;
                g_inventory_item_id         NUMBER;
                g_transaction_type_id       NUMBER;
                g_subinventory_code         VARCHAR2(10);
                g_locator_id                NUMBER;
                g_pp_transaction_temp_id    NUMBER;
                g_restrict_subs_code        NUMBER;
                g_restrict_locs_code        NUMBER;
    g_project_id                NUMBER;
    g_task_id                   NUMBER;

    BEGIN
    g_organization_id :=p_organization_id;
    g_inventory_item_id := p_inventory_item_id;
    g_transaction_type_id := p_transaction_type_id;
          IF p_subinventory_code = ''-9999'' THEN
      g_subinventory_code := NULL;
    ELSE
      g_subinventory_code := p_subinventory_code;
    END IF;
          IF p_locator_id = -9999 THEN
      g_locator_id := NULL;
    ELSE
      g_locator_id := p_locator_id;
    END IF;
    g_pp_transaction_temp_id := p_pp_transaction_temp_id;
    g_restrict_subs_code := p_restrict_subs_code;
    g_restrict_locs_code := p_restrict_locs_code;
    g_project_id := p_project_id;
    g_task_id := p_task_id;

    --if no restrictions
    IF g_restrict_subs_code = 2 AND
       g_restrict_locs_code = 2 THEN

      If g_subinventory_code IS NULL Then
      --if nothing passed, OPEN c_no_restrict_no_passed;

        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      log_procedure(l_api_name, '=>', '*********************   1961');
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_no_restrict);
      log_procedure(l_api_name, '=> Lenght ', length(l_stmt));
      l_rest_sql := l_stmt;
      log_procedure(l_api_name, '=> Lenght ', length(l_stmt));
      log_procedure(l_api_name, '=>_rest_sql', l_rest_sql);
      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;
       log_procedure(l_api_name, '=>', '*********************   1963');

      buildpackage(l_stmt);
       log_procedure(l_api_name, '=>', '*********************   1964');
      l_pack_body_sql       :=
          ';

      Elsif g_locator_id IS NULL Then

      --if only subinventory passed , OPEN c_no_restrict_sub_passed;

        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
       log_procedure(l_api_name, '=>', '*********************   195');
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_no_restrict);
      l_stmt                := l_stmt || ' and ' || l_subinventory_where;
       log_procedure(l_api_name, '=>', '*********************   194');
      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
          ';

      Else
      --if subinventory and locator passed, OPEN c_no_restrict_loc_passed;
        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      log_procedure(l_api_name, '=>', '*********************   99');
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_no_restrict);
      log_procedure(l_api_name, '=>', '*********************   98');
      l_stmt                := l_stmt || ' and ' || l_subinventory_where || ' and ' || l_locator_where;
      log_procedure(l_api_name, '=>', '*********************   97');
      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
          ';
      End If;
    ELSIF g_restrict_locs_code = 2 THEN
      If g_subinventory_code IS NULL Then
      --if nothing passed, OPEN c_sub_restrict_no_passed;
        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_sub_restrict);

      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
          ';
      Elsif g_locator_id IS NULL Then
      --if only subinventory passed, OPEN c_sub_restrict_sub_passed;
         OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_sub_restrict);
      l_stmt                := l_stmt || ' and ' || l_subinventory_where;

      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
              ';

      Else
      --if subinventory and locator passed, OPEN c_sub_restrict_loc_passed;
        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_sub_restrict);
      l_stmt                := l_stmt || ' and ' || l_subinventory_where || ' and ' || l_locator_where;

      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
          ';
      End If;
    ELSE
      If g_subinventory_code IS NULL Then
      --if nothing passed, OPEN c_loc_restrict_no_passed;
        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_loc_restrict);

      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
          ';

      Elsif g_locator_id IS NULL Then
      --if only subinventory passed,OPEN c_loc_restrict_sub_passed;
        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_loc_restrict);
      l_stmt                := l_stmt || ' and ' || l_subinventory_where;

      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
              ';

      Else
      --if subinventory and locator passed, OPEN c_loc_restrict_loc_passed;
        OPEN p_cursor FOR ';
      buildpackage(l_pack_body_sql);
      --build correct statement
      l_stmt                := REPLACE(g_stmt, ':g_put_base', g_put_base_loc_restrict);
      l_stmt                := l_stmt || ' and ' || l_subinventory_where || ' and ' || l_locator_where;

      IF g_rule_order IS NOT NULL THEN
        l_stmt  := l_stmt || ' order by ' || g_rule_order;
      END IF;

      buildpackage(l_stmt);
      l_pack_body_sql       :=
             ';
      End If;
    END IF;

    x_result :=1;

   END open_curs;

   PROCEDURE fetch_one_row(
                        p_cursor  IN WMS_RULE_PVT.cv_put_type,
      x_subinventory_code OUT NOCOPY VARCHAR2,
      x_locator_id OUT NOCOPY NUMBER,
      x_project_id OUT NOCOPY NUMBER,
      x_task_id OUT NOCOPY NUMBER,
      x_return_status OUT NOCOPY NUMBER) IS


   BEGIN
      if p_cursor%ISOPEN then
         FETCH p_cursor INTO
               x_subinventory_code, x_locator_id, x_project_id, x_task_id;
          IF p_cursor%FOUND THEN
                x_return_status := 1;
          ELSE
               x_return_status := 0;
          END IF;
      else
              x_return_status := 0;
      end if;

   END fetch_one_row;

   PROCEDURE close_curs( p_cursor  IN WMS_RULE_PVT.cv_put_type) IS
   BEGIN
       if p_cursor%ISOPEN then
           CLOSE p_cursor;
         end if;
   END close_curs;

   END '
          || l_package_name
          || ';';
    ELSE
      -- Build for Pick
      IF l_allocation_mode_id IN (1, 2) THEN
        --build the sql portion of the cursor for non-serial-controlled items
        g_stmt  :=
             'select ' || g_base_select || g_rule_select || ' from ' || g_rule_from || g_base_from || ' where ' || g_input_where || g_rule_where;
      --Ensures that we only get one rec per rev/lot/sub/loc, grouping
      -- all recs together regardless of LPN
      -- l_allocation_mode_id IN (3,4)
      ELSE
        g_stmt  :=    'select '
                   || g_base_select
                   || g_rule_select_serial
                   || ' from '
                   || g_rule_from
                   || g_base_from
                   || ' where '
                   || g_input_where
                   || g_rule_where
                   || 'group by '
                   || g_base_group_by
                   || g_rule_group_by;
      END IF;

      --inv_pp_debug.send_long_to_pipe('g_base_from : ' || g_base_from);

      IF g_rule_order IS NOT NULL THEN
        g_stmt  := g_stmt || ' order by ' || g_rule_order;
      END IF;

      --assemble create package statement
      l_pack_sql       :=
             'CREATE OR REPLACE PACKAGE '
          || l_package_name
          || ' AS
                   procedure open_curs (
                   p_cursor            IN OUT NOCOPY WMS_RULE_PVT.cv_pick_type,
                   p_organization_id            IN NUMBER,
                   p_inventory_item_id          IN NUMBER,
                   p_transaction_type_id        IN NUMBER,
                   p_revision                   IN VARCHAR2,
                   p_lot_number                 IN VARCHAR2,
                   p_subinventory_code          IN VARCHAR2,
                   p_locator_id                 IN NUMBER,
                   p_cost_group_id          IN NUMBER,
                   p_pp_transaction_temp_id     IN NUMBER,
                   p_serial_controlled    IN NUMBER,
                   p_detail_serial    IN NUMBER,
                   p_detail_any_serial    IN NUMBER,
                   p_from_serial_number   IN VARCHAR2,
                   p_to_serial_number   IN VARCHAR2,
                   p_unit_number    IN VARCHAR2,
                   p_lpn_id     IN NUMBER,
                   p_project_id     IN NUMBER,
                   p_task_id      IN NUMBER,
                   x_result                     OUT NOCOPY NUMBER);

                   PROCEDURE fetch_one_row  (
                      p_cursor                 IN WMS_RULE_PVT.cv_pick_type,
                      x_revision               OUT NOCOPY VARCHAR2,
                      x_lot_number             OUT NOCOPY VARCHAR2,
                      x_lot_expiration_date    OUT NOCOPY DATE,
                      x_subinventory_code      OUT NOCOPY VARCHAR2,
                      x_locator_id             OUT NOCOPY NUMBER,
                      x_cost_group_id          OUT NOCOPY NUMBER,
                      x_uom_code               OUT NOCOPY VARCHAR2,
                      x_lpn_id                 OUT NOCOPY NUMBER,
                      x_serial_number          OUT NOCOPY VARCHAR2,
                      x_possible_quantity      OUT NOCOPY NUMBER,
                      x_sec_possible_quantity  OUT NOCOPY NUMBER,
                      x_grade_code             OUT NOCOPY VARCHAR2,
                      x_consist_string         OUT NOCOPY VARCHAR2,
                      x_order_by_string        OUT NOCOPY VARCHAR2,
                      x_return_status          OUT NOCOPY NUMBER);

            PROCEDURE close_curs( p_cursor  IN WMS_RULE_PVT.cv_pick_type);

            PROCEDURE fetch_available_rows  (
                      p_cursor              IN WMS_RULE_PVT.cv_pick_type,
                      x_return_status       OUT NOCOPY NUMBER);



    end '
          || l_package_name
          || ';';
      --inv_pp_debug.send_long_to_pipe(l_pack_sql);
      --open cursor
      --l_cursor := dbms_sql.open_cursor;
      --parse cursor
      --dbms_sql.parse(l_cursor, l_pack_sql, dbms_sql.native);
      --close cursor
      --dbms_sql.close_cursor(l_cursor);
      buildpackage(l_pack_sql);
      createpackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      initbuildpackage;
      --   inv_pp_debug.send_long_to_pipe(g_stmt_serial_detail);
       --  inv_pp_debug.send_long_to_pipe(g_stmt_serial);
         --assemble the dynamic package creation statment

      l_pack_body_sql  :=
             'CREATE OR REPLACE PACKAGE BODY '
          || l_package_name
          || ' AS

     PROCEDURE open_curs
        (
                p_cursor                IN OUT NOCOPY WMS_RULE_PVT.cv_pick_type,
                p_organization_id   IN NUMBER,
                p_inventory_item_id   IN NUMBER,
                p_transaction_type_id   IN NUMBER,
                p_revision    IN VARCHAR2,
                p_lot_number    IN VARCHAR2,
                p_subinventory_code IN VARCHAR2,
                p_locator_id    IN NUMBER,
                p_cost_group_id   IN NUMBER,
                p_pp_transaction_temp_id IN NUMBER,
                p_serial_controlled IN NUMBER,
                p_detail_serial   IN NUMBER,
                p_detail_any_serial IN NUMBER,
                p_from_serial_number  IN VARCHAR2,
                p_to_serial_number  IN VARCHAR2,
                p_unit_number   IN VARCHAR2,
                p_lpn_id    IN NUMBER,
                p_project_id    IN NUMBER,
                p_task_id   IN NUMBER,
                x_result    OUT NOCOPY NUMBER
        ) IS
                g_organization_id             NUMBER;
                g_inventory_item_id           NUMBER;
                g_transaction_type_id         NUMBER;
                g_revision                    VARCHAR2(3);
                g_lot_number                  VARCHAR2(80);
                g_subinventory_code           VARCHAR2(10);
                g_locator_id                  NUMBER;
                g_cost_group_id               NUMBER;
                g_pp_transaction_temp_id      NUMBER;
                g_serial_control              NUMBER;
                g_detail_serial               NUMBER;
                g_detail_any_serial           NUMBER;
                g_from_serial_number          VARCHAR2(30);
                g_to_serial_number            VARCHAR2(30);
                g_unit_number                 VARCHAR2(30);
                g_lpn_id                      NUMBER;
                g_project_id                  NUMBER;
                g_task_id                     NUMBER;


    BEGIN
      g_organization_id :=p_organization_id;
      g_inventory_item_id := p_inventory_item_id;
      g_transaction_type_id := p_transaction_type_id;
      g_revision := p_revision;
      g_lot_number := p_lot_number;
      g_subinventory_code :=p_subinventory_code;
      g_locator_id := p_locator_id;
      g_cost_group_id := p_cost_group_id;
      g_pp_transaction_temp_id := p_pp_transaction_temp_id;
      g_serial_control:= p_serial_controlled;
      g_detail_serial := p_detail_serial;
      g_detail_any_serial := p_detail_any_serial;
      g_from_serial_number := p_from_serial_number;
      g_to_serial_number := p_to_serial_number;
      g_unit_number := p_unit_number;
      g_lpn_id := p_lpn_id;
      g_project_id := p_project_id;
      g_task_id := p_task_id;

     IF (g_serial_control = 1)    AND (g_detail_serial in (1,2)) THEN
         OPEN p_cursor FOR ';
              buildpackage(l_pack_body_sql);
              buildpackage(g_stmt_serial_detail_new);
              l_pack_body_sql  := ';
     Elsif (g_serial_control = 1) AND (g_detail_serial = 3) THEN
        OPEN p_cursor FOR ';
             buildpackage(l_pack_body_sql);
             buildpackage(g_stmt_serial_validate);
             l_pack_body_sql  := ';
     Elsif (g_serial_control = 1) AND  (g_detail_serial = 4) THEN
           OPEN p_cursor FOR ';
                buildpackage(l_pack_body_sql);
                buildpackage(g_stmt_serial);
                l_pack_body_sql  := ';

     Elsif ((g_serial_control <> 1) OR (g_detail_serial = 0)) THEN
       OPEN p_cursor FOR ';
        buildpackage(l_pack_body_sql);
        buildpackage(g_stmt);
        l_pack_body_sql  :=
             ';
     END IF;

    x_result :=1;

   END open_curs;

   PROCEDURE fetch_one_row(
                        p_cursor   IN WMS_RULE_PVT.cv_pick_type,
                        x_revision OUT NOCOPY VARCHAR2,
                        x_lot_number OUT NOCOPY VARCHAR2,
                        x_lot_expiration_date OUT NOCOPY DATE,
                        x_subinventory_code OUT NOCOPY VARCHAR2,
                        x_locator_id OUT NOCOPY NUMBER,
                        x_cost_group_id OUT NOCOPY NUMBER,
                        x_uom_code OUT NOCOPY VARCHAR2,
                        x_lpn_id OUT NOCOPY NUMBER,
                        x_serial_number OUT NOCOPY VARCHAR2,
                        x_possible_quantity OUT NOCOPY NUMBER,
                        x_sec_possible_quantity  OUT NOCOPY NUMBER,
                        x_grade_code             OUT NOCOPY VARCHAR2,
                        x_consist_string  OUT NOCOPY VARCHAR2,
                        x_order_by_string OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY NUMBER) IS


   BEGIN
           IF (p_cursor%ISOPEN) THEN

               FETCH p_cursor INTO
               x_revision
               , x_lot_number
               , x_lot_expiration_date
               , x_subinventory_code
               , x_locator_id
               , x_cost_group_id
               , x_uom_code
               , x_lpn_id
               , x_serial_number
               , x_possible_quantity
               , x_sec_possible_quantity
               , x_grade_code
               , x_consist_string
               , x_order_by_string;
               IF p_cursor%FOUND THEN
                  x_return_status :=1;
               ELSE
                  x_return_status :=0;
               END IF;
            ELSE
               x_return_status:=0;
            END IF;


   END fetch_one_row;

   PROCEDURE close_curs( p_cursor IN WMS_RULE_PVT.cv_pick_type) IS
   BEGIN
        if (p_cursor%ISOPEN) THEN
            CLOSE p_cursor;
        END IF;
   END close_curs;

   -- LG convergence new procedure for the new manual picking select screen
   PROCEDURE fetch_available_rows(
      p_cursor   IN WMS_RULE_PVT.cv_pick_type,
      x_return_status OUT NOCOPY NUMBER) IS

    /* Fix for Bug#8360804 . Added temp variable of type available_inventory_tbl */

     l_available_inv_tbl WMS_SEARCH_ORDER_GLOBALS_PVT.available_inventory_tbl;
     l_count number ;


   BEGIN
           IF (p_cursor%ISOPEN) THEN

              /* Fix for bug#8360804. Collect into temp variable and then add it to g_available_inv_tbl */

               FETCH p_cursor bulk collect INTO l_available_inv_tbl;

               IF p_cursor%FOUND THEN
                  x_return_status :=1;
               ELSE
                  x_return_status :=0;
               END IF;

               IF (WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.exists(1)) THEN

                  l_count := WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.LAST ;

                  FOR i in l_available_inv_tbl.FIRST..l_available_inv_tbl.LAST LOOP
                    l_count := l_count + 1 ;
                    WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(l_count) := l_available_inv_tbl(i) ;
                  END LOOP ;

               ELSE
                   WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl := l_available_inv_tbl ;
               END IF ;
            ELSE
               x_return_status:=0;
            END IF;


   END fetch_available_rows;

   -- end LG convergence

   END '
          || l_package_name
          || ';';
    END IF; -- type_code = 4

    -- Add last part of SQL to the global table, then call
    --  CreatePackage to generate package body
    buildpackage(l_pack_body_sql);
    createpackage(x_return_status, l_package_name, TRUE);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    initbuildpackage;
     -- inv_pp_debug.send_long_to_pipe(l_pack_body_sql);
    /*
      --open cursor

      l_cursor := dbms_sql.open_cursor;
      dbms_out
      --parse cursor

      dbms_sql.parse(l_cursor, l_pack_body_sql, dbms_sql.native);

      --close cursor
      dbms_sql.close_cursor(l_cursor);
    */



    --
    -- clean up everything again
    freeglobals;

    --

    /*
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
        fnd_message.set_name('WMS','WMS_SYNTAX_CHECK_SUCCESS');
        fnd_msg_pub.add;
      END IF;
    */ --
    -- end of debugging section
    log_procedure(l_api_name, 'end', 'End GenerateRulePackage');
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;

      -- end of debugging section
      --
      IF DBMS_SQL.is_open(l_cursor) THEN
        DBMS_SQL.close_cursor(l_cursor);
      END IF;

      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      log_error(l_api_name, 'error', 'Expected error - ' || x_msg_data);
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;

      -- end of debugging section
      --
      IF DBMS_SQL.is_open(l_cursor) THEN
        DBMS_SQL.close_cursor(l_cursor);
      END IF;

      freeglobals;
      fnd_message.set_name('WMS', 'WMS_PACKAGE_GEN_FAILED');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
    --
    WHEN OTHERS THEN
      --
      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;

      -- end of debugging section
      --
      IF rule%ISOPEN THEN
        CLOSE rule;
      END IF;

      IF DBMS_SQL.is_open(l_cursor) THEN
        DBMS_SQL.close_cursor(l_cursor);
      END IF;

      freeglobals;
      fnd_message.set_name('WMS', 'WMS_PACKAGE_GEN_FAILED');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
  --
  END generaterulepackage;

  -- API name    : Assign_operation_plans
  -- Type        : Private
  -- Function    : Assign operation plans to records in MMTT
  -- Input Parameters  :
  --
  -- Output Parameters:
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       : calls Assign_operation_plan(p_task_id NUMBER)
  --
  -- This procedure loops through mtl_material_transactions_temp table, assign
  -- user defined operation plans to tasks that have not been assigned a operation_plan
  -- for the given Move Order Header.
  --


  PROCEDURE assign_operation_plans(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2
  , p_commit               IN            VARCHAR2
  , p_validation_level     IN            NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_move_order_header_id IN            NUMBER
  ) IS
    CURSOR c_tasks IS
      SELECT mmtt.transaction_temp_id
        FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mol
       WHERE mmtt.operation_plan_id IS NULL
         AND mmtt.move_order_line_id = mol.line_id
         AND mol.header_id = p_move_order_header_id;

    l_task_id       NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_api_name      VARCHAR2(30)   := 'assign_operation_plans';
    l_count         NUMBER;
  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Bug# 4587423
    -- See if there are any enabled rules for Operation Plan Selection.
    l_count := 0;
    BEGIN
       SELECT 1 INTO l_count
	 FROM dual
	 WHERE EXISTS (SELECT 1 FROM wms_rules_b rules
		       WHERE  rules.type_code = 7
		       AND    rules.enabled_flag = 'Y'
		       AND    (organization_id = -1
			       OR organization_id IN (SELECT mmtt.organization_id
						      FROM mtl_material_transactions_temp mmtt,
						      mtl_txn_request_lines mol
						      WHERE mmtt.operation_plan_id IS NULL /*bug9128227*/
						      AND mmtt.move_order_line_id = mol.line_id
						      AND mol.header_id = p_move_order_header_id)));
    EXCEPTION
       WHEN OTHERS THEN
	  l_count := 0;
    END;

    -- Bug# 4587423
    -- If there is at least one operation plan selection rule enabled,
    -- go through the existing logic.
    IF (l_count > 0) THEN
       OPEN c_tasks;
       LOOP
	  FETCH c_tasks INTO l_task_id;
	  EXIT WHEN c_tasks%NOTFOUND;

	  if (inv_control.g_current_release_level >= inv_release.g_j_release_level
	      and  wms_ui_tasks_apis.g_wms_patch_level >= wms_ui_tasks_apis.g_patchset_j)
	    then
	     -- ### Outbound for patchset 'J'
	     wms_rule_pvt_ext_psetj.assign_operation_plan_psetj
	       (p_api_version      => 1.0,
		x_return_status    => l_return_status,
		x_msg_count        => l_msg_count,
		x_msg_data         => l_msg_data,
		p_task_id          => l_task_id
		);
	   elsif (inv_control.g_current_release_level < inv_release.g_j_release_level
		  or wms_ui_tasks_apis.g_wms_patch_level < wms_ui_tasks_apis.g_patchset_j)
	     then
	     -- ### Outbound for patchset 'I'
	     assign_operation_plan
	       (p_api_version      => 1.0,
		p_task_id          => l_task_id,
		x_return_status    => l_return_status,
		x_msg_count        => l_msg_count,
		x_msg_data         => l_msg_data
		);
	  end if;

	  IF l_return_status <> fnd_api.g_ret_sts_success THEN
	     x_return_status  := fnd_api.g_ret_sts_error;
	  END IF;
       END LOOP;

       CLOSE c_tasks;
     ELSE
       -- Bug# 4587423
       -- No rules exist for outbound operaton plan selection.
       -- Just stamp the org default outbound operation plan or the default
       -- "Locator and LPN Based Consolidation in Staging Lane" seeded outbound operation plan
       -- for the MMTT records associated with the move order header.
       UPDATE mtl_material_transactions_temp mmtt
	 SET mmtt.operation_plan_id = (SELECT NVL(default_pick_op_plan_id, 1)
				       FROM mtl_parameters mp
				       WHERE mp.organization_id = mmtt.organization_id)
	 WHERE mmtt.operation_plan_id IS NULL
	   AND mmtt.move_order_line_id IN (SELECT line_id
					   FROM mtl_txn_request_lines mol
					   WHERE mol.header_id = p_move_order_header_id)
	   AND mmtt.transaction_source_type_id in (2, 8);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END assign_operation_plans;

  --
  -- API name    : Assign Operation Plan
  -- Type        : Private
  -- Function    : Assign Operation plan to a specific record in MMTT
  -- Input Parameters  :
  --           p_task_id NUMBER
  --
  -- Output Parameters:
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       :
  --
  -- This procedure assign user defined operation plan to a specific task in
  -- mtl_material_transactions_temp. Operation plan is implemeted by WMS rules.
  -- This procedure calls the rule package created for operation plan rules to check
  -- which operation plan rule actually matches the task in question.


  PROCEDURE assign_operation_plan(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2
  , p_commit           IN            VARCHAR2
  , p_validation_level IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_task_id          IN            NUMBER
  ) IS
    l_rule_id              NUMBER;
    l_pack_exists          NUMBER;
    l_package_name         VARCHAR2(30);
    l_count                NUMBER;
    l_return_status        NUMBER;
    l_found                BOOLEAN      := FALSE;
    l_organization_id      NUMBER;
    l_wms_task_type        NUMBER;
    l_operation_plan_id    NUMBER;
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'Assign_operation_plan';

    -- Cursor for task type rule loop
    -- Only rules with the same WMS system task type as the task
    -- will be selected
    -- Rules are ordered by rule weight and creation date

    CURSOR c_rules IS
      SELECT   rules.rule_id
             , mmtt.organization_id
             , mmtt.wms_task_type
             , rules.type_hdr_id
          FROM wms_rules_b rules, wms_op_plans_b wop, mtl_material_transactions_temp mmtt
	WHERE rules.type_code = 7
	AND rules.enabled_flag = 'Y'
	AND rules.type_hdr_id = wop.operation_plan_id
	AND wop.system_task_type = NVL(mmtt.wms_task_type, wop.system_task_type)
	--AND    mmtt.transaction_source_type_id <> 5 -- exclude wip issue tasks
	AND    mmtt.transaction_source_type_id IN (2, 8) --restrict to sales order and internal order mmtts only
	AND mmtt.transaction_temp_id = p_task_id
	AND rules.organization_id IN (mmtt.organization_id, -1)
	AND NVL(wop.organization_id, mmtt.organization_id) = mmtt.organization_id
           AND wop.enabled_flag = 'Y'
      ORDER BY rules.rule_weight DESC, rules.creation_date;

    -- Bug# 4587423: If a default outbound operation plan is not defined for the org,
    -- default to 1 (Locator and LPN Based Consolidation in Staging Lane)
    CURSOR c_default_operation_plan IS
      SELECT NVL(default_pick_op_plan_id, 1)
        FROM mtl_parameters
       WHERE organization_id = l_organization_id;

       l_rule_counter           INTEGER;
  BEGIN
    SAVEPOINT assign_operation_plan_sp;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    IF p_validation_level <> fnd_api.g_valid_level_none THEN
      -- in case further needs for validation
      NULL;
    END IF;

    OPEN c_rules; -- open the eligible rules cursor

    LOOP -- loop through the rules
      FETCH c_rules INTO l_rule_id, l_organization_id, l_wms_task_type, l_operation_plan_id;
      EXIT WHEN c_rules%NOTFOUND;

      BEGIN
        -- get the pre-generated package name for this rule
        getpackagename(l_rule_id, l_package_name);

         --- Execute op Rule
        For l_rule_counter IN 1..2  LOOP
            execute_op_rule(l_rule_id, p_task_id, l_return_status);
	    IF (l_return_status = -1) and l_rule_counter   = 2 THEN --error
	        fnd_message.set_name('WMS', 'WMS_PACKAGE_MISSING');
	        fnd_message.set_token('RULEID', l_rule_id);
	        fnd_msg_pub.ADD;
	        log_error_msg(l_api_name, 'rule_package_missing');
	        log_statement(l_api_name, 'pack_name', 'Package name: ' || l_package_name);
	        RAISE fnd_api.g_exc_unexpected_error;
	    ELSIF l_return_status <> -1 THEN
	        EXIT;
	    END IF;
       END LOOP;

       IF l_return_status > 0 THEN -- the rule matches the task
          l_found  := TRUE;

          -- update mmtt table to assign the operation plan


          UPDATE mtl_material_transactions_temp mmtt
             SET mmtt.operation_plan_id = l_operation_plan_id
           WHERE mmtt.transaction_temp_id = p_task_id;

          EXIT; -- operation plan assigned, jump out of the rule loop
        END IF; -- l_return_status > 0
      EXCEPTION -- handle exceptions for matching one rule
        WHEN fnd_api.g_exc_error THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END; -- end matching one rule
    END LOOP;

    CLOSE c_rules; --close the rule cursor

    -- get default operation plan
    IF NOT l_found THEN

      begin
            select organization_id
             into  l_organization_id
             from  mtl_material_transactions_temp
	      where  transaction_temp_id = p_task_id
	      AND transaction_source_type_id IN (2, 8);   -- bug fix 3361560
      exception
            when others then
                null;
      end;

      IF NVL(g_current_organization_id, -1) <> l_organization_id THEN
        g_current_organization_id  := l_organization_id;
        OPEN c_default_operation_plan;
        FETCH c_default_operation_plan INTO g_default_operation_plan_id;

        IF c_default_operation_plan%NOTFOUND THEN
          l_operation_plan_id  := NULL;
        END IF;

        CLOSE c_default_operation_plan;
      END IF;

      l_operation_plan_id  := g_default_operation_plan_id;

      UPDATE mtl_material_transactions_temp mmtt
         SET mmtt.operation_plan_id = l_operation_plan_id
       WHERE mmtt.transaction_temp_id = p_task_id;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- if the rule package not created yet, close the rule cursor
      IF c_rules%ISOPEN THEN
        CLOSE c_rules;
      END IF;

      ROLLBACK TO assign_operation_plan_sp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO assign_operation_plan_sp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END assign_operation_plan;

  --**************************************

  --
  -- API name    : AssignTT
  -- Type        : Private
  -- Function    : Assign task type to records in MMTT
  -- Input Parameters  :
  --
  -- Output Parameters:
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       : calls AssignTTs(p_task_id NUMBER)
  --
  -- This procedure loops through mtl_material_transactions_temp table, assign
  -- user defined task type to tasks that have not been assigned a task type
  -- for the given Move Order Header.
  --


  PROCEDURE assigntts(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2
  , p_commit               IN            VARCHAR2
  , p_validation_level     IN            NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_move_order_header_id IN            NUMBER
  ) IS
    CURSOR c_tasks IS
      SELECT mmtt.transaction_temp_id
            ,mmtt.organization_id -- Added new
            ,mmtt.wms_task_type   -- Added new
        FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mol
       WHERE mmtt.standard_operation_id IS NULL
         AND mmtt.move_order_line_id = mol.line_id
         AND mol.header_id = p_move_order_header_id;

    l_task_id           NUMBER;
    l_organization_id   NUMBER; -- Added new
    l_wms_task_type     NUMBER; -- Added new
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_api_name      VARCHAR2(30)   := 'assignTTs';
    l_count         NUMBER;
  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Bug# 4587423
    -- See if there are any enabled rules for Task Type Assignment for
    -- all orgs or for the orgs in the set of MMTT records for the given move order header.
    l_count := 0;
    BEGIN
       SELECT 1 INTO l_count
	 FROM dual
	 WHERE EXISTS (SELECT 1 FROM wms_rules_b rules
		       WHERE  rules.type_code = 3
		       AND    rules.enabled_flag = 'Y'
		       AND    (organization_id = -1
			       OR organization_id IN (SELECT mmtt.organization_id
						      FROM mtl_material_transactions_temp mmtt,
						      mtl_txn_request_lines mol
						      WHERE mmtt.standard_operation_id IS NULL
						      AND mmtt.move_order_line_id = mol.line_id
						      AND mol.header_id = p_move_order_header_id)));
    EXCEPTION
       WHEN OTHERS THEN
	  l_count := 0;
    END;

    -- Bug# 4587423
    -- If there is at least one task type assignment rule enabled,
    -- go through the existing logic.
    IF (l_count > 0) THEN
       OPEN c_tasks;
       LOOP
	  FETCH c_tasks INTO l_task_id
                            ,l_organization_id  -- new
                            ,l_wms_task_type;    -- new
	  EXIT WHEN c_tasks%NOTFOUND;
	  assigntt
	    (p_api_version                => 1.0,
	     p_task_id                    => l_task_id,
	     x_return_status              => l_return_status,
	     x_msg_count                  => l_msg_count,
	     x_msg_data                   => l_msg_data
	     );

	  IF l_return_status <> fnd_api.g_ret_sts_success THEN
	     x_return_status  := fnd_api.g_ret_sts_error;
	  END IF;
       END LOOP;

       CLOSE c_tasks;
     ELSE
       -- Bug# 4587423
       -- No valid rules exist for task type assignment so just stamp the org level
       -- default task type for the given WMS task type on the MMTT record.
       UPDATE mtl_material_transactions_temp mmtt
	 SET standard_operation_id =
	 (SELECT DECODE(mmtt.wms_task_type, 1, default_pick_task_type_id,
			2, default_putaway_task_type_id,
			3, default_cc_task_type_id,
			4, default_repl_task_type_id,
			5, default_moxfer_task_type_id,
			6, default_moissue_task_type_id,
			NULL)
	  FROM mtl_parameters mp WHERE mp.organization_id = mmtt.organization_id)
	 WHERE mmtt.standard_operation_id IS NULL
	   AND mmtt.move_order_line_id IN (SELECT line_id
					   FROM mtl_txn_request_lines mol
					   WHERE mol.header_id = p_move_order_header_id);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END assigntts;

  --
  -- API name    : AssignTT
  -- Type        : Private
  -- Function    : Assign task type to a specific record in MMTT
  -- Input Parameters  :
  --           p_task_id NUMBER
  --
  -- Output Parameters:
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       :
  --
  -- This procedure assign user defined task types to a specific task in
  -- mtl_material_transactions_temp. Task type is implemeted by WMS rules.
  -- This procedure calls the rule package created for task type rules to check
  -- which task type rule actually matches the task in question.
  --

  PROCEDURE assigntt(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2
  , p_commit           IN            VARCHAR2
  , p_validation_level IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_task_id          IN            NUMBER
   ) IS
    l_rule_id                   NUMBER;
    l_pack_exists               NUMBER;
    l_package_name              VARCHAR2(30);
    l_rule_func_sql             LONG;
    l_rule_result               NUMBER;
    l_cursor                    INTEGER;
    l_dummy                     NUMBER;
    l_count                     NUMBER;
    l_return_status             NUMBER;
    l_revision_dummy            VARCHAR2(10);
    l_lot_number_dummy          VARCHAR2(80);
    l_lot_expiration_date_dummy DATE;
    l_subinventory_code_dummy   VARCHAR2(10);
    l_locator_id_dummy          NUMBER;
    l_possible_qty_dummy        NUMBER;
    l_uom_code_dummy            VARCHAR2(3);
    l_order_by_string_dummy     VARCHAR2(1000);
    l_found                     BOOLEAN        := FALSE;
    l_organization_id           NUMBER;
    l_wms_task_type             NUMBER;
    l_task_type_id              NUMBER;
    l_type_hdr_id               NUMBER;

    l_api_version      CONSTANT NUMBER         := 1.0;
    l_api_name         CONSTANT VARCHAR2(30)   := 'AssignTT';

    l_debug                     NUMBER;


    -- Cursor for task type rule loop
    -- Only rules with the same WMS system task type as the task
    -- will be selected
    -- Rules are ordered by rule weight and creation date

    CURSOR c_rules IS
      SELECT   rules.rule_id
             , rules.type_hdr_id /* Added this Column */
             , mmtt.organization_id
             , mmtt.wms_task_type
          FROM wms_rules_b rules, bom_standard_operations bso , mtl_material_transactions_temp mmtt
         WHERE rules.type_code = 3
           AND rules.enabled_flag = 'Y'
           AND rules.type_hdr_id = bso.standard_operation_id
           AND bso.wms_task_type = NVL(mmtt.wms_task_type, bso.wms_task_type)
           AND mmtt.transaction_temp_id = p_task_id
           AND rules.organization_id IN (mmtt.organization_id, -1)
           AND bso.organization_id = mmtt.organization_id
      ORDER BY rules.rule_weight DESC, rules.creation_date;

  /*CURSOR c_rules_new IS
    SELECT   rules.rule_id ,  rules.type_hdr_id
	FROM wms_rules_b rules, bom_standard_operations bso
       WHERE rules.type_code = 3
	 AND rules.enabled_flag = 'Y'
	 AND rules.type_hdr_id = bso.standard_operation_id
	 AND bso.wms_task_type = NVL(p_wms_task_type, bso.wms_task_type)
	 AND rules.organization_id IN (p_organization_id, -1)
	 AND bso.organization_id = p_organization_id
    ORDER BY rules.rule_weight DESC, rules.creation_date; */

    -- Following Code is commented because now we need to get 2 more default task_type..MOISSUE and MOXFER
      /*CURSOR c_default_task_type IS
      SELECT default_pick_task_type_id
            ,default_cc_task_type_id
            ,default_putaway_task_type_id
            ,default_repl_task_type_id
        FROM mtl_parameters
       WHERE organization_id = l_organization_id;
      */

    CURSOR c_default_task_type IS
      SELECT default_pick_task_type_id
           , default_cc_task_type_id
           , default_putaway_task_type_id
           , default_repl_task_type_id
           , default_moxfer_task_type_id
           , default_moissue_task_type_id
           , default_pick_op_plan_id
        FROM mtl_parameters
       WHERE organization_id =  l_organization_id;

       l_rule_counter           INTEGER;
  BEGIN
    SAVEPOINT assignttsp;

    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;
    l_debug := g_debug;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    IF p_validation_level <> fnd_api.g_valid_level_none THEN
      -- in case further needs for validation
      NULL;
    END IF;

    OPEN c_rules; -- open the eligible rules cursor

    LOOP -- loop through the rules
      FETCH c_rules INTO l_rule_id, l_type_hdr_id, l_organization_id, l_wms_task_type;
      EXIT WHEN c_rules%NOTFOUND;

      --inv_log_util.TRACE('found the rule', 'RULE_ENGINE', 4);

      BEGIN
        -- get the pre-generated package name for this rule
        getpackagename(l_rule_id, l_package_name);

        --- Execute Task Rule

       -- execute_task_rule(l_rule_id, p_task_id, l_return_status);
        For l_rule_counter IN 1..2  LOOP
           IF l_debug = 1 THEN
              log_error(l_api_name, 'Assigntt', 'Inside Loop :l_rule_counter         ' || l_rule_counter);
              log_error(l_api_name, 'Assigntt', 'Calling execute_Task :l_rul        e_id ' || l_rule_id);
              log_error(l_api_name, 'Assigntt', 'Calling execute_Task :p_Tas        k_id ' || p_task_id);
           END IF;
           execute_task_rule(l_rule_id, p_task_id, l_return_status);
             IF (l_return_status = -1) and l_rule_counter   = 2 THEN --error
               fnd_message.set_name('WMS', 'WMS_PACKAGE_MISSING');
               fnd_message.set_token('RULEID', l_rule_id);
               fnd_msg_pub.ADD;
               IF l_debug = 1 THEN
                  log_error_msg(l_api_name, 'rule_package_missing');
                  log_statement(l_api_name, 'pack_name', 'Package name: ' || l_package_name);
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
             ELSIF  l_return_status <> -1 THEN
                EXIT;
             END IF;
        END LOOP;
        If l_debug = 1 THEN
           log_error(l_api_name, 'Assigntt', 'After Execute_Task :l_return_s        tatus ' || l_return_status);
        END IF;

        IF l_return_status > 0 THEN -- the rule matches the task
           l_found  := TRUE;

          -- update mmtt table to assign the task type

          UPDATE mtl_material_transactions_temp mmtt
             SET mmtt.standard_operation_id = l_type_hdr_id
           WHERE mmtt.transaction_temp_id = p_task_id;
           /*
           UPDATE mtl_material_transactions_temp mmtt
	                SET mmtt.standard_operation_id = (SELECT type_hdr_id
	                                                    FROM wms_rules_b
	                                                   WHERE rule_id = l_rule_id)
           WHERE mmtt.transaction_temp_id = p_task_id
           */

          EXIT; -- task assigned, jump out of the rule loop
        END IF; -- l_return_status > 0
      EXCEPTION -- handle exceptions for matching one rule
        WHEN fnd_api.g_exc_error THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END; -- end matching one rule
    END LOOP;

    CLOSE c_rules; --close the rule cursor

    -- get default task type
    IF NOT l_found THEN
     -- bug 2737846
     begin
      select organization_id, wms_task_type
       into  l_organization_id, l_wms_task_type
       from  mtl_material_transactions_temp
      where  transaction_temp_id = p_task_id;
     exception
        when others then
          null;
     end;

      --inv_log_util.TRACE('NOT found the rule: g_current_organization_id'||g_current_organization_id, 'RULE_ENGINE', 4);
      --inv_log_util.TRACE('NOT found the rule: l_organization_id:'||l_organization_id, 'RULE_ENGINE', 4);
      IF NVL(g_current_organization_id, -1) <> l_organization_id THEN
        g_current_organization_id  := l_organization_id;


        OPEN c_default_task_type;
        /*FETCH c_default_task_type INTO g_default_pick_task_type_id
                          ,g_default_cc_task_type_id
                          ,g_default_putaway_task_type_id
                          ,g_default_repl_task_type_id;
         */
        FETCH c_default_task_type INTO g_default_pick_task_type_id
                                     , g_default_cc_task_type_id
                                     , g_default_putaway_task_type_id
                                     , g_default_repl_task_type_id
                                     , g_default_moxfer_task_type_id
                                     , g_default_moissue_task_type_id
				     , g_default_operation_plan_id;

        IF c_default_task_type%NOTFOUND THEN
          g_current_organization_id       := NULL;
          g_default_pick_task_type_id     := NULL;
          g_default_cc_task_type_id       := NULL;
          g_default_putaway_task_type_id  := NULL;
          g_default_repl_task_type_id     := NULL;
          g_default_moxfer_task_type_id   := NULL;
          g_default_moissue_task_type_id  := NULL;
	  g_default_operation_plan_id	  := NULL;
          --inv_log_util.TRACE('default_task_type not found', 'RULE_ENGINE', 4);
        END IF;

        CLOSE c_default_task_type;
      END IF;

      --inv_log_util.TRACE('inside cursor c_defualt_task_type', 'RULE_ENGINE', 4);


      IF l_wms_task_type = 1 THEN
         l_task_type_id  := g_default_pick_task_type_id;
      ELSIF l_wms_task_type = 2 THEN
        l_task_type_id  := g_default_putaway_task_type_id;
      ELSIF l_wms_task_type = 3 THEN
        l_task_type_id  := g_default_cc_task_type_id; --g_default_repl_task_type_id; --Bug# 3110550
      ELSIF l_wms_task_type = 4 THEN
        l_task_type_id  := g_default_repl_task_type_id; --g_default_cc_task_type_id; --Bug# 3110550
      ELSIF l_wms_task_type = 5 THEN
        l_task_type_id  := g_default_moxfer_task_type_id;
      ELSIF l_wms_task_type = 6 THEN
        l_task_type_id  := g_default_moissue_task_type_id;
      ELSE
        l_task_type_id  := NULL;
      END IF;

      --inv_log_util.TRACE('wms_task_type = 1, task_type_id=:' || l_task_type_id, 'RULE_ENGINE', 4);
      --inv_log_util.TRACE('before update statement', 'RULE_ENGINE', 4);

      UPDATE mtl_material_transactions_temp mmtt
         SET mmtt.standard_operation_id = l_task_type_id
       WHERE mmtt.transaction_temp_id = p_task_id;

       --inv_log_util.TRACE('after update statement: standard_operation_id:'||jxlu_soi, 'RULE_ENGINE', 4);
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- if the rule package not created yet, close the rule cursor
      IF c_rules%ISOPEN THEN
        CLOSE c_rules;
      END IF;

      ROLLBACK TO assignttsp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO assignttsp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END assigntt;

  --
  -- API name    : CalcRuleWeight
  -- Type        : Private
  -- Function    : Calculate initial rule weight based on number of distinct restriction
  --               parameters. This is currently the requirement for task type assignment
  --
  -- Input Parameters  :
  --           p_task_id NUMBER
  --
  -- Output Parameters:
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       :
  --
  -- This procedure will be called by Define Rule form through generate rule package call

  PROCEDURE calcruleweight(p_rule_id NUMBER) IS
  BEGIN

    UPDATE wms_rules_b
       SET rule_weight = (SELECT 100 * COUNT(parameter_id)
                            FROM (SELECT DISTINCT rules.rule_id
                                                , par.parameter_id
                                             FROM wms_rules_b rules, wms_restrictions rest, wms_parameters_b par
                                            WHERE rules.rule_id = p_rule_id
                                              AND rules.rule_id = rest.rule_id(+)
                                              AND rest.parameter_id = par.parameter_id(+)
                                              AND (NVL(par.use_for_tt_assn_flag, 'Y') = 'Y'
                                                   OR NVL(par.use_for_label_rest_flag, 'Y') = 'Y'
                                                  )))
     WHERE rule_id = p_rule_id
       AND rule_weight IS NULL;


  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END calcruleweight;

  --===========================================================================================
  --
  -- API name    : ApplyLabel
  -- Type        : Private
  -- Function    : Retrieve Label based on Label request
  -- Input Parameters  :
  --           p_label_request_id  NUMBER
  --           p_document_id       NUMBER
  --
  -- Output Parameters: x_label_format_id
  -- Version     :
  -- Current version 1.0
  --
  -- Notes       :
  --
  -- This procedure retrieves a specific label for a label request in
  -- wms_label_requests.
  -- This procedure calls the rule package created for Label rules to check
  -- which label rule actually matches the label request in question.
  --===========================================================================
  PROCEDURE applylabel(
    p_api_version       IN            NUMBER
  , p_init_msg_list     IN            VARCHAR2
  , p_commit            IN            VARCHAR2
  , p_validation_level  IN            NUMBER
  , p_label_request_id  IN            NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  , x_label_format_id   OUT NOCOPY    NUMBER
  , x_label_format_name OUT NOCOPY    VARCHAR2
  ) IS
    l_rule_id              NUMBER;
    l_rule_weight          NUMBER;
    l_pack_exists          NUMBER;
    l_package_name         VARCHAR2(30);
    l_rule_func_sql        LONG;
    l_rule_result          NUMBER;
    l_cursor               INTEGER;
    l_dummy                NUMBER;
    l_count                NUMBER;
    l_return_status        NUMBER;
    l_label_format_id      NUMBER;
    l_document_id          NUMBER;
    l_label_format_name    wms_label_formats.label_format_name%TYPE;
    l_api_version CONSTANT NUMBER                                     := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                               := 'ApplyLabel';
    l_msg_data             VARCHAR2(2000);
    l_strategy_id          NUMBER                                     := NULL;


    -- Cursor for label rule loop
    -- Only rules with the type_code = 4
    -- will be selected
    -- Rules are ordered by rule weight and creation date

    CURSOR c_rules IS
      SELECT   rules.rule_id
             , rules.rule_weight
             , rules.type_hdr_id
             , wl.label_format_name
             , wl.document_id
          FROM wms_rules_b rules, wms_label_formats wl, wms_label_requests wlr
         WHERE rules.type_code = 4
           AND rules.type_hdr_id = wl.label_format_id
           AND wl.label_format_id = NVL(wlr.label_format_id, wl.label_format_id)
           AND NVL(format_disable_date, SYSDATE + 1) > SYSDATE   --Bug #3452076
           AND wlr.document_id = wl.document_id
           AND wlr.label_request_id = p_label_request_id
           AND rules.enabled_flag = 'Y'
           AND (rules.organization_id = wlr.organization_id
                OR rules.organization_id = -1
               ) -- Common to All Org.
      ORDER BY rules.rule_weight DESC, rules.creation_date;

    CURSOR l_default_label_curs IS
      SELECT label_format_id
           , label_format_name
        FROM wms_label_formats
       WHERE document_id = l_document_id
         AND default_format_flag IN ('Y', 'y');

    CURSOR l_label_requests_curs IS
      SELECT *
        FROM wms_label_requests
       WHERE label_request_id = p_label_request_id;

    l_label_req_rc         wms_label_requests%ROWTYPE;
    l_rule_counter           INTEGER;
    l_debug                  NUMBER;
    ll_ctr                   NUMBER;
  BEGIN
    SAVEPOINT assignlabelsp;
   ----
       SELECT   count(rules.rule_id ) into  ll_ctr
       FROM wms_rules_b rules, wms_label_formats wl, wms_label_requests wlr
       WHERE rules.type_code = 4
                  AND rules.type_hdr_id = wl.label_format_id
                  AND wl.label_format_id = NVL(wlr.label_format_id, wl.label_format_id)
                  AND NVL(format_disable_date, SYSDATE + 1) > SYSDATE   --Bug #        3452076
                  AND wlr.document_id = wl.document_id
                  AND wlr.label_request_id = p_label_request_id
                  AND rules.enabled_flag = 'Y'
                  AND (rules.organization_id = wlr.organization_id
                       OR rules.organization_id = -1
                  ) ;
   ----
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       TRACE('Executing ApplyLabel()...Label_request_ID :  '|| p_label_request_id);
       TRACE('Number of rules to process(LL_CTR) :' || ll_ctr);
    END IF;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    x_return_status      := fnd_api.g_ret_sts_success;

    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    IF p_validation_level <> fnd_api.g_valid_level_none THEN
      -- in case further needs for validation
      NULL;
    END IF;

    -- Retrieve document_id based on P_label_request_id

    OPEN l_label_requests_curs;
    FETCH l_label_requests_curs INTO l_label_req_rc;

    --dummy should = 2, one for package, one for package body
    IF (l_label_requests_curs%NOTFOUND) THEN
      CLOSE l_label_requests_curs;
      IF l_debug = 1 THEN
         TRACE('Invalid Label Request Id : '|| p_label_request_id);
      END IF;
      fnd_message.set_name('WMS', 'INVALID_LABEL_REQ');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    CLOSE l_label_requests_curs;

    l_document_id        := l_label_req_rc.document_id;
    IF l_debug = 1 THEN
       TRACE('Label request document Id : '|| l_document_id);
    END IF;
    l_return_status      := 0; -- Initialize to 0
    OPEN c_rules; -- open the eligible rules cursor

    LOOP -- loop through the rules
      FETCH c_rules INTO l_rule_id, l_rule_weight, l_label_format_id, l_label_format_name, l_label_req_rc.document_id;
      EXIT WHEN c_rules%NOTFOUND;
      -- get the pre-generated package name for this rule
      getpackagename(l_rule_id, l_package_name);

      FOR l_rule_counter IN 1..2  LOOP
           IF l_debug = 1 THEN
            log_error(l_api_name, 'AssignLabel', 'Inside Loop :l_rule_counter ' || l_rule_counter);
            log_error(l_api_name, 'AssignLabel', 'Calling execute_label :l_rule_id ' || l_rule_id);
            log_error(l_api_name, 'AssignLabel', 'p_label_request_id ' || p_label_request_id);
           END IF;
           execute_label_rule(l_rule_id, p_label_request_id, l_return_status);
           IF l_debug = 1 THEN
              log_statement(l_api_name, 'Inside Loop', 'l_return_status' || l_return_status);
           END IF;
           log_statement(l_api_name, 'pack_name', 'Package name: ' || l_package_name);
           IF (l_return_status = -1) and l_rule_counter   = 2 THEN --error
              fnd_message.set_name('WMS', 'WMS_PACKAGE_MISSING');
              fnd_message.set_token('RULEID', l_rule_id);
              fnd_msg_pub.ADD;
              IF l_debug = 1 THEN
                 log_error_msg(l_api_name, 'rule_package_missing');
                 log_error(l_api_name, 'Rule missing in the list pkg', 'l_rule_id ' || l_rule_id);
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status  <> -1 THEN
               EXIT;
            END IF;
      END LOOP;

      IF l_return_status > 0 THEN -- the rule matches the label request
        -- update wms_label_requests table with label_format_id


        UPDATE wms_label_requests wlr
           SET wlr.label_format_id = l_label_format_id
             , wlr.rule_id = l_rule_id
             , wlr.strategy_id = l_strategy_id
             , wlr.rule_weight = l_rule_weight
         WHERE wlr.label_request_id = p_label_request_id;
        IF l_debug = 1 THEN
           TRACE('Rule Match.Update Label Request with format ID :'|| l_label_format_id || ' ' || l_label_format_name);
        END IF;

        EXIT; -- label retrieved, jump out of the rule loop
      ELSIF (l_return_status = 0) THEN
        IF l_debug = 1 THEN
          trace('no rows found from procedure execute_label_rule()');
        END IF;
      END IF;
    END LOOP;

    CLOSE c_rules; --close the rule cursor

    -- ===================================================================
    -- Retrieve default label if there is no rule match the label request
    -- ===================================================================
    IF l_debug = 1 THEN
      trace('l_return_status : '|| l_return_status);
    END IF;

    IF (l_return_status = 0) THEN
      IF l_debug = 1 THEN
         TRACE('No rule match retrieve the default format ');
      END IF;
      --Bug: 2646648 Patchset I label cleanup
      --Reset l_label_format_id(name) to null
      -- before retrieving default format
        -- so that if no default format, it will have value null
      -- instead of the value from cursor c_rules
      l_label_format_id    := NULL;
      l_label_format_name  := NULL;
      OPEN l_default_label_curs;
      FETCH l_default_label_curs INTO l_label_format_id, l_label_format_name;
      CLOSE l_default_label_curs;
    END IF;

    -- update wms_label_requests table with label_format_id


    UPDATE wms_label_requests wlr
       SET wlr.label_format_id = l_label_format_id
     WHERE wlr.label_request_id = p_label_request_id;

    IF l_debug = 1 THEN
       TRACE('Update Label Request with label ID :'|| l_label_format_id || '.(' || SQL%ROWCOUNT || ')');
    END IF;

    --
    -- Assign x_label_format_id with l_label_format_id
    --
    x_label_format_id    := l_label_format_id;
    x_label_format_name  := l_label_format_name;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- if the rule package not created yet, close the rule cursor
      IF c_rules%ISOPEN THEN
        CLOSE c_rules;
      END IF;

      ROLLBACK TO assignlabelsp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      l_msg_data       := SQLERRM;
      IF l_debug = 1 THEN
         TRACE('EXCEPTION OTHERS: '|| l_msg_data);
      END IF;
      ROLLBACK TO assignlabelsp;
      freeglobals;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END applylabel;

  PROCEDURE get_wms_sys_task_type(
    p_move_order_type            IN            NUMBER
  , p_transaction_action_id      IN            NUMBER
  , p_transaction_source_type_id IN            NUMBER
  , x_wms_sys_task_type          OUT NOCOPY    NUMBER
  ) IS
  BEGIN
    IF p_move_order_type = 2 THEN -- replenishment
      x_wms_sys_task_type  := 4; -- replenishment
    ELSIF p_move_order_type IN (3,5) THEN -- Bug 2666620: BackFlush MO Type Removed
      x_wms_sys_task_type  := 1; -- pick
    ELSIF p_move_order_type = 6 THEN -- put away
      x_wms_sys_task_type  := 2;
    ELSIF (p_move_order_type = 1
           AND p_transaction_action_id = 1
           AND p_transaction_source_type_id = 4
          ) THEN -- MO Issue
      x_wms_sys_task_type  := 6;
    ELSIF (p_move_order_type = 1
           AND p_transaction_action_id = 2
           AND p_transaction_source_type_id = 4
          ) THEN -- MO Xfer
      x_wms_sys_task_type  := 5;
    END IF;
  END get_wms_sys_task_type;

  --Compile_All_Rule_Packages
  --  Concurrent program which generates rule packages
  -- for all rules with enabled flag = Y
  PROCEDURE compile_all_rule_packages(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER) IS
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    l_rule_id       NUMBER;
    l_error_string  VARCHAR2(240);
    l_errbuf        VARCHAR2(240);
    l_return_code   NUMBER;

    CURSOR l_enabled_rules IS
      SELECT   rule_id
          FROM wms_rules_b
         WHERE enabled_flag = 'Y'
      ORDER BY rule_id;
  BEGIN
    --fnd_file.put_names('genall.log', 'genall.out', '/home/jcearley/work/');
    retcode  := 0;
    --fnd_file.put_line(fnd_file.LOG, '===Compiling All Rule Packages===');
    OPEN l_enabled_rules;

    LOOP
      FETCH l_enabled_rules INTO l_rule_id;
      EXIT WHEN l_enabled_rules%NOTFOUND;
      --fnd_file.put_line(fnd_file.LOG, 'Compiling Rule ID= ' || l_rule_id);
      wms_rule_pvt.generaterulepackage(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_validation_level           => fnd_api.g_valid_level_full
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_rule_id                    => l_rule_id
      );

     --
     -- kkoothan  Bug Fix:2561401
     -- Used FND APIs to check the return status of the called procedure
     -- instead of using hard coded values.
     --
     IF (l_return_status = fnd_api.g_ret_sts_success) THEN
        FND_FILE.put_line(FND_FILE.LOG, 'Success from GenerateRulePackage');
     ELSE
        FND_FILE.put_line(FND_FILE.LOG, 'Error from GenerateRulePackage:');
        retcode  := 1;

        FOR i IN 1 .. l_msg_count LOOP
          --fnd_file.put_line(fnd_file.LOG, 'Error:');
          l_error_string  := fnd_message.get;
          --fnd_file.put_line(fnd_file.LOG, l_error_string);
          errbuf          := errbuf || ' Error: Rule ' || l_rule_id || '
          ' || l_error_string;
        END LOOP;
      END IF;
    END LOOP;

    --- Calling procedure to generate all rule list packages
    --- this package should be called stand alone .
    buildrulespkg(l_errbuf, l_return_code, l_return_status);

    IF (l_return_status = fnd_api.g_ret_sts_success) THEN
      FND_FILE.put_line(FND_FILE.LOG, 'Success from BuildRulesPkg');
    ELSE
      FND_FILE.put_line(FND_FILE.LOG, 'Error from BuildRulesPkg:');
      retcode  := 1;

      FOR i IN 1 .. l_msg_count LOOP
        --fnd_file.put_line(fnd_file.LOG, 'Error:');
        l_error_string  := fnd_message.get;
        --fnd_file.put_line(fnd_file.LOG, l_error_string);
        errbuf          := errbuf || ' Error: Creating WMS Rule List Package ' || l_error_string;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      retcode  := 2;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Compile All Rule Packages');
      END IF;

      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      --fnd_file.put_line(fnd_file.LOG, 'Exception in compile_all_rule_packages');
      --fnd_file.put_line(fnd_file.LOG, l_msg_data);
      errbuf   := errbuf || 'Error: ' || l_msg_data;
  END compile_all_rule_packages;

    --
    --
    PROCEDURE QuickPick
      (p_api_version                  IN   NUMBER                              ,
       p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
       p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
       p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
       x_return_status                OUT  NOCOPY   VARCHAR2                            ,
       x_msg_count                    OUT  NOCOPY   NUMBER 	                           ,
       x_msg_data                     OUT  NOCOPY   VARCHAR2                            ,
       p_type_code                    IN   NUMBER   DEFAULT NULL ,
       p_transaction_temp_id          IN   NUMBER   DEFAULT NULL ,
       p_organization_id              IN   NUMBER   DEFAULT NULL ,
       p_inventory_item_id            IN   NUMBER   DEFAULT NULL ,
       p_transaction_uom              IN   VARCHAR2 DEFAULT NULL,
       p_primary_uom                  IN   VARCHAR2 DEFAULT NULL,
       p_secondary_uom                IN   VARCHAR2 DEFAULT NULL,                  -- new
       p_grade_code                   IN   VARCHAR2 DEFAULT NULL,                  -- new
       p_transaction_type_id          IN   NUMBER   DEFAULT NULL ,
       p_tree_id                      IN   NUMBER   DEFAULT NULL ,
       x_finished                     OUT  NOCOPY   VARCHAR2 			   ,
       p_detail_serial                IN   BOOLEAN  DEFAULT FALSE 		   ,
       p_from_serial                  IN   VARCHAR2 DEFAULT NULL 		   ,
       p_to_serial                    IN   VARCHAR2 DEFAULT NULL 		   ,
       p_detail_any_serial            IN   NUMBER   DEFAULT NULL,
       p_unit_volume                  IN   NUMBER   DEFAULT NULL,
       p_volume_uom_code              IN   VARCHAR2 DEFAULT NULL,
       p_unit_weight                  IN   NUMBER   DEFAULT NULL,
       p_weight_uom_code              IN   VARCHAR2 DEFAULT NULL,
       p_base_uom_code                IN   VARCHAR2 DEFAULT NULL,
       p_lpn_id                       IN   NUMBER   DEFAULT NULL,
       p_unit_number                  IN   VARCHAR2 DEFAULT NULL,
       p_simulation_mode              IN   NUMBER   DEFAULT -1,
       p_project_id                   IN   NUMBER   DEFAULT NULL,
       p_task_id                      IN   NUMBER   DEFAULT NULL
       )
        IS

          -- API standard variables
            l_api_version   CONSTANT NUMBER              := 1.0;
            l_api_name      CONSTANT VARCHAR2(30)        := 'QuickPick';
            l_debug_on               BOOLEAN;

            --  input variables

            l_pp_transaction_temp_id wms_transactions_temp.pp_transaction_temp_id%TYPE; --
            l_revision               wms_transactions_temp.revision%TYPE;               --
            l_lot_number             wms_transactions_temp.lot_number%TYPE;             --
            l_lot_expiration_date    wms_transactions_temp.lot_expiration_date%TYPE;    --
            l_from_subinventory_code wms_transactions_temp.from_subinventory_code%TYPE; --
            l_to_subinventory_code   wms_transactions_temp.to_subinventory_code%TYPE;   --
            l_subinventory_code      wms_transactions_temp.to_subinventory_code%TYPE;
            l_from_locator_id        wms_transactions_temp.from_locator_id%TYPE;        --
            l_to_locator_id          wms_transactions_temp.to_locator_id%TYPE;          --
            l_locator_id             wms_transactions_temp.to_locator_id%TYPE;
            l_from_cost_group_id     wms_transactions_temp.from_cost_group_id%TYPE;     --
            l_to_cost_group_id       wms_transactions_temp.to_cost_group_id%TYPE;       --
            l_cost_group_id          wms_transactions_temp.to_cost_group_id%TYPE;
            l_lpn_id                 wms_transactions_temp.lpn_id%TYPE;                 --
            l_initial_pri_quantity   wms_transactions_temp.primary_quantity%TYPE;

            l_reservation_id         NUMBER; --
            l_needed_quantity        NUMBER; --
            l_sec_needed_quantity    NUMBER; --           -- new
            l_grade_code             VARCHAR2(150); --           -- new
            l_cur_rec                NUMBER;

            -- variables needed for qty tree
            l_qoh                    NUMBER;
            l_rqoh                   NUMBER;
            l_qr                     NUMBER;
            l_qs                     NUMBER;
            l_att                    NUMBER;
            l_atr                    NUMBER;
            l_tree_mode              NUMBER;
            l_tree_id                NUMBER;
            l_sqoh                    NUMBER;           -- new
            l_srqoh                   NUMBER;           -- new
            l_sqr                     NUMBER;           -- new
            l_sqs                     NUMBER;           -- new
            l_satt                    NUMBER;           -- new
            l_satr                    NUMBER;           -- new

            l_inserted_record        BOOLEAN;
            l_allocated_quantity     NUMBER;
            l_remaining_quantity     NUMBER;
            l_finished               VARCHAR2(1);
            l_sec_allocated_quantity     NUMBER;           -- new
            l_sec_remaining_quantity     NUMBER;           -- new

           --   Variables to check if Item is Lot and serial contriled

            l_lot_status_enabled      VARCHAR2(1);
            l_default_lot_status_id   NUMBER := NULL;
            l_serial_status_enabled   VARCHAR2(1);
            l_default_serial_status_id NUMBER;


            l_serial_control_code     NUMBER;
            l_is_serial_control       NUMBER;

            l_unit_number             VARCHAR2(30);
            l_allowed                 VARCHAR2(1) := 'Y';
            l_serial_allowed          VARCHAR2(1) := 'Y';

            g_trace_recs              wms_search_order_globals_pvt.pre_suggestions_record_tbl;

            l_debug                  NUMBER;         -- 1 for debug is on , 0 for debug is off
            l_progress               VARCHAR2(10);   -- local variable to track program progress,

                                                     -- especially useful when exception occurs
            l_serial_number          NUMBER;         -- [ new code ]

	  -- LPN Status Project
             l_onhand_status_trx_allowed VARCHAR2(1);
             l_default_status_id        NUMBER ;
          -- LPN Status Project

          cursor lpn_serial_cur(l_lpn_id NUMBER ) is
          SELECT STATUS_ID FROM MTL_SERIAL_NUMBERS
          WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
          AND LPN_ID = l_lpn_id;


  BEGIN

     IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;
     l_debug := g_debug;
     l_progress := 10;

     l_tree_id := p_tree_id;

     IF l_debug = 1 THEN
        log_procedure(l_api_name, 'QuickPick', 'enter '|| g_pkg_name || '.' || l_api_name);
     END IF;
     -- end of debugging section
     --
     -- Standard start of API savepoint
     SAVEPOINT  QuickPicksp;

     -- Standard call to check for call compatibility
     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE
     IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status  := fnd_api.g_ret_sts_success;
     -- Initialize functional return status to completed
     x_finished       := fnd_api.g_true;
     -- Validate input parameters and pre-requisites, if validation level
     -- requires this

     IF p_validation_level <> fnd_api.g_valid_level_none THEN
       IF l_debug = 1 THEN
          log_statement(l_api_name, 'Quick Pick',
        'p_validation_level <> fnd_api.g_valid_level_none ');
       END IF;

     IF p_type_code IS NULL
        OR p_type_code = fnd_api.g_miss_num
        OR p_type_code = 1 THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_message.set_name('WMS', 'WMS_RULE_TYPE_CODE_MISSING');
           log_error_msg(l_api_name, 'type_code_missing');
           fnd_msg_pub.ADD;
        END IF;
        RAISE fnd_api.g_exc_error;
     END IF;

     IF l_debug = 1 THEN
        log_statement(l_api_name, 'Quick Pick',
                 'p_transaction_temp_id  ' || p_transaction_temp_id );
     END IF;

     IF p_transaction_temp_id IS NULL
        OR p_transaction_temp_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_message.set_name('WMS', 'WMS_TRX_REQ_LINE_ID_MISS');
           log_error_msg(l_api_name, 'trx_req_line_id_missing');
           fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
     END IF;

     IF l_debug = 1 THEN
        log_statement(l_api_name, 'Quick Pick',
           'p_organization_id   ' ||  p_organization_id  );
     END IF;

  	     IF p_organization_id IS NULL
  	        OR p_organization_id = fnd_api.g_miss_num THEN
  	        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
  	           fnd_message.set_name('INV', 'INV_NO_ORG_INFORMATION');
  	           log_error_msg(l_api_name, 'org_id_missing');
  	           fnd_msg_pub.ADD;
  	        END IF;

  	        RAISE fnd_api.g_exc_error;
  	     END IF;

             IF l_debug = 1 THEN
	        log_statement(l_api_name, 'Quick Pick',
	       		    'p_Inventory_item_id_id   ' ||  p_inventory_item_id );
              END IF;

  	     IF p_inventory_item_id IS NULL
  	        OR p_inventory_item_id = fnd_api.g_miss_num THEN
  	        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
  	           fnd_message.set_name('INV', 'INV_ITEM_ID_REQUIRED');
  	           log_error_msg(l_api_name, 'item_id_missing');
  	           fnd_msg_pub.ADD;
  	        END IF;

  	        RAISE fnd_api.g_exc_error;
  	      END IF;

            /**  Commented for bug 4006426
              IF l_debug = 1 THEN
 	        log_statement(l_api_name, 'Quick Pick', 'qty Tree =>' || p_tree_id );
              END IF;

  	      IF  (p_tree_id IS NULL
  		 OR p_tree_id = fnd_api.g_miss_num
  		) THEN
  	        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
  	           fnd_message.set_name('INV', 'INV_QTY_TREE_ID_MISSING');
  	           log_error_msg(l_api_name, 'qty_tree_id_missing');
  	           fnd_msg_pub.ADD;
  	         END IF;

  	         RAISE fnd_api.g_exc_error;
  	        END IF;

                IF l_debug = 1 THEN
 	           log_statement(l_api_name, 'Quick Pick', 'finished validations and qty tree init' );
                END IF;
                */
            END IF;

   -- LPN Status Project
            if (inv_cache.set_org_rec(p_organization_id)) then
               l_default_status_id :=  nvl(inv_cache.org_rec.default_status_id,-1);
            end if;
  -- LPN Status Project
             --
             -- backup qty tree
           If p_tree_id IS NOT NULL  THEN  -- Added for bug # 4006426

            IF l_debug = 1 THEN
              log_statement(l_api_name, 'backup_tree',
                'Calling inv_quantity_tree_pvt.backup_tree');
            END IF;

           inv_quantity_tree_pvt.backup_tree(x_return_status, p_tree_id);

           IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'backup_tree_unexp_err',
                'Unexpected error from inv_quantity_tree_pvt.backup_tree');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
           ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              IF l_debug = 1 THEN
                 log_statement(l_api_name, 'backup_tree_err',
                'Error from inv_quantity_tree_pvt.backup_tree');
              END IF;
              RAISE fnd_api.g_exc_error;
           END IF;
        END IF;   --- Added for bug # 4006426

           g_locs_index       	:= 0;
           g_locs.DELETE;
           l_cur_rec      	:= 0; 	 --initialize pointer to next rec

           IF l_debug = 1 THEN
 	      log_statement(l_api_name, 'Quick Pick',
 	                    'Check if item is lot  status / Serial Status  enabled');
           END IF;

           --Check if item is lot  status / Serial Status  enabled --
           inv_material_status_grp.get_lot_serial_status_control(
          	 p_organization_id	 	=> p_organization_id
          	,p_inventory_item_id	 	=> p_inventory_item_id
          	,x_return_status	 	=> x_return_status
          	,x_msg_count		 	=> x_msg_count
          	,x_msg_data		 	=> x_msg_data
          	,x_lot_status_enabled    	=> l_lot_status_enabled
          	,x_default_lot_status_id    	=> l_default_lot_status_id
          	,x_serial_status_enabled    	=> l_serial_status_enabled
          	,x_default_serial_status_id 	=> l_default_serial_status_id);

           wms_re_common_pvt.initinputpointer; -- Initialize the pointer
                   			       -- to the first trx detail input line

           IF l_debug = 1 THEN
 	      log_statement(l_api_name, 'Quick Pick',
 	                   'Initialize the pointer to the first trx detail input line');
 	      log_statement(l_api_name, 'Quick Pick',
 	                   'Loop through all the trx detail input lines');
           END IF;

               -- Loop through all the trx detail input lines
               WHILE TRUE LOOP
                  IF l_debug = 1 THEN
                     log_statement(l_api_name, 'Quick Pick',
 	                   'Get the next trx detail input line ');
                  END IF;

                  -- Get the next trx detail input line
                  wms_re_common_pvt.getnextinputline(
                         l_pp_transaction_temp_id
                       , l_revision
                       , l_lot_number
                       , l_lot_expiration_date
                       , l_from_subinventory_code
                       , l_from_locator_id
                       , l_from_cost_group_id
                       , l_to_subinventory_code
                       , l_to_locator_id
                       , l_to_cost_group_id
                       , l_needed_quantity
                       , l_sec_needed_quantity
                       , l_grade_code
                       , l_reservation_id
                       , l_serial_number -- [ new code ]
                       , l_lpn_id
                  );
                 EXIT WHEN l_pp_transaction_temp_id IS NULL;
                 IF l_debug = 1 THEN
		    log_statement(l_api_name, 'Quick Pick',
		  	          'Get sub/Locator /Lot / serial status allowed'  || l_needed_quantity );
                 END IF;
              -- Get sub/Locator /Lot / serial status allowed  --

         --LPN Status Project
                   IF l_debug = 1 THEN
	                log_statement(l_api_name, 'Came to LPN Status Project ', l_onhand_status_trx_allowed);
                    END IF;


                l_onhand_status_trx_allowed := 'Y';

               IF l_default_status_id = -1 THEN
                    l_onhand_status_trx_allowed:='N';

                   -- Get sub/Locator /Lot / serial status allowed  --
                  l_allowed  := inv_detail_util_pvt.is_sub_loc_lot_trx_allowed(
          			p_transaction_type_id        => p_transaction_type_id
          		      , p_organization_id            => p_organization_id
          		      , p_inventory_item_id          => p_inventory_item_id
          		      , p_subinventory_code          => l_from_subinventory_code
          		      , p_locator_id                 => l_from_locator_id
          		      , p_lot_number                 => l_lot_number );
         		IF (  l_allowed =  'N') then
      			      WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_ATT_SUB_STATUS_NA';
			      fnd_message.set_name('WMS', 'WMS_ATT_SUB_STATUS_NA');
			      fnd_msg_pub.ADD;
                              fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
			       IF l_debug = 1 THEN
      				  log_error_msg(l_api_name, x_msg_data);
			       END IF;
                        END IF;


               ELSE
                     l_allowed:='N';
                     if (inv_cache.item_rec.serial_number_control_code in (1,6)) then
		            l_onhand_status_trx_allowed := inv_detail_util_pvt.is_onhand_status_trx_allowed(
                                         p_transaction_type_id
                                        ,p_organization_id
                                        ,p_inventory_item_id
                                        ,l_from_subinventory_code
                                        ,l_from_locator_id
                                        ,l_lot_number
		                        , l_lpn_id);

	 	              IF l_debug = 1 THEN
	                         log_statement(l_api_name, 'l_onhand_status_trx_allowed ', l_onhand_status_trx_allowed);
                              END IF;

			   IF (l_onhand_status_trx_allowed =  'N') then
      			          WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_DISALLOW_TRANSACTION';
			          fnd_message.set_name('WMS', 'WMS_DISALLOW_TRANSACTION');
			          fnd_msg_pub.ADD;
                                  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
			              IF l_debug = 1 THEN
      	           			  log_error_msg(l_api_name, x_msg_data);
			               END IF;
                            END IF;
       	           end if; -- if (inv_cache.item_rec.serial_number_control_code in (1,6))

	         END IF;  -- IF l_default_status_id = -1

             --LPN Status Project

                 IF ( l_serial_status_enabled = 'Y') then
                      IF l_debug = 1 THEN
		 	 log_statement(l_api_name, 'Quick Pick',
		 	     'inside If l_serial_status_enabled =  y ') ;
		 	 log_statement(l_api_name, 'Quick Pick',
		 	    'Calling inv_detail_util_pvt.is_serial_trx_allowed');
                      END IF;
                      --bug 7171840 changed the code to check the status at serial level rather than item defualt status
                      FOR L_LPN_CUR IN lpn_serial_cur(l_lpn_id) LOOP
                              l_serial_allowed := inv_detail_util_pvt.is_serial_trx_allowed(
                              p_transaction_type_id   => p_transaction_type_id
                            ,p_organization_id       => p_organization_id
                            ,p_inventory_item_id     => p_inventory_item_id
                            ,p_serial_status         => L_LPN_CUR.STATUS_ID ) ;

                        IF L_SERIAL_ALLOWED = 'N' THEN
                           log_statement(l_api_name, 'Quick Pick',
		 		  	          'inside If l_serial_status_enabled =  N ') ;
                          EXIT;
                       END IF;
                       L_SERIAL_ALLOWED := 'Y';
                   END LOOP ;
                      /* commented out for bug 7171840
                      l_serial_allowed := inv_detail_util_pvt.is_serial_trx_allowed(
          	              p_transaction_type_id   => p_transaction_type_id
          	             ,p_organization_id       => p_organization_id
          	             ,p_inventory_item_id     => p_inventory_item_id
            	             ,p_serial_status         => l_default_serial_status_id ) ;
                         end of bug 7171848*/

                 ELSIF ( l_serial_status_enabled = 'N') then
                     IF l_debug = 1 THEN
		        log_statement(l_api_name, 'Quick Pick',
		 		  	          'inside If l_serial_status_enabled =  N ') ;
                     END IF;
                     l_serial_allowed :=  'Y' ;
                 END IF;

                 l_cur_rec := l_cur_rec + 1 ;

                 -- Bug # 5512287
		 g_locs(l_cur_rec).quantity            :=  l_needed_quantity;
                 g_locs(l_cur_rec).secondary_quantity  :=  l_sec_needed_quantity;

            	 g_locs(l_cur_rec).revision 		:=  l_revision;
          	 g_locs(l_cur_rec).lot_number 		:=  l_lot_number;
          	 g_locs(l_cur_rec).subinventory_code	:=  l_from_subinventory_code;
          	 g_locs(l_cur_rec).locator_id		:=  l_from_locator_id;
          	 g_locs(l_cur_rec).cost_group_id	:=  l_from_cost_group_id;
          	 g_locs(l_cur_rec).lpn_id		:=  l_lpn_id;

          	 --add record to table
      		 g_locs_index            := g_locs_index + 1;

      		 IF l_debug = 1 THEN
      		    log_statement(l_api_name, 'loc_index', 'loc index: ' || g_locs_index);
                 END IF;

      		IF l_debug = 1 THEN
          	   log_statement(l_api_name, 'validate_and_insert', 'Calling  validate_and_insert');
          	   log_statement(l_api_name, 'validate_and_insert', 'p_record_id 	'||  l_cur_rec);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_needed_quantity 	'||  l_needed_quantity);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_needed_sec_quantity 	'||  l_sec_needed_quantity);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_organization_id 	'||  p_organization_id);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_inventory_item_id'||  p_inventory_item_id);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_to_subinventory_code'|| l_to_subinventory_code);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_to_locator_id 	'||  l_to_locator_id);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_to_cost_group_id '||   l_to_cost_group_id );
          	   log_statement(l_api_name, 'validate_and_insert', 'p_primary_uom 	'||   p_primary_uom);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_transaction_uom 	'||   p_transaction_uom);
          	   log_statement(l_api_name, 'validate_and_insert', 'p_transaction_temp_id'|| p_transaction_temp_id );
             	   log_statement(l_api_name, 'validate_and_insert', 'p_type_code 	'||   p_type_code );
  		   log_statement(l_api_name, 'validate_and_insert', 'p_reservation_id  	'||   l_reservation_id  );
          	   log_statement(l_api_name, 'validate_and_insert', 'p_tree_id 		'||   l_tree_id);
          	   log_statement(l_api_name, 'validate_and_insert', 'Insert an Output record into WTT if status allowed');
  		 END IF;
  		 --  Insert an Output record into WTT if status allowed
  		 --
  	--LPN Status Project

                IF l_debug = 1 THEN
			 log_statement(l_api_name, 'l_onhand_status_trx_allowed: ', l_onhand_status_trx_allowed);
		         log_statement(l_api_name, 'l_allowed: ', l_allowed);
			 log_statement(l_api_name, 'l_serial_allowed: ', l_serial_allowed);
		 END IF;


              IF ( ( nvl(l_allowed, 'Y') =  'Y' OR l_onhand_status_trx_allowed='Y') and  nvl(l_serial_allowed, 'Y')  =  'Y') then
        --LPN Status Project
                 IF p_tree_id IS NOT NULL THEN  -- Added for bug #4006426

                    IF l_debug = 1 THEN
                       log_statement(l_api_name, 'Calling validate_and_insert', '');
                    END IF;
                      validate_and_insert(
                       x_return_status              => x_return_status
                     , x_msg_count                  => x_msg_count
                     , x_msg_data                   => x_msg_data
                     , p_record_id                  => l_cur_rec
                     , p_needed_quantity            => l_needed_quantity
                     , p_use_pick_uom               => FALSE
                     , p_organization_id            => p_organization_id
                     , p_inventory_item_id          => p_inventory_item_id
                     , p_to_subinventory_code       => l_to_subinventory_code
                     , p_to_locator_id              => l_to_locator_id
                     , p_to_cost_group_id           => l_to_cost_group_id
                     , p_primary_uom                => p_primary_uom
                     , p_transaction_uom            => p_transaction_uom
                     , p_transaction_temp_id        => p_transaction_temp_id
                     , p_type_code                  => p_type_code
                     , p_rule_id                    => 0
                     , p_reservation_id             => l_reservation_id
                     , p_tree_id                    => l_tree_id
                     , p_debug_on                   => l_debug_on
                     , p_needed_sec_quantity        => l_sec_needed_quantity
                     , p_secondary_uom              => p_secondary_uom
                     , p_grade_code                 => p_grade_code
                     , x_inserted_record            => l_inserted_record
                     , x_allocated_quantity         => l_allocated_quantity
                     , x_remaining_quantity         => l_remaining_quantity
                     , x_sec_allocated_quantity     => l_sec_allocated_quantity
                     , x_sec_remaining_quantity     => l_sec_remaining_quantity
                     );
                 ELSIF p_tree_id is NULL THEN  -- Call the new local procedure validate_and_insert_noqtytree() for bug #4006426

                       IF l_debug = 1 THEN
                          log_statement(l_api_name, 'Calling validateNinsert', '');
                       END IF;

                         ValidNinsert(
                             x_return_status              => x_return_status
                           , x_msg_count                  => x_msg_count
                           , x_msg_data                   => x_msg_data
                           , p_record_id                  => l_cur_rec
                           , p_needed_quantity            => l_needed_quantity
                           , p_use_pick_uom               => FALSE
                           , p_organization_id            => p_organization_id
                           , p_inventory_item_id          => p_inventory_item_id
                           , p_to_subinventory_code       => l_to_subinventory_code
                           , p_to_locator_id              => l_to_locator_id
                           , p_to_cost_group_id           => l_to_cost_group_id
                           , p_primary_uom                => p_primary_uom
                           , p_transaction_uom            => p_transaction_uom
                           , p_transaction_temp_id        => p_transaction_temp_id
                           , p_type_code                  => p_type_code
                           , p_rule_id                    => 0
                           , p_reservation_id             => l_reservation_id
                           , p_tree_id                    => l_tree_id
                           , p_debug_on                   => l_debug_on
                           , x_inserted_record            => l_inserted_record
                           , x_allocated_quantity         => l_allocated_quantity
                           , x_remaining_quantity         => l_remaining_quantity
                           );
                 END IF;

                   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                      IF l_debug = 1 THEN
                                log_statement(l_api_name, 'uerr_validate_insert',
                                        'Unexpected error in validate_and_insert');
                         END IF;
                         RAISE fnd_api.g_exc_unexpected_error;
                      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                         IF l_debug = 1 THEN
                            log_statement(l_api_name, 'err_validate_insert', 'Error in validate_and_insert');
                         END IF;
                         RAISE fnd_api.g_exc_error;
                      END IF;

                      IF l_inserted_record = FALSE   OR l_allocated_quantity < l_needed_quantity THEN
                         fnd_message.set_name('WMS', 'WMS_LPN_UNAVAILABLE');  --- to be Added to Mesg Dict
                         fnd_msg_pub.ADD;
                         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
                         IF l_debug = 1 THEN
                          log_error_msg(l_api_name, x_msg_data);
                         END IF;

                         WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_LPN_UNAVAILABLE';
                         IF p_tree_id IS NOT NULL THEN  -- Bug# 4006426

                             IF l_debug = 1 THEN
                                log_statement(l_api_name, 'insert_failed', 'Record failed to allocation.  Rolling back and ' || 'invalidating LPN');
                                log_statement(l_api_name, 'restore_tree', 'Calling restore_tree');
                             END IF;
                             inv_quantity_tree_pvt.restore_tree(x_return_status => x_return_status, p_tree_id => p_tree_id);
                         END IF; -- Bug # 4006426
                       END IF;

                         IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                            IF l_debug = 1 THEN
                               log_error(l_api_name, 'uerr_restore_tree', 'Unexpected error in restore_tree');
                            END IF;
                            RAISE fnd_api.g_exc_unexpected_error;
                         ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                            IF l_debug = 1 THEN
                               log_error(l_api_name, 'err_restore_tree', 'Error in restore_tree');
                            END IF;
                            RAISE fnd_api.g_exc_error;
                         END IF;
                      ELSE

			 IF (  l_allowed =  'N') then
			       WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_ATT_SUB_STATUS_NA';
			       fnd_message.set_name('WMS', 'WMS_ATT_SUB_STATUS_NA');
			       fnd_msg_pub.ADD;

			       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
			       IF l_debug = 1 THEN
				  log_error_msg(l_api_name, x_msg_data);
			       END IF;

			 ELSIF l_serial_allowed =  'N' then
			       WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE := 'WMS_ATT_SERIAL_STATUS_NA' ;
			       fnd_message.set_name('WMS', 'WMS_ATT_SUB_STATUS_NA');
			       fnd_msg_pub.ADD;
			       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

			       IF l_debug = 1 THEN
				  log_error_msg(l_api_name, x_msg_data);
			       END IF;
			 END IF;
                      END IF;

                   -- <<nextoutputrecord>>
                   l_cur_rec  := g_locs(l_cur_rec).next_rec;

                END LOOP;
      EXCEPTION
          WHEN fnd_api.g_exc_error THEN

                ROLLBACK TO QuickPicksp;
                freeglobals;
                x_return_status  := fnd_api.g_ret_sts_error;
                fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

                IF l_debug = 1 THEN
                   log_error(l_api_name, 'error', 'Expected error - ' || x_msg_data);
                END IF;

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO QuickPicksp;
                freeglobals;
                x_return_status  := fnd_api.g_ret_sts_unexp_error;
                fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

                IF l_debug = 1 THEN
                   log_error(l_api_name, 'unexp_error', 'Unexpected error - ' || x_msg_data);
                END IF;

          WHEN OTHERS THEN
                ROLLBACK TO QuickPicksp;
                freeglobals;
                x_return_status  := fnd_api.g_ret_sts_unexp_error;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                  fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                END IF;
                fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

                IF l_debug = 1 THEN
                   log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);
                END IF;
      END QuickPick;

  -- LG convergence
  --
  -- API name    : get_available_inventory
  -- Type        : Private
  -- Function    : Applies a wms rule to the given transaction
  --               input parameters and creates recommendations
  -- Pre-reqs    : Record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
  --               identified by parameters p_transaction_temp_id and
  --               p_type_code ( base table for the view is
  --               MTL_MATERIAL_TRANSACTIONS_TEMP );
  --               At least one transaction detail record in
  --               WMS_TRX_DETAILS_TMP_V identified by line type code = 1
  --               and parameters p_transaction_temp_id and p_type_code
  --               ( base tables are MTL_MATERIAL_TRANSACTIONS_TEMP and
  --               WMS_TRANSACTIONS_TEMP, respectively );
  --               Rule record has to exist in WMS_RULES_B uniquely
  --               identified by parameter p_rule_id;
  --     Package WMS_RULE_(RULEID) must exist;
  --               If picking, quantity tree has to exist, created through
  --               INV_Quantity_Tree_PVT.Create_Tree and uniquely identified
  --               by parameter p_tree_id
  -- Parameters  :
  --   p_api_version          Standard Input Parameter
  --   p_init_msg_list        Standard Input Parameter
  --   p_commit               Standard Input Parameter
  --   p_validation_level     Standard Input Parameter
  --   p_rule_id              Identifier of the rule to apply
  --   p_type_code            Type code of the rule
  --   p_partial_success_allowed_flag
  --            'Y' or 'N'
  --   p_transaction_temp_id  Identifier for the record in view
  --            wms_strategy_mat_txn_tmp_v that represents
  --            the request for detailing
  --   p_organization_id      Organization identifier
  --   p_inventory_item_id    Inventory item identifier
  --   p_transaction_uom      Transaction UOM code
  --   p_primary_uom          Primary UOM code
  --   p_tree_id              Identifier for the quantity tree
  --
  -- Output Parameters
  --   x_return_status        Standard Output Parameter
  --   x_msg_count            Standard Output Parameter
  --   x_msg_data             Standard Output Parameter
  --   x_finished             whether the rule has found enough quantity to
  --                          find a location that completely satisfy
  --                          the requested quantity (value is 'Y' or 'N')
  --
  -- Version
  --   Currently version is 1.0
  --
  -- Notes       : Calls API's of WMS_Common_PVT and INV_Quantity_Tree_PVT
  --               This API must be called internally by
  --               WMS_Strategy_PVT.Apply only !
  --APPLY
  PROCEDURE get_available_inventory(
    p_api_version                  IN            NUMBER
  , p_init_msg_list                IN            VARCHAR2
  , p_commit                       IN            VARCHAR2
  , p_validation_level             IN            NUMBER
  , x_return_status                OUT NOCOPY    VARCHAR2
  , x_msg_count                    OUT NOCOPY    NUMBER
  , x_msg_data                     OUT NOCOPY    VARCHAR2
  , p_rule_id                      IN            NUMBER
  , p_type_code                    IN            NUMBER
  , p_partial_success_allowed_flag IN            VARCHAR2
  , p_transaction_temp_id          IN            NUMBER
  , p_organization_id              IN            NUMBER
  , p_inventory_item_id            IN            NUMBER
  , p_transaction_uom              IN            VARCHAR2
  , p_primary_uom                  IN            VARCHAR2
  , p_transaction_type_id          IN            NUMBER
  , p_tree_id                      IN            NUMBER
  , x_finished                     OUT NOCOPY    VARCHAR2
  , p_detail_serial                IN            BOOLEAN
  , p_from_serial                  IN            VARCHAR2
  , p_to_serial                    IN            VARCHAR2
  , p_detail_any_serial            IN            NUMBER
  , p_unit_volume                  IN            NUMBER
  , p_volume_uom_code              IN            VARCHAR2
  , p_unit_weight                  IN            NUMBER
  , p_weight_uom_code              IN            VARCHAR2
  , p_base_uom_code                IN            VARCHAR2
  , p_lpn_id                       IN            NUMBER
  , p_unit_number                  IN            VARCHAR2
  , p_simulation_mode              IN            NUMBER
  , p_project_id                   IN            NUMBER
  , p_task_id                      IN            NUMBER
  ) IS
    -- API standard variables
    l_api_version   CONSTANT NUMBER                                              := 1.0;
    l_api_name      CONSTANT VARCHAR2(30)                                        := 'Apply';
    -- variables needed for dynamic SQL
    l_cursor                 INTEGER;
    l_rows                   INTEGER;
    -- rule dynamic SQL input variables
    l_pp_transaction_temp_id wms_transactions_temp.pp_transaction_temp_id%TYPE;
    l_revision               wms_transactions_temp.revision%TYPE  := null;
    l_lot_number             wms_transactions_temp.lot_number%TYPE  := null;
    l_lot_expiration_date    wms_transactions_temp.lot_expiration_date%TYPE;
    l_from_subinventory_code wms_transactions_temp.from_subinventory_code%TYPE;
    l_to_subinventory_code   wms_transactions_temp.to_subinventory_code%TYPE;
    l_subinventory_code      wms_transactions_temp.to_subinventory_code%TYPE;
    l_from_locator_id        wms_transactions_temp.from_locator_id%TYPE;
    l_to_locator_id          wms_transactions_temp.to_locator_id%TYPE;
    l_locator_id             wms_transactions_temp.to_locator_id%TYPE;
    l_from_cost_group_id     wms_transactions_temp.from_cost_group_id%TYPE;
    l_to_cost_group_id       wms_transactions_temp.to_cost_group_id%TYPE;
    l_cost_group_id          wms_transactions_temp.to_cost_group_id%TYPE;
    l_lpn_id                 wms_transactions_temp.lpn_id%TYPE  := null;
    l_initial_pri_quantity   wms_transactions_temp.primary_quantity%TYPE;
    -- rule dynamic SQL output variables
    l_orevision              wms_transactions_temp.revision%TYPE;
    l_olot_number            wms_transactions_temp.lot_number%TYPE;
    l_olot_expiration_date   wms_transactions_temp.lot_expiration_date%TYPE;
    l_osubinventory_code     wms_transactions_temp.from_subinventory_code%TYPE;
    l_olocator_id            wms_transactions_temp.from_locator_id%TYPE;
    l_olocator_id_prev       wms_transactions_temp.from_locator_id%TYPE;
    l_olocator_id_new        wms_transactions_temp.from_locator_id%TYPE;
    l_ocost_group_id         wms_transactions_temp.from_cost_group_id%TYPE;
    l_olpn_id                wms_transactions_temp.lpn_id%TYPE;
    l_possible_quantity      wms_transactions_temp.primary_quantity%TYPE;
    l_possible_trx_qty       wms_transactions_temp.transaction_quantity%TYPE;
    l_reservation_id         wms_transactions_temp.reservation_id%TYPE;
    -- variables needed for qty tree
    l_qoh                    NUMBER;
    l_rqoh                   NUMBER;
    l_qr                     NUMBER;
    l_qs                     NUMBER;
    l_att                    NUMBER;
    l_atr                    NUMBER;
    --
    l_rule_func_sql          LONG;
    l_rule_result            NUMBER;
    l_dummy                  NUMBER;
    l_pack_exists            NUMBER;
    l_serial_control_code    NUMBER;
    l_is_serial_control      NUMBER;
    l_package_name           VARCHAR2(128);
    l_msg_data               VARCHAR2(240);
    l_msg_count              NUMBER;
    l_rule_id                NUMBER;
    l_unit_number            VARCHAR2(30);
    --variables related to pick by UOM
    l_uom_code               VARCHAR2(3);
    l_order_by_string        VARCHAR2(1000);
    l_consist_string         VARCHAR2(1000);
    l_cur_order_by_string    VARCHAR2(1000)                                      := '-9999999';
    l_default_pick_rule      NUMBER;
    l_default_put_rule       NUMBER;
    l_allowed                VARCHAR2(1);
    l_loc_avail_units        NUMBER;
    l_capacity_updated       BOOLEAN;
    l_consider_staging_capacity   BOOLEAN; --Added bug3237702
    l_return_status          VARCHAR2(1);
    l_consist_exists         BOOLEAN;
    l_comingle               VARCHAR2(1);
    l_serial_number          VARCHAR2(30);
    l_detail_serial          NUMBER;
    l_found                  BOOLEAN;
    l_first_serial           NUMBER;
    l_locs_index             NUMBER; --index to v_locs table
    l_debug_on               BOOLEAN;
    l_uom_index              NUMBER;
    l_lpn_controlled_flag    NUMBER;
    l_check_cg               BOOLEAN;
    l_restrict_subs_code     NUMBER;
    l_restrict_locs_code     NUMBER;
    l_quantity_function      NUMBER;
    v_current_row            t_location_rec;
    --added to support allocation mode
    l_cur_lpn_group          NUMBER;
    l_cur_lpn_rec            NUMBER;
    l_needed_quantity        NUMBER;
    l_inserted_record        BOOLEAN;
    l_expected_quantity      NUMBER;
    l_allocated_quantity     NUMBER;
    l_remaining_quantity     NUMBER;
    l_sec_inserted_record    BOOLEAN;                   -- new
    l_sec_expected_quantity  NUMBER;                    -- new
    l_sec_allocated_quantity NUMBER;                    -- new
    l_sec_remaining_quantity NUMBER;                    -- new
    l_sec_needed_quantity    NUMBER;                    -- new
    l_grade_code             VARCHAR2(150);             -- new
    l_allocation_mode        NUMBER;
    l_cur_uom_rec            NUMBER;
    l_first_uom_rec          NUMBER;
    l_last_uom_rec           NUMBER;
    l_finished               BOOLEAN;
    l_cur_consist_group      NUMBER;
    l_use_pick_uom           BOOLEAN;
    l_order_by_rank          NUMBER                                              := 0;
    l_cur_rec                NUMBER;
    l_prev_rec               NUMBER;
    l_next_rec               NUMBER;
    l_hash_size              NUMBER;
    l_sub_rsv_type	     NUMBER;

    --added to support pjm
    l_project_id             NUMBER;
    l_oproject_id            NUMBER;
    l_task_id                NUMBER;
    l_otask_id               NUMBER;
    l_input_lpn_id           NUMBER;
    --- Initilization of Ref cursors for Pick and putaway rules
-- Added to pass into DoProjectCheck new parameter used in other apply procedure  Bug3237702
    l_dummy_loc		NUMBER;

    v_pick_cursor            wms_rule_pvt.cv_pick_type;
    v_put_cursor             wms_rule_pvt.cv_put_type;

    l_debug                  NUMBER;   -- 1 for debug is on , 0 for debug is off
    l_progress 		     VARCHAR2(10);  -- local variable to track program progress,
                                            -- especially useful when exception occurs

    l_default_inv_pick_rule    NUMBER;      --added for bug8310188
    l_wms_enabled_flag         VARCHAR2(1); --added for bug8310188
    l_rule_override_flag       inv_cache.org_rec.rules_override_lot_reservation%TYPE; -- 8809951
    l_return_value             BOOLEAN;     -- 8809951

    --cursor used to determine if suggestions should be minimized
    -- for this rule.  This flag affects how the Pick UOM functionality
    -- works.
    CURSOR c_allocation_mode IS
      SELECT allocation_mode_id
           , qty_function_parameter_id
        FROM wms_rules_b
       WHERE rule_id = l_rule_id;

    --cursor used to determine if rule has any consistency requirements
    CURSOR l_consist IS
      SELECT consistency_id
        FROM wms_rule_consistencies
       WHERE rule_id = l_rule_id;

    --cursor to get the total quantity for the LPN
    CURSOR c_lpn_quantity IS
      SELECT SUM(primary_transaction_quantity)
        FROM mtl_onhand_quantities_detail
       WHERE lpn_id = v_current_row.lpn_id;


  BEGIN
    --
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_progress := 10;
    -- debugging portion
    -- can be commented ut for final code
    if nvl(inv_cache.is_pickrelease, FALSE) THEN
      If (l_debug = 1) then
       log_event(l_api_name, 'Check if Pick Release', 'True');
      End if;
      l_consider_staging_capacity := FALSE;
    else
      If (l_debug = 1) then
       log_event(l_api_name, 'Check if Pick Release', 'False');
      End if;
      l_consider_staging_capacity := TRUE;
    end if;
    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '|| g_pkg_name || '.'
              || l_api_name);
    END IF;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start Apply');
    END IF;
    -- end of debugging section
    --
    -- Standard start of API savepoint
    SAVEPOINT applyrulesp;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    --
    -- Initialize functional return status to completed
    x_finished       := fnd_api.g_true;

    --
    -- Validate input parameters and pre-requisites, if validation level
    -- requires this
    IF p_validation_level <> fnd_api.g_valid_level_none THEN
      IF p_type_code IS NULL
         OR p_type_code = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_RULE_TYPE_CODE_MISSING');
          fnd_msg_pub.ADD;
          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'type_code_missing');
          END IF;
        END IF;
        RAISE fnd_api.g_exc_error;
    END IF;

    -- init variables
    l_revision      := null;
    l_lot_number    := null;
    l_lpn_id        := null;

      --changed by jcearley on 11/22/99, b/c a null rule_id is now allowed
      --  if rule_id is null, use default rule (0 for put away, 1 for pick)

      IF p_rule_id IS NULL OR p_rule_id = fnd_api.g_miss_num THEN
           --query org parameters to get user's default rule
           IF l_debug = 1 THEN
              log_statement(l_api_name,'no_rule','Getting default rule at org level');
           END IF;
           -- 8809951 removed cursor and using INV CACHE
	   IF (INV_CACHE. set_org_rec(p_organization_id) ) THEN
			        l_default_pick_rule         := inv_cache.org_rec.default_wms_picking_rule_id;
			        l_default_put_rule          := inv_cache.org_rec.default_put_away_rule_id;
			        l_rule_override_flag        := inv_cache.org_rec.rules_override_lot_reservation;
			        l_default_inv_pick_rule   := inv_cache.org_rec.default_picking_rule_id;
			        l_wms_enabled_flag       := inv_cache.org_rec.wms_enabled_flag;
	    END If;

           --if default rule not defined, use default seeded rule
           IF p_type_code = 1 THEN --put away
             l_rule_id  := l_default_put_rule;

             IF l_rule_id IS NULL THEN
                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'no_org_rule_put',
                       'Did not find org default put away rule');
                END IF;
                l_rule_id  := 10;
             END IF;
            ELSE --pick
             --start adding for bug8310188
	      IF l_wms_enabled_flag ='Y' THEN
               l_rule_id  := l_default_pick_rule;
	      ELSE
               l_rule_id  := l_default_inv_pick_rule;
	      END IF ;
            --End adding for bug8310188
             IF l_rule_id IS NULL THEN
                IF l_debug = 1 THEN
                   log_statement(l_api_name, 'no_org_rule_put',
                       'Did not find org default put away rule');
                END IF;
                l_rule_id  := 2;
             END IF;
           END IF;
           IF l_debug = 1 THEN
              log_statement(l_api_name, 'default_rule',
                 'Rule being used: ' || l_rule_id);
           END IF;
      ELSE
        l_rule_id  := p_rule_id;
      END IF;

      /* Lgao, Bug 5141737 select available will not check this flag, not used */
      /*IF p_partial_success_allowed_flag IS NULL
         OR p_partial_success_allowed_flag = fnd_api.g_miss_char THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_PARTIAL_SUCC_FLAG_MISS');

           IF l_debug = 1 THEN
              log_error_msg(l_api_name, 'partial_succ_flag_missing');
           END IF;
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
      */

      IF p_transaction_temp_id IS NULL
         OR p_transaction_temp_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('WMS', 'WMS_TRX_REQ_LINE_ID_MISS');
          fnd_msg_pub.ADD;
           IF l_debug = 1 THEN
              log_error_msg(l_api_name, 'trx_req_line_id_missing');
           END IF;

        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_organization_id IS NULL
         OR p_organization_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('INV', 'INV_NO_ORG_INFORMATION');
          fnd_msg_pub.ADD;
          IF l_debug = 1 THEN
	     log_error_msg(l_api_name, 'org_id_missing');
          END IF;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF p_inventory_item_id IS NULL
         OR p_inventory_item_id = fnd_api.g_miss_num THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('INV', 'INV_ITEM_ID_REQUIRED');
          fnd_msg_pub.ADD;
          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'item_id_missing');
          END IF;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF  p_type_code = 2
          AND (p_tree_id IS NULL
               OR p_tree_id = fnd_api.g_miss_num
              ) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('INV', 'INV_QTY_TREE_ID_MISSING');
          fnd_msg_pub.ADD;

          IF l_debug = 1 THEN
             log_error_msg(l_api_name, 'qty_tree_id_missing');
          END IF;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --inv_pp_debug.send_message_to_pipe('finished validations and qty tree init');

    --
    -- backup qty tree
    IF p_type_code = 2 THEN
       IF l_debug = 1 THEN
          log_statement(l_api_name, 'backup_tree',
                 'Calling inv_quantity_tree_pvt.backup_tree');
       END IF;
       inv_quantity_tree_pvt.backup_tree(x_return_status, p_tree_id);

       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
           IF l_debug = 1 THEN
              log_statement(l_api_name, 'backup_tree_unexp_err',
                 'Unexpected error from inv_quantity_tree_pvt.backup_tree');
           END IF;

           RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
           IF l_debug = 1 THEN
                 log_statement(l_api_name, 'backup_tree_err',
                       'Error from inv_quantity_tree_pvt.backup_tree');
           END IF;
           RAISE fnd_api.g_exc_error;
        END IF;

        --does the rule have any consistency restrictions?
        OPEN l_consist;
        FETCH l_consist INTO l_dummy;

        IF l_consist%NOTFOUND THEN
           l_consist_exists  := FALSE;

           IF l_debug = 1 THEN
              log_statement(l_api_name, 'consist_exist_false',
                    'Consistencies do not exist');
           END IF;
        ELSE
           l_consist_exists  := TRUE;

           IF l_debug = 1 THEN
              log_statement(l_api_name, 'consist_exist_true', 'Consistencies exist');
           END IF;

        END IF;
        CLOSE l_consist;
    END IF;

    --

    --Get allocation mode
    OPEN c_allocation_mode;
    FETCH c_allocation_mode INTO l_allocation_mode, l_quantity_function;

    IF c_allocation_mode%NOTFOUND
       OR l_allocation_mode IS NULL THEN
      --by default, make allocation mode 3
      l_allocation_mode  := 3;
    END IF;

    CLOSE c_allocation_mode;

    IF l_allocation_mode IN (3, 4) THEN
      l_use_pick_uom  := TRUE;
    ELSE
      l_use_pick_uom  := FALSE;
    END IF;

    -- make sure, everything is clean
    freeglobals;
    wms_parameter_pvt.clearcache;
    --
    g_trace_recs.DELETE;
    l_debug_on       := isruledebugon(p_simulation_mode);
    --query items table to see if item is serial controlled (picking) or if it
    -- restricts subs or locators (putaway)
    -- 8809951 start removed cursor and using INV CACHE
      l_return_value := INV_CACHE.set_item_rec(
				   p_organization_id,
				   p_inventory_item_id);
      If NOT l_return_value Then
	If l_debug = 1 then
	   log_statement(l_api_name, '-', 'Error setting from sub cache');
	end if;
	RAISE fnd_api.g_exc_unexpected_error;
      End If;

      l_serial_control_code 	:= NVL(inv_cache.item_rec.serial_number_control_code,1);
      l_restrict_subs_code  	:= NVL(inv_cache.item_rec.restrict_subinventories_code, 2);
      l_restrict_locs_code  	:= NVL(inv_cache.item_rec.restrict_locators_code, 2);
      -- 8809951 end

    -- Only detail serial numbers if they are prespecified or entered
    -- at inventory receipt for this item.
    IF p_type_code = 2 THEN --pick
      IF l_serial_control_code IN (2, 5) THEN
        l_is_serial_control  := 1;
      ELSE
        l_is_serial_control  := 0;
      END IF;
    ELSE
      l_is_serial_control  := 0;
    END IF;

    IF p_detail_serial = TRUE THEN
      l_detail_serial  := 1;
    ELSE
      l_detail_serial  := 0;
    END IF;

    IF l_debug = 1 THEN
       log_statement(l_api_name, 'input_proj', 'Project: ' || p_project_id);
       log_statement(l_api_name, 'input_task', 'Task: ' || p_task_id);
    END IF;

    --get the name of the rule package
    getpackagename(l_rule_id, l_package_name);
    -- Initialize the pointer to the first trx detail input line
    wms_re_common_pvt.initinputpointer;
    --
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'get line ', 'get line input');
    END IF;
      wms_re_common_pvt.getnextinputline(
        l_pp_transaction_temp_id
      , l_revision
      , l_lot_number
      , l_lot_expiration_date
      , l_from_subinventory_code
      , l_from_locator_id
      , l_from_cost_group_id
      , l_to_subinventory_code
      , l_to_locator_id
      , l_to_cost_group_id
      , l_needed_quantity
      , l_sec_needed_quantity
      , l_grade_code
      , l_reservation_id
      , l_serial_number -- [ new code ]
      , l_lpn_id
      );

    -- Loop through all the trx detail input lines
      IF l_debug = 1 THEN
      	log_statement(l_api_name, 'input_rec', 'Got next input line');
      	log_statement(l_api_name, 'input_rev', 'rev:' || l_revision);
      	log_statement(l_api_name, 'input_lot', 'lot:' || l_lot_number);
      	log_statement(l_api_name, 'input_sub', 'sub:' || l_from_subinventory_code);
      	log_statement(l_api_name, 'input_loc', 'loc:' || l_from_locator_id);
      	log_statement(l_api_name, 'input_cg', 'cg:' || l_from_cost_group_id);
      	log_statement(l_api_name, 'input_tsub', 'tsub:' || l_to_subinventory_code);
      	log_statement(l_api_name, 'input_tloc', 'tloc:' || l_to_locator_id);
      	log_statement(l_api_name, 'input_tcg', 'tcg:' || l_to_cost_group_id);
      	log_statement(l_api_name, 'input_lpn', 'lpn:' || l_lpn_id);
      	log_statement(l_api_name, 'input_qty', 'qty:' || l_needed_quantity);
      	log_statement(l_api_name, 'input_qty', 'sec qty:' || l_sec_needed_quantity);

      END IF;

      IF ((p_project_id IS NOT NULL) AND (l_to_locator_id IS NOT NULL) AND (p_type_code = 1)) THEN
        --bug 2400549 - for WIP backflush transfer putaway,
        --always use the locator specified on the move order line, even
        --if that locator is from common stock (not project)
        -- Bug 2666620: BackFlush MO Type Removed. It is now 5. Moreover Txn Action ID is 2 which is
        --              already handled.
        IF NOT (wms_engine_pvt.g_move_order_type = 5 AND wms_engine_pvt.g_transaction_action_id = 2) THEN

           IF l_debug = 1 THEN
              log_statement(l_api_name, 'do_project1', 'Calling do project check');
           END IF;

          IF doprojectcheck(l_return_status, l_to_locator_id, p_project_id, p_task_id, l_to_locator_id, l_dummy_loc) THEN

            IF l_debug = 1 THEN
               log_statement(l_api_name, 'do_project1_success', 'Do Project Check passed');
            END IF;

            NULL;
          END IF;
        END IF;
      END IF;

      --
      -- Save the initial input qty for later usage
      l_initial_pri_quantity  := l_needed_quantity;
      --
      l_input_lpn_id          := l_lpn_id;

      IF p_type_code = 2 THEN
        --check for null values.  NULL produces error in stored procedure,
        --  so we treat -9999 as NULL;
        -- since revision is varchar(3), use -99
        -- we only want to overwrite revision and lot for pick rules, since
        -- we use these values in putaway.
        IF (l_revision IS NULL) THEN
          --gmi_reservation_util.println('l_revision is null');
          l_revision  := '-99';
        END IF;

        IF (l_lot_number IS NULL) THEN
          l_lot_number  := '-9999';
        END IF;
      END IF;

      IF (p_type_code = 2) THEN --pick
        l_subinventory_code  := l_from_subinventory_code;
        l_locator_id         := l_from_locator_id;
        l_cost_group_id      := l_from_cost_group_id;
      ELSE --put away
        l_subinventory_code  := l_to_subinventory_code;
        l_locator_id         := l_to_locator_id;
        l_cost_group_id      := l_to_cost_group_id;
      END IF;

      IF (l_subinventory_code IS NULL) THEN
        l_subinventory_code  := '-9999';
      END IF;

      IF (l_locator_id IS NULL) THEN
        l_locator_id  := -9999;
      END IF;

      IF (l_cost_group_id IS NULL) THEN
        l_cost_group_id  := -9999;
      END IF;

      IF (l_lpn_id IS NULL) THEN
        l_lpn_id  := -9999;
      END IF;

      IF (p_project_id IS NULL) THEN
        l_project_id  := -9999;
      ELSE
        l_project_id  := p_project_id;
      END IF;

      IF (p_task_id IS NULL) THEN
        l_task_id  := -9999;
      ELSE
        l_task_id  := p_task_id;
      END IF;

      IF (p_unit_number IS NULL) THEN
        l_unit_number  := '-9999';
      ELSE
        l_unit_number  := p_unit_number;
      END IF;

      IF l_debug = 1 THEN
         log_statement(l_api_name, 'calling_open_curs', 'Calling open_curs');
      END IF;

      -- Bug# 2430429
      -- The call to open_curs was not using bind variables.
      -- This was causing performance problems

      -- l_cursor := dbms_sql.open_cursor;
      --build dynamic PL/SQL for call to stored procedure;
      -- open_curs opens the appropriate cursor for the rule;
      -- this call has to be dynamic because of the name of the rule package
      IF p_type_code = 2 THEN
         --pick_open_curs
         --inv_pp_debug.send_message_to_pipe('Calling **pick_open_curs ** wms_rule_pick_pkg1.execute');
         IF (l_revision IS NULL) THEN
           --gmi_reservation_util.println('l_revision is null');
           l_revision  := '-99';
         END IF;

         IF (l_lot_number IS NULL) THEN
           l_lot_number  := '-9999';
         END IF;
         IF (l_lpn_id IS NULL) THEN
            l_lpn_id  := -9999;
         END IF;
         IF l_debug = 1 THEN
                log_statement(l_api_name, 'pick_open_rule :l_rule_id ', l_rule_id);
                log_statement(l_api_name, 'pick_open_rule :p_organization_id ', p_organization_id);
                log_statement(l_api_name, 'pick_open_rule :p_inventory_item_id ',  p_inventory_item_id);
                log_statement(l_api_name, 'pick_open_rule :p_transaction_type_id ',  p_transaction_type_id);
                log_statement(l_api_name, 'pick_open_rule :l_revision ',  l_revision);
                log_statement(l_api_name, 'pick_open_rule :l_lot_number ',  l_lot_number);
                log_statement(l_api_name, 'pick_open_rule :l_from_subinventory_code ',  l_subinventory_code);
                log_statement(l_api_name, 'pick_open_rule :l_locator_id ',  l_locator_id);
                log_statement(l_api_name, 'pick_open_rule :l_cost_group_id ',  l_cost_group_id);
                log_statement(l_api_name, 'pick_open_rule :l_pp_transaction_temp_id ',  l_pp_transaction_temp_id);
                log_statement(l_api_name, 'pick_open_rule :l_is_serial_control ', l_is_serial_control);
                log_statement(l_api_name, 'pick_open_rule :l_detail_serial ',  l_detail_serial);
                log_statement(l_api_name, 'pick_open_rule :p_detail_any_serial ',  p_detail_any_serial);
                log_statement(l_api_name, 'pick_open_rule :p_from_serial ', p_from_serial);
                log_statement(l_api_name, 'pick_open_rule :p_to_serial ', p_to_serial);
                log_statement(l_api_name, 'pick_open_rule :l_unit_number ',  l_unit_number);
                log_statement(l_api_name, 'pick_open_rule :l_lpn_id ',  l_lpn_id);
                log_statement(l_api_name, 'pick_open_rule :l_project_id ',  l_project_id);
                log_statement(l_api_name, 'pick_open_rule :l_task_id ',  l_task_id);
                log_statement(l_api_name, 'pick_open_rule  :l_rule_result ',l_rule_result);
          END IF;
          pick_open_rule(
            v_pick_cursor
          , l_rule_id
          , p_organization_id
          , p_inventory_item_id
          , p_transaction_type_id
          , l_revision
          , l_lot_number
          , l_subinventory_code
          , l_locator_id
          , l_cost_group_id
          , l_pp_transaction_temp_id
          , l_is_serial_control
          , l_detail_serial
          , p_detail_any_serial
          , p_from_serial
          , p_to_serial
          , l_unit_number
          , l_lpn_id
          , l_project_id
          , l_task_id
          , l_rule_result
          );
        --gmi_reservation_util.println('after open rule');
          fetchcursorrows(
              x_return_status
            , x_msg_count
            , x_msg_data
            , v_pick_cursor
            , l_rule_id
            );
        close_pick_rule(l_rule_id, v_pick_cursor);

        /*FETCH v_pick_cursor bulk collect INTO
        WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl;
        */
        /*FOR i IN 1..WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.COUNT
        LOOP
            WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).organization_id := p_organization_id;
            WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).inventory_item_id := p_inventory_item_id;
        END LOOP;
        gmi_reservation_util.println('fetch the rows, return rows number'
                      ||WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.COUNT);
        FOR i IN 1..WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.COUNT
        LOOP
          gmi_reservation_util.println('fetch the rows, 2nd qty '
                      ||WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).secondary_onhand_qty);
        end loop;
        */
     END IF;
  EXCEPTION
    /*WHEN INVALID_PKG_STATE THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      log_error(l_api_name, 'execute_fetch_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);
     */
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);

      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;
  -- end of debugging section
  END get_available_inventory;

  PROCEDURE FetchCursorRows(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_cursor              IN            wms_rule_pvt.cv_pick_type
  , p_rule_id             IN            NUMBER
  ) IS
    invalid_pkg_state  exception;
    Pragma Exception_Init(invalid_pkg_state, -6508);

    l_list_pkg     VARCHAR2(30);

    l_api_name     VARCHAR2(30)  := 'FetchCursor';
    l_rows         NUMBER;
    l_func_sql     VARCHAR(1000);
    l_cursor       NUMBER;
    l_dummy        NUMBER;
    l_package_name VARCHAR2(128);
    l_ctr          NUMBER        := 0;


  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    --
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('enter '|| g_pkg_name || '.' || l_api_name);
    END IF;

    log_procedure(l_api_name, 'start', 'Start FetchCursorrows');
    -- end of debugging section
    --

    --get package name based on rule id
    getpackagename(p_rule_id, l_package_name);
    log_statement(l_package_name,  'package_name ', l_package_name);
    --- calling the static fetch cursor. The name of the rule package will be
    --- determined based on the rule_id
    --- If the ctr is 1 then there is no subscript ,
    --- if ctr = 2 then subscript = 1
    --- and if ctr = 3 then subscript = 2, this script is added to the package
    --- name.
    l_ctr        := wms_rule_gen_pkgs.get_count_no_lock('PICK');
    l_list_pkg   :=  'wms_rule_pick_pkg' || l_ctr ;
    log_statement(l_package_name,  'l_ctr ', l_ctr);
    --log_statement(l_package_name,  'p_cursor ', p_cursor);

    IF (l_ctr = 1) THEN

      wms_rule_pick_pkg1.execute_fetch_available_inv(
        p_cursor
      , p_rule_id
      , x_return_status
      );
    ELSIF (l_ctr = 2) THEN

      wms_rule_pick_pkg2.execute_fetch_available_inv(
        p_cursor
      , p_rule_id
      , x_return_status
      );
    ELSIF (l_ctr = 3) THEN
      wms_rule_pick_pkg3.execute_fetch_available_inv(
        p_cursor
      , p_rule_id
      , x_return_status
      );
    END IF;

    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '|| g_pkg_name || '.' || l_api_name);
    END IF;
    -- end of debugging section
    log_procedure(l_api_name, 'end', 'End FetchCursorrows');
  --
  EXCEPTION
    WHEN INVALID_PKG_STATE THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WMS', 'WMS_INVALID_PKG');
      fnd_message.set_token('LIST_PKG',  l_list_pkg);
      fnd_message.set_token('RULE_NAME', l_package_name);
      fnd_msg_pub.ADD;
      log_error(l_api_name, 'execute_fetch_rule', 'Invalid Package, Contact your DBA - '
                            || l_list_pkg || ' / ' || l_package_name);

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      --
      log_error(l_api_name, 'other_error', 'Other error - ' || x_msg_data);

      -- debugging portion
      -- can be commented ut for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;
  -- end of debugging section
  END FetchCursorRows;
  -- end LG convergence

END wms_rule_pvt;

/
