--------------------------------------------------------
--  DDL for Package ITG_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_MSG" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgmsgs.pls 120.8 2006/09/15 13:35:12 pvaddana noship $
 * CVS:  itgmsgs.pls,v 1.16 2002/11/15 23:57:03 ecoe Exp
 */

  PROCEDURE text(p_text       VARCHAR2);
  PROCEDURE debug(p_pkg_name   VARCHAR2,p_proc_name  VARCHAR2,p_text       VARCHAR2);
  PROCEDURE debug_more(p_text       VARCHAR2);

  PROCEDURE missing_element_value(
    p_name       VARCHAR2,
    p_value      VARCHAR2
  );

  PROCEDURE data_value_error(
    p_value      VARCHAR2,
    p_min	 NUMBER,
    p_max        NUMBER
  );

  PROCEDURE update_failed;

  PROCEDURE existing_flex_value(
    p_flex_value VARCHAR2,
    p_vset_id    NUMBER
  );

  PROCEDURE invalid_account_type(
    p_acct_type  VARCHAR2
  );

  PROCEDURE flex_insert_fail(
    p_flex_value VARCHAR2
  );

  PROCEDURE flex_update_fail_novalue(
    p_flex_value VARCHAR2
  );

  PROCEDURE flex_update_fail_notl(
    p_flex_value VARCHAR2
  );

  PROCEDURE invalid_currency_code;
  PROCEDURE same_currency_code;
  PROCEDURE duplicate_exchange_rate;

  PROCEDURE no_po_found(
    p_po_code VARCHAR2,
    p_org_id  NUMBER
  );

  PROCEDURE no_line_locs_found;
  PROCEDURE allocship_toomany_rtn;
  PROCEDURE allocdist_toomany_rtn;
  PROCEDURE allocreqn_toomany_rtn;
  PROCEDURE poline_closed_rcv;
  PROCEDURE poline_zeroqty_rcv;
  /*Added to error out the negative RECEIPTS (Bug:5438268) */
  PROCEDURE poline_negqty_rcv;
  PROCEDURE receipt_tol_exceeded;

  PROCEDURE receipt_closepo_fail(
    p_return_code VARCHAR2
  );
  /*Added  to fix bug :5258514 */
  PROCEDURE receipt_closerelease_fail(
  p_return_code VARCHAR2
  );

  PROCEDURE inspect_tol_exceeded;
  PROCEDURE poline_negqty_ins;
  PROCEDURE poline_zeroqty_ins;
  PROCEDURE poline_zeroamt_inv;
  PROCEDURE poline_badsign_inv;
  PROCEDURE poline_closed_inv;
  PROCEDURE invoice_tol_exceeded;

  PROCEDURE invoice_closepo_fail(
    p_return_code VARCHAR2
  );

 /*Added  to fix bug :5258514 */
  PROCEDURE invoice_closerelease_fail(
    p_return_code VARCHAR2
  );
  PROCEDURE poline_closed_final;
  PROCEDURE poline_invalid_doctype;
  PROCEDURE toomany_base_uom_flag;
  PROCEDURE null_disable_date;
  PROCEDURE delete_failed;
  PROCEDURE bad_uom_crossval;
  PROCEDURE toomany_default_conv_flag;
  PROCEDURE neg_conv;

  PROCEDURE conv_not_found(
    p_uom_code VARCHAR2
  );

  PROCEDURE base_uom_not_found(
    p_uom_code VARCHAR2
  );

  PROCEDURE uom_not_found(
    p_uom_code VARCHAR2
  );

  PROCEDURE unknown_document_error;
  PROCEDURE document_success;
  PROCEDURE orgeff_check_failed;

  PROCEDURE invalid_argument(
    p_name  VARCHAR2,
    p_value VARCHAR2
  );

  PROCEDURE invalid_doc_direction(
    p_doc_dir VARCHAR2
  );

  PROCEDURE missing_orgind(
    p_doc_typ VARCHAR2,
    p_doc_dir VARCHAR2
  );

  PROCEDURE effectivity_update_fail(
    p_org_id  NUMBER,
    p_doc_typ VARCHAR2,
    p_doc_dir VARCHAR2,
    p_eff_id  NUMBER
  );

  PROCEDURE effectivity_insert_fail(
    p_org_id  NUMBER,
    p_doc_typ VARCHAR2,
    p_doc_dir VARCHAR2
  );

  PROCEDURE daily_exchange_rate_error(
    p_currency_from VARCHAR2,
    p_currency_to   VARCHAR2,
    p_error_code    VARCHAR2
  );

  PROCEDURE checked_error(p_action VARCHAR2);
  PROCEDURE unexpected_error(p_action VARCHAR2);
  PROCEDURE invalid_org(p_org_id VARCHAR2);
  PROCEDURE vendor_not_found(p_name VARCHAR2);
  PROCEDURE no_vendor_site(p_site_code VARCHAR2);
  PROCEDURE gl_req_fail(p_sob_id VARCHAR2);
  PROCEDURE no_gl_currency(p_sob_id VARCHAR2);
  PROCEDURE NO_SET_OF_BOOKS(p_sob VARCHAR2);
  PROCEDURE NO_GL_PERIOD(p_sob VARCHAR2,p_effective_date VARCHAR2);
  PROCEDURE no_uom(p_uom VARCHAR2);
  PROCEDURE no_uom_class(p_uom_class VARCHAR2);
  PROCEDURE no_uomclass_conv;
  PROCEDURE dup_uomclass_conv;
  PROCEDURE no_uom_conv;
  PROCEDURE no_req_hdr(p_reqid VARCHAR2,p_org VARCHAR2);
  PROCEDURE no_req_line(p_req_id VARCHAR2, p_req_line VARCHAR2,p_org VARCHAR2);
  PROCEDURE no_po_line(p_org_id VARCHAR2,p_po_code VARCHAR2,p_line_num VARCHAR2);
  PROCEDURE incorrect_setup;
  PROCEDURE mici_only_failed;
  PROCEDURE no_hazard_class(p_hazrdmatl VARCHAR2);
  PROCEDURE cln_failure(p_clnmsg VARCHAR2);
  PROCEDURE no_vset(p_set_id VARCHAR2);
  PROCEDURE no_currtype_match(p_curr_from VARCHAR2,p_curr_to VARCHAR2);
  PROCEDURE gl_no_currec(p_sob VARCHAR2,p_currency_to VARCHAR2);
  PROCEDURE ratetype_noupd;
  PROCEDURE gl_fromcur_wrong(p_sob VARCHAR2, p_currency_from VARCHAR2);
  PROCEDURE item_commodity_ign;
  PROCEDURE item_import_pending(p_ccmid VARCHAR2,p_status VARCHAR2,p_phase VARCHAR2);
  PROCEDURE ITEMCAT_IMPORT_PENDING(p_ccmid VARCHAR2);
  PROCEDURE inv_cp_fail(p_status VARCHAR2,p_phase VARCHAR2);
  PROCEDURE item_import_errors;
  PROCEDURE dup_vendor;
  PROCEDURE vendor_site_only;
  PROCEDURE sup_number_exists(p_sup_no VARCHAR2);
  PROCEDURE vendor_contact_only;
  PROCEDURE dup_uom(p_uom_code VARCHAR2,p_unit_of_measure VARCHAR2);
  PROCEDURE dup_uom_conv(p_item VARCHAR2,p_uom VARCHAR2);
  PROCEDURE uomconvrate_err;
  PROCEDURE apicallret(p_api VARCHAR2, p_retcode VARCHAR2, p_retmsg VARCHAR2);
  /* Added following two procs to fix bug 4882347 */
  PROCEDURE inv_qty_larg_than_exp;
  PROCEDURE insp_qty_larg_than_exp;
 /*Added to validate flex_value max size of COA inbound transaction to fix bug : 5533589*/
  PROCEDURE INVALID_FLEXVAL_LENGTH(p_vset_id  NUMBER,p_flex_value  VARCHAR2);
  END ITG_MSG;

 

/
