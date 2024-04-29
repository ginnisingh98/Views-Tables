--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEMGROUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEMGROUP_PVT_W" as
  /* $Header: AHLVIGWB.pls 120.1 2005/08/09 11:02 priyan noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_mc_itemgroup_pvt.item_association_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
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
    , a32 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_association_id := a0(indx);
          t(ddindx).item_group_name := a1(indx);
          t(ddindx).item_group_id := a2(indx);
          t(ddindx).source_item_association_id := a3(indx);
          t(ddindx).inventory_org_code := a4(indx);
          t(ddindx).inventory_org_id := a5(indx);
          t(ddindx).inventory_item_name := a6(indx);
          t(ddindx).inventory_item_id := a7(indx);
          t(ddindx).revision := a8(indx);
          t(ddindx).priority := a9(indx);
          t(ddindx).uom_code := a10(indx);
          t(ddindx).quantity := a11(indx);
          t(ddindx).interchange_type_meaning := a12(indx);
          t(ddindx).interchange_type_code := a13(indx);
          t(ddindx).interchange_reason := a14(indx);
          t(ddindx).object_version_number := a15(indx);
          t(ddindx).attribute_category := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          t(ddindx).operation_flag := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_mc_itemgroup_pvt.item_association_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
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
    a32 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
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
      a32 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_association_id;
          a1(indx) := t(ddindx).item_group_name;
          a2(indx) := t(ddindx).item_group_id;
          a3(indx) := t(ddindx).source_item_association_id;
          a4(indx) := t(ddindx).inventory_org_code;
          a5(indx) := t(ddindx).inventory_org_id;
          a6(indx) := t(ddindx).inventory_item_name;
          a7(indx) := t(ddindx).inventory_item_id;
          a8(indx) := t(ddindx).revision;
          a9(indx) := t(ddindx).priority;
          a10(indx) := t(ddindx).uom_code;
          a11(indx) := t(ddindx).quantity;
          a12(indx) := t(ddindx).interchange_type_meaning;
          a13(indx) := t(ddindx).interchange_type_code;
          a14(indx) := t(ddindx).interchange_reason;
          a15(indx) := t(ddindx).object_version_number;
          a16(indx) := t(ddindx).attribute_category;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          a32(indx) := t(ddindx).operation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  VARCHAR2
    , p6_a12 in out nocopy  VARCHAR2
    , p6_a13 in out nocopy  VARCHAR2
    , p6_a14 in out nocopy  VARCHAR2
    , p6_a15 in out nocopy  VARCHAR2
    , p6_a16 in out nocopy  VARCHAR2
    , p6_a17 in out nocopy  VARCHAR2
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  VARCHAR2
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
    , p6_a23 in out nocopy  VARCHAR2
    , p6_a24 in out nocopy  VARCHAR2
    , p6_a25 in out nocopy  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_item_group_rec ahl_mc_itemgroup_pvt.item_group_rec_type;
    ddp_x_items_tbl ahl_mc_itemgroup_pvt.item_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_x_item_group_rec.item_group_id := p6_a0;
    ddp_x_item_group_rec.name := p6_a1;
    ddp_x_item_group_rec.source_item_group_id := p6_a2;
    ddp_x_item_group_rec.status_code := p6_a3;
    ddp_x_item_group_rec.status_meaning := p6_a4;
    ddp_x_item_group_rec.type_code := p6_a5;
    ddp_x_item_group_rec.type_meaning := p6_a6;
    ddp_x_item_group_rec.description := p6_a7;
    ddp_x_item_group_rec.object_version_number := p6_a8;
    ddp_x_item_group_rec.attribute_category := p6_a9;
    ddp_x_item_group_rec.attribute1 := p6_a10;
    ddp_x_item_group_rec.attribute2 := p6_a11;
    ddp_x_item_group_rec.attribute3 := p6_a12;
    ddp_x_item_group_rec.attribute4 := p6_a13;
    ddp_x_item_group_rec.attribute5 := p6_a14;
    ddp_x_item_group_rec.attribute6 := p6_a15;
    ddp_x_item_group_rec.attribute7 := p6_a16;
    ddp_x_item_group_rec.attribute8 := p6_a17;
    ddp_x_item_group_rec.attribute9 := p6_a18;
    ddp_x_item_group_rec.attribute10 := p6_a19;
    ddp_x_item_group_rec.attribute11 := p6_a20;
    ddp_x_item_group_rec.attribute12 := p6_a21;
    ddp_x_item_group_rec.attribute13 := p6_a22;
    ddp_x_item_group_rec.attribute14 := p6_a23;
    ddp_x_item_group_rec.attribute15 := p6_a24;
    ddp_x_item_group_rec.operation_flag := p6_a25;

    ahl_mc_itemgroup_pvt_w.rosetta_table_copy_in_p2(ddp_x_items_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_itemgroup_pvt.create_item_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_item_group_rec,
      ddp_x_items_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddp_x_item_group_rec.item_group_id;
    p6_a1 := ddp_x_item_group_rec.name;
    p6_a2 := ddp_x_item_group_rec.source_item_group_id;
    p6_a3 := ddp_x_item_group_rec.status_code;
    p6_a4 := ddp_x_item_group_rec.status_meaning;
    p6_a5 := ddp_x_item_group_rec.type_code;
    p6_a6 := ddp_x_item_group_rec.type_meaning;
    p6_a7 := ddp_x_item_group_rec.description;
    p6_a8 := ddp_x_item_group_rec.object_version_number;
    p6_a9 := ddp_x_item_group_rec.attribute_category;
    p6_a10 := ddp_x_item_group_rec.attribute1;
    p6_a11 := ddp_x_item_group_rec.attribute2;
    p6_a12 := ddp_x_item_group_rec.attribute3;
    p6_a13 := ddp_x_item_group_rec.attribute4;
    p6_a14 := ddp_x_item_group_rec.attribute5;
    p6_a15 := ddp_x_item_group_rec.attribute6;
    p6_a16 := ddp_x_item_group_rec.attribute7;
    p6_a17 := ddp_x_item_group_rec.attribute8;
    p6_a18 := ddp_x_item_group_rec.attribute9;
    p6_a19 := ddp_x_item_group_rec.attribute10;
    p6_a20 := ddp_x_item_group_rec.attribute11;
    p6_a21 := ddp_x_item_group_rec.attribute12;
    p6_a22 := ddp_x_item_group_rec.attribute13;
    p6_a23 := ddp_x_item_group_rec.attribute14;
    p6_a24 := ddp_x_item_group_rec.attribute15;
    p6_a25 := ddp_x_item_group_rec.operation_flag;

    ahl_mc_itemgroup_pvt_w.rosetta_table_copy_out_p2(ddp_x_items_tbl, p7_a0
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
      );
  end;

  procedure modify_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_item_group_rec ahl_mc_itemgroup_pvt.item_group_rec_type;
    ddp_x_items_tbl ahl_mc_itemgroup_pvt.item_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_item_group_rec.item_group_id := p6_a0;
    ddp_item_group_rec.name := p6_a1;
    ddp_item_group_rec.source_item_group_id := p6_a2;
    ddp_item_group_rec.status_code := p6_a3;
    ddp_item_group_rec.status_meaning := p6_a4;
    ddp_item_group_rec.type_code := p6_a5;
    ddp_item_group_rec.type_meaning := p6_a6;
    ddp_item_group_rec.description := p6_a7;
    ddp_item_group_rec.object_version_number := p6_a8;
    ddp_item_group_rec.attribute_category := p6_a9;
    ddp_item_group_rec.attribute1 := p6_a10;
    ddp_item_group_rec.attribute2 := p6_a11;
    ddp_item_group_rec.attribute3 := p6_a12;
    ddp_item_group_rec.attribute4 := p6_a13;
    ddp_item_group_rec.attribute5 := p6_a14;
    ddp_item_group_rec.attribute6 := p6_a15;
    ddp_item_group_rec.attribute7 := p6_a16;
    ddp_item_group_rec.attribute8 := p6_a17;
    ddp_item_group_rec.attribute9 := p6_a18;
    ddp_item_group_rec.attribute10 := p6_a19;
    ddp_item_group_rec.attribute11 := p6_a20;
    ddp_item_group_rec.attribute12 := p6_a21;
    ddp_item_group_rec.attribute13 := p6_a22;
    ddp_item_group_rec.attribute14 := p6_a23;
    ddp_item_group_rec.attribute15 := p6_a24;
    ddp_item_group_rec.operation_flag := p6_a25;

    ahl_mc_itemgroup_pvt_w.rosetta_table_copy_in_p2(ddp_x_items_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_itemgroup_pvt.modify_item_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_group_rec,
      ddp_x_items_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ahl_mc_itemgroup_pvt_w.rosetta_table_copy_out_p2(ddp_x_items_tbl, p7_a0
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
      );
  end;

  procedure remove_item_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
  )

  as
    ddp_item_group_rec ahl_mc_itemgroup_pvt.item_group_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_item_group_rec.item_group_id := p6_a0;
    ddp_item_group_rec.name := p6_a1;
    ddp_item_group_rec.source_item_group_id := p6_a2;
    ddp_item_group_rec.status_code := p6_a3;
    ddp_item_group_rec.status_meaning := p6_a4;
    ddp_item_group_rec.type_code := p6_a5;
    ddp_item_group_rec.type_meaning := p6_a6;
    ddp_item_group_rec.description := p6_a7;
    ddp_item_group_rec.object_version_number := p6_a8;
    ddp_item_group_rec.attribute_category := p6_a9;
    ddp_item_group_rec.attribute1 := p6_a10;
    ddp_item_group_rec.attribute2 := p6_a11;
    ddp_item_group_rec.attribute3 := p6_a12;
    ddp_item_group_rec.attribute4 := p6_a13;
    ddp_item_group_rec.attribute5 := p6_a14;
    ddp_item_group_rec.attribute6 := p6_a15;
    ddp_item_group_rec.attribute7 := p6_a16;
    ddp_item_group_rec.attribute8 := p6_a17;
    ddp_item_group_rec.attribute9 := p6_a18;
    ddp_item_group_rec.attribute10 := p6_a19;
    ddp_item_group_rec.attribute11 := p6_a20;
    ddp_item_group_rec.attribute12 := p6_a21;
    ddp_item_group_rec.attribute13 := p6_a22;
    ddp_item_group_rec.attribute14 := p6_a23;
    ddp_item_group_rec.attribute15 := p6_a24;
    ddp_item_group_rec.operation_flag := p6_a25;

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_itemgroup_pvt.remove_item_group(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_group_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure modify_position_assos(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_group_id  NUMBER
    , p_object_version_number  NUMBER
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p10_a7 JTF_VARCHAR2_TABLE_100
    , p10_a8 JTF_VARCHAR2_TABLE_100
    , p10_a9 JTF_VARCHAR2_TABLE_100
    , p10_a10 JTF_NUMBER_TABLE
    , p10_a11 JTF_NUMBER_TABLE
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_VARCHAR2_TABLE_100
    , p10_a14 JTF_NUMBER_TABLE
    , p10_a15 JTF_DATE_TABLE
    , p10_a16 JTF_DATE_TABLE
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_NUMBER_TABLE
    , p10_a19 JTF_VARCHAR2_TABLE_100
    , p10_a20 JTF_VARCHAR2_TABLE_200
    , p10_a21 JTF_VARCHAR2_TABLE_200
    , p10_a22 JTF_VARCHAR2_TABLE_200
    , p10_a23 JTF_VARCHAR2_TABLE_200
    , p10_a24 JTF_VARCHAR2_TABLE_200
    , p10_a25 JTF_VARCHAR2_TABLE_200
    , p10_a26 JTF_VARCHAR2_TABLE_200
    , p10_a27 JTF_VARCHAR2_TABLE_200
    , p10_a28 JTF_VARCHAR2_TABLE_200
    , p10_a29 JTF_VARCHAR2_TABLE_200
    , p10_a30 JTF_VARCHAR2_TABLE_200
    , p10_a31 JTF_VARCHAR2_TABLE_200
    , p10_a32 JTF_VARCHAR2_TABLE_200
    , p10_a33 JTF_VARCHAR2_TABLE_200
    , p10_a34 JTF_VARCHAR2_TABLE_200
    , p10_a35 JTF_VARCHAR2_TABLE_100
    , p10_a36 JTF_NUMBER_TABLE
  )

  as
    ddp_nodes_tbl ahl_mc_node_pvt.node_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ahl_mc_node_pvt_w.rosetta_table_copy_in_p6(ddp_nodes_tbl, p10_a0
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
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_itemgroup_pvt.modify_position_assos(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_group_id,
      p_object_version_number,
      ddp_nodes_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end ahl_mc_itemgroup_pvt_w;

/
