--------------------------------------------------------
--  DDL for Package OKL_AM_RV_WRITEDOWN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_RV_WRITEDOWN_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLURVWS.pls 120.1 2005/07/07 12:49:33 asawanka noship $ */
  procedure create_residual_value_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , x_residual_value_status out nocopy  VARCHAR2
  );
end okl_am_rv_writedown_pub_w;

 

/
