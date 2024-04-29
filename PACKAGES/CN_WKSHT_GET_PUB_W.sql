--------------------------------------------------------
--  DDL for Package CN_WKSHT_GET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_WKSHT_GET_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwwkgts.pls 115.17 2003/06/27 20:36:34 achung ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_wksht_get_pub.wksht_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_wksht_get_pub.wksht_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_srp_wksht(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_payrun_id  NUMBER
    , p_salesrep_name  VARCHAR2
    , p_employee_number  VARCHAR2
    , p_analyst_name  VARCHAR2
    , p_my_analyst  VARCHAR2
    , p_unassigned  VARCHAR2
    , p_worksheet_status  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_order_by  VARCHAR2
    , p18_a0 out nocopy JTF_NUMBER_TABLE
    , p18_a1 out nocopy JTF_NUMBER_TABLE
    , p18_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p18_a3 out nocopy JTF_NUMBER_TABLE
    , p18_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a5 out nocopy JTF_NUMBER_TABLE
    , p18_a6 out nocopy JTF_NUMBER_TABLE
    , p18_a7 out nocopy JTF_NUMBER_TABLE
    , p18_a8 out nocopy JTF_NUMBER_TABLE
    , p18_a9 out nocopy JTF_NUMBER_TABLE
    , p18_a10 out nocopy JTF_NUMBER_TABLE
    , p18_a11 out nocopy JTF_NUMBER_TABLE
    , p18_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a15 out nocopy JTF_NUMBER_TABLE
    , p18_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p18_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , x_tot_amount_earnings out nocopy  NUMBER
    , x_tot_amount_adj out nocopy  NUMBER
    , x_tot_amount_adj_rec out nocopy  NUMBER
    , x_tot_amount_total out nocopy  NUMBER
    , x_tot_held_amount out nocopy  NUMBER
    , x_tot_ced out nocopy  NUMBER
    , x_tot_earn_diff out nocopy  NUMBER
    , x_total_records out nocopy  NUMBER
  );
end cn_wksht_get_pub_w;

 

/
