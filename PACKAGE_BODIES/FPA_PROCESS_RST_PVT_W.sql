--------------------------------------------------------
--  DDL for Package Body FPA_PROCESS_RST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PROCESS_RST_PVT_W" as
  /* $Header: FPAERSTB.pls 120.2 2005/09/14 11:37:48 appldev noship $ */
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
  )

  as
    ddp_scorecard_tbl fpa_scorecards_pvt.fpa_scorecard_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    fpa_scorecards_pvt_w.rosetta_table_copy_in_p2(ddp_scorecard_tbl, p5_a0
      , p5_a1
      , p5_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    fpa_process_rst_pvt.update_calc_pjt_scorecard_aw(p_api_version,
      p_init_msg_list,
      p_commit,
      p_planning_cycle_id,
      p_project_id,
      ddp_scorecard_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

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
  )

  as
    ddp_scorecard_tbl fpa_scorecards_pvt.fpa_scorecard_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    fpa_scorecards_pvt_w.rosetta_table_copy_in_p2(ddp_scorecard_tbl, p6_a0
      , p6_a1
      , p6_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    fpa_process_rst_pvt.update_calc_scen_scorecard_aw(p_api_version,
      p_init_msg_list,
      p_commit,
      p_planning_cycle_id,
      p_scenario_id,
      p_project_id,
      ddp_scorecard_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end fpa_process_rst_pvt_w;

/
