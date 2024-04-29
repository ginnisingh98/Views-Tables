--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UF_PVT_W" as
  /* $Header: AHLUMFWB.pls 120.2 2008/01/18 01:22:41 sikumar ship $ */
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

  procedure rosetta_table_copy_in_p16(t out nocopy ahl_ump_uf_pvt.uf_details_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).uf_detail_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).created_by := a2(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_updated_by := a4(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).uf_header_id := a7(indx);
          t(ddindx).uom_code := a8(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).usage_per_day := a11(indx);
          t(ddindx).operation_flag := a12(indx);
          t(ddindx).attribute_category := a13(indx);
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute2 := a15(indx);
          t(ddindx).attribute3 := a16(indx);
          t(ddindx).attribute4 := a17(indx);
          t(ddindx).attribute5 := a18(indx);
          t(ddindx).attribute6 := a19(indx);
          t(ddindx).attribute7 := a20(indx);
          t(ddindx).attribute8 := a21(indx);
          t(ddindx).attribute9 := a22(indx);
          t(ddindx).attribute10 := a23(indx);
          t(ddindx).attribute11 := a24(indx);
          t(ddindx).attribute12 := a25(indx);
          t(ddindx).attribute13 := a26(indx);
          t(ddindx).attribute14 := a27(indx);
          t(ddindx).attribute15 := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t ahl_ump_uf_pvt.uf_details_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).uf_detail_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).created_by;
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := t(ddindx).last_updated_by;
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).uf_header_id;
          a8(indx) := t(ddindx).uom_code;
          a9(indx) := t(ddindx).start_date;
          a10(indx) := t(ddindx).end_date;
          a11(indx) := t(ddindx).usage_per_day;
          a12(indx) := t(ddindx).operation_flag;
          a13(indx) := t(ddindx).attribute_category;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute2;
          a16(indx) := t(ddindx).attribute3;
          a17(indx) := t(ddindx).attribute4;
          a18(indx) := t(ddindx).attribute5;
          a19(indx) := t(ddindx).attribute6;
          a20(indx) := t(ddindx).attribute7;
          a21(indx) := t(ddindx).attribute8;
          a22(indx) := t(ddindx).attribute9;
          a23(indx) := t(ddindx).attribute10;
          a24(indx) := t(ddindx).attribute11;
          a25(indx) := t(ddindx).attribute12;
          a26(indx) := t(ddindx).attribute13;
          a27(indx) := t(ddindx).attribute14;
          a28(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p16;

  procedure process_utilization_forecast(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  DATE
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_DATE_TABLE
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_DATE_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 in out nocopy JTF_DATE_TABLE
    , p6_a10 in out nocopy JTF_DATE_TABLE
    , p6_a11 in out nocopy JTF_NUMBER_TABLE
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_uf_header_rec ahl_ump_uf_pvt.uf_header_rec_type;
    ddp_x_uf_details_tbl ahl_ump_uf_pvt.uf_details_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_uf_header_rec.uf_header_id := p5_a0;
    ddp_x_uf_header_rec.object_version_number := p5_a1;
    ddp_x_uf_header_rec.created_by := p5_a2;
    ddp_x_uf_header_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_x_uf_header_rec.last_updated_by := p5_a4;
    ddp_x_uf_header_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_x_uf_header_rec.last_update_login := p5_a6;
    ddp_x_uf_header_rec.unit_config_header_id := p5_a7;
    ddp_x_uf_header_rec.unit_name := p5_a8;
    ddp_x_uf_header_rec.pc_node_id := p5_a9;
    ddp_x_uf_header_rec.inventory_item_id := p5_a10;
    ddp_x_uf_header_rec.inventory_item_name := p5_a11;
    ddp_x_uf_header_rec.inventory_org_code := p5_a12;
    ddp_x_uf_header_rec.inventory_org_id := p5_a13;
    ddp_x_uf_header_rec.csi_item_instance_id := p5_a14;
    ddp_x_uf_header_rec.use_unit_flag := p5_a15;
    ddp_x_uf_header_rec.forecast_type := p5_a16;
    ddp_x_uf_header_rec.operation_flag := p5_a17;
    ddp_x_uf_header_rec.attribute_category := p5_a18;
    ddp_x_uf_header_rec.attribute1 := p5_a19;
    ddp_x_uf_header_rec.attribute2 := p5_a20;
    ddp_x_uf_header_rec.attribute3 := p5_a21;
    ddp_x_uf_header_rec.attribute4 := p5_a22;
    ddp_x_uf_header_rec.attribute5 := p5_a23;
    ddp_x_uf_header_rec.attribute6 := p5_a24;
    ddp_x_uf_header_rec.attribute7 := p5_a25;
    ddp_x_uf_header_rec.attribute8 := p5_a26;
    ddp_x_uf_header_rec.attribute9 := p5_a27;
    ddp_x_uf_header_rec.attribute10 := p5_a28;
    ddp_x_uf_header_rec.attribute11 := p5_a29;
    ddp_x_uf_header_rec.attribute12 := p5_a30;
    ddp_x_uf_header_rec.attribute13 := p5_a31;
    ddp_x_uf_header_rec.attribute14 := p5_a32;
    ddp_x_uf_header_rec.attribute15 := p5_a33;

    ahl_ump_uf_pvt_w.rosetta_table_copy_in_p16(ddp_x_uf_details_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_uf_pvt.process_utilization_forecast(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_uf_header_rec,
      ddp_x_uf_details_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_uf_header_rec.uf_header_id;
    p5_a1 := ddp_x_uf_header_rec.object_version_number;
    p5_a2 := ddp_x_uf_header_rec.created_by;
    p5_a3 := ddp_x_uf_header_rec.creation_date;
    p5_a4 := ddp_x_uf_header_rec.last_updated_by;
    p5_a5 := ddp_x_uf_header_rec.last_update_date;
    p5_a6 := ddp_x_uf_header_rec.last_update_login;
    p5_a7 := ddp_x_uf_header_rec.unit_config_header_id;
    p5_a8 := ddp_x_uf_header_rec.unit_name;
    p5_a9 := ddp_x_uf_header_rec.pc_node_id;
    p5_a10 := ddp_x_uf_header_rec.inventory_item_id;
    p5_a11 := ddp_x_uf_header_rec.inventory_item_name;
    p5_a12 := ddp_x_uf_header_rec.inventory_org_code;
    p5_a13 := ddp_x_uf_header_rec.inventory_org_id;
    p5_a14 := ddp_x_uf_header_rec.csi_item_instance_id;
    p5_a15 := ddp_x_uf_header_rec.use_unit_flag;
    p5_a16 := ddp_x_uf_header_rec.forecast_type;
    p5_a17 := ddp_x_uf_header_rec.operation_flag;
    p5_a18 := ddp_x_uf_header_rec.attribute_category;
    p5_a19 := ddp_x_uf_header_rec.attribute1;
    p5_a20 := ddp_x_uf_header_rec.attribute2;
    p5_a21 := ddp_x_uf_header_rec.attribute3;
    p5_a22 := ddp_x_uf_header_rec.attribute4;
    p5_a23 := ddp_x_uf_header_rec.attribute5;
    p5_a24 := ddp_x_uf_header_rec.attribute6;
    p5_a25 := ddp_x_uf_header_rec.attribute7;
    p5_a26 := ddp_x_uf_header_rec.attribute8;
    p5_a27 := ddp_x_uf_header_rec.attribute9;
    p5_a28 := ddp_x_uf_header_rec.attribute10;
    p5_a29 := ddp_x_uf_header_rec.attribute11;
    p5_a30 := ddp_x_uf_header_rec.attribute12;
    p5_a31 := ddp_x_uf_header_rec.attribute13;
    p5_a32 := ddp_x_uf_header_rec.attribute14;
    p5_a33 := ddp_x_uf_header_rec.attribute15;

    ahl_ump_uf_pvt_w.rosetta_table_copy_out_p16(ddp_x_uf_details_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      );



  end;

  procedure get_uf_from_pc(p_init_msg_list  VARCHAR2
    , p_pc_node_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_inventory_org_id  NUMBER
    , p_unit_config_header_id  NUMBER
    , p_unit_name  VARCHAR2
    , p_part_number  VARCHAR2
    , p_onward_end_date  date
    , p_add_unit_item_forecast  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_DATE_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_DATE_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_onward_end_date date;
    ddx_uf_details_tbl ahl_ump_uf_pvt.uf_details_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_onward_end_date := rosetta_g_miss_date_in_map(p_onward_end_date);




    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_uf_pvt.get_uf_from_pc(p_init_msg_list,
      p_pc_node_id,
      p_inventory_item_id,
      p_inventory_org_id,
      p_unit_config_header_id,
      p_unit_name,
      p_part_number,
      ddp_onward_end_date,
      p_add_unit_item_forecast,
      ddx_uf_details_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_ump_uf_pvt_w.rosetta_table_copy_out_p16(ddx_uf_details_tbl, p9_a0
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
      , p9_a27
      , p9_a28
      );

  end;

  procedure get_uf_from_part(p_init_msg_list  VARCHAR2
    , p_csi_item_instance_id  NUMBER
    , p_onward_end_date  date
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_DATE_TABLE
    , p3_a10 out nocopy JTF_DATE_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_onward_end_date date;
    ddx_uf_details_tbl ahl_ump_uf_pvt.uf_details_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_onward_end_date := rosetta_g_miss_date_in_map(p_onward_end_date);



    -- here's the delegated call to the old PL/SQL routine
    ahl_ump_uf_pvt.get_uf_from_part(p_init_msg_list,
      p_csi_item_instance_id,
      ddp_onward_end_date,
      ddx_uf_details_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    ahl_ump_uf_pvt_w.rosetta_table_copy_out_p16(ddx_uf_details_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      );

  end;

end ahl_ump_uf_pvt_w;

/
