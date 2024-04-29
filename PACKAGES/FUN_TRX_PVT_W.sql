--------------------------------------------------------
--  DDL for Package FUN_TRX_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TRX_PVT_W" AUTHID CURRENT_USER as
  /* $Header: fun_trx_pvt_w_s.pls 120.6.12010000.4 2010/01/25 07:34:50 ychandra ship $ */
  TYPE numarray IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
  procedure rosetta_table_copy_in_p5(t out nocopy fun_trx_pvt.batch_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t fun_trx_pvt.batch_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy fun_trx_pvt.trx_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t fun_trx_pvt.trx_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p7(t out nocopy fun_trx_pvt.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t fun_trx_pvt.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy fun_trx_pvt.init_dist_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p8(t fun_trx_pvt.init_dist_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p9(t out nocopy fun_trx_pvt.dist_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t fun_trx_pvt.dist_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p10(t out nocopy fun_trx_pvt.number_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p10(t fun_trx_pvt.number_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure init_batch_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_insert  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  DATE
    , p7_a13 in out nocopy  DATE
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_DATE_TABLE
    , p8_a15 in out nocopy JTF_NUMBER_TABLE
    , p8_a16 in out nocopy JTF_NUMBER_TABLE
    , p8_a17 in out nocopy JTF_NUMBER_TABLE
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_NUMBER_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_NUMBER_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure init_trx_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  NUMBER
    , p6_a9 in out nocopy  NUMBER
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  VARCHAR2
    , p6_a13 in out nocopy  NUMBER
    , p6_a14 in out nocopy  DATE
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  NUMBER
    , p6_a17 in out nocopy  NUMBER
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  VARCHAR2
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_currency_code  VARCHAR2
    , p_gl_date  DATE
    , p_trx_date  DATE
  );
  procedure init_dist_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_le_id  NUMBER
    , p_ledger_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
  );
  procedure init_ic_dist_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_le_id  NUMBER
    , p_ledger_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  VARCHAR2
  );
  procedure init_generate_distributions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  DATE
    , p5_a13 in out nocopy  DATE
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  NUMBER
    , p5_a16 in out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 in out nocopy JTF_NUMBER_TABLE
    , p6_a14 in out nocopy JTF_DATE_TABLE
    , p6_a15 in out nocopy JTF_NUMBER_TABLE
    , p6_a16 in out nocopy JTF_NUMBER_TABLE
    , p6_a17 in out nocopy JTF_NUMBER_TABLE
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure create_reverse_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_trx_tbl_id JTF_NUMBER_TABLE
    , p_reversed_batch_number  VARCHAR2
    , p_reversal_method  VARCHAR2
    , p_reversed_batch_date  DATE
    , p_reversed_gl_date  DATE
    , p_reversed_description  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_reversed_batch_id in out nocopy  NUMBER
  );
  procedure recipient_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );

    procedure Modified(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );

  procedure is_Modified(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );

  procedure ini_recipient_validate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  DATE
    , p6_a13 in out nocopy  DATE
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  NUMBER
    , p6_a16 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  DATE
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_NUMBER_TABLE
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );
function isOldDistId(distId number) return varchar2;
end fun_trx_pvt_w;

/
