--------------------------------------------------------
--  DDL for Package JTF_RS_GROUPS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUPS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfrsros.pls 120.0 2005/05/11 08:21:45 appldev ship $ */
  procedure create_resource_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_exclusive_flag  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_accounting_code  VARCHAR2
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_group_id out NOCOPY  NUMBER
    , x_group_number out NOCOPY  VARCHAR2
  );
  procedure create_resource_group_migrate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_exclusive_flag  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_accounting_code  VARCHAR2
    , p_group_id  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , x_group_id out NOCOPY  NUMBER
    , x_group_number out NOCOPY  VARCHAR2
  );
  procedure update_resource_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_group_id  NUMBER
    , p_group_number  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_exclusive_flag  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_accounting_code  VARCHAR2
    , p_object_version_num in out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
  );
end jtf_rs_groups_pub_w;

 

/
