--------------------------------------------------------
--  DDL for Package PO_LINES_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV4" AUTHID CURRENT_USER as
/* $Header: POXPOL4S.pls 120.0.12010000.2 2011/05/03 23:09:05 ajunnikr ship $ */

FUNCTION get_line_num                      -- <GA FPI>
(   p_po_line_id          PO_LINES_ALL.po_line_id%TYPE
) RETURN PO_LINES_ALL.line_num%TYPE;

FUNCTION is_cumulative_pricing             -- <GA FPI>
(   p_po_line_id          PO_LINES_ALL.po_line_id%TYPE
) RETURN BOOLEAN;

FUNCTION effective_dates_exist             -- <GA FPI>
(   p_po_line_id          PO_LINES_ALL.po_line_id%TYPE
) RETURN BOOLEAN;

FUNCTION allow_price_override              -- <2716528>
(   p_po_line_id          PO_LINES_ALL.po_line_id%TYPE
) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_ship_dist_num()

  DESCRIPTION:		This procedure gets the no. of shipments and distributions
                        associated with a line. In addition it also gets the
                        promised date, need-by date and the charge account that
                        have been rolled up from these entities to the line.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	08/08/95     SIYER
===========================================================================*/
 procedure get_ship_dist_num(X_po_line_id          IN NUMBER,
                              X_num_of_ship         IN OUT NOCOPY NUMBER,
                              --< NBD TZ/Timestamp FPJ Start >
                              --X_promised_date       IN OUT NOCOPY VARCHAR2,
                              --X_need_by             IN OUT NOCOPY VARCHAR2,
                              X_promised_date       IN OUT NOCOPY DATE,
                              X_need_by             IN OUT NOCOPY DATE,
                              --< NBD TZ/Timestamp FPJ End >
                              X_num_of_dist         IN OUT NOCOPY NUMBER,
                              X_code_combination_id IN OUT NOCOPY NUMBER);


/*===========================================================================
  FUNCTION  NAME:	get_encumbered_quantity

  DESCRIPTION:		Gets the total encumbered quantity for a Standard
			or Planned purchase order line.

  PARAMETERS:		X_po_line_id           IN     NUMBER,
		        X_encumbered_quantity  RETURN NUMBER

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU		11/1	Created

===========================================================================*/

  FUNCTION get_encumbered_quantity (X_po_line_id           IN     NUMBER)
		   		    RETURN NUMBER;


/*===========================================================================
  FUNCTION  NAME:	get_receipt_required_flag

  DESCRIPTION:		Gets the receipt_required_flag for a  purchase order line.


  PARAMETERS:		X_line_type_id           IN     NUMBER,
		        X_item_id                IN     NUMBER,
                        X_inventory_ord_id       IN     NUMBER,

                        X_receipt_required_flag  RETURN VARCHAR2

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU		11/1	Created

===========================================================================*/

  FUNCTION get_receipt_required_flag (X_line_type_id           IN     NUMBER,
                                      X_item_id                IN     NUMBER,
				      X_inventory_org_id       IN     NUMBER)
		   		      RETURN VARCHAR2;


/*===========================================================================
  PROCEDURE NAME:	get_ship_dist_info()

  DESCRIPTION:		This procedure gets the total of shipments quantity_received
                        and quantity_billed for a Standard/Planned PO line.
                        In addition it also gets the encumbered_flag from shipments,
                        online_req_flag, prevent_price_update_flag from distributions.


  PARAMETERS:		X_po_line_id         		 IN NUMBER,
                        X_quantity_received  		 IN OUT NUMBER,
                        X_quantity_billed    		 IN OUT NUMBER,
                        X_encumbered_flag    		 IN OUT VARCHAR2,
			X_prevent_price_update_flag   	 IN OUT VARCHAR2,
                        X_online_req_flag                IN OUT VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU	 	11/01/95	Created
                        SIYER           02/15/96        Added more params
===========================================================================*/
 procedure get_ship_quantity_info(X_po_line_id          	IN NUMBER,
                                  X_expense_accrual_code        IN VARCHAR2,
                                  X_po_header_id                IN NUMBER,
                                  X_type_lookup_code            IN VARCHAR2,
                            	  X_quantity_received   	IN OUT NOCOPY NUMBER,
                              	  X_quantity_billed     	IN OUT NOCOPY NUMBER,
                                  X_encumbered_flag     	IN OUT NOCOPY VARCHAR2,
                                  X_prevent_price_update_flag 	IN OUT NOCOPY VARCHAR2,
				  X_online_req_flag 		IN OUT NOCOPY VARCHAR2,
                                  X_quantity_released           IN OUT NOCOPY NUMBER,
                                  X_amount_released             IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:	get_quotation_info()

  DESCRIPTION:		This procedure gets the quotation details information
                        that are related to a purchase order line.

  PARAMETERS:		X_from_header_id      IN NUMBER,
                        X_from_line_id 	      IN NUMBER,
                        X_quotation_number    IN OUT VARCHAR2,
             		X_quotation_line      IN OUT NUMBER,
			X_quotation_type      IN OUT VARCHAR2,
                        X_vendor_quotation_number IN OUT VARCHAR2.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU	 	11/01/95	Created
                        SIYER           3/29/96         Removed the from_type_lookup_code
                                                        parameter.
===========================================================================*/
 procedure get_quotation_info	 (X_from_header_id      	IN NUMBER,
				  X_from_line_id        	IN NUMBER,
                            	  X_quotation_number    	IN OUT NOCOPY VARCHAR2,
             			  X_quotation_line		IN OUT NOCOPY NUMBER,
				  X_quotation_type	     	IN OUT NOCOPY VARCHAR2,
                              	  X_vendor_quotation_number    	IN OUT NOCOPY VARCHAR2,
                                  x_quote_terms_id              IN OUT NOCOPY NUMBER,
                                  x_quote_ship_via_lookup_code  IN OUT NOCOPY VARCHAR2,
                                  x_quote_fob_lookup_code       IN OUT NOCOPY VARCHAR2,
                                  x_quote_freight_terms         IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	get_lookup_code_dsp ()

  DESCRIPTION:		This procedure gets the po lookup codes displayed value.

  PARAMETERS:		X_lookup_type         IN VARCHAR2,
                        X_lookup_code 	      IN VARCHAR2,
                        X_displayed_field     IN OUT VARCHAR2


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU	 	11/06/95	Created
===========================================================================*/
 procedure get_lookup_code_dsp	 (X_lookup_type        	        IN VARCHAR2,
				  X_lookup_code 	        IN VARCHAR2,
                            	  X_displayed_field             IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	online_req ()

  DESCRIPTION:

  PARAMETERS:		X_po_line_id


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	CMOK	 	04/1/96		Created
===========================================================================*/

  FUNCTION online_req(x_po_line_id    IN  NUMBER) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_item_id ()

  DESCRIPTION:

  PARAMETERS:		X_item_id_record


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	 	12/6/96		Created
===========================================================================*/
 -- moved this to RCVTISVS.pls

  /* PROCEDURE get_item_id(x_item_id_record    IN OUT  rcv_shipment_line_sv.item_id_record_type); */

/*===========================================================================
  PROCEDURE NAME:	get_sub_item_id ()

  DESCRIPTION:

  PARAMETERS:		X_sub_item_id_record


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	 	12/6/96		Created
===========================================================================*/

  -- moved this to RCVTISVS.pls

  /* PROCEDURE get_sub_item_id(x_sub_item_id_record    IN OUT  rcv_shipment_line_sv.sub_item_id_record_type); */

/*===========================================================================
  PROCEDURE NAME:	get_po_line_id ()

  DESCRIPTION:

  PARAMETERS:		X_po_line_id_record


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	 	12/6/96		Created
===========================================================================*/

  -- Moved this to RCVTISVS.pls

  /* PROCEDURE get_po_line_id(x_po_line_id_record    IN OUT  rcv_shipment_line_sv.po_line_id_record_type); */

/*===========================================================================
  PROCEDURE NAME:	get_oke_contract_header_info ()

  DESCRIPTION:		This procedure gets the oke_header_num to display in the form.

  PARAMETERS:	X_oke_contract_header_id	IN 		NUMBER
	     	X_oke_contract_num		IN OUT		VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:  Called by po_lines_sv5.post_query(); file POXPOL5B.pls

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	togeorge	 	10/03/2000	Created
===========================================================================*/
  PROCEDURE get_oke_contract_header_info(
		X_oke_contract_header_id	IN 		NUMBER,
	     	X_oke_contract_num		IN OUT	NOCOPY 	VARCHAR2
		);

 --Bug# 1625462
 --togeorge 01/30/2001
 --Now displaying translated values for uom.
 procedure get_unit_meas_lookup_code_tl(
		X_unit_meas_lookup_code		IN 		VARCHAR2,
	     	X_unit_meas_lookup_code_tl	IN OUT	NOCOPY 	VARCHAR2
		);

 --Bug# 1751180
 --togeorge 04/27/2001
 --This procedure would select the translated uom using uom_code since om stores uom_code unlike units_of_measure as po.
 procedure get_om_uom_tl(
		X_uom_code			IN 		VARCHAR2,
	     	X_unit_meas_lookup_code_tl	IN OUT	NOCOPY 	VARCHAR2
		);

		/*
 	 Bug 12414858: Introduced the below function to fetch inventory_org_id.
 	  This function will be called in the query of the view po_lines_v.
 	  This is done for performance gains.
 	 */
 	 FUNCTION get_inventory_orgid
 	 (   p_org_id          NUMBER
 	 ) RETURN NUMBER;

END PO_LINES_SV4;

/
