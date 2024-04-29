--------------------------------------------------------
--  DDL for Package Body WMS_RULE_8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_8" AS

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
          IF p_subinventory_code = '-9999' THEN
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

        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;

      Elsif g_locator_id IS NULL Then

      --if only subinventory passed , OPEN c_no_restrict_sub_passed;

        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 and base.subinventory_code = g_subinventory_code
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;

      Else
      --if subinventory and locator passed, OPEN c_no_restrict_loc_passed;
        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 and base.subinventory_code = g_subinventory_code
 and base.locator_id = g_locator_id
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;
      End If;
    ELSIF g_restrict_locs_code = 2 THEN
      If g_subinventory_code IS NULL Then
      --if nothing passed, OPEN c_sub_restrict_no_passed;
        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
    and mil.subinventory_code(+) = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;
      Elsif g_locator_id IS NULL Then
      --if only subinventory passed, OPEN c_sub_restrict_sub_passed;
         OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
    and mil.subinventory_code(+) = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 and base.subinventory_code = g_subinventory_code
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;

      Else
      --if subinventory and locator passed, OPEN c_sub_restrict_loc_passed;
        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
    and mil.subinventory_code(+) = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 and base.subinventory_code = g_subinventory_code
 and base.locator_id = g_locator_id
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;
      End If;
    ELSE
      If g_subinventory_code IS NULL Then
      --if nothing passed, OPEN c_loc_restrict_no_passed;
        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
    and mil.subinventory_code = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
    and mil.organization_id = msl.organization_id
    and mil.inventory_location_id = msl.secondary_locator
    and msl.inventory_item_Id = g_inventory_item_id
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;

      Elsif g_locator_id IS NULL Then
      --if only subinventory passed,OPEN c_loc_restrict_sub_passed;
        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
    and mil.subinventory_code = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
    and mil.organization_id = msl.organization_id
    and mil.inventory_location_id = msl.secondary_locator
    and msl.inventory_item_Id = g_inventory_item_id
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 and base.subinventory_code = g_subinventory_code
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;

      Else
      --if subinventory and locator passed, OPEN c_loc_restrict_loc_passed;
        OPEN p_cursor FOR select base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,base.PROJECT_ID
,base.TASK_ID
 from MTL_ITEM_LOCATIONS omil
,MTL_SYSTEM_ITEMS msi
,WMS_TRX_DETAILS_TMP_V mptdtv
,(
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
    and mil.subinventory_code = msei.secondary_inventory_name
    and NVL(msei.disable_date, sysdate+1) > sysdate
    and NVL(mil.disable_date, sysdate+1) > sysdate
    and mil.organization_id = misi.organization_id
    and mil.subinventory_code = misi.secondary_inventory
    and misi.inventory_item_id = g_inventory_item_id
    and mil.organization_id = msl.organization_id
    and mil.inventory_location_id = msl.secondary_locator
    and msl.inventory_item_Id = g_inventory_item_id
)base
 where base.ORGANIZATION_ID = g_organization_id
and base.INVENTORY_ITEM_ID = g_inventory_item_id
 and (g_project_id = base.project_id OR base.project_id IS NULL)
 and (g_task_id = base.task_id OR base.task_id IS NULL)
 and mptdtv.PP_TRANSACTION_TEMP_ID = g_pp_transaction_temp_id
and msi.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and msi.INVENTORY_ITEM_ID = mptdtv.INVENTORY_ITEM_ID
and omil.ORGANIZATION_ID = mptdtv.TO_ORGANIZATION_ID
and omil.INVENTORY_LOCATION_ID = NVL(mptdtv.to_locator_id,base.locator_id)
and (
 wms_parameter_Pvt.GetNumOtherLots(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id,
mptdtv.lot_number) = 0
and wms_parameter_Pvt.GetNumOtherItems(
base.organization_id,
base.inventory_item_id,
base.subinventory_code,
base.locator_id) = 0
)
 and base.subinventory_code = g_subinventory_code
 and base.locator_id = g_locator_id
 order by WMS_Parameter_PVT.GetItemOnHand(
base.ORGANIZATION_ID
,mptdtv.INVENTORY_ITEM_ID
,base.SUBINVENTORY_CODE
,base.LOCATOR_ID
,msi.PRIMARY_UOM_CODE
,mptdtv.TRANSACTION_UOM ) desc
,base.PROJECT_ID
,base.TASK_ID
;
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

   END WMS_RULE_8;

/
