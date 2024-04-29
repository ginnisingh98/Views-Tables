--------------------------------------------------------
--  DDL for Package OZF_PRICE_LIST_REPORT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRICE_LIST_REPORT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwprls.pls 120.0 2005/06/01 03:14:14 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ozf_price_list_report_pvt.section_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ozf_price_list_report_pvt.section_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    );

  procedure get_section_heirarchy(p_section_id  NUMBER
    , p1_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p1_a1 OUT NOCOPY JTF_NUMBER_TABLE
    , p1_a2 OUT NOCOPY JTF_NUMBER_TABLE
    , p1_a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
  );
end ozf_price_list_report_pvt_w;

 

/
