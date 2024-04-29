--------------------------------------------------------
--  DDL for Package PO_LOCATIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LOCATIONS_SV2" AUTHID CURRENT_USER as
/* $Header: POXCOL1S.pls 120.1 2006/02/14 12:26:02 dreddy noship $*/

/*===========================================================================
  PACKAGE NAME:		PO_LOCATIONS_SV2

  DESCRIPTION:		Contains a single validation function for location
			that takes arguments indicating what kind of
			location is being validated.

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:		Liza Broadbent

  PROCEDURE/FUNCTION NAMES:
			val_location()


  HISTORY:		11-15-95	LBROADBE	Created

===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	val_location()

  DESCRIPTION:		Validates destination locations.  The x_ship_to
			and x_receiving parameters should be set to 'Y'
			by the calling routine if these flags should be
			checked.  The x_val_internal parameter should be
			set to 'Y' if you want to verify that a row exists
			in po_location_associations for this location.  The
			function returns FALSE if the locations is invalid
			for any of the relevant business rules.

  RETURN VALUE:		boolean


  PARAMETERS:		x_location_id,
		      	x_destination_org_id,
		     	x_ship_to,
		      	x_receiving,
		      	x_val_internal
                        x_source_org_id  (Bug 5028505)

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	15-NOV-95	LBROADBE
===========================================================================*/
function val_location(x_location_id        in number,
		      x_destination_org_id in number,
		      x_ship_to       	   in varchar2,
		      x_receiving	   in varchar2,
		      x_val_internal	   in varchar2,
                      x_source_org_id      in number default null) return boolean;

END PO_LOCATIONS_SV2;

 

/
