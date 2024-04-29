--------------------------------------------------------
--  DDL for Package PO_LINES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPILSS.pls 120.0.12000000.1 2007/07/27 08:27:41 grohit noship $ */

/*==================================================================
  FUNCTION NAME:  val_line_num_uniqueness()

  DESCRIPTION:    This API is used to validate the uniqueness of
                  the line number in po_lines table.

  PARAMETERS:	  x_line_num      IN NUMBER,
                  x_rowid         IN VARCHAR2,
                  x_po_header_id  IN NUMBER

  DESIGN
  REFERENCES:	  832vlapl.doc

  ALGORITHM:      API returns TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	DXYU


=======================================================================*/
 FUNCTION val_line_num_uniqueness(x_line_num       IN NUMBER,
                                  x_rowid          IN VARCHAR2,
                                  x_po_header_id   IN NUMBER)
 RETURN BOOLEAN;

/*======================================================================
  FUNCTION NAME:	val_line_id_uniqueness()

  DESCRIPTION:		This API is used to validate the uniqueness of
                        the line id in po_lines table.

  PARAMETERS:		x_po_line_id    IN NUMBER,
                        x_rowid         IN VARCHAR2,
                        x_po_header_id  IN NUMBER

  DESIGN REFERENCES:    832vlapl.doc

  ALGORITHM:            API returns TRUE if validation succeeds, FALSE
                        otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE HISTORY:	Created		16-FEB-1996	DXYU

=======================================================================*/
 FUNCTION val_line_id_uniqueness(x_po_line_id    IN NUMBER,
                                 x_rowid         IN VARCHAR2,
                                 x_po_header_id  IN NUMBER)
 RETURN BOOLEAN;


/*==================================================================
  FUNCTION NAME:  derive_po_line_id()

  DESCRIPTION:    This API is used to derive po_line_id given
                  po_header_id and line_numas input parameter.

  PARAMETERS:	  x_po_header_id  IN NUMBER,
                  x_line_num      IN NUMBER

  DESIGN
  REFERENCES:	  832dvapi.doc

  ALGORITHM:      API returns po_line_id (NUMBER) if found,
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	19-FEB-1996	SODAYAR


=======================================================================*/
FUNCTION derive_po_line_id(X_po_header_id IN NUMBER,
                           X_line_num IN NUMBER) return NUMBER;

END PO_LINES_SV1;

 

/
