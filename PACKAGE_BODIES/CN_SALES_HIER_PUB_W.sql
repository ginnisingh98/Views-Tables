--------------------------------------------------------
--  DDL for Package Body CN_SALES_HIER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SALES_HIER_PUB_W" as
  /* $Header: cnwhierb.pls 115.5 2002/11/25 23:57:30 fting ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_sales_hier_pub.hier_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).number := a1(indx);
          t(ddindx).role := a2(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_sales_hier_pub.hier_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).number;
          a2(indx) := t(ddindx).role;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_sales_hier_pub.grp_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).grp_name := a0(indx);
          t(ddindx).grp_id := a1(indx);
          t(ddindx).mgr_name := a2(indx);
          t(ddindx).mgr_number := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_sales_hier_pub.grp_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).grp_name;
          a1(indx) := t(ddindx).grp_id;
          a2(indx) := t(ddindx).mgr_name;
          a3(indx) := t(ddindx).mgr_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure get_sales_hier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_date  date
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_start_record_grp  NUMBER
    , p_increment_count_grp  NUMBER
    , p14_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_DATE_TABLE
    , p14_a4 out nocopy JTF_DATE_TABLE
    , x_mgr_count out nocopy  NUMBER
    , p16_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a3 out nocopy JTF_DATE_TABLE
    , p16_a4 out nocopy JTF_DATE_TABLE
    , x_srp_count out nocopy  NUMBER
    , p18_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a1 out nocopy JTF_NUMBER_TABLE
    , p18_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p18_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , x_grp_count out nocopy  NUMBER
  )

  as
    ddp_date date;
    ddx_mgr_tbl cn_sales_hier_pub.hier_tbl_type;
    ddx_srp_tbl cn_sales_hier_pub.hier_tbl_type;
    ddx_grp_tbl cn_sales_hier_pub.grp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_date := rosetta_g_miss_date_in_map(p_date);











    -- here's the delegated call to the old PL/SQL routine
    cn_sales_hier_pub.get_sales_hier(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      p_salesrep_id,
      p_comp_group_id,
      ddp_date,
      p_start_record,
      p_increment_count,
      p_start_record_grp,
      p_increment_count_grp,
      ddx_mgr_tbl,
      x_mgr_count,
      ddx_srp_tbl,
      x_srp_count,
      ddx_grp_tbl,
      x_grp_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    cn_sales_hier_pub_w.rosetta_table_copy_out_p1(ddx_mgr_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      );


    cn_sales_hier_pub_w.rosetta_table_copy_out_p1(ddx_srp_tbl, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      );


    cn_sales_hier_pub_w.rosetta_table_copy_out_p3(ddx_grp_tbl, p18_a0
      , p18_a1
      , p18_a2
      , p18_a3
      );

  end;

end cn_sales_hier_pub_w;

/
