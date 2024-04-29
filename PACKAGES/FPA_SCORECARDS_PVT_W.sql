--------------------------------------------------------
--  DDL for Package FPA_SCORECARDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_SCORECARDS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: FPAESCRS.pls 120.2 2005/09/14 11:37:20 appldev noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy fpa_scorecards_pvt.fpa_scorecard_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p2(t fpa_scorecards_pvt.fpa_scorecard_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure update_calc_pjt_scorecard_aw(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_planning_cycle_id  NUMBER
    , p_project_id  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_calc_scen_scorecard_aw(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_planning_cycle_id  NUMBER
    , p_scenario_id  NUMBER
    , p_project_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end fpa_scorecards_pvt_w;

 

/
