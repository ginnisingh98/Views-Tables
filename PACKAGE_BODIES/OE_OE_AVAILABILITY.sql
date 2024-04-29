--------------------------------------------------------
--  DDL for Package Body OE_OE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_AVAILABILITY" AS
/* $Header: OEXFAVAB.pls 120.0.12010000.2 2008/08/04 14:59:27 amallik ship $ */

  --Global variables

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'oe_oe_availability';
  G_ATP_TBL          OE_ATP.atp_tbl_type;
  G_line_id          CONSTANT NUMBER :=1234;
  G_atp_line_id      CONSTANT NUMBER := -9987;
  g_header_id        CONSTANT NUMBER :=2345;
  g_hsecs            number;
  g_place            varchar2(100);
  g_total            number :=0;
  g_total2           number ;

   -- Things from her would go
/*
g_inventory_item_id      number;
g_qty                    number;
g_uom                    varchar2(20);
g_request_date           date;
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
*/
   -- Till here it would go
   --Global Tables required for temp_table population.

  G_LINE_INDEX_tbl               QP_PREQ_GRP.pls_integer_type;
  G_LINE_TYPE_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_EFFECTIVE_DATE_TBL   QP_PREQ_GRP.DATE_TYPE   ;
  G_ACTIVE_DATE_FIRST_TBL        QP_PREQ_GRP.DATE_TYPE   ;
  G_ACTIVE_DATE_FIRST_TYPE_TBL   QP_PREQ_GRP.VARCHAR_TYPE;
  G_ACTIVE_DATE_SECOND_TBL       QP_PREQ_GRP.DATE_TYPE   ;
  G_ACTIVE_DATE_SECOND_TYPE_TBL  QP_PREQ_GRP.VARCHAR_TYPE ;
  G_LINE_QUANTITY_TBL            QP_PREQ_GRP.NUMBER_TYPE ;
  G_LINE_UOM_CODE_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
  G_REQUEST_TYPE_CODE_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICED_QUANTITY_TBL          QP_PREQ_GRP.NUMBER_TYPE;
  G_UOM_QUANTITY_TBL             QP_PREQ_GRP.NUMBER_TYPE;
  G_PRICED_UOM_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
  G_CURRENCY_CODE_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
  G_UNIT_PRICE_TBL               QP_PREQ_GRP.NUMBER_TYPE;
  G_PERCENT_PRICE_TBL            QP_PREQ_GRP.NUMBER_TYPE;
  G_ADJUSTED_UNIT_PRICE_TBL      QP_PREQ_GRP.NUMBER_TYPE;
  G_UPD_ADJUSTED_UNIT_PRICE_TBL  QP_PREQ_GRP.NUMBER_TYPE;
  G_PROCESSED_FLAG_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICE_FLAG_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
  G_LINE_ID_TBL                  QP_PREQ_GRP.NUMBER_TYPE;
  G_PROCESSING_ORDER_TBL         QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ROUNDING_FACTOR_TBL          QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ROUNDING_FLAG_TBL            QP_PREQ_GRP.FLAG_TYPE;
  G_QUALIFIERS_EXIST_FLAG_TBL    QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_ATTRS_EXIST_FLAG_TBL QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICE_LIST_ID_TBL            QP_PREQ_GRP.NUMBER_TYPE;
  G_PL_VALIDATED_FLAG_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICE_REQUEST_CODE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
  G_USAGE_PRICING_TYPE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
  G_LINE_CATEGORY_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_STATUS_CODE_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_STATUS_TEXT_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_LINE_INDEX_tbl          QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ATTR_LINE_DETAIL_INDEX_tbl   QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ATTR_VALIDATED_FLAG_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRICING_CONTEXT_tbl     QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRICING_ATTRIBUTE_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_ATTRIBUTE_LEVEL_tbl	 QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_ATTRIBUTE_TYPE_tbl	 QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_APPLIED_FLAG_tbl	 QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRICING_STATUS_CODE_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRICING_ATTR_FLAG_tbl 	 QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_LIST_HEADER_ID_tbl	 QP_PREQ_GRP.NUMBER_TYPE;
  G_ATTR_LIST_LINE_ID_tbl	 QP_PREQ_GRP.NUMBER_TYPE;
  G_ATTR_VALUE_FROM_tbl          QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_SETUP_VALUE_FROM_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_VALUE_TO_tbl     	 QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_SETUP_VALUE_TO_tbl	 QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_GROUPING_NUMBER_tbl 	 QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ATTR_NO_QUAL_IN_GRP_tbl      QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ATTR_COMP_OPERATOR_TYPE_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRICING_STATUS_TEXT_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_QUAL_PRECEDENCE_tbl     QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ATTR_DATATYPE_tbl            QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_QUALIFIER_TYPE_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRODUCT_UOM_CODE_TBL    QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_EXCLUDER_FLAG_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRICING_PHASE_ID_TBL    QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ATTR_INCOM_GRP_CODE_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_LDET_TYPE_CODE_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_MODIFIER_LEVEL_CODE_TBL QP_PREQ_GRP.VARCHAR_TYPE;
  G_ATTR_PRIMARY_UOM_FLAG_TBL    QP_PREQ_GRP.VARCHAR_TYPE;
  G_CATCHWEIGHT_QTY_TBL          QP_PREQ_GRP.NUMBER_TYPE;
  G_ACTUAL_ORDER_QTY_TBL         QP_PREQ_GRP.NUMBER_TYPE;
  G_IS_THERE_FREEZE_OVERRIDE  Boolean:=TRUE;


--g_panda_rec_table panda_rec_table;


Procedure Call_MRP_ATP(
               in_global_orgs  in varchar2,
               in_ship_from_org_id in number,
out_available_qty out nocopy varchar2,

out_ship_from_org_id out nocopy number,

out_available_date out nocopy date,

out_qty_uom out nocopy varchar2,

x_out_message out nocopy varchar2,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

x_error_message out nocopy varchar2

                      ) IS

l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
x_atp_rec                 MRP_ATP_PUB.ATP_Rec_Typ;
in_atp_rec                 MRP_ATP_PUB.ATP_Rec_Typ;
I                         NUMBER := 1;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING CALL ATP' ) ;
   END IF;

   Initialize_mrp_record
       ( p_x_atp_rec => in_atp_rec
         ,l_count    =>1 );


                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'INVENTORY_ITEM_ID='||g_panda_rec_table(1).P_INVENTORY_ITEM_ID
					   || ' SHIP_FORM_ORG_ID='||G_panda_rec_table(1).p_SHIP_FROM_ORG_ID
					   || ' IN_GLOBAL_ORGS='||IN_GLOBAL_ORGS);
                        oe_debug_pub.add(' CUST_ID='||G_panda_rec_table(1).p_CUSTOMER_ID|| ' SHIP_TO_ORG_ID='
					 ||G_panda_rec_table(1).p_SHIP_TO_ORG_ID||' QTY='||G_panda_rec_table(1).p_QTY
					 || ' UOM='||G_panda_rec_table(1).p_UOM||' REQ DATE='||
					 G_panda_rec_table(1).p_REQUEST_DATE ) ;
                    END IF;

   --if the call is made for GA then the org_id is passed
   IF in_global_orgs = 'Y' and
      in_ship_from_org_id is not null then

     in_atp_rec.Source_Organization_Id(1)  := in_ship_from_org_id;
   ELSE

     in_atp_rec.Source_Organization_Id(1)  := g_panda_rec_table(1).p_ship_from_org_id;
   END IF;

   /*SELECT  OE_ORDER_LINES_S.NEXTVAL
     INTO  l_line_id
     FROM  DUAL;
   */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE_ID='||G_ATP_LINE_ID ) ;
   END IF;

   in_atp_rec.Identifier(I)              := g_atp_line_id;
   in_atp_rec.Action(I)                  := 100;
   in_atp_rec.calling_module(I)          := 660;
   in_atp_rec.customer_id(I)             := g_panda_rec_table(1).p_customer_id;
   in_atp_rec.customer_site_id(I)        := g_panda_rec_table(1).p_ship_to_org_id;
   in_atp_rec.inventory_item_id(I)       := g_panda_rec_table(1).p_inventory_item_id;
   in_atp_rec.quantity_ordered(I)        := g_panda_rec_table(1).p_qty;
   in_atp_rec.quantity_uom(I)            := g_panda_rec_table(1).p_uom;
   in_atp_rec.Earliest_Acceptable_Date(I):= null;
   in_atp_rec.Requested_Ship_Date(I)     := g_panda_rec_table(1).p_request_date;
   in_atp_rec.Requested_Arrival_Date(I)  := null;
   in_atp_rec.Delivery_Lead_Time(I)      := Null;
   in_atp_rec.Freight_Carrier(I)         := null;
   in_atp_rec.Ship_Method(I)             := null;
   in_atp_rec.Demand_Class(I)            := null;
   in_atp_rec.Ship_Set_Name(I)           := null;
   in_atp_rec.Arrival_Set_Name(I)        := null;
   in_atp_rec.Override_Flag(I)           := 'N';
   in_atp_rec.Ship_Date(I)               := null;
   in_atp_rec.Available_Quantity(I)      := null;
   in_atp_rec.Requested_Date_Quantity(I) := null;
   in_atp_rec.Group_Ship_Date(I)         := null;
   in_atp_rec.Group_Arrival_Date(I)      := null;
   in_atp_rec.Vendor_Id(I)               := null;
   in_atp_rec.Vendor_Site_Id(I)          := null;
   in_atp_rec.Insert_Flag(I)             := 1; -- it can be 0 or 1
   in_atp_rec.Error_Code(I)              := null;
   in_atp_rec.Message(I)                 := null;
   in_atp_rec.atp_lead_time(I)           := 0;

   SELECT mrp_atp_schedule_temp_s.nextval
     INTO l_session_id
     FROM dual;

   -- Call ATP

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('1.CALLING MRP API WITH SESSION ID '||L_SESSION_ID);
   END IF;

    IF l_debug_level  > 0 THEN
     print_time('Calling MRP');
    END IF;

   MRP_ATP_PUB.Call_ATP (
                 p_session_id             =>  l_session_id
               , p_atp_rec                =>  in_atp_rec
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
     oe_debug_pub.add(  'AFTER CALL MRP_ATP_PUB.CALL_ATP STS='||X_RETURN_STATUS|| ' MSG COUNT='||X_MSG_COUNT);

     IF x_atp_rec.available_quantity.COUNT > 0 AND
        x_atp_rec.source_organization_id.COUNT > 0 then
     oe_debug_pub.add( ' MSG DATA='||X_MSG_DATA|| 'AVL QTY='|| X_ATP_REC.AVAILABLE_QUANTITY ( 1 ) ||
		       'SHIP_FROM_ORG_ID =' ||X_ATP_REC.SOURCE_ORGANIZATION_ID ( 1 ) ) ;
     END IF;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ERROR IS' || X_MSG_DATA , 1 ) ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   Check_Results_from_rec(
                       in_global_orgs =>in_global_orgs
                      ,p_atp_rec       => x_atp_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count  =>x_msg_count
                      ,x_msg_data =>x_msg_data
                      ,x_error_message  =>x_error_message
                         );

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'STATUS='||X_RETURN_STATUS|| ' X_ERROR_MESSAGE ='
			||X_ERROR_MESSAGE|| ' MSG DATA='||X_MSG_DATA ) ;
   END IF;

/* Commented the following code to fix fp bug 3498932 */
/*

   IF nvl(x_return_status,'E') <> 'P' then

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN_STATUS<>P' ) ;
     END IF;

     IF nvl(x_return_status,'E') <> 'E' THEN
       IF  nvl(x_atp_rec.available_quantity(1),0) = 0 then

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AVAILABLE QUANTITY IS 0' ) ;
         END IF;
         out_available_date   := null;
         out_available_qty    := 0;

       ELSE
         IF x_atp_rec.available_quantity.COUNT > 0 THEN
           out_available_qty    := x_atp_rec.available_quantity(1);
         END IF;
         IF x_atp_rec.ship_date.COUNT > 0 THEN
           out_available_date    := x_atp_rec.ship_date(1);
         END IF;
         IF x_atp_rec.group_ship_date.COUNT > 0 THEN
           IF x_atp_rec.group_ship_date(1) is not null THEN
             out_available_date  := x_atp_rec.group_ship_date(1);
           END IF;
         END IF;

       END IF;
     ELSE
       out_available_date   := null;
       out_available_qty    := 0;

     END IF; -- if status is not E

   ELSE -- if status is P

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN_STATUS=P MESG='||X_ERROR_MESSAGE ) ;
     END IF;
     out_available_qty    := x_error_message;
     out_available_date   := null;
     x_error_message := null;

   END IF; -- if return status is not P
 */
/* End of code commented to fix the bug 3498932 */
 /* Added the following code to fix the bug 3498932 */

         IF x_atp_rec.available_quantity.COUNT > 0 THEN
           out_available_qty    := x_atp_rec.available_quantity(1);
         END IF;
         IF x_atp_rec.ship_date.COUNT > 0 THEN
           out_available_date    := x_atp_rec.ship_date(1);
         END IF;
         IF x_atp_rec.group_ship_date.COUNT > 0 THEN
           IF x_atp_rec.group_ship_date(1) is not null THEN
             out_available_date  := x_atp_rec.group_ship_date(1);
           END IF;
         END IF;
         IF x_atp_rec.error_code(1) = 53 then
           out_available_qty    := x_atp_rec.requested_date_quantity(1);
         END IF;

/* End of new code added to fix the bug 3498932 */

   IF x_atp_rec.source_organization_id.COUNT > 0 THEN
     out_ship_from_org_id := x_atp_rec.source_organization_id(1);
   END IF;
   IF x_atp_rec.quantity_uom.COUNT > 0 THEN
     out_qty_uom          := x_atp_rec.quantity_uom(1);
   END IF;


   IF l_debug_level  > 0 THEN
     oe_debug_pub.add( 'OUT_AVAL_QTY='||OUT_AVAILABLE_QTY|| ' SHIP_FORM_ORG_ID='||
		       OUT_SHIP_FROM_ORG_ID|| ' UOM='||OUT_QTY_UOM);


     IF x_atp_rec.ship_date.COUNT > 0 THEN
       oe_debug_pub.add(' OUT SHIP DATE='||X_ATP_REC.SHIP_DATE(1));
     END IF;

     IF x_atp_rec.group_ship_date.COUNT > 0 THEN
        oe_debug_pub.add(' OUT GRP SHIP DATE='||X_ATP_REC.GROUP_SHIP_DATE(1));
     END IF;

     IF x_atp_rec.arrival_date.COUNT > 0 THEN
      oe_debug_pub.add(' OUT ARRIVAL DATE='||X_ATP_REC.ARRIVAL_DATE(1));
     END IF;

     IF x_atp_rec.requested_date_quantity.COUNT > 0 THEN
        oe_debug_pub.add('REQ DATE QTY='||X_ATP_REC.REQUESTED_DATE_QUANTITY(1));
     END IF;
     IF x_atp_rec.available_quantity.COUNT > 0 THEN
        oe_debug_pub.add(' AVAILABLE QTY='||X_ATP_REC.AVAILABLE_QUANTITY(1));
     END IF;

   END IF; -- if debug is on


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



PROCEDURE defaulting(
            in_source in varchar2
            ,in_org_id in varchar2
            ,in_item_id in number
            ,in_customer_id in number
            ,in_ship_to_org_id in number
            ,in_bill_to_org_id in number
            ,in_agreement_id in number
            ,in_order_type_id in number
            ,out_wsh_id out nocopy number
            ,out_uom out nocopy varchar2
            ,out_item_type_code  out nocopy varchar2
            ,out_price_list_id out nocopy number
            ,out_conversion_type out nocopy varchar2

                     ) IS

x_msg_count number;
tmp_var varchar2(2000);
tmp_var1 varchar2(2000);
x_msg_data varchar2(2000);
x_return_status varchar2(2000);

l_old_rec oe_ak_order_lines_v%ROWTYPE;
l_rec     oe_ak_order_lines_v%ROWTYPE;
l_out_rec oe_ak_order_lines_v%ROWTYPE;
l_old_header_rec OE_AK_ORDER_HEADERS_V%ROWTYPE;
l_record         OE_AK_ORDER_HEADERS_V%ROWTYPE;
l_out_record         OE_AK_ORDER_HEADERS_V%ROWTYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_bom_item_type Varchar2(1);
l_pick_components_flag Varchar2(1);
BEGIN


                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ENTERING OE_AVAILABILITY.DEFAULTING '|| ' ITEM_ID='||
					 IN_ITEM_ID|| ' SOURCE TYPE ='||IN_SOURCE|| ' ORG ID TYPE ='||IN_ORG_ID);
                     oe_debug_pub.add( ' CUSTOMER_ID ='||IN_CUSTOMER_ID|| ' SHIP_TO_ORG_ID ='||
				       IN_SHIP_TO_ORG_ID|| ' IN_BILL_TO_ORG_ID ='||IN_BILL_TO_ORG_ID
				       || ' IN_AGREEMENT_ID ='||IN_AGREEMENT_ID|| ' IN_ORDER_TYPE_ID ='
				       ||IN_ORDER_TYPE_ID ) ;
                  END IF;



  IF in_source = 'ITEM' then

    l_rec.inventory_item_id     := in_item_id;
    l_rec.org_id                := in_org_id;
    l_rec.sold_to_org_id        := in_customer_id;
    l_rec.ship_to_org_id        := in_ship_to_org_id;
    l_rec.ship_from_org_id      := FND_API.G_MISS_NUM;
    l_rec.order_quantity_uom    := FND_API.G_MISS_CHAR;
    --l_rec.price_list_id       := FND_API.G_MISS_NUM;

    l_out_rec := l_rec;

    ONT_LINE_DEF_HDLR.Default_record(
                        p_x_rec => l_out_rec,
                        p_initial_rec =>l_rec,
                        p_in_old_rec  => l_old_rec
                                    );
    out_wsh_id           := l_out_rec.ship_from_org_id;
    out_uom              := l_out_rec.order_quantity_uom;
    out_price_list_id    := null;
    BEGIN
      SELECT BOM_ITEM_TYPE,PICK_COMPONENTS_FLAG
      INTO l_bom_item_type,l_pick_components_flag
      FROM MTL_SYSTEM_ITEMS
      WHERE INVENTORY_ITEM_ID= in_item_id
      AND ORGANIZATION_ID=in_org_id;
      IF l_bom_item_type=4 AND l_pick_components_flag='N' THEN
        out_item_type_code := 'STANDARD';
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Null;
    WHEN TOO_MANY_ROWS THEN
      Null;
    WHEN OTHERS THEN
      Null;
    END;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WSH_ID='||OUT_WSH_ID|| ' UOM='||OUT_UOM|| ' PRICE_LIST_ID='||
					    OUT_PRICE_LIST_ID ) ;
                     END IF;

  ELSIF in_source = 'CUSTOMER' then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOURCE = CUSTOMER' ) ;
    END IF;
    l_record.sold_to_org_id        := in_customer_id;
    l_record.org_id                := in_org_id;
    l_record.ship_to_org_id        := in_ship_to_org_id;
    l_record.agreement_id          := in_agreement_id;
    l_record.invoice_to_org_id     := in_bill_to_org_id;
    l_record.ship_from_org_id      := FND_API.G_MISS_NUM;
    l_record.price_list_id         := FND_API.G_MISS_NUM;

    l_out_record := l_record;

    ONT_HEADER_Def_Hdlr.Default_Record
         ( p_x_rec       => l_out_record
         , p_initial_rec => l_record
         , p_in_old_rec	 => l_old_header_rec
         , p_iteration	 => 1
         );

    out_wsh_id           := l_out_record.ship_from_org_id;
    out_price_list_id    := l_out_record.price_list_id;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WSH_ID='||OUT_WSH_ID|| ' UOM='||OUT_UOM|| ' PRICE_LIST_ID='
					    ||OUT_PRICE_LIST_ID ) ;
                     END IF;

  ELSIF in_source = 'SHIP_TO' then

    l_record.sold_to_org_id        := in_customer_id;
    l_record.org_id                := in_org_id;
    l_record.ship_to_org_id        := in_ship_to_org_id;
    l_record.agreement_id          := in_agreement_id;
    l_record.invoice_to_org_id     := in_bill_to_org_id;
    l_record.ship_from_org_id      := FND_API.G_MISS_NUM;
    l_record.price_list_id         := FND_API.G_MISS_NUM;

    l_out_record := l_record;

    ONT_HEADER_Def_Hdlr.Default_Record
         ( p_x_rec       => l_out_record
         , p_initial_rec => l_record
         , p_in_old_rec	 => l_old_header_rec
         , p_iteration	 => 1
         );

    out_wsh_id           := l_out_record.ship_from_org_id;
    out_price_list_id    := l_out_record.price_list_id;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WSH_ID='||OUT_WSH_ID|| ' UOM='||OUT_UOM||
					    ' PRICE_LIST_ID='||OUT_PRICE_LIST_ID ) ;
                     END IF;

  ELSIF in_source = 'BILL_TO' then

    l_record.sold_to_org_id        := in_customer_id;
    l_record.org_id                := in_org_id;
    l_record.ship_to_org_id        := in_ship_to_org_id;
    l_record.agreement_id          := in_agreement_id;
    l_record.invoice_to_org_id     := in_bill_to_org_id;
    l_record.price_list_id         := FND_API.G_MISS_NUM;

    l_out_record := l_record;

    ONT_HEADER_Def_Hdlr.Default_Record
         ( p_x_rec       => l_out_record
         , p_initial_rec => l_record
         , p_in_old_rec	 => l_old_header_rec
         , p_iteration	 => 1
         );

    out_wsh_id           := null;
    out_uom              := null;
    out_price_list_id    := l_out_record.price_list_id;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WSH_ID='||OUT_WSH_ID|| ' UOM='||OUT_UOM
					    || ' PRICE_LIST_ID='||OUT_PRICE_LIST_ID ) ;
                     END IF;

  ELSIF in_source = 'AGREEMENT' then

    l_rec.agreement_id          := in_agreement_id;
    l_rec.ship_to_org_id        := in_ship_to_org_id;
    l_rec.invoice_to_org_id     := in_bill_to_org_id;
    l_rec.sold_to_org_id        := in_customer_id;
    l_rec.org_id                := in_org_id;
    l_rec.price_list_id         := FND_API.G_MISS_NUM;

    l_out_rec := l_rec;

    ONT_LINE_DEF_HDLR.Default_record(
                        p_x_rec => l_out_rec,
                        p_initial_rec =>l_rec,
                        p_in_old_rec  => l_old_rec
                                    );
    out_wsh_id           := null;
    out_uom              := null;
    out_price_list_id    := l_out_rec.price_list_id;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WSH_ID='||OUT_WSH_ID|| ' UOM='||
					    OUT_UOM|| ' PRICE_LIST_ID='||OUT_PRICE_LIST_ID ) ;
                     END IF;

  ELSIF in_source = 'ORDER_TYPE' then

    l_record.org_id                := in_org_id;
    l_record.order_type_id         := in_order_type_id;
    l_record.conversion_type_code  := FND_API.G_MISS_CHAR;

    l_out_record := l_record;


    ONT_HEADER_Def_Hdlr.Default_Record
         ( p_x_rec       => l_out_record
         , p_initial_rec => l_record
         , p_in_old_rec	 => l_old_header_rec
         , p_iteration	 => 1
         );

    out_conversion_type  := l_out_record.conversion_type_code;
    out_uom              := null;
    out_price_list_id    := null;
    out_wsh_id           := null;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WSH_ID='||OUT_WSH_ID|| ' UOM='||OUT_UOM
					    || ' CONVERSION_TYPE_CODE='||OUT_CONVERSION_TYPE ) ;
                     END IF;

  ELSIF in_source = 'STARTUP' then

    l_record.org_id                := in_org_id;

    l_record.conversion_type_code  := FND_API.G_MISS_CHAR;
    l_record.price_list_id         := FND_API.G_MISS_NUM;
    l_record.ship_from_org_id      := FND_API.G_MISS_NUM;

    l_out_record := l_record;

    ONT_HEADER_Def_Hdlr.Default_Record
         ( p_x_rec       => l_out_record
         , p_initial_rec => l_record
         , p_in_old_rec	 => l_old_header_rec
         , p_iteration	 => 1
         );

    out_wsh_id           := l_out_rec.ship_from_org_id;
    out_uom              := l_out_rec.order_quantity_uom;
    out_price_list_id    := l_out_record.price_list_id;
    out_conversion_type  := l_out_record.conversion_type_code;

  END IF; -- in source_type

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_AVAILABILITY.DEFAULTING' ) ;
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


Procedure Check_Results_from_rec (
        in_global_orgs in varchar2
       ,p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

,x_error_message OUT NOCOPY varchar2

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
  IF l_debug_level  > 0 AND
    p_atp_rec.error_code.COUNT > 0 THEN
    oe_debug_pub.add(  '2. ENTERING CHECK_RESULTS ERROR_CODE='|| P_ATP_REC.ERROR_CODE ( J ) ||
		       ' IN_GLOBAL_ORGS='||IN_GLOBAL_ORGS ) ;
  END IF;

  IF p_atp_rec.error_code.COUNT > 0 AND
     p_atp_rec.error_code(J) <> 0 AND
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
          IF in_global_orgs = 'N' then

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

         /* Added the following code to fix the bug 3498932 */

          ELSIF p_atp_rec.error_code(J) = 53 THEN

            x_return_status := 'E';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ERROR CODE = 53' ) ;
            END IF;

            FND_MESSAGE.SET_NAME('ONT','ONT_PRC_AVA_NO_REQUESTED_QTY');
            FND_MESSAGE.SET_TOKEN('PARTIAL_QUANTITY', p_atp_rec.requested_date_quantity(J));
            FND_MESSAGE.SET_TOKEN('REQUEST_DATE', p_atp_rec.requested_ship_date(J));
            FND_MESSAGE.SET_TOKEN('EARLIEST_DATE', p_atp_rec.ship_date(J));

            IF in_global_orgs = 'N' then
                OE_MSG_PUB.Add;
            ELSE
                x_error_message := fnd_message.get;
            END IF;

/* End of code added to fix the bug 3498932 */


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

              IF in_global_orgs = 'N' then
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
                          oe_debug_pub.add(  ' ELSE '||P_ATP_REC.SOURCE_ORGANIZATION_ID ( 1 ) ||
					     ' ERROR CODE : ' || P_ATP_REC.ERROR_CODE ( J ) ) ;
                      END IF;

      -- Muti org changes.
      IF (p_atp_rec.error_code(J) <> -99 ) THEN

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'ERROR CODE : ' || P_ATP_REC.ERROR_CODE ( J ) || 'IDENTIFIER : ' ||
					       P_ATP_REC.IDENTIFIER ( J ) || 'ITEM : ' ||
					       P_ATP_REC.INVENTORY_ITEM_ID ( J ));
                            oe_debug_pub.add( 'REQUEST SHIP DATE :' ||
					      TO_CHAR ( P_ATP_REC.REQUESTED_SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' )
					      || 'REQUEST ARRIVAL DATE :' || P_ATP_REC.REQUESTED_ARRIVAL_DATE ( J ));
                            oe_debug_pub.add( 'ARRIVAL DATE :' ||
					      TO_CHAR ( P_ATP_REC.ARRIVAL_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) ||
					      'SHIP DATE :' ||
					      TO_CHAR ( P_ATP_REC.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ));
                           oe_debug_pub.add( 'LEAD TIME :' ||P_ATP_REC.DELIVERY_LEAD_TIME ( J ) ||
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

  IF x_return_status ='E'  and in_global_orgs = 'N' then
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

  /*p_x_atp_rec.Inventory_Item_Id.extend(l_count);
  p_x_atp_rec.Source_Organization_Id.extend(l_count);
  p_x_atp_rec.Identifier.extend(l_count);
  p_x_atp_rec.Order_Number.extend(l_count);
  p_x_atp_rec.Calling_Module.extend(l_count);
  p_x_atp_rec.Customer_Id.extend(l_count);
  p_x_atp_rec.Customer_Site_Id.extend(l_count);
  p_x_atp_rec.Destination_Time_Zone.extend(l_count);
  p_x_atp_rec.Quantity_Ordered.extend(l_count);
  p_x_atp_rec.Quantity_UOM.extend(l_count);
  p_x_atp_rec.Requested_Ship_Date.extend(l_count);
  p_x_atp_rec.Requested_Arrival_Date.extend(l_count);
  p_x_atp_rec.Earliest_Acceptable_Date.extend(l_count);
  p_x_atp_rec.Latest_Acceptable_Date.extend(l_count);
  p_x_atp_rec.Delivery_Lead_Time.extend(l_count);
  p_x_atp_rec.Atp_Lead_Time.extend(l_count);
  p_x_atp_rec.Freight_Carrier.extend(l_count);
  p_x_atp_rec.Ship_Method.extend(l_count);
  p_x_atp_rec.Demand_Class.extend(l_count);
  p_x_atp_rec.Ship_Set_Name.extend(l_count);
  p_x_atp_rec.Arrival_Set_Name.extend(l_count);
  p_x_atp_rec.Override_Flag.extend(l_count);
  p_x_atp_rec.Action.extend(l_count);
  p_x_atp_rec.ship_date.extend(l_count);
  p_x_atp_rec.Available_Quantity.extend(l_count);
  p_x_atp_rec.Requested_Date_Quantity.extend(l_count);
  p_x_atp_rec.Group_Ship_Date.extend(l_count);
  p_x_atp_rec.Group_Arrival_Date.extend(l_count);
  p_x_atp_rec.Vendor_Id.extend(l_count);
  p_x_atp_rec.Vendor_Site_Id.extend(l_count);
  p_x_atp_rec.Insert_Flag.extend(l_count);
  p_x_atp_rec.Error_Code.extend(l_count);
  p_x_atp_rec.Message.extend(l_count);
  p_x_atp_rec.Old_Source_Organization_Id.extend(l_count);
  p_x_atp_rec.Old_Demand_Class.extend(l_count);
  p_x_atp_rec.oe_flag.extend(l_count);
  p_x_atp_rec.ato_delete_flag.extend(l_count);
  p_x_atp_rec.attribute_01.extend(l_count);
  p_x_atp_rec.attribute_05.extend(l_count);*/


EXCEPTION

   WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Initialize_mrp_record');
       END IF;

END Initialize_mrp_record;



Procedure Query_Qty_Tree(p_org_id            IN NUMBER,
                         p_item_id           IN NUMBER,
                         p_sch_date          IN DATE DEFAULT NULL,
x_on_hand_qty OUT NOCOPY NUMBER,

x_avail_to_reserve OUT NOCOPY NUMBER

                         ) IS

l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
l_qoh                     NUMBER;
l_rqoh                    NUMBER;
l_qr                      NUMBER;
l_qs                      NUMBER;
l_att                     NUMBER;
l_atr                     NUMBER;
l_msg_index               NUMBER;
l_lot_control_flag        BOOLEAN;
l_lot_control_code        NUMBER;
l_org_id                  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'ENTERING QUERY_QTY_TREE'|| 'ORG IS : ' || P_ORG_ID
					  || 'ITEM IS : ' || P_ITEM_ID ) ;
                   END IF;

  BEGIN
    IF p_org_id is null THEN
       l_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
    END IF;

    SELECT msi.lot_control_code
    INTO   l_lot_control_code
    FROM   mtl_system_items msi
    WHERE  msi.inventory_item_id = p_item_id
    AND    msi.organization_id   = nvl(p_org_id,l_org_id);

    IF l_lot_control_code = 2 THEN
       l_lot_control_flag := TRUE;
    ELSE
       l_lot_control_flag := FALSE;
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
   l_lot_control_flag := FALSE;
  END;

  inv_quantity_tree_pub.query_quantities
    (  p_api_version_number      => 1.0
     , x_return_status           => l_return_status
     , x_msg_count               => l_msg_count
     , x_msg_data                => l_msg_data
     , p_organization_id         => p_org_id
     , p_inventory_item_id       => p_item_id
     , p_tree_mode               => 2
     , p_is_revision_control     => false
     , p_is_lot_control          => l_lot_control_flag
     , p_lot_expiration_date     => nvl(p_sch_date,sysdate)
     , p_is_serial_control       => false
     , p_revision                => null
     , p_lot_number              => null
     , p_subinventory_code       => null
     , p_locator_id              => null
     , x_qoh                     => l_qoh
     , x_rqoh                    => l_rqoh
     , x_qr                      => l_qr
     , x_qs                      => l_qs
     , x_att                     => l_att
     , x_atr                     => l_atr
     );

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'RR: L_QOH ' || L_QOH|| 'RR: L_QOH ' || L_ATR ) ;
                   END IF;

  x_on_hand_qty      := l_qoh;
  x_avail_to_reserve := l_atr;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING QUERY_QTY_TREE ' , 1 ) ;
  END IF;

END Query_Qty_Tree;



PROCEDURE get_ship_from_org(in_org_id in number,
out_code out nocopy varchar2,

out_name out nocopy varchar2

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
      oe_debug_pub.add(  'ENTERING OE_AVAILABILITY.COPY_HEADER_TO_REQUEST' , 1 ) ;
   END IF;

   l_line_index := l_line_index+1;
   px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE :=p_Request_Type_Code;
   px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
   px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'ORDER';
   -- Hold the header_id in line_id for 'HEADER' Records

   px_req_line_tbl(l_line_index).line_id := g_line_id;

   if g_panda_rec_table(1).p_pricing_date is null or g_panda_rec_table(1).p_pricing_date = fnd_api.g_miss_date then
      px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
   Else
      px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := g_panda_rec_table(1).p_pricing_date;
   End If;

   px_req_line_tbl(l_line_index).CURRENCY_CODE := g_panda_rec_table(1).p_currency;
   px_req_line_tbl(l_line_index).PRICE_FLAG := p_calculate_price_flag;
   px_req_line_tbl(l_line_index).Active_date_first_type := 'ORD';
   px_req_line_tbl(l_line_index).Active_date_first := g_panda_rec_table(1).p_request_date;


   --If G_ROUNDING_FLAG = 'Y' Then
   IF g_panda_rec_table(1).p_price_list_id is not null then
      px_req_line_tbl(l_line_index).Rounding_factor := Get_Rounding_factor(g_panda_rec_table(1).p_price_list_id);
   END IF;
   --End If;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CURR='||G_panda_rec_table(1).p_CURRENCY||' REQ DATE='||
			 G_panda_rec_table(1).p_REQUEST_DATE||' ROUNDING_FACTOR='||
			 PX_REQ_LINE_TBL ( L_LINE_INDEX ) .ROUNDING_FACTOR ) ;
   END IF;

   --px_req_line_tbl(l_line_index).price_request_code := p_header_rec.price_request_code; -- PROMOTIONS SEP/01
   --populating temp tables
    G_LINE_INDEX_TBL.delete;
   if l_debug_level > 0 then
      oe_debug_pub.add('********** POPULATING HEADER RECORD INTO TEMP TABLE *********************');
      --oe_debug_pub.add('line index is='||G_LINE_INDEX_TBL(l_line_index));
   end if;
   G_LINE_INDEX_TBL(l_line_index)             :=  px_req_line_tbl(l_line_index).LINE_INDEX;
   G_LINE_TYPE_CODE_TBL(l_line_index)         :=  px_req_line_tbl(l_line_index).LINE_TYPE_CODE;
   G_PRICING_EFFECTIVE_DATE_TBL(l_line_index) :=  TRUNC(px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE);
   G_ACTIVE_DATE_FIRST_TBL(l_line_index)      :=  TRUNC(px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST);
   G_ACTIVE_DATE_FIRST_TYPE_TBL(l_line_index) :=  px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST_TYPE;
   G_ACTIVE_DATE_SECOND_TBL(l_line_index)     :=  TRUNC(px_req_line_tbl(l_line_index).ACTIVE_DATE_SECOND);
   G_ACTIVE_DATE_SECOND_TYPE_TBL(l_line_index):= px_req_line_tbl(l_line_index).ACTIVE_DATE_SECOND_TYPE;
   G_LINE_QUANTITY_TBL(l_line_index)          := px_req_line_tbl(l_line_index).LINE_QUANTITY;
   G_LINE_UOM_CODE_TBL(l_line_index)          := px_req_line_tbl(l_line_index).LINE_UOM_CODE;
   G_REQUEST_TYPE_CODE_TBL(l_line_index)      := px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE;
   G_PRICED_QUANTITY_TBL(l_line_index)        := px_req_line_tbl(l_line_index).PRICED_QUANTITY;
   G_UOM_QUANTITY_TBL(l_line_index)           := px_req_line_tbl(l_line_index).UOM_QUANTITY;
   G_PRICED_UOM_CODE_TBL(l_line_index)        := px_req_line_tbl(l_line_index).PRICED_UOM_CODE;
   G_CURRENCY_CODE_TBL(l_line_index)          := px_req_line_tbl(l_line_index).CURRENCY_CODE;
   G_UNIT_PRICE_TBL(l_line_index)             := px_req_line_tbl(l_line_index).unit_price;  -- AG
   G_PERCENT_PRICE_TBL(l_line_index)          := px_req_line_tbl(l_line_index).PERCENT_PRICE;
   G_ADJUSTED_UNIT_PRICE_TBL(l_line_index)    := px_req_line_tbl(l_line_index).ADJUSTED_UNIT_PRICE;
   G_PROCESSED_FLAG_TBL(l_line_index)         := QP_PREQ_GRP.G_NOT_PROCESSED;
   G_PRICE_FLAG_TBL(l_line_index)             := px_req_line_tbl(l_line_index).PRICE_FLAG;
   G_LINE_ID_TBL(l_line_index)                := px_req_line_tbl(l_line_index).LINE_ID;
   if l_debug_level >0 then
      oe_debug_pub.add('the order line id'||G_LINE_ID_TBL(l_line_index));
   end if;
   G_ROUNDING_FLAG_TBL(l_line_index)          := NULL;
   G_ROUNDING_FACTOR_TBL(l_line_index)        := px_req_line_tbl(l_line_index).ROUNDING_FACTOR;
   G_PROCESSING_ORDER_TBL(l_line_index)       := NULL;
   G_PRICING_STATUS_CODE_tbl(l_line_index)    := QP_PREQ_GRP.G_STATUS_UNCHANGED;
   G_PRICING_STATUS_TEXT_tbl(l_line_index)    := NULL;

   G_QUALIFIERS_EXIST_FLAG_TBL(l_line_index)            :='N';
   G_PRICING_ATTRS_EXIST_FLAG_TBL(l_line_index)       :='N';
   G_PRICE_LIST_ID_TBL(l_line_index)                 :=g_panda_rec_table(1).p_price_list_id;
   G_PL_VALIDATED_FLAG_TBL(l_line_index)                := 'N';
   G_PRICE_REQUEST_CODE_TBL(l_line_index)        := NULL;
   G_USAGE_PRICING_TYPE_TBL(l_line_index)        :='REGULAR';
   G_UPD_ADJUSTED_UNIT_PRICE_TBL(l_line_index) :=NULL;
   G_LINE_CATEGORY_TBL(l_line_index)           :=NULL;
   G_CATCHWEIGHT_QTY_TBL(l_line_index)         := NULL;
   G_ACTUAL_ORDER_QTY_TBL(l_line_index)        :=NULL;

   --Temp Table population done

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_OE_AVAILABILITY.COPY_HEADER_TO_REQUEST' ) ;
   END IF;

END copy_Header_to_request;


PROCEDURE copy_Line_to_request(
			       px_req_line_tbl   in out nocopy QP_PREQ_GRP.LINE_TBL_TYPE
			       ,p_pricing_event   in    varchar2
			       ,p_Request_Type_Code in	varchar2
			       ,p_honor_price_flag in VARCHAR2 Default 'Y'
			       ,p_line_index in number
			       ) IS

   l_line_index	pls_integer := nvl(px_req_line_tbl.count,0);
   l_uom_rate      NUMBER;
   v_discounting_privilege VARCHAR2(30);
   l_item_type_code VARCHAR2(30);

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
begin

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_ORDER_ADJ_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
   END IF;

   l_line_index := l_line_index+1;
   px_req_line_tbl(l_line_index).Line_id := g_line_id;
   px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := p_Request_Type_Code;
   px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
   px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'LINE';

   IF g_panda_rec_table(p_line_index).p_pricing_date is null or
      g_panda_rec_table(p_line_index).p_pricing_date = fnd_api.g_miss_date then
      px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
   ELSE
      px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := g_panda_rec_table(p_line_index).p_pricing_date;
   END IF;

   px_req_line_tbl(l_line_index).LINE_QUANTITY := g_panda_rec_table(p_line_index).p_qty ;
   px_req_line_tbl(l_line_index).LINE_UOM_CODE := g_panda_rec_table(p_line_index).p_uom;
   px_req_line_tbl(l_line_index).PRICED_QUANTITY := g_panda_rec_table(p_line_index).p_qty;
   px_req_line_tbl(l_line_index).PRICED_UOM_CODE := g_panda_rec_table(p_line_index).p_uom;
   px_req_line_tbl(l_line_index).CURRENCY_CODE :=g_panda_rec_table(p_line_index).p_currency;
   px_req_line_tbl(l_line_index).UNIT_PRICE := Null;
   --px_req_line_tbl(l_line_index).PERCENT_PRICE := p_Line_rec.unit_list_percent;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QTY='||G_panda_rec_table(p_line_index).p_QTY||' UOM ='||
			 G_panda_rec_table(p_line_index).p_UOM||' CURR='||G_panda_rec_table(p_line_index).p_CURRENCY ) ;
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
      Get_Rounding_factor(g_panda_rec_table(p_line_index).p_price_list_id);
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
  px_req_line_tbl(l_line_index).Active_date_first := g_panda_rec_table(p_line_index).p_request_date;

  IF g_panda_rec_table(p_line_index).p_request_date is not null then
    px_req_line_tbl(l_line_index).Active_date_Second_type := 'SHIP';
    px_req_line_tbl(l_line_index).Active_date_Second := g_panda_rec_table(p_line_index).p_request_date;
  End If;

  --px_req_line_tbl(l_line_index).price_request_code := p_line_rec.price_request_code; -- PROMOTIONS  SEP/01
  --px_req_line_tbl(l_line_index).line_category :=p_line_rec.line_category_code;

   oe_debug_pub.add('********Temp tables population for lines **************');
   oe_debug_pub.add('LINE INDEX'||l_line_index);

   G_LINE_INDEX_TBL(l_line_index)            :=  px_req_line_tbl(l_line_index).LINE_INDEX;
   G_LINE_TYPE_CODE_TBL(l_line_index)        :=  px_req_line_tbl(l_line_index).LINE_TYPE_CODE;
   G_PRICING_EFFECTIVE_DATE_TBL(l_line_index):=  TRUNC(px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE);
   G_ACTIVE_DATE_FIRST_TBL(l_line_index)     :=  TRUNC(px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST);
   G_ACTIVE_DATE_FIRST_TYPE_TBL(l_line_index):=  px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST_TYPE;
   G_ACTIVE_DATE_SECOND_TBL(l_line_index)    :=  TRUNC(px_req_line_tbl(l_line_index).ACTIVE_DATE_SECOND);
   G_ACTIVE_DATE_SECOND_TYPE_TBL(l_line_index):= px_req_line_tbl(l_line_index).ACTIVE_DATE_SECOND_TYPE;
  --px_req_line_tbl(l_line_index).priced_quantity := NULL;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'QUANTITY'||PX_REQ_LINE_TBL(L_LINE_INDEX).LINE_QUANTITY||' '||
			  PX_REQ_LINE_TBL(L_LINE_INDEX).PRICED_QUANTITY , 3 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRICE FLAG'||PX_REQ_LINE_TBL(L_LINE_INDEX).PRICE_FLAG ) ;
   END IF;
   G_LINE_QUANTITY_TBL(l_line_index)          := px_req_line_tbl(l_line_index).LINE_QUANTITY;

   G_LINE_UOM_CODE_TBL(l_line_index)          := px_req_line_tbl(l_line_index).LINE_UOM_CODE;
   G_REQUEST_TYPE_CODE_TBL(l_line_index)      := px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE;
   G_PRICED_QUANTITY_TBL(l_line_index)        := px_req_line_tbl(l_line_index).PRICED_QUANTITY;
   G_UOM_QUANTITY_TBL(l_line_index)           := NULL;
   G_PRICED_UOM_CODE_TBL(l_line_index)        := px_req_line_tbl(l_line_index).PRICED_UOM_CODE;
   G_CURRENCY_CODE_TBL(l_line_index)          := px_req_line_tbl(l_line_index).CURRENCY_CODE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNIT PRICE'||PX_REQ_LINE_TBL(L_LINE_INDEX).UNIT_PRICE||' '||
			   PX_REQ_LINE_TBL(L_LINE_INDEX).ADJUSTED_UNIT_PRICE ) ;
    END IF;
   G_UNIT_PRICE_TBL(l_line_index)             := px_req_line_tbl(l_line_index).unit_price;  -- AG
   G_PERCENT_PRICE_TBL(l_line_index)          := NULL;
   G_ADJUSTED_UNIT_PRICE_TBL(l_line_index)    := px_req_line_tbl(l_line_index).ADJUSTED_UNIT_PRICE;
   G_PROCESSED_FLAG_TBL(l_line_index)         := QP_PREQ_GRP.G_NOT_PROCESSED;
   G_PRICE_FLAG_TBL(l_line_index)             := px_req_line_tbl(l_line_index).PRICE_FLAG;
   G_LINE_ID_TBL(l_line_index)                := px_req_line_tbl(l_line_index).LINE_ID;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE ID IN G_LINE_ID_TBL:'|| G_LINE_ID_TBL ( L_LINE_INDEX ) ) ;
   END IF;
   G_ROUNDING_FLAG_TBL(l_line_index)          := NULL;  -- AG
   G_ROUNDING_FACTOR_TBL(l_line_index)        := px_req_line_tbl(l_line_index).ROUNDING_FACTOR;
   G_PROCESSING_ORDER_TBL(l_line_index)       := NULL;
   G_PRICING_STATUS_CODE_tbl(l_line_index)    := QP_PREQ_GRP.G_STATUS_UNCHANGED;  -- AG
   G_PRICING_STATUS_TEXT_tbl(l_line_index)    := NULL;
   G_QUALIFIERS_EXIST_FLAG_TBL(l_line_index)            :='N';
   G_PRICING_ATTRS_EXIST_FLAG_TBL(l_line_index)       :='N';
   G_PRICE_LIST_ID_TBL(l_line_index)                 :=g_panda_rec_table(1).p_price_list_id;
   G_PL_VALIDATED_FLAG_TBL(l_line_index)                := 'N';
   G_PRICE_REQUEST_CODE_TBL(l_line_index)        := NULL;
   G_USAGE_PRICING_TYPE_TBL(l_line_index)        :='REGULAR';
   G_UPD_ADJUSTED_UNIT_PRICE_TBL(l_line_index) :=NULL;
   G_LINE_CATEGORY_TBL(l_line_index) := NULL;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_OE_AVAILABILITY.COPY_LINE_TO_REQUEST' , 1 ) ;
  END IF;

END copy_Line_to_request;



PROCEDURE set_pricing_control_record (
				      l_Control_Rec  in out nocopy  QP_PREQ_GRP.CONTROL_RECORD_TYPE
				      ,in_pricing_event in varchar2)IS

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

   l_control_rec.pricing_event    := in_pricing_event;
   l_Control_Rec.calculate_flag   := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
   --l_control_rec.simulation_flag  := 'Y';
   l_control_rec.simulation_flag :='Y';
   l_control_rec.gsa_check_flag := 'Y';
   l_control_rec.gsa_dup_check_flag := 'Y';
   --newly added
   l_control_rec.temp_table_insert_flag := 'N';
   l_control_rec.request_type_code := 'ONT';
   l_control_rec.rounding_flag := 'Q';
   l_control_rec.use_multi_currency:='Y';

END set_pricing_control_record;



PROCEDURE build_context_for_line(
        p_req_line_tbl_count in number,
        p_price_request_code in varchar2,
        p_item_type_code in varchar2,
        p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
        p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE,
	p_line_index in number
       )IS

qp_attr_mapping_error exception;
--l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_org_id Number := to_number( fnd_profile.value('ORG_ID'));
l_master_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
p_pricing_contexts_Tbl	  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_pass_line VARCHAR2(1) :='N';
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS FOR LINE' , 1 ) ;
  END IF;

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ORG_ID='||L_ORG_ID|| ' PRICING_DATE='||
					 G_panda_rec_table(p_line_index).p_PRICING_DATE|| ' INV ITEM_IE='
                                        ||' master_org='||l_master_org_id
					 ||G_panda_rec_table(p_line_index).p_INVENTORY_ITEM_ID);
                      oe_debug_pub.add( ' AGREEMENT_ID='||G_panda_rec_table(p_line_index).p_AGREEMENT_ID||
					' REQ DATE='||G_panda_rec_table(p_line_index).p_REQUEST_DATE||
					' SHIP_TO_ORG_ID='||G_panda_rec_table(p_line_index).p_SHIP_TO_ORG_ID||
					' INVOICE_TO_ORG_ID='||G_panda_rec_table(p_line_index).p_INVOICE_TO_ORG_ID ) ;
                  END IF;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'QTY='||G_panda_rec_table(p_line_index).p_QTY||
					' ITEM_TYPE_CODE='||P_ITEM_TYPE_CODE||
					' PRICE_LIST_ID='||G_panda_rec_table(p_line_index).p_PRICE_LIST_ID||
					' CUST_ID='||G_panda_rec_table(p_line_index).p_CUSTOMER_ID||
					' PRICE REQ CODE='||P_PRICE_REQUEST_CODE||
					' UOM='||G_panda_rec_table(p_line_index).p_UOM ) ;
                 END IF;

  oe_order_pub.g_line.org_id             := l_org_id;
  oe_order_pub.g_line.pricing_date       := g_panda_rec_table(p_line_index).p_pricing_date;
  oe_order_pub.g_line.inventory_item_id  := g_panda_rec_table(p_line_index).p_inventory_item_id;
  oe_order_pub.g_line.agreement_id       := g_panda_rec_table(p_line_index).p_agreement_id;
  --oe_order_pub.g_line.ordered_date     := g_request_date;
  oe_order_pub.g_line.ship_to_org_id     := g_panda_rec_table(p_line_index).p_ship_to_org_id;
  oe_order_pub.g_line.invoice_to_org_id  := g_panda_rec_table(p_line_index).p_invoice_to_org_id;
  oe_order_pub.g_line.ordered_quantity   := g_panda_rec_table(p_line_index).p_qty;
  oe_order_pub.g_line.item_identifier_type := g_panda_rec_table(p_line_index).p_item_identifier_type; -- 3661905
  oe_order_pub.g_line.ordered_item_id    := g_panda_rec_table(p_line_index).p_ordered_item_id; -- 3661905
  oe_order_pub.g_line.line_id            := g_line_id;
  oe_order_pub.g_line.header_id          := g_header_id;
  oe_order_pub.g_line.item_type_code     := p_item_type_code;
  oe_order_pub.g_line.price_list_id      := g_panda_rec_table(p_line_index).p_price_list_id;
  oe_order_pub.g_line.sold_to_org_id     := g_panda_rec_table(p_line_index).p_customer_id;
  oe_order_pub.g_line.price_request_code := p_price_request_code;
  oe_order_pub.g_line.order_quantity_uom := g_panda_rec_table(p_line_index).p_uom;

--Bug 6697648/6759791 --copy header level attribute, Index should be 1(for header) and NOT p_line_index
  oe_order_pub.g_hdr.order_type_id      := g_panda_rec_table(1).p_order_type_id;

  IF g_panda_rec_table(p_line_index).p_item_identifier_type ='INT' then

     SELECT concatenated_segments
       INTO  oe_order_pub.g_line.ordered_item
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = g_panda_rec_table(p_line_index).p_inventory_item_id
       AND    organization_id = l_master_org_id;

  End IF;

  QP_Attr_Mapping_PUB.Build_Contexts(
     p_request_type_code => 'ONT',
     p_line_index =>2,
     p_pricing_type_code =>'L',
     p_check_line_flag => 'N',
     p_pricing_event =>'BATCH',
     x_pass_line =>l_pass_line);

				--     x_price_contexts_result_tbl => p_pricing_contexts_Tbl,
--     x_qual_contexts_result_tbl  => p_qualifier_Contexts_Tbl
  --   );

  /*copy_attribs_to_Req(
     p_line_index         => 	p_req_line_tbl_count
     ,px_Req_line_attr_tbl    =>p_Req_line_attr_tbl
     ,px_Req_qual_tbl         =>p_Req_qual_tbl
     ,p_pricing_contexts_tbl => p_pricing_contexts_Tbl
     ,p_qualifier_contexts_tbl  => p_qualifier_Contexts_Tbl
     );*/
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('l_PASS_LINE'||l_pass_line);
     END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS FOR LINE' , 1 ) ;
  END IF;

EXCEPTION
    when no_data_found then
      Null;
    when others then
      Raise QP_ATTR_MAPPING_ERROR;

END build_context_for_line;



PROCEDURE build_context_for_header(
        p_req_line_tbl_count in number,
        p_price_request_code in varchar2,
        p_item_type_code in varchar2,
        p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
        p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
       )IS

qp_attr_mapping_error exception;
--l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_org_id Number := to_number( fnd_profile.value('ORG_ID'));
p_pricing_contexts_Tbl	  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS FOR HEADER' , 1 ) ;
  END IF;


                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ORG_ID='||L_ORG_ID|| ' PRICING_DATE='||
					 G_panda_rec_table(1).p_PRICING_DATE|| ' AGREEMENT_ID='||
					 G_panda_rec_table(1).p_AGREEMENT_ID|| ' REQ DATE='||
					 G_panda_rec_table(1).p_REQUEST_DATE|| ' SHIP_TO_ORG_ID='||
					 G_panda_rec_table(1).p_SHIP_TO_ORG_ID|| ' INVOICE_TO_ORG_ID='||
					 G_panda_rec_table(1).p_INVOICE_TO_ORG_ID ) ;
                  END IF;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'QTY='||G_panda_rec_table(1).p_QTY||
					' PRICE_LIST_ID='||G_panda_rec_table(1).p_PRICE_LIST_ID||
					' CUST_ID='||G_panda_rec_table(1).p_CUSTOMER_ID|| ' PRICE REQ CODE='||
					P_PRICE_REQUEST_CODE ) ;
                 END IF;

  oe_order_pub.g_hdr.agreement_id       := g_panda_rec_table(1).p_agreement_id;
  oe_order_pub.g_hdr.invoice_to_org_id  := g_panda_rec_table(1).p_invoice_to_org_id;
  oe_order_pub.g_hdr.ordered_date       := g_panda_rec_table(1).p_request_date;
  oe_order_pub.g_hdr.header_id          := g_header_id;
  oe_order_pub.g_hdr.org_id             := l_org_id;
  oe_order_pub.g_hdr.price_list_id      := g_panda_rec_table(1).p_price_list_id;
  oe_order_pub.g_hdr.price_request_code := p_price_request_code;
  oe_order_pub.g_hdr.pricing_date       := g_panda_rec_table(1).p_pricing_date;
  oe_order_pub.g_hdr.request_date       := g_panda_rec_table(1).p_request_date;
  oe_order_pub.g_hdr.ship_to_org_id     := g_panda_rec_table(1).p_ship_to_org_id;
  oe_order_pub.g_hdr.sold_to_org_id     := g_panda_rec_table(1).p_customer_id;
  oe_order_pub.g_hdr.order_type_id      := g_panda_rec_table(1).p_order_type_id;
  oe_order_pub.g_hdr.ship_from_org_id   := g_panda_rec_table(1).p_ship_from_org_id;
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

  /*
  QP_Attr_Mapping_PUB.Build_Contexts(
     p_request_type_code => 'ONT',
     p_pricing_type	=>'H',
     x_price_contexts_result_tbl => p_pricing_contexts_Tbl,
     x_qual_contexts_result_tbl  => p_qualifier_Contexts_Tbl
     );*/

     QP_ATTR_Mapping_PUB.Build_Contexts(
          p_request_type_code =>'ONT',
          p_line_index =>1,
          p_pricing_type_code =>'H');


  /*
  copy_attribs_to_Req(
     p_line_index         => 	p_req_line_tbl_count
     ,px_Req_line_attr_tbl    =>p_Req_line_attr_tbl
     ,px_Req_qual_tbl         =>p_Req_qual_tbl
     ,p_pricing_contexts_tbl => p_pricing_contexts_Tbl
     ,p_qualifier_contexts_tbl  => p_qualifier_Contexts_Tbl
     );*/

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
			     ,p_g_line_index in number

			     ) is

   i	pls_integer;

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

      --
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_OE_AVAILABILITY.APPEND_ATTRIBUTES' , 1 ) ;
   END IF;

   IF g_panda_rec_table(p_g_line_index).p_pricing_attribute1 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE1';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE1;
   END IF;

   IF g_panda_rec_table(p_g_line_index).p_pricing_attribute2 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE2';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE2;
   END IF;

   IF g_panda_rec_table(p_g_line_index).p_pricing_attribute3 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE3';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE3;
   END IF;

   IF g_panda_rec_table(p_g_line_index).p_pricing_attribute4 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE4';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE4;
   END IF;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute5 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE5';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE5;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute6 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE6';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE6;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute7 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE7';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE7;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute8 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE8';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE8;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute9 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE9';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE9;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute10 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE10';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE10;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute11 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE11';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE11;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute12 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE12';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE12;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute13 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE13';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE13;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute14 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE14';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE14;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute15 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE15';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE15;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute16 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE16';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE16;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute17 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE17';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE17;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute18 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE18';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE18;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute19 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE19';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE19;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute20 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE20;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute21 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE21';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE21;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute22 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE22';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE22;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute23 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE23';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE23;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute24 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE24';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE24;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute25 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE25';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE25;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute26 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE26';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE26;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute27 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE27';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE27;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute28 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE28';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE28;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute29 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE29';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_PRICING_ATTRIBUTE29;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute30 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE30';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute30;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute31 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE31';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute31;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute32 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE32';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute32;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute33 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE33';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute33;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute34 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE34';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute34;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute35 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE35';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute35;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute36 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE36';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute36;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute37 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE37';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute37;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute38 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE38';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute38;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute39 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE39';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute39;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute40 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE40';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute40;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute41 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE41';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute41;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute42 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE42';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute42;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute43 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE43';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute43;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute44 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE44';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute44;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute45 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE45';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute45;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute46 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE46';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute46;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute47 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE47';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute47;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute48 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE48';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute48;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute49 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE49';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute49;
   end if;


   if g_panda_rec_table(p_g_line_index).p_pricing_attribute50 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE20';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute20;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute51 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE51';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute51;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute52 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE52';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute52;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute53 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE53';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute53;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute54 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE54';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute54;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute55 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE55';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute55;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute56 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE56';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute56;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute57 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE57';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute57;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute58 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE58';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute58;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute59 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE59';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute59;
   end if;


   if g_panda_rec_table(p_g_line_index).p_pricing_attribute60 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE60';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute60;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute61 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE61';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute61;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute62 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE62';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute62;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute63 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE63';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute63;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute64 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE64';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute64;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute65 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE65';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute65;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute66 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE66';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute66;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute67 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE67';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute67;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute68 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE68';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute68;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute69 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE69';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute69;
   end if;


   if g_panda_rec_table(p_g_line_index).p_pricing_attribute70 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE70';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute70;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute71 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE71';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute71;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute72 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE72';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute72;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute73 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE73';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute73;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute74 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE74';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute74;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute75 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE75';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute75;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute76 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE76';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute76;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute77 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE77';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute77;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute78 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE78';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute27;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute79 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE79';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute27;
   end if;


   if g_panda_rec_table(p_g_line_index).p_pricing_attribute80 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE80';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute80;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute81 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE81';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute81;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute82 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE82';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute82;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute83 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE83';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute83;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute84 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE84';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute84;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute85 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE85';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute85;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute86 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE86';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute86;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute87 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE87';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute87;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute88 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE88';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute88;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute89 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE89';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute89;
   end if;


   if g_panda_rec_table(p_g_line_index).p_pricing_attribute90 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE90';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute90;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute91 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE91';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute91;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute92 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE92';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute92;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute93 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE93';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=g_panda_rec_table(p_g_line_index).p_pricing_attribute93;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute94 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE94';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute94;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute95 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE95';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute95;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute96 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE96';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute96;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute97 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE97';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute97;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute98 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE98';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute98;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute99 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE99';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_panda_rec_table(p_g_line_index).p_pricing_attribute99;
   end if;

   if g_panda_rec_table(p_g_line_index).p_pricing_attribute100 is not null then
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).pricing_context := g_panda_rec_table(p_g_line_index).p_pricing_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'PRICING_ATTRIBUTE100';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From:=g_panda_rec_table(p_g_line_index).p_pricing_attribute100;
   end if;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_OE_AVAILABILITY.APPEND_ATTRIBUTES' , 1 ) ;
   END IF;

END Append_attributes;

PROCEDURE Append_attr_to_ttables(px_req_line_attr_tbl in out nocopy QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
				 )
IS
   i number;
   k number;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_attribute_type VARCHAR2(30);
BEGIN
   --Temp Tables
   k:=G_ATTR_PRICING_ATTRIBUTE_TBL.count;
   i := px_req_line_attr_tbl.first;
   if l_debug_level >0 then
      oe_debug_pub.add('****populating attributes in to temp table **********');
   end if;

   if l_debug_level > 0 then

      oe_debug_pub.add('k='||k||'i='||i);
   end if;

   while i is not null  loop
      k:=k+1;
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'POPULATE LINE ATTRS'||K||' '||PX_REQ_LINE_ATTR_TBL ( I ) .PRICING_CONTEXT , 3 ) ;
      END IF;

      IF (px_req_line_attr_tbl(I).PRICING_CONTEXT = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
	 l_attribute_type := QP_PREQ_GRP.G_PRODUCT_TYPE;
      ELSIF (px_req_line_attr_tbl(I).PRICING_CONTEXT = 'MODLIST') THEN
	 l_attribute_type := QP_PREQ_GRP.G_QUALIFIER_TYPE;
      ELSE
	 l_attribute_type := QP_PREQ_GRP.G_PRICING_TYPE;
      END IF;
      G_ATTR_LINE_INDEX_tbl(k) := px_req_line_attr_tbl(i).line_index;
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'LINE_INDEX:'||G_ATTR_LINE_INDEX_TBL ( K ) ) ;
      END IF;
      G_ATTR_LINE_DETAIL_INDEX_tbl(k) := NULL;
      G_ATTR_ATTRIBUTE_LEVEL_tbl(k) := QP_PREQ_GRP.G_LINE_LEVEL;
      G_ATTR_VALIDATED_FLAG_tbl(k) := 'N';
      G_ATTR_ATTRIBUTE_TYPE_tbl(k) := l_attribute_type;
      G_ATTR_PRICING_CONTEXT_tbl(k)
	 := px_req_line_attr_tbl(i).pricing_context;
      G_ATTR_PRICING_ATTRIBUTE_tbl(k)
	 := px_req_line_attr_tbl(i).pricing_attribute;
      G_ATTR_APPLIED_FLAG_tbl(k) := QP_PREQ_GRP.G_LIST_NOT_APPLIED;--NULL;
	 G_ATTR_PRICING_STATUS_CODE_tbl(k) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
      G_ATTR_PRICING_ATTR_FLAG_tbl (k) := QP_PREQ_GRP.G_YES;--NULL;
	 G_ATTR_LIST_HEADER_ID_tbl(k) := NULL;
      G_ATTR_LIST_LINE_ID_tbl(k) := NULL;
      G_ATTR_VALUE_FROM_tbl(k)      :=px_req_line_attr_tbl(i).pricing_attr_value_from;
      G_ATTR_SETUP_VALUE_FROM_tbl(k):=NULL;
      G_ATTR_VALUE_TO_tbl(k)      :=NULL;
      G_ATTR_SETUP_VALUE_TO_tbl(k) := NULL;
      G_ATTR_GROUPING_NUMBER_tbl(k) := NULL;
      G_ATTR_NO_QUAL_IN_GRP_tbl(k)     :=NULL;
      G_ATTR_COMP_OPERATOR_TYPE_tbl(k):= NULL;
      G_ATTR_PRICING_STATUS_TEXT_tbl(k) :=NULL;
      G_ATTR_QUAL_PRECEDENCE_tbl(k):=NULL;
      G_ATTR_DATATYPE_tbl(k)          := NULL;
      G_ATTR_QUALIFIER_TYPE_tbl(k)   := NULL;
      G_ATTR_PRODUCT_UOM_CODE_TBL(k) := NULL;
      G_ATTR_EXCLUDER_FLAG_TBL(k) := NULL;
      G_ATTR_PRICING_PHASE_ID_TBL(k) := NULL;
      G_ATTR_INCOM_GRP_CODE_TBL(k):=NULL;
      G_ATTR_LDET_TYPE_CODE_TBL(k):=NULL;
      G_ATTR_MODIFIER_LEVEL_CODE_TBL(k):=NULL;
      G_ATTR_PRIMARY_UOM_FLAG_TBL(k):=NULL;
      i:= px_req_line_attr_tbl.next(i);
    END LOOP;


  --G_ATTR_LINE_INDEX_tbl(G_ATTR_LINE_INDEX_tbl.count+1):=2;
  --G_ATTR_ATTRIBUTE_LEVEL_tbl(G_ATTR_LINE_INDEX_tbl.count):=QP_PREQ_GRP.G_LINE_LEVEL;

   --Temp_tables population ends

end append_attr_to_TTables;

PROCEDURE Reset_All_Tbls
AS


l_routine VARCHAR2(240):='QP_PREQ_GRP.Reset_All_Tbls';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 G_LINE_INDEX_tbl.delete;
 G_LINE_TYPE_CODE_TBL.delete          ;
 G_PRICING_EFFECTIVE_DATE_TBL.delete  ;
 G_ACTIVE_DATE_FIRST_TBL.delete       ;
 G_ACTIVE_DATE_FIRST_TYPE_TBL.delete  ;
 G_ACTIVE_DATE_SECOND_TBL.delete      ;
 G_ACTIVE_DATE_SECOND_TYPE_TBL.delete ;
 G_LINE_QUANTITY_TBL.delete           ;
 G_LINE_UOM_CODE_TBL.delete           ;
 G_REQUEST_TYPE_CODE_TBL.delete       ;
 G_PRICED_QUANTITY_TBL.delete         ;
 G_UOM_QUANTITY_TBL.delete         ;
 G_PRICED_UOM_CODE_TBL.delete         ;
 G_CURRENCY_CODE_TBL.delete           ;
 G_UNIT_PRICE_TBL.delete              ;
 G_PERCENT_PRICE_TBL.delete           ;
 G_ADJUSTED_UNIT_PRICE_TBL.delete     ;
 G_PROCESSED_FLAG_TBL.delete          ;
 G_PRICE_FLAG_TBL.delete              ;
 G_LINE_ID_TBL.delete                 ;
 G_PROCESSING_ORDER_TBL.delete        ;
 G_ROUNDING_FLAG_TBL.delete;
 G_ROUNDING_FACTOR_TBL.delete              ;
 G_PRICING_STATUS_CODE_TBL.delete       ;
 G_PRICING_STATUS_TEXT_TBL.delete       ;
 G_ATTR_LINE_INDEX_tbl.delete;
 G_ATTR_ATTRIBUTE_LEVEL_tbl.delete;
 G_ATTR_VALIDATED_FLAG_tbl.delete;
 G_ATTR_ATTRIBUTE_TYPE_tbl.delete;
 G_ATTR_PRICING_CONTEXT_tbl.delete;
 G_ATTR_PRICING_ATTRIBUTE_tbl.delete;
 G_ATTR_APPLIED_FLAG_tbl.delete;
 G_ATTR_PRICING_STATUS_CODE_tbl.delete;
 G_ATTR_PRICING_ATTR_FLAG_tbl.delete;
 G_ATTR_LIST_HEADER_ID_tbl.delete;
 G_ATTR_LIST_LINE_ID_tbl.delete;
 G_ATTR_VALUE_FROM_tbl.delete;
 G_ATTR_SETUP_VALUE_FROM_tbl.delete;
 G_ATTR_VALUE_TO_tbl.delete;
 G_ATTR_SETUP_VALUE_TO_tbl.delete;
 G_ATTR_GROUPING_NUMBER_tbl.delete;
 G_ATTR_NO_QUAL_IN_GRP_tbl.delete;
 G_ATTR_COMP_OPERATOR_TYPE_tbl.delete;
 G_ATTR_VALIDATED_FLAG_tbl.delete;
 G_ATTR_APPLIED_FLAG_tbl.delete;
 G_ATTR_PRICING_STATUS_CODE_tbl.delete;
 G_ATTR_PRICING_STATUS_TEXT_tbl.delete;
 G_ATTR_QUAL_PRECEDENCE_tbl.delete;
 G_ATTR_DATATYPE_tbl.delete;
 G_ATTR_PRICING_ATTR_FLAG_tbl.delete    ;
 G_ATTR_QUALIFIER_TYPE_tbl.delete;
 G_ATTR_PRODUCT_UOM_CODE_TBL.delete;
 G_ATTR_EXCLUDER_FLAG_TBL.delete;
 G_ATTR_PRICING_PHASE_ID_TBL.delete;
 G_ATTR_INCOM_GRP_CODE_TBL.delete;
 G_ATTR_LDET_TYPE_CODE_TBL.delete;
 G_ATTR_MODIFIER_LEVEL_CODE_TBL.delete;
 G_ATTR_PRIMARY_UOM_FLAG_TBL.delete;
EXCEPTION
WHEN OTHERS THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  L_ROUTINE||': '||SQLERRM , 1 ) ;
END IF;
END reset_all_tbls;


procedure Populate_Temp_Table
IS
   l_return_status  varchar2(1) := FND_API.G_RET_STS_SUCCESS;
   l_return_status_Text     varchar2(240) ;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE DIRECT INSERT INTO TEMP TABLE: BULK INSERT'||G_LINE_INDEX_TBL.COUNT , 1 ) ;
   END IF;
   QP_PREQ_GRP.INSERT_LINES2
      (p_LINE_INDEX =>   G_LINE_INDEX_TBL,
       p_LINE_TYPE_CODE =>  G_LINE_TYPE_CODE_TBL,
       p_PRICING_EFFECTIVE_DATE =>G_PRICING_EFFECTIVE_DATE_TBL,
       p_ACTIVE_DATE_FIRST       =>G_ACTIVE_DATE_FIRST_TBL,
       p_ACTIVE_DATE_FIRST_TYPE  =>G_ACTIVE_DATE_FIRST_TYPE_TBL,
       p_ACTIVE_DATE_SECOND      =>G_ACTIVE_DATE_SECOND_TBL,
       p_ACTIVE_DATE_SECOND_TYPE =>G_ACTIVE_DATE_SECOND_TYPE_TBL,
       p_LINE_QUANTITY =>     G_LINE_QUANTITY_TBL,
       p_LINE_UOM_CODE =>     G_LINE_UOM_CODE_TBL,
       p_REQUEST_TYPE_CODE => G_REQUEST_TYPE_CODE_TBL,
       p_PRICED_QUANTITY =>   G_PRICED_QUANTITY_TBL,
       p_PRICED_UOM_CODE =>   G_PRICED_UOM_CODE_TBL,
       p_CURRENCY_CODE   =>   G_CURRENCY_CODE_TBL,
       p_UNIT_PRICE      =>   G_UNIT_PRICE_TBL,
       p_PERCENT_PRICE   =>   G_PERCENT_PRICE_TBL,
       p_UOM_QUANTITY =>      G_UOM_QUANTITY_TBL,
       p_ADJUSTED_UNIT_PRICE =>G_ADJUSTED_UNIT_PRICE_TBL,
       p_UPD_ADJUSTED_UNIT_PRICE =>G_UPD_ADJUSTED_UNIT_PRICE_TBL,
       p_PROCESSED_FLAG      =>G_PROCESSED_FLAG_TBL,
       p_PRICE_FLAG          =>G_PRICE_FLAG_TBL,
       p_LINE_ID             =>G_LINE_ID_TBL,
       p_PROCESSING_ORDER    =>G_PROCESSING_ORDER_TBL,
       p_PRICING_STATUS_CODE =>G_PRICING_STATUS_CODE_tbl,
       p_PRICING_STATUS_TEXT =>G_PRICING_STATUS_TEXT_tbl,
       p_ROUNDING_FLAG       =>G_ROUNDING_FLAG_TBL,
       p_ROUNDING_FACTOR     =>G_ROUNDING_FACTOR_TBL,
       p_QUALIFIERS_EXIST_FLAG => G_QUALIFIERS_EXIST_FLAG_TBL,
       p_PRICING_ATTRS_EXIST_FLAG =>G_PRICING_ATTRS_EXIST_FLAG_TBL,
       p_PRICE_LIST_ID          => G_PRICE_LIST_ID_TBL,
       p_VALIDATED_FLAG         => G_PL_VALIDATED_FLAG_TBL,
       p_PRICE_REQUEST_CODE     => G_PRICE_REQUEST_CODE_TBL,
       p_USAGE_PRICING_TYPE  =>    G_USAGE_PRICING_TYPE_tbl,
       p_line_category       =>    G_LINE_CATEGORY_tbl,
       --p_catchweight_qty     =>    G_CATCHWEIGHT_QTY_tbl,
       --p_actual_order_qty    =>    G_ACTUAL_ORDER_QTY_TBL,
       x_status_code         =>l_return_status,
       x_status_text         =>l_return_status_text);

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'WRONG IN INSERT_LINES2'||L_RETURN_STATUS_TEXT , 1 ) ;
      END IF;
      FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
      FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
      OE_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF G_ATTR_LINE_INDEX_tbl.count > 0 THEN
      QP_PREQ_GRP.INSERT_LINE_ATTRS2
	 (    G_ATTR_LINE_INDEX_tbl,
	      G_ATTR_LINE_DETAIL_INDEX_tbl  ,
	      G_ATTR_ATTRIBUTE_LEVEL_tbl    ,
	      G_ATTR_ATTRIBUTE_TYPE_tbl     ,
	      G_ATTR_LIST_HEADER_ID_tbl     ,
	      G_ATTR_LIST_LINE_ID_tbl       ,
	      G_ATTR_PRICING_CONTEXT_tbl            ,
	      G_ATTR_PRICING_ATTRIBUTE_tbl          ,
	      G_ATTR_VALUE_FROM_tbl         ,
	      G_ATTR_SETUP_VALUE_FROM_tbl   ,
	      G_ATTR_VALUE_TO_tbl           ,
	      G_ATTR_SETUP_VALUE_TO_tbl     ,
	      G_ATTR_GROUPING_NUMBER_tbl         ,
	      G_ATTR_NO_QUAL_IN_GRP_tbl      ,
	      G_ATTR_COMP_OPERATOR_TYPE_tbl  ,
	      G_ATTR_VALIDATED_FLAG_tbl            ,
	      G_ATTR_APPLIED_FLAG_tbl              ,
	      G_ATTR_PRICING_STATUS_CODE_tbl       ,
	      G_ATTR_PRICING_STATUS_TEXT_tbl       ,
	      G_ATTR_QUAL_PRECEDENCE_tbl      ,
	      G_ATTR_DATATYPE_tbl                  ,
	      G_ATTR_PRICING_ATTR_FLAG_tbl         ,
	      G_ATTR_QUALIFIER_TYPE_tbl            ,
	      G_ATTR_PRODUCT_UOM_CODE_TBL          ,
	      G_ATTR_EXCLUDER_FLAG_TBL             ,
	      G_ATTR_PRICING_PHASE_ID_TBL ,
	      G_ATTR_INCOM_GRP_CODE_TBL,
	      G_ATTR_LDET_TYPE_CODE_TBL,
	      G_ATTR_MODIFIER_LEVEL_CODE_TBL,
	      G_ATTR_PRIMARY_UOM_FLAG_TBL,
	      l_return_status                   ,
	      l_return_status_text                   );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ERROR INSERTING INTO LINE ATTRS'||SQLERRM ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
	 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
	 OE_MSG_PUB.Add;
	 raise fnd_api.g_exc_unexpected_error;
      END IF;

   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER DIRECT INSERT INTO TEMP TABLE: BULK INSERT' , 1 ) ;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_ERROR;
END POPULATE_TEMP_TABLE;


PROCEDURE Populate_results
   (x_line_tbl          OUT nocopy  QP_PREQ_GRP.LINE_TBL_TYPE,
    x_line_qual_tbl        OUT nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE,
    x_line_attr_tbl        OUT  nocopy QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
    x_line_detail_tbl      OUT  nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
    x_line_detail_qual_tbl OUT  nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
    x_line_detail_attr_tbl OUT  nocopy QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
    x_related_lines_tbl    OUT  nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE)
AS

  CURSOR l_lines_cur IS
    SELECT LINE_INDEX,
           LINE_ID,
           PRICE_LIST_HEADER_ID, -- shu, print out this
           LINE_TYPE_CODE,
           LINE_QUANTITY,
           LINE_UOM_CODE,
           LINE_UNIT_PRICE, -- shu
           ROUNDING_FACTOR, -- shu
           PRICED_QUANTITY,
           UOM_QUANTITY,
           PRICED_UOM_CODE,
           CURRENCY_CODE,
           UNIT_PRICE,
           PERCENT_PRICE,
           PARENT_PRICE,
           PARENT_QUANTITY,
           PARENT_UOM_CODE,
           PRICE_FLAG,
           ADJUSTED_UNIT_PRICE,
	   UPDATED_ADJUSTED_UNIT_PRICE,
           PROCESSING_ORDER,
           PROCESSED_CODE,
           PRICING_STATUS_CODE,
           PRICING_STATUS_TEXT,
           HOLD_CODE,
           HOLD_TEXT,
           PRICE_REQUEST_CODE,
           PRICING_EFFECTIVE_DATE,
           EXTENDED_PRICE, 		/* block pricing */
	   ORDER_UOM_SELLING_PRICE
    FROM   QP_PREQ_LINES_TMP;


  CURSOR l_qual_cur (L_ATTRIBUTE_LEVEL VARCHAR2)IS
    SELECT QPLAT.LINE_INDEX,
           QPLAT.LINE_DETAIL_INDEX,
           QPLAT.CONTEXT,
           QPLAT.ATTRIBUTE,
           QPLAT.SETUP_VALUE_FROM,
           QPLAT.SETUP_VALUE_TO,
           QPLAT.COMPARISON_OPERATOR_TYPE_CODE,
           QPLAT.VALIDATED_FLAG,
           QPLAT.PRICING_STATUS_CODE,
           QPLAT.PRICING_STATUS_TEXT
      FROM  QP_PREQ_LDETS_TMP QPLD ,
	    QP_PREQ_LINE_ATTRS_TMP QPLAT
     WHERE QPLD.LINE_DETAIL_INDEX = QPLAT.LINE_DETAIL_INDEX
       AND   QPLD.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
       AND   QPLAT.ATTRIBUTE_TYPE = 'QUALIFIER';
           --AND QPLAT.PRICING_STATUS_CODE = G_STATUS_NEW;


  CURSOR l_pricing_attr_cur IS
    SELECT QPLAT_PRICING.CONTEXT        PRICING_CONTEXT,
           QPLAT_PRICING.ATTRIBUTE      PRICING_ATTRIBUTE,
           nvl(QPLAT_PRICING.SETUP_VALUE_FROM,QPLAT_PRICING.VALUE_FROM)     PRICING_ATTR_VALUE_FROM,
           QPLAT_PRICING.SETUP_VALUE_TO       PRICING_ATTR_VALUE_TO,
           QPLAT_PRICING.COMPARISON_OPERATOR_TYPE_CODE,
           QPLAT_PRICING.LINE_DETAIL_INDEX,
           QPLAT_PRICING.LINE_INDEX,
           QPLAT_PRICING.VALIDATED_FLAG
      FROM  QP_PREQ_LDETS_TMP QPLD ,
	    QP_PREQ_LINE_ATTRS_TMP QPLAT_PRICING
     WHERE QPLD.LINE_DETAIL_INDEX = QPLAT_PRICING.LINE_DETAIL_INDEX
       AND   QPLD.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
       AND   QPLAT_PRICING.ATTRIBUTE_TYPE IN ('PRICING','PRODUCT');
  --AND QPLAT_PRICING.PRICING_STATUS_CODE = G_STATUS_NEW;


  CURSOR l_ldets_cur IS

    SELECT /*+ ORDERED USE_NL(A B C) l_ldets_cur */

           a.LINE_DETAIL_INDEX,
           a.LINE_DETAIL_TYPE_CODE,
           a.LINE_INDEX,
           a.CREATED_FROM_LIST_HEADER_ID LIST_HEADER_ID,
           a.CREATED_FROM_LIST_LINE_ID   LIST_LINE_ID,
           a.CREATED_FROM_LIST_LINE_TYPE LIST_LINE_TYPE_CODE,
           a.PRICE_BREAK_TYPE_CODE,
           a.LINE_QUANTITY,
           a.ADJUSTMENT_AMOUNT,
	   a.AUTOMATIC_FLAG,
           a.PRICING_PHASE_ID,
           a.OPERAND_CALCULATION_CODE,
           a.OPERAND_VALUE,
           a.PRICING_GROUP_SEQUENCE,
           a.CREATED_FROM_LIST_TYPE_CODE,
           a.APPLIED_FLAG,
           a.PRICING_STATUS_CODE,
           a.PRICING_STATUS_TEXT,
           a.LIMIT_CODE,
           a.LIMIT_TEXT,
           a.LIST_LINE_NO,
           a.GROUP_QUANTITY,
           a.GROUP_AMOUNT, -- 2388011_new
           a.UPDATED_FLAG,
	   a.PROCESS_CODE,
	   a.CALCULATION_CODE,
	   a.CHANGE_REASON_CODE,
	   a.CHANGE_REASON_TEXT,
	   a.ORDER_QTY_ADJ_AMT,
           b.SUBSTITUTION_VALUE SUBSTITUTION_VALUE_TO,
           b.SUBSTITUTION_ATTRIBUTE,
           b.ACCRUAL_FLAG,
           b.modifier_level_code,
           b.ESTIM_GL_VALUE,
           b.ACCRUAL_CONVERSION_RATE,
           --Pass throuh components
           b.OVERRIDE_FLAG,
           b.PRINT_ON_INVOICE_FLAG,
           b.INVENTORY_ITEM_ID,
           b.ORGANIZATION_ID,
           b.RELATED_ITEM_ID,
           b.RELATIONSHIP_TYPE_ID,
           b.ESTIM_ACCRUAL_RATE,
           b.EXPIRATION_DATE,
           b.BENEFIT_PRICE_LIST_LINE_ID,
           b.RECURRING_FLAG,
           b.RECURRING_VALUE,
	   b.BENEFIT_LIMIT,
           b.CHARGE_TYPE_CODE,
           b.CHARGE_SUBTYPE_CODE,
           b.BENEFIT_QTY,
           b.BENEFIT_UOM_CODE,
           b.PRORATION_TYPE_CODE,
           b.INCLUDE_ON_RETURNS_FLAG,
           b.REBATE_TRANSACTION_TYPE_CODE,
           b.NUMBER_EXPIRATION_PERIODS,
           b.EXPIRATION_PERIOD_UOM,
           b.COMMENTS
      FROM  QP_PREQ_LDETS_TMP a,
	    QP_LIST_LINES     b
     WHERE a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
       AND   a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;


  CURSOR l_rltd_lines_cur IS
    SELECT  LINE_INDEX,
            LINE_DETAIL_INDEX,
            RELATIONSHIP_TYPE_CODE,
            RELATED_LINE_INDEX,
            RELATED_LINE_DETAIL_INDEX,
            PRICING_STATUS_CODE,
            PRICING_STATUS_TEXT
      FROM QP_PREQ_RLTD_LINES_TMP
     WHERE PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
     ORDER BY SETUP_VALUE_FROM;


I PLS_INTEGER :=1;
J PLS_INTEGER :=1;
l_expiration_period_end_date Date;
l_status_code VARCHAR2(30);
l_status_text VARCHAR2(30);
E_ROUTINE_ERROR EXCEPTION;
l_routine VARCHAR2(240):='QP_PREQ_GRP.POPULATE_OUTPUT';

BEGIN


   oe_debug_pub.add('----Before populate l_line_tbl-----');
   oe_debug_pub.add('----Line information return back to caller----');

   FOR l_line IN l_lines_cur LOOP
      --requirement from Jay, will cause holes in pl/sql table.
      I :=  l_line.LINE_INDEX;
      x_line_tbl(I).LINE_INDEX := l_line.LINE_INDEX;
      x_line_tbl(I).LINE_ID    := l_line.LINE_ID;
      x_line_tbl(I).HEADER_ID    := l_line.PRICE_LIST_HEADER_ID;
      x_line_tbl(I).LINE_TYPE_CODE := l_line.LINE_TYPE_CODE;
      x_line_tbl(I).PRICED_QUANTITY := l_line.PRICED_QUANTITY;
      x_line_tbl(I).CURRENCY_CODE := l_line.CURRENCY_CODE;
      x_line_tbl(I).ROUNDING_FACTOR := l_line.ROUNDING_FACTOR;
      x_line_tbl(I).PRICED_UOM_CODE := l_line.PRICED_UOM_CODE;
      x_line_tbl(I).UNIT_PRICE := l_line.UNIT_PRICE; --shu_latest
      x_line_tbl(I).LINE_QUANTITY:=l_line.LINE_QUANTITY;
      x_line_tbl(I).LINE_UOM_CODE:=l_line.LINE_UOM_CODE;
      x_line_tbl(I).LINE_UNIT_PRICE := l_line.LINE_UNIT_PRICE; --shu_latest
      x_line_tbl(I).UOM_QUANTITY := l_line.UOM_QUANTITY; --shu_latest
      x_line_tbl(I).PERCENT_PRICE := l_line.PERCENT_PRICE;
   -- x_line_tbl(I).ADJUSTED_UNIT_PRICE := l_line.ADJUSTED_UNIT_PRICE;
      x_line_tbl(I).ADJUSTED_UNIT_PRICE:= l_line.ORDER_UOM_SELLING_PRICE;
      x_line_tbl(I).UPDATED_ADJUSTED_UNIT_PRICE := l_line.UPDATED_ADJUSTED_UNIT_PRICE;
      x_line_tbl(I).PARENT_PRICE := l_line.PARENT_PRICE;
      x_line_tbl(I).PARENT_QUANTITY := l_line.PARENT_QUANTITY;
      x_line_tbl(I).PARENT_UOM_CODE := l_line.PARENT_UOM_CODE;
      x_line_tbl(I).PROCESSED_CODE := l_line.PROCESSED_CODE;
      x_line_tbl(I).PRICE_FLAG := l_line.PRICE_FLAG;
      x_line_tbl(I).STATUS_CODE := l_line.PRICING_STATUS_CODE;
      x_line_tbl(I).STATUS_TEXT := substr(l_line.PRICING_STATUS_TEXT,1,2000); -- shulin, fix bug 1745788
      x_line_tbl(I).HOLD_CODE := l_line.HOLD_CODE;
      x_line_tbl(I).HOLD_TEXT := substr(l_line.HOLD_TEXT,1,240);
      x_line_tbl(I).PRICE_REQUEST_CODE := l_line.PRICE_REQUEST_CODE;
      x_line_tbl(I).PRICING_EFFECTIVE_DATE := l_line.PRICING_EFFECTIVE_DATE;
      x_line_tbl(I).EXTENDED_PRICE := l_line.EXTENDED_PRICE; -- block pricing


   END LOOP;
   I:=1;


   --Populate Line detail

   oe_debug_pub.add('----Line detail information return back to caller----');

   FOR l_dets IN l_ldets_cur LOOP

      oe_debug_pub.add('----populating line detail output------');
      --requirement by Jay, will cause holes in pl/sql tbl
      I := l_dets.line_detail_index;
      x_line_detail_tbl(I).LINE_DETAIL_INDEX := l_dets.LINE_DETAIL_INDEX;
      x_line_detail_tbl(I).LINE_DETAIL_TYPE_CODE:=l_dets.LINE_DETAIL_TYPE_CODE;
      x_line_detail_tbl(I).LINE_INDEX:=l_dets.LINE_INDEX;
      x_line_detail_tbl(I).LIST_HEADER_ID:=l_dets.LIST_HEADER_ID;
      x_line_detail_tbl(I).LIST_LINE_ID:=l_dets.LIST_LINE_ID;
      x_line_detail_tbl(I).LIST_LINE_TYPE_CODE:=l_dets.LIST_LINE_TYPE_CODE;
      x_line_detail_tbl(I).SUBSTITUTION_TO:=l_dets.SUBSTITUTION_VALUE_TO;
      x_line_detail_tbl(I).LINE_QUANTITY :=l_dets.LINE_QUANTITY;
      --x_line_detail_tbl(I).ADJUSTMENT_AMOUNT := l_dets.ADJUSTMENT_AMOUNT;
      x_line_detail_tbl(I).ADJUSTMENT_AMOUNT:= nvl(l_dets.ORDER_QTY_ADJ_AMT,l_dets.ADJUSTMENT_AMOUNT);
      --   nvl(ldets.order_qty_adj_amt, ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1))
      x_line_detail_tbl(I).AUTOMATIC_FLAG    := l_dets.AUTOMATIC_FLAG;
      x_line_detail_tbl(I).APPLIED_FLAG      := l_dets.APPLIED_FLAG;
      x_line_detail_tbl(I).PRICING_GROUP_SEQUENCE := l_dets.PRICING_GROUP_SEQUENCE;
      x_line_detail_tbl(I).CREATED_FROM_LIST_TYPE_CODE:=l_dets.CREATED_FROM_LIST_TYPE_CODE;
      x_line_detail_tbl(I).PRICE_BREAK_TYPE_CODE := l_dets.PRICE_BREAK_TYPE_CODE;
      x_line_detail_tbl(I).OVERRIDE_FLAG   := L_Dets.override_flag;
      x_line_detail_tbl(I).PRINT_ON_INVOICE_FLAG :=l_dets.print_on_invoice_flag;
      x_line_detail_tbl(I).PRICING_PHASE_ID := l_dets.PRICING_PHASE_ID;
      x_line_detail_tbl(I).APPLIED_FLAG := l_dets.APPLIED_FLAG;
      x_line_detail_tbl(I).OPERAND_CALCULATION_CODE := l_dets.OPERAND_CALCULATION_CODE;
      x_line_detail_tbl(I).OPERAND_VALUE := l_dets.OPERAND_VALUE;
      x_line_detail_tbl(I).STATUS_CODE:=l_dets.PRICING_STATUS_CODE;
      x_line_detail_tbl(I).STATUS_TEXT:=substr(l_dets.PRICING_STATUS_TEXT,1,240);
      x_line_detail_tbl(I).SUBSTITUTION_ATTRIBUTE:=l_dets.SUBSTITUTION_ATTRIBUTE;
      x_line_detail_tbl(I).ACCRUAL_FLAG:=l_dets.ACCRUAL_FLAG;
      x_line_detail_tbl(I).LIST_LINE_NO:=l_dets.LIST_LINE_NO;
      x_line_detail_tbl(I).ESTIM_GL_VALUE:=l_dets.ESTIM_GL_VALUE;
      x_line_detail_tbl(I).ACCRUAL_CONVERSION_RATE:=l_dets.ACCRUAL_CONVERSION_RATE;
      --Pass throuh components
      x_line_detail_tbl(I).OVERRIDE_FLAG:= l_dets.OVERRIDE_FLAG;
      x_line_detail_tbl(I).PRINT_ON_INVOICE_FLAG:=l_dets.PRINT_ON_INVOICE_FLAG;
      x_line_detail_tbl(I).INVENTORY_ITEM_ID:=l_dets.INVENTORY_ITEM_ID;
      x_line_detail_tbl(I).ORGANIZATION_ID:=l_dets.ORGANIZATION_ID;
      x_line_detail_tbl(I).RELATED_ITEM_ID:= l_dets.RELATED_ITEM_ID;
      x_line_detail_tbl(I).RELATIONSHIP_TYPE_ID:=l_dets.RELATIONSHIP_TYPE_ID;
      x_line_detail_tbl(I).ESTIM_ACCRUAL_RATE:=l_dets.ESTIM_ACCRUAL_RATE;

      x_line_detail_tbl(I).BENEFIT_PRICE_LIST_LINE_ID:=l_dets.BENEFIT_PRICE_LIST_LINE_ID;
      x_line_detail_tbl(I).RECURRING_FLAG:= l_dets.RECURRING_FLAG;
      x_line_detail_tbl(I).RECURRING_VALUE:= l_dets.RECURRING_VALUE;
      x_line_detail_tbl(I).BENEFIT_LIMIT:= l_dets.BENEFIT_LIMIT;
      x_line_detail_tbl(I).CHARGE_TYPE_CODE:=  l_dets.CHARGE_TYPE_CODE;
      x_line_detail_tbl(I).CHARGE_SUBTYPE_CODE:=l_dets.CHARGE_SUBTYPE_CODE;
      x_line_detail_tbl(I).BENEFIT_QTY:=l_dets.BENEFIT_QTY;
      x_line_detail_tbl(I).BENEFIT_UOM_CODE:=l_dets.BENEFIT_UOM_CODE;
      x_line_detail_tbl(I).PRORATION_TYPE_CODE:=l_dets.PRORATION_TYPE_CODE;
      x_line_detail_tbl(I).INCLUDE_ON_RETURNS_FLAG := l_dets.INCLUDE_ON_RETURNS_FLAG;
      x_line_detail_tbl(I).LIST_LINE_NO := l_dets.LIST_LINE_NO;
      x_line_detail_tbl(I).MODIFIER_LEVEL_CODE := l_dets.MODIFIER_LEVEL_CODE;
      x_line_detail_tbl(I).GROUP_VALUE := nvl(l_dets.GROUP_QUANTITY,l_dets.GROUP_AMOUNT); -- 2388011_new
      x_line_detail_tbl(I).COMMENTS := l_dets.COMMENTS;
      x_line_detail_tbl(I).UPDATED_FLAG := l_dets.UPDATED_FLAG;
      x_line_detail_tbl(I).PROCESS_CODE := l_dets.PROCESS_CODE;
      x_line_detail_tbl(I).LIMIT_CODE := l_dets.LIMIT_CODE;
      x_line_detail_tbl(I).LIMIT_TEXT := substr(l_dets.LIMIT_TEXT,1,240);
      x_line_detail_tbl(I).CALCULATION_CODE := l_dets.CALCULATION_CODE;
      x_line_detail_tbl(I).CHANGE_REASON_CODE := l_dets.CHANGE_REASON_CODE;
      x_line_detail_tbl(I).CHANGE_REASON_CODE := substr(l_dets.CHANGE_REASON_CODE,1,240);

      IF l_status_code = FND_API.G_RET_STS_ERROR THEN
	 --  IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
	 oe_debug_pub.add(l_routine||':'||substr(l_status_text,1,240));
	 --END IF;
      END IF;

      x_line_detail_tbl(I).EXPIRATION_DATE :=l_expiration_period_end_date;
   END LOOP;
   I:=1;

   --Populate Qualifier detail
   --IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
   oe_debug_pub.add('----Before populate x_qual_tbl-----');
   --END IF;
   FOR l_qual IN l_qual_cur(QP_PREQ_GRP.G_DETAIL_LEVEL) LOOP
      x_line_detail_qual_tbl(I).LINE_DETAIL_INDEX := l_qual.LINE_DETAIL_INDEX;
      x_line_detail_qual_tbl(I).QUALIFIER_CONTEXT := l_qual.CONTEXT;
      x_line_detail_qual_tbl(I).QUALIFIER_ATTRIBUTE := l_qual.ATTRIBUTE;
      x_line_detail_qual_tbl(I).QUALIFIER_ATTR_VALUE_FROM := l_qual.SETUP_VALUE_FROM;
      x_line_detail_qual_tbl(I).QUALIFIER_ATTR_VALUE_TO := l_qual.SETUP_VALUE_TO;
      x_line_detail_qual_tbl(I).COMPARISON_OPERATOR_CODE := l_qual.COMPARISON_OPERATOR_TYPE_CODE;
      x_line_detail_qual_tbl(I).status_code := l_qual.PRICING_STATUS_CODE;
      x_line_detail_qual_tbl(I).VALIDATED_FLAG :=l_qual.VALIDATED_FLAG;

      I:=I+1;
   END LOOP;
   I:=1;

   --LINE ATTRIBUTE DETAIL NEEDED
   --IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
   oe_debug_pub.add('----Before populate attr_tbl-----');
   --END IF;
   FOR l_prc IN l_pricing_attr_cur LOOP
      --IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      oe_debug_pub.add('--------populating x_line_detail_attr----------');
      oe_debug_pub.add('Line Detail Index: '||l_prc.LINE_DETAIL_INDEX);
      --END IF;
      x_line_detail_attr_tbl(I).LINE_DETAIL_INDEX := l_prc.LINE_DETAIL_INDEX;
      x_line_detail_attr_tbl(I).PRICING_CONTEXT := l_prc.PRICING_CONTEXT;
      x_line_detail_attr_tbl(I).PRICING_ATTRIBUTE := l_prc.PRICING_ATTRIBUTE;
      x_line_detail_attr_tbl(I).PRICING_ATTR_VALUE_FROM :=l_prc.PRICING_ATTR_VALUE_FROM;
      x_line_detail_attr_tbl(I).PRICING_ATTR_VALUE_TO :=l_prc.PRICING_ATTR_VALUE_TO;
      x_line_detail_attr_tbl(I).VALIDATED_FLAG :=l_prc.VALIDATED_FLAG;
      --x_line_attr_tbl(I).PRICING_STATUS_CODE := l_prc.PRICING_STATUS_CODE;
      --x_line_attr_tbl(I).PRICING_STATUS_TEXT := l_prc.PRICING_STATUS_TEXT;
      I:=I+1;
   END LOOP;

   I:=1;

   --IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
   oe_debug_pub.add('----Before populate l_rltd_lines_tbl-----');
   --END IF;
   FOR l_rltd IN l_rltd_lines_cur LOOP
      x_related_lines_tbl(I).LINE_INDEX := l_rltd.Line_index;
      x_related_lines_tbl(I).LINE_DETAIL_INDEX :=  l_rltd.LINE_DETAIL_INDEX;
      x_related_lines_tbl(I).RELATIONSHIP_TYPE_CODE :=l_rltd.RELATIONSHIP_TYPE_CODE;
      x_related_lines_tbl(I).RELATED_LINE_INDEX     :=l_rltd.RELATED_LINE_INDEX;
      x_related_lines_tbl(I).RELATED_LINE_DETAIL_INDEX :=l_rltd.RELATED_LINE_DETAIL_INDEX;
      x_related_lines_tbl(I).STATUS_CODE :=l_rltd.PRICING_STATUS_CODE;
      x_related_lines_tbl(I).STATUS_TEXT :=l_rltd.PRICING_STATUS_TEXT;
      I:=I+1;
   END LOOP;

EXCEPTION
   WHEN E_ROUTINE_ERROR THEN
      --   IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      oe_debug_pub.add(l_routine||':'||substr(l_status_text,1,240));
      -- END IF;

END Populate_results;




PROCEDURE price_item(out_req_line_tbl in out NOCOPY /* file.sql.39 change */ QP_PREQ_GRP.LINE_TBL_TYPE,
		     out_Req_line_attr_tbl         in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
		     out_Req_LINE_DETAIL_attr_tbl  in out nocopy  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
		     out_Req_LINE_DETAIL_tbl        in out nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
		     out_Req_related_lines_tbl      in out nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
		     out_Req_qual_tbl               in out nocopy QP_PREQ_GRP.QUAL_TBL_TYPE,
		     out_Req_LINE_DETAIL_qual_tbl   in out nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
		     out_child_detail_type out nocopy varchar2

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

   out_child_detail_type := qp_preq_grp.G_CHILD_DETAIL_TYPE;
   reset_all_tbls;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SETTING REQUEST ID' , 1 ) ;
   END IF;

   qp_price_request_context.set_request_id;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('REQUEST ID IS : ' || QP_PREQ_GRP.G_REQUEST_ID , 1 ) ;
   END IF;


   OE_ORDER_PUB.G_HDR:=NULL;
   OE_ORDER_PUB.G_LINE:=NULL;

   copy_Header_to_request(
			  p_request_type_code => 'ONT'
			  ,p_calculate_price_flag  => 'Y'
			  ,px_req_line_tbl => l_req_line_tbl
			  );

   set_pricing_control_record (
			       l_Control_Rec  => l_control_rec
			       ,in_pricing_event => 'BATCH'
                               );


   for l_line_index in g_panda_rec_table.first..g_panda_rec_table.last
		       LOOP
      copy_Line_to_request(
			   px_req_line_tbl => l_req_line_tbl
			   ,p_pricing_event => 'BATCH'
			   ,p_Request_Type_Code => 'ONT'
			   ,p_honor_price_flag => 'Y'
			   ,p_line_index=>l_line_index
			   );

      build_context_for_line(
			     p_req_line_tbl_count =>l_req_line_tbl.count,
			     p_price_request_code => null,
			     p_item_type_code => null,
			     p_Req_line_attr_tbl =>l_req_line_attr_tbl,
			     p_Req_qual_tbl =>l_req_qual_tbl,
			     p_line_index=>l_line_index
			     );

      Append_attributes(
			p_header_id => g_header_id
			,p_Line_id   => g_line_id
			,p_line_index =>l_req_line_tbl.count
			,px_Req_line_attr_tbl => l_req_line_attr_tbl
			,px_Req_qual_tbl => l_req_qual_tbl
			,p_g_line_index =>l_line_index
			);

   end loop; -- Looping for each line


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
		     ,p_line_index => l_req_line_tbl.count
		     ,px_Req_line_attr_tbl => l_req_line_attr_tbl
		     ,px_Req_qual_tbl => l_req_qual_tbl
		     ,p_g_line_index =>1
		     );

   oe_Debug_pub.add(' Populating the attr tables');
   append_attr_to_TTables(px_req_line_attr_tbl=>l_req_line_attr_tbl);

   out_req_line_tbl(1).status_Code := null;
   out_req_line_tbl(1).status_text := null;

   IF l_debug_level  > 0 THEN
      print_time('Calling PE');
   END IF;

   oe_Debug_pub.add(' Populating the temp tables');
   populate_temp_table;

   QP_PREQ_PUB.PRICE_REQUEST
      (p_control_rec           =>l_control_rec,
       x_return_status         =>l_return_status,
       x_return_status_Text    =>l_return_status_Text
       );

   IF l_debug_level  > 0 THEN
      print_time('After Calling PE');
   END IF;
   oe_debug_pub.add('After caling the pricing engine');

   populate_results(
		    x_line_tbl =>out_req_line_tbl
		    ,x_line_qual_tbl =>out_Req_qual_tbl
		    ,x_line_attr_tbl =>out_Req_line_attr_tbl
		    ,x_line_detail_tbl =>out_req_line_detail_tbl
		    ,x_line_detail_qual_tbl=>out_req_line_detail_qual_tbl
		    ,x_line_detail_attr_tbl =>out_req_line_detail_attr_tbl
		    ,x_related_lines_tbl=>out_req_related_lines_tbl);

   IF l_debug_level > 0 THEN
      print_time('After populating the pl/sql records');
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

	 IF out_req_line_detail_tbl.exists(i) then

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
               oe_debug_pub.add(  'OPERAND_CALCULATION_CODE='||OUT_REQ_LINE_DETAIL_TBL(I).OPERAND_CALCULATION_CODE);
	       oe_debug_pub.add(  'LST_PRICE='||OUT_REQ_LINE_DETAIL_TBL ( I ) .LIST_PRICE ) ;
	       oe_debug_pub.add(  'ADJUSTMENT_AMOUNT='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .ADJUSTMENT_AMOUNT ) ;
	       oe_debug_pub.add(  'LINE_QUANTITY='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .LINE_QUANTITY ) ;
	       oe_debug_pub.add(  'MODIFIER_LEVEL_CODE='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .MODIFIER_LEVEL_CODE ) ;
	       oe_debug_pub.add(  'INVENTORY_ITEM_ID='|| OUT_REQ_LINE_DETAIL_TBL ( I ) .INVENTORY_ITEM_ID ) ;
	       oe_debug_pub.add(  'RECURRING_FLAG='||OUT_REQ_LINE_DETAIL_TBL (I).RECURRING_FLAG );
	       oe_debug_pub.add(  'RECURRING_VALUE='||OUT_REQ_LINE_DETAIL_TBL(I).RECURRING_VALUE);
	    end if;
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
	    oe_debug_pub.add('*******************************' ) ;
	    oe_debug_pub.add('QUAL TABLE RECORD='||I ) ;
	    oe_debug_pub.add('LINE_INDEX='||OUT_REQ_QUAL_TBL ( I ) .LINE_INDEX ) ;
	    oe_debug_pub.add('QUALIFIER_CONTEXT='|| OUT_REQ_QUAL_TBL ( I ) .QUALIFIER_CONTEXT ) ;
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
      oe_debug_pub.add( 'EXITING PRICE_ITEM*******************************' ) ;
   END IF;

EXCEPTION
   when others then

      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'PRICE ITEM EXCEPTION WHEN OTHERS CODE='|| SQLCODE||' MESSAGE='||SQLERRM ) ;
END IF;

END price_item;

PROCEDURE pass_values_to_backend (
				  in_panda_rec_table in panda_rec_table)
IS

BEGIN

   g_panda_rec_table.delete;
   for i in in_panda_rec_table.first..in_panda_rec_table.last
      loop
      oe_debug_pub.add(' Line Record Nbr='||i);

      g_panda_rec_table(i):=in_panda_rec_table(i);
            oe_debug_pub.add('*******IT STARTS HERE*****');
	    oe_debug_pub.add('index is'||i||' item is='||g_panda_rec_table(i).p_inventory_item_id);

      end loop;

END pass_values_to_backend;



PROCEDURE copy_attribs_to_Req(
       p_line_index number
      ,px_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
      ,px_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
      ,p_pricing_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
      ,p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
) IS

i pls_integer := 0;
l_attr_index	pls_integer := nvl(px_Req_line_attr_tbl.last,0);
l_qual_index	pls_integer := nvl(px_Req_qual_tbl.last,0);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_OE_AVAILABILITY.COPY_ATTRIBS_TO_REQ' , 1 ) ;
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
    oe_debug_pub.add(  'EXITING OE_OE_AVAILABILITY.COPY_ATTRIBS_TO_REQ' , 1 ) ;
END IF;

END copy_attribs_to_Req;




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
l_return_status out nocopy varchar2,

l_msg_count out nocopy number,

l_msg_data out nocopy varchar2

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
 and qppa.product_attr_value= g_panda_rec_table(1).p_inventory_item_id
 and qppa.excluder_flag = 'N'
 and qppa.list_header_id=qpq.list_header_id
 and qppa.list_line_id=qpll.list_line_id
 and  g_panda_rec_table(1).p_pricing_date between nvl(trunc(qplh.start_date_active),g_panda_rec_table(1).p_pricing_date)
 and nvl(trunc(qplh.End_date_active),g_panda_rec_table(1).p_pricing_date);

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
                          oe_debug_pub.add(  'INVALID PRICE LIST'|| ' PRICE_LIST_ID='||G_panda_rec_table(1).p_PRICE_LIST_ID ) ;
                      END IF;
      IF g_panda_rec_table(1).p_price_list_id is null then

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
      FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
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
        FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERRORS'); --bug#7149497
        FND_MESSAGE.SET_TOKEN('ERR_TEXT',in_status_text);
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
             WHERE inventory_item_id = g_inventory_item_id
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



PROCEDURE Get_modifier_name( in_list_header_id in number
,out_name out nocopy varchar2

,out_description out nocopy varchar2

,out_end_date out nocopy date

,out_start_date out nocopy date

,out_currency out nocopy varchar2

,out_ask_for_flag out nocopy varchar2

                           ) IS


l_list_type_code varchar2(300);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT name,
           description,
           list_type_code,
           end_date_active,
           start_date_active,
           currency_code,
           ask_for_flag
      INTO out_name,
           out_description,
           l_list_type_code,
           out_end_date,
           out_start_date,
           out_currency,
           out_ask_for_flag

      FROM qp_list_headers_vl
     WHERE list_header_id = in_list_header_id;


                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'END_DATE='||OUT_END_DATE|| ' START_DATE='||OUT_START_DATE ) ;
                     END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_AVA.GET_MODIFIER_NAME TYP='||L_LIST_TYPE_CODE ) ;
    END IF;

EXCEPTION
    when no_data_found then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_AVAILABILITY.GET_MODIFIER_NAME NO DATA FOUND' ) ;
        END IF;
    when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_AVAILABILITY.GET_MODIFIER_NAME WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
                        END IF;

END get_modifier_name;



PROCEDURE Get_list_line_details( in_list_line_id in number
,out_end_date out nocopy date

,out_start_date out nocopy date

,out_list_line_type_Code out nocopy varchar2

,out_modifier_level_code out nocopy varchar2

                           ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT
           list_line_type_code,
           end_date_active,
           start_date_active,
           modifier_level_code
      INTO
           out_list_line_type_code,
           out_end_date,
           out_start_date,
           out_modifier_level_code

      FROM qp_list_lines
     WHERE list_line_id = in_list_line_id;


                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'EXITING OE_AVA.GET_LINE_DETAILS TYPE='|| 'LIST_LINE_TYPE_CODE='|| OUT_LIST_LINE_TYPE_CODE|| 'END_DATE='||OUT_END_DATE|| ' START_DATE='||OUT_START_DATE ) ;
                     END IF;

EXCEPTION
    when no_data_found then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_AVAILABILITY.GET_LIST_LINE_DETAILS NO DATA FOUND' ) ;
        END IF;
    when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_AVAILABILITY.GET_LIST_LINE_DETAILS WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
                        END IF;

END get_list_line_details;


FUNCTION Get_qp_lookup_meaning( in_lookup_code in varchar2,
                                in_lookup_type in varchar2) return varchar2 IS

l_meaning varchar2(300);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CODE='||IN_LOOKUP_CODE||' TYPE='||IN_LOOKUP_TYPE ) ;
    END IF;

    SELECT meaning
      INTO l_meaning
      FROM qp_lookups
     WHERE lookup_type = in_lookup_type
       AND lookup_code = in_lookup_code;

    IF l_meaning = fnd_api.g_miss_char then
      l_meaning:= Null;
    END IF;

    Return l_meaning;

EXCEPTION
    when no_data_found then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_AVAILABILITY.GET_QP_LOOKUP_MEANING NO DATA FOUND' ) ;
        END IF;
        Return Null;

END get_qp_lookup_meaning;


FUNCTION get_pricing_attribute(
                       in_CONTEXT_NAME in varchar2,
                       in_ATTRIBUTE_NAME in varchar2
                                          ) return varchar2 IS
l_pricing_attribute varchar2(300);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'GET_PRICING_ATTRIBUTE '|| 'IN_CONTEXT = '||IN_CONTEXT_NAME|| 'IN_ATTRIBUTE_NAME='||IN_ATTRIBUTE_NAME ) ;
                    END IF;
    l_pricing_attribute := QP_UTIL.get_attribute_name(
              p_application_short_name=> 'QP',
              P_FLEXFIELD_NAME =>'QP_ATTR_DEFNS_PRICING',
              P_CONTEXT_NAME =>in_context_name,
              P_ATTRIBUTE_NAME =>in_attribute_name
                      );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING GET_PRICING_ATTRIBUTE ='||L_PRICING_ATTRIBUTE ) ;
    END IF;

    return l_pricing_attribute;

EXCEPTION

  WHEN others then
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WHEN OTHERS FOR GET_PRICING_ATTRIBUTE'|| SQLCODE||SQLERRM ) ;
                     END IF;
    return null;

END get_pricing_attribute;



PROCEDURE get_Price_List_info(
                          p_price_list_id IN  NUMBER,
out_name out nocopy varchar2,

out_end_date out nocopy date,

out_start_date out nocopy date,

out_automatic_flag out nocopy varchar2,

out_rounding_factor out nocopy varchar2,

out_terms_id out nocopy number,

out_gsa_indicator out nocopy varchar2,

out_currency out nocopy varchar2,

out_freight_terms_code out nocopy varchar2

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




PROCEDURE  get_item_information(
            in_inventory_item_id in number
           ,in_org_id in number
,out_item_status out nocopy varchar2

,out_wsh out nocopy varchar2

,out_wsh_name out nocopy varchar2

,out_category out nocopy varchar2

,out_lead_time out nocopy number

,out_cost out nocopy number

,out_primary_uom out nocopy varchar2

,out_user_item_type out nocopy varchar2

,out_make_or_buy out nocopy varchar2

,out_weight_uom out nocopy varchar2

,out_unit_weight out nocopy number

,out_volume_uom out nocopy varchar2

,out_unit_volume out nocopy number

,out_min_order_quantity out nocopy number

,out_max_order_quantity out nocopy number

,out_fixed_order_quantity out nocopy number

,out_customer_order_flag out nocopy varchar2

,out_internal_order_flag out nocopy varchar2

,out_stockable out nocopy varchar2

,out_reservable out nocopy varchar2

,out_returnable out nocopy varchar2

,out_shippable out nocopy varchar2

,out_orderable_on_web out nocopy varchar2

,out_taxable out nocopy varchar2

,out_serviceable out nocopy varchar2

,out_atp_flag out nocopy varchar2

          ) IS

  CURSOR c_item_info IS
    SELECT shippable_item_flag,
           customer_order_enabled_flag,
           internal_order_enabled_flag,
           stock_enabled_flag,
           default_shipping_org,
           returnable_flag,
           source_organization_id,
           unit_weight,
           weight_uom_code,
           unit_volume,
           volume_uom_code,
           cum_manufacturing_lead_time,
           cumulative_total_lead_time,
           primary_unit_of_measure,
           inventory_item_status_code,
           full_lead_time,
           order_cost,
           minimum_order_quantity,
           maximum_order_quantity,
           fixed_order_quantity,
           reservable_type,
           item_type,
           orderable_on_web_flag,
           planning_make_buy_code,
           taxable_flag ,
           serviceable_product_flag,
           atp_flag
      FROM mtl_system_items
     WHERE inventory_item_id = in_inventory_item_id
       AND organization_id   = in_org_id;

 l_default_shipping_org number;
 l_source_organization_id number;
 l_weight_uom_code varchar2(3);
 l_volumne_uom_code varchar2(3);
 l_cum_manufactureing_lead_time number;
 l_cummulative_total_lead_time number;
 l_inventory_item_status_code varchar2(10);
 l_full_lead_time number;
 l_order_cost number;
 l_reservable_type number;
 l_user_item_type varchar2(30);
 l_ship_from_org varchar2(200);
 l_ship_from_org_name varchar2(200);
 l_make_buy number;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ENTERING OE_OE_AVAILABILITY.GET_ITEM_INFO'||
					 'INV_ITEM_ID='||IN_INVENTORY_ITEM_ID|| 'ORG_ID='||IN_ORG_ID ) ;
                  END IF;

  OPEN  c_item_info;
  FETCH c_item_info
   INTO out_shippable,
        out_customer_order_flag,
        out_internal_order_flag,
        out_stockable,
        l_default_shipping_org,
        out_returnable,
        l_source_organization_id,
        out_unit_weight,
        l_weight_uom_code,
        out_unit_volume,
        l_volumne_uom_code,
        l_cum_manufactureing_lead_time,
        l_cummulative_total_lead_time,
        out_primary_uom,
        l_inventory_item_status_code,
        l_full_lead_time,
        l_order_cost,
        out_min_order_quantity,
        out_max_order_quantity,
        out_fixed_order_quantity,
        l_reservable_type,
        l_user_item_type,
        out_orderable_on_web,
        l_make_buy,
        out_taxable,
        out_serviceable,
        out_atp_flag;

  CLOSE c_item_Info;

  out_item_status := l_inventory_item_status_code;

  IF l_make_buy = 1 then
    out_make_or_buy := 'Make';
  ELSE
    out_make_or_buy := 'Buy';
  END IF;


  oe_oe_availability.get_Ship_From_Org
         (   in_org_id => in_org_id
         ,   out_code=>out_wsh
         ,   out_name =>out_wsh_name
          );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'USER_ITEM_TYPE='||L_USER_ITEM_TYPE ) ;
  END IF;

  out_lead_time := l_cummulative_total_lead_time;
  out_cost := l_order_cost;

  IF l_reservable_type = 1 then
    out_reservable := 'Y';
  ELSE
    out_reservable := 'N';

  END IF;

  IF l_user_item_type is NOT NULL then
    select meaning
      into out_user_item_type
      from fnd_common_lookups
     where lookup_type = 'ITEM_TYPE'
       and lookup_code = l_user_item_type;
  ELSE
    out_user_item_type := null;

  END IF;
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'EXITING OE_OE_AVAILABILITY.GET_ITEM_INFO'||
					 ' ITEM_STATUS ='||OUT_ITEM_STATUS ) ;
                  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF c_item_info%ISOPEN then
      CLOSE c_item_info;
    END IF;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'WHEN OTHERS OE_OE_AVAILABILITY.GET_ITEM_INFO '||
					    'INV_ITEM_ID='||IN_INVENTORY_ITEM_ID|| 'ORG_ID='||IN_ORG_ID||
					    'SQLCODE='||SQLCODE|| 'SQLERRM='||SQLERRM ) ;
                     END IF;

END get_item_information;



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
                          oe_debug_pub.add(  'TIME FROM ' ||G_PLACE||' TO '||IN_PLACE||
					     ' TIME DIFF='|| L_TOTAL||' SECONDS'||' TOTAL SO FAR='||G_TOTAL ) ;
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


PROCEDURE get_global_availability (
                in_customer_id in number
               ,in_customer_site_id in number
               ,in_inventory_item_id in number
               ,in_org_id            in number
               ,x_return_status out nocopy varchar2
               ,x_msg_data out nocopy varchar2
               ,x_msg_count out nocopy number
               ,l_source_orgs_table out nocopy source_orgs_table
                           )IS

l_instance_id number;
CURSOR c_instance_id IS
  SELECT instance_id,
         instance_code
    FROM mrp_ap_apps_instances;

l_mrp_atp_database_link varchar2(300);
x_assignment_set_id number;
x_assignment_set_name varchar2(300);
x_plan_id number;
x_plan_name varchar2(300);
x_ret_code varchar2(300);
x_err_mesg varchar2(2000);
l_session_id number;
--l_item_arr  mrp_atp_pub.number_arr := mrp_atp_pub.number_arr(1);
l_organization_id number;
x_sources mrp_atp_pvt.atp_source_typ;
l_calling_module number;
x_error_mesg varchar2(2000);
l_other_cols  order_sch_wb.other_cols_typ;
--l_source_orgs_table source_orgs_table;
l_count number := 1;
l_on_hand_qty number;
l_reservable_qty number;
l_available_qty    number;
l_ship_from_org_id number;
l_available_date   date;
l_qty_uom          varchar2(25);
l_out_message      varchar2(300);
l_return_status    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_error_message varchar2(2000);
l_org_id number;
l_customer_id number;
l_customer_site_id number;
l_ship_method varchar2(30);
l_dynstring           VARCHAR2(500) := NULL;
l_instance_code varchar2(100);

l_inv_ctp number;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

CURSOR c_temp_table(in_session_id in number) IS
  SELECT source_organization_id,
         sr_instance_id,
         ship_method,
         delivery_lead_time,
         freight_carrier
    FROM mrp_atp_schedule_temp
   WHERE session_id = in_session_id
     --AND status_flag = -99;
     AND status_flag = 22;

sql_stmt              VARCHAR2(3200);

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING GA IN_ORG_ID='||IN_ORG_ID|| ' IN_CUSTOMER_ID='||IN_CUSTOMER_ID
		       || ' IN_SITE_ID ='||IN_CUSTOMER_SITE_ID|| ' IN_ITEM_ID ='||IN_INVENTORY_ITEM_ID ) ;
  END IF;

  OPEN c_instance_id;
  FETCH c_instance_id
   INTO l_instance_id,
        l_instance_code;
  CLOSE c_instance_id;


  x_return_status := 'S';
  l_mrp_atp_database_link := fnd_profile.value('MRP_ATP_DATABASE_LINK');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'L_INSTANCE_ID='||L_INSTANCE_ID|| ' DB LINK='
		       ||L_MRP_ATP_DATABASE_LINK ||' Ins Code='||l_instance_code) ;
  END IF;

  msc_sch_wb.get_assignment_set(
         x_dblink        => l_mrp_atp_database_link
         ,x_assignment_set_id=>x_assignment_set_id
         ,x_assignment_set_name=>x_assignment_set_name
         ,x_plan_id            =>x_plan_id
         ,x_plan_name          =>x_plan_name
         ,x_sr_instance_id=>l_instance_id
         ,x_inst          =>'APPS'
         ,x_ret_code      =>x_return_status
         ,x_err_mesg      =>x_err_mesg
                        );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ASSIGNMENT_SET_ID='||X_ASSIGNMENT_SET_ID|| ' SET NAME='||
		       X_ASSIGNMENT_SET_NAME|| ' PLAN ID='||X_PLAN_ID|| ' PLAN NAME='
		       ||X_PLAN_NAME|| ' RET CODE='||X_RETURN_STATUS|| ' ERR MESG='||X_ERR_MESG ) ;
  END IF;

  IF nvl(x_return_status,'E') = 'E'
       and x_assignment_set_id is null  then

    x_msg_data := x_err_mesg;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNING IN GA 1' ) ;
    END IF;

    IF x_msg_data is not null then

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MSG DATA IS NOT NULL' ) ;
      END IF;
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('ONT','ONT_AVAIL_GENERIC');
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MSG DATA IS NOT NULL 2' ) ;
      END IF;
      FND_MESSAGE.SET_TOKEN('TEXT',x_msg_data);
      OE_MSG_PUB.Add;

    END IF;


  ELSE -- if get_assignment_set was sucessful


    SELECT mrp_atp_schedule_temp_s.nextval
      INTO l_session_id
      FROM dual;

    x_return_status := 'S';

    IF in_customer_site_id is not null and in_customer_id is not null then
      l_customer_id := in_customer_id;
      l_customer_site_id := in_customer_site_id;
      l_org_id := null;
    ELSE
      l_org_id := in_org_id;
      l_customer_id := null;
      l_customer_site_id := null;
    END IF;


    /*fnd_profile.get('INV_CTP',l_inv_ctp);
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Inventory Capable to Promise='||l_inv_ctp);
    END IF;

    --Profile Inventory Capable to Prmise
    -- 4= PDS and we need to select a plan_id for org-org sourcing
    -- 5= ODS and we need to pass -1 as plan_id
    IF l_inv_ctp = 5 then
      x_plan_id := -1;
    END IF;

    -- if destination is the org, then for looking at the sourcing rule
    -- we need to pass the plan_id from the planning server
    -- get_assignment_set currently does not return plan_id
    IF l_inv_ctp <> 5 AND
       l_org_id is not null and
      (l_customer_id is null and l_customer_site_id is null) then

      IF l_mrp_atp_database_link IS NOT NULL THEN
        l_dynstring := '@'||l_mrp_atp_database_link;
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Getting Plan Id dynamic string='||l_dynstring);
      END IF;

      sql_stmt :=
       ' SELECT '||
       ' mast.plan_id '||
       ' FROM msc_atp_plan_sn'||l_dynstring||' mast '||
       ' WHERE mast.sr_instance_id = :in_instance_id '||
       ' AND mast.sr_inventory_item_id = :in_inventory_item_id'||
       ' AND mast.organization_id = :in_org_id';

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Planning Sql='||sql_stmt);
      END IF;


      EXECUTE IMMEDIATE sql_stmt INTO x_plan_id
		using l_instance_id,in_inventory_item_id,l_org_id;


      IF x_plan_id is null then
        fnd_message.set_name('MSC', 'MSC_NO_PLANS_DEFINED');
        oe_msg_pub.add;
        x_return_status := 'E';
        oe_debug_pub.add('Plan Id NOT FOUND');
      END IF;

    END IF; -- if plan_id needs to be fetched */


    IF x_plan_id is null then
      x_plan_id := -1;
    END IF;

    -- if the plan was fetched and found then continue
    IF nvl(x_return_status,'E') <> 'E' then

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Before inserting into temp table '||
                ' instance_id='||l_instance_id||
                ' session_id='||l_session_id||
                ' inv_item_id='||in_inventory_item_id||
                ' customer_id='||l_customer_id||
                ' customer_site_id='||l_customer_site_id||
                ' org_id='||l_org_id||
                ' ship_method='||l_ship_method
                       );
    END IF;

    -- insert into mrp_atp_schedule_Temp
    INSERT INTO MRP_ATP_SCHEDULE_TEMP(
                  sr_instance_id,
                  session_id,
                  inventory_item_id,
                  organization_id,
                  scenario_id,
                  customer_id,
                  customer_site_id,
                  ship_method,
                  status_flag)
             VALUES
                  (l_instance_id,
                   l_session_id,
                   in_inventory_item_id,
                   l_org_id,
                   -1,
                   l_customer_id,
                   l_customer_site_id,
                   l_ship_method,
                   4
                  );


    IF l_debug_level  > 0 THEN
      print_time('Calling Get Supply Sources');
    END IF;

    msc_sch_wb.get_supply_sources_local(
                x_dblink=>l_mrp_atp_database_link,
		x_session_id=>l_session_id,
		x_sr_instance_id=>l_instance_id,
		x_assignment_set_id=>x_assignment_set_id,
		x_plan_id=>x_plan_id,
                x_calling_inst=>'APPS',
		x_ret_status=>x_return_status,
                x_error_mesg=>x_err_mesg);

    IF l_debug_level  > 0 THEN
      print_time('After Calling Get Supply Sources');

      oe_debug_pub.add(  ' After CALLing  get_supply_sources_local '||
                         ' status='||x_return_status||
                         ' message='||x_err_mesg);

    END IF;

    IF nvl(x_return_status,'S') <> 'S' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' ERROR IN CALL TO get_supply_sources_local');
      END IF;
      fnd_message.set_name('MSC', x_err_mesg);
      oe_msg_pub.add;

    ELSE

      IF x_return_status IS NULL THEN
        x_return_status := 'S';
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' SUCCESS IN CALL TO get_supply_sources_local');
      END IF;

      -- Read from mrp_atp_schedule_Temp
      -- Insert into l_sources_orgs_table org_id and instance_id
      -- delete from mrp_atp_schedule_temp

      FOR l_temp_rec in c_temp_table(l_session_id)
      LOOP
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' Reading data from temp table');
        END IF;
        l_source_orgs_table(l_count).org_id:=l_temp_rec.source_organization_id;
        l_source_orgs_table(l_count).instance_id:=l_temp_rec.sr_instance_id;
        l_source_orgs_table(l_count).ship_method:=l_temp_rec.ship_method;
        l_source_orgs_table(l_count).delivery_lead_time:=l_temp_rec.delivery_lead_time;
        l_source_orgs_table(l_count).freight_carrier:=l_temp_rec.freight_carrier;
        l_source_orgs_table(l_count).instance_code:=l_instance_code;
        l_count := l_count + 1;

      END LOOP;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' After Reading data from temp table');
      END IF;

      IF l_source_orgs_table.COUNT > 0 then
        FOR i in l_source_orgs_table.FIRST..l_source_orgs_table.LAST
        LOOP
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(' Record = '||i||
             ' org_id ='||l_source_orgs_table(i).org_id||
             ' instance_id ='||l_source_orgs_table(i).instance_id||
             ' ship_method ='||l_source_orgs_table(i).ship_method||
             ' del_lead_time ='||l_source_orgs_table(i).delivery_lead_time||
             ' Instance_Code ='||l_source_orgs_table(i).Instance_Code
                            );

          END IF;

        END LOOP;
      ELSE

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' THERE ARE NO SOURCES TO BE DISPLAYED ' ) ;
        END IF;
        x_return_status := 'E';
        x_error_mesg := 'MRP_ATP_NO_SOURCES';
        FND_MESSAGE.SET_NAME('MSC','MRP_ATP_NO_SOURCES');
        OE_MSG_PUB.Add;
        x_return_status := 'E';

      END IF; -- IF x_sources.organization_id.COUNT > 0

    END IF; -- if get_supply_sources is not successful

    --deleting from the temp table
    DELETE mrp_atp_schedule_temp
     WHERE session_id = l_session_id;

  END IF; -- if the fetching of plan was successful

  END IF; -- if get_assignment fails


  -- if it was a failure then we retrieve the message
  IF nvl(x_return_status,'E') <> 'S' then
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
      oe_debug_pub.add(  'EXITING GA' ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN OTHERS OF get_global_availability' ) ;
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
              'Get_Global_Availability');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_global_availability;



PROCEDURE different_uom(
                        in_org_id in number
                       ,in_ordered_uom in varchar2
                       ,in_pricing_uom in varchar2
,out_conversion_rate out nocopy number

                       )IS

CURSOR c_items IS
  SELECT primary_uom_code
    FROM mtl_system_items_b
   WHERE organization_id = in_org_id
     AND inventory_item_id = g_panda_rec_table(1).p_Inventory_item_id;

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
                      oe_debug_pub.add(  'ENTERING OE_AVAILABILITY.DIFFERENT_UOM'||
					 ' ORDERED_UOM ='||IN_ORDERED_UOM|| ' PRICING_UOM='||
					 IN_PRICING_UOM|| ' IN_INV_ITEM_ID='||
					 G_panda_rec_table(1).p_INVENTORY_ITEM_ID|| ' IN_ORG_ID='||IN_ORG_ID ) ;
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
     AND inventory_item_id = g_panda_rec_table(1).p_inventory_item_id;

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
     AND inventory_item_id = g_panda_rec_table(1).p_inventory_item_id;

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


PROCEDURE Call_mrp_and_inventory(
                        in_org_id in number
,out_on_hand_qty out nocopy number

,out_reservable_qty out nocopy number

,out_available_qty out nocopy varchar2

,out_available_date out nocopy date

,out_error_message out nocopy varchar2

,out_qty_uom out nocopy varchar2

                                ) IS

l_ship_from_org_id number;
l_out_message varchar2(4000);
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(4000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


    Query_Qty_Tree( p_org_id=>in_org_id
                   ,p_item_id=>g_panda_rec_table(1).p_inventory_item_id
                   ,p_sch_date=>g_panda_rec_table(1).p_request_date
                   ,x_on_hand_qty =>out_on_hand_qty
                   ,x_avail_to_reserve =>out_reservable_qty
                   );


    Call_MRP_ATP(
          in_global_orgs => 'Y'
         ,in_ship_from_org_id =>in_org_id
         ,out_available_qty => out_available_qty
         ,out_ship_from_org_id =>l_ship_from_org_id
         ,out_available_date  =>out_available_date
         ,out_qty_uom        =>out_qty_uom
         ,x_out_message      =>l_out_message
         ,x_return_status    =>l_return_status
         ,x_msg_count        =>l_msg_count
         ,x_msg_data         =>l_msg_data
         ,x_error_message    =>out_error_message
                );

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'L_RETURN_STATUS='||L_RETURN_STATUS|| ' OUT_AVAILABLE_QTY='||OUT_AVAILABLE_QTY|| ' L_OUT_MESSAGE='||L_OUT_MESSAGE|| ' OUT_ERROR_MESSAGE='||OUT_ERROR_MESSAGE ) ;
                    END IF;


                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'CALL_MRP_AND_INVENTORY'|| ' OUT_AVAILABLE_DATE ='||OUT_AVAILABLE_DATE|| ' OUT_AVAILABLE_QTY ='||OUT_AVAILABLE_QTY);
                        oe_debug_pub.add( ' OUT_ON_HAND_QTY ='||OUT_ON_HAND_QTY|| ' OUT_RESERVABLE_QTY ='||OUT_RESERVABLE_QTY|| ' OUT_ERROR_MESSAGE ='||OUT_ERROR_MESSAGE ) ;
                    END IF;

EXCEPTION
   WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'INSIDE CALL_MRP_AND_INVENTORY '|| SQLERRM||SQLERRM ) ;
                     END IF;

END call_mrp_and_inventory;



PROCEDURE set_mrp_debug(out_mrp_file out nocopy varchar2) IS


l_session_id number;
l_mrp_dir varchar2(200);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT mrp_atp_schedule_temp_s.nextval
      INTO l_session_id
      FROM dual;

    SELECT ltrim(rtrim(substr(value, instr(value,',',-1,1)+1)))
      INTO l_mrp_dir
      FROM v$parameter
     WHERE name='utl_file_dir';

    order_sch_wb.mr_debug := 'Y';
    order_sch_wb.debug_session_id := l_session_id;

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'MSC_ATP_DEBUG DIR='||L_MRP_DIR|| ' SESSION ID ='||L_SESSION_ID ) ;
                    END IF;
    l_mrp_dir := substr(l_mrp_dir,1,18);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'MSC_ATP_DEBUG DIR2='||L_MRP_DIR ) ;
    END IF;
    out_mrp_file := l_mrp_dir||'/session-'||l_session_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE_OE_AVAILABILITY.SET_MRP_DEBUG NO_DATA_FOUND' ) ;
    END IF;
  WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'WHEN OTHERS OE_OE_AVAILABILITY.SET_MRP_DEBUG '|| SQLCODE||SQLERRM ) ;
                    END IF;

END set_mrp_debug;


PROCEDURE copy_fields_to_globals(
                in_inventory_item_id      in number,
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
l_index number :=1;
BEGIN

   g_panda_rec_table.delete;


   l_index:=1;
   g_panda_rec_table(l_index).p_inventory_item_id := in_inventory_item_id;
   g_panda_rec_table(l_index).p_qty               := in_qty;
   g_panda_rec_table(l_index).p_uom               := in_uom;
   g_panda_rec_table(l_index).p_request_date      := in_request_date;
   g_panda_rec_table(l_index).p_customer_id       := in_customer_id;
   g_panda_rec_table(l_index).p_item_identIFier_type:= in_item_identifier_type;
   g_panda_rec_table(l_index).p_agreement_id      := in_agreement_id;
   g_panda_rec_table(l_index).p_price_list_id     := in_price_list_id;
   g_panda_rec_table(l_index).p_ship_to_org_id    := in_ship_to_org_id;
   g_panda_rec_table(l_index).p_invoice_to_org_id := in_invoice_to_org_id;
   g_panda_rec_table(l_index).p_ship_from_org_id  := in_ship_from_org_id;
   g_panda_rec_table(l_index).p_pricing_date      := in_pricing_date;
   g_panda_rec_table(l_index).p_order_type_id     := in_order_type_id;
   g_panda_rec_table(l_index).p_currency          := in_currency;
   g_panda_rec_table(l_index).p_pricing_context   := in_pricing_context;
   g_panda_rec_table(l_index).p_pricing_attribute1:= in_pricing_attribute1;
   g_panda_rec_table(l_index).p_pricing_attribute2:= in_pricing_attribute2;
   g_panda_rec_table(l_index).p_pricing_attribute3:= in_pricing_attribute3;
   g_panda_rec_table(l_index).p_pricing_attribute4:= in_pricing_attribute4;
   g_panda_rec_table(l_index).p_pricing_attribute5:= in_pricing_attribute5;
   g_panda_rec_table(l_index).p_pricing_attribute6:= in_pricing_attribute6;
   g_panda_rec_table(l_index).p_pricing_attribute7:= in_pricing_attribute7;
   g_panda_rec_table(l_index).p_pricing_attribute8:= in_pricing_attribute8;
   g_panda_rec_table(l_index).p_pricing_attribute9:= in_pricing_attribute9;
   g_panda_rec_table(l_index).p_pricing_attribute10  := in_pricing_attribute10;
   g_panda_rec_table(l_index).p_pricing_attribute11  := in_pricing_attribute11;
   g_panda_rec_table(l_index).p_pricing_attribute12  := in_pricing_attribute12;
   g_panda_rec_table(l_index).p_pricing_attribute13  := in_pricing_attribute13;
   g_panda_rec_table(l_index).p_pricing_attribute14  := in_pricing_attribute14;
   g_panda_rec_table(l_index).p_pricing_attribute15  := in_pricing_attribute15;
   g_panda_rec_table(l_index).p_pricing_attribute16  := in_pricing_attribute16;
   g_panda_rec_table(l_index).p_pricing_attribute17  := in_pricing_attribute17;
   g_panda_rec_table(l_index).p_pricing_attribute18  := in_pricing_attribute18;
   g_panda_rec_table(l_index).p_pricing_attribute19  := in_pricing_attribute19;
   g_panda_rec_table(l_index).p_pricing_attribute20  := in_pricing_attribute20;
   g_panda_rec_table(l_index).p_pricing_attribute21  := in_pricing_attribute21;
    g_panda_rec_table(l_index).p_pricing_attribute22  :=in_pricing_attribute22;
    g_panda_rec_table(l_index).p_pricing_attribute23  :=in_pricing_attribute23;
    g_panda_rec_table(l_index).p_pricing_attribute24  :=in_pricing_attribute24;
    g_panda_rec_table(l_index).p_pricing_attribute25  :=in_pricing_attribute25;
    g_panda_rec_table(l_index).p_pricing_attribute26  :=in_pricing_attribute26;
    g_panda_rec_table(l_index).p_pricing_attribute27  :=in_pricing_attribute27;
    g_panda_rec_table(l_index).p_pricing_attribute28  :=in_pricing_attribute28;
    g_panda_rec_table(l_index).p_pricing_attribute29  := in_pricing_attribute29;
    g_panda_rec_table(l_index).p_pricing_attribute30  := in_pricing_attribute30;
    g_panda_rec_table(l_index).p_pricing_attribute31  := in_pricing_attribute31;
    g_panda_rec_table(l_index).p_pricing_attribute32  := in_pricing_attribute32;
    g_panda_rec_table(l_index).p_pricing_attribute33  := in_pricing_attribute33;
    g_panda_rec_table(l_index).p_pricing_attribute34  := in_pricing_attribute34;
    g_panda_rec_table(l_index).p_pricing_attribute35  := in_pricing_attribute35;
    g_panda_rec_table(l_index).p_pricing_attribute36  := in_pricing_attribute36;
    g_panda_rec_table(l_index).p_pricing_attribute37  := in_pricing_attribute37;
    g_panda_rec_table(l_index).p_pricing_attribute38  := in_pricing_attribute38;
    g_panda_rec_table(l_index).p_pricing_attribute39  := in_pricing_attribute39;
    g_panda_rec_table(l_index).p_pricing_attribute40  := in_pricing_attribute40;
    g_panda_rec_table(l_index).p_pricing_attribute41  := in_pricing_attribute41;
    g_panda_rec_table(l_index).p_pricing_attribute42  := in_pricing_attribute42;
    g_panda_rec_table(l_index).p_pricing_attribute43  := in_pricing_attribute43;
    g_panda_rec_table(l_index).p_pricing_attribute44  := in_pricing_attribute44;
    g_panda_rec_table(l_index).p_pricing_attribute45  := in_pricing_attribute45;
    g_panda_rec_table(l_index).p_pricing_attribute46  := in_pricing_attribute46;
    g_panda_rec_table(l_index).p_pricing_attribute47  := in_pricing_attribute47;
    g_panda_rec_table(l_index).p_pricing_attribute48  := in_pricing_attribute48;
    g_panda_rec_table(l_index).p_pricing_attribute49  := in_pricing_attribute49;
    g_panda_rec_table(l_index).p_pricing_attribute50  := in_pricing_attribute50;
    g_panda_rec_table(l_index).p_pricing_attribute51  := in_pricing_attribute51;
    g_panda_rec_table(l_index).p_pricing_attribute52  := in_pricing_attribute52;
    g_panda_rec_table(l_index).p_pricing_attribute53  := in_pricing_attribute53;
    g_panda_rec_table(l_index).p_pricing_attribute54  := in_pricing_attribute54;
    g_panda_rec_table(l_index).p_pricing_attribute55  := in_pricing_attribute55;
    g_panda_rec_table(l_index).p_pricing_attribute56  := in_pricing_attribute56;
    g_panda_rec_table(l_index).p_pricing_attribute57  := in_pricing_attribute57;
    g_panda_rec_table(l_index).p_pricing_attribute58  := in_pricing_attribute58;
    g_panda_rec_table(l_index).p_pricing_attribute59  := in_pricing_attribute59;
    g_panda_rec_table(l_index).p_pricing_attribute60  := in_pricing_attribute60;
    g_panda_rec_table(l_index).p_pricing_attribute61  := in_pricing_attribute61;
    g_panda_rec_table(l_index).p_pricing_attribute62  := in_pricing_attribute62;
    g_panda_rec_table(l_index).p_pricing_attribute63  := in_pricing_attribute63;
    g_panda_rec_table(l_index).p_pricing_attribute64  := in_pricing_attribute64;
    g_panda_rec_table(l_index).p_pricing_attribute65  := in_pricing_attribute65;
    g_panda_rec_table(l_index).p_pricing_attribute66  := in_pricing_attribute66;
    g_panda_rec_table(l_index).p_pricing_attribute67  := in_pricing_attribute67;
    g_panda_rec_table(l_index).p_pricing_attribute68  := in_pricing_attribute68;
    g_panda_rec_table(l_index).p_pricing_attribute69  := in_pricing_attribute69;
    g_panda_rec_table(l_index).p_pricing_attribute70  := in_pricing_attribute70;
    g_panda_rec_table(l_index).p_pricing_attribute71  := in_pricing_attribute71;
    g_panda_rec_table(l_index).p_pricing_attribute72  := in_pricing_attribute72;
    g_panda_rec_table(l_index).p_pricing_attribute73  := in_pricing_attribute73;
    g_panda_rec_table(l_index).p_pricing_attribute74  := in_pricing_attribute74;
    g_panda_rec_table(l_index).p_pricing_attribute75  := in_pricing_attribute75;
    g_panda_rec_table(l_index).p_pricing_attribute76  := in_pricing_attribute76;
    g_panda_rec_table(l_index).p_pricing_attribute77  := in_pricing_attribute77;
    g_panda_rec_table(l_index).p_pricing_attribute78  := in_pricing_attribute78;
    g_panda_rec_table(l_index).p_pricing_attribute79  := in_pricing_attribute79;
    g_panda_rec_table(l_index).p_pricing_attribute80  := in_pricing_attribute80;
    g_panda_rec_table(l_index).p_pricing_attribute81  := in_pricing_attribute81;
    g_panda_rec_table(l_index).p_pricing_attribute82  := in_pricing_attribute82;
    g_panda_rec_table(l_index).p_pricing_attribute83  := in_pricing_attribute83;
    g_panda_rec_table(l_index).p_pricing_attribute84  := in_pricing_attribute84;
    g_panda_rec_table(l_index).p_pricing_attribute85  := in_pricing_attribute85;
    g_panda_rec_table(l_index).p_pricing_attribute86  := in_pricing_attribute86;
    g_panda_rec_table(l_index).p_pricing_attribute87  := in_pricing_attribute87;
    g_panda_rec_table(l_index).p_pricing_attribute88  := in_pricing_attribute88;
    g_panda_rec_table(l_index).p_pricing_attribute89  := in_pricing_attribute89;
    g_panda_rec_table(l_index).p_pricing_attribute90  := in_pricing_attribute90;
    g_panda_rec_table(l_index).p_pricing_attribute91  := in_pricing_attribute91;
    g_panda_rec_table(l_index).p_pricing_attribute92  := in_pricing_attribute92;
    g_panda_rec_table(l_index).p_pricing_attribute93  := in_pricing_attribute93;
    g_panda_rec_table(l_index).p_pricing_attribute94  := in_pricing_attribute94;
    g_panda_rec_table(l_index).p_pricing_attribute95  := in_pricing_attribute95;
    g_panda_rec_table(l_index).p_pricing_attribute96  := in_pricing_attribute96;
    g_panda_rec_table(l_index).p_pricing_attribute97  := in_pricing_attribute97;
    g_panda_rec_table(l_index).p_pricing_attribute98  := in_pricing_attribute98;
    g_panda_rec_table(l_index).p_pricing_attribute99  := in_pricing_attribute99;
    g_panda_rec_table(l_index).p_pricing_attribute100 := in_pricing_attribute100;

END copy_fields_to_globals;


END oe_oe_availability;

/
