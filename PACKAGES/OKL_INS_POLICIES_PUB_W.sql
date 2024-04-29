--------------------------------------------------------
--  DDL for Package OKL_INS_POLICIES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_POLICIES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLOIPYS.pls 120.1 2005/09/22 10:15:23 pagarg noship $ */
  procedure insert_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_DATE_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_DATE_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
  );
  procedure insert_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  );
  procedure lock_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
  );
  procedure lock_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  );
  procedure update_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_DATE_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_DATE_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  );
  procedure delete_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
  );
  procedure delete_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  );
  procedure validate_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_300
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_300
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_VARCHAR2_TABLE_500
    , p5_a58 JTF_VARCHAR2_TABLE_500
    , p5_a59 JTF_VARCHAR2_TABLE_500
    , p5_a60 JTF_VARCHAR2_TABLE_500
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_DATE_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_DATE_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
  );
  procedure validate_ins_policies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  );
end okl_ins_policies_pub_w;

 

/
