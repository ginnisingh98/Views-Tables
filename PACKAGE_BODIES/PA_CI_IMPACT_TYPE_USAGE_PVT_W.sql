--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACT_TYPE_USAGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACT_TYPE_USAGE_PVT_W" as
  /* $Header: PACIIMUB.pls 120.0.12010000.1 2009/06/08 18:58:03 cklee noship $ */
  procedure rosetta_table_copy_in_p9(t out nocopy pa_ci_impact_type_usage_pvt.impact_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).impact_type_code := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t pa_ci_impact_type_usage_pvt.impact_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).impact_type_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure apply_ci_impact_type_usage(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_only  VARCHAR2
    , p_max_msg_count  NUMBER
    , p_ui_mode  VARCHAR2
    , p_ci_class_code  VARCHAR2
    , p_ci_type_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_impact_tbl pa_ci_impact_type_usage_pvt.impact_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    pa_ci_impact_type_usage_pvt_w.rosetta_table_copy_in_p9(ddp_impact_tbl, p8_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    pa_ci_impact_type_usage_pvt.apply_ci_impact_type_usage(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validate_only,
      p_max_msg_count,
      p_ui_mode,
      p_ci_class_code,
      p_ci_type_id,
      ddp_impact_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end pa_ci_impact_type_usage_pvt_w;

/
