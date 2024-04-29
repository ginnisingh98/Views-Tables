--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_PREFERENCE_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_PREFERENCE_V2PUB_JW" as
  /* $Header: ARH2CTJB.pls 120.2 2005/06/18 04:27:41 jhuang noship $ */
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

  procedure create_contact_preference_1(p_init_msg_list  VARCHAR2
    , x_contact_preference_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  DATE := null
    , p1_a9  DATE := null
    , p1_a10  NUMBER := null
    , p1_a11  NUMBER := null
    , p1_a12  NUMBER := null
    , p1_a13  NUMBER := null
    , p1_a14  NUMBER := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
  )
  as
    ddp_contact_preference_rec hz_contact_preference_v2pub.contact_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_preference_rec.contact_preference_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_preference_rec.contact_level_table := p1_a1;
    ddp_contact_preference_rec.contact_level_table_id := rosetta_g_miss_num_map(p1_a2);
    ddp_contact_preference_rec.contact_type := p1_a3;
    ddp_contact_preference_rec.preference_code := p1_a4;
    ddp_contact_preference_rec.preference_topic_type := p1_a5;
    ddp_contact_preference_rec.preference_topic_type_id := rosetta_g_miss_num_map(p1_a6);
    ddp_contact_preference_rec.preference_topic_type_code := p1_a7;
    ddp_contact_preference_rec.preference_start_date := rosetta_g_miss_date_in_map(p1_a8);
    ddp_contact_preference_rec.preference_end_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_contact_preference_rec.preference_start_time_hr := rosetta_g_miss_num_map(p1_a10);
    ddp_contact_preference_rec.preference_end_time_hr := rosetta_g_miss_num_map(p1_a11);
    ddp_contact_preference_rec.preference_start_time_mi := rosetta_g_miss_num_map(p1_a12);
    ddp_contact_preference_rec.preference_end_time_mi := rosetta_g_miss_num_map(p1_a13);
    ddp_contact_preference_rec.max_no_of_interactions := rosetta_g_miss_num_map(p1_a14);
    ddp_contact_preference_rec.max_no_of_interact_uom_code := p1_a15;
    ddp_contact_preference_rec.requested_by := p1_a16;
    ddp_contact_preference_rec.reason_code := p1_a17;
    ddp_contact_preference_rec.status := p1_a18;
    ddp_contact_preference_rec.created_by_module := p1_a19;
    ddp_contact_preference_rec.application_id := rosetta_g_miss_num_map(p1_a20);





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_preference_v2pub.create_contact_preference(p_init_msg_list,
      ddp_contact_preference_rec,
      x_contact_preference_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_contact_preference_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  DATE := null
    , p1_a9  DATE := null
    , p1_a10  NUMBER := null
    , p1_a11  NUMBER := null
    , p1_a12  NUMBER := null
    , p1_a13  NUMBER := null
    , p1_a14  NUMBER := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
  )
  as
    ddp_contact_preference_rec hz_contact_preference_v2pub.contact_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_preference_rec.contact_preference_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_preference_rec.contact_level_table := p1_a1;
    ddp_contact_preference_rec.contact_level_table_id := rosetta_g_miss_num_map(p1_a2);
    ddp_contact_preference_rec.contact_type := p1_a3;
    ddp_contact_preference_rec.preference_code := p1_a4;
    ddp_contact_preference_rec.preference_topic_type := p1_a5;
    ddp_contact_preference_rec.preference_topic_type_id := rosetta_g_miss_num_map(p1_a6);
    ddp_contact_preference_rec.preference_topic_type_code := p1_a7;
    ddp_contact_preference_rec.preference_start_date := rosetta_g_miss_date_in_map(p1_a8);
    ddp_contact_preference_rec.preference_end_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_contact_preference_rec.preference_start_time_hr := rosetta_g_miss_num_map(p1_a10);
    ddp_contact_preference_rec.preference_end_time_hr := rosetta_g_miss_num_map(p1_a11);
    ddp_contact_preference_rec.preference_start_time_mi := rosetta_g_miss_num_map(p1_a12);
    ddp_contact_preference_rec.preference_end_time_mi := rosetta_g_miss_num_map(p1_a13);
    ddp_contact_preference_rec.max_no_of_interactions := rosetta_g_miss_num_map(p1_a14);
    ddp_contact_preference_rec.max_no_of_interact_uom_code := p1_a15;
    ddp_contact_preference_rec.requested_by := p1_a16;
    ddp_contact_preference_rec.reason_code := p1_a17;
    ddp_contact_preference_rec.status := p1_a18;
    ddp_contact_preference_rec.created_by_module := p1_a19;
    ddp_contact_preference_rec.application_id := rosetta_g_miss_num_map(p1_a20);





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_preference_v2pub.update_contact_preference(p_init_msg_list,
      ddp_contact_preference_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_contact_preference_rec_3(p_init_msg_list  VARCHAR2
    , p_contact_preference_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  DATE
    , p2_a9 out nocopy  DATE
    , p2_a10 out nocopy  NUMBER
    , p2_a11 out nocopy  NUMBER
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  NUMBER
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_preference_rec hz_contact_preference_v2pub.contact_preference_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_contact_preference_v2pub.get_contact_preference_rec(p_init_msg_list,
      p_contact_preference_id,
      ddx_contact_preference_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_preference_rec.contact_preference_id);
    p2_a1 := ddx_contact_preference_rec.contact_level_table;
    p2_a2 := rosetta_g_miss_num_map(ddx_contact_preference_rec.contact_level_table_id);
    p2_a3 := ddx_contact_preference_rec.contact_type;
    p2_a4 := ddx_contact_preference_rec.preference_code;
    p2_a5 := ddx_contact_preference_rec.preference_topic_type;
    p2_a6 := rosetta_g_miss_num_map(ddx_contact_preference_rec.preference_topic_type_id);
    p2_a7 := ddx_contact_preference_rec.preference_topic_type_code;
    p2_a8 := ddx_contact_preference_rec.preference_start_date;
    p2_a9 := ddx_contact_preference_rec.preference_end_date;
    p2_a10 := rosetta_g_miss_num_map(ddx_contact_preference_rec.preference_start_time_hr);
    p2_a11 := rosetta_g_miss_num_map(ddx_contact_preference_rec.preference_end_time_hr);
    p2_a12 := rosetta_g_miss_num_map(ddx_contact_preference_rec.preference_start_time_mi);
    p2_a13 := rosetta_g_miss_num_map(ddx_contact_preference_rec.preference_end_time_mi);
    p2_a14 := rosetta_g_miss_num_map(ddx_contact_preference_rec.max_no_of_interactions);
    p2_a15 := ddx_contact_preference_rec.max_no_of_interact_uom_code;
    p2_a16 := ddx_contact_preference_rec.requested_by;
    p2_a17 := ddx_contact_preference_rec.reason_code;
    p2_a18 := ddx_contact_preference_rec.status;
    p2_a19 := ddx_contact_preference_rec.created_by_module;
    p2_a20 := rosetta_g_miss_num_map(ddx_contact_preference_rec.application_id);



  end;

end hz_contact_preference_v2pub_jw;

/
