--------------------------------------------------------
--  DDL for Package ARW_SEARCH_CUSTOMERS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARW_SEARCH_CUSTOMERS_W" AUTHID CURRENT_USER as
 /* $Header: ARWCUSWS.pls 120.0.12010000.2 2008/11/21 15:26:29 avepati noship $ */

  procedure rosetta_table_copy_in_p1(t out nocopy arw_search_customers.custsite_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t arw_search_customers.custsite_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure initialize_account_sites(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p_party_id  NUMBER
    , p_session_id  NUMBER
    , p_user_id  NUMBER
    , p_org_id  NUMBER
    , p_is_internal_user  VARCHAR2
  );

end arw_search_customers_w;

/
