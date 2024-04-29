--------------------------------------------------------
--  DDL for Package PO_SOURCING_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SOURCING_SV4" AUTHID CURRENT_USER as
/* $Header: POXSCS1S.pls 115.2 2002/11/23 01:51:13 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_SOURCING_SV4

  DESCRIPTION:		This package contains the server side Supplier Item
			Catalog and Sourcing Application Program Interfaces
			(APIs).

  CLIENT/SERVER:	Server

  OWNER:		Liza Broadbent

  FUNCTION/PROCEDURE:	val_src_dest()
			get_disposition_message()


===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	get_disposition_message

  DESCRIPTION:		Finds the disposition message(s) associated
			with the item/organization provided.  If
			one or many messages are found, this function
			return true.  If multiple messages are found,
			the x_multiple_flag is also set to 'Y'

  RETURN VALUE:		boolean


  PARAMETERS:		x_item_id         in     number,
		  	x_org_id          in     number,
			x_cross_ref_type  in     varchar2,
			x_message	  in out varchar2,
			x_multiple_flag   in out varchar2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	15-NOV-95	LBROADBE
===========================================================================*/
function get_disposition_message(x_item_id        in     number,
				 x_org_id         in     number,
				 x_cross_ref_type in     varchar2,
				 x_message	  in out NOCOPY varchar2,
				 x_multiple_flag  in out NOCOPY varchar2) return boolean;

/*===========================================================================
  FUNCTION NAME:	val_src_dest

  DESCRIPTION:

  RETURN VALUE:		boolean


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	15-NOV-95	LBROADBE
===========================================================================*/
FUNCTION val_src_dest(x_val_level                in     varchar2,
		      x_sob_id		         in     number,
		      x_item_id		         in     number,
		      x_item_revision	         in     varchar2,
		      x_ship_to			 in     varchar2,
		      x_receiving		 in 	varchar2,
		      x_source_type	         in out NOCOPY varchar2,
		      x_destination_type	 in out NOCOPY varchar2,
		      x_destination_org_id       in out NOCOPY number,
		      x_destination_loc_id       in out NOCOPY number,
		      x_destination_subinventory in out NOCOPY varchar2,
		      x_source_org_id	         in out NOCOPY number,
		      x_source_subinventory      in out NOCOPY varchar2,
		      x_error_type		 in out NOCOPY varchar2) return boolean;

END PO_SOURCING_SV4;

 

/
