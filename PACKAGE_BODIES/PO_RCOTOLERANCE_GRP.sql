--------------------------------------------------------
--  DDL for Package Body PO_RCOTOLERANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RCOTOLERANCE_GRP" AS
/* $Header: POXGRTWB.pls 120.1.12010000.2 2008/11/03 10:27:05 rojain ship $*/


/**
* Public PROCEDURE set_approval_required_flag
* Requires: Change Request Group Id
* Modifies: Updates po_change_requests with the result of the tolerance check.
* Returns:
*  approval_required_flag: Y if user cannot auto approve
*                        : N if he/she can auto approve
*/

PROCEDURE set_approval_required_flag(
  p_chreqgrp_id IN NUMBER
, x_appr_status OUT NOCOPY VARCHAR2
, p_source_type_code  IN VARCHAR2 DEFAULT NULL
)
IS
BEGIN
   po_rcotolerance_pvt.set_approval_required_flag(p_chreqgrp_id,
			    x_appr_status,
		                              p_source_type_code);
EXCEPTION WHEN OTHERS THEN
  -- do not raise exception. if something wrong, just assume owner needs approval
  x_appr_status := 'Y';
END;


END po_rcotolerance_grp;


/
