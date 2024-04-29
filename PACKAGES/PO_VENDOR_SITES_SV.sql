--------------------------------------------------------
--  DDL for Package PO_VENDOR_SITES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDOR_SITES_SV" AUTHID CURRENT_USER AS
/* $Header: POXVDVSS.pls 120.1 2006/08/14 17:58:12 tpoon noship $*/


FUNCTION get_vendor_site_id                                          -- <GA FPI>
(    p_po_header_id        IN   PO_HEADERS_ALL.po_header_id%TYPE
) RETURN PO_HEADERS_ALL.vendor_site_id%TYPE;

/*===========================================================================
  FUNCTION NAME:	val_vendor_site_id()

  DESCRIPTION:		This function checks whether a given Supplier Site
			is still active.  For Purchase Orders, it also
			confirms that the Site is not specified as
			"RFQ Only."


  PARAMETERS:		X_document_type    IN 	  VARCHAR2,
		        X_vendor_site_id   IN 	  NUMBER

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
FUNCTION val_vendor_site_id
(
    p_document_type  IN VARCHAR2,
    p_vendor_site_id IN NUMBER,
    p_org_id         IN NUMBER DEFAULT NULL   --< Shared Proc FPJ >
)
return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_def_vendor_site()

  DESCRIPTION: If for a given vendor there is only one site,
               bring that vendor site as the default vendor site.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer 	  04/95		Created
		  Melissa Snyder  11/14/95	Added X_document_type
						parameter.
===========================================================================*/


PROCEDURE  get_def_vendor_site(X_vendor_id IN number,
                               X_vendor_site_id OUT NOCOPY number,
                               X_vendor_site_code OUT NOCOPY varchar2,
			       X_document_type IN varchar2);

/*===========================================================================
  PROCEDURE NAME:	get_vendor_site_info()

  DESCRIPTION:  For a given vendor site,this procedure gets the other
                    attributes of that vendor site.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_vendor_site_info(X_vendor_site_id IN number,
                               X_vs_ship_to_location_id IN OUT NOCOPY number,
                               X_vs_bill_to_location_id IN OUT NOCOPY number,
                               X_vs_ship_via_lookup_code IN OUT NOCOPY varchar2,
                               X_vs_fob_lookup_code IN OUT NOCOPY varchar2,
                               X_vs_pay_on_code IN OUT NOCOPY varchar2,
                               X_vs_freight_terms_lookup_code IN OUT NOCOPY varchar2,
                               X_vs_terms_id IN OUT NOCOPY number,
                               X_vs_invoice_currency_code IN OUT NOCOPY varchar2,
                               x_vs_shipping_control IN OUT NOCOPY VARCHAR2    -- <INBOUND LOGISTICS FPJ>
                               );

/*===========================================================================
  PROCEDURE NAME:	val_vendor_site()

  DESCRIPTION:
	 o DEF - If there is only one purchasing site for this vendor, default the vendor site.
		 only those vendor sites are valid for input that are purchasing
		 sites and are not rfq only sites.
  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
 PROCEDURE val_vendor_site (X_vendor_id IN number,
                            X_vendor_site_id IN number,
                            X_org_id IN number,
                            X_set_of_books_id IN number,
                            X_res_ship_to_loc_id IN OUT NOCOPY number,
                            X_ship_to_loc_dsp IN OUT NOCOPY varchar2,
                            X_ship_org_code IN OUT NOCOPY varchar2,
                            X_ship_org_name IN OUT NOCOPY varchar2,
                            X_ship_org_id  IN OUT NOCOPY number,
                            X_res_bill_to_loc_id IN OUT NOCOPY number ,
                            X_bill_to_loc_dsp IN OUT NOCOPY varchar2,
                            X_res_fob IN OUT NOCOPY varchar2,
                            X_res_pay_on_code IN OUT NOCOPY varchar2,
                            X_res_ship_via IN OUT NOCOPY varchar2 ,
                            X_res_freight_terms IN OUT NOCOPY varchar2 ,
                            X_res_terms_id IN OUT NOCOPY number,
                            X_res_invoice_currency_code IN OUT NOCOPY varchar2,
                            X_fob_dsp IN OUT NOCOPY varchar2,
                            X_pay_on_dsp IN OUT NOCOPY varchar2,
                            X_ship_via_dsp IN OUT NOCOPY varchar2,
                            X_freight_terms_dsp IN OUT NOCOPY varchar2,
                            X_terms_dsp  IN OUT NOCOPY varchar2 ,
                            X_vendor_contact_id IN OUT NOCOPY number,
                            X_vendor_contact_name IN OUT NOCOPY varchar2,
                            x_res_shipping_control IN OUT NOCOPY VARCHAR2    -- <INBOUND LOGISTICS FPJ>
                           )   ;



/*===========================================================================
  PROCEDURE NAME : get_vendor_site_name()

  DESCRIPTION    :

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXPOREL.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

========================================================================*/

  PROCEDURE get_vendor_site_name
		      (X_vendor_site_id IN NUMBER,
		       X_vendor_site_name IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:   derive_vendor_site_info()

  DESCRIPTION:      Accepts as input a vendor site record and using the components
                    that have values, derives the values for components that do not have
                    any values (are null)

  PARAMETERS:       p_vendor_site_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.VendorSiteRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:            dbms_sql is used to generate the WHERE clause based on components that
                    have values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  10/24       Raj Bhakta
===========================================================================*/

  PROCEDURE derive_vendor_site_info(
           p_vendor_site_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.VendorSiteRecType);


/*===========================================================================
  PROCEDURE NAME:   validate_vendor_site_info()

  DESCRIPTION:      Accepts as input a vendor site record,  validates the
                    components that have values and also some other business rules.

  PARAMETERS:       p_vendor_site_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.VendorSiteRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:            dbms_sql is used to generate the WHERE clause based on components that
                    have values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  10/24       Raj Bhakta
===========================================================================*/

  PROCEDURE validate_vendor_site_info(
           p_vendor_site_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.VendorSiteRecType,
           p_remit_to_site_id   NUMBER DEFAULT NULL); -- Bug# 3532503

/* RETROACTIVE FPI START */
/*******************************************************************
  PROCEDURE NAME: Get_Transmission_Defaults

  DESCRIPTION   : This procedure get the default transmission method that
		  User has set up in the Supplier Site window.

  Referenced by :
  parameters    : p_document_id - Document header_id
		  p_document_type - Document Type (PO/RELEASE etc)
		  p_preparer_id - Preparer_id of the document.
		  x_default_method - Default supplier communication method
					set up in the vendor sites.
		  x_email_address - Email address where the email should be
					sent.
		  x_fax_number - Fax number where the fax should be sent.
		  x_document_num - Document Number.
                  p_retrieve_only_flag - By default, this procedure updates the
                    xml_flag in the database based on whether the vendor site
                    is set up for XML. If this parameter is 'Y', we will not
                    update the database. This is necessary to avoid locking
                    issues from HTML. (Bug 5407459)

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

Procedure Get_Transmission_Defaults(p_document_id          IN NUMBER,
                                    p_document_type        IN VARCHAR2,
                                    p_document_subtype     IN VARCHAR2,
                                    p_preparer_id          IN OUT NOCOPY NUMBER,
                                    x_default_method          OUT NOCOPY VARCHAR2,
                                    x_email_address           OUT NOCOPY VARCHAR2,
                                    x_fax_number              OUT NOCOPY VARCHAR2,
                                    x_document_num            OUT NOCOPY VARCHAR2,
                                    p_retrieve_only_flag   IN VARCHAR2 DEFAULT NULL);

-- Bug 5407459 Added this procedure.
procedure get_transmission_defaults_edi (
                                    p_document_id          IN NUMBER,
                                    p_document_type        IN VARCHAR2,
                                    p_document_subtype     IN VARCHAR2,
                                    p_preparer_id          IN OUT NOCOPY NUMBER,
                                    x_default_method       OUT NOCOPY VARCHAR2,
                                    x_email_address        OUT NOCOPY VARCHAR2,
                                    x_fax_number           OUT NOCOPY VARCHAR2,
                                    x_document_num         OUT NOCOPY VARCHAR2,
                                    p_retrieve_only_flag   IN VARCHAR2 DEFAULT NULL);

--<Shared Proc FPJ>
FUNCTION get_org_id_from_vendor_site(p_vendor_site_id    IN NUMBER)
RETURN PO_HEADERS_ALL.org_id%TYPE;

END PO_VENDOR_SITES_SV;
/* RETROACTIVE FPI END */

 

/
