--------------------------------------------------------
--  DDL for Package OKL_TRX_CSH_BATCH_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRX_CSH_BATCH_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUBTCS.pls 120.6 2007/09/28 06:49:31 varangan ship $ */
  procedure insert_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
  );
  procedure insert_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
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
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
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
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  );
  procedure lock_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
  );
  procedure lock_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
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
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  );
  procedure update_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
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
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
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
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  );
  procedure delete_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
  );
  procedure delete_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
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
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  );
  procedure validate_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
  );
  procedure validate_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
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
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  );
  procedure handle_batch_receipt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
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
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_200
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_200
    , p7_a17 JTF_VARCHAR2_TABLE_200
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
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
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  );
end okl_trx_csh_batch_pub_w;

/
