--------------------------------------------------------
--  DDL for Package OKL_SETUP_DISB_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_DISB_RULES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLESDRS.pls 120.0 2007/04/27 09:20:05 gkhuntet noship $ */
  procedure create_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  DATE
    , p8_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  );
  procedure update_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  DATE
    , p8_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  );
  procedure validate_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_DATE_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  );
  procedure create_v_disbursement_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
  );
end okl_setup_disb_rules_pvt_w;

/
