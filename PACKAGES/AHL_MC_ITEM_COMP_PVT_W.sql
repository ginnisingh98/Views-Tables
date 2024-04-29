--------------------------------------------------------
--  DDL for Package AHL_MC_ITEM_COMP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_ITEM_COMP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLVICWS.pls 115.1 2003/09/02 06:45:46 sjayacha noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_mc_item_comp_pvt.det_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a30 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ahl_mc_item_comp_pvt.det_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_item_composition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_DATE_TABLE
    , p8_a12 in out nocopy JTF_NUMBER_TABLE
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure modify_item_composition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_DATE_TABLE
    , p8_a12 in out nocopy JTF_NUMBER_TABLE
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_mc_item_comp_pvt_w;

 

/
