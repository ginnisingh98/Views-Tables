--------------------------------------------------------
--  DDL for Package INV_LOT_EO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_EO_PVT" AUTHID CURRENT_USER as
  /* $Header: INVLTEOS.pls 120.1 2006/09/15 23:51:32 janetli noship $ */
    /*Exception definitions */
    g_exc_error                    EXCEPTION;
  g_exc_unexpected_error         EXCEPTION;

  procedure preprocess_lot(x_return_status out nocopy  VARCHAR2
      , x_msg_count out nocopy  NUMBER
      , x_msg_data out nocopy  VARCHAR2
      , p_inventory_item_id  NUMBER
      , p_organization_id  NUMBER
      , p_lot_number  VARCHAR2
      , p_parent_lot_number  VARCHAR2
      , p_reference_inventory_item_id NUMBER
      , p_reference_lot_number VARCHAR2    -- OSFM need this to inherite the attributes
      , p_source  NUMBER
      , x_is_new_lot out nocopy VARCHAR2
  );

  procedure delete_lot(x_return_status out nocopy  VARCHAR2
        , x_msg_count out nocopy  NUMBER
        , x_msg_data out nocopy  VARCHAR2
        , p_inventory_item_id  NUMBER
        , p_organization_id  NUMBER
        , p_lot_number  VARCHAR2
  );

  procedure rosetta_table_copy_in_p0(t out nocopy inv_lot_api_pub.char_tbl, a0 JTF_VARCHAR2_TABLE_1000);
  procedure rosetta_table_copy_out_p0(t inv_lot_api_pub.char_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_1000);

  procedure rosetta_table_copy_in_p1(t out nocopy inv_lot_api_pub.number_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t inv_lot_api_pub.number_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy inv_lot_api_pub.date_tbl, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p2(t inv_lot_api_pub.date_tbl, a0 out nocopy JTF_DATE_TABLE);

  procedure create_inv_lot(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_lot_number  VARCHAR2
    , p_expiration_date  DATE
    , p_disable_flag  NUMBER
    , p_attribute_category  VARCHAR2
    , p_lot_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_grade_code  VARCHAR2
    , p_origination_date  DATE
    , p_date_code  VARCHAR2
    , p_status_id  NUMBER
    , p_change_date  DATE
    , p_age  NUMBER
    , p_retest_date  DATE
    , p_maturity_date  DATE
    , p_item_size  NUMBER
    , p_color  VARCHAR2
    , p_volume  NUMBER
    , p_volume_uom  VARCHAR2
    , p_place_of_origin  VARCHAR2
    , p_best_by_date  DATE
    , p_length  NUMBER
    , p_length_uom  VARCHAR2
    , p_recycled_content  NUMBER
    , p_thickness  NUMBER
    , p_thickness_uom  VARCHAR2
    , p_width  NUMBER
    , p_width_uom  VARCHAR2
    , p_territory_code  VARCHAR2
    , p_supplier_lot_number  VARCHAR2
    , p_vendor_name  VARCHAR2
    , p_source  NUMBER
  );
  procedure update_inv_lot(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_lot_number  VARCHAR2
    , p_expiration_date  DATE
    , p_disable_flag  NUMBER
    , p_attribute_category  VARCHAR2
    , p_lot_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_grade_code  VARCHAR2
    , p_origination_date  DATE
    , p_date_code  VARCHAR2
    , p_status_id  NUMBER
    , p_change_date  DATE
    , p_age  NUMBER
    , p_retest_date  DATE
    , p_maturity_date  DATE
    , p_item_size  NUMBER
    , p_color  VARCHAR2
    , p_volume  NUMBER
    , p_volume_uom  VARCHAR2
    , p_place_of_origin  VARCHAR2
    , p_best_by_date  DATE
    , p_length  NUMBER
    , p_length_uom  VARCHAR2
    , p_recycled_content  NUMBER
    , p_thickness  NUMBER
    , p_thickness_uom  VARCHAR2
    , p_width  NUMBER
    , p_width_uom  VARCHAR2
    , p_territory_code  VARCHAR2
    , p_supplier_lot_number  VARCHAR2
    , p_vendor_name  VARCHAR2
    , p_source  NUMBER
  );
end  INV_LOT_EO_PVT;

 

/
