--------------------------------------------------------
--  DDL for Package IEM_EMTA_ADMIN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMTA_ADMIN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: iemvemrs.pls 120.1 2005/08/10 14:57 liangxia noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_emta_admin_pvt.acct_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t iem_emta_admin_pvt.acct_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_account_info(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_emta_admin_pvt_w;

 

/
