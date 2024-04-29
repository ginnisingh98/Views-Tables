--------------------------------------------------------
--  DDL for Package OKL_ACCRUAL_DEPRN_ADJ_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCRUAL_DEPRN_ADJ_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUADAS.pls 115.1 2003/10/08 17:46:54 sgiyer noship $ */
  function submit_deprn_adjustment(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_batch_name  VARCHAR2
    , p_date_from  date
    , p_date_to  date
  ) return number;
end okl_accrual_deprn_adj_pub_w;

 

/
