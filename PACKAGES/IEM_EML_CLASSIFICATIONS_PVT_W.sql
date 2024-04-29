--------------------------------------------------------
--  DDL for Package IEM_EML_CLASSIFICATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EML_CLASSIFICATIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: IEMVCLSS.pls 115.8 2003/08/05 19:26:42 ukari shipped $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_eml_classifications_pvt.emclass_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t iem_eml_classifications_pvt.emclass_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , p_score  NUMBER
    , p_message_id  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getclassification(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_message_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getclassification(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_message_id  NUMBER
    , x_category_id out nocopy  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , p_score  NUMBER
    , p_message_id  NUMBER
    , p_class_string  VARCHAR2
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_eml_classifications_pvt_w;

 

/
