--------------------------------------------------------
--  DDL for Package Body HZ_GNR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GNR_PVT_W" as
  /* $Header: ARHGNRWB.pls 120.4 2006/02/09 21:51:33 nsinghai noship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy hz_gnr_pvt.geo_struct_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).v_tab_col := a0(indx);
          t(ddindx).v_geo_type := a1(indx);
          t(ddindx).v_element_col := a2(indx);
          t(ddindx).v_level := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).v_param_value := a4(indx);
          t(ddindx).v_valid_for_usage := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t hz_gnr_pvt.geo_struct_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).v_tab_col;
          a1(indx) := t(ddindx).v_geo_type;
          a2(indx) := t(ddindx).v_element_col;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).v_level);
          a4(indx) := t(ddindx).v_param_value;
          a5(indx) := t(ddindx).v_valid_for_usage;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy hz_gnr_pvt.geo_suggest_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).country := a0(indx);
          t(ddindx).country_code := a1(indx);
          t(ddindx).country_geo_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).country_geo_type := a3(indx);
          t(ddindx).state := a4(indx);
          t(ddindx).state_code := a5(indx);
          t(ddindx).state_geo_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).state_geo_type := a7(indx);
          t(ddindx).province := a8(indx);
          t(ddindx).province_code := a9(indx);
          t(ddindx).province_geo_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).province_geo_type := a11(indx);
          t(ddindx).county := a12(indx);
          t(ddindx).county_geo_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).county_geo_type := a14(indx);
          t(ddindx).city := a15(indx);
          t(ddindx).city_geo_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).city_geo_type := a17(indx);
          t(ddindx).postal_code := a18(indx);
          t(ddindx).postal_code_geo_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).postal_code_geo_type := a20(indx);
          t(ddindx).postal_plus4_code := a21(indx);
          t(ddindx).postal_plus4_code_geo_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).postal_plus4_code_geo_type := a23(indx);
          t(ddindx).attribute1 := a24(indx);
          t(ddindx).attribute1_geo_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).attribute1_geo_type := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute2_geo_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).attribute2_geo_type := a29(indx);
          t(ddindx).attribute3 := a30(indx);
          t(ddindx).attribute3_geo_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).attribute3_geo_type := a32(indx);
          t(ddindx).attribute4 := a33(indx);
          t(ddindx).attribute4_geo_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).attribute4_geo_type := a35(indx);
          t(ddindx).attribute5 := a36(indx);
          t(ddindx).attribute5_geo_id := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).attribute5_geo_type := a38(indx);
          t(ddindx).attribute6 := a39(indx);
          t(ddindx).attribute6_geo_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).attribute6_geo_type := a41(indx);
          t(ddindx).attribute7 := a42(indx);
          t(ddindx).attribute7_geo_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).attribute7_geo_type := a44(indx);
          t(ddindx).attribute8 := a45(indx);
          t(ddindx).attribute8_geo_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).attribute8_geo_type := a47(indx);
          t(ddindx).attribute9 := a48(indx);
          t(ddindx).attribute9_geo_id := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).attribute9_geo_type := a50(indx);
          t(ddindx).attribute10 := a51(indx);
          t(ddindx).attribute10_geo_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).attribute10_geo_type := a53(indx);
          t(ddindx).suggestion_list := a54(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t hz_gnr_pvt.geo_suggest_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_4000();
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
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).country;
          a1(indx) := t(ddindx).country_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).country_geo_id);
          a3(indx) := t(ddindx).country_geo_type;
          a4(indx) := t(ddindx).state;
          a5(indx) := t(ddindx).state_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).state_geo_id);
          a7(indx) := t(ddindx).state_geo_type;
          a8(indx) := t(ddindx).province;
          a9(indx) := t(ddindx).province_code;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).province_geo_id);
          a11(indx) := t(ddindx).province_geo_type;
          a12(indx) := t(ddindx).county;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).county_geo_id);
          a14(indx) := t(ddindx).county_geo_type;
          a15(indx) := t(ddindx).city;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).city_geo_id);
          a17(indx) := t(ddindx).city_geo_type;
          a18(indx) := t(ddindx).postal_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).postal_code_geo_id);
          a20(indx) := t(ddindx).postal_code_geo_type;
          a21(indx) := t(ddindx).postal_plus4_code;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).postal_plus4_code_geo_id);
          a23(indx) := t(ddindx).postal_plus4_code_geo_type;
          a24(indx) := t(ddindx).attribute1;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).attribute1_geo_id);
          a26(indx) := t(ddindx).attribute1_geo_type;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).attribute2_geo_id);
          a29(indx) := t(ddindx).attribute2_geo_type;
          a30(indx) := t(ddindx).attribute3;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).attribute3_geo_id);
          a32(indx) := t(ddindx).attribute3_geo_type;
          a33(indx) := t(ddindx).attribute4;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).attribute4_geo_id);
          a35(indx) := t(ddindx).attribute4_geo_type;
          a36(indx) := t(ddindx).attribute5;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).attribute5_geo_id);
          a38(indx) := t(ddindx).attribute5_geo_type;
          a39(indx) := t(ddindx).attribute6;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).attribute6_geo_id);
          a41(indx) := t(ddindx).attribute6_geo_type;
          a42(indx) := t(ddindx).attribute7;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).attribute7_geo_id);
          a44(indx) := t(ddindx).attribute7_geo_type;
          a45(indx) := t(ddindx).attribute8;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).attribute8_geo_id);
          a47(indx) := t(ddindx).attribute8_geo_type;
          a48(indx) := t(ddindx).attribute9;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).attribute9_geo_id);
          a50(indx) := t(ddindx).attribute9_geo_type;
          a51(indx) := t(ddindx).attribute10;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).attribute10_geo_id);
          a53(indx) := t(ddindx).attribute10_geo_type;
          a54(indx) := t(ddindx).suggestion_list;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure search_geographies(p_table_name  VARCHAR2
    , p_address_style  VARCHAR2
    , p_address_usage  VARCHAR2
    , p_country_code  VARCHAR2
    , p_state  VARCHAR2
    , p_province  VARCHAR2
    , p_county  VARCHAR2
    , p_city  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_postal_plus4_code  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , x_mapped_struct_count out nocopy  NUMBER
    , x_records_count out nocopy  NUMBER
    , x_return_code out nocopy  NUMBER
    , x_validation_level out nocopy  VARCHAR2
    , p24_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a2 out nocopy JTF_NUMBER_TABLE
    , p24_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a6 out nocopy JTF_NUMBER_TABLE
    , p24_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a10 out nocopy JTF_NUMBER_TABLE
    , p24_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a13 out nocopy JTF_NUMBER_TABLE
    , p24_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a16 out nocopy JTF_NUMBER_TABLE
    , p24_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a19 out nocopy JTF_NUMBER_TABLE
    , p24_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a22 out nocopy JTF_NUMBER_TABLE
    , p24_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a25 out nocopy JTF_NUMBER_TABLE
    , p24_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a28 out nocopy JTF_NUMBER_TABLE
    , p24_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a31 out nocopy JTF_NUMBER_TABLE
    , p24_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a34 out nocopy JTF_NUMBER_TABLE
    , p24_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a37 out nocopy JTF_NUMBER_TABLE
    , p24_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a40 out nocopy JTF_NUMBER_TABLE
    , p24_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a43 out nocopy JTF_NUMBER_TABLE
    , p24_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a46 out nocopy JTF_NUMBER_TABLE
    , p24_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a49 out nocopy JTF_NUMBER_TABLE
    , p24_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p24_a52 out nocopy JTF_NUMBER_TABLE
    , p24_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p24_a54 out nocopy JTF_VARCHAR2_TABLE_4000
    , p25_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p25_a3 out nocopy JTF_NUMBER_TABLE
    , p25_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p25_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p26_a0 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_geo_suggest_tbl hz_gnr_pvt.geo_suggest_tbl_type;
    ddx_geo_struct_tbl hz_gnr_pvt.geo_struct_tbl_type;
    ddx_geo_suggest_misc_rec hz_gnr_pvt.geo_suggest_misc_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






























    -- here's the delegated call to the old PL/SQL routine
    hz_gnr_pvt.search_geographies(p_table_name,
      p_address_style,
      p_address_usage,
      p_country_code,
      p_state,
      p_province,
      p_county,
      p_city,
      p_postal_code,
      p_postal_plus4_code,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      x_mapped_struct_count,
      x_records_count,
      x_return_code,
      x_validation_level,
      ddx_geo_suggest_tbl,
      ddx_geo_struct_tbl,
      ddx_geo_suggest_misc_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























    hz_gnr_pvt_w.rosetta_table_copy_out_p6(ddx_geo_suggest_tbl, p24_a0
      , p24_a1
      , p24_a2
      , p24_a3
      , p24_a4
      , p24_a5
      , p24_a6
      , p24_a7
      , p24_a8
      , p24_a9
      , p24_a10
      , p24_a11
      , p24_a12
      , p24_a13
      , p24_a14
      , p24_a15
      , p24_a16
      , p24_a17
      , p24_a18
      , p24_a19
      , p24_a20
      , p24_a21
      , p24_a22
      , p24_a23
      , p24_a24
      , p24_a25
      , p24_a26
      , p24_a27
      , p24_a28
      , p24_a29
      , p24_a30
      , p24_a31
      , p24_a32
      , p24_a33
      , p24_a34
      , p24_a35
      , p24_a36
      , p24_a37
      , p24_a38
      , p24_a39
      , p24_a40
      , p24_a41
      , p24_a42
      , p24_a43
      , p24_a44
      , p24_a45
      , p24_a46
      , p24_a47
      , p24_a48
      , p24_a49
      , p24_a50
      , p24_a51
      , p24_a52
      , p24_a53
      , p24_a54
      );

    hz_gnr_pvt_w.rosetta_table_copy_out_p4(ddx_geo_struct_tbl, p25_a0
      , p25_a1
      , p25_a2
      , p25_a3
      , p25_a4
      , p25_a5
      );

    p26_a0 := ddx_geo_suggest_misc_rec.v_suggestion_msg_text;



  end;

end hz_gnr_pvt_w;

/
