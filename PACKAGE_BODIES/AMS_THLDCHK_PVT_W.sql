--------------------------------------------------------
--  DDL for Package Body AMS_THLDCHK_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_THLDCHK_PVT_W" as
  /* $Header: amswthcb.pls 115.1 2003/07/03 14:24:52 cgoyal noship $ */
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

  procedure create_thldchk(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_trigger_check_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_thldchk_rec.trigger_check_id := rosetta_g_miss_num_map(p7_a0);
    ddp_thldchk_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_thldchk_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_thldchk_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_thldchk_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_thldchk_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_thldchk_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_thldchk_rec.trigger_id := rosetta_g_miss_num_map(p7_a7);
    ddp_thldchk_rec.order_number := rosetta_g_miss_num_map(p7_a8);
    ddp_thldchk_rec.chk1_type := p7_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p7_a10;
    ddp_thldchk_rec.chk1_act_object_id := rosetta_g_miss_num_map(p7_a11);
    ddp_thldchk_rec.chk1_source_code := p7_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p7_a13);
    ddp_thldchk_rec.chk1_source_code_metric_type := p7_a14;
    ddp_thldchk_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p7_a15);
    ddp_thldchk_rec.chk1_workbook_name := p7_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p7_a17;
    ddp_thldchk_rec.chk2_type := p7_a18;
    ddp_thldchk_rec.chk2_value := rosetta_g_miss_num_map(p7_a19);
    ddp_thldchk_rec.chk2_low_value := rosetta_g_miss_num_map(p7_a20);
    ddp_thldchk_rec.chk2_high_value := rosetta_g_miss_num_map(p7_a21);
    ddp_thldchk_rec.chk2_uom_code := p7_a22;
    ddp_thldchk_rec.chk2_currency_code := p7_a23;
    ddp_thldchk_rec.chk2_source_code := p7_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p7_a25;
    ddp_thldchk_rec.chk2_act_object_id := rosetta_g_miss_num_map(p7_a26);
    ddp_thldchk_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p7_a27);
    ddp_thldchk_rec.chk2_source_code_metric_type := p7_a28;
    ddp_thldchk_rec.chk2_workbook_name := p7_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p7_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p7_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.create_thldchk(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_thldchk_rec,
      x_trigger_check_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_thldchk(p_api_version  NUMBER
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
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_thldchk_rec.trigger_check_id := rosetta_g_miss_num_map(p7_a0);
    ddp_thldchk_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_thldchk_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_thldchk_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_thldchk_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_thldchk_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_thldchk_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_thldchk_rec.trigger_id := rosetta_g_miss_num_map(p7_a7);
    ddp_thldchk_rec.order_number := rosetta_g_miss_num_map(p7_a8);
    ddp_thldchk_rec.chk1_type := p7_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p7_a10;
    ddp_thldchk_rec.chk1_act_object_id := rosetta_g_miss_num_map(p7_a11);
    ddp_thldchk_rec.chk1_source_code := p7_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p7_a13);
    ddp_thldchk_rec.chk1_source_code_metric_type := p7_a14;
    ddp_thldchk_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p7_a15);
    ddp_thldchk_rec.chk1_workbook_name := p7_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p7_a17;
    ddp_thldchk_rec.chk2_type := p7_a18;
    ddp_thldchk_rec.chk2_value := rosetta_g_miss_num_map(p7_a19);
    ddp_thldchk_rec.chk2_low_value := rosetta_g_miss_num_map(p7_a20);
    ddp_thldchk_rec.chk2_high_value := rosetta_g_miss_num_map(p7_a21);
    ddp_thldchk_rec.chk2_uom_code := p7_a22;
    ddp_thldchk_rec.chk2_currency_code := p7_a23;
    ddp_thldchk_rec.chk2_source_code := p7_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p7_a25;
    ddp_thldchk_rec.chk2_act_object_id := rosetta_g_miss_num_map(p7_a26);
    ddp_thldchk_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p7_a27);
    ddp_thldchk_rec.chk2_source_code_metric_type := p7_a28;
    ddp_thldchk_rec.chk2_workbook_name := p7_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p7_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p7_a31;

    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.update_thldchk(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_thldchk_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_thldchk(p_api_version  NUMBER
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
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_thldchk_rec.trigger_check_id := rosetta_g_miss_num_map(p6_a0);
    ddp_thldchk_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_thldchk_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_thldchk_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_thldchk_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_thldchk_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_thldchk_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_thldchk_rec.trigger_id := rosetta_g_miss_num_map(p6_a7);
    ddp_thldchk_rec.order_number := rosetta_g_miss_num_map(p6_a8);
    ddp_thldchk_rec.chk1_type := p6_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p6_a10;
    ddp_thldchk_rec.chk1_act_object_id := rosetta_g_miss_num_map(p6_a11);
    ddp_thldchk_rec.chk1_source_code := p6_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p6_a13);
    ddp_thldchk_rec.chk1_source_code_metric_type := p6_a14;
    ddp_thldchk_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p6_a15);
    ddp_thldchk_rec.chk1_workbook_name := p6_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p6_a17;
    ddp_thldchk_rec.chk2_type := p6_a18;
    ddp_thldchk_rec.chk2_value := rosetta_g_miss_num_map(p6_a19);
    ddp_thldchk_rec.chk2_low_value := rosetta_g_miss_num_map(p6_a20);
    ddp_thldchk_rec.chk2_high_value := rosetta_g_miss_num_map(p6_a21);
    ddp_thldchk_rec.chk2_uom_code := p6_a22;
    ddp_thldchk_rec.chk2_currency_code := p6_a23;
    ddp_thldchk_rec.chk2_source_code := p6_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p6_a25;
    ddp_thldchk_rec.chk2_act_object_id := rosetta_g_miss_num_map(p6_a26);
    ddp_thldchk_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p6_a27);
    ddp_thldchk_rec.chk2_source_code_metric_type := p6_a28;
    ddp_thldchk_rec.chk2_workbook_name := p6_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p6_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p6_a31;

    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.validate_thldchk(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_thldchk_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_thldchk_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_thldchk_rec.trigger_check_id := rosetta_g_miss_num_map(p0_a0);
    ddp_thldchk_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_thldchk_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_thldchk_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_thldchk_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_thldchk_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_thldchk_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_thldchk_rec.trigger_id := rosetta_g_miss_num_map(p0_a7);
    ddp_thldchk_rec.order_number := rosetta_g_miss_num_map(p0_a8);
    ddp_thldchk_rec.chk1_type := p0_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p0_a10;
    ddp_thldchk_rec.chk1_act_object_id := rosetta_g_miss_num_map(p0_a11);
    ddp_thldchk_rec.chk1_source_code := p0_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p0_a13);
    ddp_thldchk_rec.chk1_source_code_metric_type := p0_a14;
    ddp_thldchk_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p0_a15);
    ddp_thldchk_rec.chk1_workbook_name := p0_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p0_a17;
    ddp_thldchk_rec.chk2_type := p0_a18;
    ddp_thldchk_rec.chk2_value := rosetta_g_miss_num_map(p0_a19);
    ddp_thldchk_rec.chk2_low_value := rosetta_g_miss_num_map(p0_a20);
    ddp_thldchk_rec.chk2_high_value := rosetta_g_miss_num_map(p0_a21);
    ddp_thldchk_rec.chk2_uom_code := p0_a22;
    ddp_thldchk_rec.chk2_currency_code := p0_a23;
    ddp_thldchk_rec.chk2_source_code := p0_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p0_a25;
    ddp_thldchk_rec.chk2_act_object_id := rosetta_g_miss_num_map(p0_a26);
    ddp_thldchk_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p0_a27);
    ddp_thldchk_rec.chk2_source_code_metric_type := p0_a28;
    ddp_thldchk_rec.chk2_workbook_name := p0_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p0_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p0_a31;



    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.check_thldchk_items(ddp_thldchk_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_thldchk_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  NUMBER := 0-1962.0724
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  NUMBER := 0-1962.0724
    , p1_a21  NUMBER := 0-1962.0724
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  NUMBER := 0-1962.0724
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddp_complete_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_thldchk_rec.trigger_check_id := rosetta_g_miss_num_map(p0_a0);
    ddp_thldchk_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_thldchk_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_thldchk_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_thldchk_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_thldchk_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_thldchk_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_thldchk_rec.trigger_id := rosetta_g_miss_num_map(p0_a7);
    ddp_thldchk_rec.order_number := rosetta_g_miss_num_map(p0_a8);
    ddp_thldchk_rec.chk1_type := p0_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p0_a10;
    ddp_thldchk_rec.chk1_act_object_id := rosetta_g_miss_num_map(p0_a11);
    ddp_thldchk_rec.chk1_source_code := p0_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p0_a13);
    ddp_thldchk_rec.chk1_source_code_metric_type := p0_a14;
    ddp_thldchk_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p0_a15);
    ddp_thldchk_rec.chk1_workbook_name := p0_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p0_a17;
    ddp_thldchk_rec.chk2_type := p0_a18;
    ddp_thldchk_rec.chk2_value := rosetta_g_miss_num_map(p0_a19);
    ddp_thldchk_rec.chk2_low_value := rosetta_g_miss_num_map(p0_a20);
    ddp_thldchk_rec.chk2_high_value := rosetta_g_miss_num_map(p0_a21);
    ddp_thldchk_rec.chk2_uom_code := p0_a22;
    ddp_thldchk_rec.chk2_currency_code := p0_a23;
    ddp_thldchk_rec.chk2_source_code := p0_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p0_a25;
    ddp_thldchk_rec.chk2_act_object_id := rosetta_g_miss_num_map(p0_a26);
    ddp_thldchk_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p0_a27);
    ddp_thldchk_rec.chk2_source_code_metric_type := p0_a28;
    ddp_thldchk_rec.chk2_workbook_name := p0_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p0_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p0_a31;

    ddp_complete_rec.trigger_check_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.trigger_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.order_number := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.chk1_type := p1_a9;
    ddp_complete_rec.chk1_arc_source_code_from := p1_a10;
    ddp_complete_rec.chk1_act_object_id := rosetta_g_miss_num_map(p1_a11);
    ddp_complete_rec.chk1_source_code := p1_a12;
    ddp_complete_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.chk1_source_code_metric_type := p1_a14;
    ddp_complete_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.chk1_workbook_name := p1_a16;
    ddp_complete_rec.chk1_to_chk2_operator_type := p1_a17;
    ddp_complete_rec.chk2_type := p1_a18;
    ddp_complete_rec.chk2_value := rosetta_g_miss_num_map(p1_a19);
    ddp_complete_rec.chk2_low_value := rosetta_g_miss_num_map(p1_a20);
    ddp_complete_rec.chk2_high_value := rosetta_g_miss_num_map(p1_a21);
    ddp_complete_rec.chk2_uom_code := p1_a22;
    ddp_complete_rec.chk2_currency_code := p1_a23;
    ddp_complete_rec.chk2_source_code := p1_a24;
    ddp_complete_rec.chk2_arc_source_code_from := p1_a25;
    ddp_complete_rec.chk2_act_object_id := rosetta_g_miss_num_map(p1_a26);
    ddp_complete_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p1_a27);
    ddp_complete_rec.chk2_source_code_metric_type := p1_a28;
    ddp_complete_rec.chk2_workbook_name := p1_a29;
    ddp_complete_rec.chk2_workbook_owner := p1_a30;
    ddp_complete_rec.chk2_worksheet_name := p1_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.check_thldchk_record(ddp_thldchk_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_thldchk_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
  )

  as
    ddx_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.init_thldchk_rec(ddx_thldchk_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_thldchk_rec.trigger_check_id);
    p0_a1 := ddx_thldchk_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_thldchk_rec.last_updated_by);
    p0_a3 := ddx_thldchk_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_thldchk_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_thldchk_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_thldchk_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_thldchk_rec.trigger_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_thldchk_rec.order_number);
    p0_a9 := ddx_thldchk_rec.chk1_type;
    p0_a10 := ddx_thldchk_rec.chk1_arc_source_code_from;
    p0_a11 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk1_act_object_id);
    p0_a12 := ddx_thldchk_rec.chk1_source_code;
    p0_a13 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk1_source_code_metric_id);
    p0_a14 := ddx_thldchk_rec.chk1_source_code_metric_type;
    p0_a15 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk1_workbook_owner);
    p0_a16 := ddx_thldchk_rec.chk1_workbook_name;
    p0_a17 := ddx_thldchk_rec.chk1_to_chk2_operator_type;
    p0_a18 := ddx_thldchk_rec.chk2_type;
    p0_a19 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk2_value);
    p0_a20 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk2_low_value);
    p0_a21 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk2_high_value);
    p0_a22 := ddx_thldchk_rec.chk2_uom_code;
    p0_a23 := ddx_thldchk_rec.chk2_currency_code;
    p0_a24 := ddx_thldchk_rec.chk2_source_code;
    p0_a25 := ddx_thldchk_rec.chk2_arc_source_code_from;
    p0_a26 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk2_act_object_id);
    p0_a27 := rosetta_g_miss_num_map(ddx_thldchk_rec.chk2_source_code_metric_id);
    p0_a28 := ddx_thldchk_rec.chk2_source_code_metric_type;
    p0_a29 := ddx_thldchk_rec.chk2_workbook_name;
    p0_a30 := ddx_thldchk_rec.chk2_workbook_owner;
    p0_a31 := ddx_thldchk_rec.chk2_worksheet_name;
  end;

  procedure complete_thldchk_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_thldchk_rec ams_thldchk_pvt.thldchk_rec_type;
    ddx_complete_rec ams_thldchk_pvt.thldchk_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_thldchk_rec.trigger_check_id := rosetta_g_miss_num_map(p0_a0);
    ddp_thldchk_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_thldchk_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_thldchk_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_thldchk_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_thldchk_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_thldchk_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_thldchk_rec.trigger_id := rosetta_g_miss_num_map(p0_a7);
    ddp_thldchk_rec.order_number := rosetta_g_miss_num_map(p0_a8);
    ddp_thldchk_rec.chk1_type := p0_a9;
    ddp_thldchk_rec.chk1_arc_source_code_from := p0_a10;
    ddp_thldchk_rec.chk1_act_object_id := rosetta_g_miss_num_map(p0_a11);
    ddp_thldchk_rec.chk1_source_code := p0_a12;
    ddp_thldchk_rec.chk1_source_code_metric_id := rosetta_g_miss_num_map(p0_a13);
    ddp_thldchk_rec.chk1_source_code_metric_type := p0_a14;
    ddp_thldchk_rec.chk1_workbook_owner := rosetta_g_miss_num_map(p0_a15);
    ddp_thldchk_rec.chk1_workbook_name := p0_a16;
    ddp_thldchk_rec.chk1_to_chk2_operator_type := p0_a17;
    ddp_thldchk_rec.chk2_type := p0_a18;
    ddp_thldchk_rec.chk2_value := rosetta_g_miss_num_map(p0_a19);
    ddp_thldchk_rec.chk2_low_value := rosetta_g_miss_num_map(p0_a20);
    ddp_thldchk_rec.chk2_high_value := rosetta_g_miss_num_map(p0_a21);
    ddp_thldchk_rec.chk2_uom_code := p0_a22;
    ddp_thldchk_rec.chk2_currency_code := p0_a23;
    ddp_thldchk_rec.chk2_source_code := p0_a24;
    ddp_thldchk_rec.chk2_arc_source_code_from := p0_a25;
    ddp_thldchk_rec.chk2_act_object_id := rosetta_g_miss_num_map(p0_a26);
    ddp_thldchk_rec.chk2_source_code_metric_id := rosetta_g_miss_num_map(p0_a27);
    ddp_thldchk_rec.chk2_source_code_metric_type := p0_a28;
    ddp_thldchk_rec.chk2_workbook_name := p0_a29;
    ddp_thldchk_rec.chk2_workbook_owner := p0_a30;
    ddp_thldchk_rec.chk2_worksheet_name := p0_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_thldchk_pvt.complete_thldchk_rec(ddp_thldchk_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.trigger_check_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.trigger_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.order_number);
    p1_a9 := ddx_complete_rec.chk1_type;
    p1_a10 := ddx_complete_rec.chk1_arc_source_code_from;
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.chk1_act_object_id);
    p1_a12 := ddx_complete_rec.chk1_source_code;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.chk1_source_code_metric_id);
    p1_a14 := ddx_complete_rec.chk1_source_code_metric_type;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.chk1_workbook_owner);
    p1_a16 := ddx_complete_rec.chk1_workbook_name;
    p1_a17 := ddx_complete_rec.chk1_to_chk2_operator_type;
    p1_a18 := ddx_complete_rec.chk2_type;
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.chk2_value);
    p1_a20 := rosetta_g_miss_num_map(ddx_complete_rec.chk2_low_value);
    p1_a21 := rosetta_g_miss_num_map(ddx_complete_rec.chk2_high_value);
    p1_a22 := ddx_complete_rec.chk2_uom_code;
    p1_a23 := ddx_complete_rec.chk2_currency_code;
    p1_a24 := ddx_complete_rec.chk2_source_code;
    p1_a25 := ddx_complete_rec.chk2_arc_source_code_from;
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.chk2_act_object_id);
    p1_a27 := rosetta_g_miss_num_map(ddx_complete_rec.chk2_source_code_metric_id);
    p1_a28 := ddx_complete_rec.chk2_source_code_metric_type;
    p1_a29 := ddx_complete_rec.chk2_workbook_name;
    p1_a30 := ddx_complete_rec.chk2_workbook_owner;
    p1_a31 := ddx_complete_rec.chk2_worksheet_name;
  end;

end ams_thldchk_pvt_w;

/
