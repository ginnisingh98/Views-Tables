--------------------------------------------------------
--  DDL for Package IEM_AMV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_AMV_PVT_W" AUTHID CURRENT_USER as
  /* $Header: IEMPAMVS.pls 120.0 2005/06/02 13:42:37 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_amv_pvt.category_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t iem_amv_pvt.category_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_categories(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_amv_pvt_w;

 

/
