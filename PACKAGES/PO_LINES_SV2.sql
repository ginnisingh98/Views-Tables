--------------------------------------------------------
--  DDL for Package PO_LINES_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV2" AUTHID CURRENT_USER as
/* $Header: POXPOL2S.pls 115.5 2003/10/08 16:57:55 zxzhang ship $ */


/*===========================================================================
  PACKAGE NAME:		PO_LINES_SV2

  DESCRIPTION:		This package contains the server side Line level
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  FUNCTION/PROCEDURE:	get_max_line_num()
                        update_line()
===========================================================================*/


/*===========================================================================
  FUNCTION NAME:	get_max_line_num()

  DESCRIPTION:		This function will get the max line number for
                        a given po_header_id

  PARAMETERS:		X_line_id		IN       NUMBER
                        X_po_header_id		IN 	NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	13-Jul-95      SIYER
===========================================================================*/

  function get_max_line_num(X_po_header_id  IN NUMBER)
           RETURN NUMBER ;
--  pragma restrict_references(get_max_line_num,WNDS,RNPS,WNPS);

/*===========================================================================
  PROCEDURE NAME:	update_line()

  DESCRIPTION:		This procedure will be updating a po line
                        and performing other update related activities.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	21-Jul-95      SIYER
			Moved to PO_LINES_SV11 3/19/97 ECSO
===========================================================================*/
/* RETROACTIVE FPI  START */

/*******************************************************************
  PROCEDURE NAME: retroactive_change

  DESCRIPTION   : This is the API which updates the column retroactive_date
                  in po_lines with sysdate. This procedure is called from
                  ON-UPDATE triggers of PO_LINES and PO_SHIPMENTS block
                  in the Enter PO form. Po_lines.retroactive_date gives
                  the time when the blanket agreement had some retroactive
                  price change.
  Referenced by :
  parameters    : p_po_line_id. This is the line_id for which the
                  retroactive_Date needs to be updated.

  CHANGE History: Created      12-Feb-2002    pparthas
*******************************************************************/
Procedure  retroactive_change(p_po_line_id IN number);
/* RETROACTIVE FPI END*/

-- <FPJ Retroactive START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: retroactive_change
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINE_LOCATIONS_ALL.retroactive_date.
--Locks:
--  None.
--Function:
--  This is the API which updates the column retroactive_date in po_line_locations
--  for Release ONLY with sysdate.
--  This procedure is called from PO_SHIPMENTS.price_override WHEN-VALIDATE-ITEM
--  trigger in the Enter Release form.
--  This will give the release shipment a different time with its corresponding
--  blanket agreement line, so that Approval Workflow will know this release had
--  some retroactive price change.
--Parameters:
--IN:
--p_line_location_id
--  the line_location_id for which the retroactive_Date needs to be updated.
--OUT:
--  None.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
Procedure retro_change_shipment(p_line_location_id IN number);
-- <FPJ Retroactive END>

END PO_LINES_SV2;

 

/
