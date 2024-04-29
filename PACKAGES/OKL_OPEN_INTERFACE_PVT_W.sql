--------------------------------------------------------
--  DDL for Package OKL_OPEN_INTERFACE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPEN_INTERFACE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEKOIS.pls 120.1 2005/10/04 20:21:03 cklee noship $ */
  procedure check_input_record(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_number  VARCHAR2
    , p_start_date_from  date
    , p_start_date_to  date
    , p_contract_number  VARCHAR2
    , p_customer_number  VARCHAR2
    , x_total_checked out nocopy  NUMBER
  );
  procedure load_input_record(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_number  VARCHAR2
    , p_start_date_from  date
    , p_start_date_to  date
    , p_contract_number  VARCHAR2
    , p_customer_number  VARCHAR2
    , x_total_loaded out nocopy  NUMBER
  );
  function submit_import_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_number  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_party_number  VARCHAR2
  ) return number;
end okl_open_interface_pvt_w;

 

/
