--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCT_MAP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCT_MAP_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ARHGNRJS.pls 120.3 2005/10/25 14:12:22 baianand noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t hz_geo_struct_map_pub.geo_struct_map_dtl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_geo_struct_mapping(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_map_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_geo_struct_mapping(p_map_id  NUMBER
    , p_location_table_name  VARCHAR2
    , p_country  VARCHAR2
    , p_address_style  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_geo_struct_map_dtls(p_map_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_geo_struct_map_dtls(p_map_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end hz_geo_struct_map_pub_w;

 

/
