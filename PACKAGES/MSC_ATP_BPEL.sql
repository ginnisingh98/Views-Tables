--------------------------------------------------------
--  DDL for Package MSC_ATP_BPEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_BPEL" AUTHID CURRENT_USER AS
/* $Header: MSCATPBS.pls 120.0 2007/12/18 10:12:42 arrsubra noship $  */

TYPE ATP_Rec_Scalar_Typ is RECORD (
Row_Id				varchar2(30),
Instance_Id                     number,
Inventory_Item_Id               number,
Inventory_Item_Name		varchar2(40),
Source_Organization_Id          number,
Source_Organization_Code	varchar2(7),
Organization_Id 		number,
Identifier                      number,
Demand_Source_Header_Id		number,
Demand_Source_Delivery          varchar2(30),
Demand_Source_Type              number,
Scenario_Id			number,
Calling_Module                  number,
Customer_Id                  	number,
Customer_Site_Id                number,
Destination_Time_Zone           varchar2(30),
Quantity_Ordered                number,
Quantity_UOM                    varchar2(3),
Requested_Ship_Date             date,
Requested_Arrival_Date          date,
Earliest_Acceptable_Date        date,
Latest_Acceptable_Date          date,
Delivery_Lead_Time              number,
Freight_Carrier                 varchar2(30),
Ship_Method                     varchar2(30),
Demand_Class                    varchar2(30),
Ship_Set_Name                   varchar2(30),
Arrival_Set_Name                varchar2(30),
Override_Flag                   varchar2(1),
Action                          number,
Ship_Date                       date,
Arrival_date 			date,
Available_Quantity              number,
Requested_Date_Quantity         number,
Group_Ship_Date                 date,
Group_Arrival_Date              date,
Vendor_Id			number,
Vendor_Name			varchar2(80),
Vendor_Site_Id			number,
Vendor_Site_Name		varchar2(80),
Insert_Flag                     number,
OE_Flag                         varchar2(1),
Atp_Lead_Time                   number,
Error_Code			number,
Message                         varchar2(2000),
End_Pegging_Id			number,
Order_Number                    number,
Old_Source_Organization_Id      number,
Old_Demand_Class                varchar2(30),
ato_delete_flag			varchar2(1),
attribute_01      		number,
attribute_02      		number,
attribute_03      		number,
attribute_04      		number,
attribute_05                	varchar2(30),
attribute_06                	varchar2(30),
attribute_07                	varchar2(30),
attribute_08                	varchar2(30),
attribute_09			date,
attribute_10			date,
customer_name                   varchar2(255),
customer_class			varchar2(30),
customer_location		varchar2(40),
customer_country		varchar2(60),
customer_state			varchar2(60),
customer_city			varchar2(60),
customer_postal_code		varchar2(60),
substitution_typ_code           number,
req_item_detail_flag            number,
request_item_id                 number,
req_item_req_date_qty           number,
req_item_available_date         date,
req_item_available_date_qty     number,
request_item_name               varchar2(40),
old_inventory_item_id           number,
sales_rep                       varchar2(255),
customer_contact                varchar2(255),
subst_flag                      number,
Top_Model_line_id               number,
ATO_Parent_Model_Line_Id        number,
ATO_Model_Line_Id               number,
Parent_line_id                  number,
match_item_id                   number,
Config_item_line_id             number,
Validation_Org                  number,
Component_Sequence_ID           number,
Component_Code                  varchar2(255),
line_number                     varchar2(80),
included_item_flag              number,
atp_flag                        varchar2(1),
atp_components_flag             varchar2(1),
wip_supply_type                 number,
bom_item_type                   number,
mandatory_item_flag             number,
pick_components_flag            varchar2(1),
base_model_id                   number,
OSS_ERROR_CODE                  number,
matched_item_name               varchar2(255),
cascade_model_info_to_comp      number,
sequence_number                 number,
firm_flag                       number,
order_line_number               number,
option_number                   number,
shipment_number                 number,
item_desc                       varchar2(255),
old_line_schedule_date          date,
old_source_organization_code    varchar2(7),
firm_source_org_id              number,
firm_source_org_code            varchar2(7),
firm_ship_date                  date,
firm_arrival_date               date,
ship_method_text                varchar2(255),
ship_set_id                     number,
arrival_set_id                  number,
PROJECT_ID                      number,
TASK_ID                         number,
PROJECT_NUMBER                  varchar2(30),
TASK_NUMBER                     varchar2(30),
attribute_11                    number,
attribute_12                    number,
attribute_13                    number,
attribute_14                    number,
attribute_15                    varchar2(30),
attribute_16                    varchar2(30),
attribute_17                    varchar2(30),
attribute_18                    varchar2(30),
attribute_19                    date,
attribute_20                    date,
Attribute_21                    number,
attribute_22                    number,
attribute_23                    number,
attribute_24                    number,
attribute_25                    varchar2(30),
attribute_26                    varchar2(30),
attribute_27                    varchar2(30),
attribute_28                    varchar2(30),
attribute_29                    date,
attribute_30                    date,
atf_date                        date,
plan_id                         number,
original_request_date		date,
receiving_cal_code              varchar2(14),
intransit_cal_code              varchar2(14),
shipping_cal_code               varchar2(14),
manufacturing_cal_code          varchar2(14),
internal_org_id                number,
first_valid_ship_arrival_date  date,
party_site_id      		number,
part_of_set			varchar2(1)     --Added in 12.0
/* Next 3 fields belong to ER 1879787 - not ported to 12.0
available_qty_orig_uom          number,
requested_date_qty_orig_uom     number,
Primary_UOM                    varchar2(3)
*/
);

TYPE ATP_Rec_Table_Typ IS TABLE OF ATP_Rec_Scalar_Typ INDEX BY BINARY_INTEGER ;


/* This procedure Call_ATP_BPEL will be the ATP API to be
   called when J Publisher is used.
   It will internally call PROCEDURE ATP_Rec_convert_tab
   to convert table of record to record of tables.
   Now call existing ATP API MRP_ATP_PUB.Call_ATP.
   Then call PROCEDURE ATP_Rec_convert_rec  to convert the record of tables
   (output of MRP_ATP_PUB.Call_ATP) to table of record.
   These are passed as OUT parameters to Call_ATP_Wrapper API.
 */


PROCEDURE ATP_Rec_convert_tab(
		p_atp_tab              IN    MSC_ATP_BPEL.ATP_Rec_Table_Typ,
		x_atp_rec              OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ );

PROCEDURE ATP_Rec_convert_rec(
		p_atp_rec              IN    MRP_ATP_PUB.ATP_Rec_Typ,
		p_atp_tab              OUT   NoCopy MSC_ATP_BPEL.ATP_Rec_Table_Typ);

PROCEDURE Call_ATP_BPEL(
	       p_session_id    	         IN OUT NoCopy NUMBER,
               p_atp_tab                 IN    MSC_ATP_BPEL.ATP_Rec_Table_Typ,
               x_atp_tab                 OUT   NoCopy MSC_ATP_BPEL.ATP_Rec_Table_Typ,
	       x_return_status	       	 OUT   NoCopy VARCHAR2,
               x_msg_data		 OUT   NoCopy VARCHAR2,
               x_msg_count		 OUT   NoCopy NUMBER );

END MSC_ATP_BPEL;

/
