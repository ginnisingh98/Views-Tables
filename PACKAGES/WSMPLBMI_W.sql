--------------------------------------------------------
--  DDL for Package WSMPLBMI_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLBMI_W" AUTHID CURRENT_USER as
  /* $Header: WSMLBMWS.pls 120.0 2005/07/06 11:09 skaradib noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy wsmplbmi.t_sec_uom_code_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t wsmplbmi.t_sec_uom_code_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p1(t out nocopy wsmplbmi.t_sec_move_out_qty_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t wsmplbmi.t_sec_move_out_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy wsmplbmi.t_scrap_codes_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p2(t wsmplbmi.t_scrap_codes_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p3(t out nocopy wsmplbmi.t_scrap_code_qty_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p3(t wsmplbmi.t_scrap_code_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p4(t out nocopy wsmplbmi.t_bonus_codes_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p4(t wsmplbmi.t_bonus_codes_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p5(t out nocopy wsmplbmi.t_bonus_code_qty_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p5(t wsmplbmi.t_bonus_code_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p7(t out nocopy wsmplbmi.t_jobop_res_usages_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t wsmplbmi.t_jobop_res_usages_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p9(t out nocopy WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
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
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_DATE_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_VARCHAR2_TABLE_200
    , a72 JTF_VARCHAR2_TABLE_200
    , a73 JTF_VARCHAR2_TABLE_200
    , a74 JTF_VARCHAR2_TABLE_200
    , a75 JTF_VARCHAR2_TABLE_200
    , a76 JTF_VARCHAR2_TABLE_200
    , a77 JTF_VARCHAR2_TABLE_200
    , a78 JTF_VARCHAR2_TABLE_200
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p9(t WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_VARCHAR2_TABLE_200
    , a72 out nocopy JTF_VARCHAR2_TABLE_200
    , a73 out nocopy JTF_VARCHAR2_TABLE_200
    , a74 out nocopy JTF_VARCHAR2_TABLE_200
    , a75 out nocopy JTF_VARCHAR2_TABLE_200
    , a76 out nocopy JTF_VARCHAR2_TABLE_200
    , a77 out nocopy JTF_VARCHAR2_TABLE_200
    , a78 out nocopy JTF_VARCHAR2_TABLE_200
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure movetransaction(p_group_id  NUMBER
    , p_transaction_id  NUMBER
    , p_source_code  VARCHAR2
    , p_transaction_type  NUMBER
    , p_organization_id  NUMBER
    , p_wip_entity_id  NUMBER
    , p_wip_entity_name  VARCHAR2
    , p_primary_item_id  NUMBER
    , p_transaction_date  DATE
    , p_fm_operation_seq_num  NUMBER
    , p_fm_operation_code  VARCHAR2
    , p_fm_department_id  NUMBER
    , p_fm_department_code  VARCHAR2
    , p_fm_intraoperation_step_type  NUMBER
    , p_to_operation_seq_num  NUMBER
    , p_to_operation_code  VARCHAR2
    , p_to_department_id  NUMBER
    , p_to_department_code  VARCHAR2
    , p_to_intraoperation_step_type  NUMBER
    , p_primary_quantity  NUMBER
    , p_low_yield_trigger_limit  NUMBER
    , p_primary_uom  VARCHAR2
    , p_scrap_account_id  NUMBER
    , p_reason_id  NUMBER
    , p_reason_name  VARCHAR2
    , p_reference  VARCHAR2
    , p_qa_collection_id  NUMBER
    , p_jump_flag  VARCHAR2
    , p_header_id  NUMBER
    , p_primary_scrap_quantity  NUMBER
    , p_bonus_quantity  NUMBER
    , p_scrap_at_operation_flag  NUMBER
    , p_bonus_account_id  NUMBER
    , p_employee_id  NUMBER
    , p_operation_start_date  DATE
    , p_operation_completion_date  DATE
    , p_expected_completion_date  DATE
    , p_mtl_txn_hdr_id  NUMBER
    , p_sec_uom_code_tbl JTF_VARCHAR2_TABLE_100
    , p_sec_move_out_qty_tbl JTF_NUMBER_TABLE
    , p40_a0 JTF_VARCHAR2_TABLE_100
    , p40_a1 JTF_NUMBER_TABLE
    , p40_a2 JTF_NUMBER_TABLE
    , p40_a3 JTF_NUMBER_TABLE
    , p40_a4 JTF_NUMBER_TABLE
    , p40_a5 JTF_NUMBER_TABLE
    , p40_a6 JTF_VARCHAR2_TABLE_300
    , p40_a7 JTF_VARCHAR2_TABLE_300
    , p40_a8 JTF_NUMBER_TABLE
    , p40_a9 JTF_NUMBER_TABLE
    , p40_a10 JTF_VARCHAR2_TABLE_100
    , p40_a11 JTF_VARCHAR2_TABLE_100
    , p40_a12 JTF_DATE_TABLE
    , p40_a13 JTF_VARCHAR2_TABLE_200
    , p40_a14 JTF_VARCHAR2_TABLE_200
    , p40_a15 JTF_VARCHAR2_TABLE_200
    , p40_a16 JTF_VARCHAR2_TABLE_200
    , p40_a17 JTF_VARCHAR2_TABLE_200
    , p40_a18 JTF_VARCHAR2_TABLE_200
    , p40_a19 JTF_VARCHAR2_TABLE_200
    , p40_a20 JTF_VARCHAR2_TABLE_200
    , p40_a21 JTF_VARCHAR2_TABLE_200
    , p40_a22 JTF_VARCHAR2_TABLE_200
    , p40_a23 JTF_VARCHAR2_TABLE_200
    , p40_a24 JTF_VARCHAR2_TABLE_200
    , p40_a25 JTF_VARCHAR2_TABLE_200
    , p40_a26 JTF_VARCHAR2_TABLE_200
    , p40_a27 JTF_VARCHAR2_TABLE_200
    , p40_a28 JTF_VARCHAR2_TABLE_200
    , p40_a29 JTF_VARCHAR2_TABLE_200
    , p40_a30 JTF_VARCHAR2_TABLE_200
    , p40_a31 JTF_VARCHAR2_TABLE_200
    , p40_a32 JTF_VARCHAR2_TABLE_200
    , p40_a33 JTF_DATE_TABLE
    , p40_a34 JTF_DATE_TABLE
    , p40_a35 JTF_DATE_TABLE
    , p40_a36 JTF_DATE_TABLE
    , p40_a37 JTF_DATE_TABLE
    , p40_a38 JTF_DATE_TABLE
    , p40_a39 JTF_DATE_TABLE
    , p40_a40 JTF_DATE_TABLE
    , p40_a41 JTF_DATE_TABLE
    , p40_a42 JTF_DATE_TABLE
    , p40_a43 JTF_NUMBER_TABLE
    , p40_a44 JTF_NUMBER_TABLE
    , p40_a45 JTF_NUMBER_TABLE
    , p40_a46 JTF_NUMBER_TABLE
    , p40_a47 JTF_NUMBER_TABLE
    , p40_a48 JTF_NUMBER_TABLE
    , p40_a49 JTF_NUMBER_TABLE
    , p40_a50 JTF_NUMBER_TABLE
    , p40_a51 JTF_NUMBER_TABLE
    , p40_a52 JTF_NUMBER_TABLE
    , p40_a53 JTF_NUMBER_TABLE
    , p40_a54 JTF_NUMBER_TABLE
    , p40_a55 JTF_NUMBER_TABLE
    , p40_a56 JTF_NUMBER_TABLE
    , p40_a57 JTF_NUMBER_TABLE
    , p40_a58 JTF_NUMBER_TABLE
    , p40_a59 JTF_NUMBER_TABLE
    , p40_a60 JTF_NUMBER_TABLE
    , p40_a61 JTF_NUMBER_TABLE
    , p40_a62 JTF_NUMBER_TABLE
    , p40_a63 JTF_NUMBER_TABLE
    , p40_a64 JTF_NUMBER_TABLE
    , p40_a65 JTF_VARCHAR2_TABLE_100
    , p40_a66 JTF_VARCHAR2_TABLE_200
    , p40_a67 JTF_VARCHAR2_TABLE_200
    , p40_a68 JTF_VARCHAR2_TABLE_200
    , p40_a69 JTF_VARCHAR2_TABLE_200
    , p40_a70 JTF_VARCHAR2_TABLE_200
    , p40_a71 JTF_VARCHAR2_TABLE_200
    , p40_a72 JTF_VARCHAR2_TABLE_200
    , p40_a73 JTF_VARCHAR2_TABLE_200
    , p40_a74 JTF_VARCHAR2_TABLE_200
    , p40_a75 JTF_VARCHAR2_TABLE_200
    , p40_a76 JTF_VARCHAR2_TABLE_200
    , p40_a77 JTF_VARCHAR2_TABLE_200
    , p40_a78 JTF_VARCHAR2_TABLE_200
    , p40_a79 JTF_VARCHAR2_TABLE_200
    , p40_a80 JTF_VARCHAR2_TABLE_200
    , p41_a0 JTF_VARCHAR2_TABLE_100
    , p41_a1 JTF_NUMBER_TABLE
    , p41_a2 JTF_NUMBER_TABLE
    , p41_a3 JTF_NUMBER_TABLE
    , p41_a4 JTF_NUMBER_TABLE
    , p41_a5 JTF_NUMBER_TABLE
    , p41_a6 JTF_VARCHAR2_TABLE_300
    , p41_a7 JTF_VARCHAR2_TABLE_300
    , p41_a8 JTF_NUMBER_TABLE
    , p41_a9 JTF_NUMBER_TABLE
    , p41_a10 JTF_VARCHAR2_TABLE_100
    , p41_a11 JTF_VARCHAR2_TABLE_100
    , p41_a12 JTF_DATE_TABLE
    , p41_a13 JTF_VARCHAR2_TABLE_200
    , p41_a14 JTF_VARCHAR2_TABLE_200
    , p41_a15 JTF_VARCHAR2_TABLE_200
    , p41_a16 JTF_VARCHAR2_TABLE_200
    , p41_a17 JTF_VARCHAR2_TABLE_200
    , p41_a18 JTF_VARCHAR2_TABLE_200
    , p41_a19 JTF_VARCHAR2_TABLE_200
    , p41_a20 JTF_VARCHAR2_TABLE_200
    , p41_a21 JTF_VARCHAR2_TABLE_200
    , p41_a22 JTF_VARCHAR2_TABLE_200
    , p41_a23 JTF_VARCHAR2_TABLE_200
    , p41_a24 JTF_VARCHAR2_TABLE_200
    , p41_a25 JTF_VARCHAR2_TABLE_200
    , p41_a26 JTF_VARCHAR2_TABLE_200
    , p41_a27 JTF_VARCHAR2_TABLE_200
    , p41_a28 JTF_VARCHAR2_TABLE_200
    , p41_a29 JTF_VARCHAR2_TABLE_200
    , p41_a30 JTF_VARCHAR2_TABLE_200
    , p41_a31 JTF_VARCHAR2_TABLE_200
    , p41_a32 JTF_VARCHAR2_TABLE_200
    , p41_a33 JTF_DATE_TABLE
    , p41_a34 JTF_DATE_TABLE
    , p41_a35 JTF_DATE_TABLE
    , p41_a36 JTF_DATE_TABLE
    , p41_a37 JTF_DATE_TABLE
    , p41_a38 JTF_DATE_TABLE
    , p41_a39 JTF_DATE_TABLE
    , p41_a40 JTF_DATE_TABLE
    , p41_a41 JTF_DATE_TABLE
    , p41_a42 JTF_DATE_TABLE
    , p41_a43 JTF_NUMBER_TABLE
    , p41_a44 JTF_NUMBER_TABLE
    , p41_a45 JTF_NUMBER_TABLE
    , p41_a46 JTF_NUMBER_TABLE
    , p41_a47 JTF_NUMBER_TABLE
    , p41_a48 JTF_NUMBER_TABLE
    , p41_a49 JTF_NUMBER_TABLE
    , p41_a50 JTF_NUMBER_TABLE
    , p41_a51 JTF_NUMBER_TABLE
    , p41_a52 JTF_NUMBER_TABLE
    , p41_a53 JTF_NUMBER_TABLE
    , p41_a54 JTF_NUMBER_TABLE
    , p41_a55 JTF_NUMBER_TABLE
    , p41_a56 JTF_NUMBER_TABLE
    , p41_a57 JTF_NUMBER_TABLE
    , p41_a58 JTF_NUMBER_TABLE
    , p41_a59 JTF_NUMBER_TABLE
    , p41_a60 JTF_NUMBER_TABLE
    , p41_a61 JTF_NUMBER_TABLE
    , p41_a62 JTF_NUMBER_TABLE
    , p41_a63 JTF_NUMBER_TABLE
    , p41_a64 JTF_NUMBER_TABLE
    , p41_a65 JTF_VARCHAR2_TABLE_100
    , p41_a66 JTF_VARCHAR2_TABLE_200
    , p41_a67 JTF_VARCHAR2_TABLE_200
    , p41_a68 JTF_VARCHAR2_TABLE_200
    , p41_a69 JTF_VARCHAR2_TABLE_200
    , p41_a70 JTF_VARCHAR2_TABLE_200
    , p41_a71 JTF_VARCHAR2_TABLE_200
    , p41_a72 JTF_VARCHAR2_TABLE_200
    , p41_a73 JTF_VARCHAR2_TABLE_200
    , p41_a74 JTF_VARCHAR2_TABLE_200
    , p41_a75 JTF_VARCHAR2_TABLE_200
    , p41_a76 JTF_VARCHAR2_TABLE_200
    , p41_a77 JTF_VARCHAR2_TABLE_200
    , p41_a78 JTF_VARCHAR2_TABLE_200
    , p41_a79 JTF_VARCHAR2_TABLE_200
    , p41_a80 JTF_VARCHAR2_TABLE_200
    , p_scrap_codes_tbl JTF_VARCHAR2_TABLE_100
    , p_scrap_code_qty_tbl JTF_NUMBER_TABLE
    , p_bonus_codes_tbl JTF_VARCHAR2_TABLE_100
    , p_bonus_code_qty_tbl JTF_NUMBER_TABLE
    , p46_a0 JTF_NUMBER_TABLE
    , p46_a1 JTF_NUMBER_TABLE
    , p46_a2 JTF_NUMBER_TABLE
    , p46_a3 JTF_NUMBER_TABLE
    , p46_a4 JTF_NUMBER_TABLE
    , p46_a5 JTF_NUMBER_TABLE
    , p46_a6 JTF_NUMBER_TABLE
    , p46_a7 JTF_NUMBER_TABLE
    , p46_a8 JTF_VARCHAR2_TABLE_100
    , p46_a9 JTF_DATE_TABLE
    , p46_a10 JTF_NUMBER_TABLE
    , p46_a11 JTF_DATE_TABLE
    , p46_a12 JTF_NUMBER_TABLE
    , p46_a13 JTF_NUMBER_TABLE
    , p46_a14 JTF_NUMBER_TABLE
    , p46_a15 JTF_DATE_TABLE
    , p46_a16 JTF_DATE_TABLE
    , p46_a17 JTF_DATE_TABLE
    , p46_a18 JTF_NUMBER_TABLE
    , p46_a19 JTF_VARCHAR2_TABLE_100
    , p46_a20 JTF_NUMBER_TABLE
    , p46_a21 JTF_NUMBER_TABLE
    , p46_a22 JTF_VARCHAR2_TABLE_100
    , p46_a23 JTF_VARCHAR2_TABLE_100
    , p46_a24 JTF_NUMBER_TABLE
    , x_wip_move_api_sucess_msg out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end wsmplbmi_w;

 

/
