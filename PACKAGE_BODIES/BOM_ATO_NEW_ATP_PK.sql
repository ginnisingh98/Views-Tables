--------------------------------------------------------
--  DDL for Package Body BOM_ATO_NEW_ATP_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ATO_NEW_ATP_PK" as
/* $Header: BOMNATPB.pls 115.0 99/08/18 12:49:59 porting shi $ */

function config_link_atp(
         RTOMLine       in   number,
         dSrcHdrId      in   number,
         dSrcType       in   number,
         OrgId          in   number,
         error_message  out  varchar2,
         message_name   out  varchar2)

return integer is

p_atp_table		MRP_ATP_PUB.ATP_Rec_Typ;
p_instance_id		integer := -1;
p_session_id		number := 101;
x_atp_table		MRP_ATP_PUB.ATP_Rec_Typ;
x_atp_supply_demand   	MRP_ATP_PUB.ATP_Supply_Demand_Typ;
x_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
x_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
x_return_status         VARCHAR2(1);
x_msg_count             number;
x_msg_data              varchar2(200);

temp number := null;
temp1 date := null;
stmt number;
atp_error   exception;
begin

/*---------------------------------------------------------------+
  We need to inform ATP to modify demand (quanatity zero) for
  the rows that have been deactivated in mtl_demand by the Schedule
  function, as part of 'link Config' action
+----------------------------------------------------------------*/
  select inventory_item_id,
         organization_id,
         demand_id,
         primary_uom_quantity,
         uom_code,
         requirement_date,
         demand_class,
         temp,      -- calling module
         temp,      -- customer_id
         temp,      -- customer_site_id
         temp,      -- destination_time_zone
         temp1,     -- requested arrival_date
         temp1,     -- latest acceptable_date
         temp,      -- delivery lead time
         temp,      -- Freight_Carrier
         temp,      -- Ship_Method
         temp,      --Ship_Set_Name
         temp,      -- Arrival_Set_Name
         temp,      -- Override_Flag
         temp,      -- Action
         temp1,     -- Ship_date
         temp,      -- available_quantity
         temp,      -- requested_date_quantity
         temp1,     -- group_ship_date
         temp1,     -- group_arrival_date
         temp,      -- vendor_id
         temp,      -- vendor_site_id
         temp,      -- insert_flag
         temp,      -- error_code
         temp       -- Message
  bulk collect into
         p_atp_table.Inventory_Item_Id       ,
         p_atp_table.Source_Organization_Id  ,
         p_atp_table.Identifier              ,
         p_atp_table.Quantity_Ordered        ,
         p_atp_table.Quantity_UOM            ,
         p_atp_table.Requested_Ship_Date     ,
         p_atp_table.Demand_Class            ,
         p_atp_table.Calling_Module          ,
         p_atp_table.Customer_Id             ,
         p_atp_table.Customer_Site_Id        ,
         p_atp_table.Destination_Time_Zone   ,
         p_atp_table.Requested_Arrival_Date  ,
         p_atp_table.Latest_Acceptable_Date  ,
         p_atp_table.Delivery_Lead_Time      ,
         p_atp_table.Freight_Carrier         ,
         p_atp_table.Ship_Method             ,
         p_atp_table.Ship_Set_Name           ,
         p_atp_table.Arrival_Set_Name        ,
         p_atp_table.Override_Flag           ,
         p_atp_table.Action                  ,
         p_atp_table.Ship_Date               ,
         p_atp_table.Available_Quantity      ,
         p_atp_table.Requested_Date_Quantity ,
         p_atp_table.Group_Ship_Date         ,
         p_atp_table.Group_Arrival_Date      ,
         p_atp_table.Vendor_Id               ,
         p_atp_table.Vendor_Site_Id          ,
         p_atp_table.Insert_Flag             ,
         p_atp_table.Error_Code              ,
         p_atp_table.Message
    from mtl_demand md
    where md.RTO_MODEL_SOURCE_LINE   = RTOMLine
    and md.demand_source_header_id = dSrcHdrId
    and md.demand_source_type      = dSrcType
    and md.organization_id         = OrgId
    and md.primary_uom_quantity    > 0
    and md.config_status           = 80
    and md.row_status_flag         = 2
    and md.demand_type not in (1,2);

/*---------------------------------------------------------------+
  We also need to inform ATP to add demand (quanatity zero) for
  the mandatory components that have been inserted (derived demand)
  in mtl_demand by the Schedule function, as part of
  'link Config' action
+----------------------------------------------------------------*/

        select inventory_item_id,
               organization_id,
               demand_id,
               primary_uom_quantity,
               uom_code,
               requirement_date,
               demand_class,
               temp,      -- calling module
               temp,      -- customer_id
               temp,      -- customer_site_id
               temp,      -- destination_time_zone
               temp1,     -- requested arrival_date
               temp1,     -- latest acceptable_date
               temp,      -- delivery lead time
               temp,      -- Freight_Carrier
               temp,      -- Ship_Method
               temp,      --Ship_Set_Name
               temp,      -- Arrival_Set_Name
               temp,      -- Override_Flag
               temp,      -- Action
               temp1,     -- Ship_date
               temp,      -- available_quantity
               temp,      -- requested_date_quantity
               temp1,     -- group_ship_date
               temp1,     -- group_arrival_date
               temp,      -- vendor_id
               temp,      -- vendor_site_id
               temp,      -- insert_flag
               temp,      -- error_code
               temp       -- Message
        bulk collect into
               p_atp_table.Inventory_Item_Id       ,
               p_atp_table.Source_Organization_Id  ,
               p_atp_table.Identifier              ,
               p_atp_table.Quantity_Ordered        ,
               p_atp_table.Quantity_UOM            ,
               p_atp_table.Requested_Ship_Date     ,
               p_atp_table.Demand_Class            ,
               p_atp_table.Calling_Module          ,
               p_atp_table.Customer_Id             ,
               p_atp_table.Customer_Site_Id        ,
               p_atp_table.Destination_Time_Zone   ,
               p_atp_table.Requested_Arrival_Date  ,
               p_atp_table.Latest_Acceptable_Date  ,
               p_atp_table.Delivery_Lead_Time      ,
               p_atp_table.Freight_Carrier         ,
               p_atp_table.Ship_Method             ,
               p_atp_table.Ship_Set_Name           ,
               p_atp_table.Arrival_Set_Name        ,
               p_atp_table.Override_Flag           ,
               p_atp_table.Action                  ,
               p_atp_table.Ship_Date               ,
               p_atp_table.Available_Quantity      ,
               p_atp_table.Requested_Date_Quantity ,
               p_atp_table.Group_Ship_Date         ,
               p_atp_table.Group_Arrival_Date      ,
               p_atp_table.Vendor_Id               ,
               p_atp_table.Vendor_Site_Id          ,
               p_atp_table.Insert_Flag             ,
               p_atp_table.Error_Code              ,
               p_atp_table.Message
        from mtl_demand md
        where md.RTO_MODEL_SOURCE_LINE = RTOMLine
        and   md.DEMAND_SOURCE_HEADER_ID = dSrcHdrId
        and   md.DEMAND_SOURCE_TYPE = dSrcType
        and   md.ORGANIZATION_ID = OrgId
        and   md.PRIMARY_UOM_QUANTITY > 0
        and   md.config_status =20
        and   md.demand_type in (4,5)
        and   md.row_status_flag = 1
        and   md.parent_demand_id is null;

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

  IF (    x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       or x_return_status = FND_API.G_RET_STS_ERROR ) then
       raise atp_error;
  else
      return (1);
  END IF;

  exception

    when atp_error then
        error_message := 'BOMNATPB:'||to_char(stmt)||':'||' ATP API returned Error';
        message_name := 'BOM_ATO_LINK_ERROR';
        return(0);

    when others then
        error_message := 'BOMNATPB:'||to_char(stmt)||':'||substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_LINK_ERROR';
      return(0);

end config_link_atp;

function config_delink_atp (
         RTOMLine       in     number,
         dSrcHdrId      in     number,
         dSrcType       in     number,
         OrgId          in     number,
         error_message  out    varchar2,
         message_name   out    varchar2)
return integer is

p_atp_table		MRP_ATP_PUB.ATP_Rec_Typ;
p_instance_id		integer := -1;
p_session_id		number := 101;
x_atp_table		MRP_ATP_PUB.ATP_Rec_Typ;
x_atp_supply_demand   	MRP_ATP_PUB.ATP_Supply_Demand_Typ;
x_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
x_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
x_return_status         VARCHAR2(1);
x_msg_count             number;
x_msg_data              varchar2(200);

temp number := null;
temp1 date  := null;
stmt number;
atp_error   exception;

begin


   /*---------------------------------------------------------------+
     We need to inform ATP to modify demand (quanatity zero) for
     the mandatory components (derived demand) in mtl_demand
     that will be deleted by the Schedule function, as part of
     'delink Config' action
   +----------------------------------------------------------------*/
   stmt := 10;
   select inventory_item_id,
       organization_id,
       demand_id,
       primary_uom_quantity,
       uom_code,
       requirement_date,
       demand_class,
       temp,      -- calling module
       temp,      -- customer_id
       temp,      -- customer_site_id
       temp,      -- destination_time_zone
       temp1,     -- requested arrival_date
       temp1,     -- latest acceptable_date
       temp,      -- delivery lead time
       temp,      -- Freight_Carrier
       temp,      -- Ship_Method
       temp,      --Ship_Set_Name
       temp,      -- Arrival_Set_Name
       temp,      -- Override_Flag
       temp,      -- Action
       temp1,     -- Ship_date
       temp,      -- available_quantity
       temp,      -- requested_date_quantity
       temp1,     -- group_ship_date
       temp1,     -- group_arrival_date
       temp,      -- vendor_id
       temp,      -- vendor_site_id
       temp,      -- insert_flag
       temp,      -- error_code
       temp       -- Message
   bulk collect into
       p_atp_table.Inventory_Item_Id       ,
       p_atp_table.Source_Organization_Id  ,
       p_atp_table.Identifier              ,
       p_atp_table.Quantity_Ordered        ,
       p_atp_table.Quantity_UOM            ,
       p_atp_table.Requested_Ship_Date     ,
       p_atp_table.Demand_Class            ,
       p_atp_table.Calling_Module          ,
       p_atp_table.Customer_Id             ,
       p_atp_table.Customer_Site_Id        ,
       p_atp_table.Destination_Time_Zone   ,
       p_atp_table.Requested_Arrival_Date  ,
       p_atp_table.Latest_Acceptable_Date  ,
       p_atp_table.Delivery_Lead_Time      ,
       p_atp_table.Freight_Carrier         ,
       p_atp_table.Ship_Method             ,
       p_atp_table.Ship_Set_Name           ,
       p_atp_table.Arrival_Set_Name        ,
       p_atp_table.Override_Flag           ,
       p_atp_table.Action                  ,
       p_atp_table.Ship_Date               ,
       p_atp_table.Available_Quantity      ,
       p_atp_table.Requested_Date_Quantity ,
       p_atp_table.Group_Ship_Date         ,
       p_atp_table.Group_Arrival_Date      ,
       p_atp_table.Vendor_Id               ,
       p_atp_table.Vendor_Site_Id          ,
       p_atp_table.Insert_Flag             ,
       p_atp_table.Error_Code              ,
       p_atp_table.Message
   from mtl_demand md
   where md.RTO_MODEL_SOURCE_LINE = RTOMLine
   and md.demand_source_header_id = dSrcHdrId
   and md.demand_source_type = dSrcType
   and md.organization_id = OrgId
   and md.config_status = 20
   and md.row_status_flag = 1
   and md.parent_demand_id is null
   and md.primary_uom_quantity > 0
   and md.demand_type  in (4,5);

   /*---------------------------------------------------------------+
     We also need to inform ATP to add demand  for
     the model components rows in  mtl_demand that will be re-activated
     by the schedule function, as part of 'delink Config' action
   +----------------------------------------------------------------*/

   select inventory_item_id,
       organization_id,
       demand_id,
       primary_uom_quantity,
       uom_code,
       requirement_date,
       demand_class,
       temp,      -- calling module
       temp,      -- customer_id
       temp,      -- customer_site_id
       temp,      -- destination_time_zone
       temp1,     -- requested arrival_date
       temp1,     -- latest acceptable_date
       temp,      -- delivery lead time
       temp,      -- Freight_Carrier
       temp,      -- Ship_Method
       temp,      --Ship_Set_Name
       temp,      -- Arrival_Set_Name
       temp,      -- Override_Flag
       temp,      -- Action
       temp1,     -- Ship_date
       temp,      -- available_quantity
       temp,      -- requested_date_quantity
       temp1,     -- group_ship_date
       temp1,     -- group_arrival_date
       temp,      -- vendor_id
       temp,      -- vendor_site_id
       temp,      -- insert_flag
       temp,      -- error_code
       temp       -- Message
   bulk collect into
       p_atp_table.Inventory_Item_Id       ,
       p_atp_table.Source_Organization_Id  ,
       p_atp_table.Identifier              ,
       p_atp_table.Quantity_Ordered        ,
       p_atp_table.Quantity_UOM            ,
       p_atp_table.Requested_Ship_Date     ,
       p_atp_table.Demand_Class            ,
       p_atp_table.Calling_Module          ,
       p_atp_table.Customer_Id             ,
       p_atp_table.Customer_Site_Id        ,
       p_atp_table.Destination_Time_Zone   ,
       p_atp_table.Requested_Arrival_Date  ,
       p_atp_table.Latest_Acceptable_Date  ,
       p_atp_table.Delivery_Lead_Time      ,
       p_atp_table.Freight_Carrier         ,
       p_atp_table.Ship_Method             ,
       p_atp_table.Ship_Set_Name           ,
       p_atp_table.Arrival_Set_Name        ,
       p_atp_table.Override_Flag           ,
       p_atp_table.Action                  ,
       p_atp_table.Ship_Date               ,
       p_atp_table.Available_Quantity      ,
       p_atp_table.Requested_Date_Quantity ,
       p_atp_table.Group_Ship_Date         ,
       p_atp_table.Group_Arrival_Date      ,
       p_atp_table.Vendor_Id               ,
       p_atp_table.Vendor_Site_Id          ,
       p_atp_table.Insert_Flag             ,
       p_atp_table.Error_Code              ,
       p_atp_table.Message
   from mtl_demand md
   where md.rto_model_source_line = RTOMLine
   and   md.demand_source_header_id = dSrcHdrId
   and   md.demand_source_type = dSrcType
   and   md.organization_id = orgId
   and   md.primary_uom_quantity > 0
   and   md.config_status =80
   and   md.row_status_flag = 2;

   /*---------------------------------------+
        call atp module
   +----------------------------------------*/

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

  IF (    x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       or x_return_status = FND_API.G_RET_STS_ERROR ) then
       raise atp_error;
  else
      return (1);
  END IF;

  exception
    when atp_error then
        error_message := 'BOMNATPB:'||to_char(stmt)||':'||' ATP API returned Error';
        message_name := 'BOM_ATO_LINK_ERROR';
        return(0);

    when others then
        error_message := 'BOMNATPB:'||to_char(stmt)||':'||substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_LINK_ERROR';
      return(0);

end config_delink_atp;
end BOM_ATO_NEW_ATP_PK;

/
