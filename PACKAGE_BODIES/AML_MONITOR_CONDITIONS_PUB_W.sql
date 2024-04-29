--------------------------------------------------------
--  DDL for Package Body AML_MONITOR_CONDITIONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_MONITOR_CONDITIONS_PUB_W" as
  /* $Header: amlwlmcb.pls 115.0 2002/12/06 02:01:37 ajchatto noship $ */
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
    b number := 0-1962.072;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure create_monitor_condition(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_monitor_condition_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.072
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.072
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.072
    , p5_a5  NUMBER := 0-1962.072
    , p5_a6  NUMBER := 0-1962.072
    , p5_a7  NUMBER := 0-1962.072
    , p5_a8  NUMBER := 0-1962.072
    , p5_a9  NUMBER := 0-1962.072
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.072
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.072
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.072
    , p5_a20  NUMBER := 0-1962.072
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.072
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_condition_rec aml_monitor_conditions_pub.condition_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_condition_rec.monitor_condition_id := rosetta_g_miss_num_map(p5_a0);
    ddp_condition_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_condition_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_condition_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_condition_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_condition_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_condition_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_condition_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_condition_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_condition_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_condition_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_condition_rec.process_rule_id := rosetta_g_miss_num_map(p5_a11);
    ddp_condition_rec.monitor_type_code := p5_a12;
    ddp_condition_rec.time_lag_num := rosetta_g_miss_num_map(p5_a13);
    ddp_condition_rec.time_lag_uom_code := p5_a14;
    ddp_condition_rec.time_lag_from_stage := p5_a15;
    ddp_condition_rec.time_lag_to_stage := p5_a16;
    ddp_condition_rec.expiration_relative := p5_a17;
    ddp_condition_rec.reminder_defined := p5_a18;
    ddp_condition_rec.total_reminders := rosetta_g_miss_num_map(p5_a19);
    ddp_condition_rec.reminder_frequency := rosetta_g_miss_num_map(p5_a20);
    ddp_condition_rec.reminder_freq_uom_code := p5_a21;
    ddp_condition_rec.timeout_defined := p5_a22;
    ddp_condition_rec.timeout_duration := rosetta_g_miss_num_map(p5_a23);
    ddp_condition_rec.timeout_uom_code := p5_a24;
    ddp_condition_rec.notify_owner := p5_a25;
    ddp_condition_rec.notify_owner_manager := p5_a26;
    ddp_condition_rec.attribute_category := p5_a27;
    ddp_condition_rec.attribute1 := p5_a28;
    ddp_condition_rec.attribute2 := p5_a29;
    ddp_condition_rec.attribute3 := p5_a30;
    ddp_condition_rec.attribute4 := p5_a31;
    ddp_condition_rec.attribute5 := p5_a32;
    ddp_condition_rec.attribute6 := p5_a33;
    ddp_condition_rec.attribute7 := p5_a34;
    ddp_condition_rec.attribute8 := p5_a35;
    ddp_condition_rec.attribute9 := p5_a36;
    ddp_condition_rec.attribute10 := p5_a37;
    ddp_condition_rec.attribute11 := p5_a38;
    ddp_condition_rec.attribute12 := p5_a39;
    ddp_condition_rec.attribute13 := p5_a40;
    ddp_condition_rec.attribute14 := p5_a41;
    ddp_condition_rec.attribute15 := p5_a42;





    -- here's the delegated call to the old PL/SQL routine
    aml_monitor_conditions_pub.create_monitor_condition(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_condition_rec,
      x_monitor_condition_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_monitor_condition(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.072
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.072
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.072
    , p5_a5  NUMBER := 0-1962.072
    , p5_a6  NUMBER := 0-1962.072
    , p5_a7  NUMBER := 0-1962.072
    , p5_a8  NUMBER := 0-1962.072
    , p5_a9  NUMBER := 0-1962.072
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.072
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.072
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.072
    , p5_a20  NUMBER := 0-1962.072
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.072
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_condition_rec aml_monitor_conditions_pub.condition_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_condition_rec.monitor_condition_id := rosetta_g_miss_num_map(p5_a0);
    ddp_condition_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_condition_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_condition_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_condition_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_condition_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_condition_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_condition_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_condition_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_condition_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_condition_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_condition_rec.process_rule_id := rosetta_g_miss_num_map(p5_a11);
    ddp_condition_rec.monitor_type_code := p5_a12;
    ddp_condition_rec.time_lag_num := rosetta_g_miss_num_map(p5_a13);
    ddp_condition_rec.time_lag_uom_code := p5_a14;
    ddp_condition_rec.time_lag_from_stage := p5_a15;
    ddp_condition_rec.time_lag_to_stage := p5_a16;
    ddp_condition_rec.expiration_relative := p5_a17;
    ddp_condition_rec.reminder_defined := p5_a18;
    ddp_condition_rec.total_reminders := rosetta_g_miss_num_map(p5_a19);
    ddp_condition_rec.reminder_frequency := rosetta_g_miss_num_map(p5_a20);
    ddp_condition_rec.reminder_freq_uom_code := p5_a21;
    ddp_condition_rec.timeout_defined := p5_a22;
    ddp_condition_rec.timeout_duration := rosetta_g_miss_num_map(p5_a23);
    ddp_condition_rec.timeout_uom_code := p5_a24;
    ddp_condition_rec.notify_owner := p5_a25;
    ddp_condition_rec.notify_owner_manager := p5_a26;
    ddp_condition_rec.attribute_category := p5_a27;
    ddp_condition_rec.attribute1 := p5_a28;
    ddp_condition_rec.attribute2 := p5_a29;
    ddp_condition_rec.attribute3 := p5_a30;
    ddp_condition_rec.attribute4 := p5_a31;
    ddp_condition_rec.attribute5 := p5_a32;
    ddp_condition_rec.attribute6 := p5_a33;
    ddp_condition_rec.attribute7 := p5_a34;
    ddp_condition_rec.attribute8 := p5_a35;
    ddp_condition_rec.attribute9 := p5_a36;
    ddp_condition_rec.attribute10 := p5_a37;
    ddp_condition_rec.attribute11 := p5_a38;
    ddp_condition_rec.attribute12 := p5_a39;
    ddp_condition_rec.attribute13 := p5_a40;
    ddp_condition_rec.attribute14 := p5_a41;
    ddp_condition_rec.attribute15 := p5_a42;




    -- here's the delegated call to the old PL/SQL routine
    aml_monitor_conditions_pub.update_monitor_condition(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_condition_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure delete_monitor_condition(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.072
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.072
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.072
    , p5_a5  NUMBER := 0-1962.072
    , p5_a6  NUMBER := 0-1962.072
    , p5_a7  NUMBER := 0-1962.072
    , p5_a8  NUMBER := 0-1962.072
    , p5_a9  NUMBER := 0-1962.072
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.072
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.072
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.072
    , p5_a20  NUMBER := 0-1962.072
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.072
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_condition_rec aml_monitor_conditions_pub.condition_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_condition_rec.monitor_condition_id := rosetta_g_miss_num_map(p5_a0);
    ddp_condition_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_condition_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_condition_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_condition_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_condition_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_condition_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_condition_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_condition_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_condition_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_condition_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_condition_rec.process_rule_id := rosetta_g_miss_num_map(p5_a11);
    ddp_condition_rec.monitor_type_code := p5_a12;
    ddp_condition_rec.time_lag_num := rosetta_g_miss_num_map(p5_a13);
    ddp_condition_rec.time_lag_uom_code := p5_a14;
    ddp_condition_rec.time_lag_from_stage := p5_a15;
    ddp_condition_rec.time_lag_to_stage := p5_a16;
    ddp_condition_rec.expiration_relative := p5_a17;
    ddp_condition_rec.reminder_defined := p5_a18;
    ddp_condition_rec.total_reminders := rosetta_g_miss_num_map(p5_a19);
    ddp_condition_rec.reminder_frequency := rosetta_g_miss_num_map(p5_a20);
    ddp_condition_rec.reminder_freq_uom_code := p5_a21;
    ddp_condition_rec.timeout_defined := p5_a22;
    ddp_condition_rec.timeout_duration := rosetta_g_miss_num_map(p5_a23);
    ddp_condition_rec.timeout_uom_code := p5_a24;
    ddp_condition_rec.notify_owner := p5_a25;
    ddp_condition_rec.notify_owner_manager := p5_a26;
    ddp_condition_rec.attribute_category := p5_a27;
    ddp_condition_rec.attribute1 := p5_a28;
    ddp_condition_rec.attribute2 := p5_a29;
    ddp_condition_rec.attribute3 := p5_a30;
    ddp_condition_rec.attribute4 := p5_a31;
    ddp_condition_rec.attribute5 := p5_a32;
    ddp_condition_rec.attribute6 := p5_a33;
    ddp_condition_rec.attribute7 := p5_a34;
    ddp_condition_rec.attribute8 := p5_a35;
    ddp_condition_rec.attribute9 := p5_a36;
    ddp_condition_rec.attribute10 := p5_a37;
    ddp_condition_rec.attribute11 := p5_a38;
    ddp_condition_rec.attribute12 := p5_a39;
    ddp_condition_rec.attribute13 := p5_a40;
    ddp_condition_rec.attribute14 := p5_a41;
    ddp_condition_rec.attribute15 := p5_a42;




    -- here's the delegated call to the old PL/SQL routine
    aml_monitor_conditions_pub.delete_monitor_condition(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_condition_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end aml_monitor_conditions_pub_w;

/
