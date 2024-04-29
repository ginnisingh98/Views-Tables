--------------------------------------------------------
--  DDL for Package INV_LOC_WMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOC_WMS_PUB" AUTHID CURRENT_USER AS
/* $Header: INVLOCPS.pls 120.2.12000000.1 2007/01/17 16:19:55 appldev ship $*/
/*#
 * The Locator Maintenance procedures allow users to create, update and delete
 * stock locators in an inventory organization.  Users can also use these procedures
 * to assign an item to a locator as required.
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Locator Maintenance API
 * @rep:category BUSINESS_ENTITY INV_ORGANIZATION_SETUP
 */

/*
** ---------------------------------------------------------------------------
** procedure	: create_locator
** description	: this procedure creates a new locator in a given organization
**
** i/p 		:
** p_organization_id
**	identifier of organization in which locator is to
**	be created.
** p_organization_code
**	organization code of organziation in which locator
**	is to be created. Either p_organization_id or
**	p_organziation_code MUST be passed
** p_concatenated_segments
**	concatenated segment string with separator
**	of the locator to be created. Eg:A.1.1
** p_description
**	locator description
** p_inventory_location_type
**	type of locator.
**	dock door(1) or staging lane(2) or storage locator(3)
** p_picking_order
**	number that identifies relative position of locator
**      for  travel optimization during picking and task dispatching.
**      It has a a higher precedence over x,y,z coordinates.
** p_location_maximum_units
**	Maxmimum units the locator can hold
** p_subinventory_code
**	Subinventory to which locator belongs
** p_location_weight_uom_code
**	UOM of locator's max weight capacity
** p_max_weight
**	Max weight locator can hold
** p_volume_uom_code
**	UOM of locator's max volume capacity
** p_max_cubic_area
**	Max volume capacity of the locator
** p_x_coordinate
**	X-position of the locator in space. Used
**      for  travel optimization during picking and task dispatching.
** p_y_coordinate
**	Y-position of the locator in space. Used
**      for  travel optimization during picking and task dispatching.
** p_z_coordinate
**	Z-position of the locator in space. Used
**      for  travel optimization during picking and task dispatching.
** p_physical_location_id
**      locators that are the same physically have the same
**	inventory_location_id in this column
** p_pick_uom_code
**	UOM in which material is picked from locator
** p_dimension_uom_code
**	UOM in which locator dimensions are expressed
** p_length
**	Length of the locator
** p_width
**	Width of the locator
** p_height
**	Height of the locator
** p_status_id
**	Material Status that needs to be associated to locator
** p_dropping_order
**      For ordering drop-off locators and also to order by putaway
**      drop-off operations (bug 2681871)
**
** o/p:
** x_return_status
** 	return status indicating success, error, unexpected error
** x_msg_count
** 	number of messages in message list
** x_msg_data
** 	if the number of messages in message list is 1, contains
**     	message text
** x_inventory_location_id
**	identifier of newly created locator or existing locator
** x_locator_exists
**	Y - locator exists for given input
**      N - locator created for given input
**
** ---------------------------------------------------------------------------
*/
/*#
 * Use this procedure to create a new locator in an organization.
 * For given organization and the concatenated locator segments provided, this
 * procedure creates a
 * new locator in the organization and returns the locator identifier. If a
 * locator already exists with the same concatenated segments, the procedure
 * returns the locator identifier.
 * @param x_return_status Return status indicating success or failure
 * @paraminfo {@rep:required}
 * @param x_msg_count Returns the number of messages in message list
 * @paraminfo {@rep:required}
 * @param x_msg_data Returns the message text if the number of messages in message list is one
 * @paraminfo {@rep:required}
 * @param x_inventory_location_id Identifier of newly created locator or existing locator
 * @paraminfo {@rep:required}
 * @param x_locator_exists Returns 'Y' if the locator exists for the given input and 'N' if a new locator is created for given input
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization Id in which locator is to be created, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_code Organization code in which locator is to be created, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_concatenated_segments Concatenated segment string (with separator) of the locator to be created is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_description Locator description is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_location_type Type of locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_picking_order Number that identifies relative position of locator for travel optimization during task dipatching is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_location_maximum_units Maximum units the locator can hold is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_subinventory_code Sub inventory to which locator belongs is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_location_weight_uom_code UOM of locator's maximum weight capacity is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_max_weight Maximum weight the locator can hold is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_volume_uom_code UOM of locator's max volume capacity is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_max_cubic_area Max volume capacity of the locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_x_coordinate X-position of the locator in space is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_y_coordinate Y-position of the locator in space is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_z_coordinate Z-position of the locator in space is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_physical_location_id Locators that are the same physically have the same inventory_location_id passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_pick_uom_code UOM in which material is picked from locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_dimension_uom_code UOM in which locator dimensions are expressed is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_length Length of the locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_width Width of the locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_height Height of the locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_status_id Material Status that needs to be associated to locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_dropping_order Number that identifies relative position of locator for consolidation and put away drop-off operations is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_attribute_category Holds the Context of the Descriptive FlexField for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute1 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute2 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute3 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute4 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute5 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute6 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute7 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute8 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute9 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute10 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute11 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute12 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute13 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute14 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute15 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Locator
 */
PROCEDURE CREATE_LOCATOR (x_return_status		  OUT NOCOPY VARCHAR2,
			    x_msg_count 		  OUT NOCOPY NUMBER,
			    x_msg_data			  OUT NOCOPY VARCHAR2,
			    x_inventory_location_id 	  OUT NOCOPY NUMBER,
			    x_locator_exists		  OUT NOCOPY VARCHAR2,
			    p_organization_id             IN NUMBER ,
                            p_organization_code           IN VARCHAR2,
			    p_concatenated_segments       IN VARCHAR2,
                            p_description                 IN VARCHAR2,
			    p_inventory_location_type     IN NUMBER ,
                            p_picking_order               IN NUMBER ,
                            p_location_maximum_units      IN NUMBER ,
			    p_SUBINVENTORY_CODE           IN VARCHAR2,
			    p_LOCATION_WEIGHT_UOM_CODE    IN VARCHAR2,
			    p_mAX_WEIGHT                  IN NUMBER,
 			    p_vOLUME_UOM_CODE             IN VARCHAR2,
 			    p_mAX_CUBIC_AREA              IN NUMBER,
			    p_x_COORDINATE                IN NUMBER,
 			    p_Y_COORDINATE                IN NUMBER,
 			    p_Z_COORDINATE                IN NUMBER,
		   	    p_PHYSICAL_LOCATION_ID        IN NUMBER,
 			    p_PICK_UOM_CODE               IN VARCHAR2,
			    p_DIMENSION_UOM_CODE          IN VARCHAR2,
 			    p_LENGTH                      IN NUMBER,
 			    p_WIDTH                       IN NUMBER,
			    p_HEIGHT                      IN NUMBER,
 			    p_STATUS_ID                   IN NUMBER,
			    p_dropping_order              IN NUMBER,
             p_attribute_category          IN VARCHAR2 DEFAULT NULL,
             p_attribute1               IN    VARCHAR2 DEFAULT NULL
  , p_attribute2               IN            VARCHAR2 DEFAULT NULL
  , p_attribute3               IN            VARCHAR2 DEFAULT NULL
  , p_attribute4               IN            VARCHAR2 DEFAULT NULL
  , p_attribute5               IN            VARCHAR2 DEFAULT NULL
  , p_attribute6               IN            VARCHAR2 DEFAULT NULL
  , p_attribute7               IN            VARCHAR2 DEFAULT NULL
  , p_attribute8               IN            VARCHAR2 DEFAULT NULL
  , p_attribute9               IN            VARCHAR2 DEFAULT NULL
  , p_attribute10              IN            VARCHAR2 DEFAULT NULL
  , p_attribute11              IN            VARCHAR2 DEFAULT NULL
  , p_attribute12              IN            VARCHAR2 DEFAULT NULL
  , p_attribute13              IN            VARCHAR2 DEFAULT NULL
  , p_attribute14              IN            VARCHAR2 DEFAULT NULL
  , p_attribute15              IN            VARCHAR2 DEFAULT NULL
  , p_alias                    IN            VARCHAR2 DEFAULT NULL
			  ) ;

/*
** ---------------------------------------------------------------------------
** procedure    : update_locator
** description  : this procedure updates an existing locator
**
** i/p          :
** NOTE:
**	if the default value of the input parameter is used, then
**	that column retains its original value and is not changed
**	during update.
**      this can be achieved by not passing this parameter during the
**	API call.
**
** p_organization_id
**      identifier of organization in which locator is to
**      be updated.
** p_organization_code
**      organization code of organziation in which locator
**      is to be updated. Either p_organization_id or
**      p_organziation_code MUST be passed
** p_inventory_location_id
**	identifier of locator to be updated
** p_concatenated_segments
**      concatenated segment string with separator
**      of the locator to be updated. Eg:A.1.1
**	either p_inventory_location_id or p_concatenated_segments
**	MUST be passed.
** p_description
**      locator description
** p_inventory_location_type
**      type of locator.
**      dock door(1) or staging lane(2) or storage locator(3)
** p_picking_order
**      number that identifies physical position of locator
**      for  travel optimization during picking and task dispatching.
**      It has a a higher precedence over x,y,z coordinates.
** p_location_maximum_units
**      Maxmimum units the locator can hold
** p_subinventory_code
**      Subinventory to which locator belongs
** p_location_weight_uom_code
**      UOM of locator's max weight capacity
** p_max_weight
**      Max weight locator can hold
** p_volume_uom_code
**      UOM of locator's max volume capacity
** p_max_cubic_area
**      Max volume capacity of the locator
** p_x_coordinate
**      X-position of the locator in space. Used
**      for  travel optimization during picking and task dispatching.
** p_y_coordinate
**      Y-position of the locator in space. Used
**      for  travel optimization during picking and task dispatching.
** p_z_coordinate
**      Z-position of the locator in space. Used
**      for  travel optimization during picking and task dispatching.
** p_physical_location_id
**      locators that are the same physically have the same
**      inventory_location_id in this column
** p_pick_uom_code
**      UOM in which material is picked from locator
** p_dimension_uom_code
**      UOM in which locator dimensions are expressed
** p_length
**      Length of the locator
** p_width
**      Width of the locator
** p_height
**      Height of the locator
** p_status_id
**      Material Status that needs to be associated to locator
** p_dropping_order
**      For ordering drop-off locators and also to order by putaway
**      drop-off operations (bug 2681871)
**
** o/p:
** x_return_status
**      return status indicating success, error, unexpected error
** x_msg_count
**      number of messages in message list
** x_msg_data
**      if the number of messages in message list is 1, contains
**      message text
**
** ---------------------------------------------------------------------------
*/
/*#
 * Use this procedure to update an existing locator in an organization.
 * This procedure updates an existing locator with the information provided as input
 * parameters. If the default value is passed, the corresponding locator column will
 * retain its original value.
 * @param x_return_status Return status indicating success or failure
 * @paraminfo {@rep:required}
 * @param x_msg_count Returns the number of messages in message list
 * @paraminfo {@rep:required}
 * @param x_msg_data Returns the message text if the number of messages in message list is one
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization Id in which locator exists, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_code Organization code in which locator exists, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_location_id Identifier of locator to be updated is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_concatenated_segments Concatenated segment string (with separator) of the locator to be updated is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_description Locator description is passed as input in this variable
 * @param p_disabled_date Date on which the locator would be disabled is paused as input in this variable
 * @param p_inventory_location_type Type of locator is passed as input in this variable
 * @param p_picking_order Number that identifies relative position of locator for travel optimization during task dipatching is passed as input in this variable
 * @param p_location_maximum_units Maximum units the locator can hold is passed as input in this variable
 * @param p_location_weight_uom_code UOM of locator's maximum weight capacity is passed as input in this variable
 * @param p_max_weight Maximum weight the locator can hold is passed as input in this variable
 * @param p_volume_uom_code UOM of locator's max volume capacity is passed as input in this variable
 * @param p_max_cubic_area Max volume capacity of the locator is passed as input in this variable
 * @param p_x_coordinate X-position of the locator in space is passed as input in this variable
 * @param p_y_coordinate Y-position of the locator in space is passed as input in this variable
 * @param p_z_coordinate Z-position of the locator in space is passed as input in this variable
 * @param p_physical_location_id Locators that are the same physically have the same inventory_location_id passed as input in this variable
 * @param p_pick_uom_code UOM in which material is picked from locator is passed as input in this variable
 * @param p_dimension_uom_code UOM in which locator dimensions are expressed is passed as input in this variable
 * @param p_length Length of the locator is passed as input in this variable
 * @param p_width Width of the locator is passed as input in this variable
 * @param p_height Height of the locator is passed as input in this variable
 * @param p_status_id Material Status that needs to be associated to locator is passed as input in this variable
 * @param p_dropping_order Number that identifies relative position of locator for consolidation and put away drop-off operations is passed as input in this variable* @rep:scope public
 ** For the DFF attributes mentioned below, to update correctly use the following strategy
 **     To retain the value in the table, do not pass any value OR pass NULL as i/p
 **     To update the attribute with NULL, pass fnd_api.g_miss_char
 **     To update with any other value, pass the appropriate value
 * @param p_attribute_category Holds the Context of the Descriptive FlexField for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute1 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute2 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute3 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute4 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute5 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute6 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute7 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute8 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute9 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute10 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute11 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute12 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute13 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute14 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @param p_attribute15 Holds the Descriptive FlexField attribute for the Locator
 * @paraminfo {@rep:Not Mandatory}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Locator
 */
PROCEDURE UPDATE_LOCATOR (x_return_status               OUT NOCOPY VARCHAR2,
		    	  x_msg_count 		        OUT NOCOPY NUMBER,
			  x_msg_data			OUT NOCOPY VARCHAR2,
		          p_organization_id             IN NUMBER ,
                          p_organization_code 	        IN VARCHAR2,
                          p_inventory_location_id 	IN NUMBER,
                          p_concatenated_segments 	IN VARCHAR2,
                          p_description 		IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                          p_disabled_date 		IN DATE DEFAULT FND_API.G_MISS_DATE,
                          p_inventory_location_type 	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_picking_order 		IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_location_maximum_units 	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_location_Weight_uom_code    IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                          p_max_weight 		        IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_volume_uom_code 		IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                          p_max_cubic_area 		IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_x_coordinate 		IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_y_coordinate		IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_z_coordinate 		IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_physical_location_id 	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_pick_uom_code 		IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                          p_dimension_uom_code 	        IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                          p_length 			IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_width 			IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_height 			IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_status_id 		        IN NUMBER DEFAULT FND_API.G_MISS_NUM,
			                 p_dropping_order        IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                          p_attribute_category    IN VARCHAR2 DEFAULT NULL,
                          p_attribute1               IN  VARCHAR2 DEFAULT NULL
  , p_attribute2               IN            VARCHAR2 DEFAULT NULL
  , p_attribute3               IN            VARCHAR2 DEFAULT NULL
  , p_attribute4               IN            VARCHAR2 DEFAULT NULL
  , p_attribute5               IN            VARCHAR2 DEFAULT NULL
  , p_attribute6               IN            VARCHAR2 DEFAULT NULL
  , p_attribute7               IN            VARCHAR2 DEFAULT NULL
  , p_attribute8               IN            VARCHAR2 DEFAULT NULL
  , p_attribute9               IN            VARCHAR2 DEFAULT NULL
  , p_attribute10              IN            VARCHAR2 DEFAULT NULL
  , p_attribute11              IN            VARCHAR2 DEFAULT NULL
  , p_attribute12              IN            VARCHAR2 DEFAULT NULL
  , p_attribute13              IN            VARCHAR2 DEFAULT NULL
  , p_attribute14              IN            VARCHAR2 DEFAULT NULL
  , p_attribute15              IN            VARCHAR2 DEFAULT NULL
  , p_alias                    IN            VARCHAR2 DEFAULT NULL
		         );
/*
** ---------------------------------------------------------------------------
** procedure    : create_loc_item_tie
** description  : For a given set of organization, subinventory, item and
**                locator, this API ties the given item to the given locator.
** i/p          :

** p_inventory_item_id
**    Identifier of item .
** p_item
**     Concatenated segment string with separator of the item.
**     Either P_inventory_item_id or the p_item MUST be passed
** p_organization_id
**     Identifier of organization
** p_organization_code
**     Organization code of organziation in which locator is to
**     be updated. Either p_organization_id  or p_organziation_code
**     MUST be passed
** p_subinventory_code
**     The subinventory to which the locator need to be attached to .
** p_inventory_location_id
**     Identifier of locator to be attached to the specified subinventory
** p_locator
**     Concatenated segment string with separator of the locator to be
**     updated. Eg:A.1.1 either p_inventory_location_id or
**     p_concatenated_segments MUST be passed.
** p_status_id
**     Identifier of status
** p_par_level Indicates the the maximum quantity
**
** o/p:
**
** x_return_status
**      return status indicating success, error, unexpected error
** x_msg_count
**      number of messages in message list
** x_msg_data
**      if the number of messages in message list is 1, contains
**      message text
**
** ---------------------------------------------------------------------------
*/
/*#
 * Use this procedure to assign an item to a locator in an organization.
 * For a given organization, subinventory, item and locator, this procedure ties
 * the item to the locator.
 * @param x_return_status Return status indicating success or failure
 * @paraminfo {@rep:required}
 * @param x_msg_count Returns the number of messages in message list
 * @paraminfo {@rep:required}
 * @param x_msg_data Returns the message text if the number of messages in message list is one
 * @paraminfo {@rep:required}
 * @param p_inventory_item_id  Identifier of the item that is to be tied to a locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_item Concatenated segment string (with separator) of the item to be tied to a locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization Id in which the item and locator exist, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_code Organization code in which the item and locator exist, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_subinventory_code Sub inventory to which locator belongs is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_inventory_location_id Identifier of locator to be attached to the specified item is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_locator Concatenated segment string (with separator) of the locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_status_id Material Status of the locator is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_par_level PAR level for the Item-Locator is passed as input in this variable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Item-Locator Tie
 */
PROCEDURE CREATE_LOC_ITEM_TIE( x_return_status              OUT NOCOPY VARCHAR2,
                               x_msg_count                  OUT NOCOPY NUMBER,
                               x_msg_data                   OUT NOCOPY VARCHAR2,
                               p_inventory_item_id          IN NUMBER,
                               p_item                       IN VARCHAR2,
                               p_organization_id            IN NUMBER,
                               p_organization_code          IN VARCHAR2,
                               p_subinventory_code          IN VARCHAR2,
                               p_inventory_location_id      IN NUMBER,
                               p_locator                    IN VARCHAR2,
                               p_status_id                  IN NUMBER,
                               p_par_level                  IN NUMBER DEFAULT NULL
                              );
/*
**-----------------------------------------------------------------------------------
**
** procedure   : delete_locator
** description : this procedure deletes a locator in a given organization.
** i/p         :
** p_inventory_location_id
**     identifier of locator to be deleted
** p_concatenated_segments
**     concatenated segment string with separator of the locator to be deleted. Eg:A.1.1
** p_organization_id
**     identifier of organization in which locator is to be deleted.
** p_organization_code
**     organization code of organziation in which locator is to be deleted.
**     Either  p_organization_id  or   p_organziation_code MUST be passed

** p_validation_req_flag
**     the flag which determines whether validation is required or not.
**     If it is 'N',the locator is deleted without any further validation
**     on its existence  in other tables.If it is'Y', the locator is deleted
**     only if doesnot exist in other tables.
**
** o/p
** x_return_status
**     return status indicating success, error, unexpected error
** x_msg_count
**     number of messages in message list
** x_msg_data		:
**     if the number of messages in message list is 1,
**     contains message text x_inventory_location_id
**
**-----------------------------------------------------------------------------------
*/
/*#
 * Use this procedure to delete an existing locator in an organization.
 * For a given organization and locator, this procedure deletes the existing locator after ensuring that
 * the locator is obsolete and does not exist in any core Inventory tables (i.e.
 * it has no on hand balances or pending material transactions).
 * @param x_return_status Return status indicating success or failure
 * @paraminfo {@rep:required}
 * @param x_msg_count Returns the number of messages in message list
 * @paraminfo {@rep:required}
 * @param x_msg_data Returns the message text if the number of messages in message list is one
 * @paraminfo {@rep:required}
 * @param p_inventory_location_id Identifier of locator to be deleted is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_concatenated_segments Concatenated segment string (with separator) of the locator to be deleted is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_id Organization Id in which the locator exists, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_organization_code Organization code in which the locator exists, is passed as input in this variable
 * @paraminfo {@rep:required}
 * @param p_validation_req_flag The flag that determines whether validation is required or not is passed as input in this variable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Locator
 */
PROCEDURE DELETE_LOCATOR
 ( x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   p_inventory_location_id     IN  NUMBER,
   p_concatenated_segments     IN  VARCHAR2,
   p_organization_id           IN  NUMBER,
   p_organization_code         IN  VARCHAR2,
   p_validation_req_flag       IN  VARCHAR2 DEFAULT 'Y'
 );
END inv_loc_wms_pub;


 

/
