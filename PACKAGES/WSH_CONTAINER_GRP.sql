--------------------------------------------------------
--  DDL for Package WSH_CONTAINER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CONTAINER_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHCOGPS.pls 120.0.12010000.1 2008/07/29 05:59:00 appldev ship $ */


TYPE ChangedAttributeTabType IS TABLE OF WSH_INTERFACE.ChangedAttributeRecType
        INDEX BY BINARY_INTEGER;

C_DELIVERY_DETAIL_CALL  NUMBER := 1000001212;


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
        p_lpn_ids               IN      WSH_UTIL_CORE.ID_TAB_TYPE,

	-- program specific out parameters
	x_container_ids		OUT NOCOPY 	WSH_UTIL_CORE.ID_TAB_TYPE,
        p_caller                IN      VARCHAR2 DEFAULT 'WMS'
);


------------------------------------------------------------------------------
-- Procedure:	Update_Container
--
-- Parameters:	1) container_rec - container record of type
--		wsh_delivery_details_grp.changedattributerectype
--		2) other standard parameters
--
-- Description: This procedure takes in a record of container attributes that
-- contains the name and delivery detail id of container to update the
-- container record in WSH_DELIVERY_DETAILS with the attributes input in the
-- container rec type. The API validates the container name and detail id and
-- calls the wsh_delivery_details_grp.update_shipping_attributes public API.
------------------------------------------------------------------------------

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
	p_container_rec		IN	WSH_CONTAINER_GRP.CHANGEDATTRIBUTETABTYPE

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
-- THIS PROCEDURE IS ONLY TO BE CALLED FROM
-- WSH_DELIVERY_DETAIL_GRP.Delivery_Detail_Action

------------------------------------------------------------------------------


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
	p_action_code		IN	VARCHAR2 ,
        p_caller                IN      VARCHAR2 DEFAULT 'WMS'
);

END WSH_CONTAINER_GRP;

/
