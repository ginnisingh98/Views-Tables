--------------------------------------------------------
--  DDL for Package CN_SRP_PMT_PLANS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PMT_PLANS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwsppas.pls 120.3 2005/09/14 03:43 vensrini noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_srp_pmt_plans_pvt.payrun_tbl, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t cn_srp_pmt_plans_pvt.payrun_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure create_srp_pmt_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  DATE
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  NUMBER
  );
  procedure update_srp_pmt_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  DATE
    , p8_a5 in out nocopy  DATE
    , p8_a6 in out nocopy  NUMBER
    , p8_a7 in out nocopy  NUMBER
    , p8_a8 in out nocopy  NUMBER
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  NUMBER
  );
  procedure check_payruns(p_operation  VARCHAR2
    , p_srp_pmt_plan_id  NUMBER
    , p_salesrep_id  NUMBER
    , p_start_date  DATE
    , p_end_date  DATE
    , x_payrun_tbl out nocopy JTF_VARCHAR2_TABLE_100
  );
end cn_srp_pmt_plans_pvt_w;

 

/
