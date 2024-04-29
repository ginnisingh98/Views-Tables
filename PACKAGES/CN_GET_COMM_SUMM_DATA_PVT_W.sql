--------------------------------------------------------
--  DDL for Package CN_GET_COMM_SUMM_DATA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_COMM_SUMM_DATA_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwcomms.pls 120.4 2005/10/24 07:21 sjustina noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_get_comm_summ_data_pvt.comm_summ_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_get_comm_summ_data_pvt.comm_summ_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p2(t out nocopy cn_get_comm_summ_data_pvt.salesrep_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t cn_get_comm_summ_data_pvt.salesrep_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p3(t out nocopy cn_get_comm_summ_data_pvt.group_code_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p3(t cn_get_comm_summ_data_pvt.group_code_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p5(t out nocopy cn_get_comm_summ_data_pvt.pe_info_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t cn_get_comm_summ_data_pvt.pe_info_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy cn_get_comm_summ_data_pvt.salesrep_info_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t cn_get_comm_summ_data_pvt.salesrep_info_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p9(t out nocopy cn_get_comm_summ_data_pvt.pe_ptd_credit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p9(t cn_get_comm_summ_data_pvt.pe_ptd_credit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_salesrep_list(p_first  NUMBER
    , p_last  NUMBER
    , p_period_id  NUMBER
    , p_analyst_id  NUMBER
    , p_org_id  NUMBER
    , x_total_rows out nocopy  NUMBER
    , x_salesrep_tbl out nocopy JTF_NUMBER_TABLE
  );
  procedure get_quota_summary(p_salesrep_id  NUMBER
    , p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_DATE_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_quota_manager_summary(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_quota_analyst_summary(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p_analyst_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_DATE_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_salesrep_pe_info(p_salesrep_id  NUMBER
    , p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_manager_pe_info(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_analyst_pe_info(p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p_org_id  NUMBER
    , p_analyst_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_salesrep_details(p_salesrep_id  NUMBER
    , p_org_id  NUMBER
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_manager_details(p_org_id  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a5 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_analyst_details(p_org_id  NUMBER
    , p_analyst_id  NUMBER
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a5 out nocopy JTF_NUMBER_TABLE
  );
  procedure get_group_codes(p_org_id  NUMBER
    , x_result_tbl out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_ptd_credit(p_salesrep_id  NUMBER
    , p_payrun_id  NUMBER
    , p_org_id  NUMBER
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
  );
end cn_get_comm_summ_data_pvt_w;

 

/
