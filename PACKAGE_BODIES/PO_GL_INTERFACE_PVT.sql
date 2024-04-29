--------------------------------------------------------
--  DDL for Package Body PO_GL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GL_INTERFACE_PVT" AS
/* $Header: PO_GL_INTER_PVT.plb 120.1 2005/06/07 07:16:45 vsanjay noship $*/

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_aff_validation_context
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Procedure:
--   This procedure Sets the context information for accounting flexfields so
--   that only the valid balancing and management segment values will be
--   displayed.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id for which the context needs to be set.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:  Nothing
--Notes:
--   Context_Type - the type of context being set.  Valid values are:
--   LE - Legal Entity
--   LG - Ledger
--   OU - Operating Unit
--   Context_Id - the legal entity id, ledger id, or operating unit id
--             depending upon the context type.Here we are passing the Context
--             type as 'OU'.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE set_aff_validation_context(p_org_id Number)
IS

BEGIN

        GL_GLOBAL.set_aff_validation('OU', p_org_id);

END set_aff_validation_context;

END PO_GL_INTERFACE_PVT;

/
