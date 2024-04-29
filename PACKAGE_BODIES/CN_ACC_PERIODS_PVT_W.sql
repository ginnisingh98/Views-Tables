--------------------------------------------------------
--  DDL for Package Body CN_ACC_PERIODS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ACC_PERIODS_PVT_W" as
  /* $Header: cnwsyprb.pls 120.1 2005/09/14 03:43 vensrini noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_acc_periods_pvt.acc_period_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).period_name := a0(indx);
          t(ddindx).period_year := a1(indx);
          t(ddindx).start_date := a2(indx);
          t(ddindx).end_date := a3(indx);
          t(ddindx).closing_status_meaning := a4(indx);
          t(ddindx).prosessing_status := a5(indx);
          t(ddindx).freeze_flag := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_acc_periods_pvt.acc_period_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).period_name;
          a1(indx) := t(ddindx).period_year;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          a4(indx) := t(ddindx).closing_status_meaning;
          a5(indx) := t(ddindx).prosessing_status;
          a6(indx) := t(ddindx).freeze_flag;
          a7(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure update_acc_periods(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_acc_period_tbl cn_acc_periods_pvt.acc_period_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cn_acc_periods_pvt_w.rosetta_table_copy_in_p1(ddp_acc_period_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );





    -- here's the delegated call to the old PL/SQL routine
    cn_acc_periods_pvt.update_acc_periods(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_acc_period_tbl,
      p_org_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_acc_periods(p_year  NUMBER
    , x_system_status out nocopy  VARCHAR2
    , x_calendar out nocopy  VARCHAR2
    , x_period_type out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_DATE_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_acc_period_tbl cn_acc_periods_pvt.acc_period_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cn_acc_periods_pvt.get_acc_periods(p_year,
      x_system_status,
      x_calendar,
      x_period_type,
      ddx_acc_period_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    cn_acc_periods_pvt_w.rosetta_table_copy_out_p1(ddx_acc_period_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );
  end;

end cn_acc_periods_pvt_w;

/
