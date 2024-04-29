--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_PUB_W2" AUTHID CURRENT_USER as
  /* $Header: asxwsl2s.pls 115.18 2003/09/18 22:44:15 ckapoor ship $ */
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
  );
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
  );
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
  );
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
  );
  procedure get_access_profiles(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p1_a0 out nocopy  VARCHAR2
    , p1_a1 out nocopy  VARCHAR2
    , p1_a2 out nocopy  VARCHAR2
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  VARCHAR2
  );
  function get_profile(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_300
    , p_profile_name  VARCHAR2
  ) return varchar2;
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
  );
end as_sales_leads_pub_w2;

 

/
