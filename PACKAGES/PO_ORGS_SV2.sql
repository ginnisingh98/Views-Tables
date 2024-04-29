--------------------------------------------------------
--  DDL for Package PO_ORGS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ORGS_SV2" AUTHID CURRENT_USER as
/* $Header: POXCOO1S.pls 115.2 2002/11/25 23:40:55 sbull ship $*/
/*===========================================================================
  PACKAGE NAME:		PO_ORGS_SV2

  DESCRIPTION:		This package contains source and destination org
			validation APIs.

  CLIENT/SERVER:	Server

  OWNER:		Liza Broadbent

  FUNCTION/PROCEDURE:	val_source_org()
			val_dest_org()


===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	val_dest_org()


  DESCRIPTION:   	Validates a destination organization.  Returns FALSE
			if the org is invalid.  Note:  if the x_source_type
			parameter is NULL, then this function will not fail
			for this reason (it handles a NULL source type).

  PARAMETERS:		x_destination_org_id in number,
			x_item_id	     in number,
			x_item_revision	     in varchar2,
			x_destination_type   in varchar2,
			x_sob_id	     in number,
			x_source_type	     in varchar2

  RETURN VALUE:		boolean


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     	Liza Broadbent		11-15-95	Created

===============================================================================*/
function val_dest_org(x_destination_org_id in number,
		      x_item_id            in number,
		      x_item_revision      in varchar2,
		      x_destination_type   in varchar2,
		      x_sob_id		   in number,
		      x_source_type        in varchar2) return boolean;

/*===========================================================================
  FUNCTION NAME:	val_source_org()


  DESCRIPTION:   	Validates a source organization.  Returns FALSE
			if the org is invalid.  It also sets the x_error_type
			parameter to indicate how the validation failed.


  PARAMETERS:		x_source_org_id      in number,
			x_destination_org_id in number,
			x_item_id	     in number,
			x_item_revision      in varchar2,
			x_sob_id	     in number,
			x_error_type	     in out varchar2

  RETURN VALUE:		boolean


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     	Liza Broadbent		11-15-95	Created

===============================================================================*/
function val_source_org(x_source_org_id       in number,
			x_destination_org_id  in number,
			x_destination_type    in varchar2,
			x_item_id             in number,
			x_item_revision	      in varchar2,
			x_sob_id	      in number,
		 	x_error_type	      in out NOCOPY varchar2) return boolean;
END PO_ORGS_SV2;

 

/
