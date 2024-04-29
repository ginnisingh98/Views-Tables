--------------------------------------------------------
--  DDL for Package CN_WKSHT_CT_UP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_WKSHT_CT_UP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwwkcds.pls 120.0 2005/09/26 15:09:14 fmburu noship $ */
  procedure apply_payment_plan_upd(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_srp_pmt_asgn_id  NUMBER
    , p_payrun_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  DATE
    , p10_a4  DATE
    , p10_a5  NUMBER
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , p11_a0  VARCHAR2
    , p11_a1  VARCHAR2
    , p11_a2  VARCHAR2
    , p11_a3  DATE
    , p11_a4  DATE
    , p11_a5  NUMBER
    , p11_a6  NUMBER
    , p11_a7  NUMBER
    , p11_a8  VARCHAR2
    , p11_a9  VARCHAR2
    , p11_a10  VARCHAR2
    , p11_a11  VARCHAR2
    , p11_a12  VARCHAR2
    , p11_a13  VARCHAR2
    , p11_a14  VARCHAR2
    , p11_a15  VARCHAR2
    , p11_a16  VARCHAR2
    , p11_a17  VARCHAR2
    , p11_a18  VARCHAR2
    , p11_a19  VARCHAR2
    , p11_a20  VARCHAR2
    , p11_a21  VARCHAR2
    , p11_a22  VARCHAR2
    , p11_a23  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure apply_payment_plan_cre(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_srp_pmt_asgn_id  NUMBER
    , p_payrun_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  DATE
    , p10_a4  DATE
    , p10_a5  NUMBER
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure apply_payment_plan_del(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_srp_pmt_asgn_id  NUMBER
    , p_payrun_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  DATE
    , p10_a4  DATE
    , p10_a5  NUMBER
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , x_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
end cn_wksht_ct_up_pub_w;

 

/
