--------------------------------------------------------
--  DDL for Package WSH_ROUTING_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ROUTING_REQUEST" AUTHID CURRENT_USER as
/* $Header: WSHRORQS.pls 120.0 2005/05/26 17:05:02 appldev noship $ */


TYPE tbl_number		is	table of number index by binary_integer;
TYPE tbl_var1		is 	table of varchar2(1) index by binary_integer;
TYPE tbl_var3		is 	table of varchar2(3) index by binary_integer;
TYPE tbl_var15		is 	table of varchar2(15) index by binary_integer;
TYPE tbl_var30		is 	table of varchar2(30) index by binary_integer;
TYPE tbl_var40		is 	table of varchar2(40) index by binary_integer;
TYPE tbl_var60		is 	table of varchar2(60) index by binary_integer;
TYPE tbl_var150		is 	table of varchar2(150) index by binary_integer;
TYPE tbl_var240		is 	table of varchar2(240) index by binary_integer;
TYPE tbl_var500		is 	table of varchar2(500) index by binary_integer;
TYPE tbl_var2000	is 	table of varchar2(2000) index by binary_integer;
TYPE tbl_var32767	is 	table of varchar2(32767) index by binary_integer;
TYPE tbl_date		is 	table of date index by binary_integer;


--Record to store input parameter as passed from Routing Request/Supplier Address Book UI.
TYPE In_param_Rec_Type IS RECORD (
caller		varchar2(2000), --WSH:Shipping ISP:iSupplier Protal.
user_id		number,         --User Id, passed if caller is ISP.
txn_type	varchar2(2000), --RREQ:Routing Request SAB:Supplier Address Book.
date_format 	varchar2(2000)  --UI date format need to be same with server date format.
);


--Routing Resquest Header Record type
TYPE Header_Rec_Type is Record (
Supplier_name			tbl_var240,
Request_date			tbl_date,
Request_Number			tbl_var40, --vendor merge change
Request_revision		tbl_number,
error_flag			tbl_var1
);


--Routing Resquest Delivery Record type
TYPE Delivery_Rec_type is Record (
Header_line_number		tbl_number,
Ship_From_Address1		tbl_var240,
Ship_From_Address2		tbl_var240,
Ship_From_Address3		tbl_var240,
Ship_From_Address4		tbl_var240,
Ship_From_city			tbl_var60,
Ship_From_state			tbl_var60,
Ship_From_county		tbl_var60,
Ship_From_country		tbl_var60,
Ship_From_province		tbl_var60,
Ship_From_postal_code		tbl_var60,
Ship_From_code			tbl_var30,
Shipper_name			tbl_var240,
Phone				tbl_var40,
email				tbl_var500,
Number_of_containers		tbl_number,
total_weight			tbl_number,
weight_uom			tbl_var3,
total_volume 			tbl_number,
volume_UOM			tbl_var3,
remark				tbl_var500,
error_flag			tbl_var1
);


--Routing Resquest Line Record type
TYPE Line_Rec_type is Record (
Delivery_line_number		tbl_number,
Po_Header_number		tbl_var150,
Po_Release_number		tbl_number,
PO_Line_number			tbl_var150,
PO_Shipment_number		tbl_number,
Po_Operating_unit		tbl_var240,
Item_quantity			tbl_number,
Item_uom			tbl_var3,
weight				tbl_number,
Weight_uom			tbl_var3,
volume 				tbl_number,
Volume_UOM			tbl_var3,
Earliest_pickup_date		tbl_date,
Latest_pickup_date		tbl_date,
error_flag			tbl_var1
);


--Address book Line Record type
TYPE Address_Rec_Type is Record (
Supplier_name			tbl_var240,
Ship_From_Address1		tbl_var240,
Ship_From_Address2		tbl_var240,
Ship_From_Address3		tbl_var240,
Ship_From_Address4		tbl_var240,
Ship_From_city			tbl_var60,
Ship_From_state			tbl_var60,
Ship_From_county		tbl_var60,
Ship_From_country		tbl_var60,
Ship_From_province		tbl_var60,
Ship_From_postal_code		tbl_var60,
Ship_From_code			tbl_var30,
Shipper_name			tbl_var240,
Phone				tbl_var40,
email				tbl_var500,
action				tbl_var15,
error_flag			tbl_var1
);

--Record to hold data passed between different api.
TYPE detail_att_rec_type IS RECORD (
        delivery_detail_id	number,
        inventory_item_id	number,
	requested_quantity_uom	varchar2(3),
	requested_quantity	number,
	requested_quantity_uom2	varchar2(3),
	requested_quantity2	number,
	item_quantity		number,
	weight			number,
        weight_uom		varchar2(3),
	volume			number,
        volume_uom		varchar2(3),
	Earliest_pickup_date	date,
	Latest_pickup_date	date,
        date_requested		date,
	earliest_dropoff_date	date,
	latest_dropoff_date	date,
        organization_id		number,
        routing_req_id		number,
        prev_routing_req_id	number,
        vendor_id		number,
        party_id		number,
        ship_from_location_id	number,
        party_site_id		number,
        source_header_number	varchar2(150),
        source_header_type_id   number,
        source_header_type_name	varchar2(240),
	org_id			number,
	released_status		varchar2(1),
	source_code		varchar2(30),
	dd_net_weight		number,
	dd_gross_weight		number,
	dd_volume		number,
        dd_wv_frozen_flag	varchar2(1)
);


-- Start of comments
-- API name : Process_File
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to upload routing request and Supplier Address Book. This api is called
--            from Routing Request/Supplier Address Book UI. Api does
--           1.Intilized the message global table.
--           2.Based on transaction type called the corresponding
--             wrapper api for processing.
-- Parameters :
-- IN:
--      p_caller        IN              WSH/ISP
--      p_txn_type      IN              RREQ -For Routing Request, SAB for Supplier Address Book.
--      p_user_id       IN              Passed if caller is ISP.
--      p_date_format   IN              UI date format need to be same with server date format.
--      p_file_fields   IN              List of fields as parse from Routing Request/Supplier Address book file.
-- OUT:
--      x_message_tbl   OUT NOCOPY      List of success/error messages return to calling api.
--      x_return_status OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE Process_File(
        p_caller	IN  VARCHAR2,
        p_txn_type	IN  VARCHAR2,
	p_user_id	IN  NUMBER,
        p_date_format   IN  VARCHAR2,
        p_file_fields   IN  WSH_FILE_RECORD_TYPE ,
        x_message_tbl   OUT NOCOPY WSH_FILE_MSG_TABLE,
        x_return_status OUT NOCOPY      varchar2);


END WSH_ROUTING_REQUEST;

 

/
