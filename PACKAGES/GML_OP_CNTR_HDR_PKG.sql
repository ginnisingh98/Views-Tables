--------------------------------------------------------
--  DDL for Package GML_OP_CNTR_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_OP_CNTR_HDR_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLOMCNS.pls 120.1 2006/09/15 19:33:10 plowe noship $ */


  FUNCTION get_organization(pwhse_code VARCHAR2) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(get_organization,WNDS);

  FUNCTION get_uom_code(pprice_uom VARCHAR2) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_uom_code,WNDS);

  FUNCTION get_item(pitem_id NUMBER) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(get_item,WNDS);


  --To insert the records from op_cntr_hdr table.
  PROCEDURE op_cntr_hdr;

  --To insert the contract detail records from op_cntr_dtl table for the op_cntr_hdr(contract_id).
  PROCEDURE op_cntr_dtl(plist_header_id NUMBER, pcontract_id NUMBER,
                        pcurrency_code VARCHAR2,pcontract_no VARCHAR2,pcontract_desc VARCHAR2);

  --To insert the effectivity detail records from op_prce_eff table for the op_cntr_hdr(contract_id).
  PROCEDURE op_prce_eff(plist_header_id NUMBER,pcontract_id NUMBER,pcontract_no VARCHAR2,
                        pdate_created DATE,pdate_modified DATE);
  --To insert the contract detail records(whse_code,frtbill_mthd,qc_grade)
  --from op_cntr_dtl table for the op_cntr_hdr.
  PROCEDURE op_cntr_dtl_details(pqc_grade VARCHAR2,pwhse_code VARCHAR2,pfrtbill_mthd VARCHAR2, pattr_grp_no NUMBER,
                                pitem_id NUMBER,pprice_uom VARCHAR2,plist_line_Id NUMBER, plist_header_id NUMBER,
                                plist_line_type_code VARCHAR2);
  --To insert the contract break records from op_cntr_brk table for the op_cntr_dtl(price_id).
  PROCEDURE op_cntr_brk(plist_header_id NUMBER, pprice_id NUMBER,pprice_type NUMBER,
                        pbase_price NUMBER,pitem_id NUMBER,pprice_uom VARCHAR2,plist_line_id NUMBER);
  --To insert the contract break values from op_cntr_brk table.
  PROCEDURE op_cntr_brk_values(pprice_id NUMBER,pqty_breakpoint NUMBER,plist_line_id NUMBER,plist_header_id NUMBER,
                               pitem_id NUMBER,pprice_uom VARCHAR2);
  --To get the contract break records from qp_list_lines_v.
  PROCEDURE qp_rltd_modifiers(pblist_line_id NUMBER,plist_line_id  NUMBER);
  --To create agreements for the effectivities in op_prce_eff.
  PROCEDURE op_oe_agreement(plist_header_id NUMBER,pcontract_no VARCHAR2,pdate_created DATE,
                            pdate_modified DATE,pcust_no VARCHAR2,pstart_date DATE,
                            pend_date DATE,psite_use_id NUMBER,ppreference NUMBER,porgn_code VARCHAR2);
  PROCEDURE op_chrg_mst(pbreak_type NUMBER,pprice_type NUMBER,
                        pprice_id NUMBER,pbase_price NUMBER,
                        pprice_uom VARCHAR2,pitem_id NUMBER,pcurrency_code VARCHAR2,
                        pcontract_no VARCHAR2,pcontract_desc VARCHAR2, olist_header_id NUMBER);
  PROCEDURE op_chrg_dtl(plist_header_id NUMBER,pbreak_type NUMBER,pprice_type NUMBER,
                        pprice_id NUMBER,pbase_price NUMBER,pprice_uom VARCHAR2, pitem_id NUMBER);
  PROCEDURE op_chrg_brk(plist_header_id NUMBER,pprice_type NUMBER,plist_line_id NUMBER,
                        pbreak_type NUMBER,pitem_id NUMBER,	pprice_id NUMBER,pbase_price NUMBER,pprice_uom VARCHAR2);
  PROCEDURE op_chrg_brk_values(pvalue_breakpoint NUMBER, plist_line_id NUMBER,
                               plist_header_id NUMBER, pitem_id NUMBER,pprice_id NUMBER,pprice_uom VARCHAR2);
  PROCEDURE qp_chrg_rltd_modifiers(pblist_line_id NUMBER,plist_line_id NUMBER);
  PROCEDURE handle_error_messages(psession_id NUMBER, ppackage_name VARCHAR2,
                                  pprocedure_name VARCHAR2, pmessage VARCHAR2);
END gml_op_cntr_hdr_pkg;

 

/
