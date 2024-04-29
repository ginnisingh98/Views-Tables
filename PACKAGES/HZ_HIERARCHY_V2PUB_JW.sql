--------------------------------------------------------
--  DDL for Package HZ_HIERARCHY_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_HIERARCHY_V2PUB_JW" AUTHID CURRENT_USER as
  /* $Header: ARH2HIJS.pls 120.2 2005/06/18 04:28:21 jhuang noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy hz_hierarchy_v2pub.related_nodes_list_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t hz_hierarchy_v2pub.related_nodes_list_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure is_top_parent_1(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_effective_date  date
    , x_result out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure check_parent_child_2(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_child_id  NUMBER
    , p_child_table_name  VARCHAR2
    , p_child_object_type  VARCHAR2
    , p_effective_date  date
    , x_result out nocopy  VARCHAR2
    , x_level_number out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_parent_nodes_3(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_child_id  NUMBER
    , p_child_table_name  VARCHAR2
    , p_child_object_type  VARCHAR2
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_include_node  VARCHAR2
    , p_effective_date  date
    , p_no_of_records  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_child_nodes_4(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_child_table_name  VARCHAR2
    , p_child_object_type  VARCHAR2
    , p_include_node  VARCHAR2
    , p_effective_date  date
    , p_no_of_records  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_DATE_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_top_parent_nodes_5(p_init_msg_list  VARCHAR2
    , p_hierarchy_type  VARCHAR2
    , p_parent_table_name  VARCHAR2
    , p_parent_object_type  VARCHAR2
    , p_effective_date  date
    , p_no_of_records  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end hz_hierarchy_v2pub_jw;

 

/
