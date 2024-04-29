--------------------------------------------------------
--  DDL for Package Body MSC_ATP_BPEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_BPEL" AS
/* $Header: MSCATPBB.pls 120.0 2007/12/18 10:13:49 arrsubra noship $  */

G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_ATP_BPEL' ;

PROCEDURE ATP_Rec_convert_tab(
		p_atp_tab              IN    MSC_ATP_BPEL.ATP_Rec_Table_Typ,
		x_atp_rec              OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ )
IS

x_return_status varchar2(10);

begin

msc_sch_wb.atp_debug('Begin Procedure ATP_Rec_convert_tab');

for i in 1..p_atp_tab.COUNT loop

 msc_sch_wb.atp_debug('Before extend');

 MSC_SATP_FUNC.Extend_Atp(x_atp_rec, x_return_status, 1);

 msc_sch_wb.atp_debug('After extend');
 msc_sch_wb.atp_debug('x_atp_rec.Row_Id.count: '||x_atp_rec.Row_Id.COUNT);

--assignments
x_atp_rec.Row_Id(i)	:= p_atp_tab(i).Row_Id;
x_atp_rec.Instance_Id(i)   := p_atp_tab(i).Instance_Id   ;
x_atp_rec.Inventory_Item_Id(i)   := p_atp_tab(i).Inventory_Item_Id ;
x_atp_rec.Inventory_Item_Name(i) := p_atp_tab(i).Inventory_Item_Name;
x_atp_rec.Source_Organization_Id(i)   := p_atp_tab(i).Source_Organization_Id ;
x_atp_rec.Source_Organization_Code(i)	:= p_atp_tab(i).Source_Organization_Code;
x_atp_rec.Organization_Id(i) 	:= p_atp_tab(i).Organization_Id;
x_atp_rec.Identifier(i)           := p_atp_tab(i).Identifier ;
x_atp_rec.Demand_Source_Header_Id(i) := p_atp_tab(i).Demand_Source_Header_Id;
x_atp_rec.Demand_Source_Delivery(i)  := p_atp_tab(i).Demand_Source_Delivery  ;
x_atp_rec.Demand_Source_Type(i)   := p_atp_tab(i).Demand_Source_Type ;
x_atp_rec.Scenario_Id(i)	:= p_atp_tab(i).Scenario_Id;
x_atp_rec.Calling_Module(i)      := p_atp_tab(i).Calling_Module ;
x_atp_rec.Customer_Id(i)         := p_atp_tab(i).Customer_Id;
x_atp_rec.Customer_Site_Id(i)    := p_atp_tab(i).Customer_Site_Id ;
x_atp_rec.Destination_Time_Zone(i)   := p_atp_tab(i).Destination_Time_Zone ;
x_atp_rec.Quantity_Ordered(i)                := p_atp_tab(i).Quantity_Ordered ;
x_atp_rec.Quantity_UOM(i)                   := p_atp_tab(i).Quantity_UOM   ;
x_atp_rec.Requested_Ship_Date(i)             := p_atp_tab(i).Requested_Ship_Date ;
x_atp_rec.Requested_Arrival_Date(i)        := p_atp_tab(i).Requested_Arrival_Date ;
x_atp_rec.Earliest_Acceptable_Date(i)       := p_atp_tab(i).Earliest_Acceptable_Date   ;
x_atp_rec.Latest_Acceptable_Date(i)       := p_atp_tab(i).Latest_Acceptable_Date;
x_atp_rec.Delivery_Lead_Time(i)             := p_atp_tab(i).Delivery_Lead_Time ;
x_atp_rec.Freight_Carrier(i)                := p_atp_tab(i).Freight_Carrier;
x_atp_rec.Ship_Method(i)                     := p_atp_tab(i).Ship_Method ;
x_atp_rec.Demand_Class(i)                    := p_atp_tab(i).Demand_Class ;
x_atp_rec.Ship_Set_Name(i)                   := p_atp_tab(i).Ship_Set_Name;
x_atp_rec.Arrival_Set_Name(i)                := p_atp_tab(i).Arrival_Set_Name ;
x_atp_rec.Override_Flag(i)                   := p_atp_tab(i).Override_Flag  ;
x_atp_rec.Action(i)                          := p_atp_tab(i).Action  ;
x_atp_rec.Ship_Date(i)                       := p_atp_tab(i).Ship_Date ;
x_atp_rec.Arrival_date(i) 			:= p_atp_tab(i).Arrival_date;
x_atp_rec.Available_Quantity(i)              := p_atp_tab(i).Available_Quantity ;
x_atp_rec.Requested_Date_Quantity(i)         := p_atp_tab(i).Requested_Date_Quantity  ;
x_atp_rec.Group_Ship_Date(i)                 := p_atp_tab(i).Group_Ship_Date;
x_atp_rec.Group_Arrival_Date(i)              := p_atp_tab(i).Group_Arrival_Date ;
x_atp_rec.Vendor_Id(i)			:= p_atp_tab(i).Vendor_Id;
x_atp_rec.Vendor_Name(i)			:= p_atp_tab(i).Vendor_Name;
x_atp_rec.Vendor_Site_Id(i)			:= p_atp_tab(i).Vendor_Site_Id;
x_atp_rec.Vendor_Site_Name(i)			:= p_atp_tab(i).Vendor_Site_Name;
x_atp_rec.Insert_Flag(i)			:= p_atp_tab(i).Insert_Flag;
x_atp_rec.OE_Flag(i)                            := p_atp_tab(i).OE_Flag;
x_atp_rec.Atp_Lead_Time(i)                   := p_atp_tab(i).Atp_Lead_Time;
x_atp_rec.Error_Code(i)			:= p_atp_tab(i).Error_Code;
x_atp_rec.Message(i)                         := p_atp_tab(i).Message;
x_atp_rec.End_Pegging_Id(i)			:= p_atp_tab(i).End_Pegging_Id;
x_atp_rec.Order_Number(i)                    := p_atp_tab(i).Order_Number;
x_atp_rec.Old_Source_Organization_Id(i)      := p_atp_tab(i).Old_Source_Organization_Id;
x_atp_rec.Old_Demand_Class(i)               := p_atp_tab(i).Old_Demand_Class;
x_atp_rec.ato_delete_flag(i)			:= p_atp_tab(i).ato_delete_flag;
x_atp_rec.attribute_01(i)      			:= p_atp_tab(i).attribute_01;
x_atp_rec.attribute_02(i)      		:= p_atp_tab(i).attribute_02;
--x_atp_rec.attribute_03(i)      		:= p_atp_tab(i).attribute_03;
x_atp_rec.attribute_04(i)      		     := p_atp_tab(i).attribute_04;
x_atp_rec.attribute_05(i)                		:= p_atp_tab(i).attribute_05;
x_atp_rec.attribute_06(i)                		:= p_atp_tab(i).attribute_06;
x_atp_rec.attribute_07(i)                	:= p_atp_tab(i).attribute_07;
x_atp_rec.attribute_08(i)                	:= p_atp_tab(i).attribute_08;
--x_atp_rec.attribute_09(i)			:= p_atp_tab(i).attribute_09;
--x_atp_rec.attribute_10(i)			:= p_atp_tab(i).attribute_10;
x_atp_rec.customer_name(i)                   := p_atp_tab(i).customer_name;
x_atp_rec.customer_class(i)			:= p_atp_tab(i).customer_class;
x_atp_rec.customer_location(i)		:= p_atp_tab(i).customer_location;
x_atp_rec.customer_country(i)		:= p_atp_tab(i).customer_country;
x_atp_rec.customer_state(i)			:= p_atp_tab(i).customer_state;
x_atp_rec.customer_city(i)			:= p_atp_tab(i).customer_city;
x_atp_rec.customer_postal_code(i)		:= p_atp_tab(i).customer_postal_code;
x_atp_rec.substitution_typ_code(i)           := p_atp_tab(i).substitution_typ_code;
x_atp_rec.req_item_detail_flag(i)            := p_atp_tab(i).req_item_detail_flag;
x_atp_rec.request_item_id(i)                 := p_atp_tab(i).request_item_id;
x_atp_rec.req_item_req_date_qty(i)           := p_atp_tab(i).req_item_req_date_qty;
x_atp_rec.req_item_available_date(i)         := p_atp_tab(i).req_item_available_date;
x_atp_rec.req_item_available_date_qty(i)     := p_atp_tab(i).req_item_available_date_qty;
x_atp_rec.request_item_name(i)                := p_atp_tab(i).request_item_name;
x_atp_rec.old_inventory_item_id(i)           := p_atp_tab(i).old_inventory_item_id;
x_atp_rec.sales_rep(i)                       := p_atp_tab(i).sales_rep;
x_atp_rec.customer_contact(i)                := p_atp_tab(i).customer_contact;
x_atp_rec.subst_flag(i)                      := p_atp_tab(i).subst_flag;
x_atp_rec.Top_Model_line_id(i)               := p_atp_tab(i).Top_Model_line_id;
x_atp_rec.ATO_Parent_Model_Line_Id(i)        := p_atp_tab(i).ATO_Parent_Model_Line_Id;
x_atp_rec.ATO_Model_Line_Id(i)               := p_atp_tab(i).ATO_Model_Line_Id;
x_atp_rec.Parent_line_id(i)                  := p_atp_tab(i).Parent_line_id;
x_atp_rec.match_item_id(i)                   := p_atp_tab(i).match_item_id;
x_atp_rec.Config_item_line_id(i)             := p_atp_tab(i).Config_item_line_id;
x_atp_rec.Validation_Org(i)                  := p_atp_tab(i).Validation_Org;
x_atp_rec.Component_Sequence_ID(i)           := p_atp_tab(i).Component_Sequence_ID;
x_atp_rec.Component_Code(i)                  := p_atp_tab(i).Component_Code;
x_atp_rec.line_number(i)                     := p_atp_tab(i).line_number;
x_atp_rec.included_item_flag(i)              := p_atp_tab(i).included_item_flag;
x_atp_rec.atp_flag(i)                        := p_atp_tab(i).atp_flag;
x_atp_rec.atp_components_flag(i)             := p_atp_tab(i).atp_components_flag;
x_atp_rec.wip_supply_type(i)                 := p_atp_tab(i).wip_supply_type;
x_atp_rec.bom_item_type(i)                   := p_atp_tab(i).bom_item_type;
x_atp_rec.mandatory_item_flag(i)             := p_atp_tab(i).mandatory_item_flag;
x_atp_rec.pick_components_flag(i)            := p_atp_tab(i).pick_components_flag;
x_atp_rec.base_model_id(i)                   := p_atp_tab(i).base_model_id;
x_atp_rec.OSS_ERROR_CODE(i)                  := p_atp_tab(i).OSS_ERROR_CODE;
x_atp_rec.matched_item_name(i)               := p_atp_tab(i).matched_item_name;
x_atp_rec.cascade_model_info_to_comp(i)      := p_atp_tab(i).cascade_model_info_to_comp;
x_atp_rec.sequence_number(i)                 := p_atp_tab(i).sequence_number;
x_atp_rec.firm_flag(i)                       := p_atp_tab(i).firm_flag;
x_atp_rec.order_line_number(i)               := p_atp_tab(i).order_line_number;
x_atp_rec.option_number(i)                   := p_atp_tab(i).option_number;
x_atp_rec.shipment_number(i)                 := p_atp_tab(i).shipment_number;
x_atp_rec.item_desc(i)                       := p_atp_tab(i).item_desc;
x_atp_rec.old_line_schedule_date(i)          := p_atp_tab(i).old_line_schedule_date;
x_atp_rec.old_source_organization_code(i)    := p_atp_tab(i).old_source_organization_code;
x_atp_rec.firm_source_org_id(i)              := p_atp_tab(i).firm_source_org_id;
x_atp_rec.firm_source_org_code(i)           := p_atp_tab(i).firm_source_org_code;
x_atp_rec.firm_ship_date(i)                  := p_atp_tab(i).firm_ship_date;
x_atp_rec.firm_arrival_date(i)               := p_atp_tab(i).firm_arrival_date;
x_atp_rec.ship_method_text(i)                := p_atp_tab(i).ship_method_text;
x_atp_rec.ship_set_id(i)                     := p_atp_tab(i).ship_set_id;
x_atp_rec.arrival_set_id(i)                  := p_atp_tab(i).arrival_set_id;
x_atp_rec.PROJECT_ID(i)                      := p_atp_tab(i).PROJECT_ID;
x_atp_rec.TASK_ID(i)                         := p_atp_tab(i).TASK_ID;
x_atp_rec.PROJECT_NUMBER(i)                  := p_atp_tab(i).PROJECT_NUMBER;
x_atp_rec.TASK_NUMBER(i)                     := p_atp_tab(i).TASK_NUMBER;
x_atp_rec.attribute_11(i)                        := p_atp_tab(i).attribute_11;
x_atp_rec.attribute_12(i)                    := p_atp_tab(i).attribute_12;
x_atp_rec.attribute_13(i)                    := p_atp_tab(i).attribute_13;
x_atp_rec.attribute_14(i)                        := p_atp_tab(i).attribute_14;
x_atp_rec.attribute_15(i)                        := p_atp_tab(i).attribute_15;
x_atp_rec.attribute_16(i)                       := p_atp_tab(i).attribute_16;
x_atp_rec.attribute_17(i)                    := p_atp_tab(i).attribute_17;
x_atp_rec.attribute_18(i)                    := p_atp_tab(i).attribute_18;
x_atp_rec.attribute_19(i)                    := p_atp_tab(i).attribute_19;
x_atp_rec.attribute_20(i)                    := p_atp_tab(i).attribute_20;
x_atp_rec.Attribute_21(i)                        := p_atp_tab(i).attribute_21;
x_atp_rec.attribute_22(i)                    := p_atp_tab(i).attribute_22;
x_atp_rec.attribute_23(i)                    := p_atp_tab(i).attribute_23;
x_atp_rec.attribute_24(i)                       := p_atp_tab(i).attribute_24;
x_atp_rec.attribute_25(i)                      := p_atp_tab(i).attribute_25;
x_atp_rec.attribute_26(i)                     := p_atp_tab(i).attribute_26;
x_atp_rec.attribute_27(i)                    := p_atp_tab(i).attribute_27;
x_atp_rec.attribute_28(i)                    := p_atp_tab(i).attribute_28;
x_atp_rec.attribute_29(i)                    := p_atp_tab(i).attribute_29;
x_atp_rec.attribute_30(i)                    := p_atp_tab(i).attribute_30;
x_atp_rec.atf_date(i)                        := p_atp_tab(i).atf_date;
x_atp_rec.original_request_date(i)		:= p_atp_tab(i).original_request_date;
x_atp_rec.receiving_cal_code(i)              := p_atp_tab(i).receiving_cal_code;
x_atp_rec.intransit_cal_code(i)             := p_atp_tab(i).intransit_cal_code;
x_atp_rec.shipping_cal_code(i)               := p_atp_tab(i).shipping_cal_code;
x_atp_rec.manufacturing_cal_code(i)          := p_atp_tab(i).manufacturing_cal_code;
x_atp_rec.internal_org_id(i)                := p_atp_tab(i).internal_org_id;
x_atp_rec.first_valid_ship_arrival_date(i)  := p_atp_tab(i).first_valid_ship_arrival_date;
x_atp_rec.party_site_id(i)      		:= p_atp_tab(i).party_site_id;
x_atp_rec.part_of_set(i)      		    := p_atp_tab(i).part_of_set;  --Added in 12.0
/*  Next 3 fields belong to ER 1879787 - not ported to 12.0
x_atp_rec.available_qty_orig_uom(i)           := p_atp_tab(i).available_qty_orig_uom;
x_atp_rec.requested_date_qty_orig_uom(i)     := p_atp_tab(i).requested_date_qty_orig_uom;
x_atp_rec.Primary_UOM(i)		     := p_atp_tab(i).Primary_UOM;
*/
end loop;

exception when others then
msc_sch_wb.atp_debug('Inside exception of ATP_Rec_convert_tab '||sqlerrm);

END ATP_Rec_convert_tab ;

PROCEDURE ATP_Rec_convert_rec(
		p_atp_rec              IN    MRP_ATP_PUB.ATP_Rec_Typ,
		p_atp_tab              OUT   NoCopy MSC_ATP_BPEL.ATP_Rec_Table_Typ)
IS

begin

msc_sch_wb.atp_debug('Begin Procedure ATP_Rec_convert_rec');

FOR i in 1..p_atp_rec.action.COUNT LOOP

msc_sch_wb.atp_debug('i: '||i);

-- assignments

p_atp_tab(i).Row_Id	:= p_atp_rec.Row_Id(i);
p_atp_tab(i).Instance_Id   := p_atp_rec.Instance_Id(i);
p_atp_tab(i).Inventory_Item_Id   := p_atp_rec.Inventory_Item_Id(i);
p_atp_tab(i).Inventory_Item_Name := p_atp_rec.Inventory_Item_Name(i);
p_atp_tab(i).Source_Organization_Id   := p_atp_rec.Source_Organization_Id(i);
p_atp_tab(i).Source_Organization_Code	:= p_atp_rec.Source_Organization_Code(i);
p_atp_tab(i).Organization_Id 	:= p_atp_rec.Organization_Id(i);
p_atp_tab(i).Identifier           := p_atp_rec.Identifier(i);
p_atp_tab(i).Demand_Source_Header_Id := p_atp_rec.Demand_Source_Header_Id(i);
p_atp_tab(i).Demand_Source_Delivery  := p_atp_rec.Demand_Source_Delivery(i);
p_atp_tab(i).Demand_Source_Type   := p_atp_rec.Demand_Source_Type(i);
p_atp_tab(i).Scenario_Id	:= p_atp_rec.Scenario_Id(i);
p_atp_tab(i).Calling_Module      := p_atp_rec.Calling_Module(i);
p_atp_tab(i).Customer_Id         := p_atp_rec.Customer_Id(i);
p_atp_tab(i).Customer_Site_Id    := p_atp_rec.Customer_Site_Id(i);
p_atp_tab(i).Destination_Time_Zone   := p_atp_rec.Destination_Time_Zone(i);
p_atp_tab(i).Quantity_Ordered                := p_atp_rec.Quantity_Ordered(i);
p_atp_tab(i).Quantity_UOM                   := p_atp_rec.Quantity_UOM(i);
p_atp_tab(i).Requested_Ship_Date             := p_atp_rec.Requested_Ship_Date(i);
p_atp_tab(i).Requested_Arrival_Date        := p_atp_rec.Requested_Arrival_Date(i);
p_atp_tab(i).Earliest_Acceptable_Date       := p_atp_rec.Earliest_Acceptable_Date(i);
p_atp_tab(i).Latest_Acceptable_Date       := p_atp_rec.Latest_Acceptable_Date(i);
p_atp_tab(i).Delivery_Lead_Time             := p_atp_rec.Delivery_Lead_Time(i);
p_atp_tab(i).Freight_Carrier                := p_atp_rec.Freight_Carrier(i);
p_atp_tab(i).Ship_Method                     := p_atp_rec.Ship_Method(i);
p_atp_tab(i).Demand_Class                    := p_atp_rec.Demand_Class(i);
p_atp_tab(i).Ship_Set_Name                   := p_atp_rec.Ship_Set_Name(i);
p_atp_tab(i).Arrival_Set_Name                := p_atp_rec.Arrival_Set_Name(i);
p_atp_tab(i).Override_Flag                   := p_atp_rec.Override_Flag(i);
p_atp_tab(i).Action                         := p_atp_rec.Action(i);
p_atp_tab(i).Ship_Date                      := p_atp_rec.Ship_Date(i);
p_atp_tab(i).Arrival_date			:= p_atp_rec.Arrival_date(i);
p_atp_tab(i).Available_Quantity              := p_atp_rec.Available_Quantity(i);
p_atp_tab(i).Requested_Date_Quantity        := p_atp_rec.Requested_Date_Quantity(i);
p_atp_tab(i).Group_Ship_Date                 := p_atp_rec.Group_Ship_Date(i);
p_atp_tab(i).Group_Arrival_Date              := p_atp_rec.Group_Arrival_Date(i);
p_atp_tab(i).Vendor_Id			:= p_atp_rec.Vendor_Id(i);
p_atp_tab(i).Vendor_Name			:= p_atp_rec.Vendor_Name(i);
p_atp_tab(i).Vendor_Site_Id			:= p_atp_rec.Vendor_Site_Id(i);
p_atp_tab(i).Vendor_Site_Name			:= p_atp_rec.Vendor_Site_Name(i);
p_atp_tab(i).Insert_Flag			:= p_atp_rec.Insert_Flag(i);
p_atp_tab(i).OE_Flag                           := p_atp_rec.OE_Flag(i);
p_atp_tab(i).Atp_Lead_Time                   := p_atp_rec.Atp_Lead_Time(i);
p_atp_tab(i).Error_Code			:= p_atp_rec.Error_Code(i);
p_atp_tab(i).Message                         := p_atp_rec.Message(i);
p_atp_tab(i).End_Pegging_Id			:= p_atp_rec.End_Pegging_Id(i);
p_atp_tab(i).Order_Number                    := p_atp_rec.Order_Number(i);
p_atp_tab(i).Old_Source_Organization_Id      := p_atp_rec.Old_Source_Organization_Id(i);
p_atp_tab(i).Old_Demand_Class              := p_atp_rec.Old_Demand_Class(i);
p_atp_tab(i).ato_delete_flag			:= p_atp_rec.ato_delete_flag(i);
p_atp_tab(i).attribute_01      			:= p_atp_rec.attribute_01(i);
p_atp_tab(i).attribute_02      		:= p_atp_rec.attribute_02(i);
--p_atp_tab(i).attribute_03      		:= p_atp_rec.attribute_03(i);
p_atp_tab(i).attribute_04      		     := p_atp_rec.attribute_04(i);
p_atp_tab(i).attribute_05                		:= p_atp_rec.attribute_05(i);
p_atp_tab(i).attribute_06                		:= p_atp_rec.attribute_06(i);
p_atp_tab(i).attribute_07                	:= p_atp_rec.attribute_07(i);
p_atp_tab(i).attribute_08                	:= p_atp_rec.attribute_08(i);
--p_atp_tab(i).attribute_09			:= p_atp_rec.attribute_09(i);
--p_atp_tab(i).attribute_10			:= p_atp_rec.attribute_10(i);
p_atp_tab(i).customer_name                   := p_atp_rec.customer_name(i);
p_atp_tab(i).customer_class			:= p_atp_rec.customer_class(i);
p_atp_tab(i).customer_location		:= p_atp_rec.customer_location(i);
p_atp_tab(i).customer_country		:= p_atp_rec.customer_country(i);
p_atp_tab(i).customer_state			:= p_atp_rec.customer_state(i);
p_atp_tab(i).customer_city			:= p_atp_rec.customer_city(i);
p_atp_tab(i).customer_postal_code		:= p_atp_rec.customer_postal_code(i);
p_atp_tab(i).substitution_typ_code           := p_atp_rec.substitution_typ_code(i);
p_atp_tab(i).req_item_detail_flag            := p_atp_rec.req_item_detail_flag(i);
p_atp_tab(i).request_item_id                 := p_atp_rec.request_item_id(i);
p_atp_tab(i).req_item_req_date_qty           := p_atp_rec.req_item_req_date_qty(i);
p_atp_tab(i).req_item_available_date         := p_atp_rec.req_item_available_date(i);
p_atp_tab(i).req_item_available_date_qty     := p_atp_rec.req_item_available_date_qty(i);
p_atp_tab(i).request_item_name               := p_atp_rec.request_item_name(i);
p_atp_tab(i).old_inventory_item_id           := p_atp_rec.old_inventory_item_id(i);
p_atp_tab(i).sales_rep                       := p_atp_rec.sales_rep(i);
p_atp_tab(i).customer_contact                := p_atp_rec.customer_contact(i);
p_atp_tab(i).subst_flag                      := p_atp_rec.subst_flag(i);
p_atp_tab(i).Top_Model_line_id               := p_atp_rec.Top_Model_line_id(i);
p_atp_tab(i).ATO_Parent_Model_Line_Id        := p_atp_rec.ATO_Parent_Model_Line_Id(i);
p_atp_tab(i).ATO_Model_Line_Id               := p_atp_rec.ATO_Model_Line_Id(i);
p_atp_tab(i).Parent_line_id                  := p_atp_rec.Parent_line_id(i);
p_atp_tab(i).match_item_id                   := p_atp_rec.match_item_id(i);
p_atp_tab(i).Config_item_line_id             := p_atp_rec.Config_item_line_id(i);
p_atp_tab(i).Validation_Org                  := p_atp_rec.Validation_Org(i);
p_atp_tab(i).Component_Sequence_ID           := p_atp_rec.Component_Sequence_ID(i);
p_atp_tab(i).Component_Code                  := p_atp_rec.Component_Code(i);
p_atp_tab(i).line_number                     := p_atp_rec.line_number(i);
p_atp_tab(i).included_item_flag              := p_atp_rec.included_item_flag(i);
p_atp_tab(i).atp_flag                        := p_atp_rec.atp_flag(i);
p_atp_tab(i).atp_components_flag             := p_atp_rec.atp_components_flag(i);
p_atp_tab(i).wip_supply_type                 := p_atp_rec.wip_supply_type(i);
p_atp_tab(i).bom_item_type                   := p_atp_rec.bom_item_type(i);
p_atp_tab(i).mandatory_item_flag             := p_atp_rec.mandatory_item_flag(i);
p_atp_tab(i).pick_components_flag            := p_atp_rec.pick_components_flag(i);
p_atp_tab(i).base_model_id                   := p_atp_rec.base_model_id(i);
p_atp_tab(i).OSS_ERROR_CODE                  := p_atp_rec.OSS_ERROR_CODE(i);
p_atp_tab(i).matched_item_name               := p_atp_rec.matched_item_name(i);
p_atp_tab(i).cascade_model_info_to_comp      := p_atp_rec.cascade_model_info_to_comp(i);
p_atp_tab(i).sequence_number                 := p_atp_rec.sequence_number(i);
p_atp_tab(i).firm_flag                       := p_atp_rec.firm_flag(i);
p_atp_tab(i).order_line_number               := p_atp_rec.order_line_number(i);
p_atp_tab(i).option_number                   := p_atp_rec.option_number(i);
p_atp_tab(i).shipment_number                 := p_atp_rec.shipment_number(i);
p_atp_tab(i).item_desc                       := p_atp_rec.item_desc(i);
p_atp_tab(i).old_line_schedule_date          := p_atp_rec.old_line_schedule_date(i);
p_atp_tab(i).old_source_organization_code    := p_atp_rec.old_source_organization_code(i);
p_atp_tab(i).firm_source_org_id              := p_atp_rec.firm_source_org_id(i);
p_atp_tab(i).firm_source_org_code            := p_atp_rec.firm_source_org_code(i);
p_atp_tab(i).firm_ship_date                  := p_atp_rec.firm_ship_date(i);
p_atp_tab(i).firm_arrival_date               := p_atp_rec.firm_arrival_date(i);
p_atp_tab(i).ship_method_text                := p_atp_rec.ship_method_text(i);
p_atp_tab(i).ship_set_id                     := p_atp_rec.ship_set_id(i);
p_atp_tab(i).arrival_set_id                  := p_atp_rec.arrival_set_id(i);
p_atp_tab(i).PROJECT_ID                      := p_atp_rec.PROJECT_ID(i);
p_atp_tab(i).TASK_ID                         := p_atp_rec.TASK_ID(i);
p_atp_tab(i).PROJECT_NUMBER                  := p_atp_rec.PROJECT_NUMBER(i);
p_atp_tab(i).TASK_NUMBER                     := p_atp_rec.TASK_NUMBER(i);
p_atp_tab(i).attribute_11                    := p_atp_rec.attribute_11(i);
p_atp_tab(i).attribute_12                    := p_atp_rec.attribute_12(i);
p_atp_tab(i).attribute_13                    := p_atp_rec.attribute_13(i);
p_atp_tab(i).attribute_14                    := p_atp_rec.attribute_14(i);
p_atp_tab(i).attribute_15                    := p_atp_rec.attribute_15(i);
p_atp_tab(i).attribute_16                    := p_atp_rec.attribute_16(i);
p_atp_tab(i).attribute_17                    := p_atp_rec.attribute_17(i);
p_atp_tab(i).attribute_18                    := p_atp_rec.attribute_18(i);
p_atp_tab(i).attribute_19                    := p_atp_rec.attribute_19(i);
p_atp_tab(i).attribute_20                    := p_atp_rec.attribute_20(i);
p_atp_tab(i).Attribute_21                    := p_atp_rec.attribute_21(i);
p_atp_tab(i).attribute_22                    := p_atp_rec.attribute_22(i);
p_atp_tab(i).attribute_23                    := p_atp_rec.attribute_23(i);
p_atp_tab(i).attribute_24                    := p_atp_rec.attribute_24(i);
p_atp_tab(i).attribute_25                    := p_atp_rec.attribute_25(i);
p_atp_tab(i).attribute_26                    := p_atp_rec.attribute_26(i);
p_atp_tab(i).attribute_27                    := p_atp_rec.attribute_27(i);
p_atp_tab(i).attribute_28                    := p_atp_rec.attribute_28(i);
p_atp_tab(i).attribute_29                    := p_atp_rec.attribute_29(i);
p_atp_tab(i).attribute_30                    := p_atp_rec.attribute_30(i);
p_atp_tab(i).atf_date                        := p_atp_rec.atf_date(i);
p_atp_tab(i).original_request_date	     := p_atp_rec.original_request_date(i);
p_atp_tab(i).receiving_cal_code              := p_atp_rec.receiving_cal_code(i);
p_atp_tab(i).intransit_cal_code              := p_atp_rec.intransit_cal_code(i);
p_atp_tab(i).shipping_cal_code               := p_atp_rec.shipping_cal_code(i);
p_atp_tab(i).manufacturing_cal_code          := p_atp_rec.manufacturing_cal_code(i);
p_atp_tab(i).internal_org_id                 := p_atp_rec.internal_org_id(i);
p_atp_tab(i).first_valid_ship_arrival_date   := p_atp_rec.first_valid_ship_arrival_date(i);
p_atp_tab(i).party_site_id      	     := p_atp_rec.party_site_id(i);
p_atp_tab(i).part_of_set       	             := p_atp_rec.part_of_set(i);	--Added in 12.0
/*  Next 3 fields belong to ER 1879787 - not ported to 12.0
p_atp_tab(i).available_qty_orig_uom          := p_atp_rec.available_qty_orig_uom(i);
p_atp_tab(i).requested_date_qty_orig_uom     := p_atp_rec.requested_date_qty_orig_uom(i);
p_atp_tab(i).Primary_UOM		     := p_atp_rec.Primary_UOM(i);
*/
END LOOP;

exception when others then
msc_sch_wb.atp_debug('Inside exception of ATP_Rec_convert_rec '||sqlerrm);

END ATP_Rec_convert_rec ;

PROCEDURE Call_ATP_BPEL(
	       p_session_id    	         IN OUT NoCopy NUMBER,
               p_atp_tab                 IN    MSC_ATP_BPEL.ATP_Rec_Table_Typ,
               x_atp_tab                 OUT   NoCopy MSC_ATP_BPEL.ATP_Rec_Table_Typ,
	       x_return_status	       	 OUT   NoCopy VARCHAR2,
               x_msg_data		 OUT   NoCopy VARCHAR2,
               x_msg_count		 OUT   NoCopy NUMBER
) IS

 p_atp_rec       MRP_ATP_PUB.ATP_Rec_Typ;
 x_atp_rec       MRP_ATP_PUB.ATP_Rec_Typ;
 x_atp_supply_demand  MRP_ATP_PUB.ATP_Supply_Demand_Typ;
 x_atp_period         MRP_ATP_PUB.ATP_Period_Typ;
 x_atp_details        MRP_ATP_PUB.ATP_Details_Typ;

BEGIN
msc_sch_wb.atp_debug('Inside begin of PROCEDURE Call_ATP_BPEL');

msc_sch_wb.atp_debug('Before call ATP_Rec_convert_tab');

/* Call Procedure ATP_Rec_convert_tab to convert input table of records
to record of tables. */

ATP_Rec_convert_tab( p_atp_tab,  p_atp_rec );

msc_sch_wb.atp_debug('After call ATP_Rec_convert_tab');

MRP_ATP_PUB.Call_ATP(
               p_session_id ,
               p_atp_rec ,
               x_atp_rec ,
               x_atp_supply_demand ,
               x_atp_period        ,
               x_atp_details       ,
               x_return_status     ,
               x_msg_data          ,
               x_msg_count );

 msc_sch_wb.atp_debug('After call Call_ATP');
 msc_sch_wb.atp_debug('x_atp_rec.Inventory_Item_Id.COUNT: '||x_atp_rec.Inventory_Item_Id.COUNT);
 msc_sch_wb.atp_debug('x_atp_supply_demand.Inventory_Item_Id.COUNT: '||x_atp_supply_demand.Inventory_Item_Id.COUNT);
 msc_sch_wb.atp_debug('x_atp_period.Inventory_Item_Id.COUNT: '||x_atp_period.Inventory_Item_Id.COUNT);
 msc_sch_wb.atp_debug('x_atp_details.Inventory_Item_Id.COUNT: '||x_atp_details.Inventory_Item_Id.COUNT);

/* Call Procedure ATP_Rec_convert_rec to convert  record of tables to
table of records. */

ATP_Rec_convert_rec( x_atp_rec, x_atp_tab);

 msc_sch_wb.atp_debug('After call ATP_Rec_convert_rec');
 msc_sch_wb.atp_debug('End of wrapper file Call_ATP_BPEL .');
 msc_sch_wb.atp_debug('********************************');

EXCEPTION when others then
 msc_sch_wb.atp_debug('Inside exception in Call_ATP_BPEL '||sqlerrm);

END Call_ATP_BPEL;


END MSC_ATP_BPEL;

/
