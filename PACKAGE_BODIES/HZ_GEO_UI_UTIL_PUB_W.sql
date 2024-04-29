--------------------------------------------------------
--  DDL for Package Body HZ_GEO_UI_UTIL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_UI_UTIL_PUB_W" as
  /* $Header: ARHGEUJB.pls 120.3 2005/09/28 20:10:59 sroychou noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy hz_geo_ui_util_pub.tax_geo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).level_number := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).geography_type := a1(indx);
          t(ddindx).loc_comp := a2(indx);
          t(ddindx).tax_geo_valid := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t hz_geo_ui_util_pub.tax_geo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).level_number);
          a1(indx) := t(ddindx).geography_type;
          a2(indx) := t(ddindx).loc_comp;
          a3(indx) := t(ddindx).tax_geo_valid;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure update_map_usages(p_map_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_400
    , p1_a2 JTF_VARCHAR2_TABLE_400
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_400
    , p2_a2 JTF_VARCHAR2_TABLE_400
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_show_gnr out nocopy  VARCHAR2
  )

  as
    ddp_tax_tbl hz_geo_ui_util_pub.tax_geo_tbl_type;
    ddp_geo_tbl hz_geo_ui_util_pub.tax_geo_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    hz_geo_ui_util_pub_w.rosetta_table_copy_in_p1(ddp_tax_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      );

    hz_geo_ui_util_pub_w.rosetta_table_copy_in_p1(ddp_geo_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );






    -- here's the delegated call to the old PL/SQL routine
    hz_geo_ui_util_pub.update_map_usages(p_map_id,
      ddp_tax_tbl,
      ddp_geo_tbl,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_show_gnr);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end hz_geo_ui_util_pub_w;

/
