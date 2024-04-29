--------------------------------------------------------
--  DDL for Package Body PO_DOC_MANAGER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOC_MANAGER_PUB" AS
/* $Header: POXWAPIB.pls 120.0.12010000.2 2008/08/04 08:35:05 rramasam ship $ */

/*===========================================================================

  PROCEDURE NAME:    CALL_DOC_MANAGER(X_DM_CALL_REC IN OUT PO_DOC_MANAGER_PUB.DM_CALL_REC_TYPE)

=============================================================================*/

PROCEDURE CALL_DOC_MANAGER(X_DM_CALL_REC IN OUT NOCOPY PO_DOC_MANAGER_PUB.DM_CALL_REC_TYPE) IS
pragma AUTONOMOUS_TRANSACTION;
  BEGIN

    -- <Doc Manager Rewrite R12 Start>
    -- This API should no longer be used; the old Pro*C doc manager is
    -- obsoleted for all actions other than cancel, which will soon be obsoleted.
    -- This API was originally mislabelled.  This is not a PUB level API.
    -- All functionality of the old document manager has been moved to
    -- packages like PO_DOCUMENT_ACTION_PVT and PO_DOCUMENT_FUNDS_PVT.
    -- If pub level apis are needed, they should be wrapped around those
    -- new packages.

    -- This methods does nothing now.

    COMMIT;

    -- <Doc Manager Rewrite R12 End>

  END CALL_DOC_MANAGER;

END PO_DOC_MANAGER_PUB;


/
