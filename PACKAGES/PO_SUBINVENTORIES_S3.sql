--------------------------------------------------------
--  DDL for Package PO_SUBINVENTORIES_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SUBINVENTORIES_S3" AUTHID CURRENT_USER as
/* $Header: POXCOS3S.pls 120.0.12010000.1 2008/09/18 12:20:56 appldev noship $*/

/*===========================================================================
  PACKAGE NAME:		PO_SUBINVENTORIES_S3

  DESCRIPTION:		This package contains validation for Inventory
			transfers to determine whether an item/sub
			combination is valid based on their source
			and destination asset attributes.

  OWNER:		Liza Broadbent (should be transferred to Inventory)

  FUNCTION/PROCEDURE:	val_expense_asset()
			val_expense_asset()

===========================================================================*/
/*=========================================================================

   FUNCTION: 	val_expense_asset()

   RETURN:	boolean

   PARAMETERS:	x_item_id		in number
		x_src_org_id		in number
		x_src_subinventory	in varchar2
		x_dest_org_id		in number
		x_dest_subinventory	in varchar2

		-- Use this version when you do not know the
		-- attributes required in the second version.
		-- This version will find these attributes,
		-- and call the second version.
  OR...

		x_item_id		in number
		x_src_sub_asset_flag	in number
		x_src_item_asset_flag	in varchar2
		x_dest_sub_asset_flag	in number
		x_dest_item_asset_flag	in varchar2
		x_fob_point		in number
		x_intransit_type	in number

   Description: This function looks for invalid expense/asset
		source and destination subinventory and item
		combinations.  It returns FALSE if the combination
		is invalid, and TRUE if it is.

    Algorithm:  The following matrix highlights identifies
		valid and invalid combinations (published by
                Inventory on February 8, 1996):
   Transfer Type: 	Direct

   From Item	To Item		From Sub	To Sub	  Valid?
   -------------------------------------------------------------
   Asset	Asset		Asset		Asset	   Yes
   Asset	Asset		Asset		Expense    Yes
   Asset	Asset		Expense		Expense    Yes
   Asset	Asset		Expense		Asset	   No **
   Asset	Expense		Asset		Asset	   Yes
   Asset	Expense		Asset		Expense    Yes
   Asset	Expense		Expense		Asset	   Yes
   Asset	Expense		Expense		Expense	   Yes
   Expense	Asset		Asset		Expense    Yes
   Expense	Asset		Asset		Asset	   No **
   Expense      Asset		Expense		Expense	   Yes
   Expense 	Asset		Expense		Asset	   No **
   Expense	Expense		Asset		Asset	   Yes
   Expense	Expense		Asset		Expense	   Yes
   Expense	Expense		Expense		Asset	   Yes
   Expense	Expense		Expense		Expense	   Yes

   Transfer Type:	Intransit, FOB = Receipt

   From Item	To Item		From Sub	To Sub	  Valid?
   -------------------------------------------------------------
   Asset	Asset		Asset		Asset	  Yes
   Asset	Asset		Asset		Expense   Yes
   Asset	Asset		Expense		Asset	  No **
   Asset	Asset		Expense		Expense   No **
   Asset	Expense		Asset		Asset	  Yes
   Asset	Expense		Asset		Expense   Yes
   Asset	Expense		Expense		Asset	  No **
   Asset	Expense		Expense		Expense   No **
   Expense	Asset		Asset		Asset	  No **
   Expense	Asset		Asset		Expense   Yes
   Expense	Asset		Expense		Asset	  No **
   Expense	Asset		Expense		Expense	  Yes
   Expense	Expense		Asset		Asset     Yes
   Expense	Expense		Asset		Expense	  Yes
   Expense	Expense		Expense		Asset	  Yes
   Expense	Expense		Expense		Expense	  Yes

   Transfer Type:	Intransit, FOB = Shipment

   From Item	To Item		From Sub	To Sub	  Valid?
   -------------------------------------------------------------
   Asset	Asset		Asset		Asset	  Yes
   Asset	Asset		Asset		Expense   Yes
   Asset	Asset		Expense		Asset	  No **
   Asset	Asset		Epense		Expense   No **
   Asset	Expense		Asset		Asset	  Yes
   Asset	Expense		Asset		Expense   Yes
   Asset	Expense		Expense		Asset	  Yes
   Asset	Expense		Expense		Expense   Yes
   Expense 	Asset		Asset		Asset	  No **
   Expense	Asset		Asset		Expense   No **
   Expense	Asset		Expense		Asset	  No **
   Expense	Asset		Expense		Expense   No **
   Expense	Expense		Asset		Asset	  Yes
   Expense	Expense		Asset		Expense   Yes
   Expense	Expense		Expense		Asset	  Yes
   Expense	Expense		Expense		Expense   Yes

   HISTORY:	Created		31-MAR-96	Liza Broadbent

=============================================================================*/
function val_expense_asset(x_item_id		in number,
			   x_src_org_id		in number,
			   x_src_subinventory	in varchar2,
			   x_dest_org_id	in number,
			   x_dest_subinventory	in varchar2) return boolean;

function val_expense_asset(x_item_id	          in number,
			   x_src_sub_asset_flag   in number,
			   x_src_item_asset_flag  in varchar2,
			   x_dest_sub_asset_flag  in number,
			   x_dest_item_asset_flag in varchar2,
			   x_fob_point		  in number,
			   x_intransit_type	  in number) return boolean;

END PO_SUBINVENTORIES_S3;

/
