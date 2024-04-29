--------------------------------------------------------
--  DDL for Package OKL_XMP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XMP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLIXMPS.pls 120.0 2007/04/02 09:12:21 udhenuko noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_xmp_pvt.xmp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p2(t okl_xmp_pvt.xmp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  NUMBER
    , p5_a23  DATE
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  VARCHAR2
  );
  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  NUMBER
    , p5_a23  DATE
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  VARCHAR2
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  NUMBER
    , p5_a23  DATE
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  VARCHAR2
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  NUMBER
    , p5_a23  DATE
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  VARCHAR2
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  NUMBER
    , p5_a23  DATE
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  VARCHAR2
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
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
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_300
  );
end okl_xmp_pvt_w;

/
