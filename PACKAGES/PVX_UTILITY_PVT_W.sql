--------------------------------------------------------
--  DDL for Package PVX_UTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_UTILITY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwutls.pls 120.1 2008/02/28 22:19:20 hekkiral ship $ */
  procedure rosetta_table_copy_in_p11(t out nocopy pvx_utility_pvt.log_params_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p11(t pvx_utility_pvt.log_params_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure convert_timezone(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_user_tz_id  NUMBER
    , p_in_time  date
    , p_convert_type  VARCHAR2
    , x_out_time out nocopy  DATE
  );
  procedure create_history_log(p_arc_history_for_entity_code  VARCHAR2
    , p_history_for_entity_id  NUMBER
    , p_history_category_code  VARCHAR2
    , p_message_code  VARCHAR2
    , p_partner_id  NUMBER
    , p_access_level_flag  VARCHAR2
    , p_interaction_level  NUMBER
    , p_comments  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_2000
    , p8_a2 JTF_VARCHAR2_TABLE_100
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_business_days(p_from_date  date
    , p_to_date  date
    , x_bus_days out nocopy  NUMBER
  );
end pvx_utility_pvt_w;

/
