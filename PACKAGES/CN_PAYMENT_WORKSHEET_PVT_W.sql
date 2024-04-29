--------------------------------------------------------
--  DDL for Package CN_PAYMENT_WORKSHEET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYMENT_WORKSHEET_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwwkshs.pls 120.1.12000000.3 2007/05/23 11:29:36 rrshetty ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy cn_payment_worksheet_pvt.salesrep_tab_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t cn_payment_worksheet_pvt.salesrep_tab_typ, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy cn_payment_worksheet_pvt.calc_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t cn_payment_worksheet_pvt.calc_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    );

  procedure generic_conc_processor(p_payrun_id  NUMBER
    , p1_a0  VARCHAR2
    , p_org_id  NUMBER
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , x_errbuf out nocopy  VARCHAR2
    , x_retcode out nocopy  NUMBER
  );
  procedure create_worksheet(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , x_loading_status out nocopy  VARCHAR2
    , x_status out nocopy  VARCHAR2
  );
end cn_payment_worksheet_pvt_w;

 

/
