--------------------------------------------------------
--  DDL for Package AS_UTILITY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_UTILITY_PUB_W" AUTHID CURRENT_USER as
  /* $Header: asxwutls.pls 120.1 2005/11/28 02:29 sumahali noship $ */
  procedure rosetta_table_copy_in_p6(t out nocopy as_utility_pub.profile_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p6(t as_utility_pub.profile_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p10(t out nocopy as_utility_pub.item_property_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p10(t as_utility_pub.item_property_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    );

end as_utility_pub_w;

 

/
