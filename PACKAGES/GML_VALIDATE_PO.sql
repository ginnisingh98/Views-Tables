--------------------------------------------------------
--  DDL for Package GML_VALIDATE_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_VALIDATE_PO" AUTHID CURRENT_USER AS
/* $Header: GMLPOVAS.pls 115.5 99/07/16 06:17:27 porting shi $ */

  FUNCTION val_orgn_code
	  (v_orgn_code IN sy_orgn_mst.orgn_code%TYPE) RETURN BOOLEAN;

  /* FUNCTION val_operator_code
    	(v_op_code IN sy_oper_mst.op_code%TYPE) RETURN BOOLEAN;*/

  FUNCTION val_doc_assign
	(v_orgn_code IN sy_docs_seq.orgn_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_warehouse
  	(v_whse_code IN ic_whse_mst.whse_code%TYPE,
	 v_orgn_code IN ic_whse_mst.orgn_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_vendor
	(v_of_vendor_site_id IN po_vend_mst.of_vendor_site_id%TYPE,
	 v_co_code IN po_vend_mst.co_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_item
	(v_item_no IN ic_item_mst.item_no%TYPE) RETURN BOOLEAN;

  FUNCTION val_currency
	(v_currency_code IN gl_curr_mst.currency_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_aqui_cost_code
	(v_aqui_cost_code IN po_cost_mst.aqui_cost_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_uom
	(v_um_code IN sy_uoms_mst.um_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_shipper_code
	(v_shipper_code IN op_ship_mst.shipper_code%TYPE) RETURN BOOLEAN;

  FUNCTION val_frtbill_mthd
	(v_frtbill_mthd IN op_frgt_mth.of_frtbill_mthd%TYPE) RETURN BOOLEAN;

  FUNCTION val_terms_code
	(v_of_terms_code IN op_term_mst.of_terms_code%TYPE)  RETURN BOOLEAN;

  FUNCTION val_qc_grade_wanted
	(v_qc_grade_wanted IN qc_grad_mst.qc_grade%TYPE)  RETURN BOOLEAN;

  PROCEDURE get_gl_source
	(v_trans_source_type OUT gl_srce_mst.trans_source_type%TYPE);

  PROCEDURE get_base_currency
	(v_base_currency_code OUT gl_plcy_mst.base_currency_code%TYPE,
	 v_orgn_code IN sy_orgn_mst.orgn_code%TYPE);

  PROCEDURE get_exchange_rate
	(v_exchange_rate OUT gl_xchg_rte.exchange_rate%TYPE,
	 v_mul_div_sign OUT gl_xchg_rte.mul_div_sign%TYPE,
	 v_exchange_rate_date OUT gl_xchg_rte.exchange_rate_date%TYPE,
	 v_to_currency IN gl_xchg_rte.to_currency_code%TYPE,
	 v_from_currency IN gl_xchg_rte.from_currency_code%TYPE,
	 v_trans_source_type IN gl_srce_mst.trans_source_type%TYPE);


END GML_VALIDATE_PO;

 

/
