--------------------------------------------------------
--  DDL for Package Body IBE_ATP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ATP_PVT_W" as
  /* $Header: IBEVATWB.pls 115.9 2003/08/29 09:09:17 nsultan ship $ */
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

  procedure rosetta_table_copy_in_p1(t out NOCOPY ibe_atp_pvt.atp_line_tbl_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quote_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).uom_code := a4(indx);
          t(ddindx).customer_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).ship_to_site_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).ship_method_code := a7(indx);
          t(ddindx).request_date := a8(indx);
          t(ddindx).request_date_quantity := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).available_date := a10(indx);
          t(ddindx).error_code := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).error_message := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ibe_atp_pvt.atp_line_tbl_typ, a0 out NOCOPY JTF_NUMBER_TABLE
    , a1 out NOCOPY JTF_NUMBER_TABLE
    , a2 out NOCOPY JTF_NUMBER_TABLE
    , a3 out NOCOPY JTF_NUMBER_TABLE
    , a4 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY JTF_NUMBER_TABLE
    , a6 out NOCOPY JTF_NUMBER_TABLE
    , a7 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY JTF_NUMBER_TABLE
    , a10 out NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 out NOCOPY JTF_NUMBER_TABLE
    , a12 out NOCOPY JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).quote_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a4(indx) := t(ddindx).uom_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_site_id);
          a7(indx) := t(ddindx).ship_method_code;
          a8(indx) := t(ddindx).request_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).request_date_quantity);
          a10(indx) := t(ddindx).available_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).error_code);
          a12(indx) := t(ddindx).error_message;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure check_availability(p_quote_header_id  NUMBER
    , p_date_format  VARCHAR2
    , p_lang_code  VARCHAR2
    , x_error_flag out NOCOPY VARCHAR2
    , x_error_message out NOCOPY VARCHAR2
    , p5_a0 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a1 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a2 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a3 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a4 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a5 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a6 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a7 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a8 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a9 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a10 in out NOCOPY JTF_VARCHAR2_TABLE_100
    , p5_a11 in out NOCOPY JTF_NUMBER_TABLE
    , p5_a12 in out NOCOPY JTF_VARCHAR2_TABLE_2000
  )
  as
    ddx_atp_line_tbl ibe_atp_pvt.atp_line_tbl_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ibe_atp_pvt_w.rosetta_table_copy_in_p1(ddx_atp_line_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      );

    -- here's the delegated call to the old PL/SQL routine
    ibe_atp_pvt.check_availability(p_quote_header_id,
      p_date_format,
      p_lang_code,
      x_error_flag,
      x_error_message,
      ddx_atp_line_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any





    ibe_atp_pvt_w.rosetta_table_copy_out_p1(ddx_atp_line_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      );
  end;

end ibe_atp_pvt_w;

/
