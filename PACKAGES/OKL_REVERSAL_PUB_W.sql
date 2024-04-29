--------------------------------------------------------
--  DDL for Package OKL_REVERSAL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSAL_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUREVS.pls 120.1 2005/07/18 15:58:00 viselvar noship $ */
  procedure reverse_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_id  NUMBER
    , p_source_table  VARCHAR2
    , p_acct_date  date
  );
  procedure reverse_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_table  VARCHAR2
    , p_acct_date  date
    , p_source_id_tbl JTF_NUMBER_TABLE
  );
end okl_reversal_pub_w;

 

/
