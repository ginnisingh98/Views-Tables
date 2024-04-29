--------------------------------------------------------
--  DDL for Package AHL_VWP_MR_CST_PR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_MR_CST_PR_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWMCPS.pls 120.1 2006/05/04 06:24 anraj noship $ */
  procedure estimate_mr_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure estimate_mr_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_mr_items_no_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  DATE
    , p8_a22  DATE
    , p8_a23  DATE
    , p8_a24  DATE
    , p8_a25  DATE
    , p8_a26  DATE
    , p8_a27  VARCHAR2
    , p8_a28  NUMBER
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  NUMBER
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  VARCHAR2
    , p8_a37  NUMBER
    , p8_a38  NUMBER
    , p8_a39  NUMBER
    , p8_a40  DATE
    , p8_a41  NUMBER
    , p8_a42  DATE
    , p8_a43  NUMBER
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  VARCHAR2
    , p8_a56  VARCHAR2
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_DATE_TABLE
    , p9_a22 out nocopy JTF_DATE_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_DATE_TABLE
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_DATE_TABLE
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_DATE_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure get_mr_cost_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_vwp_mr_cst_pr_pvt_w;

 

/
