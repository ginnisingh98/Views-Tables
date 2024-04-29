--------------------------------------------------------
--  DDL for Package POGOT_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POGOT_S" AUTHID CURRENT_USER AS
/* $Header: POGOTS.pls 120.0 2005/06/01 21:13:03 appldev noship $*/
/*===========================================================================
  FUNCTION NAME:	get_total

  DESCRIPTION:          Calculates the total of an object

  PARAMETERS:

  Parameter	         IN/OUT	Datatype   Description
  -------------          ------ ---------- ----------------------------
  x_object_type		  IN    VARCHAR2   Object Type
                                           'H' - for PO Header
                                           'L' - for PO Line
                                           'B' - for PO Blanket
                                           'P' - for Po Planned
                                           'E' - for Requisition Header
                                           'I' - for Requisition Line
                                           'C' - for Contract
                                           'R' - for Release

  x_object_id    	  IN    NUMBER     Id of the object to be
                                           totalled

  x_base_cur_result	  IN    BOOLEAN    Result in Base Currency

  RETURN VALUE:	   Returns total of the object

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION  get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER,
                     x_base_cur_result IN BOOLEAN ) RETURN NUMBER;

FUNCTION  ecx_get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER,
                     x_po_currency IN VARCHAR2) RETURN NUMBER;
                    -- x_base_cur_result_1 IN NUMBER ) RETURN NUMBER;

end;

 

/
