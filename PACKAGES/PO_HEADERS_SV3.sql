--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV3" AUTHID CURRENT_USER AS
/* $Header: POXPOH3S.pls 115.4 2002/12/11 23:39:37 anhuang ship $*/

/*===========================================================================
  PROCEDURE NAME:	get_security_level_code()

  DESCRIPTION:   This procedure gets the security level code for a given
                 document sub type.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
procedure get_security_level_code(X_po_type     IN varchar2,
                                   X_po_sub_type IN varchar2,
                                   X_security_level_code IN OUT NOCOPY varchar2);


procedure test_get_security_level_code;
/*===========================================================================
  FUNCTION NAME:	get_currency_code()

  DESCRIPTION:   This procedure returns the currency code for a given PO.
                 For instance, this is used in the PO_LINE_LOCATIONS_RELEASE_V
                 view.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 function get_currency_code(X_po_header_id IN NUMBER)
          return varchar2;

PROCEDURE get_currency_info                              -- <2694908>
(   p_po_header_id      IN         PO_HEADERS_ALL.po_header_id%TYPE ,
    x_currency_code     OUT NOCOPY PO_HEADERS_ALL.currency_code%TYPE ,
    x_rate_type         OUT NOCOPY PO_HEADERS_ALL.rate_type%TYPE,
    x_rate_date         OUT NOCOPY PO_HEADERS_ALL.rate_date%TYPE,
    x_rate              OUT NOCOPY PO_HEADERS_ALL.rate%TYPE
);
 -- pragma restrict_references (get_currency_code, WNDS,RNPS,WNPS);



/*===========================================================================
  PROCEDURE NAME:	get_doc_num()

  DESCRIPTION:   	This procedure obtains the document number
			given the po_header_id.

  PARAMETERS:		x_doc_num	IN OUT VARCHAR2
			x_header_id	IN     NUMBER

  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	 08/09  Created
===========================================================================*/
procedure get_doc_num (X_doc_num	IN OUT NOCOPY VARCHAR2,
                       X_header_id	IN     NUMBER);

/*===========================================================================
  PROCEDURE NAME:	get_po_header_id ()

  DESCRIPTION:   	This procedure obtains the po_header_id
			given the document number.

  PARAMETERS:		x_doc_num	IN OUT VARCHAR2
			x_header_id	IN     NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG		 12/6/96  Created
===========================================================================*/

-- Moved this into RCVTISVS.pls due to compatibility issues with globalization
/* procedure get_po_header_id (X_po_header_id_record	IN OUT	rcv_shipment_line_sv.document_num_record_type); */


/*===========================================================================
  FUNCTION NAME:	get_po_status()

  DESCRIPTION:   This function returns the status for a given PO.
                 The document statuses are concatenated into one field
                 that is returned.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 function get_po_status  (X_po_header_id IN NUMBER)
                          return varchar2;

 -- pragma restrict_references (get_po_status, WNDS,RNPS,WNPS);



END PO_HEADERS_SV3;

 

/
