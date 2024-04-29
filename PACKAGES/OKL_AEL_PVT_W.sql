--------------------------------------------------------
--  DDL for Package OKL_AEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AEL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLIAELS.pls 120.2 2005/12/02 12:57:50 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_ael_pvt.ael_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_800
    , a18 JTF_VARCHAR2_TABLE_800
    , a19 JTF_VARCHAR2_TABLE_800
    , a20 JTF_VARCHAR2_TABLE_800
    , a21 JTF_VARCHAR2_TABLE_800
    , a22 JTF_VARCHAR2_TABLE_800
    , a23 JTF_VARCHAR2_TABLE_800
    , a24 JTF_VARCHAR2_TABLE_800
    , a25 JTF_VARCHAR2_TABLE_800
    , a26 JTF_VARCHAR2_TABLE_800
    , a27 JTF_VARCHAR2_TABLE_800
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t okl_ael_pvt.ael_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_800
    , a18 out nocopy JTF_VARCHAR2_TABLE_800
    , a19 out nocopy JTF_VARCHAR2_TABLE_800
    , a20 out nocopy JTF_VARCHAR2_TABLE_800
    , a21 out nocopy JTF_VARCHAR2_TABLE_800
    , a22 out nocopy JTF_VARCHAR2_TABLE_800
    , a23 out nocopy JTF_VARCHAR2_TABLE_800
    , a24 out nocopy JTF_VARCHAR2_TABLE_800
    , a25 out nocopy JTF_VARCHAR2_TABLE_800
    , a26 out nocopy JTF_VARCHAR2_TABLE_800
    , a27 out nocopy JTF_VARCHAR2_TABLE_800
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy okl_ael_pvt.aelv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_800
    , a17 JTF_VARCHAR2_TABLE_800
    , a18 JTF_VARCHAR2_TABLE_800
    , a19 JTF_VARCHAR2_TABLE_800
    , a20 JTF_VARCHAR2_TABLE_800
    , a21 JTF_VARCHAR2_TABLE_800
    , a22 JTF_VARCHAR2_TABLE_800
    , a23 JTF_VARCHAR2_TABLE_800
    , a24 JTF_VARCHAR2_TABLE_800
    , a25 JTF_VARCHAR2_TABLE_800
    , a26 JTF_VARCHAR2_TABLE_800
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_DATE_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_ael_pvt.aelv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_800
    , a17 out nocopy JTF_VARCHAR2_TABLE_800
    , a18 out nocopy JTF_VARCHAR2_TABLE_800
    , a19 out nocopy JTF_VARCHAR2_TABLE_800
    , a20 out nocopy JTF_VARCHAR2_TABLE_800
    , a21 out nocopy JTF_VARCHAR2_TABLE_800
    , a22 out nocopy JTF_VARCHAR2_TABLE_800
    , a23 out nocopy JTF_VARCHAR2_TABLE_800
    , a24 out nocopy JTF_VARCHAR2_TABLE_800
    , a25 out nocopy JTF_VARCHAR2_TABLE_800
    , a26 out nocopy JTF_VARCHAR2_TABLE_800
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_DATE_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy okl_ael_pvt.ae_line_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p6(t okl_ael_pvt.ae_line_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p7(t out nocopy okl_ael_pvt.account_overlay_source_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p7(t okl_ael_pvt.account_overlay_source_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p8(t out nocopy okl_ael_pvt.subledger_doc_seq_value_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p8(t okl_ael_pvt.subledger_doc_seq_value_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p9(t out nocopy okl_ael_pvt.tax_code_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p9(t okl_ael_pvt.tax_code_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p10(t out nocopy okl_ael_pvt.ae_line_number_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p10(t okl_ael_pvt.ae_line_number_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p11(t out nocopy okl_ael_pvt.code_combination_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p11(t okl_ael_pvt.code_combination_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p12(t out nocopy okl_ael_pvt.ae_header_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p12(t okl_ael_pvt.ae_header_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p13(t out nocopy okl_ael_pvt.currency_conversion_type_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p13(t okl_ael_pvt.currency_conversion_type_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p14(t out nocopy okl_ael_pvt.ae_line_type_code_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p14(t okl_ael_pvt.ae_line_type_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p15(t out nocopy okl_ael_pvt.source_table_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p15(t okl_ael_pvt.source_table_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p16(t out nocopy okl_ael_pvt.source_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p16(t okl_ael_pvt.source_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p17(t out nocopy okl_ael_pvt.object_version_number_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p17(t okl_ael_pvt.object_version_number_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p18(t out nocopy okl_ael_pvt.currency_code_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p18(t okl_ael_pvt.currency_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p19(t out nocopy okl_ael_pvt.currency_conversion_date_typ, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p19(t okl_ael_pvt.currency_conversion_date_typ, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p20(t out nocopy okl_ael_pvt.currency_conversion_rate_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p20(t okl_ael_pvt.currency_conversion_rate_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p21(t out nocopy okl_ael_pvt.entered_dr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p21(t okl_ael_pvt.entered_dr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p22(t out nocopy okl_ael_pvt.entered_cr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p22(t okl_ael_pvt.entered_cr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p23(t out nocopy okl_ael_pvt.accounted_dr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p23(t okl_ael_pvt.accounted_dr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p24(t out nocopy okl_ael_pvt.accounted_cr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p24(t okl_ael_pvt.accounted_cr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p25(t out nocopy okl_ael_pvt.reference1_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p25(t okl_ael_pvt.reference1_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p26(t out nocopy okl_ael_pvt.reference2_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p26(t okl_ael_pvt.reference2_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p27(t out nocopy okl_ael_pvt.reference3_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p27(t okl_ael_pvt.reference3_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p28(t out nocopy okl_ael_pvt.reference4_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p28(t okl_ael_pvt.reference4_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p29(t out nocopy okl_ael_pvt.reference5_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p29(t okl_ael_pvt.reference5_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p30(t out nocopy okl_ael_pvt.reference6_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p30(t okl_ael_pvt.reference6_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p31(t out nocopy okl_ael_pvt.reference7_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p31(t okl_ael_pvt.reference7_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p32(t out nocopy okl_ael_pvt.reference8_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p32(t okl_ael_pvt.reference8_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p33(t out nocopy okl_ael_pvt.reference9_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p33(t okl_ael_pvt.reference9_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p34(t out nocopy okl_ael_pvt.reference10_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p34(t okl_ael_pvt.reference10_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p35(t out nocopy okl_ael_pvt.description_typ, a0 JTF_VARCHAR2_TABLE_800);
  procedure rosetta_table_copy_out_p35(t okl_ael_pvt.description_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800);

  procedure rosetta_table_copy_in_p36(t out nocopy okl_ael_pvt.third_party_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p36(t okl_ael_pvt.third_party_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p37(t out nocopy okl_ael_pvt.third_party_sub_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p37(t okl_ael_pvt.third_party_sub_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p38(t out nocopy okl_ael_pvt.stat_amount_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p38(t okl_ael_pvt.stat_amount_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p39(t out nocopy okl_ael_pvt.ussgl_transaction_code_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p39(t okl_ael_pvt.ussgl_transaction_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p40(t out nocopy okl_ael_pvt.subledger_doc_sequence_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p40(t okl_ael_pvt.subledger_doc_sequence_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p41(t out nocopy okl_ael_pvt.accounting_error_code_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p41(t okl_ael_pvt.accounting_error_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p42(t out nocopy okl_ael_pvt.gl_transfer_error_code_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p42(t okl_ael_pvt.gl_transfer_error_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p43(t out nocopy okl_ael_pvt.gl_sl_link_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p43(t okl_ael_pvt.gl_sl_link_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p44(t out nocopy okl_ael_pvt.taxable_entered_dr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p44(t okl_ael_pvt.taxable_entered_dr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p45(t out nocopy okl_ael_pvt.taxable_entered_cr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p45(t okl_ael_pvt.taxable_entered_cr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p46(t out nocopy okl_ael_pvt.taxable_accounted_dr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p46(t okl_ael_pvt.taxable_accounted_dr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p47(t out nocopy okl_ael_pvt.taxable_accounted_cr_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p47(t okl_ael_pvt.taxable_accounted_cr_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p48(t out nocopy okl_ael_pvt.applied_from_trx_hdr_tab_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p48(t okl_ael_pvt.applied_from_trx_hdr_tab_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p49(t out nocopy okl_ael_pvt.applied_from_trx_hdr_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p49(t okl_ael_pvt.applied_from_trx_hdr_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p50(t out nocopy okl_ael_pvt.applied_to_trx_hdr_table_typ, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p50(t okl_ael_pvt.applied_to_trx_hdr_table_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p51(t out nocopy okl_ael_pvt.applied_to_trx_hdr_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p51(t okl_ael_pvt.applied_to_trx_hdr_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p52(t out nocopy okl_ael_pvt.tax_link_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p52(t okl_ael_pvt.tax_link_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p53(t out nocopy okl_ael_pvt.org_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p53(t okl_ael_pvt.org_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p54(t out nocopy okl_ael_pvt.program_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p54(t okl_ael_pvt.program_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p55(t out nocopy okl_ael_pvt.program_application_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p55(t okl_ael_pvt.program_application_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p56(t out nocopy okl_ael_pvt.program_update_date_typ, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p56(t okl_ael_pvt.program_update_date_typ, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p57(t out nocopy okl_ael_pvt.request_id_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p57(t okl_ael_pvt.request_id_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p58(t out nocopy okl_ael_pvt.created_by_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p58(t okl_ael_pvt.created_by_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p59(t out nocopy okl_ael_pvt.creation_date_typ, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p59(t okl_ael_pvt.creation_date_typ, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p60(t out nocopy okl_ael_pvt.last_updated_by_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p60(t okl_ael_pvt.last_updated_by_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p61(t out nocopy okl_ael_pvt.last_update_date_typ, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p61(t okl_ael_pvt.last_update_date_typ, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p62(t out nocopy okl_ael_pvt.last_update_login_typ, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p62(t okl_ael_pvt.last_update_login_typ, a0 out nocopy JTF_NUMBER_TABLE);

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  );
  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  );
  procedure insert_row_perf(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  );
  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  );
  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  );
  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  );
  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  );
end okl_ael_pvt_w;

 

/
