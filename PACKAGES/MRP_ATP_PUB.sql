--------------------------------------------------------
--  DDL for Package MRP_ATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ATP_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPEATPS.pls 120.4 2008/01/03 10:44:53 avjain ship $  */

TYPE number_arr IS TABLE OF number;
TYPE char1_arr IS TABLE of varchar2(1);
TYPE char3_arr IS TABLE OF varchar2(3);
TYPE char7_arr IS TABLE OF varchar2(7);
TYPE char10_arr IS TABLE OF varchar2(10);
TYPE char14_arr IS TABLE of varchar2(14); -- For ship_rec_cal
TYPE char15_arr IS TABLE of varchar2(15);
TYPE char16_arr IS TABLE of varchar2(16); --4774169
TYPE char20_arr  IS TABLE of varchar2(20);
TYPE char30_arr IS TABLE OF varchar2(30);
TYPE char40_arr IS TABLE OF varchar2(40);
TYPE char60_arr IS TABLE OF varchar2(60);
TYPE char62_arr IS TABLE OF varchar2(62);
TYPE char80_arr IS TABLE of varchar2(80);
TYPE char255_arr IS TABLE of varchar2(255);
TYPE char2000_arr IS TABLE of varchar2(2000);
TYPE date_arr IS TABLE OF date;

TYPE ATP_Supply_Demand_Typ is RECORD (
Level				number_arr := number_arr(),
Identifier                      number_arr := number_arr(),
Inventory_Item_Id               number_arr := number_arr(),
Request_Item_Id			number_arr := number_arr(),
Organization_Id                 number_arr := number_arr(),
Department_Id			number_arr := number_arr(),
Resource_Id			number_arr := number_arr(),
Supplier_Id			number_arr := number_arr(),
Supplier_Site_Id		number_arr := number_arr(),
From_Organization_Id		number_arr := number_arr(),
From_Location_Id		number_arr := number_arr(),
To_Organization_Id		number_arr := number_arr(),
To_Location_Id			number_arr := number_arr(),
Ship_Method			char30_arr := char30_arr(),
Uom				char3_arr := char3_arr(),
Disposition_Type                number_arr := number_arr(),
Disposition_Name		char80_arr := char80_arr(),
Identifier1                     number_arr := number_arr(),
Identifier2                     number_arr := number_arr(),
Identifier3                     number_arr := number_arr(),
Identifier4                     number_arr := number_arr(),
Supply_Demand_Type              number_arr := number_arr(),
Supply_Demand_Source_Type       number_arr := number_arr(),
Supply_Demand_Source_Type_Name  char80_arr := char80_arr(),
Supply_Demand_Date              date_arr := date_arr(),
Supply_Demand_Quantity          number_arr := number_arr(),
Scenario_Id                     number_arr := number_arr(),
Pegging_Id                      number_arr := number_arr(),
End_Pegging_Id                  number_arr := number_arr(),
-- time_phased_atp
Original_Item_Id                number_arr := number_arr(),
Original_Supply_Demand_Type     number_arr := number_arr(),
Original_Demand_Date            date_arr   := date_arr(),
Original_Demand_Quantity        number_arr := number_arr(),
Allocated_Quantity              number_arr := number_arr(),
Pf_Display_Flag                 number_arr := number_arr()
);

TYPE ATP_Period_Typ is Record (
Level                           number_arr := number_arr(),
Identifier                      number_arr := number_arr(),
Inventory_Item_Id		number_arr := number_arr(),
Request_Item_Id                 number_arr := number_arr(),
Organization_Id			number_arr := number_arr(),
Department_Id                   number_arr := number_arr(),
Resource_Id                     number_arr := number_arr(),
Supplier_Id                     number_arr := number_arr(),
Supplier_Site_Id                number_arr := number_arr(),
From_Organization_Id            number_arr := number_arr(),
From_Location_Id                number_arr := number_arr(),
To_Organization_Id              number_arr := number_arr(),
To_Location_Id                  number_arr := number_arr(),
Ship_Method                     char30_arr := char30_arr(),
Uom                             char3_arr := char3_arr(),
Total_Supply_Quantity		number_arr := number_arr(),
Total_Demand_Quantity		number_arr := number_arr(),
Period_Start_Date               date_arr := date_arr(),
Period_End_Date                 date_arr := date_arr(),
Period_Quantity                 number_arr := number_arr(),
Cumulative_Quantity             number_arr := number_arr(),
Identifier1                     number_arr := number_arr(),
Identifier2                     number_arr := number_arr(),
Scenario_Id                     number_arr := number_arr(),
Pegging_Id                      number_arr := number_arr(),
End_Pegging_Id                  number_arr := number_arr(),
--ssurendr 25-NOV-2002: New fields added for alloc w/b
Identifier4			number_arr := number_arr(), -- Sysdate allocation percent. Used only in rule based case
Demand_Class			char80_arr := char80_arr(), -- Demand class in DC case; Level 3 Demand class in CC case
Class				char80_arr := char80_arr(), -- Customer class. Used only in customer class case
Customer_Id			number_arr := number_arr(), -- Customer Id. Used only in customer class case
Customer_Site_Id		number_arr := number_arr(), -- Customer site Id. Used only in customer class case
Allocated_Supply_Quantity	number_arr := number_arr(), -- Supply allocated to a demand class on a date
Supply_Adjustment_Quantity	number_arr := number_arr(), -- Supply adjusment. Used only in demand priority case
Backward_Forward_Quantity	number_arr := number_arr(), -- Figures after b/w:f/w consumption. Used only in demand priority case
Backward_Quantity		number_arr := number_arr(), -- Figures after b/w consumption. Used only in rule based case
Demand_Adjustment_Quantity	number_arr := number_arr(), -- Demand adjusment. Used only in rule based case
Adjusted_Availability_Quantity	number_arr := number_arr(), -- Figures after DC consumption (and f/w consumption in method 1)
                                            -- Used only in rule based case
Adjusted_Cum_Quantity		number_arr := number_arr(), -- Adjusted Cum. Used only in rule based and method 2
Unallocated_Supply_Quantity	number_arr := number_arr(), -- Unallocated supply. Used only in rule based and method 2
Unallocated_Demand_Quantity	number_arr := number_arr(), -- Unallocated demand. Used only in rule based and method 2
Unallocated_Net_Quantity	number_arr := number_arr(), -- Unallocated net. Used only in rule based and method 2
-- time_phased_atp
Total_Bucketed_Demand_Quantity  number_arr := number_arr(), -- Bucketed Demand. Used only in PF time phased ATP
-- bug 3282426
Unalloc_Bucketed_Demand_Qty     number_arr := number_arr()  -- Unallocated bucketed demand. Used in rule based + time phased ATP
);

TYPE ATP_Details_Typ is RECORD (
Level				number_arr := number_arr(),
Identifier                      number_arr := number_arr(),
Request_Item_Id			number_arr := number_arr(),
Request_Item_Name		char40_arr := char40_arr(),
Inventory_Item_Id               number_arr := number_arr(),
Inventory_Item_Name		char40_arr := char40_arr(),
Organization_Id                 number_arr := number_arr(),
Organization_Code               char3_arr := char3_arr(),
Department_Id                   number_arr := number_arr(),
Department_Code                 char10_arr := char10_arr(),
Resource_Id                     number_arr := number_arr(),
Resource_Code                   char10_arr := char10_arr(),
Supplier_Id                     number_arr := number_arr(),
Supplier_Name                   char80_arr := char80_arr(),
Supplier_Site_Id                number_arr := number_arr(),
From_Organization_Id            number_arr := number_arr(),
From_Organization_Code          char3_arr := char3_arr(),
From_Location_Id                number_arr := number_arr(),
From_Location_Code              char20_arr := char20_arr(),
To_Organization_Id              number_arr := number_arr(),
To_Organization_Code            char3_arr := char3_arr(),
To_Location_Id                  number_arr := number_arr(),
To_Location_Code                char20_arr := char20_arr(),
Ship_Method                     char30_arr := char30_arr(),
Uom                             char3_arr := char3_arr(),
Supply_Demand_Type		number_arr := number_arr(),
Supply_Demand_Quantity		number_arr := number_arr(),
Source_Type			number_arr := number_arr(),
Identifier1                     number_arr := number_arr(),
Identifier2			number_arr := number_arr(),
Identifier3                     number_arr := number_arr(),
Identifier4                     number_arr := number_arr(),
Scenario_Id                     number_arr := number_arr()
);


-- NGOEL 6/14, added ato_delete_flag and attribute_01 to attribute_10
-- for any future requirements.

TYPE ATP_Rec_Typ is RECORD (
Row_Id				char30_arr := char30_arr(),
Instance_Id                     number_arr := number_arr(),
Inventory_Item_Id               number_arr := number_arr(),
Inventory_Item_Name		char40_arr := char40_arr(),
Source_Organization_Id          number_arr := number_arr(),
Source_Organization_Code	char7_arr := char7_arr(),
Organization_Id 		number_arr := number_arr(),
Identifier                      number_arr := number_arr(),
Demand_Source_Header_Id		number_arr := number_arr(),
Demand_Source_Delivery          char30_arr := char30_arr(),
Demand_Source_Type              number_arr := number_arr(),
Scenario_Id			number_arr := number_arr(),
Calling_Module                  number_arr := number_arr(),
Customer_Id                  	number_arr := number_arr(),
Customer_Site_Id                number_arr := number_arr(),
Destination_Time_Zone           char30_arr := char30_arr(),
Quantity_Ordered                number_arr := number_arr(),
Quantity_UOM                    char3_arr := char3_arr(),
Requested_Ship_Date             date_arr := date_arr(),
Requested_Arrival_Date          date_arr := date_arr(),
Earliest_Acceptable_Date        date_arr := date_arr(),
Latest_Acceptable_Date          date_arr := date_arr(),
Delivery_Lead_Time              number_arr := number_arr(),
Freight_Carrier                 char30_arr := char30_arr(),
Ship_Method                     char30_arr := char30_arr(),
Demand_Class                    char30_arr := char30_arr(),
Ship_Set_Name                   char30_arr := char30_arr(),
Arrival_Set_Name                char30_arr := char30_arr(),
Override_Flag                   char1_arr := char1_arr(),
Action                          number_arr := number_arr(),
Ship_Date                       date_arr := date_arr(),
Arrival_date 			date_arr := date_arr(),
Available_Quantity              number_arr := number_arr(),
Requested_Date_Quantity         number_arr := number_arr(),
Group_Ship_Date                 date_arr := date_arr(),
Group_Arrival_Date              date_arr := date_arr(),
Vendor_Id			number_arr := number_arr(),
Vendor_Name			char80_arr := char80_arr(),
Vendor_Site_Id			number_arr := number_arr(),
Vendor_Site_Name		char80_arr := char80_arr(),
Insert_Flag                     number_arr := number_arr(),
OE_Flag                         char1_arr := char1_arr(),
Atp_Lead_Time                   number_arr := number_arr(),
Error_Code			number_arr := number_arr(),
Message                         char2000_arr := char2000_arr(),
End_Pegging_Id			number_arr := number_arr(),
Order_Number                    number_arr := number_arr(),
Old_Source_Organization_Id      number_arr := number_arr(),
Old_Demand_Class                char30_arr := char30_arr(),
ato_delete_flag			char1_arr := char1_arr(),
attribute_01      		number_arr := number_arr(),	-- used for source_document_line_id for internal SO
attribute_02      		number_arr := number_arr(),
attribute_03      		number_arr := number_arr(),
attribute_04      		number_arr := number_arr(),     -- used for 24x7 ATP - stores refresh number
attribute_05                	char30_arr := char30_arr(),	-- used for procure CTO for setting visible demand flag
attribute_06                	char30_arr := char30_arr(),	-- used for sending ATP_Flag from source to destination
attribute_07                	char30_arr := char30_arr(),
attribute_08                	char30_arr := char30_arr(),
attribute_09			date_arr := date_arr(),
attribute_10			date_arr := date_arr(),
-- start of new attributes for region level sourcing
--customer_name			char80_arr := char80_arr(),
customer_name			char255_arr := char255_arr(),--3991728
customer_class			char30_arr := char30_arr(),
customer_location		char40_arr := char40_arr(),
customer_country		char60_arr := char60_arr(),
customer_state			char60_arr := char60_arr(),
customer_city			char60_arr := char60_arr(),
customer_postal_code		char60_arr := char60_arr(),
-- end of new attributes for region level sourcing
--- new columns for Product substitution
substitution_typ_code           number_arr := number_arr(),
req_item_detail_flag            number_arr := number_arr(),
request_item_id                 number_arr := number_arr(),
req_item_req_date_qty           number_arr := number_arr(),
req_item_available_date         date_arr := date_arr(),
req_item_available_date_qty     number_arr := number_arr(),
request_item_name               char40_arr := char40_arr(),
old_inventory_item_id           number_arr := number_arr(),
sales_rep                       char255_arr := char255_arr(),
customer_contact                char255_arr := char255_arr(),
subst_flag                      number_arr := number_arr(),
---new column for CTO enhancement project
Top_Model_line_id               number_arr := number_arr(),
ATO_Parent_Model_Line_Id        number_arr := number_arr(),
ATO_Model_Line_Id               number_arr := number_arr(),
Parent_line_id                  number_arr := number_arr(),
match_item_id                   number_arr := number_arr(),
Config_item_line_id             number_arr := number_arr(),
Validation_Org                  number_arr := number_arr(),
Component_Sequence_ID           number_arr := number_arr(),
Component_Code                  char255_arr := char255_arr(),
line_number                     char80_arr := char80_arr(),
included_item_flag              number_arr := number_arr(),
atp_flag                        char1_arr  := char1_arr(),
atp_components_flag             char1_arr  := char1_arr(),
wip_supply_type                 number_arr := number_arr(),
bom_item_type                   number_arr := number_arr(),
mandatory_item_flag             number_arr := number_arr(),
pick_components_flag            char1_arr := char1_arr(),
base_model_id                   number_arr := number_arr(),
OSS_ERROR_CODE                  number_arr := number_arr(),
matched_item_name               char255_arr := char255_arr(),
cascade_model_info_to_comp      number_arr := number_arr(),
--columns for backlog workbench
sequence_number                 number_arr := number_arr(),
firm_flag                       number_arr := number_arr(),
order_line_number               number_arr := number_arr(),
option_number                   number_arr := number_arr(),
shipment_number                 number_arr := number_arr(),
item_desc                       char255_arr := char255_arr(),
old_line_schedule_date          date_arr := date_arr(),
old_source_organization_code    char7_arr := char7_arr(),
firm_source_org_id              number_arr := number_arr(),
firm_source_org_code            char7_arr := char7_arr(),
firm_ship_date                  date_arr := date_arr(),
firm_arrival_date               date_arr := date_arr(),
ship_method_text                char255_arr := char255_arr(),
ship_set_id                     number_arr := number_arr(),
arrival_set_id                  number_arr := number_arr(),
PROJECT_ID                      number_arr := number_arr(),
TASK_ID                         number_arr := number_arr(),
PROJECT_NUMBER                  char30_arr := char30_arr(),
TASK_NUMBER                     char30_arr := char30_arr(),
attribute_11                    number_arr := number_arr(),
attribute_12                    number_arr := number_arr(),
attribute_13                    number_arr := number_arr(),
attribute_14                    number_arr := number_arr(),
attribute_15                    char30_arr := char30_arr(),
attribute_16                    char30_arr := char30_arr(),
attribute_17                    char30_arr := char30_arr(),
attribute_18                    char30_arr := char30_arr(),
attribute_19                    date_arr := date_arr(),
attribute_20                    date_arr := date_arr(),
Attribute_21                    number_arr := number_arr(),
attribute_22                    number_arr := number_arr(),
attribute_23                    number_arr := number_arr(),
attribute_24                    number_arr := number_arr(),
attribute_25                    char30_arr := char30_arr(),
attribute_26                    char30_arr := char30_arr(),
attribute_27                    char30_arr := char30_arr(),
attribute_28                    char30_arr := char30_arr(),
attribute_29                    date_arr := date_arr(),
attribute_30                    date_arr := date_arr(),
-- time_phased_atp
atf_date                        date_arr := date_arr(),
plan_id                         number_arr := number_arr(),
--request by plan
original_request_date		date_arr := date_arr(),
-- ship_rec_cal
receiving_cal_code              char14_arr := char14_arr(),
intransit_cal_code              char14_arr := char14_arr(),
shipping_cal_code               char14_arr := char14_arr(),
manufacturing_cal_code          char14_arr := char14_arr(),
--3409286
internal_org_id                number_arr := number_arr(),
--bug 3328421
first_valid_ship_arrival_date  date_arr := date_arr(),
--2814895
party_site_id      		number_arr := number_arr(),
part_of_set                    char1_arr := char1_arr() --4500382
);


-- Added by ngoel 10/13/2000. This type is required for supporting
-- multi-level multi-org CTO models from OM and CZ modules.

TYPE ATP_BOM_Rec_Typ is RECORD (
assembly_identifier     	number_arr := number_arr(),
assembly_item_id        	number_arr := number_arr(),
component_identifier 		number_arr := number_arr(),
component_item_id 		number_arr := number_arr(),
quantity                	number_arr := number_arr(),
fixed_lt                	number_arr := number_arr(),
variable_lt             	number_arr := number_arr(),
pre_process_lt			number_arr := number_arr(),
effective_date			date_arr := date_arr(),
disable_date			date_arr := date_arr(),
atp_check			number_arr := number_arr(),
wip_supply_type			number_arr := number_arr(),
smc_flag			char1_arr := char1_arr(),
source_organization_id          number_arr := number_arr(),     -- 2400614 : krajan
atp_flag                        char1_arr := char1_arr()       -- 2462661 : krajan
);



-- Added by ngoel 10/26/2000. This type is required for supporting
-- multi-level multi-org CTO models from OM and CZ modules.

TYPE shipset_status_rec_type is RECORD (
Ship_Set_Name                   char30_arr := char30_arr(),
Status                          char1_arr := char1_arr());


PROCEDURE Call_ATP (
               p_session_id	    IN OUT NoCopy NUMBER,
               p_atp_rec            IN    MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_rec            OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
	       x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	       x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
               x_return_status      OUT   NoCopy VARCHAR2,
               x_msg_data           OUT   NoCopy VARCHAR2,
               x_msg_count          OUT   NoCopy NUMBER
);

PROCEDURE Call_ATP_No_Commit (
               p_session_id         IN OUT NoCopy NUMBER,
               p_atp_rec            IN    MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_rec            OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
               x_return_status      OUT   NoCopy VARCHAR2,
               x_msg_data           OUT   NoCopy VARCHAR2,
               x_msg_count          OUT   NoCopy NUMBER
);


END MRP_ATP_PUB;

/
