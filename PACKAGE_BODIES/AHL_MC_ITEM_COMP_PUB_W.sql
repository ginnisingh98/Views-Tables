--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEM_COMP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEM_COMP_PUB_W" as
  /* $Header: AHLPICWB.pls 120.1 2006/05/03 01:08 sathapli noship $ */
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

  procedure process_item_composition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  NUMBER
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  DATE
    , p8_a9 in out nocopy  NUMBER
    , p8_a10 in out nocopy  VARCHAR2
    , p8_a11 in out nocopy  VARCHAR2
    , p8_a12 in out nocopy  VARCHAR2
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  VARCHAR2
    , p8_a15 in out nocopy  VARCHAR2
    , p8_a16 in out nocopy  VARCHAR2
    , p8_a17 in out nocopy  VARCHAR2
    , p8_a18 in out nocopy  VARCHAR2
    , p8_a19 in out nocopy  VARCHAR2
    , p8_a20 in out nocopy  VARCHAR2
    , p8_a21 in out nocopy  VARCHAR2
    , p8_a22 in out nocopy  VARCHAR2
    , p8_a23 in out nocopy  VARCHAR2
    , p8_a24 in out nocopy  VARCHAR2
    , p8_a25 in out nocopy  VARCHAR2
    , p8_a26 in out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 in out nocopy JTF_NUMBER_TABLE
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_NUMBER_TABLE
    , p9_a11 in out nocopy JTF_DATE_TABLE
    , p9_a12 in out nocopy JTF_NUMBER_TABLE
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_ic_header_rec ahl_mc_item_comp_pvt.header_rec_type;
    ddp_x_ic_det_tbl ahl_mc_item_comp_pvt.det_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_ic_header_rec.item_composition_id := p8_a0;
    ddp_x_ic_header_rec.inventory_item_id := p8_a1;
    ddp_x_ic_header_rec.inventory_item_name := p8_a2;
    ddp_x_ic_header_rec.inventory_org_id := p8_a3;
    ddp_x_ic_header_rec.inventory_org_code := p8_a4;
    ddp_x_ic_header_rec.inventory_master_org_id := p8_a5;
    ddp_x_ic_header_rec.draft_flag := p8_a6;
    ddp_x_ic_header_rec.status_code := p8_a7;
    ddp_x_ic_header_rec.effective_end_date := rosetta_g_miss_date_in_map(p8_a8);
    ddp_x_ic_header_rec.object_version_number := p8_a9;
    ddp_x_ic_header_rec.attribute_category := p8_a10;
    ddp_x_ic_header_rec.attribute1 := p8_a11;
    ddp_x_ic_header_rec.attribute2 := p8_a12;
    ddp_x_ic_header_rec.attribute3 := p8_a13;
    ddp_x_ic_header_rec.attribute4 := p8_a14;
    ddp_x_ic_header_rec.attribute5 := p8_a15;
    ddp_x_ic_header_rec.attribute6 := p8_a16;
    ddp_x_ic_header_rec.attribute7 := p8_a17;
    ddp_x_ic_header_rec.attribute8 := p8_a18;
    ddp_x_ic_header_rec.attribute9 := p8_a19;
    ddp_x_ic_header_rec.attribute10 := p8_a20;
    ddp_x_ic_header_rec.attribute11 := p8_a21;
    ddp_x_ic_header_rec.attribute12 := p8_a22;
    ddp_x_ic_header_rec.attribute13 := p8_a23;
    ddp_x_ic_header_rec.attribute14 := p8_a24;
    ddp_x_ic_header_rec.attribute15 := p8_a25;
    ddp_x_ic_header_rec.operation_flag := p8_a26;

    ahl_mc_item_comp_pvt_w.rosetta_table_copy_in_p2(ddp_x_ic_det_tbl, p9_a0
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
      , p9_a29
      , p9_a30
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_item_comp_pub.process_item_composition(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_ic_header_rec,
      ddp_x_ic_det_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_ic_header_rec.item_composition_id;
    p8_a1 := ddp_x_ic_header_rec.inventory_item_id;
    p8_a2 := ddp_x_ic_header_rec.inventory_item_name;
    p8_a3 := ddp_x_ic_header_rec.inventory_org_id;
    p8_a4 := ddp_x_ic_header_rec.inventory_org_code;
    p8_a5 := ddp_x_ic_header_rec.inventory_master_org_id;
    p8_a6 := ddp_x_ic_header_rec.draft_flag;
    p8_a7 := ddp_x_ic_header_rec.status_code;
    p8_a8 := ddp_x_ic_header_rec.effective_end_date;
    p8_a9 := ddp_x_ic_header_rec.object_version_number;
    p8_a10 := ddp_x_ic_header_rec.attribute_category;
    p8_a11 := ddp_x_ic_header_rec.attribute1;
    p8_a12 := ddp_x_ic_header_rec.attribute2;
    p8_a13 := ddp_x_ic_header_rec.attribute3;
    p8_a14 := ddp_x_ic_header_rec.attribute4;
    p8_a15 := ddp_x_ic_header_rec.attribute5;
    p8_a16 := ddp_x_ic_header_rec.attribute6;
    p8_a17 := ddp_x_ic_header_rec.attribute7;
    p8_a18 := ddp_x_ic_header_rec.attribute8;
    p8_a19 := ddp_x_ic_header_rec.attribute9;
    p8_a20 := ddp_x_ic_header_rec.attribute10;
    p8_a21 := ddp_x_ic_header_rec.attribute11;
    p8_a22 := ddp_x_ic_header_rec.attribute12;
    p8_a23 := ddp_x_ic_header_rec.attribute13;
    p8_a24 := ddp_x_ic_header_rec.attribute14;
    p8_a25 := ddp_x_ic_header_rec.attribute15;
    p8_a26 := ddp_x_ic_header_rec.operation_flag;

    ahl_mc_item_comp_pvt_w.rosetta_table_copy_out_p2(ddp_x_ic_det_tbl, p9_a0
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
      , p9_a29
      , p9_a30
      );
  end;

end ahl_mc_item_comp_pub_w;

/
