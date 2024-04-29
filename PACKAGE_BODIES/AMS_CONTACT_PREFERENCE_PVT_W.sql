--------------------------------------------------------
--  DDL for Package Body AMS_CONTACT_PREFERENCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CONTACT_PREFERENCE_PVT_W" as
  /* $Header: amswcppb.pls 120.1 2005/06/27 05:43:00 appldev ship $ */
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

  procedure create_contact_preference(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_request_id  NUMBER
    , x_contact_preference_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_ams_contact_pref_rec ams_contact_preference_pvt.contact_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ams_contact_pref_rec.contact_preference_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ams_contact_pref_rec.contact_level_table := p7_a1;
    ddp_ams_contact_pref_rec.contact_level_table_id := rosetta_g_miss_num_map(p7_a2);
    ddp_ams_contact_pref_rec.contact_type := p7_a3;
    ddp_ams_contact_pref_rec.preference_code := p7_a4;
    ddp_ams_contact_pref_rec.preference_topic_type := p7_a5;
    ddp_ams_contact_pref_rec.preference_topic_type_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ams_contact_pref_rec.preference_topic_type_code := p7_a7;
    ddp_ams_contact_pref_rec.preference_start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_ams_contact_pref_rec.preference_end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_ams_contact_pref_rec.preference_start_time_hr := rosetta_g_miss_num_map(p7_a10);
    ddp_ams_contact_pref_rec.preference_end_time_hr := rosetta_g_miss_num_map(p7_a11);
    ddp_ams_contact_pref_rec.preference_start_time_mi := rosetta_g_miss_num_map(p7_a12);
    ddp_ams_contact_pref_rec.preference_end_time_mi := rosetta_g_miss_num_map(p7_a13);
    ddp_ams_contact_pref_rec.max_no_of_interactions := rosetta_g_miss_num_map(p7_a14);
    ddp_ams_contact_pref_rec.max_no_of_interact_uom_code := p7_a15;
    ddp_ams_contact_pref_rec.requested_by := p7_a16;
    ddp_ams_contact_pref_rec.reason_code := p7_a17;
    ddp_ams_contact_pref_rec.status := p7_a18;
    ddp_ams_contact_pref_rec.created_by_module := p7_a19;
    ddp_ams_contact_pref_rec.application_id := rosetta_g_miss_num_map(p7_a20);



    -- here's the delegated call to the old PL/SQL routine
    ams_contact_preference_pvt.create_contact_preference(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_contact_pref_rec,
      p_request_id,
      x_contact_preference_id);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_contact_preference(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_request_id  NUMBER
    , px_object_version_number in OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_ams_contact_pref_rec ams_contact_preference_pvt.contact_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ams_contact_pref_rec.contact_preference_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ams_contact_pref_rec.contact_level_table := p7_a1;
    ddp_ams_contact_pref_rec.contact_level_table_id := rosetta_g_miss_num_map(p7_a2);
    ddp_ams_contact_pref_rec.contact_type := p7_a3;
    ddp_ams_contact_pref_rec.preference_code := p7_a4;
    ddp_ams_contact_pref_rec.preference_topic_type := p7_a5;
    ddp_ams_contact_pref_rec.preference_topic_type_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ams_contact_pref_rec.preference_topic_type_code := p7_a7;
    ddp_ams_contact_pref_rec.preference_start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_ams_contact_pref_rec.preference_end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_ams_contact_pref_rec.preference_start_time_hr := rosetta_g_miss_num_map(p7_a10);
    ddp_ams_contact_pref_rec.preference_end_time_hr := rosetta_g_miss_num_map(p7_a11);
    ddp_ams_contact_pref_rec.preference_start_time_mi := rosetta_g_miss_num_map(p7_a12);
    ddp_ams_contact_pref_rec.preference_end_time_mi := rosetta_g_miss_num_map(p7_a13);
    ddp_ams_contact_pref_rec.max_no_of_interactions := rosetta_g_miss_num_map(p7_a14);
    ddp_ams_contact_pref_rec.max_no_of_interact_uom_code := p7_a15;
    ddp_ams_contact_pref_rec.requested_by := p7_a16;
    ddp_ams_contact_pref_rec.reason_code := p7_a17;
    ddp_ams_contact_pref_rec.status := p7_a18;
    ddp_ams_contact_pref_rec.created_by_module := p7_a19;
    ddp_ams_contact_pref_rec.application_id := rosetta_g_miss_num_map(p7_a20);



    -- here's the delegated call to the old PL/SQL routine
    ams_contact_preference_pvt.update_contact_preference(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_contact_pref_rec,
      p_request_id,
      px_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

end ams_contact_preference_pvt_w;

/
