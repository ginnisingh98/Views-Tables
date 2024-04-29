--------------------------------------------------------
--  DDL for Package PO_SUBINVENTORIES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SUBINVENTORIES_S" AUTHID CURRENT_USER AS
/* $Header: POXCOS1S.pls 115.2 2002/11/25 23:38:08 sbull ship $*/

/* create client package */
/*
PACKAGE PO_SUBINVENTORIES_S IS
*/

/*===========================================================================
  FUNCTION NAME:	val_subinventory()

  DESCRIPTION:
	This function is for receiving transactions. So transaction date,
	destination type, item id, and organization id must be passed. It
	does not do a generic subinventory validation. (1)

	Valify if subinventory is required for a given destincation type.
	'EXPENSE', 'SHOP FLOOR', 'INVENTORY'.  'RECEIVING', 'MULTIPLE'. (2)
	Always required if destination type is inventory.

	If subinventory is required, check whether subinventory field is
	entered.  MESSAGE_NAME="RCV_ALL_MISSING_SUBINVENTORY"

	Check if given subinventory is valid based on item subinventory
	restriction, subinventory in-active date, etc.


  PARAMETERS:
	x_subinventory   	IN VARCHAR2(10),
	x_organization_id	IN NUMBER,
	x_transaction_date	IN DATE, (3)
	x_item_id		IN NUMBER,
	x_destination_type	IN VARCHAR2

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:
	if x_destination_type is not inventory, then
	   return ok
	end if

        if x_subinventory = '' then
	   return fail
	end if

	if subinventory active date expired then
	   return fail
	end if

	get restrict_subinventories_code from mtl_system_items for the
	->current x_item_id (2)
	if x_subinventory is not in valid subinventory list, then
	   return fail
	end if

	return ok. looks like everything is good.

  NOTES:

  OPEN ISSUES:
	1. Should we implement this function a more generic validation
	   routing.  For example, some one want to check a subinventory
	   is valid without item info, destination info, etc.

	2. No type 'MULTIPLE' should be passed in. If 'MULTIPLE', calling
	   procedure should get exactly destination type and then call
	   this function.

	3. Since enter receipts and enter receipt transactions can set
	   transaction date to be different than sysdate, a transaction
	   date is needed to compare with inventory's inactive date.
	   Need to check/discuss with other products' implementations.

  CLOSED ISSUES:

  CHANGE HISTORY:
	dropped parameters:
		x_po_subinventory, x_distribution_id, x_source_type,
		x_shipment_line_id
	added parameters:
		x_transaction_date - because sub inactive date is compared
		                     with the transaction date.
===========================================================================*/

FUNCTION val_subinventory
(
	x_subinventory   	IN VARCHAR2,
	x_organization_id	IN NUMBER,
	x_transaction_date	IN DATE,
	x_item_id		IN NUMBER,
	x_destination_type	IN VARCHAR2
)
RETURN	NUMBER;



/*===========================================================================
  FUNCTION NAME:	val_locator()

  DESCRIPTION:
	Verify if locator is needed based on locator control. To get locator
	control, use get_locator_control.
		1 - No locator control
		2 - Prespecified locator control
		3 - Dynamic entry locator control


  PARAMETERS:
	x_org_locator_control	IN NUMBER, (3)
	x_sub_locator_control	IN NUMBER, (3)
	x_item_locator_control	IN NUMBER, (3)
	x_transaction_date	IN DATE, (5)
	x_locator		IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory_id	IN NUMBER,
	x_organization_id	IN NUMBER


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:
	get locator control using get_locator_control

	if locator control = 1 (no locator control) then
	   return SUCCESS
	end if

	if x_locator = '' then
	   return FAIL
	end if

	case locator control
	   :if 2 (predefined locator control)
	      return inventory validate_locator (1)
	   :if 3 (dynamic entry locator control)
	      return inventory insert_locator (2)
	   :if others
	      return FAIL
	end case

  NOTES:
	A. Inventory has the locator key-flex api. use fnd key flex update
	definition to control key flex locator field in forms.

  OPEN ISSUES:
	1. Does inventory has a function/procedure check if a locator is in
	predefined locator?

	2. Does inventory has a function/procedure which insert a new locator
	into defined locator list?

	3. These parameters may be required in inventory functions/procedures
	described in issue 1 and 2.

	4. See CLOSED ISSUES.

	5. Again like val_subinventory, does inactive_date compare against
	sysdate or transaction_date which could differ from sysdata.

  CLOSED ISSUES:
	4. If get locator control returned no locator control at organization
	level, but mtl_system_item has restrict locator control set, which
	one takes precedance?

	-- get_locator_control should resolve this conflict. If an item has
	restrict locator control, then the item is under restrict locator
	control even organization, subinventory and item itself does not have
	locator control set.

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_locator
(
	x_locator		IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory    	IN VARCHAR2,
	x_organization_id	IN NUMBER
)
RETURN	NUMBER;

/*===========================================================================
  PROCEDURE NAME:	get_locator_control()

  DESCRIPTION:
	Get a locator control for an item under a subinventory, and a given
	organization.

	This function evaluate locator controls at all level in the order of
	organization, subinventory and item. Higher level has the precedence
	than lower level. For example, if locator control at organization
	level is set to no locator control, then no more checks needed at
	lower levels. (1)

		1 - No locator control
		2 - Prespecified locator control
		3 - Dynamic entry locator control
		4 - Locator control determined at subinventory level
		5 - Locator control determined at item level

  PARAMETERS:
	x_organization_id	IN NUMBER,
	x_subinventory	        IN VARCHAR2,
	x_item_id		IN NUMBER,
	x_locator		OUT NUMBER


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:
	get organization locator control. the organization locator control
	is defined in mtl_parameters by joining organization id.
	   select nvl(stock_locator_control_code, 1)
	   into   organization locator control
	   from   mtl_parameters
	   where  organization_id = current organization id

	if item has restrict locator control, return 2

	if organization locator control = 1 or 2 or 3 then
	   locator_control = organization locator control
	   end proc
	end if

	if organization locator control = 4 then
	   get subinventory locator control. the subinventory locator control
	   is defined in mtl_secondary_inventories.
	      select nvl(locator_type, 1)
	      into   subinventory locator control
	      from   mtl_secondary_inventories
	      where  organization_id = current organization id
	      and    secondary_inventory_name = current subinventory name

	   if subinventory locator control = 1 or 2 or 3 then
	      locator_control = organization locator control
	      end proc
	   end if

	   if subinventory locator control != 5 then
	      end proc w/ error
	   end if
	end if

	get item locator control. the item locator control is defined in
	mtl_system_items.
	   select nvl(msi.location_control_code, 1),
	   into   item_locator_control,
	   from   mtl_system_items msi,
	   where  msi.organization_id = organization_id
	   and    msi.inventory_item_id = transactions.item_id

	locator control = item locator control
	end proc.

  NOTES:

  OPEN ISSUES:
	1. See CLOSED ISSUES.

	2. Inventory has client side api LOCATOR.LOCATOR which takes
	org_control, sub_control, item_control, restrict_code, neg_inv_code,
	and trx_action-id. The problem with this is that you have to call
	those different controls first. Need to find out what values can be
	used for neg_inv_code, and trx_action_id.

  CLOSED ISSUES:
	1. If from org -> sub -> item, the locator control is 1. But the
	item has restrict locator control. Return which locator control?

	-- Always check item level restrict locator control, return 2 for
	predefined control if an item has restrict locator control.

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_locator_control
(
	x_organization_id	IN NUMBER,
	x_subinventory    	IN VARCHAR2,
	x_item_id		IN NUMBER,
	x_locator		IN OUT NOCOPY NUMBER,
	x_restrict_locator	IN OUT NOCOPY NUMBER
);

PROCEDURE get_locator_control
(
	x_organization_id	IN NUMBER,
	x_subinventory    	IN VARCHAR2,
	x_item_id		IN NUMBER,
	x_locator		IN OUT NOCOPY NUMBER
);

/*===========================================================================
  FUNCTION NAME:	get_default_subinventory()

  DESCRIPTION:
        Gets the default sub for a given item and org.  This is used in
        express and when you're starting up the form.

  PARAMETERS:
	x_organization_id	IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory   	IN VARCHAR2(10),

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
       GK  06/02/95   Created Function
===========================================================================*/

PROCEDURE get_default_subinventory
(
	x_organization_id	IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory   	IN OUT NOCOPY VARCHAR2
);

/*===========================================================================
  FUNCTION NAME:	get_default_locator()

  DESCRIPTION:
        Gets the default locator for a given item and org.  This is used in
        express and when you're starting up the form.

  PARAMETERS:
        x_organization_id	IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory   	IN VARCHAR2,
        x_locator_id            IN OUT NUMBER

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
       GK  06/02/95   Created Function
===========================================================================*/

PROCEDURE get_default_locator
(
	x_organization_id	IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory   	IN VARCHAR2,
        x_locator_id            IN OUT NOCOPY NUMBER
) ;


/*===========================================================================
  PROCEDURE NAME:	check_sub_transfer

  DESCRIPTION:		This procedure  checks to make sure that
			we do not allow transfer of ASSET items from
			an expense subinventory to an asset
			subinventory.




  PARAMETERS:		x_source_organization_id	IN   NUMBER
			x_destination_organization_id	IN   NUMBER
			x_destination_subinventory	IN   VARCHAR2
			x_item_id			IN   NUMBER
			x_allow_expense_source		OUT  VARCHAR2

  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:		- Get the asset_flag for the item in the
			  destination organization.
			- If the item is not an asset item, set
			  allow_expense_source to 'Y' and return.
			- Get the in_transit type for the orgs
			  involved in the transfer.
			- If in_transit, set allow_expense_source
			  to 'N' and return.
			- get the default destination subinventory
			  if not provided.
			- get the subinventory type for the
			  subinventory and destination org.
			- if the subinventory is an ASSET sub, set
			  allow_expense_source to 'N' else set
			  allow_expense_source to 'Y'.

  NOTES:

  OPEN ISSUES:


  CLOSED ISSUES:

  CHANGE HISTORY:	06/19		Ramana Y Mulpury
===========================================================================*/

PROCEDURE  check_sub_transfer (x_source_organization_id	     IN  NUMBER,
			      x_destination_organization_id  IN  NUMBER,
			      x_destination_subinventory     IN  NUMBER,
			      x_item_id			     IN  NUMBER,
			      x_allow_expense_source	     OUT NOCOPY VARCHAR2
			     );


PROCEDURE test_check_sub_transfer (x_source_organization_id  IN  NUMBER,
			      x_destination_organization_id  IN  NUMBER,
			      x_destination_subinventory     IN  NUMBER,
			      x_item_id			     IN  NUMBER);



/*===========================================================================
  FUNCTION NAME:	val_src_subinventory

  DESCRIPTION:		This procedure  validates the
			source subinventory based on the
			destination and item information.

			This function returns FALSE if the
			source subinventory is not valid.


  PARAMETERS:		x_src_sub			IN   VARCHAR2
			x_dest_org_id			IN   NUMBER
			x_dest_type			IN   VARCHAR2
			x_dest_org_id			IN   NUMBER
			x_dest_sub			IN   VARCHAR2
			x_item_id			IN   NUMBER


  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:		DEBUG: Need to review this with Kevin.


  CLOSED ISSUES:

  CHANGE HISTORY:	07/06		Ramana Y Mulpury
===========================================================================*/


FUNCTION val_src_subinventory (	x_src_sub	   	IN VARCHAR2,
				x_src_org_id		IN INTEGER,
				x_dest_type		IN VARCHAR2,
				x_dest_org_id		IN INTEGER,
				x_dest_sub		IN VARCHAR2,
				x_item_id		IN NUMBER
)
RETURN	BOOLEAN;



/*===========================================================================
  FUNCTION NAME:	val_locator_control()

  DESCRIPTION:
	See if org/sub/item is under locator control.  If it is then make
	sure that the locator is specified accordingly: If locator control
	is 2 which means it is under predefined locator contol or 3
	which means it's under dynamic (any value)
        locator control then you need to go get the default locator id

  PARAMETERS:
        X_to_organization_id     IN NUMBER
	X_item_id                IN NUMBER
	X_subinventory           IN VARCHAR2
	X_locator_id             IN NUMBER
	x_organization_id	 IN NUMBER

   RETURN:
	BOOLEAN  - Is the locator valid for the sub destination

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
       GK  06/02/95   Created Function
===========================================================================*/

FUNCTION val_locator_control (
X_to_organization_id     IN NUMBER,
X_item_id                IN NUMBER,
X_subinventory           IN VARCHAR2,
X_locator_id             IN NUMBER)
RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	get_subinventory_details

  DESCRIPTION:		Obtain asset_inventory information
		        for the subinventory.


			1 - asset subinventory
			2 - non asset subinventory

  PARAMETERS:		x_subinventory  	IN OUT VARCHAR2
		   	x_asset_inventory 	IN OUT NUMBER


  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:


  CLOSED ISSUES:

  CHANGE HISTORY:	10/30		Ramana Y Mulpury
===========================================================================*/

PROCEDURE  get_subinventory_details (x_subinventory	IN OUT NOCOPY VARCHAR2,
				     x_organization_id	IN OUT NOCOPY NUMBER,
				     x_asset_inventory  IN OUT NOCOPY NUMBER);



END PO_SUBINVENTORIES_S;

 

/
