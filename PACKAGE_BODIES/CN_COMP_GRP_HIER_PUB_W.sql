--------------------------------------------------------
--  DDL for Package Body CN_COMP_GRP_HIER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_GRP_HIER_PUB_W" as
  /* $Header: cnwcghrb.pls 115.3 2002/01/28 20:12:32 pkm ship      $ */
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

  procedure rosetta_table_copy_in_p1(t out cn_comp_grp_hier_pub.comp_group_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).level := a0(indx);
          t(ddindx).cg_salesrep_name := a1(indx);
          t(ddindx).cg_salesrep_id := a2(indx);
          t(ddindx).parent_comp_group_id := a3(indx);
          t(ddindx).grp_or_name_flag := a4(indx);
          t(ddindx).role_name := a5(indx);
          t(ddindx).role_id := a6(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).start_cg_id := a9(indx);
          t(ddindx).end_cg_id := a10(indx);
          t(ddindx).image := a11(indx);
          t(ddindx).expand := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_comp_grp_hier_pub.comp_group_tbl, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_NUMBER_TABLE
    , a7 out JTF_DATE_TABLE
    , a8 out JTF_DATE_TABLE
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_VARCHAR2_TABLE_100
    , a12 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).level;
          a1(indx) := t(ddindx).cg_salesrep_name;
          a2(indx) := t(ddindx).cg_salesrep_id;
          a3(indx) := t(ddindx).parent_comp_group_id;
          a4(indx) := t(ddindx).grp_or_name_flag;
          a5(indx) := t(ddindx).role_name;
          a6(indx) := t(ddindx).role_id;
          a7(indx) := t(ddindx).start_date_active;
          a8(indx) := t(ddindx).end_date_active;
          a9(indx) := t(ddindx).start_cg_id;
          a10(indx) := t(ddindx).end_cg_id;
          a11(indx) := t(ddindx).image;
          a12(indx) := t(ddindx).expand;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_comp_group_hier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_focus_cg_id  NUMBER
    , p_expand  CHAR
    , p_date  date
    , p8_a0 out JTF_VARCHAR2_TABLE_100
    , p8_a1 out JTF_VARCHAR2_TABLE_100
    , p8_a2 out JTF_NUMBER_TABLE
    , p8_a3 out JTF_NUMBER_TABLE
    , p8_a4 out JTF_VARCHAR2_TABLE_100
    , p8_a5 out JTF_VARCHAR2_TABLE_100
    , p8_a6 out JTF_NUMBER_TABLE
    , p8_a7 out JTF_DATE_TABLE
    , p8_a8 out JTF_DATE_TABLE
    , p8_a9 out JTF_NUMBER_TABLE
    , p8_a10 out JTF_NUMBER_TABLE
    , p8_a11 out JTF_VARCHAR2_TABLE_100
    , p8_a12 out JTF_VARCHAR2_TABLE_100
    , l_mgr_count out  NUMBER
    , x_period_year out  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_loading_status out  VARCHAR2
  )
  as
    ddp_date date;
    ddx_mgr_tbl cn_comp_grp_hier_pub.comp_group_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_date := rosetta_g_miss_date_in_map(p_date);








    -- here's the delegated call to the old PL/SQL routine
    cn_comp_grp_hier_pub.get_comp_group_hier(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_salesrep_id,
      p_comp_group_id,
      p_focus_cg_id,
      p_expand,
      ddp_date,
      ddx_mgr_tbl,
      l_mgr_count,
      x_period_year,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any








    cn_comp_grp_hier_pub_w.rosetta_table_copy_out_p1(ddx_mgr_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      );






  end;

end cn_comp_grp_hier_pub_w;

/
