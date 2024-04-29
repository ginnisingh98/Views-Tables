--------------------------------------------------------
--  DDL for Package AHL_UMP_SMRINSTANCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_SMRINSTANCE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLSMRWS.pls 120.1.12010000.2 2008/12/27 18:02:21 sracha ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_ump_smrinstance_pvt.results_mrinstance_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_4000
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t ahl_ump_smrinstance_pvt.results_mrinstance_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    );

  procedure search_mr_instances(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_start_row  NUMBER
    , p_rows_per_page  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  DATE
    , p8_a8  DATE
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_DATE_TABLE
    , p9_a8 out nocopy JTF_DATE_TABLE
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_DATE_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_NUMBER_TABLE
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , x_results_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_ump_smrinstance_pvt_w;

/
