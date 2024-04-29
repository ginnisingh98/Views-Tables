--------------------------------------------------------
--  DDL for Package Body CN_GET_SRP_DATA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_SRP_DATA_PVT_W" as
  /* $Header: cnwsfgtb.pls 115.6 2002/11/25 22:30:34 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_get_srp_data_pvt.srp_data_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).srp_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).emp_num := a2(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).cost_center := a5(indx);
          t(ddindx).comp_group_id := a6(indx);
          t(ddindx).comp_group_name := a7(indx);
          t(ddindx).job_code := a8(indx);
          t(ddindx).job_title := a9(indx);
          t(ddindx).disc_job_title := a10(indx);
          t(ddindx).role_id := a11(indx);
          t(ddindx).role_name := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_get_srp_data_pvt.srp_data_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).srp_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).emp_num;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          a5(indx) := t(ddindx).cost_center;
          a6(indx) := t(ddindx).comp_group_id;
          a7(indx) := t(ddindx).comp_group_name;
          a8(indx) := t(ddindx).job_code;
          a9(indx) := t(ddindx).job_title;
          a10(indx) := t(ddindx).disc_job_title;
          a11(indx) := t(ddindx).role_id;
          a12(indx) := t(ddindx).role_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_srp_list(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p0_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a3 out nocopy JTF_DATE_TABLE
    , p0_a4 out nocopy JTF_DATE_TABLE
    , p0_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 out nocopy JTF_NUMBER_TABLE
    , p0_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 out nocopy JTF_NUMBER_TABLE
    , p0_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_srp_data cn_get_srp_data_pvt.srp_data_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    cn_get_srp_data_pvt.get_srp_list(ddx_srp_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    cn_get_srp_data_pvt_w.rosetta_table_copy_out_p1(ddx_srp_data, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      );
  end;

  procedure search_srp_data(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_date  date
    , p_search_name  VARCHAR2
    , p_search_job  VARCHAR2
    , p_search_emp_num  VARCHAR2
    , p_search_group  VARCHAR2
    , p_order_by  NUMBER
    , p_order_dir  VARCHAR2
    , x_total_rows out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_DATE_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_date date;
    ddx_srp_data cn_get_srp_data_pvt.srp_data_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_date := rosetta_g_miss_date_in_map(p_date);









    -- here's the delegated call to the old PL/SQL routine
    cn_get_srp_data_pvt.search_srp_data(p_range_low,
      p_range_high,
      ddp_date,
      p_search_name,
      p_search_job,
      p_search_emp_num,
      p_search_group,
      p_order_by,
      p_order_dir,
      x_total_rows,
      ddx_srp_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    cn_get_srp_data_pvt_w.rosetta_table_copy_out_p1(ddx_srp_data, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );
  end;

  procedure get_srp_data(p_srp_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_DATE_TABLE
    , p1_a4 out nocopy JTF_DATE_TABLE
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_NUMBER_TABLE
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a11 out nocopy JTF_NUMBER_TABLE
    , p1_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_srp_data cn_get_srp_data_pvt.srp_data_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    cn_get_srp_data_pvt.get_srp_data(p_srp_id,
      ddx_srp_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    cn_get_srp_data_pvt_w.rosetta_table_copy_out_p1(ddx_srp_data, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      );
  end;

  procedure get_managers(p_srp_id  NUMBER
    , p_date  date
    , p_comp_group_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_date date;
    ddx_srp_data cn_get_srp_data_pvt.srp_data_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_date := rosetta_g_miss_date_in_map(p_date);



    -- here's the delegated call to the old PL/SQL routine
    cn_get_srp_data_pvt.get_managers(p_srp_id,
      ddp_date,
      p_comp_group_id,
      ddx_srp_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    cn_get_srp_data_pvt_w.rosetta_table_copy_out_p1(ddx_srp_data, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );
  end;

end cn_get_srp_data_pvt_w;

/
