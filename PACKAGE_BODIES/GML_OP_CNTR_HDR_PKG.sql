--------------------------------------------------------
--  DDL for Package Body GML_OP_CNTR_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OP_CNTR_HDR_PKG" AS
/* $Header: GMLOMCNB.pls 120.1 2006/09/15 19:33:33 plowe noship $ */

  --This will be called in op_cntr_dtl_details procedure to insert mtl_organization_id based on whse_code
  --for column pricing attribute value from

  FUNCTION get_organization(pwhse_code VARCHAR2) RETURN NUMBER IS
   begin
   null;
  END get_organization;

  --This procedure will get the uom_code from mtl_units_of_measure_vl.

  FUNCTION get_uom_code(pprice_uom VARCHAR2) RETURN VARCHAR2 IS
   begin
   null;
  END get_uom_code;

  --This procedure will validate the item_id in mtl_system_items table before inserting into the
  --column product attribute value
  -- PK Bug 4372804 Replaced IN clause with join and removed distinct

  FUNCTION get_item(pitem_id NUMBER) RETURN NUMBER IS
    begin
   null;
  END get_item;


  PROCEDURE op_cntr_hdr IS

    begin
   null;
  END op_cntr_hdr;


  PROCEDURE op_cntr_dtl(plist_header_id NUMBER, pcontract_id NUMBER,
  			pcurrency_code VARCHAR2,pcontract_no VARCHAR2,pcontract_desc VARCHAR2) IS
    begin
   null;
  END op_cntr_dtl;

  PROCEDURE op_prce_eff(plist_header_id NUMBER,pcontract_id NUMBER,pcontract_no VARCHAR2,
  			pdate_created DATE,pdate_modified DATE) IS
   begin
   null;
  END op_prce_eff;

  PROCEDURE op_cntr_dtl_details(pqc_grade VARCHAR2, pwhse_code VARCHAR2,
                                pfrtbill_mthd VARCHAR2, pattr_grp_no NUMBER, pitem_id  NUMBER,
                                pprice_uom VARCHAR2, plist_line_id NUMBER,
				plist_header_id NUMBER,
                                plist_line_type_code VARCHAR2) IS

  begin
   null;
  END op_cntr_dtl_details;

  PROCEDURE op_cntr_brk(plist_header_id NUMBER, pprice_id NUMBER,
  			pprice_type NUMBER,pbase_price NUMBER,
  			pitem_id NUMBER,pprice_uom VARCHAR2,
  			plist_line_id NUMBER) IS
    begin
   null;
  END op_cntr_brk;

  PROCEDURE op_cntr_brk_values (pprice_id NUMBER, pqty_breakpoint NUMBER,
  			        plist_line_id NUMBER,plist_header_id NUMBER, pitem_id NUMBER,
  			        pprice_uom VARCHAR2) IS
   begin
   null;
   END op_cntr_brk_values;

  PROCEDURE qp_rltd_modifiers(pblist_line_id NUMBER,plist_line_id  NUMBER) is
    begin
   null;
  END qp_rltd_modifiers;

  PROCEDURE op_oe_agreement(plist_header_id NUMBER,pcontract_no VARCHAR2,
  			    pdate_created DATE,pdate_modified DATE,
  			    pcust_no VARCHAR2,pstart_date DATE,
  			    pend_date DATE,psite_use_id NUMBER,ppreference NUMBER,porgn_code VARCHAR2) IS
    begin
   null;
  END op_oe_agreement;

  PROCEDURE op_chrg_mst (pbreak_type NUMBER,pprice_type NUMBER,
  			 pprice_id NUMBER,pbase_price NUMBER,
  			 pprice_uom VARCHAR2,pitem_id NUMBER,pcurrency_code VARCHAR2,
  			 pcontract_no VARCHAR2,pcontract_desc VARCHAR2, olist_header_id NUMBER) IS
    begin
   null;
  END op_chrg_mst;

  PROCEDURE op_chrg_dtl (plist_header_id NUMBER,pbreak_type NUMBER,pprice_type NUMBER,
  			 pprice_id NUMBER,pbase_price NUMBER,pprice_uom VARCHAR2,
  			 pitem_id NUMBER) IS
	  begin
   null;

  END op_chrg_dtl;

  PROCEDURE op_chrg_brk(plist_header_id NUMBER,pprice_type NUMBER,plist_line_id NUMBER,
  			pbreak_type NUMBER,pitem_id NUMBER,
  			pprice_id NUMBER,pbase_price NUMBER,pprice_uom VARCHAR2) IS
      begin
   null;
  END op_chrg_brk;

 PROCEDURE op_chrg_brk_values(pvalue_breakpoint NUMBER, plist_line_id NUMBER,
                               plist_header_id NUMBER, pitem_id NUMBER,pprice_id NUMBER,pprice_uom VARCHAR2) is
    begin
   null;
  END op_chrg_brk_values;

  PROCEDURE qp_chrg_rltd_modifiers (pblist_line_id NUMBER,plist_line_id NUMBER) IS
       begin
   null;
  END qp_chrg_rltd_modifiers;

  PROCEDURE handle_error_messages(psession_id NUMBER, ppackage_name VARCHAR2, pprocedure_name VARCHAR2, pmessage VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

     begin
   null;
  END handle_error_messages;

END gml_op_cntr_hdr_pkg;

/
