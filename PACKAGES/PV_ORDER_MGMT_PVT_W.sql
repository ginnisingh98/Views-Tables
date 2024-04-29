--------------------------------------------------------
--  DDL for Package PV_ORDER_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ORDER_MGMT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwpoms.pls 120.5 2005/12/14 12:24 dgottlie ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy pv_order_mgmt_pvt.payment_info_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t pv_order_mgmt_pvt.payment_info_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy pv_order_mgmt_pvt.order_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t pv_order_mgmt_pvt.order_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure set_enrq_payment_info(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_contact_party_id  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_is_authorized out nocopy  VARCHAR2
  );
  procedure set_vad_payment_info(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_contact_party_id  NUMBER
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end pv_order_mgmt_pvt_w;

 

/
