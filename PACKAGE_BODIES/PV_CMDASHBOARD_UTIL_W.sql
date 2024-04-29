--------------------------------------------------------
--  DDL for Package Body PV_CMDASHBOARD_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_CMDASHBOARD_UTIL_W" as
  /* $Header: pvxwcdub.pls 120.0 2005/07/05 23:49:54 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy pv_cmdashboard_util.kpi_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_id := a0(indx);
          t(ddindx).attribute_name := a1(indx);
          t(ddindx).attribute_value := a2(indx);
          t(ddindx).enabled_flag := a3(indx);
          t(ddindx).display_style := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t pv_cmdashboard_util.kpi_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute_id;
          a1(indx) := t(ddindx).attribute_name;
          a2(indx) := t(ddindx).attribute_value;
          a3(indx) := t(ddindx).enabled_flag;
          a4(indx) := t(ddindx).display_style;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_kpis_detail(p_resource_id  NUMBER
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 in out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_kpi_set pv_cmdashboard_util.kpi_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    pv_cmdashboard_util_w.rosetta_table_copy_in_p1(ddp_kpi_set, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );

    -- here's the delegated call to the old PL/SQL routine
    pv_cmdashboard_util.get_kpis_detail(p_resource_id,
      ddp_kpi_set);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    pv_cmdashboard_util_w.rosetta_table_copy_out_p1(ddp_kpi_set, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      );
  end;

end pv_cmdashboard_util_w;

/
