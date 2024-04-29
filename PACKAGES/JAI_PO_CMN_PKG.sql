--------------------------------------------------------
--  DDL for Package JAI_PO_CMN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_CMN_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_cmn.pls 120.4 2008/01/21 10:58:06 rchandan ship $ */

 /* PROCEDURE insert_accrual_reconcile
            (p_transaction_id number,
             p_po_line_location_id number,
             p_po_distribution_id number,
             p_shipment_line_id number,
             p_organization_id number,
             p_transaction_date date,
             p_transaction_amount number,
             p_accrual_account_id number
             );*/

  PROCEDURE insert_line
              ( v_code IN VARCHAR2,
	              v_line_loc_id IN NUMBER,
			          v_po_hdr_id IN NUMBER,
			    		  v_po_line_id IN NUMBER,
			    		  v_cre_dt IN DATE,
			    		  v_cre_by IN NUMBER,
			    		  v_last_upd_dt IN DATE,
			    		  v_last_upd_by IN NUMBER,
			    		  v_last_upd_login IN NUMBER,
					      flag IN VARCHAR2
            , v_service_type_code IN VARCHAR2 DEFAULT NULL);

  FUNCTION Ja_In_Po_Get_Func_Curr( p_po_header_id IN NUMBER ) RETURN VARCHAR2;  -- Used to get Functional Currency.

  FUNCTION Ja_In_Po_Assessable_Val_Conv( p_po_header_id IN NUMBER,
                                         p_assessable_val IN NUMBER,
					 p_func_curr IN VARCHAR2,
					 p_doc_curr IN VARCHAR2,
					 /* Bug 5096787. Added by Lakshmi Gopalsami */
					 p_rate IN NUMBER DEFAULT NULL,
					 p_rate_date IN DATE DEFAULT NULL,
					 p_rate_type IN VARCHAR2 DEFAULT NULL
					 )
          RETURN NUMBER;  -- Used to calculate the assessable value in the document currency.

  PROCEDURE Ja_In_Po_Func_Curr( p_po_header_id IN NUMBER,
                                p_assessable_val IN OUT NOCOPY NUMBER,
				p_doc_curr IN VARCHAR2,
				p_conv_rate IN OUT NOCOPY NUMBER,  -- Used to integrate the above functions to get assessable value in doc. currency
                                /* Bug 5096787. Added by Lakshmi Gopalsami */
				p_rate IN NUMBER DEFAULT NULL,
				p_rate_date IN DATE DEFAULT NULL,
				p_rate_type IN VARCHAR2 DEFAULT NULL
				);

  PROCEDURE locate_source_line
  (
    p_header_id IN NUMBER,
    p_line_num  IN NUMBER,
    p_line_quantity IN NUMBER,
    p_po_line_id OUT NOCOPY NUMBER,
    p_line_location_id OUT NOCOPY NUMBER,
    p_line_id NUMBER DEFAULT NULL
  );

  PROCEDURE process_release_shipment
  (
    v_shipment_type IN VARCHAR2,
    v_src_ship_id IN NUMBER,
    v_line_loc_id IN NUMBER,
    v_po_line_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_qty IN NUMBER,
    v_po_rel_id IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by IN NUMBER,
    v_last_upd_login IN NUMBER,
    flag IN VARCHAR2 DEFAULT NULL
    ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/11
  );

  PROCEDURE get_functional_curr
  ( v_ship_to_loc_id IN NUMBER, v_po_org_id IN NUMBER, v_inv_org_id IN NUMBER,
    v_doc_curr IN VARCHAR2, v_assessable_value IN OUT NOCOPY NUMBER,
    v_rate IN OUT NOCOPY NUMBER, v_rate_type IN VARCHAR2, v_rate_date IN DATE,
    v_func_currency IN OUT NOCOPY VARCHAR2
  );

END jai_po_cmn_pkg;

/
