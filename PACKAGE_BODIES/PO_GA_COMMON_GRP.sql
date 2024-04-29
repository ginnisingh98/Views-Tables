--------------------------------------------------------
--  DDL for Package Body PO_GA_COMMON_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GA_COMMON_GRP" AS
/* $Header: POXGACMB.pls 115.0 2002/11/25 23:11:12 dreddy noship $ */

/*==============================================================================

	FUNCTION:      is_global_agreement

	DESCRIPTION:   Returns TRUE if the po_header_id is a Global Agreement.
                   FALSE otherwise.

==============================================================================*/
FUNCTION is_global
(
	p_po_header_id	  	PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS

BEGIN

    return PO_GA_PVT.is_global_agreement (p_po_header_id);

EXCEPTION

    WHEN OTHERS THEN
	return (FALSE);

END is_global;

END PO_GA_COMMON_GRP;

/
