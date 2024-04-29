--------------------------------------------------------
--  DDL for Package Body AHL_MC_MASTERCONFIG_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_MASTERCONFIG_PUB_W" as
  /* $Header: AHLPMCWB.pls 120.1.12010000.2 2008/11/06 09:54:49 sathapli ship $ */
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

  procedure process_master_config(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  VARCHAR2
    , p8_a2 in out nocopy  VARCHAR2
    , p8_a3 in out nocopy  NUMBER
    , p8_a4 in out nocopy  NUMBER
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  NUMBER
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
    , p8_a27 in out nocopy  VARCHAR2
    , p8_a28 in out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  NUMBER
    , p9_a12 in out nocopy  NUMBER
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  NUMBER
    , p9_a15 in out nocopy  DATE
    , p9_a16 in out nocopy  DATE
    , p9_a17 in out nocopy  NUMBER
    , p9_a18 in out nocopy  NUMBER
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  VARCHAR2
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  NUMBER
  )

  as
    ddp_x_mc_header_rec ahl_mc_masterconfig_pvt.header_rec_type;
    ddp_x_node_rec ahl_mc_node_pvt.node_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_mc_header_rec.mc_header_id := p8_a0;
    ddp_x_mc_header_rec.name := p8_a1;
    ddp_x_mc_header_rec.description := p8_a2;
    ddp_x_mc_header_rec.mc_id := p8_a3;
    ddp_x_mc_header_rec.version_number := p8_a4;
    ddp_x_mc_header_rec.revision := p8_a5;
    ddp_x_mc_header_rec.model_code := p8_a6;
    ddp_x_mc_header_rec.model_meaning := p8_a7;
    ddp_x_mc_header_rec.config_status_code := p8_a8;
    ddp_x_mc_header_rec.config_status_meaning := p8_a9;
    ddp_x_mc_header_rec.object_version_number := p8_a10;
    ddp_x_mc_header_rec.security_group_id := p8_a11;
    ddp_x_mc_header_rec.attribute_category := p8_a12;
    ddp_x_mc_header_rec.attribute1 := p8_a13;
    ddp_x_mc_header_rec.attribute2 := p8_a14;
    ddp_x_mc_header_rec.attribute3 := p8_a15;
    ddp_x_mc_header_rec.attribute4 := p8_a16;
    ddp_x_mc_header_rec.attribute5 := p8_a17;
    ddp_x_mc_header_rec.attribute6 := p8_a18;
    ddp_x_mc_header_rec.attribute7 := p8_a19;
    ddp_x_mc_header_rec.attribute8 := p8_a20;
    ddp_x_mc_header_rec.attribute9 := p8_a21;
    ddp_x_mc_header_rec.attribute10 := p8_a22;
    ddp_x_mc_header_rec.attribute11 := p8_a23;
    ddp_x_mc_header_rec.attribute12 := p8_a24;
    ddp_x_mc_header_rec.attribute13 := p8_a25;
    ddp_x_mc_header_rec.attribute14 := p8_a26;
    ddp_x_mc_header_rec.attribute15 := p8_a27;
    ddp_x_mc_header_rec.operation_flag := p8_a28;

    ddp_x_node_rec.relationship_id := p9_a0;
    ddp_x_node_rec.mc_header_id := p9_a1;
    ddp_x_node_rec.position_key := p9_a2;
    ddp_x_node_rec.position_ref_code := p9_a3;
    ddp_x_node_rec.position_ref_meaning := p9_a4;
    ddp_x_node_rec.ata_code := p9_a5;
    ddp_x_node_rec.ata_meaning := p9_a6;
    ddp_x_node_rec.position_necessity_code := p9_a7;
    ddp_x_node_rec.position_necessity_meaning := p9_a8;
    ddp_x_node_rec.uom_code := p9_a9;
    ddp_x_node_rec.quantity := p9_a10;
    ddp_x_node_rec.parent_relationship_id := p9_a11;
    ddp_x_node_rec.item_group_id := p9_a12;
    ddp_x_node_rec.item_group_name := p9_a13;
    ddp_x_node_rec.display_order := p9_a14;
    ddp_x_node_rec.active_start_date := rosetta_g_miss_date_in_map(p9_a15);
    ddp_x_node_rec.active_end_date := rosetta_g_miss_date_in_map(p9_a16);
    ddp_x_node_rec.object_version_number := p9_a17;
    ddp_x_node_rec.security_group_id := p9_a18;
    ddp_x_node_rec.attribute_category := p9_a19;
    ddp_x_node_rec.attribute1 := p9_a20;
    ddp_x_node_rec.attribute2 := p9_a21;
    ddp_x_node_rec.attribute3 := p9_a22;
    ddp_x_node_rec.attribute4 := p9_a23;
    ddp_x_node_rec.attribute5 := p9_a24;
    ddp_x_node_rec.attribute6 := p9_a25;
    ddp_x_node_rec.attribute7 := p9_a26;
    ddp_x_node_rec.attribute8 := p9_a27;
    ddp_x_node_rec.attribute9 := p9_a28;
    ddp_x_node_rec.attribute10 := p9_a29;
    ddp_x_node_rec.attribute11 := p9_a30;
    ddp_x_node_rec.attribute12 := p9_a31;
    ddp_x_node_rec.attribute13 := p9_a32;
    ddp_x_node_rec.attribute14 := p9_a33;
    ddp_x_node_rec.attribute15 := p9_a34;
    ddp_x_node_rec.operation_flag := p9_a35;
    ddp_x_node_rec.parent_node_rec_index := p9_a36;

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_masterconfig_pub.process_master_config(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_mc_header_rec,
      ddp_x_node_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_mc_header_rec.mc_header_id;
    p8_a1 := ddp_x_mc_header_rec.name;
    p8_a2 := ddp_x_mc_header_rec.description;
    p8_a3 := ddp_x_mc_header_rec.mc_id;
    p8_a4 := ddp_x_mc_header_rec.version_number;
    p8_a5 := ddp_x_mc_header_rec.revision;
    p8_a6 := ddp_x_mc_header_rec.model_code;
    p8_a7 := ddp_x_mc_header_rec.model_meaning;
    p8_a8 := ddp_x_mc_header_rec.config_status_code;
    p8_a9 := ddp_x_mc_header_rec.config_status_meaning;
    p8_a10 := ddp_x_mc_header_rec.object_version_number;
    p8_a11 := ddp_x_mc_header_rec.security_group_id;
    p8_a12 := ddp_x_mc_header_rec.attribute_category;
    p8_a13 := ddp_x_mc_header_rec.attribute1;
    p8_a14 := ddp_x_mc_header_rec.attribute2;
    p8_a15 := ddp_x_mc_header_rec.attribute3;
    p8_a16 := ddp_x_mc_header_rec.attribute4;
    p8_a17 := ddp_x_mc_header_rec.attribute5;
    p8_a18 := ddp_x_mc_header_rec.attribute6;
    p8_a19 := ddp_x_mc_header_rec.attribute7;
    p8_a20 := ddp_x_mc_header_rec.attribute8;
    p8_a21 := ddp_x_mc_header_rec.attribute9;
    p8_a22 := ddp_x_mc_header_rec.attribute10;
    p8_a23 := ddp_x_mc_header_rec.attribute11;
    p8_a24 := ddp_x_mc_header_rec.attribute12;
    p8_a25 := ddp_x_mc_header_rec.attribute13;
    p8_a26 := ddp_x_mc_header_rec.attribute14;
    p8_a27 := ddp_x_mc_header_rec.attribute15;
    p8_a28 := ddp_x_mc_header_rec.operation_flag;

    p9_a0 := ddp_x_node_rec.relationship_id;
    p9_a1 := ddp_x_node_rec.mc_header_id;
    p9_a2 := ddp_x_node_rec.position_key;
    p9_a3 := ddp_x_node_rec.position_ref_code;
    p9_a4 := ddp_x_node_rec.position_ref_meaning;
    p9_a5 := ddp_x_node_rec.ata_code;
    p9_a6 := ddp_x_node_rec.ata_meaning;
    p9_a7 := ddp_x_node_rec.position_necessity_code;
    p9_a8 := ddp_x_node_rec.position_necessity_meaning;
    p9_a9 := ddp_x_node_rec.uom_code;
    p9_a10 := ddp_x_node_rec.quantity;
    p9_a11 := ddp_x_node_rec.parent_relationship_id;
    p9_a12 := ddp_x_node_rec.item_group_id;
    p9_a13 := ddp_x_node_rec.item_group_name;
    p9_a14 := ddp_x_node_rec.display_order;
    p9_a15 := ddp_x_node_rec.active_start_date;
    p9_a16 := ddp_x_node_rec.active_end_date;
    p9_a17 := ddp_x_node_rec.object_version_number;
    p9_a18 := ddp_x_node_rec.security_group_id;
    p9_a19 := ddp_x_node_rec.attribute_category;
    p9_a20 := ddp_x_node_rec.attribute1;
    p9_a21 := ddp_x_node_rec.attribute2;
    p9_a22 := ddp_x_node_rec.attribute3;
    p9_a23 := ddp_x_node_rec.attribute4;
    p9_a24 := ddp_x_node_rec.attribute5;
    p9_a25 := ddp_x_node_rec.attribute6;
    p9_a26 := ddp_x_node_rec.attribute7;
    p9_a27 := ddp_x_node_rec.attribute8;
    p9_a28 := ddp_x_node_rec.attribute9;
    p9_a29 := ddp_x_node_rec.attribute10;
    p9_a30 := ddp_x_node_rec.attribute11;
    p9_a31 := ddp_x_node_rec.attribute12;
    p9_a32 := ddp_x_node_rec.attribute13;
    p9_a33 := ddp_x_node_rec.attribute14;
    p9_a34 := ddp_x_node_rec.attribute15;
    p9_a35 := ddp_x_node_rec.operation_flag;
    p9_a36 := ddp_x_node_rec.parent_node_rec_index;
  end;

end ahl_mc_masterconfig_pub_w;

/
