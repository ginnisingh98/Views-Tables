--------------------------------------------------------
--  DDL for Package Body OE_CAT_RESULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CAT_RESULTS_PUB" AS
/* $Header: OEXCATRB.pls 115.3 2000/10/02 13:47:03 pkm ship      $ */

G_STATUS VARCHAR2(240);
G_AVAILABLE_QUANTITY NUMBER;
G_AVAILABLE_DATE DATE;
G_FUTURE_QUANTITY NUMBER;
G_SERIAL_NUMBER NUMBER;


G_PRICING_STATUS VARCHAR2(240) := 'S';
G_CUSTOMER_PRICE NUMBER(15,2) := 0;
G_LIST_PRICE NUMBER(15,2) := 0;

PROCEDURE Check_Availability (
p_calling_module IN VARCHAR2,
p_inventory_item_id IN NUMBER,
p_organization_id IN NUMBER,
p_customer_id IN NUMBER,
p_customer_site_id IN NUMBER,
p_uom IN VARCHAR2,
p_pricelist_id IN VARCHAR2,
p_input_quantity IN NUMBER ,
p_need_by_date IN VARCHAR2,
p_vendor_item_number IN VARCHAR2,
p_currency_code IN VARCHAR2,
x_return_status OUT VARCHAR2,
x_pocall_status OUT VARCHAR2,
x_available_qty OUT NUMBER,
x_available_date OUT DATE,
x_customer_price OUT NUMBER,
x_list_price OUT NUMBER,
x_pricing_status OUT VARCHAR2
) IS

BEGIN


Get_Availability(p_inventory_item_id, p_input_quantity,p_organization_id,p_customer_id,
p_customer_site_id,p_uom,p_need_by_date );

if (p_calling_module <> 'EnterOrder') then
    OE_CATALOG_PRICING_PUB.Get_Pricing(p_inventory_item_id,g_available_quantity,p_uom,p_pricelist_id,p_customer_id,p_currency_code,p_need_by_date, g_pricing_status, g_customer_price, g_list_price);
end if;

x_return_status := g_status;
x_pocall_status := 'S';
x_available_qty := G_AVAILABLE_QUANTITY;
x_available_date := G_AVAILABLE_DATE;
x_customer_price := g_customer_price;
x_list_price := g_list_price;
x_pricing_status := g_pricing_status;
END;


PROCEDURE Get_Availability (
p_inventory_item_id IN NUMBER ,
p_input_quantity IN NUMBER,
p_organization_id IN NUMBER,
p_customer_id IN NUMBER,
p_customer_site_id IN NUMBER,
p_uom IN VARCHAR2,
p_need_by_date IN VARCHAR2
) IS

p_atp_table		MRP_ATP_PUB.ATP_Rec_Typ;
p_instance_id	     integer := -1;
p_session_id        number := 1;
x_atp_table		MRP_ATP_PUB.ATP_Rec_Typ;
x_atp_supply_demand	MRP_ATP_PUB.ATP_Supply_Demand_Typ;
x_atp_period        MRP_ATP_PUB.ATP_Period_Typ;
x_atp_details       MRP_ATP_PUB.ATP_Details_Typ;
x_return_status     VARCHAR2(1);
x_msg_data          VARCHAR2(200);
x_msg_count         NUMBER;
i number ;

BEGIN

p_atp_table.Inventory_Item_Id := MRP_ATP_PUB.number_arr(p_inventory_item_id);
p_atp_table.Source_Organization_Id := MRP_ATP_PUB.number_arr(p_organization_id);
p_atp_table.Identifier := MRP_ATP_PUB.number_arr(11);
p_atp_table.Calling_Module := MRP_ATP_PUB.number_arr(660);
p_atp_table.Customer_Id := MRP_ATP_PUB.number_arr(p_customer_id);
p_atp_table.Customer_Site_Id := MRP_ATP_PUB.number_arr(p_customer_site_id);
p_atp_table.Destination_Time_Zone := MRP_ATP_PUB.char30_arr(null);
p_atp_table.Quantity_Ordered := MRP_ATP_PUB.number_arr(p_input_quantity);
p_atp_table.Quantity_UOM := MRP_ATP_PUB.char3_arr(p_uom);
p_atp_table.Requested_Ship_Date := MRP_ATP_PUB.date_arr(null);
p_atp_table.Requested_Arrival_Date := MRP_ATP_PUB.date_arr(to_date(p_need_by_date,'DD-MON-YYYY'));
p_atp_table.Latest_Acceptable_Date := MRP_ATP_PUB.date_arr(to_date(p_need_by_date,'DD-MON-YYYY'));
p_atp_table.Delivery_Lead_Time := MRP_ATP_PUB.number_arr(null);
p_atp_table.Freight_Carrier :=  MRP_ATP_PUB.char30_arr(null);
p_atp_table.Ship_Method :=  MRP_ATP_PUB.char30_arr(null);
p_atp_table.Demand_Class :=  MRP_ATP_PUB.char30_arr(null);
p_atp_table.Ship_Set_Name :=  MRP_ATP_PUB.char30_arr(null);
p_atp_table.Arrival_Set_Name :=  MRP_ATP_PUB.char30_arr(null);
p_atp_table.Override_Flag :=  MRP_ATP_PUB.char1_arr(null);
p_atp_table.Action :=  MRP_ATP_PUB.number_arr(100);
p_atp_table.Ship_Date := MRP_ATP_PUB.date_arr(null);
p_atp_table.Available_Quantity := MRP_ATP_PUB.number_arr(null);
p_atp_table.Requested_Date_Quantity := MRP_ATP_PUB.number_arr(null);
p_atp_table.Group_Ship_Date := MRP_ATP_PUB.date_arr(null);
p_atp_table.Vendor_Id := MRP_ATP_PUB.number_arr(null);
p_atp_table.Vendor_Site_Id := MRP_ATP_PUB.number_arr(null);
p_atp_table.Insert_Flag := MRP_ATP_PUB.number_arr(null);
p_atp_table.Error_Code := MRP_ATP_PUB.number_arr(null);
p_atp_table.Message := MRP_ATP_PUB.char2000_arr(null);

-- call atp module
MRP_ATP_PUB.Call_ATP(
p_session_id,
p_atp_table,
x_atp_table,
x_atp_supply_demand,
x_atp_period,
x_atp_details,
x_return_status,
x_msg_data,
x_msg_count);

IF x_atp_table.Error_Code(1) = 0 OR x_atp_table.Error_Code(1) = 61 THEN

  g_available_quantity := p_input_quantity;
  g_available_date := to_date(p_need_by_date,'DD-MON-YYYY');
  g_status := 'Available';

ELSE

 BEGIN
   select meaning
   into g_status
   from mfg_lookups
   where lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS' and
   lookup_code = x_atp_table.Error_Code(1);
 EXCEPTION
 when others then
   g_status := 'Error retreiving Message from Database';

 END;

 g_available_quantity := to_char(x_atp_table.Requested_Date_Quantity(1));
 g_available_date := to_char(x_atp_table.Ship_Date(1));
 g_future_quantity := p_input_quantity - to_char(x_atp_table.Requested_Date_Quantity(1));
END IF;

END Get_Availability;


END OE_CAT_RESULTS_PUB ;

/
