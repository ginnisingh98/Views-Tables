--------------------------------------------------------
--  DDL for Package WSH_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE" AUTHID CURRENT_USER as
/* $Header: WSHDDINS.pls 120.0.12010000.2 2009/12/03 12:28:03 mvudugul ship $ */

TYPE t_shipper_rec is RECORD
		(shipper_ID1					VARCHAR2(30),
		shipper_ID2					VARCHAR2(30),
		shipper_ID3					VARCHAR2(30),
		shipper_ID4					VARCHAR2(30),
		shipper_ID5					VARCHAR2(30));

TYPE ChangedAttributeRecType IS RECORD -- This record now includes all the columns
                                       -- other than the WHO columns in wsh_delivery_details,
                                       -- it is also now sorted.
		(
	action_flag				VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	arrival_set_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ato_line_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	attribute1				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute10				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute11				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute12				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute13				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute14				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute15				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute2				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute3				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute4				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute5				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute6				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute7				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute8				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute9				VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	attribute_category			VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	cancelled_quantity             	 	NUMBER          DEFAULT FND_API.G_MISS_NUM,
	cancelled_quantity2            		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	carrier_id				NUMBER 	 	DEFAULT FND_API.G_MISS_NUM ,
	classification                 		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	commodity_code_cat_id          		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	container_flag            		VARCHAR2(1)    	DEFAULT FND_API.G_MISS_CHAR,
	container_name            		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	container_type_code            		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	country_of_origin              		VARCHAR2(150)    DEFAULT FND_API.G_MISS_CHAR,
	currency_code      			VARCHAR2(15)  	DEFAULT FND_API.G_MISS_CHAR ,
	cust_model_serial_number       		VARCHAR2(50)    DEFAULT FND_API.G_MISS_CHAR,
	cust_po_number				VARCHAR2(50)  	DEFAULT FND_API.G_MISS_CHAR ,
	customer_dock_code			VARCHAR2(50)  	DEFAULT FND_API.G_MISS_CHAR ,
	customer_id                    		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	customer_item_id               		NUMBER         	DEFAULT FND_API.G_MISS_NUM ,
	customer_job                   		VARCHAR2(50)    DEFAULT FND_API.G_MISS_CHAR,
	customer_prod_seq			VARCHAR2(50)  	DEFAULT FND_API.G_MISS_CHAR ,
	customer_production_line       		VARCHAR2(50)    DEFAULT FND_API.G_MISS_CHAR,
	customer_requested_lot_flag	        VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	cycle_count_quantity              	NUMBER    	DEFAULT FND_API.G_MISS_NUM ,    -- added for Backordering
	cycle_count_quantity2            	NUMBER    	DEFAULT FND_API.G_MISS_NUM ,
	date_requested				DATE 		DEFAULT FND_API.G_MISS_DATE ,
	date_scheduled				DATE 		DEFAULT FND_API.G_MISS_DATE ,
	deliver_to_contact_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	deliver_to_org_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	delivered_quantity             		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	delivered_quantity2            		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	delivery_detail_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	dep_plan_required_flag			VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	detail_container_item_id		NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	fill_percent                   		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	fob_code				VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
        freight_carrier_code                    VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR ,
	freight_class_cat_id           		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	freight_terms_code			VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
	gross_weight				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	hazard_class_id                		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	hold_code				VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	inspection_flag    			VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,   -- added for Contracts
	intmed_ship_to_contact_id		NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	intmed_ship_to_org_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	inv_interfaced_flag            		VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
	inventory_item_id              		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	item_description               		VARCHAR2(250)   DEFAULT FND_API.G_MISS_CHAR,
	item_type_code				VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
	line_number 		 		VARCHAR2(150) 	DEFAULT FND_API.G_MISS_CHAR, -- Bug 1610845
	load_seq_number                		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	locator_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	lot_id                            	NUMBER   	DEFAULT FND_API.G_MISS_NUM ,
-- HW OPMCONV. Need to expand length of lot_number to 80
	lot_number				VARCHAR2(80)  	DEFAULT FND_API.G_MISS_CHAR ,
	lpn_content_id                 		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	lpn_id                         		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	master_container_item_id		NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	master_serial_number           		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	maximum_load_weight            		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	maximum_volume                 		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	minimum_fill_percent           		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	move_order_line_id             		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	movement_id                    		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	mvt_stat_status                		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	net_weight				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	oe_interfaced_flag             		VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
	order_quantity_uom			VARCHAR2(3)  	DEFAULT FND_API.G_MISS_CHAR ,
	ordered_quantity			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ordered_quantity2                 	NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ordered_quantity_uom2             	VARCHAR2(3)  	DEFAULT FND_API.G_MISS_CHAR ,
	org_id                         		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	organization_id                		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	original_source_line_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	original_subinventory    		VARCHAR2(10) 	DEFAULT FND_API.G_MISS_CHAR,
	packing_instructions			VARCHAR2(2000)  DEFAULT FND_API.G_MISS_CHAR ,
	pending_quantity			NUMBER 		DEFAULT FND_API.G_MISS_NUM,	 -- overpicking bug 1848530
	pending_quantity2			NUMBER 		DEFAULT FND_API.G_MISS_NUM, 	 -- overpicking bug 1848530
	pickable_flag          			VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	picked_quantity				NUMBER 		DEFAULT FND_API.G_MISS_NUM,	 -- overpicking bug 1848530
	picked_quantity2			NUMBER 		DEFAULT FND_API.G_MISS_NUM,	 -- overpicking bug 1848530
-- HW OPMCONV. Need to expand length of grade to 150
	preferred_grade                   	VARCHAR2(150)  	DEFAULT FND_API.G_MISS_CHAR ,
	project_id                     		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	quality_control_quantity       		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	quality_control_quantity2      		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	received_quantity                     	NUMBER          DEFAULT FND_API.G_MISS_NUM,
	received_quantity2                     	NUMBER          DEFAULT FND_API.G_MISS_NUM,
	released_status                     	VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
	request_id                     		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	revision				VARCHAR2(3)  	DEFAULT FND_API.G_MISS_CHAR ,
	seal_code                      		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	serial_number				VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
	ship_from_org_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ship_model_complete_flag		VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	ship_set_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ship_to_contact_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ship_to_org_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ship_to_site_use_id            		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	ship_tolerance_above			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	ship_tolerance_below			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	shipment_priority_code			VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
	shipped_flag            		VARCHAR2(1)  	DEFAULT FND_API.G_MISS_CHAR ,
	shipped_quantity                        NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	shipped_quantity2                       NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	shipping_instructions			VARCHAR2(2000)  DEFAULT FND_API.G_MISS_CHAR ,
	shipping_method_code		 	VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
	sold_to_contact_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	sold_to_org_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	source_code                    		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	source_header_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	source_header_number                    VARCHAR2(150)   DEFAULT FND_API.G_MISS_CHAR,
	source_header_type_id                   NUMBER          DEFAULT FND_API.G_MISS_NUM,
	source_header_type_name                 VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	source_line_id				NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	source_line_set_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	split_from_delivery_detail_id           NUMBER          DEFAULT FND_API.G_MISS_NUM,
	src_requested_quantity                  NUMBER          DEFAULT FND_API.G_MISS_NUM,
	src_requested_quantity2                 NUMBER          DEFAULT FND_API.G_MISS_NUM,
	src_requested_quantity_uom              VARCHAR2(3)     DEFAULT FND_API.G_MISS_CHAR,
	src_requested_quantity_uom2             VARCHAR2(3)     DEFAULT FND_API.G_MISS_CHAR,
	subinventory				VARCHAR2(10)  	DEFAULT FND_API.G_MISS_CHAR ,
-- HW OPMCONV. No need for sublot anymore
--      sublot_number                           VARCHAR2(32)  	DEFAULT FND_API.G_MISS_CHAR ,
	task_id                                 NUMBER          DEFAULT FND_API.G_MISS_NUM,
	to_serial_number                        VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	top_model_line_id			NUMBER  	DEFAULT FND_API.G_MISS_NUM ,
	tp_attribute1                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute10                          VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute11                          VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute12                          VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute13                          VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute14                          VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute15                          VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute2                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute3                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute4                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute5                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute6                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute7                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute8                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute9                           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tp_attribute_category                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
	tracking_number                         VARCHAR2(30)  	DEFAULT FND_API.G_MISS_CHAR ,
	trans_id 				NUMBER 		DEFAULT FND_API.G_MISS_NUM,       -- NC OPM changes BUG #1636578
	transaction_temp_id            		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	transfer_lpn_id    			NUMBER    	DEFAULT FND_API.G_MISS_NUM ,    -- added for cross-docking
	unit_number                    		VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
	unit_price                     		NUMBER          DEFAULT FND_API.G_MISS_NUM,
	volume					NUMBER  	DEFAULT FND_API.G_MISS_NUM,
	volume_uom_code			        VARCHAR2(3)  	DEFAULT FND_API.G_MISS_CHAR ,
	weight_uom_code			        VARCHAR2(3)  	DEFAULT FND_API.G_MISS_CHAR,
--added for calc. TP dates
	latest_acceptable_date                  DATE 	DEFAULT FND_API.G_MISS_DATE ,
	promise_date                            DATE 	DEFAULT FND_API.G_MISS_DATE ,
	schedule_arrival_date                   DATE 	DEFAULT FND_API.G_MISS_DATE ,
	earliest_acceptable_date                DATE 	DEFAULT FND_API.G_MISS_DATE ,
	earliest_ship_date                      DATE 	DEFAULT FND_API.G_MISS_DATE, --demand_satisfaction_date from TP
        -- J: W/V Changes
        filled_volume                           NUMBER  DEFAULT FND_API.G_MISS_NUM,
        client_id                                NUMBER -- LSP PROJECT
);

TYPE ChangedAttributeTabType IS TABLE OF ChangedAttributeRecType
        INDEX BY BINARY_INTEGER;

-- anxsharm for Load Tender
-- Used to take the snap shot before the call is made from INV or OM
TYPE delivery_detail_rec is RECORD
		(delivery_detail_id	WSH_DELIVERY_DETAILS.DELIVERY_DETAIL_ID%TYPE,
		 requested_quantity     WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY%TYPE,
		 shipped_quantity       WSH_DELIVERY_DETAILS.SHIPPED_QUANTITY%TYPE,
		 picked_quantity        WSH_DELIVERY_DETAILS.PICKED_QUANTITY%TYPE,
		 gross_weight           WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE,
		 net_weight             WSH_DELIVERY_DETAILS.NET_WEIGHT%TYPE,
		 weight_uom_code        WSH_DELIVERY_DETAILS.WEIGHT_UOM_CODE%TYPE,
		 volume                 WSH_DELIVERY_DETAILS.VOLUME%TYPE,
		 volume_uom_code        WSH_DELIVERY_DETAILS.VOLUME_UOM_CODE%TYPE,
                 delivery_id            wsh_delivery_assignments_v.DELIVERY_ID%TYPE,
                 parent_delivery_detail_id  wsh_delivery_assignments_v.PARENT_DELIVERY_DETAIL_ID%TYPE,
                 released_status        WSH_DELIVERY_DETAILS.RELEASED_STATUS%TYPE
                );
TYPE DeliveryDetailTab IS TABLE OF delivery_detail_rec INDEX BY BINARY_INTEGER;

--
--  Procedure:          Update_Shipping_Attributes
--  Parameters:         p_source_code,
--                      p_changed_so_attributes,
--                      x_return_status
--                      p_log_level
--  Description:        This procedure can be called when shipment
--                      line has been changed or cancelled.
--                      For example, if Order Entry sales order line
--                      information has been changed, then the
--                      p_source_code = "OE",
--                      p_source_header_id = OE_HEADERS.HEADER_ID,
--                      p_original_source_entity_id = OE_LINES.LINE_ID.
--                      The user has to fill up the changed attributes
--                      table according to what has been changed
--                      for the specified line. The action will result
--                      in a staus of 0 - success, 1 - failure.
--
PROCEDURE Update_Shipping_Attributes
                (p_source_code              	IN     	VARCHAR2,
                 p_changed_attributes		IN     	ChangedAttributeTabType,
		 x_return_status		OUT NOCOPY 	VARCHAR2,
                 p_log_level                    IN      NUMBER  DEFAULT FND_API.G_MISS_NUM -- log level fix
                );

-- These procedures Get_In_Transit_Qty are for TPA.
-- Bug 1569962
PROCEDURE Get_In_Transit_Qty(
                         p_source_code                  IN     VARCHAR2 DEFAULT 'OE',
			 p_customer_id			IN		NUMBER,
			 p_ship_to_org_id		IN		NUMBER,
			 p_ship_from_org_id		IN		NUMBER,
			 p_inventory_item_id		IN		NUMBER,
			 p_order_header_id		IN		NUMBER,
			 p_shipper_recs			IN		T_SHIPPER_REC,
			 p_schedule_generation_date	IN		DATE,
			 x_in_transit_qty		OUT NOCOPY 		NUMBER,
			 x_return_status		OUT NOCOPY 		VARCHAR2);
PROCEDURE Get_In_Transit_Qty(
                         p_source_code                  IN     VARCHAR2 DEFAULT 'OE',
			 p_customer_id				IN		NUMBER,
			 p_ship_to_org_id		IN		NUMBER,
			 p_ship_from_org_id		IN		NUMBER,
			 p_inventory_item_id		IN		NUMBER,
			 p_order_header_id			IN		NUMBER,
			 p_cust_production_seq_num	IN 	VARCHAR2,
			 p_shipper_recs			IN		T_SHIPPER_REC,
			 p_schedule_generation_date	IN		DATE,
			 p_shipment_date			IN		DATE,
			 x_in_transit_qty			OUT NOCOPY 		NUMBER,
			 x_return_status			OUT NOCOPY 		VARCHAR2);

--
--  Procedure:      Import_Delivery_Details
--  Parameters:     errbuf
--                  retcode
--                  p_source_line_id
--                  p_source_code
--  Description:    Concurrent program procedure will import a delivery details or all
--                  eligible delivery details into shipping.
--

PROCEDURE Import_Delivery_Details
			 (errbuf		OUT NOCOPY  VARCHAR2,
			  retcode		OUT NOCOPY  VARCHAR2,
			  p_source_line_id	IN  NUMBER,
			  p_source_code		IN  VARCHAR2
			 );

--
--  Procedure:      Default_Container
--  Parameters:     p_delivery_detail_id
--                  x_return_status
--  Description:    This procedure will set default master and detail container
--                  item id for delivery details.    If there is no
--				corresponding master/detail container info for ordered
--				item, these two fields will remain as old values.
--

PROCEDURE Default_Container(
  p_delivery_detail_id 					IN 	 NUMBER
, x_return_status				   	OUT NOCOPY       VARCHAR2
);

PROCEDURE Populate_detail_info(
  p_old_delivery_detail_info     	IN 	 WSH_DELIVERY_DETAILS%ROWTYPE
, x_new_delivery_detail_info          OUT NOCOPY wsh_glbl_var_strct_grp.delivery_details_rec_type
, x_return_status          		      OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Details(
  p_details_id     IN WSH_UTIL_CORE.Id_Tab_Type
, x_return_status   OUT NOCOPY  VARCHAR2);

PROCEDURE Get_Max_Load_Qty(
			 p_move_order_line_id		IN		NUMBER,
			 x_max_load_quantity		OUT NOCOPY 		NUMBER,
			 x_container_item_id		OUT NOCOPY 		NUMBER,
			 x_return_status			OUT NOCOPY 		VARCHAR2);



--
--  Procedure:          Lock_Records
--  Parameters:
--               p_source_code         source system of records to lock
--               p_changed_attributes  list of records to lock
--               x_interface_flag      'Y' if in OM Interface, 'N' if normal process
--               x_return_status       return status
--
--  Description:
--               Lock the records' delivery lines if the action is not Import.
--               It will check whether the process is normal or during OM Interface.
--               If the process is normal, it will verify the records' delivery lines are not
--               shipped or in confirmed deliveries.
PROCEDURE Lock_Records(
  p_source_code            IN      VARCHAR2,
  p_changed_attributes     IN      ChangedAttributeTabType,
  x_interface_flag         OUT NOCOPY      VARCHAR2,
  x_return_status          OUT NOCOPY      VARCHAR2);



--
--  Procedure:          Lock_Delivery_Detail
--  Parameters:
--               p_delivery_detail_id  delivery detail to lock
--               p_source_code         source system to lock
--               x_confirmed_flag      set to TRUE if its delivery is confirmed
--               x_shipped_flag        set to TRUE if it is shipped
--               x_interface_flag      set to 'Y' if source_line_id < 0
--               x_return_status       return status
--
--  Description:
--               Lock the delivery line and its assignment record.
--               Also set the flags if conditions are met.
--               Note: if x_interface_flag becomes 'Y', the other flags will not be updated further.
PROCEDURE Lock_Delivery_Detail(
  p_delivery_detail_id     IN          NUMBER,
  p_source_code            IN          VARCHAR2,
  x_confirmed_flag         IN OUT NOCOPY       BOOLEAN,
  x_shipped_flag           IN OUT NOCOPY       BOOLEAN,
  x_interface_flag         IN OUT NOCOPY       VARCHAR2,
  x_return_status             OUT NOCOPY       VARCHAR2);



--
--  Procedure:          Process_Records
--  Parameters:
--               p_source_code         source system of records to process
--               p_changed_attributes  list of records to process
--               p_interface_flag      'Y' if in OM Interface, 'N' if normal process
--               x_return_status       return status
--
--  Description:
--               Main loop for performing actions on the records.
PROCEDURE Process_Records(
  p_source_code            IN     VARCHAR2,
  p_changed_attributes     IN     ChangedAttributeTabType,
  p_interface_flag         IN     VARCHAR2,
  x_return_status          OUT NOCOPY     VARCHAR2);



--
--  Procedure:          PRINTMSG
--  Parameters:
--               txt                   concurrent log text
--               name                  Message name
--
--  Description:
--               Sets a message if online or prints to log if concurrent.
PROCEDURE PRINTMSG (txt VARCHAR2,
                    name VARCHAR2 DEFAULT NULL);

--
--  Procedure:          cancel_details
--  Parameters:
--               p_details_id          table of delivery detail ids
--               x_return_status       return status
--
--  Description:
--               Cancels the delivery details
PROCEDURE Cancel_Details(
  p_details_id     IN WSH_UTIL_CORE.Id_Tab_Type
, x_return_status   OUT NOCOPY VARCHAR2);


END WSH_INTERFACE;

/
