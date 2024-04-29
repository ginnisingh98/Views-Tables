--------------------------------------------------------
--  DDL for Package OKL_API_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_API_W" AUTHID CURRENT_USER as
  /* $Header: OKLIAPIS.pls 120.3 2005/09/22 23:31:37 fmiao noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_api.msg_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t okl_api.msg_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p3(t out nocopy okl_api.error_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t okl_api.error_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

end okl_api_w;

 

/
