--------------------------------------------------------
--  DDL for Package Body JTF_UM_INDIVIDUAL_USER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_INDIVIDUAL_USER_PVT_W" as
  /* $Header: JTFWUIRB.pls 120.2 2005/09/02 18:36:56 applrt ship $ */
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

  procedure registerindividualuser(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_self_service_user  VARCHAR2
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_um_person_rec jtf_um_register_user_pvt.person_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_um_person_rec.first_name := p4_a0;
    ddp_um_person_rec.last_name := p4_a1;
    ddp_um_person_rec.user_name := p4_a2;
    ddp_um_person_rec.password := p4_a3;
    ddp_um_person_rec.phone_area_code := p4_a4;
    ddp_um_person_rec.phone_number := p4_a5;
    ddp_um_person_rec.email_address := p4_a6;
    ddp_um_person_rec.party_id := rosetta_g_miss_num_map(p4_a7);
    ddp_um_person_rec.user_id := rosetta_g_miss_num_map(p4_a8);
    ddp_um_person_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_um_person_rec.privacy_preference := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    jtf_um_individual_user_pvt.registerindividualuser(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_self_service_user,
      ddp_um_person_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_um_person_rec.first_name;
    p4_a1 := ddp_um_person_rec.last_name;
    p4_a2 := ddp_um_person_rec.user_name;
    p4_a3 := ddp_um_person_rec.password;
    p4_a4 := ddp_um_person_rec.phone_area_code;
    p4_a5 := ddp_um_person_rec.phone_number;
    p4_a6 := ddp_um_person_rec.email_address;
    p4_a7 := rosetta_g_miss_num_map(ddp_um_person_rec.party_id);
    p4_a8 := rosetta_g_miss_num_map(ddp_um_person_rec.user_id);
    p4_a9 := ddp_um_person_rec.start_date_active;
    p4_a10 := ddp_um_person_rec.privacy_preference;



  end;

end jtf_um_individual_user_pvt_w;

/
