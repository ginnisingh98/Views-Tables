--------------------------------------------------------
--  DDL for Package POA_EDW_SPEND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_SPEND_PKG" AUTHID CURRENT_USER AS
/* $Header: POASPNDS.pls 115.3 2003/02/19 20:57:30 mangupta ship $ */

  FUNCTION	CONTRACT_AMT_RELEASED(p_contract_id	IN NUMBER,
				          p_org_id	IN NUMBER,
                                          p_contract_type IN VARCHAR2)
				RETURN NUMBER;

  FUNCTION      LINE_AMT_RELEASED(p_contract_id IN NUMBER,
                                      p_org_id      IN NUMBER,
                                      p_line_id	    IN NUMBER)
                                RETURN NUMBER;

  FUNCTION      LINE_QTY_RELEASED(p_contract_id IN NUMBER,
                                      p_org_id      IN NUMBER,
                                      p_line_id     IN NUMBER)
                                RETURN NUMBER;

  FUNCTION	APPROVED_BY(p_po_header_id	IN NUMBER)
			        RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(APPROVED_BY, WNDS, WNPS, RNPS);

  FUNCTION      GET_ACCEPTANCE_DATE(p_doc_id      IN NUMBER,
                                    p_type        IN VARCHAR2)
                                RETURN DATE;

    PRAGMA RESTRICT_REFERENCES(GET_ACCEPTANCE_DATE, WNDS, WNPS, RNPS);

  FUNCTION      GET_REQ_APPROVAL_DATE(p_req_dist_id      IN NUMBER)
                                RETURN DATE;
    PRAGMA RESTRICT_REFERENCES(GET_REQ_APPROVAL_DATE, WNDS, WNPS, RNPS);

  FUNCTION      GET_SUPPLIER_APPROVED(p_po_dist_id      IN NUMBER)
                                RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(GET_SUPPLIER_APPROVED, WNDS, WNPS, RNPS);

 FUNCTION      GET_SUPPLIER_APPROVED(p_po_dist_id      IN NUMBER,
                                     p_vendor_id       IN NUMBER,
                                     p_vendor_site_id  IN NUMBER,
                                     p_ship_to_org_id  IN NUMBER,
                                     p_item_id         IN NUMBER,
                                     p_category_id     IN NUMBER
                                     )
                                RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(GET_SUPPLIER_APPROVED, WNDS, WNPS, RNPS);

 FUNCTION 	get_check_cut_date(p_po_dist_id		NUMBER)
							RETURN DATE;

    PRAGMA RESTRICT_REFERENCES(get_check_cut_date, WNDS, WNPS, RNPS);

 FUNCTION	get_invoice_received_date(p_po_dist_id    NUMBER)
							RETURN DATE;

    PRAGMA RESTRICT_REFERENCES(get_invoice_received_date, WNDS, WNPS, RNPS);

 FUNCTION	get_invoice_creation_date(p_po_dist_id	 NUMBER)
							RETURN DATE;

    PRAGMA RESTRICT_REFERENCES(get_invoice_creation_date, WNDS, WNPS, RNPS);

 FUNCTION	get_goods_received_date(p_po_line_loc_id	 NUMBER)
							RETURN DATE;

    PRAGMA RESTRICT_REFERENCES(get_goods_received_date, WNDS, WNPS, RNPS);

 FUNCTION 	get_ipv(p_po_dist_id	NUMBER)
							RETURN NUMBER;

    PRAGMA RESTRICT_REFERENCES(get_ipv, WNDS, WNPS, RNPS);

END POA_EDW_SPEND_PKG;

 

/
