--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHDDTHS.pls 120.4.12010000.2 2010/08/06 16:18:15 anvarshn ship $ */

--==============DECLARE CONSTANTS =======================================
-- Declare Constants for Various released status of delivery detail

  C_READY_TO_RELEASE             CONSTANT VARCHAR2(1) := 'R';
  C_RELEASED_TO_WAREHOUSE        CONSTANT VARCHAR2(1) := 'S';
  C_STAGED                       CONSTANT VARCHAR2(1) := 'Y';
  C_SHIP_CONFIRMED               CONSTANT VARCHAR2(1) := 'C';
  C_INTERFACED                   CONSTANT VARCHAR2(1) := 'I';
  C_BACKORDERED                  CONSTANT VARCHAR2(1) := 'B';
  C_PLANNED_FOR_XDOCK            CONSTANT VARCHAR2(1) := 'K';
  C_NOT_APPLICABLE               CONSTANT VARCHAR2(1) := 'X';
  C_CANCELLED                    CONSTANT VARCHAR2(1) := 'D';

--========================================================================

--==============DECLARE RECORD/TABLE STRUCTURES=======================================

/* Do not use Delivery_Details_Rec_Type, use the record defined in
   wsh_glbl_var_strct_grp
*/
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
-- HW OPMCONV. Need to expand length of lot_number to 80
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
-- hverddin 26-jun-2000 start of OPM changes
-- HW OPMCONV. Need to expand length of grade to 150
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
-- HW OPMCONV. No need for sublot anymore
--   sublot_number                 VARCHAR2(32) ,
-- hverddin 26-jun-2000 end of OPM changes
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
        transaction_id                  NUMBER,  -----2803570
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
        -- J: W/V Changes
        unit_weight                     NUMBER,
        unit_volume                     NUMBER,
        filled_volume                   NUMBER,
        wv_frozen_flag                  VARCHAR2(1),
        mode_of_transport               VARCHAR2(30),
        service_level                   VARCHAR2(30),
        po_revision_number              NUMBER,
        release_revision_number         NUMBER,
        consignee_flag                  VARCHAR2(1)     --RTV changes
      );

	TYPE Delivery_Assignments_Rec_Type IS RECORD(
	delivery_assignment_id		NUMBER,
	delivery_id				NUMBER,
	parent_delivery_id			NUMBER,
	delivery_detail_id			NUMBER,
	parent_delivery_detail_id	NUMBER,
	creation_date				DATE,
	created_by				NUMBER,
	last_update_date			DATE,
	last_updated_by			NUMBER,
	last_update_login			NUMBER,
	program_application_id		NUMBER,
	program_id				NUMBER,
	program_update_date			DATE,
	request_id				NUMBER,
	active_flag				VARCHAR2(1),
        received_quantity                       NUMBER,
        received_quantity2                      NUMBER,
        source_line_set_id                      NUMBER,
        TYPE                                    VARCHAR2(30)
	);

/* Do not use Delivery_Details_Attr_Tbl_Type, use the table defined in
   wsh_glbl_var_strct_grp
*/
TYPE Delivery_Details_Attr_Tbl_Type is TABLE of Delivery_Details_Rec_Type index by binary_integer;

--========================================================================

--==============DECLARE PROCEDURES =======================================
--

	--
	--  Procedure:   create_new_detail_from_old
	--  Parameters:  A Delivery Detail RecType with values only in the columns to be changed,
        --               Old delivery detail id from which the new to be copied
	--               Row_id out
	--               Delivery_Detail_id out
	--               Return_Status out
	--  Description: This procedure will create a new delivery detail.
        --               It copies values of unchanged attributes from the old delivery detail
	--               It will return the delivery_detail_id
	--  Prereq:      Use initialize_detail() to initialize the record type
        --               Then (optionally) modify whichever attributes you need to in that record
        --               And then pass it along with the old delivery delivery detail id to be copied from
        PROCEDURE create_new_detail_from_old(
            p_delivery_detail_rec   IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
            p_delivery_detail_id    IN NUMBER,
            x_row_id         OUT NOCOPY  VARCHAR2,
            x_delivery_detail_id OUT NOCOPY  NUMBER,
            x_return_status OUT NOCOPY  VARCHAR2);

-- This API has been created for
-- BULK OPERATION in Auto Packing
        PROCEDURE create_dd_from_old_bulk(
            p_delivery_detail_rec   IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
            p_delivery_detail_id    IN NUMBER,
            p_num_of_rec    IN NUMBER,
            x_dd_id_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
            x_return_status OUT NOCOPY  VARCHAR2
            );

-- This API has been created for
-- BULK OPERATION in Auto Packing
-- used after call to create_delivery_details as well as
-- create_new_dd_from_old

	PROCEDURE Create_Deliv_Assignment_bulk(
	    p_delivery_assignments_info	IN Delivery_Assignments_Rec_TYPE,
            p_num_of_rec    IN NUMBER,
            p_dd_id_tab                     IN WSH_UTIL_CORE.id_tab_type,
            x_da_id_tab                     OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
            x_return_status			OUT NOCOPY  VARCHAR2
	    );


	--
	--  Procedure:   Create_Delivery_Detail
	--  Parameters:  All Attributes of a Delivery Detail Record,
	--               Row_id out
	--               Delivery_Detail_id out
	--               Return_Status out
	--  Description: This procedure will create a delivery detail.
	--               It will return to the use the delivery_detail_id
	--               if not provided as a parameter.
	--


-- added new parameter to use this API
	PROCEDURE Create_Delivery_Details(
		p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
		x_rowid			OUT NOCOPY  VARCHAR2,
		x_delivery_detail_id	OUT NOCOPY  NUMBER,
		x_return_status		OUT NOCOPY  VARCHAR2
               );

	PROCEDURE Create_Delivery_Details_Bulk(
		p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
                p_num_of_rec            IN NUMBER,
                -- lpn conv
                p_container_info_rec    IN  WSH_GLBL_VAR_STRCT_GRP.ContInfoRectype,
		x_return_status		OUT NOCOPY  VARCHAR2,
                x_dd_id_tab             OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
               );

	--
   	--  Procedure:   Delete_Delivery_Detail
	--  Parameters:  All Attributes of a Delivery Detail Record
	--  Description: This procedure will delete a delivery detail.
	--

    PROCEDURE Delete_Delivery_Details(
		p_rowid 		IN VARCHAR2 := NULL,
		p_delivery_detail_id 	IN NUMBER := NULL,
                p_cancel_flag           IN VARCHAR2 DEFAULT NULL,
		x_return_status 	OUT NOCOPY  VARCHAR2);


	--
	--  Procedure:   Lock_Delivery_Details
	--  Parameters:  All Attributes of a Delivery Detail Record
	--  Description: This procedure will lock a delivery detail
	--               record. It is specifically designed for
	--               use by the form.
	--

    PROCEDURE Lock_Delivery_Details(
		p_rowid			IN VARCHAR2,
		p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type);


	--
	--  Procedure:   Update_Delivery_Line
	--  Parameters:  All Attributes of a Delivery Line Record
	--  Description: This procedure will update attributes of
	--               a delivery line.
	--


    	PROCEDURE Update_Delivery_Details(
		p_rowid			IN VARCHAR2 := NULL,
		p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
		x_return_status         OUT NOCOPY  VARCHAR2
                );
	--
	--  Procedure:   Create_Delivery_Assignments
	--  Parameters:  All Attributes of a Delivery Assignment Record,
	--               Row_id out
	--               Delivery_Assignment_id out
	--               Return_Status out
	--  Description: This procedure will create a delivery_assignment
	--               It will return to the use the delivery_assignment_id
	--               if not provided as a parameter.
	--

	PROCEDURE Create_Delivery_Assignments(
		p_delivery_assignments_info	IN Delivery_Assignments_Rec_TYPE,
		x_rowid				OUT NOCOPY  VARCHAR2,
		x_delivery_assignment_id	OUT NOCOPY  NUMBER,
		x_return_status			OUT NOCOPY  VARCHAR2
		);
	--
	--  Procedure:   Delete_Delivery_Assignments
	--  Parameters:  All Attributes of a Delivery Assignment Record,
	--               Row_id out
	--               Delivery_Assignment_id out
	--               Return_Status out
	--  Description: This procedure will delete a delivery assignment.
	--               It will return to the use the delivery_assignment id
	--               if not provided as a parameter.
	--
        --  OTM R12 : This procedure was reviewed during OTM R12 frontport
        --            but not modified since it's not called from anywhere.
        --            Procedure body should be modified properly when it will be
        --            in use. Refer to TDD for the details of expected changes.


	PROCEDURE Delete_Delivery_Assignments(
		p_rowid				IN VARCHAR2 := NULL,
		p_delivery_assignment_id	IN NUMBER := NULL,
		x_return_status			OUT NOCOPY  VARCHAR2
		);

	--
	--  Procedure:   Update_Delivery_Assignments
	--  Parameters:
	--               Row_id in
	--               Return_Status out
	--  Description: This procedure will update a delivery assignment.
	--
        --  OTM R12 : This procedure was reviewed during OTM R12 frontport
        --            but not modified since it's not called from anywhere.
        --            Procedure body should be modified properly when it will be
        --            in use. Refer to TDD for the details of expected changes.

	PROCEDURE Update_Delivery_Assignments(
		p_rowid				IN VARCHAR2 := NULL,
		p_delivery_assignments_info	IN Delivery_Assignments_Rec_Type,
		x_return_status			OUT NOCOPY  VARCHAR2);
	--
	--  Procedure:   Lock_Delivery_Assignments
	--  Parameters:  All Attributes of a Delivery Assignment Record,
	--               Row_id in
	--               Return_Status out
	--  Description: This procedure will lock a delivery assignment.
	--

	PROCEDURE Lock_Delivery_Assignments(
		p_rowid                  	IN VARCHAR2,
		p_delivery_assignments_info   	IN Delivery_Assignments_Rec_Type,
		x_return_status			OUT NOCOPY  VARCHAR2);

	--
	--  Procedure:   Lock_Delivery_Details Wrapper
	--  Parameters:  A table of all attributes of a Delivery detail Record,
	--               Caller in
	--               Return_Status,Valid_index_id_tab out
	--  Description: This procedure will lock multiple delivery details.

        procedure Lock_Delivery_Details(
	        p_rec_attr_tab		IN		WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
                p_caller		IN		VARCHAR2,
                p_valid_index_tab       IN              wsh_util_core.id_tab_type,
                x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
	        x_return_status		OUT		NOCOPY VARCHAR2
);


/*    ---------------------------------------------------------------------
     Procedure:	Lock_Detail_No_Compare

     Parameters:	Delivery_Detail Id DEFAULT NULL
                         Delivery Id        DEFAULT NULL

     Description:  This procedure is used for obtaining locks of lines/lpns
                    using the delivery_detail_id or the delivery_id.
                    This is called by delivery detail's wrapper lock API when the p_caller is NOT WSHFSTRX.
                   It is also called by delivery's wrapper lock API when the
                   action is CONFIRM, AUTO-PACK or AUTO-PACK-MASTER.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:   Harmonization Project. Patchset I
     ----------------------------------------------------------------------- */

        Procedure lock_detail_no_compare(
                p_delivery_detail_id   IN    NUMBER DEFAULT NULL,
                p_delivery_id          IN    NUMBER DEFAULT NULL);

	--  Bug 3292364
	--  Procedure:   Table_To_Record
	--  Parameters:  x_delivery_detail_rec: A record of all attributes of a Delivery detail Record
	--               p_delivery_detail_id : delivery_detail_id of the detail that is to be copied
	--               Return_Status,
	--  Description: This procedure will copy the attributes of a delivery detail in wsh_delivery_details
        --               and copy it to a record.


        Procedure Table_To_Record(
          p_delivery_detail_id IN NUMBER,
          x_delivery_detail_rec OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
          x_return_status OUT NOCOPY VARCHAR2);


      -- Locks wsh_delivery assignments based on delivery or delivery detail entered.
      Procedure lock_wda_no_compare(
                p_delivery_detail_id   IN    NUMBER DEFAULT NULL,
                p_delivery_id          IN    NUMBER DEFAULT NULL);


END WSH_DELIVERY_DETAILS_PKG;

/
