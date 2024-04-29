--------------------------------------------------------
--  DDL for Package JTF_RS_RES_SSWA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RES_SSWA_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsrws.pls 120.0 2005/05/11 08:21:53 appldev ship $ */
  procedure create_emp_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_source_first_name  VARCHAR2
    , p_source_last_name  VARCHAR2
    , p_source_middle_name  VARCHAR2
    , p_employee_number  VARCHAR2
    , p_source_sex  VARCHAR2
    , p_source_title  VARCHAR2
    , p_source_job_id  NUMBER
    , p_source_email  VARCHAR2
    , p_source_start_date  date
    , p_source_end_date  date
    , p_user_name  VARCHAR2
    , p_source_address_id  NUMBER
    , p_source_office  VARCHAR2
    , p_source_mailstop  VARCHAR2
    , p_source_location  VARCHAR2
    , p_source_phone  VARCHAR2
    , p_salesrep_number  VARCHAR2
    , p_sales_credit_type_id  NUMBER
    , p_source_mgr_id  NUMBER
    , x_resource_id out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , p_called_from  VARCHAR2
    , p_user_password in out NOCOPY  VARCHAR2
  );
  procedure update_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_number  VARCHAR2
    , p_resource_name  VARCHAR2
    , p_source_name  VARCHAR2
    , p_address_id  VARCHAR2
    , p_source_office  VARCHAR2
    , p_source_mailstop  VARCHAR2
    , p_source_location  VARCHAR2
    , p_source_phone  VARCHAR2
    , p_source_email  VARCHAR2
    , p_object_version_number  NUMBER
    , p_approved  VARCHAR2
    , p_source_job_id  NUMBER
    , p_source_job_title  VARCHAR2
    , p_salesrep_number  VARCHAR2
    , p_sales_credit_type_id  NUMBER
    , p_end_date_active  date
    , p_user_id  NUMBER
    , p_user_name  VARCHAR2
    , p_mgr_resource_id  NUMBER
    , p_org_id  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , p_time_zone  NUMBER
    , p_cost_per_hr  NUMBER
    , p_primary_language  VARCHAR2
    , p_secondary_language  VARCHAR2
    , p_support_site_id  NUMBER
    , p_source_mobile_phone  VARCHAR2
    , p_source_pager  VARCHAR2
  );
end jtf_rs_res_sswa_pub_w;

 

/
