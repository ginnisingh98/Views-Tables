--------------------------------------------------------
--  DDL for Package OKL_INTERNAL_BILLING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTERNAL_BILLING_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEIARS.pls 120.0 2007/07/16 14:36:48 gkhuntet noship $ */
  procedure create_billing_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_3000
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_VARCHAR2_TABLE_500
    , p6_a37 JTF_VARCHAR2_TABLE_500
    , p6_a38 JTF_VARCHAR2_TABLE_500
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_DATE_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_NUMBER_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_3000
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_VARCHAR2_TABLE_100
    , p7_a17 JTF_VARCHAR2_TABLE_2000
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_DATE_TABLE
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_VARCHAR2_TABLE_500
    , p7_a28 JTF_VARCHAR2_TABLE_500
    , p7_a29 JTF_VARCHAR2_TABLE_500
    , p7_a30 JTF_VARCHAR2_TABLE_500
    , p7_a31 JTF_VARCHAR2_TABLE_500
    , p7_a32 JTF_VARCHAR2_TABLE_500
    , p7_a33 JTF_VARCHAR2_TABLE_500
    , p7_a34 JTF_VARCHAR2_TABLE_500
    , p7_a35 JTF_VARCHAR2_TABLE_500
    , p7_a36 JTF_VARCHAR2_TABLE_500
    , p7_a37 JTF_VARCHAR2_TABLE_500
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_DATE_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_VARCHAR2_TABLE_200
    , p7_a51 JTF_VARCHAR2_TABLE_200
    , p7_a52 JTF_DATE_TABLE
    , p7_a53 JTF_DATE_TABLE
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_3000
    , p7_a58 JTF_DATE_TABLE
    , p7_a59 JTF_VARCHAR2_TABLE_300
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_100
    , p7_a62 JTF_DATE_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  DATE
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  NUMBER
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  DATE
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  NUMBER
    , p8_a50 out nocopy  DATE
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  NUMBER
    , p8_a53 out nocopy  DATE
    , p8_a54 out nocopy  NUMBER
    , p8_a55 out nocopy  DATE
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  NUMBER
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  NUMBER
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  VARCHAR2
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_DATE_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_NUMBER_TABLE
    , p9_a46 out nocopy JTF_DATE_TABLE
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_DATE_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_DATE_TABLE
    , p9_a53 out nocopy JTF_NUMBER_TABLE
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_DATE_TABLE
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_NUMBER_TABLE
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_DATE_TABLE
    , p10_a42 out nocopy JTF_NUMBER_TABLE
    , p10_a43 out nocopy JTF_NUMBER_TABLE
    , p10_a44 out nocopy JTF_NUMBER_TABLE
    , p10_a45 out nocopy JTF_DATE_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_DATE_TABLE
    , p10_a48 out nocopy JTF_NUMBER_TABLE
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a52 out nocopy JTF_DATE_TABLE
    , p10_a53 out nocopy JTF_DATE_TABLE
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , p10_a58 out nocopy JTF_DATE_TABLE
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a62 out nocopy JTF_DATE_TABLE
    , p10_a63 out nocopy JTF_NUMBER_TABLE
    , p10_a64 out nocopy JTF_NUMBER_TABLE
    , p10_a65 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_manual_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_3000
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_VARCHAR2_TABLE_500
    , p6_a37 JTF_VARCHAR2_TABLE_500
    , p6_a38 JTF_VARCHAR2_TABLE_500
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_DATE_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_NUMBER_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  NUMBER
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  DATE
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  NUMBER
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  DATE
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  NUMBER
    , p7_a53 out nocopy  DATE
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  DATE
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  NUMBER
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  NUMBER
    , p7_a72 out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_DATE_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_DATE_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_DATE_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_DATE_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_DATE_TABLE
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_DATE_TABLE
    , p9_a42 out nocopy JTF_NUMBER_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_DATE_TABLE
    , p9_a46 out nocopy JTF_NUMBER_TABLE
    , p9_a47 out nocopy JTF_DATE_TABLE
    , p9_a48 out nocopy JTF_NUMBER_TABLE
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a52 out nocopy JTF_DATE_TABLE
    , p9_a53 out nocopy JTF_DATE_TABLE
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , p9_a58 out nocopy JTF_DATE_TABLE
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a62 out nocopy JTF_DATE_TABLE
    , p9_a63 out nocopy JTF_NUMBER_TABLE
    , p9_a64 out nocopy JTF_NUMBER_TABLE
    , p9_a65 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_internal_billing_pvt_w;

/
