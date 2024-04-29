--------------------------------------------------------
--  DDL for Package JTF_MSITE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_GRP_W" AUTHID CURRENT_USER as
  /* $Header: JTFGRMSS.pls 115.9 2004/07/09 18:50:55 applrt ship $ */
  procedure rosetta_table_copy_in_p7(t out jtf_msite_grp.msite_currencies_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t jtf_msite_grp.msite_currencies_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t out jtf_msite_grp.msite_languages_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t jtf_msite_grp.msite_languages_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p9(t out jtf_msite_grp.msite_orgids_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t jtf_msite_grp.msite_orgids_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p10(t out jtf_msite_grp.msite_delete_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p10(t jtf_msite_grp.msite_delete_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p11(t out jtf_msite_grp.msite_prtyids_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p11(t jtf_msite_grp.msite_prtyids_tbl_type, a0 out JTF_NUMBER_TABLE);

  procedure delete_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
  );
  procedure save_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  NUMBER
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  NUMBER
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  VARCHAR2
    , p6_a8 in out  VARCHAR2
    , p6_a9 in out  NUMBER
    , p6_a10 in out  VARCHAR2
    , p6_a11 in out  VARCHAR2
    , p6_a12 in out  VARCHAR2
    , p6_a13 in out  VARCHAR2
    , p6_a14 in out  DATE
    , p6_a15 in out  DATE
    , p6_a16 in out  VARCHAR2
    , p6_a17 in out  NUMBER
  );
  procedure save_msite_languages(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_VARCHAR2_TABLE_100
  );
  procedure save_msite_currencies(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
  );
  procedure save_msite_orgids(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_msite_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_100
  );
  procedure insert_row(x_rowid in out  VARCHAR2
    , x_msite_id  NUMBER
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_security_group_id  NUMBER
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_creation_date  date
    , x_created_by  NUMBER
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
  );
  procedure lock_row(x_msite_id  NUMBER
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_security_group_id  NUMBER
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
  );
  procedure update_row(x_msite_id  NUMBER
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_security_group_id  NUMBER
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
  );
  procedure load_row(x_msite_id  NUMBER
    , x_owner  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_security_group_id  NUMBER
    , x_object_version_number  NUMBER
    , x_store_id  NUMBER
    , x_start_date_active  date
    , x_end_date_active  date
    , x_default_language_code  VARCHAR2
    , x_default_currency_code  VARCHAR2
    , x_default_date_format  VARCHAR2
    , x_default_org_id  NUMBER
    , x_atp_check_flag  VARCHAR2
    , x_walkin_allowed_flag  VARCHAR2
    , x_msite_root_section_id  NUMBER
    , x_profile_id  NUMBER
    , x_master_msite_flag  VARCHAR2
    , x_msite_name  VARCHAR2
    , x_msite_description  VARCHAR2
    , x_resp_access_flag  VARCHAR2
    , x_party_access_code  VARCHAR2
    , x_access_name  VARCHAR2
    , x_url  VARCHAR2
    , x_theme_id  NUMBER
  );
end jtf_msite_grp_w;

 

/
