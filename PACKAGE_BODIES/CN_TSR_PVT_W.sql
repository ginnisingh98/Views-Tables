--------------------------------------------------------
--  DDL for Package Body CN_TSR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TSR_PVT_W" as
  /* $Header: cnwtsrb.pls 115.5 2002/11/25 22:32:35 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_tsr_pvt.tsr_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).tsr_emp_no := a0(indx);
          t(ddindx).tsr_name := a1(indx);
          t(ddindx).mgr_emp_no := a2(indx);
          t(ddindx).mgr_name := a3(indx);
          t(ddindx).tsr_srp_id := a4(indx);
          t(ddindx).tsr_mgr_id := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_tsr_pvt.tsr_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).tsr_emp_no;
          a1(indx) := t(ddindx).tsr_name;
          a2(indx) := t(ddindx).mgr_emp_no;
          a3(indx) := t(ddindx).mgr_name;
          a4(indx) := t(ddindx).tsr_srp_id;
          a5(indx) := t(ddindx).tsr_mgr_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_tsr_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mgr_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_org_code  VARCHAR2
    , p_period_id  date
    , p_start_row  NUMBER
    , p_rows  NUMBER
    , p13_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_NUMBER_TABLE
    , x_total_rows out nocopy  NUMBER
    , download  VARCHAR2
  )

  as
    ddp_period_id date;
    ddx_tsr_data cn_tsr_pvt.tsr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_period_id := rosetta_g_miss_date_in_map(p_period_id);






    -- here's the delegated call to the old PL/SQL routine
    cn_tsr_pvt.get_tsr_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_mgr_id,
      p_comp_group_id,
      p_org_code,
      ddp_period_id,
      p_start_row,
      p_rows,
      ddx_tsr_data,
      x_total_rows,
      download);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    cn_tsr_pvt_w.rosetta_table_copy_out_p1(ddx_tsr_data, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      );


  end;

end cn_tsr_pvt_w;

/
