--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV9" AUTHID CURRENT_USER AS
/* $Header: POXPIRDS.pls 115.7 2004/03/24 10:25:31 amritunj ship $ */

/*==================================================================
  PROCEDURE NAME:  replace_po_original_catalog()

  DESCRIPTION:     This API is used validate the original catelog


  PARAMETERS:


  DESIGN
  REFERENCES:	  832proc.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      16-MAR-1996     Daisy Yu
                  Modified      19-MAR-2003     Akhilesh Mritunjai

=======================================================================*/
PROCEDURE replace_po_original_catalog(X_interface_header_id       IN NUMBER,
                                      X_interface_line_id         IN NUMBER,
                                      X_vendor_id                 IN NUMBER,
				      X_document_type_code        IN VARCHAR2,
			 	      X_vendor_doc_num            IN VARCHAR2,
                                      X_start_date                IN DATE,
                                      X_end_date                  IN DATE,
                                      X_header_processable_flag   IN OUT NOCOPY VARCHAR2,
                                      p_ga_flag                   IN VARCHAR2); --<Bug 3504001>


/*==================================================================
  PROCEDURE NAME:  check_po_original_catalog()

  DESCRIPTION:     This API is used to just validate the original catelog
                   It does not replace the original catalog/blanket - used
		   for the "UPDATE" action code.

  PARAMETERS:


  DESIGN
  REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	26-Jun-1998	Imran Ali

=======================================================================*/
PROCEDURE check_po_original_catalog  (X_interface_header_id       IN NUMBER,
                                      X_interface_line_id         IN NUMBER,
                                      X_vendor_id                 IN NUMBER,
				      X_document_type_code        IN VARCHAR2,
			 	      X_vendor_doc_num            IN VARCHAR2,
                                      X_start_date                IN DATE,
                                      X_end_date                  IN DATE,
				      X_document_num		  IN VARCHAR2,
				      X_po_header_id		  IN OUT NOCOPY VARCHAR2,
                                      X_header_processable_flag   IN OUT NOCOPY VARCHAR2);



PROCEDURE check_if_catalog_exists    (X_interface_header_id       IN NUMBER,
                                      X_interface_line_id         IN NUMBER,
                                      X_vendor_id                 IN NUMBER,
				      X_document_type_code        IN VARCHAR2,
			 	      X_vendor_doc_num            IN VARCHAR2,
                                      X_start_date                IN DATE,
                                      X_end_date                  IN DATE,
				      X_po_header_id		  IN OUT NOCOPY VARCHAR2,
                                      X_header_processable_flag   IN OUT NOCOPY VARCHAR2);

END PO_HEADERS_SV9;

 

/
