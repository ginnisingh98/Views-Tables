--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_CASHFLOW_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_CASHFLOW_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEQUCS.pls 120.5 2006/02/10 07:41:36 asawanka noship $ */
  procedure rosetta_table_copy_in_p21(t out nocopy okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p21(t okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_cashflow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 in out nocopy  VARCHAR2
    , p3_a1 in out nocopy  NUMBER
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  VARCHAR2
    , p3_a4 in out nocopy  VARCHAR2
    , p3_a5 in out nocopy  VARCHAR2
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  VARCHAR2
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  VARCHAR2
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  NUMBER
    , p3_a12 in out nocopy  NUMBER
    , p3_a13 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_DATE_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_cashflow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 in out nocopy  VARCHAR2
    , p3_a1 in out nocopy  NUMBER
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  VARCHAR2
    , p3_a4 in out nocopy  VARCHAR2
    , p3_a5 in out nocopy  VARCHAR2
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  VARCHAR2
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  VARCHAR2
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  NUMBER
    , p3_a12 in out nocopy  NUMBER
    , p3_a13 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_DATE_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_lease_quote_cashflow_pvt_w;

/
