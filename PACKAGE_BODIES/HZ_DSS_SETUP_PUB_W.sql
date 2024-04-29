--------------------------------------------------------
--  DDL for Package Body HZ_DSS_SETUP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_SETUP_PUB_W" as
  /* $Header: ARHPDSJB.pls 120.2 2005/06/18 04:28:05 jhuang noship $ */
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

  procedure create_entity_profile_1(p_init_msg_list  VARCHAR2
    , x_entity_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_entity_profile hz_dss_setup_pub.dss_entity_profile_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_entity_profile.entity_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_entity_profile.object_id := rosetta_g_miss_num_map(p1_a1);
    ddp_dss_entity_profile.instance_set_id := rosetta_g_miss_num_map(p1_a2);
    ddp_dss_entity_profile.parent_entity_id := rosetta_g_miss_num_map(p1_a3);
    ddp_dss_entity_profile.status := p1_a4;
    ddp_dss_entity_profile.parent_fk_column1 := p1_a5;
    ddp_dss_entity_profile.parent_fk_column2 := p1_a6;
    ddp_dss_entity_profile.parent_fk_column3 := p1_a7;
    ddp_dss_entity_profile.parent_fk_column4 := p1_a8;
    ddp_dss_entity_profile.parent_fk_column5 := p1_a9;
    ddp_dss_entity_profile.group_assignment_level := p1_a10;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_setup_pub.create_entity_profile(p_init_msg_list,
      ddp_dss_entity_profile,
      x_entity_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_entity_profile_2(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_entity_profile hz_dss_setup_pub.dss_entity_profile_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_entity_profile.entity_id := rosetta_g_miss_num_map(p1_a0);
    ddp_dss_entity_profile.object_id := rosetta_g_miss_num_map(p1_a1);
    ddp_dss_entity_profile.instance_set_id := rosetta_g_miss_num_map(p1_a2);
    ddp_dss_entity_profile.parent_entity_id := rosetta_g_miss_num_map(p1_a3);
    ddp_dss_entity_profile.status := p1_a4;
    ddp_dss_entity_profile.parent_fk_column1 := p1_a5;
    ddp_dss_entity_profile.parent_fk_column2 := p1_a6;
    ddp_dss_entity_profile.parent_fk_column3 := p1_a7;
    ddp_dss_entity_profile.parent_fk_column4 := p1_a8;
    ddp_dss_entity_profile.parent_fk_column5 := p1_a9;
    ddp_dss_entity_profile.group_assignment_level := p1_a10;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_setup_pub.update_entity_profile(p_init_msg_list,
      ddp_dss_entity_profile,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_scheme_function_3(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_scheme_function hz_dss_setup_pub.dss_scheme_function_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_scheme_function.security_scheme_code := p1_a0;
    ddp_dss_scheme_function.data_operation_code := p1_a1;
    ddp_dss_scheme_function.function_id := rosetta_g_miss_num_map(p1_a2);
    ddp_dss_scheme_function.status := p1_a3;




    -- here's the delegated call to the old PL/SQL routine
    hz_dss_setup_pub.create_scheme_function(p_init_msg_list,
      ddp_dss_scheme_function,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure update_scheme_function_4(p_init_msg_list  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_dss_scheme_function hz_dss_setup_pub.dss_scheme_function_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_dss_scheme_function.security_scheme_code := p1_a0;
    ddp_dss_scheme_function.data_operation_code := p1_a1;
    ddp_dss_scheme_function.function_id := rosetta_g_miss_num_map(p1_a2);
    ddp_dss_scheme_function.status := p1_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_dss_setup_pub.update_scheme_function(p_init_msg_list,
      ddp_dss_scheme_function,
      x_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end hz_dss_setup_pub_w;

/
