--------------------------------------------------------
--  DDL for Package OKL_REVERSAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSAL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEREVS.pls 120.1 2005/07/11 14:20:03 asawanka noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy okl_reversal_pvt.source_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t okl_reversal_pvt.source_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure reverse_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_id  NUMBER
    , p_source_table  VARCHAR2
    , p_acct_date  date
  );
  procedure reverse_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_table  VARCHAR2
    , p_acct_date  date
    , p_source_id_tbl JTF_NUMBER_TABLE
  );
end okl_reversal_pvt_w;

 

/
