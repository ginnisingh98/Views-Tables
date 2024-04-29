--------------------------------------------------------
--  DDL for Package CN_ACC_PERIODS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ACC_PERIODS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwsyprs.pls 120.1 2005/09/14 03:43 vensrini noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_acc_periods_pvt.acc_period_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_acc_periods_pvt.acc_period_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure update_acc_periods(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_acc_periods(p_year  NUMBER
    , x_system_status out nocopy  VARCHAR2
    , x_calendar out nocopy  VARCHAR2
    , x_period_type out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_DATE_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_NUMBER_TABLE
  );
end cn_acc_periods_pvt_w;

 

/
