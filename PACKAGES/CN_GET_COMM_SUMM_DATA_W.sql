--------------------------------------------------------
--  DDL for Package CN_GET_COMM_SUMM_DATA_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_COMM_SUMM_DATA_W" AUTHID CURRENT_USER as
  /* $Header: cnwcomms.pls 115.3 2001/01/15 18:45:58 pkm ship     $ */
  procedure rosetta_table_copy_in_p1(t out cn_get_comm_summ_data.comm_summ_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_get_comm_summ_data.comm_summ_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_NUMBER_TABLE
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out cn_get_comm_summ_data.pe_info_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t cn_get_comm_summ_data.pe_info_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_NUMBER_TABLE
    );

  procedure get_quota_summary(p_first  NUMBER
    , p_last  NUMBER
    , p_period_id  NUMBER
    , p_user_id  NUMBER
    , p_credit_type_id  NUMBER
    , x_total_rows out  NUMBER
    , p6_a0 out JTF_NUMBER_TABLE
    , p6_a1 out JTF_VARCHAR2_TABLE_300
    , p6_a2 out JTF_VARCHAR2_TABLE_100
    , p6_a3 out JTF_VARCHAR2_TABLE_100
    , p6_a4 out JTF_VARCHAR2_TABLE_100
    , p6_a5 out JTF_VARCHAR2_TABLE_300
    , p6_a6 out JTF_VARCHAR2_TABLE_100
    , p6_a7 out JTF_VARCHAR2_TABLE_100
    , p6_a8 out JTF_NUMBER_TABLE
    , p6_a9 out JTF_NUMBER_TABLE
    , p6_a10 out JTF_NUMBER_TABLE
  );
  procedure get_pe_info(p_srp_plan_assign_id  NUMBER
    , p_period_id  NUMBER
    , p_credit_type_id  NUMBER
    , p3_a0 out JTF_VARCHAR2_TABLE_100
    , p3_a1 out JTF_NUMBER_TABLE
    , p3_a2 out JTF_NUMBER_TABLE
    , p3_a3 out JTF_NUMBER_TABLE
    , p3_a4 out JTF_NUMBER_TABLE
    , p3_a5 out JTF_NUMBER_TABLE
    , p4_a0 out JTF_VARCHAR2_TABLE_100
    , p4_a1 out JTF_NUMBER_TABLE
    , p4_a2 out JTF_NUMBER_TABLE
    , p4_a3 out JTF_NUMBER_TABLE
    , p4_a4 out JTF_NUMBER_TABLE
    , p4_a5 out JTF_NUMBER_TABLE
    , x_ytd_total_earnings out  NUMBER
    , x_ptd_total_earnings out  NUMBER
  );
  procedure get_group_codes(p0_a0 out JTF_VARCHAR2_TABLE_100
    , p0_a1 out JTF_NUMBER_TABLE
    , p0_a2 out JTF_NUMBER_TABLE
    , p0_a3 out JTF_NUMBER_TABLE
    , p0_a4 out JTF_NUMBER_TABLE
    , p0_a5 out JTF_NUMBER_TABLE
  );
end cn_get_comm_summ_data_w;

 

/
