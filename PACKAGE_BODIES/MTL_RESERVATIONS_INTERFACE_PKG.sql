--------------------------------------------------------
--  DDL for Package Body MTL_RESERVATIONS_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_RESERVATIONS_INTERFACE_PKG" as
/* $Header: INVRSVF1B.pls 120.0 2005/05/25 06:35:54 appldev noship $ */

  PROCEDURE Lock_Row(	X_ROWID   				   VARCHAR2,
			X_RESERVATION_INTERFACE_ID                 NUMBER,
			X_RESERVATION_BATCH_ID                 	   NUMBER,
			X_REQUIREMENT_DATE			   DATE,
			X_ORGANIZATION_ID			   NUMBER,
			X_TO_ORGANIZATION_ID			   NUMBER,
 			X_INVENTORY_ITEM_ID                        NUMBER,
 			X_ITEM_SEGMENT1                            VARCHAR2,
 			X_ITEM_SEGMENT2                            VARCHAR2,
 			X_ITEM_SEGMENT3                            VARCHAR2,
 			X_ITEM_SEGMENT4                            VARCHAR2,
 			X_ITEM_SEGMENT5                            VARCHAR2,
 			X_ITEM_SEGMENT6                            VARCHAR2,
 			X_ITEM_SEGMENT7                            VARCHAR2,
 			X_ITEM_SEGMENT8                            VARCHAR2,
 			X_ITEM_SEGMENT9                            VARCHAR2,
 			X_ITEM_SEGMENT10                           VARCHAR2,
 			X_ITEM_SEGMENT11                           VARCHAR2,
 			X_ITEM_SEGMENT12                           VARCHAR2,
 			X_ITEM_SEGMENT13                           VARCHAR2,
 			X_ITEM_SEGMENT14                           VARCHAR2,
 			X_ITEM_SEGMENT15                           VARCHAR2,
 			X_ITEM_SEGMENT16                           VARCHAR2,
 			X_ITEM_SEGMENT17                           VARCHAR2,
 			X_ITEM_SEGMENT18                           VARCHAR2,
 			X_ITEM_SEGMENT19                           VARCHAR2,
 			X_ITEM_SEGMENT20                           VARCHAR2,
 			X_DEMAND_SOURCE_TYPE_ID                    NUMBER,
			X_DEMAND_SOURCE_NAME			   VARCHAR2,
 			X_DEMAND_SOURCE_HEADER_ID                  NUMBER,
 			X_DEMAND_SOURCE_LINE_ID                    NUMBER,
 			X_TO_DEMAND_SOURCE_TYPE_ID                 NUMBER,
			X_TO_DEMAND_SOURCE_NAME			   VARCHAR2,
 			X_TO_DEMAND_SOURCE_HEADER_ID               NUMBER,
 			X_TO_DEMAND_SOURCE_LINE_ID                 NUMBER,
			X_PRIMARY_UOM_CODE			   VARCHAR2,
			X_PRIMARY_UOM_ID			   NUMBER,
			X_SECONDARY_UOM_CODE			   VARCHAR2,   --InvConv change
			X_SECONDARY_UOM_ID			   NUMBER,     --InvConv change
			X_RESERVATION_UOM_CODE			   VARCHAR2,
			X_RESERVATION_UOM_ID			   NUMBER,
			X_RESERVATION_QUANTITY			   NUMBER,
			X_PRIMARY_RESERVATION_QUANTITY		   NUMBER,
			X_SECONDARY_RSV_QUANTITY		   NUMBER,     --InvConv change
			X_EXTERNAL_SOURCE_CODE			   VARCHAR2,
			X_EXTERNAL_SOURCE_LINE_ID		   NUMBER,
 			X_SUPPLY_SOURCE_TYPE_ID                    NUMBER,
			X_SUPPLY_SOURCE_NAME			   VARCHAR2,
 			X_SUPPLY_SOURCE_HEADER_ID                  NUMBER,
 			X_SUPPLY_SOURCE_LINE_ID                    NUMBER,
 			X_SUPPLY_SOURCE_LINE_DETAIL                NUMBER,
 			X_TO_SUPPLY_SOURCE_TYPE_ID                 NUMBER,
			X_TO_SUPPLY_SOURCE_NAME			   VARCHAR2,
 			X_TO_SUPPLY_SOURCE_HEADER_ID               NUMBER,
 			X_TO_SUPPLY_SOURCE_LINE_ID                 NUMBER,
 			X_TO_SUPPLY_SOURCE_LINE_DETAIL             NUMBER,
 			X_ERROR_CODE                               NUMBER,
 			X_ERROR_EXPLANATION                        VARCHAR2,
			X_REVISION				   VARCHAR2,
			X_SUBINVENTORY_CODE			   VARCHAR2,
			X_SUBINVENTORY_ID			   NUMBER,
			X_LOCATOR_ID				   NUMBER,
 			X_LOC_SEGMENT1                             VARCHAR2,
 			X_LOC_SEGMENT2                             VARCHAR2,
 			X_LOC_SEGMENT3                             VARCHAR2,
 			X_LOC_SEGMENT4                             VARCHAR2,
 			X_LOC_SEGMENT5                             VARCHAR2,
 			X_LOC_SEGMENT6                             VARCHAR2,
 			X_LOC_SEGMENT7                             VARCHAR2,
 			X_LOC_SEGMENT8                             VARCHAR2,
 			X_LOC_SEGMENT9                             VARCHAR2,
 			X_LOC_SEGMENT10                            VARCHAR2,
 			X_LOC_SEGMENT11                            VARCHAR2,
 			X_LOC_SEGMENT12                            VARCHAR2,
 			X_LOC_SEGMENT13                            VARCHAR2,
 			X_LOC_SEGMENT14                            VARCHAR2,
 			X_LOC_SEGMENT15                            VARCHAR2,
 			X_LOC_SEGMENT16                            VARCHAR2,
 			X_LOC_SEGMENT17                            VARCHAR2,
 			X_LOC_SEGMENT18                            VARCHAR2,
 			X_LOC_SEGMENT19                            VARCHAR2,
 			X_LOC_SEGMENT20                            VARCHAR2,
			X_LOT_NUMBER				   VARCHAR2,
			X_LOT_NUMBER_ID				   NUMBER,
			X_SERIAL_NUMBER				   VARCHAR2,
			X_SERIAL_NUMBER_ID			   NUMBER,
			X_TO_REVISION				   VARCHAR2,
			X_TO_SUBINVENTORY_CODE			   VARCHAR2,
			X_TO_SUBINVENTORY_ID			   NUMBER,
			X_TO_LOCATOR_ID				   NUMBER,
 			X_TO_LOC_SEGMENT1    			   VARCHAR2,
 			X_TO_LOC_SEGMENT2                          VARCHAR2,
 			X_TO_LOC_SEGMENT3                          VARCHAR2,
 			X_TO_LOC_SEGMENT4                          VARCHAR2,
 			X_TO_LOC_SEGMENT5                          VARCHAR2,
 			X_TO_LOC_SEGMENT6                          VARCHAR2,
 			X_TO_LOC_SEGMENT7                          VARCHAR2,
 			X_TO_LOC_SEGMENT8                          VARCHAR2,
 			X_TO_LOC_SEGMENT9                          VARCHAR2,
 			X_TO_LOC_SEGMENT10                         VARCHAR2,
 			X_TO_LOC_SEGMENT11                         VARCHAR2,
 			X_TO_LOC_SEGMENT12                         VARCHAR2,
 			X_TO_LOC_SEGMENT13                         VARCHAR2,
 			X_TO_LOC_SEGMENT14                         VARCHAR2,
 			X_TO_LOC_SEGMENT15                         VARCHAR2,
 			X_TO_LOC_SEGMENT16                         VARCHAR2,
 			X_TO_LOC_SEGMENT17                         VARCHAR2,
 			X_TO_LOC_SEGMENT18                         VARCHAR2,
 			X_TO_LOC_SEGMENT19                         VARCHAR2,
 			X_TO_LOC_SEGMENT20                         VARCHAR2,
			X_TO_LOT_NUMBER				   VARCHAR2,
			X_TO_LOT_NUMBER_ID			   NUMBER,
			X_TO_SERIAL_NUMBER			   VARCHAR2,
			X_TO_SERIAL_NUMBER_ID			   NUMBER,
 			X_ROW_STATUS_CODE                          NUMBER,
			X_LOCK_FLAG				   NUMBER,
			X_RESERVATION_ACTION_CODE		   NUMBER,
			X_TRANSACTION_MODE			   NUMBER,
			X_VALIDATION_FLAG			   NUMBER,
			X_PARTIAL_QUANTITIES_ALLOWED		   NUMBER,
			X_REQUEST_ID				   NUMBER,
			X_PROGRAM_APPLICATION_ID		   NUMBER,
			X_PROGRAM_ID				   NUMBER,
			X_PROGRAM_UPDATE_DATE			   DATE,
			X_PROJECT_ID				   NUMBER,
			X_TASK_ID				   NUMBER,
			X_PROJECT_PLANNING_GROUP		   NUMBER,
 			X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 			X_ATTRIBUTE1                               VARCHAR2,
 			X_ATTRIBUTE2                               VARCHAR2,
 			X_ATTRIBUTE3                               VARCHAR2,
 			X_ATTRIBUTE4                               VARCHAR2,
 			X_ATTRIBUTE5                               VARCHAR2,
 			X_ATTRIBUTE6                               VARCHAR2,
 			X_ATTRIBUTE7                               VARCHAR2,
 			X_ATTRIBUTE8                               VARCHAR2,
 			X_ATTRIBUTE9                               VARCHAR2,
 			X_ATTRIBUTE10                              VARCHAR2,
 			X_ATTRIBUTE11                              VARCHAR2,
 			X_ATTRIBUTE12                              VARCHAR2,
 			X_ATTRIBUTE13                              VARCHAR2,
 			X_ATTRIBUTE14                              VARCHAR2,
 			X_ATTRIBUTE15                              VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_reservations_interface
        WHERE  rowid = X_Rowid
	FOR UPDATE NOWAIT;
    Recinfo C%ROWTYPE;
    RECORD_CHANGED EXCEPTION;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if not (
               (   (Recinfo.reservation_batch_id = X_reservation_batch_id)
                OR (    (Recinfo.reservation_batch_id IS NULL)
                    AND (X_reservation_batch_id IS NULL)))
           AND (   (Recinfo.reservation_interface_id=X_reservation_interface_id)
                OR (    (Recinfo.reservation_interface_id IS NULL)
                    AND (X_reservation_interface_id IS NULL)))
           AND (   (Recinfo.requirement_date = X_requirement_date)
                OR (    (Recinfo.requirement_date IS NULL)
                    AND (X_requirement_date IS NULL)))
           AND (   (Recinfo.organization_id = X_organization_id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_organization_id IS NULL)))
           AND (   (Recinfo.to_organization_id = X_to_organization_id)
                OR (    (Recinfo.to_organization_id IS NULL)
                    AND (X_to_organization_id IS NULL)))
           AND (   (Recinfo.inventory_item_id =  X_inventory_item_id)
                OR (    (Recinfo.inventory_item_id IS NULL)
                    AND (X_inventory_item_id IS NULL)))
	   AND (   (Recinfo.item_segment1 =  X_item_segment1)
                OR (    (Recinfo.item_segment1 IS NULL)
                    AND (X_item_segment1 IS NULL)))
	   AND (   (Recinfo.item_segment2 =  X_item_segment2)
                OR (    (Recinfo.item_segment2 IS NULL)
                    AND (X_item_segment2 IS NULL)))
	   AND (   (Recinfo.item_segment3 =  X_item_segment3)
                OR (    (Recinfo.item_segment3 IS NULL)
                    AND (X_item_segment3 IS NULL)))
	   AND (   (Recinfo.item_segment4 =  X_item_segment4)
                OR (    (Recinfo.item_segment4 IS NULL)
                    AND (X_item_segment4 IS NULL)))
	   AND (   (Recinfo.item_segment5 =  X_item_segment5)
                OR (    (Recinfo.item_segment5 IS NULL)
                    AND (X_item_segment5 IS NULL)))
	   AND (   (Recinfo.item_segment6 =  X_item_segment6)
                OR (    (Recinfo.item_segment6 IS NULL)
                    AND (X_item_segment6 IS NULL)))
	   AND (   (Recinfo.item_segment7 =  X_item_segment7)
                OR (    (Recinfo.item_segment7 IS NULL)
                    AND (X_item_segment7 IS NULL)))
	   AND (   (Recinfo.item_segment8 =  X_item_segment8)
                OR (    (Recinfo.item_segment8 IS NULL)
                    AND (X_item_segment8 IS NULL)))
	   AND (   (Recinfo.item_segment9 =  X_item_segment9)
                OR (    (Recinfo.item_segment9 IS NULL)
                    AND (X_item_segment9 IS NULL)))
	   AND (   (Recinfo.item_segment10 =  X_item_segment10)
                OR (    (Recinfo.item_segment10 IS NULL)
                    AND (X_item_segment10 IS NULL)))
	   AND (   (Recinfo.item_segment11 =  X_item_segment11)
                OR (    (Recinfo.item_segment11 IS NULL)
                    AND (X_item_segment11 IS NULL)))
	   AND (   (Recinfo.item_segment12 =  X_item_segment12)
                OR (    (Recinfo.item_segment12 IS NULL)
                    AND (X_item_segment12 IS NULL)))
	   AND (   (Recinfo.item_segment13 =  X_item_segment13)
                OR (    (Recinfo.item_segment13 IS NULL)
                    AND (X_item_segment13 IS NULL)))
	   AND (   (Recinfo.item_segment14 =  X_item_segment14)
                OR (    (Recinfo.item_segment14 IS NULL)
                    AND (X_item_segment14 IS NULL)))
	   AND (   (Recinfo.item_segment15 =  X_item_segment15)
                OR (    (Recinfo.item_segment15 IS NULL)
                    AND (X_item_segment15 IS NULL)))
	   AND (   (Recinfo.item_segment16 =  X_item_segment16)
                OR (    (Recinfo.item_segment16 IS NULL)
                    AND (X_item_segment16 IS NULL)))
	   AND (   (Recinfo.item_segment17 =  X_item_segment17)
                OR (    (Recinfo.item_segment17 IS NULL)
                    AND (X_item_segment17 IS NULL)))
	   AND (   (Recinfo.item_segment18 =  X_item_segment18)
                OR (    (Recinfo.item_segment18 IS NULL)
                    AND (X_item_segment18 IS NULL)))
	   AND (   (Recinfo.item_segment19 =  X_item_segment19)
                OR (    (Recinfo.item_segment19 IS NULL)
                    AND (X_item_segment19 IS NULL)))
	   AND (   (Recinfo.item_segment20 =  X_item_segment20)
                OR (    (Recinfo.item_segment20 IS NULL)
                    AND (X_item_segment20 IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
	       (   (Recinfo.demand_source_type_id = X_demand_source_type_id)
                OR (    (Recinfo.demand_source_type_id IS NULL)
                    AND (X_demand_source_type_id IS NULL)))
	   AND (   (Recinfo.demand_source_name = X_demand_source_name)
                OR (    (Recinfo.demand_source_name IS NULL)
                    AND (X_demand_source_name IS NULL)))
	   AND (   (Recinfo.demand_source_header_id = X_demand_source_header_id)
                OR (    (Recinfo.demand_source_header_id IS NULL)
                    AND (X_demand_source_header_id IS NULL)))
	   AND (   (Recinfo.demand_source_line_id = X_demand_source_line_id)
                OR (    (Recinfo.demand_source_line_id IS NULL)
                    AND (X_demand_source_line_id IS NULL)))
	   AND (   (Recinfo.to_demand_source_type_id=X_to_demand_source_type_id)
                OR (    (Recinfo.to_demand_source_type_id IS NULL)
                    AND (X_to_demand_source_type_id IS NULL)))
	   AND (   (Recinfo.to_demand_source_name = X_to_demand_source_name)
                OR (    (Recinfo.to_demand_source_name IS NULL)
                    AND (X_to_demand_source_name IS NULL)))
	   AND (   (Recinfo.to_demand_source_header_id=X_to_demand_source_header_id)
                OR (    (Recinfo.to_demand_source_header_id IS NULL)
                    AND (X_to_demand_source_header_id IS NULL)))
	   AND (   (Recinfo.to_demand_source_line_id=X_to_demand_source_line_id)
                OR (    (Recinfo.to_demand_source_line_id IS NULL)
                    AND (X_to_demand_source_line_id IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
	       (   (Recinfo.primary_uom_code = X_primary_uom_code)
                OR (    (Recinfo.primary_uom_code IS NULL)
                    AND (X_primary_uom_code IS NULL)))
	   AND (   (Recinfo.primary_uom_id = X_primary_uom_id)
                OR (    (Recinfo.primary_uom_id IS NULL)
                    AND (X_primary_uom_id IS NULL)))
	   AND (   (Recinfo.secondary_uom_code = X_secondary_uom_code)    --InvConv change
                OR (    (Recinfo.secondary_uom_code IS NULL)
                    AND (X_secondary_uom_code IS NULL)))
	   AND (   (Recinfo.secondary_uom_id = X_secondary_uom_id)        --InvConv change
                OR (    (Recinfo.secondary_uom_id IS NULL)
                    AND (X_secondary_uom_id IS NULL)))
	   AND (   (Recinfo.reservation_uom_code = X_reservation_uom_code)
                OR (    (Recinfo.reservation_uom_code IS NULL)
                    AND (X_reservation_uom_code IS NULL)))
	   AND (   (Recinfo.reservation_uom_id = X_reservation_uom_id)
                OR (    (Recinfo.reservation_uom_id IS NULL)
                    AND (X_reservation_uom_id IS NULL)))
	   AND (   (Recinfo.reservation_quantity = X_reservation_quantity)
                OR (    (Recinfo.reservation_quantity IS NULL)
                    AND (X_reservation_quantity IS NULL)))
	   AND (   (Recinfo.primary_reservation_quantity=X_primary_reservation_quantity)
                OR (    (Recinfo.primary_reservation_quantity IS NULL)
                    AND (X_primary_reservation_quantity IS NULL)))
	   AND (   (Recinfo.secondary_reservation_quantity=X_secondary_rsv_quantity)    --InvConv change
                OR (    (Recinfo.secondary_reservation_quantity IS NULL)
                    AND (X_secondary_rsv_quantity IS NULL)))
	   AND (   (Recinfo.external_source_code = X_external_source_code)
                OR (    (Recinfo.external_source_code IS NULL)
                    AND (X_external_source_code IS NULL)))
	   AND (   (Recinfo.external_source_line_id = X_external_source_line_id)
                OR (    (Recinfo.external_source_line_id IS NULL)
                    AND (X_external_source_line_id IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
	       (   (Recinfo.supply_source_type_id = X_supply_source_type_id)
                OR (    (Recinfo.supply_source_type_id IS NULL)
                    AND (X_supply_source_type_id IS NULL)))
	   AND (   (Recinfo.supply_source_name = X_supply_source_name)
                OR (    (Recinfo.supply_source_name IS NULL)
                    AND (X_supply_source_name IS NULL)))
	   AND (   (Recinfo.supply_source_header_id = X_supply_source_header_id)
                OR (    (Recinfo.supply_source_header_id IS NULL)
                    AND (X_supply_source_header_id IS NULL)))
	   AND (   (Recinfo.supply_source_line_id = X_supply_source_line_id)
                OR (    (Recinfo.supply_source_line_id IS NULL)
                    AND (X_supply_source_line_id IS NULL)))
	   AND ((Recinfo.supply_source_line_detail=X_supply_source_line_detail)
                OR (    (Recinfo.supply_source_line_detail IS NULL)
                    AND (X_supply_source_line_detail IS NULL)))
	   AND (   (Recinfo.to_supply_source_type_id = X_to_supply_source_type_id)
                OR (    (Recinfo.to_supply_source_type_id IS NULL)
                    AND (X_to_supply_source_type_id IS NULL)))
	   AND (   (Recinfo.to_supply_source_name = X_to_supply_source_name)
                OR (    (Recinfo.to_supply_source_name IS NULL)
                    AND (X_to_supply_source_name IS NULL)))
	   AND (   (Recinfo.to_supply_source_header_id = X_to_supply_source_header_id)
                OR (    (Recinfo.to_supply_source_header_id IS NULL)
                    AND (X_to_supply_source_header_id IS NULL)))
	   AND (   (Recinfo.to_supply_source_line_id = X_to_supply_source_line_id)
                OR (    (Recinfo.to_supply_source_line_id IS NULL)
                    AND (X_to_supply_source_line_id IS NULL)))
	   AND ((Recinfo.to_supply_source_line_detail=X_to_supply_source_line_detail)
                OR (    (Recinfo.to_supply_source_line_detail IS NULL)
                    AND (X_to_supply_source_line_detail IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
	       (   (Recinfo.error_code = X_error_code)
                OR (    (Recinfo.error_code IS NULL)
                    AND (X_error_code IS NULL)))
	   AND (   (Recinfo.error_explanation = X_error_explanation)
                OR (    (Recinfo.error_explanation IS NULL)
                    AND (X_error_explanation IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
	       (   (Recinfo.revision = X_revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_revision IS NULL)))
	   AND (   (Recinfo.subinventory_code = X_subinventory_code)
                OR (    (Recinfo.subinventory_code IS NULL)
                    AND (X_subinventory_code IS NULL)))
	   AND (   (Recinfo.subinventory_id = X_subinventory_id)
                OR (    (Recinfo.subinventory_id IS NULL)
                    AND (X_subinventory_id IS NULL)))
	   AND (   (Recinfo.locator_id = X_locator_id)
                OR (    (Recinfo.locator_id IS NULL)
                    AND (X_locator_id IS NULL)))
           AND (   (Recinfo.Loc_Segment1 =  X_Loc_Segment1)
                OR (    (Recinfo.Loc_Segment1 IS NULL)
                    AND (X_Loc_Segment1 IS NULL)))
           AND (   (Recinfo.Loc_Segment2 =  X_Loc_Segment2)
                OR (    (Recinfo.Loc_Segment2 IS NULL)
                    AND (X_Loc_Segment2 IS NULL)))
           AND (   (Recinfo.Loc_Segment3 =  X_Loc_Segment3)
                OR (    (Recinfo.Loc_Segment3 IS NULL)
                    AND (X_Loc_Segment3 IS NULL)))
           AND (   (Recinfo.Loc_Segment4 =  X_Loc_Segment4)
                OR (    (Recinfo.Loc_Segment4 IS NULL)
                    AND (X_Loc_Segment4 IS NULL)))
           AND (   (Recinfo.Loc_Segment5 =  X_Loc_Segment5)
                OR (    (Recinfo.Loc_Segment5 IS NULL)
                    AND (X_Loc_Segment5 IS NULL)))
           AND (   (Recinfo.Loc_Segment6 =  X_Loc_Segment6)
                OR (    (Recinfo.Loc_Segment6 IS NULL)
                    AND (X_Loc_Segment6 IS NULL)))
           AND (   (Recinfo.Loc_Segment7 =  X_Loc_Segment7)
                OR (    (Recinfo.Loc_Segment7 IS NULL)
                    AND (X_Loc_Segment7 IS NULL)))
           AND (   (Recinfo.Loc_Segment8 =  X_Loc_Segment8)
                OR (    (Recinfo.Loc_Segment8 IS NULL)
                    AND (X_Loc_Segment8 IS NULL)))
           AND (   (Recinfo.Loc_Segment9 =  X_Loc_Segment9)
                OR (    (Recinfo.Loc_Segment9 IS NULL)
                    AND (X_Loc_Segment9 IS NULL)))
           AND (   (Recinfo.Loc_Segment10 =  X_Loc_Segment10)
                OR (    (Recinfo.Loc_Segment10 IS NULL)
                    AND (X_Loc_Segment10 IS NULL)))
           AND (   (Recinfo.Loc_Segment11 =  X_Loc_Segment11)
                OR (    (Recinfo.Loc_Segment11 IS NULL)
                    AND (X_Loc_Segment11 IS NULL)))
           AND (   (Recinfo.Loc_Segment12 =  X_Loc_Segment12)
                OR (    (Recinfo.Loc_Segment12 IS NULL)
                    AND (X_Loc_Segment12 IS NULL)))
           AND (   (Recinfo.Loc_Segment13 =  X_Loc_Segment13)
                OR (    (Recinfo.Loc_Segment13 IS NULL)
                    AND (X_Loc_Segment13 IS NULL)))
           AND (   (Recinfo.Loc_Segment14 =  X_Loc_Segment14)
                OR (    (Recinfo.Loc_Segment14 IS NULL)
                    AND (X_Loc_Segment14 IS NULL)))
           AND (   (Recinfo.Loc_Segment15 =  X_Loc_Segment15)
                OR (    (Recinfo.Loc_Segment15 IS NULL)
                    AND (X_Loc_Segment15 IS NULL)))
           AND (   (Recinfo.Loc_Segment16 =  X_Loc_Segment16)
                OR (    (Recinfo.Loc_Segment16 IS NULL)
                    AND (X_Loc_Segment16 IS NULL)))
           AND (   (Recinfo.Loc_Segment17 =  X_Loc_Segment17)
                OR (    (Recinfo.Loc_Segment17 IS NULL)
                    AND (X_Loc_Segment17 IS NULL)))
           AND (   (Recinfo.Loc_Segment18 =  X_Loc_Segment18)
                OR (    (Recinfo.Loc_Segment18 IS NULL)
                    AND (X_Loc_Segment18 IS NULL)))
           AND (   (Recinfo.Loc_Segment19 =  X_Loc_Segment19)
                OR (    (Recinfo.Loc_Segment19 IS NULL)
                    AND (X_Loc_Segment19 IS NULL)))
           AND (   (Recinfo.Loc_Segment20 =  X_Loc_Segment20)
                OR (    (Recinfo.Loc_Segment20 IS NULL)
                    AND (X_Loc_Segment20 IS NULL)))
           AND (   (Recinfo.lot_number =  X_lot_number)
                OR (    (Recinfo.lot_number IS NULL)
                    AND (X_lot_number IS NULL)))
           AND (   (Recinfo.lot_number_id =  X_lot_number_id)
                OR (    (Recinfo.lot_number_id IS NULL)
                    AND (X_lot_number_id IS NULL)))
           AND (   (Recinfo.serial_number =  X_serial_number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_serial_number IS NULL)))
           AND (   (Recinfo.serial_number_id =  X_serial_number_id)
                OR (    (Recinfo.serial_number_id IS NULL)
                    AND (X_serial_number_id IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
	       (   (Recinfo.to_revision = X_to_revision)
                OR (    (Recinfo.to_revision IS NULL)
                    AND (X_to_revision IS NULL)))
	   AND (   (Recinfo.to_subinventory_code = X_to_subinventory_code)
                OR (    (Recinfo.to_subinventory_code IS NULL)
                    AND (X_to_subinventory_code IS NULL)))
	   AND (   (Recinfo.to_subinventory_id = X_to_subinventory_id)
                OR (    (Recinfo.to_subinventory_id IS NULL)
                    AND (X_to_subinventory_id IS NULL)))
	   AND (   (Recinfo.to_locator_id = X_to_locator_id)
                OR (    (Recinfo.to_locator_id IS NULL)
                    AND (X_to_locator_id IS NULL)))
           AND (   (Recinfo.to_Loc_Segment1 =  X_to_Loc_Segment1)
                OR (    (Recinfo.to_Loc_Segment1 IS NULL)
                    AND (X_to_Loc_Segment1 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment2 =  X_to_Loc_Segment2)
                OR (    (Recinfo.to_Loc_Segment2 IS NULL)
                    AND (X_to_Loc_Segment2 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment3 =  X_to_Loc_Segment3)
                OR (    (Recinfo.to_Loc_Segment3 IS NULL)
                    AND (X_to_Loc_Segment3 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment4 =  X_to_Loc_Segment4)
                OR (    (Recinfo.to_Loc_Segment4 IS NULL)
                    AND (X_to_Loc_Segment4 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment5 =  X_to_Loc_Segment5)
                OR (    (Recinfo.to_Loc_Segment5 IS NULL)
                    AND (X_to_Loc_Segment5 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment6 =  X_to_Loc_Segment6)
                OR (    (Recinfo.to_Loc_Segment6 IS NULL)
                    AND (X_to_Loc_Segment6 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment7 =  X_to_Loc_Segment7)
                OR (    (Recinfo.to_Loc_Segment7 IS NULL)
                    AND (X_to_Loc_Segment7 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment8 =  X_to_Loc_Segment8)
                OR (    (Recinfo.to_Loc_Segment8 IS NULL)
                    AND (X_to_Loc_Segment8 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment9 =  X_to_Loc_Segment9)
                OR (    (Recinfo.to_Loc_Segment9 IS NULL)
                    AND (X_to_Loc_Segment9 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment10 =  X_to_Loc_Segment10)
                OR (    (Recinfo.to_Loc_Segment10 IS NULL)
                    AND (X_to_Loc_Segment10 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment11 =  X_to_Loc_Segment11)
                OR (    (Recinfo.to_Loc_Segment11 IS NULL)
                    AND (X_to_Loc_Segment11 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment12 =  X_to_Loc_Segment12)
                OR (    (Recinfo.to_Loc_Segment12 IS NULL)
                    AND (X_to_Loc_Segment12 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment13 =  X_to_Loc_Segment13)
                OR (    (Recinfo.to_Loc_Segment13 IS NULL)
                    AND (X_to_Loc_Segment13 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment14 =  X_to_Loc_Segment14)
                OR (    (Recinfo.to_Loc_Segment14 IS NULL)
                    AND (X_to_Loc_Segment14 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment15 =  X_to_Loc_Segment15)
                OR (    (Recinfo.to_Loc_Segment15 IS NULL)
                    AND (X_to_Loc_Segment15 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment16 =  X_to_Loc_Segment16)
                OR (    (Recinfo.to_Loc_Segment16 IS NULL)
                    AND (X_to_Loc_Segment16 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment17 =  X_to_Loc_Segment17)
                OR (    (Recinfo.to_Loc_Segment17 IS NULL)
                    AND (X_to_Loc_Segment17 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment18 =  X_to_Loc_Segment18)
                OR (    (Recinfo.to_Loc_Segment18 IS NULL)
                    AND (X_to_Loc_Segment18 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment19 =  X_to_Loc_Segment19)
                OR (    (Recinfo.to_Loc_Segment19 IS NULL)
                    AND (X_to_Loc_Segment19 IS NULL)))
           AND (   (Recinfo.to_Loc_Segment20 =  X_to_Loc_Segment20)
                OR (    (Recinfo.to_Loc_Segment20 IS NULL)
                    AND (X_to_Loc_Segment20 IS NULL)))
           AND (   (Recinfo.to_lot_number =  X_to_lot_number)
                OR (    (Recinfo.to_lot_number IS NULL)
                    AND (X_to_lot_number IS NULL)))
           AND (   (Recinfo.to_lot_number_id =  X_to_lot_number_id)
                OR (    (Recinfo.to_lot_number_id IS NULL)
                    AND (X_to_lot_number_id IS NULL)))
           AND (   (Recinfo.to_serial_number =  X_to_serial_number)
                OR (    (Recinfo.to_serial_number IS NULL)
                    AND (X_to_serial_number IS NULL)))
           AND (   (Recinfo.to_serial_number_id =  X_to_serial_number_id)
                OR (    (Recinfo.to_serial_number_id IS NULL)
                    AND (X_to_serial_number_id IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;

    if not (
               (   (Recinfo.row_status_code = X_row_status_code)
                OR (    (Recinfo.row_status_code IS NULL)
                    AND (X_row_status_code IS NULL)))
           AND (   (Recinfo.lock_flag = X_lock_flag)
                OR (    (Recinfo.lock_flag IS NULL)
                    AND (X_lock_flag IS NULL)))
           AND (   (Recinfo.reservation_action_code = X_reservation_action_code)
                OR (    (Recinfo.reservation_action_code IS NULL)
                    AND (X_reservation_action_code IS NULL)))
           AND (   (Recinfo.transaction_mode = X_transaction_mode)
                OR (    (Recinfo.transaction_mode IS NULL)
                    AND (X_transaction_mode IS NULL)))
           AND (   (Recinfo.validation_flag = X_validation_flag)
                OR (    (Recinfo.validation_flag IS NULL)
                    AND (X_validation_flag IS NULL)))
           AND ((Recinfo.partial_quantities_allowed = X_partial_quantities_allowed)
                OR (    (Recinfo.partial_quantities_allowed IS NULL)
                    AND (X_partial_quantities_allowed IS NULL)))
           AND (   (Recinfo.request_id = X_request_id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (X_request_id IS NULL)))
           AND (   (Recinfo.program_application_id = X_program_application_id)
                OR (    (Recinfo.program_application_id IS NULL)
                    AND (X_program_application_id IS NULL)))
           AND (   (Recinfo.program_id = X_program_id)
                OR (    (Recinfo.program_id IS NULL)
                    AND (X_program_id IS NULL)))
           AND (   (Recinfo.program_update_date = X_program_update_date)
                OR (    (Recinfo.program_update_date IS NULL)
                    AND (X_program_update_date IS NULL)))
           AND (   (Recinfo.project_id = X_project_id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (X_project_id IS NULL)))
           AND (   (Recinfo.task_id = X_task_id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_task_id IS NULL)))
           AND (   (Recinfo.project_planning_group = X_project_planning_group)
                OR (    (Recinfo.project_planning_group IS NULL)
                    AND (X_project_planning_group IS NULL)))
           AND (   (Recinfo.attribute_category = X_attribute_category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_attribute_category IS NULL)))
           AND (   (Recinfo.attribute1 = X_attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_attribute15 IS NULL)))
	   ) then
		RAISE RECORD_CHANGED;
    end if;
    exception
    WHEN RECORD_CHANGED then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    WHEN OTHERS then
      raise;
  END Lock_Row;

  PROCEDURE Update_Row( X_ROWID 				   VARCHAR2,
			X_RESERVATION_INTERFACE_ID                 NUMBER,
			X_RESERVATION_BATCH_ID                 	   NUMBER,
			X_REQUIREMENT_DATE			   DATE,
			X_ORGANIZATION_ID			   NUMBER,
			X_TO_ORGANIZATION_ID			   NUMBER,
 			X_INVENTORY_ITEM_ID                        NUMBER,
 			X_ITEM_SEGMENT1                            VARCHAR2,
 			X_ITEM_SEGMENT2                            VARCHAR2,
 			X_ITEM_SEGMENT3                            VARCHAR2,
 			X_ITEM_SEGMENT4                            VARCHAR2,
 			X_ITEM_SEGMENT5                            VARCHAR2,
 			X_ITEM_SEGMENT6                            VARCHAR2,
 			X_ITEM_SEGMENT7                            VARCHAR2,
 			X_ITEM_SEGMENT8                            VARCHAR2,
 			X_ITEM_SEGMENT9                            VARCHAR2,
 			X_ITEM_SEGMENT10                           VARCHAR2,
 			X_ITEM_SEGMENT11                           VARCHAR2,
 			X_ITEM_SEGMENT12                           VARCHAR2,
 			X_ITEM_SEGMENT13                           VARCHAR2,
 			X_ITEM_SEGMENT14                           VARCHAR2,
 			X_ITEM_SEGMENT15                           VARCHAR2,
 			X_ITEM_SEGMENT16                           VARCHAR2,
 			X_ITEM_SEGMENT17                           VARCHAR2,
 			X_ITEM_SEGMENT18                           VARCHAR2,
 			X_ITEM_SEGMENT19                           VARCHAR2,
 			X_ITEM_SEGMENT20                           VARCHAR2,
 			X_DEMAND_SOURCE_TYPE_ID                    NUMBER,
			X_DEMAND_SOURCE_NAME			   VARCHAR2,
 			X_DEMAND_SOURCE_HEADER_ID                  NUMBER,
 			X_DEMAND_SOURCE_LINE_ID                    NUMBER,
 			X_TO_DEMAND_SOURCE_TYPE_ID                 NUMBER,
			X_TO_DEMAND_SOURCE_NAME			   VARCHAR2,
 			X_TO_DEMAND_SOURCE_HEADER_ID               NUMBER,
 			X_TO_DEMAND_SOURCE_LINE_ID                 NUMBER,
			X_PRIMARY_UOM_CODE			   VARCHAR2,
			X_PRIMARY_UOM_ID			   NUMBER,
			X_SECONDARY_UOM_CODE			   VARCHAR2,   --InvConv change
			X_SECONDARY_UOM_ID			   NUMBER,     --InvConv change
			X_RESERVATION_UOM_CODE			   VARCHAR2,
			X_RESERVATION_UOM_ID			   NUMBER,
			X_RESERVATION_QUANTITY			   NUMBER,
			X_PRIMARY_RESERVATION_QUANTITY		   NUMBER,
			X_SECONDARY_RSV_QUANTITY		   NUMBER,     --InvConv change
			X_EXTERNAL_SOURCE_CODE			   VARCHAR2,
			X_EXTERNAL_SOURCE_LINE_ID		   NUMBER,
 			X_SUPPLY_SOURCE_TYPE_ID                    NUMBER,
			X_SUPPLY_SOURCE_NAME			   VARCHAR2,
 			X_SUPPLY_SOURCE_HEADER_ID                  NUMBER,
 			X_SUPPLY_SOURCE_LINE_ID                    NUMBER,
 			X_SUPPLY_SOURCE_LINE_DETAIL                NUMBER,
 			X_TO_SUPPLY_SOURCE_TYPE_ID                 NUMBER,
			X_TO_SUPPLY_SOURCE_NAME			   VARCHAR2,
 			X_TO_SUPPLY_SOURCE_HEADER_ID               NUMBER,
 			X_TO_SUPPLY_SOURCE_LINE_ID                    NUMBER,
 			X_TO_SUPPLY_SOURCE_LINE_DETAIL             NUMBER,
 			X_ERROR_CODE                               NUMBER,
 			X_ERROR_EXPLANATION                        VARCHAR2,
			X_REVISION				   VARCHAR2,
			X_SUBINVENTORY_CODE			   VARCHAR2,
			X_SUBINVENTORY_ID			   NUMBER,
			X_LOCATOR_ID				   NUMBER,
 			X_LOC_SEGMENT1                             VARCHAR2,
 			X_LOC_SEGMENT2                             VARCHAR2,
 			X_LOC_SEGMENT3                             VARCHAR2,
 			X_LOC_SEGMENT4                             VARCHAR2,
 			X_LOC_SEGMENT5                             VARCHAR2,
 			X_LOC_SEGMENT6                             VARCHAR2,
 			X_LOC_SEGMENT7                             VARCHAR2,
 			X_LOC_SEGMENT8                             VARCHAR2,
 			X_LOC_SEGMENT9                             VARCHAR2,
 			X_LOC_SEGMENT10                            VARCHAR2,
 			X_LOC_SEGMENT11                            VARCHAR2,
 			X_LOC_SEGMENT12                            VARCHAR2,
 			X_LOC_SEGMENT13                            VARCHAR2,
 			X_LOC_SEGMENT14                            VARCHAR2,
 			X_LOC_SEGMENT15                            VARCHAR2,
 			X_LOC_SEGMENT16                            VARCHAR2,
 			X_LOC_SEGMENT17                            VARCHAR2,
 			X_LOC_SEGMENT18                            VARCHAR2,
 			X_LOC_SEGMENT19                            VARCHAR2,
 			X_LOC_SEGMENT20                            VARCHAR2,
			X_LOT_NUMBER				   VARCHAR2,
			X_LOT_NUMBER_ID				   NUMBER,
			X_SERIAL_NUMBER				   VARCHAR2,
			X_SERIAL_NUMBER_ID			   NUMBER,
			X_TO_REVISION				   VARCHAR2,
			X_TO_SUBINVENTORY_CODE			   VARCHAR2,
			X_TO_SUBINVENTORY_ID			   NUMBER,
			X_TO_LOCATOR_ID				   NUMBER,
 			X_TO_LOC_SEGMENT1    			   VARCHAR2,
 			X_TO_LOC_SEGMENT2                          VARCHAR2,
 			X_TO_LOC_SEGMENT3                          VARCHAR2,
 			X_TO_LOC_SEGMENT4                          VARCHAR2,
 			X_TO_LOC_SEGMENT5                          VARCHAR2,
 			X_TO_LOC_SEGMENT6                          VARCHAR2,
 			X_TO_LOC_SEGMENT7                          VARCHAR2,
 			X_TO_LOC_SEGMENT8                          VARCHAR2,
 			X_TO_LOC_SEGMENT9                          VARCHAR2,
 			X_TO_LOC_SEGMENT10                         VARCHAR2,
 			X_TO_LOC_SEGMENT11                         VARCHAR2,
 			X_TO_LOC_SEGMENT12                         VARCHAR2,
 			X_TO_LOC_SEGMENT13                         VARCHAR2,
 			X_TO_LOC_SEGMENT14                         VARCHAR2,
 			X_TO_LOC_SEGMENT15                         VARCHAR2,
 			X_TO_LOC_SEGMENT16                         VARCHAR2,
 			X_TO_LOC_SEGMENT17                         VARCHAR2,
 			X_TO_LOC_SEGMENT18                         VARCHAR2,
 			X_TO_LOC_SEGMENT19                         VARCHAR2,
 			X_TO_LOC_SEGMENT20                         VARCHAR2,
			X_TO_LOT_NUMBER				   VARCHAR2,
			X_TO_LOT_NUMBER_ID			   NUMBER,
			X_TO_SERIAL_NUMBER			   VARCHAR2,
			X_TO_SERIAL_NUMBER_ID			   NUMBER,
 			X_ROW_STATUS_CODE                          NUMBER,
			X_LOCK_FLAG				   NUMBER,
			X_RESERVATION_ACTION_CODE		   NUMBER,
			X_TRANSACTION_MODE			   NUMBER,
			X_VALIDATION_FLAG			   NUMBER,
			X_PARTIAL_QUANTITIES_ALLOWED		   NUMBER,
 			X_LAST_UPDATE_DATE                 	   DATE,
 			X_LAST_UPDATED_BY                 	   NUMBER,
 			X_LAST_UPDATE_LOGIN                        NUMBER,
			X_REQUEST_ID				   NUMBER,
			X_PROGRAM_APPLICATION_ID		   NUMBER,
			X_PROGRAM_ID				   NUMBER,
			X_PROGRAM_UPDATE_DATE			   DATE,
			X_PROJECT_ID				   NUMBER,
			X_TASK_ID				   NUMBER,
			X_PROJECT_PLANNING_GROUP		   NUMBER,
 			X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 			X_ATTRIBUTE1                               VARCHAR2,
 			X_ATTRIBUTE2                               VARCHAR2,
 			X_ATTRIBUTE3                               VARCHAR2,
 			X_ATTRIBUTE4                               VARCHAR2,
 			X_ATTRIBUTE5                               VARCHAR2,
 			X_ATTRIBUTE6                               VARCHAR2,
 			X_ATTRIBUTE7                               VARCHAR2,
 			X_ATTRIBUTE8                               VARCHAR2,
 			X_ATTRIBUTE9                               VARCHAR2,
 			X_ATTRIBUTE10                              VARCHAR2,
 			X_ATTRIBUTE11                              VARCHAR2,
 			X_ATTRIBUTE12                              VARCHAR2,
 			X_ATTRIBUTE13                              VARCHAR2,
 			X_ATTRIBUTE14                              VARCHAR2,
 			X_ATTRIBUTE15                              VARCHAR2
  ) IS
  BEGIN
    UPDATE mtl_reservations_interface
    SET
      RESERVATION_INTERFACE_ID       = X_RESERVATION_INTERFACE_ID,
      RESERVATION_BATCH_ID           = X_RESERVATION_BATCH_ID,
      REQUIREMENT_DATE               = X_REQUIREMENT_DATE,
      ORGANIZATION_ID	             = X_ORGANIZATION_ID,
      TO_ORGANIZATION_ID             = X_TO_ORGANIZATION_ID,
      INVENTORY_ITEM_ID              = X_INVENTORY_ITEM_ID,
      ITEM_SEGMENT1                  = X_ITEM_SEGMENT1,
      ITEM_SEGMENT2                  = X_ITEM_SEGMENT2,
      ITEM_SEGMENT3                  = X_ITEM_SEGMENT3,
      ITEM_SEGMENT4                  = X_ITEM_SEGMENT4,
      ITEM_SEGMENT5                  = X_ITEM_SEGMENT5,
      ITEM_SEGMENT6                  = X_ITEM_SEGMENT6,
      ITEM_SEGMENT7                  = X_ITEM_SEGMENT7,
      ITEM_SEGMENT8                  = X_ITEM_SEGMENT8,
      ITEM_SEGMENT9                  = X_ITEM_SEGMENT9,
      ITEM_SEGMENT10                 = X_ITEM_SEGMENT10,
      ITEM_SEGMENT11                 = X_ITEM_SEGMENT11,
      ITEM_SEGMENT12                 = X_ITEM_SEGMENT12,
      ITEM_SEGMENT13                 = X_ITEM_SEGMENT13,
      ITEM_SEGMENT14                 = X_ITEM_SEGMENT14,
      ITEM_SEGMENT15                 = X_ITEM_SEGMENT15,
      ITEM_SEGMENT16                 = X_ITEM_SEGMENT16,
      ITEM_SEGMENT17                 = X_ITEM_SEGMENT17,
      ITEM_SEGMENT18                 = X_ITEM_SEGMENT18,
      ITEM_SEGMENT19                 = X_ITEM_SEGMENT19,
      ITEM_SEGMENT20                 = X_ITEM_SEGMENT20,
      DEMAND_SOURCE_TYPE_ID          = X_DEMAND_SOURCE_TYPE_ID,
      DEMAND_SOURCE_NAME             = X_DEMAND_SOURCE_NAME,
      DEMAND_SOURCE_HEADER_ID        = X_DEMAND_SOURCE_HEADER_ID,
      DEMAND_SOURCE_LINE_ID          = X_DEMAND_SOURCE_LINE_ID,
      TO_DEMAND_SOURCE_TYPE_ID       = X_TO_DEMAND_SOURCE_TYPE_ID,
      TO_DEMAND_SOURCE_NAME          = X_TO_DEMAND_SOURCE_NAME,
      TO_DEMAND_SOURCE_HEADER_ID     = X_TO_DEMAND_SOURCE_HEADER_ID,
      TO_DEMAND_SOURCE_LINE_ID       = X_TO_DEMAND_SOURCE_LINE_ID,
      PRIMARY_UOM_CODE		     = X_PRIMARY_UOM_CODE,
      PRIMARY_UOM_ID	             = X_PRIMARY_UOM_ID,
      SECONDARY_UOM_CODE	     = X_SECONDARY_UOM_CODE,   --InvConv change
      SECONDARY_UOM_ID	             = X_SECONDARY_UOM_ID,     --InvConv change
      RESERVATION_UOM_CODE	     = X_RESERVATION_UOM_CODE,
      RESERVATION_UOM_ID	     = X_RESERVATION_UOM_ID,
      RESERVATION_QUANTITY           = X_RESERVATION_QUANTITY,
      PRIMARY_RESERVATION_QUANTITY   = X_PRIMARY_RESERVATION_QUANTITY,
      SECONDARY_RESERVATION_QUANTITY = X_SECONDARY_RSV_QUANTITY,   --InvConv change
      EXTERNAL_SOURCE_CODE	     = X_EXTERNAL_SOURCE_CODE,
      EXTERNAL_SOURCE_LINE_ID        = X_EXTERNAL_SOURCE_LINE_ID,
      SUPPLY_SOURCE_TYPE_ID          = X_SUPPLY_SOURCE_TYPE_ID,
      SUPPLY_SOURCE_NAME	     = X_SUPPLY_SOURCE_NAME,
      SUPPLY_SOURCE_HEADER_ID        = X_SUPPLY_SOURCE_HEADER_ID,
      SUPPLY_SOURCE_LINE_ID          = X_SUPPLY_SOURCE_LINE_ID,
      SUPPLY_SOURCE_LINE_DETAIL      = X_SUPPLY_SOURCE_LINE_DETAIL,
      TO_SUPPLY_SOURCE_TYPE_ID       = X_TO_SUPPLY_SOURCE_TYPE_ID,
      TO_SUPPLY_SOURCE_NAME	     = X_TO_SUPPLY_SOURCE_NAME,
      TO_SUPPLY_SOURCE_HEADER_ID     = X_TO_SUPPLY_SOURCE_HEADER_ID,
      TO_SUPPLY_SOURCE_LINE_ID       = X_TO_SUPPLY_SOURCE_LINE_ID,
      TO_SUPPLY_SOURCE_LINE_DETAIL   = X_TO_SUPPLY_SOURCE_LINE_DETAIL,
      ERROR_CODE                     = X_ERROR_CODE,
      ERROR_EXPLANATION              = X_ERROR_EXPLANATION,
      REVISION			     = X_REVISION,
      SUBINVENTORY_CODE		     = X_SUBINVENTORY_CODE,
      SUBINVENTORY_ID	             = X_SUBINVENTORY_ID,
      LOCATOR_ID		     = X_LOCATOR_ID,
      LOC_SEGMENT1                   = X_LOC_SEGMENT1,
      LOC_SEGMENT2                   = X_LOC_SEGMENT2,
      LOC_SEGMENT3                   = X_LOC_SEGMENT3,
      LOC_SEGMENT4                   = X_LOC_SEGMENT4,
      LOC_SEGMENT5                   = X_LOC_SEGMENT5,
      LOC_SEGMENT6                   = X_LOC_SEGMENT6,
      LOC_SEGMENT7                   = X_LOC_SEGMENT7,
      LOC_SEGMENT8                   = X_LOC_SEGMENT8,
      LOC_SEGMENT9                   = X_LOC_SEGMENT9,
      LOC_SEGMENT10                  = X_LOC_SEGMENT10,
      LOC_SEGMENT11                  = X_LOC_SEGMENT11,
      LOC_SEGMENT12                  = X_LOC_SEGMENT12,
      LOC_SEGMENT13                  = X_LOC_SEGMENT13,
      LOC_SEGMENT14                  = X_LOC_SEGMENT14,
      LOC_SEGMENT15                  = X_LOC_SEGMENT15,
      LOC_SEGMENT16                  = X_LOC_SEGMENT16,
      LOC_SEGMENT17                  = X_LOC_SEGMENT17,
      LOC_SEGMENT18                  = X_LOC_SEGMENT18,
      LOC_SEGMENT19                  = X_LOC_SEGMENT19,
      LOC_SEGMENT20                  = X_LOC_SEGMENT20,
      LOT_NUMBER		     = X_LOT_NUMBER,
      LOT_NUMBER_ID		     = X_LOT_NUMBER_ID,
      SERIAL_NUMBER		     = X_SERIAL_NUMBER,
      SERIAL_NUMBER_ID	             = X_SERIAL_NUMBER_ID,
      TO_REVISION		     = X_TO_REVISION,
      TO_SUBINVENTORY_CODE	     = X_TO_SUBINVENTORY_CODE,
      TO_SUBINVENTORY_ID	     = X_TO_SUBINVENTORY_ID,
      TO_LOCATOR_ID		     = X_TO_LOCATOR_ID,
      TO_LOC_SEGMENT1    	     = X_TO_LOC_SEGMENT1,
      TO_LOC_SEGMENT2    	     = X_TO_LOC_SEGMENT2,
      TO_LOC_SEGMENT3    	     = X_TO_LOC_SEGMENT3,
      TO_LOC_SEGMENT4    	     = X_TO_LOC_SEGMENT4,
      TO_LOC_SEGMENT5    	     = X_TO_LOC_SEGMENT5,
      TO_LOC_SEGMENT6    	     = X_TO_LOC_SEGMENT6,
      TO_LOC_SEGMENT7    	     = X_TO_LOC_SEGMENT7,
      TO_LOC_SEGMENT8    	     = X_TO_LOC_SEGMENT8,
      TO_LOC_SEGMENT9    	     = X_TO_LOC_SEGMENT9,
      TO_LOC_SEGMENT10    	     = X_TO_LOC_SEGMENT10,
      TO_LOC_SEGMENT11    	     = X_TO_LOC_SEGMENT11,
      TO_LOC_SEGMENT12    	     = X_TO_LOC_SEGMENT12,
      TO_LOC_SEGMENT13    	     = X_TO_LOC_SEGMENT13,
      TO_LOC_SEGMENT14    	     = X_TO_LOC_SEGMENT14,
      TO_LOC_SEGMENT15    	     = X_TO_LOC_SEGMENT15,
      TO_LOC_SEGMENT16    	     = X_TO_LOC_SEGMENT16,
      TO_LOC_SEGMENT17    	     = X_TO_LOC_SEGMENT17,
      TO_LOC_SEGMENT18    	     = X_TO_LOC_SEGMENT18,
      TO_LOC_SEGMENT19    	     = X_TO_LOC_SEGMENT19,
      TO_LOC_SEGMENT20    	     = X_TO_LOC_SEGMENT20,
      TO_LOT_NUMBER		     = X_TO_LOT_NUMBER,
      TO_LOT_NUMBER_ID		     = X_TO_LOT_NUMBER_ID,
      TO_SERIAL_NUMBER	             = X_TO_SERIAL_NUMBER,
      TO_SERIAL_NUMBER_ID	     = X_TO_SERIAL_NUMBER_ID,
      ROW_STATUS_CODE                = X_ROW_STATUS_CODE,
      LOCK_FLAG		             = X_LOCK_FLAG,
      RESERVATION_ACTION_CODE	     = X_RESERVATION_ACTION_CODE,
      TRANSACTION_MODE	             = X_TRANSACTION_MODE,
      VALIDATION_FLAG	             = X_VALIDATION_FLAG,
      PARTIAL_QUANTITIES_ALLOWED     = X_PARTIAL_QUANTITIES_ALLOWED,
      LAST_UPDATE_DATE               = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY                = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN              = X_LAST_UPDATE_LOGIN,
      REQUEST_ID		     = X_REQUEST_ID,
      PROGRAM_APPLICATION_ID	     = X_PROGRAM_APPLICATION_ID,
      PROGRAM_ID		     = X_PROGRAM_ID,
      PROGRAM_UPDATE_DATE            = X_PROGRAM_UPDATE_DATE,
      PROJECT_ID		     = X_PROJECT_ID,
      TASK_ID		             = X_TASK_ID,
      PROJECT_PLANNING_GROUP         = X_PROJECT_PLANNING_GROUP,
      ATTRIBUTE_CATEGORY             = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1                     = X_ATTRIBUTE1,
      ATTRIBUTE2                     = X_ATTRIBUTE2,
      ATTRIBUTE3                     = X_ATTRIBUTE3,
      ATTRIBUTE4                     = X_ATTRIBUTE4,
      ATTRIBUTE5                     = X_ATTRIBUTE5,
      ATTRIBUTE6                     = X_ATTRIBUTE6,
      ATTRIBUTE7                     = X_ATTRIBUTE7,
      ATTRIBUTE8                     = X_ATTRIBUTE8,
      ATTRIBUTE9                     = X_ATTRIBUTE9,
      ATTRIBUTE10                    = X_ATTRIBUTE10,
      ATTRIBUTE11                    = X_ATTRIBUTE11,
      ATTRIBUTE12                    = X_ATTRIBUTE12,
      ATTRIBUTE13                    = X_ATTRIBUTE13,
      ATTRIBUTE14                    = X_ATTRIBUTE14,
      ATTRIBUTE15                    = X_ATTRIBUTE15
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(	X_ROWID  VARCHAR2)
  IS
  BEGIN
	delete from mtl_reservations_interface
	where rowid = X_ROWID;

	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Delete_Row;

END MTL_RESERVATIONS_INTERFACE_PKG;

/
