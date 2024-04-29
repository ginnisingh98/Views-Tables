--------------------------------------------------------
--  DDL for Package PV_PG_NOTIF_UTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_NOTIF_UTILITY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwpnus.pls 115.8 2003/12/01 19:18:22 pukken ship $ */
  procedure rosetta_table_copy_in_p6(t out nocopy pv_pg_notif_utility_pvt.user_notify_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t pv_pg_notif_utility_pvt.user_notify_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_users_list(p_partner_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , x_user_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure set_pgp_notif(p_notif_id  NUMBER
    , p_object_version  NUMBER
    , p_partner_id  NUMBER
    , p_user_id  NUMBER
    , p_arc_notif_for_entity_code  VARCHAR2
    , p_notif_for_entity_id  NUMBER
    , p_notif_type_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  DATE
    , p8_a12 out nocopy  NUMBER
  );
  procedure send_mbrship_chng_notif(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
  );
  procedure send_invitations(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_invite_header_id  NUMBER
    , p_from_program_id  NUMBER
    , p_notif_event_code  VARCHAR2
    , p_discount_value  VARCHAR2
    , p_discount_unit  VARCHAR2
    , p_currency  VARCHAR2
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end pv_pg_notif_utility_pvt_w;

 

/
