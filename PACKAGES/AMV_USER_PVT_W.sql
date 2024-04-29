--------------------------------------------------------
--  DDL for Package AMV_USER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_USER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amvwusrs.pls 120.2 2005/06/30 08:50 appldev ship $ */
  procedure rosetta_table_copy_in_p31(t out nocopy amv_user_pvt.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p31(t amv_user_pvt.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000);

  procedure rosetta_table_copy_in_p32(t out nocopy amv_user_pvt.amv_number_varray_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p32(t amv_user_pvt.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p36(t out nocopy amv_user_pvt.amv_resource_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p36(t amv_user_pvt.amv_resource_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p38(t out nocopy amv_user_pvt.amv_group_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p38(t amv_user_pvt.amv_group_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p40(t out nocopy amv_user_pvt.amv_access_obj_varray, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p40(t amv_user_pvt.amv_access_obj_varray, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure find_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_check_effective_date  VARCHAR2
    , p_user_name  VARCHAR2
    , p_last_name  VARCHAR2
    , p_first_name  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure find_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure add_resourcerole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  );
  procedure remove_resourcerole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  );
  procedure replace_resourcerole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  );
  procedure get_resourceroles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , x_role_id_varray out nocopy JTF_NUMBER_TABLE
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
  );
  procedure add_grouprole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  );
  procedure remove_grouprole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  );
  procedure replace_grouprole(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_role_id_varray JTF_NUMBER_TABLE
  );
  procedure get_grouproles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_check_effective_date  VARCHAR2
    , x_role_id_varray out nocopy JTF_NUMBER_TABLE
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
  );
  procedure add_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_group_usage  VARCHAR2
    , p_email_address  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_group_id out nocopy  NUMBER
  );
  procedure update_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_new_group_name  VARCHAR2
    , p_new_group_desc  VARCHAR2
    , p_group_usage  VARCHAR2
    , p_email_address  VARCHAR2
    , p_new_start_date  date
    , p_new_end_date  date
  );
  procedure get_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
  );
  procedure find_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_group_name  VARCHAR2
    , p_group_desc  VARCHAR2
    , p_group_email  VARCHAR2
    , p_group_usage  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a5 out nocopy JTF_DATE_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure find_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_group_name  VARCHAR2
    , p_group_usage  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a5 out nocopy JTF_DATE_TABLE
    , p12_a6 out nocopy JTF_DATE_TABLE
    , x_role_code_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure add_groupmember(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_resource_id_varray JTF_NUMBER_TABLE
  );
  procedure remove_groupmember(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_resource_id_varray JTF_NUMBER_TABLE
  );
  procedure update_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  DATE := fnd_api.g_miss_date
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_DATE_TABLE
    , p8_a7 JTF_DATE_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_VARCHAR2_TABLE_100
  );
  procedure update_resourceapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_application_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_resourcechanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_channel_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_resourcecateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_category_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_resourceitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_item_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_groupapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_resource_id  NUMBER
    , p_group_id  NUMBER
    , p_application_id  NUMBER
    , p11_a0  VARCHAR2 := fnd_api.g_miss_char
    , p11_a1  VARCHAR2 := fnd_api.g_miss_char
    , p11_a2  VARCHAR2 := fnd_api.g_miss_char
    , p11_a3  VARCHAR2 := fnd_api.g_miss_char
    , p11_a4  VARCHAR2 := fnd_api.g_miss_char
    , p11_a5  VARCHAR2 := fnd_api.g_miss_char
    , p11_a6  VARCHAR2 := fnd_api.g_miss_char
    , p11_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_groupchanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_channel_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_groupcateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_category_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_groupitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_item_id  NUMBER
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_businessobjectaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_or_group_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , p_business_object_id  NUMBER
    , p_business_object_type  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  VARCHAR2
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  DATE
    , p11_a8 out nocopy  VARCHAR2
    , p11_a9 out nocopy  VARCHAR2
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  VARCHAR2
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
  );
  procedure get_channelaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_user_or_group_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , x_channel_name_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_accessperchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , x_name_varray out nocopy JTF_VARCHAR2_TABLE_4000
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_businessobjectaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_check_effective_date  VARCHAR2
    , p_user_or_group_id  NUMBER
    , p_user_or_group_type  VARCHAR2
    , p_business_object_id  NUMBER
    , p_business_object_type  VARCHAR2
    , p13_a0 out nocopy  VARCHAR2
    , p13_a1 out nocopy  VARCHAR2
    , p13_a2 out nocopy  VARCHAR2
    , p13_a3 out nocopy  VARCHAR2
    , p13_a4 out nocopy  VARCHAR2
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  VARCHAR2
  );
  procedure get_resourceapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_application_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  );
  procedure get_resourcechanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_channel_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  );
  procedure get_resourcecateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_category_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  );
  procedure get_resourceitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_include_group_flag  VARCHAR2
    , p_resource_id  NUMBER
    , p_item_id  NUMBER
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
  );
  procedure get_groupapplaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_application_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  );
  procedure get_groupchanaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_channel_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  );
  procedure get_groupcateaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_category_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  );
  procedure get_resourceitemaccess(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , p_item_id  NUMBER
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
  );
end amv_user_pvt_w;

 

/
