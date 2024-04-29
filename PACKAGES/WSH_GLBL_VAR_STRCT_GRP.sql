--------------------------------------------------------
--  DDL for Package WSH_GLBL_VAR_STRCT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_GLBL_VAR_STRCT_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHGVSGS.pls 120.6.12010000.6 2010/08/06 16:17:26 anvarshn ship $ */


        --
-- this is a temporarily  constant to used while WMS code is not ready
  c_wms_code_present  VARCHAR2(2) := 'Y';
  c_skip_miss_info  VARCHAR2(22) := 'WMS_WSH_SKIP_MISS_INFO';
        --
        --
        TYPE LPNRecordType is RECORD (
            tare_weight             NUMBER,
            tare_weight_uom_code    VARCHAR2(10),
            filled_volume_uom_code VARCHAR2(10)
        );

        TYPE dd_default_parameters_rec_type IS RECORD
        (
            --
            quantity_to_cc  NUMBER,
            quantity2_to_cc NUMBER,
            detail_group_params wsh_delivery_autocreate.grp_attr_rec_type
        );
        --
       TYPE v3_Tbl_Type is TABLE of VARCHAR2(3) index by binary_integer;

       TYPE v10_Tbl_Type is TABLE of VARCHAR2(10) index by binary_integer;
       TYPE v50_Tbl_Type is TABLE of VARCHAR2(50) index by binary_integer;

       TYPE num_Tbl_Type is TABLE of NUMBER index by binary_integer;


        TYPE ContInfoRectype IS RECORD (
                Lpn_ids   wsh_util_core.id_tab_type,
                Container_names  v50_Tbl_Type
        );

       TYPE dd_action_out_rec_type IS RECORD
       (
        valid_id_tab          WSH_UTIL_CORE.id_tab_type,
        selection_issue_flag  VARCHAR2(1),
        delivery_id_tab       WSH_UTIL_CORE.id_tab_type,
        result_id_tab         WSH_UTIL_CORE.id_tab_type,
        split_quantity        NUMBER,
        split_quantity2       NUMBER,
        source_header_id_tab wsh_util_core.id_tab_type,
        source_line_id_tab wsh_util_core.id_tab_type,
        quantity_tab wsh_util_core.id_tab_type,
        source_code_id_tab v3_tbl_type);

        --

       TYPE ddActionsInOutRecType  IS RECORD
       (
          split_quantity   NUMBER,
          split_quantity2  NUMBER
       );
        --
        TYPE ddSerialRangeRecType IS RECORD
        (
          delivery_detail_id NUMBER,
          from_serial_number VARCHAR2(30),
          to_serial_number   VARCHAR2(30),
          quantity           NUMBER,
          attribute_category VARCHAR2(30),
          attribute1         VARCHAR2(150),
          attribute2         VARCHAR2(150),
          attribute3         VARCHAR2(150),
          attribute4         VARCHAR2(150),
          attribute5         VARCHAR2(150),
          attribute6         VARCHAR2(150),
          attribute7         VARCHAR2(150),
          attribute8         VARCHAR2(150),
          attribute9         VARCHAR2(150),
          attribute10        VARCHAR2(150),
          attribute11        VARCHAR2(150),
          attribute12        VARCHAR2(150),
          attribute13        VARCHAR2(150),
          attribute14        VARCHAR2(150),
          attribute15        VARCHAR2(150)
        );
        --

        TYPE ddSerialRangeTabType IS TABLE OF ddSerialRangeRecType
        INDEX BY BINARY_INTEGER;

        TYPE detailInRecType IS RECORD
        (
            --
            caller        VARCHAR2(100),
            action_code       VARCHAR2(100),
            phase       NUMBER,
            container_item_id     NUMBER,
            container_item_name   VARCHAR2(2000),
            container_item_seg    FND_FLEX_EXT.SegmentArray,
            organization_id       NUMBER,
            organization_code     VARCHAR2(3),
            name_prefix           VARCHAR2(30),
            name_suffix           VARCHAR2(30),
            base_number           NUMBER,
            num_digits            NUMBER,
            quantity              NUMBER,
            container_name        VARCHAR2(30),
            lpn_ids               wsh_util_core.id_tab_type,
            ucc_128_suffix_flag  NUMBER := 2
        );

  --
        TYPE detailOutRecType    IS   RECORD
        (
           --
           detail_ids WSH_UTIL_CORE.Id_Tab_Type
        );



TYPE Delivery_Details_Rec_Type IS RECORD
	(delivery_detail_id			NUMBER,
	source_code				VARCHAR2(30),
	source_header_id			NUMBER,
	source_line_id				NUMBER,
	customer_id				NUMBER,
	sold_to_contact_id			NUMBER,
	inventory_item_id			NUMBER,
	item_description			VARCHAR2(250),
	hazard_class_id			NUMBER,
	country_of_origin			VARCHAR2(50),
	classification				VARCHAR2(30),
	ship_from_location_id		NUMBER,
	ship_to_location_id			NUMBER,
	ship_to_contact_id			NUMBER,
	ship_to_site_use_id			NUMBER,
	deliver_to_location_id		NUMBER,
	deliver_to_contact_id		NUMBER,
	deliver_to_site_use_id		NUMBER,
	intmed_ship_to_location_id	NUMBER,
	intmed_ship_to_contact_id	NUMBER,
	hold_code					VARCHAR2(1),
	ship_tolerance_above		NUMBER,
	ship_tolerance_below		NUMBER,
	requested_quantity			NUMBER,
	shipped_quantity			NUMBER,
	delivered_quantity			NUMBER,
	requested_quantity_uom		VARCHAR2(3),
	subinventory				VARCHAR2(10),
	revision					VARCHAR2(3),
	lot_number				VARCHAR2(80),
	customer_requested_lot_flag	VARCHAR2(1),
	serial_number				VARCHAR2(30),
	locator_id				NUMBER,
	date_requested				DATE,
	date_scheduled				DATE,
	master_container_item_id		NUMBER,
	detail_container_item_id		NUMBER,
	load_seq_number			NUMBER,
	ship_method_code			VARCHAR2(30),
	carrier_id				NUMBER,
	freight_terms_code			VARCHAR2(30),
	shipment_priority_code		VARCHAR2(30),
	fob_code					VARCHAR2(30),
	customer_item_id			NUMBER,
	dep_plan_required_flag		VARCHAR2(1),
	customer_prod_seq			VARCHAR2(50),
	customer_dock_code			VARCHAR2(50),
        cust_model_serial_number                VARCHAR2(50),
        customer_job                            VARCHAR2(50),
        customer_production_line                VARCHAR2(50),
	net_weight				NUMBER,
	weight_uom_code			VARCHAR2(3),
	volume					NUMBER,
	volume_uom_code			VARCHAR2(3),
	tp_attribute_category		VARCHAR2(240),
	tp_attribute1				VARCHAR2(240),
	tp_attribute2				VARCHAR2(240),
	tp_attribute3				VARCHAR2(240),
	tp_attribute4				VARCHAR2(240),
	tp_attribute5				VARCHAR2(240),
	tp_attribute6				VARCHAR2(240),
	tp_attribute7				VARCHAR2(240),
	tp_attribute8				VARCHAR2(240),
	tp_attribute9				VARCHAR2(240),
	tp_attribute10				VARCHAR2(240),
	tp_attribute11				VARCHAR2(240),
	tp_attribute12				VARCHAR2(240),
	tp_attribute13				VARCHAR2(240),
	tp_attribute14				VARCHAR2(240),
	tp_attribute15				VARCHAR2(240),
	attribute_category			VARCHAR2(150),
	attribute1				VARCHAR2(150),
	attribute2				VARCHAR2(150),
	attribute3				VARCHAR2(150),
	attribute4				VARCHAR2(150),
	attribute5				VARCHAR2(150),
	attribute6				VARCHAR2(150),
	attribute7				VARCHAR2(150),
	attribute8				VARCHAR2(150),
	attribute9				VARCHAR2(150),
	attribute10				VARCHAR2(150),
	attribute11				VARCHAR2(150),
	attribute12				VARCHAR2(150),
	attribute13				VARCHAR2(150),
	attribute14				VARCHAR2(150),
	attribute15				VARCHAR2(150),
	created_by				NUMBER,
	creation_date				DATE,
	last_update_date			DATE,
	last_update_login			NUMBER,
	last_updated_by			NUMBER,
	program_application_id		NUMBER,
	program_id				NUMBER,
	program_update_date			DATE,
	request_id				NUMBER,
	mvt_stat_status			VARCHAR2(30),
	released_flag				VARCHAR2(1),
	organization_id			NUMBER,
	transaction_temp_id			NUMBER,
	ship_set_id				NUMBER,
	arrival_set_id				NUMBER,
	ship_model_complete_flag      VARCHAR2(1),
	top_model_line_id			NUMBER,
	source_header_number		VARCHAR2(150),
	source_header_type_id		NUMBER,
	source_header_type_name		VARCHAR2(240),
	cust_po_number				VARCHAR2(50),
	ato_line_id				NUMBER,
	src_requested_quantity		NUMBER,
	src_requested_quantity_uom	VARCHAR2(3),
	move_order_line_id			NUMBER,
	cancelled_quantity			NUMBER,
	quality_control_quantity		NUMBER,
	cycle_count_quantity		NUMBER,
	tracking_number			VARCHAR2(30),
	movement_id				NUMBER,
	shipping_instructions		VARCHAR2(2000),
	packing_instructions		VARCHAR2(2000),
	project_id				NUMBER,
	task_id					NUMBER,
	org_id					NUMBER,
	oe_interfaced_flag			VARCHAR2(1),
	split_from_detail_id		NUMBER,
	inv_interfaced_flag			VARCHAR2(1),
	source_line_number			VARCHAR2(150),
	inspection_flag               VARCHAR2(1),
	released_status			VARCHAR2(1),
	container_flag				VARCHAR2(1),
	container_type_code 		VARCHAR2(30),
	container_name				VARCHAR2(30),
	fill_percent				NUMBER,
	gross_weight				NUMBER,
	master_serial_number		VARCHAR2(30),
	maximum_load_weight			NUMBER,
	maximum_volume				NUMBER,
	minimum_fill_percent		NUMBER,
	seal_code					VARCHAR2(30),
	unit_number  				VARCHAR2(30),
	unit_price				NUMBER,
	currency_code				VARCHAR2(15),
	freight_class_cat_id          NUMBER,
	commodity_code_cat_id         NUMBER,
     preferred_grade               VARCHAR2(150),
     src_requested_quantity2       NUMBER,
     src_requested_quantity_uom2   VARCHAR2(3),
     requested_quantity2           NUMBER,
     shipped_quantity2             NUMBER,
     delivered_quantity2           NUMBER,
     cancelled_quantity2           NUMBER,
     quality_control_quantity2     NUMBER,
     cycle_count_quantity2         NUMBER,
     requested_quantity_uom2       VARCHAR2(3),
     lpn_id                         NUMBER ,
	pickable_flag                  VARCHAR2(1),
	original_subinventory          VARCHAR2(10),
        to_serial_number               VARCHAR2(30),
	picked_quantity			NUMBER,
	picked_quantity2		NUMBER,
	received_quantity		NUMBER,
	received_quantity2		NUMBER,
	source_line_set_id		NUMBER,
        batch_id                        NUMBER,
	ROWID				VARCHAR2(4000),
        transaction_id                  NUMBER,
        VENDOR_ID                       NUMBER,
        SHIP_FROM_SITE_ID               NUMBER,
        LINE_DIRECTION                  VARCHAR2(30),
        PARTY_ID                        NUMBER,
        ROUTING_REQ_ID                  NUMBER,
        SHIPPING_CONTROL                VARCHAR2(30),
        SOURCE_BLANKET_REFERENCE_ID     NUMBER,
        SOURCE_BLANKET_REFERENCE_NUM    NUMBER,
        PO_SHIPMENT_LINE_ID             NUMBER,
        PO_SHIPMENT_LINE_NUMBER         NUMBER,
        RETURNED_QUANTITY               NUMBER,
        RETURNED_QUANTITY2              NUMBER,
        RCV_SHIPMENT_LINE_ID            NUMBER,
        SOURCE_LINE_TYPE_CODE           VARCHAR2(30),
        SUPPLIER_ITEM_NUMBER            VARCHAR2(50),
        IGNORE_FOR_PLANNING             VARCHAR2(1),
        EARLIEST_PICKUP_DATE            DATE,
        LATEST_PICKUP_DATE              DATE,
        EARLIEST_DROPOFF_DATE           DATE,
        LATEST_DROPOFF_DATE             DATE,
        REQUEST_DATE_TYPE_CODE          VARCHAR2(30),
        tp_delivery_detail_id           NUMBER,
        source_document_type_id         NUMBER,
        unit_weight                     NUMBER,
        unit_volume                     NUMBER,
        filled_volume                   NUMBER,
        wv_frozen_flag                  VARCHAR2(1),
        mode_of_transport               VARCHAR2(30),
        service_level                   VARCHAR2(30),
        po_revision_number              NUMBER,
        release_revision_number         NUMBER,
        --bug# 6689448 (replenishment project)
        replenishment_status            VARCHAR2(1),
        -- R12.1 Standalone Project Start
        original_lot_number             VARCHAR2(32),
        reference_number                VARCHAR2(30),
        reference_line_number           VARCHAR2(10),
        reference_line_quantity         NUMBER,
        reference_line_quantity_uom     VARCHAR2(3),
        original_revision               VARCHAR2(3),
        original_locator_id             NUMBER,
        -- R12.1 Standalone Project End
        client_id                       NUMBER,  -- LSP PROJECT:
        -- TPW - Distributed Organization Changes - Start
        shipment_batch_id               NUMBER,
        shipment_line_number            NUMBER,
        reference_line_id               NUMBER,
        consignee_flag                  VARCHAR2(1)  -- RTV changes

        -- TPW - Distributed Organization Changes - End
      );

      TYPE Delivery_Details_Attr_Tbl_Type is TABLE of
                       Delivery_Details_Rec_Type index by binary_integer;
        TYPE dd_action_parameters_rec_type IS RECORD
        (
            -- Generic
            Caller              VARCHAR2(100),
            Action_Code         VARCHAR2(100),
            Phase               NUMBER,
            -- Assign/Unassign
            delivery_id   NUMBER ,
            delivery_name VARCHAR2(30),
            -- Calculate weight and volume
            wv_override_flag  VARCHAR2(10),
            -- Cycle Count
            quantity_to_split NUMBER,
            quantity2_to_split  NUMBER,
            -- Pack, Unpack
            container_name      VARCHAR2(30),
            container_instance_id NUMBER,
            container_flag      VARCHAR2(1),
            delivery_flag       VARCHAR2(1),
            lpn_rec Delivery_Details_Rec_Type,

            -- Autopack
            group_id_tab        wsh_util_core.id_tab_type,
            -- Split Line
            split_quantity        NUMBER,
            split_quantity2       NUMBER,
            -- Process Deliveries
            group_by_header_flag       VARCHAR(1),
	    -- bug# 6719369 (replenishment project): batch_id attribute is used by WMS for pick releasing replenishment completed dds
	    -- in dynamic replenishment case.
	    batch_id              NUMBER
            );

     TYPE lpn_sync_comm_in_rec_type IS RECORD
     (
         dummy1 NUMBER
     );

     TYPE lpn_sync_comm_out_rec_type IS RECORD
     (
         dummy1 NUMBER
     );


     TYPE sync_tmp_rec_type
     IS
     RECORD
     (
       delivery_detail_id          NUMBER,
       parent_delivery_detail_id   NUMBER,
       delivery_id                 NUMBER,
       operation_type              VARCHAR2(10),
       call_level                  NUMBER
     );

     TYPE sync_tmp_recTbl_type
     IS
     RECORD
     (
       delivery_detail_id_tbl      num_tbl_type,
       parent_detail_id_tbl        num_tbl_type,
       delivery_id_tbl             num_tbl_type,
       operation_type_tbl          v10_tbl_type,
       call_level                  num_tbl_type
     );

     TYPE purgeInOutRecType  IS Record (
     lpn_ids             wsh_util_core.id_tab_type
     );




END WSH_GLBL_VAR_STRCT_GRP;



/
