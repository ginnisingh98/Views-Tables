--------------------------------------------------------
--  DDL for Package OKL_AM_LEASE_LOAN_TRMNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLULLTS.pls 120.6.12010000.5 2008/12/03 12:29:46 sosharma ship $ */
  procedure lease_loan_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  DATE := fnd_api.g_miss_date
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
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
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  DATE := fnd_api.g_miss_date
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  DATE := fnd_api.g_miss_date
  );
  procedure lease_loan_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_VARCHAR2_TABLE_200
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_100
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_NUMBER_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_VARCHAR2_TABLE_2000
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_100
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_VARCHAR2_TABLE_100
    , p6_a68 JTF_VARCHAR2_TABLE_100
    , p6_a69 JTF_VARCHAR2_TABLE_100
    , p6_a70 JTF_VARCHAR2_TABLE_100
    , p6_a71 JTF_VARCHAR2_TABLE_100
    , p6_a72 JTF_VARCHAR2_TABLE_100
    , p6_a73 JTF_VARCHAR2_TABLE_100
    , p6_a74 JTF_VARCHAR2_TABLE_100
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_DATE_TABLE
    , p6_a79 JTF_NUMBER_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_VARCHAR2_TABLE_100
    , p6_a82 JTF_DATE_TABLE
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_VARCHAR2_TABLE_100
    , p6_a86 JTF_VARCHAR2_TABLE_200
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_VARCHAR2_TABLE_200
    , p6_a89 JTF_VARCHAR2_TABLE_100
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_VARCHAR2_TABLE_100
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_DATE_TABLE
  );
end okl_am_lease_loan_trmnt_pub_w;

/
