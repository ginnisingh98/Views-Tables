--------------------------------------------------------
--  DDL for Package Body PVX_MISC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_MISC_PVT_W" as
  /* $Header: pvxwmisb.pls 115.18 2002/11/21 08:07:35 anubhavk ship $ */
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

  procedure admin_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , x_access_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_admin_rec pvx_misc_pvt.admin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_admin_rec.partner_profile_id := rosetta_g_miss_num_map(p7_a0);
    ddp_admin_rec.logged_resource_id := rosetta_g_miss_num_map(p7_a1);
    ddp_admin_rec.cm_id := rosetta_g_miss_num_map(p7_a2);
    ddp_admin_rec.ph_support_rep := rosetta_g_miss_num_map(p7_a3);
    ddp_admin_rec.cmm_id := rosetta_g_miss_num_map(p7_a4);
    ddp_admin_rec.partner_id := rosetta_g_miss_num_map(p7_a5);
    ddp_admin_rec.partner_relationship_id := rosetta_g_miss_num_map(p7_a6);
    ddp_admin_rec.contact_id := rosetta_g_miss_num_map(p7_a7);
    ddp_admin_rec.user_id := rosetta_g_miss_num_map(p7_a8);
    ddp_admin_rec.resource_type := p7_a9;
    ddp_admin_rec.role_resource_id := rosetta_g_miss_num_map(p7_a10);
    ddp_admin_rec.role_resource_type := p7_a11;
    ddp_admin_rec.role_code := p7_a12;
    ddp_admin_rec.resource_number := p7_a13;
    ddp_admin_rec.group_id := rosetta_g_miss_num_map(p7_a14);
    ddp_admin_rec.group_number := p7_a15;
    ddp_admin_rec.group_usage := p7_a16;
    ddp_admin_rec.source_name := p7_a17;
    ddp_admin_rec.resource_name := p7_a18;
    ddp_admin_rec.source_org_name := p7_a19;
    ddp_admin_rec.source_org_id := rosetta_g_miss_num_map(p7_a20);
    ddp_admin_rec.user_name := p7_a21;
    ddp_admin_rec.source_first_name := p7_a22;
    ddp_admin_rec.source_middle_name := p7_a23;
    ddp_admin_rec.source_last_name := p7_a24;
    ddp_admin_rec.party_site_id := rosetta_g_miss_num_map(p7_a25);
    ddp_admin_rec.object_version_number := rosetta_g_miss_num_map(p7_a26);



    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.admin_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_admin_rec,
      p_mode,
      x_access_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure admin_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , x_resource_id out nocopy  NUMBER
    , x_resource_number out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_admin_rec pvx_misc_pvt.admin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_admin_rec.partner_profile_id := rosetta_g_miss_num_map(p6_a0);
    ddp_admin_rec.logged_resource_id := rosetta_g_miss_num_map(p6_a1);
    ddp_admin_rec.cm_id := rosetta_g_miss_num_map(p6_a2);
    ddp_admin_rec.ph_support_rep := rosetta_g_miss_num_map(p6_a3);
    ddp_admin_rec.cmm_id := rosetta_g_miss_num_map(p6_a4);
    ddp_admin_rec.partner_id := rosetta_g_miss_num_map(p6_a5);
    ddp_admin_rec.partner_relationship_id := rosetta_g_miss_num_map(p6_a6);
    ddp_admin_rec.contact_id := rosetta_g_miss_num_map(p6_a7);
    ddp_admin_rec.user_id := rosetta_g_miss_num_map(p6_a8);
    ddp_admin_rec.resource_type := p6_a9;
    ddp_admin_rec.role_resource_id := rosetta_g_miss_num_map(p6_a10);
    ddp_admin_rec.role_resource_type := p6_a11;
    ddp_admin_rec.role_code := p6_a12;
    ddp_admin_rec.resource_number := p6_a13;
    ddp_admin_rec.group_id := rosetta_g_miss_num_map(p6_a14);
    ddp_admin_rec.group_number := p6_a15;
    ddp_admin_rec.group_usage := p6_a16;
    ddp_admin_rec.source_name := p6_a17;
    ddp_admin_rec.resource_name := p6_a18;
    ddp_admin_rec.source_org_name := p6_a19;
    ddp_admin_rec.source_org_id := rosetta_g_miss_num_map(p6_a20);
    ddp_admin_rec.user_name := p6_a21;
    ddp_admin_rec.source_first_name := p6_a22;
    ddp_admin_rec.source_middle_name := p6_a23;
    ddp_admin_rec.source_last_name := p6_a24;
    ddp_admin_rec.party_site_id := rosetta_g_miss_num_map(p6_a25);
    ddp_admin_rec.object_version_number := rosetta_g_miss_num_map(p6_a26);




    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.admin_resource(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_admin_rec,
      p_mode,
      x_resource_id,
      x_resource_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure admin_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , x_role_relate_id out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_admin_rec pvx_misc_pvt.admin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_admin_rec.partner_profile_id := rosetta_g_miss_num_map(p6_a0);
    ddp_admin_rec.logged_resource_id := rosetta_g_miss_num_map(p6_a1);
    ddp_admin_rec.cm_id := rosetta_g_miss_num_map(p6_a2);
    ddp_admin_rec.ph_support_rep := rosetta_g_miss_num_map(p6_a3);
    ddp_admin_rec.cmm_id := rosetta_g_miss_num_map(p6_a4);
    ddp_admin_rec.partner_id := rosetta_g_miss_num_map(p6_a5);
    ddp_admin_rec.partner_relationship_id := rosetta_g_miss_num_map(p6_a6);
    ddp_admin_rec.contact_id := rosetta_g_miss_num_map(p6_a7);
    ddp_admin_rec.user_id := rosetta_g_miss_num_map(p6_a8);
    ddp_admin_rec.resource_type := p6_a9;
    ddp_admin_rec.role_resource_id := rosetta_g_miss_num_map(p6_a10);
    ddp_admin_rec.role_resource_type := p6_a11;
    ddp_admin_rec.role_code := p6_a12;
    ddp_admin_rec.resource_number := p6_a13;
    ddp_admin_rec.group_id := rosetta_g_miss_num_map(p6_a14);
    ddp_admin_rec.group_number := p6_a15;
    ddp_admin_rec.group_usage := p6_a16;
    ddp_admin_rec.source_name := p6_a17;
    ddp_admin_rec.resource_name := p6_a18;
    ddp_admin_rec.source_org_name := p6_a19;
    ddp_admin_rec.source_org_id := rosetta_g_miss_num_map(p6_a20);
    ddp_admin_rec.user_name := p6_a21;
    ddp_admin_rec.source_first_name := p6_a22;
    ddp_admin_rec.source_middle_name := p6_a23;
    ddp_admin_rec.source_last_name := p6_a24;
    ddp_admin_rec.party_site_id := rosetta_g_miss_num_map(p6_a25);
    ddp_admin_rec.object_version_number := rosetta_g_miss_num_map(p6_a26);



    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.admin_role(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_admin_rec,
      p_mode,
      x_role_relate_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure admin_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , x_group_id out nocopy  NUMBER
    , x_group_number out nocopy  VARCHAR2
    , x_group_usage_id out nocopy  NUMBER
    , x_group_member_id out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_admin_rec pvx_misc_pvt.admin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_admin_rec.partner_profile_id := rosetta_g_miss_num_map(p6_a0);
    ddp_admin_rec.logged_resource_id := rosetta_g_miss_num_map(p6_a1);
    ddp_admin_rec.cm_id := rosetta_g_miss_num_map(p6_a2);
    ddp_admin_rec.ph_support_rep := rosetta_g_miss_num_map(p6_a3);
    ddp_admin_rec.cmm_id := rosetta_g_miss_num_map(p6_a4);
    ddp_admin_rec.partner_id := rosetta_g_miss_num_map(p6_a5);
    ddp_admin_rec.partner_relationship_id := rosetta_g_miss_num_map(p6_a6);
    ddp_admin_rec.contact_id := rosetta_g_miss_num_map(p6_a7);
    ddp_admin_rec.user_id := rosetta_g_miss_num_map(p6_a8);
    ddp_admin_rec.resource_type := p6_a9;
    ddp_admin_rec.role_resource_id := rosetta_g_miss_num_map(p6_a10);
    ddp_admin_rec.role_resource_type := p6_a11;
    ddp_admin_rec.role_code := p6_a12;
    ddp_admin_rec.resource_number := p6_a13;
    ddp_admin_rec.group_id := rosetta_g_miss_num_map(p6_a14);
    ddp_admin_rec.group_number := p6_a15;
    ddp_admin_rec.group_usage := p6_a16;
    ddp_admin_rec.source_name := p6_a17;
    ddp_admin_rec.resource_name := p6_a18;
    ddp_admin_rec.source_org_name := p6_a19;
    ddp_admin_rec.source_org_id := rosetta_g_miss_num_map(p6_a20);
    ddp_admin_rec.user_name := p6_a21;
    ddp_admin_rec.source_first_name := p6_a22;
    ddp_admin_rec.source_middle_name := p6_a23;
    ddp_admin_rec.source_last_name := p6_a24;
    ddp_admin_rec.party_site_id := rosetta_g_miss_num_map(p6_a25);
    ddp_admin_rec.object_version_number := rosetta_g_miss_num_map(p6_a26);






    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.admin_group(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_admin_rec,
      p_mode,
      x_group_id,
      x_group_number,
      x_group_usage_id,
      x_group_member_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure admin_group_member(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , x_group_member_id out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_admin_rec pvx_misc_pvt.admin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_admin_rec.partner_profile_id := rosetta_g_miss_num_map(p6_a0);
    ddp_admin_rec.logged_resource_id := rosetta_g_miss_num_map(p6_a1);
    ddp_admin_rec.cm_id := rosetta_g_miss_num_map(p6_a2);
    ddp_admin_rec.ph_support_rep := rosetta_g_miss_num_map(p6_a3);
    ddp_admin_rec.cmm_id := rosetta_g_miss_num_map(p6_a4);
    ddp_admin_rec.partner_id := rosetta_g_miss_num_map(p6_a5);
    ddp_admin_rec.partner_relationship_id := rosetta_g_miss_num_map(p6_a6);
    ddp_admin_rec.contact_id := rosetta_g_miss_num_map(p6_a7);
    ddp_admin_rec.user_id := rosetta_g_miss_num_map(p6_a8);
    ddp_admin_rec.resource_type := p6_a9;
    ddp_admin_rec.role_resource_id := rosetta_g_miss_num_map(p6_a10);
    ddp_admin_rec.role_resource_type := p6_a11;
    ddp_admin_rec.role_code := p6_a12;
    ddp_admin_rec.resource_number := p6_a13;
    ddp_admin_rec.group_id := rosetta_g_miss_num_map(p6_a14);
    ddp_admin_rec.group_number := p6_a15;
    ddp_admin_rec.group_usage := p6_a16;
    ddp_admin_rec.source_name := p6_a17;
    ddp_admin_rec.resource_name := p6_a18;
    ddp_admin_rec.source_org_name := p6_a19;
    ddp_admin_rec.source_org_id := rosetta_g_miss_num_map(p6_a20);
    ddp_admin_rec.user_name := p6_a21;
    ddp_admin_rec.source_first_name := p6_a22;
    ddp_admin_rec.source_middle_name := p6_a23;
    ddp_admin_rec.source_last_name := p6_a24;
    ddp_admin_rec.party_site_id := rosetta_g_miss_num_map(p6_a25);
    ddp_admin_rec.object_version_number := rosetta_g_miss_num_map(p6_a26);



    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.admin_group_member(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_admin_rec,
      p_mode,
      x_group_member_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_user(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_fnd_rec pvx_misc_pvt.fnd_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_fnd_rec.user_id := rosetta_g_miss_num_map(p6_a0);
    ddp_fnd_rec.user_name := p6_a1;
    ddp_fnd_rec.owner := p6_a2;
    ddp_fnd_rec.start_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_fnd_rec.end_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_fnd_rec.email_address := p6_a5;
    ddp_fnd_rec.resp_app_short_name := p6_a6;
    ddp_fnd_rec.resp_key := p6_a7;
    ddp_fnd_rec.security_group := p6_a8;
    ddp_fnd_rec.resp_id := rosetta_g_miss_num_map(p6_a9);
    ddp_fnd_rec.resp_app_id := rosetta_g_miss_num_map(p6_a10);

    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.update_user(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fnd_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure disable_responsibility(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_fnd_rec pvx_misc_pvt.fnd_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_fnd_rec.user_id := rosetta_g_miss_num_map(p6_a0);
    ddp_fnd_rec.user_name := p6_a1;
    ddp_fnd_rec.owner := p6_a2;
    ddp_fnd_rec.start_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_fnd_rec.end_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_fnd_rec.email_address := p6_a5;
    ddp_fnd_rec.resp_app_short_name := p6_a6;
    ddp_fnd_rec.resp_key := p6_a7;
    ddp_fnd_rec.security_group := p6_a8;
    ddp_fnd_rec.resp_id := rosetta_g_miss_num_map(p6_a9);
    ddp_fnd_rec.resp_app_id := rosetta_g_miss_num_map(p6_a10);


    -- here's the delegated call to the old PL/SQL routine
    pvx_misc_pvt.disable_responsibility(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fnd_rec,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end pvx_misc_pvt_w;

/
