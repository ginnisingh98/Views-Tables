--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_PVT_W" as
  /* $Header: amswmtcb.pls 120.1 2005/08/24 23:10 dmvincen noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure create_metric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_metric_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_rec ams_metric_pvt.metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_metric_rec.metric_id := rosetta_g_miss_num_map(p7_a0);
    ddp_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_metric_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_metric_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_metric_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_metric_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_metric_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_metric_rec.application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_metric_rec.arc_metric_used_for_object := p7_a8;
    ddp_metric_rec.metric_calculation_type := p7_a9;
    ddp_metric_rec.metric_category := rosetta_g_miss_num_map(p7_a10);
    ddp_metric_rec.accrual_type := p7_a11;
    ddp_metric_rec.value_type := p7_a12;
    ddp_metric_rec.sensitive_data_flag := p7_a13;
    ddp_metric_rec.enabled_flag := p7_a14;
    ddp_metric_rec.metric_sub_category := rosetta_g_miss_num_map(p7_a15);
    ddp_metric_rec.function_name := p7_a16;
    ddp_metric_rec.metric_parent_id := rosetta_g_miss_num_map(p7_a17);
    ddp_metric_rec.summary_metric_id := rosetta_g_miss_num_map(p7_a18);
    ddp_metric_rec.compute_using_function := p7_a19;
    ddp_metric_rec.default_uom_code := p7_a20;
    ddp_metric_rec.uom_type := p7_a21;
    ddp_metric_rec.formula := p7_a22;
    ddp_metric_rec.metrics_name := p7_a23;
    ddp_metric_rec.description := p7_a24;
    ddp_metric_rec.formula_display := p7_a25;
    ddp_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p7_a26);
    ddp_metric_rec.set_function_name := p7_a27;
    ddp_metric_rec.display_type := p7_a28;
    ddp_metric_rec.target_type := p7_a29;
    ddp_metric_rec.denorm_code := p7_a30;


    -- here's the delegated call to the old PL/SQL routine
    ams_metric_pvt.create_metric(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_metric_rec,
      x_metric_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_metric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_rec ams_metric_pvt.metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_metric_rec.metric_id := rosetta_g_miss_num_map(p7_a0);
    ddp_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_metric_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_metric_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_metric_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_metric_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_metric_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_metric_rec.application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_metric_rec.arc_metric_used_for_object := p7_a8;
    ddp_metric_rec.metric_calculation_type := p7_a9;
    ddp_metric_rec.metric_category := rosetta_g_miss_num_map(p7_a10);
    ddp_metric_rec.accrual_type := p7_a11;
    ddp_metric_rec.value_type := p7_a12;
    ddp_metric_rec.sensitive_data_flag := p7_a13;
    ddp_metric_rec.enabled_flag := p7_a14;
    ddp_metric_rec.metric_sub_category := rosetta_g_miss_num_map(p7_a15);
    ddp_metric_rec.function_name := p7_a16;
    ddp_metric_rec.metric_parent_id := rosetta_g_miss_num_map(p7_a17);
    ddp_metric_rec.summary_metric_id := rosetta_g_miss_num_map(p7_a18);
    ddp_metric_rec.compute_using_function := p7_a19;
    ddp_metric_rec.default_uom_code := p7_a20;
    ddp_metric_rec.uom_type := p7_a21;
    ddp_metric_rec.formula := p7_a22;
    ddp_metric_rec.metrics_name := p7_a23;
    ddp_metric_rec.description := p7_a24;
    ddp_metric_rec.formula_display := p7_a25;
    ddp_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p7_a26);
    ddp_metric_rec.set_function_name := p7_a27;
    ddp_metric_rec.display_type := p7_a28;
    ddp_metric_rec.target_type := p7_a29;
    ddp_metric_rec.denorm_code := p7_a30;

    -- here's the delegated call to the old PL/SQL routine
    ams_metric_pvt.update_metric(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_metric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_rec ams_metric_pvt.metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_metric_rec.metric_id := rosetta_g_miss_num_map(p6_a0);
    ddp_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_metric_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_metric_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_metric_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_metric_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_metric_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_metric_rec.application_id := rosetta_g_miss_num_map(p6_a7);
    ddp_metric_rec.arc_metric_used_for_object := p6_a8;
    ddp_metric_rec.metric_calculation_type := p6_a9;
    ddp_metric_rec.metric_category := rosetta_g_miss_num_map(p6_a10);
    ddp_metric_rec.accrual_type := p6_a11;
    ddp_metric_rec.value_type := p6_a12;
    ddp_metric_rec.sensitive_data_flag := p6_a13;
    ddp_metric_rec.enabled_flag := p6_a14;
    ddp_metric_rec.metric_sub_category := rosetta_g_miss_num_map(p6_a15);
    ddp_metric_rec.function_name := p6_a16;
    ddp_metric_rec.metric_parent_id := rosetta_g_miss_num_map(p6_a17);
    ddp_metric_rec.summary_metric_id := rosetta_g_miss_num_map(p6_a18);
    ddp_metric_rec.compute_using_function := p6_a19;
    ddp_metric_rec.default_uom_code := p6_a20;
    ddp_metric_rec.uom_type := p6_a21;
    ddp_metric_rec.formula := p6_a22;
    ddp_metric_rec.metrics_name := p6_a23;
    ddp_metric_rec.description := p6_a24;
    ddp_metric_rec.formula_display := p6_a25;
    ddp_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p6_a26);
    ddp_metric_rec.set_function_name := p6_a27;
    ddp_metric_rec.display_type := p6_a28;
    ddp_metric_rec.target_type := p6_a29;
    ddp_metric_rec.denorm_code := p6_a30;

    -- here's the delegated call to the old PL/SQL routine
    ams_metric_pvt.validate_metric(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_metric_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_rec ams_metric_pvt.metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_metric_rec.metric_id := rosetta_g_miss_num_map(p0_a0);
    ddp_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_metric_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_metric_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_metric_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_metric_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_metric_rec.application_id := rosetta_g_miss_num_map(p0_a7);
    ddp_metric_rec.arc_metric_used_for_object := p0_a8;
    ddp_metric_rec.metric_calculation_type := p0_a9;
    ddp_metric_rec.metric_category := rosetta_g_miss_num_map(p0_a10);
    ddp_metric_rec.accrual_type := p0_a11;
    ddp_metric_rec.value_type := p0_a12;
    ddp_metric_rec.sensitive_data_flag := p0_a13;
    ddp_metric_rec.enabled_flag := p0_a14;
    ddp_metric_rec.metric_sub_category := rosetta_g_miss_num_map(p0_a15);
    ddp_metric_rec.function_name := p0_a16;
    ddp_metric_rec.metric_parent_id := rosetta_g_miss_num_map(p0_a17);
    ddp_metric_rec.summary_metric_id := rosetta_g_miss_num_map(p0_a18);
    ddp_metric_rec.compute_using_function := p0_a19;
    ddp_metric_rec.default_uom_code := p0_a20;
    ddp_metric_rec.uom_type := p0_a21;
    ddp_metric_rec.formula := p0_a22;
    ddp_metric_rec.metrics_name := p0_a23;
    ddp_metric_rec.description := p0_a24;
    ddp_metric_rec.formula_display := p0_a25;
    ddp_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p0_a26);
    ddp_metric_rec.set_function_name := p0_a27;
    ddp_metric_rec.display_type := p0_a28;
    ddp_metric_rec.target_type := p0_a29;
    ddp_metric_rec.denorm_code := p0_a30;



    -- here's the delegated call to the old PL/SQL routine
    ams_metric_pvt.validate_metric_items(ddp_metric_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_metric_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  NUMBER := 0-1962.0724
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_metric_rec ams_metric_pvt.metric_rec_type;
    ddp_complete_rec ams_metric_pvt.metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_metric_rec.metric_id := rosetta_g_miss_num_map(p0_a0);
    ddp_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_metric_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_metric_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_metric_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_metric_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_metric_rec.application_id := rosetta_g_miss_num_map(p0_a7);
    ddp_metric_rec.arc_metric_used_for_object := p0_a8;
    ddp_metric_rec.metric_calculation_type := p0_a9;
    ddp_metric_rec.metric_category := rosetta_g_miss_num_map(p0_a10);
    ddp_metric_rec.accrual_type := p0_a11;
    ddp_metric_rec.value_type := p0_a12;
    ddp_metric_rec.sensitive_data_flag := p0_a13;
    ddp_metric_rec.enabled_flag := p0_a14;
    ddp_metric_rec.metric_sub_category := rosetta_g_miss_num_map(p0_a15);
    ddp_metric_rec.function_name := p0_a16;
    ddp_metric_rec.metric_parent_id := rosetta_g_miss_num_map(p0_a17);
    ddp_metric_rec.summary_metric_id := rosetta_g_miss_num_map(p0_a18);
    ddp_metric_rec.compute_using_function := p0_a19;
    ddp_metric_rec.default_uom_code := p0_a20;
    ddp_metric_rec.uom_type := p0_a21;
    ddp_metric_rec.formula := p0_a22;
    ddp_metric_rec.metrics_name := p0_a23;
    ddp_metric_rec.description := p0_a24;
    ddp_metric_rec.formula_display := p0_a25;
    ddp_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p0_a26);
    ddp_metric_rec.set_function_name := p0_a27;
    ddp_metric_rec.display_type := p0_a28;
    ddp_metric_rec.target_type := p0_a29;
    ddp_metric_rec.denorm_code := p0_a30;

    ddp_complete_rec.metric_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.arc_metric_used_for_object := p1_a8;
    ddp_complete_rec.metric_calculation_type := p1_a9;
    ddp_complete_rec.metric_category := rosetta_g_miss_num_map(p1_a10);
    ddp_complete_rec.accrual_type := p1_a11;
    ddp_complete_rec.value_type := p1_a12;
    ddp_complete_rec.sensitive_data_flag := p1_a13;
    ddp_complete_rec.enabled_flag := p1_a14;
    ddp_complete_rec.metric_sub_category := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.function_name := p1_a16;
    ddp_complete_rec.metric_parent_id := rosetta_g_miss_num_map(p1_a17);
    ddp_complete_rec.summary_metric_id := rosetta_g_miss_num_map(p1_a18);
    ddp_complete_rec.compute_using_function := p1_a19;
    ddp_complete_rec.default_uom_code := p1_a20;
    ddp_complete_rec.uom_type := p1_a21;
    ddp_complete_rec.formula := p1_a22;
    ddp_complete_rec.metrics_name := p1_a23;
    ddp_complete_rec.description := p1_a24;
    ddp_complete_rec.formula_display := p1_a25;
    ddp_complete_rec.hierarchy_id := rosetta_g_miss_num_map(p1_a26);
    ddp_complete_rec.set_function_name := p1_a27;
    ddp_complete_rec.display_type := p1_a28;
    ddp_complete_rec.target_type := p1_a29;
    ddp_complete_rec.denorm_code := p1_a30;


    -- here's the delegated call to the old PL/SQL routine
    ams_metric_pvt.validate_metric_record(ddp_metric_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

end ams_metric_pvt_w;

/
