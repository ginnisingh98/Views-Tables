--------------------------------------------------------
--  DDL for Package PO_CONTROL_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CONTROL_CHECKS" AUTHID CURRENT_USER AS
/* $Header: POXPOSCS.pls 120.1 2005/08/29 20:36:00 spangulu noship $ */

  -- Submission Checks

  -- <Doc Manager Rewrite R12>: Removed po_check function, get_debug function


  --<DropShip FPJ Start>
  FUNCTION chk_drop_ship(
    p_doctyp  IN VARCHAR2,
    p_docid  IN NUMBER,
    p_lineid  IN NUMBER,
    p_shipid  IN NUMBER,
    p_reportid   IN NUMBER,
    p_action IN VARCHAR2,
    p_return_code IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;
  --<DropShip FPJ End>



END PO_CONTROL_CHECKS;

 

/
