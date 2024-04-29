--------------------------------------------------------
--  DDL for Package OKL_REVERSE_CONTRACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSE_CONTRACT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLIRVKS.pls 120.2 2005/07/18 15:54:44 viselvar noship $ */
  procedure reverse_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_transaction_date  date
  );
end okl_reverse_contract_pvt_w;

 

/
