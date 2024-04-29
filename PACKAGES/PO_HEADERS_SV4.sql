--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV4" AUTHID CURRENT_USER AS
/* $Header: POXPOH4S.pls 115.7 2003/06/18 19:28:34 bao ship $*/



FUNCTION is_quotation                                    -- <GA FPI>
(   p_po_header_id             IN   PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_doc_type_lookup_code ()

  DESCRIPTION:   This procedure returns the PO document type name and
                 type lookup code for a given document_type_code and
                 document_subtype.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/




 procedure get_doc_type_lookup_code  (X_doc_type_code        IN     VARCHAR2,
				      X_doc_subtype          IN     VARCHAR2,
                                      X_def_doc_type_name    IN OUT NOCOPY VARCHAR2,
                                      X_def_type_lookup_code IN OUT NOCOPY VARCHAR2);



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
                            	  X_lookup_code_dsp             IN OUT NOCOPY VARCHAR2);


FUNCTION get_type_name                                   -- <GA FPI>
(   p_po_header_id            IN    PO_HEADERS_ALL.po_header_id%TYPE
) RETURN PO_DOCUMENT_TYPES_ALL.type_name%TYPE;

FUNCTION get_doc_num                                     -- <GA FPI>
(   p_po_header_id            IN    PO_HEADERS_ALL.po_header_id%TYPE
) RETURN PO_HEADERS_ALL.segment1%TYPE;

FUNCTION get_vendor_quote_num                            -- <GA FPI>
(   p_po_header_id            IN    PO_HEADERS_ALL.po_header_id%TYPE
) RETURN PO_HEADERS_ALL.quote_vendor_quote_number%TYPE;


/*===========================================================================
  FUNCTION NAME:	val_vendor_has_contracts()

  DESCRIPTION:		This procedure gets the number of contracts
                        associated with the vendor on the Standard/Planned
                        PO.

  PARAMETERS:		X_Vendor_id IN number

  RETURN VALUE:         X_vendor_has_contracts boolean

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SIYER   07/02/96	Created
===========================================================================*/
 function  val_vendor_has_contracts (X_vendor_id        IN NUMBER)
                  return varchar2;
-- pragma restrict_references (val_vendor_has_contracts, WNDS,RNPS,WNPS);


/*===========================================================================
  PROCEDURE NAME:	get_preparer_approve_flag ()

  DESCRIPTION:		This procedure gets the can_prepare_approve_flag from
                        the po_document_types table.

  PARAMETERS:		X_document_type               IN VARCHAR2,
                        X_document_subtype            IN VARCHAR2,
                        X_can_preparer_approve_flag   IN OUT VARCHAR2


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	WLAU	 	07/12/96	Created
===========================================================================*/

 PROCEDURE get_preparer_approve_flag
           (X_document_type             IN VARCHAR2,
	    X_document_subtype          IN VARCHAR2,
            X_can_preparer_approve_flag IN OUT NOCOPY VARCHAR2);


FUNCTION cumulative_lines_exist                          -- <2706225>
(    p_po_header_id           IN     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

/*
FUNCTION references_exist                -- <GA FPI>
(   p_po_header_id     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;
*/

-- <GC FPJ START>

PROCEDURE is_contract_valid
(  p_po_header_id IN         NUMBER,
   x_result       OUT NOCOPY VARCHAR2
);

-- <GC FPJ END>

END PO_HEADERS_SV4;

 

/
