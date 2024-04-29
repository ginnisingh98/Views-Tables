--------------------------------------------------------
--  DDL for Package OKL_INTEREST_CALC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_CALC_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUITUS.pls 120.1 2005/07/14 12:03:58 asawanka noship $ */
  procedure calc_interest_activate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_activation_date  date
    , x_amount out nocopy  NUMBER
    , x_source_id out nocopy  NUMBER
  );
end okl_interest_calc_pub_w;

 

/
