--------------------------------------------------------
--  DDL for Package OKL_INTEREST_CALC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_CALC_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEITUS.pls 120.2 2005/12/08 11:50:00 gboomina noship $ */
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
end okl_interest_calc_pvt_w;

 

/
