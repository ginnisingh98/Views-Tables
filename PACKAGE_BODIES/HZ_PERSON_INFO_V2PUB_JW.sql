--------------------------------------------------------
--  DDL for Package Body HZ_PERSON_INFO_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PERSON_INFO_V2PUB_JW" as
  /* $Header: ARH2PIJB.pls 120.5 2005/06/18 04:29:06 jhuang noship $ */
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

  procedure create_person_language_1(p_init_msg_list  VARCHAR2
    , x_language_use_reference_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  NUMBER := null
  )
  as
    ddp_person_language_rec hz_person_info_v2pub.person_language_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_person_language_rec.language_use_reference_id := rosetta_g_miss_num_map(p1_a0);
    ddp_person_language_rec.language_name := p1_a1;
    ddp_person_language_rec.party_id := rosetta_g_miss_num_map(p1_a2);
    ddp_person_language_rec.native_language := p1_a3;
    ddp_person_language_rec.primary_language_indicator := p1_a4;
    ddp_person_language_rec.reads_level := p1_a5;
    ddp_person_language_rec.speaks_level := p1_a6;
    ddp_person_language_rec.writes_level := p1_a7;
    ddp_person_language_rec.spoken_comprehension_level := p1_a8;
    ddp_person_language_rec.status := p1_a9;
    ddp_person_language_rec.created_by_module := p1_a10;
    ddp_person_language_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.create_person_language(p_init_msg_list,
      ddp_person_language_rec,
      x_language_use_reference_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_person_language_2(p_init_msg_list  VARCHAR2
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
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  NUMBER := null
  )
  as
    ddp_person_language_rec hz_person_info_v2pub.person_language_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_person_language_rec.language_use_reference_id := rosetta_g_miss_num_map(p1_a0);
    ddp_person_language_rec.language_name := p1_a1;
    ddp_person_language_rec.party_id := rosetta_g_miss_num_map(p1_a2);
    ddp_person_language_rec.native_language := p1_a3;
    ddp_person_language_rec.primary_language_indicator := p1_a4;
    ddp_person_language_rec.reads_level := p1_a5;
    ddp_person_language_rec.speaks_level := p1_a6;
    ddp_person_language_rec.writes_level := p1_a7;
    ddp_person_language_rec.spoken_comprehension_level := p1_a8;
    ddp_person_language_rec.status := p1_a9;
    ddp_person_language_rec.created_by_module := p1_a10;
    ddp_person_language_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.update_person_language(p_init_msg_list,
      ddp_person_language_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_person_language_rec_3(p_init_msg_list  VARCHAR2
    , p_language_use_reference_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_person_language_rec hz_person_info_v2pub.person_language_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.get_person_language_rec(p_init_msg_list,
      p_language_use_reference_id,
      ddp_person_language_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddp_person_language_rec.language_use_reference_id);
    p2_a1 := ddp_person_language_rec.language_name;
    p2_a2 := rosetta_g_miss_num_map(ddp_person_language_rec.party_id);
    p2_a3 := ddp_person_language_rec.native_language;
    p2_a4 := ddp_person_language_rec.primary_language_indicator;
    p2_a5 := ddp_person_language_rec.reads_level;
    p2_a6 := ddp_person_language_rec.speaks_level;
    p2_a7 := ddp_person_language_rec.writes_level;
    p2_a8 := ddp_person_language_rec.spoken_comprehension_level;
    p2_a9 := ddp_person_language_rec.status;
    p2_a10 := ddp_person_language_rec.created_by_module;
    p2_a11 := rosetta_g_miss_num_map(ddp_person_language_rec.application_id);



  end;

  procedure create_citizenship_4(p_init_msg_list  VARCHAR2
    , x_citizenship_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  DATE := null
    , p1_a6  DATE := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  NUMBER := null
  )
  as
    ddp_citizenship_rec hz_person_info_v2pub.citizenship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_citizenship_rec.citizenship_id := rosetta_g_miss_num_map(p1_a0);
    ddp_citizenship_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_citizenship_rec.birth_or_selected := p1_a2;
    ddp_citizenship_rec.country_code := p1_a3;
    ddp_citizenship_rec.date_recognized := rosetta_g_miss_date_in_map(p1_a4);
    ddp_citizenship_rec.date_disowned := rosetta_g_miss_date_in_map(p1_a5);
    ddp_citizenship_rec.end_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_citizenship_rec.document_type := p1_a7;
    ddp_citizenship_rec.document_reference := p1_a8;
    ddp_citizenship_rec.status := p1_a9;
    ddp_citizenship_rec.created_by_module := p1_a10;
    ddp_citizenship_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.create_citizenship(p_init_msg_list,
      ddp_citizenship_rec,
      x_citizenship_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_citizenship_5(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  DATE := null
    , p1_a6  DATE := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  NUMBER := null
  )
  as
    ddp_citizenship_rec hz_person_info_v2pub.citizenship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_citizenship_rec.citizenship_id := rosetta_g_miss_num_map(p1_a0);
    ddp_citizenship_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_citizenship_rec.birth_or_selected := p1_a2;
    ddp_citizenship_rec.country_code := p1_a3;
    ddp_citizenship_rec.date_recognized := rosetta_g_miss_date_in_map(p1_a4);
    ddp_citizenship_rec.date_disowned := rosetta_g_miss_date_in_map(p1_a5);
    ddp_citizenship_rec.end_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_citizenship_rec.document_type := p1_a7;
    ddp_citizenship_rec.document_reference := p1_a8;
    ddp_citizenship_rec.status := p1_a9;
    ddp_citizenship_rec.created_by_module := p1_a10;
    ddp_citizenship_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.update_citizenship(p_init_msg_list,
      ddp_citizenship_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_citizenship_rec_6(p_init_msg_list  VARCHAR2
    , p_citizenship_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  DATE
    , p2_a6 out nocopy  DATE
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_citizenship_rec hz_person_info_v2pub.citizenship_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.get_citizenship_rec(p_init_msg_list,
      p_citizenship_id,
      ddx_citizenship_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_citizenship_rec.citizenship_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_citizenship_rec.party_id);
    p2_a2 := ddx_citizenship_rec.birth_or_selected;
    p2_a3 := ddx_citizenship_rec.country_code;
    p2_a4 := ddx_citizenship_rec.date_recognized;
    p2_a5 := ddx_citizenship_rec.date_disowned;
    p2_a6 := ddx_citizenship_rec.end_date;
    p2_a7 := ddx_citizenship_rec.document_type;
    p2_a8 := ddx_citizenship_rec.document_reference;
    p2_a9 := ddx_citizenship_rec.status;
    p2_a10 := ddx_citizenship_rec.created_by_module;
    p2_a11 := rosetta_g_miss_num_map(ddx_citizenship_rec.application_id);



  end;

  procedure create_education_7(p_init_msg_list  VARCHAR2
    , x_education_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  DATE := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  NUMBER := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  NUMBER := null
  )
  as
    ddp_education_rec hz_person_info_v2pub.education_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_education_rec.education_id := rosetta_g_miss_num_map(p1_a0);
    ddp_education_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_education_rec.course_major := p1_a2;
    ddp_education_rec.degree_received := p1_a3;
    ddp_education_rec.start_date_attended := rosetta_g_miss_date_in_map(p1_a4);
    ddp_education_rec.last_date_attended := rosetta_g_miss_date_in_map(p1_a5);
    ddp_education_rec.school_attended_name := p1_a6;
    ddp_education_rec.school_party_id := rosetta_g_miss_num_map(p1_a7);
    ddp_education_rec.type_of_school := p1_a8;
    ddp_education_rec.status := p1_a9;
    ddp_education_rec.created_by_module := p1_a10;
    ddp_education_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.create_education(p_init_msg_list,
      ddp_education_rec,
      x_education_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_education_8(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  DATE := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  NUMBER := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  NUMBER := null
  )
  as
    ddp_education_rec hz_person_info_v2pub.education_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_education_rec.education_id := rosetta_g_miss_num_map(p1_a0);
    ddp_education_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_education_rec.course_major := p1_a2;
    ddp_education_rec.degree_received := p1_a3;
    ddp_education_rec.start_date_attended := rosetta_g_miss_date_in_map(p1_a4);
    ddp_education_rec.last_date_attended := rosetta_g_miss_date_in_map(p1_a5);
    ddp_education_rec.school_attended_name := p1_a6;
    ddp_education_rec.school_party_id := rosetta_g_miss_num_map(p1_a7);
    ddp_education_rec.type_of_school := p1_a8;
    ddp_education_rec.status := p1_a9;
    ddp_education_rec.created_by_module := p1_a10;
    ddp_education_rec.application_id := rosetta_g_miss_num_map(p1_a11);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.update_education(p_init_msg_list,
      ddp_education_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_education_rec_9(p_init_msg_list  VARCHAR2
    , p_education_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  DATE
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  NUMBER
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_education_rec hz_person_info_v2pub.education_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.get_education_rec(p_init_msg_list,
      p_education_id,
      ddx_education_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_education_rec.education_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_education_rec.party_id);
    p2_a2 := ddx_education_rec.course_major;
    p2_a3 := ddx_education_rec.degree_received;
    p2_a4 := ddx_education_rec.start_date_attended;
    p2_a5 := ddx_education_rec.last_date_attended;
    p2_a6 := ddx_education_rec.school_attended_name;
    p2_a7 := rosetta_g_miss_num_map(ddx_education_rec.school_party_id);
    p2_a8 := ddx_education_rec.type_of_school;
    p2_a9 := ddx_education_rec.status;
    p2_a10 := ddx_education_rec.created_by_module;
    p2_a11 := rosetta_g_miss_num_map(ddx_education_rec.application_id);



  end;

  procedure create_employment_history_10(p_init_msg_list  VARCHAR2
    , x_employment_history_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  DATE := null
    , p1_a3  DATE := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  NUMBER := null
  )
  as
    ddp_employment_history_rec hz_person_info_v2pub.employment_history_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_employment_history_rec.employment_history_id := rosetta_g_miss_num_map(p1_a0);
    ddp_employment_history_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_employment_history_rec.begin_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_employment_history_rec.end_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_employment_history_rec.employment_type_code := p1_a4;
    ddp_employment_history_rec.employed_as_title_code := p1_a5;
    ddp_employment_history_rec.employed_as_title := p1_a6;
    ddp_employment_history_rec.employed_by_name_company := p1_a7;
    ddp_employment_history_rec.employed_by_party_id := rosetta_g_miss_num_map(p1_a8);
    ddp_employment_history_rec.employed_by_division_name := p1_a9;
    ddp_employment_history_rec.supervisor_name := p1_a10;
    ddp_employment_history_rec.branch := p1_a11;
    ddp_employment_history_rec.military_rank := p1_a12;
    ddp_employment_history_rec.served := p1_a13;
    ddp_employment_history_rec.station := p1_a14;
    ddp_employment_history_rec.responsibility := p1_a15;
    ddp_employment_history_rec.weekly_work_hours := rosetta_g_miss_num_map(p1_a16);
    ddp_employment_history_rec.reason_for_leaving := p1_a17;
    ddp_employment_history_rec.faculty_position_flag := p1_a18;
    ddp_employment_history_rec.tenure_code := p1_a19;
    ddp_employment_history_rec.fraction_of_tenure := rosetta_g_miss_num_map(p1_a20);
    ddp_employment_history_rec.comments := p1_a21;
    ddp_employment_history_rec.status := p1_a22;
    ddp_employment_history_rec.created_by_module := p1_a23;
    ddp_employment_history_rec.application_id := rosetta_g_miss_num_map(p1_a24);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.create_employment_history(p_init_msg_list,
      ddp_employment_history_rec,
      x_employment_history_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_employment_history_11(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  DATE := null
    , p1_a3  DATE := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  NUMBER := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  NUMBER := null
  )
  as
    ddp_employment_history_rec hz_person_info_v2pub.employment_history_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_employment_history_rec.employment_history_id := rosetta_g_miss_num_map(p1_a0);
    ddp_employment_history_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_employment_history_rec.begin_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_employment_history_rec.end_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_employment_history_rec.employment_type_code := p1_a4;
    ddp_employment_history_rec.employed_as_title_code := p1_a5;
    ddp_employment_history_rec.employed_as_title := p1_a6;
    ddp_employment_history_rec.employed_by_name_company := p1_a7;
    ddp_employment_history_rec.employed_by_party_id := rosetta_g_miss_num_map(p1_a8);
    ddp_employment_history_rec.employed_by_division_name := p1_a9;
    ddp_employment_history_rec.supervisor_name := p1_a10;
    ddp_employment_history_rec.branch := p1_a11;
    ddp_employment_history_rec.military_rank := p1_a12;
    ddp_employment_history_rec.served := p1_a13;
    ddp_employment_history_rec.station := p1_a14;
    ddp_employment_history_rec.responsibility := p1_a15;
    ddp_employment_history_rec.weekly_work_hours := rosetta_g_miss_num_map(p1_a16);
    ddp_employment_history_rec.reason_for_leaving := p1_a17;
    ddp_employment_history_rec.faculty_position_flag := p1_a18;
    ddp_employment_history_rec.tenure_code := p1_a19;
    ddp_employment_history_rec.fraction_of_tenure := rosetta_g_miss_num_map(p1_a20);
    ddp_employment_history_rec.comments := p1_a21;
    ddp_employment_history_rec.status := p1_a22;
    ddp_employment_history_rec.created_by_module := p1_a23;
    ddp_employment_history_rec.application_id := rosetta_g_miss_num_map(p1_a24);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.update_employment_history(p_init_msg_list,
      ddp_employment_history_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_employment_history_rec_12(p_init_msg_list  VARCHAR2
    , p_employment_history_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  DATE
    , p2_a3 out nocopy  DATE
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  NUMBER
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  NUMBER
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  NUMBER
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_employment_history_rec hz_person_info_v2pub.employment_history_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.get_employment_history_rec(p_init_msg_list,
      p_employment_history_id,
      ddx_employment_history_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_employment_history_rec.employment_history_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_employment_history_rec.party_id);
    p2_a2 := ddx_employment_history_rec.begin_date;
    p2_a3 := ddx_employment_history_rec.end_date;
    p2_a4 := ddx_employment_history_rec.employment_type_code;
    p2_a5 := ddx_employment_history_rec.employed_as_title_code;
    p2_a6 := ddx_employment_history_rec.employed_as_title;
    p2_a7 := ddx_employment_history_rec.employed_by_name_company;
    p2_a8 := rosetta_g_miss_num_map(ddx_employment_history_rec.employed_by_party_id);
    p2_a9 := ddx_employment_history_rec.employed_by_division_name;
    p2_a10 := ddx_employment_history_rec.supervisor_name;
    p2_a11 := ddx_employment_history_rec.branch;
    p2_a12 := ddx_employment_history_rec.military_rank;
    p2_a13 := ddx_employment_history_rec.served;
    p2_a14 := ddx_employment_history_rec.station;
    p2_a15 := ddx_employment_history_rec.responsibility;
    p2_a16 := rosetta_g_miss_num_map(ddx_employment_history_rec.weekly_work_hours);
    p2_a17 := ddx_employment_history_rec.reason_for_leaving;
    p2_a18 := ddx_employment_history_rec.faculty_position_flag;
    p2_a19 := ddx_employment_history_rec.tenure_code;
    p2_a20 := rosetta_g_miss_num_map(ddx_employment_history_rec.fraction_of_tenure);
    p2_a21 := ddx_employment_history_rec.comments;
    p2_a22 := ddx_employment_history_rec.status;
    p2_a23 := ddx_employment_history_rec.created_by_module;
    p2_a24 := rosetta_g_miss_num_map(ddx_employment_history_rec.application_id);



  end;

  procedure create_work_class_13(p_init_msg_list  VARCHAR2
    , x_work_class_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
  )
  as
    ddp_work_class_rec hz_person_info_v2pub.work_class_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_work_class_rec.work_class_id := rosetta_g_miss_num_map(p1_a0);
    ddp_work_class_rec.level_of_experience := p1_a1;
    ddp_work_class_rec.work_class_name := p1_a2;
    ddp_work_class_rec.employment_history_id := rosetta_g_miss_num_map(p1_a3);
    ddp_work_class_rec.status := p1_a4;
    ddp_work_class_rec.created_by_module := p1_a5;
    ddp_work_class_rec.application_id := rosetta_g_miss_num_map(p1_a6);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.create_work_class(p_init_msg_list,
      ddp_work_class_rec,
      x_work_class_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_work_class_14(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
  )
  as
    ddp_work_class_rec hz_person_info_v2pub.work_class_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_work_class_rec.work_class_id := rosetta_g_miss_num_map(p1_a0);
    ddp_work_class_rec.level_of_experience := p1_a1;
    ddp_work_class_rec.work_class_name := p1_a2;
    ddp_work_class_rec.employment_history_id := rosetta_g_miss_num_map(p1_a3);
    ddp_work_class_rec.status := p1_a4;
    ddp_work_class_rec.created_by_module := p1_a5;
    ddp_work_class_rec.application_id := rosetta_g_miss_num_map(p1_a6);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.update_work_class(p_init_msg_list,
      ddp_work_class_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_work_class_rec_15(p_init_msg_list  VARCHAR2
    , p_work_class_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  NUMBER
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_work_class_rec hz_person_info_v2pub.work_class_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.get_work_class_rec(p_init_msg_list,
      p_work_class_id,
      ddx_work_class_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_work_class_rec.work_class_id);
    p2_a1 := ddx_work_class_rec.level_of_experience;
    p2_a2 := ddx_work_class_rec.work_class_name;
    p2_a3 := rosetta_g_miss_num_map(ddx_work_class_rec.employment_history_id);
    p2_a4 := ddx_work_class_rec.status;
    p2_a5 := ddx_work_class_rec.created_by_module;
    p2_a6 := rosetta_g_miss_num_map(ddx_work_class_rec.application_id);



  end;

  procedure create_person_interest_16(p_init_msg_list  VARCHAR2
    , x_person_interest_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  DATE := null
    , p1_a11  VARCHAR := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  NUMBER := null
  )
  as
    ddp_person_interest_rec hz_person_info_v2pub.person_interest_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_person_interest_rec.person_interest_id := rosetta_g_miss_num_map(p1_a0);
    ddp_person_interest_rec.level_of_interest := p1_a1;
    ddp_person_interest_rec.party_id := rosetta_g_miss_num_map(p1_a2);
    ddp_person_interest_rec.level_of_participation := p1_a3;
    ddp_person_interest_rec.interest_type_code := p1_a4;
    ddp_person_interest_rec.comments := p1_a5;
    ddp_person_interest_rec.sport_indicator := p1_a6;
    ddp_person_interest_rec.sub_interest_type_code := p1_a7;
    ddp_person_interest_rec.interest_name := p1_a8;
    ddp_person_interest_rec.team := p1_a9;
    ddp_person_interest_rec.since := rosetta_g_miss_date_in_map(p1_a10);
    ddp_person_interest_rec.status := p1_a11;
    ddp_person_interest_rec.created_by_module := p1_a12;
    ddp_person_interest_rec.application_id := rosetta_g_miss_num_map(p1_a13);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.create_person_interest(p_init_msg_list,
      ddp_person_interest_rec,
      x_person_interest_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_person_interest_17(p_init_msg_list  VARCHAR2
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
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  DATE := null
    , p1_a11  VARCHAR := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  NUMBER := null
  )
  as
    ddp_person_interest_rec hz_person_info_v2pub.person_interest_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_person_interest_rec.person_interest_id := rosetta_g_miss_num_map(p1_a0);
    ddp_person_interest_rec.level_of_interest := p1_a1;
    ddp_person_interest_rec.party_id := rosetta_g_miss_num_map(p1_a2);
    ddp_person_interest_rec.level_of_participation := p1_a3;
    ddp_person_interest_rec.interest_type_code := p1_a4;
    ddp_person_interest_rec.comments := p1_a5;
    ddp_person_interest_rec.sport_indicator := p1_a6;
    ddp_person_interest_rec.sub_interest_type_code := p1_a7;
    ddp_person_interest_rec.interest_name := p1_a8;
    ddp_person_interest_rec.team := p1_a9;
    ddp_person_interest_rec.since := rosetta_g_miss_date_in_map(p1_a10);
    ddp_person_interest_rec.status := p1_a11;
    ddp_person_interest_rec.created_by_module := p1_a12;
    ddp_person_interest_rec.application_id := rosetta_g_miss_num_map(p1_a13);





    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.update_person_interest(p_init_msg_list,
      ddp_person_interest_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_person_interest_rec_18(p_init_msg_list  VARCHAR2
    , p_person_interest_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  DATE
    , p2_a11 out nocopy  VARCHAR
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_person_interest_rec hz_person_info_v2pub.person_interest_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_person_info_v2pub.get_person_interest_rec(p_init_msg_list,
      p_person_interest_id,
      ddx_person_interest_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_person_interest_rec.person_interest_id);
    p2_a1 := ddx_person_interest_rec.level_of_interest;
    p2_a2 := rosetta_g_miss_num_map(ddx_person_interest_rec.party_id);
    p2_a3 := ddx_person_interest_rec.level_of_participation;
    p2_a4 := ddx_person_interest_rec.interest_type_code;
    p2_a5 := ddx_person_interest_rec.comments;
    p2_a6 := ddx_person_interest_rec.sport_indicator;
    p2_a7 := ddx_person_interest_rec.sub_interest_type_code;
    p2_a8 := ddx_person_interest_rec.interest_name;
    p2_a9 := ddx_person_interest_rec.team;
    p2_a10 := ddx_person_interest_rec.since;
    p2_a11 := ddx_person_interest_rec.status;
    p2_a12 := ddx_person_interest_rec.created_by_module;
    p2_a13 := rosetta_g_miss_num_map(ddx_person_interest_rec.application_id);



  end;

end hz_person_info_v2pub_jw;

/
