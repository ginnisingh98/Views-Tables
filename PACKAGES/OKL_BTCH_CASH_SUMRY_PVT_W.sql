--------------------------------------------------------
--  DDL for Package OKL_BTCH_CASH_SUMRY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BTCH_CASH_SUMRY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEBASS.pls 115.4 2003/11/11 02:00:11 rgalipo noship $ */
  procedure rosetta_table_copy_in_p13(t out NOCOPY okl_btch_cash_sumry_pvt.okl_btch_sumry_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p13(t okl_btch_cash_sumry_pvt.okl_btch_sumry_tbl_type, a0 out NOCOPY JTF_NUMBER_TABLE
    , a1 out NOCOPY JTF_VARCHAR2_TABLE_100
    );

  procedure handle_batch_sumry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out NOCOPY VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  );
end okl_btch_cash_sumry_pvt_w;

 

/
