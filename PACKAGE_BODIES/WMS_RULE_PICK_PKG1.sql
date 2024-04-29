--------------------------------------------------------
--  DDL for Package Body WMS_RULE_PICK_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_PICK_PKG1" AS

 ---- For Opening the Pick CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.Cv_pick_type,
          p_rule_id                    IN NUMBER,
          p_organization_id            IN NUMBER,
          p_inventory_item_id          IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          p_revision                   IN VARCHAR2,
          p_lot_number                 IN VARCHAR2,
          p_subinventory_code          IN VARCHAR2,
          p_locator_id                 IN NUMBER,
          p_cost_group_id              IN NUMBER,
          p_pp_transaction_temp_id     IN NUMBER,
          p_serial_controlled          IN NUMBER,
          p_detail_serial              IN NUMBER,
          p_detail_any_serial          IN NUMBER,
          p_from_serial_number         IN VARCHAR2,
          p_to_serial_number           IN VARCHAR2,
          p_unit_number                IN VARCHAR2,
          p_lpn_id                     IN NUMBER,
          p_project_id                 IN NUMBER,
          p_task_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER) is

  BEGIN
     IF    p_rule_id = 1 THEN
         WMS_RULE_1.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 2 THEN
         WMS_RULE_2.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 3 THEN
         WMS_RULE_3.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 4 THEN
         WMS_RULE_4.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 5 THEN
         WMS_RULE_5.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 6 THEN
         WMS_RULE_6.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 15 THEN
         WMS_RULE_15.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 14 THEN
         WMS_RULE_14.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 16 THEN
         WMS_RULE_16.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 17 THEN
         WMS_RULE_17.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
     ELSIF    p_rule_id = 18 THEN
         WMS_RULE_18.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
 
     END IF;
END EXECUTE_OPEN_RULE;

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor               IN  WMS_RULE_PVT.Cv_pick_type,
          p_rule_id              IN NUMBER,
          x_revision              OUT NOCOPY VARCHAR2,
          x_lot_number            OUT NOCOPY VARCHAR2,
          x_lot_expiration_date   OUT NOCOPY DATE,
          x_subinventory_code     OUT NOCOPY VARCHAR2,
          x_locator_id            OUT NOCOPY NUMBER,
          x_cost_group_id         OUT NOCOPY NUMBER,
          x_uom_code              OUT NOCOPY VARCHAR2,
          x_lpn_id                OUT NOCOPY NUMBER,
          x_serial_number         OUT NOCOPY VARCHAR2,
          x_possible_quantity     OUT NOCOPY NUMBER,
          x_sec_possible_quantity OUT NOCOPY NUMBER,
          x_grade_code            OUT NOCOPY VARCHAR2,
          x_consist_string        OUT NOCOPY VARCHAR2,
          x_order_by_string       OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY NUMBER) is

 BEGIN
     IF    p_rule_id = 1 THEN
         WMS_RULE_1.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 2 THEN
         WMS_RULE_2.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 3 THEN
         WMS_RULE_3.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 4 THEN
         WMS_RULE_4.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 5 THEN
         WMS_RULE_5.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 6 THEN
         WMS_RULE_6.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 15 THEN
         WMS_RULE_15.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 14 THEN
         WMS_RULE_14.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 16 THEN
         WMS_RULE_16.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 17 THEN
         WMS_RULE_17.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
     ELSIF    p_rule_id = 18 THEN
         WMS_RULE_18.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
 
     END IF;

END EXECUTE_FETCH_RULE;

PROCEDURE EXECUTE_FETCH_AVAILABLE_INV (
          p_cursor               IN  WMS_RULE_PVT.Cv_pick_type,
          p_rule_id              IN NUMBER,
          x_return_status         OUT NOCOPY NUMBER) is

 BEGIN
     IF    p_rule_id = 1 THEN
         WMS_RULE_1.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 2 THEN
         WMS_RULE_2.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 3 THEN
         WMS_RULE_3.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 4 THEN
         WMS_RULE_4.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 5 THEN
         WMS_RULE_5.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 6 THEN
         WMS_RULE_6.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 15 THEN
         WMS_RULE_15.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 14 THEN
         WMS_RULE_14.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 16 THEN
         WMS_RULE_16.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 17 THEN
         WMS_RULE_17.fetch_available_rows(
         p_cursor,
         x_return_status );
     ELSIF    p_rule_id = 18 THEN
         WMS_RULE_18.fetch_available_rows(
         p_cursor,
         x_return_status );
 
     END IF;

END EXECUTE_FETCH_AVAILABLE_INV;

 PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER,
                               p_cursor  IN WMS_RULE_PVT.Cv_pick_type) is
   BEGIN
     IF    p_rule_id = 1 THEN
          WMS_RULE_1.close_curs(p_cursor);
     ELSIF    p_rule_id = 2 THEN
          WMS_RULE_2.close_curs(p_cursor);
     ELSIF    p_rule_id = 3 THEN
          WMS_RULE_3.close_curs(p_cursor);
     ELSIF    p_rule_id = 4 THEN
          WMS_RULE_4.close_curs(p_cursor);
     ELSIF    p_rule_id = 5 THEN
          WMS_RULE_5.close_curs(p_cursor);
     ELSIF    p_rule_id = 6 THEN
          WMS_RULE_6.close_curs(p_cursor);
     ELSIF    p_rule_id = 15 THEN
          WMS_RULE_15.close_curs(p_cursor);
     ELSIF    p_rule_id = 14 THEN
          WMS_RULE_14.close_curs(p_cursor);
     ELSIF    p_rule_id = 16 THEN
          WMS_RULE_16.close_curs(p_cursor);
     ELSIF    p_rule_id = 17 THEN
          WMS_RULE_17.close_curs(p_cursor);
     ELSIF    p_rule_id = 18 THEN
          WMS_RULE_18.close_curs(p_cursor);
 
     END IF;
 END EXECUTE_CLOSE_RULE;
END WMS_RULE_PICK_PKG1;
--COMMIT;
--EXIT;

/
