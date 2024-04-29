--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_PROCESS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_PROCESS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUAECS.pls 120.1 2005/07/07 13:31:37 dkagrawa noship $ */
  procedure do_accounting_con(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_request_id out nocopy  NUMBER
  );
end okl_accounting_process_pub_w;

 

/
