--------------------------------------------------------
--  DDL for Package WSH_CONTAINER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CONTAINER_PUB" AUTHID CURRENT_USER AS
/* $Header: WSHCOPBS.pls 120.0 2005/05/26 18:12:54 appldev noship $ */
/*#
 * This package provides the APIs for  execution of various container functions,
 * including creation, updation of containers and other actions.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Container
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_DELIVERY_LINE
 * @rep:category BUSINESS_ENTITY WSH_DELIVERY
 */

TYPE CONT_REC_TYPE IS RECORD
	(delivery_detail_id		NUMBER,
	source_code			VARCHAR2(30),
	source_header_id		NUMBER,
	source_line_id			NUMBER,
	customer_id			NUMBER,
	sold_to_contact_id		NUMBER,
	inventory_item_id		NUMBER,
	item_description		VARCHAR2(250),
	hazard_class_id			NUMBER,
	country_of_origin		VARCHAR2(150),
	classification			VARCHAR2(30),
	ship_from_location_id		NUMBER,
	ship_to_location_id		NUMBER,
	ship_to_contact_id		NUMBER,
	deliver_to_location_id		NUMBER,
	deliver_to_contact_id		NUMBER,
	intmed_ship_to_location_id	NUMBER,
	intmed_ship_to_contact_id	NUMBER,
	hold_code			VARCHAR2(1),
	ship_tolerance_above		NUMBER,
	ship_tolerance_below		NUMBER,
	requested_quantity		NUMBER,
	shipped_quantity		NUMBER,
	delivered_quantity		NUMBER,
	requested_quantity_uom		VARCHAR2(3),
	subinventory			VARCHAR2(10),
	revision			VARCHAR2(3),
-- HW OPMCONV. Need to expand length of lot_number to 80
	lot_number			VARCHAR2(80),
	customer_requested_lot_flag	VARCHAR2(1),
	serial_number			VARCHAR2(30),
	locator_id			NUMBER,
	date_requested			DATE,
	date_scheduled			DATE,
	master_container_item_id	NUMBER,
	detail_container_item_id	NUMBER,
	load_seq_number			NUMBER,
	ship_method_code		VARCHAR2(30),
	carrier_id			NUMBER,
	freight_terms_code		VARCHAR2(30),
	shipment_priority_code		VARCHAR2(30),
	fob_code			VARCHAR2(30),
	customer_item_id		NUMBER,
	dep_plan_required_flag		VARCHAR2(1),
	customer_prod_seq		VARCHAR2(50),
	customer_dock_code		VARCHAR2(30),
	net_weight			NUMBER,
	weight_uom_code			VARCHAR2(3),
	volume				NUMBER,
	volume_uom_code			VARCHAR2(3),
	tp_attribute_category		VARCHAR2(240),
	tp_attribute1			VARCHAR2(240),
	tp_attribute2			VARCHAR2(240),
	tp_attribute3			VARCHAR2(240),
	tp_attribute4			VARCHAR2(240),
	tp_attribute5			VARCHAR2(240),
	tp_attribute6			VARCHAR2(240),
	tp_attribute7			VARCHAR2(240),
	tp_attribute8			VARCHAR2(240),
	tp_attribute9			VARCHAR2(240),
	tp_attribute10			VARCHAR2(240),
	tp_attribute11			VARCHAR2(240),
	tp_attribute12			VARCHAR2(240),
	tp_attribute13			VARCHAR2(240),
	tp_attribute14			VARCHAR2(240),
	tp_attribute15			VARCHAR2(240),
	attribute_category		VARCHAR2(150),
	attribute1			VARCHAR2(150),
	attribute2			VARCHAR2(150),
	attribute3			VARCHAR2(150),
	attribute4			VARCHAR2(150),
	attribute5			VARCHAR2(150),
	attribute6			VARCHAR2(150),
	attribute7			VARCHAR2(150),
	attribute8			VARCHAR2(150),
	attribute9			VARCHAR2(150),
	attribute10			VARCHAR2(150),
	attribute11			VARCHAR2(150),
	attribute12			VARCHAR2(150),
	attribute13			VARCHAR2(150),
	attribute14			VARCHAR2(150),
	attribute15			VARCHAR2(150),
	created_by			NUMBER,
	creation_date			DATE,
	last_update_date		DATE,
	last_update_login		NUMBER,
	last_updated_by			NUMBER,
	program_application_id		NUMBER,
	program_id			NUMBER,
	program_update_date		DATE,
	request_id			NUMBER,
	mvt_stat_status			VARCHAR2(30),
	released_flag			VARCHAR2(1),
	organization_id			NUMBER,
	transaction_temp_id		NUMBER,
	ship_set_id			NUMBER,
	arrival_set_id			NUMBER,
	ship_model_complete_flag      	VARCHAR2(1),
	top_model_line_id		NUMBER,
	source_header_number		VARCHAR2(150),
	source_header_type_id		NUMBER,
	source_header_type_name		VARCHAR2(240),
	cust_po_number			VARCHAR2(50),
	ato_line_id			NUMBER,
	src_requested_quantity		NUMBER,
	src_requested_quantity_uom	VARCHAR2(3),
	move_order_line_id		NUMBER,
	cancelled_quantity		NUMBER,
	quality_control_quantity	NUMBER,
	cycle_count_quantity		NUMBER,
	tracking_number			NUMBER,
	movement_id			NUMBER,
	shipping_instructions		VARCHAR2(2000),
	packing_instructions		VARCHAR2(2000),
	project_id			NUMBER,
	task_id				NUMBER,
	org_id				NUMBER,
	oe_interfaced_flag		VARCHAR2(1),
	split_from_detail_id		NUMBER,
	inv_interfaced_flag		VARCHAR2(1),
	source_line_number		VARCHAR2(150),
	released_status			VARCHAR2(1),
	container_flag			VARCHAR2(1),
	container_type_code 		VARCHAR2(30),
	container_name			VARCHAR2(30),
	fill_percent			NUMBER,
	gross_weight			NUMBER,
	master_serial_number		VARCHAR2(30),
	maximum_load_weight		NUMBER,
	maximum_volume			NUMBER,
	minimum_fill_percent		NUMBER,
	seal_code			VARCHAR2(30),
	unit_number  			VARCHAR2(30),
	unit_price			NUMBER,
	currency_code			VARCHAR2(15),
	freight_class_cat_id          	NUMBER,
	commodity_code_cat_id         	NUMBER ,
	inspection_flag          VARCHAR2(1)
    );


------------------------------------------------------------------------------
-- Procedure:	Create_Containers
--
-- Parameters:	1) container_item_id (key flex id)
--		2) container_item_name (concatinated name for container item)
--		3) container_item_seg (flex field seg array for item name)
--		4) organization_id - organization id for container
--		5) organization_code - organization code for container
--		6) name_prefix - container name prefix
--		7) name_suffix - container name suffix
--		8) base_number - starting number for numeric portion of name
--		9) num_digits - precision for number of digits
--		10) quantity - number of containers
--		11) container_name - container name if creating 1 container
--		12) table of container ids - out table of ids
--		13) other standard parameters
--
-- Description: This procedure takes in a container item id or container item
-- name and other necessary parameters to create one or more containers and
-- creates the required containers. It returns a table of container instance
-- ids (delivery detail ids) along with the standard out parameters.
------------------------------------------------------------------------------

/*#
 * This procedure is used to create containers. More than one container can be created
 * with a single procedure call by passing in the required parameters.

 * @param p_api_version         version number of the API
 * @param p_init_msg_list       messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param p_validation_level    validation level will be set as none if set as 0
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_container_item_id   container inventory item id (key flex id)
 * @param p_container_item_name container item name
 * @param p_container_item_seg  flex field seg array for item name
 * @param p_organization_id     organization id for container
 * @param p_organization_code   organization code for container
 * @param p_name_prefix         container name prefix
 * @param p_name_suffix         container name suffix
 * @param p_base_number         starting number for numeric portion of name
 * @param p_num_digits          precision for number of digits
 * @param p_quantity            number of containers
 * @param p_container_name      container name if creating 1 container
 * @param x_container_ids       output table of container ids (delivery detail ids) created
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Containers
 */
PROCEDURE Create_Containers (
	-- Standard parameters
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level	IN	NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status    	OUT NOCOPY 	VARCHAR2,
	x_msg_count 		OUT NOCOPY 	NUMBER,
	x_msg_data 		OUT NOCOPY 	VARCHAR2,

	-- program specific parameters
	p_container_item_id	IN	NUMBER,
	p_container_item_name 	IN	VARCHAR2,
	p_container_item_seg 	IN 	FND_FLEX_EXT.SegmentArray,
	p_organization_id	IN 	NUMBER,
	p_organization_code	IN 	VARCHAR2,
	p_name_prefix		IN	VARCHAR2,
	p_name_suffix		IN 	VARCHAR2,
	p_base_number		IN 	NUMBER,
	p_num_digits		IN 	NUMBER,
	p_quantity		IN 	NUMBER,
	p_container_name	IN 	VARCHAR2,

	-- program specific out parameters
	x_container_ids		OUT NOCOPY 	WSH_UTIL_CORE.ID_TAB_TYPE,
        p_ucc_128_suffix_flag   IN NUMBER DEFAULT 2
);


------------------------------------------------------------------------------
-- Procedure:	Update_Container
--
-- Parameters:	1) container_rec - container record of type
--		wsh_delivery_details_pub.changedattributerectype
--		2) other standard parameters
--
-- Description: This procedure takes in a record of container attributes that
-- contains the name and delivery detail id of container to update the
-- container record in WSH_DELIVERY_DETAILS with the attributes input in the
-- container rec type. The API validates the container name and detail id and
-- calls the wsh_delivery_details_pub.update_shipping_attributes public API.
------------------------------------------------------------------------------
/*#
 * This procedure is used to update a container. A record of container
 * attributes can be passed in to update the container record.
 * @param p_api_version         version number of the API
 * @param p_init_msg_list       messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param p_validation_level    validation level will be set as none if set as 0
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_container_rec       record of container attributes to be updated
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Container
 */
PROCEDURE Update_Container (
	-- Standard parameters
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level	IN	NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status    	OUT NOCOPY 	VARCHAR2,
	x_msg_count 		OUT NOCOPY 	NUMBER,
	x_msg_data 		OUT NOCOPY 	VARCHAR2,

	-- program specific parameters
	p_container_rec		IN	WSH_DELIVERY_DETAILS_PUB.CHANGEDATTRIBUTERECTYPE

);


------------------------------------------------------------------------------
-- Procedure:	Auto_Pack
--
-- Parameters:	1) entity_tab - table of ids of either lines or containers or
--			deliveries that need to be autopacked
--		2) entity_type - type of entity id contained in the entity_tab
--			that needs to be autopacked ('L' - lines,
--			'C' - containers OR 'D' - deliveries)
--		3) group_id_tab - table of ids (numbers that determine
--			the grouping of lines for packing into containers)
--		4) container_instance_tab - table of delivery detail ids of
--			containers that are created during the autopacking
--		5) pack cont flag - a 'Y' or 'N' value to determine whether to
--			to autopack the detail containers that are created into
--			parent containers.
--		6) other standard parameters
--
-- Description: This procedure takes in a table of ids of either delivery lines
-- or container or deliveries and autopacks the lines/containers/deliveries
-- into detail containers. The grouping id table is used only if the input
-- table of entities are lines or containers only. The packing of lines and
-- containers into parent containers is determined by the grouping id for each
-- line/container. If the grouping id table is not input, the API determines
-- the grouping ids for the lines/containers based on the grouping attributes
-- of the lines/containers. The lines/containers are then autopacked into
-- detail containers and the detail containers are packed into parent/master
-- containers based on whether the pack cont flag is set to 'Y' or 'N'. The
-- API returns a table of container instance ids created during the autopacking
-- operation. If the detail containers are packed into parent containers, the
-- output table of ids will contain both the detail and parent containers'
-- delivery detail ids.
------------------------------------------------------------------------------
/*#
 * This procedure takes in a table of ids of either delivery lines
 * or container or deliveries and autopacks the lines/containers/deliveries
 * into detail containers. The grouping id table is used only if the input
 * table of entities are lines or containers. The packing of lines and
 * containers into parent containers is determined by the grouping id for each
 * line/container. If the grouping id table is not input, the API determines
 * the grouping ids for the lines/containers based on the grouping attributes
 * of the lines/containers. The lines/containers are then autopacked into
 * detail containers and the detail containers are packed into parent/master
 * containers based on whether the pack cont flag is set to 'Y' or 'N'. The
 * API returns a table of container instance ids created during the autopacking
 * operation. If the detail containers are packed into parent containers, the
 * output table of ids will contain both the detail and parent containers'
 * delivery detail ids.
 * @param p_api_version         version number of the API
 * @param p_init_msg_list       messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param p_validation_level    validation level will be set as none if set as 0
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_entity_tab		table of ids of either lines or containers or deliveries that need to be autopacked
 * @param p_entity_type         type of entity - 'L' for lines, 'C' for containers OR 'D' for deliveries
 * @param p_group_id_tab        table of ids that determine the grouping of lines
 * @param p_pack_cont_flag      'Y' or 'N' value whether to autopack the detail containers that are created
 * @param x_cont_inst_tab       output table of ids that contains both detail and parent containers delivery detail ids.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Autopack Lines/Containers/Deliveries
 */
PROCEDURE Auto_Pack (
	-- Standard parameters
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level	IN	NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status    	OUT NOCOPY 	VARCHAR2,
	x_msg_count 		OUT NOCOPY 	NUMBER,
	x_msg_data 		OUT NOCOPY 	VARCHAR2,

	-- program specific parameters
	p_entity_tab		IN 	WSH_UTIL_CORE.ID_TAB_TYPE,
	p_entity_type		IN	VARCHAR2,
	p_group_id_tab		IN 	WSH_UTIL_CORE.ID_TAB_TYPE,
	p_pack_cont_flag	IN	VARCHAR2,

	-- program specific out parameters
	x_cont_inst_tab		OUT NOCOPY  	WSH_UTIL_CORE.ID_TAB_TYPE

);



------------------------------------------------------------------------------
-- Procedure:	Container_Actions
--
-- Parameters:	1) detail_tab - input table of delivery detail ids
--		2) container_instance_id - delivery detail id of parent
--			container that is being packed.
--		3) container_name - container name if id is not known
--		4) container_flag - 'Y' or 'N' depending on whether to unpack
--			or not. ('Y' is unpack)
--		5) delivery_flag - 'Y' or 'N' if container needs to be
--			unassigned from delivery. ('Y' if unassign from del)
--		6) delivery_id - delivery id to assign container to.
--		7) delivery_name - name of delivery that container is being
--			assigned to.
--		8) action_code - action code 'Pack', 'Assign', 'Unpack' or
--			'Unassign' to specify what action to perform.
--		9) other standard parameters
--
-- Description: This procedure takes in a table of delivery detail ids and
-- name and/or delivery detail id of container to pack. If the action code is
-- is assign then delivery id and delivery name must be specified. The API
-- determines what action to perform based on the action code and then calls
-- appropriate private pack/assign/unpack/unassign API.
-- The input table of ids could be lines or containers. The delivery lines and
-- containers are separated from the input table and validated before the
-- appropriate private APIs are called
------------------------------------------------------------------------------
/*#
 * Procedure for performing the container actions such as Pack, Assign,
 * Unpack, Unassign based on the action code passed in. The input table
 * of ids could be lines or containers.
 * @param p_api_version         version number of the API
 * @param p_init_msg_list       messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param p_validation_level    validation level will be set as none if set as 0
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_detail_tab		input table of delivery detail ids
 * @param p_container_name	container name if id is not known
 * @param p_cont_instance_id 	delivery detail id of parent container to pack the details/containers in
 * @param p_container_flag	value should be 'Y' if unpack also needs to be performed
 * @param p_delivery_flag	value should be 'Y' if container needs to be unassigned from delivery else should be 'N'
 * @param p_delivery_id		delivery id to which the container is to be assigned
 * @param p_delivery_name	delivery name to which the container is to be assigned
 * @param p_action_code		action code to specify what action to perform.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Container Actions
 */
PROCEDURE Container_Actions (
	-- Standard parameters
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level	IN	NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status    	OUT NOCOPY 	VARCHAR2,
	x_msg_count 		OUT NOCOPY 	NUMBER,
	x_msg_data 		OUT NOCOPY 	VARCHAR2,

	-- program specific parameters
	p_detail_tab		IN	WSH_UTIL_CORE.ID_TAB_TYPE,
	p_container_name	IN 	VARCHAR2 DEFAULT NULL,
	p_cont_instance_id 	IN	NUMBER DEFAULT NULL,
	p_container_flag	IN	VARCHAR2  DEFAULT 'N',
	p_delivery_flag		IN	VARCHAR2  DEFAULT 'N',
	p_delivery_id		IN 	NUMBER DEFAULT NULL,
	p_delivery_name		IN 	VARCHAR2 DEFAULT NULL,
	p_action_code		IN	VARCHAR2

);


END WSH_CONTAINER_PUB;

 

/
