--------------------------------------------------------
--  DDL for Package OZF_FUND_EXTENSION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_EXTENSION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwfexs.pls 115.1 2004/04/16 11:47:26 rimehrot noship $ */
  procedure validate_delete_fund(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_id  NUMBER
    , p_object_version_number  NUMBER
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ozf_fund_extension_pvt_w;

 

/
