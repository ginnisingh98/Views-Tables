--------------------------------------------------------
--  DDL for Package PO_SUBINVENTORIES_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SUBINVENTORIES_S2" AUTHID CURRENT_USER as
/* $Header: POXCOS2S.pls 115.2 2002/11/25 23:37:33 sbull ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_SUBINVENTORIES_S2

  DESCRIPTION:		This package contains new subinventory validation
			routines released on 11/17/95.  One of the relevant
			changes from the previous versions is there is no
			longer a separate source and destination subinventory
			validation procedure; there is only one which handles
			either case.

  CLIENT/SERVER:	Server

  OWNER:		Liza Broadbent

  FUNCTION/PROCEDURE:	val_subinventory()
			val_mrp_src_sub()

===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	val_subinventory

  DESCRIPTION:		Validation for either a source or destination
			subinventory which returns FALSE if the sub is
			invalid.  Set the x_validation_type parameter
			to either -- DESTINATION or SOURCE -- to indicate
			which validation to perform. The error type is
		 	used to determine what message the calling procedure
			should display if the function returns FALSE.



  RETURN VALUE:		boolean


  PARAMETERS:		x_dest_subinventory,
			x_destination_org_id,
			x_source_type,
			x_source_subinventory,
			x_source_org_id,
			x_transaction_date,
			x_item_id,
			x_destination_type,
			x_validation_type

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	15-NOV-95	LBROADBE
			Modified        25-JAN-96       Ramana Mulpury

===========================================================================*/
function val_subinventory(x_dest_subinventory   in varchar2,
			  x_destination_org_id  in number,
			  x_source_type		in varchar2,
			  x_source_subinventory in varchar2,
			  x_source_org_id	in number,
			  x_transaction_date    in date,
			  x_item_id	        in number,
			  x_destination_type    in varchar2,
			  x_validation_type     in varchar2,
			  x_error_type		in out NOCOPY varchar2)return boolean;

/*===========================================================================
  FUNCTION NAME:	val_mrp_src_sub()

  DESCRIPTION:		Checks whether the source and destination orgs are the
			same.  If so, it then checks to see if the item is
			MPR planned in this common org.  If it is, the source
			subinventory must be non-nettable.  The function
			returns FALSE if the validation fails.

  RETURN VALUE:		boolean


  PARAMETERS:		x_subinventory,
			x_source_org_id,
			x_destination_org_id,
			x_item_id

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	15-NOV-95	LBROADBE
===========================================================================*/
function val_mrp_src_sub(x_subinventory       in varchar2,
			 x_source_org_id      in number,
			 x_destination_org_id in number,
			 x_item_id	      in number) return boolean;

END PO_SUBINVENTORIES_S2;

 

/
