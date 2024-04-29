--------------------------------------------------------
--  DDL for Package OKL_FE_STD_RATE_TMPL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_STD_RATE_TMPL_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUSRTS.pls 120.0 2005/07/07 10:46:52 viselvar noship $ */
  procedure get_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_srt_id  NUMBER
    , p_version_number  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  DATE
    , p7_a37 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
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
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  DATE
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_DATE_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_DATE_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a9 out nocopy JTF_NUMBER_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_DATE_TABLE
    , p11_a12 out nocopy JTF_DATE_TABLE
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_DATE_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_DATE_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_500
  );
  procedure get_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_srt_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  DATE
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  DATE
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_DATE_TABLE
    , p9_a5 out nocopy JTF_DATE_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_DATE_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_DATE_TABLE
    , p10_a12 out nocopy JTF_DATE_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_DATE_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
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
  );
  procedure create_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
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
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
  );
  procedure insert_srt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  DATE
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  NUMBER
    , p6_a30  DATE
    , p6_a31  NUMBER
    , p6_a32  DATE
    , p6_a33  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  DATE
    , p7_a37 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
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
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  NUMBER
  );
  procedure update_srt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
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
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
  );
  procedure invalid_objects(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_version_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure calc_start_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , x_cal_eff_from out nocopy  DATE
  );
end okl_fe_std_rate_tmpl_pub_w;

 

/
