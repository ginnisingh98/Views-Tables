--------------------------------------------------------
--  DDL for Package OKL_MULTI_GAAP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MULTI_GAAP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUGAPS.pls 115.2 2004/02/06 22:36:06 sgiyer noship $ */
  function submit_multi_gaap(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_date_from  date
    , p_date_to  date
    , p_batch_name  VARCHAR2
  ) return number;
end okl_multi_gaap_pub_w;

 

/
