--------------------------------------------------------
--  DDL for Package PO_AGENTS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AGENTS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIAGS.pls 120.0.12010000.1 2008/09/18 12:21:09 appldev noship $ */

/*==================================================================
  FUNCTION NAME:  derive_agent_id()

  DESCRIPTION:    This API is used to derive agent_id in PO_HEADERS
                  given apgent_name as an input parameter. Agent_name
                  is assumed to be the full name of the employee in
                  po_buyers_val_v.

  PARAMETERS:	  x_agent_name    IN VARCHAR2


  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      returns agent_id (NUMBER) if found; NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      12-MAR-1996     Daisy Yu

=======================================================================*/

FUNCTION derive_agent_id(X_agent_name IN VARCHAR2)return NUMBER;

/*==================================================================
  FUNCTION NAME:  val_agent_id()

  DESCRIPTION:    This API used to check if X_agent_id is an active and
                  valid buyer.

  PARAMETERS:	  x_agent_id       IN NUMBER



  DESIGN
  REFERENCES:	  832vlapi.doc

  ALGORITHM:      API returns TRUE if validation succeeds; FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan


=======================================================================*/
FUNCTION val_agent_id(x_agent_id   IN NUMBER) RETURN BOOLEAN;

END PO_AGENTS_SV1;

/
