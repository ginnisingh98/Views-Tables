--------------------------------------------------------
--  DDL for Package Body INV_TROHDR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TROHDR_UTIL" AS
  /* $Header: INVUTRHB.pls 120.0 2005/05/25 06:23:59 appldev noship $ */

  --  Global constant holding the package name

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Trohdr_Util';

  --  Procedure Clear_Dependent_Attr

  PROCEDURE clear_dependent_attr(
    p_attr_id        IN     NUMBER := fnd_api.g_miss_num
  , p_trohdr_rec     IN     inv_move_order_pub.trohdr_rec_type
  , p_old_trohdr_rec IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , x_trohdr_rec     IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  ) IS
    l_index        NUMBER                      := 0;
    l_src_attr_tbl inv_globals.number_tbl_type;
    l_dep_attr_tbl inv_globals.number_tbl_type;
  BEGIN
    --  Load out record

    x_trohdr_rec  := p_trohdr_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = fnd_api.g_miss_num THEN
      IF NOT inv_globals.equal(p_trohdr_rec.attribute1, p_old_trohdr_rec.attribute1) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute1;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute10, p_old_trohdr_rec.attribute10) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute10;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute11, p_old_trohdr_rec.attribute11) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute11;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute12, p_old_trohdr_rec.attribute12) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute12;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute13, p_old_trohdr_rec.attribute13) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute13;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute14, p_old_trohdr_rec.attribute14) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute14;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute15, p_old_trohdr_rec.attribute15) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute15;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute2, p_old_trohdr_rec.attribute2) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute2;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute3, p_old_trohdr_rec.attribute3) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute3;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute4, p_old_trohdr_rec.attribute4) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute4;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute5, p_old_trohdr_rec.attribute5) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute5;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute6, p_old_trohdr_rec.attribute6) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute6;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute7, p_old_trohdr_rec.attribute7) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute7;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute8, p_old_trohdr_rec.attribute8) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute8;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute9, p_old_trohdr_rec.attribute9) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute9;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.attribute_category, p_old_trohdr_rec.attribute_category) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute_category;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.created_by, p_old_trohdr_rec.created_by) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_created_by;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.creation_date, p_old_trohdr_rec.creation_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_creation_date;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.date_required, p_old_trohdr_rec.date_required) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_date_required;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.description, p_old_trohdr_rec.description) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_description;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.from_subinventory_code, p_old_trohdr_rec.from_subinventory_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_from_subinventory;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.header_id, p_old_trohdr_rec.header_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_header;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.header_status, p_old_trohdr_rec.header_status) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_header_status;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.last_updated_by, p_old_trohdr_rec.last_updated_by) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_last_updated_by;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.last_update_date, p_old_trohdr_rec.last_update_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_last_update_date;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.last_update_login, p_old_trohdr_rec.last_update_login) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_last_update_login;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.organization_id, p_old_trohdr_rec.organization_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_organization;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.program_application_id, p_old_trohdr_rec.program_application_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_program_application;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.program_id, p_old_trohdr_rec.program_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_program;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.program_update_date, p_old_trohdr_rec.program_update_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_program_update_date;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.request_id, p_old_trohdr_rec.request_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_request;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.request_number, p_old_trohdr_rec.request_number) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_request_number;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.status_date, p_old_trohdr_rec.status_date) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_status_date;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.to_account_id, p_old_trohdr_rec.to_account_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_to_account;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.to_subinventory_code, p_old_trohdr_rec.to_subinventory_code) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_to_subinventory;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.move_order_type, p_old_trohdr_rec.move_order_type) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_move_order_type;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.transaction_type_id, p_old_trohdr_rec.transaction_type_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_transaction_type;
      END IF;

      IF NOT inv_globals.equal(p_trohdr_rec.ship_to_location_id, p_old_trohdr_rec.ship_to_location_id) THEN
        l_index                  := l_index + 1;
        l_src_attr_tbl(l_index)  := inv_trohdr_util.g_ship_to_location_id;
      END IF;
    ELSIF p_attr_id = g_attribute1 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute1;
    ELSIF p_attr_id = g_attribute10 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute10;
    ELSIF p_attr_id = g_attribute11 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute11;
    ELSIF p_attr_id = g_attribute12 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute12;
    ELSIF p_attr_id = g_attribute13 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute13;
    ELSIF p_attr_id = g_attribute14 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute14;
    ELSIF p_attr_id = g_attribute15 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute15;
    ELSIF p_attr_id = g_attribute2 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute2;
    ELSIF p_attr_id = g_attribute3 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute3;
    ELSIF p_attr_id = g_attribute4 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute4;
    ELSIF p_attr_id = g_attribute5 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute5;
    ELSIF p_attr_id = g_attribute6 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute6;
    ELSIF p_attr_id = g_attribute7 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute7;
    ELSIF p_attr_id = g_attribute8 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute8;
    ELSIF p_attr_id = g_attribute9 THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute9;
    ELSIF p_attr_id = g_attribute_category THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_attribute_category;
    ELSIF p_attr_id = g_created_by THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_created_by;
    ELSIF p_attr_id = g_creation_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_creation_date;
    ELSIF p_attr_id = g_date_required THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_date_required;
    ELSIF p_attr_id = g_description THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_description;
    ELSIF p_attr_id = g_from_subinventory THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_from_subinventory;
    ELSIF p_attr_id = g_header THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_header;
    ELSIF p_attr_id = g_header_status THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_header_status;
    ELSIF p_attr_id = g_last_updated_by THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_last_updated_by;
    ELSIF p_attr_id = g_last_update_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_last_update_date;
    ELSIF p_attr_id = g_last_update_login THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_last_update_login;
    ELSIF p_attr_id = g_organization THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_organization;
    ELSIF p_attr_id = g_program_application THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_program_application;
    ELSIF p_attr_id = g_program THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_program;
    ELSIF p_attr_id = g_program_update_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_program_update_date;
    ELSIF p_attr_id = g_request THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_request;
    ELSIF p_attr_id = g_request_number THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_request_number;
    ELSIF p_attr_id = g_status_date THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_status_date;
    ELSIF p_attr_id = g_to_account THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_to_account;
    ELSIF p_attr_id = g_to_subinventory THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_to_subinventory;
    ELSIF p_attr_id = g_move_order_type THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_move_order_type;
    ELSIF p_attr_id = g_transaction_type THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_transaction_type;
    ELSIF p_attr_id = g_ship_to_location_id THEN
      l_index                  := l_index + 1;
      l_src_attr_tbl(l_index)  := inv_trohdr_util.g_ship_to_location_id;
    END IF;
  END clear_dependent_attr;

  --  Procedure Apply_Attribute_Changes

  PROCEDURE apply_attribute_changes(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_old_trohdr_rec IN inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec, x_trohdr_rec IN OUT NOCOPY inv_move_order_pub.trohdr_rec_type) IS
  BEGIN
    --  Load out record

    x_trohdr_rec  := p_trohdr_rec;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute1, p_old_trohdr_rec.attribute1) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute10, p_old_trohdr_rec.attribute10) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute11, p_old_trohdr_rec.attribute11) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute12, p_old_trohdr_rec.attribute12) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute13, p_old_trohdr_rec.attribute13) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute14, p_old_trohdr_rec.attribute14) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute15, p_old_trohdr_rec.attribute15) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute2, p_old_trohdr_rec.attribute2) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute3, p_old_trohdr_rec.attribute3) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute4, p_old_trohdr_rec.attribute4) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute5, p_old_trohdr_rec.attribute5) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute6, p_old_trohdr_rec.attribute6) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute7, p_old_trohdr_rec.attribute7) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute8, p_old_trohdr_rec.attribute8) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute9, p_old_trohdr_rec.attribute9) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.attribute_category, p_old_trohdr_rec.attribute_category) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.created_by, p_old_trohdr_rec.created_by) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.creation_date, p_old_trohdr_rec.creation_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.date_required, p_old_trohdr_rec.date_required) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.description, p_old_trohdr_rec.description) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.from_subinventory_code, p_old_trohdr_rec.from_subinventory_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.header_id, p_old_trohdr_rec.header_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.header_status, p_old_trohdr_rec.header_status) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.last_updated_by, p_old_trohdr_rec.last_updated_by) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.last_update_date, p_old_trohdr_rec.last_update_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.last_update_login, p_old_trohdr_rec.last_update_login) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.organization_id, p_old_trohdr_rec.organization_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.program_application_id, p_old_trohdr_rec.program_application_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.program_id, p_old_trohdr_rec.program_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.program_update_date, p_old_trohdr_rec.program_update_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.request_id, p_old_trohdr_rec.request_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.request_number, p_old_trohdr_rec.request_number) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.status_date, p_old_trohdr_rec.status_date) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.to_account_id, p_old_trohdr_rec.to_account_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.to_subinventory_code, p_old_trohdr_rec.to_subinventory_code) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.move_order_type, p_old_trohdr_rec.move_order_type) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.transaction_type_id, p_old_trohdr_rec.transaction_type_id) THEN
      NULL;
    END IF;

    IF NOT inv_globals.equal(p_trohdr_rec.ship_to_location_id, p_old_trohdr_rec.ship_to_location_id) THEN
      NULL;
    END IF;
  END apply_attribute_changes;

  --  Function Complete_Record

  FUNCTION complete_record(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_old_trohdr_rec IN inv_move_order_pub.trohdr_rec_type)
    RETURN inv_move_order_pub.trohdr_rec_type IS
    l_trohdr_rec inv_move_order_pub.trohdr_rec_type := p_trohdr_rec;
  BEGIN
    IF l_trohdr_rec.attribute1 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute1  := p_old_trohdr_rec.attribute1;
    END IF;

    IF l_trohdr_rec.attribute10 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute10  := p_old_trohdr_rec.attribute10;
    END IF;

    IF l_trohdr_rec.attribute11 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute11  := p_old_trohdr_rec.attribute11;
    END IF;

    IF l_trohdr_rec.attribute12 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute12  := p_old_trohdr_rec.attribute12;
    END IF;

    IF l_trohdr_rec.attribute13 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute13  := p_old_trohdr_rec.attribute13;
    END IF;

    IF l_trohdr_rec.attribute14 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute14  := p_old_trohdr_rec.attribute14;
    END IF;

    IF l_trohdr_rec.attribute15 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute15  := p_old_trohdr_rec.attribute15;
    END IF;

    IF l_trohdr_rec.attribute2 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute2  := p_old_trohdr_rec.attribute2;
    END IF;

    IF l_trohdr_rec.attribute3 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute3  := p_old_trohdr_rec.attribute3;
    END IF;

    IF l_trohdr_rec.attribute4 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute4  := p_old_trohdr_rec.attribute4;
    END IF;

    IF l_trohdr_rec.attribute5 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute5  := p_old_trohdr_rec.attribute5;
    END IF;

    IF l_trohdr_rec.attribute6 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute6  := p_old_trohdr_rec.attribute6;
    END IF;

    IF l_trohdr_rec.attribute7 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute7  := p_old_trohdr_rec.attribute7;
    END IF;

    IF l_trohdr_rec.attribute8 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute8  := p_old_trohdr_rec.attribute8;
    END IF;

    IF l_trohdr_rec.attribute9 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute9  := p_old_trohdr_rec.attribute9;
    END IF;

    IF l_trohdr_rec.attribute_category = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute_category  := p_old_trohdr_rec.attribute_category;
    END IF;

    IF l_trohdr_rec.created_by = fnd_api.g_miss_num THEN
      l_trohdr_rec.created_by  := p_old_trohdr_rec.created_by;
    END IF;

    IF l_trohdr_rec.creation_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.creation_date  := p_old_trohdr_rec.creation_date;
    END IF;

    IF l_trohdr_rec.date_required = fnd_api.g_miss_date THEN
      l_trohdr_rec.date_required  := p_old_trohdr_rec.date_required;
    END IF;

    IF l_trohdr_rec.description = fnd_api.g_miss_char THEN
      l_trohdr_rec.description  := p_old_trohdr_rec.description;
    END IF;

    IF l_trohdr_rec.from_subinventory_code = fnd_api.g_miss_char THEN
      l_trohdr_rec.from_subinventory_code  := p_old_trohdr_rec.from_subinventory_code;
    END IF;

    IF l_trohdr_rec.header_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.header_id  := p_old_trohdr_rec.header_id;
    END IF;

    IF l_trohdr_rec.header_status = fnd_api.g_miss_num THEN
      l_trohdr_rec.header_status  := p_old_trohdr_rec.header_status;
    END IF;

    IF l_trohdr_rec.last_updated_by = fnd_api.g_miss_num THEN
      l_trohdr_rec.last_updated_by  := p_old_trohdr_rec.last_updated_by;
    END IF;

    IF l_trohdr_rec.last_update_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.last_update_date  := p_old_trohdr_rec.last_update_date;
    END IF;

    IF l_trohdr_rec.last_update_login = fnd_api.g_miss_num THEN
      l_trohdr_rec.last_update_login  := p_old_trohdr_rec.last_update_login;
    END IF;

    IF l_trohdr_rec.organization_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.organization_id  := p_old_trohdr_rec.organization_id;
    END IF;

    IF l_trohdr_rec.program_application_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.program_application_id  := p_old_trohdr_rec.program_application_id;
    END IF;

    IF l_trohdr_rec.program_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.program_id  := p_old_trohdr_rec.program_id;
    END IF;

    IF l_trohdr_rec.program_update_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.program_update_date  := p_old_trohdr_rec.program_update_date;
    END IF;

    IF l_trohdr_rec.request_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.request_id  := p_old_trohdr_rec.request_id;
    END IF;

    IF l_trohdr_rec.request_number = fnd_api.g_miss_char THEN
      l_trohdr_rec.request_number  := p_old_trohdr_rec.request_number;
    END IF;

    IF l_trohdr_rec.status_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.status_date  := p_old_trohdr_rec.status_date;
    END IF;

    IF l_trohdr_rec.to_account_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.to_account_id  := p_old_trohdr_rec.to_account_id;
    END IF;

    IF l_trohdr_rec.to_subinventory_code = fnd_api.g_miss_char THEN
      l_trohdr_rec.to_subinventory_code  := p_old_trohdr_rec.to_subinventory_code;
    END IF;

    IF l_trohdr_rec.move_order_type = fnd_api.g_miss_num THEN
      l_trohdr_rec.move_order_type  := p_old_trohdr_rec.move_order_type;
    END IF;

    IF l_trohdr_rec.transaction_type_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.transaction_type_id  := p_old_trohdr_rec.transaction_type_id;
    END IF;

    IF l_trohdr_rec.ship_to_location_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.ship_to_location_id  := p_old_trohdr_rec.ship_to_location_id;
    END IF;

    RETURN l_trohdr_rec;
  END complete_record;

  --  Function Convert_Miss_To_Null

  FUNCTION convert_miss_to_null(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type)
    RETURN inv_move_order_pub.trohdr_rec_type IS
    l_trohdr_rec inv_move_order_pub.trohdr_rec_type := p_trohdr_rec;
  BEGIN
    IF l_trohdr_rec.attribute1 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute1  := NULL;
    END IF;

    IF l_trohdr_rec.attribute10 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute10  := NULL;
    END IF;

    IF l_trohdr_rec.attribute11 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute11  := NULL;
    END IF;

    IF l_trohdr_rec.attribute12 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute12  := NULL;
    END IF;

    IF l_trohdr_rec.attribute13 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute13  := NULL;
    END IF;

    IF l_trohdr_rec.attribute14 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute14  := NULL;
    END IF;

    IF l_trohdr_rec.attribute15 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute15  := NULL;
    END IF;

    IF l_trohdr_rec.attribute2 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute2  := NULL;
    END IF;

    IF l_trohdr_rec.attribute3 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute3  := NULL;
    END IF;

    IF l_trohdr_rec.attribute4 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute4  := NULL;
    END IF;

    IF l_trohdr_rec.attribute5 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute5  := NULL;
    END IF;

    IF l_trohdr_rec.attribute6 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute6  := NULL;
    END IF;

    IF l_trohdr_rec.attribute7 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute7  := NULL;
    END IF;

    IF l_trohdr_rec.attribute8 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute8  := NULL;
    END IF;

    IF l_trohdr_rec.attribute9 = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute9  := NULL;
    END IF;

    IF l_trohdr_rec.attribute_category = fnd_api.g_miss_char THEN
      l_trohdr_rec.attribute_category  := NULL;
    END IF;

    IF l_trohdr_rec.created_by = fnd_api.g_miss_num THEN
      l_trohdr_rec.created_by  := NULL;
    END IF;

    IF l_trohdr_rec.creation_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.creation_date  := NULL;
    END IF;

    IF l_trohdr_rec.date_required = fnd_api.g_miss_date THEN
      l_trohdr_rec.date_required  := NULL;
    END IF;

    IF l_trohdr_rec.description = fnd_api.g_miss_char THEN
      l_trohdr_rec.description  := NULL;
    END IF;

    IF l_trohdr_rec.from_subinventory_code = fnd_api.g_miss_char THEN
      l_trohdr_rec.from_subinventory_code  := NULL;
    END IF;

    IF l_trohdr_rec.header_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.header_id  := NULL;
    END IF;

    IF l_trohdr_rec.header_status = fnd_api.g_miss_num THEN
      l_trohdr_rec.header_status  := NULL;
    END IF;

    IF l_trohdr_rec.last_updated_by = fnd_api.g_miss_num THEN
      l_trohdr_rec.last_updated_by  := NULL;
    END IF;

    IF l_trohdr_rec.last_update_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.last_update_date  := NULL;
    END IF;

    IF l_trohdr_rec.last_update_login = fnd_api.g_miss_num THEN
      l_trohdr_rec.last_update_login  := NULL;
    END IF;

    IF l_trohdr_rec.organization_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.organization_id  := NULL;
    END IF;

    IF l_trohdr_rec.program_application_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.program_application_id  := NULL;
    END IF;

    IF l_trohdr_rec.program_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.program_id  := NULL;
    END IF;

    IF l_trohdr_rec.program_update_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.program_update_date  := NULL;
    END IF;

    IF l_trohdr_rec.request_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.request_id  := NULL;
    END IF;

    IF l_trohdr_rec.request_number = fnd_api.g_miss_char THEN
      l_trohdr_rec.request_number  := NULL;
    END IF;

    IF l_trohdr_rec.status_date = fnd_api.g_miss_date THEN
      l_trohdr_rec.status_date  := NULL;
    END IF;

    IF l_trohdr_rec.to_account_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.to_account_id  := NULL;
    END IF;

    IF l_trohdr_rec.to_subinventory_code = fnd_api.g_miss_char THEN
      l_trohdr_rec.to_subinventory_code  := NULL;
    END IF;

    IF l_trohdr_rec.move_order_type = fnd_api.g_miss_num THEN
      l_trohdr_rec.move_order_type  := NULL;
    END IF;

    IF l_trohdr_rec.transaction_type_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.transaction_type_id  := NULL;
    END IF;

    IF l_trohdr_rec.ship_to_location_id = fnd_api.g_miss_num THEN
      l_trohdr_rec.ship_to_location_id  := NULL;
    END IF;

    RETURN l_trohdr_rec;
  END convert_miss_to_null;

  --  Bug#2536932: Function convert_miss_to_null for TROHDR_VAL_REC_TYPE

  FUNCTION convert_miss_to_null(p_trohdr_val_rec IN inv_move_order_pub.trohdr_val_rec_type)
     RETURN inv_move_order_pub.trohdr_val_rec_type IS
     l_trohdr_val_rec inv_move_order_pub.trohdr_val_rec_type := p_trohdr_val_rec;
  BEGIN
     IF l_trohdr_val_rec.from_subinventory = FND_API.g_miss_char THEN
        l_trohdr_val_rec.from_subinventory := NULL;
     END IF;

     IF l_trohdr_val_rec.header = FND_API.g_miss_char THEN
        l_trohdr_val_rec.header := NULL;
     END IF;

     IF l_trohdr_val_rec.ORGANIZATION = FND_API.g_miss_char THEN
        l_trohdr_val_rec.ORGANIZATION := NULL;
     END IF;

     IF l_trohdr_val_rec.to_account = FND_API.g_miss_char THEN
        l_trohdr_val_rec.to_account := NULL;
     END IF;

     IF l_trohdr_val_rec.to_subinventory = FND_API.g_miss_char THEN
        l_trohdr_val_rec.to_subinventory := NULL;
     END IF;

     IF l_trohdr_val_rec.move_order_type = FND_API.g_miss_char THEN
        l_trohdr_val_rec.move_order_type := NULL;
     END IF;

     IF l_trohdr_val_rec.transaction_type = FND_API.g_miss_char THEN
        l_trohdr_val_rec.transaction_type := NULL;
     END IF;

     RETURN l_trohdr_val_rec;
  END convert_miss_to_null;

  --  Procedure Update_Row

  PROCEDURE update_row(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type) IS
  BEGIN
    UPDATE mtl_txn_request_headers
       SET attribute1 = p_trohdr_rec.attribute1
         , attribute10 = p_trohdr_rec.attribute10
         , attribute11 = p_trohdr_rec.attribute11
         , attribute12 = p_trohdr_rec.attribute12
         , attribute13 = p_trohdr_rec.attribute13
         , attribute14 = p_trohdr_rec.attribute14
         , attribute15 = p_trohdr_rec.attribute15
         , attribute2 = p_trohdr_rec.attribute2
         , attribute3 = p_trohdr_rec.attribute3
         , attribute4 = p_trohdr_rec.attribute4
         , attribute5 = p_trohdr_rec.attribute5
         , attribute6 = p_trohdr_rec.attribute6
         , attribute7 = p_trohdr_rec.attribute7
         , attribute8 = p_trohdr_rec.attribute8
         , attribute9 = p_trohdr_rec.attribute9
         , attribute_category = p_trohdr_rec.attribute_category
         , created_by = p_trohdr_rec.created_by
         , creation_date = p_trohdr_rec.creation_date
         , date_required = p_trohdr_rec.date_required
         , description = p_trohdr_rec.description
         , from_subinventory_code = p_trohdr_rec.from_subinventory_code
         , header_id = p_trohdr_rec.header_id
         , header_status = p_trohdr_rec.header_status
         , last_updated_by = p_trohdr_rec.last_updated_by
         , last_update_date = p_trohdr_rec.last_update_date
         , last_update_login = p_trohdr_rec.last_update_login
         , organization_id = p_trohdr_rec.organization_id
         , program_application_id = p_trohdr_rec.program_application_id
         , program_id = p_trohdr_rec.program_id
         , program_update_date = p_trohdr_rec.program_update_date
         , request_id = p_trohdr_rec.request_id
         , request_number = p_trohdr_rec.request_number
         , status_date = p_trohdr_rec.status_date
         , to_account_id = p_trohdr_rec.to_account_id
         , to_subinventory_code = p_trohdr_rec.to_subinventory_code
         , move_order_type = p_trohdr_rec.move_order_type
         , transaction_type_id = p_trohdr_rec.transaction_type_id
         , ship_to_location_id = p_trohdr_rec.ship_to_location_id
     WHERE header_id = p_trohdr_rec.header_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_row;

  --  Procedure Insert_Row

  PROCEDURE insert_row(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type) IS
  BEGIN
    INSERT INTO mtl_txn_request_headers
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
              , description
              , from_subinventory_code
              , header_id
              , header_status
              , last_updated_by
              , last_update_date
              , last_update_login
              , organization_id
              , program_application_id
              , program_id
              , program_update_date
              , request_id
              , request_number
              , status_date
              , to_account_id
              , to_subinventory_code
              , move_order_type
              , transaction_type_id
              , grouping_rule_id
              , ship_to_location_id
                )
         VALUES (
                p_trohdr_rec.attribute1
              , p_trohdr_rec.attribute10
              , p_trohdr_rec.attribute11
              , p_trohdr_rec.attribute12
              , p_trohdr_rec.attribute13
              , p_trohdr_rec.attribute14
              , p_trohdr_rec.attribute15
              , p_trohdr_rec.attribute2
              , p_trohdr_rec.attribute3
              , p_trohdr_rec.attribute4
              , p_trohdr_rec.attribute5
              , p_trohdr_rec.attribute6
              , p_trohdr_rec.attribute7
              , p_trohdr_rec.attribute8
              , p_trohdr_rec.attribute9
              , p_trohdr_rec.attribute_category
              , p_trohdr_rec.created_by
              , p_trohdr_rec.creation_date
              , p_trohdr_rec.date_required
              , p_trohdr_rec.description
              , p_trohdr_rec.from_subinventory_code
              , p_trohdr_rec.header_id
              , p_trohdr_rec.header_status
              , p_trohdr_rec.last_updated_by
              , p_trohdr_rec.last_update_date
              , p_trohdr_rec.last_update_login
              , p_trohdr_rec.organization_id
              , p_trohdr_rec.program_application_id
              , p_trohdr_rec.program_id
              , p_trohdr_rec.program_update_date
              , p_trohdr_rec.request_id
              , p_trohdr_rec.request_number
              , p_trohdr_rec.status_date
              , p_trohdr_rec.to_account_id
              , p_trohdr_rec.to_subinventory_code
              , p_trohdr_rec.move_order_type
              , p_trohdr_rec.transaction_type_id
              , p_trohdr_rec.grouping_rule_id
              , p_trohdr_rec.ship_to_location_id
                );
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Insert_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END insert_row;

  --  Procedure Delete_Row

  PROCEDURE delete_row(p_header_id IN NUMBER) IS
  BEGIN
    DELETE FROM mtl_txn_request_headers
          WHERE header_id = p_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END delete_row;

  --  Procedure Update_Row_Status

  PROCEDURE update_row_status(p_header_id IN NUMBER, p_status IN NUMBER) IS
    l_trohdr_rec inv_move_order_pub.trohdr_rec_type;
  BEGIN
    l_trohdr_rec                    := inv_trohdr_util.query_row(p_header_id);
    l_trohdr_rec.header_status      := p_status;
    l_trohdr_rec.last_update_date   := SYSDATE;
    l_trohdr_rec.last_updated_by    := fnd_global.user_id;
    l_trohdr_rec.last_update_login  := fnd_global.login_id;
    inv_trohdr_util.update_row(l_trohdr_rec);
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Row_Status');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_row_status;

  --  Function Query_Row

  FUNCTION query_row(p_header_id IN NUMBER)
    RETURN inv_move_order_pub.trohdr_rec_type IS
    l_trohdr_rec inv_move_order_pub.trohdr_rec_type;
  BEGIN
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
         , description
         , from_subinventory_code
         , header_id
         , header_status
         , last_updated_by
         , last_update_date
         , last_update_login
         , organization_id
         , program_application_id
         , program_id
         , program_update_date
         , request_id
         , request_number
         , status_date
         , to_account_id
         , to_subinventory_code
         , move_order_type
         , transaction_type_id
         , grouping_rule_id
         , ship_to_location_id
      INTO l_trohdr_rec.attribute1
         , l_trohdr_rec.attribute10
         , l_trohdr_rec.attribute11
         , l_trohdr_rec.attribute12
         , l_trohdr_rec.attribute13
         , l_trohdr_rec.attribute14
         , l_trohdr_rec.attribute15
         , l_trohdr_rec.attribute2
         , l_trohdr_rec.attribute3
         , l_trohdr_rec.attribute4
         , l_trohdr_rec.attribute5
         , l_trohdr_rec.attribute6
         , l_trohdr_rec.attribute7
         , l_trohdr_rec.attribute8
         , l_trohdr_rec.attribute9
         , l_trohdr_rec.attribute_category
         , l_trohdr_rec.created_by
         , l_trohdr_rec.creation_date
         , l_trohdr_rec.date_required
         , l_trohdr_rec.description
         , l_trohdr_rec.from_subinventory_code
         , l_trohdr_rec.header_id
         , l_trohdr_rec.header_status
         , l_trohdr_rec.last_updated_by
         , l_trohdr_rec.last_update_date
         , l_trohdr_rec.last_update_login
         , l_trohdr_rec.organization_id
         , l_trohdr_rec.program_application_id
         , l_trohdr_rec.program_id
         , l_trohdr_rec.program_update_date
         , l_trohdr_rec.request_id
         , l_trohdr_rec.request_number
         , l_trohdr_rec.status_date
         , l_trohdr_rec.to_account_id
         , l_trohdr_rec.to_subinventory_code
         , l_trohdr_rec.move_order_type
         , l_trohdr_rec.transaction_type_id
         , l_trohdr_rec.grouping_rule_id
         , l_trohdr_rec.ship_to_location_id
      FROM mtl_txn_request_headers
     WHERE header_id = p_header_id;

    RETURN l_trohdr_rec;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Query_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END query_row;

  --  Procedure       lock_Row
  --

  PROCEDURE lock_row(x_return_status OUT NOCOPY VARCHAR2, p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, x_trohdr_rec IN OUT NOCOPY inv_move_order_pub.trohdr_rec_type) IS
    l_trohdr_rec inv_move_order_pub.trohdr_rec_type;
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
             , description
             , from_subinventory_code
             , header_id
             , header_status
             , last_updated_by
             , last_update_date
             , last_update_login
             , organization_id
             , program_application_id
             , program_id
             , program_update_date
             , request_id
             , request_number
             , status_date
             , to_account_id
             , to_subinventory_code
             , move_order_type
             , transaction_type_id
             , grouping_rule_id
             , ship_to_location_id
          INTO l_trohdr_rec.attribute1
             , l_trohdr_rec.attribute10
             , l_trohdr_rec.attribute11
             , l_trohdr_rec.attribute12
             , l_trohdr_rec.attribute13
             , l_trohdr_rec.attribute14
             , l_trohdr_rec.attribute15
             , l_trohdr_rec.attribute2
             , l_trohdr_rec.attribute3
             , l_trohdr_rec.attribute4
             , l_trohdr_rec.attribute5
             , l_trohdr_rec.attribute6
             , l_trohdr_rec.attribute7
             , l_trohdr_rec.attribute8
             , l_trohdr_rec.attribute9
             , l_trohdr_rec.attribute_category
             , l_trohdr_rec.created_by
             , l_trohdr_rec.creation_date
             , l_trohdr_rec.date_required
             , l_trohdr_rec.description
             , l_trohdr_rec.from_subinventory_code
             , l_trohdr_rec.header_id
             , l_trohdr_rec.header_status
             , l_trohdr_rec.last_updated_by
             , l_trohdr_rec.last_update_date
             , l_trohdr_rec.last_update_login
             , l_trohdr_rec.organization_id
             , l_trohdr_rec.program_application_id
             , l_trohdr_rec.program_id
             , l_trohdr_rec.program_update_date
             , l_trohdr_rec.request_id
             , l_trohdr_rec.request_number
             , l_trohdr_rec.status_date
             , l_trohdr_rec.to_account_id
             , l_trohdr_rec.to_subinventory_code
             , l_trohdr_rec.move_order_type
             , l_trohdr_rec.transaction_type_id
             , l_trohdr_rec.grouping_rule_id
             , l_trohdr_rec.ship_to_location_id
          FROM mtl_txn_request_headers
         WHERE header_id = p_trohdr_rec.header_id
    FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  inv_globals.equal(p_trohdr_rec.attribute1, l_trohdr_rec.attribute1)
        AND inv_globals.equal(p_trohdr_rec.attribute10, l_trohdr_rec.attribute10)
        AND inv_globals.equal(p_trohdr_rec.attribute11, l_trohdr_rec.attribute11)
        AND inv_globals.equal(p_trohdr_rec.attribute12, l_trohdr_rec.attribute12)
        AND inv_globals.equal(p_trohdr_rec.attribute13, l_trohdr_rec.attribute13)
        AND inv_globals.equal(p_trohdr_rec.attribute14, l_trohdr_rec.attribute14)
        AND inv_globals.equal(p_trohdr_rec.attribute15, l_trohdr_rec.attribute15)
        AND inv_globals.equal(p_trohdr_rec.attribute2, l_trohdr_rec.attribute2)
        AND inv_globals.equal(p_trohdr_rec.attribute3, l_trohdr_rec.attribute3)
        AND inv_globals.equal(p_trohdr_rec.attribute4, l_trohdr_rec.attribute4)
        AND inv_globals.equal(p_trohdr_rec.attribute5, l_trohdr_rec.attribute5)
        AND inv_globals.equal(p_trohdr_rec.attribute6, l_trohdr_rec.attribute6)
        AND inv_globals.equal(p_trohdr_rec.attribute7, l_trohdr_rec.attribute7)
        AND inv_globals.equal(p_trohdr_rec.attribute8, l_trohdr_rec.attribute8)
        AND inv_globals.equal(p_trohdr_rec.attribute9, l_trohdr_rec.attribute9)
        AND inv_globals.equal(p_trohdr_rec.attribute_category, l_trohdr_rec.attribute_category)
        AND inv_globals.equal(p_trohdr_rec.created_by, l_trohdr_rec.created_by)
        AND inv_globals.equal(p_trohdr_rec.creation_date, l_trohdr_rec.creation_date)
        AND inv_globals.equal(p_trohdr_rec.date_required, l_trohdr_rec.date_required)
        AND inv_globals.equal(p_trohdr_rec.description, l_trohdr_rec.description)
        AND inv_globals.equal(p_trohdr_rec.from_subinventory_code, l_trohdr_rec.from_subinventory_code)
        AND inv_globals.equal(p_trohdr_rec.header_id, l_trohdr_rec.header_id)
        AND inv_globals.equal(p_trohdr_rec.header_status, l_trohdr_rec.header_status)
        AND inv_globals.equal(p_trohdr_rec.last_updated_by, l_trohdr_rec.last_updated_by)
        AND inv_globals.equal(p_trohdr_rec.last_update_date, l_trohdr_rec.last_update_date)
        AND inv_globals.equal(p_trohdr_rec.last_update_login, l_trohdr_rec.last_update_login)
        AND inv_globals.equal(p_trohdr_rec.organization_id, l_trohdr_rec.organization_id)
        AND inv_globals.equal(p_trohdr_rec.program_application_id, l_trohdr_rec.program_application_id)
        AND inv_globals.equal(p_trohdr_rec.program_id, l_trohdr_rec.program_id)
        AND inv_globals.equal(p_trohdr_rec.program_update_date, l_trohdr_rec.program_update_date)
        AND inv_globals.equal(p_trohdr_rec.request_id, l_trohdr_rec.request_id)
        AND inv_globals.equal(p_trohdr_rec.request_number, l_trohdr_rec.request_number)
        AND inv_globals.equal(p_trohdr_rec.status_date, l_trohdr_rec.status_date)
        AND inv_globals.equal(p_trohdr_rec.to_account_id, l_trohdr_rec.to_account_id)
        AND inv_globals.equal(p_trohdr_rec.to_subinventory_code, l_trohdr_rec.to_subinventory_code)
        AND inv_globals.equal(p_trohdr_rec.move_order_type, l_trohdr_rec.move_order_type)
        AND inv_globals.equal(p_trohdr_rec.transaction_type_id, l_trohdr_rec.transaction_type_id)
        AND inv_globals.equal(p_trohdr_rec.grouping_rule_id, l_trohdr_rec.grouping_rule_id)
        AND inv_globals.equal(p_trohdr_rec.ship_to_location_id, l_trohdr_rec.ship_to_location_id) THEN
      --  Row has not changed. Set out parameter.

      x_trohdr_rec                := l_trohdr_rec;
      --  Set return status

      x_return_status             := fnd_api.g_ret_sts_success;
      x_trohdr_rec.return_status  := fnd_api.g_ret_sts_success;
    ELSE
      --  Row has changed by another user.

      x_return_status             := fnd_api.g_ret_sts_error;
      x_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_CHANGED');
        fnd_msg_pub.ADD;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status             := fnd_api.g_ret_sts_error;
      x_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_DELETED');
        fnd_msg_pub.ADD;
      END IF;
    WHEN app_exceptions.record_lock_exception THEN
      x_return_status             := fnd_api.g_ret_sts_error;
      x_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('INV', 'OE_LOCK_ROW_ALREADY_LOCKED');
        fnd_msg_pub.ADD;
      END IF;
    WHEN OTHERS THEN
      x_return_status             := fnd_api.g_ret_sts_unexp_error;
      x_trohdr_rec.return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Lock_Row');
      END IF;
  END lock_row;

  --  Function Get_Values

  FUNCTION get_values(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_old_trohdr_rec IN inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec)
    RETURN inv_move_order_pub.trohdr_val_rec_type IS
    l_trohdr_val_rec inv_move_order_pub.trohdr_val_rec_type;
  BEGIN
    --    IF p_trohdr_rec.from_subinventory_code IS NOT NULL AND
    --        p_trohdr_rec.from_subinventory_code <> FND_API.G_MISS_CHAR AND
    --        NOT INV_GLOBALS.Equal(p_trohdr_rec.from_subinventory_code,
    --        p_old_trohdr_rec.from_subinventory_code)
    --    THEN
    --        l_trohdr_val_rec.from_subinventory := INV_Id_To_Value.From_Subinventory
    --        (   p_from_subinventory_code      => p_trohdr_rec.from_subinventory_code
    --        );
    --    END IF;

    IF  p_trohdr_rec.header_id IS NOT NULL
        AND p_trohdr_rec.header_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trohdr_rec.header_id, p_old_trohdr_rec.header_id) THEN
      l_trohdr_val_rec.header  := inv_id_to_value.header(p_header_id => p_trohdr_rec.header_id);
    END IF;

    IF  p_trohdr_rec.organization_id IS NOT NULL
        AND p_trohdr_rec.organization_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trohdr_rec.organization_id, p_old_trohdr_rec.organization_id) THEN
      l_trohdr_val_rec.ORGANIZATION  := inv_id_to_value.ORGANIZATION(p_organization_id => p_trohdr_rec.organization_id);
    END IF;

    IF  p_trohdr_rec.to_account_id IS NOT NULL
        AND p_trohdr_rec.to_account_id <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trohdr_rec.to_account_id, p_old_trohdr_rec.to_account_id) THEN
      l_trohdr_val_rec.to_account  := inv_id_to_value.to_account(p_to_account_id => p_trohdr_rec.to_account_id);
    END IF;

    --    IF p_trohdr_rec.to_subinventory_code IS NOT NULL AND
    --        p_trohdr_rec.to_subinventory_code <> FND_API.G_MISS_CHAR AND
    --        NOT INV_GLOBALS.Equal(p_trohdr_rec.to_subinventory_code,
    --        p_old_trohdr_rec.to_subinventory_code)
    --    THEN
    --        l_trohdr_val_rec.to_subinventory := INV_Id_To_Value.To_Subinventory
    --        (   p_to_subinventory_code        => p_trohdr_rec.to_subinventory_code
    --        );
    --    END IF;

    IF  p_trohdr_rec.move_order_type IS NOT NULL
        AND p_trohdr_rec.move_order_type <> fnd_api.g_miss_num
        AND NOT inv_globals.equal(p_trohdr_rec.move_order_type, p_old_trohdr_rec.move_order_type) THEN
      l_trohdr_val_rec.move_order_type  := inv_id_to_value.move_order_type(p_move_order_type => p_trohdr_rec.move_order_type);
    END IF;

    /*IF p_trohdr_rec.transaction_type_id IS NOT NULL AND
        p_trohdr_rec.transaction_type_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_trohdr_rec.transaction_type_id,
        p_old_trohdr_rec.transaction_type_id)
    THEN
        l_trohdr_val_rec.transaction_type_id := INV_Id_To_Value.Transaction_Type_Id
        (   p_transaction_type_id         => p_trohdr_rec.transaction_type_id
        );
    END IF;*/

    RETURN l_trohdr_val_rec;
  END get_values;

  --  Function Get_Ids

  FUNCTION get_ids(p_trohdr_rec IN inv_move_order_pub.trohdr_rec_type, p_trohdr_val_rec IN inv_move_order_pub.trohdr_val_rec_type)
    RETURN inv_move_order_pub.trohdr_rec_type IS
    l_trohdr_rec inv_move_order_pub.trohdr_rec_type;
  BEGIN
    --  initialize  return_status.

    l_trohdr_rec.return_status  := fnd_api.g_ret_sts_success;
    --  initialize l_trohdr_rec.

    l_trohdr_rec                := p_trohdr_rec;

    IF p_trohdr_val_rec.from_subinventory <> fnd_api.g_miss_char THEN
      IF p_trohdr_rec.from_subinventory_code <> fnd_api.g_miss_char THEN
        l_trohdr_rec.from_subinventory_code  := p_trohdr_rec.from_subinventory_code;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'from_subinventory');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trohdr_rec.from_subinventory_code  := inv_value_to_id.from_subinventory(p_organization_id => p_trohdr_rec.organization_id, p_from_subinventory => p_trohdr_val_rec.from_subinventory);

        IF l_trohdr_rec.from_subinventory_code = fnd_api.g_miss_char THEN
          l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trohdr_val_rec.header <> fnd_api.g_miss_char THEN
      IF p_trohdr_rec.header_id <> fnd_api.g_miss_num THEN
        l_trohdr_rec.header_id  := p_trohdr_rec.header_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'header');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trohdr_rec.header_id  := inv_value_to_id.header(p_header => p_trohdr_val_rec.header);

        IF l_trohdr_rec.header_id = fnd_api.g_miss_num THEN
          l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trohdr_val_rec.ORGANIZATION <> fnd_api.g_miss_char THEN
      IF p_trohdr_rec.organization_id <> fnd_api.g_miss_num THEN
        l_trohdr_rec.organization_id  := p_trohdr_rec.organization_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'organization');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trohdr_rec.organization_id  := inv_value_to_id.ORGANIZATION(p_organization => p_trohdr_val_rec.ORGANIZATION);

        IF l_trohdr_rec.organization_id = fnd_api.g_miss_num THEN
          l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trohdr_val_rec.to_account <> fnd_api.g_miss_char THEN
      IF p_trohdr_rec.to_account_id <> fnd_api.g_miss_num THEN
        l_trohdr_rec.to_account_id  := p_trohdr_rec.to_account_id;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'to_account');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trohdr_rec.to_account_id  := inv_value_to_id.to_account(p_organization_id => p_trohdr_rec.organization_id, p_to_account => p_trohdr_val_rec.to_account);

        IF l_trohdr_rec.to_account_id = fnd_api.g_miss_num THEN
          l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trohdr_val_rec.to_subinventory <> fnd_api.g_miss_char THEN
      IF p_trohdr_rec.to_subinventory_code <> fnd_api.g_miss_char THEN
        l_trohdr_rec.to_subinventory_code  := p_trohdr_rec.to_subinventory_code;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'to_subinventory');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trohdr_rec.to_subinventory_code  := inv_value_to_id.to_subinventory(p_organization_id => p_trohdr_rec.organization_id, p_to_subinventory => p_trohdr_val_rec.to_subinventory);

        IF l_trohdr_rec.to_subinventory_code = fnd_api.g_miss_char THEN
          l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    IF p_trohdr_val_rec.move_order_type <> fnd_api.g_miss_char THEN
      IF p_trohdr_rec.move_order_type <> fnd_api.g_miss_num THEN
        l_trohdr_rec.move_order_type  := p_trohdr_rec.move_order_type;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
          fnd_message.set_name('INV', 'FND_BOTH_VAL_AND_ID_EXIST');
          fnd_message.set_token('ATTRIBUTE', 'move_order_type');
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        l_trohdr_rec.move_order_type  := inv_value_to_id.move_order_type(p_move_order_type => p_trohdr_val_rec.move_order_type);

        IF l_trohdr_rec.move_order_type = fnd_api.g_miss_num THEN
          l_trohdr_rec.return_status  := fnd_api.g_ret_sts_error;
        END IF;
      END IF;
    END IF;

    /*
            IF p_trohdr_rec.transaction_type_id <> FND_API.G_MISS_NUM THEN

                l_trohdr_rec.transaction_type_id := p_trohdr_rec.transaction_type_id;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                THEN

                    FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_type_id');
                    FND_MSG_PUB.Add;

                END IF;

            ELSE

                l_trohdr_rec.transaction_type_id := INV_Value_To_Id.transaction_type_id
                (   p_transaction_type_id            => p_trohdr_val_rec.transaction_type_id
                );
        END IF;
    */
    RETURN l_trohdr_rec;
  END get_ids;
END inv_trohdr_util;

/
