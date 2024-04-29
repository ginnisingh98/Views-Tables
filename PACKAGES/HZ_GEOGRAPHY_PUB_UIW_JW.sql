--------------------------------------------------------
--  DDL for Package HZ_GEOGRAPHY_PUB_UIW_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEOGRAPHY_PUB_UIW_JW" AUTHID CURRENT_USER as
  /* $Header: ARHGEOJB.pls 120.2 2006/02/21 05:58:19 idali noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy hz_geography_pub_uiw.parent_geography_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t hz_geography_pub_uiw.parent_geography_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p6(t out nocopy hz_geography_pub_uiw.zone_relation_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p6(t hz_geography_pub_uiw.zone_relation_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    );

  procedure create_master_relation(p_init_msg_list  VARCHAR2
    , x_relationship_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  DATE := SYSDATE
    , p1_a3  DATE := to_date('31-12-4712','DD-MM-YYYY')
    , p1_a4  VARCHAR2 := null
    , p1_a5  NUMBER := null
  );
  procedure create_geo_identifier(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := 'USER_ENTERED'
    , p1_a5  VARCHAR2 := 'N'
    , p1_a6  VARCHAR2 := userenv('LANG')
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
  );
  procedure update_geo_identifier(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_cp_request_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := userenv('LANG')
    , p1_a7  VARCHAR2 := null
    , p1_a8  NUMBER := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
  );
  procedure create_master_geography(p_init_msg_list  VARCHAR2
    , p_parent_geography_id JTF_NUMBER_TABLE
    , x_geography_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := SYSDATE
    , p1_a5  DATE := to_date('31-12-4712', 'DD-MM-YYYY')
    , p1_a6  VARCHAR2 := 'USER_ENTERED'
    , p1_a7  VARCHAR2 := userenv('LANG')
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  NUMBER := null
  );
  procedure update_geography(p_init_msg_list  VARCHAR2
    , p_geography_id  NUMBER
    , p_end_date  date
    , p_timezone_code  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_geography_range(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  DATE := SYSDATE
    , p1_a7  DATE := to_date('31-12-4712','DD-MM-YYYY')
    , p1_a8  VARCHAR2 := null
    , p1_a9  NUMBER := null
  );
  procedure update_geography_range(p_init_msg_list  VARCHAR2
    , p_geography_id  NUMBER
    , p_geography_from  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_zone_relation(p_init_msg_list  VARCHAR2
    , p_geography_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_400
    , p2_a2 JTF_VARCHAR2_TABLE_400
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_DATE_TABLE
    , p_created_by_module  VARCHAR2
    , p_application_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_zone(p_init_msg_list  VARCHAR2
    , p_zone_type  VARCHAR2
    , p_zone_name  VARCHAR2
    , p_zone_code  VARCHAR2
    , p_zone_code_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_geo_data_provider  VARCHAR2
    , p_language_code  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_400
    , p9_a2 JTF_VARCHAR2_TABLE_400
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_DATE_TABLE
    , p_timezone_code  VARCHAR2
    , x_geography_id out nocopy  NUMBER
    , p_created_by_module  VARCHAR2
    , p_application_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end hz_geography_pub_uiw_jw;

 

/
