--------------------------------------------------------
--  DDL for Package Body WMS_RULE_14
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_14" AS

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
         OPEN p_cursor FOR select base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.UOM_CODE
,decode(g_lpn_id, -9999, NULL, g_lpn_id) LPN_ID
,base.SERIAL_NUMBER
,base.primary_quantity 
,base.secondary_quantity 
,base.grade_code 
,NULL consist_string
,NULL order_by_string
 from WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
      and decode(g_unit_number, '-9999', 'a', '-7777', nvl(msn.end_item_unit_number, '-7777'), msn.end_item_unit_number) =
      decode(g_unit_number, '-9999', 'a', g_unit_number)
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
     )base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and decode(g_subinventory_code, '-9999', 'a', base.SUBINVENTORY_CODE) = decode(g_subinventory_code, '-9999', 'a', g_subinventory_code)
 and  ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null )  AND exists(select 1 from mtl_material_statuses where status_id = base.STATUS_ID AND RESERVABLE_TYPE = 1)) OR ((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL)  or base.STATUS_ID IS NULL) and decode(g_subinventory_code, '-9999', base.RESERVABLE_TYPE, 1) = 1))
 and decode(g_locator_id, -9999, 1, base.locator_id) = decode(g_locator_id,-9999, 1, g_locator_id)
 and decode(g_revision, '-99', 'a', base.REVISION) = decode(g_revision, '-99', 'a', g_revision)
 and decode(g_lot_number, '-9999', 'a', base.LOT_NUMBER) = decode(g_lot_number, '-9999', 'a', g_lot_number)
 and decode(g_lpn_id, -9999, 1, base.lpn_id) = decode(g_lpn_id, -9999, 1, g_lpn_id)
 and decode(g_cost_group_id, -9999, 1, base.cost_group_id) = decode(g_cost_group_id, -9999, 1, g_cost_group_id)
 and (decode(g_project_id, -9999, -1, base.project_id) = decode(g_project_id, -9999, -1, g_project_id) OR ( g_project_id = -7777  and base.project_id IS NULL)) 
 and (g_project_id = -9999 OR nvl(base.task_id, -9999) = g_task_id OR (g_task_id = -7777 and base.task_id IS NULL))
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
 order by base.SERIAL_NUMBER asc,base.CONVERSION_RATE desc
;
     Elsif (g_serial_control = 1) AND (g_detail_serial = 3) THEN
        OPEN p_cursor FOR select base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.UOM_CODE
,decode(g_lpn_id, -9999, NULL, g_lpn_id) LPN_ID
,NULL SERIAL_NUMBER
,sum(base.primary_quantity) 
,sum(base.secondary_quantity) 
,base.grade_code 
,NULL consist_string
,NULL order_by_string
 from WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
       and decode(g_unit_number, '-9999', 'a', '-7777', nvl(msn.end_item_unit_number, '-7777'), msn.end_item_unit_number) =
       decode(g_unit_number, '-9999', 'a', g_unit_number)
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
                                        ,msn.status_id) = 'Y' )base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and decode(g_subinventory_code, '-9999', 'a', base.SUBINVENTORY_CODE) = decode(g_subinventory_code, '-9999', 'a', g_subinventory_code)
 and  ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null )  AND exists(select 1 from mtl_material_statuses where status_id = base.STATUS_ID AND RESERVABLE_TYPE = 1)) OR ((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL)  or base.STATUS_ID IS NULL) and decode(g_subinventory_code, '-9999', base.RESERVABLE_TYPE, 1) = 1))
 and decode(g_locator_id, -9999, 1, base.locator_id) = decode(g_locator_id,-9999, 1, g_locator_id)
 and decode(g_revision, '-99', 'a', base.REVISION) = decode(g_revision, '-99', 'a', g_revision)
 and decode(g_lot_number, '-9999', 'a', base.LOT_NUMBER) = decode(g_lot_number, '-9999', 'a', g_lot_number)
 and decode(g_lpn_id, -9999, 1, base.lpn_id) = decode(g_lpn_id, -9999, 1, g_lpn_id)
 and decode(g_cost_group_id, -9999, 1, base.cost_group_id) = decode(g_cost_group_id, -9999, 1, g_cost_group_id)
 and (decode(g_project_id, -9999, -1, base.project_id) = decode(g_project_id, -9999, -1, g_project_id) OR ( g_project_id = -7777  and base.project_id IS NULL)) 
 and (g_project_id = -9999 OR nvl(base.task_id, -9999) = g_task_id OR (g_task_id = -7777 and base.task_id IS NULL))
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
 group by base.ORGANIZATION_ID
,base.INVENTORY_ITEM_ID
,base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.PROJECT_ID
,base.TASK_ID
,base.UOM_CODE
,base.GRADE_CODE
,base.SERIAL_NUMBER,base.CONVERSION_RATE
 order by base.SERIAL_NUMBER asc,base.CONVERSION_RATE desc
;
     Elsif (g_serial_control = 1) AND  (g_detail_serial = 4) THEN
           OPEN p_cursor FOR select base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.UOM_CODE
,decode(g_lpn_id, -9999, NULL, g_lpn_id) LPN_ID
,NULL SERIAL_NUMBER
,sum(base.primary_quantity) 
,sum(base.secondary_quantity) 
,base.grade_code 
,NULL consist_string
,NULL order_by_string
 from WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
            and decode(g_unit_number, '-9999', 'a', '-7777', nvl(msn.end_item_unit_number, '-7777'), msn.end_item_unit_number) =
            decode(g_unit_number, '-9999', 'a', g_unit_number)
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
             )base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and decode(g_subinventory_code, '-9999', 'a', base.SUBINVENTORY_CODE) = decode(g_subinventory_code, '-9999', 'a', g_subinventory_code)
 and  ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null )  AND exists(select 1 from mtl_material_statuses where status_id = base.STATUS_ID AND RESERVABLE_TYPE = 1)) OR ((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL)  or base.STATUS_ID IS NULL) and decode(g_subinventory_code, '-9999', base.RESERVABLE_TYPE, 1) = 1))
 and decode(g_locator_id, -9999, 1, base.locator_id) = decode(g_locator_id,-9999, 1, g_locator_id)
 and decode(g_revision, '-99', 'a', base.REVISION) = decode(g_revision, '-99', 'a', g_revision)
 and decode(g_lot_number, '-9999', 'a', base.LOT_NUMBER) = decode(g_lot_number, '-9999', 'a', g_lot_number)
 and decode(g_lpn_id, -9999, 1, base.lpn_id) = decode(g_lpn_id, -9999, 1, g_lpn_id)
 and decode(g_cost_group_id, -9999, 1, base.cost_group_id) = decode(g_cost_group_id, -9999, 1, g_cost_group_id)
 and (decode(g_project_id, -9999, -1, base.project_id) = decode(g_project_id, -9999, -1, g_project_id) OR ( g_project_id = -7777  and base.project_id IS NULL)) 
 and (g_project_id = -9999 OR nvl(base.task_id, -9999) = g_task_id OR (g_task_id = -7777 and base.task_id IS NULL))
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
 group by base.ORGANIZATION_ID
,base.INVENTORY_ITEM_ID
,base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.PROJECT_ID
,base.TASK_ID
,base.UOM_CODE
,base.GRADE_CODE
,base.SERIAL_NUMBER,base.CONVERSION_RATE
 order by base.SERIAL_NUMBER asc,base.CONVERSION_RATE desc
;

     Elsif ((g_serial_control <> 1) OR (g_detail_serial = 0)) THEN
       OPEN p_cursor FOR select base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.UOM_CODE
,decode(g_lpn_id, -9999, NULL, g_lpn_id) LPN_ID
,NULL SERIAL_NUMBER
,sum(base.primary_quantity) 
,sum(base.secondary_quantity) 
,base.grade_code 
,NULL consist_string
,NULL order_by_string
 from WMS_TRX_DETAILS_TMP_V mptdtv
,(
SELECT x.organization_id       organization_id     
  ,x.inventory_item_id         inventory_item_id   
  ,x.revision                  revision            
  ,x.lot_number                lot_number          
  ,x.lot_expiration_date       lot_expiration_date 
  ,x.subinventory_code         subinventory_code   
  ,x.locator_id                locator_id          
  ,x.cost_group_id             cost_group_id       
  ,x.status_id                 status_id       
  ,NULL                        serial_number       
  ,x.lpn_id                    lpn_id              
  ,x.project_id                project_id          
  ,x.task_id                   task_id             
  ,x.date_received             date_received       
  ,x.primary_quantity          primary_quantity    
  ,x.secondary_quantity          secondary_quantity    
  ,x.grade_code                  grade_code            
  ,x.reservable_type           reservable_type     
  ,x.locreservable             locreservable 
  ,x.lotreservable             lotreservable 
  ,NVL(loc.pick_uom_code,sub.pick_uom_code) uom_code
  ,WMS_Rule_PVT.GetConversionRate(                 
       NVL(loc.pick_uom_code, sub.pick_uom_code)   
       ,x.organization_id            
       ,x.inventory_item_id) conversion_rate       
  ,NULL locator_inventory_item_id                  
  ,NULL empty_flag                                 
  ,NULL location_current_units                     
FROM (
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
              ,moq.revision, moq.lot_number
              ,moq.subinventory_code, moq.locator_id		--added status_id
              ,moq.cost_group_id,moq.status_id, mils.reservable_type, moq.lpn_id         -- Bug 6719290
              ,decode(mils.project_id, mils.project_id, moq.project_id)
              ,decode(mils.task_id, mils.task_id, moq.task_id)
          ) x
          ,mtl_secondary_inventories sub
          ,mtl_lot_numbers lot
    where x.primary_quantity > 0
      and x.organization_id = sub.organization_id
      and x.subinventory_code = sub.secondary_inventory_name
      and x.organization_id = lot.organization_id (+)
      and x.inventory_item_id = lot.inventory_item_id (+)
      and x.lot_number = lot.lot_number (+)
     ) x                                           
    ,mtl_secondary_inventories sub                 
    ,mtl_item_locations loc                        
WHERE x.organization_id = loc.organization_id (+)  
   AND x.locator_id = loc.inventory_location_id (+)
   AND sub.organization_id = x.organization_id     
   AND sub.secondary_inventory_name = x.subinventory_code 
) base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and decode(g_subinventory_code, '-9999', 'a', base.SUBINVENTORY_CODE) = decode(g_subinventory_code, '-9999', 'a', g_subinventory_code)
 and  ((exists (select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not null )  AND exists(select 1 from mtl_material_statuses where status_id = base.STATUS_ID AND RESERVABLE_TYPE = 1)) OR ((NOT exists(select 1 from mtl_parameters where organization_id = g_organization_id and default_status_id is not NULL)  or base.STATUS_ID IS NULL) and decode(g_subinventory_code, '-9999', base.RESERVABLE_TYPE, 1) = 1))
 and decode(g_locator_id, -9999, 1, base.locator_id) = decode(g_locator_id,-9999, 1, g_locator_id)
 and decode(g_revision, '-99', 'a', base.REVISION) = decode(g_revision, '-99', 'a', g_revision)
 and decode(g_lot_number, '-9999', 'a', base.LOT_NUMBER) = decode(g_lot_number, '-9999', 'a', g_lot_number)
 and decode(g_lpn_id, -9999, 1, base.lpn_id) = decode(g_lpn_id, -9999, 1, g_lpn_id)
 and decode(g_cost_group_id, -9999, 1, base.cost_group_id) = decode(g_cost_group_id, -9999, 1, g_cost_group_id)
 and (decode(g_project_id, -9999, -1, base.project_id) = decode(g_project_id, -9999, -1, g_project_id) OR ( g_project_id = -7777  and base.project_id IS NULL)) 
 and (g_project_id = -9999 OR nvl(base.task_id, -9999) = g_task_id OR (g_task_id = -7777 and base.task_id IS NULL))
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
group by base.ORGANIZATION_ID
,base.INVENTORY_ITEM_ID
,base.REVISION
,base.LOT_NUMBER
,base.LOT_EXPIRATION_DATE
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.COST_GROUP_ID
,base.PROJECT_ID
,base.TASK_ID
,base.UOM_CODE
,base.GRADE_CODE
,base.SERIAL_NUMBER,base.CONVERSION_RATE
 order by base.SERIAL_NUMBER asc,base.CONVERSION_RATE desc
;
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


   BEGIN
           IF (p_cursor%ISOPEN) THEN

               FETCH p_cursor bulk collect INTO
                 WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl;
               IF p_cursor%FOUND THEN
                  x_return_status :=1;
               ELSE
                  x_return_status :=0;
               END IF;
            ELSE
               x_return_status:=0;
            END IF;


   END fetch_available_rows;

   -- end LG convergence

   END WMS_RULE_14;

/
