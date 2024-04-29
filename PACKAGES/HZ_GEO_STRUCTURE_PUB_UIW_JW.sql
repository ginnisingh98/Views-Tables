--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCTURE_PUB_UIW_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCTURE_PUB_UIW_JW" AUTHID CURRENT_USER as
  /* $Header: ARHGSTJS.pls 120.1 2005/08/26 15:22:32 dmmehta noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy hz_geo_structure_pub_uiw.incl_geo_type_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t hz_geo_structure_pub_uiw.incl_geo_type_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure create_geography_type(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
  );
  procedure create_geo_structure(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
  );
  procedure create_geo_rel_type(p_init_msg_list  VARCHAR2
    , x_relationship_type_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
  );
  procedure create_zone_type(p_init_msg_list  VARCHAR2
    , p_included_geography_type JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := 'N'
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
  );
  procedure update_zone_type(p_init_msg_list  VARCHAR2
    , p_included_geography_type JTF_VARCHAR2_TABLE_100
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  NUMBER := null
  );
end hz_geo_structure_pub_uiw_jw;

 

/
