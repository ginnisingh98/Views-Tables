--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEADS_PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEADS_PUB_W2" as
  /* $Header: asxwsl2b.pls 115.18 2003/09/18 22:44:23 ckapoor ship $ */
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

  procedure copy_lead_to_opportunity(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_identity_salesgroup_id  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_300
    , p_sales_lead_id  NUMBER
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_DATE_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_DATE_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_DATE_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_VARCHAR2_TABLE_100
    , p11_a12 JTF_NUMBER_TABLE
    , p11_a13 JTF_NUMBER_TABLE
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_VARCHAR2_TABLE_100
    , p11_a17 JTF_NUMBER_TABLE
    , p11_a18 JTF_NUMBER_TABLE
    , p11_a19 JTF_NUMBER_TABLE
    , p11_a20 JTF_VARCHAR2_TABLE_100
    , p11_a21 JTF_VARCHAR2_TABLE_200
    , p11_a22 JTF_VARCHAR2_TABLE_200
    , p11_a23 JTF_VARCHAR2_TABLE_200
    , p11_a24 JTF_VARCHAR2_TABLE_200
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_VARCHAR2_TABLE_200
    , p11_a36 JTF_NUMBER_TABLE
    , p_opportunity_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_line_tbl as_sales_leads_pub.sales_lead_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p9_a0
      , p9_a1
      );


    as_sales_leads_pub_w.rosetta_table_copy_in_p7(ddp_sales_lead_line_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      );





    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.copy_lead_to_opportunity(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_identity_salesgroup_id,
      ddp_sales_lead_profile_tbl,
      p_sales_lead_id,
      ddp_sales_lead_line_tbl,
      p_opportunity_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure link_lead_to_opportunity(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_identity_salesgroup_id  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_300
    , p_sales_lead_id  NUMBER
    , p_opportunity_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p9_a0
      , p9_a1
      );






    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.link_lead_to_opportunity(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_identity_salesgroup_id,
      ddp_sales_lead_profile_tbl,
      p_sales_lead_id,
      p_opportunity_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure create_opportunity_for_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_identity_salesgroup_id  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_300
    , p_sales_lead_id  NUMBER
    , p_opp_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_opportunity_id out nocopy  NUMBER
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p9_a0
      , p9_a1
      );







    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.create_opportunity_for_lead(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_identity_salesgroup_id,
      ddp_sales_lead_profile_tbl,
      p_sales_lead_id,
      p_opp_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_opportunity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure assign_sales_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p_sales_lead_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_assign_id_tbl as_sales_leads_pub.assign_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_sales_lead_profile_tbl, p8_a0
      , p8_a1
      );






    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.assign_sales_lead(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      p_sales_lead_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_assign_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    as_sales_leads_pub_w.rosetta_table_copy_out_p19(ddx_assign_id_tbl, p13_a0
      , p13_a1
      );
  end;

  procedure get_access_profiles(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy  VARCHAR2
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  VARCHAR2
  )

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p0_a0
      , p0_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.get_access_profiles(ddp_profile_tbl,
      ddx_access_profile_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_access_profile_rec.cust_access_profile_value;
    p1_a1 := ddx_access_profile_rec.lead_access_profile_value;
    p1_a2 := ddx_access_profile_rec.opp_access_profile_value;
    p1_a3 := ddx_access_profile_rec.mgr_update_profile_value;
    p1_a4 := ddx_access_profile_rec.admin_update_profile_value;
  end;

  function get_profile(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p_profile_name  VARCHAR2
  ) return varchar2

  as
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p0_a0
      , p0_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := as_sales_leads_pub.get_profile(ddp_profile_tbl,
      p_profile_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

  procedure run_lead_engines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p_salesgroup_id  NUMBER
    , p_sales_lead_id  NUMBER
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_lead_engines_out_rec as_sales_leads_pub.lead_engines_out_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    as_sales_leads_pub.run_lead_engines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_admin_group_id,
      p_identity_salesforce_id,
      p_salesgroup_id,
      p_sales_lead_id,
      ddx_lead_engines_out_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_lead_engines_out_rec.qualified_flag;
    p8_a1 := rosetta_g_miss_num_map(ddx_lead_engines_out_rec.lead_rank_id);
    p8_a2 := ddx_lead_engines_out_rec.channel_code;
    p8_a3 := ddx_lead_engines_out_rec.indirect_channel_flag;
    p8_a4 := ddx_lead_engines_out_rec.sales_team_flag;



  end;

end as_sales_leads_pub_w2;

/
