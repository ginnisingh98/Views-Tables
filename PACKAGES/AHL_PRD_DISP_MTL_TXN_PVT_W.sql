--------------------------------------------------------
--  DDL for Package AHL_PRD_DISP_MTL_TXN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DISP_MTL_TXN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWDMTS.pls 120.0 2005/05/26 00:00:31 appldev noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_prd_disp_mtl_txn_pvt.disp_mtl_txn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
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
    );
  procedure rosetta_table_copy_out_p2(t ahl_prd_disp_mtl_txn_pvt.disp_mtl_txn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
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
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_prd_disp_mtl_txn_pvt.disp_mtxn_assoc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_prd_disp_mtl_txn_pvt.disp_mtxn_assoc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_disp_mtl_txn(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_module  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_DATE_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_DATE_TABLE
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
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
  );
  procedure get_disp_for_mtl_txn(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_wo_mtl_txn_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_prd_disp_mtl_txn_pvt_w;

 

/
