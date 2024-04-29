--------------------------------------------------------
--  DDL for Package OKL_AM_AMORTIZE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_AMORTIZE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLETATS.pls 120.6.12010000.2 2010/04/29 15:10:54 rpillay ship $ */
  procedure create_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_kle_id  NUMBER
    , p_early_termination_yn  VARCHAR2
    , p_quote_eff_date  date
    , p_quote_accpt_date  date
  );
  procedure create_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_early_termination_yn  VARCHAR2
    , p_quote_eff_date  date
    , p_quote_accpt_date  date
  );
  procedure update_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  DATE := fnd_api.g_miss_date
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  DATE := fnd_api.g_miss_date
    , p6_a58  NUMBER := 0-1962.0724
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  NUMBER := 0-1962.0724
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  NUMBER := 0-1962.0724
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  DATE := fnd_api.g_miss_date
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  NUMBER := 0-1962.0724
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  NUMBER := 0-1962.0724
  );
  procedure update_offlease_asset_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_4000
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_VARCHAR2_TABLE_400
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_VARCHAR2_TABLE_100
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_NUMBER_TABLE
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_NUMBER_TABLE
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_NUMBER_TABLE
    , p6_a63 JTF_NUMBER_TABLE
    , p6_a64 JTF_NUMBER_TABLE
    , p6_a65 JTF_NUMBER_TABLE
    , p6_a66 JTF_NUMBER_TABLE
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_DATE_TABLE
    , p6_a70 JTF_NUMBER_TABLE
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_NUMBER_TABLE
    , p6_a73 JTF_VARCHAR2_TABLE_100
    , p6_a74 JTF_NUMBER_TABLE
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_DATE_TABLE
    , p6_a79 JTF_NUMBER_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_NUMBER_TABLE
    , x_record_status out nocopy  VARCHAR2
  );
  procedure update_depreciation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
  );
end okl_am_amortize_pvt_w;

/
