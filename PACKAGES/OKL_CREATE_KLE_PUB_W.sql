--------------------------------------------------------
--  DDL for Package OKL_CREATE_KLE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_KLE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUKLLS.pls 115.9 2004/02/05 00:12:58 avsingh noship $ */
  procedure update_fin_cap_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  NUMBER
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  DATE
    , p9_a31 out nocopy  DATE
    , p9_a32 out nocopy  DATE
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  NUMBER
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  VARCHAR2
    , p9_a40 out nocopy  VARCHAR2
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  VARCHAR2
    , p9_a43 out nocopy  VARCHAR2
    , p9_a44 out nocopy  VARCHAR2
    , p9_a45 out nocopy  VARCHAR2
    , p9_a46 out nocopy  VARCHAR2
    , p9_a47 out nocopy  VARCHAR2
    , p9_a48 out nocopy  VARCHAR2
    , p9_a49 out nocopy  VARCHAR2
    , p9_a50 out nocopy  VARCHAR2
    , p9_a51 out nocopy  VARCHAR2
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  DATE
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  DATE
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  NUMBER
    , p9_a69 out nocopy  NUMBER
    , p9_a70 out nocopy  DATE
    , p9_a71 out nocopy  NUMBER
    , p9_a72 out nocopy  DATE
    , p9_a73 out nocopy  NUMBER
    , p9_a74 out nocopy  NUMBER
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  VARCHAR2
    , p9_a80 out nocopy  VARCHAR2
    , p9_a81 out nocopy  NUMBER
    , p9_a82 out nocopy  VARCHAR2
    , p9_a83 out nocopy  NUMBER
    , p9_a84 out nocopy  NUMBER
    , p9_a85 out nocopy  NUMBER
    , p9_a86 out nocopy  NUMBER
    , p9_a87 out nocopy  VARCHAR2
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  NUMBER
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  NUMBER
    , p10_a19 out nocopy  NUMBER
    , p10_a20 out nocopy  DATE
    , p10_a21 out nocopy  DATE
    , p10_a22 out nocopy  NUMBER
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  DATE
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  NUMBER
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  NUMBER
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  NUMBER
    , p10_a32 out nocopy  NUMBER
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  DATE
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  DATE
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  NUMBER
    , p10_a39 out nocopy  NUMBER
    , p10_a40 out nocopy  NUMBER
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  DATE
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  DATE
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  DATE
    , p10_a48 out nocopy  DATE
    , p10_a49 out nocopy  DATE
    , p10_a50 out nocopy  NUMBER
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  NUMBER
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  NUMBER
    , p10_a58 out nocopy  DATE
    , p10_a59 out nocopy  NUMBER
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , p10_a67 out nocopy  VARCHAR2
    , p10_a68 out nocopy  VARCHAR2
    , p10_a69 out nocopy  VARCHAR2
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  VARCHAR2
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  VARCHAR2
    , p10_a75 out nocopy  VARCHAR2
    , p10_a76 out nocopy  NUMBER
    , p10_a77 out nocopy  NUMBER
    , p10_a78 out nocopy  NUMBER
    , p10_a79 out nocopy  DATE
    , p10_a80 out nocopy  NUMBER
    , p10_a81 out nocopy  DATE
    , p10_a82 out nocopy  NUMBER
    , p10_a83 out nocopy  DATE
    , p10_a84 out nocopy  DATE
    , p10_a85 out nocopy  DATE
    , p10_a86 out nocopy  DATE
    , p10_a87 out nocopy  NUMBER
    , p10_a88 out nocopy  NUMBER
    , p10_a89 out nocopy  NUMBER
    , p10_a90 out nocopy  VARCHAR2
    , p10_a91 out nocopy  NUMBER
    , p10_a92 out nocopy  VARCHAR2
    , p10_a93 out nocopy  NUMBER
    , p10_a94 out nocopy  NUMBER
    , p10_a95 out nocopy  DATE
    , p10_a96 out nocopy  VARCHAR2
    , p10_a97 out nocopy  VARCHAR2
    , p10_a98 out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  DATE := fnd_api.g_miss_date
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  DATE := fnd_api.g_miss_date
    , p8_a21  DATE := fnd_api.g_miss_date
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  DATE := fnd_api.g_miss_date
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  NUMBER := 0-1962.0724
    , p8_a28  NUMBER := 0-1962.0724
    , p8_a29  NUMBER := 0-1962.0724
    , p8_a30  NUMBER := 0-1962.0724
    , p8_a31  NUMBER := 0-1962.0724
    , p8_a32  NUMBER := 0-1962.0724
    , p8_a33  NUMBER := 0-1962.0724
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  DATE := fnd_api.g_miss_date
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  DATE := fnd_api.g_miss_date
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  DATE := fnd_api.g_miss_date
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  DATE := fnd_api.g_miss_date
    , p8_a48  DATE := fnd_api.g_miss_date
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  NUMBER := 0-1962.0724
    , p8_a58  DATE := fnd_api.g_miss_date
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  VARCHAR2 := fnd_api.g_miss_char
    , p8_a68  VARCHAR2 := fnd_api.g_miss_char
    , p8_a69  VARCHAR2 := fnd_api.g_miss_char
    , p8_a70  VARCHAR2 := fnd_api.g_miss_char
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  NUMBER := 0-1962.0724
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  DATE := fnd_api.g_miss_date
    , p8_a80  NUMBER := 0-1962.0724
    , p8_a81  DATE := fnd_api.g_miss_date
    , p8_a82  NUMBER := 0-1962.0724
    , p8_a83  DATE := fnd_api.g_miss_date
    , p8_a84  DATE := fnd_api.g_miss_date
    , p8_a85  DATE := fnd_api.g_miss_date
    , p8_a86  DATE := fnd_api.g_miss_date
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  VARCHAR2 := fnd_api.g_miss_char
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  NUMBER := 0-1962.0724
    , p8_a95  DATE := fnd_api.g_miss_date
    , p8_a96  VARCHAR2 := fnd_api.g_miss_char
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  NUMBER := 0-1962.0724
  );
  procedure create_add_on_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_DATE_TABLE
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_DATE_TABLE
    , p8_a27 JTF_NUMBER_TABLE
    , p8_a28 JTF_NUMBER_TABLE
    , p8_a29 JTF_NUMBER_TABLE
    , p8_a30 JTF_NUMBER_TABLE
    , p8_a31 JTF_NUMBER_TABLE
    , p8_a32 JTF_NUMBER_TABLE
    , p8_a33 JTF_NUMBER_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_VARCHAR2_TABLE_100
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_DATE_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_DATE_TABLE
    , p8_a48 JTF_DATE_TABLE
    , p8_a49 JTF_DATE_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_VARCHAR2_TABLE_100
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_VARCHAR2_TABLE_100
    , p8_a56 JTF_VARCHAR2_TABLE_100
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_DATE_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_VARCHAR2_TABLE_100
    , p8_a61 JTF_VARCHAR2_TABLE_500
    , p8_a62 JTF_VARCHAR2_TABLE_500
    , p8_a63 JTF_VARCHAR2_TABLE_500
    , p8_a64 JTF_VARCHAR2_TABLE_500
    , p8_a65 JTF_VARCHAR2_TABLE_500
    , p8_a66 JTF_VARCHAR2_TABLE_500
    , p8_a67 JTF_VARCHAR2_TABLE_500
    , p8_a68 JTF_VARCHAR2_TABLE_500
    , p8_a69 JTF_VARCHAR2_TABLE_500
    , p8_a70 JTF_VARCHAR2_TABLE_500
    , p8_a71 JTF_VARCHAR2_TABLE_500
    , p8_a72 JTF_VARCHAR2_TABLE_500
    , p8_a73 JTF_VARCHAR2_TABLE_500
    , p8_a74 JTF_VARCHAR2_TABLE_500
    , p8_a75 JTF_VARCHAR2_TABLE_500
    , p8_a76 JTF_NUMBER_TABLE
    , p8_a77 JTF_NUMBER_TABLE
    , p8_a78 JTF_NUMBER_TABLE
    , p8_a79 JTF_DATE_TABLE
    , p8_a80 JTF_NUMBER_TABLE
    , p8_a81 JTF_DATE_TABLE
    , p8_a82 JTF_NUMBER_TABLE
    , p8_a83 JTF_DATE_TABLE
    , p8_a84 JTF_DATE_TABLE
    , p8_a85 JTF_DATE_TABLE
    , p8_a86 JTF_DATE_TABLE
    , p8_a87 JTF_NUMBER_TABLE
    , p8_a88 JTF_NUMBER_TABLE
    , p8_a89 JTF_NUMBER_TABLE
    , p8_a90 JTF_VARCHAR2_TABLE_100
    , p8_a91 JTF_NUMBER_TABLE
    , p8_a92 JTF_VARCHAR2_TABLE_100
    , p8_a93 JTF_NUMBER_TABLE
    , p8_a94 JTF_NUMBER_TABLE
    , p8_a95 JTF_DATE_TABLE
    , p8_a96 JTF_VARCHAR2_TABLE_100
    , p8_a97 JTF_VARCHAR2_TABLE_100
    , p8_a98 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_DATE_TABLE
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_DATE_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_DATE_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_DATE_TABLE
    , p11_a21 out nocopy JTF_DATE_TABLE
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_NUMBER_TABLE
    , p11_a24 out nocopy JTF_DATE_TABLE
    , p11_a25 out nocopy JTF_DATE_TABLE
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_NUMBER_TABLE
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p11_a29 out nocopy JTF_NUMBER_TABLE
    , p11_a30 out nocopy JTF_NUMBER_TABLE
    , p11_a31 out nocopy JTF_NUMBER_TABLE
    , p11_a32 out nocopy JTF_NUMBER_TABLE
    , p11_a33 out nocopy JTF_NUMBER_TABLE
    , p11_a34 out nocopy JTF_DATE_TABLE
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a38 out nocopy JTF_NUMBER_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a42 out nocopy JTF_DATE_TABLE
    , p11_a43 out nocopy JTF_NUMBER_TABLE
    , p11_a44 out nocopy JTF_NUMBER_TABLE
    , p11_a45 out nocopy JTF_DATE_TABLE
    , p11_a46 out nocopy JTF_NUMBER_TABLE
    , p11_a47 out nocopy JTF_DATE_TABLE
    , p11_a48 out nocopy JTF_DATE_TABLE
    , p11_a49 out nocopy JTF_DATE_TABLE
    , p11_a50 out nocopy JTF_NUMBER_TABLE
    , p11_a51 out nocopy JTF_NUMBER_TABLE
    , p11_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a53 out nocopy JTF_NUMBER_TABLE
    , p11_a54 out nocopy JTF_NUMBER_TABLE
    , p11_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a57 out nocopy JTF_NUMBER_TABLE
    , p11_a58 out nocopy JTF_DATE_TABLE
    , p11_a59 out nocopy JTF_NUMBER_TABLE
    , p11_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a76 out nocopy JTF_NUMBER_TABLE
    , p11_a77 out nocopy JTF_NUMBER_TABLE
    , p11_a78 out nocopy JTF_NUMBER_TABLE
    , p11_a79 out nocopy JTF_DATE_TABLE
    , p11_a80 out nocopy JTF_NUMBER_TABLE
    , p11_a81 out nocopy JTF_DATE_TABLE
    , p11_a82 out nocopy JTF_NUMBER_TABLE
    , p11_a83 out nocopy JTF_DATE_TABLE
    , p11_a84 out nocopy JTF_DATE_TABLE
    , p11_a85 out nocopy JTF_DATE_TABLE
    , p11_a86 out nocopy JTF_DATE_TABLE
    , p11_a87 out nocopy JTF_NUMBER_TABLE
    , p11_a88 out nocopy JTF_NUMBER_TABLE
    , p11_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a91 out nocopy JTF_NUMBER_TABLE
    , p11_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a93 out nocopy JTF_NUMBER_TABLE
    , p11_a94 out nocopy JTF_NUMBER_TABLE
    , p11_a95 out nocopy JTF_DATE_TABLE
    , p11_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a98 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  NUMBER
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  NUMBER
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  NUMBER
    , p12_a19 out nocopy  NUMBER
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  NUMBER
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  DATE
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  DATE
    , p12_a31 out nocopy  DATE
    , p12_a32 out nocopy  DATE
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , p12_a45 out nocopy  VARCHAR2
    , p12_a46 out nocopy  VARCHAR2
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  VARCHAR2
    , p12_a50 out nocopy  VARCHAR2
    , p12_a51 out nocopy  VARCHAR2
    , p12_a52 out nocopy  VARCHAR2
    , p12_a53 out nocopy  VARCHAR2
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  DATE
    , p12_a56 out nocopy  NUMBER
    , p12_a57 out nocopy  DATE
    , p12_a58 out nocopy  VARCHAR2
    , p12_a59 out nocopy  VARCHAR2
    , p12_a60 out nocopy  VARCHAR2
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  VARCHAR2
    , p12_a63 out nocopy  VARCHAR2
    , p12_a64 out nocopy  VARCHAR2
    , p12_a65 out nocopy  VARCHAR2
    , p12_a66 out nocopy  VARCHAR2
    , p12_a67 out nocopy  NUMBER
    , p12_a68 out nocopy  NUMBER
    , p12_a69 out nocopy  NUMBER
    , p12_a70 out nocopy  DATE
    , p12_a71 out nocopy  NUMBER
    , p12_a72 out nocopy  DATE
    , p12_a73 out nocopy  NUMBER
    , p12_a74 out nocopy  NUMBER
    , p12_a75 out nocopy  VARCHAR2
    , p12_a76 out nocopy  VARCHAR2
    , p12_a77 out nocopy  NUMBER
    , p12_a78 out nocopy  NUMBER
    , p12_a79 out nocopy  VARCHAR2
    , p12_a80 out nocopy  VARCHAR2
    , p12_a81 out nocopy  NUMBER
    , p12_a82 out nocopy  VARCHAR2
    , p12_a83 out nocopy  NUMBER
    , p12_a84 out nocopy  NUMBER
    , p12_a85 out nocopy  NUMBER
    , p12_a86 out nocopy  NUMBER
    , p12_a87 out nocopy  VARCHAR2
    , p12_a88 out nocopy  NUMBER
    , p12_a89 out nocopy  NUMBER
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  VARCHAR2
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  NUMBER
    , p13_a8 out nocopy  NUMBER
    , p13_a9 out nocopy  DATE
    , p13_a10 out nocopy  NUMBER
    , p13_a11 out nocopy  NUMBER
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  NUMBER
    , p13_a14 out nocopy  NUMBER
    , p13_a15 out nocopy  NUMBER
    , p13_a16 out nocopy  NUMBER
    , p13_a17 out nocopy  NUMBER
    , p13_a18 out nocopy  NUMBER
    , p13_a19 out nocopy  NUMBER
    , p13_a20 out nocopy  DATE
    , p13_a21 out nocopy  DATE
    , p13_a22 out nocopy  NUMBER
    , p13_a23 out nocopy  NUMBER
    , p13_a24 out nocopy  DATE
    , p13_a25 out nocopy  DATE
    , p13_a26 out nocopy  DATE
    , p13_a27 out nocopy  NUMBER
    , p13_a28 out nocopy  NUMBER
    , p13_a29 out nocopy  NUMBER
    , p13_a30 out nocopy  NUMBER
    , p13_a31 out nocopy  NUMBER
    , p13_a32 out nocopy  NUMBER
    , p13_a33 out nocopy  NUMBER
    , p13_a34 out nocopy  DATE
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  DATE
    , p13_a37 out nocopy  VARCHAR2
    , p13_a38 out nocopy  NUMBER
    , p13_a39 out nocopy  NUMBER
    , p13_a40 out nocopy  NUMBER
    , p13_a41 out nocopy  VARCHAR2
    , p13_a42 out nocopy  DATE
    , p13_a43 out nocopy  NUMBER
    , p13_a44 out nocopy  NUMBER
    , p13_a45 out nocopy  DATE
    , p13_a46 out nocopy  NUMBER
    , p13_a47 out nocopy  DATE
    , p13_a48 out nocopy  DATE
    , p13_a49 out nocopy  DATE
    , p13_a50 out nocopy  NUMBER
    , p13_a51 out nocopy  NUMBER
    , p13_a52 out nocopy  VARCHAR2
    , p13_a53 out nocopy  NUMBER
    , p13_a54 out nocopy  NUMBER
    , p13_a55 out nocopy  VARCHAR2
    , p13_a56 out nocopy  VARCHAR2
    , p13_a57 out nocopy  NUMBER
    , p13_a58 out nocopy  DATE
    , p13_a59 out nocopy  NUMBER
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  VARCHAR2
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p13_a66 out nocopy  VARCHAR2
    , p13_a67 out nocopy  VARCHAR2
    , p13_a68 out nocopy  VARCHAR2
    , p13_a69 out nocopy  VARCHAR2
    , p13_a70 out nocopy  VARCHAR2
    , p13_a71 out nocopy  VARCHAR2
    , p13_a72 out nocopy  VARCHAR2
    , p13_a73 out nocopy  VARCHAR2
    , p13_a74 out nocopy  VARCHAR2
    , p13_a75 out nocopy  VARCHAR2
    , p13_a76 out nocopy  NUMBER
    , p13_a77 out nocopy  NUMBER
    , p13_a78 out nocopy  NUMBER
    , p13_a79 out nocopy  DATE
    , p13_a80 out nocopy  NUMBER
    , p13_a81 out nocopy  DATE
    , p13_a82 out nocopy  NUMBER
    , p13_a83 out nocopy  DATE
    , p13_a84 out nocopy  DATE
    , p13_a85 out nocopy  DATE
    , p13_a86 out nocopy  DATE
    , p13_a87 out nocopy  NUMBER
    , p13_a88 out nocopy  NUMBER
    , p13_a89 out nocopy  NUMBER
    , p13_a90 out nocopy  VARCHAR2
    , p13_a91 out nocopy  NUMBER
    , p13_a92 out nocopy  VARCHAR2
    , p13_a93 out nocopy  NUMBER
    , p13_a94 out nocopy  NUMBER
    , p13_a95 out nocopy  DATE
    , p13_a96 out nocopy  VARCHAR2
    , p13_a97 out nocopy  VARCHAR2
    , p13_a98 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_NUMBER_TABLE
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_NUMBER_TABLE
    , p14_a16 out nocopy JTF_DATE_TABLE
    , p14_a17 out nocopy JTF_NUMBER_TABLE
    , p14_a18 out nocopy JTF_DATE_TABLE
    , p14_a19 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_add_on_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_DATE_TABLE
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_DATE_TABLE
    , p8_a27 JTF_NUMBER_TABLE
    , p8_a28 JTF_NUMBER_TABLE
    , p8_a29 JTF_NUMBER_TABLE
    , p8_a30 JTF_NUMBER_TABLE
    , p8_a31 JTF_NUMBER_TABLE
    , p8_a32 JTF_NUMBER_TABLE
    , p8_a33 JTF_NUMBER_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_VARCHAR2_TABLE_100
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_DATE_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_DATE_TABLE
    , p8_a48 JTF_DATE_TABLE
    , p8_a49 JTF_DATE_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_VARCHAR2_TABLE_100
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_VARCHAR2_TABLE_100
    , p8_a56 JTF_VARCHAR2_TABLE_100
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_DATE_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_VARCHAR2_TABLE_100
    , p8_a61 JTF_VARCHAR2_TABLE_500
    , p8_a62 JTF_VARCHAR2_TABLE_500
    , p8_a63 JTF_VARCHAR2_TABLE_500
    , p8_a64 JTF_VARCHAR2_TABLE_500
    , p8_a65 JTF_VARCHAR2_TABLE_500
    , p8_a66 JTF_VARCHAR2_TABLE_500
    , p8_a67 JTF_VARCHAR2_TABLE_500
    , p8_a68 JTF_VARCHAR2_TABLE_500
    , p8_a69 JTF_VARCHAR2_TABLE_500
    , p8_a70 JTF_VARCHAR2_TABLE_500
    , p8_a71 JTF_VARCHAR2_TABLE_500
    , p8_a72 JTF_VARCHAR2_TABLE_500
    , p8_a73 JTF_VARCHAR2_TABLE_500
    , p8_a74 JTF_VARCHAR2_TABLE_500
    , p8_a75 JTF_VARCHAR2_TABLE_500
    , p8_a76 JTF_NUMBER_TABLE
    , p8_a77 JTF_NUMBER_TABLE
    , p8_a78 JTF_NUMBER_TABLE
    , p8_a79 JTF_DATE_TABLE
    , p8_a80 JTF_NUMBER_TABLE
    , p8_a81 JTF_DATE_TABLE
    , p8_a82 JTF_NUMBER_TABLE
    , p8_a83 JTF_DATE_TABLE
    , p8_a84 JTF_DATE_TABLE
    , p8_a85 JTF_DATE_TABLE
    , p8_a86 JTF_DATE_TABLE
    , p8_a87 JTF_NUMBER_TABLE
    , p8_a88 JTF_NUMBER_TABLE
    , p8_a89 JTF_NUMBER_TABLE
    , p8_a90 JTF_VARCHAR2_TABLE_100
    , p8_a91 JTF_NUMBER_TABLE
    , p8_a92 JTF_VARCHAR2_TABLE_100
    , p8_a93 JTF_NUMBER_TABLE
    , p8_a94 JTF_NUMBER_TABLE
    , p8_a95 JTF_DATE_TABLE
    , p8_a96 JTF_VARCHAR2_TABLE_100
    , p8_a97 JTF_VARCHAR2_TABLE_100
    , p8_a98 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_DATE_TABLE
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_DATE_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_DATE_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_DATE_TABLE
    , p11_a21 out nocopy JTF_DATE_TABLE
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_NUMBER_TABLE
    , p11_a24 out nocopy JTF_DATE_TABLE
    , p11_a25 out nocopy JTF_DATE_TABLE
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_NUMBER_TABLE
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p11_a29 out nocopy JTF_NUMBER_TABLE
    , p11_a30 out nocopy JTF_NUMBER_TABLE
    , p11_a31 out nocopy JTF_NUMBER_TABLE
    , p11_a32 out nocopy JTF_NUMBER_TABLE
    , p11_a33 out nocopy JTF_NUMBER_TABLE
    , p11_a34 out nocopy JTF_DATE_TABLE
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a38 out nocopy JTF_NUMBER_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a42 out nocopy JTF_DATE_TABLE
    , p11_a43 out nocopy JTF_NUMBER_TABLE
    , p11_a44 out nocopy JTF_NUMBER_TABLE
    , p11_a45 out nocopy JTF_DATE_TABLE
    , p11_a46 out nocopy JTF_NUMBER_TABLE
    , p11_a47 out nocopy JTF_DATE_TABLE
    , p11_a48 out nocopy JTF_DATE_TABLE
    , p11_a49 out nocopy JTF_DATE_TABLE
    , p11_a50 out nocopy JTF_NUMBER_TABLE
    , p11_a51 out nocopy JTF_NUMBER_TABLE
    , p11_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a53 out nocopy JTF_NUMBER_TABLE
    , p11_a54 out nocopy JTF_NUMBER_TABLE
    , p11_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a57 out nocopy JTF_NUMBER_TABLE
    , p11_a58 out nocopy JTF_DATE_TABLE
    , p11_a59 out nocopy JTF_NUMBER_TABLE
    , p11_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a76 out nocopy JTF_NUMBER_TABLE
    , p11_a77 out nocopy JTF_NUMBER_TABLE
    , p11_a78 out nocopy JTF_NUMBER_TABLE
    , p11_a79 out nocopy JTF_DATE_TABLE
    , p11_a80 out nocopy JTF_NUMBER_TABLE
    , p11_a81 out nocopy JTF_DATE_TABLE
    , p11_a82 out nocopy JTF_NUMBER_TABLE
    , p11_a83 out nocopy JTF_DATE_TABLE
    , p11_a84 out nocopy JTF_DATE_TABLE
    , p11_a85 out nocopy JTF_DATE_TABLE
    , p11_a86 out nocopy JTF_DATE_TABLE
    , p11_a87 out nocopy JTF_NUMBER_TABLE
    , p11_a88 out nocopy JTF_NUMBER_TABLE
    , p11_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a91 out nocopy JTF_NUMBER_TABLE
    , p11_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a93 out nocopy JTF_NUMBER_TABLE
    , p11_a94 out nocopy JTF_NUMBER_TABLE
    , p11_a95 out nocopy JTF_DATE_TABLE
    , p11_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a98 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_NUMBER_TABLE
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a15 out nocopy JTF_NUMBER_TABLE
    , p12_a16 out nocopy JTF_DATE_TABLE
    , p12_a17 out nocopy JTF_NUMBER_TABLE
    , p12_a18 out nocopy JTF_DATE_TABLE
    , p12_a19 out nocopy JTF_NUMBER_TABLE
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  VARCHAR2
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  NUMBER
    , p13_a5 out nocopy  NUMBER
    , p13_a6 out nocopy  NUMBER
    , p13_a7 out nocopy  NUMBER
    , p13_a8 out nocopy  VARCHAR2
    , p13_a9 out nocopy  VARCHAR2
    , p13_a10 out nocopy  NUMBER
    , p13_a11 out nocopy  VARCHAR2
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  VARCHAR2
    , p13_a14 out nocopy  VARCHAR2
    , p13_a15 out nocopy  VARCHAR2
    , p13_a16 out nocopy  VARCHAR2
    , p13_a17 out nocopy  VARCHAR2
    , p13_a18 out nocopy  NUMBER
    , p13_a19 out nocopy  NUMBER
    , p13_a20 out nocopy  NUMBER
    , p13_a21 out nocopy  NUMBER
    , p13_a22 out nocopy  VARCHAR2
    , p13_a23 out nocopy  VARCHAR2
    , p13_a24 out nocopy  VARCHAR2
    , p13_a25 out nocopy  VARCHAR2
    , p13_a26 out nocopy  VARCHAR2
    , p13_a27 out nocopy  VARCHAR2
    , p13_a28 out nocopy  DATE
    , p13_a29 out nocopy  VARCHAR2
    , p13_a30 out nocopy  DATE
    , p13_a31 out nocopy  DATE
    , p13_a32 out nocopy  DATE
    , p13_a33 out nocopy  VARCHAR2
    , p13_a34 out nocopy  NUMBER
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  NUMBER
    , p13_a37 out nocopy  VARCHAR2
    , p13_a38 out nocopy  VARCHAR2
    , p13_a39 out nocopy  VARCHAR2
    , p13_a40 out nocopy  VARCHAR2
    , p13_a41 out nocopy  VARCHAR2
    , p13_a42 out nocopy  VARCHAR2
    , p13_a43 out nocopy  VARCHAR2
    , p13_a44 out nocopy  VARCHAR2
    , p13_a45 out nocopy  VARCHAR2
    , p13_a46 out nocopy  VARCHAR2
    , p13_a47 out nocopy  VARCHAR2
    , p13_a48 out nocopy  VARCHAR2
    , p13_a49 out nocopy  VARCHAR2
    , p13_a50 out nocopy  VARCHAR2
    , p13_a51 out nocopy  VARCHAR2
    , p13_a52 out nocopy  VARCHAR2
    , p13_a53 out nocopy  VARCHAR2
    , p13_a54 out nocopy  NUMBER
    , p13_a55 out nocopy  DATE
    , p13_a56 out nocopy  NUMBER
    , p13_a57 out nocopy  DATE
    , p13_a58 out nocopy  VARCHAR2
    , p13_a59 out nocopy  VARCHAR2
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  NUMBER
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p13_a66 out nocopy  VARCHAR2
    , p13_a67 out nocopy  NUMBER
    , p13_a68 out nocopy  NUMBER
    , p13_a69 out nocopy  NUMBER
    , p13_a70 out nocopy  DATE
    , p13_a71 out nocopy  NUMBER
    , p13_a72 out nocopy  DATE
    , p13_a73 out nocopy  NUMBER
    , p13_a74 out nocopy  NUMBER
    , p13_a75 out nocopy  VARCHAR2
    , p13_a76 out nocopy  VARCHAR2
    , p13_a77 out nocopy  NUMBER
    , p13_a78 out nocopy  NUMBER
    , p13_a79 out nocopy  VARCHAR2
    , p13_a80 out nocopy  VARCHAR2
    , p13_a81 out nocopy  NUMBER
    , p13_a82 out nocopy  VARCHAR2
    , p13_a83 out nocopy  NUMBER
    , p13_a84 out nocopy  NUMBER
    , p13_a85 out nocopy  NUMBER
    , p13_a86 out nocopy  NUMBER
    , p13_a87 out nocopy  VARCHAR2
    , p13_a88 out nocopy  NUMBER
    , p13_a89 out nocopy  NUMBER
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  NUMBER
    , p14_a2 out nocopy  NUMBER
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  VARCHAR2
    , p14_a5 out nocopy  VARCHAR2
    , p14_a6 out nocopy  VARCHAR2
    , p14_a7 out nocopy  NUMBER
    , p14_a8 out nocopy  NUMBER
    , p14_a9 out nocopy  DATE
    , p14_a10 out nocopy  NUMBER
    , p14_a11 out nocopy  NUMBER
    , p14_a12 out nocopy  NUMBER
    , p14_a13 out nocopy  NUMBER
    , p14_a14 out nocopy  NUMBER
    , p14_a15 out nocopy  NUMBER
    , p14_a16 out nocopy  NUMBER
    , p14_a17 out nocopy  NUMBER
    , p14_a18 out nocopy  NUMBER
    , p14_a19 out nocopy  NUMBER
    , p14_a20 out nocopy  DATE
    , p14_a21 out nocopy  DATE
    , p14_a22 out nocopy  NUMBER
    , p14_a23 out nocopy  NUMBER
    , p14_a24 out nocopy  DATE
    , p14_a25 out nocopy  DATE
    , p14_a26 out nocopy  DATE
    , p14_a27 out nocopy  NUMBER
    , p14_a28 out nocopy  NUMBER
    , p14_a29 out nocopy  NUMBER
    , p14_a30 out nocopy  NUMBER
    , p14_a31 out nocopy  NUMBER
    , p14_a32 out nocopy  NUMBER
    , p14_a33 out nocopy  NUMBER
    , p14_a34 out nocopy  DATE
    , p14_a35 out nocopy  VARCHAR2
    , p14_a36 out nocopy  DATE
    , p14_a37 out nocopy  VARCHAR2
    , p14_a38 out nocopy  NUMBER
    , p14_a39 out nocopy  NUMBER
    , p14_a40 out nocopy  NUMBER
    , p14_a41 out nocopy  VARCHAR2
    , p14_a42 out nocopy  DATE
    , p14_a43 out nocopy  NUMBER
    , p14_a44 out nocopy  NUMBER
    , p14_a45 out nocopy  DATE
    , p14_a46 out nocopy  NUMBER
    , p14_a47 out nocopy  DATE
    , p14_a48 out nocopy  DATE
    , p14_a49 out nocopy  DATE
    , p14_a50 out nocopy  NUMBER
    , p14_a51 out nocopy  NUMBER
    , p14_a52 out nocopy  VARCHAR2
    , p14_a53 out nocopy  NUMBER
    , p14_a54 out nocopy  NUMBER
    , p14_a55 out nocopy  VARCHAR2
    , p14_a56 out nocopy  VARCHAR2
    , p14_a57 out nocopy  NUMBER
    , p14_a58 out nocopy  DATE
    , p14_a59 out nocopy  NUMBER
    , p14_a60 out nocopy  VARCHAR2
    , p14_a61 out nocopy  VARCHAR2
    , p14_a62 out nocopy  VARCHAR2
    , p14_a63 out nocopy  VARCHAR2
    , p14_a64 out nocopy  VARCHAR2
    , p14_a65 out nocopy  VARCHAR2
    , p14_a66 out nocopy  VARCHAR2
    , p14_a67 out nocopy  VARCHAR2
    , p14_a68 out nocopy  VARCHAR2
    , p14_a69 out nocopy  VARCHAR2
    , p14_a70 out nocopy  VARCHAR2
    , p14_a71 out nocopy  VARCHAR2
    , p14_a72 out nocopy  VARCHAR2
    , p14_a73 out nocopy  VARCHAR2
    , p14_a74 out nocopy  VARCHAR2
    , p14_a75 out nocopy  VARCHAR2
    , p14_a76 out nocopy  NUMBER
    , p14_a77 out nocopy  NUMBER
    , p14_a78 out nocopy  NUMBER
    , p14_a79 out nocopy  DATE
    , p14_a80 out nocopy  NUMBER
    , p14_a81 out nocopy  DATE
    , p14_a82 out nocopy  NUMBER
    , p14_a83 out nocopy  DATE
    , p14_a84 out nocopy  DATE
    , p14_a85 out nocopy  DATE
    , p14_a86 out nocopy  DATE
    , p14_a87 out nocopy  NUMBER
    , p14_a88 out nocopy  NUMBER
    , p14_a89 out nocopy  NUMBER
    , p14_a90 out nocopy  VARCHAR2
    , p14_a91 out nocopy  NUMBER
    , p14_a92 out nocopy  VARCHAR2
    , p14_a93 out nocopy  NUMBER
    , p14_a94 out nocopy  NUMBER
    , p14_a95 out nocopy  DATE
    , p14_a96 out nocopy  VARCHAR2
    , p14_a97 out nocopy  VARCHAR2
    , p14_a98 out nocopy  NUMBER
  );
  procedure delete_add_on_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_DATE_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_DATE_TABLE
    , p8_a21 JTF_DATE_TABLE
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_DATE_TABLE
    , p8_a26 JTF_DATE_TABLE
    , p8_a27 JTF_NUMBER_TABLE
    , p8_a28 JTF_NUMBER_TABLE
    , p8_a29 JTF_NUMBER_TABLE
    , p8_a30 JTF_NUMBER_TABLE
    , p8_a31 JTF_NUMBER_TABLE
    , p8_a32 JTF_NUMBER_TABLE
    , p8_a33 JTF_NUMBER_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_VARCHAR2_TABLE_100
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_DATE_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_DATE_TABLE
    , p8_a48 JTF_DATE_TABLE
    , p8_a49 JTF_DATE_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_VARCHAR2_TABLE_100
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_VARCHAR2_TABLE_100
    , p8_a56 JTF_VARCHAR2_TABLE_100
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_DATE_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_VARCHAR2_TABLE_100
    , p8_a61 JTF_VARCHAR2_TABLE_500
    , p8_a62 JTF_VARCHAR2_TABLE_500
    , p8_a63 JTF_VARCHAR2_TABLE_500
    , p8_a64 JTF_VARCHAR2_TABLE_500
    , p8_a65 JTF_VARCHAR2_TABLE_500
    , p8_a66 JTF_VARCHAR2_TABLE_500
    , p8_a67 JTF_VARCHAR2_TABLE_500
    , p8_a68 JTF_VARCHAR2_TABLE_500
    , p8_a69 JTF_VARCHAR2_TABLE_500
    , p8_a70 JTF_VARCHAR2_TABLE_500
    , p8_a71 JTF_VARCHAR2_TABLE_500
    , p8_a72 JTF_VARCHAR2_TABLE_500
    , p8_a73 JTF_VARCHAR2_TABLE_500
    , p8_a74 JTF_VARCHAR2_TABLE_500
    , p8_a75 JTF_VARCHAR2_TABLE_500
    , p8_a76 JTF_NUMBER_TABLE
    , p8_a77 JTF_NUMBER_TABLE
    , p8_a78 JTF_NUMBER_TABLE
    , p8_a79 JTF_DATE_TABLE
    , p8_a80 JTF_NUMBER_TABLE
    , p8_a81 JTF_DATE_TABLE
    , p8_a82 JTF_NUMBER_TABLE
    , p8_a83 JTF_DATE_TABLE
    , p8_a84 JTF_DATE_TABLE
    , p8_a85 JTF_DATE_TABLE
    , p8_a86 JTF_DATE_TABLE
    , p8_a87 JTF_NUMBER_TABLE
    , p8_a88 JTF_NUMBER_TABLE
    , p8_a89 JTF_NUMBER_TABLE
    , p8_a90 JTF_VARCHAR2_TABLE_100
    , p8_a91 JTF_NUMBER_TABLE
    , p8_a92 JTF_VARCHAR2_TABLE_100
    , p8_a93 JTF_NUMBER_TABLE
    , p8_a94 JTF_NUMBER_TABLE
    , p8_a95 JTF_DATE_TABLE
    , p8_a96 JTF_VARCHAR2_TABLE_100
    , p8_a97 JTF_VARCHAR2_TABLE_100
    , p8_a98 JTF_NUMBER_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  NUMBER
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  DATE
    , p9_a31 out nocopy  DATE
    , p9_a32 out nocopy  DATE
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  NUMBER
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  VARCHAR2
    , p9_a40 out nocopy  VARCHAR2
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  VARCHAR2
    , p9_a43 out nocopy  VARCHAR2
    , p9_a44 out nocopy  VARCHAR2
    , p9_a45 out nocopy  VARCHAR2
    , p9_a46 out nocopy  VARCHAR2
    , p9_a47 out nocopy  VARCHAR2
    , p9_a48 out nocopy  VARCHAR2
    , p9_a49 out nocopy  VARCHAR2
    , p9_a50 out nocopy  VARCHAR2
    , p9_a51 out nocopy  VARCHAR2
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  DATE
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  DATE
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  NUMBER
    , p9_a69 out nocopy  NUMBER
    , p9_a70 out nocopy  DATE
    , p9_a71 out nocopy  NUMBER
    , p9_a72 out nocopy  DATE
    , p9_a73 out nocopy  NUMBER
    , p9_a74 out nocopy  NUMBER
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  VARCHAR2
    , p9_a80 out nocopy  VARCHAR2
    , p9_a81 out nocopy  NUMBER
    , p9_a82 out nocopy  VARCHAR2
    , p9_a83 out nocopy  NUMBER
    , p9_a84 out nocopy  NUMBER
    , p9_a85 out nocopy  NUMBER
    , p9_a86 out nocopy  NUMBER
    , p9_a87 out nocopy  VARCHAR2
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  NUMBER
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  NUMBER
    , p10_a19 out nocopy  NUMBER
    , p10_a20 out nocopy  DATE
    , p10_a21 out nocopy  DATE
    , p10_a22 out nocopy  NUMBER
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  DATE
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  NUMBER
    , p10_a28 out nocopy  NUMBER
    , p10_a29 out nocopy  NUMBER
    , p10_a30 out nocopy  NUMBER
    , p10_a31 out nocopy  NUMBER
    , p10_a32 out nocopy  NUMBER
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  DATE
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  DATE
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  NUMBER
    , p10_a39 out nocopy  NUMBER
    , p10_a40 out nocopy  NUMBER
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  DATE
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  DATE
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  DATE
    , p10_a48 out nocopy  DATE
    , p10_a49 out nocopy  DATE
    , p10_a50 out nocopy  NUMBER
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  NUMBER
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  NUMBER
    , p10_a58 out nocopy  DATE
    , p10_a59 out nocopy  NUMBER
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , p10_a67 out nocopy  VARCHAR2
    , p10_a68 out nocopy  VARCHAR2
    , p10_a69 out nocopy  VARCHAR2
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  VARCHAR2
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  VARCHAR2
    , p10_a75 out nocopy  VARCHAR2
    , p10_a76 out nocopy  NUMBER
    , p10_a77 out nocopy  NUMBER
    , p10_a78 out nocopy  NUMBER
    , p10_a79 out nocopy  DATE
    , p10_a80 out nocopy  NUMBER
    , p10_a81 out nocopy  DATE
    , p10_a82 out nocopy  NUMBER
    , p10_a83 out nocopy  DATE
    , p10_a84 out nocopy  DATE
    , p10_a85 out nocopy  DATE
    , p10_a86 out nocopy  DATE
    , p10_a87 out nocopy  NUMBER
    , p10_a88 out nocopy  NUMBER
    , p10_a89 out nocopy  NUMBER
    , p10_a90 out nocopy  VARCHAR2
    , p10_a91 out nocopy  NUMBER
    , p10_a92 out nocopy  VARCHAR2
    , p10_a93 out nocopy  NUMBER
    , p10_a94 out nocopy  NUMBER
    , p10_a95 out nocopy  DATE
    , p10_a96 out nocopy  VARCHAR2
    , p10_a97 out nocopy  VARCHAR2
    , p10_a98 out nocopy  NUMBER
  );
  procedure create_party_roles_rec(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  );
  procedure update_party_roles_rec(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
  );
  procedure create_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_NUMBER_TABLE
    , p13_a5 JTF_VARCHAR2_TABLE_100
    , p13_a6 JTF_NUMBER_TABLE
    , p13_a7 JTF_VARCHAR2_TABLE_100
    , p13_a8 JTF_VARCHAR2_TABLE_100
    , p13_a9 JTF_VARCHAR2_TABLE_200
    , p13_a10 JTF_VARCHAR2_TABLE_100
    , p13_a11 JTF_VARCHAR2_TABLE_100
    , p13_a12 JTF_VARCHAR2_TABLE_200
    , p13_a13 JTF_VARCHAR2_TABLE_100
    , p13_a14 JTF_NUMBER_TABLE
    , p13_a15 JTF_VARCHAR2_TABLE_100
    , p13_a16 JTF_VARCHAR2_TABLE_100
    , p13_a17 JTF_NUMBER_TABLE
    , p13_a18 JTF_NUMBER_TABLE
    , p13_a19 JTF_VARCHAR2_TABLE_100
    , p13_a20 JTF_VARCHAR2_TABLE_500
    , p13_a21 JTF_VARCHAR2_TABLE_500
    , p13_a22 JTF_VARCHAR2_TABLE_500
    , p13_a23 JTF_VARCHAR2_TABLE_500
    , p13_a24 JTF_VARCHAR2_TABLE_500
    , p13_a25 JTF_VARCHAR2_TABLE_500
    , p13_a26 JTF_VARCHAR2_TABLE_500
    , p13_a27 JTF_VARCHAR2_TABLE_500
    , p13_a28 JTF_VARCHAR2_TABLE_500
    , p13_a29 JTF_VARCHAR2_TABLE_500
    , p13_a30 JTF_VARCHAR2_TABLE_500
    , p13_a31 JTF_VARCHAR2_TABLE_500
    , p13_a32 JTF_VARCHAR2_TABLE_500
    , p13_a33 JTF_VARCHAR2_TABLE_500
    , p13_a34 JTF_VARCHAR2_TABLE_500
    , p13_a35 JTF_NUMBER_TABLE
    , p13_a36 JTF_DATE_TABLE
    , p13_a37 JTF_NUMBER_TABLE
    , p13_a38 JTF_DATE_TABLE
    , p13_a39 JTF_NUMBER_TABLE
    , p13_a40 JTF_NUMBER_TABLE
    , p13_a41 JTF_NUMBER_TABLE
    , p13_a42 JTF_VARCHAR2_TABLE_100
    , p13_a43 JTF_NUMBER_TABLE
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  NUMBER
    , p14_a2 out nocopy  VARCHAR2
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  NUMBER
    , p14_a5 out nocopy  NUMBER
    , p14_a6 out nocopy  NUMBER
    , p14_a7 out nocopy  NUMBER
    , p14_a8 out nocopy  VARCHAR2
    , p14_a9 out nocopy  VARCHAR2
    , p14_a10 out nocopy  NUMBER
    , p14_a11 out nocopy  VARCHAR2
    , p14_a12 out nocopy  NUMBER
    , p14_a13 out nocopy  VARCHAR2
    , p14_a14 out nocopy  VARCHAR2
    , p14_a15 out nocopy  VARCHAR2
    , p14_a16 out nocopy  VARCHAR2
    , p14_a17 out nocopy  VARCHAR2
    , p14_a18 out nocopy  NUMBER
    , p14_a19 out nocopy  NUMBER
    , p14_a20 out nocopy  NUMBER
    , p14_a21 out nocopy  NUMBER
    , p14_a22 out nocopy  VARCHAR2
    , p14_a23 out nocopy  VARCHAR2
    , p14_a24 out nocopy  VARCHAR2
    , p14_a25 out nocopy  VARCHAR2
    , p14_a26 out nocopy  VARCHAR2
    , p14_a27 out nocopy  VARCHAR2
    , p14_a28 out nocopy  DATE
    , p14_a29 out nocopy  VARCHAR2
    , p14_a30 out nocopy  DATE
    , p14_a31 out nocopy  DATE
    , p14_a32 out nocopy  DATE
    , p14_a33 out nocopy  VARCHAR2
    , p14_a34 out nocopy  NUMBER
    , p14_a35 out nocopy  VARCHAR2
    , p14_a36 out nocopy  NUMBER
    , p14_a37 out nocopy  VARCHAR2
    , p14_a38 out nocopy  VARCHAR2
    , p14_a39 out nocopy  VARCHAR2
    , p14_a40 out nocopy  VARCHAR2
    , p14_a41 out nocopy  VARCHAR2
    , p14_a42 out nocopy  VARCHAR2
    , p14_a43 out nocopy  VARCHAR2
    , p14_a44 out nocopy  VARCHAR2
    , p14_a45 out nocopy  VARCHAR2
    , p14_a46 out nocopy  VARCHAR2
    , p14_a47 out nocopy  VARCHAR2
    , p14_a48 out nocopy  VARCHAR2
    , p14_a49 out nocopy  VARCHAR2
    , p14_a50 out nocopy  VARCHAR2
    , p14_a51 out nocopy  VARCHAR2
    , p14_a52 out nocopy  VARCHAR2
    , p14_a53 out nocopy  VARCHAR2
    , p14_a54 out nocopy  NUMBER
    , p14_a55 out nocopy  DATE
    , p14_a56 out nocopy  NUMBER
    , p14_a57 out nocopy  DATE
    , p14_a58 out nocopy  VARCHAR2
    , p14_a59 out nocopy  VARCHAR2
    , p14_a60 out nocopy  VARCHAR2
    , p14_a61 out nocopy  NUMBER
    , p14_a62 out nocopy  VARCHAR2
    , p14_a63 out nocopy  VARCHAR2
    , p14_a64 out nocopy  VARCHAR2
    , p14_a65 out nocopy  VARCHAR2
    , p14_a66 out nocopy  VARCHAR2
    , p14_a67 out nocopy  NUMBER
    , p14_a68 out nocopy  NUMBER
    , p14_a69 out nocopy  NUMBER
    , p14_a70 out nocopy  DATE
    , p14_a71 out nocopy  NUMBER
    , p14_a72 out nocopy  DATE
    , p14_a73 out nocopy  NUMBER
    , p14_a74 out nocopy  NUMBER
    , p14_a75 out nocopy  VARCHAR2
    , p14_a76 out nocopy  VARCHAR2
    , p14_a77 out nocopy  NUMBER
    , p14_a78 out nocopy  NUMBER
    , p14_a79 out nocopy  VARCHAR2
    , p14_a80 out nocopy  VARCHAR2
    , p14_a81 out nocopy  NUMBER
    , p14_a82 out nocopy  VARCHAR2
    , p14_a83 out nocopy  NUMBER
    , p14_a84 out nocopy  NUMBER
    , p14_a85 out nocopy  NUMBER
    , p14_a86 out nocopy  NUMBER
    , p14_a87 out nocopy  VARCHAR2
    , p14_a88 out nocopy  NUMBER
    , p14_a89 out nocopy  NUMBER
    , p15_a0 out nocopy  NUMBER
    , p15_a1 out nocopy  NUMBER
    , p15_a2 out nocopy  VARCHAR2
    , p15_a3 out nocopy  NUMBER
    , p15_a4 out nocopy  NUMBER
    , p15_a5 out nocopy  NUMBER
    , p15_a6 out nocopy  NUMBER
    , p15_a7 out nocopy  NUMBER
    , p15_a8 out nocopy  VARCHAR2
    , p15_a9 out nocopy  VARCHAR2
    , p15_a10 out nocopy  NUMBER
    , p15_a11 out nocopy  VARCHAR2
    , p15_a12 out nocopy  NUMBER
    , p15_a13 out nocopy  VARCHAR2
    , p15_a14 out nocopy  VARCHAR2
    , p15_a15 out nocopy  VARCHAR2
    , p15_a16 out nocopy  VARCHAR2
    , p15_a17 out nocopy  VARCHAR2
    , p15_a18 out nocopy  NUMBER
    , p15_a19 out nocopy  NUMBER
    , p15_a20 out nocopy  NUMBER
    , p15_a21 out nocopy  NUMBER
    , p15_a22 out nocopy  VARCHAR2
    , p15_a23 out nocopy  VARCHAR2
    , p15_a24 out nocopy  VARCHAR2
    , p15_a25 out nocopy  VARCHAR2
    , p15_a26 out nocopy  VARCHAR2
    , p15_a27 out nocopy  VARCHAR2
    , p15_a28 out nocopy  DATE
    , p15_a29 out nocopy  VARCHAR2
    , p15_a30 out nocopy  DATE
    , p15_a31 out nocopy  DATE
    , p15_a32 out nocopy  DATE
    , p15_a33 out nocopy  VARCHAR2
    , p15_a34 out nocopy  NUMBER
    , p15_a35 out nocopy  VARCHAR2
    , p15_a36 out nocopy  NUMBER
    , p15_a37 out nocopy  VARCHAR2
    , p15_a38 out nocopy  VARCHAR2
    , p15_a39 out nocopy  VARCHAR2
    , p15_a40 out nocopy  VARCHAR2
    , p15_a41 out nocopy  VARCHAR2
    , p15_a42 out nocopy  VARCHAR2
    , p15_a43 out nocopy  VARCHAR2
    , p15_a44 out nocopy  VARCHAR2
    , p15_a45 out nocopy  VARCHAR2
    , p15_a46 out nocopy  VARCHAR2
    , p15_a47 out nocopy  VARCHAR2
    , p15_a48 out nocopy  VARCHAR2
    , p15_a49 out nocopy  VARCHAR2
    , p15_a50 out nocopy  VARCHAR2
    , p15_a51 out nocopy  VARCHAR2
    , p15_a52 out nocopy  VARCHAR2
    , p15_a53 out nocopy  VARCHAR2
    , p15_a54 out nocopy  NUMBER
    , p15_a55 out nocopy  DATE
    , p15_a56 out nocopy  NUMBER
    , p15_a57 out nocopy  DATE
    , p15_a58 out nocopy  VARCHAR2
    , p15_a59 out nocopy  VARCHAR2
    , p15_a60 out nocopy  VARCHAR2
    , p15_a61 out nocopy  NUMBER
    , p15_a62 out nocopy  VARCHAR2
    , p15_a63 out nocopy  VARCHAR2
    , p15_a64 out nocopy  VARCHAR2
    , p15_a65 out nocopy  VARCHAR2
    , p15_a66 out nocopy  VARCHAR2
    , p15_a67 out nocopy  NUMBER
    , p15_a68 out nocopy  NUMBER
    , p15_a69 out nocopy  NUMBER
    , p15_a70 out nocopy  DATE
    , p15_a71 out nocopy  NUMBER
    , p15_a72 out nocopy  DATE
    , p15_a73 out nocopy  NUMBER
    , p15_a74 out nocopy  NUMBER
    , p15_a75 out nocopy  VARCHAR2
    , p15_a76 out nocopy  VARCHAR2
    , p15_a77 out nocopy  NUMBER
    , p15_a78 out nocopy  NUMBER
    , p15_a79 out nocopy  VARCHAR2
    , p15_a80 out nocopy  VARCHAR2
    , p15_a81 out nocopy  NUMBER
    , p15_a82 out nocopy  VARCHAR2
    , p15_a83 out nocopy  NUMBER
    , p15_a84 out nocopy  NUMBER
    , p15_a85 out nocopy  NUMBER
    , p15_a86 out nocopy  NUMBER
    , p15_a87 out nocopy  VARCHAR2
    , p15_a88 out nocopy  NUMBER
    , p15_a89 out nocopy  NUMBER
    , p16_a0 out nocopy  NUMBER
    , p16_a1 out nocopy  NUMBER
    , p16_a2 out nocopy  VARCHAR2
    , p16_a3 out nocopy  NUMBER
    , p16_a4 out nocopy  NUMBER
    , p16_a5 out nocopy  NUMBER
    , p16_a6 out nocopy  NUMBER
    , p16_a7 out nocopy  NUMBER
    , p16_a8 out nocopy  VARCHAR2
    , p16_a9 out nocopy  VARCHAR2
    , p16_a10 out nocopy  NUMBER
    , p16_a11 out nocopy  VARCHAR2
    , p16_a12 out nocopy  NUMBER
    , p16_a13 out nocopy  VARCHAR2
    , p16_a14 out nocopy  VARCHAR2
    , p16_a15 out nocopy  VARCHAR2
    , p16_a16 out nocopy  VARCHAR2
    , p16_a17 out nocopy  VARCHAR2
    , p16_a18 out nocopy  NUMBER
    , p16_a19 out nocopy  NUMBER
    , p16_a20 out nocopy  NUMBER
    , p16_a21 out nocopy  NUMBER
    , p16_a22 out nocopy  VARCHAR2
    , p16_a23 out nocopy  VARCHAR2
    , p16_a24 out nocopy  VARCHAR2
    , p16_a25 out nocopy  VARCHAR2
    , p16_a26 out nocopy  VARCHAR2
    , p16_a27 out nocopy  VARCHAR2
    , p16_a28 out nocopy  DATE
    , p16_a29 out nocopy  VARCHAR2
    , p16_a30 out nocopy  DATE
    , p16_a31 out nocopy  DATE
    , p16_a32 out nocopy  DATE
    , p16_a33 out nocopy  VARCHAR2
    , p16_a34 out nocopy  NUMBER
    , p16_a35 out nocopy  VARCHAR2
    , p16_a36 out nocopy  NUMBER
    , p16_a37 out nocopy  VARCHAR2
    , p16_a38 out nocopy  VARCHAR2
    , p16_a39 out nocopy  VARCHAR2
    , p16_a40 out nocopy  VARCHAR2
    , p16_a41 out nocopy  VARCHAR2
    , p16_a42 out nocopy  VARCHAR2
    , p16_a43 out nocopy  VARCHAR2
    , p16_a44 out nocopy  VARCHAR2
    , p16_a45 out nocopy  VARCHAR2
    , p16_a46 out nocopy  VARCHAR2
    , p16_a47 out nocopy  VARCHAR2
    , p16_a48 out nocopy  VARCHAR2
    , p16_a49 out nocopy  VARCHAR2
    , p16_a50 out nocopy  VARCHAR2
    , p16_a51 out nocopy  VARCHAR2
    , p16_a52 out nocopy  VARCHAR2
    , p16_a53 out nocopy  VARCHAR2
    , p16_a54 out nocopy  NUMBER
    , p16_a55 out nocopy  DATE
    , p16_a56 out nocopy  NUMBER
    , p16_a57 out nocopy  DATE
    , p16_a58 out nocopy  VARCHAR2
    , p16_a59 out nocopy  VARCHAR2
    , p16_a60 out nocopy  VARCHAR2
    , p16_a61 out nocopy  NUMBER
    , p16_a62 out nocopy  VARCHAR2
    , p16_a63 out nocopy  VARCHAR2
    , p16_a64 out nocopy  VARCHAR2
    , p16_a65 out nocopy  VARCHAR2
    , p16_a66 out nocopy  VARCHAR2
    , p16_a67 out nocopy  NUMBER
    , p16_a68 out nocopy  NUMBER
    , p16_a69 out nocopy  NUMBER
    , p16_a70 out nocopy  DATE
    , p16_a71 out nocopy  NUMBER
    , p16_a72 out nocopy  DATE
    , p16_a73 out nocopy  NUMBER
    , p16_a74 out nocopy  NUMBER
    , p16_a75 out nocopy  VARCHAR2
    , p16_a76 out nocopy  VARCHAR2
    , p16_a77 out nocopy  NUMBER
    , p16_a78 out nocopy  NUMBER
    , p16_a79 out nocopy  VARCHAR2
    , p16_a80 out nocopy  VARCHAR2
    , p16_a81 out nocopy  NUMBER
    , p16_a82 out nocopy  VARCHAR2
    , p16_a83 out nocopy  NUMBER
    , p16_a84 out nocopy  NUMBER
    , p16_a85 out nocopy  NUMBER
    , p16_a86 out nocopy  NUMBER
    , p16_a87 out nocopy  VARCHAR2
    , p16_a88 out nocopy  NUMBER
    , p16_a89 out nocopy  NUMBER
    , p17_a0 out nocopy  NUMBER
    , p17_a1 out nocopy  NUMBER
    , p17_a2 out nocopy  VARCHAR2
    , p17_a3 out nocopy  NUMBER
    , p17_a4 out nocopy  NUMBER
    , p17_a5 out nocopy  NUMBER
    , p17_a6 out nocopy  NUMBER
    , p17_a7 out nocopy  NUMBER
    , p17_a8 out nocopy  VARCHAR2
    , p17_a9 out nocopy  VARCHAR2
    , p17_a10 out nocopy  NUMBER
    , p17_a11 out nocopy  VARCHAR2
    , p17_a12 out nocopy  NUMBER
    , p17_a13 out nocopy  VARCHAR2
    , p17_a14 out nocopy  VARCHAR2
    , p17_a15 out nocopy  VARCHAR2
    , p17_a16 out nocopy  VARCHAR2
    , p17_a17 out nocopy  VARCHAR2
    , p17_a18 out nocopy  NUMBER
    , p17_a19 out nocopy  NUMBER
    , p17_a20 out nocopy  NUMBER
    , p17_a21 out nocopy  NUMBER
    , p17_a22 out nocopy  VARCHAR2
    , p17_a23 out nocopy  VARCHAR2
    , p17_a24 out nocopy  VARCHAR2
    , p17_a25 out nocopy  VARCHAR2
    , p17_a26 out nocopy  VARCHAR2
    , p17_a27 out nocopy  VARCHAR2
    , p17_a28 out nocopy  DATE
    , p17_a29 out nocopy  VARCHAR2
    , p17_a30 out nocopy  DATE
    , p17_a31 out nocopy  DATE
    , p17_a32 out nocopy  DATE
    , p17_a33 out nocopy  VARCHAR2
    , p17_a34 out nocopy  NUMBER
    , p17_a35 out nocopy  VARCHAR2
    , p17_a36 out nocopy  NUMBER
    , p17_a37 out nocopy  VARCHAR2
    , p17_a38 out nocopy  VARCHAR2
    , p17_a39 out nocopy  VARCHAR2
    , p17_a40 out nocopy  VARCHAR2
    , p17_a41 out nocopy  VARCHAR2
    , p17_a42 out nocopy  VARCHAR2
    , p17_a43 out nocopy  VARCHAR2
    , p17_a44 out nocopy  VARCHAR2
    , p17_a45 out nocopy  VARCHAR2
    , p17_a46 out nocopy  VARCHAR2
    , p17_a47 out nocopy  VARCHAR2
    , p17_a48 out nocopy  VARCHAR2
    , p17_a49 out nocopy  VARCHAR2
    , p17_a50 out nocopy  VARCHAR2
    , p17_a51 out nocopy  VARCHAR2
    , p17_a52 out nocopy  VARCHAR2
    , p17_a53 out nocopy  VARCHAR2
    , p17_a54 out nocopy  NUMBER
    , p17_a55 out nocopy  DATE
    , p17_a56 out nocopy  NUMBER
    , p17_a57 out nocopy  DATE
    , p17_a58 out nocopy  VARCHAR2
    , p17_a59 out nocopy  VARCHAR2
    , p17_a60 out nocopy  VARCHAR2
    , p17_a61 out nocopy  NUMBER
    , p17_a62 out nocopy  VARCHAR2
    , p17_a63 out nocopy  VARCHAR2
    , p17_a64 out nocopy  VARCHAR2
    , p17_a65 out nocopy  VARCHAR2
    , p17_a66 out nocopy  VARCHAR2
    , p17_a67 out nocopy  NUMBER
    , p17_a68 out nocopy  NUMBER
    , p17_a69 out nocopy  NUMBER
    , p17_a70 out nocopy  DATE
    , p17_a71 out nocopy  NUMBER
    , p17_a72 out nocopy  DATE
    , p17_a73 out nocopy  NUMBER
    , p17_a74 out nocopy  NUMBER
    , p17_a75 out nocopy  VARCHAR2
    , p17_a76 out nocopy  VARCHAR2
    , p17_a77 out nocopy  NUMBER
    , p17_a78 out nocopy  NUMBER
    , p17_a79 out nocopy  VARCHAR2
    , p17_a80 out nocopy  VARCHAR2
    , p17_a81 out nocopy  NUMBER
    , p17_a82 out nocopy  VARCHAR2
    , p17_a83 out nocopy  NUMBER
    , p17_a84 out nocopy  NUMBER
    , p17_a85 out nocopy  NUMBER
    , p17_a86 out nocopy  NUMBER
    , p17_a87 out nocopy  VARCHAR2
    , p17_a88 out nocopy  NUMBER
    , p17_a89 out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  DATE := fnd_api.g_miss_date
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  DATE := fnd_api.g_miss_date
    , p8_a21  DATE := fnd_api.g_miss_date
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  DATE := fnd_api.g_miss_date
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  NUMBER := 0-1962.0724
    , p8_a28  NUMBER := 0-1962.0724
    , p8_a29  NUMBER := 0-1962.0724
    , p8_a30  NUMBER := 0-1962.0724
    , p8_a31  NUMBER := 0-1962.0724
    , p8_a32  NUMBER := 0-1962.0724
    , p8_a33  NUMBER := 0-1962.0724
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  DATE := fnd_api.g_miss_date
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  DATE := fnd_api.g_miss_date
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  DATE := fnd_api.g_miss_date
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  DATE := fnd_api.g_miss_date
    , p8_a48  DATE := fnd_api.g_miss_date
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  NUMBER := 0-1962.0724
    , p8_a58  DATE := fnd_api.g_miss_date
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  VARCHAR2 := fnd_api.g_miss_char
    , p8_a68  VARCHAR2 := fnd_api.g_miss_char
    , p8_a69  VARCHAR2 := fnd_api.g_miss_char
    , p8_a70  VARCHAR2 := fnd_api.g_miss_char
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  NUMBER := 0-1962.0724
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  DATE := fnd_api.g_miss_date
    , p8_a80  NUMBER := 0-1962.0724
    , p8_a81  DATE := fnd_api.g_miss_date
    , p8_a82  NUMBER := 0-1962.0724
    , p8_a83  DATE := fnd_api.g_miss_date
    , p8_a84  DATE := fnd_api.g_miss_date
    , p8_a85  DATE := fnd_api.g_miss_date
    , p8_a86  DATE := fnd_api.g_miss_date
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  VARCHAR2 := fnd_api.g_miss_char
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  NUMBER := 0-1962.0724
    , p8_a95  DATE := fnd_api.g_miss_date
    , p8_a96  VARCHAR2 := fnd_api.g_miss_char
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  NUMBER := 0-1962.0724
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  NUMBER := 0-1962.0724
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  DATE := fnd_api.g_miss_date
    , p9_a17  NUMBER := 0-1962.0724
    , p9_a18  DATE := fnd_api.g_miss_date
    , p9_a19  NUMBER := 0-1962.0724
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  NUMBER := 0-1962.0724
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  NUMBER := 0-1962.0724
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  NUMBER := 0-1962.0724
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  NUMBER := 0-1962.0724
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  NUMBER := 0-1962.0724
    , p10_a19  NUMBER := 0-1962.0724
    , p10_a20  NUMBER := 0-1962.0724
    , p10_a21  NUMBER := 0-1962.0724
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  VARCHAR2 := fnd_api.g_miss_char
    , p10_a26  VARCHAR2 := fnd_api.g_miss_char
    , p10_a27  VARCHAR2 := fnd_api.g_miss_char
    , p10_a28  DATE := fnd_api.g_miss_date
    , p10_a29  VARCHAR2 := fnd_api.g_miss_char
    , p10_a30  DATE := fnd_api.g_miss_date
    , p10_a31  DATE := fnd_api.g_miss_date
    , p10_a32  DATE := fnd_api.g_miss_date
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  NUMBER := 0-1962.0724
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  NUMBER := 0-1962.0724
    , p10_a37  VARCHAR2 := fnd_api.g_miss_char
    , p10_a38  VARCHAR2 := fnd_api.g_miss_char
    , p10_a39  VARCHAR2 := fnd_api.g_miss_char
    , p10_a40  VARCHAR2 := fnd_api.g_miss_char
    , p10_a41  VARCHAR2 := fnd_api.g_miss_char
    , p10_a42  VARCHAR2 := fnd_api.g_miss_char
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  VARCHAR2 := fnd_api.g_miss_char
    , p10_a45  VARCHAR2 := fnd_api.g_miss_char
    , p10_a46  VARCHAR2 := fnd_api.g_miss_char
    , p10_a47  VARCHAR2 := fnd_api.g_miss_char
    , p10_a48  VARCHAR2 := fnd_api.g_miss_char
    , p10_a49  VARCHAR2 := fnd_api.g_miss_char
    , p10_a50  VARCHAR2 := fnd_api.g_miss_char
    , p10_a51  VARCHAR2 := fnd_api.g_miss_char
    , p10_a52  VARCHAR2 := fnd_api.g_miss_char
    , p10_a53  VARCHAR2 := fnd_api.g_miss_char
    , p10_a54  NUMBER := 0-1962.0724
    , p10_a55  DATE := fnd_api.g_miss_date
    , p10_a56  NUMBER := 0-1962.0724
    , p10_a57  DATE := fnd_api.g_miss_date
    , p10_a58  VARCHAR2 := fnd_api.g_miss_char
    , p10_a59  VARCHAR2 := fnd_api.g_miss_char
    , p10_a60  VARCHAR2 := fnd_api.g_miss_char
    , p10_a61  NUMBER := 0-1962.0724
    , p10_a62  VARCHAR2 := fnd_api.g_miss_char
    , p10_a63  VARCHAR2 := fnd_api.g_miss_char
    , p10_a64  VARCHAR2 := fnd_api.g_miss_char
    , p10_a65  VARCHAR2 := fnd_api.g_miss_char
    , p10_a66  VARCHAR2 := fnd_api.g_miss_char
    , p10_a67  NUMBER := 0-1962.0724
    , p10_a68  NUMBER := 0-1962.0724
    , p10_a69  NUMBER := 0-1962.0724
    , p10_a70  DATE := fnd_api.g_miss_date
    , p10_a71  NUMBER := 0-1962.0724
    , p10_a72  DATE := fnd_api.g_miss_date
    , p10_a73  NUMBER := 0-1962.0724
    , p10_a74  NUMBER := 0-1962.0724
    , p10_a75  VARCHAR2 := fnd_api.g_miss_char
    , p10_a76  VARCHAR2 := fnd_api.g_miss_char
    , p10_a77  NUMBER := 0-1962.0724
    , p10_a78  NUMBER := 0-1962.0724
    , p10_a79  VARCHAR2 := fnd_api.g_miss_char
    , p10_a80  VARCHAR2 := fnd_api.g_miss_char
    , p10_a81  NUMBER := 0-1962.0724
    , p10_a82  VARCHAR2 := fnd_api.g_miss_char
    , p10_a83  NUMBER := 0-1962.0724
    , p10_a84  NUMBER := 0-1962.0724
    , p10_a85  NUMBER := 0-1962.0724
    , p10_a86  NUMBER := 0-1962.0724
    , p10_a87  VARCHAR2 := fnd_api.g_miss_char
    , p10_a88  NUMBER := 0-1962.0724
    , p10_a89  NUMBER := 0-1962.0724
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  NUMBER := 0-1962.0724
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  NUMBER := 0-1962.0724
    , p11_a6  VARCHAR2 := fnd_api.g_miss_char
    , p11_a7  VARCHAR2 := fnd_api.g_miss_char
    , p11_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a9  VARCHAR2 := fnd_api.g_miss_char
    , p11_a10  VARCHAR2 := fnd_api.g_miss_char
    , p11_a11  NUMBER := 0-1962.0724
    , p11_a12  VARCHAR2 := fnd_api.g_miss_char
    , p11_a13  NUMBER := 0-1962.0724
    , p11_a14  VARCHAR2 := fnd_api.g_miss_char
    , p11_a15  NUMBER := 0-1962.0724
    , p11_a16  DATE := fnd_api.g_miss_date
    , p11_a17  NUMBER := 0-1962.0724
    , p11_a18  DATE := fnd_api.g_miss_date
    , p11_a19  NUMBER := 0-1962.0724
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  NUMBER := 0-1962.0724
    , p12_a4  NUMBER := 0-1962.0724
    , p12_a5  NUMBER := 0-1962.0724
    , p12_a6  NUMBER := 0-1962.0724
    , p12_a7  NUMBER := 0-1962.0724
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  VARCHAR2 := fnd_api.g_miss_char
    , p12_a13  VARCHAR2 := fnd_api.g_miss_char
    , p12_a14  VARCHAR2 := fnd_api.g_miss_char
    , p12_a15  NUMBER := 0-1962.0724
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  NUMBER := 0-1962.0724
    , p12_a18  VARCHAR2 := fnd_api.g_miss_char
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  NUMBER := 0-1962.0724
    , p12_a21  VARCHAR2 := fnd_api.g_miss_char
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  VARCHAR2 := fnd_api.g_miss_char
    , p12_a24  VARCHAR2 := fnd_api.g_miss_char
    , p12_a25  DATE := fnd_api.g_miss_date
    , p12_a26  DATE := fnd_api.g_miss_date
    , p12_a27  DATE := fnd_api.g_miss_date
    , p12_a28  NUMBER := 0-1962.0724
    , p12_a29  NUMBER := 0-1962.0724
    , p12_a30  NUMBER := 0-1962.0724
    , p12_a31  VARCHAR2 := fnd_api.g_miss_char
    , p12_a32  NUMBER := 0-1962.0724
    , p12_a33  NUMBER := 0-1962.0724
    , p12_a34  NUMBER := 0-1962.0724
    , p12_a35  NUMBER := 0-1962.0724
    , p12_a36  VARCHAR2 := fnd_api.g_miss_char
    , p12_a37  VARCHAR2 := fnd_api.g_miss_char
    , p12_a38  VARCHAR2 := fnd_api.g_miss_char
    , p12_a39  VARCHAR2 := fnd_api.g_miss_char
    , p12_a40  VARCHAR2 := fnd_api.g_miss_char
    , p12_a41  VARCHAR2 := fnd_api.g_miss_char
    , p12_a42  VARCHAR2 := fnd_api.g_miss_char
    , p12_a43  VARCHAR2 := fnd_api.g_miss_char
    , p12_a44  VARCHAR2 := fnd_api.g_miss_char
    , p12_a45  VARCHAR2 := fnd_api.g_miss_char
    , p12_a46  VARCHAR2 := fnd_api.g_miss_char
    , p12_a47  VARCHAR2 := fnd_api.g_miss_char
    , p12_a48  VARCHAR2 := fnd_api.g_miss_char
    , p12_a49  VARCHAR2 := fnd_api.g_miss_char
    , p12_a50  VARCHAR2 := fnd_api.g_miss_char
    , p12_a51  VARCHAR2 := fnd_api.g_miss_char
    , p12_a52  NUMBER := 0-1962.0724
    , p12_a53  DATE := fnd_api.g_miss_date
    , p12_a54  NUMBER := 0-1962.0724
    , p12_a55  DATE := fnd_api.g_miss_date
    , p12_a56  NUMBER := 0-1962.0724
    , p12_a57  VARCHAR2 := fnd_api.g_miss_char
    , p12_a58  NUMBER := 0-1962.0724
    , p12_a59  NUMBER := 0-1962.0724
    , p12_a60  NUMBER := 0-1962.0724
    , p12_a61  NUMBER := 0-1962.0724
    , p12_a62  NUMBER := 0-1962.0724
    , p12_a63  NUMBER := 0-1962.0724
    , p12_a64  NUMBER := 0-1962.0724
    , p12_a65  NUMBER := 0-1962.0724
    , p12_a66  NUMBER := 0-1962.0724
    , p12_a67  DATE := fnd_api.g_miss_date
    , p12_a68  NUMBER := 0-1962.0724
    , p12_a69  NUMBER := 0-1962.0724
    , p12_a70  NUMBER := 0-1962.0724
    , p12_a71  VARCHAR2 := fnd_api.g_miss_char
    , p12_a72  NUMBER := 0-1962.0724
    , p12_a73  VARCHAR2 := fnd_api.g_miss_char
    , p12_a74  VARCHAR2 := fnd_api.g_miss_char
    , p12_a75  NUMBER := 0-1962.0724
    , p12_a76  DATE := fnd_api.g_miss_date
  );
  procedure update_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p16_a0 out nocopy  NUMBER
    , p16_a1 out nocopy  NUMBER
    , p16_a2 out nocopy  VARCHAR2
    , p16_a3 out nocopy  NUMBER
    , p16_a4 out nocopy  NUMBER
    , p16_a5 out nocopy  NUMBER
    , p16_a6 out nocopy  NUMBER
    , p16_a7 out nocopy  NUMBER
    , p16_a8 out nocopy  VARCHAR2
    , p16_a9 out nocopy  VARCHAR2
    , p16_a10 out nocopy  NUMBER
    , p16_a11 out nocopy  VARCHAR2
    , p16_a12 out nocopy  NUMBER
    , p16_a13 out nocopy  VARCHAR2
    , p16_a14 out nocopy  VARCHAR2
    , p16_a15 out nocopy  VARCHAR2
    , p16_a16 out nocopy  VARCHAR2
    , p16_a17 out nocopy  VARCHAR2
    , p16_a18 out nocopy  NUMBER
    , p16_a19 out nocopy  NUMBER
    , p16_a20 out nocopy  NUMBER
    , p16_a21 out nocopy  NUMBER
    , p16_a22 out nocopy  VARCHAR2
    , p16_a23 out nocopy  VARCHAR2
    , p16_a24 out nocopy  VARCHAR2
    , p16_a25 out nocopy  VARCHAR2
    , p16_a26 out nocopy  VARCHAR2
    , p16_a27 out nocopy  VARCHAR2
    , p16_a28 out nocopy  DATE
    , p16_a29 out nocopy  VARCHAR2
    , p16_a30 out nocopy  DATE
    , p16_a31 out nocopy  DATE
    , p16_a32 out nocopy  DATE
    , p16_a33 out nocopy  VARCHAR2
    , p16_a34 out nocopy  NUMBER
    , p16_a35 out nocopy  VARCHAR2
    , p16_a36 out nocopy  NUMBER
    , p16_a37 out nocopy  VARCHAR2
    , p16_a38 out nocopy  VARCHAR2
    , p16_a39 out nocopy  VARCHAR2
    , p16_a40 out nocopy  VARCHAR2
    , p16_a41 out nocopy  VARCHAR2
    , p16_a42 out nocopy  VARCHAR2
    , p16_a43 out nocopy  VARCHAR2
    , p16_a44 out nocopy  VARCHAR2
    , p16_a45 out nocopy  VARCHAR2
    , p16_a46 out nocopy  VARCHAR2
    , p16_a47 out nocopy  VARCHAR2
    , p16_a48 out nocopy  VARCHAR2
    , p16_a49 out nocopy  VARCHAR2
    , p16_a50 out nocopy  VARCHAR2
    , p16_a51 out nocopy  VARCHAR2
    , p16_a52 out nocopy  VARCHAR2
    , p16_a53 out nocopy  VARCHAR2
    , p16_a54 out nocopy  NUMBER
    , p16_a55 out nocopy  DATE
    , p16_a56 out nocopy  NUMBER
    , p16_a57 out nocopy  DATE
    , p16_a58 out nocopy  VARCHAR2
    , p16_a59 out nocopy  VARCHAR2
    , p16_a60 out nocopy  VARCHAR2
    , p16_a61 out nocopy  NUMBER
    , p16_a62 out nocopy  VARCHAR2
    , p16_a63 out nocopy  VARCHAR2
    , p16_a64 out nocopy  VARCHAR2
    , p16_a65 out nocopy  VARCHAR2
    , p16_a66 out nocopy  VARCHAR2
    , p16_a67 out nocopy  NUMBER
    , p16_a68 out nocopy  NUMBER
    , p16_a69 out nocopy  NUMBER
    , p16_a70 out nocopy  DATE
    , p16_a71 out nocopy  NUMBER
    , p16_a72 out nocopy  DATE
    , p16_a73 out nocopy  NUMBER
    , p16_a74 out nocopy  NUMBER
    , p16_a75 out nocopy  VARCHAR2
    , p16_a76 out nocopy  VARCHAR2
    , p16_a77 out nocopy  NUMBER
    , p16_a78 out nocopy  NUMBER
    , p16_a79 out nocopy  VARCHAR2
    , p16_a80 out nocopy  VARCHAR2
    , p16_a81 out nocopy  NUMBER
    , p16_a82 out nocopy  VARCHAR2
    , p16_a83 out nocopy  NUMBER
    , p16_a84 out nocopy  NUMBER
    , p16_a85 out nocopy  NUMBER
    , p16_a86 out nocopy  NUMBER
    , p16_a87 out nocopy  VARCHAR2
    , p16_a88 out nocopy  NUMBER
    , p16_a89 out nocopy  NUMBER
    , p17_a0 out nocopy  NUMBER
    , p17_a1 out nocopy  NUMBER
    , p17_a2 out nocopy  VARCHAR2
    , p17_a3 out nocopy  NUMBER
    , p17_a4 out nocopy  NUMBER
    , p17_a5 out nocopy  NUMBER
    , p17_a6 out nocopy  NUMBER
    , p17_a7 out nocopy  NUMBER
    , p17_a8 out nocopy  VARCHAR2
    , p17_a9 out nocopy  VARCHAR2
    , p17_a10 out nocopy  NUMBER
    , p17_a11 out nocopy  VARCHAR2
    , p17_a12 out nocopy  NUMBER
    , p17_a13 out nocopy  VARCHAR2
    , p17_a14 out nocopy  VARCHAR2
    , p17_a15 out nocopy  VARCHAR2
    , p17_a16 out nocopy  VARCHAR2
    , p17_a17 out nocopy  VARCHAR2
    , p17_a18 out nocopy  NUMBER
    , p17_a19 out nocopy  NUMBER
    , p17_a20 out nocopy  NUMBER
    , p17_a21 out nocopy  NUMBER
    , p17_a22 out nocopy  VARCHAR2
    , p17_a23 out nocopy  VARCHAR2
    , p17_a24 out nocopy  VARCHAR2
    , p17_a25 out nocopy  VARCHAR2
    , p17_a26 out nocopy  VARCHAR2
    , p17_a27 out nocopy  VARCHAR2
    , p17_a28 out nocopy  DATE
    , p17_a29 out nocopy  VARCHAR2
    , p17_a30 out nocopy  DATE
    , p17_a31 out nocopy  DATE
    , p17_a32 out nocopy  DATE
    , p17_a33 out nocopy  VARCHAR2
    , p17_a34 out nocopy  NUMBER
    , p17_a35 out nocopy  VARCHAR2
    , p17_a36 out nocopy  NUMBER
    , p17_a37 out nocopy  VARCHAR2
    , p17_a38 out nocopy  VARCHAR2
    , p17_a39 out nocopy  VARCHAR2
    , p17_a40 out nocopy  VARCHAR2
    , p17_a41 out nocopy  VARCHAR2
    , p17_a42 out nocopy  VARCHAR2
    , p17_a43 out nocopy  VARCHAR2
    , p17_a44 out nocopy  VARCHAR2
    , p17_a45 out nocopy  VARCHAR2
    , p17_a46 out nocopy  VARCHAR2
    , p17_a47 out nocopy  VARCHAR2
    , p17_a48 out nocopy  VARCHAR2
    , p17_a49 out nocopy  VARCHAR2
    , p17_a50 out nocopy  VARCHAR2
    , p17_a51 out nocopy  VARCHAR2
    , p17_a52 out nocopy  VARCHAR2
    , p17_a53 out nocopy  VARCHAR2
    , p17_a54 out nocopy  NUMBER
    , p17_a55 out nocopy  DATE
    , p17_a56 out nocopy  NUMBER
    , p17_a57 out nocopy  DATE
    , p17_a58 out nocopy  VARCHAR2
    , p17_a59 out nocopy  VARCHAR2
    , p17_a60 out nocopy  VARCHAR2
    , p17_a61 out nocopy  NUMBER
    , p17_a62 out nocopy  VARCHAR2
    , p17_a63 out nocopy  VARCHAR2
    , p17_a64 out nocopy  VARCHAR2
    , p17_a65 out nocopy  VARCHAR2
    , p17_a66 out nocopy  VARCHAR2
    , p17_a67 out nocopy  NUMBER
    , p17_a68 out nocopy  NUMBER
    , p17_a69 out nocopy  NUMBER
    , p17_a70 out nocopy  DATE
    , p17_a71 out nocopy  NUMBER
    , p17_a72 out nocopy  DATE
    , p17_a73 out nocopy  NUMBER
    , p17_a74 out nocopy  NUMBER
    , p17_a75 out nocopy  VARCHAR2
    , p17_a76 out nocopy  VARCHAR2
    , p17_a77 out nocopy  NUMBER
    , p17_a78 out nocopy  NUMBER
    , p17_a79 out nocopy  VARCHAR2
    , p17_a80 out nocopy  VARCHAR2
    , p17_a81 out nocopy  NUMBER
    , p17_a82 out nocopy  VARCHAR2
    , p17_a83 out nocopy  NUMBER
    , p17_a84 out nocopy  NUMBER
    , p17_a85 out nocopy  NUMBER
    , p17_a86 out nocopy  NUMBER
    , p17_a87 out nocopy  VARCHAR2
    , p17_a88 out nocopy  NUMBER
    , p17_a89 out nocopy  NUMBER
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  NUMBER
    , p18_a2 out nocopy  VARCHAR2
    , p18_a3 out nocopy  NUMBER
    , p18_a4 out nocopy  NUMBER
    , p18_a5 out nocopy  NUMBER
    , p18_a6 out nocopy  NUMBER
    , p18_a7 out nocopy  NUMBER
    , p18_a8 out nocopy  VARCHAR2
    , p18_a9 out nocopy  VARCHAR2
    , p18_a10 out nocopy  NUMBER
    , p18_a11 out nocopy  VARCHAR2
    , p18_a12 out nocopy  NUMBER
    , p18_a13 out nocopy  VARCHAR2
    , p18_a14 out nocopy  VARCHAR2
    , p18_a15 out nocopy  VARCHAR2
    , p18_a16 out nocopy  VARCHAR2
    , p18_a17 out nocopy  VARCHAR2
    , p18_a18 out nocopy  NUMBER
    , p18_a19 out nocopy  NUMBER
    , p18_a20 out nocopy  NUMBER
    , p18_a21 out nocopy  NUMBER
    , p18_a22 out nocopy  VARCHAR2
    , p18_a23 out nocopy  VARCHAR2
    , p18_a24 out nocopy  VARCHAR2
    , p18_a25 out nocopy  VARCHAR2
    , p18_a26 out nocopy  VARCHAR2
    , p18_a27 out nocopy  VARCHAR2
    , p18_a28 out nocopy  DATE
    , p18_a29 out nocopy  VARCHAR2
    , p18_a30 out nocopy  DATE
    , p18_a31 out nocopy  DATE
    , p18_a32 out nocopy  DATE
    , p18_a33 out nocopy  VARCHAR2
    , p18_a34 out nocopy  NUMBER
    , p18_a35 out nocopy  VARCHAR2
    , p18_a36 out nocopy  NUMBER
    , p18_a37 out nocopy  VARCHAR2
    , p18_a38 out nocopy  VARCHAR2
    , p18_a39 out nocopy  VARCHAR2
    , p18_a40 out nocopy  VARCHAR2
    , p18_a41 out nocopy  VARCHAR2
    , p18_a42 out nocopy  VARCHAR2
    , p18_a43 out nocopy  VARCHAR2
    , p18_a44 out nocopy  VARCHAR2
    , p18_a45 out nocopy  VARCHAR2
    , p18_a46 out nocopy  VARCHAR2
    , p18_a47 out nocopy  VARCHAR2
    , p18_a48 out nocopy  VARCHAR2
    , p18_a49 out nocopy  VARCHAR2
    , p18_a50 out nocopy  VARCHAR2
    , p18_a51 out nocopy  VARCHAR2
    , p18_a52 out nocopy  VARCHAR2
    , p18_a53 out nocopy  VARCHAR2
    , p18_a54 out nocopy  NUMBER
    , p18_a55 out nocopy  DATE
    , p18_a56 out nocopy  NUMBER
    , p18_a57 out nocopy  DATE
    , p18_a58 out nocopy  VARCHAR2
    , p18_a59 out nocopy  VARCHAR2
    , p18_a60 out nocopy  VARCHAR2
    , p18_a61 out nocopy  NUMBER
    , p18_a62 out nocopy  VARCHAR2
    , p18_a63 out nocopy  VARCHAR2
    , p18_a64 out nocopy  VARCHAR2
    , p18_a65 out nocopy  VARCHAR2
    , p18_a66 out nocopy  VARCHAR2
    , p18_a67 out nocopy  NUMBER
    , p18_a68 out nocopy  NUMBER
    , p18_a69 out nocopy  NUMBER
    , p18_a70 out nocopy  DATE
    , p18_a71 out nocopy  NUMBER
    , p18_a72 out nocopy  DATE
    , p18_a73 out nocopy  NUMBER
    , p18_a74 out nocopy  NUMBER
    , p18_a75 out nocopy  VARCHAR2
    , p18_a76 out nocopy  VARCHAR2
    , p18_a77 out nocopy  NUMBER
    , p18_a78 out nocopy  NUMBER
    , p18_a79 out nocopy  VARCHAR2
    , p18_a80 out nocopy  VARCHAR2
    , p18_a81 out nocopy  NUMBER
    , p18_a82 out nocopy  VARCHAR2
    , p18_a83 out nocopy  NUMBER
    , p18_a84 out nocopy  NUMBER
    , p18_a85 out nocopy  NUMBER
    , p18_a86 out nocopy  NUMBER
    , p18_a87 out nocopy  VARCHAR2
    , p18_a88 out nocopy  NUMBER
    , p18_a89 out nocopy  NUMBER
    , p19_a0 out nocopy  NUMBER
    , p19_a1 out nocopy  NUMBER
    , p19_a2 out nocopy  VARCHAR2
    , p19_a3 out nocopy  NUMBER
    , p19_a4 out nocopy  NUMBER
    , p19_a5 out nocopy  NUMBER
    , p19_a6 out nocopy  NUMBER
    , p19_a7 out nocopy  NUMBER
    , p19_a8 out nocopy  VARCHAR2
    , p19_a9 out nocopy  VARCHAR2
    , p19_a10 out nocopy  NUMBER
    , p19_a11 out nocopy  VARCHAR2
    , p19_a12 out nocopy  NUMBER
    , p19_a13 out nocopy  VARCHAR2
    , p19_a14 out nocopy  VARCHAR2
    , p19_a15 out nocopy  VARCHAR2
    , p19_a16 out nocopy  VARCHAR2
    , p19_a17 out nocopy  VARCHAR2
    , p19_a18 out nocopy  NUMBER
    , p19_a19 out nocopy  NUMBER
    , p19_a20 out nocopy  NUMBER
    , p19_a21 out nocopy  NUMBER
    , p19_a22 out nocopy  VARCHAR2
    , p19_a23 out nocopy  VARCHAR2
    , p19_a24 out nocopy  VARCHAR2
    , p19_a25 out nocopy  VARCHAR2
    , p19_a26 out nocopy  VARCHAR2
    , p19_a27 out nocopy  VARCHAR2
    , p19_a28 out nocopy  DATE
    , p19_a29 out nocopy  VARCHAR2
    , p19_a30 out nocopy  DATE
    , p19_a31 out nocopy  DATE
    , p19_a32 out nocopy  DATE
    , p19_a33 out nocopy  VARCHAR2
    , p19_a34 out nocopy  NUMBER
    , p19_a35 out nocopy  VARCHAR2
    , p19_a36 out nocopy  NUMBER
    , p19_a37 out nocopy  VARCHAR2
    , p19_a38 out nocopy  VARCHAR2
    , p19_a39 out nocopy  VARCHAR2
    , p19_a40 out nocopy  VARCHAR2
    , p19_a41 out nocopy  VARCHAR2
    , p19_a42 out nocopy  VARCHAR2
    , p19_a43 out nocopy  VARCHAR2
    , p19_a44 out nocopy  VARCHAR2
    , p19_a45 out nocopy  VARCHAR2
    , p19_a46 out nocopy  VARCHAR2
    , p19_a47 out nocopy  VARCHAR2
    , p19_a48 out nocopy  VARCHAR2
    , p19_a49 out nocopy  VARCHAR2
    , p19_a50 out nocopy  VARCHAR2
    , p19_a51 out nocopy  VARCHAR2
    , p19_a52 out nocopy  VARCHAR2
    , p19_a53 out nocopy  VARCHAR2
    , p19_a54 out nocopy  NUMBER
    , p19_a55 out nocopy  DATE
    , p19_a56 out nocopy  NUMBER
    , p19_a57 out nocopy  DATE
    , p19_a58 out nocopy  VARCHAR2
    , p19_a59 out nocopy  VARCHAR2
    , p19_a60 out nocopy  VARCHAR2
    , p19_a61 out nocopy  NUMBER
    , p19_a62 out nocopy  VARCHAR2
    , p19_a63 out nocopy  VARCHAR2
    , p19_a64 out nocopy  VARCHAR2
    , p19_a65 out nocopy  VARCHAR2
    , p19_a66 out nocopy  VARCHAR2
    , p19_a67 out nocopy  NUMBER
    , p19_a68 out nocopy  NUMBER
    , p19_a69 out nocopy  NUMBER
    , p19_a70 out nocopy  DATE
    , p19_a71 out nocopy  NUMBER
    , p19_a72 out nocopy  DATE
    , p19_a73 out nocopy  NUMBER
    , p19_a74 out nocopy  NUMBER
    , p19_a75 out nocopy  VARCHAR2
    , p19_a76 out nocopy  VARCHAR2
    , p19_a77 out nocopy  NUMBER
    , p19_a78 out nocopy  NUMBER
    , p19_a79 out nocopy  VARCHAR2
    , p19_a80 out nocopy  VARCHAR2
    , p19_a81 out nocopy  NUMBER
    , p19_a82 out nocopy  VARCHAR2
    , p19_a83 out nocopy  NUMBER
    , p19_a84 out nocopy  NUMBER
    , p19_a85 out nocopy  NUMBER
    , p19_a86 out nocopy  NUMBER
    , p19_a87 out nocopy  VARCHAR2
    , p19_a88 out nocopy  NUMBER
    , p19_a89 out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  DATE := fnd_api.g_miss_date
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  DATE := fnd_api.g_miss_date
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  NUMBER := 0-1962.0724
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  DATE := fnd_api.g_miss_date
    , p8_a21  DATE := fnd_api.g_miss_date
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  DATE := fnd_api.g_miss_date
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  NUMBER := 0-1962.0724
    , p8_a28  NUMBER := 0-1962.0724
    , p8_a29  NUMBER := 0-1962.0724
    , p8_a30  NUMBER := 0-1962.0724
    , p8_a31  NUMBER := 0-1962.0724
    , p8_a32  NUMBER := 0-1962.0724
    , p8_a33  NUMBER := 0-1962.0724
    , p8_a34  DATE := fnd_api.g_miss_date
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  DATE := fnd_api.g_miss_date
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  DATE := fnd_api.g_miss_date
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  DATE := fnd_api.g_miss_date
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  DATE := fnd_api.g_miss_date
    , p8_a48  DATE := fnd_api.g_miss_date
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  NUMBER := 0-1962.0724
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  NUMBER := 0-1962.0724
    , p8_a58  DATE := fnd_api.g_miss_date
    , p8_a59  NUMBER := 0-1962.0724
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  VARCHAR2 := fnd_api.g_miss_char
    , p8_a68  VARCHAR2 := fnd_api.g_miss_char
    , p8_a69  VARCHAR2 := fnd_api.g_miss_char
    , p8_a70  VARCHAR2 := fnd_api.g_miss_char
    , p8_a71  VARCHAR2 := fnd_api.g_miss_char
    , p8_a72  VARCHAR2 := fnd_api.g_miss_char
    , p8_a73  VARCHAR2 := fnd_api.g_miss_char
    , p8_a74  VARCHAR2 := fnd_api.g_miss_char
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  NUMBER := 0-1962.0724
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  DATE := fnd_api.g_miss_date
    , p8_a80  NUMBER := 0-1962.0724
    , p8_a81  DATE := fnd_api.g_miss_date
    , p8_a82  NUMBER := 0-1962.0724
    , p8_a83  DATE := fnd_api.g_miss_date
    , p8_a84  DATE := fnd_api.g_miss_date
    , p8_a85  DATE := fnd_api.g_miss_date
    , p8_a86  DATE := fnd_api.g_miss_date
    , p8_a87  NUMBER := 0-1962.0724
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
    , p8_a90  VARCHAR2 := fnd_api.g_miss_char
    , p8_a91  NUMBER := 0-1962.0724
    , p8_a92  VARCHAR2 := fnd_api.g_miss_char
    , p8_a93  NUMBER := 0-1962.0724
    , p8_a94  NUMBER := 0-1962.0724
    , p8_a95  DATE := fnd_api.g_miss_date
    , p8_a96  VARCHAR2 := fnd_api.g_miss_char
    , p8_a97  VARCHAR2 := fnd_api.g_miss_char
    , p8_a98  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  NUMBER := 0-1962.0724
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  NUMBER := 0-1962.0724
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  DATE := fnd_api.g_miss_date
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  DATE := fnd_api.g_miss_date
    , p9_a31  DATE := fnd_api.g_miss_date
    , p9_a32  DATE := fnd_api.g_miss_date
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  NUMBER := 0-1962.0724
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  NUMBER := 0-1962.0724
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  NUMBER := 0-1962.0724
    , p9_a55  DATE := fnd_api.g_miss_date
    , p9_a56  NUMBER := 0-1962.0724
    , p9_a57  DATE := fnd_api.g_miss_date
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  NUMBER := 0-1962.0724
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  NUMBER := 0-1962.0724
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  DATE := fnd_api.g_miss_date
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  DATE := fnd_api.g_miss_date
    , p9_a73  NUMBER := 0-1962.0724
    , p9_a74  NUMBER := 0-1962.0724
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  VARCHAR2 := fnd_api.g_miss_char
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  VARCHAR2 := fnd_api.g_miss_char
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  NUMBER := 0-1962.0724
    , p9_a82  VARCHAR2 := fnd_api.g_miss_char
    , p9_a83  NUMBER := 0-1962.0724
    , p9_a84  NUMBER := 0-1962.0724
    , p9_a85  NUMBER := 0-1962.0724
    , p9_a86  NUMBER := 0-1962.0724
    , p9_a87  VARCHAR2 := fnd_api.g_miss_char
    , p9_a88  NUMBER := 0-1962.0724
    , p9_a89  NUMBER := 0-1962.0724
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  NUMBER := 0-1962.0724
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  NUMBER := 0-1962.0724
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  NUMBER := 0-1962.0724
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  NUMBER := 0-1962.0724
    , p10_a16  DATE := fnd_api.g_miss_date
    , p10_a17  NUMBER := 0-1962.0724
    , p10_a18  DATE := fnd_api.g_miss_date
    , p10_a19  NUMBER := 0-1962.0724
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  VARCHAR2 := fnd_api.g_miss_char
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  NUMBER := 0-1962.0724
    , p11_a6  NUMBER := 0-1962.0724
    , p11_a7  NUMBER := 0-1962.0724
    , p11_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a9  VARCHAR2 := fnd_api.g_miss_char
    , p11_a10  NUMBER := 0-1962.0724
    , p11_a11  VARCHAR2 := fnd_api.g_miss_char
    , p11_a12  NUMBER := 0-1962.0724
    , p11_a13  VARCHAR2 := fnd_api.g_miss_char
    , p11_a14  VARCHAR2 := fnd_api.g_miss_char
    , p11_a15  VARCHAR2 := fnd_api.g_miss_char
    , p11_a16  VARCHAR2 := fnd_api.g_miss_char
    , p11_a17  VARCHAR2 := fnd_api.g_miss_char
    , p11_a18  NUMBER := 0-1962.0724
    , p11_a19  NUMBER := 0-1962.0724
    , p11_a20  NUMBER := 0-1962.0724
    , p11_a21  NUMBER := 0-1962.0724
    , p11_a22  VARCHAR2 := fnd_api.g_miss_char
    , p11_a23  VARCHAR2 := fnd_api.g_miss_char
    , p11_a24  VARCHAR2 := fnd_api.g_miss_char
    , p11_a25  VARCHAR2 := fnd_api.g_miss_char
    , p11_a26  VARCHAR2 := fnd_api.g_miss_char
    , p11_a27  VARCHAR2 := fnd_api.g_miss_char
    , p11_a28  DATE := fnd_api.g_miss_date
    , p11_a29  VARCHAR2 := fnd_api.g_miss_char
    , p11_a30  DATE := fnd_api.g_miss_date
    , p11_a31  DATE := fnd_api.g_miss_date
    , p11_a32  DATE := fnd_api.g_miss_date
    , p11_a33  VARCHAR2 := fnd_api.g_miss_char
    , p11_a34  NUMBER := 0-1962.0724
    , p11_a35  VARCHAR2 := fnd_api.g_miss_char
    , p11_a36  NUMBER := 0-1962.0724
    , p11_a37  VARCHAR2 := fnd_api.g_miss_char
    , p11_a38  VARCHAR2 := fnd_api.g_miss_char
    , p11_a39  VARCHAR2 := fnd_api.g_miss_char
    , p11_a40  VARCHAR2 := fnd_api.g_miss_char
    , p11_a41  VARCHAR2 := fnd_api.g_miss_char
    , p11_a42  VARCHAR2 := fnd_api.g_miss_char
    , p11_a43  VARCHAR2 := fnd_api.g_miss_char
    , p11_a44  VARCHAR2 := fnd_api.g_miss_char
    , p11_a45  VARCHAR2 := fnd_api.g_miss_char
    , p11_a46  VARCHAR2 := fnd_api.g_miss_char
    , p11_a47  VARCHAR2 := fnd_api.g_miss_char
    , p11_a48  VARCHAR2 := fnd_api.g_miss_char
    , p11_a49  VARCHAR2 := fnd_api.g_miss_char
    , p11_a50  VARCHAR2 := fnd_api.g_miss_char
    , p11_a51  VARCHAR2 := fnd_api.g_miss_char
    , p11_a52  VARCHAR2 := fnd_api.g_miss_char
    , p11_a53  VARCHAR2 := fnd_api.g_miss_char
    , p11_a54  NUMBER := 0-1962.0724
    , p11_a55  DATE := fnd_api.g_miss_date
    , p11_a56  NUMBER := 0-1962.0724
    , p11_a57  DATE := fnd_api.g_miss_date
    , p11_a58  VARCHAR2 := fnd_api.g_miss_char
    , p11_a59  VARCHAR2 := fnd_api.g_miss_char
    , p11_a60  VARCHAR2 := fnd_api.g_miss_char
    , p11_a61  NUMBER := 0-1962.0724
    , p11_a62  VARCHAR2 := fnd_api.g_miss_char
    , p11_a63  VARCHAR2 := fnd_api.g_miss_char
    , p11_a64  VARCHAR2 := fnd_api.g_miss_char
    , p11_a65  VARCHAR2 := fnd_api.g_miss_char
    , p11_a66  VARCHAR2 := fnd_api.g_miss_char
    , p11_a67  NUMBER := 0-1962.0724
    , p11_a68  NUMBER := 0-1962.0724
    , p11_a69  NUMBER := 0-1962.0724
    , p11_a70  DATE := fnd_api.g_miss_date
    , p11_a71  NUMBER := 0-1962.0724
    , p11_a72  DATE := fnd_api.g_miss_date
    , p11_a73  NUMBER := 0-1962.0724
    , p11_a74  NUMBER := 0-1962.0724
    , p11_a75  VARCHAR2 := fnd_api.g_miss_char
    , p11_a76  VARCHAR2 := fnd_api.g_miss_char
    , p11_a77  NUMBER := 0-1962.0724
    , p11_a78  NUMBER := 0-1962.0724
    , p11_a79  VARCHAR2 := fnd_api.g_miss_char
    , p11_a80  VARCHAR2 := fnd_api.g_miss_char
    , p11_a81  NUMBER := 0-1962.0724
    , p11_a82  VARCHAR2 := fnd_api.g_miss_char
    , p11_a83  NUMBER := 0-1962.0724
    , p11_a84  NUMBER := 0-1962.0724
    , p11_a85  NUMBER := 0-1962.0724
    , p11_a86  NUMBER := 0-1962.0724
    , p11_a87  VARCHAR2 := fnd_api.g_miss_char
    , p11_a88  NUMBER := 0-1962.0724
    , p11_a89  NUMBER := 0-1962.0724
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  NUMBER := 0-1962.0724
    , p12_a3  NUMBER := 0-1962.0724
    , p12_a4  NUMBER := 0-1962.0724
    , p12_a5  NUMBER := 0-1962.0724
    , p12_a6  VARCHAR2 := fnd_api.g_miss_char
    , p12_a7  VARCHAR2 := fnd_api.g_miss_char
    , p12_a8  VARCHAR2 := fnd_api.g_miss_char
    , p12_a9  VARCHAR2 := fnd_api.g_miss_char
    , p12_a10  VARCHAR2 := fnd_api.g_miss_char
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  VARCHAR2 := fnd_api.g_miss_char
    , p12_a13  NUMBER := 0-1962.0724
    , p12_a14  VARCHAR2 := fnd_api.g_miss_char
    , p12_a15  NUMBER := 0-1962.0724
    , p12_a16  DATE := fnd_api.g_miss_date
    , p12_a17  NUMBER := 0-1962.0724
    , p12_a18  DATE := fnd_api.g_miss_date
    , p12_a19  NUMBER := 0-1962.0724
    , p13_a0  NUMBER := 0-1962.0724
    , p13_a1  NUMBER := 0-1962.0724
    , p13_a2  VARCHAR2 := fnd_api.g_miss_char
    , p13_a3  NUMBER := 0-1962.0724
    , p13_a4  NUMBER := 0-1962.0724
    , p13_a5  NUMBER := 0-1962.0724
    , p13_a6  NUMBER := 0-1962.0724
    , p13_a7  NUMBER := 0-1962.0724
    , p13_a8  NUMBER := 0-1962.0724
    , p13_a9  NUMBER := 0-1962.0724
    , p13_a10  NUMBER := 0-1962.0724
    , p13_a11  NUMBER := 0-1962.0724
    , p13_a12  VARCHAR2 := fnd_api.g_miss_char
    , p13_a13  VARCHAR2 := fnd_api.g_miss_char
    , p13_a14  VARCHAR2 := fnd_api.g_miss_char
    , p13_a15  NUMBER := 0-1962.0724
    , p13_a16  NUMBER := 0-1962.0724
    , p13_a17  NUMBER := 0-1962.0724
    , p13_a18  VARCHAR2 := fnd_api.g_miss_char
    , p13_a19  NUMBER := 0-1962.0724
    , p13_a20  NUMBER := 0-1962.0724
    , p13_a21  VARCHAR2 := fnd_api.g_miss_char
    , p13_a22  VARCHAR2 := fnd_api.g_miss_char
    , p13_a23  VARCHAR2 := fnd_api.g_miss_char
    , p13_a24  VARCHAR2 := fnd_api.g_miss_char
    , p13_a25  DATE := fnd_api.g_miss_date
    , p13_a26  DATE := fnd_api.g_miss_date
    , p13_a27  DATE := fnd_api.g_miss_date
    , p13_a28  NUMBER := 0-1962.0724
    , p13_a29  NUMBER := 0-1962.0724
    , p13_a30  NUMBER := 0-1962.0724
    , p13_a31  VARCHAR2 := fnd_api.g_miss_char
    , p13_a32  NUMBER := 0-1962.0724
    , p13_a33  NUMBER := 0-1962.0724
    , p13_a34  NUMBER := 0-1962.0724
    , p13_a35  NUMBER := 0-1962.0724
    , p13_a36  VARCHAR2 := fnd_api.g_miss_char
    , p13_a37  VARCHAR2 := fnd_api.g_miss_char
    , p13_a38  VARCHAR2 := fnd_api.g_miss_char
    , p13_a39  VARCHAR2 := fnd_api.g_miss_char
    , p13_a40  VARCHAR2 := fnd_api.g_miss_char
    , p13_a41  VARCHAR2 := fnd_api.g_miss_char
    , p13_a42  VARCHAR2 := fnd_api.g_miss_char
    , p13_a43  VARCHAR2 := fnd_api.g_miss_char
    , p13_a44  VARCHAR2 := fnd_api.g_miss_char
    , p13_a45  VARCHAR2 := fnd_api.g_miss_char
    , p13_a46  VARCHAR2 := fnd_api.g_miss_char
    , p13_a47  VARCHAR2 := fnd_api.g_miss_char
    , p13_a48  VARCHAR2 := fnd_api.g_miss_char
    , p13_a49  VARCHAR2 := fnd_api.g_miss_char
    , p13_a50  VARCHAR2 := fnd_api.g_miss_char
    , p13_a51  VARCHAR2 := fnd_api.g_miss_char
    , p13_a52  NUMBER := 0-1962.0724
    , p13_a53  DATE := fnd_api.g_miss_date
    , p13_a54  NUMBER := 0-1962.0724
    , p13_a55  DATE := fnd_api.g_miss_date
    , p13_a56  NUMBER := 0-1962.0724
    , p13_a57  VARCHAR2 := fnd_api.g_miss_char
    , p13_a58  NUMBER := 0-1962.0724
    , p13_a59  NUMBER := 0-1962.0724
    , p13_a60  NUMBER := 0-1962.0724
    , p13_a61  NUMBER := 0-1962.0724
    , p13_a62  NUMBER := 0-1962.0724
    , p13_a63  NUMBER := 0-1962.0724
    , p13_a64  NUMBER := 0-1962.0724
    , p13_a65  NUMBER := 0-1962.0724
    , p13_a66  NUMBER := 0-1962.0724
    , p13_a67  DATE := fnd_api.g_miss_date
    , p13_a68  NUMBER := 0-1962.0724
    , p13_a69  NUMBER := 0-1962.0724
    , p13_a70  NUMBER := 0-1962.0724
    , p13_a71  VARCHAR2 := fnd_api.g_miss_char
    , p13_a72  NUMBER := 0-1962.0724
    , p13_a73  VARCHAR2 := fnd_api.g_miss_char
    , p13_a74  VARCHAR2 := fnd_api.g_miss_char
    , p13_a75  NUMBER := 0-1962.0724
    , p13_a76  DATE := fnd_api.g_miss_date
    , p14_a0  NUMBER := 0-1962.0724
    , p14_a1  NUMBER := 0-1962.0724
    , p14_a2  VARCHAR2 := fnd_api.g_miss_char
    , p14_a3  NUMBER := 0-1962.0724
    , p14_a4  NUMBER := 0-1962.0724
    , p14_a5  NUMBER := 0-1962.0724
    , p14_a6  NUMBER := 0-1962.0724
    , p14_a7  NUMBER := 0-1962.0724
    , p14_a8  VARCHAR2 := fnd_api.g_miss_char
    , p14_a9  VARCHAR2 := fnd_api.g_miss_char
    , p14_a10  NUMBER := 0-1962.0724
    , p14_a11  VARCHAR2 := fnd_api.g_miss_char
    , p14_a12  NUMBER := 0-1962.0724
    , p14_a13  VARCHAR2 := fnd_api.g_miss_char
    , p14_a14  VARCHAR2 := fnd_api.g_miss_char
    , p14_a15  VARCHAR2 := fnd_api.g_miss_char
    , p14_a16  VARCHAR2 := fnd_api.g_miss_char
    , p14_a17  VARCHAR2 := fnd_api.g_miss_char
    , p14_a18  NUMBER := 0-1962.0724
    , p14_a19  NUMBER := 0-1962.0724
    , p14_a20  NUMBER := 0-1962.0724
    , p14_a21  NUMBER := 0-1962.0724
    , p14_a22  VARCHAR2 := fnd_api.g_miss_char
    , p14_a23  VARCHAR2 := fnd_api.g_miss_char
    , p14_a24  VARCHAR2 := fnd_api.g_miss_char
    , p14_a25  VARCHAR2 := fnd_api.g_miss_char
    , p14_a26  VARCHAR2 := fnd_api.g_miss_char
    , p14_a27  VARCHAR2 := fnd_api.g_miss_char
    , p14_a28  DATE := fnd_api.g_miss_date
    , p14_a29  VARCHAR2 := fnd_api.g_miss_char
    , p14_a30  DATE := fnd_api.g_miss_date
    , p14_a31  DATE := fnd_api.g_miss_date
    , p14_a32  DATE := fnd_api.g_miss_date
    , p14_a33  VARCHAR2 := fnd_api.g_miss_char
    , p14_a34  NUMBER := 0-1962.0724
    , p14_a35  VARCHAR2 := fnd_api.g_miss_char
    , p14_a36  NUMBER := 0-1962.0724
    , p14_a37  VARCHAR2 := fnd_api.g_miss_char
    , p14_a38  VARCHAR2 := fnd_api.g_miss_char
    , p14_a39  VARCHAR2 := fnd_api.g_miss_char
    , p14_a40  VARCHAR2 := fnd_api.g_miss_char
    , p14_a41  VARCHAR2 := fnd_api.g_miss_char
    , p14_a42  VARCHAR2 := fnd_api.g_miss_char
    , p14_a43  VARCHAR2 := fnd_api.g_miss_char
    , p14_a44  VARCHAR2 := fnd_api.g_miss_char
    , p14_a45  VARCHAR2 := fnd_api.g_miss_char
    , p14_a46  VARCHAR2 := fnd_api.g_miss_char
    , p14_a47  VARCHAR2 := fnd_api.g_miss_char
    , p14_a48  VARCHAR2 := fnd_api.g_miss_char
    , p14_a49  VARCHAR2 := fnd_api.g_miss_char
    , p14_a50  VARCHAR2 := fnd_api.g_miss_char
    , p14_a51  VARCHAR2 := fnd_api.g_miss_char
    , p14_a52  VARCHAR2 := fnd_api.g_miss_char
    , p14_a53  VARCHAR2 := fnd_api.g_miss_char
    , p14_a54  NUMBER := 0-1962.0724
    , p14_a55  DATE := fnd_api.g_miss_date
    , p14_a56  NUMBER := 0-1962.0724
    , p14_a57  DATE := fnd_api.g_miss_date
    , p14_a58  VARCHAR2 := fnd_api.g_miss_char
    , p14_a59  VARCHAR2 := fnd_api.g_miss_char
    , p14_a60  VARCHAR2 := fnd_api.g_miss_char
    , p14_a61  NUMBER := 0-1962.0724
    , p14_a62  VARCHAR2 := fnd_api.g_miss_char
    , p14_a63  VARCHAR2 := fnd_api.g_miss_char
    , p14_a64  VARCHAR2 := fnd_api.g_miss_char
    , p14_a65  VARCHAR2 := fnd_api.g_miss_char
    , p14_a66  VARCHAR2 := fnd_api.g_miss_char
    , p14_a67  NUMBER := 0-1962.0724
    , p14_a68  NUMBER := 0-1962.0724
    , p14_a69  NUMBER := 0-1962.0724
    , p14_a70  DATE := fnd_api.g_miss_date
    , p14_a71  NUMBER := 0-1962.0724
    , p14_a72  DATE := fnd_api.g_miss_date
    , p14_a73  NUMBER := 0-1962.0724
    , p14_a74  NUMBER := 0-1962.0724
    , p14_a75  VARCHAR2 := fnd_api.g_miss_char
    , p14_a76  VARCHAR2 := fnd_api.g_miss_char
    , p14_a77  NUMBER := 0-1962.0724
    , p14_a78  NUMBER := 0-1962.0724
    , p14_a79  VARCHAR2 := fnd_api.g_miss_char
    , p14_a80  VARCHAR2 := fnd_api.g_miss_char
    , p14_a81  NUMBER := 0-1962.0724
    , p14_a82  VARCHAR2 := fnd_api.g_miss_char
    , p14_a83  NUMBER := 0-1962.0724
    , p14_a84  NUMBER := 0-1962.0724
    , p14_a85  NUMBER := 0-1962.0724
    , p14_a86  NUMBER := 0-1962.0724
    , p14_a87  VARCHAR2 := fnd_api.g_miss_char
    , p14_a88  NUMBER := 0-1962.0724
    , p14_a89  NUMBER := 0-1962.0724
    , p15_a0  NUMBER := 0-1962.0724
    , p15_a1  NUMBER := 0-1962.0724
    , p15_a2  NUMBER := 0-1962.0724
    , p15_a3  NUMBER := 0-1962.0724
    , p15_a4  NUMBER := 0-1962.0724
    , p15_a5  VARCHAR2 := fnd_api.g_miss_char
    , p15_a6  NUMBER := 0-1962.0724
    , p15_a7  VARCHAR2 := fnd_api.g_miss_char
    , p15_a8  VARCHAR2 := fnd_api.g_miss_char
    , p15_a9  VARCHAR2 := fnd_api.g_miss_char
    , p15_a10  VARCHAR2 := fnd_api.g_miss_char
    , p15_a11  VARCHAR2 := fnd_api.g_miss_char
    , p15_a12  VARCHAR2 := fnd_api.g_miss_char
    , p15_a13  VARCHAR2 := fnd_api.g_miss_char
    , p15_a14  NUMBER := 0-1962.0724
    , p15_a15  VARCHAR2 := fnd_api.g_miss_char
    , p15_a16  VARCHAR2 := fnd_api.g_miss_char
    , p15_a17  NUMBER := 0-1962.0724
    , p15_a18  NUMBER := 0-1962.0724
    , p15_a19  VARCHAR2 := fnd_api.g_miss_char
    , p15_a20  VARCHAR2 := fnd_api.g_miss_char
    , p15_a21  VARCHAR2 := fnd_api.g_miss_char
    , p15_a22  VARCHAR2 := fnd_api.g_miss_char
    , p15_a23  VARCHAR2 := fnd_api.g_miss_char
    , p15_a24  VARCHAR2 := fnd_api.g_miss_char
    , p15_a25  VARCHAR2 := fnd_api.g_miss_char
    , p15_a26  VARCHAR2 := fnd_api.g_miss_char
    , p15_a27  VARCHAR2 := fnd_api.g_miss_char
    , p15_a28  VARCHAR2 := fnd_api.g_miss_char
    , p15_a29  VARCHAR2 := fnd_api.g_miss_char
    , p15_a30  VARCHAR2 := fnd_api.g_miss_char
    , p15_a31  VARCHAR2 := fnd_api.g_miss_char
    , p15_a32  VARCHAR2 := fnd_api.g_miss_char
    , p15_a33  VARCHAR2 := fnd_api.g_miss_char
    , p15_a34  VARCHAR2 := fnd_api.g_miss_char
    , p15_a35  NUMBER := 0-1962.0724
    , p15_a36  DATE := fnd_api.g_miss_date
    , p15_a37  NUMBER := 0-1962.0724
    , p15_a38  DATE := fnd_api.g_miss_date
    , p15_a39  NUMBER := 0-1962.0724
    , p15_a40  NUMBER := 0-1962.0724
    , p15_a41  NUMBER := 0-1962.0724
    , p15_a42  VARCHAR2 := fnd_api.g_miss_char
    , p15_a43  NUMBER := 0-1962.0724
  );
  procedure create_ints_ib_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p_current_units  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_VARCHAR2_TABLE_100
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_VARCHAR2_TABLE_100
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_500
    , p9_a21 JTF_VARCHAR2_TABLE_500
    , p9_a22 JTF_VARCHAR2_TABLE_500
    , p9_a23 JTF_VARCHAR2_TABLE_500
    , p9_a24 JTF_VARCHAR2_TABLE_500
    , p9_a25 JTF_VARCHAR2_TABLE_500
    , p9_a26 JTF_VARCHAR2_TABLE_500
    , p9_a27 JTF_VARCHAR2_TABLE_500
    , p9_a28 JTF_VARCHAR2_TABLE_500
    , p9_a29 JTF_VARCHAR2_TABLE_500
    , p9_a30 JTF_VARCHAR2_TABLE_500
    , p9_a31 JTF_VARCHAR2_TABLE_500
    , p9_a32 JTF_VARCHAR2_TABLE_500
    , p9_a33 JTF_VARCHAR2_TABLE_500
    , p9_a34 JTF_VARCHAR2_TABLE_500
    , p9_a35 JTF_NUMBER_TABLE
    , p9_a36 JTF_DATE_TABLE
    , p9_a37 JTF_NUMBER_TABLE
    , p9_a38 JTF_DATE_TABLE
    , p9_a39 JTF_NUMBER_TABLE
    , p9_a40 JTF_NUMBER_TABLE
    , p9_a41 JTF_NUMBER_TABLE
    , p9_a42 JTF_VARCHAR2_TABLE_100
    , p9_a43 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a35 out nocopy JTF_NUMBER_TABLE
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_NUMBER_TABLE
    , p11_a38 out nocopy JTF_DATE_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_NUMBER_TABLE
    , p11_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a43 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  NUMBER
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  NUMBER
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  NUMBER
    , p12_a19 out nocopy  NUMBER
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  NUMBER
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  DATE
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  DATE
    , p12_a31 out nocopy  DATE
    , p12_a32 out nocopy  DATE
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , p12_a45 out nocopy  VARCHAR2
    , p12_a46 out nocopy  VARCHAR2
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  VARCHAR2
    , p12_a50 out nocopy  VARCHAR2
    , p12_a51 out nocopy  VARCHAR2
    , p12_a52 out nocopy  VARCHAR2
    , p12_a53 out nocopy  VARCHAR2
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  DATE
    , p12_a56 out nocopy  NUMBER
    , p12_a57 out nocopy  DATE
    , p12_a58 out nocopy  VARCHAR2
    , p12_a59 out nocopy  VARCHAR2
    , p12_a60 out nocopy  VARCHAR2
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  VARCHAR2
    , p12_a63 out nocopy  VARCHAR2
    , p12_a64 out nocopy  VARCHAR2
    , p12_a65 out nocopy  VARCHAR2
    , p12_a66 out nocopy  VARCHAR2
    , p12_a67 out nocopy  NUMBER
    , p12_a68 out nocopy  NUMBER
    , p12_a69 out nocopy  NUMBER
    , p12_a70 out nocopy  DATE
    , p12_a71 out nocopy  NUMBER
    , p12_a72 out nocopy  DATE
    , p12_a73 out nocopy  NUMBER
    , p12_a74 out nocopy  NUMBER
    , p12_a75 out nocopy  VARCHAR2
    , p12_a76 out nocopy  VARCHAR2
    , p12_a77 out nocopy  NUMBER
    , p12_a78 out nocopy  NUMBER
    , p12_a79 out nocopy  VARCHAR2
    , p12_a80 out nocopy  VARCHAR2
    , p12_a81 out nocopy  NUMBER
    , p12_a82 out nocopy  VARCHAR2
    , p12_a83 out nocopy  NUMBER
    , p12_a84 out nocopy  NUMBER
    , p12_a85 out nocopy  NUMBER
    , p12_a86 out nocopy  NUMBER
    , p12_a87 out nocopy  VARCHAR2
    , p12_a88 out nocopy  NUMBER
    , p12_a89 out nocopy  NUMBER
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  VARCHAR2
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  NUMBER
    , p13_a8 out nocopy  NUMBER
    , p13_a9 out nocopy  DATE
    , p13_a10 out nocopy  NUMBER
    , p13_a11 out nocopy  NUMBER
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  NUMBER
    , p13_a14 out nocopy  NUMBER
    , p13_a15 out nocopy  NUMBER
    , p13_a16 out nocopy  NUMBER
    , p13_a17 out nocopy  NUMBER
    , p13_a18 out nocopy  NUMBER
    , p13_a19 out nocopy  NUMBER
    , p13_a20 out nocopy  DATE
    , p13_a21 out nocopy  DATE
    , p13_a22 out nocopy  NUMBER
    , p13_a23 out nocopy  NUMBER
    , p13_a24 out nocopy  DATE
    , p13_a25 out nocopy  DATE
    , p13_a26 out nocopy  DATE
    , p13_a27 out nocopy  NUMBER
    , p13_a28 out nocopy  NUMBER
    , p13_a29 out nocopy  NUMBER
    , p13_a30 out nocopy  NUMBER
    , p13_a31 out nocopy  NUMBER
    , p13_a32 out nocopy  NUMBER
    , p13_a33 out nocopy  NUMBER
    , p13_a34 out nocopy  DATE
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  DATE
    , p13_a37 out nocopy  VARCHAR2
    , p13_a38 out nocopy  NUMBER
    , p13_a39 out nocopy  NUMBER
    , p13_a40 out nocopy  NUMBER
    , p13_a41 out nocopy  VARCHAR2
    , p13_a42 out nocopy  DATE
    , p13_a43 out nocopy  NUMBER
    , p13_a44 out nocopy  NUMBER
    , p13_a45 out nocopy  DATE
    , p13_a46 out nocopy  NUMBER
    , p13_a47 out nocopy  DATE
    , p13_a48 out nocopy  DATE
    , p13_a49 out nocopy  DATE
    , p13_a50 out nocopy  NUMBER
    , p13_a51 out nocopy  NUMBER
    , p13_a52 out nocopy  VARCHAR2
    , p13_a53 out nocopy  NUMBER
    , p13_a54 out nocopy  NUMBER
    , p13_a55 out nocopy  VARCHAR2
    , p13_a56 out nocopy  VARCHAR2
    , p13_a57 out nocopy  NUMBER
    , p13_a58 out nocopy  DATE
    , p13_a59 out nocopy  NUMBER
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  VARCHAR2
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p13_a66 out nocopy  VARCHAR2
    , p13_a67 out nocopy  VARCHAR2
    , p13_a68 out nocopy  VARCHAR2
    , p13_a69 out nocopy  VARCHAR2
    , p13_a70 out nocopy  VARCHAR2
    , p13_a71 out nocopy  VARCHAR2
    , p13_a72 out nocopy  VARCHAR2
    , p13_a73 out nocopy  VARCHAR2
    , p13_a74 out nocopy  VARCHAR2
    , p13_a75 out nocopy  VARCHAR2
    , p13_a76 out nocopy  NUMBER
    , p13_a77 out nocopy  NUMBER
    , p13_a78 out nocopy  NUMBER
    , p13_a79 out nocopy  DATE
    , p13_a80 out nocopy  NUMBER
    , p13_a81 out nocopy  DATE
    , p13_a82 out nocopy  NUMBER
    , p13_a83 out nocopy  DATE
    , p13_a84 out nocopy  DATE
    , p13_a85 out nocopy  DATE
    , p13_a86 out nocopy  DATE
    , p13_a87 out nocopy  NUMBER
    , p13_a88 out nocopy  NUMBER
    , p13_a89 out nocopy  NUMBER
    , p13_a90 out nocopy  VARCHAR2
    , p13_a91 out nocopy  NUMBER
    , p13_a92 out nocopy  VARCHAR2
    , p13_a93 out nocopy  NUMBER
    , p13_a94 out nocopy  NUMBER
    , p13_a95 out nocopy  DATE
    , p13_a96 out nocopy  VARCHAR2
    , p13_a97 out nocopy  VARCHAR2
    , p13_a98 out nocopy  NUMBER
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  NUMBER
    , p14_a2 out nocopy  NUMBER
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  NUMBER
    , p14_a5 out nocopy  NUMBER
    , p14_a6 out nocopy  VARCHAR2
    , p14_a7 out nocopy  VARCHAR2
    , p14_a8 out nocopy  VARCHAR2
    , p14_a9 out nocopy  VARCHAR2
    , p14_a10 out nocopy  VARCHAR2
    , p14_a11 out nocopy  NUMBER
    , p14_a12 out nocopy  VARCHAR2
    , p14_a13 out nocopy  NUMBER
    , p14_a14 out nocopy  VARCHAR2
    , p14_a15 out nocopy  NUMBER
    , p14_a16 out nocopy  DATE
    , p14_a17 out nocopy  NUMBER
    , p14_a18 out nocopy  DATE
    , p14_a19 out nocopy  NUMBER
    , p15_a0 out nocopy  NUMBER
    , p15_a1 out nocopy  NUMBER
    , p15_a2 out nocopy  NUMBER
    , p15_a3 out nocopy  NUMBER
    , p15_a4 out nocopy  NUMBER
    , p15_a5 out nocopy  NUMBER
    , p15_a6 out nocopy  VARCHAR2
    , p15_a7 out nocopy  VARCHAR2
    , p15_a8 out nocopy  VARCHAR2
    , p15_a9 out nocopy  VARCHAR2
    , p15_a10 out nocopy  VARCHAR2
    , p15_a11 out nocopy  NUMBER
    , p15_a12 out nocopy  VARCHAR2
    , p15_a13 out nocopy  NUMBER
    , p15_a14 out nocopy  VARCHAR2
    , p15_a15 out nocopy  NUMBER
    , p15_a16 out nocopy  DATE
    , p15_a17 out nocopy  NUMBER
    , p15_a18 out nocopy  DATE
    , p15_a19 out nocopy  NUMBER
    , p16_a0 out nocopy  NUMBER
    , p16_a1 out nocopy  NUMBER
    , p16_a2 out nocopy  VARCHAR2
    , p16_a3 out nocopy  NUMBER
    , p16_a4 out nocopy  NUMBER
    , p16_a5 out nocopy  NUMBER
    , p16_a6 out nocopy  NUMBER
    , p16_a7 out nocopy  NUMBER
    , p16_a8 out nocopy  NUMBER
    , p16_a9 out nocopy  NUMBER
    , p16_a10 out nocopy  NUMBER
    , p16_a11 out nocopy  NUMBER
    , p16_a12 out nocopy  VARCHAR2
    , p16_a13 out nocopy  VARCHAR2
    , p16_a14 out nocopy  VARCHAR2
    , p16_a15 out nocopy  NUMBER
    , p16_a16 out nocopy  NUMBER
    , p16_a17 out nocopy  NUMBER
    , p16_a18 out nocopy  VARCHAR2
    , p16_a19 out nocopy  NUMBER
    , p16_a20 out nocopy  NUMBER
    , p16_a21 out nocopy  VARCHAR2
    , p16_a22 out nocopy  VARCHAR2
    , p16_a23 out nocopy  VARCHAR2
    , p16_a24 out nocopy  VARCHAR2
    , p16_a25 out nocopy  DATE
    , p16_a26 out nocopy  DATE
    , p16_a27 out nocopy  DATE
    , p16_a28 out nocopy  NUMBER
    , p16_a29 out nocopy  NUMBER
    , p16_a30 out nocopy  NUMBER
    , p16_a31 out nocopy  VARCHAR2
    , p16_a32 out nocopy  NUMBER
    , p16_a33 out nocopy  NUMBER
    , p16_a34 out nocopy  NUMBER
    , p16_a35 out nocopy  NUMBER
    , p16_a36 out nocopy  VARCHAR2
    , p16_a37 out nocopy  VARCHAR2
    , p16_a38 out nocopy  VARCHAR2
    , p16_a39 out nocopy  VARCHAR2
    , p16_a40 out nocopy  VARCHAR2
    , p16_a41 out nocopy  VARCHAR2
    , p16_a42 out nocopy  VARCHAR2
    , p16_a43 out nocopy  VARCHAR2
    , p16_a44 out nocopy  VARCHAR2
    , p16_a45 out nocopy  VARCHAR2
    , p16_a46 out nocopy  VARCHAR2
    , p16_a47 out nocopy  VARCHAR2
    , p16_a48 out nocopy  VARCHAR2
    , p16_a49 out nocopy  VARCHAR2
    , p16_a50 out nocopy  VARCHAR2
    , p16_a51 out nocopy  VARCHAR2
    , p16_a52 out nocopy  NUMBER
    , p16_a53 out nocopy  DATE
    , p16_a54 out nocopy  NUMBER
    , p16_a55 out nocopy  DATE
    , p16_a56 out nocopy  NUMBER
    , p16_a57 out nocopy  VARCHAR2
    , p16_a58 out nocopy  NUMBER
    , p16_a59 out nocopy  NUMBER
    , p16_a60 out nocopy  NUMBER
    , p16_a61 out nocopy  NUMBER
    , p16_a62 out nocopy  NUMBER
    , p16_a63 out nocopy  NUMBER
    , p16_a64 out nocopy  NUMBER
    , p16_a65 out nocopy  NUMBER
    , p16_a66 out nocopy  NUMBER
    , p16_a67 out nocopy  DATE
    , p16_a68 out nocopy  NUMBER
    , p16_a69 out nocopy  NUMBER
    , p16_a70 out nocopy  NUMBER
    , p16_a71 out nocopy  VARCHAR2
    , p16_a72 out nocopy  NUMBER
    , p16_a73 out nocopy  VARCHAR2
    , p16_a74 out nocopy  VARCHAR2
    , p16_a75 out nocopy  NUMBER
    , p16_a76 out nocopy  DATE
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  NUMBER := 0-1962.0724
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  NUMBER := 0-1962.0724
    , p8_a20  NUMBER := 0-1962.0724
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  DATE := fnd_api.g_miss_date
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  DATE := fnd_api.g_miss_date
    , p8_a31  DATE := fnd_api.g_miss_date
    , p8_a32  DATE := fnd_api.g_miss_date
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  NUMBER := 0-1962.0724
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
    , p8_a43  VARCHAR2 := fnd_api.g_miss_char
    , p8_a44  VARCHAR2 := fnd_api.g_miss_char
    , p8_a45  VARCHAR2 := fnd_api.g_miss_char
    , p8_a46  VARCHAR2 := fnd_api.g_miss_char
    , p8_a47  VARCHAR2 := fnd_api.g_miss_char
    , p8_a48  VARCHAR2 := fnd_api.g_miss_char
    , p8_a49  VARCHAR2 := fnd_api.g_miss_char
    , p8_a50  VARCHAR2 := fnd_api.g_miss_char
    , p8_a51  VARCHAR2 := fnd_api.g_miss_char
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  VARCHAR2 := fnd_api.g_miss_char
    , p8_a54  NUMBER := 0-1962.0724
    , p8_a55  DATE := fnd_api.g_miss_date
    , p8_a56  NUMBER := 0-1962.0724
    , p8_a57  DATE := fnd_api.g_miss_date
    , p8_a58  VARCHAR2 := fnd_api.g_miss_char
    , p8_a59  VARCHAR2 := fnd_api.g_miss_char
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  NUMBER := 0-1962.0724
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
    , p8_a66  VARCHAR2 := fnd_api.g_miss_char
    , p8_a67  NUMBER := 0-1962.0724
    , p8_a68  NUMBER := 0-1962.0724
    , p8_a69  NUMBER := 0-1962.0724
    , p8_a70  DATE := fnd_api.g_miss_date
    , p8_a71  NUMBER := 0-1962.0724
    , p8_a72  DATE := fnd_api.g_miss_date
    , p8_a73  NUMBER := 0-1962.0724
    , p8_a74  NUMBER := 0-1962.0724
    , p8_a75  VARCHAR2 := fnd_api.g_miss_char
    , p8_a76  VARCHAR2 := fnd_api.g_miss_char
    , p8_a77  NUMBER := 0-1962.0724
    , p8_a78  NUMBER := 0-1962.0724
    , p8_a79  VARCHAR2 := fnd_api.g_miss_char
    , p8_a80  VARCHAR2 := fnd_api.g_miss_char
    , p8_a81  NUMBER := 0-1962.0724
    , p8_a82  VARCHAR2 := fnd_api.g_miss_char
    , p8_a83  NUMBER := 0-1962.0724
    , p8_a84  NUMBER := 0-1962.0724
    , p8_a85  NUMBER := 0-1962.0724
    , p8_a86  NUMBER := 0-1962.0724
    , p8_a87  VARCHAR2 := fnd_api.g_miss_char
    , p8_a88  NUMBER := 0-1962.0724
    , p8_a89  NUMBER := 0-1962.0724
  );
  procedure update_ints_ib_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p_top_line_id  NUMBER
    , p_dnz_chr_id  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_VARCHAR2_TABLE_100
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_VARCHAR2_TABLE_100
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_500
    , p9_a21 JTF_VARCHAR2_TABLE_500
    , p9_a22 JTF_VARCHAR2_TABLE_500
    , p9_a23 JTF_VARCHAR2_TABLE_500
    , p9_a24 JTF_VARCHAR2_TABLE_500
    , p9_a25 JTF_VARCHAR2_TABLE_500
    , p9_a26 JTF_VARCHAR2_TABLE_500
    , p9_a27 JTF_VARCHAR2_TABLE_500
    , p9_a28 JTF_VARCHAR2_TABLE_500
    , p9_a29 JTF_VARCHAR2_TABLE_500
    , p9_a30 JTF_VARCHAR2_TABLE_500
    , p9_a31 JTF_VARCHAR2_TABLE_500
    , p9_a32 JTF_VARCHAR2_TABLE_500
    , p9_a33 JTF_VARCHAR2_TABLE_500
    , p9_a34 JTF_VARCHAR2_TABLE_500
    , p9_a35 JTF_NUMBER_TABLE
    , p9_a36 JTF_DATE_TABLE
    , p9_a37 JTF_NUMBER_TABLE
    , p9_a38 JTF_DATE_TABLE
    , p9_a39 JTF_NUMBER_TABLE
    , p9_a40 JTF_NUMBER_TABLE
    , p9_a41 JTF_NUMBER_TABLE
    , p9_a42 JTF_VARCHAR2_TABLE_100
    , p9_a43 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 out nocopy JTF_DATE_TABLE
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 out nocopy JTF_DATE_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_DATE_TABLE
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_NUMBER_TABLE
    , p10_a57 out nocopy JTF_DATE_TABLE
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_NUMBER_TABLE
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a67 out nocopy JTF_NUMBER_TABLE
    , p10_a68 out nocopy JTF_NUMBER_TABLE
    , p10_a69 out nocopy JTF_NUMBER_TABLE
    , p10_a70 out nocopy JTF_DATE_TABLE
    , p10_a71 out nocopy JTF_NUMBER_TABLE
    , p10_a72 out nocopy JTF_DATE_TABLE
    , p10_a73 out nocopy JTF_NUMBER_TABLE
    , p10_a74 out nocopy JTF_NUMBER_TABLE
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a81 out nocopy JTF_NUMBER_TABLE
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a83 out nocopy JTF_NUMBER_TABLE
    , p10_a84 out nocopy JTF_NUMBER_TABLE
    , p10_a85 out nocopy JTF_NUMBER_TABLE
    , p10_a86 out nocopy JTF_NUMBER_TABLE
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_NUMBER_TABLE
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a35 out nocopy JTF_NUMBER_TABLE
    , p11_a36 out nocopy JTF_DATE_TABLE
    , p11_a37 out nocopy JTF_NUMBER_TABLE
    , p11_a38 out nocopy JTF_DATE_TABLE
    , p11_a39 out nocopy JTF_NUMBER_TABLE
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_NUMBER_TABLE
    , p11_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a43 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_ints_ib_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_new_yn  VARCHAR2
    , p_asset_number  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_200
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_2000
    , p7_a14 JTF_VARCHAR2_TABLE_2000
    , p7_a15 JTF_VARCHAR2_TABLE_2000
    , p7_a16 JTF_VARCHAR2_TABLE_300
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_VARCHAR2_TABLE_100
    , p7_a25 JTF_VARCHAR2_TABLE_2000
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_DATE_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_500
    , p7_a40 JTF_VARCHAR2_TABLE_500
    , p7_a41 JTF_VARCHAR2_TABLE_500
    , p7_a42 JTF_VARCHAR2_TABLE_500
    , p7_a43 JTF_VARCHAR2_TABLE_500
    , p7_a44 JTF_VARCHAR2_TABLE_500
    , p7_a45 JTF_VARCHAR2_TABLE_500
    , p7_a46 JTF_VARCHAR2_TABLE_500
    , p7_a47 JTF_VARCHAR2_TABLE_500
    , p7_a48 JTF_VARCHAR2_TABLE_500
    , p7_a49 JTF_VARCHAR2_TABLE_500
    , p7_a50 JTF_VARCHAR2_TABLE_500
    , p7_a51 JTF_VARCHAR2_TABLE_500
    , p7_a52 JTF_VARCHAR2_TABLE_500
    , p7_a53 JTF_VARCHAR2_TABLE_500
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_DATE_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_DATE_TABLE
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_VARCHAR2_TABLE_100
    , p7_a63 JTF_VARCHAR2_TABLE_100
    , p7_a64 JTF_VARCHAR2_TABLE_100
    , p7_a65 JTF_VARCHAR2_TABLE_100
    , p7_a66 JTF_VARCHAR2_TABLE_100
    , p7_a67 JTF_NUMBER_TABLE
    , p7_a68 JTF_NUMBER_TABLE
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_DATE_TABLE
    , p7_a71 JTF_NUMBER_TABLE
    , p7_a72 JTF_DATE_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_NUMBER_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_VARCHAR2_TABLE_100
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_NUMBER_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_VARCHAR2_TABLE_100
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  NUMBER
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  NUMBER
    , p8_a55 out nocopy  DATE
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  DATE
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  DATE
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  NUMBER
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  VARCHAR2
    , p8_a80 out nocopy  VARCHAR2
    , p8_a81 out nocopy  NUMBER
    , p8_a82 out nocopy  VARCHAR2
    , p8_a83 out nocopy  NUMBER
    , p8_a84 out nocopy  NUMBER
    , p8_a85 out nocopy  NUMBER
    , p8_a86 out nocopy  NUMBER
    , p8_a87 out nocopy  VARCHAR2
    , p8_a88 out nocopy  NUMBER
    , p8_a89 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  NUMBER
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  NUMBER
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  DATE
    , p9_a21 out nocopy  DATE
    , p9_a22 out nocopy  NUMBER
    , p9_a23 out nocopy  NUMBER
    , p9_a24 out nocopy  DATE
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  NUMBER
    , p9_a28 out nocopy  NUMBER
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  NUMBER
    , p9_a34 out nocopy  DATE
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  DATE
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  NUMBER
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  DATE
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  DATE
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  DATE
    , p9_a48 out nocopy  DATE
    , p9_a49 out nocopy  DATE
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  VARCHAR2
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  DATE
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  VARCHAR2
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  NUMBER
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  DATE
    , p9_a80 out nocopy  NUMBER
    , p9_a81 out nocopy  DATE
    , p9_a82 out nocopy  NUMBER
    , p9_a83 out nocopy  DATE
    , p9_a84 out nocopy  DATE
    , p9_a85 out nocopy  DATE
    , p9_a86 out nocopy  DATE
    , p9_a87 out nocopy  NUMBER
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p9_a90 out nocopy  VARCHAR2
    , p9_a91 out nocopy  NUMBER
    , p9_a92 out nocopy  VARCHAR2
    , p9_a93 out nocopy  NUMBER
    , p9_a94 out nocopy  NUMBER
    , p9_a95 out nocopy  DATE
    , p9_a96 out nocopy  VARCHAR2
    , p9_a97 out nocopy  VARCHAR2
    , p9_a98 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  DATE
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  DATE
    , p10_a19 out nocopy  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  VARCHAR2
    , p11_a7 out nocopy  VARCHAR2
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  DATE
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  DATE
    , p11_a19 out nocopy  NUMBER
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  NUMBER
    , p12_a9 out nocopy  NUMBER
    , p12_a10 out nocopy  NUMBER
    , p12_a11 out nocopy  NUMBER
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  NUMBER
    , p12_a16 out nocopy  NUMBER
    , p12_a17 out nocopy  NUMBER
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  NUMBER
    , p12_a20 out nocopy  NUMBER
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  DATE
    , p12_a26 out nocopy  DATE
    , p12_a27 out nocopy  DATE
    , p12_a28 out nocopy  NUMBER
    , p12_a29 out nocopy  NUMBER
    , p12_a30 out nocopy  NUMBER
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  NUMBER
    , p12_a33 out nocopy  NUMBER
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  NUMBER
    , p12_a36 out nocopy  VARCHAR2
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , p12_a45 out nocopy  VARCHAR2
    , p12_a46 out nocopy  VARCHAR2
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  VARCHAR2
    , p12_a50 out nocopy  VARCHAR2
    , p12_a51 out nocopy  VARCHAR2
    , p12_a52 out nocopy  NUMBER
    , p12_a53 out nocopy  DATE
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  DATE
    , p12_a56 out nocopy  NUMBER
    , p12_a57 out nocopy  VARCHAR2
    , p12_a58 out nocopy  NUMBER
    , p12_a59 out nocopy  NUMBER
    , p12_a60 out nocopy  NUMBER
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  NUMBER
    , p12_a63 out nocopy  NUMBER
    , p12_a64 out nocopy  NUMBER
    , p12_a65 out nocopy  NUMBER
    , p12_a66 out nocopy  NUMBER
    , p12_a67 out nocopy  DATE
    , p12_a68 out nocopy  NUMBER
    , p12_a69 out nocopy  NUMBER
    , p12_a70 out nocopy  NUMBER
    , p12_a71 out nocopy  VARCHAR2
    , p12_a72 out nocopy  NUMBER
    , p12_a73 out nocopy  VARCHAR2
    , p12_a74 out nocopy  VARCHAR2
    , p12_a75 out nocopy  NUMBER
    , p12_a76 out nocopy  DATE
  );
  procedure create_asset_line_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
  );
  procedure update_asset_line_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
  );
end okl_create_kle_pub_w;

 

/
