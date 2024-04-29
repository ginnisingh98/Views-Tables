--------------------------------------------------------
--  DDL for Package INV_TROLIN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TROLIN_UTIL" AUTHID CURRENT_USER AS
  /* $Header: INVUTRLS.pls 120.0.12000000.1 2007/01/17 16:34:20 appldev ship $ */

  --  Attributes global constants

  g_attribute1                 CONSTANT NUMBER := 2;
  g_attribute10                CONSTANT NUMBER := 3;
  g_attribute11                CONSTANT NUMBER := 4;
  g_attribute12                CONSTANT NUMBER := 5;
  g_attribute13                CONSTANT NUMBER := 6;
  g_attribute14                CONSTANT NUMBER := 7;
  g_attribute15                CONSTANT NUMBER := 8;
  g_attribute2                 CONSTANT NUMBER := 9;
  g_attribute3                 CONSTANT NUMBER := 10;
  g_attribute4                 CONSTANT NUMBER := 11;
  g_attribute5                 CONSTANT NUMBER := 12;
  g_attribute6                 CONSTANT NUMBER := 13;
  g_attribute7                 CONSTANT NUMBER := 14;
  g_attribute8                 CONSTANT NUMBER := 15;
  g_attribute9                 CONSTANT NUMBER := 16;
  g_attribute_category         CONSTANT NUMBER := 17;
  g_created_by                 CONSTANT NUMBER := 18;
  g_creation_date              CONSTANT NUMBER := 19;
  g_date_required              CONSTANT NUMBER := 20;
  g_from_locator               CONSTANT NUMBER := 21;
  g_from_subinventory          CONSTANT NUMBER := 22;
  --G_FROM_SUBINVENTORY           CONSTANT NUMBER := 23;
  g_header                     CONSTANT NUMBER := 24;
  g_inventory_item             CONSTANT NUMBER := 25;
  g_last_updated_by            CONSTANT NUMBER := 26;
  g_last_update_date           CONSTANT NUMBER := 27;
  g_last_update_login          CONSTANT NUMBER := 28;
  g_line                       CONSTANT NUMBER := 29;
  g_line_number                CONSTANT NUMBER := 30;
  g_line_status                CONSTANT NUMBER := 31;
  g_lot_number                 CONSTANT NUMBER := 32;
  g_organization               CONSTANT NUMBER := 33;
  g_program_application        CONSTANT NUMBER := 34;
  g_program                    CONSTANT NUMBER := 35;
  g_program_update_date        CONSTANT NUMBER := 36;
  g_project                    CONSTANT NUMBER := 37;
  g_quantity                   CONSTANT NUMBER := 38;
  g_quantity_delivered         CONSTANT NUMBER := 39;
  g_quantity_detailed          CONSTANT NUMBER := 40;
  g_reason                     CONSTANT NUMBER := 41;
  g_reference                  CONSTANT NUMBER := 42;
  --G_REFERENCE                   CONSTANT NUMBER := 43;
  g_reference_type             CONSTANT NUMBER := 44;
  g_request                    CONSTANT NUMBER := 45;
  g_revision                   CONSTANT NUMBER := 46;
  g_serial_number_end          CONSTANT NUMBER := 47;
  g_serial_number_start        CONSTANT NUMBER := 48;
  g_status_date                CONSTANT NUMBER := 49;
  g_task                       CONSTANT NUMBER := 50;
  g_to_account                 CONSTANT NUMBER := 51;
  g_to_locator                 CONSTANT NUMBER := 52;
  g_to_subinventory            CONSTANT NUMBER := 53;
  --G_TO_SUBINVENTORY             CONSTANT NUMBER := 54;
  g_transaction_header         CONSTANT NUMBER := 55;
  g_uom                        CONSTANT NUMBER := 56;
  --G_UOM                         CONSTANT NUMBER := 57;
  g_max_attr_id                CONSTANT NUMBER := 58;
  g_transaction_type_id        CONSTANT NUMBER := 59;
  g_transaction_source_type_id CONSTANT NUMBER := 60;
  g_txn_source_id              CONSTANT NUMBER := 61;
  g_txn_source_line_id         CONSTANT NUMBER := 62;
  g_txn_source_line_detail_id  CONSTANT NUMBER := 63;
  g_primary_quantity           CONSTANT NUMBER := 64;
  g_to_organization_id         CONSTANT NUMBER := 65;
  g_pick_strategy_id           CONSTANT NUMBER := 66;
  g_put_away_strategy_id       CONSTANT NUMBER := 67;
  g_unit_number                CONSTANT NUMBER := 68;
  g_ship_to_location_id        CONSTANT NUMBER := 69;
  g_from_cost_group_id         CONSTANT NUMBER := 70;
  g_to_cost_group_id           CONSTANT NUMBER := 71;
  g_lpn_id                     CONSTANT NUMBER := 72;
  g_to_lpn_id                  CONSTANT NUMBER := 73;
  g_pick_methodology_id        CONSTANT NUMBER := 74;
  g_container_item_id          CONSTANT NUMBER := 75;
  g_carton_grouping_id         CONSTANT NUMBER := 76;
  g_pick_slip_number           CONSTANT NUMBER := 77;
  g_pick_slip_date             CONSTANT NUMBER := 78;
  g_ship_set_id                CONSTANT NUMBER := 79;
  g_ship_model_id              CONSTANT NUMBER := 80;
  g_model_quantity             CONSTANT NUMBER := 81;
  g_required_quantity          CONSTANT NUMBER := 82;
--INVCONV BEGIN
  g_secondary_quantity           CONSTANT NUMBER := 83;
  g_secondary_quantity_delivered CONSTANT NUMBER := 84;
  g_secondary_quantity_detailed  CONSTANT NUMBER := 85;
  g_secondary_uom                CONSTANT NUMBER := 86;
  g_grade_code                   CONSTANT NUMBER := 87;
  g_secondary_required_quantity  CONSTANT NUMBER := 88;
--INVCONV END;

  --  Procedure Clear_Dependent_Attr

  PROCEDURE clear_dependent_attr(
    p_attr_id        IN     NUMBER := fnd_api.g_miss_num
  , p_trolin_rec     IN     inv_move_order_pub.trolin_rec_type
  , p_old_trolin_rec IN     inv_move_order_pub.trolin_rec_type := inv_move_order_pub.g_miss_trolin_rec
  , x_trolin_rec     IN OUT    NOCOPY inv_move_order_pub.trolin_rec_type
  );

  --  Procedure Apply_Attribute_Changes

  PROCEDURE apply_attribute_changes(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_old_trolin_rec IN inv_move_order_pub.trolin_rec_type := inv_move_order_pub.g_miss_trolin_rec, x_trolin_rec IN OUT NOCOPY inv_move_order_pub.trolin_rec_type);

  --  Function Complete_Record

  FUNCTION complete_record(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_old_trolin_rec IN inv_move_order_pub.trolin_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type;

  --  Function Convert_Miss_To_Null for TROLIN_REC_TYPE

  FUNCTION convert_miss_to_null(p_trolin_rec IN inv_move_order_pub.trolin_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type;

  --  Function Convert_Miss_To_Null_Parallel for TROLIN_REC_TYPE

  FUNCTION convert_miss_to_null_parallel(p_trolin_rec IN inv_move_order_pub.trolin_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type;

  --  Bug#2536932: Function Convert_Miss_To_Null for TROLIN_VAL_REC_TYPE
  --  Converts all Miss Char, Number or Date to NULL values.

  FUNCTION convert_miss_to_null(p_trolin_val_rec IN inv_move_order_pub.trolin_val_rec_type)
    RETURN inv_move_order_pub.trolin_val_rec_type;

  --  Procedure Update_Row

  PROCEDURE update_row(p_trolin_rec IN inv_move_order_pub.trolin_rec_type);

  --  Procedure Update_Row_Status

  PROCEDURE update_row_status(p_line_id IN NUMBER, p_status IN NUMBER);

  --  Procedure Insert_Row

  PROCEDURE insert_row(p_trolin_rec IN inv_move_order_pub.trolin_rec_type);

  --  Procedure Delete_Row

  PROCEDURE delete_row(p_line_id IN NUMBER);

  --  Function Query_Row

  FUNCTION query_row(p_line_id IN NUMBER)
    RETURN inv_move_order_pub.trolin_rec_type;

  --  Function Query_Rows

  --

  FUNCTION query_rows(p_line_id IN NUMBER := fnd_api.g_miss_num, p_header_id IN NUMBER := fnd_api.g_miss_num)
    RETURN inv_move_order_pub.trolin_tbl_type;

  --  Function Get_Lines
  --

  FUNCTION get_lines(p_header_id IN NUMBER)
    RETURN inv_move_order_pub.trolin_tbl_type;

  --  Procedure       lock_Row
  --

  PROCEDURE lock_row(x_return_status OUT NOCOPY VARCHAR2, p_trolin_rec IN inv_move_order_pub.trolin_rec_type, x_trolin_rec IN OUT NOCOPY inv_move_order_pub.trolin_rec_type);

  --  Function Get_Values

  FUNCTION get_values(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_old_trolin_rec IN inv_move_order_pub.trolin_rec_type := inv_move_order_pub.g_miss_trolin_rec)
    RETURN inv_move_order_pub.trolin_val_rec_type;

  --  Function Get_Ids

  FUNCTION get_ids(p_trolin_rec IN inv_move_order_pub.trolin_rec_type, p_trolin_val_rec IN inv_move_order_pub.trolin_val_rec_type)
    RETURN inv_move_order_pub.trolin_rec_type;

  --  Procedure insert_mo_lines_bulk  /* For Parallel Pick release */

  PROCEDURE insert_mo_lines_bulk
  (
      p_new_trolin_tbl IN inv_move_order_pub.Trolin_New_Tbl_Type
    , x_return_status  IN OUT NOCOPY VARCHAR2
  );

END inv_trolin_util;

 

/
