--------------------------------------------------------
--  DDL for Package Body INV_TROLIN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TROLIN_UTIL" AS
  /* $Header: INVUTRLB.pls 120.3.12010000.2 2009/08/28 18:00:21 vissubra ship $ */

  --  Global constant holding the package name

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Trolin_Util';

  --  Procedure Clear_Dependent_Attr

  PROCEDURE clear_dependent_attr(
    p_attr_id        IN     NUMBER := fnd_api.g_miss_num
  , p_trolin_rec     IN     inv_move_order_pub.trolin_rec_type
  , p_old_trolin_rec IN     inv_move_order_pub.trolin_rec_type := inv_move_order_pub.g_miss_trolin_rec
  , x_trolin_rec     IN OUT    NOCOPY inv_move_order_pub.trolin_rec_type
  ) IS
    l_index        NUMBER                      := 0;
    l_src_attr_tbl inv_globals.number_tbl_type;
    l_dep_attr_tbl inv_globals.number_tbl_type;
  BEGIN
    --  Load out record

    x_trolin_rec  := p_trolin_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = fnd_api.g_miss_num THEN
      IF NOT inv_globals.equal(p_trolin_rec.attribute1, p_old_trolin_rec.attribute1) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute1;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute10, p_old_trolin_rec.attribute10) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute10;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute11, p_old_trolin_rec.attribute11) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute11;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute12, p_old_trolin_rec.attribute12) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute12;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute13, p_old_trolin_rec.attribute13) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute13;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute14, p_old_trolin_rec.attribute14) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute14;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute15, p_old_trolin_rec.attribute15) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute15;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute2, p_old_trolin_rec.attribute2) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute2;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute3, p_old_trolin_rec.attribute3) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute3;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute4, p_old_trolin_rec.attribute4) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute4;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute5, p_old_trolin_rec.attribute5) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute5;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute6, p_old_trolin_rec.attribute6) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute6;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute7, p_old_trolin_rec.attribute7) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute7;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute8, p_old_trolin_rec.attribute8) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute8;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute9, p_old_trolin_rec.attribute9) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute9;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.attribute_category, p_old_trolin_rec.attribute_category) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute_category;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.created_by, p_old_trolin_rec.created_by) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_created_by;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.creation_date, p_old_trolin_rec.creation_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_creation_date;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.date_required, p_old_trolin_rec.date_required) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_date_required;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.from_locator_id, p_old_trolin_rec.from_locator_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_locator;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.from_subinventory_code, p_old_trolin_rec.from_subinventory_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_subinventory;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.from_subinventory_id, p_old_trolin_rec.from_subinventory_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_subinventory;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.header_id, p_old_trolin_rec.header_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_header;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.inventory_item_id, p_old_trolin_rec.inventory_item_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_inventory_item;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.last_updated_by, p_old_trolin_rec.last_updated_by) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_last_updated_by;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.last_update_date, p_old_trolin_rec.last_update_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_last_update_date;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.last_update_login, p_old_trolin_rec.last_update_login) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_last_update_login;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.line_id, p_old_trolin_rec.line_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_line;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.line_number, p_old_trolin_rec.line_number) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_line_number;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.line_status, p_old_trolin_rec.line_status) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_line_status;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.lot_number, p_old_trolin_rec.lot_number) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_lot_number;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.organization_id, p_old_trolin_rec.organization_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_organization;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.program_application_id, p_old_trolin_rec.program_application_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_program_application;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.program_id, p_old_trolin_rec.program_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_program;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.program_update_date, p_old_trolin_rec.program_update_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_program_update_date;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.project_id, p_old_trolin_rec.project_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_project;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.quantity, p_old_trolin_rec.quantity) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_quantity;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.quantity_delivered, p_old_trolin_rec.quantity_delivered) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_quantity_delivered;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.quantity_detailed, p_old_trolin_rec.quantity_detailed) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_quantity_detailed;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.reason_id, p_old_trolin_rec.reason_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_reason;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.REFERENCE, p_old_trolin_rec.REFERENCE) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_reference;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.reference_id, p_old_trolin_rec.reference_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_reference;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.reference_type_code, p_old_trolin_rec.reference_type_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_reference_type;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.request_id, p_old_trolin_rec.request_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_request;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.revision, p_old_trolin_rec.revision) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_revision;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.serial_number_end, p_old_trolin_rec.serial_number_end) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_serial_number_end;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.serial_number_start, p_old_trolin_rec.serial_number_start) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_serial_number_start;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.status_date, p_old_trolin_rec.status_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_status_date;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.task_id, p_old_trolin_rec.task_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_task;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_account_id, p_old_trolin_rec.to_account_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_account;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_locator_id, p_old_trolin_rec.to_locator_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_locator;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_subinventory_code, p_old_trolin_rec.to_subinventory_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_subinventory;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_subinventory_id, p_old_trolin_rec.to_subinventory_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_subinventory;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.transaction_header_id, p_old_trolin_rec.transaction_header_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_transaction_header;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.uom_code, p_old_trolin_rec.uom_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_uom;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.transaction_type_id, p_old_trolin_rec.transaction_type_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_transaction_type_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_organization_id, p_old_trolin_rec.to_organization_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_organization_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.primary_quantity, p_old_trolin_rec.primary_quantity) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_primary_quantity;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.txn_source_id, p_old_trolin_rec.txn_source_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_txn_source_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.txn_source_line_id, p_old_trolin_rec.txn_source_line_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_txn_source_line_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.txn_source_line_detail_id, p_old_trolin_rec.txn_source_line_detail_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_txn_source_line_detail_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.transaction_source_type_id, p_old_trolin_rec.transaction_source_type_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_transaction_source_type_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.put_away_strategy_id, p_old_trolin_rec.put_away_strategy_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_put_away_strategy_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.pick_strategy_id, p_old_trolin_rec.pick_strategy_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_strategy_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.unit_number, p_old_trolin_rec.unit_number) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_unit_number;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.ship_to_location_id, p_old_trolin_rec.ship_to_location_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_ship_to_location_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.from_cost_group_id, p_old_trolin_rec.from_cost_group_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_cost_group_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_cost_group_id, p_old_trolin_rec.to_cost_group_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_cost_group_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.lpn_id, p_old_trolin_rec.lpn_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_lpn_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.to_lpn_id, p_old_trolin_rec.to_lpn_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_lpn_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.pick_methodology_id, p_old_trolin_rec.pick_methodology_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_methodology_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.container_item_id, p_old_trolin_rec.container_item_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_container_item_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.carton_grouping_id, p_old_trolin_rec.carton_grouping_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_carton_grouping_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.pick_slip_number, p_old_trolin_rec.pick_slip_number) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_slip_number;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.pick_slip_date, p_old_trolin_rec.pick_slip_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_slip_date;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.ship_set_id, p_old_trolin_rec.ship_set_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_ship_set_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.ship_model_id, p_old_trolin_rec.ship_model_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_ship_model_id;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.model_quantity, p_old_trolin_rec.model_quantity) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_model_quantity;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.required_quantity, p_old_trolin_rec.required_quantity) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_required_quantity;
END IF;
--INVCONV BEGIN
      IF NOT inv_globals.equal(p_trolin_rec.secondary_quantity, p_old_trolin_rec.secondary_quantity) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_quantity;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.secondary_quantity_delivered, p_old_trolin_rec.secondary_quantity_delivered) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_quantity_delivered;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.secondary_quantity_detailed, p_old_trolin_rec.secondary_quantity_detailed) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_quantity_detailed;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.secondary_uom, p_old_trolin_rec.secondary_uom) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_uom;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.grade_code, p_old_trolin_rec.grade_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_grade_code;
      END IF;

      IF NOT inv_globals.equal(p_trolin_rec.secondary_required_quantity, p_old_trolin_rec.secondary_required_quantity) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_required_quantity;
      END IF;
--INVCONV END;
    ELSIF p_attr_id = g_attribute1 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute1;
    ELSIF p_attr_id = g_attribute10 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute10;
    ELSIF p_attr_id = g_attribute11 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute11;
    ELSIF p_attr_id = g_attribute12 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute12;
    ELSIF p_attr_id = g_attribute13 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute13;
    ELSIF p_attr_id = g_attribute14 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute14;
    ELSIF p_attr_id = g_attribute15 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute15;
    ELSIF p_attr_id = g_attribute2 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute2;
    ELSIF p_attr_id = g_attribute3 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute3;
    ELSIF p_attr_id = g_attribute4 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute4;
    ELSIF p_attr_id = g_attribute5 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute5;
    ELSIF p_attr_id = g_attribute6 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute6;
    ELSIF p_attr_id = g_attribute7 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute7;
    ELSIF p_attr_id = g_attribute8 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute8;
    ELSIF p_attr_id = g_attribute9 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute9;
    ELSIF p_attr_id = g_attribute_category THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_attribute_category;
    ELSIF p_attr_id = g_created_by THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_created_by;
    ELSIF p_attr_id = g_creation_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_creation_date;
    ELSIF p_attr_id = g_date_required THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_date_required;
    ELSIF p_attr_id = g_from_locator THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_locator;
    ELSIF p_attr_id = g_from_subinventory THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_subinventory;
    ELSIF p_attr_id = g_from_subinventory THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_subinventory;
    ELSIF p_attr_id = g_header THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_header;
    ELSIF p_attr_id = g_inventory_item THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_inventory_item;
    ELSIF p_attr_id = g_last_updated_by THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_last_updated_by;
    ELSIF p_attr_id = g_last_update_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_last_update_date;
    ELSIF p_attr_id = g_last_update_login THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_last_update_login;
    ELSIF p_attr_id = g_line THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_line;
    ELSIF p_attr_id = g_line_number THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_line_number;
    ELSIF p_attr_id = g_line_status THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_line_status;
    ELSIF p_attr_id = g_lot_number THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_lot_number;
    ELSIF p_attr_id = g_organization THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_organization;
    ELSIF p_attr_id = g_program_application THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_program_application;
    ELSIF p_attr_id = g_program THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_program;
    ELSIF p_attr_id = g_program_update_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_program_update_date;
    ELSIF p_attr_id = g_project THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_project;
    ELSIF p_attr_id = g_quantity THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_quantity;
    ELSIF p_attr_id = g_quantity_delivered THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_quantity_delivered;
    ELSIF p_attr_id = g_quantity_detailed THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_quantity_detailed;
    ELSIF p_attr_id = g_reason THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_reason;
    ELSIF p_attr_id = g_reference THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_reference;
    ELSIF p_attr_id = g_reference THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_reference;
    ELSIF p_attr_id = g_reference_type THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_reference_type;
    ELSIF p_attr_id = g_request THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_request;
    ELSIF p_attr_id = g_revision THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_revision;
    ELSIF p_attr_id = g_serial_number_end THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_serial_number_end;
    ELSIF p_attr_id = g_serial_number_start THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_serial_number_start;
    ELSIF p_attr_id = g_status_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_status_date;
    ELSIF p_attr_id = g_task THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_task;
    ELSIF p_attr_id = g_to_account THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_account;
    ELSIF p_attr_id = g_to_locator THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_locator;
    ELSIF p_attr_id = g_to_subinventory THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_subinventory;
    ELSIF p_attr_id = g_to_subinventory THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_subinventory;
    ELSIF p_attr_id = g_transaction_header THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_transaction_header;
    ELSIF p_attr_id = g_uom THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_uom;
    ELSIF p_attr_id = g_txn_source_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_txn_source_id;
    ELSIF p_attr_id = g_txn_source_line_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_txn_source_line_id;
    ELSIF p_attr_id = g_txn_source_line_detail_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_txn_source_line_detail_id;
    ELSIF p_attr_id = g_transaction_type_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_transaction_type_id;
    ELSIF p_attr_id = g_transaction_source_type_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_transaction_source_type_id;
    ELSIF p_attr_id = g_primary_quantity THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_primary_quantity;
    ELSIF p_attr_id = g_to_organization_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_organization_id;
    ELSIF p_attr_id = g_put_away_strategy_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_put_away_strategy_id;
    ELSIF p_attr_id = g_pick_strategy_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_strategy_id;
    ELSIF p_attr_id = g_unit_number THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_unit_number;
    ELSIF p_attr_id = g_ship_to_location_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_ship_to_location_id;
    ELSIF p_attr_id = g_from_cost_group_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_from_cost_group_id;
    ELSIF p_attr_id = g_to_cost_group_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_cost_group_id;
    ELSIF p_attr_id = g_lpn_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_lpn_id;
    ELSIF p_attr_id = g_to_lpn_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_to_lpn_id;
    ELSIF p_attr_id = g_pick_methodology_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_methodology_id;
    ELSIF p_attr_id = g_container_item_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_container_item_id;
    ELSIF p_attr_id = g_carton_grouping_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_carton_grouping_id;
    ELSIF p_attr_id = g_pick_slip_number THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_slip_number;
    ELSIF p_attr_id = g_pick_slip_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_pick_slip_date;
    ELSIF p_attr_id = g_ship_set_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_ship_set_id;
    ELSIF p_attr_id = g_ship_model_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_ship_model_id;
    ELSIF p_attr_id = g_model_quantity THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_model_quantity;
    ELSIF p_attr_id = g_required_quantity THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_required_quantity;
--INVCONV BEGIN
    ELSIF p_attr_id = g_secondary_quantity THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_quantity;
    ELSIF p_attr_id = g_secondary_quantity_delivered THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_quantity_delivered;
    ELSIF p_attr_id = g_secondary_quantity_detailed THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_quantity_detailed;
    ELSIF p_attr_id = g_secondary_required_quantity THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_required_quantity;
    ELSIF p_attr_id = g_secondary_uom THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_secondary_uom;
    ELSIF p_attr_id = g_grade_code THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trolin_util.g_grade_code;
--INVCONV END
    END IF;
  END clear_dependent_attr;

  --  Procedure Apply_Attribute_Changes

  PROCEDURE apply_attribute_changes(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_old_trolin_rec IN inv_move_order_pub.trolin_rec_type := inv_move_order_pub.g_miss_trolin_rec, x_trolin_rec IN OUT NOCOPY inv_move_order_pub.trolin_rec_type) IS
  BEGIN
    --  Load out record

    x_trolin_rec  := p_trolin_rec;

    IF NOT inv_globals.equal(p_trolin_rec.attribute1, p_old_trolin_rec.attribute1) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute10, p_old_trolin_rec.attribute10) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute11, p_old_trolin_rec.attribute11) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute12, p_old_trolin_rec.attribute12) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute13, p_old_trolin_rec.attribute13) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute14, p_old_trolin_rec.attribute14) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute15, p_old_trolin_rec.attribute15) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute2, p_old_trolin_rec.attribute2) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute3, p_old_trolin_rec.attribute3) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute4, p_old_trolin_rec.attribute4) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute5, p_old_trolin_rec.attribute5) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute6, p_old_trolin_rec.attribute6) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute7, p_old_trolin_rec.attribute7) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute8, p_old_trolin_rec.attribute8) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute9, p_old_trolin_rec.attribute9) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.attribute_category, p_old_trolin_rec.attribute_category) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.created_by, p_old_trolin_rec.created_by) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.creation_date, p_old_trolin_rec.creation_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.date_required, p_old_trolin_rec.date_required) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.from_locator_id, p_old_trolin_rec.from_locator_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.from_subinventory_code, p_old_trolin_rec.from_subinventory_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.from_subinventory_id, p_old_trolin_rec.from_subinventory_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.header_id, p_old_trolin_rec.header_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.inventory_item_id, p_old_trolin_rec.inventory_item_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.last_updated_by, p_old_trolin_rec.last_updated_by) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.last_update_date, p_old_trolin_rec.last_update_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.last_update_login, p_old_trolin_rec.last_update_login) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.line_id, p_old_trolin_rec.line_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.line_number, p_old_trolin_rec.line_number) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.line_status, p_old_trolin_rec.line_status) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.lot_number, p_old_trolin_rec.lot_number) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.organization_id, p_old_trolin_rec.organization_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.program_application_id, p_old_trolin_rec.program_application_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.program_id, p_old_trolin_rec.program_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.program_update_date, p_old_trolin_rec.program_update_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.project_id, p_old_trolin_rec.project_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.quantity, p_old_trolin_rec.quantity) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.quantity_delivered, p_old_trolin_rec.quantity_delivered) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.quantity_detailed, p_old_trolin_rec.quantity_detailed) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.reason_id, p_old_trolin_rec.reason_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.REFERENCE, p_old_trolin_rec.REFERENCE) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.reference_id, p_old_trolin_rec.reference_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.reference_type_code, p_old_trolin_rec.reference_type_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.request_id, p_old_trolin_rec.request_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.revision, p_old_trolin_rec.revision) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.serial_number_end, p_old_trolin_rec.serial_number_end) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.serial_number_start, p_old_trolin_rec.serial_number_start) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.status_date, p_old_trolin_rec.status_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.task_id, p_old_trolin_rec.task_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_account_id, p_old_trolin_rec.to_account_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_locator_id, p_old_trolin_rec.to_locator_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_subinventory_code, p_old_trolin_rec.to_subinventory_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_subinventory_id, p_old_trolin_rec.to_subinventory_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.transaction_header_id, p_old_trolin_rec.transaction_header_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.uom_code, p_old_trolin_rec.uom_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.transaction_type_id, p_old_trolin_rec.transaction_type_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.transaction_source_type_id, p_old_trolin_rec.transaction_source_type_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.txn_source_id, p_old_trolin_rec.txn_source_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.txn_source_line_id, p_old_trolin_rec.txn_source_line_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.txn_source_line_detail_id, p_old_trolin_rec.txn_source_line_detail_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_organization_id, p_old_trolin_rec.to_organization_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.primary_quantity, p_old_trolin_rec.primary_quantity) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.pick_strategy_id, p_old_trolin_rec.pick_strategy_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.put_away_strategy_id, p_old_trolin_rec.put_away_strategy_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.unit_number, p_old_trolin_rec.unit_number) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.ship_to_location_id, p_old_trolin_rec.ship_to_location_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.from_cost_group_id, p_old_trolin_rec.from_cost_group_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_cost_group_id, p_old_trolin_rec.to_cost_group_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.lpn_id, p_old_trolin_rec.lpn_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.to_lpn_id, p_old_trolin_rec.to_lpn_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.pick_methodology_id, p_old_trolin_rec.pick_methodology_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.container_item_id, p_old_trolin_rec.container_item_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.carton_grouping_id, p_old_trolin_rec.carton_grouping_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.pick_slip_number, p_old_trolin_rec.pick_slip_number) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.pick_slip_date, p_old_trolin_rec.pick_slip_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.ship_set_id, p_old_trolin_rec.ship_set_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.ship_model_id, p_old_trolin_rec.ship_model_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.model_quantity, p_old_trolin_rec.model_quantity) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.required_quantity, p_old_trolin_rec.required_quantity) THEN
      NULL;
END IF;
--INVCONV BEGIN
   IF NOT inv_globals.equal(p_trolin_rec.secondary_uom, p_old_trolin_rec.secondary_uom) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.secondary_quantity, p_old_trolin_rec.secondary_quantity) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.secondary_quantity_delivered, p_old_trolin_rec.secondary_quantity_delivered) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.secondary_quantity_detailed, p_old_trolin_rec.secondary_quantity_detailed) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.grade_code, p_old_trolin_rec.grade_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trolin_rec.secondary_required_quantity, p_old_trolin_rec.secondary_required_quantity) THEN
      NULL;
    END IF;

--INVCONV END;

  END apply_attribute_changes;

  --  Function Complete_Record

  FUNCTION complete_record(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_old_trolin_rec IN inv_move_order_pub.trolin_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type := p_trolin_rec;
  BEGIN
    IF l_trolin_rec.attribute1 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute1  := p_old_trolin_rec.attribute1;
    END IF;

    IF l_trolin_rec.attribute10 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute10  := p_old_trolin_rec.attribute10;
    END IF;

    IF l_trolin_rec.attribute11 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute11  := p_old_trolin_rec.attribute11;
    END IF;

    IF l_trolin_rec.attribute12 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute12  := p_old_trolin_rec.attribute12;
    END IF;

    IF l_trolin_rec.attribute13 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute13  := p_old_trolin_rec.attribute13;
    END IF;

    IF l_trolin_rec.attribute14 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute14  := p_old_trolin_rec.attribute14;
    END IF;

    IF l_trolin_rec.attribute15 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute15  := p_old_trolin_rec.attribute15;
    END IF;

    IF l_trolin_rec.attribute2 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute2  := p_old_trolin_rec.attribute2;
    END IF;

    IF l_trolin_rec.attribute3 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute3  := p_old_trolin_rec.attribute3;
    END IF;

    IF l_trolin_rec.attribute4 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute4  := p_old_trolin_rec.attribute4;
    END IF;

    IF l_trolin_rec.attribute5 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute5  := p_old_trolin_rec.attribute5;
    END IF;

    IF l_trolin_rec.attribute6 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute6  := p_old_trolin_rec.attribute6;
    END IF;

    IF l_trolin_rec.attribute7 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute7  := p_old_trolin_rec.attribute7;
    END IF;

    IF l_trolin_rec.attribute8 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute8  := p_old_trolin_rec.attribute8;
    END IF;

    IF l_trolin_rec.attribute9 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute9  := p_old_trolin_rec.attribute9;
    END IF;

    IF l_trolin_rec.attribute_category = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute_category  := p_old_trolin_rec.attribute_category;
    END IF;

    IF l_trolin_rec.created_by = fnd_api.g_miss_num THEN
      l_trolin_rec.created_by  := p_old_trolin_rec.created_by;
    END IF;

    IF l_trolin_rec.creation_date = fnd_api.g_miss_date THEN
      l_trolin_rec.creation_date  := p_old_trolin_rec.creation_date;
    END IF;

    IF l_trolin_rec.date_required = fnd_api.g_miss_date THEN
      l_trolin_rec.date_required  := p_old_trolin_rec.date_required;
    END IF;

    IF l_trolin_rec.from_locator_id = fnd_api.g_miss_num THEN
      l_trolin_rec.from_locator_id  := p_old_trolin_rec.from_locator_id;
    END IF;

    IF l_trolin_rec.from_subinventory_code = fnd_api.g_miss_char THEN
      l_trolin_rec.from_subinventory_code  := p_old_trolin_rec.from_subinventory_code;
    END IF;

    IF l_trolin_rec.from_subinventory_id = fnd_api.g_miss_num THEN
      l_trolin_rec.from_subinventory_id  := p_old_trolin_rec.from_subinventory_id;
    END IF;

    IF l_trolin_rec.header_id = fnd_api.g_miss_num THEN
      l_trolin_rec.header_id  := p_old_trolin_rec.header_id;
    END IF;

    IF l_trolin_rec.inventory_item_id = fnd_api.g_miss_num THEN
      l_trolin_rec.inventory_item_id  := p_old_trolin_rec.inventory_item_id;
    END IF;

    IF l_trolin_rec.last_updated_by = fnd_api.g_miss_num THEN
      l_trolin_rec.last_updated_by  := p_old_trolin_rec.last_updated_by;
    END IF;

    IF l_trolin_rec.last_update_date = fnd_api.g_miss_date THEN
      l_trolin_rec.last_update_date  := p_old_trolin_rec.last_update_date;
    END IF;

    IF l_trolin_rec.last_update_login = fnd_api.g_miss_num THEN
      l_trolin_rec.last_update_login  := p_old_trolin_rec.last_update_login;
    END IF;

    IF l_trolin_rec.line_id = fnd_api.g_miss_num THEN
      l_trolin_rec.line_id  := p_old_trolin_rec.line_id;
    END IF;

    IF l_trolin_rec.line_number = fnd_api.g_miss_num THEN
      l_trolin_rec.line_number  := p_old_trolin_rec.line_number;
    END IF;

    IF l_trolin_rec.line_status = fnd_api.g_miss_num THEN
      l_trolin_rec.line_status  := p_old_trolin_rec.line_status;
    END IF;

    IF l_trolin_rec.lot_number = fnd_api.g_miss_char THEN
      l_trolin_rec.lot_number  := p_old_trolin_rec.lot_number;
    END IF;

    IF l_trolin_rec.organization_id = fnd_api.g_miss_num THEN
      l_trolin_rec.organization_id  := p_old_trolin_rec.organization_id;
    END IF;

    IF l_trolin_rec.program_application_id = fnd_api.g_miss_num THEN
      l_trolin_rec.program_application_id  := p_old_trolin_rec.program_application_id;
    END IF;

    IF l_trolin_rec.program_id = fnd_api.g_miss_num THEN
      l_trolin_rec.program_id  := p_old_trolin_rec.program_id;
    END IF;

    IF l_trolin_rec.program_update_date = fnd_api.g_miss_date THEN
      l_trolin_rec.program_update_date  := p_old_trolin_rec.program_update_date;
    END IF;

    IF l_trolin_rec.project_id = fnd_api.g_miss_num THEN
      l_trolin_rec.project_id  := p_old_trolin_rec.project_id;
    END IF;

    IF l_trolin_rec.quantity = fnd_api.g_miss_num THEN
      l_trolin_rec.quantity  := p_old_trolin_rec.quantity;
    END IF;

    IF l_trolin_rec.quantity_delivered = fnd_api.g_miss_num THEN
      l_trolin_rec.quantity_delivered  := p_old_trolin_rec.quantity_delivered;
    END IF;

    IF l_trolin_rec.quantity_detailed = fnd_api.g_miss_num THEN
      l_trolin_rec.quantity_detailed  := p_old_trolin_rec.quantity_detailed;
    END IF;

    IF l_trolin_rec.reason_id = fnd_api.g_miss_num THEN
      l_trolin_rec.reason_id  := p_old_trolin_rec.reason_id;
    END IF;

    IF l_trolin_rec.REFERENCE = fnd_api.g_miss_char THEN
      l_trolin_rec.REFERENCE  := p_old_trolin_rec.REFERENCE;
    END IF;

    IF l_trolin_rec.reference_id = fnd_api.g_miss_num THEN
      l_trolin_rec.reference_id  := p_old_trolin_rec.reference_id;
    END IF;

    IF l_trolin_rec.reference_type_code = fnd_api.g_miss_num THEN
      l_trolin_rec.reference_type_code  := p_old_trolin_rec.reference_type_code;
    END IF;

    IF l_trolin_rec.request_id = fnd_api.g_miss_num THEN
      l_trolin_rec.request_id  := p_old_trolin_rec.request_id;
    END IF;

    IF l_trolin_rec.revision = fnd_api.g_miss_char THEN
      l_trolin_rec.revision  := p_old_trolin_rec.revision;
    END IF;

    IF l_trolin_rec.serial_number_end = fnd_api.g_miss_char THEN
      l_trolin_rec.serial_number_end  := p_old_trolin_rec.serial_number_end;
    END IF;

    IF l_trolin_rec.serial_number_start = fnd_api.g_miss_char THEN
      l_trolin_rec.serial_number_start  := p_old_trolin_rec.serial_number_start;
    END IF;

    IF l_trolin_rec.status_date = fnd_api.g_miss_date THEN
      l_trolin_rec.status_date  := p_old_trolin_rec.status_date;
    END IF;

    IF l_trolin_rec.task_id = fnd_api.g_miss_num THEN
      l_trolin_rec.task_id  := p_old_trolin_rec.task_id;
    END IF;

    IF l_trolin_rec.to_account_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_account_id  := p_old_trolin_rec.to_account_id;
    END IF;

    IF l_trolin_rec.to_locator_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_locator_id  := p_old_trolin_rec.to_locator_id;
    END IF;

    IF l_trolin_rec.to_subinventory_code = fnd_api.g_miss_char THEN
      l_trolin_rec.to_subinventory_code  := p_old_trolin_rec.to_subinventory_code;
    END IF;

    IF l_trolin_rec.to_subinventory_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_subinventory_id  := p_old_trolin_rec.to_subinventory_id;
    END IF;

    IF l_trolin_rec.transaction_header_id = fnd_api.g_miss_num THEN
      l_trolin_rec.transaction_header_id  := p_old_trolin_rec.transaction_header_id;
    END IF;

    IF l_trolin_rec.uom_code = fnd_api.g_miss_char THEN
      l_trolin_rec.uom_code  := p_old_trolin_rec.uom_code;
    END IF;

    IF l_trolin_rec.transaction_type_id = fnd_api.g_miss_num THEN
      l_trolin_rec.transaction_type_id  := p_old_trolin_rec.transaction_type_id;
    END IF;

    IF l_trolin_rec.transaction_source_type_id = fnd_api.g_miss_num THEN
      l_trolin_rec.transaction_source_type_id  := p_old_trolin_rec.transaction_source_type_id;
    END IF;

    IF l_trolin_rec.txn_source_id = fnd_api.g_miss_num THEN
      l_trolin_rec.txn_source_id  := p_old_trolin_rec.txn_source_id;
    END IF;

    IF l_trolin_rec.txn_source_line_id = fnd_api.g_miss_num THEN
      l_trolin_rec.txn_source_line_id  := p_old_trolin_rec.txn_source_line_id;
    END IF;

    IF l_trolin_rec.txn_source_line_detail_id = fnd_api.g_miss_num THEN
      l_trolin_rec.txn_source_line_detail_id  := p_old_trolin_rec.txn_source_line_detail_id;
    END IF;

    IF l_trolin_rec.primary_quantity = fnd_api.g_miss_num THEN
      l_trolin_rec.primary_quantity  := p_old_trolin_rec.primary_quantity;
    END IF;

    IF l_trolin_rec.to_organization_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_organization_id  := p_old_trolin_rec.to_organization_id;
    END IF;

    IF l_trolin_rec.pick_strategy_id = fnd_api.g_miss_num THEN
      l_trolin_rec.pick_strategy_id  := p_old_trolin_rec.pick_strategy_id;
    END IF;

    IF l_trolin_rec.put_away_strategy_id = fnd_api.g_miss_num THEN
      l_trolin_rec.put_away_strategy_id  := p_old_trolin_rec.put_away_strategy_id;
    END IF;

    IF l_trolin_rec.unit_number = fnd_api.g_miss_char THEN
      l_trolin_rec.unit_number  := p_old_trolin_rec.unit_number;
    END IF;

    IF l_trolin_rec.ship_to_location_id = fnd_api.g_miss_num THEN
      l_trolin_rec.ship_to_location_id  := p_old_trolin_rec.ship_to_location_id;
    END IF;

    IF l_trolin_rec.from_cost_group_id = fnd_api.g_miss_num THEN
      l_trolin_rec.from_cost_group_id  := p_old_trolin_rec.from_cost_group_id;
    END IF;

    IF l_trolin_rec.to_cost_group_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_cost_group_id  := p_old_trolin_rec.to_cost_group_id;
    END IF;

    IF l_trolin_rec.lpn_id = fnd_api.g_miss_num THEN
      l_trolin_rec.lpn_id  := p_old_trolin_rec.lpn_id;
    END IF;

    IF l_trolin_rec.to_lpn_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_lpn_id  := p_old_trolin_rec.to_lpn_id;
    END IF;

    IF l_trolin_rec.pick_methodology_id = fnd_api.g_miss_num THEN
      l_trolin_rec.pick_methodology_id  := p_old_trolin_rec.pick_methodology_id;
    END IF;

    IF l_trolin_rec.container_item_id = fnd_api.g_miss_num THEN
      l_trolin_rec.container_item_id  := p_old_trolin_rec.container_item_id;
    END IF;

    IF l_trolin_rec.carton_grouping_id = fnd_api.g_miss_num THEN
      l_trolin_rec.carton_grouping_id  := p_old_trolin_rec.carton_grouping_id;
    END IF;

--INVCONV BEGIN
    IF l_trolin_rec.secondary_quantity = fnd_api.g_miss_num THEN
      l_trolin_rec.secondary_quantity  := p_old_trolin_rec.secondary_quantity;
    END IF;

    --Bug #4565509 - Should update secondary quantities from old records
    IF l_trolin_rec.secondary_quantity_delivered = fnd_api.g_miss_num THEN
      l_trolin_rec.secondary_quantity_delivered  := p_old_trolin_rec.secondary_quantity_delivered;
    END IF;

    IF l_trolin_rec.secondary_quantity_detailed = fnd_api.g_miss_num THEN
      l_trolin_rec.secondary_quantity_detailed  := p_old_trolin_rec.secondary_quantity_detailed;
    END IF;

    IF l_trolin_rec.secondary_uom = fnd_api.g_miss_char THEN
      l_trolin_rec.secondary_uom  := p_old_trolin_rec.secondary_uom;
    END IF;

    IF l_trolin_rec.grade_code = fnd_api.g_miss_char THEN
      l_trolin_rec.grade_code  := p_old_trolin_rec.grade_code;
    END IF;

-- INVCONV END;

    RETURN l_trolin_rec;
  END complete_record;

  --  Function Convert_Miss_To_Null

  FUNCTION convert_miss_to_null(p_trolin_rec IN inv_move_order_pub.trolin_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type := p_trolin_rec;
  BEGIN
    /*inv_debug.message('in convert');*/
    IF l_trolin_rec.attribute1 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute1  := NULL;
    END IF;

    IF l_trolin_rec.attribute10 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute10  := NULL;
    END IF;

    IF l_trolin_rec.attribute11 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute11  := NULL;
    END IF;

    IF l_trolin_rec.attribute12 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute12  := NULL;
    END IF;

    IF l_trolin_rec.attribute13 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute13  := NULL;
    END IF;

    IF l_trolin_rec.attribute14 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute14  := NULL;
    END IF;

    IF l_trolin_rec.attribute15 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute15  := NULL;
    END IF;

    IF l_trolin_rec.attribute2 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute2  := NULL;
    END IF;

    IF l_trolin_rec.attribute3 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute3  := NULL;
    END IF;

    IF l_trolin_rec.attribute4 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute4  := NULL;
    END IF;

    IF l_trolin_rec.attribute5 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute5  := NULL;
    END IF;

    IF l_trolin_rec.attribute6 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute6  := NULL;
    END IF;

    IF l_trolin_rec.attribute7 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute7  := NULL;
    END IF;

    IF l_trolin_rec.attribute8 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute8  := NULL;
    END IF;

    IF l_trolin_rec.attribute9 = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute9  := NULL;
    END IF;

    IF l_trolin_rec.attribute_category = fnd_api.g_miss_char THEN
      l_trolin_rec.attribute_category  := NULL;
    END IF;

    IF l_trolin_rec.created_by = fnd_api.g_miss_num THEN
      l_trolin_rec.created_by  := NULL;
    END IF;

    IF l_trolin_rec.creation_date = fnd_api.g_miss_date THEN
      l_trolin_rec.creation_date  := NULL;
    END IF;

    IF l_trolin_rec.date_required = fnd_api.g_miss_date THEN
      l_trolin_rec.date_required  := NULL;
    END IF;

    IF l_trolin_rec.from_locator_id = fnd_api.g_miss_num THEN
      l_trolin_rec.from_locator_id  := NULL;
    END IF;

    IF l_trolin_rec.from_subinventory_code = fnd_api.g_miss_char THEN
      l_trolin_rec.from_subinventory_code  := NULL;
    END IF;

    IF l_trolin_rec.from_subinventory_id = fnd_api.g_miss_num THEN
      l_trolin_rec.from_subinventory_id  := NULL;
    END IF;

    IF l_trolin_rec.header_id = fnd_api.g_miss_num THEN
      l_trolin_rec.header_id  := NULL;
    END IF;

    IF l_trolin_rec.inventory_item_id = fnd_api.g_miss_num THEN
      l_trolin_rec.inventory_item_id  := NULL;
    END IF;

    IF l_trolin_rec.last_updated_by = fnd_api.g_miss_num THEN
      l_trolin_rec.last_updated_by  := NULL;
    END IF;

    IF l_trolin_rec.last_update_date = fnd_api.g_miss_date THEN
      l_trolin_rec.last_update_date  := NULL;
    END IF;

    IF l_trolin_rec.last_update_login = fnd_api.g_miss_num THEN
      l_trolin_rec.last_update_login  := NULL;
    END IF;

    IF l_trolin_rec.line_id = fnd_api.g_miss_num THEN
      l_trolin_rec.line_id  := NULL;
    END IF;

    IF l_trolin_rec.line_number = fnd_api.g_miss_num THEN
      l_trolin_rec.line_number  := NULL;
    END IF;

    IF l_trolin_rec.line_status = fnd_api.g_miss_num THEN
      l_trolin_rec.line_status  := NULL;
    END IF;

    IF l_trolin_rec.lot_number = fnd_api.g_miss_char THEN
      l_trolin_rec.lot_number  := NULL;
    END IF;

    IF l_trolin_rec.organization_id = fnd_api.g_miss_num THEN
      l_trolin_rec.organization_id  := NULL;
    END IF;

    IF l_trolin_rec.program_application_id = fnd_api.g_miss_num THEN
      l_trolin_rec.program_application_id  := NULL;
    END IF;

    IF l_trolin_rec.program_id = fnd_api.g_miss_num THEN
      l_trolin_rec.program_id  := NULL;
    END IF;

    IF l_trolin_rec.program_update_date = fnd_api.g_miss_date THEN
      l_trolin_rec.program_update_date  := NULL;
    END IF;

    IF l_trolin_rec.project_id = fnd_api.g_miss_num THEN
      l_trolin_rec.project_id  := NULL;
    END IF;

    IF l_trolin_rec.quantity = fnd_api.g_miss_num THEN
      l_trolin_rec.quantity  := NULL;
    END IF;

    IF l_trolin_rec.quantity_delivered = fnd_api.g_miss_num THEN
      l_trolin_rec.quantity_delivered  := NULL;
    END IF;

    IF l_trolin_rec.quantity_detailed = fnd_api.g_miss_num THEN
      l_trolin_rec.quantity_detailed  := NULL;
    END IF;

    IF l_trolin_rec.reason_id = fnd_api.g_miss_num THEN
      l_trolin_rec.reason_id  := NULL;
    END IF;

    IF l_trolin_rec.REFERENCE = fnd_api.g_miss_char THEN
      l_trolin_rec.REFERENCE  := NULL;
    END IF;

    IF l_trolin_rec.reference_id = fnd_api.g_miss_num THEN
      l_trolin_rec.reference_id  := NULL;
    END IF;

    IF l_trolin_rec.reference_type_code = fnd_api.g_miss_num THEN
      l_trolin_rec.reference_type_code  := NULL;
    END IF;

    IF l_trolin_rec.request_id = fnd_api.g_miss_num THEN
      l_trolin_rec.request_id  := NULL;
    END IF;

    IF l_trolin_rec.revision = fnd_api.g_miss_char THEN
      l_trolin_rec.revision  := NULL;
    END IF;

    IF l_trolin_rec.serial_number_end = fnd_api.g_miss_char THEN
      l_trolin_rec.serial_number_end  := NULL;
    END IF;

    IF l_trolin_rec.serial_number_start = fnd_api.g_miss_char THEN
      l_trolin_rec.serial_number_start  := NULL;
    END IF;

    IF l_trolin_rec.status_date = fnd_api.g_miss_date THEN
      l_trolin_rec.status_date  := NULL;
    END IF;

    IF l_trolin_rec.task_id = fnd_api.g_miss_num THEN
      l_trolin_rec.task_id  := NULL;
    END IF;

    IF l_trolin_rec.to_account_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_account_id  := NULL;
    END IF;

    IF l_trolin_rec.to_locator_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_locator_id  := NULL;
    END IF;

    IF l_trolin_rec.to_subinventory_code = fnd_api.g_miss_char THEN
      l_trolin_rec.to_subinventory_code  := NULL;
    END IF;

    IF l_trolin_rec.to_subinventory_id = fnd_api.g_miss_num THEN
      l_trolin_rec.to_subinventory_id  := NULL;
    END IF;

    IF l_trolin_rec.transaction_header_id = fnd_api.g_miss_num THEN
      l_trolin_rec.transaction_header_id  := NULL;
    END IF;

    IF l_trolin_rec.uom_code = fnd_api.g_miss_char THEN
      l_trolin_rec.uom_code  := NULL;
    END IF;

--INVCONV BEGIN
    IF l_trolin_rec.secondary_quantity = fnd_api.g_miss_num THEN
      l_trolin_rec.secondary_quantity  := NULL;
    END IF;

    --Bug #4565509 - Should set secondary quantities
    IF l_trolin_rec.secondary_quantity_delivered = fnd_api.g_miss_num THEN
      l_trolin_rec.secondary_quantity_delivered  := NULL;
    END IF;

    IF l_trolin_rec.secondary_quantity_detailed = fnd_api.g_miss_num THEN
      l_trolin_rec.secondary_quantity_detailed  := NULL;
    END IF;

    IF l_trolin_rec.secondary_uom = fnd_api.g_miss_char THEN
      l_trolin_rec.secondary_uom  := NULL;
    END IF;

    IF l_trolin_rec.grade_code = fnd_api.g_miss_char THEN
      l_trolin_rec.grade_code  := NULL;
    END IF;
    /*Bug#5764123. Added the below code to NULL out 'pick_methodology_id',
      'container_item_id' and 'carton_grouping_id', if their value is MISS_NUM.*/
      IF (l_trolin_rec.pick_methodology_id = fnd_api.g_miss_num) THEN
        l_trolin_rec.pick_methodology_id := NULL;
      END IF;
      IF (l_trolin_rec.container_item_id = fnd_api.g_miss_num) THEN
        l_trolin_rec.container_item_id := NULL;
      END IF;
      IF (l_trolin_rec.carton_grouping_id = fnd_api.g_miss_num) THEN
        l_trolin_rec.carton_grouping_id := NULL;
      END IF;

-- INVCONV END;
    /*    IF l_trolin_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.transaction_type_id := NULL;
        END IF;

        IF l_trolin_rec.transaction_source_type_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.transaction_source_type_id := NULL;
        END IF;

        IF l_trolin_rec.txn_source_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.txn_source_id := NULL;
        END IF;

        IF l_trolin_rec.txn_source_line_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.txn_source_line_id := NULL;
        END IF;

        IF l_trolin_rec.txn_source_line_detail_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.txn_source_line_detail_id := NULL;
        END IF;

        IF l_trolin_rec.to_organization_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.to_organization_id := NULL;
        END IF;

        IF l_trolin_rec.primary_quantity = FND_API.G_MISS_NUM THEN
            l_trolin_rec.primary_quantity := NULL;
        END IF;

        IF l_trolin_rec.pick_strategy_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.pick_strategy_id := NULL;
        END IF;

        IF l_trolin_rec.put_away_strategy_id = FND_API.G_MISS_NUM THEN
            l_trolin_rec.put_away_strategy_id := NULL;
        END IF;
    */
    RETURN l_trolin_rec;
  END convert_miss_to_null;

 --  Function Convert_Miss_To_Null_Parallel  /*For Parallel Pick-Release*/

  FUNCTION convert_miss_to_null_parallel(p_trolin_rec IN inv_move_order_pub.trolin_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type := p_trolin_rec;

    BEGIN
    l_trolin_rec := inv_trolin_util.convert_miss_to_null(p_trolin_rec => l_trolin_rec);

    IF l_trolin_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.transaction_type_id := NULL;
    END IF;

    IF l_trolin_rec.transaction_source_type_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.transaction_source_type_id := NULL;
    END IF;

    IF l_trolin_rec.txn_source_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.txn_source_id := NULL;
    END IF;

    IF l_trolin_rec.txn_source_line_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.txn_source_line_id := NULL;
    END IF;

    IF l_trolin_rec.txn_source_line_detail_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.txn_source_line_detail_id := NULL;
    END IF;

    IF l_trolin_rec.to_organization_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.to_organization_id := NULL;
    END IF;

    IF l_trolin_rec.primary_quantity = FND_API.G_MISS_NUM THEN
        l_trolin_rec.primary_quantity := NULL;
    END IF;

    IF l_trolin_rec.pick_strategy_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.pick_strategy_id := NULL;
    END IF;

    IF l_trolin_rec.put_away_strategy_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.put_away_strategy_id := NULL;
    END IF;

    IF l_trolin_rec.ship_to_location_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.ship_to_location_id := NULL;
    END IF;

    IF l_trolin_rec.from_cost_group_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.from_cost_group_id := NULL;
    END IF;

    IF l_trolin_rec.to_cost_group_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.to_cost_group_id := NULL;
    END IF;

    IF l_trolin_rec.lpn_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.lpn_id := NULL;
    END IF;

    IF l_trolin_rec.to_lpn_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.to_lpn_id := NULL;
    END IF;

    IF l_trolin_rec.pick_methodology_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.pick_methodology_id := NULL;
    END IF;

    IF l_trolin_rec.container_item_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.container_item_id := NULL;
    END IF;

    IF l_trolin_rec.carton_grouping_id = FND_API.G_MISS_NUM THEN
        l_trolin_rec.carton_grouping_id := NULL;
    END IF;

    return l_trolin_rec;

  END convert_miss_to_null_parallel;


  -- Bug#2536932: Function convert_miss_to_null
  -- Converts all Miss Number, Char and Date to NULL Values.

  FUNCTION convert_miss_to_null (p_trolin_val_rec INV_MOVE_ORDER_PUB.TROLIN_VAL_REC_TYPE)
     RETURN INV_MOVE_ORDER_PUB.TROLIN_VAL_REC_TYPE IS
     l_trolin_val_rec INV_MOVE_ORDER_PUB.trolin_val_rec_type := p_trolin_val_rec;
  BEGIN
     IF l_trolin_val_rec.from_locator = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.from_locator := NULL;
     END IF;

     IF l_trolin_val_rec.header = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.header := NULL;
     END IF;

     IF l_trolin_val_rec.from_subinventory = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.from_subinventory := NULL;
     END IF;

     IF l_trolin_val_rec.inventory_item = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.inventory_item := NULL;
     END IF;

     IF l_trolin_val_rec.line = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.line := NULL;
     END IF;

     IF l_trolin_val_rec.organization = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.organization := NULL;
     END IF;

     IF l_trolin_val_rec.project = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.project := NULL;
     END IF;

     IF l_trolin_val_rec.reason = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.reason := NULL;
     END IF;

     IF l_trolin_val_rec.reference = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.reference := NULL;
     END IF;

     IF l_trolin_val_rec.reference_type = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.reference_type := NULL;
     END IF;

     IF l_trolin_val_rec.task = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.task := NULL;
     END IF;

     IF l_trolin_val_rec.to_account = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.to_account := NULL;
     END IF;

     IF l_trolin_val_rec.to_locator = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.to_locator := NULL;
     END IF;

     IF l_trolin_val_rec.to_subinventory = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.to_subinventory := NULL;
     END IF;

     IF l_trolin_val_rec.transaction_header = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.transaction_header := NULL;
     END IF;

     IF l_trolin_val_rec.uom = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.uom := NULL;
     END IF;

     IF l_trolin_val_rec.transaction_type = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.transaction_type := NULL;
     END IF;

     IF l_trolin_val_rec.to_organization = FND_API.G_MISS_CHAR THEN
        l_trolin_val_rec.to_organization := NULL;
     END IF;

     RETURN l_trolin_val_rec;
  END convert_miss_to_null;

  --  Procedure Update_Row

  PROCEDURE update_row(p_trolin_rec IN inv_move_order_pub.trolin_rec_type) IS
     l_tran_source_typ_id        NUMBER                      := 0;
     l_batch_exists              NUMBER                      := 0;

  BEGIN
      /* bug7115229 The transaction source type id is updated from 5 to 13. Because of which the select available inventory form is not
         showing the source details for the move order of type backflush transfer correctly. So iam putting a condition here before
	 updation of the transation source type id. If the txn source id corresponds to a batch, then the corresponding move order cannot
	 have a source type of inventory (13). It should retain its transaction source type id as job or schedule (5). This fix is
	 relevant only to OPM batches. */
     IF p_trolin_rec.transaction_source_type_id IS NOT NULL THEN
       BEGIN
              SELECT 1
              INTO  l_batch_exists
              FROM dual
              WHERE EXISTS (SELECT gmd.line_no
                             FROM gme_material_details gmd,mtl_txn_request_lines mtrl
                             WHERE gmd.material_detail_id=p_trolin_rec.txn_source_line_id
			     AND mtrl.organization_id=p_trolin_rec.organization_id
			     AND mtrl.txn_source_id=p_trolin_rec.txn_source_id
			     AND mtrl.inventory_item_id=p_trolin_rec.inventory_item_id
			     AND gmd.material_detail_id=mtrl.txn_source_line_id
                             AND mtrl.transaction_source_type_id=5);
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_batch_exists := 0;
	     END;
     END IF;
     IF l_batch_exists =1 THEN
	l_tran_source_typ_id:=5;
      ELSE
	l_tran_source_typ_id:=p_trolin_rec.transaction_source_type_id;
     END IF;

       UPDATE mtl_txn_request_lines
       SET attribute1 = p_trolin_rec.attribute1
         , attribute10 = p_trolin_rec.attribute10
         , attribute11 = p_trolin_rec.attribute11
         , attribute12 = p_trolin_rec.attribute12
         , attribute13 = p_trolin_rec.attribute13
         , attribute14 = p_trolin_rec.attribute14
         , attribute15 = p_trolin_rec.attribute15
         , attribute2 = p_trolin_rec.attribute2
         , attribute3 = p_trolin_rec.attribute3
         , attribute4 = p_trolin_rec.attribute4
         , attribute5 = p_trolin_rec.attribute5
         , attribute6 = p_trolin_rec.attribute6
         , attribute7 = p_trolin_rec.attribute7
         , attribute8 = p_trolin_rec.attribute8
         , attribute9 = p_trolin_rec.attribute9
         , attribute_category = p_trolin_rec.attribute_category
         , created_by = p_trolin_rec.created_by
         , creation_date = p_trolin_rec.creation_date
         , date_required = p_trolin_rec.date_required
         , from_locator_id = p_trolin_rec.from_locator_id
         , from_subinventory_code = p_trolin_rec.from_subinventory_code
         , from_subinventory_id = p_trolin_rec.from_subinventory_id
         , header_id = p_trolin_rec.header_id
         , inventory_item_id = p_trolin_rec.inventory_item_id
         , last_updated_by = p_trolin_rec.last_updated_by
         , last_update_date = p_trolin_rec.last_update_date
         , last_update_login = p_trolin_rec.last_update_login
         , line_id = p_trolin_rec.line_id
         , line_number = p_trolin_rec.line_number
         , line_status = p_trolin_rec.line_status
         , lot_number = p_trolin_rec.lot_number
         , organization_id = p_trolin_rec.organization_id
         , program_application_id = p_trolin_rec.program_application_id
         , program_id = p_trolin_rec.program_id
         , program_update_date = p_trolin_rec.program_update_date
         , project_id = p_trolin_rec.project_id
         , quantity = p_trolin_rec.quantity
         , quantity_delivered = p_trolin_rec.quantity_delivered
         , quantity_detailed = p_trolin_rec.quantity_detailed
         , reason_id = p_trolin_rec.reason_id
         , REFERENCE = p_trolin_rec.REFERENCE
         , reference_id = p_trolin_rec.reference_id
         , reference_type_code = p_trolin_rec.reference_type_code
         , request_id = p_trolin_rec.request_id
         , revision = p_trolin_rec.revision
         , serial_number_end = p_trolin_rec.serial_number_end
         , serial_number_start = p_trolin_rec.serial_number_start
         , status_date = p_trolin_rec.status_date
         , task_id = p_trolin_rec.task_id
         , to_account_id = p_trolin_rec.to_account_id
         , to_locator_id = p_trolin_rec.to_locator_id
         , to_subinventory_code = p_trolin_rec.to_subinventory_code
         , to_subinventory_id = p_trolin_rec.to_subinventory_id
         , transaction_header_id = p_trolin_rec.transaction_header_id
         , uom_code = p_trolin_rec.uom_code
         , transaction_type_id = p_trolin_rec.transaction_type_id
         , transaction_source_type_id = l_tran_source_typ_id               --bug7115229
         , txn_source_id = p_trolin_rec.txn_source_id
         , txn_source_line_id = p_trolin_rec.txn_source_line_id
         , txn_source_line_detail_id = p_trolin_rec.txn_source_line_detail_id
         , to_organization_id = p_trolin_rec.to_organization_id
         , primary_quantity = p_trolin_rec.primary_quantity
         , pick_strategy_id = p_trolin_rec.pick_strategy_id
         , put_away_strategy_id = p_trolin_rec.put_away_strategy_id
         , unit_number = p_trolin_rec.unit_number
         , ship_to_location_id = p_trolin_rec.ship_to_location_id
         , from_cost_group_id = p_trolin_rec.from_cost_group_id
         , to_cost_group_id = p_trolin_rec.to_cost_group_id
         , lpn_id = p_trolin_rec.lpn_id
         , to_lpn_id = p_trolin_rec.to_lpn_id
         , inspection_status = p_trolin_rec.inspection_status
         , pick_methodology_id = p_trolin_rec.pick_methodology_id
         , container_item_id = p_trolin_rec.container_item_id
         , carton_grouping_id = p_trolin_rec.carton_grouping_id
         , wms_process_flag = p_trolin_rec.wms_process_flag
         , pick_slip_number = p_trolin_rec.pick_slip_number
         , pick_slip_date = p_trolin_rec.pick_slip_date
         , ship_set_id = p_trolin_rec.ship_set_id
         , ship_model_id = p_trolin_rec.ship_model_id
         , model_quantity = p_trolin_rec.model_quantity
         , required_quantity = p_trolin_rec.required_quantity
--INVCONV BEGIN
         , secondary_quantity = p_trolin_rec.secondary_quantity
         , secondary_quantity_delivered = p_trolin_rec.secondary_quantity_delivered
         , secondary_quantity_detailed = p_trolin_rec.secondary_quantity_detailed
         , secondary_uom_code = p_trolin_rec.secondary_uom
         , secondary_required_quantity = p_trolin_rec.secondary_required_quantity
         , grade_code = p_trolin_rec.grade_code
--INVCONV END;
     WHERE line_id = p_trolin_rec.line_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_row;

  --  Procedure Update_Row_Status

  PROCEDURE update_row_status(p_line_id IN NUMBER, p_status IN NUMBER) IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type;
  BEGIN
    l_trolin_rec                    := inv_trolin_util.query_row(p_line_id);
    l_trolin_rec.line_status        := p_status;
    l_trolin_rec.last_update_date   := SYSDATE;
    l_trolin_rec.status_date        := SYSDATE; -- For Bug # 5053725
    l_trolin_rec.last_updated_by    := fnd_global.user_id;
    l_trolin_rec.last_update_login  := fnd_global.login_id;
    inv_trolin_util.update_row(l_trolin_rec);
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Row_Status');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_row_status;

  --  Procedure Insert_Row

  PROCEDURE insert_row(p_trolin_rec IN inv_move_order_pub.trolin_rec_type) IS
  BEGIN
    INSERT INTO mtl_txn_request_lines
                (
                attribute1
              , attribute10
              , attribute11
              , attribute12
              , attribute13
              , attribute14
              , attribute15
              , attribute2
              , attribute3
              , attribute4
              , attribute5
              , attribute6
              , attribute7
              , attribute8
              , attribute9
              , attribute_category
              , created_by
              , creation_date
              , date_required
              , from_locator_id
              , from_subinventory_code
              , from_subinventory_id
              , header_id
              , inventory_item_id
              , last_updated_by
              , last_update_date
              , last_update_login
              , line_id
              , line_number
              , line_status
              , lot_number
              , organization_id
              , program_application_id
              , program_id
              , program_update_date
              , project_id
              , quantity
              , quantity_delivered
              , quantity_detailed
              , reason_id
              , REFERENCE
              , reference_id
              , reference_type_code
              , request_id
              , revision
              , serial_number_end
              , serial_number_start
              , status_date
              , task_id
              , to_account_id
              , to_locator_id
              , to_subinventory_code
              , to_subinventory_id
              , transaction_header_id
              , uom_code
              , transaction_type_id
              , transaction_source_type_id
              , txn_source_id
              , txn_source_line_id
              , txn_source_line_detail_id
              , to_organization_id
              , primary_quantity
              , pick_strategy_id
              , put_away_strategy_id
              , unit_number
              , ship_to_location_id
              , from_cost_group_id
              , to_cost_group_id
              , lpn_id
              , to_lpn_id
              , inspection_status
              , pick_methodology_id
              , container_item_id
              , carton_grouping_id
              , wms_process_flag
              , pick_slip_number
              , pick_slip_date
              , ship_set_id
              , ship_model_id
              , model_quantity
              , required_quantity
--INVCONV BEGIN
              , secondary_quantity
              , secondary_quantity_delivered
              , secondary_quantity_detailed
              , secondary_uom_code
              , secondary_required_quantity
              , grade_code
--INVCONV END;
                )
         VALUES (
                p_trolin_rec.attribute1
              , p_trolin_rec.attribute10
              , p_trolin_rec.attribute11
              , p_trolin_rec.attribute12
              , p_trolin_rec.attribute13
              , p_trolin_rec.attribute14
              , p_trolin_rec.attribute15
              , p_trolin_rec.attribute2
              , p_trolin_rec.attribute3
              , p_trolin_rec.attribute4
              , p_trolin_rec.attribute5
              , p_trolin_rec.attribute6
              , p_trolin_rec.attribute7
              , p_trolin_rec.attribute8
              , p_trolin_rec.attribute9
              , p_trolin_rec.attribute_category
              , p_trolin_rec.created_by
              , p_trolin_rec.creation_date
              , p_trolin_rec.date_required
              , p_trolin_rec.from_locator_id
              , p_trolin_rec.from_subinventory_code
              , p_trolin_rec.from_subinventory_id
              , p_trolin_rec.header_id
              , p_trolin_rec.inventory_item_id
              , p_trolin_rec.last_updated_by
              , p_trolin_rec.last_update_date
              , p_trolin_rec.last_update_login
              , p_trolin_rec.line_id
              , p_trolin_rec.line_number
              , p_trolin_rec.line_status
              , p_trolin_rec.lot_number
              , p_trolin_rec.organization_id
              , p_trolin_rec.program_application_id
              , p_trolin_rec.program_id
              , p_trolin_rec.program_update_date
              , p_trolin_rec.project_id
              , p_trolin_rec.quantity
              , p_trolin_rec.quantity_delivered
              , p_trolin_rec.quantity_detailed
              , p_trolin_rec.reason_id
              , p_trolin_rec.REFERENCE
              , p_trolin_rec.reference_id
              , p_trolin_rec.reference_type_code
              , p_trolin_rec.request_id
              , p_trolin_rec.revision
              , p_trolin_rec.serial_number_end
              , p_trolin_rec.serial_number_start
              , p_trolin_rec.status_date
              , p_trolin_rec.task_id
              , p_trolin_rec.to_account_id
              , p_trolin_rec.to_locator_id
              , p_trolin_rec.to_subinventory_code
              , p_trolin_rec.to_subinventory_id
              , p_trolin_rec.transaction_header_id
              , p_trolin_rec.uom_code
              , p_trolin_rec.transaction_type_id
              , p_trolin_rec.transaction_source_type_id
              , p_trolin_rec.txn_source_id
              , p_trolin_rec.txn_source_line_id
              , p_trolin_rec.txn_source_line_detail_id
              , p_trolin_rec.to_organization_id
              , p_trolin_rec.primary_quantity
              , p_trolin_rec.pick_strategy_id
              , p_trolin_rec.put_away_strategy_id
              , p_trolin_rec.unit_number
              , p_trolin_rec.ship_to_location_id
              , p_trolin_rec.from_cost_group_id
              , p_trolin_rec.to_cost_group_id
              , p_trolin_rec.lpn_id
              , p_trolin_rec.to_lpn_id
              , p_trolin_rec.inspection_status
              , p_trolin_rec.pick_methodology_id
              , p_trolin_rec.container_item_id
              , p_trolin_rec.carton_grouping_id
              , p_trolin_rec.wms_process_flag
              , p_trolin_rec.pick_slip_number
              , p_trolin_rec.pick_slip_date
              , p_trolin_rec.ship_set_id
              , p_trolin_rec.ship_model_id
              , p_trolin_rec.model_quantity
              , p_trolin_rec.required_quantity
--INVCONV BEGIN
              , p_trolin_rec.secondary_quantity
              , p_trolin_rec.secondary_quantity_delivered
              , p_trolin_rec.secondary_quantity_detailed
              , p_trolin_rec.secondary_uom
              , p_trolin_rec.secondary_required_quantity
              , p_trolin_rec.grade_code
--INVCONV END;
                );
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Insert_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END insert_row;

  --  Procedure Delete_Row

  PROCEDURE delete_row(p_line_id IN NUMBER) IS
  BEGIN
    DELETE FROM mtl_txn_request_lines
          WHERE line_id = p_line_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END delete_row;

  --  Function Get_Lines

  FUNCTION get_lines(p_header_id IN NUMBER)
    RETURN inv_move_order_pub.trolin_tbl_type IS
  BEGIN
    RETURN query_rows(p_header_id => p_header_id);
  END get_lines;

  --  Function Query_Row

  FUNCTION query_row(p_line_id IN NUMBER)
    RETURN inv_move_order_pub.trolin_rec_type IS
  BEGIN
    /*    inv_debug.message('TRO: in query_row '||to_char(p_line_id)); */
    RETURN query_rows(p_line_id => p_line_id)(1);
  END query_row;

  --  Function Query_Rows

  --

  FUNCTION query_rows(p_line_id IN NUMBER := fnd_api.g_miss_num, p_header_id IN NUMBER := fnd_api.g_miss_num)
    RETURN inv_move_order_pub.trolin_tbl_type IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type;
    l_trolin_tbl inv_move_order_pub.trolin_tbl_type;

    --bug 2569864 - create separate cursors on header_id and line_Id
    CURSOR l_trolin_csr IS
      SELECT attribute1
           , attribute10
           , attribute11
           , attribute12
           , attribute13
           , attribute14
           , attribute15
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute_category
           , created_by
           , creation_date
           , date_required
           , from_locator_id
           , from_subinventory_code
           , from_subinventory_id
           , header_id
           , inventory_item_id
           , last_updated_by
           , last_update_date
           , last_update_login
           , line_id
           , line_number
           , line_status
           , lot_number
           , organization_id
           , program_application_id
           , program_id
           , program_update_date
           , project_id
           , quantity
           , quantity_delivered
           , quantity_detailed
           , reason_id
           , REFERENCE
           , reference_id
           , reference_type_code
           , request_id
           , revision
           , serial_number_end
           , serial_number_start
           , status_date
           , task_id
           , to_account_id
           , to_locator_id
           , to_subinventory_code
           , to_subinventory_id
           , transaction_header_id
           , uom_code
           , transaction_type_id
           , transaction_source_type_id
           , txn_source_id
           , txn_source_line_id
           , txn_source_line_detail_id
           , to_organization_id
           , primary_quantity
           , pick_strategy_id
           , put_away_strategy_id
           , unit_number
           , ship_to_location_id
           , from_cost_group_id
           , to_cost_group_id
           , lpn_id
           , to_lpn_id
           , inspection_status
           , pick_methodology_id
           , container_item_id
           , carton_grouping_id
           , wms_process_flag
           , pick_slip_number
           , pick_slip_date
           , ship_set_id
           , ship_model_id
           , model_quantity
           , required_quantity
--INVCONV BEGIN
           , secondary_quantity
           , secondary_quantity_delivered
           , secondary_quantity_detailed
           , secondary_uom_code
           , grade_code
           , secondary_required_quantity
--INVCONV END;
        FROM mtl_txn_request_lines
       WHERE line_id = p_line_id;

    CURSOR l_trolin_csr_header IS
      SELECT attribute1
           , attribute10
           , attribute11
           , attribute12
           , attribute13
           , attribute14
           , attribute15
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute_category
           , created_by
           , creation_date
           , date_required
           , from_locator_id
           , from_subinventory_code
           , from_subinventory_id
           , header_id
           , inventory_item_id
           , last_updated_by
           , last_update_date
           , last_update_login
           , line_id
           , line_number
           , line_status
           , lot_number
           , organization_id
           , program_application_id
           , program_id
           , program_update_date
           , project_id
           , quantity
           , quantity_delivered
           , quantity_detailed
           , reason_id
           , REFERENCE
           , reference_id
           , reference_type_code
           , request_id
           , revision
           , serial_number_end
           , serial_number_start
           , status_date
           , task_id
           , to_account_id
           , to_locator_id
           , to_subinventory_code
           , to_subinventory_id
           , transaction_header_id
           , uom_code
           , transaction_type_id
           , transaction_source_type_id
           , txn_source_id
           , txn_source_line_id
           , txn_source_line_detail_id
           , to_organization_id
           , primary_quantity
           , pick_strategy_id
           , put_away_strategy_id
           , unit_number
           , ship_to_location_id
           , from_cost_group_id
           , to_cost_group_id
           , lpn_id
           , to_lpn_id
           , inspection_status
           , pick_methodology_id
           , container_item_id
           , carton_grouping_id
           , wms_process_flag
           , pick_slip_number
           , pick_slip_date
           , ship_set_id
           , ship_model_id
           , model_quantity
           , required_quantity
--INVCONV BEGIN
           , secondary_quantity
           , secondary_quantity_delivered
           , secondary_quantity_detailed
           , secondary_uom_code
           , grade_code
           , secondary_required_quantity
--INVCONV END;
        FROM mtl_txn_request_lines
       WHERE header_id = p_header_id;
  BEGIN
    /*inv_debug.message('TRO: line_id '||to_char(p_line_id)||' header_id '||to_char(p_header_id)); */

    IF  (p_line_id IS NOT NULL
         AND p_line_id <> fnd_api.g_miss_num
        )
        AND (p_header_id IS NOT NULL
             AND p_header_id <> fnd_api.g_miss_num
            ) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Query Rows', 'Keys are mutually exclusive: line_id = ' || p_line_id || ', header_id = ' || p_header_id);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (p_line_id IS NOT NULL
        AND p_line_id <> fnd_api.g_miss_num
       ) THEN
      --  Loop over fetched records

      FOR l_implicit_rec IN l_trolin_csr LOOP
        l_trolin_rec.attribute1                  := l_implicit_rec.attribute1;
        l_trolin_rec.attribute10                 := l_implicit_rec.attribute10;
        l_trolin_rec.attribute11                 := l_implicit_rec.attribute11;
        l_trolin_rec.attribute12                 := l_implicit_rec.attribute12;
        l_trolin_rec.attribute13                 := l_implicit_rec.attribute13;
        l_trolin_rec.attribute14                 := l_implicit_rec.attribute14;
        l_trolin_rec.attribute15                 := l_implicit_rec.attribute15;
        l_trolin_rec.attribute2                  := l_implicit_rec.attribute2;
        l_trolin_rec.attribute3                  := l_implicit_rec.attribute3;
        l_trolin_rec.attribute4                  := l_implicit_rec.attribute4;
        l_trolin_rec.attribute5                  := l_implicit_rec.attribute5;
        l_trolin_rec.attribute6                  := l_implicit_rec.attribute6;
        l_trolin_rec.attribute7                  := l_implicit_rec.attribute7;
        l_trolin_rec.attribute8                  := l_implicit_rec.attribute8;
        l_trolin_rec.attribute9                  := l_implicit_rec.attribute9;
        l_trolin_rec.attribute_category          := l_implicit_rec.attribute_category;
        l_trolin_rec.created_by                  := l_implicit_rec.created_by;
        l_trolin_rec.creation_date               := l_implicit_rec.creation_date;
        l_trolin_rec.date_required               := l_implicit_rec.date_required;
        l_trolin_rec.from_locator_id             := l_implicit_rec.from_locator_id;
        l_trolin_rec.from_subinventory_code      := l_implicit_rec.from_subinventory_code;
        l_trolin_rec.from_subinventory_id        := l_implicit_rec.from_subinventory_id;
        l_trolin_rec.header_id                   := l_implicit_rec.header_id;
        l_trolin_rec.inventory_item_id           := l_implicit_rec.inventory_item_id;
        l_trolin_rec.last_updated_by             := l_implicit_rec.last_updated_by;
        l_trolin_rec.last_update_date            := l_implicit_rec.last_update_date;
        l_trolin_rec.last_update_login           := l_implicit_rec.last_update_login;
        l_trolin_rec.line_id                     := l_implicit_rec.line_id;
        l_trolin_rec.line_number                 := l_implicit_rec.line_number;
        l_trolin_rec.line_status                 := l_implicit_rec.line_status;
        l_trolin_rec.lot_number                  := l_implicit_rec.lot_number;
        l_trolin_rec.organization_id             := l_implicit_rec.organization_id;
        l_trolin_rec.program_application_id      := l_implicit_rec.program_application_id;
        l_trolin_rec.program_id                  := l_implicit_rec.program_id;
        l_trolin_rec.program_update_date         := l_implicit_rec.program_update_date;
        l_trolin_rec.project_id                  := l_implicit_rec.project_id;
        l_trolin_rec.quantity                    := l_implicit_rec.quantity;
        l_trolin_rec.quantity_delivered          := l_implicit_rec.quantity_delivered;
        l_trolin_rec.quantity_detailed           := l_implicit_rec.quantity_detailed;
        l_trolin_rec.reason_id                   := l_implicit_rec.reason_id;
        l_trolin_rec.REFERENCE                   := l_implicit_rec.REFERENCE;
        l_trolin_rec.reference_id                := l_implicit_rec.reference_id;
        l_trolin_rec.reference_type_code         := l_implicit_rec.reference_type_code;
        l_trolin_rec.request_id                  := l_implicit_rec.request_id;
        l_trolin_rec.revision                    := l_implicit_rec.revision;
        l_trolin_rec.serial_number_end           := l_implicit_rec.serial_number_end;
        l_trolin_rec.serial_number_start         := l_implicit_rec.serial_number_start;
        l_trolin_rec.status_date                 := l_implicit_rec.status_date;
        l_trolin_rec.task_id                     := l_implicit_rec.task_id;
        l_trolin_rec.to_account_id               := l_implicit_rec.to_account_id;
        l_trolin_rec.to_locator_id               := l_implicit_rec.to_locator_id;
        l_trolin_rec.to_subinventory_code        := l_implicit_rec.to_subinventory_code;
        l_trolin_rec.to_subinventory_id          := l_implicit_rec.to_subinventory_id;
        l_trolin_rec.transaction_header_id       := l_implicit_rec.transaction_header_id;
        l_trolin_rec.uom_code                    := l_implicit_rec.uom_code;
        l_trolin_rec.transaction_type_id         := l_implicit_rec.transaction_type_id;
        l_trolin_rec.transaction_source_type_id  := l_implicit_rec.transaction_source_type_id;
        l_trolin_rec.txn_source_id               := l_implicit_rec.txn_source_id;
        l_trolin_rec.txn_source_line_id          := l_implicit_rec.txn_source_line_id;
        l_trolin_rec.txn_source_line_detail_id   := l_implicit_rec.txn_source_line_detail_id;
        l_trolin_rec.to_organization_id          := l_implicit_rec.to_organization_id;
        l_trolin_rec.primary_quantity            := l_implicit_rec.primary_quantity;
        l_trolin_rec.pick_strategy_id            := l_implicit_rec.pick_strategy_id;
        l_trolin_rec.put_away_strategy_id        := l_implicit_rec.put_away_strategy_id;
        l_trolin_rec.unit_number                 := l_implicit_rec.unit_number;
        l_trolin_rec.ship_to_location_id         := l_implicit_rec.ship_to_location_id;
        l_trolin_rec.from_cost_group_id          := l_implicit_rec.from_cost_group_id;
        l_trolin_rec.to_cost_group_id            := l_implicit_rec.to_cost_group_id;
        l_trolin_rec.lpn_id                      := l_implicit_rec.lpn_id;
        l_trolin_rec.to_lpn_id                   := l_implicit_rec.to_lpn_id;
        l_trolin_rec.inspection_status           := l_implicit_rec.inspection_status;
        l_trolin_rec.pick_methodology_id         := l_implicit_rec.pick_methodology_id;
        l_trolin_rec.container_item_id           := l_implicit_rec.container_item_id;
        l_trolin_rec.carton_grouping_id          := l_implicit_rec.carton_grouping_id;
        l_trolin_rec.wms_process_flag            := l_implicit_rec.wms_process_flag;
        l_trolin_rec.pick_slip_number            := l_implicit_rec.pick_slip_number;
        l_trolin_rec.pick_slip_date              := l_implicit_rec.pick_slip_date;
        l_trolin_rec.ship_set_id                 := l_implicit_rec.ship_set_id;
        l_trolin_rec.ship_model_id               := l_implicit_rec.ship_model_id;
        l_trolin_rec.model_quantity              := l_implicit_rec.model_quantity;
        l_trolin_rec.required_quantity           := l_implicit_rec.required_quantity;
--INVCONV BEGIN
        l_trolin_rec.secondary_quantity          := l_implicit_rec.secondary_quantity;
        l_trolin_rec.secondary_quantity_delivered := l_implicit_rec.secondary_quantity_delivered;
        l_trolin_rec.secondary_quantity_detailed := l_implicit_rec.secondary_quantity_detailed;
        l_trolin_rec.secondary_uom               := l_implicit_rec.secondary_uom_code;
        l_trolin_rec.grade_code                  := l_implicit_rec.grade_code;
        l_trolin_rec.secondary_required_quantity := l_implicit_rec.secondary_required_quantity;
--INVCONV END;

        l_trolin_tbl(l_trolin_tbl.COUNT + 1)     := l_trolin_rec;
      END LOOP;
    ELSE
      FOR l_implicit_rec IN l_trolin_csr_header LOOP
        l_trolin_rec.attribute1                  := l_implicit_rec.attribute1;
        l_trolin_rec.attribute10                 := l_implicit_rec.attribute10;
        l_trolin_rec.attribute11                 := l_implicit_rec.attribute11;
        l_trolin_rec.attribute12                 := l_implicit_rec.attribute12;
        l_trolin_rec.attribute13                 := l_implicit_rec.attribute13;
        l_trolin_rec.attribute14                 := l_implicit_rec.attribute14;
        l_trolin_rec.attribute15                 := l_implicit_rec.attribute15;
        l_trolin_rec.attribute2                  := l_implicit_rec.attribute2;
        l_trolin_rec.attribute3                  := l_implicit_rec.attribute3;
        l_trolin_rec.attribute4                  := l_implicit_rec.attribute4;
        l_trolin_rec.attribute5                  := l_implicit_rec.attribute5;
        l_trolin_rec.attribute6                  := l_implicit_rec.attribute6;
        l_trolin_rec.attribute7                  := l_implicit_rec.attribute7;
        l_trolin_rec.attribute8                  := l_implicit_rec.attribute8;
        l_trolin_rec.attribute9                  := l_implicit_rec.attribute9;
        l_trolin_rec.attribute_category          := l_implicit_rec.attribute_category;
        l_trolin_rec.created_by                  := l_implicit_rec.created_by;
        l_trolin_rec.creation_date               := l_implicit_rec.creation_date;
        l_trolin_rec.date_required               := l_implicit_rec.date_required;
        l_trolin_rec.from_locator_id             := l_implicit_rec.from_locator_id;
        l_trolin_rec.from_subinventory_code      := l_implicit_rec.from_subinventory_code;
        l_trolin_rec.from_subinventory_id        := l_implicit_rec.from_subinventory_id;
        l_trolin_rec.header_id                   := l_implicit_rec.header_id;
        l_trolin_rec.inventory_item_id           := l_implicit_rec.inventory_item_id;
        l_trolin_rec.last_updated_by             := l_implicit_rec.last_updated_by;
        l_trolin_rec.last_update_date            := l_implicit_rec.last_update_date;
        l_trolin_rec.last_update_login           := l_implicit_rec.last_update_login;
        l_trolin_rec.line_id                     := l_implicit_rec.line_id;
        l_trolin_rec.line_number                 := l_implicit_rec.line_number;
        l_trolin_rec.line_status                 := l_implicit_rec.line_status;
        l_trolin_rec.lot_number                  := l_implicit_rec.lot_number;
        l_trolin_rec.organization_id             := l_implicit_rec.organization_id;
        l_trolin_rec.program_application_id      := l_implicit_rec.program_application_id;
        l_trolin_rec.program_id                  := l_implicit_rec.program_id;
        l_trolin_rec.program_update_date         := l_implicit_rec.program_update_date;
        l_trolin_rec.project_id                  := l_implicit_rec.project_id;
        l_trolin_rec.quantity                    := l_implicit_rec.quantity;
        l_trolin_rec.quantity_delivered          := l_implicit_rec.quantity_delivered;
        l_trolin_rec.quantity_detailed           := l_implicit_rec.quantity_detailed;
        l_trolin_rec.reason_id                   := l_implicit_rec.reason_id;
        l_trolin_rec.REFERENCE                   := l_implicit_rec.REFERENCE;
        l_trolin_rec.reference_id                := l_implicit_rec.reference_id;
        l_trolin_rec.reference_type_code         := l_implicit_rec.reference_type_code;
        l_trolin_rec.request_id                  := l_implicit_rec.request_id;
        l_trolin_rec.revision                    := l_implicit_rec.revision;
        l_trolin_rec.serial_number_end           := l_implicit_rec.serial_number_end;
        l_trolin_rec.serial_number_start         := l_implicit_rec.serial_number_start;
        l_trolin_rec.status_date                 := l_implicit_rec.status_date;
        l_trolin_rec.task_id                     := l_implicit_rec.task_id;
        l_trolin_rec.to_account_id               := l_implicit_rec.to_account_id;
        l_trolin_rec.to_locator_id               := l_implicit_rec.to_locator_id;
        l_trolin_rec.to_subinventory_code        := l_implicit_rec.to_subinventory_code;
        l_trolin_rec.to_subinventory_id          := l_implicit_rec.to_subinventory_id;
        l_trolin_rec.transaction_header_id       := l_implicit_rec.transaction_header_id;
        l_trolin_rec.uom_code                    := l_implicit_rec.uom_code;
        l_trolin_rec.transaction_type_id         := l_implicit_rec.transaction_type_id;
        l_trolin_rec.transaction_source_type_id  := l_implicit_rec.transaction_source_type_id;
        l_trolin_rec.txn_source_id               := l_implicit_rec.txn_source_id;
        l_trolin_rec.txn_source_line_id          := l_implicit_rec.txn_source_line_id;
        l_trolin_rec.txn_source_line_detail_id   := l_implicit_rec.txn_source_line_detail_id;
        l_trolin_rec.to_organization_id          := l_implicit_rec.to_organization_id;
        l_trolin_rec.primary_quantity            := l_implicit_rec.primary_quantity;
        l_trolin_rec.pick_strategy_id            := l_implicit_rec.pick_strategy_id;
        l_trolin_rec.put_away_strategy_id        := l_implicit_rec.put_away_strategy_id;
        l_trolin_rec.unit_number                 := l_implicit_rec.unit_number;
        l_trolin_rec.ship_to_location_id         := l_implicit_rec.ship_to_location_id;
        l_trolin_rec.from_cost_group_id          := l_implicit_rec.from_cost_group_id;
        l_trolin_rec.to_cost_group_id            := l_implicit_rec.to_cost_group_id;
        l_trolin_rec.lpn_id                      := l_implicit_rec.lpn_id;
        l_trolin_rec.to_lpn_id                   := l_implicit_rec.to_lpn_id;
        l_trolin_rec.inspection_status           := l_implicit_rec.inspection_status;
        l_trolin_rec.pick_methodology_id         := l_implicit_rec.pick_methodology_id;
        l_trolin_rec.container_item_id           := l_implicit_rec.container_item_id;
        l_trolin_rec.carton_grouping_id          := l_implicit_rec.carton_grouping_id;
        l_trolin_rec.wms_process_flag            := l_implicit_rec.wms_process_flag;
        l_trolin_rec.pick_slip_number            := l_implicit_rec.pick_slip_number;
        l_trolin_rec.pick_slip_date              := l_implicit_rec.pick_slip_date;
        l_trolin_rec.ship_set_id                 := l_implicit_rec.ship_set_id;
        l_trolin_rec.ship_model_id               := l_implicit_rec.ship_model_id;
        l_trolin_rec.model_quantity              := l_implicit_rec.model_quantity;
        l_trolin_rec.required_quantity           := l_implicit_rec.required_quantity;
--INVCONV BEGIN
        l_trolin_rec.secondary_quantity          := l_implicit_rec.secondary_quantity;
        l_trolin_rec.secondary_quantity_delivered := l_implicit_rec.secondary_quantity_delivered;
        l_trolin_rec.secondary_quantity_detailed := l_implicit_rec.secondary_quantity_detailed;
        l_trolin_rec.secondary_uom               := l_implicit_rec.secondary_uom_code;
        l_trolin_rec.grade_code                  := l_implicit_rec.grade_code;
        l_trolin_rec.secondary_required_quantity := l_implicit_rec.secondary_required_quantity;
--INVCONV END;
        l_trolin_tbl(l_trolin_tbl.COUNT + 1)     := l_trolin_rec;
      END LOOP;
    END IF;

    --  PK sent and no rows found

    IF  (p_line_id IS NOT NULL
         AND p_line_id <> fnd_api.g_miss_num
        )
        AND (l_trolin_tbl.COUNT = 0) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    --  Return fetched table

    RETURN l_trolin_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Query_Rows');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END query_rows;

  --  Procedure       lock_Row
  --

  PROCEDURE lock_row(x_return_status OUT NOCOPY VARCHAR2, p_trolin_rec IN inv_move_order_pub.trolin_rec_type, x_trolin_rec IN OUT NOCOPY inv_move_order_pub.trolin_rec_type) IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type;
  BEGIN
    SELECT     attribute1
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute_category
             , created_by
             , creation_date
             , date_required
             , from_locator_id
             , from_subinventory_code
             , from_subinventory_id
             , header_id
             , inventory_item_id
             , last_updated_by
             , last_update_date
             , last_update_login
             , line_id
             , line_number
             , line_status
             , lot_number
             , organization_id
             , program_application_id
             , program_id
             , program_update_date
             , project_id
             , quantity
             , quantity_delivered
             , quantity_detailed
             , reason_id
             , REFERENCE
             , reference_id
             , reference_type_code
             , request_id
             , revision
             , serial_number_end
             , serial_number_start
             , status_date
             , task_id
             , to_account_id
             , to_locator_id
             , to_subinventory_code
             , to_subinventory_id
             , transaction_header_id
             , uom_code
             , transaction_type_id
             , transaction_source_type_id
             , txn_source_id
             , txn_source_line_id
             , txn_source_line_detail_id
             , to_organization_id
             , primary_quantity
             , pick_strategy_id
             , put_away_strategy_id
             , unit_number
             , ship_to_location_id
             , from_cost_group_id
             , to_cost_group_id
             , lpn_id
             , to_lpn_id
             , inspection_status
             , pick_methodology_id
             , container_item_id
             , carton_grouping_id
             , wms_process_flag
             , pick_slip_number
             , pick_slip_date
             , ship_set_id
             , ship_model_id
             , model_quantity
             , required_quantity
--INVCONV BEGIN
              , secondary_quantity
              , secondary_quantity_delivered
              , secondary_quantity_detailed
              , uom_code
              , grade_code
              , secondary_required_quantity
--INVCONV END
          INTO l_trolin_rec.attribute1
             , l_trolin_rec.attribute10
             , l_trolin_rec.attribute11
             , l_trolin_rec.attribute12
             , l_trolin_rec.attribute13
             , l_trolin_rec.attribute14
             , l_trolin_rec.attribute15
             , l_trolin_rec.attribute2
             , l_trolin_rec.attribute3
             , l_trolin_rec.attribute4
             , l_trolin_rec.attribute5
             , l_trolin_rec.attribute6
             , l_trolin_rec.attribute7
             , l_trolin_rec.attribute8
             , l_trolin_rec.attribute9
             , l_trolin_rec.attribute_category
             , l_trolin_rec.created_by
             , l_trolin_rec.creation_date
             , l_trolin_rec.date_required
             , l_trolin_rec.from_locator_id
             , l_trolin_rec.from_subinventory_code
             , l_trolin_rec.from_subinventory_id
             , l_trolin_rec.header_id
             , l_trolin_rec.inventory_item_id
             , l_trolin_rec.last_updated_by
             , l_trolin_rec.last_update_date
             , l_trolin_rec.last_update_login
             , l_trolin_rec.line_id
             , l_trolin_rec.line_number
             , l_trolin_rec.line_status
             , l_trolin_rec.lot_number
             , l_trolin_rec.organization_id
             , l_trolin_rec.program_application_id
             , l_trolin_rec.program_id
             , l_trolin_rec.program_update_date
             , l_trolin_rec.project_id
             , l_trolin_rec.quantity
             , l_trolin_rec.quantity_delivered
             , l_trolin_rec.quantity_detailed
             , l_trolin_rec.reason_id
             , l_trolin_rec.REFERENCE
             , l_trolin_rec.reference_id
             , l_trolin_rec.reference_type_code
             , l_trolin_rec.request_id
             , l_trolin_rec.revision
             , l_trolin_rec.serial_number_end
             , l_trolin_rec.serial_number_start
             , l_trolin_rec.status_date
             , l_trolin_rec.task_id
             , l_trolin_rec.to_account_id
             , l_trolin_rec.to_locator_id
             , l_trolin_rec.to_subinventory_code
             , l_trolin_rec.to_subinventory_id
             , l_trolin_rec.transaction_header_id
             , l_trolin_rec.uom_code
             , l_trolin_rec.transaction_type_id
             , l_trolin_rec.transaction_source_type_id
             , l_trolin_rec.txn_source_id
             , l_trolin_rec.txn_source_line_id
             , l_trolin_rec.txn_source_line_detail_id
             , l_trolin_rec.to_organization_id
             , l_trolin_rec.primary_quantity
             , l_trolin_rec.pick_strategy_id
             , l_trolin_rec.put_away_strategy_id
             , l_trolin_rec.unit_number
             , l_trolin_rec.ship_to_location_id
             , l_trolin_rec.from_cost_group_id
             , l_trolin_rec.to_cost_group_id
             , l_trolin_rec.lpn_id
             , l_trolin_rec.to_lpn_id
             , l_trolin_rec.inspection_status
             , l_trolin_rec.pick_methodology_id
             , l_trolin_rec.container_item_id
             , l_trolin_rec.carton_grouping_id
             , l_trolin_rec.wms_process_flag
             , l_trolin_rec.pick_slip_number
             , l_trolin_rec.pick_slip_date
             , l_trolin_rec.ship_set_id
             , l_trolin_rec.ship_model_id
             , l_trolin_rec.model_quantity
             , l_trolin_rec.required_quantity
--INVCONV BEGIN
              , l_trolin_rec.secondary_quantity
              , l_trolin_rec.secondary_quantity_delivered
              , l_trolin_rec.secondary_quantity_detailed
              , l_trolin_rec.uom_code
              , l_trolin_rec.grade_code
              , l_trolin_rec.secondary_required_quantity
--INVCONV END
          FROM mtl_txn_request_lines
         WHERE line_id = p_trolin_rec.line_id
    FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  inv_globals.equal(p_trolin_rec.attribute1, l_trolin_rec.attribute1)
        AND inv_globals.equal(p_trolin_rec.attribute10, l_trolin_rec.attribute10)
        AND inv_globals.equal(p_trolin_rec.attribute11, l_trolin_rec.attribute11)
        AND inv_globals.equal(p_trolin_rec.attribute12, l_trolin_rec.attribute12)
        AND inv_globals.equal(p_trolin_rec.attribute13, l_trolin_rec.attribute13)
        AND inv_globals.equal(p_trolin_rec.attribute14, l_trolin_rec.attribute14)
        AND inv_globals.equal(p_trolin_rec.attribute15, l_trolin_rec.attribute15)
        AND inv_globals.equal(p_trolin_rec.attribute2, l_trolin_rec.attribute2)
        AND inv_globals.equal(p_trolin_rec.attribute3, l_trolin_rec.attribute3)
        AND inv_globals.equal(p_trolin_rec.attribute4, l_trolin_rec.attribute4)
        AND inv_globals.equal(p_trolin_rec.attribute5, l_trolin_rec.attribute5)
        AND inv_globals.equal(p_trolin_rec.attribute6, l_trolin_rec.attribute6)
        AND inv_globals.equal(p_trolin_rec.attribute7, l_trolin_rec.attribute7)
        AND inv_globals.equal(p_trolin_rec.attribute8, l_trolin_rec.attribute8)
        AND inv_globals.equal(p_trolin_rec.attribute9, l_trolin_rec.attribute9)
        AND inv_globals.equal(p_trolin_rec.attribute_category, l_trolin_rec.attribute_category)
        AND (inv_globals.equal(p_trolin_rec.created_by, l_trolin_rec.created_by)
             OR (p_trolin_rec.created_by = fnd_api.g_miss_num
                 AND l_trolin_rec.created_by IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.creation_date, l_trolin_rec.creation_date)
             OR (p_trolin_rec.creation_date = fnd_api.g_miss_date
                 AND l_trolin_rec.creation_date IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.date_required, l_trolin_rec.date_required)
             OR (p_trolin_rec.date_required = fnd_api.g_miss_date
                 AND l_trolin_rec.date_required IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.from_locator_id, l_trolin_rec.from_locator_id)
             OR (p_trolin_rec.from_locator_id = fnd_api.g_miss_num
                 AND l_trolin_rec.from_locator_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.from_subinventory_code, l_trolin_rec.from_subinventory_code)
             OR (p_trolin_rec.from_subinventory_code = fnd_api.g_miss_char
                 AND l_trolin_rec.from_subinventory_code IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.from_subinventory_id, l_trolin_rec.from_subinventory_id)
             OR (p_trolin_rec.from_subinventory_id = fnd_api.g_miss_num
                 AND l_trolin_rec.from_subinventory_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.header_id, l_trolin_rec.header_id)
             OR (p_trolin_rec.header_id = fnd_api.g_miss_num
                 AND l_trolin_rec.header_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.inventory_item_id, l_trolin_rec.inventory_item_id)
             OR (p_trolin_rec.inventory_item_id = fnd_api.g_miss_num
                 AND l_trolin_rec.inventory_item_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.last_updated_by, l_trolin_rec.last_updated_by)
             OR (p_trolin_rec.last_updated_by = fnd_api.g_miss_num
                 AND l_trolin_rec.last_updated_by IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.last_update_date, l_trolin_rec.last_update_date)
             OR (p_trolin_rec.last_update_date = fnd_api.g_miss_date
                 AND l_trolin_rec.last_update_date IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.last_update_login, l_trolin_rec.last_update_login)
             OR (p_trolin_rec.last_update_login = fnd_api.g_miss_num
                 AND l_trolin_rec.last_update_login IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.line_id, l_trolin_rec.line_id)
             OR (p_trolin_rec.line_id = fnd_api.g_miss_num
                 AND l_trolin_rec.line_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.line_number, l_trolin_rec.line_number)
             OR (p_trolin_rec.line_number = fnd_api.g_miss_num
                 AND l_trolin_rec.line_number IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.line_status, l_trolin_rec.line_status)
             OR (p_trolin_rec.line_status = fnd_api.g_miss_num
                 AND l_trolin_rec.line_status IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.lot_number, l_trolin_rec.lot_number)
             OR (p_trolin_rec.lot_number = fnd_api.g_miss_char
                 AND l_trolin_rec.lot_number IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.organization_id, l_trolin_rec.organization_id)
             OR (p_trolin_rec.organization_id = fnd_api.g_miss_num
                 AND l_trolin_rec.organization_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.program_application_id, l_trolin_rec.program_application_id)
             OR (p_trolin_rec.program_application_id = fnd_api.g_miss_num
                 AND l_trolin_rec.program_application_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.program_id, l_trolin_rec.program_id)
             OR (p_trolin_rec.program_id = fnd_api.g_miss_num
                 AND l_trolin_rec.program_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.program_update_date, l_trolin_rec.program_update_date)
             OR (p_trolin_rec.program_update_date = fnd_api.g_miss_date
                 AND l_trolin_rec.program_update_date IS NOT NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.project_id, l_trolin_rec.project_id)
             OR (p_trolin_rec.project_id = fnd_api.g_miss_num
                 AND l_trolin_rec.project_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.quantity, l_trolin_rec.quantity)
             OR (p_trolin_rec.quantity = fnd_api.g_miss_num
                 AND l_trolin_rec.quantity IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.quantity_delivered, l_trolin_rec.quantity_delivered)
             OR (p_trolin_rec.quantity_delivered = fnd_api.g_miss_num
                 AND l_trolin_rec.quantity_delivered IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.quantity_detailed, l_trolin_rec.quantity_detailed)
             OR (p_trolin_rec.quantity_detailed = fnd_api.g_miss_num
                 AND l_trolin_rec.quantity_detailed IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.reason_id, l_trolin_rec.reason_id)
             OR (p_trolin_rec.reason_id = fnd_api.g_miss_num
                 AND l_trolin_rec.reason_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.REFERENCE, l_trolin_rec.REFERENCE)
             OR (p_trolin_rec.REFERENCE = fnd_api.g_miss_char
                 AND l_trolin_rec.REFERENCE IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.reference_id, l_trolin_rec.reference_id)
             OR (p_trolin_rec.reference_id = fnd_api.g_miss_num
                 AND l_trolin_rec.reference_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.reference_type_code, l_trolin_rec.reference_type_code)
             OR (l_trolin_rec.reference_type_code = fnd_api.g_miss_num
                 AND l_trolin_rec.reference_type_code IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.request_id, l_trolin_rec.request_id)
             OR (p_trolin_rec.request_id = fnd_api.g_miss_num
                 AND l_trolin_rec.request_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.revision, l_trolin_rec.revision)
             OR (p_trolin_rec.revision = fnd_api.g_miss_char
                 AND l_trolin_rec.revision IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.serial_number_end, l_trolin_rec.serial_number_end)
             OR (p_trolin_rec.serial_number_end = fnd_api.g_miss_char
                 AND l_trolin_rec.serial_number_end IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.serial_number_start, l_trolin_rec.serial_number_start)
             OR (p_trolin_rec.serial_number_start = fnd_api.g_miss_char
                 AND l_trolin_rec.serial_number_start IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.status_date, l_trolin_rec.status_date)
             OR (p_trolin_rec.status_date = fnd_api.g_miss_date
                 AND l_trolin_rec.status_date IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.task_id, l_trolin_rec.task_id)
             OR (p_trolin_rec.task_id = fnd_api.g_miss_num
                 AND l_trolin_rec.task_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_account_id, l_trolin_rec.to_account_id)
             OR (p_trolin_rec.to_account_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_account_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_locator_id, l_trolin_rec.to_locator_id)
             OR (p_trolin_rec.to_locator_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_locator_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_subinventory_code, l_trolin_rec.to_subinventory_code)
             OR (p_trolin_rec.to_subinventory_code = fnd_api.g_miss_char
                 AND l_trolin_rec.to_subinventory_code IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_subinventory_id, l_trolin_rec.to_subinventory_id)
             OR (p_trolin_rec.to_subinventory_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_subinventory_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.transaction_header_id, l_trolin_rec.transaction_header_id)
             OR (p_trolin_rec.transaction_header_id = fnd_api.g_miss_num
                 AND l_trolin_rec.transaction_header_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.uom_code, l_trolin_rec.uom_code)
             OR (p_trolin_rec.uom_code = fnd_api.g_miss_char
                 AND p_trolin_rec.uom_code IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.transaction_type_id, l_trolin_rec.transaction_type_id)
             OR (p_trolin_rec.transaction_type_id = fnd_api.g_miss_num
                 AND l_trolin_rec.transaction_type_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.transaction_source_type_id, l_trolin_rec.transaction_source_type_id)
             OR (p_trolin_rec.transaction_source_type_id = fnd_api.g_miss_num
                 AND l_trolin_rec.transaction_source_type_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.txn_source_id, l_trolin_rec.txn_source_id)
             OR (p_trolin_rec.txn_source_id = fnd_api.g_miss_num
                 AND l_trolin_rec.txn_source_id IS NULL
                )
            )
        AND inv_globals.equal(p_trolin_rec.txn_source_line_id, l_trolin_rec.txn_source_line_id)
        AND (inv_globals.equal(p_trolin_rec.txn_source_line_detail_id, l_trolin_rec.txn_source_line_detail_id)
             OR (p_trolin_rec.txn_source_line_detail_id = fnd_api.g_miss_num
                 AND l_trolin_rec.txn_source_line_detail_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.primary_quantity, l_trolin_rec.primary_quantity)
             OR (p_trolin_rec.primary_quantity = fnd_api.g_miss_num
                 AND l_trolin_rec.primary_quantity IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_organization_id, l_trolin_rec.to_organization_id)
             OR (p_trolin_rec.to_organization_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_organization_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.pick_strategy_id, l_trolin_rec.pick_strategy_id)
             OR (p_trolin_rec.pick_strategy_id = fnd_api.g_miss_num
                 AND l_trolin_rec.pick_strategy_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.put_away_strategy_id, l_trolin_rec.put_away_strategy_id)
             OR (p_trolin_rec.put_away_strategy_id = fnd_api.g_miss_num
                 AND l_trolin_rec.put_away_strategy_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.unit_number, l_trolin_rec.unit_number)
             OR (p_trolin_rec.unit_number = fnd_api.g_miss_char
                 AND l_trolin_rec.unit_number IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.ship_to_location_id, l_trolin_rec.ship_to_location_id)
             OR (p_trolin_rec.ship_to_location_id = fnd_api.g_miss_num
                 AND l_trolin_rec.ship_to_location_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.from_cost_group_id, l_trolin_rec.from_cost_group_id)
             OR (p_trolin_rec.from_cost_group_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_cost_group_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_cost_group_id, l_trolin_rec.to_cost_group_id)
             OR (p_trolin_rec.to_cost_group_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_cost_group_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.lpn_id, l_trolin_rec.lpn_id)
             OR (p_trolin_rec.lpn_id = fnd_api.g_miss_num
                 AND l_trolin_rec.lpn_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.to_lpn_id, l_trolin_rec.to_lpn_id)
             OR (p_trolin_rec.to_lpn_id = fnd_api.g_miss_num
                 AND l_trolin_rec.to_lpn_id IS NULL
                )
            )
        AND inv_globals.equal(p_trolin_rec.inspection_status, l_trolin_rec.inspection_status)
        AND (inv_globals.equal(p_trolin_rec.pick_methodology_id, l_trolin_rec.pick_methodology_id)
             OR (p_trolin_rec.pick_methodology_id = fnd_api.g_miss_num
                 AND l_trolin_rec.pick_methodology_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.container_item_id, l_trolin_rec.container_item_id)
             OR (p_trolin_rec.container_item_id = fnd_api.g_miss_num
                 AND l_trolin_rec.container_item_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.carton_grouping_id, l_trolin_rec.carton_grouping_id)
             OR (p_trolin_rec.carton_grouping_id = fnd_api.g_miss_num
                 AND l_trolin_rec.carton_grouping_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.wms_process_flag, l_trolin_rec.wms_process_flag)
             OR (p_trolin_rec.wms_process_flag = fnd_api.g_miss_char
                 AND l_trolin_rec.wms_process_flag IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.pick_slip_number, l_trolin_rec.pick_slip_number)
             OR (p_trolin_rec.pick_slip_number = fnd_api.g_miss_num
                 AND l_trolin_rec.pick_slip_number IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.pick_slip_date, l_trolin_rec.pick_slip_date)
             OR (p_trolin_rec.pick_slip_date = fnd_api.g_miss_date
                 AND l_trolin_rec.pick_slip_date IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.ship_set_id, l_trolin_rec.ship_set_id)
             OR (p_trolin_rec.ship_set_id = fnd_api.g_miss_num
                 AND l_trolin_rec.ship_set_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.ship_model_id, l_trolin_rec.ship_model_id)
             OR (p_trolin_rec.ship_model_id = fnd_api.g_miss_num
                 AND l_trolin_rec.ship_model_id IS NULL
                )
            )
        AND (inv_globals.equal(p_trolin_rec.model_quantity, l_trolin_rec.model_quantity)
             OR (p_trolin_rec.model_quantity = fnd_api.g_miss_num
                 AND l_trolin_rec.model_quantity IS NULL
                )
            ) THEN
      --  Row has not changed. Set out parameter.

      x_trolin_rec                := l_trolin_rec;
      --  Set return status

      x_return_status             := fnd_api.g_ret_sts_success;
      x_trolin_rec.return_status  := fnd_api.g_ret_sts_success;
    ELSE
      --  Row has changed by another user.

      x_return_status             := fnd_api.g_ret_sts_error;
      x_trolin_rec.return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_CHANGED');
        fnd_msg_pub.ADD;
      END IF;
    END IF;
  --Line2086
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status             := fnd_api.g_ret_sts_error;
      x_trolin_rec.return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_DELETED');
        fnd_msg_pub.ADD;
      END IF;
    WHEN app_exceptions.record_lock_exception THEN
      x_return_status             := fnd_api.g_ret_sts_error;
      x_trolin_rec.return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_ALREADY_LOCKED');
        fnd_msg_pub.ADD;
      END IF;
    WHEN OTHERS THEN
      x_return_status             := fnd_api.g_ret_sts_unexp_error;
      x_trolin_rec.return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Lock_Row');
      END IF;
  END lock_row;

  --  Function Get_Values

  FUNCTION get_values(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_old_trolin_rec IN inv_move_order_pub.trolin_rec_type := inv_move_order_pub.g_miss_trolin_rec)
    RETURN inv_move_order_pub.trolin_val_rec_type IS
    l_trolin_val_rec inv_move_order_pub.trolin_val_rec_type;
  BEGIN
    -- Line2147
    IF  p_trolin_rec.from_locator_id IS NOT NULL
        AND p_trolin_rec.from_locator_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.from_locator_id, p_old_trolin_rec.from_locator_id) THEN
      l_trolin_val_rec.from_locator  := inv_id_to_value.from_locator(p_from_locator_id => p_trolin_rec.from_locator_id);
    END IF;

    --    IF p_trolin_rec.from_subinventory_code IS NOT NULL AND
    --        p_trolin_rec.from_subinventory_code <> FND_API.G_MISS_CHAR AND
    --        NOT INV_GLOBALS.Equal(p_trolin_rec.from_subinventory_code,
    --        p_old_trolin_rec.from_subinventory_code)
    --    THEN
    --        l_trolin_val_rec.from_subinventory := INV_Id_To_Value.From_Subinventory
    --        (   p_from_subinventory_code      => p_trolin_rec.from_subinventory_code
    --        );
    --    END IF;  -- Generated
    -- Line 2167
    IF  p_trolin_rec.from_subinventory_id IS NOT NULL
        AND p_trolin_rec.from_subinventory_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.from_subinventory_id, p_old_trolin_rec.from_subinventory_id) THEN
      l_trolin_val_rec.from_subinventory  := inv_id_to_value.from_subinventory(p_from_subinventory_id => p_trolin_rec.from_subinventory_id);
    --        (   p_from_subinventory_id        => p_trolin_rec.from_subinventory_id
    --        );
    END IF;

    IF  p_trolin_rec.header_id IS NOT NULL
        AND p_trolin_rec.header_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.header_id, p_old_trolin_rec.header_id) THEN
      l_trolin_val_rec.header  := inv_id_to_value.header(p_header_id => p_trolin_rec.header_id);
    END IF;

    IF  p_trolin_rec.inventory_item_id IS NOT NULL
        AND p_trolin_rec.inventory_item_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.inventory_item_id, p_old_trolin_rec.inventory_item_id) THEN
      l_trolin_val_rec.inventory_item  := inv_id_to_value.inventory_item(p_inventory_item_id => p_trolin_rec.inventory_item_id);
    END IF;

    IF  p_trolin_rec.line_id IS NOT NULL
        AND p_trolin_rec.line_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.line_id, p_old_trolin_rec.line_id) THEN
      l_trolin_val_rec.line  := inv_id_to_value.line(p_line_id => p_trolin_rec.line_id);
    END IF;

    IF  p_trolin_rec.organization_id IS NOT NULL
        AND p_trolin_rec.organization_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.organization_id, p_old_trolin_rec.organization_id) THEN
      l_trolin_val_rec.ORGANIZATION  := inv_id_to_value.ORGANIZATION(p_organization_id => p_trolin_rec.organization_id);
    END IF;

    IF  p_trolin_rec.to_organization_id IS NOT NULL
        AND p_trolin_rec.to_organization_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.to_organization_id, p_old_trolin_rec.to_organization_id) THEN
      l_trolin_val_rec.to_organization  := inv_id_to_value.to_organization(p_to_organization_id => p_trolin_rec.to_organization_id);
    END IF;

    IF  p_trolin_rec.project_id IS NOT NULL
        AND p_trolin_rec.project_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.project_id, p_old_trolin_rec.project_id) THEN
      l_trolin_val_rec.project  := inv_id_to_value.project(p_project_id => p_trolin_rec.project_id);
    END IF;

    IF  p_trolin_rec.reason_id IS NOT NULL
        AND p_trolin_rec.reason_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.reason_id, p_old_trolin_rec.reason_id) THEN
      l_trolin_val_rec.reason  := inv_id_to_value.reason(p_reason_id => p_trolin_rec.reason_id);
    END IF;

    IF  p_trolin_rec.reference_id IS NOT NULL
        AND p_trolin_rec.reference_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.reference_id, p_old_trolin_rec.reference_id) THEN
      l_trolin_val_rec.REFERENCE  := inv_id_to_value.REFERENCE(p_reference_id => p_trolin_rec.reference_id);
    END IF;

    IF  p_trolin_rec.reference_type_code IS NOT NULL
        AND p_trolin_rec.reference_type_code <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.reference_type_code, p_old_trolin_rec.reference_type_code) THEN
      l_trolin_val_rec.reference_type  := inv_id_to_value.reference_type(p_reference_type_code => p_trolin_rec.reference_type_code);
    END IF;

    IF  p_trolin_rec.task_id IS NOT NULL
        AND p_trolin_rec.task_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.task_id, p_old_trolin_rec.task_id) THEN
      l_trolin_val_rec.task  := inv_id_to_value.task(p_task_id => p_trolin_rec.task_id);
    END IF;

    IF  p_trolin_rec.to_account_id IS NOT NULL
        AND p_trolin_rec.to_account_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.to_account_id, p_old_trolin_rec.to_account_id) THEN
      l_trolin_val_rec.to_account  := inv_id_to_value.to_account(p_to_account_id => p_trolin_rec.to_account_id);
    END IF;

    IF  p_trolin_rec.to_locator_id IS NOT NULL
        AND p_trolin_rec.to_locator_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.to_locator_id, p_old_trolin_rec.to_locator_id) THEN
      l_trolin_val_rec.to_locator  := inv_id_to_value.to_locator(p_to_locator_id => p_trolin_rec.to_locator_id);
    END IF;

    --    IF p_trolin_rec.to_subinventory_code IS NOT NULL AND
    --        p_trolin_rec.to_subinventory_code <> FND_API.G_MISS_CHAR AND
    --        NOT INV_GLOBALS.Equal(p_trolin_rec.to_subinventory_code,
    --        p_old_trolin_rec.to_subinventory_code)
    --    THEN
    --        l_trolin_val_rec.to_subinventory := INV_Id_To_Value.To_Subinventory
    --        (   p_to_subinventory_code        => p_trolin_rec.to_subinventory_code
    --        );
    --    END IF; -- Generated

    IF  p_trolin_rec.to_subinventory_id IS NOT NULL
        AND p_trolin_rec.to_subinventory_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.to_subinventory_id, p_old_trolin_rec.to_subinventory_id) THEN
      l_trolin_val_rec.to_subinventory  := inv_id_to_value.to_subinventory(p_to_subinventory_id => p_trolin_rec.to_subinventory_id);
    END IF;

    IF  p_trolin_rec.transaction_header_id IS NOT NULL
        AND p_trolin_rec.transaction_header_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.transaction_header_id, p_old_trolin_rec.transaction_header_id) THEN
      l_trolin_val_rec.transaction_header  := inv_id_to_value.transaction_header(p_transaction_header_id => p_trolin_rec.transaction_header_id);
    END IF;

    IF  p_trolin_rec.transaction_type_id IS NOT NULL
        AND p_trolin_rec.transaction_type_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trolin_rec.transaction_type_id, p_old_trolin_rec.transaction_type_id) THEN
      l_trolin_val_rec.transaction_type  := inv_id_to_value.transaction_type(p_transaction_type_id => p_trolin_rec.transaction_type_id);
    END IF;

    IF  p_trolin_rec.uom_code IS NOT NULL
        AND p_trolin_rec.uom_code <> fnd_api.g_miss_char
        AND NOT inv_globals.equal(p_trolin_rec.uom_code, p_old_trolin_rec.uom_code) THEN
      l_trolin_val_rec.uom  := inv_id_to_value.uom(p_uom_code => p_trolin_rec.uom_code);
    END IF;

    RETURN l_trolin_val_rec;
  END get_values;

  --  Function Get_Ids

  FUNCTION get_ids(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_trolin_val_rec IN inv_move_order_pub.trolin_val_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type IS
    l_trolin_rec inv_move_order_pub.trolin_rec_type;
  BEGIN
    --  initialize  return_status.

    l_trolin_rec.return_status  := fnd_api.g_ret_sts_success;
    --  initialize l_trolin_rec.

    l_trolin_rec                := p_trolin_rec;

    /*
        IF  p_trolin_val_rec.from_locator <> FND_API.G_MISS_CHAR
        THEN

            IF p_trolin_rec.from_locator_id <> FND_API.G_MISS_NUM THEN

                l_trolin_rec.from_locator_id := p_trolin_rec.from_locator_id;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                THEN

                    FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_locator');
                    FND_MSG_PUB.Add;

                END IF;

            ELSE

                l_trolin_rec.from_locator_id := INV_Value_To_Id.from_locator
                (   p_organizatoin_id             => p_trolin_rec.organization_id,
                    p_from_locator                => p_trolin_val_rec.from_locator
                );

                IF l_trolin_rec.from_locator_id = FND_API.G_MISS_NUM THEN
                    l_trolin_rec.return_status := FND_API.G_RET_STS_ERROR;
                END IF;

            END IF;

        END IF;
    */

    IF p_trolin_val_rec.from_subinventory <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.from_subinventory_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.from_subinventory_id  := p_trolin_rec.from_subinventory_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'from_subinventory');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.from_subinventory_id  := inv_value_to_id.from_subinventory(p_organization_id => p_trolin_rec.organization_id, p_from_subinventory => p_trolin_val_rec.from_subinventory);

        IF l_trolin_rec.from_subinventory_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.header <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.header_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.header_id  := p_trolin_rec.header_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'header');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.header_id  := inv_value_to_id.header(p_header => p_trolin_val_rec.header);

        IF l_trolin_rec.header_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.inventory_item <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.inventory_item_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.inventory_item_id  := p_trolin_rec.inventory_item_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'inventory_item');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.inventory_item_id  := inv_value_to_id.inventory_item(p_organization_id => p_trolin_rec.organization_id, p_inventory_item => p_trolin_val_rec.inventory_item);

        IF l_trolin_rec.inventory_item_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.line <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.line_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.line_id  := p_trolin_rec.line_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'line');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.line_id  := inv_value_to_id.line(p_line => p_trolin_val_rec.line);

        IF l_trolin_rec.line_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.ORGANIZATION <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.organization_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.organization_id  := p_trolin_rec.organization_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'organization');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.organization_id  := inv_value_to_id.ORGANIZATION(p_organization => p_trolin_val_rec.ORGANIZATION);

        IF l_trolin_rec.organization_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.to_organization <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.to_organization_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.to_organization_id  := p_trolin_rec.to_organization_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'to_organization');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.to_organization_id  := inv_value_to_id.to_organization(p_to_organization => p_trolin_val_rec.to_organization);

        IF l_trolin_rec.to_organization_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.project <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.project_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.project_id  := p_trolin_rec.project_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'project');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.project_id  := inv_value_to_id.project(p_project => p_trolin_val_rec.project);

        IF l_trolin_rec.project_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.reason <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.reason_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.reason_id  := p_trolin_rec.reason_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'reason');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.reason_id  := inv_value_to_id.reason(p_reason => p_trolin_val_rec.reason);

        IF l_trolin_rec.reason_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.REFERENCE <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.reference_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.reference_id  := p_trolin_rec.reference_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'reference');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.reference_id  := inv_value_to_id.REFERENCE(p_reference => p_trolin_val_rec.REFERENCE);

        IF l_trolin_rec.reference_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.reference_type <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.reference_type_code <> fnd_api.g_miss_num THEN
        l_trolin_rec.reference_type_code  := p_trolin_rec.reference_type_code;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'reference_type');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.reference_type_code  := inv_value_to_id.reference_type(p_reference_type => p_trolin_val_rec.reference_type);

        IF l_trolin_rec.reference_type_code = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.task <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.task_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.task_id  := p_trolin_rec.task_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'task');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.task_id  := inv_value_to_id.task(p_task => p_trolin_val_rec.task);

        IF l_trolin_rec.task_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.to_account <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.to_account_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.to_account_id  := p_trolin_rec.to_account_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'to_account');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.to_account_id  := inv_value_to_id.to_account(p_organization_id => p_trolin_rec.organization_id, p_to_account => p_trolin_val_rec.to_account);

        IF l_trolin_rec.to_account_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    /*
        IF  p_trolin_val_rec.to_locator <> FND_API.G_MISS_CHAR
        THEN

            IF p_trolin_rec.to_locator_id <> FND_API.G_MISS_NUM THEN

                l_trolin_rec.to_locator_id := p_trolin_rec.to_locator_id;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                THEN

                    FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_locator');
                    FND_MSG_PUB.Add;

                END IF;

            ELSE

                l_trolin_rec.to_locator_id := INV_Value_To_Id.to_locator
                (   p_to_locator                  => p_trolin_val_rec.to_locator
                );

                IF l_trolin_rec.to_locator_id = FND_API.G_MISS_NUM THEN
                    l_trolin_rec.return_status := FND_API.G_RET_STS_ERROR;
                END IF;

            END IF;

        END IF;
    */

    IF p_trolin_val_rec.to_subinventory <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.to_subinventory_code <> fnd_api.g_miss_char THEN
        l_trolin_rec.to_subinventory_code  := p_trolin_rec.to_subinventory_code;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'to_subinventory');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.to_subinventory_code  := inv_value_to_id.to_subinventory(p_organization_id => p_trolin_rec.organization_id, p_to_subinventory => p_trolin_val_rec.to_subinventory);

        IF l_trolin_rec.to_subinventory_code = fnd_api.g_miss_char THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    -- Line2839
    IF p_trolin_val_rec.to_subinventory <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.to_subinventory_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.to_subinventory_id  := p_trolin_rec.to_subinventory_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'to_subinventory');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.to_subinventory_id  := inv_value_to_id.to_subinventory(p_organization_id => p_trolin_rec.organization_id, p_to_subinventory => p_trolin_val_rec.to_subinventory);

        IF l_trolin_rec.to_subinventory_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.transaction_header <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.transaction_header_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.transaction_header_id  := p_trolin_rec.transaction_header_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'transaction_header');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.transaction_header_id  := inv_value_to_id.transaction_header(p_transaction_header => p_trolin_val_rec.transaction_header);

        IF l_trolin_rec.transaction_header_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trolin_val_rec.transaction_type <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.transaction_type_id <> fnd_api.g_miss_num THEN
        l_trolin_rec.transaction_type_id  := p_trolin_rec.transaction_type_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'transaction_type');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trolin_rec.transaction_type_id  := inv_value_to_id.transaction_type(p_transaction_type => p_trolin_val_rec.transaction_type);

        IF l_trolin_rec.transaction_type_id = fnd_api.g_miss_num THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    -- Line2899
    IF p_trolin_val_rec.uom <> fnd_api.g_miss_char THEN
      IF p_trolin_rec.uom_code <> fnd_api.g_miss_char THEN
        l_trolin_rec.uom_code  := p_trolin_rec.uom_code;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'uom');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        -- Line2917
        l_trolin_rec.uom_code  := inv_value_to_id.uom(p_uom => p_trolin_val_rec.uom);

        IF l_trolin_rec.uom_code = fnd_api.g_miss_char THEN
          l_trolin_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    RETURN l_trolin_rec;
  END get_ids;

  --Procedure Insert_Mo_Lines_Bulk  /* For Parallel Pick-Release */

  PROCEDURE insert_mo_lines_bulk(p_new_trolin_tbl IN inv_move_order_pub.trolin_new_tbl_type
				,x_return_status IN OUT NOCOPY VARCHAR2) IS

  BEGIN
    FORALL i IN 1 .. p_new_trolin_tbl.COUNT
      insert into mtl_txn_request_lines
      values p_new_trolin_tbl(i);

  x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_unexpected_error;
  END insert_mo_lines_bulk;

END inv_trolin_util;

/
