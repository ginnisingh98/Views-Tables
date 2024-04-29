--------------------------------------------------------
--  DDL for Package Body JTF_RS_GRP_SUM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GRP_SUM_PUB_W" as
  /* $Header: jtfrsrgb.pls 120.0 2005/05/11 08:21:37 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out NOCOPY jtf_rs_grp_sum_pub.grp_sum_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).group_id := a0(indx);
          t(ddindx).group_name := a1(indx);
          t(ddindx).group_desc := a2(indx);
          t(ddindx).group_number := a3(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).parent_group := a6(indx);
          t(ddindx).parent_group_id := a7(indx);
          t(ddindx).child_group := a8(indx);
          t(ddindx).child_group_id := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_rs_grp_sum_pub.grp_sum_tbl_type, a0 out NOCOPY JTF_NUMBER_TABLE
    , a1 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY JTF_DATE_TABLE
    , a5 out NOCOPY JTF_DATE_TABLE
    , a6 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY JTF_NUMBER_TABLE
    , a8 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).group_id;
          a1(indx) := t(ddindx).group_name;
          a2(indx) := t(ddindx).group_desc;
          a3(indx) := t(ddindx).group_number;
          a4(indx) := t(ddindx).start_date_active;
          a5(indx) := t(ddindx).end_date_active;
          a6(indx) := t(ddindx).parent_group;
          a7(indx) := t(ddindx).parent_group_id;
          a8(indx) := t(ddindx).child_group;
          a9(indx) := t(ddindx).child_group_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_group(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_called_from  VARCHAR2
    , p_user_id  NUMBER
    , p_group_name  VARCHAR2
    , p_group_number  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_group_email  VARCHAR2
    , p_from_date  VARCHAR2
    , p_to_date  VARCHAR2
    , p_date_format  VARCHAR2
    , p_group_id  NUMBER
    , p_group_usage  VARCHAR2
    , x_total_rows out NOCOPY  NUMBER
    , p14_a0 out NOCOPY JTF_NUMBER_TABLE
    , p14_a1 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a2 out NOCOPY JTF_VARCHAR2_TABLE_300
    , p14_a3 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a4 out NOCOPY JTF_DATE_TABLE
    , p14_a5 out NOCOPY JTF_DATE_TABLE
    , p14_a6 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a7 out NOCOPY JTF_NUMBER_TABLE
    , p14_a8 out NOCOPY JTF_VARCHAR2_TABLE_100
    , p14_a9 out NOCOPY JTF_NUMBER_TABLE
  )
  as
    ddx_result_tbl jtf_rs_grp_sum_pub.grp_sum_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    jtf_rs_grp_sum_pub.get_group(p_range_low,
      p_range_high,
      p_called_from,
      p_user_id,
      p_group_name,
      p_group_number,
      p_group_desc,
      p_group_email,
      p_from_date,
      p_to_date,
      p_date_format,
      p_group_id,
      p_group_usage,
      x_total_rows,
      ddx_result_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any














    jtf_rs_grp_sum_pub_w.rosetta_table_copy_out_p1(ddx_result_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      );
  end;

end jtf_rs_grp_sum_pub_w;

/
