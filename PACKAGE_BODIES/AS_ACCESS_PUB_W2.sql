--------------------------------------------------------
--  DDL for Package Body AS_ACCESS_PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ACCESS_PUB_W2" as
  /* $Header: asxwac2b.pls 115.3 2002/08/16 23:26:06 kichan ship $ */
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

  procedure has_updatepersonaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_security_id  NUMBER
    , p_security_type  VARCHAR2
    , p_person_party_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_update_access_flag out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;














    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_updatepersonaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_security_id,
      p_security_type,
      p_person_party_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_update_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure has_viewpersonaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_security_id  NUMBER
    , p_security_type  VARCHAR2
    , p_person_party_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_view_access_flag out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;














    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewpersonaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_security_id,
      p_security_type,
      p_person_party_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure has_viewleadaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_sales_lead_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_view_access_flag out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewleadaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_sales_lead_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_viewopportunityaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_opportunity_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_view_access_flag out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewopportunityaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_opportunity_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_organizationaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_customer_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_access_privilege out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_organizationaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_customer_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_personaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_security_id  NUMBER
    , p_security_type  VARCHAR2
    , p_person_party_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_access_privilege out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;














    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_personaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_security_id,
      p_security_type,
      p_person_party_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure has_leadaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_sales_lead_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_access_privilege out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_leadaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_sales_lead_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_opportunityaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_opportunity_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_access_privilege out  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_opportunityaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_opportunity_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end as_access_pub_w2;

/
