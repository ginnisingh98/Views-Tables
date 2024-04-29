--------------------------------------------------------
--  DDL for Package AHL_OSP_ORDERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_ORDERS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLVOSWS.pls 120.2 2008/02/05 23:31:38 jaramana ship $ */
  procedure rosetta_table_copy_in_p27(t out nocopy ahl_osp_orders_pvt.osp_order_lines_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_2000
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p27(t ahl_osp_orders_pvt.osp_order_lines_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_NUMBER_TABLE
    );

  procedure process_osp_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  VARCHAR2
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  DATE
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  DATE
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  NUMBER
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  NUMBER
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  NUMBER
    , p5_a23 in out nocopy  NUMBER
    , p5_a24 in out nocopy  NUMBER
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  NUMBER
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  NUMBER
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  VARCHAR2
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_DATE_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_DATE_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 in out nocopy JTF_DATE_TABLE
    , p6_a13 in out nocopy JTF_DATE_TABLE
    , p6_a14 in out nocopy JTF_NUMBER_TABLE
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 in out nocopy JTF_NUMBER_TABLE
    , p6_a17 in out nocopy JTF_NUMBER_TABLE
    , p6_a18 in out nocopy JTF_NUMBER_TABLE
    , p6_a19 in out nocopy JTF_NUMBER_TABLE
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 in out nocopy JTF_NUMBER_TABLE
    , p6_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 in out nocopy JTF_NUMBER_TABLE
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 in out nocopy JTF_NUMBER_TABLE
    , p6_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_osp_orders_pvt_w;

/
