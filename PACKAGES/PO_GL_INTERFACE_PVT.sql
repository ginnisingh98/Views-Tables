--------------------------------------------------------
--  DDL for Package PO_GL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GL_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_GL_INTER_PVT.pls 120.1 2005/06/07 07:14:12 vsanjay noship $*/


/* Description: Sets the context information for accounting flexfields so
   that only the valid balancing and management segment values will be
   displayed.
 Returns:  Nothing
 Parameters:
 Context_Type - the type of context being set.  Valid values are:
 LE - Legal Entity
 LG - Ledger
 OU - Operating Unit
 Context_Id - the legal entity id, ledger id, or operating unit id
             depending upon the context type.
*/


PROCEDURE set_aff_validation_context(p_org_id Number);



END PO_GL_INTERFACE_PVT;

 

/
