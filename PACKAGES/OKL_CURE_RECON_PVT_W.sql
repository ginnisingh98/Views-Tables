--------------------------------------------------------
--  DDL for Package OKL_CURE_RECON_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_RECON_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLIRCOS.pls 115.3 2003/10/07 17:17:25 pdevaraj noship $ */
  procedure rosetta_table_copy_in_p14(t out nocopy okl_cure_recon_pvt.cure_amount_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p14(t okl_cure_recon_pvt.cure_amount_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure update_cure_invoice(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_report_id  NUMBER
    , p_invoice_date  date
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p_operation  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_cure_recon_pvt_w;

 

/
