--------------------------------------------------------
--  DDL for Package OKL_CNTR_GRP_BILLING_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CNTR_GRP_BILLING_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLICLBS.pls 120.3 2008/02/21 13:24:51 udhenuko noship $ */
  procedure rosetta_table_copy_in_p14(t out nocopy okl_cntr_grp_billing_pvt.cntr_bill_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p14(t okl_cntr_grp_billing_pvt.cntr_bill_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    );

  procedure counter_grp_billing_calc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
  );
  procedure counter_grp_billing_calc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  );
  procedure counter_grp_billing_insert(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
  );
  procedure counter_grp_billing_insert(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  );
end okl_cntr_grp_billing_pvt_w;

/