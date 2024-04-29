--------------------------------------------------------
--  DDL for Package JTF_PERZ_DATA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_DATA_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfzwpds.pls 120.2 2005/11/02 23:48:00 skothe ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_data_pub.data_attrib_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jtf_perz_data_pub.data_attrib_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_data_pub.data_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p4(t jtf_perz_data_pub.data_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure save_perz_data(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_profile_type  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p_perz_data_id  NUMBER
    , p_perz_data_name  VARCHAR2
    , p_perz_data_type  VARCHAR2
    , p_perz_data_desc  VARCHAR2
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , p12_a4 JTF_VARCHAR2_TABLE_300
    , p12_a5 JTF_VARCHAR2_TABLE_100
    , x_perz_data_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure create_perz_data(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_perz_data_id  NUMBER
    , p_perz_data_name  VARCHAR2
    , p_perz_data_type  VARCHAR2
    , p_perz_data_desc  VARCHAR2
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_VARCHAR2_TABLE_100
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_VARCHAR2_TABLE_300
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , x_perz_data_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_perz_data(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_perz_data_id  NUMBER
    , p_perz_data_name  VARCHAR2
    , p_perz_data_type  VARCHAR2
    , x_perz_data_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_perz_data_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_perz_data_type OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_perz_data_desc OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p12_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p12_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p12_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p12_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p12_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_perz_data_summary(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_perz_data_id  NUMBER
    , p_perz_data_name  VARCHAR2
    , p_perz_data_type  VARCHAR2
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure update_perz_data(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_perz_data_id  NUMBER
    , p_perz_data_name  VARCHAR2
    , p_perz_data_type  VARCHAR2
    , p_perz_data_desc  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_300
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , x_perz_data_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
end jtf_perz_data_pub_w;

 

/
