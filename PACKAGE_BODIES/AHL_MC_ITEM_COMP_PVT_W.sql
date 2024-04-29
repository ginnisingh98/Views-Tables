--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEM_COMP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEM_COMP_PVT_W" as
  /* $Header: AHLVICWB.pls 120.1 2006/05/03 01:17 sathapli noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_mc_item_comp_pvt.det_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_comp_detail_id := a0(indx);
          t(ddindx).item_composition_id := a1(indx);
          t(ddindx).item_group_id := a2(indx);
          t(ddindx).item_group_name := a3(indx);
          t(ddindx).inventory_item_id := a4(indx);
          t(ddindx).inventory_item_name := a5(indx);
          t(ddindx).inventory_org_id := a6(indx);
          t(ddindx).inventory_org_code := a7(indx);
          t(ddindx).inventory_master_org_id := a8(indx);
          t(ddindx).uom_code := a9(indx);
          t(ddindx).quantity := a10(indx);
          t(ddindx).effective_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).link_comp_detl_id := a12(indx);
          t(ddindx).object_version_number := a13(indx);
          t(ddindx).attribute_category := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          t(ddindx).operation_flag := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_mc_item_comp_pvt.det_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_comp_detail_id;
          a1(indx) := t(ddindx).item_composition_id;
          a2(indx) := t(ddindx).item_group_id;
          a3(indx) := t(ddindx).item_group_name;
          a4(indx) := t(ddindx).inventory_item_id;
          a5(indx) := t(ddindx).inventory_item_name;
          a6(indx) := t(ddindx).inventory_org_id;
          a7(indx) := t(ddindx).inventory_org_code;
          a8(indx) := t(ddindx).inventory_master_org_id;
          a9(indx) := t(ddindx).uom_code;
          a10(indx) := t(ddindx).quantity;
          a11(indx) := t(ddindx).effective_end_date;
          a12(indx) := t(ddindx).link_comp_detl_id;
          a13(indx) := t(ddindx).object_version_number;
          a14(indx) := t(ddindx).attribute_category;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          a30(indx) := t(ddindx).operation_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_item_composition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_DATE_TABLE
    , p8_a12 in out nocopy JTF_NUMBER_TABLE
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_ic_header_rec ahl_mc_item_comp_pvt.header_rec_type;
    ddp_x_det_tbl ahl_mc_item_comp_pvt.det_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_ic_header_rec.item_composition_id := p7_a0;
    ddp_x_ic_header_rec.inventory_item_id := p7_a1;
    ddp_x_ic_header_rec.inventory_item_name := p7_a2;
    ddp_x_ic_header_rec.inventory_org_id := p7_a3;
    ddp_x_ic_header_rec.inventory_org_code := p7_a4;
    ddp_x_ic_header_rec.inventory_master_org_id := p7_a5;
    ddp_x_ic_header_rec.draft_flag := p7_a6;
    ddp_x_ic_header_rec.status_code := p7_a7;
    ddp_x_ic_header_rec.effective_end_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_x_ic_header_rec.object_version_number := p7_a9;
    ddp_x_ic_header_rec.attribute_category := p7_a10;
    ddp_x_ic_header_rec.attribute1 := p7_a11;
    ddp_x_ic_header_rec.attribute2 := p7_a12;
    ddp_x_ic_header_rec.attribute3 := p7_a13;
    ddp_x_ic_header_rec.attribute4 := p7_a14;
    ddp_x_ic_header_rec.attribute5 := p7_a15;
    ddp_x_ic_header_rec.attribute6 := p7_a16;
    ddp_x_ic_header_rec.attribute7 := p7_a17;
    ddp_x_ic_header_rec.attribute8 := p7_a18;
    ddp_x_ic_header_rec.attribute9 := p7_a19;
    ddp_x_ic_header_rec.attribute10 := p7_a20;
    ddp_x_ic_header_rec.attribute11 := p7_a21;
    ddp_x_ic_header_rec.attribute12 := p7_a22;
    ddp_x_ic_header_rec.attribute13 := p7_a23;
    ddp_x_ic_header_rec.attribute14 := p7_a24;
    ddp_x_ic_header_rec.attribute15 := p7_a25;
    ddp_x_ic_header_rec.operation_flag := p7_a26;

    ahl_mc_item_comp_pvt_w.rosetta_table_copy_in_p2(ddp_x_det_tbl, p8_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_item_comp_pvt.create_item_composition(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_ic_header_rec,
      ddp_x_det_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_x_ic_header_rec.item_composition_id;
    p7_a1 := ddp_x_ic_header_rec.inventory_item_id;
    p7_a2 := ddp_x_ic_header_rec.inventory_item_name;
    p7_a3 := ddp_x_ic_header_rec.inventory_org_id;
    p7_a4 := ddp_x_ic_header_rec.inventory_org_code;
    p7_a5 := ddp_x_ic_header_rec.inventory_master_org_id;
    p7_a6 := ddp_x_ic_header_rec.draft_flag;
    p7_a7 := ddp_x_ic_header_rec.status_code;
    p7_a8 := ddp_x_ic_header_rec.effective_end_date;
    p7_a9 := ddp_x_ic_header_rec.object_version_number;
    p7_a10 := ddp_x_ic_header_rec.attribute_category;
    p7_a11 := ddp_x_ic_header_rec.attribute1;
    p7_a12 := ddp_x_ic_header_rec.attribute2;
    p7_a13 := ddp_x_ic_header_rec.attribute3;
    p7_a14 := ddp_x_ic_header_rec.attribute4;
    p7_a15 := ddp_x_ic_header_rec.attribute5;
    p7_a16 := ddp_x_ic_header_rec.attribute6;
    p7_a17 := ddp_x_ic_header_rec.attribute7;
    p7_a18 := ddp_x_ic_header_rec.attribute8;
    p7_a19 := ddp_x_ic_header_rec.attribute9;
    p7_a20 := ddp_x_ic_header_rec.attribute10;
    p7_a21 := ddp_x_ic_header_rec.attribute11;
    p7_a22 := ddp_x_ic_header_rec.attribute12;
    p7_a23 := ddp_x_ic_header_rec.attribute13;
    p7_a24 := ddp_x_ic_header_rec.attribute14;
    p7_a25 := ddp_x_ic_header_rec.attribute15;
    p7_a26 := ddp_x_ic_header_rec.operation_flag;

    ahl_mc_item_comp_pvt_w.rosetta_table_copy_out_p2(ddp_x_det_tbl, p8_a0
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
      );
  end;

  procedure modify_item_composition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 in out nocopy JTF_NUMBER_TABLE
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 in out nocopy JTF_NUMBER_TABLE
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 in out nocopy JTF_NUMBER_TABLE
    , p8_a11 in out nocopy JTF_DATE_TABLE
    , p8_a12 in out nocopy JTF_NUMBER_TABLE
    , p8_a13 in out nocopy JTF_NUMBER_TABLE
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_ic_header_rec ahl_mc_item_comp_pvt.header_rec_type;
    ddp_x_det_tbl ahl_mc_item_comp_pvt.det_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_x_ic_header_rec.item_composition_id := p7_a0;
    ddp_x_ic_header_rec.inventory_item_id := p7_a1;
    ddp_x_ic_header_rec.inventory_item_name := p7_a2;
    ddp_x_ic_header_rec.inventory_org_id := p7_a3;
    ddp_x_ic_header_rec.inventory_org_code := p7_a4;
    ddp_x_ic_header_rec.inventory_master_org_id := p7_a5;
    ddp_x_ic_header_rec.draft_flag := p7_a6;
    ddp_x_ic_header_rec.status_code := p7_a7;
    ddp_x_ic_header_rec.effective_end_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_x_ic_header_rec.object_version_number := p7_a9;
    ddp_x_ic_header_rec.attribute_category := p7_a10;
    ddp_x_ic_header_rec.attribute1 := p7_a11;
    ddp_x_ic_header_rec.attribute2 := p7_a12;
    ddp_x_ic_header_rec.attribute3 := p7_a13;
    ddp_x_ic_header_rec.attribute4 := p7_a14;
    ddp_x_ic_header_rec.attribute5 := p7_a15;
    ddp_x_ic_header_rec.attribute6 := p7_a16;
    ddp_x_ic_header_rec.attribute7 := p7_a17;
    ddp_x_ic_header_rec.attribute8 := p7_a18;
    ddp_x_ic_header_rec.attribute9 := p7_a19;
    ddp_x_ic_header_rec.attribute10 := p7_a20;
    ddp_x_ic_header_rec.attribute11 := p7_a21;
    ddp_x_ic_header_rec.attribute12 := p7_a22;
    ddp_x_ic_header_rec.attribute13 := p7_a23;
    ddp_x_ic_header_rec.attribute14 := p7_a24;
    ddp_x_ic_header_rec.attribute15 := p7_a25;
    ddp_x_ic_header_rec.operation_flag := p7_a26;

    ahl_mc_item_comp_pvt_w.rosetta_table_copy_in_p2(ddp_x_det_tbl, p8_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_item_comp_pvt.modify_item_composition(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_ic_header_rec,
      ddp_x_det_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_x_ic_header_rec.item_composition_id;
    p7_a1 := ddp_x_ic_header_rec.inventory_item_id;
    p7_a2 := ddp_x_ic_header_rec.inventory_item_name;
    p7_a3 := ddp_x_ic_header_rec.inventory_org_id;
    p7_a4 := ddp_x_ic_header_rec.inventory_org_code;
    p7_a5 := ddp_x_ic_header_rec.inventory_master_org_id;
    p7_a6 := ddp_x_ic_header_rec.draft_flag;
    p7_a7 := ddp_x_ic_header_rec.status_code;
    p7_a8 := ddp_x_ic_header_rec.effective_end_date;
    p7_a9 := ddp_x_ic_header_rec.object_version_number;
    p7_a10 := ddp_x_ic_header_rec.attribute_category;
    p7_a11 := ddp_x_ic_header_rec.attribute1;
    p7_a12 := ddp_x_ic_header_rec.attribute2;
    p7_a13 := ddp_x_ic_header_rec.attribute3;
    p7_a14 := ddp_x_ic_header_rec.attribute4;
    p7_a15 := ddp_x_ic_header_rec.attribute5;
    p7_a16 := ddp_x_ic_header_rec.attribute6;
    p7_a17 := ddp_x_ic_header_rec.attribute7;
    p7_a18 := ddp_x_ic_header_rec.attribute8;
    p7_a19 := ddp_x_ic_header_rec.attribute9;
    p7_a20 := ddp_x_ic_header_rec.attribute10;
    p7_a21 := ddp_x_ic_header_rec.attribute11;
    p7_a22 := ddp_x_ic_header_rec.attribute12;
    p7_a23 := ddp_x_ic_header_rec.attribute13;
    p7_a24 := ddp_x_ic_header_rec.attribute14;
    p7_a25 := ddp_x_ic_header_rec.attribute15;
    p7_a26 := ddp_x_ic_header_rec.operation_flag;

    ahl_mc_item_comp_pvt_w.rosetta_table_copy_out_p2(ddp_x_det_tbl, p8_a0
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
      );
  end;

end ahl_mc_item_comp_pvt_w;

/
