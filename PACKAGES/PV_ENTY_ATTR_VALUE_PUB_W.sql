--------------------------------------------------------
--  DDL for Package PV_ENTY_ATTR_VALUE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTY_ATTR_VALUE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: pvxwavps.pls 120.2 2005/11/11 15:27 amaram noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_enty_attr_value_pub.attr_value_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p2(t pv_enty_attr_value_pub.attr_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p4(t out nocopy pv_enty_attr_value_pub.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t pv_enty_attr_value_pub.number_table, a0 out nocopy JTF_NUMBER_TABLE);

  procedure upsert_attr_value(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute_id  NUMBER
    , p_entity  VARCHAR2
    , p_entity_id  NUMBER
    , p_version  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_2000
    , p11_a1 JTF_VARCHAR2_TABLE_4000
  );
  procedure copy_partner_attr_values(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attr_id_tbl JTF_NUMBER_TABLE
    , p_entity  VARCHAR2
    , p_entity_id  NUMBER
    , p_partner_id  NUMBER
  );
  procedure upsert_partner_types(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_entity_id  NUMBER
    , p_version  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_2000
    , p9_a1 JTF_VARCHAR2_TABLE_4000
  );
end pv_enty_attr_value_pub_w;

 

/
