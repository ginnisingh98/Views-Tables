--------------------------------------------------------
--  DDL for Package CSP_EXCESS_LISTS_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_EXCESS_LISTS_PKG_W" AUTHID CURRENT_USER as
  /* $Header: csptexcws.pls 120.0.12010000.2 2010/11/15 11:37:55 htank noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy csp_excess_lists_pkg.excess_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t csp_excess_lists_pkg.excess_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure insert_row(px_excess_line_id in out nocopy  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_condition_code  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_excess_quantity  NUMBER
    , p_requisition_line_id  NUMBER
    , p_returned_quantity  NUMBER
    , p_current_return_qty  NUMBER
    , p_excess_status  VARCHAR2
    , p_return_org_id  NUMBER
    , p_return_sub_inv  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  );
  procedure update_row(p_excess_line_id  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_condition_code  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_excess_quantity  NUMBER
    , p_requisition_line_id  NUMBER
    , p_returned_quantity  NUMBER
    , p_current_return_qty  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  );
  procedure lock_row(p_excess_line_id  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_condition_code  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_excess_quantity  NUMBER
    , p_requisition_line_id  NUMBER
    , p_returned_quantity  NUMBER
    , p_current_return_qty  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  );
end csp_excess_lists_pkg_w;

/
