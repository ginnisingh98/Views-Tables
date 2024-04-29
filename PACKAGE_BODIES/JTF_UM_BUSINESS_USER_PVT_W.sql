--------------------------------------------------------
--  DDL for Package Body JTF_UM_BUSINESS_USER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_BUSINESS_USER_PVT_W" as
  /* $Header: JTFWUBRB.pls 120.4 2005/12/14 06:25 snellepa ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure registerbusinessuser(p_api_version_number  NUMBER
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
    , p5_a0 in out nocopy  VARCHAR2
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  NUMBER
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_um_person_rec jtf_um_register_user_pvt.person_rec_type;
    ddp_um_organization_rec jtf_um_register_user_pvt.organization_rec_type;
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
    ddp_um_person_rec.party_id := p4_a7;
    ddp_um_person_rec.user_id := p4_a8;
    ddp_um_person_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_um_person_rec.privacy_preference := p4_a10;

    ddp_um_organization_rec.organization_number := p5_a0;
    ddp_um_organization_rec.organization_name := p5_a1;
    ddp_um_organization_rec.address1 := p5_a2;
    ddp_um_organization_rec.address2 := p5_a3;
    ddp_um_organization_rec.address3 := p5_a4;
    ddp_um_organization_rec.address4 := p5_a5;
    ddp_um_organization_rec.city := p5_a6;
    ddp_um_organization_rec.state := p5_a7;
    ddp_um_organization_rec.postal_code := p5_a8;
    ddp_um_organization_rec.county := p5_a9;
    ddp_um_organization_rec.province := p5_a10;
    ddp_um_organization_rec.altaddress := p5_a11;
    ddp_um_organization_rec.country := p5_a12;
    ddp_um_organization_rec.phone_area_code := p5_a13;
    ddp_um_organization_rec.phone_number := p5_a14;
    ddp_um_organization_rec.fax_area_code := p5_a15;
    ddp_um_organization_rec.fax_number := p5_a16;
    ddp_um_organization_rec.org_party_id := p5_a17;
    ddp_um_organization_rec.org_contact_party_id := p5_a18;
    ddp_um_organization_rec.start_date_active := rosetta_g_miss_date_in_map(p5_a19);




    -- here's the delegated call to the old PL/SQL routine
    jtf_um_business_user_pvt.registerbusinessuser(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_self_service_user,
      ddp_um_person_rec,
      ddp_um_organization_rec,
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
    p4_a7 := ddp_um_person_rec.party_id;
    p4_a8 := ddp_um_person_rec.user_id;
    p4_a9 := ddp_um_person_rec.start_date_active;
    p4_a10 := ddp_um_person_rec.privacy_preference;

    p5_a0 := ddp_um_organization_rec.organization_number;
    p5_a1 := ddp_um_organization_rec.organization_name;
    p5_a2 := ddp_um_organization_rec.address1;
    p5_a3 := ddp_um_organization_rec.address2;
    p5_a4 := ddp_um_organization_rec.address3;
    p5_a5 := ddp_um_organization_rec.address4;
    p5_a6 := ddp_um_organization_rec.city;
    p5_a7 := ddp_um_organization_rec.state;
    p5_a8 := ddp_um_organization_rec.postal_code;
    p5_a9 := ddp_um_organization_rec.county;
    p5_a10 := ddp_um_organization_rec.province;
    p5_a11 := ddp_um_organization_rec.altaddress;
    p5_a12 := ddp_um_organization_rec.country;
    p5_a13 := ddp_um_organization_rec.phone_area_code;
    p5_a14 := ddp_um_organization_rec.phone_number;
    p5_a15 := ddp_um_organization_rec.fax_area_code;
    p5_a16 := ddp_um_organization_rec.fax_number;
    p5_a17 := ddp_um_organization_rec.org_party_id;
    p5_a18 := ddp_um_organization_rec.org_contact_party_id;
    p5_a19 := ddp_um_organization_rec.start_date_active;



  end;

  procedure find_organization(p0_a0 in out nocopy  VARCHAR2
    , p0_a1 in out nocopy  VARCHAR2
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  VARCHAR2
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  NUMBER
    , p0_a19 in out nocopy  DATE
    , p_search_value  VARCHAR2
    , p_use_name  number
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddx_org_rec jtf_um_register_user_pvt.organization_rec_type;
    ddp_use_name boolean;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddx_org_rec.organization_number := p0_a0;
    ddx_org_rec.organization_name := p0_a1;
    ddx_org_rec.address1 := p0_a2;
    ddx_org_rec.address2 := p0_a3;
    ddx_org_rec.address3 := p0_a4;
    ddx_org_rec.address4 := p0_a5;
    ddx_org_rec.city := p0_a6;
    ddx_org_rec.state := p0_a7;
    ddx_org_rec.postal_code := p0_a8;
    ddx_org_rec.county := p0_a9;
    ddx_org_rec.province := p0_a10;
    ddx_org_rec.altaddress := p0_a11;
    ddx_org_rec.country := p0_a12;
    ddx_org_rec.phone_area_code := p0_a13;
    ddx_org_rec.phone_number := p0_a14;
    ddx_org_rec.fax_area_code := p0_a15;
    ddx_org_rec.fax_number := p0_a16;
    ddx_org_rec.org_party_id := p0_a17;
    ddx_org_rec.org_contact_party_id := p0_a18;
    ddx_org_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a19);


    if p_use_name is null
      then ddp_use_name := null;
    elsif p_use_name = 0
      then ddp_use_name := false;
    else ddp_use_name := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_um_business_user_pvt.find_organization(ddx_org_rec,
      p_search_value,
      ddp_use_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
    p0_a0 := ddx_org_rec.organization_number;
    p0_a1 := ddx_org_rec.organization_name;
    p0_a2 := ddx_org_rec.address1;
    p0_a3 := ddx_org_rec.address2;
    p0_a4 := ddx_org_rec.address3;
    p0_a5 := ddx_org_rec.address4;
    p0_a6 := ddx_org_rec.city;
    p0_a7 := ddx_org_rec.state;
    p0_a8 := ddx_org_rec.postal_code;
    p0_a9 := ddx_org_rec.county;
    p0_a10 := ddx_org_rec.province;
    p0_a11 := ddx_org_rec.altaddress;
    p0_a12 := ddx_org_rec.country;
    p0_a13 := ddx_org_rec.phone_area_code;
    p0_a14 := ddx_org_rec.phone_number;
    p0_a15 := ddx_org_rec.fax_area_code;
    p0_a16 := ddx_org_rec.fax_number;
    p0_a17 := ddx_org_rec.org_party_id;
    p0_a18 := ddx_org_rec.org_contact_party_id;
    p0_a19 := ddx_org_rec.start_date_active;


  end;

  procedure create_organization(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  VARCHAR2
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  VARCHAR2
    , p3_a4 in out nocopy  VARCHAR2
    , p3_a5 in out nocopy  VARCHAR2
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  VARCHAR2
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_um_person_rec jtf_um_register_user_pvt.person_rec_type;
    ddp_um_organization_rec jtf_um_register_user_pvt.organization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_um_person_rec.first_name := p3_a0;
    ddp_um_person_rec.last_name := p3_a1;
    ddp_um_person_rec.user_name := p3_a2;
    ddp_um_person_rec.password := p3_a3;
    ddp_um_person_rec.phone_area_code := p3_a4;
    ddp_um_person_rec.phone_number := p3_a5;
    ddp_um_person_rec.email_address := p3_a6;
    ddp_um_person_rec.party_id := p3_a7;
    ddp_um_person_rec.user_id := p3_a8;
    ddp_um_person_rec.start_date_active := rosetta_g_miss_date_in_map(p3_a9);
    ddp_um_person_rec.privacy_preference := p3_a10;

    ddp_um_organization_rec.organization_number := p4_a0;
    ddp_um_organization_rec.organization_name := p4_a1;
    ddp_um_organization_rec.address1 := p4_a2;
    ddp_um_organization_rec.address2 := p4_a3;
    ddp_um_organization_rec.address3 := p4_a4;
    ddp_um_organization_rec.address4 := p4_a5;
    ddp_um_organization_rec.city := p4_a6;
    ddp_um_organization_rec.state := p4_a7;
    ddp_um_organization_rec.postal_code := p4_a8;
    ddp_um_organization_rec.county := p4_a9;
    ddp_um_organization_rec.province := p4_a10;
    ddp_um_organization_rec.altaddress := p4_a11;
    ddp_um_organization_rec.country := p4_a12;
    ddp_um_organization_rec.phone_area_code := p4_a13;
    ddp_um_organization_rec.phone_number := p4_a14;
    ddp_um_organization_rec.fax_area_code := p4_a15;
    ddp_um_organization_rec.fax_number := p4_a16;
    ddp_um_organization_rec.org_party_id := p4_a17;
    ddp_um_organization_rec.org_contact_party_id := p4_a18;
    ddp_um_organization_rec.start_date_active := rosetta_g_miss_date_in_map(p4_a19);




    -- here's the delegated call to the old PL/SQL routine
    jtf_um_business_user_pvt.create_organization(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_um_person_rec,
      ddp_um_organization_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddp_um_person_rec.first_name;
    p3_a1 := ddp_um_person_rec.last_name;
    p3_a2 := ddp_um_person_rec.user_name;
    p3_a3 := ddp_um_person_rec.password;
    p3_a4 := ddp_um_person_rec.phone_area_code;
    p3_a5 := ddp_um_person_rec.phone_number;
    p3_a6 := ddp_um_person_rec.email_address;
    p3_a7 := ddp_um_person_rec.party_id;
    p3_a8 := ddp_um_person_rec.user_id;
    p3_a9 := ddp_um_person_rec.start_date_active;
    p3_a10 := ddp_um_person_rec.privacy_preference;

    p4_a0 := ddp_um_organization_rec.organization_number;
    p4_a1 := ddp_um_organization_rec.organization_name;
    p4_a2 := ddp_um_organization_rec.address1;
    p4_a3 := ddp_um_organization_rec.address2;
    p4_a4 := ddp_um_organization_rec.address3;
    p4_a5 := ddp_um_organization_rec.address4;
    p4_a6 := ddp_um_organization_rec.city;
    p4_a7 := ddp_um_organization_rec.state;
    p4_a8 := ddp_um_organization_rec.postal_code;
    p4_a9 := ddp_um_organization_rec.county;
    p4_a10 := ddp_um_organization_rec.province;
    p4_a11 := ddp_um_organization_rec.altaddress;
    p4_a12 := ddp_um_organization_rec.country;
    p4_a13 := ddp_um_organization_rec.phone_area_code;
    p4_a14 := ddp_um_organization_rec.phone_number;
    p4_a15 := ddp_um_organization_rec.fax_area_code;
    p4_a16 := ddp_um_organization_rec.fax_number;
    p4_a17 := ddp_um_organization_rec.org_party_id;
    p4_a18 := ddp_um_organization_rec.org_contact_party_id;
    p4_a19 := ddp_um_organization_rec.start_date_active;



  end;

end jtf_um_business_user_pvt_w;

/
