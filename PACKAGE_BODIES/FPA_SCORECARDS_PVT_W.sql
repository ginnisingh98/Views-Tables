--------------------------------------------------------
--  DDL for Package Body FPA_SCORECARDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_SCORECARDS_PVT_W" as
  /* $Header: FPAESCRB.pls 120.2 2005/09/14 11:37:09 appldev noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy fpa_scorecards_pvt.fpa_scorecard_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).strategic_obj_id := a0(indx);
          t(ddindx).new_score := a1(indx);
          t(ddindx).comments := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t fpa_scorecards_pvt.fpa_scorecard_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).strategic_obj_id;
          a1(indx) := t(ddindx).new_score;
          a2(indx) := t(ddindx).comments;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

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
    fpa_scorecards_pvt.update_calc_pjt_scorecard_aw(p_api_version,
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
    fpa_scorecards_pvt.update_calc_scen_scorecard_aw(p_api_version,
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

end fpa_scorecards_pvt_w;

/
