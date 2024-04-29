--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_INV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_INV" AUTHID CURRENT_USER as
/* $Header: WSHDDICS.pls 120.4 2008/01/14 14:49:13 skanduku ship $ */

/*
-----------------------------------------------------------------------------
  RECORD TYPE  : line_inv_info
  DESCRIPTION  : This record type stores some of the delivery detail attributes
		 pertaining to the inventory controls. Used to pass the info
		 on the form to the details required API.
------------------------------------------------------------------------------
*/


  TYPE line_inv_info IS RECORD (
	delivery_detail_id WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
	inventory_item_id WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
	shp_qty	WSH_DELIVERY_DETAILS.shipped_quantity%TYPE,
	req_qty WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
	ser_qty NUMBER,
	revision WSH_DELIVERY_DETAILS.revision%TYPE,
	subinventory WSH_DELIVERY_DETAILS.subinventory%TYPE,
	lot_number WSH_DELIVERY_DETAILS.lot_number%TYPE,
	locator_id WSH_DELIVERY_DETAILS.locator_id%TYPE,
	locator_control_code NUMBER,
	serial_number WSH_DELIVERY_DETAILS.serial_number%TYPE,
	serial_number_control_code NUMBER,
	transaction_temp_id WSH_DELIVERY_DETAILS.transaction_temp_id%TYPE,
        organization_id WSH_DELIVERY_DETAILS.organization_id%TYPE,
        picked_quantity NUMBER,
        picked_quantity2 NUMBER,
        requested_quantity_uom WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE,
        requested_quantity_uom2 WSH_DELIVERY_DETAILS.requested_quantity_uom2%TYPE,
        source_line_id NUMBER,
        source_header_id NUMBER,
        source_code WSH_DELIVERY_DETAILS.source_code%TYPE,
        line_direction WSH_DELIVERY_DETAILS.source_code%TYPE);


  TYPE inv_control_flag_rec IS RECORD (
	rev_flag VARCHAR2(3),
	lot_flag VARCHAR2(3),
	sub_flag VARCHAR2(3),
	loc_flag VARCHAR2(3),
	ser_flag VARCHAR2(3),
	restrict_loc NUMBER,
	restrict_sub NUMBER,
	location_control_code NUMBER,
	serial_code NUMBER ,
	reservable_type NUMBER,
        details_required_flag VARCHAR2(1), -- Bug fix 2850555
	invalid_material_status_flag VARCHAR2(1), -- Added for Material Status Control Project
        transactable_flag VARCHAR2(1) -- Bug 3599363
        );

-- HW OPMCONV - Item attributes
TYPE mtl_system_items_rec IS RECORD
   ( primary_uom_code               mtl_system_items.primary_uom_code%TYPE
   , secondary_uom_code             mtl_system_items.secondary_uom_code%TYPE
   , secondary_default_ind          mtl_system_items.secondary_default_ind%TYPE
   , lot_control_code               mtl_system_items.lot_control_code%TYPE
   , tracking_quantity_ind          mtl_system_items.tracking_quantity_ind%TYPE
   , dual_uom_deviation_low         mtl_system_items.dual_uom_deviation_low%TYPE
   , dual_uom_deviation_high        mtl_system_items.dual_uom_deviation_high%TYPE
   , enabled_flag                   mtl_system_items.enabled_flag%TYPE
   , shippable_item_flag            mtl_system_items.shippable_item_flag%TYPE
   , inventory_item_flag            mtl_system_items.inventory_item_flag%TYPE
   , lot_divisible_flag             mtl_system_items.lot_divisible_flag%TYPE
   , lot_status_enabled             mtl_system_items.lot_status_enabled%TYPE
   --  bug 5264874 Added two new attributes
   , reservable_type                mtl_system_items.reservable_type%TYPE
   , mtl_transactions_enabled_flag  mtl_system_items.mtl_transactions_enabled_flag%TYPE
   , container_item_flag            mtl_system_items.container_item_flag%TYPE);

--  bug 5264874
TYPE mtl_org_param_rec IS RECORD
   ( stock_locator_control_code     mtl_parameters.stock_locator_control_code%type
   , negative_inv_receipt_code      mtl_parameters.negative_inv_receipt_code%type
   , serial_number_type             mtl_parameters.serial_number_type%type);

TYPE mtl_sec_inv_rec IS RECORD
   ( locator_type                   mtl_secondary_inventories.locator_type%type);

--  bug 5264874 end

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Fetch_Inv_Controls
   PARAMETERS : p_delivery_detail_id - delivery detail id.
		p_inventory_item_id - inventory_item_id on line for which
		inventory controls need to be determined.
		p_organization_id - organization_id to which inventory_item
		belongs.
		p_subinventory - subinventory to which the item belongs
		x_inv_controls_rec - output record of
		WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec type containing
		all inv control flags for the item and organization.
		x_return_status - return status of the API.
  DESCRIPTION : This procedure takes a delivery detail id or alternatively the
		inventory item id and organization id and determines whether
		the item is under any of the inventory controls. The API
		fetches the control codes/flags from mtl_system_items for the
		given inventory item and organization and decodes them and
		returns a record of inv controls with a 'Y' or a 'N' for each
		of the inv controls.

------------------------------------------------------------------------------
*/


PROCEDURE Fetch_Inv_Controls (
  p_delivery_detail_id IN NUMBER DEFAULT NULL,
  p_inventory_item_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  x_inv_controls_rec OUT NOCOPY  WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE   : Details_Required
   PARAMETERS : p_line_inv_rec - WSH_DELIVERY_DETAILS_INV.line_inv_info type
		that contains information about all the inventory control
		values on the form for the delivery detail id.
		p_set_default - boolean variable that indicates whether
		to retrieve the default values for controls if the
		attributes are missing.
		x_line_inv_rec - WSH_DELIVERY_DETAILS_INV.line_inv_info type
		containing default values in the case where set_default is TRUE
  DESCRIPTION : This procedure takes a WSH_DELIVERY_DETAILS_INV.line_inv_info
		type with inventory control attributes for the delivery detail
		id from the form and determines whether additional inventory
		control information needs to be entered or not. If additional
		control information is needed then the functions returns a
		TRUE or else it is returns FALSE.
		Alternatively, if the p_set_default value is set to TRUE, then
		it retrieves any default control attributes for the inventory
		item on the line and returns the information as x_line_inv_rec

------------------------------------------------------------------------------
*/


PROCEDURE Details_Required (
  p_line_inv_rec IN WSH_DELIVERY_DETAILS_INV.line_inv_info,
  p_set_default IN BOOLEAN DEFAULT FALSE,
  x_line_inv_rec OUT NOCOPY  WSH_DELIVERY_DETAILS_INV.line_inv_info,
  x_details_required OUT NOCOPY  BOOLEAN,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
  FUNCTION   : Sub_Loc_Ctl
  PARAMETERS : p_subinventory - subinventory
	       p_organization_id - organization_id of line
  DESCRIPTION : This API takes the subinventory and determines whether the
	 	subinventory is under locator control and returns the locator
		control code for the subinventory.
-----------------------------------------------------------------------------
*/

FUNCTION Sub_Loc_Ctl (
  p_subinventory IN VARCHAR2,
  p_organization_id IN NUMBER ) RETURN NUMBER;


/*
-----------------------------------------------------------------------------
  FUNCTION   : Get_Org_Loc
  PARAMETERS : p_organization_id - organization id of line
  DESCRIPTION : This API takes the organization determines whether the
	 	organization is under locator control and returns the locator
		control code for the organization.
-----------------------------------------------------------------------------
*/

FUNCTION Get_Org_Loc (
 p_organization_id IN NUMBER) RETURN NUMBER;


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Default_Subinventory
  PARAMETERS  : p_org_id - organization_id
 	        p_inv_item_id - inventory_item_id on the line
	        x_default_sub - default subinventory for the item/org
	        x_return_status - return status of the API
  DESCRIPTION : Get Default Sub for this item/org if it is defined else it
		returns null.
-----------------------------------------------------------------------------
*/

PROCEDURE Default_Subinventory (
  p_org_id IN NUMBER,
  p_inv_item_id IN NUMBER,
  x_default_sub OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2);



/*
-----------------------------------------------------------------------------
  FUNCTION    : DEFAULT_LOCATOR
  PARAMETERS  : p_organization_id - input org id
  		p_inv_item_id - input item_id
  		p_subinventory - input sub id
  		p_loc_restricted_flag - Y or N. If Y will ensure location is
		in predefined list
  		x_locator_id -  output default locator id.
		x_return_status - return status of API.
  DESCRIPTION : Retrieves default locator. If none exists then it returns null.
-----------------------------------------------------------------------------
*/


FUNCTION DEFAULT_LOCATOR
	(p_organization_id IN NUMBER,
	 p_inv_item_id IN NUMBER,
         p_subinventory IN VARCHAR2,
         p_loc_restricted_flag IN VARCHAR2) RETURN NUMBER;



/*
-----------------------------------------------------------------------------
  FUNCTION    : Locator_Ctl_Code
  PARAMETERS  : p_organization_id - input org id
		p_restrict_loc - restrict_locators_code
  		p_org_loc_code - loc control code for org
  		p_sub_loc_code - loc control code for sub
  		p_item_loc_code - loc control code for item
  DESCRIPTION : Determines the locator control code based on the three loc
		control codes and returns the governing loc control code.
-----------------------------------------------------------------------------
*/


FUNCTION Locator_Ctl_Code (
		p_org_id IN NUMBER,
		p_restrict_loc IN NUMBER,
		p_org_loc_code  IN NUMBER,
		p_sub_loc_code  IN NUMBER,
		p_item_loc_code IN NUMBER ) RETURN NUMBER;




/*
-----------------------------------------------------------------------------
  PROCEDURE   : Mark_Serial_Number
  PARAMETERS  : p_delivery_detail_id - delivery detail id or container id
		p_serial_number - serial number in case of single quantity
		p_transaction_temp_id - transaction temp id for multiple
		quantity of serial numbers.
	        x_return_status - return status of the API
  DESCRIPTION : Call Inventory's serial number mark API. Uses the delivery
		detail id as the group mark id, temp lot id and temp id to
		identify the serial numbers in mtl serial numbers. If the qty
		is greater than 1, then it uses the transaction temp id to
		fetch all the serial number ranges and then calls the mark API
		for each of the ranges.
-----------------------------------------------------------------------------
*/

PROCEDURE Mark_Serial_Number (
  p_delivery_detail_id IN NUMBER,
  p_serial_number IN VARCHAR2,
  p_transaction_temp_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Unmark_Serial_Number
  PARAMETERS  : p_delivery_detail_id - delivery detail id or container id
		p_serial_number_code - serial number code for the inventory
		item on the line.
		p_serial_number - serial number in case of single quantity
		p_transaction_temp_id - transaction temp id for multiple
		quantity of serial numbers.
	        x_return_status - return status of the API
	        p_inventory_item_id - inventory item
  DESCRIPTION : Call Inventory's serial number unmark API. Uses the serial
                number, inventory_item_id to identify the serial numbers in
		mtl serial numbers. If the qty is greater than 1,
                then it uses the transaction temp id to
		fetch all the serial number ranges and then calls the ummark
		API for each of the ranges.
-----------------------------------------------------------------------------
*/

PROCEDURE Unmark_Serial_Number (
  p_delivery_detail_id IN NUMBER,
  p_serial_number_code IN NUMBER,
  p_serial_number IN VARCHAR2,
  p_transaction_temp_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_inventory_item_id IN NUMBER DEFAULT NULL);


/*
-----------------------------------------------------------------------------

    Procedure	: validate_locator
    Parameters	: p_locator_id
                  p_inventory_item
   		  p_sub
		  p_transaction_type_id
                  p_object_type
    Description	: This function returns a boolean value to
                  indicate if the locator is valid in the context of inventory
                  and subinventory

-----------------------------------------------------------------------------
*/

PROCEDURE Validate_Locator(
  p_locator_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN
) ;


/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Revision
   Parameters	: p_revision
                  p_organization_id
  		  p_inventory_item_id
                  x_return_status
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
-----------------------------------------------------------------------------
*/

PROCEDURE Validate_Revision(
  p_revision IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN) ;


/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Subinventory
   Parameters	: p_subinventory
                  p_organization_id
  	  	  p_inventory_item_id
		  p_transaction_type_id
                  p_object_type
                  x_return_status
                  p_to_subinventory
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
                  p_to_subinventory is defaulted to NULL, if it is NULL
                  p_subinventory will be validated as from_subinventory.
                  Else, p_to_subinventory will be validated as to_subinvnetory.
-----------------------------------------------------------------------------
*/

PROCEDURE Validate_Subinventory(
  p_subinventory IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN,
  p_to_subinventory IN VARCHAR2 DEFAULT NULL
) ;


/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Lot_Number
   Parameters	: p_lot_number
                  p_organization_id
  		  p_inventory_item_id
                  p_subinventory
  		  p_revision
                  p_locator_id
 	          p_transaction_type_id
                  p_object_type
                  x_return_status
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
-----------------------------------------------------------------------------
*/


PROCEDURE Validate_Lot_Number(
  p_lot_number IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  p_revision IN VARCHAR2,
  p_locator_id IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN) ;

/*
-----------------------------------------------------------------------------

   Procedure	: Validate_Serial
   Parameters	: p_serial_number
                  p_lot_number
                  p_organization_id
  		  p_inventory_item_id
                  p_subinventory
  		  p_revision
                  p_locator_id
 	          p_transaction_type_id
                  p_object_type
                  x_return_status
   Description	: Validate item in context of organization_id
  		  Return TRUE if validate item successfully
  		  FALSE otherwise
-----------------------------------------------------------------------------
*/
PROCEDURE Validate_Serial(
  p_serial_number IN VARCHAR2,
  p_lot_number IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_subinventory IN VARCHAR2,
  p_revision IN VARCHAR2,
  p_locator_id IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_result OUT NOCOPY  BOOLEAN) ;



/*
-----------------------------------------------------------------------------
  PROCEDURE   : Update_Locator_Subinv
  PARAMETERS  : p_organization_id - organization id for the delivery detail
		p_locator_id - locator id for the delivery detail
		-1 if dynamic insert and 1 if pre-defined.
		p_subinventory - subinventory for the delivery detail
	        x_return_status - return status of the API
  DESCRIPTION : This procedure takes in the inventory location id (locator id),
		subinventory and org for the delivery detail and validates if
		the locator id exists for the given organization and location.
		If it can find it then it raises a duplicate locator exception,
		else it updates the mtl item locations table with the
		input subinventory for the given locator id and organization.
-----------------------------------------------------------------------------
*/

PROCEDURE Update_Locator_Subinv (
 p_organization_id IN NUMBER,
 p_locator_id IN NUMBER,
 p_subinventory IN VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
  FUNCTION    : Get_Serial_Qty
  PARAMETERS  : p_organization_id - organization id of line
	        p_delivery_detail_id - delivery detail id for the line
  DESCRIPTION :	This API takes the organization and delivery detail id for
		the line and calculates the serial quantity for the line
		based on the transaction temp id/serial number that is
		entered for the line. If the item is not under serial control
		then it returns a 0. If it is an invalid delivery detail id
		then it returns a -99.
-----------------------------------------------------------------------------
*/


FUNCTION Get_Serial_Qty (
 p_organization_id IN NUMBER,
 p_delivery_detail_id IN NUMBER) RETURN NUMBER;

/*FUNCTION get_reservable_flag
Checks if the item is reservable*/

FUNCTION get_reservable_flag(x_item_id         IN NUMBER,
                             x_organization_id IN NUMBER,
                             x_pickable_flag   IN VARCHAR2) RETURN
VARCHAR2;

/*
-----------------------------------------------------------------------------
  FUNCTION    : Line_Reserved
  PARAMETERS  : p_detail_id       - delivery_detail_id
                p_source_code     - source system code
                p_released_status - released status
                p_pickable_flag   - pickable flag
                p_organization_id - organization id of item
                p_inventory_item_id - item id
                x_return_status   - success if able to look up reservation status
                                    error if cannot look up
  DESCRIPTION :	This API takes the organization and inventory item
		and determines whether the lines item is reserved.
              It returns Y if it is reserved, N otherwise.
-----------------------------------------------------------------------------
*/

FUNCTION Line_Reserved(
             p_detail_id          IN  NUMBER,
             p_source_code        IN  VARCHAR2,
             p_released_status    IN  VARCHAR2,
             p_pickable_flag      IN  VARCHAR2,
             p_organization_id    IN  NUMBER,
             p_inventory_item_id  IN  NUMBER,
             x_return_status      OUT NOCOPY  VARCHAR2) RETURN VARCHAR2 ;

PROCEDURE Create_Dynamic_Serial(
        p_from_number IN VARCHAR2,
        p_to_number IN VARCHAR2,
        p_source_line_id IN NUMBER,
        p_delivery_detail_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_organization_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_lot_number IN VARCHAR2,
        p_subinventory IN VARCHAR2,
        p_locator_id IN NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2,
        p_serial_number_type_id in  NUMBER DEFAULT NULL,
        p_source_document_type_id  in NUMBER DEFAULT NULL);

/* I: Harmonization Project: kvenkate */
PROCEDURE Validate_Serial_Range(
  p_from_serial_number IN VARCHAR2,
  p_to_serial_number   IN VARCHAR2,
  p_lot_number         IN VARCHAR2,
  p_organization_id    IN NUMBER,
  p_inventory_item_id  IN NUMBER,
  p_subinventory       IN VARCHAR2,
  p_revision           IN VARCHAR2,
  p_locator_id         IN NUMBER,
  p_quantity           IN NUMBER,
  p_transaction_type_id IN NUMBER DEFAULT NULL,
  p_object_type         IN VARCHAR2 DEFAULT NULL,
  x_prefix             OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_result             OUT NOCOPY BOOLEAN) ;

/* I: Harmonization Project: kvenkate */
PROCEDURE Create_Dynamic_Serial_Range(
        p_from_number        IN VARCHAR2,
        p_to_number          IN VARCHAR2,
        p_source_line_id     IN NUMBER,
        p_delivery_detail_id IN NUMBER,
        p_inventory_item_id  IN NUMBER,
        p_organization_id    IN NUMBER,
        p_revision           IN VARCHAR2,
        p_lot_number         IN VARCHAR2,
        p_subinventory       IN VARCHAR2,
        p_locator_id         IN NUMBER,
        p_quantity           IN NUMBER,
	x_prefix             OUT NOCOPY VARCHAR2,
        x_return_status      OUT NOCOPY VARCHAR2);

PROCEDURE Check_Default_Catch_Weights(p_line_inv_rec IN WSH_DELIVERY_DETAILS_INV.line_inv_info,
                                      x_return_status   OUT NOCOPY VARCHAR2);

-- HW OPMCONV - New procedure to get item information
/*
-----------------------------------------------------------------------------
  PROCEDURE   : Get_item_information
  PARAMETERS  : p_organization_id       - organization id
                p_inventory_item_id     - source system code
                x_mtl_system_items_rec  - Record to hold item informatiom
                x_return_status   - success if able to look up item information
                                    error if cannot find item information

  DESCRIPTION :	This API takes the organization and inventory item
		and checks if item information is already cached, if
		not, it loads the new item information for a specific
		organization
-----------------------------------------------------------------------------
*/
PROCEDURE Get_item_information (
  p_organization_id        IN            NUMBER
, p_inventory_item_id      IN            NUMBER
, x_mtl_system_items_rec   OUT  NOCOPY   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec
, x_return_status          OUT  NOCOPY VARCHAR2
);


/*
-----------------------------------------------------------------------------
  PROCEDURE   : Update_Marked_Serial
  PARAMETERS  : p_from_serial_number - serial number to be marked with new
                transaction_temp_id
                p_to_serial_number - to serial number
                p_inventory_item_id - inventory item
                p_organization_id - organization_id
                p_transaction_temp_id - newly generated transaction temp id
                for serial number
                x_return_status - return status of the API
  DESCRIPTION : Call Inventory's update_marked_serial API which will take
                serial number and new transaction_temp_id as input and
                mark the serial number with the new transaction_temp_id
-----------------------------------------------------------------------------
*/
PROCEDURE Update_Marked_Serial (
  p_from_serial_number  IN      VARCHAR2,
  p_to_serial_number    IN      VARCHAR2 DEFAULT NULL,
  p_inventory_item_id   IN      NUMBER,
  p_organization_id     IN      NUMBER,
  p_transaction_temp_id IN      NUMBER,
  x_return_status OUT NOCOPY    VARCHAR2);

/*
-----------------------------------------------------------------------------
  PROCEDURE   : get_trx_type_id
  PARAMETERS  : p_source_line_id - Order Line Id
                p_source_code - Source Code ('OE','OKE', etc.)
                x_transaction_type_id - Transaction type id based on the
                                        Line id and the Source System
                x_return_status - return status of the API
  DESCRIPTION : Determines the transaction type id based on the Line id and
                the Source System
-----------------------------------------------------------------------------
*/

PROCEDURE get_trx_type_id(
  p_source_line_id IN NUMBER,
  p_source_code IN VARCHAR2,
  x_transaction_type_id OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2 );

END WSH_DELIVERY_DETAILS_INV;

/
