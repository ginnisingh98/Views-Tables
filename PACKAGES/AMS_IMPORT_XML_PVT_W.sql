--------------------------------------------------------
--  DDL for Package AMS_IMPORT_XML_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORT_XML_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswmixs.pls 120.1 2006/01/12 22:10 rmbhanda noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ams_import_xml_pvt.xml_element_key_set_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t ams_import_xml_pvt.xml_element_key_set_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out nocopy ams_import_xml_pvt.xml_source_column_set_type, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p1(t ams_import_xml_pvt.xml_source_column_set_type, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure rosetta_table_copy_in_p2(t out nocopy ams_import_xml_pvt.xml_target_column_set_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p2(t ams_import_xml_pvt.xml_target_column_set_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p3(t out nocopy ams_import_xml_pvt.xml_element_set_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_2000
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p3(t ams_import_xml_pvt.xml_element_set_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure is_leaf_node(p_imp_xml_element_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure get_root_node(p_import_list_header_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_parent_node(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_first_child_node(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_next_sibling_node(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_children_nodes(p_imp_xml_element_id  NUMBER
    , x_child_ids out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_children_nodes(p_imp_xml_element_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_DATE_TABLE
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , p1_a3 out nocopy JTF_DATE_TABLE
    , p1_a4 out nocopy JTF_NUMBER_TABLE
    , p1_a5 out nocopy JTF_NUMBER_TABLE
    , p1_a6 out nocopy JTF_NUMBER_TABLE
    , p1_a7 out nocopy JTF_NUMBER_TABLE
    , p1_a8 out nocopy JTF_NUMBER_TABLE
    , p1_a9 out nocopy JTF_NUMBER_TABLE
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a12 out nocopy JTF_NUMBER_TABLE
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  );
end ams_import_xml_pvt_w;

 

/
