--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV8" AUTHID CURRENT_USER AS
/* $Header: POXPOS8S.pls 120.1 2005/07/03 02:20:56 manram noship $*/
/*===========================================================================
  FUNCTION NAME:	val_start_dates()

  DESCRIPTION:		This function verifies that the start date that is
			entered on the header is less than the earliest
			shipment effective date on the document.

  PARAMETERS:		X_start_date		IN	DATE
			X_po_header_id		IN	NUMBER

  RETURN VALUE:		BOOLEAN

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/

  FUNCTION val_start_dates
		(X_start_date		IN	DATE,
		 X_po_header_id		IN	NUMBER) RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	val_end_dates()

  DESCRIPTION:		This function verifies that the end date that is
			entered on the header is greater than the latest
			shipment expiration date on the document.

  PARAMETERS:		X_end_date		IN	DATE
			X_po_header_id		IN	NUMBER

  RETURN VALUE:		BOOLEAN

  DESIGN REFERENCES:	../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		08-MAY-95	MSNYDER
===========================================================================*/

  FUNCTION val_end_dates
		(X_end_date		IN	DATE,
		 X_po_header_id		IN	NUMBER) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	autocreate_ship()

  DESCRIPTION:		This procedure autocreates ONE shipment
                        and attempts to autocreate ONE distribution.

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		07-28-95        SIYER
			bug 451195      07-28-97	ssomasek added the X_ussgl_transaction_code

                        Modified        26-FEB-01       MCHANDAK(OPM-GML)
                        Bug# 1548597.. Added 3 process related fields.
                        X_secondary_unit_of_measure,X_secondary_quantity and
                        X_preferred_grade.
===========================================================================*/

 procedure autocreate_ship ( X_line_location_id        IN OUT NOCOPY NUMBER,
                             X_last_update_date               DATE,
                             X_last_updated_by                NUMBER,
                             X_creation_date                  DATE,
                             X_created_by                     NUMBER,
                             X_last_update_login              NUMBER,
                             X_po_header_id                   NUMBER,
                             X_po_line_id                     NUMBER,
                             X_type_lookup_code               VARCHAR2,
                             X_quantity                       NUMBER,
                             X_ship_to_location_id            NUMBER,
                             X_ship_org_id                    NUMBER,
                             X_need_by_date                   DATE,
                             X_promised_date                  DATE,
                             X_unit_price                     NUMBER,
                             X_tax_code_id                    NUMBER,
                             X_taxable_flag                   VARCHAR2,
                             X_enforce_ship_to_location       VARCHAR2,
                             X_receiving_routing_id           NUMBER,
                             X_inspection_required_flag       VARCHAR2,
                             X_receipt_required_flag          VARCHAR2,
                             X_qty_rcv_tolerance              NUMBER,
                             X_qty_rcv_exception_code         VARCHAR2,
                             X_days_early_receipt_allowed     NUMBER,
                             X_days_late_receipt_allowed      NUMBER,
                             X_allow_substitute_receipts      VARCHAR2,
                             X_receipt_days_exception_code    VARCHAR2,
                             X_invoice_close_tolerance        NUMBER,
                             X_receive_close_tolerance        NUMBER,
                             X_item_status                    VARCHAR2,
                             X_outside_operation_flag         VARCHAR2,
                             X_destination_type_code          VARCHAR2,
                             X_expense_accrual_code           VARCHAR2,
                             X_item_id                        NUMBER,
						    X_ussgl_transaction_code		  VARCHAR2,
                             X_accrue_on_receipt_flag  IN OUT NOCOPY VARCHAR2,
                             X_autocreated_ship        IN OUT NOCOPY BOOLEAN,
                             X_unit_meas_lookup_code   IN     VARCHAR2, -- Added Bug 731564
                             p_value_basis             IN     VARCHAR2, -- <Complex Work R12>
                             p_matching_basis          IN     VARCHAR2, -- <Complex Work R12>
-- start of bug# 1548597
                             X_secondary_unit_of_measure  IN  VARCHAR2 default  null,
                             X_secondary_quantity     IN  NUMBER default null,
                             X_preferred_grade        IN  VARCHAR2 default null,
                             p_consigned_from_supplier_flag IN VARCHAR2 default null --bug 3523348
-- end of bug# 1548597
                            ,p_org_id                     IN     NUMBER default null  -- <R12.MOAC>
			    ,p_outsourced_assembly	IN NUMBER -- <R12 SHIKYU>
);
/*===========================================================================
  PROCEDURE NAME:	get_matching_controls

  DESCRIPTION:		Get receipt required and inspection required fields.

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		10-28-95	kpowell
===========================================================================*/
PROCEDURE get_matching_controls(
			       X_vendor_id    IN number,
			       X_line_type_id IN number,
			       X_item_id    IN number,
			       X_receipt_required_flag IN OUT NOCOPY VARCHAR2,
			       X_inspection_required_flag IN OUT NOCOPY VARCHAR2);



/* <TIMEPHASED FPI START> */
/*===========================================================================
  PROCEDURE NAME:       validate_effective_dates

  DESCRIPTION:

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:    Family Pack 'I': Time Phased Pricing DLD

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         09-16-2002        davidng
===========================================================================*/
PROCEDURE validate_effective_dates(p_start_date      IN         date,        /* Header Start Date */
                                   p_end_date        IN         date,        /* Header End Date */
                                   p_from_date       IN         date,        /* Price Break Start Date */
                                   p_to_date         IN         date,        /* Price Break End Date */
                                   p_expiration_date IN         date,        /* Line Expiration Date */
                                   x_errormsg        OUT NOCOPY varchar2);   /* Error Message Name */



/*===========================================================================
  PROCEDURE NAME:       validate_pricebreak_attributes

  DESCRIPTION:

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:    Family Pack 'I': Time Phased Pricing DLD

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Created         09-16-2002        davidng
===========================================================================*/
PROCEDURE validate_pricebreak_attributes(p_from_date        IN         date,        /* Price Break Start Date */
                                         p_to_date          IN         date,        /* Price Break End Date */
                                         p_quantity         IN         varchar2,    /* Price Break Quantity */
                                         p_ship_to_org      IN         varchar2,    /* Price Break Ship To Organization Code */
                                         p_ship_to_location IN         varchar2,    /* Price Break Ship to Location Code */
                                         x_errormsg_name    OUT NOCOPY varchar2);   /* Error Message Name */

/* <TIMEPHASED FPI END> */



END PO_SHIPMENTS_SV8;

 

/
