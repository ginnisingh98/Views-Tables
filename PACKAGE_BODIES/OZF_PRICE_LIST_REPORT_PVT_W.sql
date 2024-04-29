--------------------------------------------------------
--  DDL for Package Body OZF_PRICE_LIST_REPORT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PRICE_LIST_REPORT_PVT_W" as
  /* $Header: ozfwprlb.pls 120.0 2005/06/01 00:24:05 appldev noship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ozf_price_list_report_pvt.section_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parent_section_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).child_section_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sort_order := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).leaf := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_price_list_report_pvt.section_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).parent_section_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).child_section_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).sort_order);
          a3(indx) := t(ddindx).leaf;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_section_heirarchy(p_section_id  NUMBER
    , p1_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p1_a1 OUT NOCOPY JTF_NUMBER_TABLE
    , p1_a2 OUT NOCOPY JTF_NUMBER_TABLE
    , p1_a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
  )
  as
    ddpx_section_tbl ozf_price_list_report_pvt.section_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ozf_price_list_report_pvt.get_section_heirarchy(p_section_id,
      ddpx_section_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any

    ozf_price_list_report_pvt_w.rosetta_table_copy_out_p1(ddpx_section_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      );
  end;

end ozf_price_list_report_pvt_w;

/
