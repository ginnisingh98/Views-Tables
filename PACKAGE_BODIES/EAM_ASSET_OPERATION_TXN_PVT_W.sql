--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_OPERATION_TXN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_OPERATION_TXN_PVT_W" as
  /* $Header: EAMVAORB.pls 120.4 2008/01/26 01:53:51 devijay ship $ */
  procedure insert_txn(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_txn_date  DATE
    , p_txn_type  NUMBER
    , p_instance_id  NUMBER
    , p_comments  VARCHAR2
    , p_qa_collection_id  NUMBER
    , p_operable_flag  NUMBER
    , p_employee_id  NUMBER
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_VARCHAR2_TABLE_2000
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_NUMBER_TABLE
    , p11_a13 JTF_VARCHAR2_TABLE_100
    , p11_a14 JTF_NUMBER_TABLE
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_DATE_TABLE
    , p12_a4 JTF_VARCHAR2_TABLE_100
    , p12_a5 JTF_VARCHAR2_TABLE_100
    , p12_a6 JTF_NUMBER_TABLE
    , p12_a7 JTF_NUMBER_TABLE
    , p12_a8 JTF_NUMBER_TABLE
    , p12_a9 JTF_NUMBER_TABLE
    , p12_a10 JTF_VARCHAR2_TABLE_100
    , p12_a11 JTF_VARCHAR2_TABLE_100
    , p12_a12 JTF_VARCHAR2_TABLE_100
    , p12_a13 JTF_NUMBER_TABLE
    , p12_a14 JTF_NUMBER_TABLE
    , p12_a15 JTF_VARCHAR2_TABLE_300
    , p12_a16 JTF_VARCHAR2_TABLE_100
    , p12_a17 JTF_VARCHAR2_TABLE_200
    , p12_a18 JTF_VARCHAR2_TABLE_200
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_200
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_200
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_200
    , p12_a25 JTF_VARCHAR2_TABLE_200
    , p12_a26 JTF_VARCHAR2_TABLE_200
    , p12_a27 JTF_VARCHAR2_TABLE_200
    , p12_a28 JTF_VARCHAR2_TABLE_200
    , p12_a29 JTF_VARCHAR2_TABLE_200
    , p12_a30 JTF_VARCHAR2_TABLE_200
    , p12_a31 JTF_VARCHAR2_TABLE_200
    , p12_a32 JTF_VARCHAR2_TABLE_200
    , p12_a33 JTF_VARCHAR2_TABLE_200
    , p12_a34 JTF_VARCHAR2_TABLE_200
    , p12_a35 JTF_VARCHAR2_TABLE_200
    , p12_a36 JTF_VARCHAR2_TABLE_200
    , p12_a37 JTF_VARCHAR2_TABLE_200
    , p12_a38 JTF_VARCHAR2_TABLE_200
    , p12_a39 JTF_VARCHAR2_TABLE_200
    , p12_a40 JTF_VARCHAR2_TABLE_200
    , p12_a41 JTF_VARCHAR2_TABLE_200
    , p12_a42 JTF_VARCHAR2_TABLE_200
    , p12_a43 JTF_VARCHAR2_TABLE_200
    , p12_a44 JTF_VARCHAR2_TABLE_200
    , p12_a45 JTF_VARCHAR2_TABLE_200
    , p12_a46 JTF_VARCHAR2_TABLE_200
    , p12_a47 JTF_NUMBER_TABLE
    , p12_a48 JTF_VARCHAR2_TABLE_100
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_300
    , p13_a3 JTF_DATE_TABLE
    , p13_a4 JTF_VARCHAR2_TABLE_100
    , p13_a5 JTF_VARCHAR2_TABLE_200
    , p13_a6 JTF_VARCHAR2_TABLE_200
    , p13_a7 JTF_VARCHAR2_TABLE_200
    , p13_a8 JTF_VARCHAR2_TABLE_200
    , p13_a9 JTF_VARCHAR2_TABLE_200
    , p13_a10 JTF_VARCHAR2_TABLE_200
    , p13_a11 JTF_VARCHAR2_TABLE_200
    , p13_a12 JTF_VARCHAR2_TABLE_200
    , p13_a13 JTF_VARCHAR2_TABLE_200
    , p13_a14 JTF_VARCHAR2_TABLE_200
    , p13_a15 JTF_VARCHAR2_TABLE_200
    , p13_a16 JTF_VARCHAR2_TABLE_200
    , p13_a17 JTF_VARCHAR2_TABLE_200
    , p13_a18 JTF_VARCHAR2_TABLE_200
    , p13_a19 JTF_VARCHAR2_TABLE_200
    , p13_a20 JTF_VARCHAR2_TABLE_100
    , p_attribute_category  VARCHAR2
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
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_eam_ops_quality_tbl eam_asset_operation_txn_pub.eam_quality_tbl_type;
    ddp_meter_reading_rec_tbl eam_asset_operation_txn_pub.meter_reading_rec_tbl_type;
    ddp_counter_properties_tbl eam_asset_operation_txn_pub.ctr_property_readings_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    eam_asset_operation_txn_pub_w.rosetta_table_copy_in_p2(ddp_eam_ops_quality_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      );

    eam_asset_operation_txn_pub_w.rosetta_table_copy_in_p6(ddp_meter_reading_rec_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      , p12_a27
      , p12_a28
      , p12_a29
      , p12_a30
      , p12_a31
      , p12_a32
      , p12_a33
      , p12_a34
      , p12_a35
      , p12_a36
      , p12_a37
      , p12_a38
      , p12_a39
      , p12_a40
      , p12_a41
      , p12_a42
      , p12_a43
      , p12_a44
      , p12_a45
      , p12_a46
      , p12_a47
      , p12_a48
      );

    eam_asset_operation_txn_pub_w.rosetta_table_copy_in_p4(ddp_counter_properties_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      );




















    -- here's the delegated call to the old PL/SQL routine
    eam_asset_operation_txn_pvt.insert_txn(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_txn_date,
      p_txn_type,
      p_instance_id,
      p_comments,
      p_qa_collection_id,
      p_operable_flag,
      p_employee_id,
      ddp_eam_ops_quality_tbl,
      ddp_meter_reading_rec_tbl,
      ddp_counter_properties_tbl,
      p_attribute_category,
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
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
































  end;

  procedure insert_quality_plans(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_VARCHAR2_TABLE_2000
    , p0_a9 JTF_VARCHAR2_TABLE_100
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_VARCHAR2_TABLE_100
    , p0_a14 JTF_NUMBER_TABLE
    , p_instance_id  NUMBER
    , p_txn_date  DATE
    , p_comments  VARCHAR2
    , p_operable_flag  NUMBER
    , p_organization_id  NUMBER
    , p_employee_id  NUMBER
    , p_asset_group_id  NUMBER
    , p_asset_number  VARCHAR2
    , p_asset_instance_number  VARCHAR2
    , p_txn_number  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_eam_ops_quality_tbl eam_asset_operation_txn_pub.eam_quality_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_asset_operation_txn_pub_w.rosetta_table_copy_in_p2(ddp_eam_ops_quality_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      );














    -- here's the delegated call to the old PL/SQL routine
    eam_asset_operation_txn_pvt.insert_quality_plans(ddp_eam_ops_quality_tbl,
      p_instance_id,
      p_txn_date,
      p_comments,
      p_operable_flag,
      p_organization_id,
      p_employee_id,
      p_asset_group_id,
      p_asset_number,
      p_asset_instance_number,
      p_txn_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure insert_meter_readings(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_VARCHAR2_TABLE_100
    , p0_a11 JTF_VARCHAR2_TABLE_100
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_VARCHAR2_TABLE_300
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_VARCHAR2_TABLE_200
    , p0_a38 JTF_VARCHAR2_TABLE_200
    , p0_a39 JTF_VARCHAR2_TABLE_200
    , p0_a40 JTF_VARCHAR2_TABLE_200
    , p0_a41 JTF_VARCHAR2_TABLE_200
    , p0_a42 JTF_VARCHAR2_TABLE_200
    , p0_a43 JTF_VARCHAR2_TABLE_200
    , p0_a44 JTF_VARCHAR2_TABLE_200
    , p0_a45 JTF_VARCHAR2_TABLE_200
    , p0_a46 JTF_VARCHAR2_TABLE_200
    , p0_a47 JTF_NUMBER_TABLE
    , p0_a48 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_VARCHAR2_TABLE_300
    , p1_a3 JTF_DATE_TABLE
    , p1_a4 JTF_VARCHAR2_TABLE_100
    , p1_a5 JTF_VARCHAR2_TABLE_200
    , p1_a6 JTF_VARCHAR2_TABLE_200
    , p1_a7 JTF_VARCHAR2_TABLE_200
    , p1_a8 JTF_VARCHAR2_TABLE_200
    , p1_a9 JTF_VARCHAR2_TABLE_200
    , p1_a10 JTF_VARCHAR2_TABLE_200
    , p1_a11 JTF_VARCHAR2_TABLE_200
    , p1_a12 JTF_VARCHAR2_TABLE_200
    , p1_a13 JTF_VARCHAR2_TABLE_200
    , p1_a14 JTF_VARCHAR2_TABLE_200
    , p1_a15 JTF_VARCHAR2_TABLE_200
    , p1_a16 JTF_VARCHAR2_TABLE_200
    , p1_a17 JTF_VARCHAR2_TABLE_200
    , p1_a18 JTF_VARCHAR2_TABLE_200
    , p1_a19 JTF_VARCHAR2_TABLE_200
    , p1_a20 JTF_VARCHAR2_TABLE_100
    , p_instance_id  NUMBER
    , p_txn_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_eam_meter_reading_tbl eam_asset_operation_txn_pub.meter_reading_rec_tbl_type;
    ddp_counter_properties_tbl eam_asset_operation_txn_pub.ctr_property_readings_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_asset_operation_txn_pub_w.rosetta_table_copy_in_p6(ddp_eam_meter_reading_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      );

    eam_asset_operation_txn_pub_w.rosetta_table_copy_in_p4(ddp_counter_properties_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      );






    -- here's the delegated call to the old PL/SQL routine
    eam_asset_operation_txn_pvt.insert_meter_readings(ddp_eam_meter_reading_tbl,
      ddp_counter_properties_tbl,
      p_instance_id,
      p_txn_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end eam_asset_operation_txn_pvt_w;

/
