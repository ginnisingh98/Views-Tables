--------------------------------------------------------
--  DDL for Package CSC_ACTION_ASSEMBLER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_ACTION_ASSEMBLER_PVT_W" AUTHID CURRENT_USER as
   /* $Header: cscwpots.pls 115.1 2003/03/05 21:53:45 jamose noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy csc_action_assembler_pvt.results_tab_type, a0 JTF_VARCHAR2_TABLE_1000
    , a1 JTF_VARCHAR2_TABLE_1000
    , a2 JTF_VARCHAR2_TABLE_1800
    );
  procedure rosetta_table_copy_out_p1(t csc_action_assembler_pvt.results_tab_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , a2 out nocopy JTF_VARCHAR2_TABLE_1800
    );

  procedure enable_plan_and_get_outcomes(p_party_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_end_user_type  VARCHAR2
    , p_application_short_name  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_200
    , p4_a1 JTF_VARCHAR2_TABLE_300
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_1800
  );
  procedure get_outcomes(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_action_id  NUMBER
    , p_application_short_name  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_200
    , p4_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a1 in out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_1800
  );
end csc_action_assembler_pvt_w;

 

/
