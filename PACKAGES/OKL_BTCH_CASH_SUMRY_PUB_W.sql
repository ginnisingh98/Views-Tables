--------------------------------------------------------
--  DDL for Package OKL_BTCH_CASH_SUMRY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BTCH_CASH_SUMRY_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUBASS.pls 115.4 2003/11/11 02:02:49 rgalipo noship $ */
  procedure okl_batch_sumry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out NOCOPY VARCHAR2
    , x_msg_count out NOCOPY NUMBER
    , x_msg_data out  NOCOPY VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  );
end okl_btch_cash_sumry_pub_w;

 

/
