--------------------------------------------------------
--  DDL for Package Body PVX_MDF_OWNERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_MDF_OWNERS_PVT_W" as
  /* $Header: pvxwmdfb.pls 115.8 2002/12/11 12:22:25 anubhavk ship $ */
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

  procedure create_mdf_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_mdf_owner_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mdf_owner_rec.mdf_owner_id := rosetta_g_miss_num_map(p7_a0);
    ddp_mdf_owner_rec.country := p7_a1;
    ddp_mdf_owner_rec.from_postal_code := p7_a2;
    ddp_mdf_owner_rec.to_postal_code := p7_a3;
    ddp_mdf_owner_rec.cmm_resource_id := rosetta_g_miss_num_map(p7_a4);
    ddp_mdf_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_mdf_owner_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_mdf_owner_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_mdf_owner_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_mdf_owner_rec.last_update_login := rosetta_g_miss_num_map(p7_a9);
    ddp_mdf_owner_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);
    ddp_mdf_owner_rec.request_id := rosetta_g_miss_num_map(p7_a11);
    ddp_mdf_owner_rec.program_application_id := rosetta_g_miss_num_map(p7_a12);
    ddp_mdf_owner_rec.program_id := rosetta_g_miss_num_map(p7_a13);
    ddp_mdf_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a14);


    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.create_mdf_owner(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mdf_owner_rec,
      x_mdf_owner_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_mdf_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mdf_owner_rec.mdf_owner_id := rosetta_g_miss_num_map(p7_a0);
    ddp_mdf_owner_rec.country := p7_a1;
    ddp_mdf_owner_rec.from_postal_code := p7_a2;
    ddp_mdf_owner_rec.to_postal_code := p7_a3;
    ddp_mdf_owner_rec.cmm_resource_id := rosetta_g_miss_num_map(p7_a4);
    ddp_mdf_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_mdf_owner_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_mdf_owner_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_mdf_owner_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_mdf_owner_rec.last_update_login := rosetta_g_miss_num_map(p7_a9);
    ddp_mdf_owner_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);
    ddp_mdf_owner_rec.request_id := rosetta_g_miss_num_map(p7_a11);
    ddp_mdf_owner_rec.program_application_id := rosetta_g_miss_num_map(p7_a12);
    ddp_mdf_owner_rec.program_id := rosetta_g_miss_num_map(p7_a13);
    ddp_mdf_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a14);

    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.update_mdf_owner(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mdf_owner_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_mdf_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  DATE := fnd_api.g_miss_date
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_mdf_owner_rec.mdf_owner_id := rosetta_g_miss_num_map(p6_a0);
    ddp_mdf_owner_rec.country := p6_a1;
    ddp_mdf_owner_rec.from_postal_code := p6_a2;
    ddp_mdf_owner_rec.to_postal_code := p6_a3;
    ddp_mdf_owner_rec.cmm_resource_id := rosetta_g_miss_num_map(p6_a4);
    ddp_mdf_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_mdf_owner_rec.last_updated_by := rosetta_g_miss_num_map(p6_a6);
    ddp_mdf_owner_rec.creation_date := rosetta_g_miss_date_in_map(p6_a7);
    ddp_mdf_owner_rec.created_by := rosetta_g_miss_num_map(p6_a8);
    ddp_mdf_owner_rec.last_update_login := rosetta_g_miss_num_map(p6_a9);
    ddp_mdf_owner_rec.object_version_number := rosetta_g_miss_num_map(p6_a10);
    ddp_mdf_owner_rec.request_id := rosetta_g_miss_num_map(p6_a11);
    ddp_mdf_owner_rec.program_application_id := rosetta_g_miss_num_map(p6_a12);
    ddp_mdf_owner_rec.program_id := rosetta_g_miss_num_map(p6_a13);
    ddp_mdf_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a14);

    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.validate_mdf_owner(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mdf_owner_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_mdf_owner_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  VARCHAR2 := fnd_api.g_miss_char
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  DATE := fnd_api.g_miss_date
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  NUMBER := 0-1962.0724
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  NUMBER := 0-1962.0724
    , p2_a12  NUMBER := 0-1962.0724
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_mdf_owner_rec.mdf_owner_id := rosetta_g_miss_num_map(p2_a0);
    ddp_mdf_owner_rec.country := p2_a1;
    ddp_mdf_owner_rec.from_postal_code := p2_a2;
    ddp_mdf_owner_rec.to_postal_code := p2_a3;
    ddp_mdf_owner_rec.cmm_resource_id := rosetta_g_miss_num_map(p2_a4);
    ddp_mdf_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a5);
    ddp_mdf_owner_rec.last_updated_by := rosetta_g_miss_num_map(p2_a6);
    ddp_mdf_owner_rec.creation_date := rosetta_g_miss_date_in_map(p2_a7);
    ddp_mdf_owner_rec.created_by := rosetta_g_miss_num_map(p2_a8);
    ddp_mdf_owner_rec.last_update_login := rosetta_g_miss_num_map(p2_a9);
    ddp_mdf_owner_rec.object_version_number := rosetta_g_miss_num_map(p2_a10);
    ddp_mdf_owner_rec.request_id := rosetta_g_miss_num_map(p2_a11);
    ddp_mdf_owner_rec.program_application_id := rosetta_g_miss_num_map(p2_a12);
    ddp_mdf_owner_rec.program_id := rosetta_g_miss_num_map(p2_a13);
    ddp_mdf_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a14);

    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.check_mdf_owner_items(p_validation_mode,
      x_return_status,
      ddp_mdf_owner_rec);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_mdf_owner_rec(p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  DATE := fnd_api.g_miss_date
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  NUMBER := 0-1962.0724
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddp_complete_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_mdf_owner_rec.mdf_owner_id := rosetta_g_miss_num_map(p0_a0);
    ddp_mdf_owner_rec.country := p0_a1;
    ddp_mdf_owner_rec.from_postal_code := p0_a2;
    ddp_mdf_owner_rec.to_postal_code := p0_a3;
    ddp_mdf_owner_rec.cmm_resource_id := rosetta_g_miss_num_map(p0_a4);
    ddp_mdf_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_mdf_owner_rec.last_updated_by := rosetta_g_miss_num_map(p0_a6);
    ddp_mdf_owner_rec.creation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_mdf_owner_rec.created_by := rosetta_g_miss_num_map(p0_a8);
    ddp_mdf_owner_rec.last_update_login := rosetta_g_miss_num_map(p0_a9);
    ddp_mdf_owner_rec.object_version_number := rosetta_g_miss_num_map(p0_a10);
    ddp_mdf_owner_rec.request_id := rosetta_g_miss_num_map(p0_a11);
    ddp_mdf_owner_rec.program_application_id := rosetta_g_miss_num_map(p0_a12);
    ddp_mdf_owner_rec.program_id := rosetta_g_miss_num_map(p0_a13);
    ddp_mdf_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a14);

    ddp_complete_rec.mdf_owner_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.country := p1_a1;
    ddp_complete_rec.from_postal_code := p1_a2;
    ddp_complete_rec.to_postal_code := p1_a3;
    ddp_complete_rec.cmm_resource_id := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a5);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a10);
    ddp_complete_rec.request_id := rosetta_g_miss_num_map(p1_a11);
    ddp_complete_rec.program_application_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.program_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a14);



    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.check_mdf_owner_rec(ddp_mdf_owner_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any



  end;

  procedure init_mdf_owner_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  VARCHAR2
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  DATE
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  DATE
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  DATE
  )
  as
    ddx_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.init_mdf_owner_rec(ddx_mdf_owner_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.mdf_owner_id);
    p0_a1 := ddx_mdf_owner_rec.country;
    p0_a2 := ddx_mdf_owner_rec.from_postal_code;
    p0_a3 := ddx_mdf_owner_rec.to_postal_code;
    p0_a4 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.cmm_resource_id);
    p0_a5 := ddx_mdf_owner_rec.last_update_date;
    p0_a6 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.last_updated_by);
    p0_a7 := ddx_mdf_owner_rec.creation_date;
    p0_a8 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.created_by);
    p0_a9 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.last_update_login);
    p0_a10 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.object_version_number);
    p0_a11 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.request_id);
    p0_a12 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.program_application_id);
    p0_a13 := rosetta_g_miss_num_map(ddx_mdf_owner_rec.program_id);
    p0_a14 := ddx_mdf_owner_rec.program_update_date;
  end;

  procedure complete_mdf_owner_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  DATE
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  DATE
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
  )
  as
    ddp_mdf_owner_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddx_complete_rec pvx_mdf_owners_pvt.mdf_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_mdf_owner_rec.mdf_owner_id := rosetta_g_miss_num_map(p0_a0);
    ddp_mdf_owner_rec.country := p0_a1;
    ddp_mdf_owner_rec.from_postal_code := p0_a2;
    ddp_mdf_owner_rec.to_postal_code := p0_a3;
    ddp_mdf_owner_rec.cmm_resource_id := rosetta_g_miss_num_map(p0_a4);
    ddp_mdf_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_mdf_owner_rec.last_updated_by := rosetta_g_miss_num_map(p0_a6);
    ddp_mdf_owner_rec.creation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_mdf_owner_rec.created_by := rosetta_g_miss_num_map(p0_a8);
    ddp_mdf_owner_rec.last_update_login := rosetta_g_miss_num_map(p0_a9);
    ddp_mdf_owner_rec.object_version_number := rosetta_g_miss_num_map(p0_a10);
    ddp_mdf_owner_rec.request_id := rosetta_g_miss_num_map(p0_a11);
    ddp_mdf_owner_rec.program_application_id := rosetta_g_miss_num_map(p0_a12);
    ddp_mdf_owner_rec.program_id := rosetta_g_miss_num_map(p0_a13);
    ddp_mdf_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a14);


    -- here's the delegated call to the old PL/SQL routine
    pvx_mdf_owners_pvt.complete_mdf_owner_rec(ddp_mdf_owner_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.mdf_owner_id);
    p1_a1 := ddx_complete_rec.country;
    p1_a2 := ddx_complete_rec.from_postal_code;
    p1_a3 := ddx_complete_rec.to_postal_code;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.cmm_resource_id);
    p1_a5 := ddx_complete_rec.last_update_date;
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a7 := ddx_complete_rec.creation_date;
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.request_id);
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.program_application_id);
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.program_id);
    p1_a14 := ddx_complete_rec.program_update_date;
  end;

end pvx_mdf_owners_pvt_w;

/
