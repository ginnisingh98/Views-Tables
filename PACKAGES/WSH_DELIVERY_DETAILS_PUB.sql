--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_PUB" AUTHID CURRENT_USER AS
/* $Header: WSHDDPBS.pls 120.1 2005/07/14 02:37:15 sgumaste noship $ */
/*#
 * This is the public interface for the Delivery Line entity. It allows
 * execution of various Delivery Line functions, including creation, update
 * of delivery lines and other actions.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Delivery Line
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_DELIVERY_LINE
 */


-- ---------------------------------------------------------------------------------------------------------
-- Procedure: delivery_detail_to_delivery
--
-- Parameters:    1) table of delivery_detail_ids
--        2) action: assign/unassign
--        3) delivery_id: need to specify delivery id or delivery nameif the action is 'ASSIGN'
--        4) delivery_name: need to specify delivery id or delivery name if the action is 'ASSIGN'
--        5) other standard parameters
--
-- Description: This procedure assign/unassign delivery_details to a delivery
--
-- History:
--          06-OCT-00 Changed container_name width from 50 to 30 for meeting wms requirements/changes
-- ---------------------------------------------------------------------------------------------------------

TYPE ID_TAB_TYPE IS table of number INDEX BY BINARY_INTEGER;

/*#
 * Procedure to assign/unassign delivery lines to a delivery.
 * Multiple delivery lines can be assigned to or unassigned from a delivery
 * with a single procedure call by passing in the required parameters.
 * @param p_api_version         version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param p_validation_level    validation level will be set as none if set as 0
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_TabOfDelDets        table of the delivery line IDs
 * @param p_action              action to be performed, it should be 'ASSIGN' or 'UNASSIGN'
 * @param p_delivery_id         ID of the delivery to be assigned to. If the action is 'ASSIGN', you need to specify either p_delivery_id or p_delivery_name
 * @param p_delivery_name       name of the delivery to be assigned to. If the action is 'ASSIGN', you need to specify either p_delivery_id or p_delivery_name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign/Unassign Delivery Lines
 */

PROCEDURE detail_to_delivery(
  -- Standard parameters
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit             IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level   IN   NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,

  -- program specific parameters
  p_TabOfDelDets    IN    ID_TAB_TYPE,
  p_action      IN    VARCHAR2,
  p_delivery_id   IN    NUMBER DEFAULT FND_API.G_MISS_NUM,
  p_delivery_name IN    VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
);


-- ----------------------------------------------------------------------
-- Procedure:    split_line
-- Parameters:     p_from_detail_id: The delivery detail ID to be split
--                x_new_detail_id:  The new delivery detail ID x_split_quantity:  The split quantity
--
-- Description:   This procedure splits a delivery_deatil line
--
--  ----------------------------------------------------------------------

/*#
 * Procedure to split quantity of a delivery line.
 * @param p_api_version         version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param p_validation_level    validation level will be set as none if set as 0
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_from_detail_id      delivery detail ID to be split
 * @param x_new_detail_id       output parameter to hold the new delivery line ID
 * @param x_split_quantity      primary quantity to split
 * @param x_split_quantity2     secondary quantity to split
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Split Delivery Line
 */
PROCEDURE split_line(
  -- Standard parameters
  p_api_version   IN    NUMBER,
  p_init_msg_list     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit            IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level  IN    NUMBER  DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count   OUT NOCOPY    NUMBER,
  x_msg_data    OUT NOCOPY    VARCHAR2,

  -- program specific parameters
  p_from_detail_id  IN    NUMBER,
  x_new_detail_id OUT NOCOPY    NUMBER,
  x_split_quantity  IN  OUT NOCOPY  NUMBER,
  x_split_quantity2 IN  OUT NOCOPY  NUMBER  /* added for OPM */
);


--bug 1747202: default these attributes so they won't be updated.
TYPE ChangedAttributeRecType IS RECORD (
  source_header_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  source_line_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  sold_to_org_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  customer_number           NUMBER    DEFAULT FND_API.G_MISS_NUM,
  sold_to_contact_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_from_org_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_from_org_code    VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ship_to_org_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_to_org_code    VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ship_to_contact_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  deliver_to_org_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  deliver_to_org_code   VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  deliver_to_contact_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  intmed_ship_to_org_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  intmed_ship_to_org_code   VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  intmed_ship_to_contact_id NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_tolerance_above    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_tolerance_below    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ordered_quantity    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ordered_quantity2   NUMBER    DEFAULT FND_API.G_MISS_NUM, /* added for OPM*/
  order_quantity_uom    VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ordered_quantity_uom2   VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR, /* added for OPM*/
-- HW OPMCONV -changed size of grade to 150
  preferred_grade     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR, /* added for OPM */
  ordered_qty_unit_of_measure   VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR,
  ordered_qty_unit_of_measure2  VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR, /* added for OPM*/
  subinventory      VARCHAR2(10)  DEFAULT FND_API.G_MISS_CHAR,
  revision      VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
-- HW OPMCONV - Increase the size of lot_number
  lot_number      VARCHAR2(80)  DEFAULT FND_API.G_MISS_CHAR,
-- HW OPMCONV - No need for sublot_number
--sublot_number     VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  customer_requested_lot_flag VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  serial_number     VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  locator_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  date_requested      DATE    DEFAULT FND_API.G_MISS_DATE,
  date_scheduled      DATE    DEFAULT FND_API.G_MISS_DATE,
  master_container_item_id  NUMBER    DEFAULT FND_API.G_MISS_NUM,
  detail_container_item_id  NUMBER    DEFAULT FND_API.G_MISS_NUM,
  shipping_method_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  carrier_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  freight_terms_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  freight_terms_name    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  freight_carrier_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  shipment_priority_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  fob_code      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  fob_name      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  dep_plan_required_flag    VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  customer_prod_seq   VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  customer_dock_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  gross_weight      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  net_weight      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  weight_uom_code     VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  weight_uom_desc     VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  volume        NUMBER    DEFAULT FND_API.G_MISS_NUM,
  volume_uom_code     VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  volume_uom_desc     VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  top_model_line_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_set_id     NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ato_line_id     NUMBER    DEFAULT FND_API.G_MISS_NUM,
  arrival_set_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_model_complete_flag  VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  cust_po_number      VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  released_status     VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  packing_instructions    VARCHAR2(2000)  DEFAULT FND_API.G_MISS_CHAR,
  shipping_instructions   VARCHAR2(2000)  DEFAULT FND_API.G_MISS_CHAR,
  container_name      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  container_flag      VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  delivery_detail_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  shipped_quantity                NUMBER    DEFAULT FND_API.G_MISS_NUM,
  cycle_count_quantity            NUMBER    DEFAULT FND_API.G_MISS_NUM,
  shipped_quantity2               NUMBER          DEFAULT FND_API.G_MISS_NUM, /* Bug 3055126  */
  cycle_count_quantity2           NUMBER          DEFAULT FND_API.G_MISS_NUM, /* Bug 3055126  */
  tracking_number                 VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  attribute_category              VARCHAR2(150)   DEFAULT FND_API.G_MISS_CHAR, /* Bug 3105907 */
  attribute1      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute2      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute3      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute4      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute5      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute6      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute7      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute8      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute9      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute10     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute11     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute12     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute13     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute14     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute15     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  to_serial_number                VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  -- Bug 3723831 :tp attributes also part of the public API update_shipping_attributes
  tp_attribute_category              VARCHAR2(150)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute1      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute2      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute3      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute4      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute5      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute6      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute7      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute8      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute9      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute10     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute11     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute12     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute13     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute14     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute15     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  -- J: W/V Changes
  filled_volume NUMBER    DEFAULT FND_API.G_MISS_NUM,
  -- Bug 4146352 : Added seal_code and load_seq_number
  seal_code       VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  load_seq_number NUMBER        DEFAULT FND_API.G_MISS_NUM
  );

TYPE ChangedAttributeTabType IS TABLE OF ChangedAttributeRecType
  INDEX BY BINARY_INTEGER;




--===================
-- PROCEDURES
--===================

-- Procedure Init_Changed_Attribute_Rec
-- Parameter p_init_rec record that needs to be initialized.
-- This procedure takes in a record of ChangedAttributeRecType and
-- initializes its attributes to the default FND_API_G values.

/*#
 * This procedure takes in a record of ChangedAttributeRecType and
 * initializes its attributes to the default FND_API_G values.
 * Usually, it is called before Update_Shipping_Attributes
 * to make sure the default value are set properly.
 * @param p_init_rec        record of ChangedAttributeRecType with the delivery line attibutes to be changed
 * @param x_return_status   return status of the API
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initiate Delivery Line Changed Attributes
 */
Procedure Init_Changed_Attribute_Rec(p_init_rec IN OUT NOCOPY  WSH_DELIVERY_DETAILS_PUB.ChangedAttributeRecType,
                                     x_return_status OUT NOCOPY  VARCHAR2);


--========================================================================
-- PROCEDURE : Update_Shipping_Attributes
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--            p_changed_attributes    changed attributes for delivery details
--             p_source_code           source system
--
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--========================================================================

/*#
 * Procedure to change the attributes of multiple delivery lines.
 * @param p_api_version_number  version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_changed_attributes  table of ChangedAttributeRecType to hold the changed delivery line attributes
 * @param p_source_code         source system of the delivery lines
 * @param p_container_flag      obselete optional field, you do not need to pass value for this field
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Shipping Attributes
 */
PROCEDURE Update_Shipping_Attributes (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_changed_attributes    IN     WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType
, p_source_code            IN     VARCHAR2
, p_container_flag         IN     VARCHAR2 DEFAULT NULL
);

--========================================================================
-- PROCEDURE : Update_Shipping_Attributes (overloaded)
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_changed_attributes    changed attributes for delivery details
--             p_source_code           source system
--             p_serial_range_tab      serial range table
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--
--DESCRIPTION: This overloaded version of Update_Shipping_Attributes is created
--             to  enable entry of multiple serial ranges for a given delivery
--             detail
--
--CREATED:     During patchset I
--========================================================================

/*#
 * This overloaded version of Update_Shipping_Attributes is
 * to  enable entry of multiple serial ranges for a given delivery
 * detail
 * @param p_api_version_number         version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_changed_attributes  table of the changed delivery line attributes
 * @param p_source_code         source system of the delivery lines
 * @param p_container_flag      obselete optional field, you do not need to pass value for this field
 * @param p_serial_range_tab    table of the serial range records
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Shipping Attributes to  enable entry of multiple serial ranges
 */
PROCEDURE Update_Shipping_Attributes (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_changed_attributes    IN     WSH_DELIVERY_DETAILS_PUB.ChangedAttributeTabType
, p_source_code            IN     VARCHAR2
, p_container_flag         IN     VARCHAR2 DEFAULT NULL
, p_serial_range_tab       IN     WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
);

/*#
 * Procedure to get the status of a delivery line
 * The line status could be one of the three values:
 *   1. 'SIC'  - if the delivery associated with the delivery line is
 *               Confirmed, In-Transit, or Closed
 *   2. 'PK'   - if the delivery line is packed into a container
 *   3. 'OK'   - if the delivery line is not packed or not assigned
 *
 * @param p_delivery_detail_id    delivery line ID
 * @param x_line_status           output parameter, line status
 * @param x_return_status         return status of the api
 * @rep:scope internal
 * @rep:lifecycle obsolete
 * @rep:displayname Get Delivery Line Status
 */
PROCEDURE Get_Detail_Status(
  p_delivery_detail_id  IN NUMBER
, x_line_status         OUT NOCOPY  VARCHAR2
, x_return_status       OUT NOCOPY  VARCHAR2
);

/*#
 * Procedure to perform autocreate deliveries for multiple delivery lines
 * @param p_api_version_number         version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_line_rows           table of the delivery line IDs
 * @param x_del_rows            output table of deliveries created
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Autocreate Deliveries
 */
PROCEDURE Autocreate_Deliveries(
  p_api_version_number     IN     NUMBER
, p_init_msg_list      IN   VARCHAR2  DEFAULT FND_API.G_FALSE
, p_commit             IN   VARCHAR2  DEFAULT FND_API.G_FALSE
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows             IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  wsh_util_core.id_tab_type
);

/*#
 * Procedure to perform autocreate a single trip for multiple delivery lines
 * It also creates deliveries for the delivery lines.
 * @param p_api_version_number         version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_line_rows           table of the delivery line IDs
 * @param x_del_rows            output table of deliveries created
 * @param x_trip_id             trip ID of the trip created
 * @param x_trip_name           trip name of the trip created
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Autocreate Trip
 */
PROCEDURE Autocreate_del_trip(
  p_api_version_number     IN     NUMBER
, p_init_msg_list      IN   VARCHAR2  DEFAULT FND_API.G_FALSE
, p_commit             IN   VARCHAR2  DEFAULT FND_API.G_FALSE
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
, x_trip_id                   OUT NOCOPY  NUMBER
, x_trip_name                 OUT NOCOPY  VARCHAR2
);

/*#
 * Procedure to perform autocreate trips for multiple delivery lines
 * It also creates deliveries for the delivery lines.
 * @param p_api_version_number         version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_commit              commit the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_line_rows           table of the delivery line IDs
 * @param x_del_rows            output table of deliveries created
 * @param x_trip_rows           trip IDs of the trips created
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Autocreate Trips
 */
PROCEDURE Autocreate_del_trip(
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
, x_trip_rows                   OUT NOCOPY WSH_UTIL_CORE.id_tab_type
);

END WSH_DELIVERY_DETAILS_PUB;

 

/
