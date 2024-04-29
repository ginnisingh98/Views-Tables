--------------------------------------------------------
--  DDL for Package OKL_LA_VALIDATION_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_VALIDATION_UTIL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEDVUS.pls 115.4 2003/09/23 14:17:54 kthiruva noship $ */
  procedure validate_deal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_scs_code  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_customer_id1 in out nocopy  VARCHAR2
    , p_customer_id2 in out nocopy  VARCHAR2
    , p_customer_code in out nocopy  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_chr_cust_acct_id out nocopy  NUMBER
    , p_customer_acc_name  VARCHAR2
    , p_product_name  VARCHAR2
    , p_product_id in out nocopy  VARCHAR2
    , p_product_desc in out nocopy  VARCHAR2
    , p_contact_id1 in out nocopy  VARCHAR2
    , p_contact_id2 in out nocopy  VARCHAR2
    , p_contact_code in out nocopy  VARCHAR2
    , p_contact_name  VARCHAR2
    , p_mla_no  VARCHAR2
    , p_mla_id in out nocopy  VARCHAR2
    , p_program_no  VARCHAR2
    , p_program_id in out nocopy  VARCHAR2
    , p_credit_line_no  VARCHAR2
    , p_credit_line_id in out nocopy  VARCHAR2
    , p_currency_name  VARCHAR2
    , p_currency_code in out nocopy  VARCHAR2
    , p_start_date  date
    , p_deal_type  VARCHAR2
  );
end okl_la_validation_util_pvt_w;

 

/
