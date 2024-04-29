--------------------------------------------------------
--  DDL for Package OKC_AQ_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AQ_PVT_W" AUTHID CURRENT_USER as
  /* $Header: okc_aq_pvt_w_s.pls 120.0 2005/05/25 19:22:46 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okc_aq_pvt.msg_tab_typ, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p1(t okc_aq_pvt.msg_tab_typ, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    );

end okc_aq_pvt_w;

 

/
