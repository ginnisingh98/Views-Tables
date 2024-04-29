--------------------------------------------------------
--  DDL for Package PO_GA_COMMON_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GA_COMMON_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGACMS.pls 115.0 2002/11/25 23:10:57 dreddy noship $ */

/*==============================================================================

	FUNCTION:      is_global_agreement

	DESCRIPTION:   Returns TRUE if the po_header_id is a Global Agreement.
                   FALSE otherwise.

==============================================================================*/
FUNCTION is_global
(
	p_po_header_id	  	PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN;


END PO_GA_COMMON_GRP;

 

/
