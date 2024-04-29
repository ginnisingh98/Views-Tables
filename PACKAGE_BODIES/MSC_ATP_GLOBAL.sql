--------------------------------------------------------
--  DDL for Package Body MSC_ATP_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_GLOBAL" AS
/* $Header: MSCGLBLB.pls 120.4 2007/12/12 10:28:47 sbnaik ship $  */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'MSC_ATP_GLOBAL';


PROCEDURE Extend_Atp (
  p_atp_tab             IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2,
  p_index		IN	 NUMBER  := 1
) IS
Begin

                    x_return_status := FND_API.G_RET_STS_SUCCESS;

                    p_atp_tab.Row_Id.Extend(p_index);
                    p_atp_tab.Instance_Id.Extend(p_index);
                    p_atp_tab.Inventory_Item_Id.Extend(p_index);
                    p_atp_tab.Inventory_Item_Name.Extend(p_index);
                    p_atp_tab.Source_Organization_Id.Extend(p_index);
                    p_atp_tab.Organization_Id.Extend(p_index);
                    p_atp_tab.Source_Organization_Code.Extend(p_index);
                    p_atp_tab.Identifier.Extend(p_index);
                    p_atp_tab.Demand_Source_Header_Id.Extend(p_index);
		    p_atp_tab.Demand_Source_Delivery.Extend(p_index);
 		    p_atp_tab.Demand_Source_Type.Extend(p_index);
                    p_atp_tab.Scenario_Id.Extend(p_index);
                    p_atp_tab.Calling_Module.Extend(p_index);
                    p_atp_tab.Customer_Id.Extend(p_index);
                    p_atp_tab.Customer_Site_Id.Extend(p_index);
                    p_atp_tab.Destination_Time_Zone.Extend(p_index);
                    p_atp_tab.Quantity_Ordered.Extend(p_index);
                    p_atp_tab.Quantity_UOM.Extend(p_index);
                    p_atp_tab.Requested_Ship_Date.Extend(p_index);
                    p_atp_tab.Requested_Arrival_Date.Extend(p_index);
                    p_atp_tab.Earliest_Acceptable_Date.Extend(p_index);
                    p_atp_tab.Latest_Acceptable_Date.Extend(p_index);
                    p_atp_tab.Delivery_Lead_Time.Extend(p_index);
                    p_atp_tab.Freight_Carrier.Extend(p_index);
                    p_atp_tab.Ship_Method.Extend(p_index);
                    p_atp_tab.Demand_Class.Extend(p_index);
                    p_atp_tab.Ship_Set_Name.Extend(p_index);
                    p_atp_tab.Arrival_Set_Name.Extend(p_index);
                    p_atp_tab.Override_Flag.Extend(p_index);
                    p_atp_tab.Action.Extend(p_index);
                    p_atp_tab.Ship_Date.Extend(p_index);
		    p_atp_tab.Arrival_Date.Extend(p_index);
                    p_atp_tab.Available_Quantity.Extend(p_index);
                    p_atp_tab.Requested_Date_Quantity.Extend(p_index);
                    p_atp_tab.Group_Ship_Date.Extend(p_index);
                    p_atp_tab.Group_Arrival_Date.Extend(p_index);
                    p_atp_tab.Vendor_Id.Extend(p_index);
                    p_atp_tab.Vendor_Name.Extend(p_index);
                    p_atp_tab.Vendor_Site_Id.Extend(p_index);
                    p_atp_tab.Vendor_Site_Name.Extend(p_index);
                    p_atp_tab.Insert_Flag.Extend(p_index);
                    p_atp_tab.OE_Flag.Extend(p_index);
                    p_atp_tab.Error_Code.Extend(p_index);
                    p_atp_tab.Atp_Lead_Time.Extend(p_index);
                    p_atp_tab.Message.Extend(p_index);
                    p_atp_tab.End_Pegging_Id.Extend(p_index);
                    p_atp_tab.Order_Number.Extend(p_index);
                    p_atp_tab.Old_Source_Organization_Id.Extend(p_index);
                    p_atp_tab.Old_Demand_Class.Extend(p_index);
                    p_atp_tab.ato_delete_flag.Extend(p_index);		-- added by ngoel 6/15/2001
                    p_atp_tab.attribute_05.Extend(p_index);      	-- added by ngoel 7/31/2001
                    p_atp_tab.attribute_06.Extend(p_index);      	-- added by ngoel 8/09/2001
                    p_atp_tab.attribute_07.Extend(p_index);      	-- added for bug 2392456
                    p_atp_tab.attribute_01.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_name.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_class.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_location.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_country.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_state.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_city.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_postal_code.Extend(p_index);     -- added by ngoel 10/12/2001

                    --- added for product substitution
                    p_atp_tab.substitution_typ_code.Extend(p_index);
                    p_atp_tab.req_item_detail_flag.Extend(p_index);
                    p_atp_tab.request_item_id.Extend(p_index);
                    p_atp_tab.req_item_req_date_qty.Extend(p_index);
                    p_atp_tab.req_item_available_date.Extend(p_index);
                    p_atp_tab.req_item_available_date_qty.Extend(p_index);
                    p_atp_tab.request_item_name.Extend(p_index);
                    p_atp_tab.old_inventory_item_id.Extend(p_index);
                    p_atp_tab.sales_rep.Extend(p_index);
                    p_atp_tab.customer_contact.Extend(p_index);
                    p_atp_tab.subst_flag.Extend(p_index);

                    --diag_atp
                    p_atp_tab.attribute_02.Extend(p_index);

                    -- 24x7 Support
                    p_atp_tab.attribute_04.Extend(p_index);
                    p_atp_tab.attribute_08.Extend(p_index);             -- 24x7

                    -- CTO enhancement
                    p_atp_tab.Top_Model_line_id.Extend(p_index);
                    p_atp_tab.ATO_Parent_Model_Line_Id.Extend(p_index);
                    p_atp_tab.ATO_Model_Line_Id.Extend(p_index);
                    p_atp_tab.Parent_line_id.Extend(p_index);
                    p_atp_tab.match_item_id.Extend(p_index);
                    p_atp_tab.matched_item_name.Extend(p_index);
                    p_atp_tab.Config_item_line_id.Extend(p_index);
                    p_atp_tab.Validation_Org.Extend(p_index);
                    p_atp_tab.Component_Sequence_ID.Extend(p_index);
                    p_atp_tab.Component_Code.Extend(p_index);
                    p_atp_tab.line_number.Extend(p_index);
                    p_atp_tab.included_item_flag.Extend(p_index);
                    p_atp_tab.included_item_flag.Extend(p_index);
                    p_atp_tab.atp_flag.Extend(p_index);
                    p_atp_tab.atp_components_flag.Extend(p_index);
                    p_atp_tab.wip_supply_type.Extend(p_index);
                    p_atp_tab.bom_item_type.Extend(p_index);
                    p_atp_tab.mandatory_item_flag.Extend(p_index);
                    p_atp_tab.pick_components_flag.Extend(p_index);
                    p_atp_tab.base_model_id.Extend(p_index);
                    p_atp_tab.OSS_ERROR_CODE.Extend(p_index);
                    p_atp_tab.sequence_number.Extend(p_index);
                    p_atp_tab.firm_flag.Extend(p_index);
                    p_atp_tab.order_line_number.Extend(p_index);
                    p_atp_tab.option_number.Extend(p_index);
                    p_atp_tab.shipment_number.Extend(p_index);
                    p_atp_tab.item_desc.Extend(p_index);
                    p_atp_tab.old_line_schedule_date.Extend(p_index);
                    p_atp_tab.old_source_organization_code.Extend(p_index);
                    p_atp_tab.firm_source_org_id.Extend(p_index);
                    p_atp_tab.firm_source_org_code.Extend(p_index);
                    p_atp_tab.firm_ship_date.Extend(p_index);
                    p_atp_tab.firm_arrival_date.Extend(p_index);
                    p_atp_tab.ship_method_text.Extend(p_index);
                    p_atp_tab.ship_set_id.Extend(p_index);
                    p_atp_tab.arrival_set_id.Extend(p_index);
                    p_atp_tab.PROJECT_ID.Extend(p_index);
                    p_atp_tab.TASK_ID.Extend(p_index);
                    p_atp_tab.PROJECT_NUMBER.Extend(p_index);
                    p_atp_tab.TASK_NUMBER.Extend(p_index);
                    p_atp_tab.attribute_11.Extend(p_index);
                    p_atp_tab.attribute_12.Extend(p_index);
                    p_atp_tab.attribute_13.Extend(p_index);
                    p_atp_tab.attribute_14.Extend(p_index);
                    p_atp_tab.attribute_15.Extend(p_index);
                    p_atp_tab.attribute_16.Extend(p_index);
                    p_atp_tab.attribute_17.Extend(p_index);
                    p_atp_tab.attribute_18.Extend(p_index);
                    p_atp_tab.attribute_19.Extend(p_index);
                    p_atp_tab.attribute_20.Extend(p_index);
                    p_atp_tab.Attribute_21.Extend(p_index);
                    p_atp_tab.attribute_22.Extend(p_index);
                    p_atp_tab.attribute_23.Extend(p_index);
                    p_atp_tab.attribute_24.Extend(p_index);
                    p_atp_tab.attribute_25.Extend(p_index);
                    p_atp_tab.attribute_26.Extend(p_index);
                    p_atp_tab.attribute_27.Extend(p_index);
                    p_atp_tab.attribute_28.Extend(p_index);
                    p_atp_tab.attribute_29.Extend(p_index);
                    p_atp_tab.attribute_30.Extend(p_index);

                    p_atp_tab.atf_date.Extend(p_index);
                    --plan by request date enhancment for capturing request date in case of 24*7 ATP
                    p_atp_tab.original_request_date.Extend(p_index);
                    p_atp_tab.plan_id.Extend(p_index); -- time_phased_atp

                    p_atp_tab.cascade_model_info_to_comp.extend(p_index);

                    -- ship_rec_cal
                    p_atp_tab.receiving_cal_code.Extend(p_index);
                    p_atp_tab.intransit_cal_code.Extend(p_index);
                    p_atp_tab.shipping_cal_code.Extend(p_index);
                    p_atp_tab.manufacturing_cal_code.Extend(p_index);

                    -- Bug 3449812
                    p_atp_tab.internal_org_id.Extend(p_index);

                    --bug 3328421
                    p_atp_tab.first_valid_ship_arrival_date.Extend(p_index);

                    --2814895
                    p_atp_tab.party_site_id.Extend(p_index);

                    p_atp_tab.part_of_set.extend(p_index); --4500382

                    p_atp_tab.attribute_14.extend(p_index); --5195929

--   msc_sch_wb.atp_debug('***** End Extend_Atp Procedure *****');

END Extend_Atp;

FUNCTION Get_APS_Version
RETURN Number

IS
BEGIN

RETURN G_APS_Version;

END Get_APS_Version;

Procedure Get_ATP_Session_Id (
              x_session_id       OUT NOCOPY NUMBER,
              x_return_status    OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_dblink VARCHAR2(80);
l_instance_id number;
l_return_status varchar2(10);
BEGIN

   --get dblink
   MSC_SATP_FUNC.get_dblink_profile(l_dblink,l_instance_id,l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --RAISE FND_API.G_EXC_ERROR ;
       --if we are unable to get l_dblink then we assume that its same instance.
       -- This may happen when APS instance is not defined.
       l_return_status := FND_API.G_RET_STS_SUCCESS;
       l_dblink := null;
   END IF;

   --get session id
   MSC_SCH_WB.get_session_id(l_dblink, x_session_id);

   x_return_status := l_return_status;
EXCEPTION
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
END Get_ATP_Session_Id;


END MSC_ATP_GLOBAL;

/
