--------------------------------------------------------
--  DDL for Package PO_VENDORS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORS_SV" AUTHID CURRENT_USER as
/* $Header: POXVDVES.pls 120.1 2005/06/24 01:52:25 vsanjay noship $*/

/*===========================================================================
  FUNCTION NAME:	val_vendor()

  DESCRIPTION:		This function checks whether a given Supplier is
			still active.


  PARAMETERS:		X_vendor_id IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Changed to	14-AUG-1995	LBROADBE
			Function
===========================================================================*/
FUNCTION val_vendor(X_vendor_id IN NUMBER) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_vendor_defaults()


  DESCRIPTION:    Get the Vendor attributes for a given vendor_id.
                  If there is a default Vendor Site for this Vendor,
                     get the vendor_site info.

                  If there is no default vendor site, do not bother to validate
                  the vendor attributes right now.They will probably be overwritten by
                  the Vendor Site info.

                  If there exists a default Vendor Site info,

                  ( The validation logic first checks if the value stored at the
                  vendor site level is valid; Only if teh vendor site info is not
                  valid, should we use the value stored at the vendor level)

                  Validate the invoice currency_code,
                               fob lookupcode,
                               freight_terms lookup code,
                               ship_via_lookup code,
                               terms_id.
                  Get the validated code's displayed value.
                  Validate the Ship-To Location and get its attributes
                  Validate the Bill-to location and get its attributes.



  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer      04/95		Created.
		  Melissa Snyder  11/14/95	Added X_document_type
						parameter.

===============================================================================*/

 procedure get_vendor_defaults ( X_vendor_id IN NUMBER,
                                  X_org_id IN number,
                                  X_set_of_books_id IN number,
                                  X_res_fob IN OUT NOCOPY varchar2 ,
                                  X_res_ship_via IN OUT NOCOPY varchar2 ,
                                  X_res_freight_terms IN OUT NOCOPY varchar2 ,
                                  X_res_terms_id  IN OUT NOCOPY number ,
                                  X_vendor_site_id IN OUT NOCOPY number ,
                                  X_vendor_site_code IN OUT NOCOPY VARCHAR2,
                                  X_fob_dsp IN OUT NOCOPY varchar2,
                                  X_ship_via_dsp IN OUT NOCOPY varchar2,
                                  X_freight_terms_dsp IN OUT NOCOPY varchar2,
                                  X_terms_dsp  IN OUT NOCOPY varchar2,
                                  X_res_ship_to_loc_id  IN OUT NOCOPY number,
                                  X_ship_to_loc_dsp IN OUT NOCOPY varchar2,
                                  X_ship_org_code IN OUT NOCOPY varchar2,
                                  X_ship_org_name IN OUT NOCOPY varchar2,
                                  X_ship_org_id  IN OUT NOCOPY number,
                                  X_res_bill_to_loc_id IN OUT NOCOPY number,
                                  X_bill_to_loc_dsp IN OUT NOCOPY varchar2 ,
                                  X_res_invoice_currency_code IN OUT NOCOPY varchar2,
                                  X_type_1099 IN OUT NOCOPY varchar2,
                                  X_receipt_required_flag IN OUT NOCOPY varchar2,
                                  X_vendor_contact_id IN OUT NOCOPY number,
                                  X_vendor_contact_name IN OUT NOCOPY varchar2,
                                  X_inspection_required_flag IN OUT NOCOPY varchar2,
				  X_document_type IN varchar2);

/*===========================================================================
 PROCEDURE NAME:	get_vendor_info()

  DESCRIPTION:  Given a vendor id, this procedure returns the
                relevant attributes of that vendor.


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/

 procedure get_vendor_info(X_vendor_id IN number,
                           X_ship_to_location_id IN OUT NOCOPY number,
                           X_bill_to_location_id IN OUT NOCOPY number,
                           X_ship_via_lookup_code IN OUT NOCOPY varchar2,
                           X_fob_lookup_code IN OUT NOCOPY varchar2,
                           X_freight_terms_lookup_code IN OUT NOCOPY varchar2,
                           X_terms_id IN OUT NOCOPY number,
                           X_type_1099  IN OUT NOCOPY varchar2,
                           X_hold_flag IN OUT NOCOPY  varchar2,
                           X_invoice_currency_code IN OUT NOCOPY varchar2,
                           X_receipt_required_flag IN OUT NOCOPY varchar2,
                           X_num_1099 IN OUT NOCOPY varchar2,
                           X_vat_registration_num  IN OUT NOCOPY varchar2,
                           X_inspection_required_flag IN OUT NOCOPY varchar2 );


/*===========================================================================
 PROCEDURE NAME:	val_fob()

  DESCRIPTION:     This procedure decides if the given fob lookup code
                   is valid (ie., if it is still an active lookupcode)


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/
 procedure val_fob( X_temp_fob_lookup_code IN varchar2,
                    X_res_fob IN OUT NOCOPY varchar2 );

/*===========================================================================
 PROCEDURE NAME:	val_freight_terms()

  DESCRIPTION:     This procedure decides if the given freight terms lookup code
                   is valid (ie., if it is still an active lookupcode)


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/
 procedure val_freight_terms( X_temp_freight_terms IN varchar2,
                              X_res_freight_terms IN OUT NOCOPY varchar2) ;

/*===========================================================================
 PROCEDURE NAME:	val_freight_carrier()

  DESCRIPTION:     This procedure decides if the given freight carrier
                   is valid (ie., if it is still an active lookupcode)


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/
 procedure val_freight_carrier(X_temp_ship_via IN varchar2,
                               X_org_id IN number,
                               X_res_ship_via IN OUT NOCOPY varchar2);

PROCEDURE get_terms_conditions                                    -- <GA FPI>
(   p_po_header_id              IN         PO_HEADERS_ALL.po_header_id%TYPE
,   x_terms_id                  OUT NOCOPY PO_HEADERS_ALL.terms_id%TYPE
,   x_ship_via_lookup_code      OUT NOCOPY PO_HEADERS_ALL.ship_via_lookup_code%TYPE
,   x_fob_lookup_code           OUT NOCOPY PO_HEADERS_ALL.fob_lookup_code%TYPE
,   x_freight_terms_lookup_code OUT NOCOPY PO_HEADERS_ALL.freight_terms_lookup_code%TYPE
,   x_shipping_control          OUT NOCOPY PO_HEADERS_ALL.shipping_control%TYPE    -- <INBOUND LOGISTICS FPJ>
);

/* INBOUND LOGISTICS FPJ START */
/**
* Private Procedure: val_shipping_control
* Requires: None
* Modifies: None
* Effects: Decides if the given shipping control is valid, i.e. if it's still
*   an active lookup code
*   IF p_temp_shipping_control is valide
*       RETURN p_temp_shipping_control
*   ELSE
*       RETURN NULL
* Returns: x_res_shipping_control
*/

PROCEDURE val_shipping_control
(
    p_temp_shipping_control    IN               VARCHAR2,
    x_res_shipping_control     IN OUT NOCOPY    VARCHAR2
);
/* INBOUND LOGISTICS FPJ END */

/*===========================================================================
 PROCEDURE NAME:	get_displayed_values()

  DESCRIPTION:     This procedure gets the displayed values for the
                   following lookup codes: FOB,
                                           Freight Terms,
                                           Ship Via ( Freight Carrier),
                                           Payment Terms.
                   It calls the PO_CORE_S package to get the FOB and Freight
                   Terms display.



  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/

 procedure get_displayed_values (X_res_fob IN varchar2, X_res_freight_terms IN varchar2,
                                 X_res_ship_via IN varchar2, X_res_terms_id IN number,
                                 X_fob_dsp IN OUT NOCOPY varchar2, X_freight_terms_dsp IN OUT NOCOPY varchar2,
                                 X_ship_via_dsp IN OUT NOCOPY varchar2, X_terms_dsp IN OUT NOCOPY varchar2,
                                 X_org_id IN number);

FUNCTION get_terms_dsp                                           -- <GA FPI>
(   p_terms_id           IN      AP_TERMS.term_id%TYPE
) RETURN AP_TERMS.name%TYPE;


/*===========================================================================
 PROCEDURE NAME:	get_ship_to_loc_attributes()

  DESCRIPTION:     This procedure gets the ship to Location
                   attributes for a given location id.


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/

 procedure get_ship_to_loc_attributes ( X_temp_ship_to_loc_id IN number, X_ship_to_loc_dsp IN OUT NOCOPY varchar2,
                                        X_ship_org_code IN OUT NOCOPY varchar2, X_ship_org_name IN OUT NOCOPY varchar2,
                                        X_ship_org_id IN OUT NOCOPY  number, X_set_of_books_id IN number);

/*===========================================================================
 PROCEDURE NAME:	get_bill_to_loc_attributes()

  DESCRIPTION:     This procedure gets the Bill to Location
                   attributes for a given location id.


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         04/95

===============================================================================*/

 procedure get_bill_to_loc_attributes (X_temp_bill_to_loc_id IN number, X_bill_to_loc_dsp IN OUT NOCOPY varchar2);


/*===========================================================================
  PROCEDURE NAME : get_vendor_name()

  DESCRIPTION    :  For a given Vendor Id, this procedures gets the Vendor Name.

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXPOREL.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

========================================================================*/
 PROCEDURE get_vendor_name
		      (X_vendor_id IN NUMBER,
		       X_vendor_name IN OUT NOCOPY VARCHAR2);

   PROCEDURE test_get_vendor (X_vendor_id IN NUMBER);


/*===========================================================================
  Bug #508009
  FUNCTION NAME : get_vendor_name_func()

  DESCRIPTION    :  For a given Vendor Id, this returns  the Vendor Name.

  PARAMETERS:   NUMBER - Vendor ID

  RETURN VALUE: VARCHAR2 - Vendor Name

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

========================================================================*/

    FUNCTION get_vendor_name_func(X_vendor_id  IN NUMBER) RETURN VARCHAR2;

--    PRAGMA RESTRICT_REFERENCES(get_vendor_name_func, WNDS);



/*===========================================================================
  PROCEDURE NAME : get_vendor_details

  DESCRIPTION    : Obtain the  vendor name, vendor site, vendor contact
		   and vendor phone using the vendor id , vendor site id
		   and vendor contact id.

  PARAMETERS:	   x_vendor_id		IN  NUMBER
		   x_vendor_site_id	IN  NUMBER
		   x_vendor_contact_id	IN  NUMBER
		   x_vendor_name	OUT VARCHAR2
		   x_vendor_location    OUT VARCHAR2
		   x_vendor_contact	OUT VARCHAR2
		   x_vendor_phone	OUT VARCHAR2


  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created 	10/21		Ramana Mulpury

========================================================================*/
 PROCEDURE get_vendor_details (x_vendor_id      	IN     NUMBER,
		               x_vendor_site_id 	IN     NUMBER,
			       x_vendor_contact_id	IN     NUMBER,
			       x_vendor_name		IN OUT NOCOPY VARCHAR2,
			       x_vendor_location	IN OUT NOCOPY VARCHAR2,
			       x_vendor_contact		IN OUT NOCOPY VARCHAR2,
			       x_vendor_phone		IN OUT NOCOPY VARCHAR2);



/*===========================================================================
  PROCEDURE NAME : derive_vendor_info

  DESCRIPTION    : Accepts as input vendor record that has vendor_name, vendor_id
                   and vendor_num. Derives values for the columns that are null.
                   Needs atleast one column to have a value in the input.

  PARAMETERS:	   p_vendor_record  in out rcv_shipment_header_sv.VendorRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:           Uses dbms_sql to create query where condition based on the input
                   columns that have values.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created 	10/24		Raj Bhakta

========================================================================*/

 PROCEDURE derive_vendor_info (p_vendor_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.VendorRecType);


/*===========================================================================
  PROCEDURE NAME : validate_vendor_info

  DESCRIPTION    : Accepts as input vendor record that has vendor_id, vendor_name and
                   vendor_num as components. Based on the components that have values
                   validates for a no of conditions.

  PARAMETERS:	   p_vendor_record  in out rcv_shipment_header_sv.VendorRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:           Uses dbms_sql to create query WHERE condition based on the input
                   columns that have values.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created 	10/24		Raj Bhakta

========================================================================*/

 PROCEDURE validate_vendor_info (p_vendor_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.VendorRecType);

END PO_VENDORS_SV;

 

/
