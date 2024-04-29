--------------------------------------------------------
--  DDL for Package IBC_CITEM_RUNTIME_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_RUNTIME_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ibcwcirs.pls 120.0 2005/05/27 14:56:48 appldev noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ibc_citem_runtime_pub.rendition_file_name_tbl, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p0(t ibc_citem_runtime_pub.rendition_file_name_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p1(t out nocopy ibc_citem_runtime_pub.rendition_file_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t ibc_citem_runtime_pub.rendition_file_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy ibc_citem_runtime_pub.rendition_mime_type_tbl, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p2(t ibc_citem_runtime_pub.rendition_mime_type_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p3(t out nocopy ibc_citem_runtime_pub.rendition_name_tbl, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p3(t ibc_citem_runtime_pub.rendition_name_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p4(t out nocopy ibc_citem_runtime_pub.comp_item_attrib_tcode_tbl, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p4(t ibc_citem_runtime_pub.comp_item_attrib_tcode_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p5(t out nocopy ibc_citem_runtime_pub.comp_item_citem_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p5(t ibc_citem_runtime_pub.comp_item_citem_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p7(t out nocopy ibc_citem_runtime_pub.content_item_meta_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p7(t ibc_citem_runtime_pub.content_item_meta_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p9(t out nocopy ibc_citem_runtime_pub.content_item_id_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p9(t ibc_citem_runtime_pub.content_item_id_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure get_citems_meta_by_assoc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_association_type_code  VARCHAR2
    , p_associated_object_val1  VARCHAR2
    , p_associated_object_val2  VARCHAR2
    , p_associated_object_val3  VARCHAR2
    , p_associated_object_val4  VARCHAR2
    , p_associated_object_val5  VARCHAR2
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_DATE_TABLE
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a10 out nocopy JTF_NUMBER_TABLE
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_citems_meta_by_assoc_ctyp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_association_type_code  VARCHAR2
    , p_associated_object_val1  VARCHAR2
    , p_associated_object_val2  VARCHAR2
    , p_associated_object_val3  VARCHAR2
    , p_associated_object_val4  VARCHAR2
    , p_associated_object_val5  VARCHAR2
    , p_content_type_code  VARCHAR2
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_DATE_TABLE
    , p13_a3 out nocopy JTF_DATE_TABLE
    , p13_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p13_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a10 out nocopy JTF_NUMBER_TABLE
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_citems_meta(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_content_item_ids JTF_NUMBER_TABLE
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_DATE_TABLE
    , p7_a3 out nocopy JTF_DATE_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_citem_meta(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_content_item_id  NUMBER
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  DATE
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
  );
  procedure get_citem_basic(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_content_item_id  NUMBER
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  DATE
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  JTF_VARCHAR2_TABLE_300
    , p7_a12 out nocopy  JTF_NUMBER_TABLE
    , p7_a13 out nocopy  JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy  JTF_VARCHAR2_TABLE_300
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  CLOB
    , p7_a18 out nocopy  JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy  JTF_NUMBER_TABLE
  );
end ibc_citem_runtime_pub_w;

 

/
