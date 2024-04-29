--------------------------------------------------------
--  DDL for Package CN_IMP_MAPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_MAPS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwimmps.pls 120.4 2006/03/23 00:42 hanaraya noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy cn_imp_maps_pvt.v_tbl_type, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p0(t cn_imp_maps_pvt.v_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure rosetta_table_copy_in_p6(t out nocopy cn_imp_maps_pvt.map_field_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p6(t cn_imp_maps_pvt.map_field_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure create_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_header_id  NUMBER
    , p_src_column_num  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  NUMBER
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  VARCHAR2
    , p9_a14  VARCHAR2
    , p9_a15  VARCHAR2
    , p9_a16  VARCHAR2
    , p9_a17  VARCHAR2
    , p9_a18  VARCHAR2
    , p9_a19  VARCHAR2
    , p9_a20  DATE
    , p9_a21  NUMBER
    , p9_a22  DATE
    , p9_a23  NUMBER
    , p9_a24  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_200
    , p10_a1 JTF_VARCHAR2_TABLE_200
    , p10_a2 JTF_VARCHAR2_TABLE_200
    , p_target_fields JTF_VARCHAR2_TABLE_200
    , x_imp_map_id out nocopy  NUMBER
    , p_org_id  NUMBER
  );
  procedure retrieve_fields(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_map_id  NUMBER
    , p_import_type_code  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , x_map_obj_num out nocopy  NUMBER
    , p_org_id  NUMBER
  );
  procedure create_imp_map(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , x_imp_map_id out nocopy  NUMBER
  );
  procedure delete_imp_map(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
  );
end cn_imp_maps_pvt_w;

 

/
