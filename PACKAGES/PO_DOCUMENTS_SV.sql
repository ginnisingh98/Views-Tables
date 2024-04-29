--------------------------------------------------------
--  DDL for Package PO_DOCUMENTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENTS_SV" AUTHID CURRENT_USER as
/* $Header: POXDOTYS.pls 115.2 2002/11/23 03:30:15 sbull ship $ */
/*===========================================================================
  PACKAGE NAME:		po_documents_sv

  DESCRIPTION:		Contains all server side procedures that access
			po documents  entity

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		RMULPURY

  PROCEDURE/FUNCTIONS:	get_doc_type_info
			get_doc_security_level
			get_doc_access_level
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_doc_type_info

  DESCRIPTION:

  PARAMETERS:		x_doc_type_code	IN  VARCHAR2
			x_doc_subtype	IN  VARCHAR2
			x_type_name	OUT VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	5/15	CREATED
===========================================================================*/

PROCEDURE get_doc_type_info ( x_doc_type_code      IN  VARCHAR2,
                              x_doc_subtype        IN  VARCHAR2,
			      x_type_name	   OUT NOCOPY VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:	get_doc_security_level

  DESCRIPTION:

  PARAMETERS:		x_doc_type_code	IN  VARCHAR2
			x_doc_subtype	IN  VARCHAR2
			x_security_level OUT VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	5/15	CREATED
===========================================================================*/

PROCEDURE get_doc_security_level ( x_doc_type_code      IN  VARCHAR2,
                                   x_doc_subtype        IN  VARCHAR2,
			           x_security_level	OUT NOCOPY VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:	get_doc_access_level

  DESCRIPTION:

  PARAMETERS:		x_doc_type_code	IN  VARCHAR2
			x_doc_subtype	IN  VARCHAR2
			x_access_level  OUT VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	5/15	CREATED
===========================================================================*/

PROCEDURE get_doc_access_level ( x_doc_type_code      IN  VARCHAR2,
                                 x_doc_subtype        IN  VARCHAR2,
			         x_access_level	      OUT NOCOPY VARCHAR2);



END PO_DOCUMENTS_SV;

 

/
