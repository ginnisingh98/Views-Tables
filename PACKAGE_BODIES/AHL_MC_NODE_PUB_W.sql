--------------------------------------------------------
--  DDL for Package Body AHL_MC_NODE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_NODE_PUB_W" as
  /* $Header: AHLPNOWB.pls 120.1 2005/07/30 23:05 tamdas noship $ */
  procedure process_node(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy  NUMBER
    , p8_a1 in out nocopy  NUMBER
    , p8_a2 in out nocopy  NUMBER
    , p8_a3 in out nocopy  VARCHAR2
    , p8_a4 in out nocopy  VARCHAR2
    , p8_a5 in out nocopy  VARCHAR2
    , p8_a6 in out nocopy  VARCHAR2
    , p8_a7 in out nocopy  VARCHAR2
    , p8_a8 in out nocopy  VARCHAR2
    , p8_a9 in out nocopy  VARCHAR2
    , p8_a10 in out nocopy  NUMBER
    , p8_a11 in out nocopy  NUMBER
    , p8_a12 in out nocopy  NUMBER
    , p8_a13 in out nocopy  VARCHAR2
    , p8_a14 in out nocopy  NUMBER
    , p8_a15 in out nocopy  DATE
    , p8_a16 in out nocopy  DATE
    , p8_a17 in out nocopy  NUMBER
    , p8_a18 in out nocopy  NUMBER
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
    , p8_a29 in out nocopy  VARCHAR2
    , p8_a30 in out nocopy  VARCHAR2
    , p8_a31 in out nocopy  VARCHAR2
    , p8_a32 in out nocopy  VARCHAR2
    , p8_a33 in out nocopy  VARCHAR2
    , p8_a34 in out nocopy  VARCHAR2
    , p8_a35 in out nocopy  VARCHAR2
    , p8_a36 in out nocopy  NUMBER
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_200
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
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a25 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_DATE_TABLE
    , p10_a6 in out nocopy JTF_DATE_TABLE
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_NUMBER_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_node_rec ahl_mc_node_pvt.node_rec_type;
    ddp_x_counter_rules_tbl ahl_mc_node_pvt.counter_rules_tbl_type;
    ddp_x_subconfig_tbl ahl_mc_node_pvt.subconfig_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_x_node_rec.relationship_id := p8_a0;
    ddp_x_node_rec.mc_header_id := p8_a1;
    ddp_x_node_rec.position_key := p8_a2;
    ddp_x_node_rec.position_ref_code := p8_a3;
    ddp_x_node_rec.position_ref_meaning := p8_a4;
    ddp_x_node_rec.ata_code := p8_a5;
    ddp_x_node_rec.ata_meaning := p8_a6;
    ddp_x_node_rec.position_necessity_code := p8_a7;
    ddp_x_node_rec.position_necessity_meaning := p8_a8;
    ddp_x_node_rec.uom_code := p8_a9;
    ddp_x_node_rec.quantity := p8_a10;
    ddp_x_node_rec.parent_relationship_id := p8_a11;
    ddp_x_node_rec.item_group_id := p8_a12;
    ddp_x_node_rec.item_group_name := p8_a13;
    ddp_x_node_rec.display_order := p8_a14;
    ddp_x_node_rec.active_start_date := p8_a15;
    ddp_x_node_rec.active_end_date := p8_a16;
    ddp_x_node_rec.object_version_number := p8_a17;
    ddp_x_node_rec.security_group_id := p8_a18;
    ddp_x_node_rec.attribute_category := p8_a19;
    ddp_x_node_rec.attribute1 := p8_a20;
    ddp_x_node_rec.attribute2 := p8_a21;
    ddp_x_node_rec.attribute3 := p8_a22;
    ddp_x_node_rec.attribute4 := p8_a23;
    ddp_x_node_rec.attribute5 := p8_a24;
    ddp_x_node_rec.attribute6 := p8_a25;
    ddp_x_node_rec.attribute7 := p8_a26;
    ddp_x_node_rec.attribute8 := p8_a27;
    ddp_x_node_rec.attribute9 := p8_a28;
    ddp_x_node_rec.attribute10 := p8_a29;
    ddp_x_node_rec.attribute11 := p8_a30;
    ddp_x_node_rec.attribute12 := p8_a31;
    ddp_x_node_rec.attribute13 := p8_a32;
    ddp_x_node_rec.attribute14 := p8_a33;
    ddp_x_node_rec.attribute15 := p8_a34;
    ddp_x_node_rec.operation_flag := p8_a35;
    ddp_x_node_rec.parent_node_rec_index := p8_a36;

    ahl_mc_node_pvt_w.rosetta_table_copy_in_p8(ddp_x_counter_rules_tbl, p9_a0
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
      );

    ahl_mc_node_pvt_w.rosetta_table_copy_in_p10(ddp_x_subconfig_tbl, p10_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_mc_node_pub.process_node(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_node_rec,
      ddp_x_counter_rules_tbl,
      ddp_x_subconfig_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddp_x_node_rec.relationship_id;
    p8_a1 := ddp_x_node_rec.mc_header_id;
    p8_a2 := ddp_x_node_rec.position_key;
    p8_a3 := ddp_x_node_rec.position_ref_code;
    p8_a4 := ddp_x_node_rec.position_ref_meaning;
    p8_a5 := ddp_x_node_rec.ata_code;
    p8_a6 := ddp_x_node_rec.ata_meaning;
    p8_a7 := ddp_x_node_rec.position_necessity_code;
    p8_a8 := ddp_x_node_rec.position_necessity_meaning;
    p8_a9 := ddp_x_node_rec.uom_code;
    p8_a10 := ddp_x_node_rec.quantity;
    p8_a11 := ddp_x_node_rec.parent_relationship_id;
    p8_a12 := ddp_x_node_rec.item_group_id;
    p8_a13 := ddp_x_node_rec.item_group_name;
    p8_a14 := ddp_x_node_rec.display_order;
    p8_a15 := ddp_x_node_rec.active_start_date;
    p8_a16 := ddp_x_node_rec.active_end_date;
    p8_a17 := ddp_x_node_rec.object_version_number;
    p8_a18 := ddp_x_node_rec.security_group_id;
    p8_a19 := ddp_x_node_rec.attribute_category;
    p8_a20 := ddp_x_node_rec.attribute1;
    p8_a21 := ddp_x_node_rec.attribute2;
    p8_a22 := ddp_x_node_rec.attribute3;
    p8_a23 := ddp_x_node_rec.attribute4;
    p8_a24 := ddp_x_node_rec.attribute5;
    p8_a25 := ddp_x_node_rec.attribute6;
    p8_a26 := ddp_x_node_rec.attribute7;
    p8_a27 := ddp_x_node_rec.attribute8;
    p8_a28 := ddp_x_node_rec.attribute9;
    p8_a29 := ddp_x_node_rec.attribute10;
    p8_a30 := ddp_x_node_rec.attribute11;
    p8_a31 := ddp_x_node_rec.attribute12;
    p8_a32 := ddp_x_node_rec.attribute13;
    p8_a33 := ddp_x_node_rec.attribute14;
    p8_a34 := ddp_x_node_rec.attribute15;
    p8_a35 := ddp_x_node_rec.operation_flag;
    p8_a36 := ddp_x_node_rec.parent_node_rec_index;

    ahl_mc_node_pvt_w.rosetta_table_copy_out_p8(ddp_x_counter_rules_tbl, p9_a0
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
      );

    ahl_mc_node_pvt_w.rosetta_table_copy_out_p10(ddp_x_subconfig_tbl, p10_a0
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
      );
  end;

  procedure delete_nodes(p_api_version  NUMBER
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
    ahl_mc_node_pub.delete_nodes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_nodes_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ahl_mc_node_pub_w;

/
