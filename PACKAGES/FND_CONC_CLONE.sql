--------------------------------------------------------
--  DDL for Package FND_CONC_CLONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_CLONE" AUTHID CURRENT_USER as
/* $Header: AFCPCLNS.pls 120.1.12010000.3 2015/08/13 15:13:01 ckclark ship $ */

/*
 * Procedure: target_clean
 *
 * ***************************************************************************
 * NOTE: If you are not sure what you are doing do not run this procedure.
 *       This API is for Rapid Install team use only.
 * ***************************************************************************
 *
 * Purpose: To clean up target database for cloning purpose.
 *   It is callers responsibility to do the commit after calling target_clean
 *   target_clean does not handle any exceptions.
 *
 * Arguments: none
 *
 */
procedure target_clean;

/*
 * Procedure: setup_clean
 *
 * ***************************************************************************
 * NOTE: If you are not sure what you are doing do not run this procedure.
 *       This API is for Cloning instance and will be used by  cloning.
 * ***************************************************************************
 *
 * Purpose: To clean up target database in a cloning case.
 *   It is callers responsibility to do the commit after calling
 *   setup_clean.  setup_clean does not handle any exceptions.
 *
 * Arguments: none
 *
 */
procedure setup_clean;


/*
 * Procedure: cancel_all_pending
 *
 * ***************************************************************************
 * NOTE: If you are not sure what you are doing do not run this function.
 *       This API is for ATG internal use only.
 *       This function should be used only after a clone, and while
 *       no concurrent managers are running.
 * ***************************************************************************
 *
 * Purpose: To clean up target database in a cloning case.
 *   It is callers responsibility to do the commit after calling
 *   cancel_all_pending.  Exceptions will be set on the FND_MESSAGE stack.
 *
 * Arguments: none
 * Returns: Number of requests cancelled, -1 on error
 *
 */
function cancel_all_pending return number;


end;

/
