--------------------------------------------------------
--  DDL for Package JTF_PERZ_DDF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_DDF_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfzwdds.pls 120.2 2005/11/02 23:00:47 skothe ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_perz_ddf_pub.ddf_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jtf_perz_ddf_pub.ddf_out_tbl_type, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure save_data_default(p_api_version_number  NUMBER
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
    , p_perz_ddf_id  NUMBER
    , p_perz_ddf_context  VARCHAR2
    , p_gui_object_name  VARCHAR2
    , p_gui_object_id  NUMBER
    , p_ddf_value  VARCHAR2
    , p_ddf_value_type  VARCHAR2
    , x_perz_ddf_id OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure get_data_default(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_application_id  NUMBER
    , p_profile_id  NUMBER
    , p_profile_name  VARCHAR2
    , p_perz_ddf_id  NUMBER
    , p_perz_ddf_context  VARCHAR2
    , p_gui_object_name  VARCHAR2
    , p_gui_object_id  NUMBER
    , p_ddf_value  VARCHAR2
    , p_ddf_value_type  VARCHAR2
    , p11_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a2 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p11_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
end jtf_perz_ddf_pub_w;

 

/
