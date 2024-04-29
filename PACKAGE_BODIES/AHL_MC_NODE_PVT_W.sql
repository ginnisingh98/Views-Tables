--------------------------------------------------------
--  DDL for Package Body AHL_MC_NODE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_NODE_PVT_W" as
  /* $Header: AHLVNOWB.pls 120.4 2006/05/03 02:12 sathapli noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_mc_node_pvt.node_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).relationship_id := a0(indx);
          t(ddindx).mc_header_id := a1(indx);
          t(ddindx).position_key := a2(indx);
          t(ddindx).position_ref_code := a3(indx);
          t(ddindx).position_ref_meaning := a4(indx);
          t(ddindx).ata_code := a5(indx);
          t(ddindx).ata_meaning := a6(indx);
          t(ddindx).position_necessity_code := a7(indx);
          t(ddindx).position_necessity_meaning := a8(indx);
          t(ddindx).uom_code := a9(indx);
          t(ddindx).quantity := a10(indx);
          t(ddindx).parent_relationship_id := a11(indx);
          t(ddindx).item_group_id := a12(indx);
          t(ddindx).item_group_name := a13(indx);
          t(ddindx).display_order := a14(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).object_version_number := a17(indx);
          t(ddindx).security_group_id := a18(indx);
          t(ddindx).attribute_category := a19(indx);
          t(ddindx).attribute1 := a20(indx);
          t(ddindx).attribute2 := a21(indx);
          t(ddindx).attribute3 := a22(indx);
          t(ddindx).attribute4 := a23(indx);
          t(ddindx).attribute5 := a24(indx);
          t(ddindx).attribute6 := a25(indx);
          t(ddindx).attribute7 := a26(indx);
          t(ddindx).attribute8 := a27(indx);
          t(ddindx).attribute9 := a28(indx);
          t(ddindx).attribute10 := a29(indx);
          t(ddindx).attribute11 := a30(indx);
          t(ddindx).attribute12 := a31(indx);
          t(ddindx).attribute13 := a32(indx);
          t(ddindx).attribute14 := a33(indx);
          t(ddindx).attribute15 := a34(indx);
          t(ddindx).operation_flag := a35(indx);
          t(ddindx).parent_node_rec_index := a36(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ahl_mc_node_pvt.node_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).relationship_id;
          a1(indx) := t(ddindx).mc_header_id;
          a2(indx) := t(ddindx).position_key;
          a3(indx) := t(ddindx).position_ref_code;
          a4(indx) := t(ddindx).position_ref_meaning;
          a5(indx) := t(ddindx).ata_code;
          a6(indx) := t(ddindx).ata_meaning;
          a7(indx) := t(ddindx).position_necessity_code;
          a8(indx) := t(ddindx).position_necessity_meaning;
          a9(indx) := t(ddindx).uom_code;
          a10(indx) := t(ddindx).quantity;
          a11(indx) := t(ddindx).parent_relationship_id;
          a12(indx) := t(ddindx).item_group_id;
          a13(indx) := t(ddindx).item_group_name;
          a14(indx) := t(ddindx).display_order;
          a15(indx) := t(ddindx).active_start_date;
          a16(indx) := t(ddindx).active_end_date;
          a17(indx) := t(ddindx).object_version_number;
          a18(indx) := t(ddindx).security_group_id;
          a19(indx) := t(ddindx).attribute_category;
          a20(indx) := t(ddindx).attribute1;
          a21(indx) := t(ddindx).attribute2;
          a22(indx) := t(ddindx).attribute3;
          a23(indx) := t(ddindx).attribute4;
          a24(indx) := t(ddindx).attribute5;
          a25(indx) := t(ddindx).attribute6;
          a26(indx) := t(ddindx).attribute7;
          a27(indx) := t(ddindx).attribute8;
          a28(indx) := t(ddindx).attribute9;
          a29(indx) := t(ddindx).attribute10;
          a30(indx) := t(ddindx).attribute11;
          a31(indx) := t(ddindx).attribute12;
          a32(indx) := t(ddindx).attribute13;
          a33(indx) := t(ddindx).attribute14;
          a34(indx) := t(ddindx).attribute15;
          a35(indx) := t(ddindx).operation_flag;
          a36(indx) := t(ddindx).parent_node_rec_index;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy ahl_mc_node_pvt.counter_rules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ctr_update_rule_id := a0(indx);
          t(ddindx).relationship_id := a1(indx);
          t(ddindx).uom_code := a2(indx);
          t(ddindx).rule_code := a3(indx);
          t(ddindx).rule_meaning := a4(indx);
          t(ddindx).ratio := a5(indx);
          t(ddindx).object_version_number := a6(indx);
          t(ddindx).security_group_id := a7(indx);
          t(ddindx).attribute_category := a8(indx);
          t(ddindx).attribute1 := a9(indx);
          t(ddindx).attribute2 := a10(indx);
          t(ddindx).attribute3 := a11(indx);
          t(ddindx).attribute4 := a12(indx);
          t(ddindx).attribute5 := a13(indx);
          t(ddindx).attribute6 := a14(indx);
          t(ddindx).attribute7 := a15(indx);
          t(ddindx).attribute8 := a16(indx);
          t(ddindx).attribute9 := a17(indx);
          t(ddindx).attribute10 := a18(indx);
          t(ddindx).attribute11 := a19(indx);
          t(ddindx).attribute12 := a20(indx);
          t(ddindx).attribute13 := a21(indx);
          t(ddindx).attribute14 := a22(indx);
          t(ddindx).attribute15 := a23(indx);
          t(ddindx).operation_flag := a24(indx);
          t(ddindx).node_tbl_index := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ahl_mc_node_pvt.counter_rules_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).ctr_update_rule_id;
          a1(indx) := t(ddindx).relationship_id;
          a2(indx) := t(ddindx).uom_code;
          a3(indx) := t(ddindx).rule_code;
          a4(indx) := t(ddindx).rule_meaning;
          a5(indx) := t(ddindx).ratio;
          a6(indx) := t(ddindx).object_version_number;
          a7(indx) := t(ddindx).security_group_id;
          a8(indx) := t(ddindx).attribute_category;
          a9(indx) := t(ddindx).attribute1;
          a10(indx) := t(ddindx).attribute2;
          a11(indx) := t(ddindx).attribute3;
          a12(indx) := t(ddindx).attribute4;
          a13(indx) := t(ddindx).attribute5;
          a14(indx) := t(ddindx).attribute6;
          a15(indx) := t(ddindx).attribute7;
          a16(indx) := t(ddindx).attribute8;
          a17(indx) := t(ddindx).attribute9;
          a18(indx) := t(ddindx).attribute10;
          a19(indx) := t(ddindx).attribute11;
          a20(indx) := t(ddindx).attribute12;
          a21(indx) := t(ddindx).attribute13;
          a22(indx) := t(ddindx).attribute14;
          a23(indx) := t(ddindx).attribute15;
          a24(indx) := t(ddindx).operation_flag;
          a25(indx) := t(ddindx).node_tbl_index;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy ahl_mc_node_pvt.subconfig_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mc_config_relation_id := a0(indx);
          t(ddindx).mc_header_id := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).version_number := a3(indx);
          t(ddindx).relationship_id := a4(indx);
          t(ddindx).active_start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).active_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).priority := a8(indx);
          t(ddindx).security_group_id := a9(indx);
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).operation_flag := a26(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t ahl_mc_node_pvt.subconfig_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).mc_config_relation_id;
          a1(indx) := t(ddindx).mc_header_id;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).version_number;
          a4(indx) := t(ddindx).relationship_id;
          a5(indx) := t(ddindx).active_start_date;
          a6(indx) := t(ddindx).active_end_date;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).priority;
          a9(indx) := t(ddindx).security_group_id;
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := t(ddindx).operation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure create_node(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  DATE
    , p7_a16 in out nocopy  DATE
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  NUMBER
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a25 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_DATE_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_NUMBER_TABLE
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_node_rec ahl_mc_node_pvt.node_rec_type;
    ddp_x_counter_rules_tbl ahl_mc_node_pvt.counter_rules_tbl_type;
    ddp_x_subconfig_tbl ahl_mc_node_pvt.subconfig_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_node_rec.relationship_id := p7_a0;
    ddp_x_node_rec.mc_header_id := p7_a1;
    ddp_x_node_rec.position_key := p7_a2;
    ddp_x_node_rec.position_ref_code := p7_a3;
    ddp_x_node_rec.position_ref_meaning := p7_a4;
    ddp_x_node_rec.ata_code := p7_a5;
    ddp_x_node_rec.ata_meaning := p7_a6;
    ddp_x_node_rec.position_necessity_code := p7_a7;
    ddp_x_node_rec.position_necessity_meaning := p7_a8;
    ddp_x_node_rec.uom_code := p7_a9;
    ddp_x_node_rec.quantity := p7_a10;
    ddp_x_node_rec.parent_relationship_id := p7_a11;
    ddp_x_node_rec.item_group_id := p7_a12;
    ddp_x_node_rec.item_group_name := p7_a13;
    ddp_x_node_rec.display_order := p7_a14;
    ddp_x_node_rec.active_start_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_x_node_rec.active_end_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_x_node_rec.object_version_number := p7_a17;
    ddp_x_node_rec.security_group_id := p7_a18;
    ddp_x_node_rec.attribute_category := p7_a19;
    ddp_x_node_rec.attribute1 := p7_a20;
    ddp_x_node_rec.attribute2 := p7_a21;
    ddp_x_node_rec.attribute3 := p7_a22;
    ddp_x_node_rec.attribute4 := p7_a23;
    ddp_x_node_rec.attribute5 := p7_a24;
    ddp_x_node_rec.attribute6 := p7_a25;
    ddp_x_node_rec.attribute7 := p7_a26;
    ddp_x_node_rec.attribute8 := p7_a27;
    ddp_x_node_rec.attribute9 := p7_a28;
    ddp_x_node_rec.attribute10 := p7_a29;
    ddp_x_node_rec.attribute11 := p7_a30;
    ddp_x_node_rec.attribute12 := p7_a31;
    ddp_x_node_rec.attribute13 := p7_a32;
    ddp_x_node_rec.attribute14 := p7_a33;
    ddp_x_node_rec.attribute15 := p7_a34;
    ddp_x_node_rec.operation_flag := p7_a35;
    ddp_x_node_rec.parent_node_rec_index := p7_a36;

    ahl_mc_node_pvt_w.rosetta_table_copy_in_p8(ddp_x_counter_rules_tbl, p8_a0
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
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      );

    ahl_mc_node_pvt_w.rosetta_table_copy_in_p10(ddp_x_subconfig_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_node_pvt.create_node(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_node_rec,
      ddp_x_counter_rules_tbl,
      ddp_x_subconfig_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_x_node_rec.relationship_id;
    p7_a1 := ddp_x_node_rec.mc_header_id;
    p7_a2 := ddp_x_node_rec.position_key;
    p7_a3 := ddp_x_node_rec.position_ref_code;
    p7_a4 := ddp_x_node_rec.position_ref_meaning;
    p7_a5 := ddp_x_node_rec.ata_code;
    p7_a6 := ddp_x_node_rec.ata_meaning;
    p7_a7 := ddp_x_node_rec.position_necessity_code;
    p7_a8 := ddp_x_node_rec.position_necessity_meaning;
    p7_a9 := ddp_x_node_rec.uom_code;
    p7_a10 := ddp_x_node_rec.quantity;
    p7_a11 := ddp_x_node_rec.parent_relationship_id;
    p7_a12 := ddp_x_node_rec.item_group_id;
    p7_a13 := ddp_x_node_rec.item_group_name;
    p7_a14 := ddp_x_node_rec.display_order;
    p7_a15 := ddp_x_node_rec.active_start_date;
    p7_a16 := ddp_x_node_rec.active_end_date;
    p7_a17 := ddp_x_node_rec.object_version_number;
    p7_a18 := ddp_x_node_rec.security_group_id;
    p7_a19 := ddp_x_node_rec.attribute_category;
    p7_a20 := ddp_x_node_rec.attribute1;
    p7_a21 := ddp_x_node_rec.attribute2;
    p7_a22 := ddp_x_node_rec.attribute3;
    p7_a23 := ddp_x_node_rec.attribute4;
    p7_a24 := ddp_x_node_rec.attribute5;
    p7_a25 := ddp_x_node_rec.attribute6;
    p7_a26 := ddp_x_node_rec.attribute7;
    p7_a27 := ddp_x_node_rec.attribute8;
    p7_a28 := ddp_x_node_rec.attribute9;
    p7_a29 := ddp_x_node_rec.attribute10;
    p7_a30 := ddp_x_node_rec.attribute11;
    p7_a31 := ddp_x_node_rec.attribute12;
    p7_a32 := ddp_x_node_rec.attribute13;
    p7_a33 := ddp_x_node_rec.attribute14;
    p7_a34 := ddp_x_node_rec.attribute15;
    p7_a35 := ddp_x_node_rec.operation_flag;
    p7_a36 := ddp_x_node_rec.parent_node_rec_index;

    ahl_mc_node_pvt_w.rosetta_table_copy_out_p8(ddp_x_counter_rules_tbl, p8_a0
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
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      );

    ahl_mc_node_pvt_w.rosetta_table_copy_out_p10(ddp_x_subconfig_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      );
  end;

  procedure modify_node(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  DATE
    , p7_a16 in out nocopy  DATE
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  NUMBER
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a25 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_DATE_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_NUMBER_TABLE
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_node_rec ahl_mc_node_pvt.node_rec_type;
    ddp_x_counter_rules_tbl ahl_mc_node_pvt.counter_rules_tbl_type;
    ddp_x_subconfig_tbl ahl_mc_node_pvt.subconfig_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_node_rec.relationship_id := p7_a0;
    ddp_x_node_rec.mc_header_id := p7_a1;
    ddp_x_node_rec.position_key := p7_a2;
    ddp_x_node_rec.position_ref_code := p7_a3;
    ddp_x_node_rec.position_ref_meaning := p7_a4;
    ddp_x_node_rec.ata_code := p7_a5;
    ddp_x_node_rec.ata_meaning := p7_a6;
    ddp_x_node_rec.position_necessity_code := p7_a7;
    ddp_x_node_rec.position_necessity_meaning := p7_a8;
    ddp_x_node_rec.uom_code := p7_a9;
    ddp_x_node_rec.quantity := p7_a10;
    ddp_x_node_rec.parent_relationship_id := p7_a11;
    ddp_x_node_rec.item_group_id := p7_a12;
    ddp_x_node_rec.item_group_name := p7_a13;
    ddp_x_node_rec.display_order := p7_a14;
    ddp_x_node_rec.active_start_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_x_node_rec.active_end_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_x_node_rec.object_version_number := p7_a17;
    ddp_x_node_rec.security_group_id := p7_a18;
    ddp_x_node_rec.attribute_category := p7_a19;
    ddp_x_node_rec.attribute1 := p7_a20;
    ddp_x_node_rec.attribute2 := p7_a21;
    ddp_x_node_rec.attribute3 := p7_a22;
    ddp_x_node_rec.attribute4 := p7_a23;
    ddp_x_node_rec.attribute5 := p7_a24;
    ddp_x_node_rec.attribute6 := p7_a25;
    ddp_x_node_rec.attribute7 := p7_a26;
    ddp_x_node_rec.attribute8 := p7_a27;
    ddp_x_node_rec.attribute9 := p7_a28;
    ddp_x_node_rec.attribute10 := p7_a29;
    ddp_x_node_rec.attribute11 := p7_a30;
    ddp_x_node_rec.attribute12 := p7_a31;
    ddp_x_node_rec.attribute13 := p7_a32;
    ddp_x_node_rec.attribute14 := p7_a33;
    ddp_x_node_rec.attribute15 := p7_a34;
    ddp_x_node_rec.operation_flag := p7_a35;
    ddp_x_node_rec.parent_node_rec_index := p7_a36;

    ahl_mc_node_pvt_w.rosetta_table_copy_in_p8(ddp_x_counter_rules_tbl, p8_a0
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
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      );

    ahl_mc_node_pvt_w.rosetta_table_copy_in_p10(ddp_x_subconfig_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_node_pvt.modify_node(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_node_rec,
      ddp_x_counter_rules_tbl,
      ddp_x_subconfig_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_x_node_rec.relationship_id;
    p7_a1 := ddp_x_node_rec.mc_header_id;
    p7_a2 := ddp_x_node_rec.position_key;
    p7_a3 := ddp_x_node_rec.position_ref_code;
    p7_a4 := ddp_x_node_rec.position_ref_meaning;
    p7_a5 := ddp_x_node_rec.ata_code;
    p7_a6 := ddp_x_node_rec.ata_meaning;
    p7_a7 := ddp_x_node_rec.position_necessity_code;
    p7_a8 := ddp_x_node_rec.position_necessity_meaning;
    p7_a9 := ddp_x_node_rec.uom_code;
    p7_a10 := ddp_x_node_rec.quantity;
    p7_a11 := ddp_x_node_rec.parent_relationship_id;
    p7_a12 := ddp_x_node_rec.item_group_id;
    p7_a13 := ddp_x_node_rec.item_group_name;
    p7_a14 := ddp_x_node_rec.display_order;
    p7_a15 := ddp_x_node_rec.active_start_date;
    p7_a16 := ddp_x_node_rec.active_end_date;
    p7_a17 := ddp_x_node_rec.object_version_number;
    p7_a18 := ddp_x_node_rec.security_group_id;
    p7_a19 := ddp_x_node_rec.attribute_category;
    p7_a20 := ddp_x_node_rec.attribute1;
    p7_a21 := ddp_x_node_rec.attribute2;
    p7_a22 := ddp_x_node_rec.attribute3;
    p7_a23 := ddp_x_node_rec.attribute4;
    p7_a24 := ddp_x_node_rec.attribute5;
    p7_a25 := ddp_x_node_rec.attribute6;
    p7_a26 := ddp_x_node_rec.attribute7;
    p7_a27 := ddp_x_node_rec.attribute8;
    p7_a28 := ddp_x_node_rec.attribute9;
    p7_a29 := ddp_x_node_rec.attribute10;
    p7_a30 := ddp_x_node_rec.attribute11;
    p7_a31 := ddp_x_node_rec.attribute12;
    p7_a32 := ddp_x_node_rec.attribute13;
    p7_a33 := ddp_x_node_rec.attribute14;
    p7_a34 := ddp_x_node_rec.attribute15;
    p7_a35 := ddp_x_node_rec.operation_flag;
    p7_a36 := ddp_x_node_rec.parent_node_rec_index;

    ahl_mc_node_pvt_w.rosetta_table_copy_out_p8(ddp_x_counter_rules_tbl, p8_a0
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
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      );

    ahl_mc_node_pvt_w.rosetta_table_copy_out_p10(ddp_x_subconfig_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      );
  end;

  procedure copy_mc_nodes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_rel_id  NUMBER
    , p_dest_rel_id  NUMBER
    , p_new_rev_flag  number
    , p_node_copy  number
  )

  as
    ddp_new_rev_flag boolean;
    ddp_node_copy boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    if p_new_rev_flag is null
      then ddp_new_rev_flag := null;
    elsif p_new_rev_flag = 0
      then ddp_new_rev_flag := false;
    else ddp_new_rev_flag := true;
    end if;

    if p_node_copy is null
      then ddp_node_copy := null;
    elsif p_node_copy = 0
      then ddp_node_copy := false;
    else ddp_node_copy := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_node_pvt.copy_mc_nodes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_rel_id,
      p_dest_rel_id,
      ddp_new_rev_flag,
      ddp_node_copy);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure process_documents(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_node_id  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 in out nocopy JTF_NUMBER_TABLE
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_documents_tbl ahl_di_asso_doc_gen_pub.association_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ahl_di_asso_doc_gen_pub_w.rosetta_table_copy_in_p1(ddp_x_documents_tbl, p8_a0
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
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_node_pvt.process_documents(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_node_id,
      ddp_x_documents_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_di_asso_doc_gen_pub_w.rosetta_table_copy_out_p1(ddp_x_documents_tbl, p8_a0
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
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      );
  end;

  procedure associate_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_DATE_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p7_a31 JTF_VARCHAR2_TABLE_200
    , p7_a32 JTF_VARCHAR2_TABLE_200
    , p7_a33 JTF_VARCHAR2_TABLE_200
    , p7_a34 JTF_VARCHAR2_TABLE_200
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
  )

  as
    ddp_nodes_tbl ahl_mc_node_pvt.node_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ahl_mc_node_pvt_w.rosetta_table_copy_in_p6(ddp_nodes_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_node_pvt.associate_item_group(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_nodes_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ahl_mc_node_pvt_w;

/
