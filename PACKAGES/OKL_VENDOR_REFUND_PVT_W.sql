--------------------------------------------------------
--  DDL for Package OKL_VENDOR_REFUND_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_REFUND_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLIRFDS.pls 120.1 2005/09/30 21:26:59 cklee noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy okl_vendor_refund_pvt.error_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t okl_vendor_refund_pvt.error_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy okl_vendor_refund_pvt.error_message_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p5(t okl_vendor_refund_pvt.error_message_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

end okl_vendor_refund_pvt_w;

 

/
