--------------------------------------------------------
--  DDL for Package Body PV_PROCESS_RULES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PROCESS_RULES_PUB_W" as
  /* $Header: pvrwprub.pls 120.1 2005/09/07 12:03:11 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_process_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_process_rule_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_rules_rec pv_rule_rectype_pub.rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rules_rec.process_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_rules_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_rules_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_rules_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_rules_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_rules_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_rules_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rules_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rules_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rules_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_rules_rec.process_rule_name := p5_a11;
    ddp_rules_rec.parent_rule_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rules_rec.process_type := p5_a13;
    ddp_rules_rec.rank := rosetta_g_miss_num_map(p5_a14);
    ddp_rules_rec.status_code := p5_a15;
    ddp_rules_rec.start_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_rules_rec.end_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_rules_rec.action := p5_a18;
    ddp_rules_rec.action_value := p5_a19;
    ddp_rules_rec.owner_resource_id := rosetta_g_miss_num_map(p5_a20);
    ddp_rules_rec.currency_code := p5_a21;
    ddp_rules_rec.language := p5_a22;
    ddp_rules_rec.source_lang := p5_a23;
    ddp_rules_rec.description := p5_a24;
    ddp_rules_rec.attribute_category := p5_a25;
    ddp_rules_rec.attribute1 := p5_a26;
    ddp_rules_rec.attribute2 := p5_a27;
    ddp_rules_rec.attribute3 := p5_a28;
    ddp_rules_rec.attribute4 := p5_a29;
    ddp_rules_rec.attribute5 := p5_a30;
    ddp_rules_rec.attribute6 := p5_a31;
    ddp_rules_rec.attribute7 := p5_a32;
    ddp_rules_rec.attribute8 := p5_a33;
    ddp_rules_rec.attribute9 := p5_a34;
    ddp_rules_rec.attribute10 := p5_a35;
    ddp_rules_rec.attribute11 := p5_a36;
    ddp_rules_rec.attribute12 := p5_a37;
    ddp_rules_rec.attribute13 := p5_a38;
    ddp_rules_rec.attribute14 := p5_a39;
    ddp_rules_rec.attribute15 := p5_a40;





    -- here's the delegated call to the old PL/SQL routine
    pv_process_rules_pub.create_process_rules(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_rules_rec,
      x_process_rule_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_process_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_rules_rec pv_rule_rectype_pub.rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rules_rec.process_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_rules_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_rules_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_rules_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_rules_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_rules_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_rules_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rules_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rules_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rules_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_rules_rec.process_rule_name := p5_a11;
    ddp_rules_rec.parent_rule_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rules_rec.process_type := p5_a13;
    ddp_rules_rec.rank := rosetta_g_miss_num_map(p5_a14);
    ddp_rules_rec.status_code := p5_a15;
    ddp_rules_rec.start_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_rules_rec.end_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_rules_rec.action := p5_a18;
    ddp_rules_rec.action_value := p5_a19;
    ddp_rules_rec.owner_resource_id := rosetta_g_miss_num_map(p5_a20);
    ddp_rules_rec.currency_code := p5_a21;
    ddp_rules_rec.language := p5_a22;
    ddp_rules_rec.source_lang := p5_a23;
    ddp_rules_rec.description := p5_a24;
    ddp_rules_rec.attribute_category := p5_a25;
    ddp_rules_rec.attribute1 := p5_a26;
    ddp_rules_rec.attribute2 := p5_a27;
    ddp_rules_rec.attribute3 := p5_a28;
    ddp_rules_rec.attribute4 := p5_a29;
    ddp_rules_rec.attribute5 := p5_a30;
    ddp_rules_rec.attribute6 := p5_a31;
    ddp_rules_rec.attribute7 := p5_a32;
    ddp_rules_rec.attribute8 := p5_a33;
    ddp_rules_rec.attribute9 := p5_a34;
    ddp_rules_rec.attribute10 := p5_a35;
    ddp_rules_rec.attribute11 := p5_a36;
    ddp_rules_rec.attribute12 := p5_a37;
    ddp_rules_rec.attribute13 := p5_a38;
    ddp_rules_rec.attribute14 := p5_a39;
    ddp_rules_rec.attribute15 := p5_a40;




    -- here's the delegated call to the old PL/SQL routine
    pv_process_rules_pub.update_process_rules(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_rules_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure delete_process_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_rules_rec pv_rule_rectype_pub.rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rules_rec.process_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_rules_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_rules_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_rules_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_rules_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_rules_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_rules_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rules_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rules_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rules_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_rules_rec.process_rule_name := p5_a11;
    ddp_rules_rec.parent_rule_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rules_rec.process_type := p5_a13;
    ddp_rules_rec.rank := rosetta_g_miss_num_map(p5_a14);
    ddp_rules_rec.status_code := p5_a15;
    ddp_rules_rec.start_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_rules_rec.end_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_rules_rec.action := p5_a18;
    ddp_rules_rec.action_value := p5_a19;
    ddp_rules_rec.owner_resource_id := rosetta_g_miss_num_map(p5_a20);
    ddp_rules_rec.currency_code := p5_a21;
    ddp_rules_rec.language := p5_a22;
    ddp_rules_rec.source_lang := p5_a23;
    ddp_rules_rec.description := p5_a24;
    ddp_rules_rec.attribute_category := p5_a25;
    ddp_rules_rec.attribute1 := p5_a26;
    ddp_rules_rec.attribute2 := p5_a27;
    ddp_rules_rec.attribute3 := p5_a28;
    ddp_rules_rec.attribute4 := p5_a29;
    ddp_rules_rec.attribute5 := p5_a30;
    ddp_rules_rec.attribute6 := p5_a31;
    ddp_rules_rec.attribute7 := p5_a32;
    ddp_rules_rec.attribute8 := p5_a33;
    ddp_rules_rec.attribute9 := p5_a34;
    ddp_rules_rec.attribute10 := p5_a35;
    ddp_rules_rec.attribute11 := p5_a36;
    ddp_rules_rec.attribute12 := p5_a37;
    ddp_rules_rec.attribute13 := p5_a38;
    ddp_rules_rec.attribute14 := p5_a39;
    ddp_rules_rec.attribute15 := p5_a40;




    -- here's the delegated call to the old PL/SQL routine
    pv_process_rules_pub.delete_process_rules(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_rules_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure copy_process_rules(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_resource_id  NUMBER
    , x_process_rule_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
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
  )
  as
    ddp_rules_rec pv_rule_rectype_pub.rules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rules_rec.process_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_rules_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_rules_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_rules_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_rules_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_rules_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_rules_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_rules_rec.request_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rules_rec.program_application_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rules_rec.program_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rules_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_rules_rec.process_rule_name := p5_a11;
    ddp_rules_rec.parent_rule_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rules_rec.process_type := p5_a13;
    ddp_rules_rec.rank := rosetta_g_miss_num_map(p5_a14);
    ddp_rules_rec.status_code := p5_a15;
    ddp_rules_rec.start_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_rules_rec.end_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_rules_rec.action := p5_a18;
    ddp_rules_rec.action_value := p5_a19;
    ddp_rules_rec.owner_resource_id := rosetta_g_miss_num_map(p5_a20);
    ddp_rules_rec.currency_code := p5_a21;
    ddp_rules_rec.language := p5_a22;
    ddp_rules_rec.source_lang := p5_a23;
    ddp_rules_rec.description := p5_a24;
    ddp_rules_rec.attribute_category := p5_a25;
    ddp_rules_rec.attribute1 := p5_a26;
    ddp_rules_rec.attribute2 := p5_a27;
    ddp_rules_rec.attribute3 := p5_a28;
    ddp_rules_rec.attribute4 := p5_a29;
    ddp_rules_rec.attribute5 := p5_a30;
    ddp_rules_rec.attribute6 := p5_a31;
    ddp_rules_rec.attribute7 := p5_a32;
    ddp_rules_rec.attribute8 := p5_a33;
    ddp_rules_rec.attribute9 := p5_a34;
    ddp_rules_rec.attribute10 := p5_a35;
    ddp_rules_rec.attribute11 := p5_a36;
    ddp_rules_rec.attribute12 := p5_a37;
    ddp_rules_rec.attribute13 := p5_a38;
    ddp_rules_rec.attribute14 := p5_a39;
    ddp_rules_rec.attribute15 := p5_a40;





    -- here's the delegated call to the old PL/SQL routine
    pv_process_rules_pub.copy_process_rules(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_resource_id,
      ddp_rules_rec,
      x_process_rule_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

end pv_process_rules_pub_w;

/
