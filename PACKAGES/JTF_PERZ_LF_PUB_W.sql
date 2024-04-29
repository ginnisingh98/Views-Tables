--------------------------------------------------------
--  DDL for Package JTF_PERZ_LF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_LF_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfzwlfs.pls 120.2 2005/11/02 23:01:20 skothe ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_lf_pub.attrib_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jtf_perz_lf_pub.attrib_rec_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_lf_pub.attrib_value_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t jtf_perz_lf_pub.attrib_value_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_lf_pub.lf_object_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t jtf_perz_lf_pub.lf_object_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure save_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_profile_type  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p_application_id  NUMBER
    , p_parent_id  NUMBER
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_object_name  VARCHAR2
    , p_object_description  VARCHAR2
    , p_active_flag  VARCHAR2
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_VARCHAR2_TABLE_100
    , p15_a2 JTF_VARCHAR2_TABLE_100
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_NUMBER_TABLE
    , x_object_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure save_lf_object_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p_object_type_desc  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , x_object_type_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure create_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_application_id  NUMBER
    , p_parent_id  NUMBER
    , p_object_id  NUMBER
    , p_object_name  VARCHAR2
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_NUMBER_TABLE
    , x_object_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_lf_object_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_object_type  VARCHAR
    , p_object_type_id  NUMBER
    , x_object_type_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_object_type_desc OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_priority  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_object_id  NUMBER
    , p_object_name  VARCHAR
    , p_obj_active_flag  VARCHAR2
    , p_get_children_flag  VARCHAR2
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p10_a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure update_lf_object(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_application_id  NUMBER
    , p_parent_id  NUMBER
    , p_object_id  NUMBER
    , p_object_name  VARCHAR2
    , p_active_flag  VARCHAR2
    , p_object_type_id  NUMBER
    , p_object_type  VARCHAR2
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_VARCHAR2_TABLE_100
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , p12_a4 JTF_NUMBER_TABLE
    , x_object_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
end jtf_perz_lf_pub_w;

 

/
