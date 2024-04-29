--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_EST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_EST_PUB_W" as
  /* $Header: EAMPCEWB.pls 120.0.12010000.3 2009/01/03 00:08:14 devijay noship $ */
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

  procedure explode_initial_estimate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_estimate_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_ce_msg_tbl eam_est_datastructures_pub.eam_ce_message_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.explode_initial_estimate(p_api_version,
      p_init_msg_list,
      p_commit,
      p_estimate_id,
      ddx_ce_msg_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    eam_est_datastructures_pub_w.rosetta_table_copy_out_p3(ddx_ce_msg_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      );



  end;

  procedure insert_all_wo_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_estimate_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_300
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_DATE_TABLE
    , p4_a16 JTF_DATE_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_NUMBER_TABLE
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_VARCHAR2_TABLE_300
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_4000
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_NUMBER_TABLE
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_NUMBER_TABLE
    , p4_a35 JTF_NUMBER_TABLE
    , p4_a36 JTF_NUMBER_TABLE
    , p4_a37 JTF_NUMBER_TABLE
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_NUMBER_TABLE
    , p4_a41 JTF_VARCHAR2_TABLE_300
    , p4_a42 JTF_NUMBER_TABLE
    , p4_a43 JTF_VARCHAR2_TABLE_100
    , p4_a44 JTF_NUMBER_TABLE
    , p4_a45 JTF_NUMBER_TABLE
    , p4_a46 JTF_NUMBER_TABLE
    , p4_a47 JTF_VARCHAR2_TABLE_100
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_NUMBER_TABLE
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_VARCHAR2_TABLE_300
    , p4_a52 JTF_NUMBER_TABLE
    , p4_a53 JTF_VARCHAR2_TABLE_100
    , p4_a54 JTF_DATE_TABLE
    , p4_a55 JTF_NUMBER_TABLE
    , p4_a56 JTF_NUMBER_TABLE
    , p4_a57 JTF_NUMBER_TABLE
    , p4_a58 JTF_NUMBER_TABLE
    , p4_a59 JTF_VARCHAR2_TABLE_300
    , p4_a60 JTF_NUMBER_TABLE
    , p4_a61 JTF_NUMBER_TABLE
    , p4_a62 JTF_NUMBER_TABLE
    , p4_a63 JTF_NUMBER_TABLE
    , p4_a64 JTF_NUMBER_TABLE
    , p4_a65 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_eam_ce_wo_lines_tbl eam_est_datastructures_pub.eam_ce_work_order_lines_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    eam_est_datastructures_pub_w.rosetta_table_copy_in_p13(ddp_eam_ce_wo_lines_tbl, p4_a0
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
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      );




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.insert_all_wo_lines(p_api_version,
      p_init_msg_list,
      p_commit,
      p_estimate_id,
      ddp_eam_ce_wo_lines_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure insert_parent_wo_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_estimate_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
  )

  as
    ddp_parent_wo_line_rec eam_est_datastructures_pub.eam_ce_parent_wo_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_parent_wo_line_rec.estimate_id := rosetta_g_miss_num_map(p4_a0);
    ddp_parent_wo_line_rec.parent_work_order_number := p4_a1;
    ddp_parent_wo_line_rec.organization_id := rosetta_g_miss_num_map(p4_a2);
    ddp_parent_wo_line_rec.asset_group_id := rosetta_g_miss_num_map(p4_a3);
    ddp_parent_wo_line_rec.asset_number := p4_a4;
    ddp_parent_wo_line_rec.maintenance_object_id := rosetta_g_miss_num_map(p4_a5);
    ddp_parent_wo_line_rec.maintenance_object_type := rosetta_g_miss_num_map(p4_a6);
    ddp_parent_wo_line_rec.maintenance_object_source := rosetta_g_miss_num_map(p4_a7);
    ddp_parent_wo_line_rec.work_order_description := p4_a8;
    ddp_parent_wo_line_rec.acct_class_code := p4_a9;
    ddp_parent_wo_line_rec.project_id := rosetta_g_miss_num_map(p4_a10);
    ddp_parent_wo_line_rec.task_id := rosetta_g_miss_num_map(p4_a11);
    ddp_parent_wo_line_rec.scheduled_start_date := rosetta_g_miss_date_in_map(p4_a12);
    ddp_parent_wo_line_rec.scheduled_completion_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_parent_wo_line_rec.status_type := rosetta_g_miss_num_map(p4_a14);
    ddp_parent_wo_line_rec.create_parent_flag := p4_a15;
    ddp_parent_wo_line_rec.owning_department_id := rosetta_g_miss_num_map(p4_a16);




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.insert_parent_wo_line(p_api_version,
      p_init_msg_list,
      p_commit,
      p_estimate_id,
      ddp_parent_wo_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_cu_recs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_org_id  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_cu_tbl eam_est_datastructures_pub.eam_construction_units_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    eam_est_datastructures_pub_w.rosetta_table_copy_in_p9(ddpx_cu_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      );




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.get_cu_recs(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_org_id,
      ddpx_cu_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    eam_est_datastructures_pub_w.rosetta_table_copy_out_p9(ddpx_cu_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      );



  end;

  procedure get_cu_activities(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_cu_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_activities_tbl eam_est_datastructures_pub.eam_estimate_associations_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.get_cu_activities(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_cu_id,
      ddx_activities_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    eam_est_datastructures_pub_w.rosetta_table_copy_out_p11(ddx_activities_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      );



  end;

  procedure create_estimate(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_estimate_rec eam_est_datastructures_pub.eam_construction_estimate_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddpx_estimate_rec.estimate_id := rosetta_g_miss_num_map(p4_a0);
    ddpx_estimate_rec.organization_id := rosetta_g_miss_num_map(p4_a1);
    ddpx_estimate_rec.estimate_number := p4_a2;
    ddpx_estimate_rec.estimate_description := p4_a3;
    ddpx_estimate_rec.grouping_option := rosetta_g_miss_num_map(p4_a4);
    ddpx_estimate_rec.parent_wo_id := rosetta_g_miss_num_map(p4_a5);
    ddpx_estimate_rec.create_parent_wo_flag := p4_a6;
    ddpx_estimate_rec.attribute_category := p4_a7;
    ddpx_estimate_rec.attribute1 := p4_a8;
    ddpx_estimate_rec.attribute2 := p4_a9;
    ddpx_estimate_rec.attribute3 := p4_a10;
    ddpx_estimate_rec.attribute4 := p4_a11;
    ddpx_estimate_rec.attribute5 := p4_a12;
    ddpx_estimate_rec.attribute6 := p4_a13;
    ddpx_estimate_rec.attribute7 := p4_a14;
    ddpx_estimate_rec.attribute8 := p4_a15;
    ddpx_estimate_rec.attribute9 := p4_a16;
    ddpx_estimate_rec.attribute10 := p4_a17;
    ddpx_estimate_rec.attribute11 := p4_a18;
    ddpx_estimate_rec.attribute12 := p4_a19;
    ddpx_estimate_rec.attribute13 := p4_a20;
    ddpx_estimate_rec.attribute14 := p4_a21;
    ddpx_estimate_rec.attribute15 := p4_a22;




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.create_estimate(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddpx_estimate_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddpx_estimate_rec.estimate_id);
    p4_a1 := rosetta_g_miss_num_map(ddpx_estimate_rec.organization_id);
    p4_a2 := ddpx_estimate_rec.estimate_number;
    p4_a3 := ddpx_estimate_rec.estimate_description;
    p4_a4 := rosetta_g_miss_num_map(ddpx_estimate_rec.grouping_option);
    p4_a5 := rosetta_g_miss_num_map(ddpx_estimate_rec.parent_wo_id);
    p4_a6 := ddpx_estimate_rec.create_parent_wo_flag;
    p4_a7 := ddpx_estimate_rec.attribute_category;
    p4_a8 := ddpx_estimate_rec.attribute1;
    p4_a9 := ddpx_estimate_rec.attribute2;
    p4_a10 := ddpx_estimate_rec.attribute3;
    p4_a11 := ddpx_estimate_rec.attribute4;
    p4_a12 := ddpx_estimate_rec.attribute5;
    p4_a13 := ddpx_estimate_rec.attribute6;
    p4_a14 := ddpx_estimate_rec.attribute7;
    p4_a15 := ddpx_estimate_rec.attribute8;
    p4_a16 := ddpx_estimate_rec.attribute9;
    p4_a17 := ddpx_estimate_rec.attribute10;
    p4_a18 := ddpx_estimate_rec.attribute11;
    p4_a19 := ddpx_estimate_rec.attribute12;
    p4_a20 := ddpx_estimate_rec.attribute13;
    p4_a21 := ddpx_estimate_rec.attribute14;
    p4_a22 := ddpx_estimate_rec.attribute15;



  end;

  procedure update_estimate(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_estimate_rec eam_est_datastructures_pub.eam_construction_estimate_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_estimate_rec.estimate_id := rosetta_g_miss_num_map(p4_a0);
    ddp_estimate_rec.organization_id := rosetta_g_miss_num_map(p4_a1);
    ddp_estimate_rec.estimate_number := p4_a2;
    ddp_estimate_rec.estimate_description := p4_a3;
    ddp_estimate_rec.grouping_option := rosetta_g_miss_num_map(p4_a4);
    ddp_estimate_rec.parent_wo_id := rosetta_g_miss_num_map(p4_a5);
    ddp_estimate_rec.create_parent_wo_flag := p4_a6;
    ddp_estimate_rec.attribute_category := p4_a7;
    ddp_estimate_rec.attribute1 := p4_a8;
    ddp_estimate_rec.attribute2 := p4_a9;
    ddp_estimate_rec.attribute3 := p4_a10;
    ddp_estimate_rec.attribute4 := p4_a11;
    ddp_estimate_rec.attribute5 := p4_a12;
    ddp_estimate_rec.attribute6 := p4_a13;
    ddp_estimate_rec.attribute7 := p4_a14;
    ddp_estimate_rec.attribute8 := p4_a15;
    ddp_estimate_rec.attribute9 := p4_a16;
    ddp_estimate_rec.attribute10 := p4_a17;
    ddp_estimate_rec.attribute11 := p4_a18;
    ddp_estimate_rec.attribute12 := p4_a19;
    ddp_estimate_rec.attribute13 := p4_a20;
    ddp_estimate_rec.attribute14 := p4_a21;
    ddp_estimate_rec.attribute15 := p4_a22;




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.update_estimate(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_estimate_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure set_activities_for_ce(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_ce_id  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_activities_tbl eam_est_datastructures_pub.eam_estimate_associations_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    eam_est_datastructures_pub_w.rosetta_table_copy_in_p11(ddpx_activities_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      );




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.set_activities_for_ce(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_ce_id,
      ddpx_activities_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    eam_est_datastructures_pub_w.rosetta_table_copy_out_p11(ddpx_activities_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      );



  end;

  procedure update_ce_wo_lns_by_group_opt(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  NUMBER := 0-1962.0724
  )

  as
    ddp_ce_wo_defaults eam_est_datastructures_pub.eam_ce_wo_defaults_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ce_wo_defaults.estimate_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ce_wo_defaults.default_work_order_number := p4_a1;
    ddp_ce_wo_defaults.organization_id := rosetta_g_miss_num_map(p4_a2);
    ddp_ce_wo_defaults.asset_group_id := rosetta_g_miss_num_map(p4_a3);
    ddp_ce_wo_defaults.asset_number := p4_a4;
    ddp_ce_wo_defaults.maintenance_object_id := rosetta_g_miss_num_map(p4_a5);
    ddp_ce_wo_defaults.maintenance_object_type := rosetta_g_miss_num_map(p4_a6);
    ddp_ce_wo_defaults.maintenance_object_source := rosetta_g_miss_num_map(p4_a7);
    ddp_ce_wo_defaults.work_order_description := p4_a8;
    ddp_ce_wo_defaults.acct_class_code := p4_a9;
    ddp_ce_wo_defaults.project_id := rosetta_g_miss_num_map(p4_a10);
    ddp_ce_wo_defaults.task_id := rosetta_g_miss_num_map(p4_a11);
    ddp_ce_wo_defaults.scheduled_start_date := rosetta_g_miss_date_in_map(p4_a12);
    ddp_ce_wo_defaults.scheduled_completion_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_ce_wo_defaults.user_defined_status_id := rosetta_g_miss_num_map(p4_a14);
    ddp_ce_wo_defaults.grouping_option := rosetta_g_miss_num_map(p4_a15);




    -- here's the delegated call to the old PL/SQL routine
    eam_construction_est_pub.update_ce_wo_lns_by_group_opt(p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      ddp_ce_wo_defaults,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end eam_construction_est_pub_w;

/
