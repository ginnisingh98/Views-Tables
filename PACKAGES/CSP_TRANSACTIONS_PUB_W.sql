--------------------------------------------------------
--  DDL for Package CSP_TRANSACTIONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_TRANSACTIONS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csptppws.pls 120.1.12010000.6 2012/02/08 07:37:21 htank ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy csp_transactions_pub.trans_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t csp_transactions_pub.trans_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p17(t out nocopy csp_transactions_pub.csparray, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p17(t csp_transactions_pub.csparray, a0 out nocopy JTF_NUMBER_TABLE);

  procedure create_move_order_header(px_header_id in out nocopy  NUMBER
    , p_request_number  VARCHAR2
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_date_required  date
    , p_organization_id  NUMBER
    , p_from_subinventory_code  VARCHAR2
    , p_to_subinventory_code  VARCHAR2
    , p_address1  VARCHAR2
    , p_address2  VARCHAR2
    , p_address3  VARCHAR2
    , p_address4  VARCHAR2
    , p_city  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_state  VARCHAR2
    , p_province  VARCHAR2
    , p_country  VARCHAR2
    , p_freight_carrier  VARCHAR2
    , p_shipment_method  VARCHAR2
    , p_autoreceipt_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_move_order_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , px_line_id in out nocopy  NUMBER
    , p_header_id  NUMBER
    , p_organization_id  NUMBER
    , p_from_subinventory_code  VARCHAR2
    , p_from_locator_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_revision  VARCHAR2
    , p_lot_number  VARCHAR2
    , p_serial_number_start  VARCHAR2
    , p_serial_number_end  VARCHAR2
    , p_quantity  NUMBER
    , p_uom_code  VARCHAR2
    , p_quantity_delivered  NUMBER
    , p_to_subinventory_code  VARCHAR2
    , p_to_locator_id  VARCHAR2
    , p_to_organization_id  NUMBER
    , p_service_request  VARCHAR2
    , p_task_id  NUMBER
    , p_task_assignment_id  NUMBER
    , p_customer_po  VARCHAR2
    , p_date_required  date
    , p_comments  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure transact_material(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , px_transaction_id in out nocopy  NUMBER
    , px_transaction_header_id in out nocopy  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_locator_id  NUMBER
    , p_lot_number  VARCHAR2
    , p_lot_expiration_date  date
    , p_revision  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_to_serial_number  VARCHAR2
    , p_quantity  NUMBER
    , p_uom  VARCHAR2
    , p_source_id  VARCHAR2
    , p_source_line_id  NUMBER
    , p_transaction_type_id  NUMBER
    , p_account_id  NUMBER
    , p_transfer_to_subinventory  VARCHAR2
    , p_transfer_to_locator  NUMBER
    , p_transfer_to_organization  NUMBER
    , p_online_process_flag  number
    , p_transaction_source_id  NUMBER
    , p_trx_source_line_id  NUMBER
    , p_transaction_source_name  VARCHAR2
    , p_waybill_airbill  VARCHAR2
    , p_shipment_number  VARCHAR2
    , p_freight_code  VARCHAR2
    , p_reason_id  NUMBER
    , p_transaction_reference  VARCHAR2
    , p_transaction_date  date
    , p_expected_delivery_date  date
    , p_final_completion_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure transact_temp_record(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_temp_id  NUMBER
    , px_transaction_header_id in out nocopy  NUMBER
    , p_online_process_flag  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure transact_items_transfer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_NUMBER_TABLE
    , p3_a17 in out nocopy JTF_NUMBER_TABLE
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a19 in out nocopy JTF_NUMBER_TABLE
    , p3_a20 in out nocopy JTF_NUMBER_TABLE
    , p_trans_type_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure transact_subinv_transfer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_NUMBER_TABLE
    , p3_a17 in out nocopy JTF_NUMBER_TABLE
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a19 in out nocopy JTF_NUMBER_TABLE
    , p3_a20 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure transact_intorg_transfer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_NUMBER_TABLE
    , p3_a17 in out nocopy JTF_NUMBER_TABLE
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a19 in out nocopy JTF_NUMBER_TABLE
    , p3_a20 in out nocopy JTF_NUMBER_TABLE
    , p_if_intransit  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_move_order(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_NUMBER_TABLE
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a19 in out nocopy JTF_NUMBER_TABLE
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_date_required  date
    , p_comments  VARCHAR2
    , x_move_order_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure receive_requirement_trans(p_trans_header_id  NUMBER
    , p_trans_line_id  NUMBER
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  VARCHAR2
    , p2_a11  NUMBER
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
    , p2_a17  NUMBER
    , p2_a18  VARCHAR2
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p_trans_type  VARCHAR2
    , p_req_line_detail_id  NUMBER
    , p_close_short  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csp_transactions_pub_w;

/
