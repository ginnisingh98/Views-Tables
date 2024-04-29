--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV2" AUTHID CURRENT_USER AS
/* $Header: POXPOH2S.pls 115.5 2003/11/01 00:05:04 dxie ship $*/

/*===========================================================================
  PROCEDURE NAME:	val_approval_status()

  DESCRIPTION:
                Verify if any of the values have changed from their
                old values ( by selecting from  the db for the same rowid)
                           Agent Id
                           Vendor Site Id
                           Contact Id
                           confirming_order_flag
                           bill_to_location_id
                           terms_id
                           ship_via_lookup_code
                           fob_lookup_code
                           freight_terms_lookup_code
                           note_to_vendor
                           acceptance_required_flag
                           acceptance_due_date
                           blanket_total_amount
                           start_date
                           end_date
                           amount_limit
			   conterms_articles_upd_date   --<CONTERMS FPJ>
			   conterms_deliv_upd_date      --<CONTERMS FPJ>
         				 - Refresh the document status.
			  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 FUNCTION  val_approval_status(X_po_header_id             IN NUMBER,
		               X_agent_id                 IN NUMBER,
                               X_vendor_site_id           IN NUMBER,
                               X_vendor_contact_id        IN NUMBER,
                               X_confirming_order_flag    IN VARCHAR2,
                               X_ship_to_location_id      IN NUMBER,
                               X_bill_to_location_id      IN NUMBER,
                               X_terms_id                 IN NUMBER,
                               X_ship_via_lookup_code     IN VARCHAR2,
                               X_fob_lookup_code          IN VARCHAR2,
                               X_freight_terms_lookup_code IN VARCHAR2,
                               X_note_to_vendor            IN VARCHAR2,
                               X_acceptance_required_flag  IN VARCHAR2,
                               X_acceptance_due_date       IN DATE,
                               X_blanket_total_amount      IN NUMBER,
                               X_start_date                IN DATE,
                               X_end_date                  IN DATE,
                               X_amount_limit             IN NUMBER
			       ,p_kterms_art_upd_date       IN DATE --<CONTERMS FPJ>
			       ,p_kterms_deliv_upd_date     IN DATE --<CONTERMS FPJ>
                               ,p_shipping_control           IN VARCHAR2 -- <INBOUND LOGISTICS FPJ>
)
           RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	update_children()

  DESCRIPTION:
	 - Refresh the document status.
			  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

--PROCEDURE update_children();


/*===========================================================================
  FUNCTION NAME:	val_release_date()

  DESCRIPTION:

	If the end date is not null we check if there has a release
	against this po (for planned pos/blankets only) after the end date.
	if yes we give the user the message PO_ALL_DATE_BETWEEN_START_END
	Check the notification controls when this field is changed.
        If there are any date based controls , display the error message
        PO_PO_NFC_DATE_CONTROLS_EXIST.  This returns failure.

  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 FUNCTION val_release_date(X_po_header_id number,
                           X_start_date date,
                           X_end_date  date,
                           X_type_lookup_code varchar2,
                           X_menu_path varchar2)
            return boolean;

/*===========================================================================
  FUNCTION NAME:	val_start_date()

  DESCRIPTION: This function checks if there are any releases that have been
               made prior to the start date ( for a PLANNED PO/BLANKET)


  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

function  val_start_date(X_Po_Header_Id                     NUMBER,
                            X_start_date                       DATE  )
             return boolean;

/*===========================================================================
  FUNCTION NAME:	val_end_date()

  DESCRIPTION:  Check that there is no release against this PO after the date
                specified.


  PARAMETERS:

  RETURN VALUE:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION  val_end_date(X_Po_Header_Id                   NUMBER,
                       X_end_date                       DATE  )

         return boolean;

/*==========================================================================

  PROCEDURE NAME : update_req_link()


  DESCRIPTION:  This procedure removes the link to a PO in the Requisition_Lines
                Table when the PO is being deleted.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/

 PROCEDURE update_req_link(X_po_header_id IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:	get_po_details()

  DESCRIPTION:   Get the purchase order details that are associated with
      the purchase order header id.  This routine is called
      from the Enter Releases Form after picking the PO Number
      that you would like to create a release against.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOREL.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_po_details(X_po_header_id IN NUMBER,
		         X_type_lookup_code    IN OUT NOCOPY VARCHAR2,
                         X_revision_num        IN OUT NOCOPY NUMBER,
		         X_currency_code       IN OUT NOCOPY VARCHAR2,
                         X_supplier_id         IN OUT NOCOPY NUMBER,
                         X_supplier_site_id    IN OUT NOCOPY NUMBER,
                         X_ship_to_location_id IN OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:	get_segment1_details()

  DESCRIPTION:
  PARAMETERS:

  DESIGN REFERENCES:	../POXPOREL.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

-- PROCEDURE get_segment1_details();

procedure test_start_date ( X_po_header_id IN number, X_start_date IN date);
procedure test_get_po_encumbered (X_po_header_id IN number);

/*===========================================================================
  PROCEDURE NAME:	get_document_status()

  DESCRIPTION:   This procedure gets the displayed value for the document status
                 for a given lookup_code ( for eg. INCOMPLETE)

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

  procedure get_document_status(X_lookup_code IN varchar2,
				X_document_type IN varchar2,
				X_document_status IN OUT NOCOPY varchar2);


-- <GC FPJ START>

/**=========================================================================
* Procedure: val_contract_eff_date                  <GC FPJ>
* Effects:   Check whether there is any standard PO line that is not created
*            within the effective dates of the contract
* Requires:  None
* Modifies:  None
* Returns:   x_result: FND_API.G_TRUE if all lines are within the effective
*                      dates
*                      FND_API.G_FALSE if there exists a line not being
*                      created within the effective dates of the contract it
*                      is referecing
==========================================================================**/

PROCEDURE val_contract_eff_date
( p_po_header_id     IN         NUMBER,
  p_start_date       IN         DATE,
  p_end_date         IN         DATE,
  x_result           OUT NOCOPY VARCHAR2
);

-- <GC FPJ END>

END PO_HEADERS_SV2;

 

/
