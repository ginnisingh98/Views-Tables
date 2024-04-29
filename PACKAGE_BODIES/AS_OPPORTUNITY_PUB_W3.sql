--------------------------------------------------------
--  DDL for Package Body AS_OPPORTUNITY_PUB_W3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPPORTUNITY_PUB_W3" as
  /* $Header: asxwop3b.pls 120.1 2005/08/04 03:06 appldev ship $ */
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

  procedure update_competitors(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_VARCHAR2_TABLE_200
    , p5_a26 JTF_VARCHAR2_TABLE_200
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_VARCHAR2_TABLE_200
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_VARCHAR2_TABLE_200
    , p5_a31 JTF_VARCHAR2_TABLE_200
    , p5_a32 JTF_VARCHAR2_TABLE_200
    , p5_a33 JTF_VARCHAR2_TABLE_200
    , p5_a34 JTF_VARCHAR2_TABLE_200
    , p5_a35 JTF_VARCHAR2_TABLE_200
    , p5_a36 JTF_VARCHAR2_TABLE_200
    , p5_a37 JTF_VARCHAR2_TABLE_200
    , p5_a38 JTF_VARCHAR2_TABLE_200
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_competitor_tbl as_opportunity_pub.competitor_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_competitor_out_tbl as_opportunity_pub.competitor_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p26(ddp_competitor_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_competitors(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_competitor_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_competitor_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p29(ddx_competitor_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure delete_competitors(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_DATE_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_300
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_VARCHAR2_TABLE_200
    , p5_a26 JTF_VARCHAR2_TABLE_200
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_VARCHAR2_TABLE_200
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_VARCHAR2_TABLE_200
    , p5_a31 JTF_VARCHAR2_TABLE_200
    , p5_a32 JTF_VARCHAR2_TABLE_200
    , p5_a33 JTF_VARCHAR2_TABLE_200
    , p5_a34 JTF_VARCHAR2_TABLE_200
    , p5_a35 JTF_VARCHAR2_TABLE_200
    , p5_a36 JTF_VARCHAR2_TABLE_200
    , p5_a37 JTF_VARCHAR2_TABLE_200
    , p5_a38 JTF_VARCHAR2_TABLE_200
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_competitor_tbl as_opportunity_pub.competitor_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_competitor_out_tbl as_opportunity_pub.competitor_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p26(ddp_competitor_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_competitors(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_competitor_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_competitor_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p29(ddx_competitor_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure create_competitor_prods(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_competitor_prod_tbl as_opportunity_pub.competitor_prod_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_competitor_prod_out_tbl as_opportunity_pub.competitor_prod_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p44(ddp_competitor_prod_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.create_competitor_prods(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_competitor_prod_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_competitor_prod_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p47(ddx_competitor_prod_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure update_competitor_prods(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_competitor_prod_tbl as_opportunity_pub.competitor_prod_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_competitor_prod_out_tbl as_opportunity_pub.competitor_prod_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p44(ddp_competitor_prod_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_competitor_prods(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_competitor_prod_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_competitor_prod_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p47(ddx_competitor_prod_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure delete_competitor_prods(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_competitor_prod_tbl as_opportunity_pub.competitor_prod_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_competitor_prod_out_tbl as_opportunity_pub.competitor_prod_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p44(ddp_competitor_prod_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_competitor_prods(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_competitor_prod_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_competitor_prod_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p47(ddx_competitor_prod_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure create_decision_factors(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_decision_factor_tbl as_opportunity_pub.decision_factor_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_decision_factor_out_tbl as_opportunity_pub.decision_factor_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p50(ddp_decision_factor_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.create_decision_factors(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_decision_factor_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_decision_factor_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p53(ddx_decision_factor_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure update_decision_factors(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_decision_factor_tbl as_opportunity_pub.decision_factor_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_decision_factor_out_tbl as_opportunity_pub.decision_factor_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p50(ddp_decision_factor_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.update_decision_factors(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_decision_factor_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_decision_factor_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p53(ddx_decision_factor_out_tbl, p11_a0
      , p11_a1
      );



  end;

  procedure delete_decision_factors(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_300
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_decision_factor_tbl as_opportunity_pub.decision_factor_tbl_type;
    ddp_profile_tbl as_utility_pub.profile_tbl_type;
    ddx_decision_factor_out_tbl as_opportunity_pub.decision_factor_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    as_opportunity_pub_w.rosetta_table_copy_in_p50(ddp_decision_factor_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      );





    as_utility_pub_w.rosetta_table_copy_in_p6(ddp_profile_tbl, p10_a0
      , p10_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    as_opportunity_pub.delete_decision_factors(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_identity_salesforce_id,
      ddp_decision_factor_tbl,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_partner_cont_party_id,
      ddp_profile_tbl,
      ddx_decision_factor_out_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    as_opportunity_pub_w.rosetta_table_copy_out_p53(ddx_decision_factor_out_tbl, p11_a0
      , p11_a1
      );



  end;

end as_opportunity_pub_w3;

/
