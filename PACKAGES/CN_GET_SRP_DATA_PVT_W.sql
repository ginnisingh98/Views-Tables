--------------------------------------------------------
--  DDL for Package CN_GET_SRP_DATA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_SRP_DATA_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwsfgts.pls 115.7 2002/11/25 22:30:41 nkodkani ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_get_srp_data_pvt.srp_data_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_get_srp_data_pvt.srp_data_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_srp_list(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p0_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a3 out nocopy JTF_DATE_TABLE
    , p0_a4 out nocopy JTF_DATE_TABLE
    , p0_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 out nocopy JTF_NUMBER_TABLE
    , p0_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 out nocopy JTF_NUMBER_TABLE
    , p0_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure search_srp_data(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_date  date
    , p_search_name  VARCHAR2
    , p_search_job  VARCHAR2
    , p_search_emp_num  VARCHAR2
    , p_search_group  VARCHAR2
    , p_order_by  NUMBER
    , p_order_dir  VARCHAR2
    , x_total_rows out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_DATE_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_srp_data(p_srp_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_DATE_TABLE
    , p1_a4 out nocopy JTF_DATE_TABLE
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_NUMBER_TABLE
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a11 out nocopy JTF_NUMBER_TABLE
    , p1_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_managers(p_srp_id  NUMBER
    , p_date  date
    , p_comp_group_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
end cn_get_srp_data_pvt_w;

 

/
