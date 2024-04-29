--------------------------------------------------------
--  DDL for Package AHL_UC_INSTANCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_INSTANCE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWUCIS.pls 120.1.12010000.4 2008/11/20 11:47:07 sathapli ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ahl_uc_instance_pvt.uc_child_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_uc_instance_pvt.uc_child_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_uc_instance_pvt.uc_descendant_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t ahl_uc_instance_pvt.uc_descendant_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_uc_instance_pvt.available_instance_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_400
    , a20 JTF_VARCHAR2_TABLE_400
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p7(t ahl_uc_instance_pvt.available_instance_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_400
    , a20 out nocopy JTF_VARCHAR2_TABLE_400
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure update_instance_attr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  DATE
    , p8_a14  DATE
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p_prod_user_flag  VARCHAR2
  );
  procedure install_new_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_prod_user_flag  VARCHAR2
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  VARCHAR2
    , p10_a3 in out nocopy  VARCHAR2
    , p10_a4 in out nocopy  NUMBER
    , p10_a5 in out nocopy  VARCHAR2
    , p10_a6 in out nocopy  VARCHAR2
    , p10_a7 in out nocopy  VARCHAR2
    , p10_a8 in out nocopy  VARCHAR2
    , p10_a9 in out nocopy  VARCHAR2
    , p10_a10 in out nocopy  NUMBER
    , p10_a11 in out nocopy  VARCHAR2
    , p10_a12 in out nocopy  VARCHAR2
    , p10_a13 in out nocopy  DATE
    , p10_a14 in out nocopy  DATE
    , p10_a15 in out nocopy  NUMBER
    , p10_a16 in out nocopy  NUMBER
    , p10_a17 in out nocopy  VARCHAR2
    , p10_a18 in out nocopy  VARCHAR2
    , p10_a19 in out nocopy  VARCHAR2
    , p10_a20 in out nocopy  VARCHAR2
    , p10_a21 in out nocopy  VARCHAR2
    , p10_a22 in out nocopy  VARCHAR2
    , p10_a23 in out nocopy  VARCHAR2
    , p10_a24 in out nocopy  VARCHAR2
    , p10_a25 in out nocopy  VARCHAR2
    , p10_a26 in out nocopy  VARCHAR2
    , p10_a27 in out nocopy  VARCHAR2
    , p10_a28 in out nocopy  VARCHAR2
    , p10_a29 in out nocopy  VARCHAR2
    , p10_a30 in out nocopy  VARCHAR2
    , p10_a31 in out nocopy  VARCHAR2
    , p10_a32 in out nocopy  VARCHAR2
    , p10_a33 in out nocopy  VARCHAR2
    , p10_a34 in out nocopy  VARCHAR2
    , p10_a35 in out nocopy  VARCHAR2
    , p10_a36 in out nocopy  VARCHAR2
    , p10_a37 in out nocopy  VARCHAR2
    , p10_a38 in out nocopy  VARCHAR2
    , p10_a39 in out nocopy  VARCHAR2
    , p10_a40 in out nocopy  VARCHAR2
    , p10_a41 in out nocopy  VARCHAR2
    , p10_a42 in out nocopy  VARCHAR2
    , p10_a43 in out nocopy  VARCHAR2
    , p10_a44 in out nocopy  VARCHAR2
    , p10_a45 in out nocopy  VARCHAR2
    , p10_a46 in out nocopy  VARCHAR2
    , p10_a47 in out nocopy  VARCHAR2
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  VARCHAR2
    , p11_a2 in out nocopy  NUMBER
    , p11_a3 in out nocopy  VARCHAR2
    , p11_a4 in out nocopy  VARCHAR2
    , p11_a5 in out nocopy  NUMBER
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  VARCHAR2
    , p11_a8 in out nocopy  NUMBER
    , p11_a9 in out nocopy  VARCHAR2
    , p11_a10 in out nocopy  DATE
    , p11_a11 in out nocopy  DATE
    , p11_a12 in out nocopy  NUMBER
    , p11_a13 in out nocopy  VARCHAR2
    , p11_a14 in out nocopy  VARCHAR2
    , p11_a15 in out nocopy  VARCHAR2
    , p11_a16 in out nocopy  VARCHAR2
    , p11_a17 in out nocopy  VARCHAR2
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  VARCHAR2
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
    , p11_a23 in out nocopy  VARCHAR2
    , p11_a24 in out nocopy  VARCHAR2
    , p11_a25 in out nocopy  VARCHAR2
    , p11_a26 in out nocopy  VARCHAR2
    , p11_a27 in out nocopy  VARCHAR2
    , p11_a28 in out nocopy  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure install_existing_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_instance_id  NUMBER
    , p_instance_number  VARCHAR2
    , p_relationship_id  NUMBER
    , p_csi_ii_ovn  NUMBER
    , p_prod_user_flag  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure swap_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_old_instance_id  NUMBER
    , p_new_instance_id  NUMBER
    , p_new_instance_number  VARCHAR2
    , p_relationship_id  NUMBER
    , p_csi_ii_ovn  NUMBER
    , p_prod_user_flag  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure get_available_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_parent_instance_id  NUMBER
    , p_relationship_id  NUMBER
    , p_item_number  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_instance_number  VARCHAR2
    , p_workorder_id  NUMBER
    , p_start_row_index  NUMBER
    , p_max_rows  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_NUMBER_TABLE
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_DATE_TABLE
    , p14_a15 out nocopy JTF_DATE_TABLE
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_NUMBER_TABLE
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_400
    , p14_a21 out nocopy JTF_NUMBER_TABLE
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a26 out nocopy JTF_NUMBER_TABLE
    , p14_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , p14_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a35 out nocopy JTF_NUMBER_TABLE
    , p14_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a37 out nocopy JTF_NUMBER_TABLE
    , p14_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , x_tbl_count out nocopy  NUMBER
  );
  procedure get_avail_subinv_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_relationship_id  NUMBER
    , p_item_number  VARCHAR2
    , p_serial_number  VARCHAR2
    , p_instance_number  VARCHAR2
    , p_workorder_id  NUMBER
    , p_start_row_index  NUMBER
    , p_max_rows  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_NUMBER_TABLE
    , p13_a13 out nocopy JTF_NUMBER_TABLE
    , p13_a14 out nocopy JTF_DATE_TABLE
    , p13_a15 out nocopy JTF_DATE_TABLE
    , p13_a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , p13_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a18 out nocopy JTF_NUMBER_TABLE
    , p13_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p13_a20 out nocopy JTF_VARCHAR2_TABLE_400
    , p13_a21 out nocopy JTF_NUMBER_TABLE
    , p13_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a23 out nocopy JTF_NUMBER_TABLE
    , p13_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a26 out nocopy JTF_NUMBER_TABLE
    , p13_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a29 out nocopy JTF_NUMBER_TABLE
    , p13_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a35 out nocopy JTF_NUMBER_TABLE
    , p13_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a37 out nocopy JTF_NUMBER_TABLE
    , p13_a38 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure create_unassigned_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_uc_header_id  NUMBER
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  VARCHAR2
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  DATE
    , p8_a14 in out nocopy  DATE
    , p8_a15 in out nocopy  NUMBER
    , p8_a16 in out nocopy  NUMBER
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p8_a29 in out nocopy  VARCHAR2
    , p8_a30 in out nocopy  VARCHAR2
    , p8_a31 in out nocopy  VARCHAR2
    , p8_a32 in out nocopy  VARCHAR2
    , p8_a33 in out nocopy  VARCHAR2
    , p8_a34 in out nocopy  VARCHAR2
    , p8_a35 in out nocopy  VARCHAR2
    , p8_a36 in out nocopy  VARCHAR2
    , p8_a37 in out nocopy  VARCHAR2
    , p8_a38 in out nocopy  VARCHAR2
    , p8_a39 in out nocopy  VARCHAR2
    , p8_a40 in out nocopy  VARCHAR2
    , p8_a41 in out nocopy  VARCHAR2
    , p8_a42 in out nocopy  VARCHAR2
    , p8_a43 in out nocopy  VARCHAR2
    , p8_a44 in out nocopy  VARCHAR2
    , p8_a45 in out nocopy  VARCHAR2
    , p8_a46 in out nocopy  VARCHAR2
    , p8_a47 in out nocopy  VARCHAR2
  );
end ahl_uc_instance_pvt_w;

/
