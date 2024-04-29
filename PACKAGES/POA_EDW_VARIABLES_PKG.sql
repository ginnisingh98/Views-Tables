--------------------------------------------------------
--  DDL for Package POA_EDW_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_VARIABLES_PKG" AUTHID CURRENT_USER AS
/* $Header: poavars.pls 115.7 2004/01/28 06:34:24 sdiwakar noship $ */

  FUNCTION get_check_cut_date (p_po_distribution_id IN NUMBER) RETURN DATE;
  PRAGMA RESTRICT_REFERENCES(get_check_cut_date, WNDS);

  FUNCTION get_goods_received_date  (p_po_line_location_id IN NUMBER) RETURN DATE;
  PRAGMA RESTRICT_REFERENCES (get_goods_received_date, WNDS);

  FUNCTION get_invoice_creation_date (p_po_distribution_id IN NUMBER) RETURN DATE;
  PRAGMA RESTRICT_REFERENCES (get_invoice_creation_date, WNDS);

  FUNCTION get_invoice_received_date (p_po_distribution_id IN NUMBER)	RETURN DATE;
  PRAGMA RESTRICT_REFERENCES (get_invoice_received_date, WNDS);

  FUNCTION get_req_approval_date (p_po_req_dist_id IN NUMBER) RETURN DATE;
  PRAGMA RESTRICT_REFERENCES (get_req_approval_date, WNDS);

  FUNCTION get_ipv (p_po_distribution_id IN NUMBER) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (get_ipv, WNDS);

  FUNCTION get_supplier_approved (p_po_distribution_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_supplier_approved, WNDS);

  FUNCTION get_supplier_approved (p_po_distribution_id IN NUMBER,
                                  p_vendor_id IN NUMBER,
                                  p_vendor_site_id IN NUMBER,
                                  p_ship_to_org_id IN NUMBER,
                                  p_item_id IN NUMBER,
                                  p_category_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_supplier_approved, WNDS);

  FUNCTION  APPROVED_BY (p_po_header_id  IN NUMBER)  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (APPROVED_BY, WNDS);

  FUNCTION get_acceptance_date (p_po_doc_id IN NUMBER, p_type IN VARCHAR2) RETURN DATE;
  PRAGMA RESTRICT_REFERENCES (get_acceptance_date, WNDS);

  FUNCTION get_global_currency_rate (p_rate_type      VARCHAR2,
                                     p_currency_code  VARCHAR2,
                                     p_rate_date      DATE,
                                     p_rate           NUMBER)  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (get_global_currency_rate, WNDS);

  FUNCTION get_uom_conv_rate (p_uom_code    VARCHAR2,
                              p_item_id     NUMBER)  RETURN NUMBER;

  PROCEDURE init;

END POA_EDW_VARIABLES_PKG;

 

/
