--------------------------------------------------------
--  DDL for Package OZF_CLAIM_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_LINE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwclns.pls 120.1 2007/12/26 10:36:00 kpatro ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_claim_line_pvt.claim_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_2000
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_VARCHAR2_TABLE_200
    , a72 JTF_VARCHAR2_TABLE_200
    , a73 JTF_VARCHAR2_TABLE_200
    , a74 JTF_VARCHAR2_TABLE_200
    , a75 JTF_VARCHAR2_TABLE_200
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_DATE_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ozf_claim_line_pvt.claim_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_VARCHAR2_TABLE_200
    , a72 out nocopy JTF_VARCHAR2_TABLE_200
    , a73 out nocopy JTF_VARCHAR2_TABLE_200
    , a74 out nocopy JTF_VARCHAR2_TABLE_200
    , a75 out nocopy JTF_VARCHAR2_TABLE_200
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure check_create_line_hist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  VARCHAR2
    , p6_a34  DATE
    , p6_a35  NUMBER
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  DATE
    , p6_a42  NUMBER
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  NUMBER
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  NUMBER
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  VARCHAR2
    , p6_a62  VARCHAR2
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  VARCHAR2
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  DATE
    , p6_a80  VARCHAR2
    , p6_a81  NUMBER
    , p6_a82  NUMBER
    , p6_a83  NUMBER
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  DATE
    , p6_a87  NUMBER
    , p6_a88  NUMBER
    , p6_a89  VARCHAR2
    , p_object_attribute  VARCHAR2
    , x_create_hist_flag out nocopy  VARCHAR2
  );
  procedure create_claim_line_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_VARCHAR2_TABLE_300
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_2000
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_200
    , p7_a62 JTF_VARCHAR2_TABLE_200
    , p7_a63 JTF_VARCHAR2_TABLE_200
    , p7_a64 JTF_VARCHAR2_TABLE_200
    , p7_a65 JTF_VARCHAR2_TABLE_200
    , p7_a66 JTF_VARCHAR2_TABLE_200
    , p7_a67 JTF_VARCHAR2_TABLE_200
    , p7_a68 JTF_VARCHAR2_TABLE_200
    , p7_a69 JTF_VARCHAR2_TABLE_200
    , p7_a70 JTF_VARCHAR2_TABLE_200
    , p7_a71 JTF_VARCHAR2_TABLE_200
    , p7_a72 JTF_VARCHAR2_TABLE_200
    , p7_a73 JTF_VARCHAR2_TABLE_200
    , p7_a74 JTF_VARCHAR2_TABLE_200
    , p7_a75 JTF_VARCHAR2_TABLE_200
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_VARCHAR2_TABLE_100
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_VARCHAR2_TABLE_100
    , p7_a85 JTF_VARCHAR2_TABLE_100
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_VARCHAR2_TABLE_100
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  );
  procedure create_claim_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  DATE
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  DATE
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  DATE
    , p7_a80  VARCHAR2
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  NUMBER
    , p7_a89  VARCHAR2
    , p_mode  VARCHAR2
    , x_claim_line_id out nocopy  NUMBER
  );
  procedure delete_claim_line_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_VARCHAR2_TABLE_300
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_2000
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_200
    , p7_a62 JTF_VARCHAR2_TABLE_200
    , p7_a63 JTF_VARCHAR2_TABLE_200
    , p7_a64 JTF_VARCHAR2_TABLE_200
    , p7_a65 JTF_VARCHAR2_TABLE_200
    , p7_a66 JTF_VARCHAR2_TABLE_200
    , p7_a67 JTF_VARCHAR2_TABLE_200
    , p7_a68 JTF_VARCHAR2_TABLE_200
    , p7_a69 JTF_VARCHAR2_TABLE_200
    , p7_a70 JTF_VARCHAR2_TABLE_200
    , p7_a71 JTF_VARCHAR2_TABLE_200
    , p7_a72 JTF_VARCHAR2_TABLE_200
    , p7_a73 JTF_VARCHAR2_TABLE_200
    , p7_a74 JTF_VARCHAR2_TABLE_200
    , p7_a75 JTF_VARCHAR2_TABLE_200
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_VARCHAR2_TABLE_100
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_VARCHAR2_TABLE_100
    , p7_a85 JTF_VARCHAR2_TABLE_100
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_VARCHAR2_TABLE_100
    , p_change_object_version  VARCHAR2
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  );
  procedure update_claim_line_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_VARCHAR2_TABLE_300
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_2000
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_200
    , p7_a62 JTF_VARCHAR2_TABLE_200
    , p7_a63 JTF_VARCHAR2_TABLE_200
    , p7_a64 JTF_VARCHAR2_TABLE_200
    , p7_a65 JTF_VARCHAR2_TABLE_200
    , p7_a66 JTF_VARCHAR2_TABLE_200
    , p7_a67 JTF_VARCHAR2_TABLE_200
    , p7_a68 JTF_VARCHAR2_TABLE_200
    , p7_a69 JTF_VARCHAR2_TABLE_200
    , p7_a70 JTF_VARCHAR2_TABLE_200
    , p7_a71 JTF_VARCHAR2_TABLE_200
    , p7_a72 JTF_VARCHAR2_TABLE_200
    , p7_a73 JTF_VARCHAR2_TABLE_200
    , p7_a74 JTF_VARCHAR2_TABLE_200
    , p7_a75 JTF_VARCHAR2_TABLE_200
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_VARCHAR2_TABLE_100
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_VARCHAR2_TABLE_100
    , p7_a85 JTF_VARCHAR2_TABLE_100
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_VARCHAR2_TABLE_100
    , p_change_object_version  VARCHAR2
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  );
  procedure update_claim_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  DATE
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  DATE
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  DATE
    , p7_a80  VARCHAR2
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  NUMBER
    , p7_a89  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version out nocopy  NUMBER
  );
  procedure validate_claim_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  VARCHAR2
    , p6_a34  DATE
    , p6_a35  NUMBER
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  DATE
    , p6_a42  NUMBER
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  NUMBER
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  NUMBER
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  VARCHAR2
    , p6_a62  VARCHAR2
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  VARCHAR2
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  DATE
    , p6_a80  VARCHAR2
    , p6_a81  NUMBER
    , p6_a82  NUMBER
    , p6_a83  NUMBER
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  DATE
    , p6_a87  NUMBER
    , p6_a88  NUMBER
    , p6_a89  VARCHAR2
  );
  procedure check_claim_line_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  DATE
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  DATE
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  DATE
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_claim_line_record(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  DATE
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  DATE
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  DATE
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  NUMBER
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  VARCHAR2
    , p1_a32  NUMBER
    , p1_a33  VARCHAR2
    , p1_a34  DATE
    , p1_a35  NUMBER
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  DATE
    , p1_a40  NUMBER
    , p1_a41  DATE
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  NUMBER
    , p1_a47  VARCHAR2
    , p1_a48  NUMBER
    , p1_a49  VARCHAR2
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  NUMBER
    , p1_a54  NUMBER
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  VARCHAR2
    , p1_a63  VARCHAR2
    , p1_a64  VARCHAR2
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  VARCHAR2
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  NUMBER
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  DATE
    , p1_a80  VARCHAR2
    , p1_a81  NUMBER
    , p1_a82  NUMBER
    , p1_a83  NUMBER
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  DATE
    , p1_a87  NUMBER
    , p1_a88  NUMBER
    , p1_a89  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_claim_line_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  DATE
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  DATE
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  DATE
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  DATE
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  VARCHAR2
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  VARCHAR2
    , p0_a63 out nocopy  VARCHAR2
    , p0_a64 out nocopy  VARCHAR2
    , p0_a65 out nocopy  VARCHAR2
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  VARCHAR2
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  DATE
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  NUMBER
    , p0_a82 out nocopy  NUMBER
    , p0_a83 out nocopy  NUMBER
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  DATE
    , p0_a87 out nocopy  NUMBER
    , p0_a88 out nocopy  NUMBER
    , p0_a89 out nocopy  VARCHAR2
  );
  procedure complete_claim_line_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  DATE
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  DATE
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  DATE
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  DATE
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  DATE
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  DATE
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  VARCHAR2
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  VARCHAR2
    , p1_a63 out nocopy  VARCHAR2
    , p1_a64 out nocopy  VARCHAR2
    , p1_a65 out nocopy  VARCHAR2
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  VARCHAR2
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  DATE
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  NUMBER
    , p1_a82 out nocopy  NUMBER
    , p1_a83 out nocopy  NUMBER
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  DATE
    , p1_a87 out nocopy  NUMBER
    , p1_a88 out nocopy  NUMBER
    , p1_a89 out nocopy  VARCHAR2
  );
end ozf_claim_line_pvt_w;

/
