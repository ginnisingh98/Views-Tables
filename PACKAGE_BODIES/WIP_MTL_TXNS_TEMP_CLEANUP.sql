--------------------------------------------------------
--  DDL for Package Body WIP_MTL_TXNS_TEMP_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTL_TXNS_TEMP_CLEANUP" AS
/* $Header: wipmtclb.pls 115.7 2002/11/28 13:28:53 rmahidha ship $ */

  procedure fetch_and_delete(
    p_hdr_id in     number,
    p_act_id in     number default NULL,
    p_mtls   in out nocopy mtl_transactions_temp_rec) is

    i number := 0;

    cursor get_materials(
      c_hdr_id number,
      c_act_id number) is
    SELECT
      TRANSACTION_HEADER_ID,
      TRANSACTION_TEMP_ID,
      SOURCE_CODE,
      SOURCE_LINE_ID,
      TRANSACTION_MODE,
      LOCK_FLAG,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      INVENTORY_ITEM_ID,
      REVISION,
      ORGANIZATION_ID,
      SUBINVENTORY_CODE,
      LOCATOR_ID,
      TRANSACTION_QUANTITY,
      PRIMARY_QUANTITY,
      TRANSACTION_UOM,
      TRANSACTION_COST,
      TRANSACTION_TYPE_ID,
      TRANSACTION_ACTION_ID,
      TRANSACTION_SOURCE_TYPE_ID,
      TRANSACTION_SOURCE_ID,
      TRANSACTION_SOURCE_NAME,
      TRANSACTION_DATE,
      ACCT_PERIOD_ID,
      DISTRIBUTION_ACCOUNT_ID,
      TRANSACTION_REFERENCE,
      REASON_ID,
      LOT_NUMBER,
      LOT_EXPIRATION_DATE,
      SERIAL_NUMBER,
      RECEIVING_DOCUMENT,
      RCV_TRANSACTION_ID,
      MOVE_TRANSACTION_ID,
      COMPLETION_TRANSACTION_ID,
      WIP_ENTITY_TYPE,
      SCHEDULE_ID,
      REPETITIVE_LINE_ID,
      EMPLOYEE_CODE,
      SCHEDULE_UPDATE_CODE,
      SETUP_TEARDOWN_CODE,
      ITEM_ORDERING,
      NEGATIVE_REQ_FLAG,
      OPERATION_SEQ_NUM,
      PICKING_LINE_ID,
      TRX_SOURCE_LINE_ID,
      TRX_SOURCE_DELIVERY_ID,
      PHYSICAL_ADJUSTMENT_ID,
      CYCLE_COUNT_ID,
      RMA_LINE_ID,
      CUSTOMER_SHIP_ID,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_RATE,
      CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_DATE,
      USSGL_TRANSACTION_CODE,
      VENDOR_LOT_NUMBER,
      ENCUMBRANCE_ACCOUNT,
      ENCUMBRANCE_AMOUNT,
      SHIP_TO_LOCATION,
      SHIPMENT_NUMBER,
      TRANSFER_COST,
      TRANSPORTATION_COST,
      TRANSPORTATION_ACCOUNT,
      FREIGHT_CODE,
      CONTAINERS,
      WAYBILL_AIRBILL,
      EXPECTED_ARRIVAL_DATE,
      TRANSFER_SUBINVENTORY,
      TRANSFER_ORGANIZATION,
      TRANSFER_TO_LOCATION,
      NEW_AVERAGE_COST,
      VALUE_CHANGE,
      PERCENTAGE_CHANGE,
      MATERIAL_ALLOCATION_TEMP_ID,
      DEMAND_SOURCE_HEADER_ID,
      DEMAND_SOURCE_LINE,
      DEMAND_SOURCE_DELIVERY,
      ITEM_SEGMENTS,
      ITEM_DESCRIPTION,
      ITEM_TRX_ENABLED_FLAG,
      ITEM_LOCATION_CONTROL_CODE,
      ITEM_RESTRICT_SUBINV_CODE,
      ITEM_RESTRICT_LOCATORS_CODE,
      ITEM_REVISION_QTY_CONTROL_CODE,
      ITEM_PRIMARY_UOM_CODE,
      ITEM_UOM_CLASS,
      ITEM_SHELF_LIFE_CODE,
      ITEM_SHELF_LIFE_DAYS,
      ITEM_LOT_CONTROL_CODE,
      ITEM_SERIAL_CONTROL_CODE,
      ALLOWED_UNITS_LOOKUP_CODE,
      DEPARTMENT_ID,
      WIP_SUPPLY_TYPE,
      SUPPLY_SUBINVENTORY,
      SUPPLY_LOCATOR_ID,
      VALID_SUBINVENTORY_FLAG,
      VALID_LOCATOR_FLAG,
      LOCATOR_SEGMENTS,
      CURRENT_LOCATOR_CONTROL_CODE,
      NUMBER_OF_LOTS_ENTERED,
      WIP_COMMIT_FLAG,
      NEXT_LOT_NUMBER,
      LOT_ALPHA_PREFIX,
      NEXT_SERIAL_NUMBER,
      SERIAL_ALPHA_PREFIX,
      POSTING_FLAG,
      REQUIRED_FLAG,
      PROCESS_FLAG,
      ERROR_CODE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      PRIMARY_SWITCH,
      DEPARTMENT_CODE,
      ERROR_EXPLANATION,
      DEMAND_ID,
      ITEM_INVENTORY_ASSET_FLAG,
      SHIPPABLE_FLAG,
      REQUISITION_LINE_ID,
      REQUISITION_DISTRIBUTION_ID,
      MOVEMENT_ID,
      RESERVATION_QUANTITY,
      SHIPPED_QUANTITY,
      TRANSACTION_LINE_NUMBER,
      EXPENDITURE_TYPE,
      FINAL_COMPLETION_FLAG,
      MATERIAL_ACCOUNT,
      MATERIAL_OVERHEAD_ACCOUNT,
      OUTSIDE_PROCESSING_ACCOUNT,
      OVERHEAD_ACCOUNT,
      PA_EXPENDITURE_ORG_ID,
      PROJECT_ID,
      RESOURCE_ACCOUNT,
      SOURCE_PROJECT_ID,
      SOURCE_TASK_ID,
      TASK_ID,
      TO_PROJECT_ID,
      TO_TASK_ID,
      TRANSACTION_SEQUENCE_ID,
      transfer_percentage,
      qa_collection_id,
      overcompletion_transaction_id,
      overcompletion_transaction_qty,
      overcompletion_primary_qty,
      kanban_card_id
    FROM MTL_MATERIAL_TRANSACTIONS_TEMP
    WHERE TRANSACTION_HEADER_ID = c_hdr_id
    AND   TRANSACTION_ACTION_ID = NVL(c_act_id, TRANSACTION_ACTION_ID);

    mtl_rec get_materials%rowtype;
  begin
    -- initialize
    if (p_mtls.numrecs is NULL) then
      -- p_mtls is empty
      p_mtls.numrecs := i;
    else
      -- p_mtls already has records
      i := p_mtls.numrecs;
    end if;

    open get_materials(
      c_hdr_id => p_hdr_id,
      c_act_id => p_act_id);

    loop
      fetch get_materials into mtl_rec;

      exit when (get_materials%NOTFOUND);

      i := i + 1;
      p_mtls.numrecs := i;
      p_mtls.TRANSACTION_HEADER_ID(i) := mtl_rec.TRANSACTION_HEADER_ID;
      p_mtls.TRANSACTION_TEMP_ID(i) := mtl_rec.TRANSACTION_TEMP_ID;
      p_mtls.SOURCE_CODE(i) := mtl_rec.SOURCE_CODE;
      p_mtls.SOURCE_LINE_ID(i) := mtl_rec.SOURCE_LINE_ID;
      p_mtls.TRANSACTION_MODE(i) := mtl_rec.TRANSACTION_MODE;
      p_mtls.LOCK_FLAG(i) := mtl_rec.LOCK_FLAG;
      p_mtls.LAST_UPDATE_DATE(i) := mtl_rec.LAST_UPDATE_DATE;
      p_mtls.LAST_UPDATED_BY(i) := mtl_rec.LAST_UPDATED_BY;
      p_mtls.CREATION_DATE(i) := mtl_rec.CREATION_DATE;
      p_mtls.CREATED_BY(i) := mtl_rec.CREATED_BY;
      p_mtls.LAST_UPDATE_LOGIN(i) := mtl_rec.LAST_UPDATE_LOGIN;
      p_mtls.REQUEST_ID(i) := mtl_rec.REQUEST_ID;
      p_mtls.PROGRAM_APPLICATION_ID(i) := mtl_rec.PROGRAM_APPLICATION_ID;
      p_mtls.PROGRAM_ID(i) := mtl_rec.PROGRAM_ID;
      p_mtls.PROGRAM_UPDATE_DATE(i) := mtl_rec.PROGRAM_UPDATE_DATE;
      p_mtls.INVENTORY_ITEM_ID(i) := mtl_rec.INVENTORY_ITEM_ID;
      p_mtls.REVISION(i) := mtl_rec.REVISION;
      p_mtls.ORGANIZATION_ID(i) := mtl_rec.ORGANIZATION_ID;
      p_mtls.SUBINVENTORY_CODE(i) := mtl_rec.SUBINVENTORY_CODE;
      p_mtls.LOCATOR_ID(i) := mtl_rec.LOCATOR_ID;
      p_mtls.TRANSACTION_QUANTITY(i) := mtl_rec.TRANSACTION_QUANTITY;
      p_mtls.PRIMARY_QUANTITY(i) := mtl_rec.PRIMARY_QUANTITY;
      p_mtls.TRANSACTION_UOM(i) := mtl_rec.TRANSACTION_UOM;
      p_mtls.TRANSACTION_COST(i) := mtl_rec.TRANSACTION_COST;
      p_mtls.TRANSACTION_TYPE_ID(i) := mtl_rec.TRANSACTION_TYPE_ID;
      p_mtls.TRANSACTION_ACTION_ID(i) := mtl_rec.TRANSACTION_ACTION_ID;
      p_mtls.TRANSACTION_SOURCE_TYPE_ID(i) := mtl_rec.TRANSACTION_SOURCE_TYPE_ID;
      p_mtls.TRANSACTION_SOURCE_ID(i) := mtl_rec.TRANSACTION_SOURCE_ID;
      p_mtls.TRANSACTION_SOURCE_NAME(i) := mtl_rec.TRANSACTION_SOURCE_NAME;
      p_mtls.TRANSACTION_DATE(i) := mtl_rec.TRANSACTION_DATE;
      p_mtls.ACCT_PERIOD_ID(i) := mtl_rec.ACCT_PERIOD_ID;
      p_mtls.DISTRIBUTION_ACCOUNT_ID(i) := mtl_rec.DISTRIBUTION_ACCOUNT_ID;
      p_mtls.TRANSACTION_REFERENCE(i) := mtl_rec.TRANSACTION_REFERENCE;
      p_mtls.REASON_ID(i) := mtl_rec.REASON_ID;
      p_mtls.LOT_NUMBER(i) := mtl_rec.LOT_NUMBER;
      p_mtls.LOT_EXPIRATION_DATE(i) := mtl_rec.LOT_EXPIRATION_DATE;
      p_mtls.SERIAL_NUMBER(i) := mtl_rec.SERIAL_NUMBER;
      p_mtls.RECEIVING_DOCUMENT(i) := mtl_rec.RECEIVING_DOCUMENT;
      p_mtls.RCV_TRANSACTION_ID(i) := mtl_rec.RCV_TRANSACTION_ID;
      p_mtls.MOVE_TRANSACTION_ID(i) := mtl_rec.MOVE_TRANSACTION_ID;
      p_mtls.COMPLETION_TRANSACTION_ID(i) := mtl_rec.COMPLETION_TRANSACTION_ID;
      p_mtls.WIP_ENTITY_TYPE(i) := mtl_rec.WIP_ENTITY_TYPE;
      p_mtls.SCHEDULE_ID(i) := mtl_rec.SCHEDULE_ID;
      p_mtls.REPETITIVE_LINE_ID(i) := mtl_rec.REPETITIVE_LINE_ID;
      p_mtls.EMPLOYEE_CODE(i) := mtl_rec.EMPLOYEE_CODE;
      p_mtls.SCHEDULE_UPDATE_CODE(i) := mtl_rec.SCHEDULE_UPDATE_CODE;
      p_mtls.SETUP_TEARDOWN_CODE(i) := mtl_rec.SETUP_TEARDOWN_CODE;
      p_mtls.ITEM_ORDERING(i) := mtl_rec.ITEM_ORDERING;
      p_mtls.NEGATIVE_REQ_FLAG(i) := mtl_rec.NEGATIVE_REQ_FLAG;
      p_mtls.OPERATION_SEQ_NUM(i) := mtl_rec.OPERATION_SEQ_NUM;
      p_mtls.PICKING_LINE_ID(i) := mtl_rec.PICKING_LINE_ID;
      p_mtls.TRX_SOURCE_LINE_ID(i) := mtl_rec.TRX_SOURCE_LINE_ID;
      p_mtls.TRX_SOURCE_DELIVERY_ID(i) := mtl_rec.TRX_SOURCE_DELIVERY_ID;
      p_mtls.PHYSICAL_ADJUSTMENT_ID(i) := mtl_rec.PHYSICAL_ADJUSTMENT_ID;
      p_mtls.CYCLE_COUNT_ID(i) := mtl_rec.CYCLE_COUNT_ID;
      p_mtls.RMA_LINE_ID(i) := mtl_rec.RMA_LINE_ID;
      p_mtls.CUSTOMER_SHIP_ID(i) := mtl_rec.CUSTOMER_SHIP_ID;
      p_mtls.CURRENCY_CODE(i) := mtl_rec.CURRENCY_CODE;
      p_mtls.CURRENCY_CONVERSION_RATE(i) := mtl_rec.CURRENCY_CONVERSION_RATE;
      p_mtls.CURRENCY_CONVERSION_TYPE(i) := mtl_rec.CURRENCY_CONVERSION_TYPE;
      p_mtls.CURRENCY_CONVERSION_DATE(i) := mtl_rec.CURRENCY_CONVERSION_DATE;
      p_mtls.USSGL_TRANSACTION_CODE(i) := mtl_rec.USSGL_TRANSACTION_CODE;
      p_mtls.VENDOR_LOT_NUMBER(i) := mtl_rec.VENDOR_LOT_NUMBER;
      p_mtls.ENCUMBRANCE_ACCOUNT(i) := mtl_rec.ENCUMBRANCE_ACCOUNT;
      p_mtls.ENCUMBRANCE_AMOUNT(i) := mtl_rec.ENCUMBRANCE_AMOUNT;
      p_mtls.SHIP_TO_LOCATION(i) := mtl_rec.SHIP_TO_LOCATION;
      p_mtls.SHIPMENT_NUMBER(i) := mtl_rec.SHIPMENT_NUMBER;
      p_mtls.TRANSFER_COST(i) := mtl_rec.TRANSFER_COST;
      p_mtls.TRANSPORTATION_COST(i) := mtl_rec.TRANSPORTATION_COST;
      p_mtls.TRANSPORTATION_ACCOUNT(i) := mtl_rec.TRANSPORTATION_ACCOUNT;
      p_mtls.FREIGHT_CODE(i) := mtl_rec.FREIGHT_CODE;
      p_mtls.CONTAINERS(i) := mtl_rec.CONTAINERS;
      p_mtls.WAYBILL_AIRBILL(i) := mtl_rec.WAYBILL_AIRBILL;
      p_mtls.EXPECTED_ARRIVAL_DATE(i) := mtl_rec.EXPECTED_ARRIVAL_DATE;
      p_mtls.TRANSFER_SUBINVENTORY(i) := mtl_rec.TRANSFER_SUBINVENTORY;
      p_mtls.TRANSFER_ORGANIZATION(i) := mtl_rec.TRANSFER_ORGANIZATION;
      p_mtls.TRANSFER_TO_LOCATION(i) := mtl_rec.TRANSFER_TO_LOCATION;
      p_mtls.NEW_AVERAGE_COST(i) := mtl_rec.NEW_AVERAGE_COST;
      p_mtls.VALUE_CHANGE(i) := mtl_rec.VALUE_CHANGE;
      p_mtls.PERCENTAGE_CHANGE(i) := mtl_rec.PERCENTAGE_CHANGE;
      p_mtls.MATERIAL_ALLOCATION_TEMP_ID(i) := mtl_rec.MATERIAL_ALLOCATION_TEMP_ID;
      p_mtls.DEMAND_SOURCE_HEADER_ID(i) := mtl_rec.DEMAND_SOURCE_HEADER_ID;
      p_mtls.DEMAND_SOURCE_LINE(i) := mtl_rec.DEMAND_SOURCE_LINE;
      p_mtls.DEMAND_SOURCE_DELIVERY(i) := mtl_rec.DEMAND_SOURCE_DELIVERY;
      p_mtls.ITEM_SEGMENTS(i) := mtl_rec.ITEM_SEGMENTS;
      p_mtls.ITEM_DESCRIPTION(i) := mtl_rec.ITEM_DESCRIPTION;
      p_mtls.ITEM_TRX_ENABLED_FLAG(i) := mtl_rec.ITEM_TRX_ENABLED_FLAG;
      p_mtls.ITEM_LOCATION_CONTROL_CODE(i) := mtl_rec.ITEM_LOCATION_CONTROL_CODE;
      p_mtls.ITEM_RESTRICT_SUBINV_CODE(i) := mtl_rec.ITEM_RESTRICT_SUBINV_CODE;
      p_mtls.ITEM_RESTRICT_LOCATORS_CODE(i) := mtl_rec.ITEM_RESTRICT_LOCATORS_CODE;
      p_mtls.ITEM_REVISION_QTY_CONTROL_CODE(i) := mtl_rec.ITEM_REVISION_QTY_CONTROL_CODE;
      p_mtls.ITEM_UOM_CLASS(i) := mtl_rec.ITEM_UOM_CLASS;
      p_mtls.ITEM_PRIMARY_UOM_CODE(i) := mtl_rec.ITEM_PRIMARY_UOM_CODE;
      p_mtls.ITEM_SHELF_LIFE_CODE(i) := mtl_rec.ITEM_SHELF_LIFE_CODE;
      p_mtls.ITEM_SHELF_LIFE_DAYS(i) := mtl_rec.ITEM_SHELF_LIFE_DAYS;
      p_mtls.ITEM_LOT_CONTROL_CODE(i) := mtl_rec.ITEM_LOT_CONTROL_CODE;
      p_mtls.ITEM_SERIAL_CONTROL_CODE(i) := mtl_rec.ITEM_SERIAL_CONTROL_CODE;
      p_mtls.ALLOWED_UNITS_LOOKUP_CODE(i) := mtl_rec.ALLOWED_UNITS_LOOKUP_CODE;
      p_mtls.DEPARTMENT_ID(i) := mtl_rec.DEPARTMENT_ID;
      p_mtls.WIP_SUPPLY_TYPE(i) := mtl_rec.WIP_SUPPLY_TYPE;
      p_mtls.SUPPLY_SUBINVENTORY(i) := mtl_rec.SUPPLY_SUBINVENTORY;
      p_mtls.SUPPLY_LOCATOR_ID(i) := mtl_rec.SUPPLY_LOCATOR_ID;
      p_mtls.VALID_SUBINVENTORY_FLAG(i) := mtl_rec.VALID_SUBINVENTORY_FLAG;
      p_mtls.VALID_LOCATOR_FLAG(i) := mtl_rec.VALID_LOCATOR_FLAG;
      p_mtls.LOCATOR_SEGMENTS(i) := mtl_rec.LOCATOR_SEGMENTS;
      p_mtls.CURRENT_LOCATOR_CONTROL_CODE(i) := mtl_rec.CURRENT_LOCATOR_CONTROL_CODE;
      p_mtls.NUMBER_OF_LOTS_ENTERED(i) := mtl_rec.NUMBER_OF_LOTS_ENTERED;
      p_mtls.WIP_COMMIT_FLAG(i) := mtl_rec.WIP_COMMIT_FLAG;
      p_mtls.NEXT_LOT_NUMBER(i) := mtl_rec.NEXT_LOT_NUMBER;
      p_mtls.LOT_ALPHA_PREFIX(i) := mtl_rec.LOT_ALPHA_PREFIX;
      p_mtls.NEXT_SERIAL_NUMBER(i) := mtl_rec.NEXT_SERIAL_NUMBER;
      p_mtls.SERIAL_ALPHA_PREFIX(i) := mtl_rec.SERIAL_ALPHA_PREFIX;
      p_mtls.POSTING_FLAG(i) := mtl_rec.POSTING_FLAG;
      p_mtls.REQUIRED_FLAG(i) := mtl_rec.REQUIRED_FLAG;
      p_mtls.PROCESS_FLAG(i) := mtl_rec.PROCESS_FLAG;
      p_mtls.ERROR_CODE(i) := mtl_rec.ERROR_CODE;
      p_mtls.ATTRIBUTE_CATEGORY(i) := mtl_rec.ATTRIBUTE_CATEGORY;
      p_mtls.ATTRIBUTE1(i) := mtl_rec.ATTRIBUTE1;
      p_mtls.ATTRIBUTE2(i) := mtl_rec.ATTRIBUTE2;
      p_mtls.ATTRIBUTE3(i) := mtl_rec.ATTRIBUTE3;
      p_mtls.ATTRIBUTE4(i) := mtl_rec.ATTRIBUTE4;
      p_mtls.ATTRIBUTE5(i) := mtl_rec.ATTRIBUTE5;
      p_mtls.ATTRIBUTE6(i) := mtl_rec.ATTRIBUTE6;
      p_mtls.ATTRIBUTE7(i) := mtl_rec.ATTRIBUTE7;
      p_mtls.ATTRIBUTE8(i) := mtl_rec.ATTRIBUTE8;
      p_mtls.ATTRIBUTE9(i) := mtl_rec.ATTRIBUTE9;
      p_mtls.ATTRIBUTE10(i) := mtl_rec.ATTRIBUTE10;
      p_mtls.ATTRIBUTE11(i) := mtl_rec.ATTRIBUTE11;
      p_mtls.ATTRIBUTE12(i) := mtl_rec.ATTRIBUTE12;
      p_mtls.ATTRIBUTE13(i) := mtl_rec.ATTRIBUTE13;
      p_mtls.ATTRIBUTE14(i) := mtl_rec.ATTRIBUTE14;
      p_mtls.ATTRIBUTE15(i) := mtl_rec.ATTRIBUTE15;
      p_mtls.PRIMARY_SWITCH(i) := mtl_rec.PRIMARY_SWITCH;
      p_mtls.DEPARTMENT_CODE(i) := mtl_rec.DEPARTMENT_CODE;
      p_mtls.ERROR_EXPLANATION(i) := mtl_rec.ERROR_EXPLANATION;
      p_mtls.DEMAND_ID(i) := mtl_rec.DEMAND_ID;
      p_mtls.ITEM_INVENTORY_ASSET_FLAG(i) := mtl_rec.ITEM_INVENTORY_ASSET_FLAG;
      p_mtls.SHIPPABLE_FLAG(i) := mtl_rec.SHIPPABLE_FLAG;
      p_mtls.REQUISITION_LINE_ID(i) := mtl_rec.REQUISITION_LINE_ID;
      p_mtls.REQUISITION_DISTRIBUTION_ID(i) := mtl_rec.REQUISITION_DISTRIBUTION_ID;
      p_mtls.MOVEMENT_ID(i) := mtl_rec.MOVEMENT_ID;
      p_mtls.RESERVATION_QUANTITY(i) := mtl_rec.RESERVATION_QUANTITY;
      p_mtls.SHIPPED_QUANTITY(i) := mtl_rec.SHIPPED_QUANTITY;
      p_mtls.TRANSACTION_LINE_NUMBER(i) := mtl_rec.TRANSACTION_LINE_NUMBER;
      p_mtls.EXPENDITURE_TYPE(i) := mtl_rec.EXPENDITURE_TYPE;
      p_mtls.FINAL_COMPLETION_FLAG(i) := mtl_rec.FINAL_COMPLETION_FLAG;
      p_mtls.MATERIAL_ACCOUNT(i) := mtl_rec.MATERIAL_ACCOUNT;
      p_mtls.MATERIAL_OVERHEAD_ACCOUNT(i) := mtl_rec.MATERIAL_OVERHEAD_ACCOUNT;
      p_mtls.OUTSIDE_PROCESSING_ACCOUNT(i) := mtl_rec.OUTSIDE_PROCESSING_ACCOUNT;
      p_mtls.OVERHEAD_ACCOUNT(i) := mtl_rec.OVERHEAD_ACCOUNT;
      p_mtls.PA_EXPENDITURE_ORG_ID(i) := mtl_rec.PA_EXPENDITURE_ORG_ID;
      p_mtls.PROJECT_ID(i) := mtl_rec.PROJECT_ID;
      p_mtls.RESOURCE_ACCOUNT(i) := mtl_rec.RESOURCE_ACCOUNT;
      p_mtls.SOURCE_PROJECT_ID(i) := mtl_rec.SOURCE_PROJECT_ID;
      p_mtls.SOURCE_TASK_ID(i) := mtl_rec.SOURCE_TASK_ID;
      p_mtls.TASK_ID(i) := mtl_rec.TASK_ID;
      p_mtls.TO_PROJECT_ID(i) := mtl_rec.TO_PROJECT_ID;
      p_mtls.TO_TASK_ID(i) := mtl_rec.TO_TASK_ID;
      p_mtls.TRANSACTION_SEQUENCE_ID(i) := mtl_rec.TRANSACTION_SEQUENCE_ID;
      p_mtls.TRANSFER_PERCENTAGE(i) := mtl_rec.TRANSFER_PERCENTAGE;
      p_mtls.qa_collection_id(i) := mtl_rec.qa_collection_id;
      p_mtls.overcompletion_transaction_id(i) := mtl_rec.overcompletion_transaction_id;
      p_mtls.overcompletion_transaction_qty(i) := mtl_rec.overcompletion_transaction_qty;
      p_mtls.overcompletion_primary_qty(i) := mtl_rec.overcompletion_primary_qty;
      p_mtls.kanban_card_id(i) := mtl_rec.kanban_card_id;
    end loop;

    close get_materials;

    if (p_mtls.numrecs > 0) then
      DELETE FROM MTL_MATERIAL_TRANSACTIONS_TEMP
      WHERE TRANSACTION_HEADER_ID = p_hdr_id
      AND   TRANSACTION_ACTION_ID = NVL(p_act_id, TRANSACTION_ACTION_ID);
    end if;
  end fetch_and_delete;

  procedure fetch_and_delete(
    p_hdr_id in     number,
    p_act_id in     number,
    p_lots   in out nocopy wip_lot_temp_cleanup.mtl_transaction_lots_temp_rec) is

    i number := 0;

    cursor get_lots(
      c_hdr_id number,
      c_act_id number) is
    select
      transaction_temp_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      transaction_quantity,
      primary_quantity,
      lot_number,
      lot_expiration_date,
      error_code,
      serial_transaction_temp_id,
      group_header_id
    from mtl_transaction_lots_temp
    where transaction_temp_id in
      (select transaction_temp_id
       from   mtl_material_transactions_temp
       where  transaction_header_id = c_hdr_id
       and    transaction_action_id = nvl(c_act_id, transaction_action_id));

    lot_rec get_lots%rowtype;
  begin
    -- initialize
    if (p_lots.numrecs is NULL) then
      -- p_lots is empty
      p_lots.numrecs := i;
    else
      -- p_lots already has records
      i := p_lots.numrecs;
    end if;

    open get_lots(
      c_hdr_id => p_hdr_id,
      c_act_id => p_act_id);

    loop
      fetch get_lots into lot_rec;

      exit when (get_lots%NOTFOUND);

      i := i + 1;
      p_lots.numrecs := i;
      p_lots.transaction_temp_id(i) := lot_rec.transaction_temp_id;
      p_lots.last_update_date(i) := lot_rec.last_update_date;
      p_lots.last_updated_by(i) := lot_rec.last_updated_by;
      p_lots.creation_date(i) := lot_rec.creation_date;
      p_lots.created_by(i) := lot_rec.created_by;
      p_lots.last_update_login(i) := lot_rec.last_update_login;
      p_lots.request_id(i) := lot_rec.request_id;
      p_lots.program_application_id(i) := lot_rec.program_application_id;
      p_lots.program_id(i) := lot_rec.program_id;
      p_lots.program_update_date(i) := lot_rec.program_update_date;
      p_lots.transaction_quantity(i) := lot_rec.transaction_quantity;
      p_lots.primary_quantity(i) := lot_rec.primary_quantity;
      p_lots.lot_number(i) := lot_rec.lot_number;
      p_lots.lot_expiration_date(i) := lot_rec.lot_expiration_date;
      p_lots.error_code(i) := lot_rec.error_code;
      p_lots.serial_transaction_temp_id(i) := lot_rec.serial_transaction_temp_id;
      p_lots.group_header_id(i) := lot_rec.group_header_id;
    end loop;

    close get_lots;

    if (p_lots.numrecs > 0) then
      delete from mtl_transaction_lots_temp
      where transaction_temp_id in
        (select transaction_temp_id
         from   mtl_material_transactions_temp
         where  transaction_header_id = p_hdr_id
         and    transaction_action_id = nvl(p_act_id, transaction_action_id));
    end if;
  end fetch_and_delete;

  procedure fetch_and_delete(
    p_hdr_id  in     number,
    p_act_id  in     number,
    p_serials in out nocopy wip_serial_temp_cleanup.mtl_serial_numbers_temp_rec) is

    i number := 0;

    cursor get_serials(
      c_hdr_id number,
      c_act_id number) is
    select
      transaction_temp_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      vendor_serial_number,
      vendor_lot_number,
      fm_serial_number,
      to_serial_number,
      serial_prefix,
      error_code error_code,
      group_header_id
    from mtl_serial_numbers_temp
    where
      transaction_temp_id in
        (select transaction_temp_id
         from mtl_material_transactions_temp
         where transaction_header_id = c_hdr_id
         and transaction_action_id = nvl(c_act_id, transaction_action_id))
      or
      transaction_temp_id in
        (select serial_transaction_temp_id
         from mtl_transaction_lots_temp
         where transaction_temp_id in
           (select transaction_temp_id
            from mtl_material_transactions_temp
            where transaction_header_id = c_hdr_id
            and transaction_action_id = nvl(c_act_id, transaction_action_id)));

    serial_rec get_serials%rowtype;
  begin
    -- initialize
    if (p_serials.numrecs is NULL) then
      -- p_serials is empty
      p_serials.numrecs := i;
    else
      -- p_serials already has records
      i := p_serials.numrecs;
    end if;

    open get_serials(
      c_hdr_id => p_hdr_id,
      c_act_id => p_act_id);

    loop
      fetch get_serials into serial_rec;

      exit when (get_serials%NOTFOUND);

      i := i + 1;
      p_serials.numrecs := i;
      p_serials.transaction_temp_id(i) := serial_rec.transaction_temp_id;
      p_serials.last_update_date(i) := serial_rec.last_update_date;
      p_serials.last_updated_by(i) := serial_rec.last_updated_by;
      p_serials.creation_date(i) := serial_rec.creation_date;
      p_serials.created_by(i) := serial_rec.created_by;
      p_serials.last_update_login(i) := serial_rec.last_update_login;
      p_serials.request_id(i) := serial_rec.request_id;
      p_serials.program_application_id(i) := serial_rec.program_application_id;
      p_serials.program_id(i) := serial_rec.program_id;
      p_serials.program_update_date(i) := serial_rec.program_update_date;
      p_serials.vendor_serial_number(i) := serial_rec.vendor_serial_number;
      p_serials.vendor_lot_number(i) := serial_rec.vendor_lot_number;
      p_serials.fm_serial_number(i) := serial_rec.fm_serial_number;
      p_serials.to_serial_number(i) := serial_rec.to_serial_number;
      p_serials.serial_prefix(i) := serial_rec.serial_prefix;
      p_serials.error_code(i) := serial_rec.error_code;
      p_serials.group_header_id(i) := serial_rec.group_header_id;
    end loop;

    close get_serials;

    if (p_serials.numrecs > 0) then
      delete from mtl_serial_numbers_temp
      where
      transaction_temp_id in
        (select transaction_temp_id
         from mtl_material_transactions_temp
         where transaction_header_id = p_hdr_id
         and transaction_action_id = nvl(p_act_id, transaction_action_id))
      or
      transaction_temp_id in
        (select serial_transaction_temp_id
         from mtl_transaction_lots_temp
         where transaction_temp_id in
           (select transaction_temp_id
            from mtl_material_transactions_temp
            where transaction_header_id = p_hdr_id
            and transaction_action_id = nvl(p_act_id, transaction_action_id)));
    end if;
  end fetch_and_delete;

  procedure fetch_and_delete(
    p_hdr_id  in     number,
    p_act_id  in     number,
    p_dyn_sns in out nocopy wip_serial_number_cleanup.mtl_serial_numbers_rec) is

    i number := 0;

    cursor get_serials(
      c_hdr_id number,
      c_act_id number) is
    select
    INVENTORY_ITEM_ID,
    SERIAL_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    INITIALIZATION_DATE,
    COMPLETION_DATE,
    SHIP_DATE,
    CURRENT_STATUS,
    REVISION,
    LOT_NUMBER,
    FIXED_ASSET_TAG,
    RESERVED_ORDER_ID,
    PARENT_ITEM_ID,
    PARENT_SERIAL_NUMBER,
    ORIGINAL_WIP_ENTITY_ID,
    ORIGINAL_UNIT_VENDOR_ID,
    VENDOR_SERIAL_NUMBER,
    VENDOR_LOT_NUMBER,
    LAST_TXN_SOURCE_TYPE_ID,
    LAST_TRANSACTION_ID,
    LAST_RECEIPT_ISSUE_TYPE,
    LAST_TXN_SOURCE_NAME,
    LAST_TXN_SOURCE_ID,
    DESCRIPTIVE_TEXT,
    CURRENT_SUBINVENTORY_CODE,
    CURRENT_LOCATOR_ID,
    CURRENT_ORGANIZATION_ID,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    GROUP_MARK_ID,
    LINE_MARK_ID,
    LOT_LINE_MARK_ID
    from mtl_serial_numbers
    where current_status = 6
    and group_mark_id = c_hdr_id
    and (line_mark_id in
      (select transaction_temp_id
       from mtl_material_transactions_temp
       where transaction_header_id = c_hdr_id
       and transaction_action_id = nvl(c_act_id, transaction_action_id))
         or
         lot_line_mark_id in
      (select serial_transaction_temp_id
       from mtl_transaction_lots_temp
       where transaction_temp_id in
         (select transaction_temp_id
          from mtl_material_transactions_temp
          where transaction_header_id = c_hdr_id
          and transaction_action_id = nvl(c_act_id, transaction_action_id))));

    serial_rec get_serials%rowtype;
  begin
    -- initialize
    if (p_dyn_sns.numrecs is NULL) then
      -- p_dyn_sns is empty
      p_dyn_sns.numrecs := i;
    else
      -- p_dyn_sns already has records
      i := p_dyn_sns.numrecs;
    end if;

    open get_serials(
      c_hdr_id => p_hdr_id,
      c_act_id => p_hdr_id);

    loop
      fetch get_serials into serial_rec;

      exit when (get_serials%NOTFOUND);

      i := i + 1;
      p_dyn_sns.numrecs := i;
      p_dyn_sns.INVENTORY_ITEM_ID(i) := serial_rec.INVENTORY_ITEM_ID;
      p_dyn_sns.SERIAL_NUMBER(i) := serial_rec.SERIAL_NUMBER;
      p_dyn_sns.LAST_UPDATE_DATE(i) := serial_rec.LAST_UPDATE_DATE;
      p_dyn_sns.LAST_UPDATED_BY(i) := serial_rec.LAST_UPDATED_BY;
      p_dyn_sns.CREATION_DATE(i) := serial_rec.CREATION_DATE;
      p_dyn_sns.CREATED_BY(i) := serial_rec.CREATED_BY;
      p_dyn_sns.LAST_UPDATE_LOGIN(i) := serial_rec.LAST_UPDATE_LOGIN;
      p_dyn_sns.REQUEST_ID(i) := serial_rec.REQUEST_ID;
      p_dyn_sns.PROGRAM_APPLICATION_ID(i) := serial_rec.PROGRAM_APPLICATION_ID;
      p_dyn_sns.PROGRAM_ID(i) := serial_rec.PROGRAM_ID;
      p_dyn_sns.PROGRAM_UPDATE_DATE(i) := serial_rec.PROGRAM_UPDATE_DATE;
      p_dyn_sns.INITIALIZATION_DATE(i) := serial_rec.INITIALIZATION_DATE;
      p_dyn_sns.COMPLETION_DATE(i) := serial_rec.COMPLETION_DATE;
      p_dyn_sns.SHIP_DATE(i) := serial_rec.SHIP_DATE;
      p_dyn_sns.CURRENT_STATUS(i) := serial_rec.CURRENT_STATUS;
      p_dyn_sns.REVISION(i) := serial_rec.REVISION;
      p_dyn_sns.LOT_NUMBER(i) := serial_rec.LOT_NUMBER;
      p_dyn_sns.FIXED_ASSET_TAG(i) := serial_rec.FIXED_ASSET_TAG;
      p_dyn_sns.RESERVED_ORDER_ID(i) := serial_rec.RESERVED_ORDER_ID;
      p_dyn_sns.PARENT_ITEM_ID(i) := serial_rec.PARENT_ITEM_ID;
      p_dyn_sns.PARENT_SERIAL_NUMBER(i) := serial_rec.PARENT_SERIAL_NUMBER;
      p_dyn_sns.ORIGINAL_WIP_ENTITY_ID(i) := serial_rec.ORIGINAL_WIP_ENTITY_ID;
      p_dyn_sns.ORIGINAL_UNIT_VENDOR_ID(i) := serial_rec.ORIGINAL_UNIT_VENDOR_ID;
      p_dyn_sns.VENDOR_SERIAL_NUMBER(i) := serial_rec.VENDOR_SERIAL_NUMBER;
      p_dyn_sns.VENDOR_LOT_NUMBER(i) := serial_rec.VENDOR_LOT_NUMBER;
      p_dyn_sns.LAST_TXN_SOURCE_TYPE_ID(i) := serial_rec.LAST_TXN_SOURCE_TYPE_ID;
      p_dyn_sns.LAST_TRANSACTION_ID(i) := serial_rec.LAST_TRANSACTION_ID;
      p_dyn_sns.LAST_RECEIPT_ISSUE_TYPE(i) := serial_rec.LAST_RECEIPT_ISSUE_TYPE;
      p_dyn_sns.LAST_TXN_SOURCE_NAME(i) := serial_rec.LAST_TXN_SOURCE_NAME;
      p_dyn_sns.LAST_TXN_SOURCE_ID(i) := serial_rec.LAST_TXN_SOURCE_ID;
      p_dyn_sns.DESCRIPTIVE_TEXT(i) := serial_rec.DESCRIPTIVE_TEXT;
      p_dyn_sns.CURRENT_SUBINVENTORY_CODE(i) := serial_rec.CURRENT_SUBINVENTORY_CODE;
      p_dyn_sns.CURRENT_LOCATOR_ID(i) := serial_rec.CURRENT_LOCATOR_ID;
      p_dyn_sns.CURRENT_ORGANIZATION_ID(i) := serial_rec.CURRENT_ORGANIZATION_ID;
      p_dyn_sns.ATTRIBUTE_CATEGORY(i) := serial_rec.ATTRIBUTE_CATEGORY;
      p_dyn_sns.ATTRIBUTE1(i) := serial_rec.ATTRIBUTE1;
      p_dyn_sns.ATTRIBUTE2(i) := serial_rec.ATTRIBUTE2;
      p_dyn_sns.ATTRIBUTE3(i) := serial_rec.ATTRIBUTE3;
      p_dyn_sns.ATTRIBUTE4(i) := serial_rec.ATTRIBUTE4;
      p_dyn_sns.ATTRIBUTE5(i) := serial_rec.ATTRIBUTE5;
      p_dyn_sns.ATTRIBUTE6(i) := serial_rec.ATTRIBUTE6;
      p_dyn_sns.ATTRIBUTE7(i) := serial_rec.ATTRIBUTE7;
      p_dyn_sns.ATTRIBUTE8(i) := serial_rec.ATTRIBUTE8;
      p_dyn_sns.ATTRIBUTE9(i) := serial_rec.ATTRIBUTE9;
      p_dyn_sns.ATTRIBUTE10(i) := serial_rec.ATTRIBUTE10;
      p_dyn_sns.ATTRIBUTE11(i) := serial_rec.ATTRIBUTE11;
      p_dyn_sns.ATTRIBUTE12(i) := serial_rec.ATTRIBUTE12;
      p_dyn_sns.ATTRIBUTE13(i) := serial_rec.ATTRIBUTE13;
      p_dyn_sns.ATTRIBUTE14(i) := serial_rec.ATTRIBUTE14;
      p_dyn_sns.ATTRIBUTE15(i) := serial_rec.ATTRIBUTE15;
      p_dyn_sns.GROUP_MARK_ID(i) := serial_rec.GROUP_MARK_ID;
      p_dyn_sns.LINE_MARK_ID(i) := serial_rec.LINE_MARK_ID;
      p_dyn_sns.LOT_LINE_MARK_ID(i) := serial_rec.LOT_LINE_MARK_ID;
    end loop;

    close get_serials;

    if (p_dyn_sns.numrecs > 0) then
      delete mtl_serial_numbers
      where current_status = 6
      and group_mark_id = p_hdr_id
      and (line_mark_id in
        (select transaction_temp_id
         from mtl_material_transactions_temp
         where transaction_header_id = p_hdr_id
         and transaction_action_id = nvl(p_act_id, transaction_action_id))
           or
           lot_line_mark_id in
        (select serial_transaction_temp_id
         from mtl_transaction_lots_temp
         where transaction_temp_id in
           (select transaction_temp_id
            from mtl_material_transactions_temp
            where transaction_header_id = p_hdr_id
            and transaction_action_id = nvl(p_act_id, transaction_action_id))));
    end if;
  end fetch_and_delete;

  procedure fetch_and_unmark(
    p_hdr_id  in     number,
    p_act_id  in     number,
    p_serials in out nocopy wip_serial_number_cleanup.mtl_serial_numbers_mark_rec) is
    i number := 0;

    cursor get_serials(
      c_hdr_id number,
      c_act_id number) is
    select
    SERIAL_NUMBER,
    INVENTORY_ITEM_ID,
    GROUP_MARK_ID,
    LINE_MARK_ID,
    LOT_LINE_MARK_ID
    from mtl_serial_numbers
    where group_mark_id = c_hdr_id
    and (line_mark_id in
      (select transaction_temp_id
       from mtl_material_transactions_temp
       where transaction_header_id = c_hdr_id
       and transaction_action_id = nvl(c_act_id, transaction_action_id))
         or
         lot_line_mark_id in
      (select serial_transaction_temp_id
       from mtl_transaction_lots_temp
       where transaction_temp_id in
         (select transaction_temp_id
          from mtl_material_transactions_temp
          where transaction_header_id = c_hdr_id
          and transaction_action_id = nvl(c_act_id, transaction_action_id))));

    serial_rec get_serials%rowtype;
  begin
    -- initialize
    if (p_serials.numrecs is NULL) then
      -- p_serials is empty
      p_serials.numrecs := i;
    else
      -- p_serials already has records
      i := p_serials.numrecs;
    end if;

    open get_serials(
      c_hdr_id => p_hdr_id,
      c_act_id => p_act_id);

    loop
      fetch get_serials into serial_rec;

      exit when (get_serials%NOTFOUND);

      i := i + 1;
      p_serials.numrecs := i;
      p_serials.SERIAL_NUMBER(i) := serial_rec.SERIAL_NUMBER;
      p_serials.INVENTORY_ITEM_ID(i) := serial_rec.INVENTORY_ITEM_ID;
      p_serials.GROUP_MARK_ID(i) := serial_rec.GROUP_MARK_ID;
      p_serials.LINE_MARK_ID(i) := serial_rec.LINE_MARK_ID;
      p_serials.LOT_LINE_MARK_ID(i) := serial_rec.LOT_LINE_MARK_ID;
    end loop;

    close get_serials;

    if (p_serials.numrecs > 0) then
      update mtl_serial_numbers
      set group_mark_id = null,
          line_mark_id = null,
          lot_line_mark_id = null
      where group_mark_id = p_hdr_id
      and (line_mark_id in
        (select transaction_temp_id
         from mtl_material_transactions_temp
         where transaction_header_id = p_hdr_id
         and transaction_action_id = nvl(p_act_id, transaction_action_id))
           or
           lot_line_mark_id in
        (select serial_transaction_temp_id
         from mtl_transaction_lots_temp
         where transaction_temp_id in
           (select transaction_temp_id
            from mtl_material_transactions_temp
            where transaction_header_id = p_hdr_id
            and transaction_action_id = nvl(p_act_id, transaction_action_id))));
    end if;
  end fetch_and_unmark;

  procedure fetch_and_delete(
    p_hdr_id      in     number,
    p_act_id      in     number default NULL,
    p_materials   in out nocopy mtl_transactions_temp_rec,
    p_lots        in out nocopy wip_lot_temp_cleanup.mtl_transaction_lots_temp_rec,
    p_serials     in out nocopy wip_serial_temp_cleanup.mtl_serial_numbers_temp_rec,
    p_dyn_serials in out nocopy wip_serial_number_cleanup.mtl_serial_numbers_rec,
    p_ser_marks   in out nocopy wip_serial_number_cleanup.mtl_serial_numbers_mark_rec) is
  begin
    -- get marked serial numbers
    fetch_and_unmark(
      p_hdr_id  => p_hdr_id,
      p_act_id  => p_act_id,
      p_serials => p_ser_marks);

    -- get dynamic serial numbers
    fetch_and_delete(
      p_hdr_id  => p_hdr_id,
      p_act_id  => p_act_id,
      p_dyn_sns => p_dyn_serials);

    -- get serial records
    fetch_and_delete(
      p_hdr_id  => p_hdr_id,
      p_act_id  => p_act_id,
      p_serials => p_serials);

    -- get lot records
    fetch_and_delete(
      p_hdr_id => p_hdr_id,
      p_act_id => p_act_id,
      p_lots   => p_lots);

    -- get material records
    fetch_and_delete(
      p_hdr_id => p_hdr_id,
      p_act_id => p_act_id,
      p_mtls   => p_materials);
  end fetch_and_delete;

  procedure insert_rows(
    p_mtls in mtl_transactions_temp_rec) is
    i number := 1;
  begin
    while (i <= nvl(p_mtls.numrecs, 0)) loop
      insert into mtl_material_transactions_temp (
        TRANSACTION_HEADER_ID,
        TRANSACTION_TEMP_ID,
        SOURCE_CODE,
        SOURCE_LINE_ID,
        TRANSACTION_MODE,
        LOCK_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        INVENTORY_ITEM_ID,
        REVISION,
        ORGANIZATION_ID,
        SUBINVENTORY_CODE,
        LOCATOR_ID,
        TRANSACTION_QUANTITY,
        PRIMARY_QUANTITY,
        TRANSACTION_UOM,
        TRANSACTION_COST,
        TRANSACTION_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_SOURCE_ID,
        TRANSACTION_SOURCE_NAME,
        TRANSACTION_DATE,
        ACCT_PERIOD_ID,
        DISTRIBUTION_ACCOUNT_ID,
        TRANSACTION_REFERENCE,
        REASON_ID,
        LOT_NUMBER,
        LOT_EXPIRATION_DATE,
        SERIAL_NUMBER,
        RECEIVING_DOCUMENT,
        RCV_TRANSACTION_ID,
        MOVE_TRANSACTION_ID,
        COMPLETION_TRANSACTION_ID,
        WIP_ENTITY_TYPE,
        SCHEDULE_ID,
        REPETITIVE_LINE_ID,
        EMPLOYEE_CODE,
        SCHEDULE_UPDATE_CODE,
        SETUP_TEARDOWN_CODE,
        ITEM_ORDERING,
        NEGATIVE_REQ_FLAG,
        OPERATION_SEQ_NUM,
        PICKING_LINE_ID,
        TRX_SOURCE_LINE_ID,
        TRX_SOURCE_DELIVERY_ID,
        PHYSICAL_ADJUSTMENT_ID,
        CYCLE_COUNT_ID,
        RMA_LINE_ID,
        CUSTOMER_SHIP_ID,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_DATE,
        USSGL_TRANSACTION_CODE,
        VENDOR_LOT_NUMBER,
        ENCUMBRANCE_ACCOUNT,
        ENCUMBRANCE_AMOUNT,
        SHIP_TO_LOCATION,
        SHIPMENT_NUMBER,
        TRANSFER_COST,
        TRANSPORTATION_COST,
        TRANSPORTATION_ACCOUNT,
        FREIGHT_CODE,
        CONTAINERS,
        WAYBILL_AIRBILL,
        EXPECTED_ARRIVAL_DATE,
        TRANSFER_SUBINVENTORY,
        TRANSFER_ORGANIZATION,
        TRANSFER_TO_LOCATION,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        MATERIAL_ALLOCATION_TEMP_ID,
        DEMAND_SOURCE_HEADER_ID,
        DEMAND_SOURCE_LINE,
        DEMAND_SOURCE_DELIVERY,
        ITEM_SEGMENTS,
        ITEM_DESCRIPTION,
        ITEM_TRX_ENABLED_FLAG,
        ITEM_LOCATION_CONTROL_CODE,
        ITEM_RESTRICT_SUBINV_CODE,
        ITEM_RESTRICT_LOCATORS_CODE,
        ITEM_REVISION_QTY_CONTROL_CODE,
        ITEM_PRIMARY_UOM_CODE,
        ITEM_UOM_CLASS,
        ITEM_SHELF_LIFE_CODE,
        ITEM_SHELF_LIFE_DAYS,
        ITEM_LOT_CONTROL_CODE,
        ITEM_SERIAL_CONTROL_CODE,
        ALLOWED_UNITS_LOOKUP_CODE,
        DEPARTMENT_ID,
        WIP_SUPPLY_TYPE,
        SUPPLY_SUBINVENTORY,
        SUPPLY_LOCATOR_ID,
        VALID_SUBINVENTORY_FLAG,
        VALID_LOCATOR_FLAG,
        LOCATOR_SEGMENTS,
        CURRENT_LOCATOR_CONTROL_CODE,
        NUMBER_OF_LOTS_ENTERED,
        WIP_COMMIT_FLAG,
        NEXT_LOT_NUMBER,
        LOT_ALPHA_PREFIX,
        NEXT_SERIAL_NUMBER,
        SERIAL_ALPHA_PREFIX,
        POSTING_FLAG,
        REQUIRED_FLAG,
        PROCESS_FLAG,
        ERROR_CODE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        PRIMARY_SWITCH,
        DEPARTMENT_CODE,
        ERROR_EXPLANATION,
        DEMAND_ID,
        ITEM_INVENTORY_ASSET_FLAG,
        SHIPPABLE_FLAG,
        REQUISITION_LINE_ID,
        REQUISITION_DISTRIBUTION_ID,
        MOVEMENT_ID,
        RESERVATION_QUANTITY,
        SHIPPED_QUANTITY,
        TRANSACTION_LINE_NUMBER,
        EXPENDITURE_TYPE,
        FINAL_COMPLETION_FLAG,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        PA_EXPENDITURE_ORG_ID,
        PROJECT_ID,
        RESOURCE_ACCOUNT,
        SOURCE_PROJECT_ID,
        SOURCE_TASK_ID,
        TASK_ID,
        TO_PROJECT_ID,
        TO_TASK_ID,
        TRANSACTION_SEQUENCE_ID,
        transfer_percentage,
	qa_collection_id,
	overcompletion_transaction_id,
	overcompletion_transaction_qty,
	overcompletion_primary_qty,
	kanban_card_id
      ) values (
        p_mtls.TRANSACTION_HEADER_ID(i),
        p_mtls.TRANSACTION_TEMP_ID(i),
        p_mtls.SOURCE_CODE(i),
        p_mtls.SOURCE_LINE_ID(i),
        p_mtls.TRANSACTION_MODE(i),
        p_mtls.LOCK_FLAG(i),
        p_mtls.LAST_UPDATE_DATE(i),
        p_mtls.LAST_UPDATED_BY(i),
        p_mtls.CREATION_DATE(i),
        p_mtls.CREATED_BY(i),
        p_mtls.LAST_UPDATE_LOGIN(i),
        p_mtls.REQUEST_ID(i),
        p_mtls.PROGRAM_APPLICATION_ID(i),
        p_mtls.PROGRAM_ID(i),
        p_mtls.PROGRAM_UPDATE_DATE(i),
        p_mtls.INVENTORY_ITEM_ID(i),
        p_mtls.REVISION(i),
        p_mtls.ORGANIZATION_ID(i),
        p_mtls.SUBINVENTORY_CODE(i),
        p_mtls.LOCATOR_ID(i),
        p_mtls.TRANSACTION_QUANTITY(i),
        p_mtls.PRIMARY_QUANTITY(i),
        p_mtls.TRANSACTION_UOM(i),
        p_mtls.TRANSACTION_COST(i),
        p_mtls.TRANSACTION_TYPE_ID(i),
        p_mtls.TRANSACTION_ACTION_ID(i),
        p_mtls.TRANSACTION_SOURCE_TYPE_ID(i),
        p_mtls.TRANSACTION_SOURCE_ID(i),
        p_mtls.TRANSACTION_SOURCE_NAME(i),
        p_mtls.TRANSACTION_DATE(i),
        p_mtls.ACCT_PERIOD_ID(i),
        p_mtls.DISTRIBUTION_ACCOUNT_ID(i),
        p_mtls.TRANSACTION_REFERENCE(i),
        p_mtls.REASON_ID(i),
        p_mtls.LOT_NUMBER(i),
        p_mtls.LOT_EXPIRATION_DATE(i),
        p_mtls.SERIAL_NUMBER(i),
        p_mtls.RECEIVING_DOCUMENT(i),
        p_mtls.RCV_TRANSACTION_ID(i),
        p_mtls.MOVE_TRANSACTION_ID(i),
        p_mtls.COMPLETION_TRANSACTION_ID(i),
        p_mtls.WIP_ENTITY_TYPE(i),
        p_mtls.SCHEDULE_ID(i),
        p_mtls.REPETITIVE_LINE_ID(i),
        p_mtls.EMPLOYEE_CODE(i),
        p_mtls.SCHEDULE_UPDATE_CODE(i),
        p_mtls.SETUP_TEARDOWN_CODE(i),
        p_mtls.ITEM_ORDERING(i),
        p_mtls.NEGATIVE_REQ_FLAG(i),
        p_mtls.OPERATION_SEQ_NUM(i),
        p_mtls.PICKING_LINE_ID(i),
        p_mtls.TRX_SOURCE_LINE_ID(i),
        p_mtls.TRX_SOURCE_DELIVERY_ID(i),
        p_mtls.PHYSICAL_ADJUSTMENT_ID(i),
        p_mtls.CYCLE_COUNT_ID(i),
        p_mtls.RMA_LINE_ID(i),
        p_mtls.CUSTOMER_SHIP_ID(i),
        p_mtls.CURRENCY_CODE(i),
        p_mtls.CURRENCY_CONVERSION_RATE(i),
        p_mtls.CURRENCY_CONVERSION_TYPE(i),
        p_mtls.CURRENCY_CONVERSION_DATE(i),
        p_mtls.USSGL_TRANSACTION_CODE(i),
        p_mtls.VENDOR_LOT_NUMBER(i),
        p_mtls.ENCUMBRANCE_ACCOUNT(i),
        p_mtls.ENCUMBRANCE_AMOUNT(i),
        p_mtls.SHIP_TO_LOCATION(i),
        p_mtls.SHIPMENT_NUMBER(i),
        p_mtls.TRANSFER_COST(i),
        p_mtls.TRANSPORTATION_COST(i),
        p_mtls.TRANSPORTATION_ACCOUNT(i),
        p_mtls.FREIGHT_CODE(i),
        p_mtls.CONTAINERS(i),
        p_mtls.WAYBILL_AIRBILL(i),
        p_mtls.EXPECTED_ARRIVAL_DATE(i),
        p_mtls.TRANSFER_SUBINVENTORY(i),
        p_mtls.TRANSFER_ORGANIZATION(i),
        p_mtls.TRANSFER_TO_LOCATION(i),
        p_mtls.NEW_AVERAGE_COST(i),
        p_mtls.VALUE_CHANGE(i),
        p_mtls.PERCENTAGE_CHANGE(i),
        p_mtls.MATERIAL_ALLOCATION_TEMP_ID(i),
        p_mtls.DEMAND_SOURCE_HEADER_ID(i),
        p_mtls.DEMAND_SOURCE_LINE(i),
        p_mtls.DEMAND_SOURCE_DELIVERY(i),
        p_mtls.ITEM_SEGMENTS(i),
        p_mtls.ITEM_DESCRIPTION(i),
        p_mtls.ITEM_TRX_ENABLED_FLAG(i),
        p_mtls.ITEM_LOCATION_CONTROL_CODE(i),
        p_mtls.ITEM_RESTRICT_SUBINV_CODE(i),
        p_mtls.ITEM_RESTRICT_LOCATORS_CODE(i),
        p_mtls.ITEM_REVISION_QTY_CONTROL_CODE(i),
        p_mtls.ITEM_PRIMARY_UOM_CODE(i),
        p_mtls.ITEM_UOM_CLASS(i),
        p_mtls.ITEM_SHELF_LIFE_CODE(i),
        p_mtls.ITEM_SHELF_LIFE_DAYS(i),
        p_mtls.ITEM_LOT_CONTROL_CODE(i),
        p_mtls.ITEM_SERIAL_CONTROL_CODE(i),
        p_mtls.ALLOWED_UNITS_LOOKUP_CODE(i),
        p_mtls.DEPARTMENT_ID(i),
        p_mtls.WIP_SUPPLY_TYPE(i),
        p_mtls.SUPPLY_SUBINVENTORY(i),
        p_mtls.SUPPLY_LOCATOR_ID(i),
        p_mtls.VALID_SUBINVENTORY_FLAG(i),
        p_mtls.VALID_LOCATOR_FLAG(i),
        p_mtls.LOCATOR_SEGMENTS(i),
        p_mtls.CURRENT_LOCATOR_CONTROL_CODE(i),
        p_mtls.NUMBER_OF_LOTS_ENTERED(i),
        p_mtls.WIP_COMMIT_FLAG(i),
        p_mtls.NEXT_LOT_NUMBER(i),
        p_mtls.LOT_ALPHA_PREFIX(i),
        p_mtls.NEXT_SERIAL_NUMBER(i),
        p_mtls.SERIAL_ALPHA_PREFIX(i),
        p_mtls.POSTING_FLAG(i),
        p_mtls.REQUIRED_FLAG(i),
        p_mtls.PROCESS_FLAG(i),
        p_mtls.ERROR_CODE(i),
        p_mtls.ATTRIBUTE_CATEGORY(i),
        p_mtls.ATTRIBUTE1(i),
        p_mtls.ATTRIBUTE2(i),
        p_mtls.ATTRIBUTE3(i),
        p_mtls.ATTRIBUTE4(i),
        p_mtls.ATTRIBUTE5(i),
        p_mtls.ATTRIBUTE6(i),
        p_mtls.ATTRIBUTE7(i),
        p_mtls.ATTRIBUTE8(i),
        p_mtls.ATTRIBUTE9(i),
        p_mtls.ATTRIBUTE10(i),
        p_mtls.ATTRIBUTE11(i),
        p_mtls.ATTRIBUTE12(i),
        p_mtls.ATTRIBUTE13(i),
        p_mtls.ATTRIBUTE14(i),
        p_mtls.ATTRIBUTE15(i),
        p_mtls.PRIMARY_SWITCH(i),
        p_mtls.DEPARTMENT_CODE(i),
        p_mtls.ERROR_EXPLANATION(i),
        p_mtls.DEMAND_ID(i),
        p_mtls.ITEM_INVENTORY_ASSET_FLAG(i),
        p_mtls.SHIPPABLE_FLAG(i),
        p_mtls.REQUISITION_LINE_ID(i),
        p_mtls.REQUISITION_DISTRIBUTION_ID(i),
        p_mtls.MOVEMENT_ID(i),
        p_mtls.RESERVATION_QUANTITY(i),
        p_mtls.SHIPPED_QUANTITY(i),
        p_mtls.TRANSACTION_LINE_NUMBER(i),
        p_mtls.EXPENDITURE_TYPE(i),
        p_mtls.FINAL_COMPLETION_FLAG(i),
        p_mtls.MATERIAL_ACCOUNT(i),
        p_mtls.MATERIAL_OVERHEAD_ACCOUNT(i),
        p_mtls.OUTSIDE_PROCESSING_ACCOUNT(i),
        p_mtls.OVERHEAD_ACCOUNT(i),
        p_mtls.PA_EXPENDITURE_ORG_ID(i),
        p_mtls.PROJECT_ID(i),
        p_mtls.RESOURCE_ACCOUNT(i),
        p_mtls.SOURCE_PROJECT_ID(i),
        p_mtls.SOURCE_TASK_ID(i),
        p_mtls.TASK_ID(i),
        p_mtls.TO_PROJECT_ID(i),
        p_mtls.TO_TASK_ID(i),
        p_mtls.TRANSACTION_SEQUENCE_ID(i),
        p_mtls.TRANSFER_PERCENTAGE(i),
	p_mtls.qa_collection_id(i),
	p_mtls.overcompletion_transaction_id(i),
	p_mtls.overcompletion_transaction_qty(i),
	p_mtls.overcompletion_primary_qty(i),
	p_mtls.kanban_card_id(i)
      );

      i := i + 1;
    end loop;
  end insert_rows;

  procedure insert_rows(
    p_materials   in  mtl_transactions_temp_rec,
    p_lots        in  wip_lot_temp_cleanup.mtl_transaction_lots_temp_rec,
    p_serials     in  wip_serial_temp_cleanup.mtl_serial_numbers_temp_rec,
    p_dyn_serials in  wip_serial_number_cleanup.mtl_serial_numbers_rec,
    p_ser_marks   in  wip_serial_number_cleanup.mtl_serial_numbers_mark_rec,
    p_retcode     out nocopy number,
    p_app         out nocopy varchar2,
    p_msg         out nocopy varchar2) is
    x_retcode number;
  begin
    -- insert material transaction records
    insert_rows(p_mtls => p_materials);

    -- insert lot records
    wip_lot_temp_cleanup.insert_rows(p_lots => p_lots);

    -- insert serial records
    wip_serial_temp_cleanup.insert_rows(p_serials => p_serials);

    -- insert dynamic serial records
    wip_serial_number_cleanup.insert_rows(p_serials => p_dyn_serials);

    -- mark serial numbers
    wip_serial_number_cleanup.mark(
      p_serials => p_ser_marks,
      p_retcode => x_retcode);

    if (x_retcode <> wip_serial_number_cleanup.SUCCESS) then
      p_app := 'INV';
      p_msg := 'INV_RPC_CLEANUP_ERROR';
    else
      p_app := NULL;
      p_msg := NULL;
    end if;
    p_retcode := x_retcode;

    exception
	when others then
		p_retcode := 1;
		p_msg := FND_API.G_RET_STS_UNEXP_ERROR;
  end insert_rows;

END WIP_MTL_TXNS_TEMP_CLEANUP;

/
