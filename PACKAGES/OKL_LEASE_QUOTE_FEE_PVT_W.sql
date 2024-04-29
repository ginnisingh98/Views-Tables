--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_FEE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_FEE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEQUFS.pls 120.6 2006/03/16 10:09:34 asawanka noship $ */
  procedure rosetta_table_copy_in_p24(t out nocopy okl_lease_quote_fee_pvt.line_relation_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p24(t okl_lease_quote_fee_pvt.line_relation_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_fee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  NUMBER
    , p3_a20  NUMBER
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  VARCHAR2
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_300
    , p4_a8 JTF_VARCHAR2_TABLE_2000
    , p4_a9 JTF_VARCHAR2_TABLE_2000
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_DATE_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , x_fee_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_fee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  NUMBER
    , p3_a20  NUMBER
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  VARCHAR2
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  NUMBER
    , p_sync_fee_header  VARCHAR2
    , p_sync_line_relations  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_fee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  NUMBER
    , p3_a20  NUMBER
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  VARCHAR2
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_300
    , p4_a8 JTF_VARCHAR2_TABLE_2000
    , p4_a9 JTF_VARCHAR2_TABLE_2000
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_DATE_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure duplicate_fee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_fee_id  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  NUMBER
    , p4_a20  NUMBER
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  NUMBER
    , p4_a24  NUMBER
    , p4_a25  NUMBER
    , p4_a26  VARCHAR2
    , p4_a27  DATE
    , p4_a28  DATE
    , p4_a29  NUMBER
    , p4_a30  NUMBER
    , p4_a31  NUMBER
    , p4_a32  NUMBER
    , p4_a33  NUMBER
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_DATE_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , x_fee_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_lease_quote_fee_pvt_w;

/
