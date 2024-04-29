--------------------------------------------------------
--  DDL for Package Body OE_RELATED_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RELATED_ITEMS_PVT" AS
/* $Header: OEXFRELB.pls 120.4 2006/09/05 19:07:11 sdatti noship $ */

--  Global variables

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'Oe_Related_Items_Pvt';
G_ATP_TBL          OE_ATP.atp_tbl_type;
G_line_id          CONSTANT NUMBER := 1237;
G_atp_line_id      CONSTANT NUMBER := -9987;
--g_header_id        CONSTANT NUMBER :=2345;
g_header_id        NUMBER;
g_hsecs		   NUMBER;
g_place            varchar2(100);
g_total            number :=0;
g_total2           number ;
g_inventory_item_id      number;
g_related_item_id        number ;
g_qty                    number ;
g_uom                    varchar2(20);
g_request_date           date ;
/*
g_related_item_id        number := 149;
g_qty                    number := 1;
g_uom                    varchar2(20) := 'Ea';
g_request_date           date := '10-OCT-2002';
*/
g_customer_id            number;
g_item_identifier_type   varchar2(40);
g_agreement_id           number;
g_price_list_id          number;
g_ship_to_org_id         number;
g_invoice_to_org_id      number;
g_ship_from_org_id       number;
g_pricing_date           date;
g_order_type_id          number;
g_currency               varchar2(20);

g_pricing_context        varchar2(30);
g_pricing_attribute1     varchar2(240);
g_pricing_attribute2     varchar2(240);
g_pricing_attribute3     varchar2(240);
g_pricing_attribute4     varchar2(240);
g_pricing_attribute5     varchar2(240);
g_pricing_attribute6     varchar2(240);
g_pricing_attribute7     varchar2(240);
g_pricing_attribute8     varchar2(240);
g_pricing_attribute9     varchar2(240);
g_pricing_attribute10    varchar2(240);
g_pricing_attribute11    varchar2(240);
g_pricing_attribute12    varchar2(240);
g_pricing_attribute13    varchar2(240);
g_pricing_attribute14    varchar2(240);
g_pricing_attribute15    varchar2(240);
g_pricing_attribute16    varchar2(240);
g_pricing_attribute17    varchar2(240);
g_pricing_attribute18    varchar2(240);
g_pricing_attribute19    varchar2(240);
g_pricing_attribute20    varchar2(240);
g_pricing_attribute21    varchar2(240);
g_pricing_attribute22    varchar2(240);
g_pricing_attribute23    varchar2(240);
g_pricing_attribute24    varchar2(240);
g_pricing_attribute25    varchar2(240);
g_pricing_attribute26    varchar2(240);
g_pricing_attribute27    varchar2(240);
g_pricing_attribute28    varchar2(240);
g_pricing_attribute29    varchar2(240);
g_pricing_attribute30    varchar2(240);
g_pricing_attribute31    varchar2(240);
g_pricing_attribute32    varchar2(240);
g_pricing_attribute33    varchar2(240);
g_pricing_attribute34    varchar2(240);
g_pricing_attribute35    varchar2(240);
g_pricing_attribute36    varchar2(240);
g_pricing_attribute37    varchar2(240);
g_pricing_attribute38    varchar2(240);
g_pricing_attribute39    varchar2(240);
g_pricing_attribute40    varchar2(240);
g_pricing_attribute41    varchar2(240);
g_pricing_attribute42    varchar2(240);
g_pricing_attribute43    varchar2(240);
g_pricing_attribute44    varchar2(240);
g_pricing_attribute45    varchar2(240);
g_pricing_attribute46    varchar2(240);
g_pricing_attribute47    varchar2(240);
g_pricing_attribute48    varchar2(240);
g_pricing_attribute49    varchar2(240);
g_pricing_attribute50    varchar2(240);
g_pricing_attribute51    varchar2(240);
g_pricing_attribute52    varchar2(240);
g_pricing_attribute53    varchar2(240);
g_pricing_attribute54    varchar2(240);
g_pricing_attribute55    varchar2(240);
g_pricing_attribute56    varchar2(240);
g_pricing_attribute57    varchar2(240);
g_pricing_attribute58    varchar2(240);
g_pricing_attribute59    varchar2(240);
g_pricing_attribute60    varchar2(240);
g_pricing_attribute61    varchar2(240);
g_pricing_attribute62    varchar2(240);
g_pricing_attribute63    varchar2(240);
g_pricing_attribute64    varchar2(240);
g_pricing_attribute65    varchar2(240);
g_pricing_attribute66    varchar2(240);
g_pricing_attribute67    varchar2(240);
g_pricing_attribute68    varchar2(240);
g_pricing_attribute69    varchar2(240);
g_pricing_attribute70    varchar2(240);
g_pricing_attribute71    varchar2(240);
g_pricing_attribute72    varchar2(240);
g_pricing_attribute73    varchar2(240);
g_pricing_attribute74    varchar2(240);
g_pricing_attribute75    varchar2(240);
g_pricing_attribute76    varchar2(240);
g_pricing_attribute77    varchar2(240);
g_pricing_attribute78    varchar2(240);
g_pricing_attribute79    varchar2(240);
g_pricing_attribute80    varchar2(240);
g_pricing_attribute81    varchar2(240);
g_pricing_attribute82    varchar2(240);
g_pricing_attribute83    varchar2(240);
g_pricing_attribute84    varchar2(240);
g_pricing_attribute85    varchar2(240);
g_pricing_attribute86    varchar2(240);
g_pricing_attribute87    varchar2(240);
g_pricing_attribute88    varchar2(240);
g_pricing_attribute89    varchar2(240);
g_pricing_attribute90    varchar2(240);
g_pricing_attribute91    varchar2(240);
g_pricing_attribute92    varchar2(240);
g_pricing_attribute93    varchar2(240);
g_pricing_attribute94    varchar2(240);
g_pricing_attribute95    varchar2(240);
g_pricing_attribute96    varchar2(240);
g_pricing_attribute97    varchar2(240);
g_pricing_attribute98    varchar2(240);
g_pricing_attribute99    varchar2(240);
g_pricing_attribute100   varchar2(240);

PROCEDURE get_upgrade_item_details(l_inv_item_id in number,
				   out_inv_item_name out nocopy varchar2,
				   out_inv_desc out nocopy varchar2,
				   out_inv_item_type out nocopy varchar2
			)
IS
l_org_id number := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
SELECT concatenated_segments,description,item_type
       INTO  out_inv_item_name,out_inv_desc,out_inv_item_type
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = l_inv_item_id
       AND    organization_id = l_org_id;


EXCEPTION
    when no_data_found then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_OE_RELATED_ITEMS.GET_item_upgrade_details NO DATA FOUND' ) ;
        END IF;
    when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_OE_RELATED_ITEMS.GET_item_NAME WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
                        END IF;

END get_upgrade_item_details;



PROCEDURE defaulting(
		     p_org_id in varchar2
		     ,p_cust_account_id in number
		     ,p_related_item_id in number
		     ,p_ship_to_org_id in number
		     ,p_line_set_id in number
		     ,p_ship_set_id in number
		     ,p_line_type_id in number
		     ,p_deliver_to_org_id in number
		     ,p_accounting_rule_id in number
		     ,p_accounting_rule_duration in number
		     ,p_actual_arrival_date in date
		     ,p_actual_shipment_date in date
		     ,p_cancelled_flag in varchar2
		     ,p_fob_point_code in varchar2
		     ,p_invoicing_rule_id in number
		     ,p_item_type_code in varchar2
		     ,p_line_category_code in varchar2
		     ,p_open_flag in varchar2
		     ,p_promise_date in date
		     ,p_salesrep_id in number
		     ,p_schedule_ship_date in date
		     ,p_schedule_arrival_date in date
		     ,p_customer_shipment_number in number
		     ,p_agreement_id in number
		     ,p_header_id in number
		     ,p_invoice_to_org_id in number
		     ,p_price_list_id in number
		     ,p_request_date in date
		     ,p_arrival_set_id in number
		     ,x_wsh_id  out NOCOPY /* file.sql.39 change */ number
		     ,x_uom  out NOCOPY /* file.sql.39 change */ varchar2
                     ) IS

   x_msg_count number;
   x_msg_data varchar2(2000);
   x_return_status varchar2(2000);

l_old_line_rec        oe_ak_order_lines_v%ROWTYPE;
l_line_rec            oe_ak_order_lines_v%ROWTYPE;
l_out_line_rec        oe_ak_order_lines_v%ROWTYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_RELATED_ITEMS_PVT.DEFAULTING '||
			 'ITEM_ID='||P_RELATED_ITEM_ID||
			 'ORG ID TYPE ='||P_ORG_ID||
			 'CUSTOMER_ID ='||P_CUST_ACCOUNT_ID||
			 'SHIP_TO_ORG_ID ='||P_SHIP_TO_ORG_ID||
			 'P_ACCOUNTING_RULE_ID'|| p_accounting_rule_id ||
			 'P_ACCOUNTING_RULE_DURATION'||p_accounting_rule_duration ||
			 'P_ACTUAL_ARRIVAL_DATE'||p_actual_arrival_date ||
			 'P_ACTUAL_SHIPMENT_DATE'||p_actual_shipment_date||
			 'P_CANCELLED_FLAG'||p_cancelled_flag ||
			 'P_FOB_POINT_CODE'||p_fob_point_code ||
			 'P_INVOICING_RULE_ID'||p_invoicing_rule_id||
			 'P_ITEM_TYPE_CODE'||p_item_type_code||
			 'P_LINE_CATEGORY_CODE'||p_line_category_code||
			 'P_OPEN_FLAG'||p_open_flag ||
			 'P_PROMISE_DATE'||p_promise_date||
			 'P_SALESREP_ID'||p_salesrep_id ||
			 'P_SCHEDULE_SHIP_DATE'||p_schedule_ship_date ||
			 'P_SCHEDULE_ARRIVAL_DATE'||p_schedule_arrival_date ||
			 'P_CUSTOMER_SHIPMENT_NUMBER'||p_customer_shipment_number||
			 'P_AGREEMENT_ID'||p_agreement_id ||
		 	 'P_HEADER_ID'||p_header_id ||
			 'P_INVOICE_TO_ORG_ID'||p_invoice_to_org_id ||
			 'P_PRICE_LIST_ID'||p_price_list_id||
			 'P_REQUEST_DATE'||p_request_date||
			 'P_ARRIVAL_SET_ID'||p_arrival_set_id ) ;
   END IF;

   l_line_rec.inventory_item_id     := p_related_item_id;
   l_line_rec.org_id                := p_org_id;
   l_line_rec.sold_to_org_id        := p_cust_account_id;
   l_line_rec.ship_to_org_id        := p_ship_to_org_id;
   ---Bug 2992459
   l_line_rec.accounting_rule_id    := p_accounting_rule_id;
   l_line_rec.accounting_rule_duration := p_accounting_rule_duration;
   l_line_rec.actual_arrival_date := p_actual_arrival_date;
   l_line_rec.actual_shipment_date := p_actual_shipment_date;
   l_line_rec.cancelled_flag := p_cancelled_flag;
   l_line_rec.fob_point_code := p_fob_point_code;
   l_line_rec.invoicing_rule_id := p_invoicing_rule_id;
   l_line_rec.item_type_code := p_item_type_code;
   l_line_rec.line_category_code := p_line_category_code;
   l_line_rec.open_flag := p_open_flag;
   l_line_rec.promise_date := p_promise_date;
   l_line_rec.salesrep_id := p_salesrep_id;
   l_line_rec.schedule_ship_date := p_schedule_ship_date;
   l_line_rec.schedule_arrival_date := p_schedule_arrival_date;
   l_line_rec.customer_shipment_number:= p_customer_shipment_number;
   l_line_rec.agreement_id := p_agreement_id;
   l_line_rec.header_id := p_header_id;
   l_line_rec.invoice_to_org_id := p_invoice_to_org_id;
   l_line_rec.price_list_id := p_price_list_id;
   l_line_rec.request_date := p_request_date;
   l_line_rec.arrival_set_id := p_arrival_set_id;
   --Bug 2992459
   l_line_rec.ship_from_org_id      := FND_API.G_MISS_NUM;
   l_line_rec.order_quantity_uom    := FND_API.G_MISS_CHAR;

   l_out_line_rec := l_line_rec;

   ONT_LINE_DEF_HDLR.Default_record(
				    p_x_rec => l_out_line_rec,
				    p_initial_rec =>l_line_rec,
				    p_in_old_rec  => l_old_line_rec
                                    );
   x_wsh_id           := l_out_line_rec.ship_from_org_id;
   x_uom              := l_out_line_rec.order_quantity_uom;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'WSH_ID='||X_WSH_ID|| ' X_UOM=' || X_UOM ) ;
   END IF;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_RELATED_ITEMS_PVT.DEFAULTING' ) ;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

      OE_MSG_PUB.Count_And_Get
	 (   p_count                       => x_msg_count
	     ,   p_data                        => x_msg_data
	     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      --  Get message count and data

      OE_MSG_PUB.Count_And_Get
	 (   p_count                       => x_msg_count
	     ,   p_data                        => x_msg_data
	     );

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	   OE_MSG_PUB.Add_Exc_Msg
	      (   G_PKG_NAME
		  ,   'defaulting'
		  );
END IF;

--  Get message count and data

OE_MSG_PUB.Count_And_Get
   (   p_count                       => x_msg_count
       ,   p_data                        => x_msg_data
       );

END defaulting;


Procedure Call_MRP_ATP(
               p_global_orgs       in varchar2,
               p_ship_from_org_id  in number,
	       p_related_item_id   in number,
	       p_related_uom       in VARCHAR2,
	       p_request_date	    in DATE,
	       p_ordered_qty	    in NUMBER,
	       p_cust_account_id   in NUMBER,
               p_ship_to_org_id    in NUMBER,
               x_available_qty    out NOCOPY /* file.sql.39 change */ varchar2,
               x_ship_from_org_id out NOCOPY /* file.sql.39 change */ number,
               x_available_date   out NOCOPY /* file.sql.39 change */ date,
               x_qty_uom          out NOCOPY /* file.sql.39 change */ varchar2,
               x_out_message        out NOCOPY /* file.sql.39 change */ varchar2,
               x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
               x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER,
               x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
               x_error_message      out NOCOPY /* file.sql.39 change */ varchar2
                      ) IS

l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
x_atp_rec                 MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_rec                 MRP_ATP_PUB.ATP_Rec_Typ;
I                         NUMBER := 1;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING CALL ATP' ) ;
   END IF;

   Initialize_mrp_record
       ( p_x_atp_rec => l_atp_rec
         ,l_count    =>1 );


        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INVENTORY_ITEM_ID='||P_RELATED_ITEM_ID||
	' SHIP_FORM_ORG_ID='||P_SHIP_FROM_ORG_ID|| ' P_GLOBAL_ORGS='||
	P_GLOBAL_ORGS|| ' CUST_ID='||P_CUST_ACCOUNT_ID|| ' SHIP_TO_ORG_ID='||
	P_SHIP_TO_ORG_ID||' QTY='||P_ORDERED_QTY|| ' UOM='||P_RELATED_UOM||' REQ DATE='||P_REQUEST_DATE ) ;
        END IF;
/*
   --if the call is made for GA then the org_id is passed
   IF p_global_orgs = 'Y' and
      in_ship_from_org_id is not null then

     lin_atp_rec_atp_rec.Source_Organization_Id(1)  := in_ship_from_org_id;
   ELSE

     l_atp_rec.Source_Organization_Id(1)  := g_ship_from_org_id;
   END IF;
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE_ID='||G_ATP_LINE_ID ) ;
   END IF;

   l_atp_rec.Source_Organization_Id(1)  := p_ship_from_org_id;
   l_atp_rec.Identifier(I)              := g_atp_line_id;
   l_atp_rec.Action(I)                  := 100;
   l_atp_rec.calling_module(I)          := 660;
   l_atp_rec.customer_id(I)             := p_cust_account_id;
   l_atp_rec.customer_site_id(I)        := p_ship_to_org_id;
   l_atp_rec.inventory_item_id(I)       := p_related_item_id;
   l_atp_rec.quantity_ordered(I)        := p_ordered_qty;
   l_atp_rec.quantity_uom(I)            := p_related_uom;
   l_atp_rec.Earliest_Acceptable_Date(I):= null;
   l_atp_rec.Requested_Ship_Date(I)     := p_request_date;
   l_atp_rec.Requested_Arrival_Date(I)  := null;
   l_atp_rec.Delivery_Lead_Time(I)      := Null;
   l_atp_rec.Freight_Carrier(I)         := null;
   l_atp_rec.Ship_Method(I)             := null;
   l_atp_rec.Demand_Class(I)            := null;
   l_atp_rec.Ship_Set_Name(I)           := null;
   l_atp_rec.Arrival_Set_Name(I)        := null;
   l_atp_rec.Override_Flag(I)           := 'N';
   l_atp_rec.Ship_Date(I)               := null;
   l_atp_rec.Available_Quantity(I)      := null;
   l_atp_rec.Requested_Date_Quantity(I) := null;
   l_atp_rec.Group_Ship_Date(I)         := null;
   l_atp_rec.Group_Arrival_Date(I)      := null;
   l_atp_rec.Vendor_Id(I)               := null;
   l_atp_rec.Vendor_Site_Id(I)          := null;
   l_atp_rec.Insert_Flag(I)             := 1; -- it can be 0 or 1
   l_atp_rec.Error_Code(I)              := null;
   l_atp_rec.Message(I)                 := null;
   l_atp_rec.atp_lead_time(I)           := 0;

   SELECT mrp_atp_schedule_temp_s.nextval
     INTO l_session_id
     FROM dual;

   -- Call ATP

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
   END IF;

    IF l_debug_level  > 0 THEN
     print_time('Calling MRP');
    END IF;

   MRP_ATP_PUB.Call_ATP (
                 p_session_id             =>  l_session_id
               , p_atp_rec                =>  l_atp_rec
               , x_atp_rec                =>  x_atp_rec
               , x_atp_supply_demand      =>  l_atp_supply_demand
               , x_atp_period             =>  l_atp_period
               , x_atp_details            =>  l_atp_details
               , x_return_status          =>  x_return_status
               , x_msg_data               =>  x_msg_data
               , x_msg_count              =>  x_msg_count
                    );

    IF l_debug_level  > 0 THEN
     print_time('After Calling MRP');
    END IF;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'AFTER CALL MRP_ATP_PUB.CALL_ATP STS='||
	X_RETURN_STATUS|| ' MSG COUNT='||X_MSG_COUNT|| ' MSG DATA='||X_MSG_DATA||
	 'AVL QTY='|| X_ATP_REC.AVAILABLE_QUANTITY ( 1 ) || 'SHIP_FROM_ORG_ID =' ||
	X_ATP_REC.SOURCE_ORGANIZATION_ID ( 1 ) ) ;
                   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ERROR IS' || X_MSG_DATA , 1 ) ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   Check_Results_from_rec(
                       p_global_orgs =>'Y'
                      ,p_atp_rec       => x_atp_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count  =>x_msg_count
                      ,x_msg_data =>x_msg_data
                      ,x_error_message  =>x_error_message
                         );

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'STATUS='||X_RETURN_STATUS|| ' X_ERROR_MESSAGE ='||X_ERROR_MESSAGE|| ' MSG DATA='||X_MSG_DATA ) ;
                    END IF;

   IF x_return_status <> 'P' then

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN_STATUS<>P' ) ;
     END IF;

     IF nvl(x_atp_rec.available_quantity(1),0) = 0 then

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AVAILABLE QUANTITY IS 0' ) ;
       END IF;
       x_available_date   := null;
       x_available_qty    := 0;

     ELSE
       x_available_qty    := x_atp_rec.available_quantity(1);
       x_available_date    := x_atp_rec.ship_date(1);
       IF x_atp_rec.group_ship_date(1) is not null THEN
         x_available_date  := x_atp_rec.group_ship_date(1);
       END IF;

     END IF;

   ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN_STATUS=P MESG='||X_ERROR_MESSAGE ) ;
     END IF;
     x_available_qty    := x_error_message;
     x_available_date   := null;
     x_error_message := null;

   END IF;


   x_ship_from_org_id := x_atp_rec.source_organization_id(1);
   x_qty_uom          := x_atp_rec.quantity_uom(1);


           IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OUT_AVAL_QTY='||X_AVAILABLE_QTY||
	' SHIP_FORM_ORG_ID='||X_SHIP_FROM_ORG_ID|| ' UOM='||X_QTY_UOM||
	 ' OUT SHIP DATE='||X_ATP_REC.SHIP_DATE ( 1 ) || ' OUT GRP SHIP DATE='||
	X_ATP_REC.GROUP_SHIP_DATE ( 1 ) || ' OUT ARRIVAL DATE='||
	X_ATP_REC.ARRIVAL_DATE ( 1 ) || ' OUT GRP ARRIVAL DATE='||
	X_ATP_REC.ARRIVAL_DATE ( 1 ) || ' REQ DATE QTY='||
	X_ATP_REC.REQUESTED_DATE_QUANTITY ( 1 ) ||
	' AVAILABLE QTY='||X_ATP_REC.AVAILABLE_QUANTITY ( 1 ) ) ;
            END IF;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING CALL ATP' , 1 ) ;
   END IF;


EXCEPTION

   WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN OTHERS OF CALL_MRP_ATP' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CODE='||SQLCODE||' MSG='||SQLERRM ) ;
        END IF;
        x_return_status := 'E';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Call_MRP_ATP');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Call_MRP_ATP;


Procedure Initialize_mrp_record
         ( p_x_atp_rec IN  OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
          ,l_count     IN  NUMBER) IS

l_return_status varchar2(10);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXTENDING THE TABLE BY ' || L_COUNT , 5 ) ;
  END IF;

  MSC_SATP_FUNC.Extend_ATP
  (p_atp_tab       => p_x_atp_rec,
   p_index         => l_count,
   x_return_status => l_return_status);

EXCEPTION

   WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Initialize_mrp_record');
       END IF;

END Initialize_mrp_record;

Procedure Check_Results_from_rec (
        p_global_orgs in varchar2
       ,p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
       ,x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
       ,x_msg_count       OUT NOCOPY /* file.sql.39 change */ NUMBER
       ,x_msg_data        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
       ,x_error_message   OUT NOCOPY /* file.sql.39 change */ varchar2
                                )IS

atp_count          NUMBER := 1;
J                  NUMBER := 1;
l_explanation      VARCHAR2(80);
l_type_code        VARCHAR2(30);
l_ship_set_name    VARCHAR2(30);
l_arrival_set_name VARCHAR2(30);
l_arrival_date     DATE := NULL;
l_sch_action       varchar2(100) := 'OESCH_ACT_ATP_CHECK';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status :=  'S';
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  '2. ENTERING CHECK_RESULTS ERROR_CODE='|| P_ATP_REC.ERROR_CODE ( J ) || ' P_GLOBAL_ORGS='||P_GLOBAL_ORGS ) ;
                   END IF;

  IF p_atp_rec.error_code(J) <> 0 AND
        p_atp_rec.error_code(J) <> -99  AND -- Multi org changes.
        p_atp_rec.error_code(J) <> 150 -- to fix bug 1880166

     THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR FROM MRP: ' || P_ATP_REC.ERROR_CODE ( J ) , 1 ) ;
      END IF;

      IF p_atp_rec.error_code(J) = 80 THEN

          l_explanation := null;

          select meaning
            into l_explanation
            from mfg_lookups
           where lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
             and lookup_code = 80;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SETTING THE MESSAGE FOR OE_SCH_NO_SOURCE' ) ;
          END IF;
          --FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_SOURCE');
          IF p_global_orgs = 'N' then

            FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_NO_SOURCES');
            OE_MSG_PUB.Add;
          ELSE
            x_error_message := l_explanation;
          END IF;

      ELSE

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SCH FAILED ERROR CODE='||P_ATP_REC.ERROR_CODE ( J ) ) ;
          END IF;

          l_explanation := null;

          select meaning
            into l_explanation
            from mfg_lookups
           where lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
             and lookup_code = p_atp_rec.error_code(J) ;

          IF p_atp_rec.error_code(J) = 19 THEN
             -- This error code is given for those lines which are
             -- in a group and whose scheduling failed due to some other lines.
             -- We do not want to give this out as a message.
             null;

          ELSIF p_atp_rec.error_code(J) = 61 THEN

            -- setting the status flag to partial for ATP not applicable
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ERROR CODE = 61' ) ;
            END IF;

            x_return_status := 'P';
            x_error_message := l_explanation;

          ELSIF p_atp_rec.Ship_Set_Name(J) is not null OR
                  p_atp_rec.Arrival_Set_Name(J) is not null THEN

             -- This line belongs to a scheduling group. We do not want
             -- to give out individual messages for each line.
             null;

          ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ADDING MESSAGE TO THE STACK' , 1 ) ;
              END IF;
              --FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
              --FND_MESSAGE.SET_TOKEN('EXPLANATION',l_explanation);

              IF p_global_orgs = 'N' then
                FND_MESSAGE.SET_NAME('ONT','ONT_INLNE_CUSTOMER');
                FND_MESSAGE.SET_TOKEN('TEXT',l_explanation);
                OE_MSG_PUB.Add;
              ELSE
                x_error_message := l_explanation;
              END IF;

          END IF;

      END IF; -- 80

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SETTING ERROR' , 1 ) ;
      END IF;
      IF x_return_status <> 'P' then
        x_return_status := 'E';
      END IF;

  ELSE

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  ' ELSE '||P_ATP_REC.SOURCE_ORGANIZATION_ID ( 1 ) || ' ERROR CODE : ' || P_ATP_REC.ERROR_CODE ( J ) ) ;
                      END IF;

      -- Muti org changes.
      IF (p_atp_rec.error_code(J) <> -99 ) THEN

            IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ERROR CODE : ' ||
                        P_ATP_REC.ERROR_CODE ( J ) || 'IDENTIFIER : ' ||
                        P_ATP_REC.IDENTIFIER ( J ) || 'ITEM : ' ||
                        P_ATP_REC.INVENTORY_ITEM_ID ( J ) || 'REQUEST SHIP DATE :' ||
                        TO_CHAR ( P_ATP_REC.REQUESTED_SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) ||
                        'REQUEST ARRIVAL DATE :' ||
                       P_ATP_REC.REQUESTED_ARRIVAL_DATE ( J ) ||
		'ARRIVAL DATE :' || TO_CHAR ( P_ATP_REC.ARRIVAL_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) ||
		'SHIP DATE :' ||
		TO_CHAR ( P_ATP_REC.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) ||
                'LEAD TIME :' ||P_ATP_REC.DELIVERY_LEAD_TIME ( J ) ||
		'GROUP SHIP DATE :'||P_ATP_REC.GROUP_SHIP_DATE ( J ) ||
		'GROUP ARR DATE :'||P_ATP_REC.GROUP_ARRIVAL_DATE ( J ) ) ;
           END IF;

        l_explanation := null;

        IF (p_atp_rec.error_code(J) <> 0) THEN

          BEGIN
              select meaning
                into l_explanation
                from mfg_lookups
               where lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
                 and lookup_code = p_atp_rec.error_code(J) ;

              g_atp_tbl(atp_count).error_message   := l_explanation;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'EXPLANATION IS : ' || L_EXPLANATION , 1 ) ;
              END IF;
              x_error_message := l_explanation;

              IF p_atp_rec.error_code(J) = 150 THEN
                OE_MSG_PUB.add_text(l_explanation);
              END IF;

          EXCEPTION
              WHEN OTHERS THEN
                  Null;
          END;

        END IF;

      END IF; --Check for -99.

  END IF; -- Main If;

  -- umcomment for testing the error handling
  --x_return_status := 'E';
  --FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_SOURCE');
  --OE_MSG_PUB.Add;

  IF x_return_status ='E'  and p_global_orgs = 'N' then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DOING COUNT_AND_GET' ) ;
    END IF;
    oe_msg_pub.count_and_get(p_encoded=>fnd_api.G_TRUE,
                             p_count => x_msg_count,
                             p_data=>x_msg_data
                             );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT = '||X_MSG_COUNT||' MSG='||X_MSG_DATA ) ;
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CHECK_RESULTS: ' || X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Results'
            );
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN CHECK_RESULTS' ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Check_Results_from_rec;

PROCEDURE get_ship_from_org(in_org_id in number,
                            out_code out NOCOPY /* file.sql.39 change */ varchar2,
                            out_name out NOCOPY /* file.sql.39 change */ varchar2
                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT organization_code,
           name
      INTO out_code,
           out_name
      FROM oe_ship_from_orgs_v
     WHERE organization_id = in_org_id;

EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_SHIP_FROM_ORG WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;

END get_ship_From_org;

procedure copy_Header_to_request(
              p_request_type_code in varchar2
             ,p_calculate_price_flag in varchar2
             ,px_req_line_tbl   in out nocopy	QP_PREQ_GRP.LINE_TBL_TYPE
                                ) is

l_line_index	pls_integer := 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_RELATED_ITEMS_PVT.COPY_HEADER_TO_REQUEST' , 1 ) ;
      oe_debug_pub.add(  ' line index in copy header to request'||l_line_index);
  END IF;

  l_line_index := l_line_index+1;
  px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE :=p_Request_Type_Code;
  px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
  px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'ORDER';
  -- Hold the header_id in line_id for 'HEADER' Records

  px_req_line_tbl(l_line_index).line_id := g_line_id;

  if g_pricing_date is null or g_pricing_date = fnd_api.g_miss_date then
    px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
  Else
    px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := g_pricing_date;
  End If;

  px_req_line_tbl(l_line_index).CURRENCY_CODE := g_currency;
  px_req_line_tbl(l_line_index).PRICE_FLAG := p_calculate_price_flag;
  px_req_line_tbl(l_line_index).Active_date_first_type := 'ORD';
  px_req_line_tbl(l_line_index).Active_date_first := g_request_date;


  --If G_ROUNDING_FLAG = 'Y' Then
  IF g_price_list_id is not null then
    px_req_line_tbl(l_line_index).Rounding_factor := Get_Rounding_factor(g_price_list_id);
  END IF;
  --End If;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CURR='||G_CURRENCY||' REQ DATE='||G_REQUEST_DATE||' ROUNDING_FACTOR='||PX_REQ_LINE_TBL ( L_LINE_INDEX ) .ROUNDING_FACTOR ) ;
  END IF;

  --px_req_line_tbl(l_line_index).price_request_code := p_header_rec.price_request_code; -- PROMOTIONS SEP/01

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_OE_RELATED_ITEMS_PVT.COPY_HEADER_TO_REQUEST' ) ;
  END IF;

END copy_Header_to_request;

PROCEDURE copy_Line_to_request(
           px_req_line_tbl   in out nocopy QP_PREQ_GRP.LINE_TBL_TYPE
          ,p_pricing_event   in    varchar2
          ,p_Request_Type_Code in	varchar2
          ,p_honor_price_flag in VARCHAR2 Default 'Y'
          ) IS

l_line_index	pls_integer := nvl(px_req_line_tbl.count,0);
v_discounting_privilege VARCHAR2(30);
l_item_type_code VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_RELATED_ITEMS_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
      oe_debug_pub.add(  'line index in copy line to request'||l_line_index);
  END IF;

  l_line_index := l_line_index+1;
  px_req_line_tbl(l_line_index).Line_id := g_line_id;
  px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := p_Request_Type_Code;
  px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
  px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'LINE';

  IF g_pricing_date is null or g_pricing_date = fnd_api.g_miss_date then
    px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
  ELSE
    px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := g_pricing_date;
  END IF;

  px_req_line_tbl(l_line_index).LINE_QUANTITY := g_qty ;
  px_req_line_tbl(l_line_index).LINE_UOM_CODE := g_uom;
  px_req_line_tbl(l_line_index).PRICED_QUANTITY := g_qty;
  px_req_line_tbl(l_line_index).PRICED_UOM_CODE := g_uom;
  px_req_line_tbl(l_line_index).CURRENCY_CODE :=g_currency;
  px_req_line_tbl(l_line_index).UNIT_PRICE := Null;
  --px_req_line_tbl(l_line_index).PERCENT_PRICE := p_Line_rec.unit_list_percent;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QTY='||G_QTY||' UOM ='||G_UOM||' CURR='||G_CURRENCY ) ;
  END IF;

  /*If (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) Then
    px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration;
  Else
    INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.service_period
                             ,To_Unit   => p_Line_rec.Order_quantity_uom
                             ,Item_ID   => p_Line_rec.Inventory_item_id
                             ,Uom_Rate  => l_Uom_rate);
    px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration * l_uom_rate;
  End If; */

  --If G_ROUNDING_FLAG = 'Y' Then
    px_req_line_tbl(l_line_index).Rounding_factor :=
                                      Get_Rounding_factor(g_price_list_id);
  --End If;

  px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';


  -- Get Discounting Privilege Profile Option value
  fnd_profile.get('ONT_DISCOUNTING_PRIVILEGE', v_discounting_privilege);

  -- Execute the pricing phase if the list price is null

  IF p_pricing_event = 'PRICE' and
     px_req_line_tbl(l_line_index).UNIT_PRICE is null then

    px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y' ;

  END IF;

  --l_item_type_code := oe_line_util.Get_Return_Item_Type_Code(p_Line_rec);
  l_item_type_code := 'STANDARD';

  px_req_line_tbl(l_line_index).Active_date_first_type := 'ORD';
  px_req_line_tbl(l_line_index).Active_date_first := g_request_date;

  IF g_request_date is not null then
    px_req_line_tbl(l_line_index).Active_date_Second_type := 'SHIP';
    px_req_line_tbl(l_line_index).Active_date_Second := g_request_date;
  End If;

  --px_req_line_tbl(l_line_index).price_request_code := p_line_rec.price_request_code; -- PROMOTIONS  SEP/01
  --px_req_line_tbl(l_line_index).line_category :=p_line_rec.line_category_code;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_RELATED_ITEMS_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
  END IF;

END copy_Line_to_request;

PROCEDURE set_pricing_control_record (
             l_Control_Rec  in out NOCOPY /* file.sql.39 change */ QP_PREQ_GRP.CONTROL_RECORD_TYPE
            ,in_pricing_event in varchar2)IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

l_set_of_books Oe_Order_Cache.Set_Of_Books_Rec_Type;
BEGIN
           l_control_rec.gsa_check_flag := 'Y';
           l_control_rec.gsa_dup_check_flag := 'Y';


            l_control_rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
            l_control_rec.simulation_flag :='Y';
            l_control_rec.pricing_event := in_pricing_Event;
           -- l_control_rec.temp_table_insert_flag := 'N';
            l_control_rec.check_cust_view_flag := 'Y';
            l_control_rec.request_type_code := 'ONT';
            l_control_rec.rounding_flag := 'Q';
            --For multi_currency price list
            l_control_rec.use_multi_currency:='Y';
            l_control_rec.USER_CONVERSION_RATE:= OE_ORDER_PUB.G_HDR.CONVERSION_RATE;
            l_control_rec.USER_CONVERSION_TYPE:= OE_ORDER_PUB.G_HDR.CONVERSION_TYPE_CODE;
            l_set_of_books := Oe_Order_Cache.Load_Set_Of_Books;
            l_control_rec.FUNCTION_CURRENCY   := l_set_of_books.currency_code;

END set_pricing_control_record;

PROCEDURE build_context_for_line(
        p_req_line_tbl_count in number,
        p_price_request_code in varchar2,
        p_item_type_code in varchar2,
        p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
        p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
       )IS

qp_attr_mapping_error exception;
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
p_pricing_contexts_Tbl	  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE OE_RELATED_ITEMS_PVT.BUILD_CONTEXTS FOR LINE' , 1 ) ;
  END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORG_ID='||L_ORG_ID|| ' PRICING_DATE='||
	G_PRICING_DATE|| ' INV ITEM_IE='||G_RELATED_ITEM_ID|| ' AGREEMENT_ID='||
	G_AGREEMENT_ID|| ' REQ DATE='||G_REQUEST_DATE|| ' SHIP_TO_ORG_ID='||
	G_SHIP_TO_ORG_ID|| ' INVOICE_TO_ORG_ID='||G_INVOICE_TO_ORG_ID ) ;
        END IF;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'QTY='||G_QTY|| ' ITEM_TYPE_CODE='||P_ITEM_TYPE_CODE|| ' PRICE_LIST_ID='||G_PRICE_LIST_ID|| ' CUST_ID='||G_CUSTOMER_ID|| ' PRICE REQ CODE='||P_PRICE_REQUEST_CODE|| ' UOM='||G_UOM ) ;
                 END IF;

  oe_order_pub.g_line.org_id             := l_org_id;
  oe_order_pub.g_line.pricing_date       := g_pricing_date;
  oe_order_pub.g_line.inventory_item_id  := g_related_item_id;
  oe_order_pub.g_line.agreement_id       := g_agreement_id;
  --oe_order_pub.g_line.ordered_date     := g_request_date;
  oe_order_pub.g_line.ship_to_org_id     := g_ship_to_org_id;
  oe_order_pub.g_line.invoice_to_org_id  := g_invoice_to_org_id;
  oe_order_pub.g_line.ordered_quantity   := g_qty;
  oe_order_pub.g_line.line_id            := g_line_id;
  oe_order_pub.g_line.header_id          := g_header_id;
  oe_order_pub.g_line.item_type_code     := p_item_type_code;
  oe_order_pub.g_line.price_list_id      := g_price_list_id;
  oe_order_pub.g_line.sold_to_org_id     := g_customer_id;
  oe_order_pub.g_line.price_request_code := p_price_request_code;
  oe_order_pub.g_line.order_quantity_uom := g_uom;


  IF g_item_identifier_type ='INT' then

     SELECT concatenated_segments
       INTO  oe_order_pub.g_line.ordered_item
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = g_related_item_id
       AND    organization_id = l_org_id;

  End IF;

  QP_Attr_Mapping_PUB.Build_Contexts(
     p_request_type_code => 'ONT',
     p_pricing_type =>'L',
     x_price_contexts_result_tbl => p_pricing_contexts_Tbl,
     x_qual_contexts_result_tbl  => p_qualifier_Contexts_Tbl
     );

  copy_attribs_to_Req(
     p_line_index         => 	p_req_line_tbl_count
     ,px_Req_line_attr_tbl    =>p_Req_line_attr_tbl
     ,px_Req_qual_tbl         =>p_Req_qual_tbl
     ,p_pricing_contexts_tbl => p_pricing_contexts_Tbl
     ,p_qualifier_contexts_tbl  => p_qualifier_Contexts_Tbl
     );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT OE_RELATED_ITEMS_PVT.BUILD_CONTEXTS FOR LINE' , 1 ) ;
  END IF;

EXCEPTION
    when no_data_found then
      Null;
    when others then
      Raise QP_ATTR_MAPPING_ERROR;

END build_context_for_line;

PROCEDURE copy_attribs_to_Req(
       p_line_index number
      ,px_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
      ,px_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
      ,p_pricing_contexts_Tbl in out nocopy QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
      ,p_qualifier_contexts_Tbl  in out nocopy QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
) IS

i pls_integer := 0;
l_attr_index	pls_integer := nvl(px_Req_line_attr_tbl.last,0);
l_qual_index	pls_integer := nvl(px_Req_qual_tbl.last,0);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_RELATED_ITEMS_PVT.COPY_ATTRIBS_TO_REQ' , 1 ) ;
  END IF;
  i := p_pricing_contexts_Tbl.First;
  While i is not null loop
    l_attr_index := l_attr_index +1;
    px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'N';
    px_Req_line_attr_tbl(l_attr_index).line_index := p_line_index;

    -- Product and Pricing Contexts go into pricing contexts...
    px_Req_line_attr_tbl(l_attr_index).PRICING_CONTEXT :=
    p_pricing_contexts_Tbl(i).context_name;
    px_Req_line_attr_tbl(l_attr_index).PRICING_ATTRIBUTE :=
    p_pricing_contexts_Tbl(i).Attribute_Name;
    px_Req_line_attr_tbl(l_attr_index).PRICING_ATTR_VALUE_FROM :=
    p_pricing_contexts_Tbl(i).attribute_value;

    i := p_pricing_contexts_Tbl.Next(i);
  end loop;

  -- Copy the qualifiers
  i := p_qualifier_contexts_Tbl.First;
  While i is not null loop
    l_qual_index := l_qual_index +1;

    If p_qualifier_contexts_Tbl(i).context_name ='MODLIST' and
      p_qualifier_contexts_Tbl(i).Attribute_Name ='QUALIFIER_ATTRIBUTE4' then

      If OE_Order_PUB.G_Line.agreement_id is not null and
        OE_Order_PUB.G_Line.agreement_id <> fnd_api.g_miss_num then
        px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'Y';
      Else
        px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'N';
      End If;

    Else
      px_Req_Qual_Tbl(l_qual_index).Validated_Flag := 'N';
    End If;

    px_Req_qual_tbl(l_qual_index).line_index := p_line_index;

    px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
    p_qualifier_contexts_Tbl(i).context_name;
    px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
    p_qualifier_contexts_Tbl(i).Attribute_Name;
    px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
    p_qualifier_contexts_Tbl(i).attribute_value;

    i := p_qualifier_contexts_Tbl.Next(i);
  end loop;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_RELATED_ITEMS_PVT.COPY_ATTRIBS_TO_REQ' , 1 ) ;
END IF;

END copy_attribs_to_Req;

PROCEDURE build_context_for_header(
        p_req_line_tbl_count in number,
        p_price_request_code in varchar2,
        p_item_type_code in varchar2,
        p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
        p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
       )IS

qp_attr_mapping_error exception;
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
p_pricing_contexts_Tbl	  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
/*4163551*/
l_header_rec OE_ORDER_PUB.header_rec_type;
/*4163551*/
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS FOR HEADER' , 1 ) ;
  END IF;


                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ORG_ID='||L_ORG_ID|| ' PRICING_DATE='||G_PRICING_DATE|| ' AGREEMENT_ID='||G_AGREEMENT_ID|| ' REQ DATE='||G_REQUEST_DATE|| ' SHIP_TO_ORG_ID='||G_SHIP_TO_ORG_ID|| ' INVOICE_TO_ORG_ID='||G_INVOICE_TO_ORG_ID ) ;
                  END IF;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'QTY='||G_QTY|| ' PRICE_LIST_ID='||G_PRICE_LIST_ID|| ' CUST_ID='||G_CUSTOMER_ID|| ' PRICE REQ CODE='||P_PRICE_REQUEST_CODE ) ;
                 END IF;
/*4163551*/
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' 1 Related Items-Header_ID='||g_header_id);
  END IF;
  IF g_header_id is NOT NULL THEN
     OE_Header_Util.Query_Row
        (   p_header_id                   => g_header_id,
            x_header_rec                  =>l_header_rec
        );
  IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  ' Queried -Related Items-Header_ID='||g_header_id);
  END IF;
  END IF;

  IF l_header_rec.header_id IS NOT NULL AND
     l_header_rec.header_id<>FND_API.G_MISS_NUM THEN
       oe_order_pub.g_hdr:=l_header_rec;
       IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Header_ID='||oe_order_pub.g_hdr.header_id);
       oe_debug_pub.add(  'sdatti Related Items-Price List='||oe_order_pub.g_hdr.price_list_id);
       END IF;
/*4163551*/
  ELSE
  oe_order_pub.g_hdr.agreement_id       := g_agreement_id;
  oe_order_pub.g_hdr.invoice_to_org_id  := g_invoice_to_org_id;
  oe_order_pub.g_hdr.ordered_date       := g_request_date;
  oe_order_pub.g_hdr.header_id          := g_header_id;
  oe_order_pub.g_hdr.org_id             := l_org_id;
  oe_order_pub.g_hdr.price_list_id      := g_price_list_id;
  oe_order_pub.g_hdr.price_request_code := p_price_request_code;
  oe_order_pub.g_hdr.pricing_date       := g_pricing_date;
  oe_order_pub.g_hdr.request_date       := g_request_date;
  oe_order_pub.g_hdr.ship_to_org_id     := g_ship_to_org_id;
  oe_order_pub.g_hdr.sold_to_org_id     := g_customer_id;
  oe_order_pub.g_hdr.order_type_id      := g_order_type_id;
  oe_order_pub.g_hdr.ship_from_org_id   := g_ship_from_org_id;
  END IF;
  --oe_order_pub.g_line.inventory_item_id  := p_inventory_item_id;
  --oe_order_pub.g_line.ordered_quantity   := p_ordered_quantity;
  --oe_order_pub.g_line.line_id            := g_line_id;
  --oe_order_pub.g_line.item_type_code     := p_item_type_code;
  --oe_order_pub.g_line.order_quantity_uom := p_uom;


  /*If p_item_identifier_type ='INT' then

     SELECT concatenated_segments
       INTO  oe_order_pub.g_line.ordered_item
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = g_inventory_item_id
       AND    organization_id = l_org_id;

  End If;*/

  QP_Attr_Mapping_PUB.Build_Contexts(
     p_request_type_code => 'ONT',
     p_pricing_type	=>'H',
     x_price_contexts_result_tbl => p_pricing_contexts_Tbl,
     x_qual_contexts_result_tbl  => p_qualifier_Contexts_Tbl
     );


  copy_attribs_to_Req(
     p_line_index         => 	p_req_line_tbl_count
     ,px_Req_line_attr_tbl    =>p_Req_line_attr_tbl
     ,px_Req_qual_tbl         =>p_Req_qual_tbl
     ,p_pricing_contexts_tbl => p_pricing_contexts_Tbl
     ,p_qualifier_contexts_tbl  => p_qualifier_Contexts_Tbl
     );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS FOR HEADER' , 1 ) ;
  END IF;

EXCEPTION
    when no_data_found then
      Null;
    when others then
      Raise QP_ATTR_MAPPING_ERROR;

END build_context_for_header;

procedure  Append_attributes(
           p_header_id number default null
          ,p_Line_id number default null
          ,p_line_index number
          ,px_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
          ,px_Req_qual_tbl in out nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
           ) is

i	pls_integer;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_RELATED_ITEMS_PVT.APPEND_ATTRIBUTES' , 1 ) ;
  END IF;

  IF g_PRICING_ATTRIBUTE1 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE1';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE1;
  END IF;

  IF g_PRICING_ATTRIBUTE2 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE2';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE2;
  END IF;

  IF g_PRICING_ATTRIBUTE3 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE3';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE3;
  END IF;

  IF g_PRICING_ATTRIBUTE4 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE4';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE4;
  END IF;

  if g_PRICING_ATTRIBUTE5 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE5';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE5;
  end if;

  if g_PRICING_ATTRIBUTE6 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE6';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE6;
  end if;

  if g_PRICING_ATTRIBUTE7 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE7';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE7;
  end if;

  if g_PRICING_ATTRIBUTE8 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE8';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE8;
  end if;

  if g_PRICING_ATTRIBUTE9 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE9';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE9;
  end if;

  if g_PRICING_ATTRIBUTE10 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE10';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE10;
  end if;

  if g_PRICING_ATTRIBUTE11 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE11';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE11;
  end if;

  if g_PRICING_ATTRIBUTE12 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE12';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE12;
  end if;

  if g_PRICING_ATTRIBUTE13 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE13';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE13;
  end if;

  if g_PRICING_ATTRIBUTE14 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE14';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE14;
  end if;

  if g_PRICING_ATTRIBUTE15 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE15';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE15;
  end if;

  if g_PRICING_ATTRIBUTE16 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE16';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE16;
  end if;

  if g_PRICING_ATTRIBUTE17 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE17';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE17;
  end if;

  if g_PRICING_ATTRIBUTE18 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE18';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE18;
  end if;

  if g_PRICING_ATTRIBUTE19 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE19';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE19;
  end if;

  if g_PRICING_ATTRIBUTE20 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE20;
  end if;

  if g_PRICING_ATTRIBUTE21 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE21';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE21;
  end if;

  if g_PRICING_ATTRIBUTE22 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE22';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE22;
  end if;

  if g_PRICING_ATTRIBUTE23 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE23';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE23;
  end if;

  if g_PRICING_ATTRIBUTE24 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE24';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE24;
  end if;

  if g_PRICING_ATTRIBUTE25 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE25';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE25;
  end if;

  if g_PRICING_ATTRIBUTE26 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE26';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE26;
  end if;

  if g_PRICING_ATTRIBUTE27 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE27';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE27;
  end if;

  if g_PRICING_ATTRIBUTE28 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE28';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE28;
  end if;

  if g_PRICING_ATTRIBUTE29 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE29';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE29;
  end if;

  if g_PRICING_ATTRIBUTE30 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE30';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE30;
  end if;

  if g_PRICING_ATTRIBUTE31 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE31';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE31;
  end if;

  if g_PRICING_ATTRIBUTE32 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE32';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE32;
  end if;

  if g_PRICING_ATTRIBUTE33 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE33';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE33;
  end if;

  if g_PRICING_ATTRIBUTE34 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE34';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE34;
  end if;

  if g_PRICING_ATTRIBUTE35 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE35';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE35;
  end if;

  if g_PRICING_ATTRIBUTE36 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE36';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE36;
  end if;

  if g_PRICING_ATTRIBUTE37 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE37';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE37;
  end if;

  if g_PRICING_ATTRIBUTE38 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE38';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE38;
  end if;

  if g_PRICING_ATTRIBUTE39 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE39';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE39;
  end if;

  if g_PRICING_ATTRIBUTE40 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE40';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE40;
  end if;

  if g_PRICING_ATTRIBUTE41 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE41';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE41;
  end if;

  if g_PRICING_ATTRIBUTE42 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE42';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE42;
  end if;

  if g_PRICING_ATTRIBUTE43 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE43';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE43;
  end if;

  if g_PRICING_ATTRIBUTE44 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE44';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE44;
  end if;

  if g_PRICING_ATTRIBUTE45 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE45';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE45;
  end if;

  if g_PRICING_ATTRIBUTE46 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE46';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE46;
  end if;

  if g_PRICING_ATTRIBUTE47 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE47';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE47;
  end if;

  if g_PRICING_ATTRIBUTE48 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE48';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE48;
  end if;

  if g_PRICING_ATTRIBUTE49 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE49';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE49;
  end if;


  if g_PRICING_ATTRIBUTE50 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE20;
  end if;

  if g_PRICING_ATTRIBUTE51 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE51';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE51;
  end if;

  if g_PRICING_ATTRIBUTE52 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE52';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE52;
  end if;

  if g_PRICING_ATTRIBUTE53 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE53';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE53;
  end if;

  if g_PRICING_ATTRIBUTE54 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE54';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE54;
  end if;

  if g_PRICING_ATTRIBUTE55 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE55';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE55;
  end if;

  if g_PRICING_ATTRIBUTE56 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE56';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE56;
  end if;

  if g_PRICING_ATTRIBUTE57 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE57';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE57;
  end if;

  if g_PRICING_ATTRIBUTE58 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE58';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE58;
  end if;

  if g_PRICING_ATTRIBUTE59 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE59';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE59;
  end if;


  if g_PRICING_ATTRIBUTE60 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE60';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE60;
  end if;

  if g_PRICING_ATTRIBUTE61 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE61';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE61;
  end if;

  if g_PRICING_ATTRIBUTE62 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE62';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE62;
  end if;

  if g_PRICING_ATTRIBUTE63 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE63';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE63;
  end if;

  if g_PRICING_ATTRIBUTE64 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE64';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE64;
  end if;

  if g_PRICING_ATTRIBUTE65 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE65';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE65;
  end if;

  if g_PRICING_ATTRIBUTE66 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE66';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE66;
  end if;

  if g_PRICING_ATTRIBUTE67 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE67';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE67;
  end if;

  if g_PRICING_ATTRIBUTE68 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE68';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE68;
  end if;

  if g_PRICING_ATTRIBUTE69 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE69';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE69;
  end if;


  if g_PRICING_ATTRIBUTE70 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE70';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE70;
  end if;

  if g_PRICING_ATTRIBUTE71 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE71';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE71;
  end if;

  if g_PRICING_ATTRIBUTE72 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE72';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE72;
  end if;

  if g_PRICING_ATTRIBUTE73 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE73';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE73;
  end if;

  if g_PRICING_ATTRIBUTE74 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE74';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE74;
  end if;

  if g_PRICING_ATTRIBUTE75 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE75';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE75;
  end if;

  if g_PRICING_ATTRIBUTE76 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE76';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE76;
  end if;

  if g_PRICING_ATTRIBUTE77 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE77';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE77;
  end if;

  if g_PRICING_ATTRIBUTE78 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE78';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE27;
  end if;

  if g_PRICING_ATTRIBUTE79 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE79';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE27;
  end if;


  if g_PRICING_ATTRIBUTE80 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE80';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE80;
  end if;

  if g_PRICING_ATTRIBUTE81 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE81';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE81;
  end if;

  if g_PRICING_ATTRIBUTE82 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE82';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE82;
  end if;

  if g_PRICING_ATTRIBUTE83 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE83';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE83;
  end if;

  if g_PRICING_ATTRIBUTE84 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE84';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE84;
  end if;

  if g_PRICING_ATTRIBUTE85 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE85';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE85;
  end if;

  if g_PRICING_ATTRIBUTE86 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE86';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE86;
  end if;

  if g_PRICING_ATTRIBUTE87 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE87';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE87;
  end if;

  if g_PRICING_ATTRIBUTE88 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE88';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE88;
  end if;

  if g_PRICING_ATTRIBUTE89 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE89';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE89;
  end if;


  if g_PRICING_ATTRIBUTE90 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE90';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE90;
  end if;

  if g_PRICING_ATTRIBUTE91 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE91';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE91;
  end if;

  if g_PRICING_ATTRIBUTE92 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE92';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE92;
  end if;

  if g_PRICING_ATTRIBUTE93 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE93';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_PRICING_ATTRIBUTE93;
  end if;

  if g_PRICING_ATTRIBUTE94 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE94';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE94;
  end if;

  if g_PRICING_ATTRIBUTE95 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE95';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE95;
  end if;

  if g_PRICING_ATTRIBUTE96 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE96';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE96;
  end if;

  if g_PRICING_ATTRIBUTE97 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE97';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE97;
  end if;

  if g_PRICING_ATTRIBUTE98 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE98';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE98;
  end if;

  if g_PRICING_ATTRIBUTE99 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE99';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_PRICING_ATTRIBUTE99;
  end if;

  if g_PRICING_ATTRIBUTE100 is not null then
    i := px_Req_line_attr_tbl.count+1;
    px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
    px_Req_line_attr_tbl(i).Validated_Flag := 'N';
    px_Req_line_attr_tbl(i).pricing_context := g_pricing_context;
    px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE100';
    px_Req_line_attr_tbl(i).Pricing_Attr_Value_From:=g_PRICING_ATTRIBUTE100;
  end if;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_RELATED_ITEMS_PVT.APPEND_ATTRIBUTES' , 1 ) ;
END IF;

END Append_attributes;

PROCEDURE price_item(
out_req_line_tbl              in out NOCOPY /* file.sql.39 change */ QP_PREQ_GRP.LINE_TBL_TYPE,
out_Req_line_attr_tbl         in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_attr_tbl  in out nocopy  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_tbl        in out nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
out_Req_related_lines_tbl      in out nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
out_Req_qual_tbl               in out nocopy QP_PREQ_GRP.QUAL_TBL_TYPE,
out_Req_LINE_DETAIL_qual_tbl   in out nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
out_child_detail_type          out NOCOPY /* file.sql.39 change */ varchar2,
                in_related_item_id        in number,
                in_qty                    in number,
                in_uom                    in varchar2,
                in_request_date           in date,
                in_customer_id            in number,
                in_item_identifier_type   in varchar2,
                in_agreement_id           in number,
                in_price_list_id          in number,
                in_ship_to_org_id         in number,
                in_invoice_to_org_id      in number,
                in_ship_from_org_id       in number,
                in_pricing_date           in date,
                in_order_type_id          in number,
                in_currency               in varchar2,
                in_pricing_context        in varchar2,
                in_pricing_attribute1     in varchar2,
                in_pricing_attribute2     in varchar2,
                in_pricing_attribute3     in varchar2,
                in_pricing_attribute4     in varchar2,
                in_pricing_attribute5     in varchar2,
                in_pricing_attribute6     in varchar2,
                in_pricing_attribute7     in varchar2,
                in_pricing_attribute8     in varchar2,
                in_pricing_attribute9     in varchar2,
                in_pricing_attribute10    in varchar2,
                in_pricing_attribute11    in varchar2,
                in_pricing_attribute12    in varchar2,
                in_pricing_attribute13    in varchar2,
                in_pricing_attribute14    in varchar2,
                in_pricing_attribute15    in varchar2,
                in_pricing_attribute16    in varchar2,
                in_pricing_attribute17    in varchar2,
                in_pricing_attribute18    in varchar2,
                in_pricing_attribute19    in varchar2,
                in_pricing_attribute20    in varchar2,
                in_pricing_attribute21    in varchar2,
                in_pricing_attribute22    in varchar2,
                in_pricing_attribute23    in varchar2,
                in_pricing_attribute24    in varchar2,
                in_pricing_attribute25    in varchar2,
                in_pricing_attribute26    in varchar2,
                in_pricing_attribute27    in varchar2,
                in_pricing_attribute28    in varchar2,
                in_pricing_attribute29    in varchar2,
                in_pricing_attribute30    in varchar2,
                in_pricing_attribute31    in varchar2,
                in_pricing_attribute32    in varchar2,
                in_pricing_attribute33    in varchar2,
                in_pricing_attribute34    in varchar2,
                in_pricing_attribute35    in varchar2,
                in_pricing_attribute36    in varchar2,
                in_pricing_attribute37    in varchar2,
                in_pricing_attribute38    in varchar2,
                in_pricing_attribute39    in varchar2,
                in_pricing_attribute40    in varchar2,
                in_pricing_attribute41    in varchar2,
                in_pricing_attribute42    in varchar2,
                in_pricing_attribute43    in varchar2,
                in_pricing_attribute44    in varchar2,
                in_pricing_attribute45    in varchar2,
                in_pricing_attribute46    in varchar2,
                in_pricing_attribute47    in varchar2,
                in_pricing_attribute48    in varchar2,
                in_pricing_attribute49    in varchar2,
                in_pricing_attribute50    in varchar2,
                in_pricing_attribute51    in varchar2,
                in_pricing_attribute52    in varchar2,
                in_pricing_attribute53    in varchar2,
                in_pricing_attribute54    in varchar2,
                in_pricing_attribute55    in varchar2,
                in_pricing_attribute56    in varchar2,
                in_pricing_attribute57    in varchar2,
                in_pricing_attribute58    in varchar2,
                in_pricing_attribute59    in varchar2,
                in_pricing_attribute60    in varchar2,
                in_pricing_attribute61    in varchar2,
                in_pricing_attribute62    in varchar2,
                in_pricing_attribute63    in varchar2,
                in_pricing_attribute64    in varchar2,
                in_pricing_attribute65    in varchar2,
                in_pricing_attribute66    in varchar2,
                in_pricing_attribute67    in varchar2,
                in_pricing_attribute68    in varchar2,
                in_pricing_attribute69    in varchar2,
                in_pricing_attribute70    in varchar2,
                in_pricing_attribute71    in varchar2,
                in_pricing_attribute72    in varchar2,
                in_pricing_attribute73    in varchar2,
                in_pricing_attribute74    in varchar2,
                in_pricing_attribute75    in varchar2,
                in_pricing_attribute76    in varchar2,
                in_pricing_attribute77    in varchar2,
                in_pricing_attribute78    in varchar2,
                in_pricing_attribute79    in varchar2,
                in_pricing_attribute80    in varchar2,
                in_pricing_attribute81    in varchar2,
                in_pricing_attribute82    in varchar2,
                in_pricing_attribute83    in varchar2,
                in_pricing_attribute84    in varchar2,
                in_pricing_attribute85    in varchar2,
                in_pricing_attribute86    in varchar2,
                in_pricing_attribute87    in varchar2,
                in_pricing_attribute88    in varchar2,
                in_pricing_attribute89    in varchar2,
                in_pricing_attribute90    in varchar2,
                in_pricing_attribute91    in varchar2,
                in_pricing_attribute92    in varchar2,
                in_pricing_attribute93    in varchar2,
                in_pricing_attribute94    in varchar2,
                in_pricing_attribute95    in varchar2,
                in_pricing_attribute96    in varchar2,
                in_pricing_attribute97    in varchar2,
                in_pricing_attribute98    in varchar2,
                in_pricing_attribute99    in varchar2,
                in_pricing_attribute100   in varchar2,
                in_header_id              in NUMBER
                     ) IS

l_return_status               varchar2(10);
l_return_status_Text	      varchar2(240) ;
l_Control_Rec                 QP_PREQ_GRP.CONTROL_RECORD_TYPE;
l_req_line_tbl                QP_PREQ_GRP.LINE_TBL_TYPE;
l_Req_qual_tbl                QP_PREQ_GRP.QUAL_TBL_TYPE;
l_Req_line_attr_tbl           QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
l_Req_LINE_DETAIL_tbl         QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_Req_LINE_DETAIL_qual_tbl    QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
l_Req_LINE_DETAIL_attr_tbl    QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
l_Req_related_lines_tbl       QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/*4163551*/
    oe_order_pub.g_hdr:=null;
    oe_order_pub.g_line:=null;
/*4163551*/

    --copy_fields_to_globals;
    g_related_item_id       := in_related_item_id;
    g_qty                   := in_qty;
    g_uom                   := in_uom;
    g_request_date          := in_request_date;
    g_customer_id           := in_customer_id;
    g_item_identifier_type  := in_item_identifier_type;
    g_agreement_id          := in_agreement_id;
    g_price_list_id         := in_price_list_id;
    g_ship_to_org_id        := in_ship_to_org_id;
    g_invoice_to_org_id     := in_invoice_to_org_id;
    g_ship_from_org_id      := in_ship_from_org_id;
    g_pricing_date          := in_pricing_date;
    g_order_type_id         := in_order_type_id;
    g_currency              := in_currency;
    g_pricing_context       := in_pricing_context;
    g_pricing_attribute1    := in_pricing_attribute1;
    g_pricing_attribute2    := in_pricing_attribute2;
    g_pricing_attribute3    := in_pricing_attribute3;
    g_pricing_attribute4    := in_pricing_attribute4;
    g_pricing_attribute5    := in_pricing_attribute5;
    g_pricing_attribute6    := in_pricing_attribute6;
    g_pricing_attribute7    := in_pricing_attribute7;
    g_pricing_attribute8    := in_pricing_attribute8;
    g_pricing_attribute9    := in_pricing_attribute9;
    g_pricing_attribute10   := in_pricing_attribute10;
    g_pricing_attribute11   := in_pricing_attribute11;
    g_pricing_attribute12   := in_pricing_attribute12;
    g_pricing_attribute13   := in_pricing_attribute13;
    g_pricing_attribute14   := in_pricing_attribute14;
    g_pricing_attribute15   := in_pricing_attribute15;
    g_pricing_attribute16   := in_pricing_attribute16;
    g_pricing_attribute17   := in_pricing_attribute17;
    g_pricing_attribute18   := in_pricing_attribute18;
    g_pricing_attribute19   := in_pricing_attribute19;
    g_pricing_attribute20   := in_pricing_attribute20;
    g_pricing_attribute21   := in_pricing_attribute21;
    g_pricing_attribute22   := in_pricing_attribute22;
    g_pricing_attribute23   := in_pricing_attribute23;
    g_pricing_attribute24   := in_pricing_attribute24;
    g_pricing_attribute25   := in_pricing_attribute25;
    g_pricing_attribute26   := in_pricing_attribute26;
    g_pricing_attribute27   := in_pricing_attribute27;
    g_pricing_attribute28   := in_pricing_attribute28;
    g_pricing_attribute29   := in_pricing_attribute29;
    g_pricing_attribute30   := in_pricing_attribute30;
    g_pricing_attribute31   := in_pricing_attribute31;
    g_pricing_attribute32   := in_pricing_attribute32;
    g_pricing_attribute33   := in_pricing_attribute33;
    g_pricing_attribute34   := in_pricing_attribute34;
    g_pricing_attribute35   := in_pricing_attribute35;
    g_pricing_attribute36   := in_pricing_attribute36;
    g_pricing_attribute37   := in_pricing_attribute37;
    g_pricing_attribute38   := in_pricing_attribute38;
    g_pricing_attribute39   := in_pricing_attribute39;
    g_pricing_attribute40   := in_pricing_attribute40;
    g_pricing_attribute41   := in_pricing_attribute41;
    g_pricing_attribute42   := in_pricing_attribute42;
    g_pricing_attribute43   := in_pricing_attribute43;
    g_pricing_attribute44   := in_pricing_attribute44;
    g_pricing_attribute45   := in_pricing_attribute45;
    g_pricing_attribute46   := in_pricing_attribute46;
    g_pricing_attribute47   := in_pricing_attribute47;
    g_pricing_attribute48   := in_pricing_attribute48;
    g_pricing_attribute49   := in_pricing_attribute49;
    g_pricing_attribute50   := in_pricing_attribute50;
    g_pricing_attribute51   := in_pricing_attribute51;
    g_pricing_attribute52   := in_pricing_attribute52;
    g_pricing_attribute53   := in_pricing_attribute53;
    g_pricing_attribute54   := in_pricing_attribute54;
    g_pricing_attribute55   := in_pricing_attribute55;
    g_pricing_attribute56   := in_pricing_attribute56;
    g_pricing_attribute57   := in_pricing_attribute57;
    g_pricing_attribute58   := in_pricing_attribute58;
    g_pricing_attribute59   := in_pricing_attribute59;
    g_pricing_attribute60   := in_pricing_attribute60;
    g_pricing_attribute61   := in_pricing_attribute61;
    g_pricing_attribute62   := in_pricing_attribute62;
    g_pricing_attribute63   := in_pricing_attribute63;
    g_pricing_attribute64   := in_pricing_attribute64;
    g_pricing_attribute65   := in_pricing_attribute65;
    g_pricing_attribute66   := in_pricing_attribute66;
    g_pricing_attribute67   := in_pricing_attribute67;
    g_pricing_attribute68   := in_pricing_attribute68;
    g_pricing_attribute69   := in_pricing_attribute69;
    g_pricing_attribute70   := in_pricing_attribute70;
    g_pricing_attribute71   := in_pricing_attribute71;
    g_pricing_attribute72   := in_pricing_attribute72;
    g_pricing_attribute73   := in_pricing_attribute73;
    g_pricing_attribute74   := in_pricing_attribute74;
    g_pricing_attribute75   := in_pricing_attribute75;
    g_pricing_attribute76   := in_pricing_attribute76;
    g_pricing_attribute77   := in_pricing_attribute77;
    g_pricing_attribute78   := in_pricing_attribute78;
    g_pricing_attribute79   := in_pricing_attribute79;
    g_pricing_attribute80   := in_pricing_attribute80;
    g_pricing_attribute81   := in_pricing_attribute81;
    g_pricing_attribute82   := in_pricing_attribute82;
    g_pricing_attribute83   := in_pricing_attribute83;
    g_pricing_attribute84   := in_pricing_attribute84;
    g_pricing_attribute85   := in_pricing_attribute85;
    g_pricing_attribute86   := in_pricing_attribute86;
    g_pricing_attribute87   := in_pricing_attribute87;
    g_pricing_attribute88   := in_pricing_attribute88;
    g_pricing_attribute89   := in_pricing_attribute89;
    g_pricing_attribute90   := in_pricing_attribute90;
    g_pricing_attribute91   := in_pricing_attribute91;
    g_pricing_attribute92   := in_pricing_attribute92;
    g_pricing_attribute93   := in_pricing_attribute93;
    g_pricing_attribute94   := in_pricing_attribute94;
    g_pricing_attribute95   := in_pricing_attribute95;
    g_pricing_attribute96   := in_pricing_attribute96;
    g_pricing_attribute97   := in_pricing_attribute97;
    g_pricing_attribute98   := in_pricing_attribute98;
    g_pricing_attribute99   := in_pricing_attribute99;
    g_pricing_attribute100  := in_pricing_attribute100;
/*4163551*/
    g_header_id             := in_header_id;
/*4163551*/

    out_child_detail_type := qp_preq_grp.G_CHILD_DETAIL_TYPE;

/*4163551*/
    set_pricing_control_record (
             l_Control_Rec  => l_control_rec
            ,in_pricing_event => 'LINE'
                               );
    copy_Header_to_request(
              p_request_type_code => 'ONT'
             ,p_calculate_price_flag  => 'Y'
             ,px_req_line_tbl => l_req_line_tbl
                           );

    build_context_for_header(
        p_req_line_tbl_count =>l_req_line_tbl.count,
        p_price_request_code => null,
        p_item_type_code => null,
        p_Req_line_attr_tbl =>l_req_line_attr_tbl,
        p_Req_qual_tbl =>l_req_qual_tbl
                             );

    Append_attributes(
           p_header_id => g_header_id
          ,p_Line_id   => g_line_id
          ,p_line_index =>l_req_line_tbl.count
          ,px_Req_line_attr_tbl => l_req_line_attr_tbl
          ,px_Req_qual_tbl => l_req_qual_tbl
           );

    copy_Line_to_request(
              px_req_line_tbl => l_req_line_tbl
             ,p_pricing_event => 'LINE'
             ,p_Request_Type_Code => 'ONT'
             ,p_honor_price_flag => 'Y'
                        );

    build_context_for_line(
        p_req_line_tbl_count =>l_req_line_tbl.count,
        p_price_request_code => null,
        p_item_type_code => null,
        p_Req_line_attr_tbl =>l_req_line_attr_tbl,
        p_Req_qual_tbl =>l_req_qual_tbl
                           );

    Append_attributes(
           p_header_id => g_header_id
          ,p_Line_id   => g_line_id
          ,p_line_index =>l_req_line_tbl.count
          ,px_Req_line_attr_tbl => l_req_line_attr_tbl
          ,px_Req_qual_tbl => l_req_qual_tbl
           );

    out_req_line_tbl(1).status_Code := null;
    out_req_line_tbl(1).status_text := null;

    IF l_debug_level  > 0 THEN
    print_time('Calling PE');
    END IF;
    QP_PREQ_GRP.PRICE_REQUEST
    (p_control_rec           =>l_control_rec
    ,p_line_tbl              =>l_Req_line_tbl
    ,p_qual_tbl              =>l_Req_qual_tbl
    ,p_line_attr_tbl         =>l_Req_line_attr_tbl
    ,p_line_detail_tbl       =>l_req_line_detail_tbl
    ,p_line_detail_qual_tbl  =>l_req_line_detail_qual_tbl
    ,p_line_detail_attr_tbl  =>l_req_line_detail_attr_tbl
    ,p_related_lines_tbl     =>l_req_related_lines_tbl
    ,x_line_tbl              =>out_req_line_tbl
    ,x_line_qual             =>out_Req_qual_tbl
    ,x_line_attr_tbl         =>out_Req_line_attr_tbl
    ,x_line_detail_tbl       =>out_req_line_detail_tbl
    ,x_line_detail_qual_tbl  =>out_req_line_detail_qual_tbl
    ,x_line_detail_attr_tbl  =>out_req_line_detail_attr_tbl
    ,x_related_lines_tbl     =>out_req_related_lines_tbl
    ,x_return_status         =>l_return_status
    ,x_return_status_Text    =>l_return_status_Text
    );

    IF l_debug_level  > 0 THEN
    print_time('After Calling PE');
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '******AFTER CALLING PRICING ENGINE' ) ;
        oe_debug_pub.add(  'MAIN STATUS ='||L_RETURN_STATUS ) ;
        oe_debug_pub.add(  'MAIN TEXT ='||L_RETURN_STATUS_TEXT ) ;
        oe_debug_pub.add(  'COUNT LINE TABLE='||OUT_REQ_LINE_TBL.COUNT ) ;
    END IF;
    if out_req_line_tbl.count > 0 then
    for i in out_req_line_tbl.first..out_req_line_tbl.last
    loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '*******************************' ) ;
                             oe_debug_pub.add(  'REQUEST_TYPE_CODE ='|| OUT_REQ_LINE_TBL ( I ) .REQUEST_TYPE_CODE ) ;
            oe_debug_pub.add(  'PRICING_EVENT ='||OUT_REQ_LINE_TBL ( I ) .PRICING_EVENT ) ;
            oe_debug_pub.add(  'HEADER_ID ='||OUT_REQ_LINE_TBL ( I ) .HEADER_ID ) ;
            oe_debug_pub.add(  'LINE_TYPE_CODE='||OUT_REQ_LINE_TBL ( I ) .LINE_TYPE_CODE ) ;
            oe_debug_pub.add(  'LINE_QUANTITY ='||OUT_REQ_LINE_TBL ( I ) .LINE_QUANTITY ) ;
            oe_debug_pub.add(  'LINE_UOM_CODE ='||OUT_REQ_LINE_TBL ( I ) .LINE_UOM_CODE ) ;
            oe_debug_pub.add(  'UOM_QUANTITY ='||OUT_REQ_LINE_TBL ( I ) .UOM_QUANTITY ) ;
            oe_debug_pub.add(  'PRI_QUANTITY='||OUT_REQ_LINE_TBL ( I ) .PRICED_QUANTITY ) ;
            oe_debug_pub.add(  'PR_UOM_CODE ='||OUT_REQ_LINE_TBL ( I ) .PRICED_UOM_CODE ) ;
            oe_debug_pub.add(  'CURRENCY_CODE ='||OUT_REQ_LINE_TBL ( I ) .CURRENCY_CODE ) ;
            oe_debug_pub.add(  'UNIT_PRICE ='||OUT_REQ_LINE_TBL ( I ) .UNIT_PRICE ) ;
            oe_debug_pub.add(  'PERCENT_PRICE ='||OUT_REQ_LINE_TBL ( I ) .PERCENT_PRICE ) ;
                             oe_debug_pub.add(  'ADJ_UNIT_PRICE='|| OUT_REQ_LINE_TBL ( I ) .ADJUSTED_UNIT_PRICE ) ;
                             oe_debug_pub.add(  'UPDATED_ADJUSTED_UNIT_PRICE ='|| OUT_REQ_LINE_TBL ( I ) .UPDATED_ADJUSTED_UNIT_PRICE ) ;
            oe_debug_pub.add(  'ROUNDING_FAC='||OUT_REQ_LINE_TBL ( I ) .ROUNDING_FACTOR ) ;
            oe_debug_pub.add(  'PRICE_FLAG ='||OUT_REQ_LINE_TBL ( I ) .PRICE_FLAG ) ;
                              oe_debug_pub.add(  'PRICE_REQUEST_CODE ='|| OUT_REQ_LINE_TBL ( I ) .PRICE_REQUEST_CODE ) ;
            oe_debug_pub.add(  'HOLD_CODE ='||OUT_REQ_LINE_TBL ( I ) .HOLD_CODE ) ;
            oe_debug_pub.add(  'HOLD_TEXT ='||OUT_REQ_LINE_TBL ( I ) .HOLD_TEXT ) ;
            oe_debug_pub.add(  'STATUS_CODE ='||OUT_REQ_LINE_TBL ( I ) .STATUS_CODE ) ;
            oe_debug_pub.add(  'STATUS_TEXT ='||OUT_REQ_LINE_TBL ( I ) .STATUS_TEXT ) ;
                              oe_debug_pub.add(  'USAGE_PRICING_TYPE ='|| OUT_REQ_LINE_TBL ( I ) .USAGE_PRICING_TYPE ) ;
            oe_debug_pub.add(  'LINE_CATEGORY ='||OUT_REQ_LINE_TBL ( I ) .LINE_CATEGORY ) ;
                              oe_debug_pub.add(  'PRICING EFFECTIVE DATE='|| OUT_REQ_LINE_TBL ( I ) .PRICING_EFFECTIVE_DATE ) ;
                              oe_debug_pub.add(  'ACTIVE_DATE_FIRST ='|| OUT_REQ_LINE_TBL ( I ) .ACTIVE_DATE_FIRST ) ;
                              oe_debug_pub.add(  'ACTIVE_DATE_FIRST_TYPE ='|| OUT_REQ_LINE_TBL ( I ) .ACTIVE_DATE_FIRST_TYPE ) ;
                              oe_debug_pub.add(  'ACTIVE_DATE_SECOND ='|| OUT_REQ_LINE_TBL ( I ) .ACTIVE_DATE_SECOND ) ;
                              oe_debug_pub.add(  'ACTIVE_DATE_SECOND_TYPE ='|| OUT_REQ_LINE_TBL ( I ) .ACTIVE_DATE_SECOND_TYPE ) ;
                          END IF;
    end loop;
    end if;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT LINE DETAIL TABLE='||OUT_REQ_LINE_DETAIL_TBL.COUNT ) ;
    END IF;
    if out_req_line_detail_tbl.count > 0 then
    for i in out_req_line_detail_tbl.first..out_req_line_detail_tbl.last
    loop
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE DETAIL TABLE RECORD='||I ) ;
          END IF;
        if out_req_line_detail_tbl.exists(i) then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  '*******************************' ) ;
              oe_debug_pub.add(  'LIN_INDEX='||OUT_REQ_LINE_DETAIL_TBL ( I ) .LINE_INDEX ) ;
                                oe_debug_pub.add(  'LIST_LINE_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .LIST_LINE_TYPE_CODE ) ;
                                oe_debug_pub.add(  'LINE_DETAIL_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .LINE_DETAIL_TYPE_CODE ) ;
                           oe_debug_pub.add(  'CREATED_FROM_LIST_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .CREATED_FROM_LIST_TYPE_CODE ) ;
                                oe_debug_pub.add(  'AUTOMATIC_FLAG='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .AUTOMATIC_FLAG ) ;
              oe_debug_pub.add(  'ACCRUAL='||OUT_REQ_LINE_DETAIL_TBL ( I ) .ACCRUAL_FLAG ) ;
              oe_debug_pub.add(  'STATUS='||OUT_REQ_LINE_DETAIL_TBL ( I ) .STATUS_CODE ) ;
              oe_debug_pub.add(  'STS_TEXT='||OUT_REQ_LINE_DETAIL_TBL ( I ) .STATUS_TEXT ) ;
                                oe_debug_pub.add(  'LIST_HEADER_ID='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .LIST_HEADER_ID ) ;
                                oe_debug_pub.add(  'LIST_LINE_ID='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .LIST_LINE_ID ) ;
                                oe_debug_pub.add(  'PRICE_BREAK_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .PRICE_BREAK_TYPE_CODE ) ;
              oe_debug_pub.add(  'LST_PRICE='||OUT_REQ_LINE_DETAIL_TBL ( I ) .LIST_PRICE ) ;
                                oe_debug_pub.add(  'ADJUSTMENT_AMOUNT='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .ADJUSTMENT_AMOUNT ) ;
                                oe_debug_pub.add(  'LINE_QUANTITY='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .LINE_QUANTITY ) ;
                                oe_debug_pub.add(  'MODIFIER_LEVEL_CODE='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .MODIFIER_LEVEL_CODE ) ;
                                oe_debug_pub.add(  'INVENTORY_ITEM_ID='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .INVENTORY_ITEM_ID ) ;
                            END IF;
        end if;

    end loop;
    end if;


                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'COUNT LINE DETAIL ATTR TBL='|| OUT_REQ_LINE_DETAIL_ATTR_TBL.COUNT ) ;
                      END IF;
    if out_req_line_detail_attr_tbl.count > 0 then
    for i in out_req_line_detail_attr_tbl.first..out_req_line_detail_attr_tbl.last
    loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '*******************************' ) ;
            oe_debug_pub.add(  'LINE DETAIL ATTR_TABLE RECORD='||I ) ;
                               oe_debug_pub.add(  'LINE_DETAIL_INDEX='|| OUT_REQ_LINE_DETAIL_ATTR_TBL ( I ) .LINE_DETAIL_INDEX ) ;
                              oe_debug_pub.add(  'PRICING_CONTEXT='|| OUT_REQ_LINE_DETAIL_ATTR_TBL ( I ) .PRICING_CONTEXT ) ;
                              oe_debug_pub.add(  'PRICING_ATTRIBUTE='|| OUT_REQ_LINE_DETAIL_ATTR_TBL ( I ) .PRICING_ATTRIBUTE ) ;
                           oe_debug_pub.add(  'PRICING_ATTR_VALUE_FROM='|| OUT_REQ_LINE_DETAIL_ATTR_TBL ( I ) .PRICING_ATTR_VALUE_FROM ) ;
                           oe_debug_pub.add(  'PRICING_ATTR_VALUE_TO='|| OUT_REQ_LINE_DETAIL_ATTR_TBL ( I ) .PRICING_ATTR_VALUE_TO ) ;
                       END IF;

    end loop;
    end if;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT LINE ATTR TBL='||OUT_REQ_LINE_ATTR_TBL.COUNT ) ;
    END IF;
    if out_req_line_attr_tbl.count > 0 then
    for i in out_req_line_attr_tbl.first..out_req_line_attr_tbl.last
    loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '*******************************' ) ;
            oe_debug_pub.add(  'LINE ATTR_TABLE RECORD='||I ) ;
            oe_debug_pub.add(  'LINE_INDEX='||OUT_REQ_LINE_ATTR_TBL ( I ) .LINE_INDEX ) ;
                              oe_debug_pub.add(  'PRICING_CONTEXT='|| OUT_REQ_LINE_ATTR_TBL ( I ) .PRICING_CONTEXT ) ;
                              oe_debug_pub.add(  'PRICING_ATTRIBUTE='|| OUT_REQ_LINE_ATTR_TBL ( I ) .PRICING_ATTRIBUTE ) ;
                              oe_debug_pub.add(  'PRICING_ATTR_VALUE_FROM='|| OUT_REQ_LINE_ATTR_TBL ( I ) .PRICING_ATTR_VALUE_FROM ) ;
                              oe_debug_pub.add(  'PRICING_ATTR_VALUE_TO='|| OUT_REQ_LINE_ATTR_TBL ( I ) .PRICING_ATTR_VALUE_TO ) ;
                          END IF;

    end loop;
    end if;


                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'COUNT RELATED LINES TBL='|| OUT_REQ_RELATED_LINES_TBL.COUNT ) ;
                          END IF;
    if out_req_related_lines_tbl.count > 0 then
    for i in out_req_related_lines_tbl.first..out_req_related_lines_tbl.last
    loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '*******************************' ) ;
            oe_debug_pub.add(  'RELATD LINES RECORD='||I ) ;
            oe_debug_pub.add(  'LIN_INDEX='||OUT_REQ_RELATED_LINES_TBL ( I ) .LINE_INDEX ) ;
                              oe_debug_pub.add(  'LINE_DETAIL_INDEX='|| OUT_REQ_RELATED_LINES_TBL ( I ) .LINE_DETAIL_INDEX ) ;
                              oe_debug_pub.add(  'RELATIONSHIP_TYPE_CODE='|| OUT_REQ_RELATED_LINES_TBL ( I ) .RELATIONSHIP_TYPE_CODE ) ;
                              oe_debug_pub.add(  'RELATED_LINE_INDEX='|| OUT_REQ_RELATED_LINES_TBL ( I ) .RELATED_LINE_INDEX ) ;
                           oe_debug_pub.add(  'RELATED_LINE_DETAIL_INDEX='|| OUT_REQ_RELATED_LINES_TBL ( I ) .RELATED_LINE_DETAIL_INDEX ) ;
                       END IF;

    end loop;
    end if;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT LINE QUAL TBL='||OUT_REQ_QUAL_TBL.COUNT ) ;
    END IF;
    if out_req_qual_tbl.count > 0 then
    for i in out_req_qual_tbl.first..out_req_qual_tbl.last
    loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '*******************************' ) ;
            oe_debug_pub.add(  'QUAL TABLE RECORD='||I ) ;
            oe_debug_pub.add(  'LINE_INDEX='||OUT_REQ_QUAL_TBL ( I ) .LINE_INDEX ) ;
                              oe_debug_pub.add(  'QUALIFIER_CONTEXT='|| OUT_REQ_QUAL_TBL ( I ) .QUALIFIER_CONTEXT ) ;
                              oe_debug_pub.add(  'QUALIFIER_ATTRIBUTE='|| OUT_REQ_QUAL_TBL ( I ) .QUALIFIER_ATTRIBUTE ) ;
                              oe_debug_pub.add(  'QUALIFIER_ATTR_VALUE_FROM='|| OUT_REQ_QUAL_TBL ( I ) .QUALIFIER_ATTR_VALUE_FROM ) ;
                              oe_debug_pub.add(  'QUALIFIER_ATTR_VALUE_TO='|| OUT_REQ_QUAL_TBL ( I ) .QUALIFIER_ATTR_VALUE_TO ) ;
                              oe_debug_pub.add(  'COMPARISON_OPERATOR_CODE='|| OUT_REQ_QUAL_TBL ( I ) .COMPARISON_OPERATOR_CODE ) ;
            oe_debug_pub.add(  'VALIDATED_FLAG='||OUT_REQ_QUAL_TBL ( I ) .VALIDATED_FLAG ) ;
        END IF;

    end loop;
    end if;


                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'COUNT LINE DETAIL QUAL TBL='|| OUT_REQ_LINE_DETAIL_QUAL_TBL.COUNT ) ;
                          END IF;
    if out_req_line_detail_qual_tbl.count > 0 then
    for i in out_req_line_detail_qual_tbl.first..out_req_line_detail_qual_tbl.last
    loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '*******************************' ) ;
            oe_debug_pub.add(  'LINE DETAIL QUAL TABLE RECORD='||I ) ;
                              oe_debug_pub.add(  'LINE_DETAIL_INDEX='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .LINE_DETAIL_INDEX ) ;
                              oe_debug_pub.add(  'QUALIFIER_CONTEXT='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .QUALIFIER_CONTEXT ) ;
                              oe_debug_pub.add(  'QUALIFIER_ATTRIBUTE='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .QUALIFIER_ATTRIBUTE ) ;
                        oe_debug_pub.add(  'QUALIFIER_ATTR_VALUE_FROM='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .QUALIFIER_ATTR_VALUE_FROM ) ;
                          oe_debug_pub.add(  'QUALIFIER_ATTR_VALUE_TO='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .QUALIFIER_ATTR_VALUE_TO ) ;
                         oe_debug_pub.add(  'COMPARISON_OPERATOR_CODE='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .COMPARISON_OPERATOR_CODE ) ;
                         oe_debug_pub.add(  'VALIDATED_FLAG='|| OUT_REQ_LINE_DETAIL_QUAL_TBL ( I ) .VALIDATED_FLAG ) ;
                     END IF;

    end loop;
    end if;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' EXITING PRICE_ITEM*******************************' ) ;
    END IF;

EXCEPTION
  when others then

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'PRICE ITEM EXCEPTION WHEN OTHERS CODE='|| SQLCODE||' MESSAGE='||SQLERRM ) ;
                     END IF;

END price_item;

PROCEDURE copy_fields_to_globals(
                in_related_item_id        in number,
                in_qty                    in number,
                in_uom                    in varchar2,
                in_request_date           in date,
                in_customer_id            in number,
                in_item_identifier_type   in varchar2,
                in_agreement_id           in number,
                in_price_list_id          in number,
                in_ship_to_org_id         in number,
                in_invoice_to_org_id      in number,
                in_ship_from_org_id       in number,
                in_pricing_date           in date,
                in_order_type_id          in number,
                in_currency               in varchar2,
                in_pricing_context        in varchar2,
                in_pricing_attribute1     in varchar2,
                in_pricing_attribute2     in varchar2,
                in_pricing_attribute3     in varchar2,
                in_pricing_attribute4     in varchar2,
                in_pricing_attribute5     in varchar2,
                in_pricing_attribute6     in varchar2,
                in_pricing_attribute7     in varchar2,
                in_pricing_attribute8     in varchar2,
                in_pricing_attribute9     in varchar2,
                in_pricing_attribute10    in varchar2,
                in_pricing_attribute11    in varchar2,
                in_pricing_attribute12    in varchar2,
                in_pricing_attribute13    in varchar2,
                in_pricing_attribute14    in varchar2,
                in_pricing_attribute15    in varchar2,
                in_pricing_attribute16    in varchar2,
                in_pricing_attribute17    in varchar2,
                in_pricing_attribute18    in varchar2,
                in_pricing_attribute19    in varchar2,
                in_pricing_attribute20    in varchar2,
                in_pricing_attribute21    in varchar2,
                in_pricing_attribute22    in varchar2,
                in_pricing_attribute23    in varchar2,
                in_pricing_attribute24    in varchar2,
                in_pricing_attribute25    in varchar2,
                in_pricing_attribute26    in varchar2,
                in_pricing_attribute27    in varchar2,
                in_pricing_attribute28    in varchar2,
                in_pricing_attribute29    in varchar2,
                in_pricing_attribute30    in varchar2,
                in_pricing_attribute31    in varchar2,
                in_pricing_attribute32    in varchar2,
                in_pricing_attribute33    in varchar2,
                in_pricing_attribute34    in varchar2,
                in_pricing_attribute35    in varchar2,
                in_pricing_attribute36    in varchar2,
                in_pricing_attribute37    in varchar2,
                in_pricing_attribute38    in varchar2,
                in_pricing_attribute39    in varchar2,
                in_pricing_attribute40    in varchar2,
                in_pricing_attribute41    in varchar2,
                in_pricing_attribute42    in varchar2,
                in_pricing_attribute43    in varchar2,
                in_pricing_attribute44    in varchar2,
                in_pricing_attribute45    in varchar2,
                in_pricing_attribute46    in varchar2,
                in_pricing_attribute47    in varchar2,
                in_pricing_attribute48    in varchar2,
                in_pricing_attribute49    in varchar2,
                in_pricing_attribute50    in varchar2,
                in_pricing_attribute51    in varchar2,
                in_pricing_attribute52    in varchar2,
                in_pricing_attribute53    in varchar2,
                in_pricing_attribute54    in varchar2,
                in_pricing_attribute55    in varchar2,
                in_pricing_attribute56    in varchar2,
                in_pricing_attribute57    in varchar2,
                in_pricing_attribute58    in varchar2,
                in_pricing_attribute59    in varchar2,
                in_pricing_attribute60    in varchar2,
                in_pricing_attribute61    in varchar2,
                in_pricing_attribute62    in varchar2,
                in_pricing_attribute63    in varchar2,
                in_pricing_attribute64    in varchar2,
                in_pricing_attribute65    in varchar2,
                in_pricing_attribute66    in varchar2,
                in_pricing_attribute67    in varchar2,
                in_pricing_attribute68    in varchar2,
                in_pricing_attribute69    in varchar2,
                in_pricing_attribute70    in varchar2,
                in_pricing_attribute71    in varchar2,
                in_pricing_attribute72    in varchar2,
                in_pricing_attribute73    in varchar2,
                in_pricing_attribute74    in varchar2,
                in_pricing_attribute75    in varchar2,
                in_pricing_attribute76    in varchar2,
                in_pricing_attribute77    in varchar2,
                in_pricing_attribute78    in varchar2,
                in_pricing_attribute79    in varchar2,
                in_pricing_attribute80    in varchar2,
                in_pricing_attribute81    in varchar2,
                in_pricing_attribute82    in varchar2,
                in_pricing_attribute83    in varchar2,
                in_pricing_attribute84    in varchar2,
                in_pricing_attribute85    in varchar2,
                in_pricing_attribute86    in varchar2,
                in_pricing_attribute87    in varchar2,
                in_pricing_attribute88    in varchar2,
                in_pricing_attribute89    in varchar2,
                in_pricing_attribute90    in varchar2,
                in_pricing_attribute91    in varchar2,
                in_pricing_attribute92    in varchar2,
                in_pricing_attribute93    in varchar2,
                in_pricing_attribute94    in varchar2,
                in_pricing_attribute95    in varchar2,
                in_pricing_attribute96    in varchar2,
                in_pricing_attribute97    in varchar2,
                in_pricing_attribute98    in varchar2,
                in_pricing_attribute99    in varchar2,
                in_pricing_attribute100   in varchar2
                ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    g_related_item_id       := in_related_item_id;
    g_qty                   := in_qty;
    g_uom                   := in_uom;
    g_request_date          := in_request_date;
    g_customer_id           := in_customer_id;
    g_item_identifier_type  := in_item_identifier_type;
    g_agreement_id          := in_agreement_id;
    g_price_list_id         := in_price_list_id;
    g_ship_to_org_id        := in_ship_to_org_id;
    g_invoice_to_org_id     := in_invoice_to_org_id;
    g_ship_from_org_id      := in_ship_from_org_id;
    g_pricing_date          := in_pricing_date;
    g_order_type_id         := in_order_type_id;
    g_currency              := in_currency;
    g_pricing_context       := in_pricing_context;
    g_pricing_attribute1    := in_pricing_attribute1;
    g_pricing_attribute2    := in_pricing_attribute2;
    g_pricing_attribute3    := in_pricing_attribute3;
    g_pricing_attribute4    := in_pricing_attribute4;
    g_pricing_attribute5    := in_pricing_attribute5;
    g_pricing_attribute6    := in_pricing_attribute6;
    g_pricing_attribute7    := in_pricing_attribute7;
    g_pricing_attribute8    := in_pricing_attribute8;
    g_pricing_attribute9    := in_pricing_attribute9;
    g_pricing_attribute10   := in_pricing_attribute10;
    g_pricing_attribute11   := in_pricing_attribute11;
    g_pricing_attribute12   := in_pricing_attribute12;
    g_pricing_attribute13   := in_pricing_attribute13;
    g_pricing_attribute14   := in_pricing_attribute14;
    g_pricing_attribute15   := in_pricing_attribute15;
    g_pricing_attribute16   := in_pricing_attribute16;
    g_pricing_attribute17   := in_pricing_attribute17;
    g_pricing_attribute18   := in_pricing_attribute18;
    g_pricing_attribute19   := in_pricing_attribute19;
    g_pricing_attribute20   := in_pricing_attribute20;
    g_pricing_attribute21   := in_pricing_attribute21;
    g_pricing_attribute22   := in_pricing_attribute22;
    g_pricing_attribute23   := in_pricing_attribute23;
    g_pricing_attribute24   := in_pricing_attribute24;
    g_pricing_attribute25   := in_pricing_attribute25;
    g_pricing_attribute26   := in_pricing_attribute26;
    g_pricing_attribute27   := in_pricing_attribute27;
    g_pricing_attribute28   := in_pricing_attribute28;
    g_pricing_attribute29   := in_pricing_attribute29;
    g_pricing_attribute30   := in_pricing_attribute30;
    g_pricing_attribute31   := in_pricing_attribute31;
    g_pricing_attribute32   := in_pricing_attribute32;
    g_pricing_attribute33   := in_pricing_attribute33;
    g_pricing_attribute34   := in_pricing_attribute34;
    g_pricing_attribute35   := in_pricing_attribute35;
    g_pricing_attribute36   := in_pricing_attribute36;
    g_pricing_attribute37   := in_pricing_attribute37;
    g_pricing_attribute38   := in_pricing_attribute38;
    g_pricing_attribute39   := in_pricing_attribute39;
    g_pricing_attribute40   := in_pricing_attribute40;
    g_pricing_attribute41   := in_pricing_attribute41;
    g_pricing_attribute42   := in_pricing_attribute42;
    g_pricing_attribute43   := in_pricing_attribute43;
    g_pricing_attribute44   := in_pricing_attribute44;
    g_pricing_attribute45   := in_pricing_attribute45;
    g_pricing_attribute46   := in_pricing_attribute46;
    g_pricing_attribute47   := in_pricing_attribute47;
    g_pricing_attribute48   := in_pricing_attribute48;
    g_pricing_attribute49   := in_pricing_attribute49;
    g_pricing_attribute50   := in_pricing_attribute50;
    g_pricing_attribute51   := in_pricing_attribute51;
    g_pricing_attribute52   := in_pricing_attribute52;
    g_pricing_attribute53   := in_pricing_attribute53;
    g_pricing_attribute54   := in_pricing_attribute54;
    g_pricing_attribute55   := in_pricing_attribute55;
    g_pricing_attribute56   := in_pricing_attribute56;
    g_pricing_attribute57   := in_pricing_attribute57;
    g_pricing_attribute58   := in_pricing_attribute58;
    g_pricing_attribute59   := in_pricing_attribute59;
    g_pricing_attribute60   := in_pricing_attribute60;
    g_pricing_attribute61   := in_pricing_attribute61;
    g_pricing_attribute62   := in_pricing_attribute62;
    g_pricing_attribute63   := in_pricing_attribute63;
    g_pricing_attribute64   := in_pricing_attribute64;
    g_pricing_attribute65   := in_pricing_attribute65;
    g_pricing_attribute66   := in_pricing_attribute66;
    g_pricing_attribute67   := in_pricing_attribute67;
    g_pricing_attribute68   := in_pricing_attribute68;
    g_pricing_attribute69   := in_pricing_attribute69;
    g_pricing_attribute70   := in_pricing_attribute70;
    g_pricing_attribute71   := in_pricing_attribute71;
    g_pricing_attribute72   := in_pricing_attribute72;
    g_pricing_attribute73   := in_pricing_attribute73;
    g_pricing_attribute74   := in_pricing_attribute74;
    g_pricing_attribute75   := in_pricing_attribute75;
    g_pricing_attribute76   := in_pricing_attribute76;
    g_pricing_attribute77   := in_pricing_attribute77;
    g_pricing_attribute78   := in_pricing_attribute78;
    g_pricing_attribute79   := in_pricing_attribute79;
    g_pricing_attribute80   := in_pricing_attribute80;
    g_pricing_attribute81   := in_pricing_attribute81;
    g_pricing_attribute82   := in_pricing_attribute82;
    g_pricing_attribute83   := in_pricing_attribute83;
    g_pricing_attribute84   := in_pricing_attribute84;
    g_pricing_attribute85   := in_pricing_attribute85;
    g_pricing_attribute86   := in_pricing_attribute86;
    g_pricing_attribute87   := in_pricing_attribute87;
    g_pricing_attribute88   := in_pricing_attribute88;
    g_pricing_attribute89   := in_pricing_attribute89;
    g_pricing_attribute90   := in_pricing_attribute90;
    g_pricing_attribute91   := in_pricing_attribute91;
    g_pricing_attribute92   := in_pricing_attribute92;
    g_pricing_attribute93   := in_pricing_attribute93;
    g_pricing_attribute94   := in_pricing_attribute94;
    g_pricing_attribute95   := in_pricing_attribute95;
    g_pricing_attribute96   := in_pricing_attribute96;
    g_pricing_attribute97   := in_pricing_attribute97;
    g_pricing_attribute98   := in_pricing_attribute98;
    g_pricing_attribute99   := in_pricing_attribute99;
    g_pricing_attribute100  := in_pricing_attribute100;

END copy_fields_to_globals;
PROCEDURE process_pricing_errors(in_line_type_code in varchar2,
                                 in_status_code    in varchar2,
                                 in_status_text    in varchar2,
                                 in_ordered_item    in varchar2,
                                 in_uom    in varchar2,
                                 in_unit_price    in number,
                                 in_adjusted_unit_price    in number,
                                 in_process_code    in varchar2 ,
                                 in_price_flag    in varchar2,
                                 in_price_list_id in number,
                                 l_return_status        out NOCOPY /* file.sql.39 change */ varchar2,
                                 l_msg_count out NOCOPY /* file.sql.39 change */ number,
                                 l_msg_data  out NOCOPY /* file.sql.39 change */ varchar2
                                 ) IS

l_price_list varchar2(200);
l_allow_negative_price varchar2(10):= nvl(OE_Sys_Parameters.VALUE('ONT_NEGATIVE_PRICING'),'N');
l_gsa_violation_action Varchar2(30) :=fnd_profile.value('ONT_GSA_VIOLATION_ACTION');
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');


Cursor get_gsa_list_lines is
Select/*+ ordered use_nl(qpq qppa qpll qplh) */ min(qpll.operand)
 From
      qp_qualifiers qpq
 ,    qp_pricing_attributes qppa
 ,    qp_list_lines qpll
 ,    qp_list_headers_b qplh
 ,    qp_price_req_sources qpprs
 where
 qpq.qualifier_context='CUSTOMER'
 and qpq.qualifier_attribute='QUALIFIER_ATTRIBUTE15'
 and qpq.qualifier_attr_value='Y'
 and qppa.list_header_id=qplh.list_header_id
 and qplh.Active_flag='Y'
 and qpprs.request_type_code = 'ONT'
 and qpprs.source_system_code=qplh.source_system_code
 and    qppa.pricing_phase_id  = 2
 and    qppa.qualification_ind = 6
 and qppa.product_attribute_context ='ITEM'
 and qppa.product_attribute='PRICING_ATTRIBUTE1'
 and qppa.product_attr_value= g_related_item_id
 and qppa.excluder_flag = 'N'
 and qppa.list_header_id=qpq.list_header_id
 and qppa.list_line_id=qpll.list_line_id
 and  g_pricing_date between nvl(trunc(qplh.start_date_active),g_pricing_date)
 and nvl(trunc(qplh.End_date_active),g_pricing_date);

l_operand  number;
l_msg_text Varchar2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING PROCESS_PRICING_ERRORS' ) ;
  END IF;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'LINE_TYPE_CODE='||IN_LINE_TYPE_CODE|| ' STATUS CODE='||IN_STATUS_CODE|| ' NEGATIVE PRICE ='||L_ALLOW_NEGATIVE_PRICE|| ' IN_UNIT_PRICE ='||IN_UNIT_PRICE|| ' IN_ADJUSTED_UNIT_PRICE ='||IN_ADJUSTED_UNIT_PRICE ) ;
                   END IF;


  IF in_line_Type_code ='LINE' and
    in_status_code in ( QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST,
                        QP_PREQ_GRP.G_STS_LHS_NOT_FOUND,
                        QP_PREQ_GRP.G_STATUS_FORMULA_ERROR,
                        QP_PREQ_GRP.G_STATUS_OTHER_ERRORS,
                        FND_API.G_RET_STS_UNEXP_ERROR,
                        FND_API.G_RET_STS_ERROR,
                        QP_PREQ_GRP.G_STATUS_CALC_ERROR,
                        QP_PREQ_GRP.G_STATUS_UOM_FAILURE,
                        QP_PREQ_GRP.G_STATUS_INVALID_UOM,
                        QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,
                        QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV,
                        QP_PREQ_GRP.G_STATUS_INVALID_INCOMP,
                        QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR)
  then

    l_return_status := 'E';

    IF in_price_list_id is not null then
      Begin
        Select name into l_price_list
          from qp_list_headers_vl
         where list_header_id = in_price_list_id;
      Exception When No_data_found then
        l_price_list := in_price_list_id;
      End;
    END IF;

    IF in_status_code  = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST then

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'INVALID PRICE LIST'|| ' PRICE_LIST_ID='||G_PRICE_LIST_ID ) ;
                      END IF;
      IF g_price_list_id is null then

        FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_GENERIC');
        FND_MESSAGE.SET_TOKEN('TEXT',in_status_text);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INVALID PL ERR TXT='||IN_STATUS_TEXT ) ;
        END IF;
        OE_MSG_PUB.Add;

      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INVALID PRICE LIST' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_PRC_NO_LIST_PRICE');
        FND_MESSAGE.SET_TOKEN('ITEM',in_Ordered_Item);
        FND_MESSAGE.SET_TOKEN('UNIT',in_uom);
        FND_MESSAGE.SET_TOKEN('PRICE_LIST',l_Price_List);
        OE_MSG_PUB.Add;

      END IF;

    ELSIF in_status_code = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND Then

      FND_MESSAGE.SET_NAME('ONT','ONT_NO_PRICE_LIST_FOUND');
      FND_MESSAGE.SET_TOKEN('ITEM',in_Ordered_Item);
      FND_MESSAGE.SET_TOKEN('UOM',in_uom);
      OE_MSG_PUB.Add;

    ELSIF in_status_code = QP_PREQ_GRP.G_STATUS_FORMULA_ERROR then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRC_ERROR_IN_FORMULA');
      OE_MSG_PUB.Add;

    ELSIF in_status_code in
    ( QP_PREQ_GRP.G_STATUS_OTHER_ERRORS , FND_API.G_RET_STS_UNEXP_ERROR,
      FND_API.G_RET_STS_ERROR) then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS');
      FND_MESSAGE.SET_TOKEN('ERR_TEXT',in_status_text);
      OE_MSG_PUB.Add;

    ELSIF in_status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_UOM');
      FND_MESSAGE.SET_TOKEN('ITEM',in_Ordered_Item);
      FND_MESSAGE.SET_TOKEN('UOM',in_uom);
      OE_MSG_PUB.Add;

    ElSIF in_status_code = QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRC_DUPLICATE_PRICE_LIST');

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DUPLICATE PRICE LIST ERROR' ) ;
      END IF;
      Begin
        Select name into l_price_list
        from qp_list_headers_vl a,qp_list_lines b where
        b.list_line_id =  to_number(substr(in_status_text,1,
        instr(in_status_text,',')-1))
        and a.list_header_id=b.list_header_id ;
      Exception When No_data_found then
        l_price_list := to_number(substr(in_status_text,1,
        instr(in_status_text,',')-1));
      When invalid_number then
        l_price_list := substr(in_status_text,1,
        instr(in_status_text,',')-1);
      End;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PRICE LIST 1='||L_PRICE_LIST ) ;
      END IF;
      FND_MESSAGE.SET_TOKEN('PRICE_LIST1','( '||in_Ordered_Item||' ) '|| l_price_list);
      Begin
        Select name into l_price_list
        from qp_list_headers_vl a,qp_list_lines b where
        b.list_line_id =  to_number(substr(in_status_text,
        instr(in_status_text,',')+1))
        and a.list_header_id=b.list_header_id	;
      Exception When No_data_found then
        l_price_list := to_number(substr(in_status_text,
        instr(in_status_text,',')+1));
      When invalid_number then
        l_price_list := substr(in_status_text,
        instr(in_status_text,',')+1);
      End;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PRICE LIST 2='||L_PRICE_LIST ) ;
      END IF;

      FND_MESSAGE.SET_TOKEN('PRICE_LIST2',l_price_list);
      OE_MSG_PUB.Add;

    ELSIF in_status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_UOM_CONVERSION');
      FND_MESSAGE.SET_TOKEN('UOM_TEXT','( '||in_Ordered_Item||' ) '||
				in_status_text);
      OE_MSG_PUB.Add;

    ElSIF in_status_code = QP_PREQ_GRP.G_STATUS_INVALID_INCOMP then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_INCOMP');
      FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '||in_Ordered_Item||' ) '||
                           in_status_text);
      OE_MSG_PUB.Add;

    ELSIF in_status_code = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR then
      FND_MESSAGE.SET_NAME('ONT','ONT_PRC_BEST_PRICE_ERROR');
      FND_MESSAGE.SET_TOKEN('ITEM',in_Ordered_Item);
      FND_MESSAGE.SET_TOKEN('ERR_TEXT',in_status_text);
      OE_MSG_PUB.Add;
    END IF;


  /*elsif ( in_unit_price < 0 or in_Adjusted_unit_price < 0) and
          l_allow_negative_price = 'N' then

    oe_debug_pub.add('Error as Negative Pricing is not Allowed');
    FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_PRICE');
    FND_MESSAGE.SET_TOKEN('ITEM',in_Ordered_Item);
    FND_MESSAGE.SET_TOKEN('LIST_PRICE',in_unit_price);
    FND_MESSAGE.SET_TOKEN('SELLING_PRICE',in_Adjusted_unit_price);
    OE_MSG_PUB.Add;
    --FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_MODIFIERS');
    --FND_MESSAGE.SET_TOKEN('LIST_LINE_NO',get_list_lines(g_line_id));
    --OE_MSG_PUB.Add;
    l_return_status := 'E';
    --RAISE FND_API.G_EXC_ERROR;*/

  ELSIF in_line_Type_code ='LINE' and
   in_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS Then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE_PRICING_ERROR' ) ;
    END IF;
    FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
    FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '||in_Ordered_Item||' ) '||in_STATUS_TEXT);
    OE_MSG_PUB.Add;

  ELSIF in_line_Type_code ='LINE' and in_status_code in
             --( QP_PREQ_GRP.G_STATUS_UPDATED,
               (QP_PREQ_GRP.G_STATUS_GSA_VIOLATION) and
             --  QP_PREQ_GRP.G_STATUS_UNCHANGED) and
	   nvl(in_process_code,'0') <> QP_PREQ_GRP.G_BY_ENGINE
	   and in_price_flag IN ('Y','P')
      --we do not want to go in this loop if price_flag is set up 'N' because
      --engine doesn't look at the line and will not return adjustments. In this
      --case we DON't want to remove the adjustments that engine doesn't return.
    then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OE_PRICING_ERROR 2' ) ;
      END IF;

      IF in_status_text is not null then
        l_return_status := 'E';
         FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
         FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '||in_Ordered_Item||' ) '||in_STATUS_TEXT);
        --FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS');
        --FND_MESSAGE.SET_TOKEN('ERR_TEXT',in_status_text);
         OE_MSG_PUB.Add;
      END IF;

      -- we need to do this check in UPDATED code or do the gsa check through
      -- the control record of Pricing
      /*OPEN get_gsa_list_lines;
      FETCH get_gsa_list_lines
       INTO l_operand;
      CLOSE get_gsa_list_lines;
      oe_debug_pub.add('After select OE_PRICING_ERROR 2');
      oe_debug_pub.add('Adj price='||in_adjusted_unit_price||
                       ' Operand='||l_operand);

      IF in_adjusted_unit_price <= l_operand then
        oe_debug_pub.add('If unit price less than operand violation='||
                          l_gsa_violation_action);
        --Check if the GSA check needs to be done.
        If l_gsa_violation_action in ('WARNING','ERROR') then

          oe_debug_pub.add('GSA warning or error');
          Begin
            SELECT concatenated_segments
              INTO l_msg_text
              FROM mtl_system_items_kfv
             WHERE inventory_item_id = g_related_item_id
               AND organization_id = l_org_id;
          Exception
            when no_data_found then
            Null;
          End;

          l_return_status := 'E';
          oe_debug_pub.add('GSA warning or error 2 msg_Text='||l_msg_text);
          FND_MESSAGE.SET_NAME('ONT','OE_GSA_VIOLATION');
          l_msg_text := l_operand||' ( '||l_msg_text||' )';
          FND_MESSAGE.SET_TOKEN('GSA_PRICE',l_msg_text);
          OE_MSG_PUB.Add;
        END IF;
      END IF; */


  ELSIF  -- Process header level adjustments
    in_line_type_code ='ORDER' and
    (in_status_code in ( QP_PREQ_GRP.G_STATUS_UPDATED ,
                         QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
     --In this case even engine doesn't update the order (status = UNCHANGED)
     --because of one of the lined is frozen,
     --there can be some order level adjustments in database which
     --need to be pulled out by append_adjustment_lines routine
      or (in_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED))
	Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE_PRICING_ERROR 3' ) ;
    END IF;
    null;

  ELSIF in_line_Type_code ='LINE' and in_status_code = 'UPDATED' then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'STATUS = UPDATED' ) ;
    END IF;

  END IF;-- Status_Code


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PROCESS PRICING ERROR AFTER ERR CHK ST='||L_RETURN_STATUS ) ;
  END IF;

  IF l_return_status ='E' then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DOING COUNT_AND_GET' ) ;
    END IF;
    oe_msg_pub.count_and_get(p_encoded=>fnd_api.G_TRUE,
                             p_count => l_msg_count,
                             p_data=>l_msg_data
                                    );
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING PROCESS_PRICING_ERRORS' ) ;
  END IF;

EXCEPTION

  when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'PROCESS PRICING ERRORS WHEN OTHERS EXCEPTION CODE='|| SQLCODE||' MESSAGE='||SQLERRM ) ;
                        END IF;

END process_pricing_errors;
FUNCTION Get_Rounding_factor(p_list_header_id number) return number is

l_rounding_factor number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    select rounding_factor
      into l_rounding_factor
      from qp_list_headers_b
     where list_header_id = p_list_header_id;

    If l_rounding_factor = fnd_api.g_miss_num then
      l_rounding_factor:= Null;
    End If;

    Return l_rounding_factor;


EXCEPTION
    when no_data_found then
        Return Null;
END Get_Rounding_factor;


PROCEDURE get_Price_List_info(
                          p_price_list_id IN  NUMBER,
                          out_name  out NOCOPY /* file.sql.39 change */ varchar2,
                          out_end_date out NOCOPY /* file.sql.39 change */ date,
                          out_start_date out NOCOPY /* file.sql.39 change */ date,
                          out_automatic_flag out NOCOPY /* file.sql.39 change */ varchar2,
                          out_rounding_factor out NOCOPY /* file.sql.39 change */ varchar2,
                          out_terms_id out NOCOPY /* file.sql.39 change */ number,
                          out_gsa_indicator out NOCOPY /* file.sql.39 change */ varchar2,
                          out_currency out NOCOPY /* file.sql.39 change */ varchar2,
                          out_freight_terms_code out NOCOPY /* file.sql.39 change */ varchar2
                         ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'GET PRICE_LIST ID='||P_PRICE_LIST_ID ) ;
    END IF;

    IF p_price_list_id IS NOT NULL THEN

        SELECT  NAME,
                end_date_active,
                start_date_active,
                automatic_flag,
                rounding_factor,
                terms_id,
                gsa_indicator,
                currency_code,
                freight_terms_code
        INTO    out_name,
                out_end_date,
                out_start_date,
                out_automatic_flag,
                out_rounding_factor,
                out_terms_id,
                out_gsa_indicator,
                out_currency,
                out_freight_terms_code

        FROM    qp_list_headers_vl
        WHERE   list_header_id = p_price_list_id
          and   list_type_code in ('PRL', 'AGR');

    END IF;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'END_DATE='||OUT_END_DATE|| ' START_DATE='||OUT_START_DATE ) ;
                     END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO DATA FOUND GET PRICE LIST_INFO' ) ;
        END IF;

    WHEN OTHERS THEN
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'WHEN OTHERS GET PRICE LIST_INFO'|| SQLCODE||SQLERRM ) ;
                         END IF;

END get_Price_List_info;

PROCEDURE different_uom(
                        in_org_id in number
                       ,in_ordered_uom in varchar2
                       ,in_pricing_uom in varchar2
                       ,out_conversion_rate out NOCOPY /* file.sql.39 change */ number
                       )IS

CURSOR c_items IS
  SELECT primary_uom_code
    FROM mtl_system_items_b
   WHERE organization_id = in_org_id
     AND inventory_item_id = g_Inventory_item_id;

CURSOR c_class(in_ordered_uom in varchar2) is
  SELECT uom_Class
    FROM mtl_units_of_measure_tl
   WHERE uom_code = in_ordered_uom;

CURSOR c_base_uom(in_class in varchar2) IS
  SELECT uom_code
    FROM mtl_units_of_measure_tl
   WHERE uom_class = in_class
     AND base_uom_flag = 'Y';

l_primary_Uom varchar2(100);
l_uom_class varchar2(50);
l_base_uom varchar2(50);
l_conversion_rate number;
l_ordered_conversion number;
l_pricing_conversion number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ENTERING OE_AVAILABILITY.DIFFERENT_UOM'|| ' ORDERED_UOM ='||IN_ORDERED_UOM|| ' PRICING_UOM='||IN_PRICING_UOM|| ' IN_INV_ITEM_ID='||G_INVENTORY_ITEM_ID|| ' IN_ORG_ID='||IN_ORG_ID ) ;
                  END IF;

  OPEN c_items;
  FETCH c_items
   INTO l_primary_uom;

  IF c_items%FOUND then

    OPEN c_class(l_primary_uom);
    FETCH c_class
     INTO l_uom_class;

    IF c_class%FOUND then

      OPEN c_base_uom(l_uom_class);
      FETCH c_base_Uom
       INTO l_base_uom;

      IF c_base_uom%FOUND then

        -- Both Ordered and Pricing are not Base UOM
        IF in_ordered_uom <> l_base_uom AND
           in_pricing_uom <> l_base_uom THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEITHER THE ORDERED OR PRICING UOM IS BASE UOM' ) ;
          END IF;

          l_ordered_conversion := get_conversion_rate(
                                     in_uom_code => in_ordered_uom,
                                     in_base_uom => l_base_uom
                                                      );
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE ORD RATE ='||L_ORDERED_CONVERSION ) ;
          END IF;
          l_pricing_conversion := get_conversion_rate(
                                     in_uom_code => in_pricing_uom,
                                     in_base_uom => l_base_uom
                                                      );
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE PRICING RATE ='||L_PRICING_CONVERSION ) ;
          END IF;

          out_conversion_rate := l_ordered_conversion/l_pricing_conversion;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE RATE ='||OUT_CONVERSION_RATE ) ;
          END IF;

        -- Ordered Uom is the Base Uom,sending the pricing uom for conversion
        ELSIF  in_ordered_uom = l_base_uom then

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE ORDERED UOM IS BASE UOM' ) ;
          END IF;

          l_ordered_conversion := get_conversion_rate(
                                     in_uom_code => in_pricing_uom,
                                     in_base_uom => l_base_uom
                                                      );
          out_conversion_rate := l_ordered_conversion;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE RATE ='||OUT_CONVERSION_RATE ) ;
          END IF;

        -- Pricing Uom is the Base Uom
        ELSIF  in_pricing_uom = l_base_uom then

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE PRICING UOM IS BASE UOM' ) ;
          END IF;
          l_pricing_conversion := get_conversion_rate(
                                     in_uom_code => in_ordered_uom,
                                     in_base_uom => l_base_uom
                                                      );
          out_conversion_rate := l_pricing_conversion;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE RATE ='||OUT_CONVERSION_RATE ) ;
          END IF;

        END IF;

      END IF;

      CLOSE c_base_uom;

    END IF;

    CLOSE c_class;

  END IF;
  CLOSE c_items;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO DATA FONUNG DIFFERENT_UOM ' ) ;
    END IF;

  WHEN OTHERS THEN
    IF c_items%ISOPEN then
      CLOSE c_items;
    END IF;
    IF c_class%ISOPEN then
      CLOSE c_class;
    END IF;
    IF c_base_uom%ISOPEN then
      CLOSE c_base_uom;
    END IF;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'ERROR IN DIFFERENT_UOM '|| SQLCODE||SQLERRM ) ;
                    END IF;

END different_uom;



FUNCTION get_conversion_rate (in_uom_code in varchar2,
                              in_base_uom in varchar2
                             ) RETURN number is


CURSOR c_item_conversion IS
  SELECT round(1/conversion_rate,6)
    FROM mtl_uom_conversions
   WHERE uom_code  = in_uom_code
     AND inventory_item_id = g_inventory_item_id;

CURSOR c_conversion IS
  SELECT round(1/conversion_rate,6)
    FROM mtl_uom_conversions
   WHERE uom_Code = in_uom_code
     AND inventory_item_id = 0;

CURSOR c_inter_class IS
  SELECT round(1/conversion_rate,6)
    FROM mtl_uom_class_conversions
   WHERE to_uom_code = in_uom_code
     AND from_uom_code  = in_base_uom
     AND inventory_item_id = g_inventory_item_id;

l_conversion_rate number;
l_uom_code varchar2(50);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'INSIDE GET_CONVERSION_RATE '|| ' IN_UOM_CODE='||IN_UOM_CODE|| ' IN_BASE_UOM='||IN_BASE_UOM ) ;
                    END IF;

    OPEN c_item_conversion;
    FETCH c_item_conversion
     INTO l_conversion_rate;

    IF c_item_conversion%NOTFOUND THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ITEM SPECIFIC CONVERSION RATE NOT FOUND' ) ;
      END IF;

      OPEN c_conversion;
      FETCH c_conversion
       INTO l_conversion_rate;

      IF c_conversion%NOTFOUND THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'GENERIC CONVERSION NOT FOUND' ) ;
        END IF;
        OPEN c_inter_class;
        FETCH c_inter_class
         INTO l_conversion_rate;

        IF c_inter_class%NOTFOUND THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTER CLASS RETURN RATE NOT FOUND= 1' ) ;
           END IF;
           l_conversion_rate := 1;

        ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTER CLASS RETURN RATE = '||L_CONVERSION_RATE ) ;
           END IF;

        END IF;
        CLOSE c_inter_class;

      ELSIF c_conversion%FOUND then

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RETURN RATE GENERIC= '||L_CONVERSION_RATE ) ;
           END IF;

      END IF;
      CLOSE c_conversion;

    ELSIF c_item_conversion%FOUND THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ITEM SPECIFIC CONVERSION RATE='||L_CONVERSION_RATE ) ;
        END IF;

    END IF;
    CLOSE c_item_conversion;

    return l_conversion_rate;

EXCEPTION

  WHEN ZERO_DIVIDE THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'DIVIDE BY ZERO ERROR IN_UOM_CODE='||IN_UOM_CODE|| ' BASE UOM='||IN_BASE_UOM ) ;
                     END IF;

    IF c_item_conversion%ISOPEN then
      CLOSE c_item_conversion;
    END IF;
    IF c_conversion%ISOPEN then
      CLOSE c_conversion;
    END IF;
    IF c_inter_class%ISOPEN then
      CLOSE c_inter_class;
    END IF;

  WHEN OTHERS THEN

    IF c_item_conversion%ISOPEN then
      CLOSE c_item_conversion;
    END IF;
    IF c_conversion%ISOPEN then
      CLOSE c_conversion;
    END IF;
    IF c_inter_class%ISOPEN then
      CLOSE c_inter_class;
    END IF;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'ERROR IN GET_CONVERSION_RATE '|| SQLCODE||SQLERRM ) ;
                    END IF;
    return 1;
END get_conversion_rate;
PROCEDURE print_time(in_place in varchar2) IS

 cursor c_hsecs is
   select hsecs
     from v$timer;

l_hsecs number;
l_total number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --print_time2;
  OPEN c_hsecs;
  FETCH c_hsecs
   INTO l_hsecs;
  CLOSE c_hsecs;

  IF g_hsecs is null then

    g_hsecs := l_hsecs;
    g_place := in_place;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'TIME STARTING AT PLACE '||G_PLACE||' TIME='||G_HSECS ) ;
    END IF;

  ELSE
    l_total := (l_hsecs - g_hsecs)/100;
    g_total := g_total + l_total;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'TIME FROM ' ||G_PLACE||' TO '||IN_PLACE||' TIME DIFF='|| L_TOTAL||' SECONDS'||' TOTAL SO FAR='||G_TOTAL ) ;
                      END IF;
    g_hsecs := l_hsecs;
    g_place := in_place;

  END IF;
  --print_time2;

END print_time;


PROCEDURE print_time2 IS

 cursor c2_hsecs is
   select hsecs
     from v$timer;

l_hsecs number;
l_total number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  OPEN c2_hsecs;
  FETCH c2_hsecs
   INTO l_hsecs;
  CLOSE c2_hsecs;

  IF g_total2 is null then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'G_TOTAL2 IS NULL L_HSECS='||L_HSECS ) ;
    END IF;
    g_total2 := l_hsecs;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_HSECS='||L_HSECS||' TOTAL2='||G_TOTAL2 ) ;
    END IF;
    l_total := (l_hsecs - g_total2)/100;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'G_TOTAL2='||L_TOTAL ) ;
    END IF;
    g_total2 := l_hsecs;
  END IF;

END print_time2;
END Oe_Related_Items_Pvt;

/
