--------------------------------------------------------
--  DDL for Package OKL_MULTI_GAAP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MULTI_GAAP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEGAPS.pls 115.2 2004/02/06 22:35:51 sgiyer noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_multi_gaap_pvt.asset_deprn_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t okl_multi_gaap_pvt.asset_deprn_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy okl_multi_gaap_pvt.ae_lines_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t okl_multi_gaap_pvt.ae_lines_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy okl_multi_gaap_pvt.rep_prd_summary_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_multi_gaap_pvt.rep_prd_summary_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  function submit_multi_gaap(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_date_from  date
    , p_date_to  date
    , p_batch_name  VARCHAR2
  ) return number;
end okl_multi_gaap_pvt_w;

 

/
