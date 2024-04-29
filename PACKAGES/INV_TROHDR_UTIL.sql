--------------------------------------------------------
--  DDL for Package INV_TROHDR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TROHDR_UTIL" AUTHID CURRENT_USER AS
  /* $Header: INVUTRHS.pls 120.0 2005/05/25 04:34:00 appldev noship $ */

  --  Attributes global constants

  g_attribute1          CONSTANT NUMBER := 1;
  g_attribute10         CONSTANT NUMBER := 2;
  g_attribute11         CONSTANT NUMBER := 3;
  g_attribute12         CONSTANT NUMBER := 4;
  g_attribute13         CONSTANT NUMBER := 5;
  g_attribute14         CONSTANT NUMBER := 6;
  g_attribute15         CONSTANT NUMBER := 7;
  g_attribute2          CONSTANT NUMBER := 8;
  g_attribute3          CONSTANT NUMBER := 9;
  g_attribute4          CONSTANT NUMBER := 10;
  g_attribute5          CONSTANT NUMBER := 11;
  g_attribute6          CONSTANT NUMBER := 12;
  g_attribute7          CONSTANT NUMBER := 13;
  g_attribute8          CONSTANT NUMBER := 14;
  g_attribute9          CONSTANT NUMBER := 15;
  g_attribute_category  CONSTANT NUMBER := 16;
  g_created_by          CONSTANT NUMBER := 17;
  g_creation_date       CONSTANT NUMBER := 18;
  g_date_required       CONSTANT NUMBER := 19;
  g_description         CONSTANT NUMBER := 20;
  g_from_subinventory   CONSTANT NUMBER := 21;
  g_header              CONSTANT NUMBER := 22;
  g_header_status       CONSTANT NUMBER := 23;
  g_last_updated_by     CONSTANT NUMBER := 24;
  g_last_update_date    CONSTANT NUMBER := 25;
  g_last_update_login   CONSTANT NUMBER := 26;
  g_organization        CONSTANT NUMBER := 27;
  g_program_application CONSTANT NUMBER := 28;
  g_program             CONSTANT NUMBER := 29;
  g_program_update_date CONSTANT NUMBER := 30;
  g_request             CONSTANT NUMBER := 31;
  g_request_number      CONSTANT NUMBER := 32;
  g_status_date         CONSTANT NUMBER := 33;
  g_to_account          CONSTANT NUMBER := 34;
  g_to_subinventory     CONSTANT NUMBER := 35;
  g_move_order_type     CONSTANT NUMBER := 36;
  g_transaction_type    CONSTANT NUMBER := 37;
  g_max_attr_id         CONSTANT NUMBER := 38;
  g_ship_to_location_id CONSTANT NUMBER := 39;

  --  Procedure Clear_Dependent_Attr

  PROCEDURE clear_dependent_attr(
    p_attr_id        IN     NUMBER := fnd_api.g_miss_num
  , p_trohdr_rec     IN     inv_move_order_pub.trohdr_rec_type
  , p_old_trohdr_rec IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , x_trohdr_rec     IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  );

  --  Procedure Apply_Attribute_Changes

  PROCEDURE apply_attribute_changes(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_old_trohdr_rec IN inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec, x_trohdr_rec IN OUT NOCOPY inv_move_order_pub.trohdr_rec_type);

  --  Function Complete_Record

  FUNCTION complete_record(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_old_trohdr_rec IN inv_move_order_pub.trohdr_rec_type)
    RETURN inv_move_order_pub.trohdr_rec_type;

  --  Function Convert_Miss_To_Null for TROHDR_REC_TYPE

  FUNCTION convert_miss_to_null(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type)
    RETURN inv_move_order_pub.trohdr_rec_type;

  --  Bug#2536932: Function Convert_Miss_To_Null for TROHDR_VAL_REC_TYPE
  --  This converts all the Miss Char or Number or Date to NULL Values.

  FUNCTION convert_miss_to_null(p_trohdr_val_rec IN inv_move_order_pub.trohdr_val_rec_type)
    RETURN inv_move_order_pub.trohdr_val_rec_type;

  --  Procedure Update_Row

  PROCEDURE update_row(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type);

  --  Procedure Update_Row_Status

  PROCEDURE update_row_status(p_header_id IN NUMBER, p_status IN NUMBER);

  --  Procedure Insert_Row

  PROCEDURE insert_row(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type);

  --  Procedure Delete_Row

  PROCEDURE delete_row(p_header_id IN NUMBER);

  --  Function Query_Row

  FUNCTION query_row(p_header_id IN NUMBER)
    RETURN inv_move_order_pub.trohdr_rec_type;

  --  Procedure       lock_Row
  --

  PROCEDURE lock_row(x_return_status OUT NOCOPY VARCHAR2, p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, x_trohdr_rec IN OUT NOCOPY inv_move_order_pub.trohdr_rec_type);

  --  Function Get_Values

  FUNCTION get_values(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_old_trohdr_rec IN inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec)
    RETURN inv_move_order_pub.trohdr_val_rec_type;

  --  Function Get_Ids

  FUNCTION get_ids(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_trohdr_val_rec IN inv_move_order_pub.trohdr_val_rec_type)
    RETURN inv_move_order_pub.trohdr_rec_type;
END inv_trohdr_util;

 

/
