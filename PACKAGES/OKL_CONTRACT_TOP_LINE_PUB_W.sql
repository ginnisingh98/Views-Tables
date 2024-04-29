--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_TOP_LINE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_TOP_LINE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUKTLS.pls 115.3 2003/10/16 01:10:34 smereddy noship $ */
  procedure create_contract_top_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p12_a6 out nocopy  VARCHAR2
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  VARCHAR2
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  VARCHAR2
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  VARCHAR2
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  VARCHAR2
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  VARCHAR2
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  DATE
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  DATE
    , p12_a38 out nocopy  NUMBER
    , p12_a39 out nocopy  NUMBER
    , p12_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  DATE := fnd_api.g_miss_date
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  DATE := fnd_api.g_miss_date
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  DATE := fnd_api.g_miss_date
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  DATE := fnd_api.g_miss_date
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  DATE := fnd_api.g_miss_date
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  DATE := fnd_api.g_miss_date
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  NUMBER := 0-1962.0724
    , p8_a35  DATE := fnd_api.g_miss_date
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  DATE := fnd_api.g_miss_date
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
  );
  procedure update_contract_top_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p12_a6 out nocopy  VARCHAR2
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  VARCHAR2
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  VARCHAR2
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  VARCHAR2
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  VARCHAR2
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  VARCHAR2
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  NUMBER
    , p12_a35 out nocopy  DATE
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  DATE
    , p12_a38 out nocopy  NUMBER
    , p12_a39 out nocopy  NUMBER
    , p12_a40 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  DATE := fnd_api.g_miss_date
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  DATE := fnd_api.g_miss_date
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  DATE := fnd_api.g_miss_date
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  DATE := fnd_api.g_miss_date
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  DATE := fnd_api.g_miss_date
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  DATE := fnd_api.g_miss_date
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  NUMBER := 0-1962.0724
    , p8_a35  DATE := fnd_api.g_miss_date
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  DATE := fnd_api.g_miss_date
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
  );
  procedure delete_contract_top_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  DATE := fnd_api.g_miss_date
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  DATE := fnd_api.g_miss_date
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  DATE := fnd_api.g_miss_date
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  DATE := fnd_api.g_miss_date
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  DATE := fnd_api.g_miss_date
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  DATE := fnd_api.g_miss_date
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  NUMBER := 0-1962.0724
    , p8_a35  DATE := fnd_api.g_miss_date
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  DATE := fnd_api.g_miss_date
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  NUMBER := 0-1962.0724
    , p8_a40  NUMBER := 0-1962.0724
  );
  procedure create_contract_top_line(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_200
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_200
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_300
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_VARCHAR2_TABLE_100
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_VARCHAR2_TABLE_200
    , p8_a18 JTF_VARCHAR2_TABLE_100
    , p8_a19 JTF_VARCHAR2_TABLE_500
    , p8_a20 JTF_VARCHAR2_TABLE_500
    , p8_a21 JTF_VARCHAR2_TABLE_500
    , p8_a22 JTF_VARCHAR2_TABLE_500
    , p8_a23 JTF_VARCHAR2_TABLE_500
    , p8_a24 JTF_VARCHAR2_TABLE_500
    , p8_a25 JTF_VARCHAR2_TABLE_500
    , p8_a26 JTF_VARCHAR2_TABLE_500
    , p8_a27 JTF_VARCHAR2_TABLE_500
    , p8_a28 JTF_VARCHAR2_TABLE_500
    , p8_a29 JTF_VARCHAR2_TABLE_500
    , p8_a30 JTF_VARCHAR2_TABLE_500
    , p8_a31 JTF_VARCHAR2_TABLE_500
    , p8_a32 JTF_VARCHAR2_TABLE_500
    , p8_a33 JTF_VARCHAR2_TABLE_500
    , p8_a34 JTF_NUMBER_TABLE
    , p8_a35 JTF_DATE_TABLE
    , p8_a36 JTF_NUMBER_TABLE
    , p8_a37 JTF_DATE_TABLE
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 out nocopy JTF_DATE_TABLE
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 out nocopy JTF_DATE_TABLE
    , p9_a31 out nocopy JTF_DATE_TABLE
    , p9_a32 out nocopy JTF_DATE_TABLE
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 out nocopy JTF_NUMBER_TABLE
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 out nocopy JTF_NUMBER_TABLE
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_DATE_TABLE
    , p9_a56 out nocopy JTF_NUMBER_TABLE
    , p9_a57 out nocopy JTF_DATE_TABLE
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_NUMBER_TABLE
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a67 out nocopy JTF_NUMBER_TABLE
    , p9_a68 out nocopy JTF_NUMBER_TABLE
    , p9_a69 out nocopy JTF_NUMBER_TABLE
    , p9_a70 out nocopy JTF_DATE_TABLE
    , p9_a71 out nocopy JTF_NUMBER_TABLE
    , p9_a72 out nocopy JTF_DATE_TABLE
    , p9_a73 out nocopy JTF_NUMBER_TABLE
    , p9_a74 out nocopy JTF_NUMBER_TABLE
    , p9_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a77 out nocopy JTF_NUMBER_TABLE
    , p9_a78 out nocopy JTF_NUMBER_TABLE
    , p9_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a81 out nocopy JTF_NUMBER_TABLE
    , p9_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a83 out nocopy JTF_NUMBER_TABLE
    , p9_a84 out nocopy JTF_NUMBER_TABLE
    , p9_a85 out nocopy JTF_NUMBER_TABLE
    , p9_a86 out nocopy JTF_NUMBER_TABLE
    , p9_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a88 out nocopy JTF_NUMBER_TABLE
    , p9_a89 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_NUMBER_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_DATE_TABLE
    , p10_a21 out nocopy JTF_DATE_TABLE
    , p10_a22 out nocopy JTF_NUMBER_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_DATE_TABLE
    , p10_a26 out nocopy JTF_DATE_TABLE
    , p10_a27 out nocopy JTF_NUMBER_TABLE
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_NUMBER_TABLE
    , p10_a30 out nocopy JTF_NUMBER_TABLE
    , p10_a31 out nocopy JTF_NUMBER_TABLE
    , p10_a32 out nocopy JTF_NUMBER_TABLE
    , p10_a33 out nocopy JTF_NUMBER_TABLE
    , p10_a34 out nocopy JTF_DATE_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_DATE_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_NUMBER_TABLE
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 out nocopy JTF_DATE_TABLE
    , p10_a43 out nocopy JTF_NUMBER_TABLE
    , p10_a44 out nocopy JTF_NUMBER_TABLE
    , p10_a45 out nocopy JTF_DATE_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_DATE_TABLE
    , p10_a48 out nocopy JTF_DATE_TABLE
    , p10_a49 out nocopy JTF_DATE_TABLE
    , p10_a50 out nocopy JTF_NUMBER_TABLE
    , p10_a51 out nocopy JTF_NUMBER_TABLE
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a53 out nocopy JTF_NUMBER_TABLE
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a57 out nocopy JTF_NUMBER_TABLE
    , p10_a58 out nocopy JTF_DATE_TABLE
    , p10_a59 out nocopy JTF_NUMBER_TABLE
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a76 out nocopy JTF_NUMBER_TABLE
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_DATE_TABLE
    , p10_a80 out nocopy JTF_NUMBER_TABLE
    , p10_a81 out nocopy JTF_DATE_TABLE
    , p10_a82 out nocopy JTF_NUMBER_TABLE
    , p10_a83 out nocopy JTF_DATE_TABLE
    , p10_a84 out nocopy JTF_DATE_TABLE
    , p10_a85 out nocopy JTF_DATE_TABLE
    , p10_a86 out nocopy JTF_DATE_TABLE
    , p10_a87 out nocopy JTF_NUMBER_TABLE
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p10_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a91 out nocopy JTF_NUMBER_TABLE
    , p10_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a93 out nocopy JTF_NUMBER_TABLE
    , p10_a94 out nocopy JTF_NUMBER_TABLE
    , p10_a95 out nocopy JTF_DATE_TABLE
    , p10_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a98 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_DATE_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_DATE_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_NUMBER_TABLE
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a34 out nocopy JTF_NUMBER_TABLE
    , p12_a35 out nocopy JTF_DATE_TABLE
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_DATE_TABLE
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_NUMBER_TABLE
    , p12_a40 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_contract_top_line(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_200
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_200
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_300
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_VARCHAR2_TABLE_100
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_VARCHAR2_TABLE_200
    , p8_a18 JTF_VARCHAR2_TABLE_100
    , p8_a19 JTF_VARCHAR2_TABLE_500
    , p8_a20 JTF_VARCHAR2_TABLE_500
    , p8_a21 JTF_VARCHAR2_TABLE_500
    , p8_a22 JTF_VARCHAR2_TABLE_500
    , p8_a23 JTF_VARCHAR2_TABLE_500
    , p8_a24 JTF_VARCHAR2_TABLE_500
    , p8_a25 JTF_VARCHAR2_TABLE_500
    , p8_a26 JTF_VARCHAR2_TABLE_500
    , p8_a27 JTF_VARCHAR2_TABLE_500
    , p8_a28 JTF_VARCHAR2_TABLE_500
    , p8_a29 JTF_VARCHAR2_TABLE_500
    , p8_a30 JTF_VARCHAR2_TABLE_500
    , p8_a31 JTF_VARCHAR2_TABLE_500
    , p8_a32 JTF_VARCHAR2_TABLE_500
    , p8_a33 JTF_VARCHAR2_TABLE_500
    , p8_a34 JTF_NUMBER_TABLE
    , p8_a35 JTF_DATE_TABLE
    , p8_a36 JTF_NUMBER_TABLE
    , p8_a37 JTF_DATE_TABLE
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_NUMBER_TABLE
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 out nocopy JTF_DATE_TABLE
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 out nocopy JTF_DATE_TABLE
    , p9_a31 out nocopy JTF_DATE_TABLE
    , p9_a32 out nocopy JTF_DATE_TABLE
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 out nocopy JTF_NUMBER_TABLE
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 out nocopy JTF_NUMBER_TABLE
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_DATE_TABLE
    , p9_a56 out nocopy JTF_NUMBER_TABLE
    , p9_a57 out nocopy JTF_DATE_TABLE
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_NUMBER_TABLE
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a67 out nocopy JTF_NUMBER_TABLE
    , p9_a68 out nocopy JTF_NUMBER_TABLE
    , p9_a69 out nocopy JTF_NUMBER_TABLE
    , p9_a70 out nocopy JTF_DATE_TABLE
    , p9_a71 out nocopy JTF_NUMBER_TABLE
    , p9_a72 out nocopy JTF_DATE_TABLE
    , p9_a73 out nocopy JTF_NUMBER_TABLE
    , p9_a74 out nocopy JTF_NUMBER_TABLE
    , p9_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a77 out nocopy JTF_NUMBER_TABLE
    , p9_a78 out nocopy JTF_NUMBER_TABLE
    , p9_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a81 out nocopy JTF_NUMBER_TABLE
    , p9_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a83 out nocopy JTF_NUMBER_TABLE
    , p9_a84 out nocopy JTF_NUMBER_TABLE
    , p9_a85 out nocopy JTF_NUMBER_TABLE
    , p9_a86 out nocopy JTF_NUMBER_TABLE
    , p9_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a88 out nocopy JTF_NUMBER_TABLE
    , p9_a89 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_NUMBER_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_NUMBER_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_DATE_TABLE
    , p10_a21 out nocopy JTF_DATE_TABLE
    , p10_a22 out nocopy JTF_NUMBER_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_DATE_TABLE
    , p10_a26 out nocopy JTF_DATE_TABLE
    , p10_a27 out nocopy JTF_NUMBER_TABLE
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_NUMBER_TABLE
    , p10_a30 out nocopy JTF_NUMBER_TABLE
    , p10_a31 out nocopy JTF_NUMBER_TABLE
    , p10_a32 out nocopy JTF_NUMBER_TABLE
    , p10_a33 out nocopy JTF_NUMBER_TABLE
    , p10_a34 out nocopy JTF_DATE_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_DATE_TABLE
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_NUMBER_TABLE
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 out nocopy JTF_DATE_TABLE
    , p10_a43 out nocopy JTF_NUMBER_TABLE
    , p10_a44 out nocopy JTF_NUMBER_TABLE
    , p10_a45 out nocopy JTF_DATE_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_DATE_TABLE
    , p10_a48 out nocopy JTF_DATE_TABLE
    , p10_a49 out nocopy JTF_DATE_TABLE
    , p10_a50 out nocopy JTF_NUMBER_TABLE
    , p10_a51 out nocopy JTF_NUMBER_TABLE
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a53 out nocopy JTF_NUMBER_TABLE
    , p10_a54 out nocopy JTF_NUMBER_TABLE
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a57 out nocopy JTF_NUMBER_TABLE
    , p10_a58 out nocopy JTF_DATE_TABLE
    , p10_a59 out nocopy JTF_NUMBER_TABLE
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a76 out nocopy JTF_NUMBER_TABLE
    , p10_a77 out nocopy JTF_NUMBER_TABLE
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_DATE_TABLE
    , p10_a80 out nocopy JTF_NUMBER_TABLE
    , p10_a81 out nocopy JTF_DATE_TABLE
    , p10_a82 out nocopy JTF_NUMBER_TABLE
    , p10_a83 out nocopy JTF_DATE_TABLE
    , p10_a84 out nocopy JTF_DATE_TABLE
    , p10_a85 out nocopy JTF_DATE_TABLE
    , p10_a86 out nocopy JTF_DATE_TABLE
    , p10_a87 out nocopy JTF_NUMBER_TABLE
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p10_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a91 out nocopy JTF_NUMBER_TABLE
    , p10_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a93 out nocopy JTF_NUMBER_TABLE
    , p10_a94 out nocopy JTF_NUMBER_TABLE
    , p10_a95 out nocopy JTF_DATE_TABLE
    , p10_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a98 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_NUMBER_TABLE
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_NUMBER_TABLE
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_DATE_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_DATE_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_NUMBER_TABLE
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a34 out nocopy JTF_NUMBER_TABLE
    , p12_a35 out nocopy JTF_DATE_TABLE
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_DATE_TABLE
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_NUMBER_TABLE
    , p12_a40 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_contract_top_line(p_api_version  NUMBER
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
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_200
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_200
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_300
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_VARCHAR2_TABLE_100
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_VARCHAR2_TABLE_200
    , p8_a18 JTF_VARCHAR2_TABLE_100
    , p8_a19 JTF_VARCHAR2_TABLE_500
    , p8_a20 JTF_VARCHAR2_TABLE_500
    , p8_a21 JTF_VARCHAR2_TABLE_500
    , p8_a22 JTF_VARCHAR2_TABLE_500
    , p8_a23 JTF_VARCHAR2_TABLE_500
    , p8_a24 JTF_VARCHAR2_TABLE_500
    , p8_a25 JTF_VARCHAR2_TABLE_500
    , p8_a26 JTF_VARCHAR2_TABLE_500
    , p8_a27 JTF_VARCHAR2_TABLE_500
    , p8_a28 JTF_VARCHAR2_TABLE_500
    , p8_a29 JTF_VARCHAR2_TABLE_500
    , p8_a30 JTF_VARCHAR2_TABLE_500
    , p8_a31 JTF_VARCHAR2_TABLE_500
    , p8_a32 JTF_VARCHAR2_TABLE_500
    , p8_a33 JTF_VARCHAR2_TABLE_500
    , p8_a34 JTF_NUMBER_TABLE
    , p8_a35 JTF_DATE_TABLE
    , p8_a36 JTF_NUMBER_TABLE
    , p8_a37 JTF_DATE_TABLE
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_NUMBER_TABLE
    , p8_a40 JTF_NUMBER_TABLE
  );
end okl_contract_top_line_pub_w;

 

/
