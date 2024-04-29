--------------------------------------------------------
--  DDL for Package Body CSI_ORGANIZATION_UNIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ORGANIZATION_UNIT_PUB_W" as
  /* $Header: csipouwb.pls 120.11 2008/01/15 03:39:23 devijay ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure get_organization_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_resolve_id_columns  VARCHAR2
    , p_time_stamp  date
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_DATE_TABLE
    , p7_a6 out nocopy JTF_DATE_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ou_query_rec csi_datastructures_pub.organization_unit_query_rec;
    ddp_time_stamp date;
    ddx_org_unit_tbl csi_datastructures_pub.org_units_header_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ou_query_rec.instance_ou_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ou_query_rec.instance_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ou_query_rec.operating_unit_id := rosetta_g_miss_num_map(p4_a2);
    ddp_ou_query_rec.relationship_type_code := p4_a3;


    ddp_time_stamp := rosetta_g_miss_date_in_map(p_time_stamp);





    -- here's the delegated call to the old PL/SQL routine
    csi_organization_unit_pub.get_organization_unit(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ou_query_rec,
      p_resolve_id_columns,
      ddp_time_stamp,
      ddx_org_unit_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    csi_datastructures_pub_w.rosetta_table_copy_out_p57(ddx_org_unit_tbl, p7_a0
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
      );



  end;

  procedure create_organization_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_DATE_TABLE
    , p4_a5 in out nocopy JTF_DATE_TABLE
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_NUMBER_TABLE
    , p4_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
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
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_org_unit_tbl csi_datastructures_pub.organization_units_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p49(ddp_org_unit_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_organization_unit_pub.create_organization_unit(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_org_unit_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_out_p49(ddp_org_unit_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      );

    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

  procedure update_organization_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
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
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_org_unit_tbl csi_datastructures_pub.organization_units_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p49(ddp_org_unit_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_organization_unit_pub.update_organization_unit(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_org_unit_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

  procedure expire_organization_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
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
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_org_unit_tbl csi_datastructures_pub.organization_units_tbl;
    ddp_txn_rec csi_datastructures_pub.transaction_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    csi_datastructures_pub_w.rosetta_table_copy_in_p49(ddp_org_unit_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      );

    ddp_txn_rec.transaction_id := rosetta_g_miss_num_map(p5_a0);
    ddp_txn_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_txn_rec.source_transaction_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_txn_rec.transaction_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_txn_rec.txn_sub_type_id := rosetta_g_miss_num_map(p5_a4);
    ddp_txn_rec.source_group_ref_id := rosetta_g_miss_num_map(p5_a5);
    ddp_txn_rec.source_group_ref := p5_a6;
    ddp_txn_rec.source_header_ref_id := rosetta_g_miss_num_map(p5_a7);
    ddp_txn_rec.source_header_ref := p5_a8;
    ddp_txn_rec.source_line_ref_id := rosetta_g_miss_num_map(p5_a9);
    ddp_txn_rec.source_line_ref := p5_a10;
    ddp_txn_rec.source_dist_ref_id1 := rosetta_g_miss_num_map(p5_a11);
    ddp_txn_rec.source_dist_ref_id2 := rosetta_g_miss_num_map(p5_a12);
    ddp_txn_rec.inv_material_transaction_id := rosetta_g_miss_num_map(p5_a13);
    ddp_txn_rec.transaction_quantity := rosetta_g_miss_num_map(p5_a14);
    ddp_txn_rec.transaction_uom_code := p5_a15;
    ddp_txn_rec.transacted_by := rosetta_g_miss_num_map(p5_a16);
    ddp_txn_rec.transaction_status_code := p5_a17;
    ddp_txn_rec.transaction_action_code := p5_a18;
    ddp_txn_rec.message_id := rosetta_g_miss_num_map(p5_a19);
    ddp_txn_rec.context := p5_a20;
    ddp_txn_rec.attribute1 := p5_a21;
    ddp_txn_rec.attribute2 := p5_a22;
    ddp_txn_rec.attribute3 := p5_a23;
    ddp_txn_rec.attribute4 := p5_a24;
    ddp_txn_rec.attribute5 := p5_a25;
    ddp_txn_rec.attribute6 := p5_a26;
    ddp_txn_rec.attribute7 := p5_a27;
    ddp_txn_rec.attribute8 := p5_a28;
    ddp_txn_rec.attribute9 := p5_a29;
    ddp_txn_rec.attribute10 := p5_a30;
    ddp_txn_rec.attribute11 := p5_a31;
    ddp_txn_rec.attribute12 := p5_a32;
    ddp_txn_rec.attribute13 := p5_a33;
    ddp_txn_rec.attribute14 := p5_a34;
    ddp_txn_rec.attribute15 := p5_a35;
    ddp_txn_rec.object_version_number := rosetta_g_miss_num_map(p5_a36);
    ddp_txn_rec.split_reason_code := p5_a37;
    ddp_txn_rec.src_txn_creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_txn_rec.gl_interface_status_code := rosetta_g_miss_num_map(p5_a39);




    -- here's the delegated call to the old PL/SQL routine
    csi_organization_unit_pub.expire_organization_unit(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_org_unit_tbl,
      ddp_txn_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_id);
    p5_a1 := ddp_txn_rec.transaction_date;
    p5_a2 := ddp_txn_rec.source_transaction_date;
    p5_a3 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_type_id);
    p5_a4 := rosetta_g_miss_num_map(ddp_txn_rec.txn_sub_type_id);
    p5_a5 := rosetta_g_miss_num_map(ddp_txn_rec.source_group_ref_id);
    p5_a6 := ddp_txn_rec.source_group_ref;
    p5_a7 := rosetta_g_miss_num_map(ddp_txn_rec.source_header_ref_id);
    p5_a8 := ddp_txn_rec.source_header_ref;
    p5_a9 := rosetta_g_miss_num_map(ddp_txn_rec.source_line_ref_id);
    p5_a10 := ddp_txn_rec.source_line_ref;
    p5_a11 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id1);
    p5_a12 := rosetta_g_miss_num_map(ddp_txn_rec.source_dist_ref_id2);
    p5_a13 := rosetta_g_miss_num_map(ddp_txn_rec.inv_material_transaction_id);
    p5_a14 := rosetta_g_miss_num_map(ddp_txn_rec.transaction_quantity);
    p5_a15 := ddp_txn_rec.transaction_uom_code;
    p5_a16 := rosetta_g_miss_num_map(ddp_txn_rec.transacted_by);
    p5_a17 := ddp_txn_rec.transaction_status_code;
    p5_a18 := ddp_txn_rec.transaction_action_code;
    p5_a19 := rosetta_g_miss_num_map(ddp_txn_rec.message_id);
    p5_a20 := ddp_txn_rec.context;
    p5_a21 := ddp_txn_rec.attribute1;
    p5_a22 := ddp_txn_rec.attribute2;
    p5_a23 := ddp_txn_rec.attribute3;
    p5_a24 := ddp_txn_rec.attribute4;
    p5_a25 := ddp_txn_rec.attribute5;
    p5_a26 := ddp_txn_rec.attribute6;
    p5_a27 := ddp_txn_rec.attribute7;
    p5_a28 := ddp_txn_rec.attribute8;
    p5_a29 := ddp_txn_rec.attribute9;
    p5_a30 := ddp_txn_rec.attribute10;
    p5_a31 := ddp_txn_rec.attribute11;
    p5_a32 := ddp_txn_rec.attribute12;
    p5_a33 := ddp_txn_rec.attribute13;
    p5_a34 := ddp_txn_rec.attribute14;
    p5_a35 := ddp_txn_rec.attribute15;
    p5_a36 := rosetta_g_miss_num_map(ddp_txn_rec.object_version_number);
    p5_a37 := ddp_txn_rec.split_reason_code;
    p5_a38 := ddp_txn_rec.src_txn_creation_date;
    p5_a39 := rosetta_g_miss_num_map(ddp_txn_rec.gl_interface_status_code);



  end;

end csi_organization_unit_pub_w;

/
