--------------------------------------------------------
--  DDL for Package Body AMS_TRIG_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRIG_PVT_W" as
  /* $Header: amswtrgb.pls 115.13 2003/07/03 14:25:28 cgoyal ship $ */
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

  procedure create_trigger(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_trigger_id out nocopy  NUMBER
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
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  DATE := fnd_api.g_miss_date
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p7_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p7_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p7_a8);
    ddp_trig_rec.arc_trigger_created_for := p7_a9;
    ddp_trig_rec.triggering_type := p7_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p7_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p7_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p7_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p7_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p7_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p7_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p7_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p7_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p7_a22);
    ddp_trig_rec.repeat_frequency_type := p7_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p7_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p7_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p7_a26);
    ddp_trig_rec.metrics_refresh_type := p7_a27;
    ddp_trig_rec.trigger_name := p7_a28;
    ddp_trig_rec.description := p7_a29;
    ddp_trig_rec.notify_flag := p7_a30;
    ddp_trig_rec.execute_schedule_flag := p7_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.create_trigger(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trig_rec,
      x_trigger_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_trigger(p_api_version  NUMBER
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
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  DATE := fnd_api.g_miss_date
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p7_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p7_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p7_a8);
    ddp_trig_rec.arc_trigger_created_for := p7_a9;
    ddp_trig_rec.triggering_type := p7_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p7_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p7_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p7_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p7_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p7_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p7_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p7_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p7_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p7_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p7_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p7_a22);
    ddp_trig_rec.repeat_frequency_type := p7_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p7_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p7_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p7_a26);
    ddp_trig_rec.metrics_refresh_type := p7_a27;
    ddp_trig_rec.trigger_name := p7_a28;
    ddp_trig_rec.description := p7_a29;
    ddp_trig_rec.notify_flag := p7_a30;
    ddp_trig_rec.execute_schedule_flag := p7_a31;

    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.update_trigger(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trig_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_trigger(p_api_version  NUMBER
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
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  DATE := fnd_api.g_miss_date
    , p6_a17  DATE := fnd_api.g_miss_date
    , p6_a18  DATE := fnd_api.g_miss_date
    , p6_a19  DATE := fnd_api.g_miss_date
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  DATE := fnd_api.g_miss_date
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p6_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p6_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p6_a8);
    ddp_trig_rec.arc_trigger_created_for := p6_a9;
    ddp_trig_rec.triggering_type := p6_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p6_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p6_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p6_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p6_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p6_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p6_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p6_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p6_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p6_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p6_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p6_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p6_a22);
    ddp_trig_rec.repeat_frequency_type := p6_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p6_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p6_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p6_a26);
    ddp_trig_rec.metrics_refresh_type := p6_a27;
    ddp_trig_rec.trigger_name := p6_a28;
    ddp_trig_rec.description := p6_a29;
    ddp_trig_rec.notify_flag := p6_a30;
    ddp_trig_rec.execute_schedule_flag := p6_a31;

    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.validate_trigger(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trig_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_trig_items(p_validation_mode  VARCHAR2
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
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  DATE := fnd_api.g_miss_date
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  DATE := fnd_api.g_miss_date
    , p0_a22  DATE := fnd_api.g_miss_date
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  DATE := fnd_api.g_miss_date
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p0_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p0_a8);
    ddp_trig_rec.arc_trigger_created_for := p0_a9;
    ddp_trig_rec.triggering_type := p0_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p0_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p0_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p0_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p0_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p0_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a22);
    ddp_trig_rec.repeat_frequency_type := p0_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p0_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a26);
    ddp_trig_rec.metrics_refresh_type := p0_a27;
    ddp_trig_rec.trigger_name := p0_a28;
    ddp_trig_rec.description := p0_a29;
    ddp_trig_rec.notify_flag := p0_a30;
    ddp_trig_rec.execute_schedule_flag := p0_a31;



    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.check_trig_items(ddp_trig_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_trig_record(x_return_status out nocopy  VARCHAR2
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
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  DATE := fnd_api.g_miss_date
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  DATE := fnd_api.g_miss_date
    , p0_a22  DATE := fnd_api.g_miss_date
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  DATE := fnd_api.g_miss_date
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
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
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  DATE := fnd_api.g_miss_date
    , p1_a16  DATE := fnd_api.g_miss_date
    , p1_a17  DATE := fnd_api.g_miss_date
    , p1_a18  DATE := fnd_api.g_miss_date
    , p1_a19  DATE := fnd_api.g_miss_date
    , p1_a20  DATE := fnd_api.g_miss_date
    , p1_a21  DATE := fnd_api.g_miss_date
    , p1_a22  DATE := fnd_api.g_miss_date
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  DATE := fnd_api.g_miss_date
    , p1_a26  DATE := fnd_api.g_miss_date
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddp_complete_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p0_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p0_a8);
    ddp_trig_rec.arc_trigger_created_for := p0_a9;
    ddp_trig_rec.triggering_type := p0_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p0_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p0_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p0_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p0_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p0_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a22);
    ddp_trig_rec.repeat_frequency_type := p0_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p0_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a26);
    ddp_trig_rec.metrics_refresh_type := p0_a27;
    ddp_trig_rec.trigger_name := p0_a28;
    ddp_trig_rec.description := p0_a29;
    ddp_trig_rec.notify_flag := p0_a30;
    ddp_trig_rec.execute_schedule_flag := p0_a31;

    ddp_complete_rec.trigger_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.process_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.trigger_created_for_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.arc_trigger_created_for := p1_a9;
    ddp_complete_rec.triggering_type := p1_a10;
    ddp_complete_rec.view_application_id := rosetta_g_miss_num_map(p1_a11);
    ddp_complete_rec.timezone_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.user_start_date_time := rosetta_g_miss_date_in_map(p1_a13);
    ddp_complete_rec.start_date_time := rosetta_g_miss_date_in_map(p1_a14);
    ddp_complete_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p1_a15);
    ddp_complete_rec.last_run_date_time := rosetta_g_miss_date_in_map(p1_a16);
    ddp_complete_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p1_a17);
    ddp_complete_rec.next_run_date_time := rosetta_g_miss_date_in_map(p1_a18);
    ddp_complete_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p1_a19);
    ddp_complete_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p1_a20);
    ddp_complete_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p1_a21);
    ddp_complete_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p1_a22);
    ddp_complete_rec.repeat_frequency_type := p1_a23;
    ddp_complete_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p1_a24);
    ddp_complete_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p1_a25);
    ddp_complete_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p1_a26);
    ddp_complete_rec.metrics_refresh_type := p1_a27;
    ddp_complete_rec.trigger_name := p1_a28;
    ddp_complete_rec.description := p1_a29;
    ddp_complete_rec.notify_flag := p1_a30;
    ddp_complete_rec.execute_schedule_flag := p1_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.check_trig_record(ddp_trig_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_trig_req_items(x_return_status out nocopy  VARCHAR2
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
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  DATE := fnd_api.g_miss_date
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  DATE := fnd_api.g_miss_date
    , p0_a22  DATE := fnd_api.g_miss_date
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  DATE := fnd_api.g_miss_date
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p0_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p0_a8);
    ddp_trig_rec.arc_trigger_created_for := p0_a9;
    ddp_trig_rec.triggering_type := p0_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p0_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p0_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p0_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p0_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p0_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a22);
    ddp_trig_rec.repeat_frequency_type := p0_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p0_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a26);
    ddp_trig_rec.metrics_refresh_type := p0_a27;
    ddp_trig_rec.trigger_name := p0_a28;
    ddp_trig_rec.description := p0_a29;
    ddp_trig_rec.notify_flag := p0_a30;
    ddp_trig_rec.execute_schedule_flag := p0_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.check_trig_req_items(ddp_trig_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure init_trig_rec(p0_a0 out nocopy  NUMBER
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
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  DATE
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  DATE
    , p0_a16 out nocopy  DATE
    , p0_a17 out nocopy  DATE
    , p0_a18 out nocopy  DATE
    , p0_a19 out nocopy  DATE
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  DATE
    , p0_a22 out nocopy  DATE
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  DATE
    , p0_a26 out nocopy  DATE
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
  )

  as
    ddx_trig_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.init_trig_rec(ddx_trig_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_trig_rec.trigger_id);
    p0_a1 := ddx_trig_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_trig_rec.last_updated_by);
    p0_a3 := ddx_trig_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_trig_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_trig_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_trig_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_trig_rec.process_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_trig_rec.trigger_created_for_id);
    p0_a9 := ddx_trig_rec.arc_trigger_created_for;
    p0_a10 := ddx_trig_rec.triggering_type;
    p0_a11 := rosetta_g_miss_num_map(ddx_trig_rec.view_application_id);
    p0_a12 := rosetta_g_miss_num_map(ddx_trig_rec.timezone_id);
    p0_a13 := ddx_trig_rec.user_start_date_time;
    p0_a14 := ddx_trig_rec.start_date_time;
    p0_a15 := ddx_trig_rec.user_last_run_date_time;
    p0_a16 := ddx_trig_rec.last_run_date_time;
    p0_a17 := ddx_trig_rec.user_next_run_date_time;
    p0_a18 := ddx_trig_rec.next_run_date_time;
    p0_a19 := ddx_trig_rec.user_repeat_daily_start_time;
    p0_a20 := ddx_trig_rec.repeat_daily_start_time;
    p0_a21 := ddx_trig_rec.user_repeat_daily_end_time;
    p0_a22 := ddx_trig_rec.repeat_daily_end_time;
    p0_a23 := ddx_trig_rec.repeat_frequency_type;
    p0_a24 := rosetta_g_miss_num_map(ddx_trig_rec.repeat_every_x_frequency);
    p0_a25 := ddx_trig_rec.user_repeat_stop_date_time;
    p0_a26 := ddx_trig_rec.repeat_stop_date_time;
    p0_a27 := ddx_trig_rec.metrics_refresh_type;
    p0_a28 := ddx_trig_rec.trigger_name;
    p0_a29 := ddx_trig_rec.description;
    p0_a30 := ddx_trig_rec.notify_flag;
    p0_a31 := ddx_trig_rec.execute_schedule_flag;
  end;

  procedure complete_trig_rec(p1_a0 out nocopy  NUMBER
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
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  DATE
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  DATE
    , p1_a16 out nocopy  DATE
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  DATE
    , p1_a19 out nocopy  DATE
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  DATE
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  DATE
    , p1_a26 out nocopy  DATE
    , p1_a27 out nocopy  VARCHAR2
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
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  DATE := fnd_api.g_miss_date
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  DATE := fnd_api.g_miss_date
    , p0_a22  DATE := fnd_api.g_miss_date
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  DATE := fnd_api.g_miss_date
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_trig_rec ams_trig_pvt.trig_rec_type;
    ddx_complete_rec ams_trig_pvt.trig_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_trig_rec.trigger_id := rosetta_g_miss_num_map(p0_a0);
    ddp_trig_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_trig_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_trig_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_trig_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_trig_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_trig_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_trig_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_trig_rec.trigger_created_for_id := rosetta_g_miss_num_map(p0_a8);
    ddp_trig_rec.arc_trigger_created_for := p0_a9;
    ddp_trig_rec.triggering_type := p0_a10;
    ddp_trig_rec.view_application_id := rosetta_g_miss_num_map(p0_a11);
    ddp_trig_rec.timezone_id := rosetta_g_miss_num_map(p0_a12);
    ddp_trig_rec.user_start_date_time := rosetta_g_miss_date_in_map(p0_a13);
    ddp_trig_rec.start_date_time := rosetta_g_miss_date_in_map(p0_a14);
    ddp_trig_rec.user_last_run_date_time := rosetta_g_miss_date_in_map(p0_a15);
    ddp_trig_rec.last_run_date_time := rosetta_g_miss_date_in_map(p0_a16);
    ddp_trig_rec.user_next_run_date_time := rosetta_g_miss_date_in_map(p0_a17);
    ddp_trig_rec.next_run_date_time := rosetta_g_miss_date_in_map(p0_a18);
    ddp_trig_rec.user_repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_trig_rec.repeat_daily_start_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_trig_rec.user_repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a21);
    ddp_trig_rec.repeat_daily_end_time := rosetta_g_miss_date_in_map(p0_a22);
    ddp_trig_rec.repeat_frequency_type := p0_a23;
    ddp_trig_rec.repeat_every_x_frequency := rosetta_g_miss_num_map(p0_a24);
    ddp_trig_rec.user_repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a25);
    ddp_trig_rec.repeat_stop_date_time := rosetta_g_miss_date_in_map(p0_a26);
    ddp_trig_rec.metrics_refresh_type := p0_a27;
    ddp_trig_rec.trigger_name := p0_a28;
    ddp_trig_rec.description := p0_a29;
    ddp_trig_rec.notify_flag := p0_a30;
    ddp_trig_rec.execute_schedule_flag := p0_a31;


    -- here's the delegated call to the old PL/SQL routine
    ams_trig_pvt.complete_trig_rec(ddp_trig_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.trigger_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.process_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.trigger_created_for_id);
    p1_a9 := ddx_complete_rec.arc_trigger_created_for;
    p1_a10 := ddx_complete_rec.triggering_type;
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.view_application_id);
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.timezone_id);
    p1_a13 := ddx_complete_rec.user_start_date_time;
    p1_a14 := ddx_complete_rec.start_date_time;
    p1_a15 := ddx_complete_rec.user_last_run_date_time;
    p1_a16 := ddx_complete_rec.last_run_date_time;
    p1_a17 := ddx_complete_rec.user_next_run_date_time;
    p1_a18 := ddx_complete_rec.next_run_date_time;
    p1_a19 := ddx_complete_rec.user_repeat_daily_start_time;
    p1_a20 := ddx_complete_rec.repeat_daily_start_time;
    p1_a21 := ddx_complete_rec.user_repeat_daily_end_time;
    p1_a22 := ddx_complete_rec.repeat_daily_end_time;
    p1_a23 := ddx_complete_rec.repeat_frequency_type;
    p1_a24 := rosetta_g_miss_num_map(ddx_complete_rec.repeat_every_x_frequency);
    p1_a25 := ddx_complete_rec.user_repeat_stop_date_time;
    p1_a26 := ddx_complete_rec.repeat_stop_date_time;
    p1_a27 := ddx_complete_rec.metrics_refresh_type;
    p1_a28 := ddx_complete_rec.trigger_name;
    p1_a29 := ddx_complete_rec.description;
    p1_a30 := ddx_complete_rec.notify_flag;
    p1_a31 := ddx_complete_rec.execute_schedule_flag;
  end;

end ams_trig_pvt_w;

/
