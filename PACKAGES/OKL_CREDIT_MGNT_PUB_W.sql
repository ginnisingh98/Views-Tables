--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MGNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MGNT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCMTS.pls 115.3 2003/10/30 23:20:06 rgalipo noship $ */
  procedure submit_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p_review_type  VARCHAR2
    , p_credit_classification  VARCHAR2
    , p_requested_amount  NUMBER
    , p_contact_party_id  NUMBER
    , p_notes  VARCHAR2
    , p11_a0  NUMBER
    , p11_a1  NUMBER
    , p11_a2  NUMBER
    , p11_a3  NUMBER
    , p11_a4  NUMBER
    , p11_a5  VARCHAR2
    , p11_a6  NUMBER
    , p11_a7  VARCHAR2
    , p11_a8  NUMBER
    , p11_a9  NUMBER
    , p11_a10  NUMBER
    , p11_a11  NUMBER
    , p11_a12  NUMBER
  );
  procedure compile_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
  );
end okl_credit_mgnt_pub_w;

 

/
