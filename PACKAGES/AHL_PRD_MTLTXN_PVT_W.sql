--------------------------------------------------------
--  DDL for Package AHL_PRD_MTLTXN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_MTLTXN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWMTXS.pls 120.3.12010000.3 2008/11/19 06:06:38 jkjain ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy ahl_prd_mtltxn_pvt.ahl_mtltxn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
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
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p5(t ahl_prd_mtltxn_pvt.ahl_mtltxn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_prd_mtltxn_pvt.ahl_mtl_txn_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p6(t ahl_prd_mtltxn_pvt.ahl_mtl_txn_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure perform_mtl_txn(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_create_sr  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a17 in out nocopy JTF_NUMBER_TABLE
    , p7_a18 in out nocopy JTF_NUMBER_TABLE
    , p7_a19 in out nocopy JTF_NUMBER_TABLE
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 in out nocopy JTF_NUMBER_TABLE
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a25 in out nocopy JTF_NUMBER_TABLE
    , p7_a26 in out nocopy JTF_NUMBER_TABLE
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 in out nocopy JTF_NUMBER_TABLE
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a33 in out nocopy JTF_NUMBER_TABLE
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a35 in out nocopy JTF_NUMBER_TABLE
    , p7_a36 in out nocopy JTF_NUMBER_TABLE
    , p7_a37 in out nocopy JTF_DATE_TABLE
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_txn_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  NUMBER
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  NUMBER
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  VARCHAR2
    , p0_a22 in out nocopy  NUMBER
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  VARCHAR2
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  VARCHAR2
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  VARCHAR2
    , p0_a32 in out nocopy  VARCHAR2
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  NUMBER
    , p0_a37 in out nocopy  DATE
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  NUMBER
    , p0_a41 in out nocopy  VARCHAR2
    , p0_a42 in out nocopy  VARCHAR2
    , p0_a43 in out nocopy  VARCHAR2
    , p0_a44 in out nocopy  VARCHAR2
    , p0_a45 in out nocopy  VARCHAR2
    , p0_a46 in out nocopy  VARCHAR2
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  VARCHAR2
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  VARCHAR2
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  VARCHAR2
    , x_item_instance_id out nocopy  NUMBER
    , x_eam_item_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_mtl_trans_returns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  DATE
    , p9_a5  DATE
    , p9_a6  VARCHAR2
    , p9_a7  NUMBER
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  NUMBER
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_NUMBER_TABLE
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_NUMBER_TABLE
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 in out nocopy JTF_NUMBER_TABLE
    , p10_a18 in out nocopy JTF_NUMBER_TABLE
    , p10_a19 in out nocopy JTF_NUMBER_TABLE
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 in out nocopy JTF_NUMBER_TABLE
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a25 in out nocopy JTF_NUMBER_TABLE
    , p10_a26 in out nocopy JTF_NUMBER_TABLE
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p10_a30 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a33 in out nocopy JTF_NUMBER_TABLE
    , p10_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a35 in out nocopy JTF_NUMBER_TABLE
    , p10_a36 in out nocopy JTF_NUMBER_TABLE
    , p10_a37 in out nocopy JTF_DATE_TABLE
    , p10_a38 in out nocopy JTF_NUMBER_TABLE
    , p10_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 in out nocopy JTF_NUMBER_TABLE
    , p10_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a60 in out nocopy JTF_VARCHAR2_TABLE_200
  );
end ahl_prd_mtltxn_pvt_w;

/
