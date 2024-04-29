--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MGNT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MGNT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLECMTS.pls 115.2 2003/01/18 02:08:11 rgalipo noship $ */
  procedure submit_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  NOCOPY VARCHAR2
    , x_msg_count out  NOCOPY NUMBER
    , x_msg_data out  NOCOPY VARCHAR2
    , p_contract_id  NUMBER
    , p_review_type  VARCHAR2
    , p_credit_classification  VARCHAR2
    , p_requested_amount  NUMBER
    , p_contact_party_id  NUMBER
    , p_notes  VARCHAR2
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  NUMBER := 0-1962.0724
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  VARCHAR2 := null
    , p11_a6  NUMBER := 0-1962.0724
    , p11_a7  VARCHAR2 := null
    , p11_a8  NUMBER := 0-1962.0724
    , p11_a9  NUMBER := 0-1962.0724
    , p11_a10  NUMBER := 0-1962.0724
    , p11_a11  NUMBER := 0-1962.0724
    , p11_a12  NUMBER := 0-1962.0724
  );
  procedure compile_credit_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  NOCOPY VARCHAR2
    , x_msg_count out  NOCOPY NUMBER
    , x_msg_data out NOCOPY VARCHAR2
    , p_contract_id  NUMBER
    , p6_a0 out NOCOPY NUMBER
    , p6_a1 out NOCOPY  NUMBER
    , p6_a2 out NOCOPY  NUMBER
    , p6_a3 out NOCOPY  NUMBER
    , p6_a4 out NOCOPY  NUMBER
    , p6_a5 out NOCOPY  VARCHAR2
    , p6_a6 out NOCOPY  NUMBER
    , p6_a7 out NOCOPY  VARCHAR2
    , p6_a8 out NOCOPY  NUMBER
    , p6_a9 out NOCOPY  NUMBER
    , p6_a10 out NOCOPY  NUMBER
    , p6_a11 out NOCOPY  NUMBER
    , p6_a12 out NOCOPY  NUMBER
  );
end okl_credit_mgnt_pvt_w;

 

/
