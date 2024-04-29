--------------------------------------------------------
--  DDL for Package RCV_ROUTING_HEADERS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROUTING_HEADERS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIRHS.pls 115.0 99/07/17 01:50:29 porting ship $ */

/*==================================================================
  FUNCTION NAME:  derive_routing_header_id()

  DESCRIPTION:    This API is used to  derive routing_header_id giving
                  routing_name as an input parameter.

  PARAMETERS:	  x_routing_name   IN VARCHAR2


  DESIGN
  REFERENCES:	  832dvapi.dd

  ALGORITHM:      API returns routing_header_id (NUMBER) if found,
                  NULL otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      13-MAR-1996     Daisy Yu

=======================================================================*/

FUNCTION derive_routing_header_id(X_routing_name IN VARCHAR2)
return NUMBER;

END RCV_ROUTING_HEADERS_SV1;

 

/
