--------------------------------------------------------
--  DDL for Package LNS_FEE_ENGINE_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FEE_ENGINE_W" AUTHID CURRENT_USER as
  /* $Header: LNS_FEE_ENGINJ_S.pls 120.3.12010000.4 2010/02/24 01:45:04 mbolli ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_fee_engine.fee_basis_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t lns_fee_engine.fee_basis_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy lns_fee_engine.fee_structure_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t lns_fee_engine.fee_structure_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy lns_fee_engine.fee_calc_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t lns_fee_engine.fee_calc_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure calculatefees(p_loan_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_NUMBER_TABLE
    , p_installment  NUMBER
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_300
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_DATE_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_VARCHAR2_TABLE_100
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_VARCHAR2_TABLE_100
    , p3_a19 JTF_VARCHAR2_TABLE_100
    , p3_a20 JTF_NUMBER_TABLE
    , p3_a21 JTF_NUMBER_TABLE
    , p3_a22 JTF_DATE_TABLE
    , p3_a23 JTF_VARCHAR2_TABLE_100
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure writefeeschedule(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a7 in out nocopy JTF_NUMBER_TABLE
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 in out nocopy JTF_NUMBER_TABLE
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure updatefeeschedule(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_300
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p3_a9 JTF_VARCHAR2_TABLE_100
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getfeeschedule(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p_disb_header_id  NUMBER
    , p_phase  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getfeedetails(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_NUMBER_TABLE
    , p_based_on_terms  VARCHAR2
    , p_phase  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure processfees(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_NUMBER_TABLE
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_300
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getsubmitforapprfeeschedule(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_billed_flag  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_fee_engine_w;

/
