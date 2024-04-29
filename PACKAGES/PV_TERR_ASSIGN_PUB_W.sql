--------------------------------------------------------
--  DDL for Package PV_TERR_ASSIGN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_TERR_ASSIGN_PUB_W" AUTHID CURRENT_USER as
  /* $Header: pvxwptas.pls 120.1 2005/08/10 01:45 appldev ship $ */
  procedure rosetta_table_copy_in_p15(t out nocopy pv_terr_assign_pub.partner_qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p15(t pv_terr_assign_pub.partner_qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p19(t out nocopy pv_terr_assign_pub.prtnr_qflr_flg_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p19(t pv_terr_assign_pub.prtnr_qflr_flg_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p22(t out nocopy pv_terr_assign_pub.resourcelist, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p22(t pv_terr_assign_pub.resourcelist, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p23(t out nocopy pv_terr_assign_pub.personlist, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p23(t pv_terr_assign_pub.personlist, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p24(t out nocopy pv_terr_assign_pub.resourcecategorylist, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p24(t pv_terr_assign_pub.resourcecategorylist, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p25(t out nocopy pv_terr_assign_pub.grouplist, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p25(t pv_terr_assign_pub.grouplist, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p30(t out nocopy pv_terr_assign_pub.prtnr_aces_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p30(t pv_terr_assign_pub.prtnr_aces_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_res_from_team_group(p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p2_a0 out nocopy  JTF_NUMBER_TABLE
    , p2_a1 out nocopy  JTF_NUMBER_TABLE
    , p2_a2 out nocopy  JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy  JTF_NUMBER_TABLE
  );
  procedure get_partner_details(p_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p4_a14 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure create_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure do_create_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_400
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_500
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure create_online_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure do_cr_online_chnl_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_400
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_VARCHAR2_TABLE_100
    , p11_a6 JTF_VARCHAR2_TABLE_100
    , p11_a7 JTF_VARCHAR2_TABLE_100
    , p11_a8 JTF_VARCHAR2_TABLE_100
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_500
    , p11_a14 JTF_VARCHAR2_TABLE_100
    , p12_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure create_vad_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_channel_team(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_vad_partner_id  NUMBER
    , p_mode  VARCHAR2
    , p_login_user  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
  );
end pv_terr_assign_pub_w;

 

/
