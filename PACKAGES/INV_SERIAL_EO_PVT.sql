--------------------------------------------------------
--  DDL for Package INV_SERIAL_EO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SERIAL_EO_PVT" AUTHID CURRENT_USER as
  /* $Header: INVSNEOS.pls 120.1 2005/07/05 14:09 jxlu noship $ */
      /*Exception definitions */
    g_exc_error                    EXCEPTION;
    g_exc_unexpected_error         EXCEPTION;


 procedure preprocess_serial(x_return_status out nocopy  VARCHAR2
        , x_msg_count out nocopy  NUMBER
        , x_msg_data out nocopy  VARCHAR2
        , p_inventory_item_id  NUMBER
        , p_organization_id  NUMBER
        , p_lot_number  VARCHAR2
        , p_parent_lot_number  VARCHAR2
        , p_from_serial_number VARCHAR2
        , x_is_new_serial out nocopy VARCHAR2
        , p_revision VARCHAR2
        , p_to_serial_number VARCHAR2

  );

  procedure delete_serial(x_return_status out nocopy  VARCHAR2
              , x_msg_count out nocopy  NUMBER
              , x_msg_data out nocopy  VARCHAR2
              , p_inventory_item_id  NUMBER
              , p_organization_id  NUMBER
              , p_from_serial_number  VARCHAR2
              , p_to_serial_number VARCHAR2
    );

  procedure rosetta_table_copy_in_p0(t out nocopy inv_lot_api_pub.char_tbl, a0 JTF_VARCHAR2_TABLE_1000);
  procedure rosetta_table_copy_out_p0(t inv_lot_api_pub.char_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_1000);

  procedure rosetta_table_copy_in_p1(t out nocopy inv_lot_api_pub.number_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t inv_lot_api_pub.number_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy inv_lot_api_pub.date_tbl, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p2(t inv_lot_api_pub.date_tbl, a0 out nocopy JTF_DATE_TABLE);


  procedure insert_serial(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_serial_number  VARCHAR2
    , p_initialization_date  DATE
    , p_completion_date  DATE
    , p_ship_date  DATE
    , p_revision  VARCHAR2
    , p_lot_number  VARCHAR2
    , p_current_locator_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_trx_src_id  NUMBER
    , p_unit_vendor_id  NUMBER
    , p_vendor_lot_number  VARCHAR2
    , p_vendor_serial_number  VARCHAR2
    , p_receipt_issue_type  NUMBER
    , p_txn_src_id  NUMBER
    , p_txn_src_name  VARCHAR2
    , p_txn_src_type_id  NUMBER
    , p_transaction_id  NUMBER
    , p_current_status  NUMBER
    , p_parent_item_id  NUMBER
    , p_parent_serial_number  VARCHAR2
    , p_cost_group_id  NUMBER
    , p_transaction_action_id  NUMBER
    , p_transaction_temp_id  NUMBER
    , p_status_id  NUMBER
    , x_object_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_organization_type  NUMBER
    , p_owning_org_id  NUMBER
    , p_owning_tp_type  NUMBER
    , p_planning_org_id  NUMBER
    , p_planning_tp_type  NUMBER
    , p_wip_entity_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_intraoperation_step_type  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_serial_attribute_category VARCHAR2
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_origination_date  DATE
    , p_territory_code  VARCHAR2
  );
  procedure update_serial(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_serial_number  VARCHAR2
    , p_initialization_date  DATE
    , p_completion_date  DATE
    , p_ship_date  DATE
    , p_revision  VARCHAR2
    , p_lot_number  VARCHAR2
    , p_current_locator_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_trx_src_id  NUMBER
    , p_unit_vendor_id  NUMBER
    , p_vendor_lot_number  VARCHAR2
    , p_vendor_serial_number  VARCHAR2
    , p_receipt_issue_type  NUMBER
    , p_txn_src_id  NUMBER
    , p_txn_src_name  VARCHAR2
    , p_txn_src_type_id  NUMBER
    , p_current_status  NUMBER
    , p_parent_item_id  NUMBER
    , p_parent_serial_number  VARCHAR2
    , p_serial_temp_id  NUMBER
    , p_last_status  NUMBER
    , p_status_id  NUMBER
    , x_object_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_organization_type  NUMBER
    , p_owning_org_id  NUMBER
    , p_owning_tp_type  NUMBER
    , p_planning_org_id  NUMBER
    , p_planning_tp_type  NUMBER
    , p_transaction_action_id  NUMBER
    , p_wip_entity_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_intraoperation_step_type  NUMBER
    , p_line_mark_id  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_serial_attribute_category VARCHAR2
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_origination_date  DATE
    , p_territory_code  VARCHAR2
  );
end INV_SERIAL_EO_PVT;

 

/
