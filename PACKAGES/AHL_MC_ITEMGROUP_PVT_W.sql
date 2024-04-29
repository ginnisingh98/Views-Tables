--------------------------------------------------------
--  DDL for Package AHL_MC_ITEMGROUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_ITEMGROUP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLVIGWS.pls 120.1 2005/08/09 11:06 priyan noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_mc_itemgroup_pvt.item_association_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
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
    , a32 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ahl_mc_itemgroup_pvt.item_association_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  VARCHAR2
    , p6_a13 in out nocopy  VARCHAR2
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  VARCHAR2
    , p6_a16 in out nocopy  VARCHAR2
    , p6_a17 in out nocopy  VARCHAR2
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  VARCHAR2
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
    , p6_a23 in out nocopy  VARCHAR2
    , p6_a24 in out nocopy  VARCHAR2
    , p6_a25 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure modify_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure remove_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
  );
  procedure modify_position_assos(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_group_id  NUMBER
    , p_object_version_number  NUMBER
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p10_a7 JTF_VARCHAR2_TABLE_100
    , p10_a8 JTF_VARCHAR2_TABLE_100
    , p10_a9 JTF_VARCHAR2_TABLE_100
    , p10_a10 JTF_NUMBER_TABLE
    , p10_a11 JTF_NUMBER_TABLE
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_VARCHAR2_TABLE_100
    , p10_a14 JTF_NUMBER_TABLE
    , p10_a15 JTF_DATE_TABLE
    , p10_a16 JTF_DATE_TABLE
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_NUMBER_TABLE
    , p10_a19 JTF_VARCHAR2_TABLE_100
    , p10_a20 JTF_VARCHAR2_TABLE_200
    , p10_a21 JTF_VARCHAR2_TABLE_200
    , p10_a22 JTF_VARCHAR2_TABLE_200
    , p10_a23 JTF_VARCHAR2_TABLE_200
    , p10_a24 JTF_VARCHAR2_TABLE_200
    , p10_a25 JTF_VARCHAR2_TABLE_200
    , p10_a26 JTF_VARCHAR2_TABLE_200
    , p10_a27 JTF_VARCHAR2_TABLE_200
    , p10_a28 JTF_VARCHAR2_TABLE_200
    , p10_a29 JTF_VARCHAR2_TABLE_200
    , p10_a30 JTF_VARCHAR2_TABLE_200
    , p10_a31 JTF_VARCHAR2_TABLE_200
    , p10_a32 JTF_VARCHAR2_TABLE_200
    , p10_a33 JTF_VARCHAR2_TABLE_200
    , p10_a34 JTF_VARCHAR2_TABLE_200
    , p10_a35 JTF_VARCHAR2_TABLE_100
    , p10_a36 JTF_NUMBER_TABLE
  );
end ahl_mc_itemgroup_pvt_w;

 

/
