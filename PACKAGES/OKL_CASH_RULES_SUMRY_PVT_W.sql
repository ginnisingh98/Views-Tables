--------------------------------------------------------
--  DDL for Package OKL_CASH_RULES_SUMRY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_RULES_SUMRY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLECSYS.pls 115.0 2002/12/24 01:13:50 bvaghela noship $ */
  procedure rosetta_table_copy_in_p13(t out nocopy okl_cash_rules_sumry_pvt.okl_cash_rl_sumry_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t okl_cash_rules_sumry_pvt.okl_cash_rl_sumry_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure handle_cash_rl_sumry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
  );
end okl_cash_rules_sumry_pvt_w;

 

/
