--------------------------------------------------------
--  DDL for Package OKC_XPRT_QA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_QA_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKCWXRULQAS.pls 120.0 2005/05/26 09:56:09 appldev noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy okc_xprt_qa_pvt.ruleidlist, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t okc_xprt_qa_pvt.ruleidlist, a0 out nocopy JTF_NUMBER_TABLE);

  procedure qa_rules(p_qa_mode  VARCHAR2
    , p_ruleid_tbl JTF_NUMBER_TABLE
    , x_sequence_id out nocopy  NUMBER
    , x_qa_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure sync_rules(p_sync_mode  VARCHAR2
    , p_org_id  NUMBER
    , p_ruleid_tbl JTF_NUMBER_TABLE
    , x_request_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okc_xprt_qa_pvt_w;

 

/
