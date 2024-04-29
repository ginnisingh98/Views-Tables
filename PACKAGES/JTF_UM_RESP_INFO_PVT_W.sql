--------------------------------------------------------
--  DDL for Package JTF_UM_RESP_INFO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_RESP_INFO_PVT_W" AUTHID CURRENT_USER as
  /* $Header: JTFWRESS.pls 120.2 2005/09/02 18:36:03 applrt ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_um_resp_info_pvt.resp_info_table_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p1(t jtf_um_resp_info_pvt.resp_info_table_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure get_resp_info_source(p_user_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 out nocopy JTF_VARCHAR2_TABLE_4000
  );
end jtf_um_resp_info_pvt_w;

 

/
