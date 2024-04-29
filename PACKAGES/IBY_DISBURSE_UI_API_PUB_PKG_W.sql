--------------------------------------------------------
--  DDL for Package IBY_DISBURSE_UI_API_PUB_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DISBURSE_UI_API_PUB_PKG_W" AUTHID CURRENT_USER as
  /* $Header: ibydapiws.pls 120.4.12010000.3 2010/05/20 13:00:48 gmaheswa ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy iby_disburse_ui_api_pub_pkg.docpayidtab, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t iby_disburse_ui_api_pub_pkg.docpayidtab, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out nocopy iby_disburse_ui_api_pub_pkg.docpaystatustab, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t iby_disburse_ui_api_pub_pkg.docpaystatustab, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p2(t out nocopy iby_disburse_ui_api_pub_pkg.pmtidtab, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t iby_disburse_ui_api_pub_pkg.pmtidtab, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p3(t out nocopy iby_disburse_ui_api_pub_pkg.pmtstatustab, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p3(t iby_disburse_ui_api_pub_pkg.pmtstatustab, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p4(t out nocopy iby_disburse_ui_api_pub_pkg.pmtdocstab, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t iby_disburse_ui_api_pub_pkg.pmtdocstab, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p5(t out nocopy iby_disburse_ui_api_pub_pkg.paperdocnumtab, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p5(t iby_disburse_ui_api_pub_pkg.paperdocnumtab, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p6(t out nocopy iby_disburse_ui_api_pub_pkg.paperdocusereasontab, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p6(t iby_disburse_ui_api_pub_pkg.paperdocusereasontab, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p7(t out nocopy iby_disburse_ui_api_pub_pkg.appnamestab, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p7(t iby_disburse_ui_api_pub_pkg.appnamestab, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p8(t out nocopy iby_disburse_ui_api_pub_pkg.appidstab, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p8(t iby_disburse_ui_api_pub_pkg.appidstab, a0 out nocopy JTF_NUMBER_TABLE);

  procedure remove_documents_payable(p_doc_list JTF_NUMBER_TABLE
    , p_doc_status_list JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
  );
  procedure remove_payments(p_pmt_list JTF_NUMBER_TABLE
    , p_pmt_status_list JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
  );
  procedure stop_payments(p_pmt_list JTF_NUMBER_TABLE
    , p_pmt_status_list JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
  );
  procedure reprint_prenum_pmt_documents(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_pmt_list JTF_NUMBER_TABLE
    , p_new_ppr_docs_list JTF_NUMBER_TABLE
    , p_old_ppr_docs_list JTF_NUMBER_TABLE
    , p_printer_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure reprint_blank_pmt_documents(p_instr_id  NUMBER
    , p_pmt_list JTF_NUMBER_TABLE
    , p_printer_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure finalize_print_status(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_used_docs_list JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  );
  procedure finalize_print_status(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_used_docs_list JTF_NUMBER_TABLE
    , p_used_pmts_list JTF_NUMBER_TABLE
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  );
  procedure finalize_print_status(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_used_docs_list JTF_NUMBER_TABLE
    , p_used_pmts_list JTF_NUMBER_TABLE
    , p_skipped_docs_list JTF_NUMBER_TABLE
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  );
  procedure finalize_instr_print_status(p_instr_id  NUMBER
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  );
  procedure mark_all_pmts_complete(p_instr_id  NUMBER
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  );
  procedure checkifdocused(p_paper_doc_num  NUMBER
    , p_pmt_document_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure checkifallpmtsterminated(p_instr_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure checkifpmtininstexists(p_payreq_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure checkifinstrxmitoutsidesystem(p_instr_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure checkifpmtentitylocked(p_object_id  NUMBER
    , p_object_type  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end iby_disburse_ui_api_pub_pkg_w;

/
