--------------------------------------------------------
--  DDL for Package AHL_PP_MATERIALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PP_MATERIALS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPPMS.pls 120.2 2008/01/31 09:07:56 bachandr ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_pp_materials_pvt.req_material_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_3000
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ahl_pp_materials_pvt.req_material_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_3000
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_pp_materials_pvt.sch_material_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_pp_materials_pvt.sch_material_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_material_reqst(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_interface_flag  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a15 in out nocopy JTF_NUMBER_TABLE
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_DATE_TABLE
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_NUMBER_TABLE
    , p5_a29 in out nocopy JTF_NUMBER_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_NUMBER_TABLE
    , p5_a35 in out nocopy JTF_DATE_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_NUMBER_TABLE
    , p5_a40 in out nocopy JTF_NUMBER_TABLE
    , p5_a41 in out nocopy JTF_NUMBER_TABLE
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 in out nocopy JTF_NUMBER_TABLE
    , p5_a60 in out nocopy JTF_VARCHAR2_TABLE_3000
    , p5_a61 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_job_return_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure process_material_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a15 in out nocopy JTF_NUMBER_TABLE
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_DATE_TABLE
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_NUMBER_TABLE
    , p5_a29 in out nocopy JTF_NUMBER_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_NUMBER_TABLE
    , p5_a35 in out nocopy JTF_DATE_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_NUMBER_TABLE
    , p5_a40 in out nocopy JTF_NUMBER_TABLE
    , p5_a41 in out nocopy JTF_NUMBER_TABLE
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 in out nocopy JTF_NUMBER_TABLE
    , p5_a60 in out nocopy JTF_VARCHAR2_TABLE_3000
    , p5_a61 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure log_transaction_record(p_wo_operation_txn_id  NUMBER
    , p_object_version_number  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
    , p_load_type_code  NUMBER
    , p_transaction_type_code  NUMBER
    , p_workorder_operation_id  NUMBER
    , p_operation_resource_id  NUMBER
    , p_schedule_material_id  NUMBER
    , p_bom_resource_id  NUMBER
    , p_cost_basis_code  NUMBER
    , p_total_required  NUMBER
    , p_assigned_units  NUMBER
    , p_autocharge_type_code  NUMBER
    , p_standard_rate_flag_code  NUMBER
    , p_applied_resource_units  NUMBER
    , p_applied_resource_value  NUMBER
    , p_inventory_item_id  NUMBER
    , p_scheduled_quantity  NUMBER
    , p_scheduled_date  date
    , p_mrp_net_flag  NUMBER
    , p_quantity_per_assembly  NUMBER
    , p_required_quantity  NUMBER
    , p_supply_locator_id  NUMBER
    , p_supply_subinventory  NUMBER
    , p_date_required  date
    , p_operation_type_code  VARCHAR2
    , p_res_sched_start_date  date
    , p_res_sched_end_date  date
    , p_op_scheduled_start_date  date
    , p_op_scheduled_end_date  date
    , p_op_actual_start_date  date
    , p_op_actual_end_date  date
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
  procedure material_notification(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_300
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_DATE_TABLE
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_NUMBER_TABLE
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_NUMBER_TABLE
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_NUMBER_TABLE
    , p4_a35 JTF_DATE_TABLE
    , p4_a36 JTF_DATE_TABLE
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_NUMBER_TABLE
    , p4_a40 JTF_NUMBER_TABLE
    , p4_a41 JTF_NUMBER_TABLE
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_NUMBER_TABLE
    , p4_a60 JTF_VARCHAR2_TABLE_3000
    , p4_a61 JTF_VARCHAR2_TABLE_100
    , p4_a62 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_pp_materials_pvt_w;

/
