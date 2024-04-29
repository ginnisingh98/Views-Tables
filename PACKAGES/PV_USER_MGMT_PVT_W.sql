--------------------------------------------------------
--  DDL for Package PV_USER_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_USER_MGMT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwumms.pls 120.8 2006/01/17 13:10 ktsao ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy pv_user_mgmt_pvt.partner_types_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t pv_user_mgmt_pvt.partner_types_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure register_partner_and_user(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_partner_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
  );
  procedure register_partner_user(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
  );
end pv_user_mgmt_pvt_w;

 

/
