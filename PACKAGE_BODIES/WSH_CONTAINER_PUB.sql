--------------------------------------------------------
--  DDL for Package Body WSH_CONTAINER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONTAINER_PUB" AS
/* $Header: WSHCOPBB.pls 120.0 2005/05/26 17:16:10 appldev noship $ */

	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) 		:= 'WSH_CONTAINER_PUB';
	p_message_type	CONSTANT VARCHAR2(1) 	:= 'E';


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

	-- program specific out parameters
	x_container_ids		OUT NOCOPY 	WSH_UTIL_CORE.ID_TAB_TYPE,
        p_ucc_128_suffix_flag   IN NUMBER
) IS


-- Standard call to check for call compatibility
l_api_version		CONSTANT	NUMBER		:= 1.0;
l_api_name		CONSTANT	VARCHAR2(30):= 'Create_Containers';


l_msg_summary 		VARCHAR2(32000)	:= NULL;
l_msg_details 		VARCHAR2(32000)	:= NULL;
l_detail_rec            wsh_glbl_var_strct_grp.detailInRecType;
l_detail_tab            wsh_glbl_var_strct_grp.delivery_details_attr_tbl_type;
l_out_rec               wsh_glbl_var_strct_grp.detailOutRecType;
l_lpn_ids               WSH_UTIL_CORE.Id_Tab_Type;

--
 l_num_errors           NUMBER := 0;
 l_num_warning          NUMBER := 0;
 --
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                      'Create_Containers';

WSH_INVALID_QTY			EXCEPTION;
WSH_FAIL_CONT_CREATION		EXCEPTION;


BEGIN

	-- Standard begin of API savepoint
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	SAVEPOINT Create_Containers_SP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'p_commit', p_commit);
            WSH_DEBUG_SV.log(l_module_name,'p_container_name',p_container_name);
            WSH_DEBUG_SV.log(l_module_name,'p_validation_level',
                                                         p_validation_level);
            WSH_DEBUG_SV.log(l_module_name,'p_container_item_id',
                                                         p_container_item_id);
            WSH_DEBUG_SV.log(l_module_name,'p_container_item_name',
                                                         p_container_item_name);
            WSH_DEBUG_SV.log(l_module_name,'p_organization_code',
                                                           p_organization_code);
            WSH_DEBUG_SV.log(l_module_name,'p_organization_id',
                                                           p_organization_id);
            WSH_DEBUG_SV.log(l_module_name,'p_name_prefix',p_name_prefix);
            WSH_DEBUG_SV.log(l_module_name,'p_name_suffix',p_name_suffix);
            WSH_DEBUG_SV.log(l_module_name,'p_base_number',p_base_number);
            WSH_DEBUG_SV.log(l_module_name,'p_num_digits',p_num_digits);
            WSH_DEBUG_SV.log(l_module_name,'p_api_version',p_api_version);
            WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list);
            WSH_DEBUG_SV.log(l_module_name,'p_quantity',p_quantity);
            WSH_DEBUG_SV.log(l_module_name,'ucc_128_suffix_flag',
                                                     p_ucc_128_suffix_flag);
        END IF;


	IF NOT FND_API.compatible_api_call (
				l_api_version,
				p_api_version,
				l_api_name,
				G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	-- validate quantity

        IF p_quantity <= 0 THEN
            RAISE WSH_INVALID_QTY;
        END IF;



        l_detail_rec.caller := 'WSH_PUB';
        l_detail_rec.action_code := 'CREATE';
        l_detail_rec.container_item_id := p_container_item_id;
        l_detail_rec.container_item_name := p_container_item_name;
        l_detail_rec.container_item_seg := p_container_item_seg;
        l_detail_rec.organization_id   := p_organization_id;
        l_detail_rec.organization_code   := p_organization_code;
        l_detail_rec.name_prefix   := p_name_prefix;
        l_detail_rec.name_suffix   := p_name_suffix;
        l_detail_rec.base_number   := p_base_number;
        l_detail_rec.num_digits   := p_num_digits;
        l_detail_rec.quantity   := p_quantity;
        l_detail_rec.container_name   := p_container_name;
        l_detail_rec.ucc_128_suffix_flag   := p_ucc_128_suffix_flag;
        l_detail_rec.lpn_ids := l_lpn_ids;

        wsh_interface_grp.Create_Update_Delivery_Detail(
                        p_api_version_number => 1.0,
                        p_init_msg_list      => FND_API.G_FALSE,
                        p_commit             => FND_API.G_FALSE,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_detail_info_tab    => l_detail_tab,
                        p_IN_rec             => l_detail_rec,
                        x_OUT_rec            => l_out_rec);


         wsh_util_core.api_post_call(
                  p_return_status  =>x_return_status,
                  x_num_warnings     =>l_num_warning,
                  x_num_errors       =>l_num_errors,
                  p_msg_data         =>x_msg_data,
                  p_raise_error_flag  => FALSE);

       IF x_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.G_RET_STS_UNEXP_ERROR ) THEN
           raise WSH_FAIL_CONT_CREATION;
       END IF;

	IF l_out_rec.detail_ids.COUNT > 0 THEN
		x_container_ids := l_out_rec.detail_ids;
	END IF;

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		-- dbms_output.put_line('commit');
		COMMIT;
	END IF;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

 EXCEPTION

	WHEN WSH_INVALID_QTY then
		rollback to Create_Containers_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_CONT_INVALID_QTY');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_QTY');
                END IF;

	WHEN WSH_FAIL_CONT_CREATION then
		rollback to Create_Containers_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_CONT_CREATE_ERROR');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,
                                         'EXCEPTION:WSH_FAIL_CONT_CREATION');
                END IF;

	WHEN OTHERS then
		rollback to Create_Containers_SP;
		wsh_util_core.default_handler('WSH_CONTAINER_PUB.Create_Containers',l_module_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');

                END IF;


END Create_Containers;


PROCEDURE populate_record(
   p_in_rec        IN          WSH_DELIVERY_DETAILS_PUB.CHANGEDATTRIBUTERECTYPE
,  p_outrec        OUT NOCOPY
                     wsh_glbl_var_strct_grp.Delivery_Details_Rec_Type)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                      'populate_record';

BEGIN

   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
   END IF;
   p_outrec.delivery_detail_id := p_in_rec.delivery_detail_id;
   p_outrec.source_code := FND_API.G_MISS_CHAR;
   p_outrec.source_header_id := p_in_rec.source_header_id;
   p_outrec.source_line_id       := p_in_rec.source_line_id;
   p_outrec.customer_id  := FND_API.G_MISS_NUM;
   p_outrec.sold_to_contact_id := p_in_rec.sold_to_contact_id;
   p_outrec.inventory_item_id := FND_API.G_MISS_NUM;
   p_outrec.item_description := FND_API.G_MISS_CHAR;
   p_outrec.hazard_class_id := FND_API.G_MISS_NUM;
   p_outrec.country_of_origin := FND_API.G_MISS_CHAR;
   p_outrec.classification       := FND_API.G_MISS_CHAR;
   p_outrec.ship_from_location_id := FND_API.G_MISS_NUM;
   p_outrec.ship_to_location_id := FND_API.G_MISS_NUM;
   p_outrec.ship_to_contact_id := p_in_rec.ship_to_contact_id;
   p_outrec.ship_to_site_use_id := FND_API.G_MISS_NUM;
   p_outrec.deliver_to_location_id := FND_API.G_MISS_NUM;
   p_outrec.deliver_to_contact_id := p_in_rec.deliver_to_contact_id;
   p_outrec.deliver_to_site_use_id :=  FND_API.G_MISS_NUM;
   p_outrec.intmed_ship_to_location_id :=  FND_API.G_MISS_NUM;
   p_outrec.intmed_ship_to_contact_id := p_in_rec.intmed_ship_to_contact_id;
   p_outrec.hold_code := FND_API.G_MISS_CHAR;
   p_outrec.ship_tolerance_above := p_in_rec.ship_tolerance_above;
   p_outrec.ship_tolerance_below := p_in_rec.ship_tolerance_below;
   p_outrec.requested_quantity   := FND_API.G_MISS_NUM;
   p_outrec.shipped_quantity     := p_in_rec.shipped_quantity;
   p_outrec.delivered_quantity   := FND_API.G_MISS_NUM;
   p_outrec.requested_quantity_uom := FND_API.G_MISS_CHAR;
   p_outrec.subinventory                 := p_in_rec.subinventory;
   p_outrec.revision                     := p_in_rec.revision;
   p_outrec.lot_number           := p_in_rec.lot_number;
   p_outrec.customer_requested_lot_flag := p_in_rec.customer_requested_lot_flag;
   p_outrec.serial_number                := p_in_rec.serial_number;
   p_outrec.locator_id           := p_in_rec.locator_id;
   p_outrec.date_requested               := p_in_rec.date_requested;
   p_outrec.date_scheduled               := p_in_rec.date_scheduled;
   p_outrec.master_container_item_id := p_in_rec.master_container_item_id;
   p_outrec.detail_container_item_id := p_in_rec.detail_container_item_id;
   p_outrec.load_seq_number      := FND_API.G_MISS_NUM;
   p_outrec.ship_method_code     := FND_API.G_MISS_CHAR;
   p_outrec.carrier_id           := p_in_rec.carrier_id;
   p_outrec.freight_terms_code   := p_in_rec.freight_terms_code;
   p_outrec.shipment_priority_code := p_in_rec.shipment_priority_code;
   p_outrec.fob_code := p_in_rec.fob_code;
   p_outrec.customer_item_id     := FND_API.G_MISS_NUM;
   p_outrec.dep_plan_required_flag := p_in_rec.dep_plan_required_flag;
   p_outrec.customer_prod_seq    := p_in_rec.customer_prod_seq;
   p_outrec.customer_dock_code   := p_in_rec.customer_dock_code;
   p_outrec.cust_model_serial_number := FND_API.G_MISS_CHAR;
   p_outrec.customer_job                             := FND_API.G_MISS_CHAR;
   p_outrec.customer_production_line                 := FND_API.G_MISS_CHAR;
   p_outrec.net_weight           := p_in_rec.net_weight;
   p_outrec.weight_uom_code      := p_in_rec.weight_uom_code;
   p_outrec.volume                       := p_in_rec.volume;
   -- J: W/V Changes
   p_outrec.filled_volume        := p_in_rec.filled_volume;
   p_outrec.volume_uom_code      := p_in_rec.volume_uom_code;
-- Bug 3723831 :tp attributes can be updated via public API. So assigning the values of p_in_rec to the same.
   p_outrec.tp_attribute_category:= p_in_rec.tp_attribute_category;
   p_outrec.tp_attribute1        := p_in_rec.tp_attribute1;
   p_outrec.tp_attribute2        := p_in_rec.tp_attribute2;
   p_outrec.tp_attribute3        := p_in_rec.tp_attribute3;
   p_outrec.tp_attribute4        := p_in_rec.tp_attribute4;
   p_outrec.tp_attribute5        := p_in_rec.tp_attribute5;
   p_outrec.tp_attribute6        := p_in_rec.tp_attribute6;
   p_outrec.tp_attribute7        := p_in_rec.tp_attribute7;
   p_outrec.tp_attribute8        := p_in_rec.tp_attribute8;
   p_outrec.tp_attribute9        := p_in_rec.tp_attribute9;
   p_outrec.tp_attribute10       := p_in_rec.tp_attribute10;
   p_outrec.tp_attribute11       := p_in_rec.tp_attribute11;
   p_outrec.tp_attribute12       := p_in_rec.tp_attribute12;
   p_outrec.tp_attribute13       := p_in_rec.tp_attribute13;
   p_outrec.tp_attribute14       := p_in_rec.tp_attribute14;
   p_outrec.tp_attribute15       := p_in_rec.tp_attribute15;
   p_outrec.attribute_category   := FND_API.G_MISS_CHAR;
   p_outrec.attribute1           := p_in_rec.attribute1;
   p_outrec.attribute2           := p_in_rec.attribute2;
   p_outrec.attribute3           := p_in_rec.attribute3;
   p_outrec.attribute4           := p_in_rec.attribute4;
   p_outrec.attribute5           := p_in_rec.attribute5;
   p_outrec.attribute6           := p_in_rec.attribute6;
   p_outrec.attribute7           := p_in_rec.attribute7;
   p_outrec.attribute8           := p_in_rec.attribute8;
   p_outrec.attribute9           := p_in_rec.attribute9;
   p_outrec.attribute10          := p_in_rec.attribute10;
   p_outrec.attribute11          := p_in_rec.attribute11;
   p_outrec.attribute12          := p_in_rec.attribute12;
   p_outrec.attribute13          := p_in_rec.attribute13;
   p_outrec.attribute14          := p_in_rec.attribute14;
   p_outrec.attribute15          := p_in_rec.attribute15;
   p_outrec.created_by           := FND_API.G_MISS_NUM;
   p_outrec.creation_date                := FND_API.G_MISS_DATE;
   p_outrec.last_update_date     := FND_API.G_MISS_DATE;
   p_outrec.last_update_login    := FND_API.G_MISS_NUM;
   p_outrec.last_updated_by      := FND_API.G_MISS_NUM;
   p_outrec.program_application_id := FND_API.G_MISS_NUM;
   p_outrec.program_id           := FND_API.G_MISS_NUM;
   p_outrec.program_update_date  := FND_API.G_MISS_DATE;
   p_outrec.request_id           := FND_API.G_MISS_NUM;
   p_outrec.mvt_stat_status      := FND_API.G_MISS_CHAR;
   p_outrec.released_flag                := FND_API.G_MISS_CHAR;
   p_outrec.organization_id      := FND_API.G_MISS_NUM;
   p_outrec.transaction_temp_id  :=  FND_API.G_MISS_NUM;
   p_outrec.ship_set_id          := p_in_rec.ship_set_id;
   p_outrec.arrival_set_id               := p_in_rec.arrival_set_id;
   p_outrec.ship_model_complete_flag       := p_in_rec.ship_model_complete_flag;
   p_outrec.top_model_line_id    := p_in_rec.top_model_line_id;
   p_outrec.source_header_number := FND_API.G_MISS_CHAR;
   p_outrec.source_header_type_id := FND_API.G_MISS_NUM;
   p_outrec.source_header_type_name := FND_API.G_MISS_CHAR;
   p_outrec.cust_po_number               := p_in_rec.cust_po_number;
   p_outrec.ato_line_id          := p_in_rec.ato_line_id;
   p_outrec.src_requested_quantity :=  FND_API.G_MISS_NUM;
   p_outrec.src_requested_quantity_uom :=  FND_API.G_MISS_CHAR;
   p_outrec.move_order_line_id   := FND_API.G_MISS_NUM;
   p_outrec.cancelled_quantity   := FND_API.G_MISS_NUM;
   p_outrec.quality_control_quantity := FND_API.G_MISS_NUM;
   p_outrec.cycle_count_quantity := p_in_rec.cycle_count_quantity;
   p_outrec.tracking_number      := p_in_rec.tracking_number;
   p_outrec.movement_id          := FND_API.G_MISS_NUM;
   p_outrec.shipping_instructions := p_in_rec.shipping_instructions;
   p_outrec.packing_instructions := p_in_rec.packing_instructions;
   p_outrec.project_id           := FND_API.G_MISS_NUM;
   p_outrec.task_id                      := FND_API.G_MISS_NUM;
   p_outrec.org_id                       := FND_API.G_MISS_NUM;
   p_outrec.oe_interfaced_flag   := FND_API.G_MISS_CHAR;
   p_outrec.split_from_detail_id := FND_API.G_MISS_NUM;
   p_outrec.inv_interfaced_flag  := FND_API.G_MISS_CHAR;
   p_outrec.source_line_number   := FND_API.G_MISS_CHAR;
   p_outrec.inspection_flag                := FND_API.G_MISS_CHAR;
   p_outrec.released_status      := p_in_rec.released_status;
   p_outrec.container_flag               := p_in_rec.container_flag;
   p_outrec.container_type_code  := FND_API.G_MISS_CHAR;
   p_outrec.container_name               := p_in_rec.container_name;
   p_outrec.fill_percent                 := FND_API.G_MISS_NUM;
   p_outrec.gross_weight                 := p_in_rec.gross_weight;
   p_outrec.master_serial_number := FND_API.G_MISS_CHAR;
   p_outrec.maximum_load_weight  := FND_API.G_MISS_NUM;
   p_outrec.maximum_volume               := FND_API.G_MISS_NUM;
   p_outrec.minimum_fill_percent := FND_API.G_MISS_NUM;
   p_outrec.seal_code                    := FND_API.G_MISS_CHAR;
   p_outrec.unit_number                  := FND_API.G_MISS_CHAR;
   p_outrec.unit_price           := FND_API.G_MISS_NUM;
   p_outrec.currency_code                := FND_API.G_MISS_CHAR;
   p_outrec.freight_class_cat_id           := FND_API.G_MISS_NUM;
   p_outrec.commodity_code_cat_id          := FND_API.G_MISS_NUM;
   p_outrec.preferred_grade                := p_in_rec.preferred_grade;
   p_outrec.src_requested_quantity2        := FND_API.G_MISS_NUM;
   p_outrec.src_requested_quantity_uom2    := FND_API.G_MISS_CHAR;
   p_outrec.requested_quantity2            := FND_API.G_MISS_NUM;
   p_outrec.shipped_quantity2              := FND_API.G_MISS_NUM;
   p_outrec.delivered_quantity2            := FND_API.G_MISS_NUM;
   p_outrec.cancelled_quantity2            := FND_API.G_MISS_NUM;
   p_outrec.quality_control_quantity2      := FND_API.G_MISS_NUM;
   p_outrec.cycle_count_quantity2          := FND_API.G_MISS_NUM;
   p_outrec.requested_quantity_uom2        := FND_API.G_MISS_CHAR;
-- HW OPMCONV - No need for sublot_number
-- p_outrec.sublot_number                  := p_in_rec.sublot_number;
   p_outrec.lpn_id                       := FND_API.G_MISS_NUM;
   p_outrec.pickable_flag                   := FND_API.G_MISS_CHAR;
   p_outrec.original_subinventory           := FND_API.G_MISS_CHAR;
   p_outrec.to_serial_number                := FND_API.G_MISS_CHAR;
   p_outrec.picked_quantity      := FND_API.G_MISS_NUM;
   p_outrec.picked_quantity2 := FND_API.G_MISS_NUM;
   p_outrec.received_quantity := FND_API.G_MISS_NUM;
   p_outrec.received_quantity2 := FND_API.G_MISS_NUM;
   p_outrec.source_line_set_id := FND_API.G_MISS_NUM;


   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;

 EXCEPTION

  WHEN OTHERS THEN
                wsh_util_core.default_handler('WSH_CONTAINER_PUB.populate_record',l_module_name) ;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');

                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END populate_record;



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

) IS

 -- Standard call to check for call compatibility
 l_api_version		CONSTANT	NUMBER	:= 1.0;
 l_api_name		CONSTANT	VARCHAR2(30):= 'Update_Containers';


 l_msg_summary 		VARCHAR2(32000)	:= NULL;
 l_msg_details 		VARCHAR2(32000)	:= NULL;
 l_detail_rec            wsh_glbl_var_strct_grp.detailInRecType;
 l_detail_info_tab       wsh_glbl_var_strct_grp.delivery_details_attr_tbl_type;
 l_detail_info_rec       wsh_glbl_var_strct_grp.Delivery_Details_Rec_Type;
 l_out_rec               wsh_glbl_var_strct_grp.detailOutRecType;
 l_lpn_ids               WSH_UTIL_CORE.Id_Tab_Type;

 --
 l_num_errors           NUMBER := 0;
 l_num_warning          NUMBER := 0;
 --
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                      'Update_Container';

 WSH_INVALID_CONT_UPDATE		EXCEPTION;
 WSH_FAIL_CONT_UPDATE			EXCEPTION;


BEGIN

	-- Standard begin of API savepoint
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	SAVEPOINT Update_Containers_SP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'p_commit', p_commit);
            WSH_DEBUG_SV.log(l_module_name,'p_validation_level',
                                                           p_validation_level);
            WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list', p_init_msg_list);
            WSH_DEBUG_SV.log(l_module_name,'p_api_version', p_api_version);
            WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',
                                         p_container_rec.delivery_detail_id);
        END IF;

	IF NOT FND_API.compatible_api_call (
				l_api_version,
				p_api_version,
				l_api_name,
				G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	-- check to make sure that the container record being input for update
	-- does not have null delivery detail ids or container name or the
	-- container flag is null or 'N'


	-- Now check for valid container based on the information in the
	-- container rec.


        populate_record(p_container_rec,l_detail_info_rec);
        l_detail_info_tab(1) := l_detail_info_rec;
        l_detail_rec.caller := 'WSH_PUB';
        l_detail_rec.action_code := 'UPDATE';
        l_detail_rec.lpn_ids := l_lpn_ids;
        --
        wsh_interface_grp.Create_Update_Delivery_Detail(
                        p_api_version_number => 1.0,
                        p_init_msg_list      => FND_API.G_FALSE,
                        p_commit             => FND_API.G_FALSE,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_detail_info_tab    => l_detail_info_tab,
                        p_IN_rec             => l_detail_rec,
                        x_OUT_rec            => l_out_rec);

         wsh_util_core.api_post_call(
                  p_return_status  =>x_return_status,
                  x_num_warnings     =>l_num_warning,
                  x_num_errors       =>l_num_errors,
                  p_msg_data         =>x_msg_data,
                  p_raise_error_flag  => FALSE);

       IF x_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.G_RET_STS_UNEXP_ERROR ) THEN
           raise WSH_FAIL_CONT_UPDATE;
       END IF;

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		-- dbms_output.put_line('commit');
		COMMIT;
	END IF;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --


        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;


EXCEPTION

	WHEN WSH_INVALID_CONT_UPDATE then
		rollback to Update_Containers_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_CONT_INVALID_UPDATE');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONT_UPDATE');
                END IF;

	WHEN WSH_FAIL_CONT_UPDATE then
		rollback to Update_Containers_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_CONT_UPDATE_ERROR');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_CONT_UPDATE');
                END IF;

	WHEN OTHERS then
		rollback to Update_Containers_SP;
		wsh_util_core.default_handler('WSH_CONTAINER_PUB.Update_Container',l_module_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');

                END IF;
END Update_Container;


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

) IS

 -- Standard call to check for call compatibility
 l_api_version		CONSTANT	NUMBER	:= 1.0;
 l_api_name		CONSTANT	VARCHAR2(30):= 'Update_Containers';

 l_return_status 	VARCHAR2(30)	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_entity_tab		WSH_UTIL_CORE.ID_TAB_TYPE;

 l_det_cnt		NUMBER := 0;
 l_count                NUMBER;

 l_msg_summary 		VARCHAR2(32000)	:= NULL;
 l_msg_details 		VARCHAR2(32000)	:= NULL;

 l_rec_att_tab          wsh_glbl_var_strct_grp.delivery_details_attr_tbl_type;
 l_action_prms          wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
 l_action_prms_dl       WSH_DELIVERIES_GRP.action_parameters_rectype;
 l_action_out_rec       wsh_glbl_var_strct_grp.dd_action_out_rec_type;

 l_delivery_out_rec     WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
 l_del_rec_attr         wsh_new_deliveries_pvt.Delivery_Rec_type;
 --
 l_num_errors           NUMBER := 0;
 l_num_warning          NUMBER := 0;
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                      'AUTO_PACK';


 WSH_INVALID_DETAIL			EXCEPTION;
 WSH_INVALID_DELIVERY			EXCEPTION;
 WSH_INVALID_ENTITY_TYPE		EXCEPTION;
 WSH_FAIL_AUTOPACK			EXCEPTION;

BEGIN
	-- Standard begin of API savepoint
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	SAVEPOINT Autopack_SP;
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'p_commit', p_commit);
            WSH_DEBUG_SV.log(l_module_name,'p_validation_level',
                                                          p_validation_level);
            WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list', p_init_msg_list);
            WSH_DEBUG_SV.log(l_module_name,'p_api_version', p_api_version);
            WSH_DEBUG_SV.log(l_module_name,'p_entity_type', p_entity_type);
            WSH_DEBUG_SV.log(l_module_name,'p_pack_cont_flag',p_pack_cont_flag);
        END IF;

	IF NOT FND_API.compatible_api_call (
				l_api_version,
				p_api_version,
				l_api_name,
				G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	-- first decide which entity it is by checking entity type..
	-- based on entity type validate all the entity ids..


        l_count := p_entity_tab.count;
        FOR i IN 1..l_count LOOP
           IF p_entity_tab(i) IS NOT NULL THEN
               l_det_cnt := l_det_cnt + 1;
               l_entity_tab(l_det_cnt) := p_entity_tab(i);
           ELSE
              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                 --bms what is the use of this l_return_status?
              END IF;
           END IF;

        END LOOP;

	IF p_entity_type = 'L' OR p_entity_type = 'C' THEN

             IF l_entity_tab.count > 0 THEN

		 l_action_prms.caller := 'WSH_PUB';
                 IF p_pack_cont_flag = 'Y' THEN
		    l_action_prms.action_code := 'AUTO-PACK-MASTER';
                 ELSIF p_pack_cont_flag = 'N' THEN
		    l_action_prms.action_code := 'AUTO-PACK';
                 END IF;

                 wsh_interface_grp.Delivery_Detail_Action(
                        p_api_version_number => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit => FND_API.G_FALSE,
                        x_return_status =>x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_detail_id_tab =>l_entity_tab,
                        p_action_prms  =>l_action_prms,
                        x_action_out_rec => l_action_out_rec);

              wsh_util_core.api_post_call(
                  p_return_status  =>x_return_status,
                  x_num_warnings     =>l_num_warning,
                  x_num_errors       =>l_num_errors,
                  p_msg_data         =>x_msg_data,
                  p_raise_error_flag  => FALSE);

             IF x_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.G_RET_STS_UNEXP_ERROR ) THEN
                raise WSH_FAIL_AUTOPACK;
             END IF;

                 x_cont_inst_tab := l_action_out_rec.result_id_tab;
              ELSE
                 RAISE WSH_INVALID_DETAIL;
              END IF;

	ELSIF p_entity_type = 'D' THEN
             l_action_prms_dl.caller := 'WSH_PUB';
             IF p_pack_cont_flag = 'Y' THEN
                l_action_prms_dl.action_code := 'AUTO-PACK-MASTER';
             ELSIF p_pack_cont_flag = 'N' THEN
                l_action_prms_dl.action_code := 'AUTO-PACK';
             END IF;

             IF l_entity_tab.count =  0 THEN
                        RAISE WSH_INVALID_DELIVERY;
             END IF;

             wsh_interface_grp.Delivery_Action(
                p_api_version_number  => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                p_commit       => FND_API.G_FALSE,
                p_action_prms  => l_action_prms_dl,
                p_delivery_id_tab => l_entity_tab,
                x_delivery_out_rec => l_delivery_out_rec,
                x_return_status   => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data
             );

              wsh_util_core.api_post_call(
                  p_return_status  =>x_return_status,
                  x_num_warnings     =>l_num_warning,
                  x_num_errors       =>l_num_errors,
                  p_msg_data         =>x_msg_data,
                  p_raise_error_flag  => FALSE);

              IF x_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.G_RET_STS_UNEXP_ERROR ) THEN
                 raise WSH_FAIL_AUTOPACK;
              END IF;

             x_cont_inst_tab := l_delivery_out_rec.result_id_tab;


	ELSE
		RAISE WSH_INVALID_ENTITY_TYPE;
	END IF;

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		-- dbms_output.put_line('commit');
		COMMIT;
	END IF;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

EXCEPTION

	WHEN WSH_INVALID_DETAIL then
		rollback to Autopack_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_DET_INVALID_DETAIL');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DETAIL');
                END IF;

	WHEN WSH_INVALID_DELIVERY then
		rollback to Autopack_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_DET_INVALID_DEL');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DELIVERY');
                END IF;
	WHEN WSH_FAIL_AUTOPACK then
		rollback to Autopack_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_AUTOPACK_ERROR');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_AUTOPACK');
                END IF;

	WHEN WSH_INVALID_ENTITY_TYPE then
		rollback to Autopack_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_PUB_CONT_TYPE_ERR');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_ENTITY_TYPE');
                END IF;
	WHEN OTHERS then
		rollback to Autopack_SP;
		wsh_util_core.default_handler('WSH_CONTAINER_PUB.Auto_Pack',l_module_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');

                END IF;

END Auto_Pack;


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

) IS

 -- Standard call to check for call compatibility
 l_api_version		CONSTANT	NUMBER	:= 1.0;
 l_api_name		CONSTANT	VARCHAR2(30):= 'Update_Containers';


 l_msg_summary 		VARCHAR2(32000)	:= NULL;
 l_msg_details 		VARCHAR2(32000)	:= NULL;
 l_action_prms          wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
 l_num_errors           NUMBER := 0;
 l_num_warning          NUMBER := 0;
 l_action_out_rec       wsh_glbl_var_strct_grp.dd_action_out_rec_type;

 l_return_status	VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                          'Container_Actions';


 WSH_INVALID_DETAIL			EXCEPTION;


BEGIN

	-- Standard begin of API savepoint
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	SAVEPOINT Container_Action_SP;

        IF l_debug_on THEN
           wsh_debug_sv.push (l_module_name);
           wsh_debug_sv.log (l_module_name,'p_api_version', p_api_version);
           wsh_debug_sv.log (l_module_name,'p_init_msg_list', p_init_msg_list);
           wsh_debug_sv.log (l_module_name,'p_commit', p_commit);
           wsh_debug_sv.log (l_module_name,'p_validation_level', p_validation_level);
           wsh_debug_sv.log (l_module_name,'p_container_name', p_container_name);
           wsh_debug_sv.log (l_module_name,'p_cont_instance_id', p_cont_instance_id);
           wsh_debug_sv.log (l_module_name,'p_container_flag', p_container_flag);
           wsh_debug_sv.log (l_module_name,'p_delivery_flag', p_delivery_flag);
           wsh_debug_sv.log (l_module_name,'p_delivery_id', p_delivery_id);
           wsh_debug_sv.log (l_module_name,'p_delivery_name', p_delivery_name);
           wsh_debug_sv.log (l_module_name,'p_action_code', p_action_code);
        END IF;

	IF NOT FND_API.compatible_api_call (
				l_api_version,
				p_api_version,
				l_api_name,
				G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	-- first decide which action to perform by checking action type..
	-- based on entity type validate all the entity ids..

	IF p_detail_tab.COUNT = 0 THEN
		RAISE WSH_INVALID_DETAIL;
	END IF;

        l_action_prms.caller := 'WSH_PUB';
        l_action_prms.Action_Code := UPPER(p_action_code);
        l_action_prms.container_name := p_container_name;
        l_action_prms.container_instance_id := p_cont_instance_id;
        l_action_prms.container_flag := p_container_flag;
        l_action_prms.delivery_flag := p_delivery_flag;
        l_action_prms.delivery_id := p_delivery_id;
        l_action_prms.delivery_name := p_delivery_name;


        wsh_interface_grp.Delivery_Detail_Action(
               p_api_version_number => 1.0,
               p_init_msg_list => FND_API.G_FALSE,
               p_commit => FND_API.G_FALSE,
               x_return_status =>l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_detail_id_tab =>p_detail_tab,
               p_action_prms  =>l_action_prms,
               x_action_out_rec => l_action_out_rec);



         wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                       x_num_warnings     =>l_num_warning,
                                       x_num_errors       =>l_num_errors);

        x_return_status := l_return_status;

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		COMMIT;
	END IF;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --


        IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
        END IF;
EXCEPTION

	WHEN WSH_INVALID_DETAIL then
		rollback to Container_Action_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_DET_INVALID_DETAIL');
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,'EXCEPTION:WSH_INVALID_DETAIL');
                     WSH_DEBUG_SV.pop(l_module_name);
                END IF;

        WHEN FND_API.G_EXC_ERROR THEN
                rollback to Container_Action_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,'EXCEPTION:G_EXC_ERROR');
                     WSH_DEBUG_SV.pop(l_module_name);
                END IF;



        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                rollback to Container_Action_SP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,'EXCEPTION:G_RET_STS_UNEXP_ERROR');
                     WSH_DEBUG_SV.pop(l_module_name);
                END IF;

        WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --

                IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,'EXCEPTION:G_EXC_WARNING');
                     WSH_DEBUG_SV.pop(l_module_name);
                END IF;

	WHEN OTHERS then
		rollback to Container_Action_SP;
		wsh_util_core.default_handler('WSH_CONTAINER_PUB.Container_Actions');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                --
                FND_MSG_PUB.Count_And_Get
                (
        	    p_count =>  x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                --
                IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name,'Others',substr(sqlerrm,1,200));
                   WSH_DEBUG_SV.pop(l_module_name);
                END IF;


END Container_Actions;


END WSH_CONTAINER_PUB;

/
