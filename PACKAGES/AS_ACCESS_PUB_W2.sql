--------------------------------------------------------
--  DDL for Package AS_ACCESS_PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ACCESS_PUB_W2" AUTHID CURRENT_USER as
  /* $Header: asxwac2s.pls 115.3 2002/08/16 23:26:30 kichan ship $ */
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
  );
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
  );
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
  );
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
  );
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
  );
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
  );
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
  );
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
  );
end as_access_pub_w2;

 

/
