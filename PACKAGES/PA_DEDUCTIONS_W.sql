--------------------------------------------------------
--  DDL for Package PA_DEDUCTIONS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DEDUCTIONS_W" AUTHID CURRENT_USER as
  /* $Header: PADCTNRS.pls 120.1.12010000.1 2009/07/21 10:59:27 sosharma noship $ */
procedure rosetta_table_copy_in_p0(t out nocopy pa_deductions.g_dctn_hdrid, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t pa_deductions.g_dctn_hdrid, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out nocopy pa_deductions.g_dctn_txnid, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t pa_deductions.g_dctn_txnid, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p4(t out nocopy pa_deductions.g_dctn_hdrtbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t pa_deductions.g_dctn_hdrtbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy pa_deductions.g_dctn_txntbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_4000
    , a19 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t pa_deductions.g_dctn_txntbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_4000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_deduction_hdr(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_NUMBER_TABLE
    , p0_a15 in out nocopy JTF_NUMBER_TABLE
    , p0_a16 in out nocopy JTF_DATE_TABLE
    , p0_a17 in out nocopy JTF_DATE_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  );
  procedure create_deduction_txn(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_DATE_TABLE
    , p0_a6 in out nocopy JTF_DATE_TABLE
    , p0_a7 in out nocopy JTF_NUMBER_TABLE
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_NUMBER_TABLE
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_NUMBER_TABLE
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  );
  procedure update_deduction_hdr(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_NUMBER_TABLE
    , p0_a15 in out nocopy JTF_NUMBER_TABLE
    , p0_a16 in out nocopy JTF_DATE_TABLE
    , p0_a17 in out nocopy JTF_DATE_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  );
  procedure update_deduction_txn(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_DATE_TABLE
    , p0_a6 in out nocopy JTF_DATE_TABLE
    , p0_a7 in out nocopy JTF_NUMBER_TABLE
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_NUMBER_TABLE
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_NUMBER_TABLE
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
  );
  procedure delete_deduction_hdr(p_dctn_hdrid JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
  );
  procedure delete_deduction_txn(p_dctn_txnid JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
  );
  procedure validate_deduction_hdr(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_NUMBER_TABLE
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_NUMBER_TABLE
    , p0_a15 in out nocopy JTF_NUMBER_TABLE
    , p0_a16 in out nocopy JTF_DATE_TABLE
    , p0_a17 in out nocopy JTF_DATE_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a20 in out nocopy JTF_NUMBER_TABLE
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure validate_deduction_txn(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_NUMBER_TABLE
    , p0_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a5 in out nocopy JTF_DATE_TABLE
    , p0_a6 in out nocopy JTF_DATE_TABLE
    , p0_a7 in out nocopy JTF_NUMBER_TABLE
    , p0_a8 in out nocopy JTF_NUMBER_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_NUMBER_TABLE
    , p0_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a12 in out nocopy JTF_NUMBER_TABLE
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p_msg_count out nocopy  NUMBER
    , p_msg_data out nocopy  VARCHAR2
    , p_return_status out nocopy  VARCHAR2
    , p_calling_mode  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end pa_deductions_w;

/
