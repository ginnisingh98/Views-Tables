--------------------------------------------------------
--  DDL for Package OKL_SEC_CONCURRENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_CONCURRENT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLESZTS.pls 120.0 2006/02/21 23:52:36 stmathew noship $ */
  procedure rosetta_table_copy_in_p22(t out nocopy okl_sec_concurrent_pvt.error_message_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p22(t okl_sec_concurrent_pvt.error_message_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

end okl_sec_concurrent_pvt_w;

/
