--------------------------------------------------------
--  DDL for Package OKL_CASH_RULES_SUMRY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_RULES_SUMRY_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCSYS.pls 115.0 2002/12/24 01:14:00 bvaghela noship $ */
  procedure okl_cash_rl_sumry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
  );
end okl_cash_rules_sumry_pub_w;

 

/
