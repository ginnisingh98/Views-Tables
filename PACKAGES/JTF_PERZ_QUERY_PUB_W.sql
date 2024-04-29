--------------------------------------------------------
--  DDL for Package JTF_PERZ_QUERY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_QUERY_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfzwpqs.pls 120.2 2005/11/02 23:49:08 skothe ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_query_pub.query_parameter_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t jtf_perz_query_pub.query_parameter_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_query_pub.query_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p4(t jtf_perz_query_pub.query_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p6(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_query_pub.query_order_by_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t jtf_perz_query_pub.query_order_by_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure save_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_profile_type  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p_query_desc  VARCHAR2
    , p_query_data_source  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_100
    , p13_a3 JTF_VARCHAR2_TABLE_100
    , p13_a4 JTF_VARCHAR2_TABLE_300
    , p13_a5 JTF_VARCHAR2_TABLE_100
    , p13_a6 JTF_NUMBER_TABLE
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_NUMBER_TABLE
    , p14_a2 JTF_VARCHAR2_TABLE_100
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p15_a0  NUMBER
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  VARCHAR2
    , p15_a4  VARCHAR2
    , p15_a5  VARCHAR2
    , p15_a6  VARCHAR2
    , p15_a7  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure create_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p_query_desc  VARCHAR2
    , p_query_data_source  VARCHAR2
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_VARCHAR2_TABLE_300
    , p11_a5 JTF_VARCHAR2_TABLE_100
    , p11_a6 JTF_NUMBER_TABLE
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , p12_a4 JTF_NUMBER_TABLE
    , p13_a0  NUMBER
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  VARCHAR2
    , p13_a4  VARCHAR2
    , p13_a5  VARCHAR2
    , p13_a6  VARCHAR2
    , p13_a7  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_query_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_query_type OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_query_desc OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_query_data_source OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p13_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p13_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p13_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p13_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p13_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p13_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p13_a6 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p14_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p14_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p14_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p14_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p14_a4 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p15_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p15_a1 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p15_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a4 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a5 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a6 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p15_a7 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_perz_query_summary(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure update_perz_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_query_id  NUMBER
    , p_query_name  VARCHAR2
    , p_query_type  VARCHAR2
    , p_query_desc  VARCHAR2
    , p_query_data_source  VARCHAR2
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_VARCHAR2_TABLE_100
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_VARCHAR2_TABLE_300
    , p10_a5 JTF_VARCHAR2_TABLE_100
    , p10_a6 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_VARCHAR2_TABLE_100
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_NUMBER_TABLE
    , p12_a0  NUMBER
    , p12_a1  NUMBER
    , p12_a2  VARCHAR2
    , p12_a3  VARCHAR2
    , p12_a4  VARCHAR2
    , p12_a5  VARCHAR2
    , p12_a6  VARCHAR2
    , p12_a7  VARCHAR2
    , x_query_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
end jtf_perz_query_pub_w;

 

/
