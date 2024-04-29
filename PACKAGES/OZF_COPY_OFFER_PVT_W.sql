--------------------------------------------------------
--  DDL for Package OZF_COPY_OFFER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_COPY_OFFER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwcpos.pls 120.0 2005/06/01 03:36:42 appldev noship $ */
  procedure copy_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id OUT NOCOPY  NUMBER
    , x_custom_setup_id OUT NOCOPY  NUMBER
  );
end ozf_copy_offer_pvt_w;

 

/
