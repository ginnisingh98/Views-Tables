--------------------------------------------------------
--  DDL for Package Body OE_OE_PRICING_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_PRICING_AVAILABILITY" AS
/* $Header: OEXFPRAB.pls 120.10.12010000.11 2010/02/03 10:04:25 aambasth ship $ */

  --Global variables

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'oe_oe_pricing_availability';
  G_ATP_TBL          OE_ATP.atp_tbl_type;
  g_order_source_id  CONSTANT NUMBER :=26;
  G_line_id          CONSTANT NUMBER :=1244;
  G_atp_line_id      CONSTANT NUMBER := -9987;
  g_header_id        CONSTANT NUMBER :=-2345; -- bug 8916379
  g_hsecs            number;
  g_place            varchar2(100);
  g_total            number :=0;
  g_total2           number ;
  global_line_index number;
  g_upgrade_item_exists varchar2(1):='N';
  g_upgrade_item_id number;
  g_upgrade_order_qty_uom varchar2(30);
  g_upgrade_ship_from_org_id number;

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
  g_promotions_tbl Promotions_Tbl;
  g_manual_modifier_tbl Manual_modifier_tbl;
  g_modf_attributes_tbl Modifier_attributes_Tbl;
  g_modf_rel_Tbl Modifier_assoc_Tbl;
  g_enforce_price_flag varchar2(2) :='N';
  g_applied_manual_tbl oe_oe_pricing_availability.number_type;

--Start of bug#7380336
  G_PR_AV  VARCHAR(20):= 'N';

 	   FUNCTION  IS_PRICING_AVAILIBILITY RETURN VARCHAR2
 	   IS

 	    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

 	   BEGIN
 	   IF l_debug_level > 0 THEN
 	      oe_debug_pub.add('In function IS_PRICING_AVAILIBILITY',1);
 	      oe_debug_pub.add('G_PR_AV ' || G_PR_AV);

 	   END IF;
 	   IF G_PR_AV = 'Y' THEN
 	     RETURN('Y') ;
 	   ELSE
 	     G_PR_AV := 'N';
 	     RETURN('N');
 	   END IF;
 	   G_PR_AV := 'N';
 	   RETURN('N')   ;

 	   END  IS_PRICING_AVAILIBILITY;    --End of bug#7380336


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
l_lookup_type VARCHAR2(50); -- added for bug 3776769
l_lookup_code NUMBER;

BEGIN

  x_return_status :=  'S';
  l_lookup_type := 'MTL_DEMAND_INTERFACE_ERRORS';  -- added for bug 3776769

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
          l_lookup_code := 80;
          select meaning
            into l_explanation
            from mfg_lookups
           where lookup_type = l_lookup_type
             and lookup_code = l_lookup_code;   -- added for bug 3776769


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SETTING THE MESSAGE FOR OE_SCH_NO_SOURCE' ) ;
          END IF;

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
          l_lookup_code := p_atp_rec.error_code(J) ;   -- added for bug 3776769
          select meaning
            into l_explanation
            from mfg_lookups
           where lookup_type = l_lookup_type
             and lookup_code =l_lookup_code;    -- added for bug 3776769

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

	    /* Added the following code to fix the bug 3245976 - issue 8 */

          ELSIF p_atp_rec.error_code(J) = 53 THEN

            x_return_status := 'E';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ERROR CODE = 53' ) ;
            END IF;

            FND_MESSAGE.SET_NAME('ONT','ONT_PRC_AVA_NO_REQUESTED_QTY');
            FND_MESSAGE.SET_TOKEN('PARTIAL_QUANTITY', p_atp_rec.requested_date_quantity(J));
            FND_MESSAGE.SET_TOKEN('REQUEST_DATE', p_atp_rec.requested_ship_date(J));
            FND_MESSAGE.SET_TOKEN('EARLIEST_DATE', p_atp_rec.ship_date(J));

	    g_mrp_error_msg :=FND_MESSAGE.GET;
	    g_mrp_error_msg_flag := 'T';

	    FND_MESSAGE.SET_NAME('ONT','ONT_PRC_AVA_NO_REQUESTED_QTY');
            FND_MESSAGE.SET_TOKEN('PARTIAL_QUANTITY', p_atp_rec.requested_date_quantity(J));
            FND_MESSAGE.SET_TOKEN('REQUEST_DATE', p_atp_rec.requested_ship_date(J));
            FND_MESSAGE.SET_TOKEN('EARLIEST_DATE', p_atp_rec.ship_date(J));

            IF in_global_orgs = 'N' then
	        OE_MSG_PUB.Add;
            ELSE
                x_error_message := fnd_message.get;
            END IF;

	/* End of code added to fix the bug 3245976 - issue 8 */

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
	     l_lookup_code := p_atp_rec.error_code(J) ;   -- added for bug 3776769
              select meaning
                into l_explanation
                from mfg_lookups
               where lookup_type =l_lookup_type
                 and lookup_code =l_lookup_code;   -- added for bug 3776769

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
   in_atp_rec.Demand_Class(I)            := g_panda_rec_table(1).p_demand_class_code; --null; --9218117
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

  IF   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
      AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 THEN
      in_atp_rec.Included_item_flag(I)  := 1; -- This has to be 1 since OM explodes included items before calling ATP.
     -- in_atp_rec.top_model_line_id(I)  := p_line_rec.top_model_line_id;
      in_atp_rec.validation_org(I) := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
 END IF;

   -- Call ATP
  -- Added to display upgraded item information
 IF  g_upgrade_item_exists ='Y' then

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('The Upgrade ITem Infomation before calling MRP');
       oe_debug_pub.add('Upgraded Item id'||g_upgrade_item_id);
       oe_debug_pub.add('Upgrade Order Uom'||g_upgrade_order_qty_uom);
       oe_debug_pub.add('Upgrade Ship from org'||g_upgrade_ship_from_org_id);
    END IF;

    IF	g_upgrade_ship_from_org_id is not null then
       in_atp_rec.Source_Organization_Id(1):= g_upgrade_ship_from_org_id;
    END IF;
    IF g_upgrade_item_id is not null then
       in_atp_rec.inventory_item_id(I):=g_upgrade_item_id;
    END IF;
    IF g_upgrade_order_qty_uom is not null then
       in_atp_rec.quantity_uom(I):=g_upgrade_order_qty_uom;
    END IF;

 END IF;

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

   /* Commented the following code to fix the bug 3245976 -- issue 8*/
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
     IF  nvl(x_atp_rec.available_quantity(1),0) = 0 then
	IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AVAILABLE QUANTITY IS 0' ) ;
	END IF;
     ELSE
	IF x_atp_rec.ship_date.COUNT > 0 THEN
           out_available_date    := x_atp_rec.ship_date(1);
	END IF;
	IF x_atp_rec.group_ship_date.COUNT > 0 THEN
           IF x_atp_rec.group_ship_date(1) is not null THEN
	      out_available_date  := x_atp_rec.group_ship_date(1);
           END IF;
	END IF;

     END IF;
     x_error_message := null;

   END IF; -- if return status is not P

   */
   /* End of code commented to fix the bug 3245976  - issue 8*/

   /* Added the following code to fix the bug 3245976 - issue 8 */

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

/* End of new code added to fix the bug 3245976 - issue 8 */

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

Procedure Enforce_price_list(in_order_type_id in number,
			     out_enforce_price_flag out nocopy varchar2)
IS
Begin
     select nvl(enforce_line_prices_flag,'N') into out_enforce_price_flag
       from oe_Order_types_v where Order_type_id=in_order_type_id;
   g_enforce_price_flag:= out_enforce_price_flag;
exception when no_data_found then
out_enforce_price_flag := 'N';
g_enforce_price_flag:= out_enforce_price_flag;
End Enforce_price_list;

Procedure Pass_Upgrade_information(in_upgrade_item_exists varchar2,
				   in_upgrade_item_id in number,
				   in_upgrade_order_qty_uom in varchar2,
				   in_upgrade_ship_from_org_id in number) IS
BEGIN
   g_upgrade_item_exists:=in_upgrade_item_exists;
   g_upgrade_item_id:=in_upgrade_item_id;
   g_upgrade_order_qty_uom:=in_upgrade_order_qty_uom;
   g_upgrade_ship_from_org_id:= in_upgrade_ship_from_org_id;
END Pass_Upgrade_information;


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

PROCEDURE defaulting(
                     in_source in varchar2,
                     in_out_default_rec  in out NOCOPY /* file.sql.39 change */ default_rec
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

   in_out_default_rec.created_by := FND_GLOBAL.user_id;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING DEFAULTING PROCEDURE');
      oe_debug_pub.add('SOURCE ='|| in_source);
      oe_debug_pub.add('VALUES PASSED');
      oe_debug_pub.add('************************************************');
      oe_debug_pub.add('ORG_ID ='|| in_out_default_rec.org_id);
      oe_debug_pub.add('SOLD_TO_ORG_ID =' || in_out_default_rec.sold_to_org_id);
      oe_debug_pub.add('INVENTORY_ITEM_ID ='|| in_out_default_rec.inventory_item_id);
      oe_debug_pub.add('ITEM_TYPE_CODE =' || in_out_default_rec.item_type_code);
      oe_debug_pub.add('USER_ID ='|| in_out_default_rec.user_id);
      oe_debug_pub.add('CREATED_BY ='|| in_out_default_rec.created_by);
      oe_debug_pub.add('SHIP_TO_ORG_ID =' || in_out_default_rec.ship_to_org_id);
      oe_debug_pub.add('ORDER_QUANTITY_UOM =' ||in_out_default_rec.order_quantity_uom);
      oe_debug_pub.add('LINE_TYPE_ID ='|| in_out_default_rec.line_type_id);
      oe_debug_pub.add('INVOICE_TO_ORG_ID = '|| in_out_default_rec.invoice_to_org_id);
      oe_debug_pub.add('DEMAND_CLASS_CODE = ' || in_out_default_rec.demand_class_code);
      oe_debug_pub.add('AGREEMENT_ID = ' || in_out_default_rec.agreement_id );
      oe_debug_pub.add('ORDER_TYPE_ID ='|| in_out_default_rec.order_type_id);
      oe_debug_pub.add('PRICE_LIST_ID = '|| in_out_default_rec.price_list_id);
      oe_debug_pub.add('SHIP_FROM_ORG_ID =' || in_out_default_rec.ship_from_org_id);
      oe_debug_pub.add('TRANSACTIONAL_CURR_CODE ='|| in_out_default_rec.transactional_curr_code);
      oe_debug_pub.add('REQUEST_DATE ='|| in_out_default_rec.request_date);
      oe_debug_pub.add('****************************************************************');
            END IF;

      IF in_source = 'ITEM' then

	 l_rec.inventory_item_id     := in_out_default_rec.inventory_item_id;
	 l_rec.org_id                := in_out_default_rec.org_id;
	 l_rec.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_rec.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_rec.created_by            := in_out_default_rec.created_by;
	 l_rec.agreement_id          := in_out_default_rec.agreement_id;
	 l_rec.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	 l_rec.request_date          := in_out_default_rec.request_date;
	 l_rec.price_list_id         := in_out_default_rec.price_list_id;
	 l_rec.line_type_id          := in_out_default_rec.line_type_id;
	 l_rec.demand_class_code     := in_out_default_rec.demand_class_code;
	 l_rec.ship_from_org_id      := FND_API.G_MISS_NUM;
	 l_rec.order_quantity_uom    := FND_API.G_MISS_CHAR;
	 l_out_rec := l_rec;


	 ONT_LINE_DEF_HDLR.Default_record(
					  p_x_rec => l_out_rec,
					  p_initial_rec =>l_rec,
					  p_in_old_rec  => l_old_rec
					  );

	 in_out_default_rec.ship_from_org_id := l_out_rec.ship_from_org_id;
	 in_out_default_rec.order_quantity_uom := l_out_rec.order_quantity_uom;


	 BEGIN
	      SELECT BOM_ITEM_TYPE,PICK_COMPONENTS_FLAG
		INTO l_bom_item_type,l_pick_components_flag
		FROM MTL_SYSTEM_ITEMS
	       WHERE INVENTORY_ITEM_ID= in_out_default_rec.inventory_item_id
		 AND ORGANIZATION_ID=in_out_default_rec.org_id;
	    IF l_bom_item_type=4 AND l_pick_components_flag='N' THEN
	       in_out_default_rec.item_type_code := 'STANDARD';
	    END IF;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       Null;

	    WHEN TOO_MANY_ROWS THEN

	       Null;

	    WHEN OTHERS THEN
	       Null;
	 END;


      ELSIF in_source = 'CUSTOMER' then

	 l_record.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_record.org_id                := in_out_default_rec.org_id;
	 l_record.transactional_curr_code := in_out_default_rec.transactional_curr_code;
	 l_record.created_by            := in_out_default_rec.created_by;
	 l_record.request_date          := in_out_default_rec.request_date;
	 l_record.demand_class_code     := in_out_default_rec.demand_class_code;
	 l_record.ship_To_org_id        := FND_API.G_MISS_NUM;
	 l_record.ship_from_org_id      := FND_API.G_MISS_NUM;
	 l_record.price_list_id         := FND_API.G_MISS_NUM;
	 l_record.order_type_id         := FND_API.G_MISS_NUM;
	 l_record.invoice_to_org_id     := FND_API.G_MISS_NUM;
	 l_record.agreement_id          := FND_API.G_MISS_NUM;
	 l_out_record := l_record;

	 ONT_HEADER_Def_Hdlr.Default_Record
	    ( p_x_rec       => l_out_record
	      , p_initial_rec => l_record
	      , p_in_old_rec	 => l_old_header_rec
	      , p_iteration	 => 1
	      );

	 in_out_default_rec.ship_from_org_id :=l_out_record.ship_from_org_id;
	 in_out_default_rec.price_list_id := l_out_record.price_list_id;
	 in_out_default_rec.order_type_id := l_out_record.order_type_id;
	 in_out_default_rec.invoice_to_org_id := l_out_record.invoice_to_org_id;
	 in_out_default_rec.agreement_id  := l_out_record.agreement_id;
	 in_out_default_rec.ship_to_org_id := l_out_record.ship_to_org_id;


      ELSIF in_source = 'SHIP_TO' then

	 l_record.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_record.org_id                := in_out_default_rec.org_id;
	 l_record.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_record.agreement_id          := in_out_default_rec.agreement_id;
	 l_record.created_by            := in_out_default_rec.created_by;
	 l_record.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	 l_record.transactional_curr_code := in_out_default_rec.transactional_curr_code;
	 l_record.request_date          := in_out_default_rec.request_date;
	 l_record.ship_from_org_id      := FND_API.G_MISS_NUM;
	 l_record.price_list_id         := FND_API.G_MISS_NUM;
	 l_record.order_type_id         := FND_API.G_MISS_NUM;
	 l_record.demand_class_code      := FND_API.G_MISS_CHAR;
	 l_record.invoice_to_org_id     := FND_API.G_MISS_NUM;

	 l_out_record := l_record;

	 ONT_HEADER_Def_Hdlr.Default_Record
	    ( p_x_rec       => l_out_record
	      , p_initial_rec => l_record
	      , p_in_old_rec	 => l_old_header_rec
	      , p_iteration	 => 1
	      );
	 in_out_default_rec.ship_from_org_id := l_out_record.ship_from_org_id;
	 in_out_default_rec.price_list_id    := l_out_record.price_list_id;
	 in_out_default_rec.order_type_id    := l_out_record.order_type_id;
	 in_out_default_rec.demand_class_code  := l_out_record.demand_class_code;
	 in_out_default_rec.invoice_to_org_id:= l_out_record.invoice_to_org_id;

      ELSIF in_source = 'BILL_TO' then

	 l_record.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_record.org_id                := in_out_default_rec.org_id;
	 l_record.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_record.agreement_id          := in_out_default_rec.agreement_id;
	 l_record.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	 l_record.transactional_curr_code := in_out_default_rec.transactional_curr_code;
	 l_record.ship_from_org_id      := in_out_default_rec.ship_from_org_id;
	 l_record.demand_class_code     := in_out_default_rec.demand_class_code;
	 l_record.created_by            := in_out_default_rec.created_by;
	 l_record.request_date          := in_out_default_rec.request_date;
	 l_record.price_list_id         := FND_API.G_MISS_NUM;
	 l_record.order_type_id         := FND_API.G_MISS_NUM;
	 l_out_record := l_record;

	 ONT_HEADER_Def_Hdlr.Default_Record
	    ( p_x_rec       => l_out_record
	      , p_initial_rec => l_record
	      , p_in_old_rec	 => l_old_header_rec
	      , p_iteration	 => 1
	      );

	 in_out_default_rec.price_list_id := l_out_record.price_list_id;
	 in_out_default_rec.order_type_id := l_out_record.order_type_id;

      ELSIF in_source = 'AGREEMENT' then


	 l_rec.agreement_id          := in_out_default_rec.agreement_id;
	 l_rec.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_rec.inventory_item_id     := in_out_default_rec.inventory_item_id;
	 l_rec.request_date          := in_out_default_rec.request_date;
	 l_rec.line_type_id          := in_out_default_rec.line_type_id;
	 l_rec.ship_from_org_id      := in_out_default_rec.ship_from_org_id;
	 l_rec.order_quantity_uom    := in_out_default_rec.order_quantity_uom;
	 l_rec.demand_class_code     := in_out_default_rec.demand_class_code;
	 l_rec.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_rec.org_id                := in_out_default_rec.org_id;
	 l_rec.created_by            := in_out_default_rec.created_by;
	 l_rec.price_list_id         := FND_API.G_MISS_NUM;
	 l_rec.invoice_to_org_id     := FND_API.G_MISS_NUM;
	 l_out_rec := l_rec;



	 ONT_LINE_DEF_HDLR.Default_record(
					  p_x_rec => l_out_rec,
					  p_initial_rec =>l_rec,
					  p_in_old_rec  => l_old_rec
					  );
	 in_out_default_rec.price_list_id := l_out_rec.price_list_id;
	 in_out_default_rec.invoice_to_org_id := l_out_rec.invoice_to_org_id;

	 --bug 4517640
	 l_record.agreement_id          := in_out_default_rec.agreement_id;
	 l_record.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_record.request_date          := in_out_default_rec.request_date;
	 l_record.ship_from_org_id      := in_out_default_rec.ship_from_org_id;
	 l_record.demand_class_code     := in_out_default_rec.demand_class_code;
	 l_record.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_record.org_id                := in_out_default_rec.org_id;
	 l_record.created_by            := in_out_default_rec.created_by;
	 l_record.price_list_id         := in_out_default_rec.price_list_id;
	 l_record.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	 l_record.transactional_curr_code :=FND_API.G_MISS_CHAR;
	 l_out_record := l_record;

          ONT_HEADER_Def_Hdlr.Default_Record
	    ( p_x_rec       => l_out_record
	      , p_initial_rec => l_record
	      , p_in_old_rec	 => l_old_header_rec
	      , p_iteration	 => 1
	     );
	 in_out_default_rec.transactional_curr_code :=l_out_record.transactional_curr_code;

	 --end 4517640

      ELSIF in_source = 'ORDER_TYPE' then

	 l_record.org_id                := in_out_default_rec.org_id;
	 l_record.order_type_id         := in_out_default_rec.order_type_id;
	 l_record.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_record.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_record.agreement_id          := in_out_default_rec.agreement_id;
	 l_record.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	 l_record.created_by            := in_out_default_rec.created_by;
	 l_record.request_date          := in_out_default_rec.request_date;
	 --Bug 7347299
	 l_record.conversion_type_code := FND_API.G_MISS_CHAR;

	 l_record.demand_class_code     := FND_API.G_MISS_CHAR;
	 l_record.price_list_id         := FND_API.G_MISS_NUM;
	 l_record.ship_from_org_id      := FND_API.G_MISS_NUM;
	 l_record.transactional_curr_code := FND_API.G_MISS_CHAR;
	 l_out_record := l_record;


	 ONT_HEADER_Def_Hdlr.Default_Record
	    ( p_x_rec       => l_out_record
	      , p_initial_rec => l_record
	      , p_in_old_rec	 => l_old_header_rec
	      , p_iteration	 => 1
	      );


	 in_out_default_rec.demand_class_code := l_out_record.demand_class_code;
	 in_out_default_rec.price_list_id := l_out_record.price_list_id;
	 in_out_default_rec.ship_from_org_id := l_out_record.ship_from_org_id;
	 in_out_default_rec.transactional_curr_code := l_out_record.transactional_curr_code;
	 --Bug 7347299
         in_out_default_rec.conversion_type_code := l_out_record.conversion_type_code;


      ELSIF in_source ='LINE_TYPE' then

	 l_rec.agreement_id          := in_out_default_rec.agreement_id;
	 l_rec.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	 l_rec.inventory_item_id     := in_out_default_rec.inventory_item_id;
	 l_rec.request_date          := in_out_default_rec.request_date;
	 l_rec.line_type_id          := in_out_default_rec.line_type_id;
	 l_rec.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	 l_rec.order_quantity_uom    := in_out_default_rec.order_quantity_uom;
	 l_rec.created_by            := in_out_default_rec.created_by;
	 l_rec.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	 l_rec.org_id                := in_out_default_rec.org_id;

	 l_rec.price_list_id         := FND_API.G_MISS_NUM;
	 l_rec.ship_from_org_id   := FND_API.G_MISS_NUM;
	 l_rec.demand_class_code   := FND_API.G_MISS_CHAR;
	 l_out_rec := l_rec;

	 ONT_LINE_DEF_HDLR.Default_record(
					  p_x_rec => l_out_rec,
					  p_initial_rec =>l_rec,
					  p_in_old_rec  => l_old_rec
					  );

	 in_out_default_rec.price_list_id := l_out_rec.price_list_id;
	 in_out_default_rec.ship_from_org_id := l_out_rec.ship_from_org_id;
	 in_out_default_rec.demand_class_code := l_out_rec.demand_class_code;

      ELSIF in_source = 'PRICE_LIST' then

	 IF  UPPER(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED')) NOT  IN ('Y', 'YES') THEN

	    l_record.org_id                := in_out_default_rec.org_id;
	    l_record.order_type_id         := in_out_default_rec.order_type_id;
	    l_record.sold_to_org_id        := in_out_default_rec.sold_to_org_id;
	    l_record.ship_to_org_id        := in_out_default_rec.ship_to_org_id;
	    l_record.agreement_id          := in_out_default_rec.agreement_id;
	    l_record.invoice_to_org_id     := in_out_default_rec.invoice_to_org_id;
	    l_record.created_by            := in_out_default_rec.created_by;
	    l_record.request_date          := in_out_default_rec.request_date;

	    l_record.demand_class_code     := in_out_default_rec.demand_class_code;
	    l_record.price_list_id         := in_out_default_rec.price_list_id;
	    l_record.ship_from_org_id      := in_out_default_rec.ship_from_org_id;

	    l_record.transactional_curr_code := FND_API.G_MISS_CHAR;
	    l_out_record := l_record;
	    ONT_HEADER_Def_Hdlr.Default_Record
	       ( p_x_rec       => l_out_record
		 , p_initial_rec => l_record
		 , p_in_old_rec	 => l_old_header_rec
		 , p_iteration	 => 1
		 );


	    in_out_default_rec.transactional_curr_code := l_out_record.transactional_curr_code;

	 END IF;

      ELSIF in_source = 'STARTUP' then

	 l_record.org_id                := in_out_default_rec.org_id;
	 l_record.created_by            := in_out_default_rec.created_by;
	 l_record.request_date          := in_out_default_rec.request_date;
	-- for line level defaulting
	 l_rec.org_id                := in_out_default_rec.org_id;
	 l_rec.created_by            := in_out_default_rec.created_by;
	 l_rec.request_date          := in_out_default_rec.request_date;



	 l_record.price_list_id         := FND_API.G_MISS_NUM;
	 l_record.ship_from_org_id      := FND_API.G_MISS_NUM;
	 l_record.order_type_id         := FND_API.G_MISS_NUM;
	 l_record.agreement_id          := FND_API.G_MISS_NUM;
	 l_record.demand_class_code     := FND_API.G_MISS_CHAR;
	 l_record.transactional_curr_code := FND_API.G_MISS_CHAR;
	 l_record.invoice_to_org_id     := FND_API.G_MISS_NUM;
	 l_record.ship_to_org_id        := FND_API.G_MISS_NUM;
         l_record.sold_to_org_id        := FND_API.G_MISS_NUM;
	 --Bug 7347299
         l_record.conversion_type_code := FND_API.G_MISS_CHAR;

	 l_out_record := l_record;

          ONT_HEADER_Def_Hdlr.Default_Record
	    ( p_x_rec       => l_out_record
	      , p_initial_rec => l_record
	      , p_in_old_rec	 => l_old_header_rec
	      , p_iteration	 => 1
	      );

	  in_out_default_rec.ship_from_org_id := l_out_record.ship_from_org_id;
	  in_out_default_rec.price_list_id    := l_out_record.price_list_id;
	  in_out_default_rec.order_type_id := l_out_record.order_type_id;
	  in_out_default_rec.agreement_id := l_out_record.agreement_id;
	  in_out_default_rec.demand_class_code := l_out_record.demand_class_code;
	  in_out_default_rec.transactional_curr_code := l_out_record.transactional_curr_code;
	  in_out_default_rec.invoice_to_org_id := l_out_record.invoice_to_org_id;
	  in_out_default_rec.ship_to_org_id   := l_out_record.ship_to_org_id;
	  in_out_default_rec.sold_to_org_id    := l_out_record.sold_to_org_id;
          --Bug 7347299
          in_out_default_rec.conversion_type_code := l_out_record.conversion_type_code;
	 -- code added to get the item identifier type

	  l_rec.agreement_id          := FND_API.G_MISS_NUM;
	  l_rec.ship_to_org_id        := FND_API.G_MISS_NUM;
	  l_rec.inventory_item_id     := FND_API.G_MISS_NUM;
	  l_rec.line_type_id          := FND_API.G_MISS_NUM;
	  l_rec.invoice_to_org_id     := FND_API.G_MISS_NUM;
	  l_rec.order_quantity_uom    := FND_API.G_MISS_CHAR;
	  l_rec.sold_to_org_id        :=FND_API.G_MISS_NUM;
	  l_rec.price_list_id         := FND_API.G_MISS_NUM;
	  l_rec.ship_from_org_id   := FND_API.G_MISS_NUM;
	  l_rec.demand_class_code   := FND_API.G_MISS_CHAR;
	  l_rec.item_identifier_type := FND_API.G_MISS_CHAR;
	  l_out_rec := l_rec;

	  ONT_LINE_DEF_HDLR.Default_record(
					  p_x_rec => l_out_rec,
					  p_initial_rec =>l_rec,
					  p_in_old_rec  => l_old_rec
					  );


	 in_out_default_rec.item_type_code := l_out_rec.item_identifier_type;


      END IF; -- in source_type

      IF l_debug_level  > 0 THEN

	 oe_debug_pub.add('VALUES RETURNED FROM DEFAULTING');
	 oe_debug_pub.add('************************************************');
	 oe_debug_pub.add('SOLD_TO_ORG_ID =' || in_out_default_rec.sold_to_org_id);
	 oe_debug_pub.add('ITEM_TYPE_CODE =' || in_out_default_rec.item_type_code);
	 oe_debug_pub.add('SHIP_TO_ORG_ID =' || in_out_default_rec.ship_to_org_id);
	 oe_debug_pub.add('ORDER_QUANTITY_UOM =' ||in_out_default_rec.order_quantity_uom);
	 oe_debug_pub.add('LINE_TYPE_ID ='|| in_out_default_rec.line_type_id);
	 oe_debug_pub.add('INVOICE_TO_ORG_ID = '|| in_out_default_rec.invoice_to_org_id);
	 oe_debug_pub.add('DEMAND_CLASS_CODE = ' || in_out_default_rec.demand_class_code);
	 oe_debug_pub.add('AGREEMENT_ID = ' || in_out_default_rec.agreement_id );
	 oe_debug_pub.add('ORDER_TYPE_ID ='|| in_out_default_rec.order_type_id);
	 oe_debug_pub.add('PRICE_LIST_ID = '|| in_out_default_rec.price_list_id);
	 oe_debug_pub.add('SHIP_FROM_ORG_ID =' || in_out_default_rec.ship_from_org_id);
	 oe_debug_pub.add('TRANSACTIONAL_CURR_CODE ='|| in_out_default_rec.transactional_curr_code);
	 oe_debug_pub.add('****************************************************************');
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

PROCEDURE get_sold_to_org(in_org_id in number,
			  out_name out nocopy varchar2,
                           out_cust_id out nocopy  number
                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT p.party_name,p.party_id
      INTO out_name,out_cust_id
      FROM hz_parties p ,hz_cust_accounts c
     WHERE p.party_id=c.party_id and c.cust_account_id = in_org_id;

EXCEPTION
WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_SHIP_FROM_ORG WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;

END get_sold_to_org;

--bug5621717
PROCEDURE get_sold_to_org(in_org_id in number,
			  out_name out nocopy varchar2,
                           out_cust_id out nocopy  varchar2
                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT p.party_name,c.ACCOUNT_NUMBER
      INTO out_name,out_cust_id
      FROM hz_parties p ,hz_cust_accounts c
     WHERE p.party_id=c.party_id and c.cust_account_id = in_org_id;

EXCEPTION
WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_SHIP_FROM_ORG WHEN OTHERS varchar-'|| SQLCODE||SQLERRM ) ;
                     END IF;

END get_sold_to_org;

PROCEDURE get_ship_to_org(in_org_id in number,
			  out_name out nocopy varchar2

                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT name
      INTO out_name
      FROM oe_ship_to_orgs_v
     WHERE organization_id = in_org_id;

EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_SHIP_TO_ORG WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;

END get_ship_to_org;


PROCEDURE get_order_type(in_order_type_id in number,
			 out_name out nocopy varchar2

                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT  name
      INTO  out_name
      FROM oe_order_types_v
     WHERE order_type_id = in_order_type_id;

EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_ORDER_TYPE WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;


END get_order_type;




PROCEDURE get_currency_name(in_transactional_curr_code in varchar2,
			 out_name out nocopy varchar2

                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_temp varchar2(30);
--
BEGIN
    if l_debug_level > 0 then
       oe_debug_pub.add('entering transactional curency with currency code'||in_transactional_curr_code);
       end if;
l_temp := UPPER(in_transactional_curr_code)||'%';
     SELECT  name
      INTO  out_name
      FROM fnd_currencies_vl
     WHERE currency_code like  l_temp;

EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_CURRENCY WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;

END get_currency_name;


PROCEDURE get_demand_class(in_demand_class_code in varchar2,
			 out_name out nocopy varchar2

                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_temp  varchar2(30);
--
BEGIN
    if l_debug_level > 0 then
      oe_Debug_pub.add('entering demand class doe with'||in_demand_class_code);
      end if;
l_temp:= UPPER(in_demand_class_code)||'%';

     SELECT  demand_class
      INTO  out_name
      FROM oe_demand_classes_v
     WHERE demand_class_code like l_temp;
	   EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_DEMAND_CLASS WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;


END get_demand_class;

PROCEDURE get_invoice_to_org(in_bill_to_org_id in number,
			 out_name out nocopy varchar2

                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT  name
      INTO  out_name
      FROM oe_invoice_to_orgs_v
     WHERE organization_id = in_bill_to_org_id;

EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_INVOICE_TO_ORG WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;


END get_invoice_to_org;

PROCEDURE get_agreement_name(in_agreement_id in number,
			 out_name out nocopy varchar2

                           )IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT  agreement_name
      INTO  out_name
      FROM oe_agreements_lov_v
     WHERE agreement_id = in_agreement_id;

EXCEPTION

WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'GET_AGREEMENT_NAME  WHEN OTHERS '|| SQLCODE||SQLERRM ) ;
                     END IF;


END get_agreement_name;






procedure copy_Header_to_request(
				 p_request_type_code in varchar2
				 ,p_calculate_price_flag in varchar2
				-- ,px_req_line_tbl   in out nocopy	QP_PREQ_GRP.LINE_TBL_TYPE
                                ,px_req_line_tbl   in out nocopy	oe_oe_pricing_availability.QP_LINE_TBL_TYPE
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
      oe_debug_pub.add(  'EXITING oe_oe_pricing_availability.COPY_HEADER_TO_REQUEST' ) ;
   END IF;

END copy_Header_to_request;


PROCEDURE copy_Line_to_request(
			      -- px_req_line_tbl   in out nocopy QP_PREQ_GRP.LINE_TBL_TYPE
                                px_req_line_tbl   in out nocopy oe_oe_pricing_availability.QP_LINE_TBL_TYPE
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
   global_line_index:=l_line_index;
--   px_req_line_tbl(l_line_index).Line_id := g_line_id;
   px_req_line_tbl(l_line_index).Line_id := g_panda_rec_table(p_line_index).p_line_id;
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

   /* Rounding factor is not needed now as it willbe calculated in QP since the rounding
   flag passed in control req is 'Q'. Bug fix for issue 5893353 --FP bug 7363233 smbalara
   --If G_ROUNDING_FLAG = 'Y' Then
   px_req_line_tbl(l_line_index).Rounding_factor :=
      Get_Rounding_factor(g_panda_rec_table(p_line_index).p_price_list_id);
   --End If;
   */

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
   If l_debug_level >0 then
   oe_debug_pub.add('********Temp tables population for lines **************');
   oe_debug_pub.add('LINE INDEX'||l_line_index);
   END IF;

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

--start 3471501
      --G_PRICE_LIST_ID_TBL(l_line_index)                 :=g_panda_rec_table(1).p_price_list_id;

   G_PRICE_LIST_ID_TBL(l_line_index)          :=g_panda_rec_table(p_line_index).p_price_list_id;

 --end 3471501

   G_PL_VALIDATED_FLAG_TBL(l_line_index)                := 'N';
   G_PRICE_REQUEST_CODE_TBL(l_line_index)        := NULL;
   G_USAGE_PRICING_TYPE_TBL(l_line_index)        :='REGULAR';
   G_UPD_ADJUSTED_UNIT_PRICE_TBL(l_line_index) :=NULL;
   G_LINE_CATEGORY_TBL(l_line_index) := NULL;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING oe_oe_pricing_availability.COPY_LINE_TO_REQUEST' , 1 ) ;
  END IF;

END copy_Line_to_request;



PROCEDURE set_pricing_control_record (
				      l_Control_Rec  in out NOCOPY /* file.sql.39 change */ oe_oe_pricing_availability.QP_CONTROL_RECORD_TYPE
				      ,in_pricing_event in varchar2)IS

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   if g_enforce_price_flag ='Y' then
      l_control_rec.pricing_event := 'PRICE';
   else
      l_control_rec.pricing_event    := in_pricing_event;
   end if;
   l_Control_Rec.calculate_flag   := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
   l_control_rec.simulation_flag  := 'Y';

   l_control_rec.gsa_check_flag := 'Y';
   l_control_rec.gsa_dup_check_flag := 'Y';
   --newly added
   l_control_rec.temp_table_insert_flag := 'N';
   l_control_rec.request_type_code := 'ONT';
  --l_control_rec.request_type_code := 'ASO';
   l_control_rec.rounding_flag := 'Q';
   l_control_rec.use_multi_currency:='Y';
   l_control_rec.SOURCE_ORDER_AMOUNT_FLAG := 'Y';   -- bug 5965668--FP bug 7491750 smbalara

END set_pricing_control_record;

Procedure copy_control_rec(in_Control_Rec  in  oe_oe_pricing_availability.QP_CONTROL_RECORD_TYPE,
			   x_Control_Rec   out NOCOPY /* file.sql.39 change */ QP_PREQ_GRP.CONTROL_RECORD_TYPE) IS

Begin
   x_control_rec.pricing_event :=	    in_control_rec.pricing_event;
   x_Control_Rec.calculate_flag  := 	    in_control_Rec.calculate_flag;
   x_control_rec.simulation_flag:=  	    in_control_rec.simulation_flag;
   x_control_rec.gsa_check_flag :=	    in_control_rec.gsa_check_flag;
   x_control_rec.gsa_dup_check_flag := 	    in_Control_rec.gsa_dup_check_flag;
   x_control_rec.temp_table_insert_flag :=  in_control_rec.temp_table_insert_flag;
   x_control_rec.request_type_code := 	    in_control_rec.request_type_code;
   x_control_rec.rounding_flag :=	    in_control_rec.rounding_flag;
   x_control_rec.use_multi_currency:=	    in_Control_rec.use_multi_currency;
   x_control_rec.SOURCE_ORDER_AMOUNT_FLAG :=in_Control_rec.SOURCE_ORDER_AMOUNT_FLAG;  -- bug 5965668--FP bug 7491750 smbalara


End copy_control_rec;


PROCEDURE build_context_for_line(
        p_req_line_tbl_count in number,
        p_price_request_code in varchar2,
        p_item_type_code in varchar2,
        p_Req_line_attr_tbl in out nocopy  oe_oe_pricing_availability.QP_LINE_ATTR_TBL_TYPE,
        p_Req_qual_tbl in out  nocopy  oe_oe_pricing_availability.QP_QUAL_TBL_TYPE,
	p_line_index in number
       )IS

qp_attr_mapping_error exception;
l_master_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_org_id Number;
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

 -- added for bug 5645866/5847803
      l_org_id := OE_GLOBALS.G_ORG_ID;
      IF l_org_id IS NULL THEN
         OE_GLOBALS.Set_Context;
         l_org_id := OE_GLOBALS.G_ORG_ID;
      END IF;

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ORG_ID='||L_ORG_ID|| ' PRICING_DATE='||
					 G_panda_rec_table(p_line_index).p_PRICING_DATE|| ' INV ITEM_IE='
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
  oe_order_pub.g_line.line_type_id       := g_panda_rec_table(p_line_index).p_line_type_id;
  oe_order_pub.g_line.item_identifier_type := g_panda_rec_table(p_line_index).p_item_identifier_type;
  oe_order_pub.g_line.ordered_item_id := g_panda_rec_table(p_line_index).p_ordered_item_id;
  --oe_order_pub.g_line.line_id            := g_line_id;
  oe_order_pub.g_line.line_id            := g_panda_rec_table(p_line_index).p_line_id;
  oe_order_pub.g_line.header_id          := g_header_id;
  oe_order_pub.g_line.item_type_code     := p_item_type_code;
  oe_order_pub.g_line.price_list_id      := g_panda_rec_table(p_line_index).p_price_list_id;
  oe_order_pub.g_line.sold_to_org_id     := g_panda_rec_table(p_line_index).p_customer_id;
  oe_order_pub.g_line.price_request_code := p_price_request_code;
  oe_order_pub.g_line.order_quantity_uom := g_panda_rec_table(p_line_index).p_uom;
  -- Added for the bug 4150554
  oe_order_pub.g_line.ship_from_org_id := g_panda_rec_table(p_line_index).p_ship_from_org_id;

  --BUG#7671483
    /*The change is done to fetch the Order_category_code based on Order_Type
    As Order_Category is directly related to Order_Type so if Order_Type is
    mentioned the corresponding Order_Category should be determined and
    interfaced to Pricing*/
    oe_order_pub.g_hdr.order_type_id      := g_panda_rec_table(p_line_index).p_order_type_id;

    oe_debug_pub.add('order_type_id' || oe_order_pub.g_hdr.order_type_id);

    oe_order_pub.g_hdr.order_category_code := OE_Header_Util.Get_Order_Type(g_panda_rec_table(1).p_order_type_id);

    oe_debug_pub.add('order_category_code' || oe_order_pub.g_hdr.order_category_code);
    oe_debug_pub.add('in line' ||g_panda_rec_table(p_line_index).p_order_type_id );
  --BUG#7671483


  IF g_panda_rec_table(p_line_index).p_item_identifier_type ='INT' then

     SELECT concatenated_segments
       INTO  oe_order_pub.g_line.ordered_item
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = g_panda_rec_table(p_line_index).p_inventory_item_id
       AND    organization_id = l_master_org_id; -- bug 5645866/5847803

  End IF;

  QP_Attr_Mapping_PUB.Build_Contexts(
     p_request_type_code => 'ONT',
     p_line_index =>global_line_index,
     p_pricing_type_code =>'L',
     p_check_line_flag => 'N',
     p_pricing_event =>'BATCH',
     x_pass_line =>l_pass_line);


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
        p_Req_line_attr_tbl in out nocopy  oe_oe_pricing_availability.QP_LINE_ATTR_TBL_TYPE,
        p_Req_qual_tbl in out  nocopy  oe_oe_pricing_availability.QP_QUAL_TBL_TYPE
       )IS

qp_attr_mapping_error exception;
-- l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_org_id Number;
p_pricing_contexts_Tbl	  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS FOR HEADER' , 1 ) ;
  END IF;

-- bug 5645866/5847803
    l_org_id := OE_GLOBALS.G_ORG_ID;
    IF l_org_id IS NULL THEN
       OE_GLOBALS.Set_Context;
       l_org_id := OE_GLOBALS.G_ORG_ID;
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



     QP_ATTR_Mapping_PUB.Build_Contexts(
          p_request_type_code =>'ONT',
          p_line_index =>1,
          p_pricing_type_code =>'H');



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
			     ,px_Req_line_attr_tbl in out nocopy  oe_oe_pricing_availability.QP_LINE_ATTR_TBL_TYPE
			     ,px_Req_qual_tbl in out nocopy  oe_oe_pricing_availability.QP_QUAL_TBL_TYPE
			     ,p_g_line_index in number

			     ) is

   i	pls_integer;

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

      --
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING oe_oe_pricing_availability.APPEND_ATTRIBUTES'||
                         ' p_line_id='||p_line_id);
   END IF;

    -- if line_id is not null, this does not apply to header level
   IF p_line_id is not null then

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'appending main attributes');
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

   end if; -- if line_id is not null

   oe_debug_pub.add(' p_line_id='||p_line_id||
                    ' promo count='||g_promotions_tbl.COUNT
                    );

   IF p_line_id is not null and g_promotions_tbl.COUNT > 0 then

   FOR k in g_promotions_tbl.first..g_promotions_tbl.last
   LOOP

     oe_debug_pub.add('promo line_id='||g_promotions_tbl(k).p_line_id||
                      ' p_level='||g_promotions_tbl(k).p_level||
                      ' p_line_id='||p_line_id);


   IF g_promotions_tbl(k).p_level <> 'ORDER' then

     IF g_promotions_tbl(k).p_line_id = p_line_id and
        g_promotions_tbl(k).p_type = 'COUPON' then

       oe_debug_pub.add(' Append line coupon attr='||g_promotions_tbl(k).p_pricing_attribute3);
       i := px_Req_line_attr_tbl.count+1;
       px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
       px_Req_line_attr_tbl(i).Validated_Flag := 'N';
       --If asked_for_rec.flex_title = 'QP_ATTR_DEFNS_QUALIFIER' then
       px_Req_line_attr_tbl(i).Pricing_Context := 'MODLIST';
       px_Req_line_attr_tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE3';
       px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_promotions_tbl(k).p_PRICING_ATTRIBUTE3;

     ELSIF g_promotions_tbl(k).p_line_id = p_line_id and
           g_promotions_tbl(k).p_type = 'PROMOTION' then

      oe_debug_pub.add(' Append Line Promotion attr1='||g_promotions_tbl(k).p_pricing_attribute1);
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).Pricing_Context := 'MODLIST';
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE1';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_promotions_tbl(k).p_PRICING_ATTRIBUTE1;


      IF g_promotions_tbl(k).p_pricing_attribute2 is not null then
        oe_debug_pub.add(' Append Line Promotion attr2='||g_promotions_tbl(k).p_pricing_attribute2);
        i := px_Req_line_attr_tbl.count+1;
        px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
        px_Req_line_attr_tbl(i).Validated_Flag := 'N';
        px_Req_line_attr_tbl(i).Pricing_Context := 'MODLIST';
        px_Req_line_attr_tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE2';
        px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_promotions_tbl(k).p_PRICING_ATTRIBUTE2;
      END IF; -- attr2 is not null

    END IF; -- if type coupon
  END IF; -- if level is not ORDER
  END LOOP;
  END IF; -- if promotions temp table is not null


  oe_debug_pub.add(' Applying Header Promotions p_line_id='||p_line_id||
                    ' promo count='||g_promotions_tbl.COUNT||
                   ' p_line_id='||p_line_id
                    );

  IF p_line_id is null and g_promotions_tbl.COUNT > 0 then
   FOR k in g_promotions_tbl.first..g_promotions_tbl.last
   LOOP

   IF g_promotions_tbl(k).p_level = 'ORDER' then

     IF g_promotions_tbl(k).p_type = 'COUPON' then

       oe_debug_pub.add(' Append Hdr coupon attr='||g_promotions_tbl(k).p_pricing_attribute3);
       i := px_Req_line_attr_tbl.count+1;
       px_Req_line_attr_tbl(i).Line_Index := 1; --p_Line_Index;
       px_Req_line_attr_tbl(i).Validated_Flag := 'N';
       --If asked_for_rec.flex_title = 'QP_ATTR_DEFNS_QUALIFIER' then
       px_Req_line_attr_tbl(i).Pricing_Context := 'MODLIST';
       px_Req_line_attr_tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE3';
       px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_promotions_tbl(k).p_PRICING_ATTRIBUTE3;

     ELSIF g_promotions_tbl(k).p_type = 'PROMOTION' then

      oe_debug_pub.add(' Append Hdr Promotion attr1='||g_promotions_tbl(k).p_pricing_attribute1);
      i := px_Req_line_attr_tbl.count+1;
      px_Req_line_attr_tbl(i).Line_Index := 1; --p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'N';
      px_Req_line_attr_tbl(i).Pricing_Context := 'MODLIST';
      px_Req_line_attr_tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE1';
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_promotions_tbl(k).p_PRICING_ATTRIBUTE1;


      IF g_promotions_tbl(k).p_pricing_attribute2 is not null then
        oe_debug_pub.add(' Append Hdr Promotion Line attr2='||g_promotions_tbl(k).p_pricing_attribute2);
        i := px_Req_line_attr_tbl.count+1;
        px_Req_line_attr_tbl(i).Line_Index := 1; --p_Line_Index;
        px_Req_line_attr_tbl(i).Validated_Flag := 'N';
        px_Req_line_attr_tbl(i).Pricing_Context := 'MODLIST';
        px_Req_line_attr_tbl(i).Pricing_Attribute := 'QUALIFIER_ATTRIBUTE2';
        px_Req_line_attr_tbl(i).Pricing_Attr_Value_From := g_promotions_tbl(k).p_PRICING_ATTRIBUTE2;
      END IF; -- attr2 is not null

    END IF; -- if type coupon
  END IF; -- if level is not ORDER

  END LOOP;
  END IF; -- if promotions temp table is not null and for header

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING oe_oe_pricing_availability.APPEND_ATTRIBUTES' , 1 ) ;
  END IF;

END Append_attributes;



PROCEDURE Append_attr_to_ttables(px_req_line_attr_tbl in out nocopy oe_oe_pricing_availability.QP_LINE_ATTR_TBL_TYPE
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
   (x_line_tbl          OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_TBL_TYPE,
    x_line_qual_tbl        OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_QUAL_TBL_TYPE,
    x_line_attr_tbl        OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_ATTR_TBL_TYPE,
    x_line_detail_tbl      OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_DETAIL_TBL_TYPE,
    x_line_detail_qual_tbl OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_DQUAL_TBL_TYPE,
    x_line_detail_attr_tbl OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_DATTR_TBL_TYPE,
    x_related_lines_tbl    OUT NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_RLTD_LINES_TBL_TYPE)
AS

  -- Cursor l_lines_cur changed for removing NMV SQL Id : 14877269

  CURSOR l_lines_cur IS
  SELECT qpt.line_index, qpt.line_id, qpt.price_list_header_id,
       qpt.line_type_code, qpt.line_quantity, qpt.line_uom_code,
       qpt.line_unit_price, qpt.rounding_factor, qpt.priced_quantity,
       qpt.uom_quantity, qpt.priced_uom_code, qpt.currency_code,
       qpt.unit_price, qpt.percent_price, qpt.parent_price,
       qpt.parent_quantity, qpt.parent_uom_code, qpt.price_flag,
       qpt.adjusted_unit_price, qpt.updated_adjusted_unit_price,
       qpt.processing_order, qpt.processed_code, qpt.pricing_status_code,
       qpt.pricing_status_text, qpt.hold_code, qpt.hold_text,
       qpt.price_request_code, qpt.pricing_effective_date, qpt.extended_price,
       qpt.order_uom_selling_price
  FROM qp_preq_lines_tmp_t qpt
 WHERE qp_java_engine_util_pub.java_engine_running = 'N'
   AND request_id = NVL (SYS_CONTEXT ('qp_context', 'request_id'), 1)
 UNION ALL
  SELECT qpt.line_index, qpt.line_id, qpt.price_list_header_id,
       qpt.line_type_code, qpt.line_quantity, qpt.line_uom_code,
       qpt.line_unit_price, qpt.rounding_factor, qpt.priced_quantity,
       qpt.uom_quantity, qpt.priced_uom_code, qpt.currency_code,
       qpt.unit_price, qpt.percent_price, qpt.parent_price,
       qpt.parent_quantity, qpt.parent_uom_code, qpt.price_flag,
       qpt.adjusted_unit_price, qpt.updated_adjusted_unit_price,
       qpt.processing_order, qpt.processed_code, qpt.pricing_status_code,
       qpt.pricing_status_text, qpt.hold_code, qpt.hold_text,
       qpt.price_request_code, qpt.pricing_effective_date, qpt.extended_price,
       qpt.order_uom_selling_price
  FROM qp_int_lines_t qpt
 WHERE qp_java_engine_util_pub.java_engine_running = 'Y'
   AND request_id = NVL (SYS_CONTEXT ('qp_context', 'request_id'), -9999);



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


 -- Cursor l_ldets_cur is changed to remove NMV and reduce Sharable Memory SQL Id 14877295

CURSOR l_ldets_cur IS
SELECT qpt.line_detail_index, qpt.line_detail_type_code, qpt.line_index,
       qpt.created_from_list_header_id list_header_id,
       qpt.created_from_list_line_id list_line_id,
       qpt.created_from_list_line_type list_line_type_code,
       qpt.price_break_type_code, qpt.line_quantity, qpt.adjustment_amount,qpt.automatic_flag,
       qpt.pricing_phase_id, qpt.operand_calculation_code, qpt.operand_value,
       qpt.pricing_group_sequence, qpt.created_from_list_type_code,
       qpt.applied_flag, qpt.pricing_status_code, qpt.pricing_status_text,
       qpt.limit_code, qpt.limit_text, qpt.list_line_no, qpt.group_quantity,
       qpt.group_amount, qpt.updated_flag, qpt.process_code,
       qpt.calculation_code, qpt.change_reason_code, qpt.change_reason_text,
       qpt.order_qty_adj_amt, b.substitution_value substitution_value_to,
       b.substitution_attribute, b.accrual_flag, b.modifier_level_code,
       b.estim_gl_value, b.accrual_conversion_rate, b.override_flag,
       b.print_on_invoice_flag, b.inventory_item_id, b.organization_id,
       b.related_item_id, b.relationship_type_id, b.estim_accrual_rate,
       b.expiration_date, b.benefit_price_list_line_id, b.recurring_flag,
       b.recurring_value, b.benefit_limit, b.charge_type_code,
       b.charge_subtype_code, b.benefit_qty, b.benefit_uom_code,
       b.proration_type_code, b.include_on_returns_flag,
       b.rebate_transaction_type_code, b.number_expiration_periods,
       b.expiration_period_uom, b.comments
  FROM qp_preq_ldets_tmp_t qpt, qp_list_lines b
 WHERE qp_java_engine_util_pub.java_engine_running = 'N'
   AND qpt.request_id = NVL (SYS_CONTEXT ('QP_CONTEXT', 'REQUEST_ID'), 1)
   AND qpt.created_from_list_line_id = b.list_line_id
   AND qpt.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
UNION ALL
SELECT qpt.line_detail_index, qpt.line_detail_type_code, qpt.line_index,
       qpt.created_from_list_header_id list_header_id, qpt.created_from_list_line_id list_line_id,
       qpt.created_from_list_line_type list_line_type_code, qpt.price_break_type_code,
       qpt.line_quantity, qpt.adjustment_amount, qpt.automatic_flag, qpt.pricing_phase_id,
       qpt.operand_calculation_code, qpt.operand_value,
       qpt.pricing_group_sequence, qpt.created_from_list_type_code,
       qpt.applied_flag, qpt.pricing_status_code, qpt.pricing_status_text,
       qpt.limit_code, qpt.limit_text, qpt.list_line_no, qpt.group_quantity,
       qpt.group_amount, qpt.updated_flag, qpt.process_code,
       qpt.calculation_code, qpt.change_reason_code, qpt.change_reason_text,
       qpt.order_qty_adj_amt, b.substitution_value substitution_value_to,
       b.substitution_attribute, b.accrual_flag, b.modifier_level_code,
       b.estim_gl_value, b.accrual_conversion_rate, b.override_flag,
       b.print_on_invoice_flag, b.inventory_item_id, b.organization_id,
       b.related_item_id, b.relationship_type_id, b.estim_accrual_rate,
       b.expiration_date, b.benefit_price_list_line_id, b.recurring_flag,
       b.recurring_value, b.benefit_limit, b.charge_type_code,
       b.charge_subtype_code, b.benefit_qty, b.benefit_uom_code,
       b.proration_type_code, b.include_on_returns_flag,
       b.rebate_transaction_type_code, b.number_expiration_periods,
       b.expiration_period_uom, b.comments
  FROM qp_int_ldets_t qpt, qp_list_lines b
 WHERE qp_java_engine_util_pub.java_engine_running = 'Y'
   AND qpt.request_id = NVL (SYS_CONTEXT ('QP_CONTEXT', 'REQUEST_ID'), -9999)
   AND qpt.created_from_list_line_id = b.list_line_id
   AND qpt.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;


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
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level >0 then
   oe_debug_pub.add('----Before populate l_line_tbl-----');
   oe_debug_pub.add('----Line information return back to caller----');
   END IF;

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
   IF l_debug_level > 0 then
   oe_debug_pub.add('----Line detail information return back to caller----');
   END IF;

   FOR l_dets IN l_ldets_cur LOOP
      IF l_debug_level > 0 then
      oe_debug_pub.add('----populating line detail output------');
      END IF;
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
	IF l_debug_level > 0 then
	    oe_debug_pub.add(l_routine||':'||substr(l_status_text,1,240));
	    END IF;
	 --END IF;
      END IF;

      x_line_detail_tbl(I).EXPIRATION_DATE :=l_expiration_period_end_date;
   END LOOP;
   I:=1;

   --Populate Qualifier detail
   --IF G_DEBUG_ENGINE = FND_API.G_TRUE THEN
   IF l_debug_level > 0 then
   oe_debug_pub.add('----Before populate x_qual_tbl-----');
   END IF;
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

  IF l_debug_level > 0 then
   oe_debug_pub.add('----Before populate attr_tbl-----');
   END IF;

   FOR l_prc IN l_pricing_attr_cur LOOP
      IF l_debug_level >0 then
      oe_debug_pub.add('--------populating x_line_detail_attr----------');
      oe_debug_pub.add('Line Detail Index: '||l_prc.LINE_DETAIL_INDEX);
      END IF;
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

   IF l_debug_level > 0 then
   oe_debug_pub.add('----Before populate l_rltd_lines_tbl-----');
   END IF;
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
         IF l_debug_level >0 then
      oe_debug_pub.add(l_routine||':'||substr(l_status_text,1,240));
       END IF;

END Populate_results;




PROCEDURE price_item(out_req_line_tbl in out NOCOPY /* file.sql.39 change */ OE_OE_PRICING_AVAILABILITY.QP_LINE_TBL_TYPE,
		     out_Req_line_attr_tbl         in out nocopy  OE_OE_PRICING_AVAILABILITY.QP_LINE_ATTR_TBL_TYPE,
		     out_Req_LINE_DETAIL_attr_tbl  in out nocopy  OE_OE_PRICING_AVAILABILITY.QP_LINE_DATTR_TBL_TYPE,
		     out_Req_LINE_DETAIL_tbl        in out nocopy OE_OE_PRICING_AVAILABILITY.QP_LINE_DETAIL_TBL_TYPE,
		     out_Req_related_lines_tbl      in out nocopy OE_OE_PRICING_AVAILABILITY.QP_RLTD_LINES_TBL_TYPE,
		     out_Req_qual_tbl               in out nocopy OE_OE_PRICING_AVAILABILITY.QP_QUAL_TBL_TYPE,
		     out_Req_LINE_DETAIL_qual_tbl   in out nocopy OE_OE_PRICING_AVAILABILITY.QP_LINE_DQUAL_TBL_TYPE,
		     out_child_detail_type out nocopy varchar2
                     ) IS

   l_return_status               varchar2(10);
   l_return_status_Text	      varchar2(240) ;
   lx_Control_Rec                 QP_PREQ_GRP.CONTROL_RECORD_TYPE;
   l_Control_Rec                 OE_OE_PRICING_AVAILABILITY.QP_CONTROL_RECORD_TYPE;
   l_req_line_tbl                OE_OE_PRICING_AVAILABILITY.QP_LINE_TBL_TYPE;
   l_Req_qual_tbl                OE_OE_PRICING_AVAILABILITY.QP_QUAL_TBL_TYPE;
   l_Req_line_attr_tbl           OE_OE_PRICING_AVAILABILITY.QP_LINE_ATTR_TBL_TYPE;
   l_Req_LINE_DETAIL_tbl         OE_OE_PRICING_AVAILABILITY.QP_LINE_DETAIL_TBL_TYPE;
   l_Req_LINE_DETAIL_qual_tbl    OE_OE_PRICING_AVAILABILITY.QP_LINE_DQUAL_TBL_TYPE;
   l_Req_LINE_DETAIL_attr_tbl    OE_OE_PRICING_AVAILABILITY.QP_LINE_DATTR_TBL_TYPE;
   l_Req_related_lines_tbl       OE_OE_PRICING_AVAILABILITY.QP_RLTD_LINES_TBL_TYPE;

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

   IF l_debug_level  > 0 THEN
      print_time('Before Calling Copy Header to Request');
   END IF;
   g_applied_manual_tbl.delete;
   copy_Header_to_request(
			 p_request_type_code => 'ONT'
                        --  p_request_type_code => 'ASO'
			  ,p_calculate_price_flag  => 'Y'
			  ,px_req_line_tbl => l_req_line_tbl
			  );

   IF l_debug_level  > 0 THEN
      print_time('After Calling Copy Header to Request');
   END IF;
   set_pricing_control_record (
			       l_Control_Rec  => l_control_rec
			       ,in_pricing_event => 'BATCH'
                               );

    copy_control_rec(in_Control_Rec => l_control_rec,
			   x_Control_Rec=>lx_control_rec);

    build_context_for_header(
			    p_req_line_tbl_count =>l_req_line_tbl.count,
			    p_price_request_code => null,
			    p_item_type_code => null,
			    p_Req_line_attr_tbl =>l_req_line_attr_tbl,
			    p_Req_qual_tbl =>l_req_qual_tbl
			    );


   IF l_debug_level  > 0 THEN
      print_time('Before Looping through Copy Line to request');
   END IF;
   for l_line_index in g_panda_rec_table.first..g_panda_rec_table.last
		       LOOP

         IF l_debug_level  > 0 THEN
         oe_debug_pub.add('the line index'||l_line_index);
	 END IF;
      copy_Line_to_request(
			   px_req_line_tbl => l_req_line_tbl
			   ,p_pricing_event => 'BATCH'
			   ,p_Request_Type_Code => 'ONT'
                          -- ,p_Request_Type_Code => 'ASO'
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



       oe_Debug_pub.add('Calling Append Attributes for Line');
	 Append_attributes(
			p_header_id => g_header_id
			,p_Line_id   => g_panda_rec_table(l_line_index).p_line_id
			,p_line_index =>global_line_index
			,px_Req_line_attr_tbl => l_req_line_attr_tbl
			,px_Req_qual_tbl => l_req_qual_tbl
			,p_g_line_index =>l_line_index
			);

-- inserting manual adjsutments
           oe_Debug_pub.add('modfier count'||g_manual_modifier_tbl.count);
	 if g_manual_modifier_tbl.count > 0 then

	    IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('before inserting manual adjustment'||g_manual_modifier_tbl.count);
	    END IF;

	    insert_manual_adjustment(in_line_id=>g_panda_rec_table(l_line_index).p_line_id,
				      in_line_index=>global_line_index) ;

	    IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('after inserting manual adjustment');
	    END IF;
	 end if;


   end loop; -- Looping for each line

   IF l_debug_level  > 0 THEN
      print_time('After Looping through Copy Line to Request');
   END IF;

/*   build_context_for_header(
			    p_req_line_tbl_count =>l_req_line_tbl.count,
			    p_price_request_code => null,
			    p_item_type_code => null,
			    p_Req_line_attr_tbl =>l_req_line_attr_tbl,
			    p_Req_qual_tbl =>l_req_qual_tbl
			    );  */

   oe_Debug_pub.add('Calling Append Attributes for Header');

   Append_attributes(
		     p_header_id => g_header_id
		     ,p_Line_id   => null
		     ,p_line_index => l_req_line_tbl.count
		     ,px_Req_line_attr_tbl => l_req_line_attr_tbl
		     ,px_Req_qual_tbl => l_req_qual_tbl
		     ,p_g_line_index =>1
		     );


   IF l_debug_level  > 0 THEN
      print_time('After appending the Header Attributes and Before Appending attributes to Temp Tables');
      oe_Debug_pub.add(' Populating the attr tables');
   END IF;

   append_attr_to_TTables(px_req_line_attr_tbl=>l_req_line_attr_tbl);
   IF l_debug_level  > 0 THEN
      print_time('After Appending attributes to Temp Tables');
   END IF;
   out_req_line_tbl(1).status_Code := null;
   out_req_line_tbl(1).status_text := null;


   IF l_debug_level > 0 then
   oe_Debug_pub.add(' Populating the temp tables');
   print_time('Before Populate Temp Tables');
   END IF;
   populate_temp_table;

    IF l_debug_level  > 0 THEN
      print_time(' After populating temp tables and Before calling PE');
   END IF;
   QP_PREQ_PUB.PRICE_REQUEST
      (p_control_rec           =>lx_control_rec,
       x_return_status         =>l_return_status,
       x_return_status_Text    =>l_return_status_Text
       );

   IF l_debug_level  > 0 THEN
      print_time('After calling PE');
      oe_debug_pub.add('After calling the pricing engine');
   END IF;
   IF l_debug_level  > 0 THEN
      print_time('Before populate results ');
   END IF;
   populate_results(
		    x_line_tbl =>out_req_line_tbl
		    ,x_line_qual_tbl =>out_Req_qual_tbl
		    ,x_line_attr_tbl =>out_Req_line_attr_tbl
		    ,x_line_detail_tbl =>out_req_line_detail_tbl
		    ,x_line_detail_qual_tbl=>out_req_line_detail_qual_tbl
		    ,x_line_detail_attr_tbl =>out_req_line_detail_attr_tbl
		    ,x_related_lines_tbl=>out_req_related_lines_tbl);

   IF l_debug_level  > 0 THEN
      print_time('After populating results');
   END IF;
   IF l_debug_level > 0 THEN
      print_time('After populating the pl/sql records');
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('******AFTER CALLING PRICING ENGINE' ) ;
      oe_debug_pub.add('MAIN STATUS ='||L_RETURN_STATUS ) ;
      oe_debug_pub.add('MAIN TEXT ='||L_RETURN_STATUS_TEXT ) ;
      oe_debug_pub.add('COUNT LINE TABLE='||OUT_REQ_LINE_TBL.COUNT ) ;
   END IF;

   if out_req_line_tbl.count > 0 then
      for i in out_req_line_tbl.first..out_req_line_tbl.last
	       loop

	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('*******************************' ) ;
            oe_debug_pub.add(' LINE_INDEX ='||OUT_REQ_LINE_TBL (I).LINE_INDEX );
	    oe_debug_pub.add('LINE_ID='||OUT_REQ_LINE_TBL (I).LINE_ID);
	    oe_debug_pub.add('REQUEST_TYPE_CODE ='|| OUT_REQ_LINE_TBL (I) .REQUEST_TYPE_CODE ) ;
	    oe_debug_pub.add('PRICING_EVENT ='||OUT_REQ_LINE_TBL (I) .PRICING_EVENT ) ;
	    oe_debug_pub.add('HEADER_ID ='||OUT_REQ_LINE_TBL (I) .HEADER_ID ) ;
	    oe_debug_pub.add('LINE_TYPE_CODE='||OUT_REQ_LINE_TBL (I) .LINE_TYPE_CODE ) ;
	    oe_debug_pub.add('LINE_QUANTITY ='||OUT_REQ_LINE_TBL (I) .LINE_QUANTITY ) ;
	    oe_debug_pub.add('LINE_UOM_CODE ='||OUT_REQ_LINE_TBL (I) .LINE_UOM_CODE ) ;
	    oe_debug_pub.add('UOM_QUANTITY ='||OUT_REQ_LINE_TBL (I) .UOM_QUANTITY ) ;
	    oe_debug_pub.add('PRI_QUANTITY='||OUT_REQ_LINE_TBL (I) .PRICED_QUANTITY ) ;
	    oe_debug_pub.add('PR_UOM_CODE ='||OUT_REQ_LINE_TBL (I) .PRICED_UOM_CODE ) ;
	    oe_debug_pub.add('CURRENCY_CODE ='||OUT_REQ_LINE_TBL (I) .CURRENCY_CODE ) ;
	    oe_debug_pub.add('UNIT_PRICE ='||OUT_REQ_LINE_TBL (I) .UNIT_PRICE ) ;
	    oe_debug_pub.add('PERCENT_PRICE ='||OUT_REQ_LINE_TBL (I) .PERCENT_PRICE ) ;
	    oe_debug_pub.add('ADJ_UNIT_PRICE='|| OUT_REQ_LINE_TBL (I) .ADJUSTED_UNIT_PRICE ) ;
	    oe_debug_pub.add('UPDATED_ADJUSTED_UNIT_PRICE ='|| OUT_REQ_LINE_TBL (I) .UPDATED_ADJUSTED_UNIT_PRICE ) ;
	    oe_debug_pub.add('ROUNDING_FAC='||OUT_REQ_LINE_TBL (I) .ROUNDING_FACTOR ) ;
	    oe_debug_pub.add('PRICE_FLAG ='||OUT_REQ_LINE_TBL (I) .PRICE_FLAG ) ;
	    oe_debug_pub.add('PRICE_REQUEST_CODE ='|| OUT_REQ_LINE_TBL (I) .PRICE_REQUEST_CODE ) ;
	    oe_debug_pub.add('HOLD_CODE ='||OUT_REQ_LINE_TBL (I) .HOLD_CODE ) ;
	    oe_debug_pub.add('HOLD_TEXT ='||OUT_REQ_LINE_TBL (I) .HOLD_TEXT ) ;
	    oe_debug_pub.add('STATUS_CODE ='||OUT_REQ_LINE_TBL (I) .STATUS_CODE ) ;
	    oe_debug_pub.add('STATUS_TEXT ='||OUT_REQ_LINE_TBL (I) .STATUS_TEXT ) ;
	    oe_debug_pub.add('USAGE_PRICING_TYPE ='|| OUT_REQ_LINE_TBL (I) .USAGE_PRICING_TYPE ) ;
	    oe_debug_pub.add('LINE_CATEGORY ='||OUT_REQ_LINE_TBL (I) .LINE_CATEGORY ) ;
	    oe_debug_pub.add('PRICING EFFECTIVE DATE='|| OUT_REQ_LINE_TBL (I) .PRICING_EFFECTIVE_DATE ) ;
	    oe_debug_pub.add('ACTIVE_DATE_FIRST ='|| OUT_REQ_LINE_TBL (I) .ACTIVE_DATE_FIRST ) ;
	    oe_debug_pub.add('ACTIVE_DATE_FIRST_TYPE ='|| OUT_REQ_LINE_TBL (I) .ACTIVE_DATE_FIRST_TYPE ) ;
	    oe_debug_pub.add('ACTIVE_DATE_SECOND ='|| OUT_REQ_LINE_TBL (I) .ACTIVE_DATE_SECOND ) ;
	    oe_debug_pub.add('ACTIVE_DATE_SECOND_TYPE ='|| OUT_REQ_LINE_TBL (I) .ACTIVE_DATE_SECOND_TYPE ) ;
	 END IF;
      end loop;
   end if;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT LINE DETAIL TABLE='||OUT_REQ_LINE_DETAIL_TBL.COUNT ) ;
   END IF;

   if out_req_line_detail_tbl.count > 0 then

      for i in out_req_line_detail_tbl.first..out_req_line_detail_tbl.last
	       loop

	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('LINE DETAIL TABLE RECORD='||I ) ;
	 END IF;

	 IF out_req_line_detail_tbl.exists(i) then

	    IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('*******************************' ) ;
	       oe_debug_pub.add('LINE_DETAIL_INDEX ='||OUT_REQ_LINE_DETAIL_TBL (I).LINE_DETAIL_INDEX);
	       oe_debug_pub.add('LINE_DETAIL_TYPE_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).LINE_DETAIL_TYPE_CODE);
	       oe_debug_pub.add('LIN_INDEX='||OUT_REQ_LINE_DETAIL_TBL (I) .LINE_INDEX ) ;
	       oe_debug_pub.add('LIST_HEADER_ID='|| OUT_REQ_LINE_DETAIL_TBL (I) .LIST_HEADER_ID ) ;
	       oe_debug_pub.add('LIST_LINE_ID='|| OUT_REQ_LINE_DETAIL_TBL (I) .LIST_LINE_ID ) ;
	       oe_debug_pub.add('LIST_LINE_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL (I) .LIST_LINE_TYPE_CODE ) ;
	       oe_debug_pub.add('LINE_DETAIL_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL (I) .LINE_DETAIL_TYPE_CODE ) ;
	       oe_debug_pub.add('SUBSTITUTION_TO='||OUT_REQ_LINE_DETAIL_TBL (I).SUBSTITUTION_TO);
	       oe_debug_pub.add('LINE_QUANTITY='||OUT_REQ_LINE_DETAIL_TBL (I).LINE_QUANTITY);
	       oe_debug_pub.add('ADJUSTMENT_AMOUNT='|| OUT_REQ_LINE_DETAIL_TBL (I) .ADJUSTMENT_AMOUNT ) ;
	       oe_debug_pub.add('AUTOMATIC_FLAG='|| OUT_REQ_LINE_DETAIL_TBL (I) .AUTOMATIC_FLAG ) ;
	       oe_debug_pub.add('APPLIED_FLAG ='||OUT_REQ_LINE_DETAIL_TBL (I).APPLIED_FLAG );
	       oe_debug_pub.add('PRICING_GROUP_SEQUENCE='||OUT_REQ_LINE_DETAIL_TBL (I).PRICING_GROUP_SEQUENCE);
	       oe_debug_pub.add('CREATED_FROM_LIST_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL (I) .CREATED_FROM_LIST_TYPE_CODE ) ;
	       oe_debug_pub.add('PRICE_BREAK_TYPE_CODE='|| OUT_REQ_LINE_DETAIL_TBL (I) .PRICE_BREAK_TYPE_CODE ) ;
	       oe_debug_pub.add('OVERRIDE_FLAG='||OUT_REQ_LINE_DETAIL_TBL (I).OVERRIDE_FLAG);
	       oe_debug_pub.add('PRINT_ON_INVOICE_FLAG='||OUT_REQ_LINE_DETAIL_TBL (I).PRINT_ON_INVOICE_FLAG);
	       oe_debug_pub.add('PRICING_PHASE_ID='||OUT_REQ_LINE_DETAIL_TBL (I).PRICING_PHASE_ID);
	       oe_debug_pub.add('OPERAND_CALCULATION_CODE='||OUT_REQ_LINE_DETAIL_TBL(I).OPERAND_CALCULATION_CODE);
	       oe_debug_pub.add('OPERAND_VALUE='||OUT_REQ_LINE_DETAIL_TBL (I).OPERAND_VALUE);
	       oe_debug_pub.add('STATUS_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).STATUS_CODE);
	       oe_debug_pub.add('STATUS_TEXT='||OUT_REQ_LINE_DETAIL_TBL (I).STATUS_TEXT);
	       oe_debug_pub.add('SUBSTITUTION_ATTRIBUTE='||OUT_REQ_LINE_DETAIL_TBL (I).SUBSTITUTION_ATTRIBUTE);
	       oe_debug_pub.add('ACCRUAL='||OUT_REQ_LINE_DETAIL_TBL (I) .ACCRUAL_FLAG ) ;
	       oe_debug_pub.add('LIST_LINE_NO='||OUT_REQ_LINE_DETAIL_TBL (I).LIST_LINE_NO);
	       oe_debug_pub.add('ESTIM_GL_VALUE='||OUT_REQ_LINE_DETAIL_TBL (I).ESTIM_GL_VALUE);
	       oe_debug_pub.add('ACCRUAL_CONVERSION_RATE='||OUT_REQ_LINE_DETAIL_TBL (I).ACCRUAL_CONVERSION_RATE);
	       oe_debug_pub.add('PRINT_ON_INVOICE_FLAG='||OUT_REQ_LINE_DETAIL_TBL (I).PRINT_ON_INVOICE_FLAG);
	       oe_debug_pub.add('INVENTORY_ITEM_ID='|| OUT_REQ_LINE_DETAIL_TBL (I) .INVENTORY_ITEM_ID ) ;
	       oe_debug_pub.add('ORGANIZATION_ID='||OUT_REQ_LINE_DETAIL_TBL (I).ORGANIZATION_ID);
	       oe_debug_pub.add('RELATED_ITEM_ID='||OUT_REQ_LINE_DETAIL_TBL (I).RELATED_ITEM_ID);
	       oe_debug_pub.add('RELATIONSHIP_TYPE_ID='||OUT_REQ_LINE_DETAIL_TBL (I).RELATIONSHIP_TYPE_ID);
	       oe_debug_pub.add('ESTIM_ACCRUAL_RATE='||OUT_REQ_LINE_DETAIL_TBL (I).ESTIM_ACCRUAL_RATE);
	       oe_debug_pub.add('BENEFIT_PRICE_LIST_LINE_ID='||OUT_REQ_LINE_DETAIL_TBL (I).BENEFIT_PRICE_LIST_LINE_ID);
	       oe_debug_pub.add('RECURRING_FLAG='||OUT_REQ_LINE_DETAIL_TBL (I).RECURRING_FLAG );
	       oe_debug_pub.add('RECURRING_VALUE='||OUT_REQ_LINE_DETAIL_TBL(I).RECURRING_VALUE);
	       oe_debug_pub.add('BENEFIT_LIMIT='||OUT_REQ_LINE_DETAIL_TBL (I).BENEFIT_LIMIT);
	       oe_debug_pub.add('CHARGE_TYPE_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).CHARGE_TYPE_CODE);
	       oe_debug_pub.add('CHARGE_SUBTYPE_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).CHARGE_SUBTYPE_CODE);
	       oe_debug_pub.add('BENEFIT_QTY='||OUT_REQ_LINE_DETAIL_TBL (I).BENEFIT_QTY);
	       oe_debug_pub.add('BENEFIT_UOM_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).BENEFIT_UOM_CODE);
	       oe_debug_pub.add('PRORATION_TYPE_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).PRORATION_TYPE_CODE);
	       oe_debug_pub.add('NCLUDE_ON_RETURNS_FLAG ='||OUT_REQ_LINE_DETAIL_TBL (I).INCLUDE_ON_RETURNS_FLAG );
	       oe_debug_pub.add('CALCULATION_CODE='||OUT_REQ_LINE_DETAIL_TBL (I).CALCULATION_CODE);
	       oe_debug_pub.add('LST_PRICE='||OUT_REQ_LINE_DETAIL_TBL (I) .LIST_PRICE ) ;
	       oe_debug_pub.add('MODIFIER_LEVEL_CODE='|| OUT_REQ_LINE_DETAIL_TBL (I) .MODIFIER_LEVEL_CODE ) ;


	    end if;
	 end if;
      end loop;

   end if;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT LINE DETAIL ATTR TBL='|| OUT_REQ_LINE_DETAIL_ATTR_TBL.COUNT ) ;
   END IF;

   if out_req_line_detail_attr_tbl.count > 0 then
      for i in out_req_line_detail_attr_tbl.first..out_req_line_detail_attr_tbl.last
	       loop
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('*******************************' ) ;
	    oe_debug_pub.add('LINE DETAIL ATTR_TABLE RECORD='||I ) ;
	    oe_debug_pub.add('LINE_DETAIL_INDEX='|| OUT_REQ_LINE_DETAIL_ATTR_TBL (I) .LINE_DETAIL_INDEX ) ;
	    oe_debug_pub.add('PRICING_CONTEXT='|| OUT_REQ_LINE_DETAIL_ATTR_TBL (I) .PRICING_CONTEXT ) ;
	    oe_debug_pub.add('PRICING_ATTRIBUTE='|| OUT_REQ_LINE_DETAIL_ATTR_TBL (I) .PRICING_ATTRIBUTE ) ;
	    oe_debug_pub.add('PRICING_ATTR_VALUE_FROM='|| OUT_REQ_LINE_DETAIL_ATTR_TBL (I) .PRICING_ATTR_VALUE_FROM ) ;
	    oe_debug_pub.add('PRICING_ATTR_VALUE_TO='|| OUT_REQ_LINE_DETAIL_ATTR_TBL (I) .PRICING_ATTR_VALUE_TO ) ;
	 END IF;

      end loop;
   end if;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT LINE ATTR TBL='||OUT_REQ_LINE_ATTR_TBL.COUNT ) ;
   END IF;

   if out_req_line_attr_tbl.count > 0 then
      for i in out_req_line_attr_tbl.first..out_req_line_attr_tbl.last
	       loop
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('*******************************' ) ;
	    oe_debug_pub.add('LINE ATTR_TABLE RECORD='||I ) ;
	    oe_debug_pub.add('LINE_INDEX='||OUT_REQ_LINE_ATTR_TBL (I) .LINE_INDEX ) ;
	    oe_debug_pub.add('PRICING_CONTEXT='|| OUT_REQ_LINE_ATTR_TBL (I) .PRICING_CONTEXT ) ;
	    oe_debug_pub.add('PRICING_ATTRIBUTE='|| OUT_REQ_LINE_ATTR_TBL (I) .PRICING_ATTRIBUTE ) ;
	    oe_debug_pub.add('PRICING_ATTR_VALUE_FROM='|| OUT_REQ_LINE_ATTR_TBL (I) .PRICING_ATTR_VALUE_FROM ) ;
	    oe_debug_pub.add('PRICING_ATTR_VALUE_TO='|| OUT_REQ_LINE_ATTR_TBL (I) .PRICING_ATTR_VALUE_TO ) ;
	 END IF;

      end loop;
   end if;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT RELATED LINES TBL='|| OUT_REQ_RELATED_LINES_TBL.COUNT ) ;
   END IF;

   if out_req_related_lines_tbl.count > 0 then
      for i in out_req_related_lines_tbl.first..out_req_related_lines_tbl.last
	       loop
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('*******************************' ) ;
	    oe_debug_pub.add('RELATD LINES RECORD='||I ) ;
	    oe_debug_pub.add('LIN_INDEX='||OUT_REQ_RELATED_LINES_TBL (I) .LINE_INDEX ) ;
	    oe_debug_pub.add('LINE_DETAIL_INDEX='|| OUT_REQ_RELATED_LINES_TBL (I) .LINE_DETAIL_INDEX ) ;
	    oe_debug_pub.add('RELATIONSHIP_TYPE_CODE='|| OUT_REQ_RELATED_LINES_TBL (I) .RELATIONSHIP_TYPE_CODE ) ;
	    oe_debug_pub.add('RELATED_LINE_INDEX='|| OUT_REQ_RELATED_LINES_TBL (I) .RELATED_LINE_INDEX ) ;
	    oe_debug_pub.add('RELATED_LINE_DETAIL_INDEX='|| OUT_REQ_RELATED_LINES_TBL (I) .RELATED_LINE_DETAIL_INDEX ) ;
	 END IF;

      end loop;
   end if;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT LINE QUAL TBL='||OUT_REQ_QUAL_TBL.COUNT ) ;
   END IF;

   if out_req_qual_tbl.count > 0 then
      for i in out_req_qual_tbl.first..out_req_qual_tbl.last
	       loop
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('*******************************' ) ;
	    oe_debug_pub.add('QUAL TABLE RECORD='||I ) ;
	    oe_debug_pub.add('LINE_INDEX='||OUT_REQ_QUAL_TBL (I) .LINE_INDEX ) ;
	    oe_debug_pub.add('QUALIFIER_CONTEXT='|| OUT_REQ_QUAL_TBL (I) .QUALIFIER_CONTEXT ) ;
	    oe_debug_pub.add('QUALIFIER_ATTRIBUTE='|| OUT_REQ_QUAL_TBL (I) .QUALIFIER_ATTRIBUTE ) ;
	    oe_debug_pub.add('QUALIFIER_ATTR_VALUE_FROM='|| OUT_REQ_QUAL_TBL (I) .QUALIFIER_ATTR_VALUE_FROM ) ;
	    oe_debug_pub.add('QUALIFIER_ATTR_VALUE_TO='|| OUT_REQ_QUAL_TBL (I) .QUALIFIER_ATTR_VALUE_TO ) ;
	    oe_debug_pub.add('COMPARISON_OPERATOR_CODE='|| OUT_REQ_QUAL_TBL (I) .COMPARISON_OPERATOR_CODE ) ;
	    oe_debug_pub.add('VALIDATED_FLAG='||OUT_REQ_QUAL_TBL (I) .VALIDATED_FLAG ) ;
	 END IF;

      end loop;
   end if;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT LINE DETAIL QUAL TBL='|| OUT_REQ_LINE_DETAIL_QUAL_TBL.COUNT ) ;
   END IF;

   if out_req_line_detail_qual_tbl.count > 0 then
      for i in out_req_line_detail_qual_tbl.first..out_req_line_detail_qual_tbl.last
	       loop
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('*******************************' ) ;
	    oe_debug_pub.add('LINE DETAIL QUAL TABLE RECORD='||I ) ;
	    oe_debug_pub.add('LINE_DETAIL_INDEX='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .LINE_DETAIL_INDEX ) ;
	    oe_debug_pub.add('QUALIFIER_CONTEXT='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .QUALIFIER_CONTEXT ) ;
	    oe_debug_pub.add('QUALIFIER_ATTRIBUTE='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .QUALIFIER_ATTRIBUTE ) ;
	    oe_debug_pub.add('QUALIFIER_ATTR_VALUE_FROM='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .QUALIFIER_ATTR_VALUE_FROM ) ;
	    oe_debug_pub.add('QUALIFIER_ATTR_VALUE_TO='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .QUALIFIER_ATTR_VALUE_TO ) ;
	    oe_debug_pub.add('COMPARISON_OPERATOR_CODE='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .COMPARISON_OPERATOR_CODE ) ;
	    oe_debug_pub.add('VALIDATED_FLAG='|| OUT_REQ_LINE_DETAIL_QUAL_TBL (I) .VALIDATED_FLAG ) ;
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
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   g_panda_rec_table.delete;
   for i in in_panda_rec_table.first..in_panda_rec_table.last
      loop
      if l_debug_level > 0 then
      oe_debug_pub.add(' Line Record Nbr='||i);
      end if;
      g_panda_rec_table(i):=in_panda_rec_table(i);
      if l_debug_level > 0 then
      oe_debug_pub.add('*******IT STARTS HERE*****');
	    oe_debug_pub.add('index is'||i||' item is='||g_panda_rec_table(i).p_inventory_item_id);
	    end if;

      end loop;

END pass_values_to_backend;

Procedure Delete_manual_modifiers Is
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   Begin

 if l_debug_level > 0 then
    oe_debug_pub.add('entered delete manual modifiers');
 end if;
 g_manual_modifier_tbl.delete;
 g_modf_rel_tbl.delete;
 g_modf_attributes_tbl.delete;
 if l_debug_level > 0 then
    oe_debug_pub.add('exiting delete manual modifiers');
 end if;

End Delete_manual_modifiers;

Procedure Pass_Modifiers_to_backend(in_manual_adj_tbl in Manual_modifier_tbl,
                                     in_modf_rel_tbl  in Modifier_assoc_Tbl,
				       in_modf_attr_tbl in Modifier_attributes_Tbl)  IS

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_ctr number;

BEGIN
   if l_debug_level > 0 then
     oe_debug_pub.add('Entering PLS pass modifiers to backend');
  end if;

   l_ctr := g_manual_modifier_tbl.COUNT ;

  /* add the passed modifier and the line id accordingly */
   if in_manual_Adj_tbl.count >0 then
   for i in in_manual_adj_tbl.first..in_manual_adj_tbl.last
	    loop
   IF  in_manual_adj_tbl.exists(i)  then
      l_ctr:=l_ctr+1;
      g_manual_modifier_tbl(l_ctr):=in_manual_adj_tbl(i);
      oe_Debug_pub.add('after assigning modifiers');
      oe_Debug_pub.add('after increasing counter');

    IF l_debug_level > 0 then
       oe_debug_pub.add('line_id='||g_manual_modifier_tbl(l_ctr).p_line_id);

    END IF;

   END IF;
  end loop;
  end if;
  -- g_modf_Rel_tbl.delete;
   l_ctr:=g_modf_rel_Tbl.count;
   if in_modf_rel_tbl.count >0 then

      for i in in_modf_rel_tbl.first..in_modf_rel_tbl.last
	    loop
	 IF  in_modf_rel_tbl.exists(i) then
	     l_ctr:=l_ctr+1;
	     g_modf_rel_tbl(l_ctr):=in_modf_rel_tbl(i);
	     oe_Debug_pub.add('after assigning modifiers relationship');
	     oe_Debug_pub.add('after increasing counter');

	    IF l_debug_level > 0 then
	       oe_debug_pub.add('line_id='||g_manual_modifier_tbl(l_ctr).p_line_id);

	    END IF;

	 END IF;
      end loop;
   end if;

      l_ctr:=g_modf_attributes_Tbl.count;
      if in_modf_attr_tbl.count >0 then
      for i in in_modf_attr_tbl.first..in_modf_attr_tbl.last
	    loop
	 IF  in_modf_attr_tbl.exists(i)  then
	    l_ctr:=l_ctr+1;
	    g_modf_attributes_tbl(l_ctr):=in_modf_attr_tbl(i);
	    oe_Debug_pub.add('after assigning modifiers attributes');


	    IF l_debug_level > 0 then
	       oe_debug_pub.add('line_id='||g_manual_modifier_tbl(l_ctr).p_line_id);

	    END IF;

	 END IF;
      end loop;
   end if;

   oe_debug_pub.add('Exiting PLS pass modifiers to backend count='||
                     g_manual_modifier_tbl.COUNT);


   END Pass_Modifiers_to_backend;

    PROCEDURE Delete_Applied_Manual_Adj(in_line_id in number,
				       in_list_line_id in number,
				       in_list_header_id in number)
    IS
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    BEGIN

       IF l_debug_level > 0 then
	  oe_debug_pub.add('Entered Delete Applied Manual Adj');
	  oe_debug_pub.add('line_id='||in_line_id||' List line id'||in_list_line_id ||'List header id'
			   ||in_list_header_id);
       END IF;


       for i in g_manual_modifier_tbl.first..g_manual_modifier_tbl.last
	   loop
      if ( g_manual_modifier_tbl.exists(i) and
	   g_manual_modifier_tbl(i).p_line_id = in_line_id and
	   g_manual_modifier_tbl(i).list_line_id =in_list_line_id and
	   g_manual_modifier_tbl(i).list_header_id=in_list_header_id) then



	 IF g_manual_modifier_tbl(i).list_line_type_code ='PBH' then

	    for k in g_modf_rel_tbl.first..g_modf_rel_tbl.last
		    loop
	      if ( g_modf_rel_tbl.exists(k) and
		   g_modf_rel_tbl(k).line_detail_index = in_list_line_id)
		 then

		 for ix in g_manual_modifier_tbl.first..g_manual_modifier_tbl.last
			   loop
		    if ( g_manual_modifier_tbl.exists(ix) and
			 g_manual_modifier_tbl(ix).p_line_id = in_line_id and
			 g_manual_modifier_tbl(ix).list_line_id =g_modf_rel_Tbl(k).rltd_line_detail_index)
		    then
                      -- delete the corresponding attributes
		       if g_modf_attributes_tbl.count >0 then
			  for ms in g_modf_attributes_tbl.first..g_modf_attributes_tbl.last
				    loop
			     if (g_modf_attributes_tbl.exists(ms) and
				 g_modf_attributes_tbl(ms).p_line_id = in_line_id and
				 g_modf_attributes_tbl(ms).p_list_line_id = g_manual_modifier_tbl(ix).list_line_id)
			     then
				g_modf_attributes_tbl.DELETE(ms);
			     end if;
			  end loop;
		       end if;

		       g_manual_modifier_tbl.DELETE(ix);
		    end if;
		 end loop;
                  g_modf_rel_tbl.delete(k);
	      end if;
	      end loop;

	    end if; -- if pbh;

	    -- delete the corresponding attributes
	/*    if g_modf_attributes_tbl.count >0 then
	       for ms in g_modf_attributes_tbl.first..g_modf_attributes_tbl.last
			 loop
		  if (g_modf_attributes_tbl.exists(ms) and
		      g_modf_attributes_tbl(ms).p_line_id = in_line_id and
		      g_modf_attributes_tbl(ms).p_list_line_id = g_manual_modifier_tbl(i).list_line_id)
		  then
		     g_modf_attributes_tbl.DELETE(ms);
		  end if;
	       end loop;
	    end if; */

	    g_manual_modifier_tbl.DELETE(i);

	 IF l_debug_level > 0 then
	  oe_debug_pub.add('Deleted the modifier');
       END IF;

      end if;
   end loop;
END Delete_Applied_Manual_Adj;


   PROCEDURE Insert_Manual_Adjustment(in_line_id in number,
				in_line_index in number)
   IS
      x_status_code  varchar2(100);
      x_status_text varchar2(2000);
      in_line_detail_index number;
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      l_line_index number;
      l_line_detail_index number;
      rltd_line_index number;
      rltd_line_detail_index number;
     l_applied_flag varchar2(1):='Y';
      l_price_break_type_code varchar2(30);
      l_insert_flag varchar2(2);
      rs number;
   BEGIN
      oe_debug_pub.add('entered insert adjustment'||g_manual_modifier_tbl.count);
      select count(*)  into in_line_detail_index from qp_preq_ldets_tmp;

      for i in g_manual_modifier_tbl.first..g_manual_modifier_tbl.last
	       Loop
           l_insert_flag:='Y';

	   IF g_manual_modifier_tbl(i).modifier_level_code ='ORDER' then
            if g_applied_manual_tbl.count > 0 then
	      for xs in g_applied_manual_tbl.first..g_applied_manual_tbl.last
			loop
		 if (g_applied_manual_tbl.exists(xs) and
		     g_applied_manual_tbl(xs)= g_manual_modifier_tbl(i).list_line_id)
		 then
		    l_insert_flag:='N';
		    exit;
		    end if;
		 end loop;
                end if;-- for count;
              end if;-- for order level;

	      if l_insert_flag = 'Y' then

	      rs:= g_applied_manual_tbl.count;
	      g_applied_manual_tbl(rs+1):= g_manual_modifier_tbl(i).list_line_id;

	 if g_manual_modifier_tbl(i).p_line_id=in_line_id or g_manual_modifier_tbl(i).modifier_level_code = 'ORDER' then
           in_line_detail_index:= in_line_detail_index+1;


           IF (nvl(g_manual_modifier_tbl(i).list_line_type_code,NULL) <>'PBH'
	       and g_manual_modifier_tbl(i).line_detail_type_code ='CHILD_DETAIL_LINE')
	   then
	      l_applied_flag :='N';
	      l_price_break_type_code:=NULL;
	   else
	      l_applied_flag := 'Y';
	      l_price_break_type_code:=g_manual_modifier_tbl(i).price_break_type_code;
	   end if;

	   IF l_debug_level >0 then
	      oe_debug_pub.add('line index'||in_line_index);
	      oe_debug_pub.add('line detail index'||in_line_detail_index);
	      oe_debug_pub.add('Line id'||g_manual_modifier_tbl(i).p_line_id);
	      oe_debug_pub.add('Modifier_number'||g_manual_modifier_tbl(i).modifier_number);
	      oe_debug_pub.add('List type code'||g_manual_modifier_tbl(i).list_line_type_code);
	      oe_debug_pub.add('Operator'||g_manual_modifier_tbl(i).operator);
	      oe_debug_pub.add('Operand'||g_manual_modifier_tbl(i).operand);
	      oe_debug_pub.add('List line id'||g_manual_modifier_tbl(i).list_line_id);
	      oe_debug_pub.add('List header id'||g_manual_modifier_tbl(i).list_header_id);
	      oe_debug_pub.add('Pricing phase id'||g_manual_modifier_tbl(i).pricing_phase_id);
	      oe_debug_pub.add('automatic flag'||g_manual_modifier_tbl(i).automatic_flag);
	      oe_debug_pub.add('modifier_level_code'||g_manual_modifier_tbl(i).modifier_level_code);
	      oe_debug_pub.add('Override flag'||g_manual_modifier_tbl(i).override_flag);
              oe_Debug_pub.add('line_detail_type_code'||g_manual_modifier_tbl(i).line_detail_type_code);
	      oe_debug_pub.add('price break type code'||g_manual_modifier_tbl(i).price_break_type_code);
	      oe_debug_pub.add('Applied flag'||l_applied_flag||
			       ' price_break_type='||l_price_break_type_code);
	   END IF;


	   IF g_manual_modifier_tbl(i).modifier_level_code = 'ORDER' then
	      l_line_index := 1;
	   ELSE
	      l_line_index := in_line_index;
	   END IF;


INSERT INTO QP_NPREQ_LDETS_TMP
		 (LINE_DETAIL_INDEX,
		  LINE_DETAIL_TYPE_CODE,
		  LINE_INDEX,
		  PROCESS_CODE,
		  PRICING_PHASE_ID,
		  OPERAND_CALCULATION_CODE,
		  OPERAND_VALUE,
		  OVERRIDE_FLAG,
		  CREATED_FROM_LIST_TYPE_CODE,
		  CREATED_FROM_LIST_HEADER_ID,
		  CREATED_FROM_LIST_LINE_ID,
		  CREATED_FROM_LIST_LINE_TYPE,
		  PRICING_STATUS_CODE,
		  APPLIED_FLAG,
		  MODIFIER_LEVEL_CODE,
		  UPDATED_FLAG,
                  PRICE_BREAK_TYPE_CODE)
		  --ORDER_QTY_OPERAND)

  VALUES (       in_LINE_DETAIL_INDEX,
		' ',
		 --in_LINE_INDEX,
		 l_LINE_INDEX,
		 'N',
		 g_manual_modifier_tbl(i).pricing_phase_id,
		 g_manual_modifier_tbl(i).operator,
		 g_manual_modifier_tbl(i).operand,
		 g_manual_modifier_tbl(i).override_flag,
		 ' ',
		 g_manual_modifier_tbl(i).list_header_id,
		 g_manual_modifier_tbl(i).list_line_id,
		 g_manual_modifier_tbl(i).list_line_type_code,
		 'X',
		 --'N',
                 l_applied_flag,
		 g_manual_modifier_tbl(i).modifier_level_code,
		 'Y',
                 l_price_break_type_code);
		-- 1);
--END IF;


       if g_manual_modifier_tbl(i).list_line_type_code='PBH' then
	  Insert into qp_npreq_line_attrs_tmp
		     (Line_index,
		      Line_detail_index,
		      attribute_level,
		      attribute_type,
		      list_header_id,
		      list_line_id,
		      context,
		      attribute,
		      value_from,
		      value_to,
		      pricing_status_code,
                      pricing_phase_id,
                      modifier_level_code,
		      validated_flag)
		     values
	             (in_line_index,
		      in_line_detail_index,
		      'LINE',
		      'PRICING',
	              g_manual_modifier_tbl(i).list_header_id,
		      g_manual_modifier_tbl(i).list_line_id,
		     'VOLUME',
		     'PRICING_ATTRIBUTE10',
		      0,
		      0 ,
		      'X',
		      g_manual_modifier_tbl(i).pricing_phase_id,
		      g_manual_modifier_tbl(i).modifier_level_code,
		      'N');
	 oe_debug_pub.add('inserted pbh line into qp_preq_line_attrs_tmp');
        end if;

   if g_modf_attributes_tbl.count >0 then
   for k in g_modf_attributes_tbl.first..g_modf_attributes_tbl.last
	    loop
      if g_modf_attributes_tbl(k).p_list_line_id = g_manual_modifier_Tbl(i).list_line_id then

 IF l_debug_level >0 then
	      oe_debug_pub.add('line index'||in_line_index);
	      oe_debug_pub.add('line detail index'||in_line_detail_index);
	      oe_debug_pub.add('list_header_id'|| g_manual_modifier_tbl(i).list_header_id);
	      oe_debug_pub.add('list line id'|| g_manual_modifier_tbl(i).list_line_id);
	      oe_debug_pub.add('context'|| g_modf_attributes_tbl(k).p_context);
	      oe_debug_pub.add('attribute'|| g_modf_attributes_tbl(k).p_attribute);
              oe_debug_pub.add('Value from'|| g_modf_attributes_tbl(k).p_attr_value_from);
	      oe_debug_pub.add('Value to'|| g_modf_attributes_tbl(k).p_attr_value_to);

	  end if;

         Insert into qp_npreq_line_attrs_tmp
		     (Line_index,
		      Line_detail_index,
		      attribute_level,
		      attribute_type,
		      list_header_id,
		      list_line_id,
		      context,
		      attribute,
		      value_from,
		      value_to,
		      pricing_status_code,
                      pricing_phase_id,
                      modifier_level_code,
		      validated_flag)
		     values
	             (in_line_index,
		      in_line_detail_index,
		      'LINE',
		      'PRICING',
	              g_manual_modifier_tbl(i).list_header_id,
		      g_manual_modifier_tbl(i).list_line_id,
		      g_modf_attributes_tbl(k).p_context,
		      g_modf_attributes_tbl(k).p_attribute,
		      g_modf_attributes_tbl(k).p_attr_value_from,
		      g_modf_attributes_tbl(k).p_attr_value_to,
		      'X',
		      g_manual_modifier_tbl(i).pricing_phase_id,
		      g_manual_modifier_tbl(i).modifier_level_code,
		      'N');
	    end if;
	 end loop;
      end if;

oe_debug_pub.add('after inserting attributes');

END IF;-- if line id
END IF; -- if order level modifiers not applied
End Loop;

if g_modf_rel_Tbl.count>0 then
 for s in g_modf_rel_tbl.first..g_modf_rel_tbl.last
	  loop
    if g_modf_rel_tbl.exists(s) and g_modf_rel_Tbl(s).p_line_id=in_line_id
				then

       select line_index,line_detail_index into l_line_index,l_line_detail_index
	 from qp_preq_ldets_Tmp where created_From_list_line_id=g_modf_rel_tbl(s).line_detail_index;

     select line_index,line_detail_index into rltd_line_index,rltd_line_detail_index from
      qp_preq_ldets_tmp where created_from_list_line_id=g_modf_rel_tbl(s).rltd_line_detail_index;

IF l_debug_level >0 then
	      oe_debug_pub.add('line index'||l_line_index);
	      oe_debug_pub.add('line detail index'||l_line_detail_index);
	      oe_debug_pub.add('related line index'|| rltd_line_index);
	      oe_debug_pub.add('related line detail index'||rltd_line_detail_index );
	end if;


     Insert into qp_npreq_rltd_lines_tmp
		  (line_index,
		   line_detail_index,
		   related_line_index,
		   related_line_detail_index,
		   pricing_status_code,
		   relationship_type_code)
		  Values
                  (l_line_index,
		   l_line_detail_index,
		   rltd_line_index,
		   rltd_line_detail_index,
		   'N',
		   'PBH_LINE');

       end if;
 end loop;
 oe_Debug_pub.add('after inserting relationship types');
end if;

oe_debug_pub.add('end of inserting');

EXCEPTION
   WHEN OTHERS THEN
      x_status_code := FND_API.G_RET_STS_ERROR;
      x_status_text :=SQLERRM;
      oe_debug_pub.add('insert into ldets'||x_status_code||'error'||x_status_text);
END Insert_Manual_Adjustment;

      PROCEDURE pass_promotions_to_backend (in_promotions_tbl promotions_tbl,
                                      in_line_id in number) IS

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_ctr number;

BEGIN

   if l_debug_level > 0 then
     oe_debug_pub.add('Entering PLS pass promotions to backend');
     oe_debug_pub.add('line_id='||in_line_id||
                      ' Count ='||in_promotions_tbl.COUNT);
   end if;

   l_ctr := g_promotions_tbl.COUNT + 1;

   -- Remove the promotion records if they already exist for that line_id
   IF g_promotions_tbl.COUNT > 0 then
     for m in g_promotions_tbl.FIRST..g_promotions_tbl.LAST
     LOOP
       oe_Debug_pub.add('deleting current promotions');
       IF g_promotions_tbl(m).p_line_id = in_line_id then
         oe_Debug_pub.add('actually deleting current promotions');
         g_promotions_tbl.DELETE(m);
       END IF;

     END LOOP;
   END IF;

   IF  in_promotions_tbl.COUNT > 0 then

   for i in in_promotions_tbl.first..in_promotions_tbl.last
   LOOP

     g_promotions_tbl(l_ctr):=in_promotions_tbl(i);

     IF l_debug_level > 0 then
       oe_debug_pub.add('line_id='||g_promotions_tbl(l_ctr).p_line_id||
                     ' type= '||g_promotions_tbl(l_ctr).p_type||
                     ' Level='||g_promotions_tbl(l_ctr).p_level||
                     ' Attr1='||g_promotions_tbl(l_ctr).p_pricing_attribute1||
                     ' Attr2='||g_promotions_tbl(l_ctr).p_pricing_attribute2||
                     ' Attr3='||g_promotions_tbl(l_ctr).p_pricing_attribute3);
     END IF;
     l_ctr := l_ctr + 1;

   END LOOP;
   END IF;

   oe_debug_pub.add('Exiting PLS pass promotions to backend count='||
                     g_promotions_tbl.COUNT);

END pass_promotions_to_backend;


PROCEDURE copy_attribs_to_Req(
       p_line_index number
      ,px_Req_line_attr_tbl in out nocopy  oe_oe_pricing_availability.QP_LINE_ATTR_TBL_TYPE
      ,px_Req_qual_tbl in out  nocopy  oe_oe_pricing_availability.QP_QUAL_TBL_TYPE
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
      oe_debug_pub.add(  'ENTERING oe_oe_pricing_availability.COPY_ATTRIBS_TO_REQ' , 1 ) ;
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
    oe_debug_pub.add(  'EXITING oe_oe_pricing_availability.COPY_ATTRIBS_TO_REQ' , 1 ) ;
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
--Bug 7409782
--l_gsa_violation_action Varchar2(30) :=fnd_profile.value('ONT_GSA_VIOLATION_ACTION');
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

--Bug 7409782
l_GSA_Enabled_Flag 	Varchar2(30) := FND_PROFILE.VALUE('QP_VERIFY_GSA');
l_gsa_violation_action  Varchar2(30) := nvl(oe_sys_parameters.value('ONT_GSA_VIOLATION_ACTION'),'WARNING');
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
      FND_MESSAGE.SET_TOKEN('ERR_TEXT',in_status_text); --3730467
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
        --Bug 7409782 starts
        IF l_gsa_violation_action = 'WARNING'
        THEN
           l_return_status := 'W';
        ELSE
           l_return_status := 'E';
        END IF;
        --Bug 7409782 ends

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

  --Bug 7409782
  IF l_return_status IN('E','W') then
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

PROCEDURE get_item_name(l_inv_item_id in number,
			out_inv_item_name out nocopy varchar2
			)
IS
l_org_id number := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
SELECT concatenated_segments
       INTO  out_inv_item_name
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = l_inv_item_id
       AND    organization_id = l_org_id;


EXCEPTION
    when no_data_found then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_AVAILABILITY.GET_item_name NO DATA FOUND' ) ;
        END IF;
    when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_AVAILABILITY.GET_item_NAME WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
                        END IF;

END get_item_name;

PROCEDURE get_item_type(in_item_type_code in  varchar2,
			out_meaning out nocopy varchar2
			)
IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type varchar2(50) ;  -- added for bug 3776769
BEGIN
   l_lookup_type := 'ITEM_IDENTIFIER_TYPE';
   Select meaning into out_meaning from oe_lookups
      where lookup_type = l_lookup_type  and  -- added for bug 3776769
            lookup_code=in_item_type_code;


EXCEPTION
    when no_data_found then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_AVAILABILITY.GET_item_type NO DATA FOUND' ) ;
        END IF;
    when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_AVAILABILITY.GET_item_type WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
                        END IF;

END get_item_type;


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
            oe_debug_pub.add(  'OE_AVAILABILITY.GET_item_upgrade_details NO DATA FOUND' ) ;
        END IF;
    when others then
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_AVAILABILITY.GET_item_NAME WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
                        END IF;

END get_upgrade_item_details;

PROCEDURE get_oid_information(l_list_line_no in number,
			      out_inv_item_name out nocopy varchar2)
IS
   l_item_id number;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_desc varchar2(200);
BEGIN
     select product_attr_value into l_item_id from qp_pricing_attributes
      where list_line_id=l_list_line_no;

   oe_debug_pub.add('after fetching the attribute value');

   get_item_name(l_inv_item_id=>l_item_id,
		 out_inv_item_name=>out_inv_item_name);




EXCEPTION
   when no_data_found then
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'OE_AVAILABILITY.GET_oid_information NO DATA FOUND' ) ;
END IF;
when others then
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'OE_AVAILABILITY.GET_oid_information WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
END IF;

END get_oid_information;

PROCEDURE get_coupon_details(in_list_line_id in number,
			     in_list_header_id in number,
			     out_benefit out nocopy varchar2,
			     out_benefit_method out nocopy varchar2,
			     out_benefit_value out nocopy varchar2,
			     out_benefit_item out nocopy varchar2)

IS
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_list_line_no NUMBER;
   l_code varchar2(200);
   l_operator varchar2(100);
   l_operand number;
   l_item_id varchar2(100);
   l_desc varchar2(100);
BEGIN
   oe_debug_pub.add('before fetching the related lines');

     select to_rltd_modifier_id into l_list_line_no
       from qp_rltd_modifiers where
      from_rltd_modifier_id=in_list_line_id;

   oe_debug_pub.add('after fetching the related line');

     select list_line_type_code,
	    arithmetic_operator,
	    operand into
      l_code,l_operator,l_operand
       from qp_list_lines where list_line_id=l_list_line_no;

   oe_debug_pub.add('after fetching the line details ');

   out_benefit:= get_qp_lookup_meaning(in_lookup_type=>'LIST_LINE_TYPE_CODE',
				       in_lookup_code=>l_code);
   out_benefit_method := get_qp_lookup_meaning(in_lookup_type=>'ARITHMETIC_OPERATOR',
					       in_lookup_code=>l_operator);
   out_benefit_value := l_operand;

   oe_debug_pub.add('out_benefit'||out_benefit||'out_benefit_method'
		    ||out_benefit_method||'out_benefit_value'||out_benefit_value);

     select product_attr_value into l_item_id from qp_pricing_attributes
      where list_line_id=l_list_line_no;

   oe_debug_pub.add('after fetching the attribute value');

   get_item_name(l_inv_item_id=>l_item_id,
		 out_inv_item_name=>out_benefit_item);


   oe_debug_pub.add('inventory item returned'||out_benefit_item);
EXCEPTION
   when no_data_found then
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'OE_AVAILABILITY.GET_coupon_details NO DATA FOUND' ) ;
END IF;
when others then
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'OE_AVAILABILITY.GET_coupon_details WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
END IF;

END get_coupon_details;

PROCEDURE get_terms_details(in_substitution_attribute in varchar2,
			    in_substitution_to in varchar2,
			    out_benefit_method out nocopy varchar2,
			    out_benefit_value out nocopy varchar2)

IS

   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_benefit_method Varchar2(500);
   l_segment_code Varchar2(500);
   l_lang_code Varchar2(10);
   l_lookup_type Varchar2(50);
BEGIN

  if l_Debug_level >0 then
   oe_debug_pub.add('entering terms with parameter Substitution attribute'||in_substitution_attribute||'substituion'||
		    in_substitution_to);
   end if;
   Begin
	select segment_code into l_benefit_method  from qp_segments_b qsb,qp_prc_contexts_b qpcb
	 where qsb.prc_context_id=qpcb.prc_context_id and
      qsb.segment_mapping_column=in_substitution_attribute and qpcb.prc_context_code='TERMS';
   Exception
      When others then
	 oe_Debug_pub.add('Exception while quering for the terms'||SQLCODE||SQLERRM);
   End ;
   -- added recently


 /*  qp_util.Get_Attribute_Code(p_FlexField_Name  => 'QP_ATTR_DEFNS_QUALIFIER',
			      p_Context_Name    =>  'TERMS',
			      p_attribute       => l_benefit_method, -- <attribute_code>, -- pass the code like "FREIGHT_TERMS"
			      x_attribute_code  =>out_benefit_method,   -- <attribute_text>, -- get the text like "Freight Terms"
			      x_segment_name    => l_segment_code
                                  );*/
   Begin
	select language_code into l_lang_code from fnd_languages  where installed_flag='B';

	select user_segment_name into out_benefit_method from qp_segments_tl qst,qp_segments_b qsb
   where qst.segment_id= qsb.segment_id and qsb.segment_code=l_benefit_method and qst.language=l_lang_code;
   Exception
      When Others then
	 oe_Debug_pub.add(' Exception while queries for  terms and language code'||SQLCODE||SQLERRM);
   End;
   if l_Debug_level >0 then
   oe_debug_pub.add('final benefit method'||out_benefit_method);
   end if;



       IF l_benefit_method ='PAYMENT_TERMS' then
	    select name into out_benefit_value from ra_terms where term_id=in_substitution_to;
       ELSIF l_benefit_method='FREIGHT_TERMS' then
	    select freight_terms into out_benefit_value from oe_frght_terms_Active_v
	     where freight_terms_code=in_substitution_to;
       ELSIF l_benefit_method ='SHIPPING_TERMS' then
	     l_lookup_type := 'SHIP_METHOD';
	    select meaning into out_benefit_value from oe_ship_methods_v where
	     lookup_type = l_lookup_type and lookup_code=in_substitution_to;
       END IF;

       oe_debug_pub.add('final benefit value'||out_benefit_value);

    EXCEPTION
       when no_data_found then
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'OE_AVAILABILITY.GET_terms_details NO DATA FOUND' ) ;
    END IF;
    when others then
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE_AVAILABILITY.GET_terms_details WHEN OTHERS '|| SQLERRM||SQLCODE ) ;
    END IF;

END get_terms_details;



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
      l.list_line_type_code,
      nvl(l.end_date_active,h.end_date_active),
      l.start_date_active,
      l.modifier_level_code
       INTO
      out_list_line_type_code,
      out_end_date,
      out_start_date,
      out_modifier_level_code

       FROM qp_list_lines l,qp_list_headers h
      WHERE l.list_line_id = in_list_line_id
        AND h.list_header_id = l.list_header_id;


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
                                ,out_bom_item_type out nocopy varchar2
                                ,out_replenish_to_order_flag out nocopy varchar2
                                ,out_build_in_wip_flag out nocopy varchar2
                                ,out_default_so_source_type out nocopy varchar2
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
	    atp_flag,
            bom_item_type,
            replenish_to_order_flag,
            build_in_wip_flag,
            decode(default_so_source_type,'EXTERNAL','External','INTERNAL','Internal')
       FROM mtl_system_items
      WHERE inventory_item_id = in_inventory_item_id
	AND organization_id   = in_org_id;

   l_default_shipping_org number;
   l_source_organization_id number;
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
   l_lookup_type varchar2(50);
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING oe_oe_pricing_availability.GET_ITEM_INFO'||
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
	    out_weight_uom,
	    out_unit_volume,
	    out_volume_uom,
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
	    out_atp_flag,
            out_bom_item_type,
            out_replenish_to_order_flag,
            out_build_in_wip_flag,
            out_default_so_source_type;

   CLOSE c_item_Info;

   out_item_status := l_inventory_item_status_code;

   IF l_make_buy = 1 then
      out_make_or_buy := 'Make';
   ELSE
      out_make_or_buy := 'Buy';
   END IF;


   oe_oe_pricing_availability.get_Ship_From_Org
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
   l_lookup_type := 'ITEM_TYPE';   -- added for bug 3776769
   IF l_user_item_type is NOT NULL then
	select meaning
          into out_user_item_type
	 from fnd_common_lookups
        where lookup_type = l_lookup_type   -- added for bug 3776769
          and lookup_code = l_user_item_type;
   ELSE
      out_user_item_type := null;

   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING oe_oe_pricing_availability.GET_ITEM_INFO'||
			 ' ITEM_STATUS ='||OUT_ITEM_STATUS ) ;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      IF c_item_info%ISOPEN then
	 CLOSE c_item_info;
END IF;

IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'WHEN OTHERS oe_oe_pricing_availability.GET_ITEM_INFO '||
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
   -- No need to check profile.. Instead get the link from
   -- table mrp_ap_apps_instances 4113599
   -- l_mrp_atp_database_link := fnd_profile.value('MRP_ATP_DATABASE_LINK');

   --Bug 6716697: Wrong dblink name was selected. Corrcted as per ATP team
   select a2m_dblink
   into l_mrp_atp_database_link
   from mrp_ap_apps_instances;

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
					     status_flag,
                                             order_line_id)
	   VALUES
	    (l_instance_id,
	     l_session_id,
	     in_inventory_item_id,
	     l_org_id,
	     -1,
	     l_customer_id,
	     l_customer_site_id,
	     l_ship_method,
	     4,
             -1
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
l_item_id number;
l_org_id number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_item_id:=g_panda_rec_table(1).p_inventory_item_id;
   l_org_id:= in_org_id;

   if g_upgrade_item_exists ='Y' then
      if g_upgrade_item_id is not null then
	 l_item_id:= g_upgrade_item_id;
      end if;
      if g_upgrade_ship_from_org_id is not null then
	 l_org_id:=g_upgrade_ship_from_org_id;
      end if;
   end if;

    Query_Qty_Tree( p_org_id=>l_org_id
                   ,p_item_id=>l_item_id
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
        oe_debug_pub.add(  'oe_oe_pricing_availability.SET_MRP_DEBUG NO_DATA_FOUND' ) ;
    END IF;
  WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'WHEN OTHERS oe_oe_pricing_availability.SET_MRP_DEBUG '|| SQLCODE||SQLERRM ) ;
                    END IF;

END set_mrp_debug;

PROCEDURE CopyINTO_PO_RecStruc
   (         p_header_rec in  oe_oe_pricing_availability.PA_Header_Tbl_Type,
             p_line_tbl in Oe_Oe_Pricing_Availability.PA_Line_Tbl_Type,
             p_Header_Adj_tbl in Oe_Oe_Pricing_Availability.PA_H_Adj_Tbl_Type,
             p_Line_Adj_tbl in  Oe_Oe_Pricing_Availability.PA_LAdj_Tbl_Type,
             p_Header_price_Att_tbl in Oe_Oe_Pricing_Availability.PA_H_PAtt_Tbl_Type,
             p_Header_Adj_Att_tbl in Oe_Oe_Pricing_Availability.PA_H_Adj_Att_Tbl_Type,
             p_Header_Adj_Assoc_tbl in  Oe_Oe_Pricing_Availability.PA_H_Adj_AsTbl_Type,
             p_Line_price_Att_tbl in  Oe_Oe_Pricing_Availability.PA_Line_PAtt_Tbl_Type,
             p_Line_Adj_Att_tbl in  Oe_Oe_Pricing_Availability.PA_LAdj_Att_Tbl_Type,
             p_Line_Adj_Assoc_tbl in Oe_Oe_Pricing_Availability.PA_L_Adj_AssTbl_Type,
             x_header_rec out NOCOPY /* file.sql.39 change */ OE_order_pub.Header_Rec_Type,
             x_line_tbl out NOCOPY /* file.sql.39 change */ OE_Order_Pub.Line_Tbl_Type,
             x_Header_Adj_tbl out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Header_Adj_Tbl_Type,
             x_Line_Adj_tbl   out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Line_Adj_Tbl_Type,
             x_Header_price_Att_tbl out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Header_Price_Att_Tbl_Type,
             x_Header_Adj_Att_tbl out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Header_Adj_Att_Tbl_Type,
             x_Header_Adj_Assoc_tbl  out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Header_Adj_Assoc_Tbl_Type,
             x_Line_price_Att_tbl  out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Line_Price_Att_Tbl_Type,
             x_Line_Adj_Att_tbl  out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Line_Adj_Att_Tbl_Type,
             x_Line_Adj_Assoc_tbl out NOCOPY /* file.sql.39 change */ Oe_Order_Pub.Line_Adj_Assoc_Tbl_Type)
IS
 j Number;
Begin



   IF p_header_rec.EXISTS(1) Then
      --copy header info
x_header_rec:=OE_Order_PUB.G_MISS_HEADER_REC;

  IF p_header_rec(1).sold_to_org_id  is not null then
    x_header_rec.sold_to_org_id :=p_header_rec(1).sold_to_org_id;
  END IF;

  IF p_header_rec(1).conversion_type_code is not null then
    x_header_rec.conversion_type_code := p_header_rec(1).conversion_type_code;
  END IF;

 IF p_header_rec(1).conversion_rate is not null then
  x_header_rec.conversion_rate := p_header_rec(1).conversion_rate;
  END IF;

  IF p_header_rec(1).ship_to_org_id is not null then
    x_header_rec.ship_to_org_id := p_header_rec(1).ship_to_org_id;
  END IF;

  IF p_header_rec(1).invoice_to_org_id is not null then
    x_header_rec.invoice_to_org_id := p_header_rec(1).invoice_to_org_id;
  END IF;

  IF p_header_rec(1).demand_class_code is not null then
    x_header_rec.demand_class_code :=p_header_rec(1).demand_class_code;
  END IF;

  x_header_rec.ordered_date := sysdate;

  IF p_header_rec(1).order_type_id is not null then
    x_header_rec.order_type_id := p_header_rec(1).order_type_id;
  END IF;

  IF  p_header_rec(1).pricing_date is not null then
  x_header_rec.pricing_date := p_header_rec(1).pricing_date;
  END IF;

  IF p_header_rec(1).ship_from_org_id is not null then
    x_header_rec.ship_from_org_id := p_header_rec(1).ship_from_org_id;
  END IF;
  IF p_header_rec(1).request_date is not null then
  x_header_rec.request_date :=p_header_rec(1).request_date;
  END IF;

  IF p_header_rec(1).transactional_curr_code is not null then
    x_header_rec.transactional_curr_code := p_header_rec(1).transactional_curr_code;
  END IF;
  IF p_header_rec(1).order_number is not null then
    x_header_rec.order_number := p_header_rec(1).order_number;
  END IF;

 oe_debug_pub.add('=====After copying Header==================================='||
		  ' Customer id = '||x_header_rec.sold_to_org_id||
           ' Currency ='||x_header_rec.transactional_curr_code||
           ' order_type_id ='||x_header_rec.order_type_id||
           ' agreement_id ='||x_header_rec.agreement_id||
           ' price_list_id ='||x_header_rec.price_list_id||
           ' ship_to_org_id ='||x_header_rec.ship_to_org_id||
           ' invoice_to_org_id ='||x_header_rec.invoice_to_org_id||
           ' Conversion_type_code ='||x_header_rec.Conversion_type_code||
           ' Conversion_rate ='||x_header_rec.Conversion_rate||
           ' Order_Number ='||x_header_rec.order_number||
		  'Header id='||x_header_rec.header_id
          );
End if;

IF p_Header_Adj_tbl.count > 0 Then
	 -- Copy header adjustments
   j:=0;
   for i in p_Header_Adj_tbl.first..p_Header_Adj_tbl.last
	    Loop
      If p_Header_Adj_tbl.Exists(i) Then
	 j:=j+1;
	 x_header_adj_tbl(j):= Oe_Order_Pub.G_Miss_Header_Adj_rec;

	 if  p_header_adj_tbl(i).list_header_id is not null then
	    x_header_adj_tbl(j).list_header_id:= p_header_adj_tbl(i).list_header_id;
	 end if;
	 if p_header_adj_tbl(i).list_line_id is not null then
	    x_header_adj_tbl(j).list_line_id:=  p_header_adj_tbl(i).list_line_id;
	 end if;
	 if  p_header_adj_tbl(i).list_line_type_code is not null then
	    x_header_adj_tbl(j).list_line_type_code:=  p_header_adj_tbl(i).list_line_type_code;
	 end if;
	 if  p_header_adj_tbl(i).updated_flag is not null then
	    x_header_adj_tbl(j).updated_flag:= p_header_adj_tbl(i).updated_flag;
	 end if;

	 if  p_header_adj_tbl(i).applied_flag is not null then
	    x_header_adj_tbl(j).applied_flag:= p_header_adj_tbl(i).applied_flag;
	 end if;

	 if  p_header_adj_tbl(i).operand is not null then
	    x_header_adj_tbl(j).operand   :=  p_header_adj_tbl(i).operand;
	 end if;

	 if p_header_adj_tbl(i).arithmetic_operator is not null then
	    x_header_adj_tbl(j).arithmetic_operator := p_header_adj_tbl(i).arithmetic_operator;
	 end if;
	 if  p_header_adj_tbl(i).pricing_phase_id is not null then
	    x_header_adj_tbl(j).pricing_phase_id  :=  p_header_adj_tbl(i).pricing_phase_id;
	 end if;

	 if  p_header_adj_tbl(i).modifier_level_code is not null then
	    x_header_adj_tbl(j).modifier_level_code	 := 	    p_header_adj_tbl(i).modifier_level_code;
	 end if;
	 if p_header_adj_tbl(i).price_break_type_code is not null then
	    x_header_adj_tbl(j).price_break_type_code := 	    p_header_adj_tbl(i).price_break_type_code;
	 end if;

      End If;
   End Loop;
End if;



IF p_Header_price_Att_tbl.count > 0 Then
      -- Copy header price attribute table
 j:=0;
 for i in p_header_price_att_tbl.first..p_header_price_att_tbl.last
	  Loop
    if p_header_price_att_tbl.Exists(i) then
       j:=j+1;
x_header_price_att_tbl(j):=OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_REC;

if p_header_price_att_tbl(i).flex_title is not null then
x_header_price_att_tbl(j).flex_title		 := p_header_price_att_tbl(i).flex_title;
end if;
if p_header_price_att_tbl(i).pricing_context is not null then
x_header_price_att_tbl(j).pricing_context  	 := p_header_price_att_tbl(i).pricing_context;
end if;
if p_header_price_att_tbl(i).pricing_attribute1 is not null then
x_header_price_att_tbl(j).pricing_attribute1     := p_header_price_att_tbl(i).pricing_attribute1;
end if;
if p_header_price_att_tbl(i).pricing_attribute2 is not null then
x_header_price_att_tbl(j).pricing_attribute2     := p_header_price_att_tbl(i).pricing_attribute2;
end if;
if p_header_price_att_tbl(i).pricing_attribute3 is not null then
x_header_price_att_tbl(j).pricing_attribute3     := p_header_price_att_tbl(i).pricing_attribute3;
end if;

end if;
End Loop;
End if;


IF p_Header_Adj_Att_tbl.count > 0 Then
          -- Copy header adjustments attribute
j:=0;
For i in p_Header_Adj_Att_tbl.first..p_Header_Adj_Att_tbl.last
	 Loop
If p_Header_Adj_Att_tbl.Exists(i) Then
   j:=j+1;
x_Header_Adj_Att_tbl(j):=OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_REC;

End if;
End Loop;
End if;


IF p_Header_Adj_Assoc_tbl.count > 0 Then
      -- Copy header adjustments associations
j:=0;
For i in p_Header_Adj_Assoc_tbl.first..p_Header_Adj_Assoc_tbl.last
	 Loop
   If p_Header_Adj_Assoc_tbl.Exists(i) Then
      j:=j+1;
x_Header_Adj_Assoc_tbl(j):=OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_REC;

End if;
End loop;
End if;


IF p_line_Tbl.count > 0 Then
   -- Copy line infor
j:=0;
For i in p_line_Tbl.first..p_line_Tbl.last
	 Loop
   j:=j+1;
   if p_line_Tbl.Exists(i) Then
x_line_Tbl(j):=OE_ORDER_PUB.G_MISS_LINE_REC;

if  p_line_Tbl(i).agreement_id is not null then
x_line_Tbl(j).agreement_id                    		   :=  p_line_Tbl(i).agreement_id;
end if;

if  p_line_Tbl(i).created_by is not null then
x_line_Tbl(j).created_by                      		   :=  p_line_Tbl(i).created_by;
end if;
if p_line_Tbl(i).creation_date is not null then
x_line_Tbl(j).creation_date                   		   :=  p_line_Tbl(i).creation_date;
end if;

if p_line_Tbl(i).deliver_to_org_id is not null then
x_line_Tbl(j).deliver_to_org_id               		   :=  p_line_Tbl(i).deliver_to_org_id;
end if;

if  p_line_Tbl(i).demand_class_code is not null then
x_line_Tbl(j).demand_class_code               		   :=  p_line_Tbl(i).demand_class_code;
end if;

if  p_line_Tbl(i).inventory_item_id is not null then
x_line_Tbl(j).inventory_item_id             		   :=  p_line_Tbl(i).inventory_item_id;
end if;

if  p_line_Tbl(i).invoice_to_org_id is not null then
x_line_Tbl(j).invoice_to_org_id             		   :=  p_line_Tbl(i).invoice_to_org_id;
end if;

if  p_line_Tbl(i).ordered_item is not null then
x_line_Tbl(j).ordered_item                  		   :=  p_line_Tbl(i).ordered_item;
end if;

if  p_line_Tbl(i).item_type_code is not null then
x_line_Tbl(j).item_type_code                 		   :=  p_line_Tbl(i).item_type_code;
end if;

if  p_line_Tbl(i).line_type_id is not null then
x_line_Tbl(j).line_type_id                   		   :=  p_line_Tbl(i).line_type_id;
end if;

if  p_line_Tbl(i).ordered_quantity is not null then
x_line_Tbl(j).ordered_quantity               		   :=  p_line_Tbl(i).ordered_quantity;
end if;

if  p_line_Tbl(i).order_quantity_uom is not null then
x_line_Tbl(j).order_quantity_uom             		   :=  p_line_Tbl(i).order_quantity_uom;
end if;

if  p_line_Tbl(i).price_list_id is not null then
x_line_Tbl(j).price_list_id                  		   :=  p_line_Tbl(i).price_list_id;
end if;

if  p_line_Tbl(i).pricing_date is not null then
x_line_Tbl(j).pricing_date                     		   :=  p_line_Tbl(i).pricing_date;
end if;

if  p_line_Tbl(i).request_date is not null then
x_line_Tbl(j).request_date                     		   :=  p_line_Tbl(i).request_date;
end if;

if  p_line_Tbl(i).ship_from_org_id is not null then
x_line_Tbl(j).ship_from_org_id              		   :=  p_line_Tbl(i).ship_from_org_id;
end if;

if  p_line_Tbl(i).ship_to_org_id is not null then
x_line_Tbl(j).ship_to_org_id                		   :=  p_line_Tbl(i).ship_to_org_id;
end if;

if  p_line_Tbl(i).ordered_item_id is not null then
x_line_Tbl(j).ordered_item_id                   	   :=  p_line_Tbl(i).ordered_item_id;
end if;
if p_line_Tbl(i).item_identifier_type is not null then
x_line_Tbl(j).item_identifier_type         		   :=  p_line_Tbl(i).item_identifier_type;
end if;

if p_line_Tbl(i).Original_Inventory_Item_Id is not null then
x_line_Tbl(j).Original_Inventory_Item_Id   		   :=  p_line_Tbl(i).Original_Inventory_Item_Id;
end if;
if  p_line_Tbl(i).Original_item_identifier_Type is not null then
x_line_Tbl(j).Original_item_identifier_Type		   :=  p_line_Tbl(i).Original_item_identifier_Type;
end if;
if  p_line_Tbl(i).Original_ordered_item_id is not null then
x_line_Tbl(j).Original_ordered_item_id     		   :=  p_line_Tbl(i).Original_ordered_item_id;
end if;
if  p_line_Tbl(i).Original_ordered_item is not null then
x_line_Tbl(j).Original_ordered_item       		   :=  p_line_Tbl(i).Original_ordered_item;
end if;
if  p_line_Tbl(i).Item_substitution_type_code is not null then
x_line_Tbl(j).Item_substitution_type_code  		   :=  p_line_Tbl(i).Item_substitution_type_code;
end if;

if  p_line_Tbl(i).item_relationship_type is not null then
x_line_Tbl(j).item_relationship_type       		   :=  p_line_Tbl(i).item_relationship_type;
end if;

End if;
End Loop;
End if;
oe_debug_pub.add('line_table count in copy'||x_line_tbl.count);
oe_Debug_pub.add('Adjsutment table count'||p_line_adj_tbl.count);
IF p_line_Adj_tbl.count > 0 Then
   -- Copy line adjustment table infor
j:=0;
For i in p_line_Adj_tbl.first..p_line_Adj_tbl.last
	 Loop
   If p_line_Adj_tbl.Exists(i) then
      j:=j+1;
x_line_Adj_tbl(j):=OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;

if  p_line_Adj_tbl(i).line_index is not null then

--commented for bug 3566972
/*
x_line_Adj_tbl(j).line_index :=1;
      --p_line_Adj_tbl(i).line_index;*/

x_line_Adj_tbl(j).line_index :=p_line_Adj_tbl(i).line_index;  -- added for bug 3566972

end if;

if  p_line_Adj_tbl(i).list_header_id is not null then
x_line_Adj_tbl(j).list_header_id :=   p_line_Adj_tbl(i).list_header_id;
end if;
if  p_line_Adj_tbl(i).list_line_id is not null then
x_line_Adj_tbl(j).list_line_id :=p_line_Adj_tbl(i).list_line_id;
end if;
if  p_line_Adj_tbl(i).list_line_type_code is not null then
x_line_Adj_tbl(j).list_line_type_code :=p_line_Adj_tbl(i).list_line_type_code;
end if;

if  p_line_Adj_tbl(i).updated_flag is not null then
x_line_Adj_tbl(j).updated_flag :=p_line_Adj_tbl(i).updated_flag;
end if;

if p_line_Adj_tbl(i).applied_flag is not null then
x_line_Adj_tbl(j).applied_flag:= p_line_Adj_tbl(i).applied_flag;
end if;

if  p_line_Adj_tbl(i).operand is not null then
x_line_Adj_tbl(j).operand :=p_line_Adj_tbl(i).operand;
end if;

if  p_line_Adj_tbl(i).arithmetic_operator is not null then
x_line_Adj_tbl(j).arithmetic_operator := p_line_Adj_tbl(i).arithmetic_operator;
end if;

if p_line_Adj_tbl(i).pricing_phase_id is not null then
x_line_Adj_tbl(j).pricing_phase_id		      :=   p_line_Adj_tbl(i).pricing_phase_id;
end if;

if p_line_Adj_tbl(i).modifier_level_code is not null then
x_line_Adj_tbl(j).modifier_level_code		      :=   p_line_Adj_tbl(i).modifier_level_code;
end if;
if p_line_Adj_tbl(i).price_break_type_code is not null then
x_line_Adj_tbl(j).price_break_type_code	   	      :=   p_line_Adj_tbl(i).price_break_type_code;
end if;

oe_Debug_pub.add('line index'||x_line_Adj_tbl(j).line_index||'list header id'||x_line_Adj_tbl(j).list_header_id
		 ||'list line id'||x_line_Adj_tbl(j).list_line_id ||'list line type code'||x_line_Adj_tbl(j).list_line_type_code
		 ||'applied flag'||x_line_Adj_tbl(j).applied_flag||'updated_flag'||x_line_Adj_tbl(j).updated_flag
		 );

End if;
End Loop;
End if;


IF p_line_price_Att_tbl.count > 0 Then
       -- Copy line pricing attribute table infor
j:=0;
For i in p_line_price_Att_tbl.first..p_line_price_Att_tbl.last
	 Loop
   if p_line_price_Att_tbl.Exists(i) then
      j:=j+1;
x_line_price_Att_tbl(j):= OE_ORDER_PUB.G_MISS_Line_Price_Att_Rec;

if p_line_price_Att_tbl(i).line_index is not null then
x_line_price_Att_tbl(j).line_index	                   :=  p_line_price_Att_tbl(i).line_index;
end if;


if  p_line_price_Att_tbl(i).flex_title is not null then
x_line_price_Att_tbl(j).flex_title			  :=  p_line_price_Att_tbl(i).flex_title;
end if;
if p_line_price_Att_tbl(i).pricing_context is not null then
x_line_price_Att_tbl(j).pricing_context			  :=  p_line_price_Att_tbl(i).pricing_context;
end if;
if p_line_price_Att_tbl(i).pricing_attribute1 is not null then
x_line_price_Att_tbl(j).pricing_attribute1		  :=  p_line_price_Att_tbl(i).pricing_attribute1;
end if;
if  p_line_price_Att_tbl(i).pricing_attribute2 is not null then
x_line_price_Att_tbl(j).pricing_attribute2		  :=  p_line_price_Att_tbl(i).pricing_attribute2;
end if;
if  p_line_price_Att_tbl(i).pricing_attribute3 is not null then
x_line_price_Att_tbl(j).pricing_attribute3		  :=  p_line_price_Att_tbl(i).pricing_attribute3;
end if;


End if;
End Loop;
End if;


IF p_line_Adj_Att_tbl.count > 0 Then
       -- Copy line adjustment attribute table
j:=0;
For i in p_line_Adj_Att_tbl.first..p_line_Adj_Att_tbl.last
	 Loop
   if p_line_Adj_Att_tbl.Exists(i) Then
      j:=j+1;
x_line_Adj_att_tbl(j):= OE_ORDER_PUB.G_MISS_Line_Adj_Att_Rec;
if p_line_Adj_att_tbl(i).Adj_index is not null then
x_line_Adj_att_tbl(j).Adj_index			  :=  p_line_Adj_att_tbl(i).Adj_index;
end if;
if  p_line_Adj_att_tbl(i).flex_title is not null then
x_line_Adj_att_tbl(j).flex_title             	  :=  p_line_Adj_att_tbl(i).flex_title;
end if;
if p_line_Adj_att_tbl(i).pricing_context is not null then
x_line_Adj_att_tbl(j).pricing_context        	  :=  p_line_Adj_att_tbl(i).pricing_context;
end if;
if  p_line_Adj_att_tbl(i).pricing_attribute is not null then
x_line_Adj_att_tbl(j).pricing_attribute      	  :=  p_line_Adj_att_tbl(i).pricing_attribute;
end if;

if  p_line_Adj_att_tbl(i).pricing_attr_value_from is not null then
x_line_Adj_att_tbl(j).pricing_attr_value_from 	  :=  p_line_Adj_att_tbl(i).pricing_attr_value_from;
end if;
if  p_line_Adj_att_tbl(i).pricing_attr_value_to is not null then
x_line_Adj_att_tbl(j).pricing_attr_value_to  	  :=  p_line_Adj_att_tbl(i).pricing_attr_value_to;
end if;

End if;
End Loop;
End if;

IF p_line_Adj_Assoc_tbl.count > 0 Then
   -- Copy line adjustment association table infor
j:=0;
For i in p_line_Adj_Assoc_tbl.first..p_line_Adj_Assoc_tbl.last
	 Loop
   if p_line_Adj_Assoc_tbl.Exists(i) Then
      j:=j+1;

if p_line_Adj_Assoc_tbl(i).Line_index is not null then
x_line_Adj_Assoc_tbl(j).Line_index	       :=   p_line_Adj_Assoc_tbl(i).Line_index;
end if;

if  p_line_Adj_Assoc_tbl(i).Adj_index is not null then
x_line_Adj_Assoc_tbl(j).Adj_index	       :=   p_line_Adj_Assoc_tbl(i).Adj_index;
end if;

--x_line_Adj_Assoc_tbl(j).rltd_Price_Adj_Id      :=   p_line_Adj_Assoc_tbl(i).rltd_Price_Adj_Id;
if  p_line_Adj_Assoc_tbl(i).Rltd_Adj_Index is not null then
x_line_Adj_Assoc_tbl(j).Rltd_Adj_Index         :=   p_line_Adj_Assoc_tbl(i).Rltd_Adj_Index;
end if;

End if;
End Loop;
End if;


End CopyINTO_PO_RecStruc;



PROCEDURE Create_Order(
             in_order in varchar2,
             in_header_rec oe_oe_pricing_availability.PA_Header_Tbl_Type,
             in_line_tbl Oe_Oe_Pricing_Availability.PA_Line_Tbl_Type,
             in_Header_Adj_tbl Oe_Oe_Pricing_Availability.PA_H_Adj_Tbl_Type,
             in_Line_Adj_tbl   Oe_Oe_Pricing_Availability.PA_LAdj_Tbl_Type,
             in_Header_price_Att_tbl Oe_Oe_Pricing_Availability.PA_H_PAtt_Tbl_Type,
             in_Header_Adj_Att_tbl Oe_Oe_Pricing_Availability.PA_H_Adj_Att_Tbl_Type,
             in_Header_Adj_Assoc_tbl  Oe_Oe_Pricing_Availability.PA_H_Adj_AsTbl_Type,
             in_Line_price_Att_tbl  Oe_Oe_Pricing_Availability.PA_Line_PAtt_Tbl_Type,
             in_Line_Adj_Att_tbl  Oe_Oe_Pricing_Availability.PA_LAdj_Att_Tbl_Type,
             in_Line_Adj_Assoc_tbl Oe_Oe_Pricing_Availability.PA_L_Adj_AssTbl_Type,
             out_order_number out NOCOPY varchar2,
             out_header_id out NOCOPY number,
             out_order_total out NOCOPY number,
             out_order_amount out nocopy number,
             out_order_charges out nocopy number,
             out_order_discount out nocopy number,
             out_order_tax     out nocopy number,
             out_item        out nocopy varchar2,
             out_currency out nocopy varchar2,
             x_msg_count OUT NOCOPY NUMBER,
             x_msg_data OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2
                      ) IS

l_Header_price_Att_tbl	      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl	      OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl	      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl	      OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl	      OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl	      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_line_adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_action_request_tbl          OE_Order_PUB.request_tbl_type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl	      OE_Order_PUB.lot_serial_tbl_type;
l_file_val                    Varchar2(30);
x_msg_index                   number;
v                             Varchar2(30);
l_date                        date;
l_booked_flag                 varchar2(1);
l_shipping_interfaced_flag    varchar2(1);
l_header_rec OE_ORDER_PUB.HEADER_REC_TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_subtotal number;
l_discount number;
l_charges  number;
l_tax      number;
l_transaction_phase_code varchar2(30);
l_x_Header_Payment_tbl OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl  OE_Order_PUB.Line_Payment_Tbl_Type;
p_old_line_rec OE_ORDER_PUB.Line_Rec_Type;
p_x_line_rec OE_ORDER_PUB.Line_Rec_Type;
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('==========================================='||
           ' Enter create_order database '||
           ' in_order = '||in_order||
           ' Customer id = '||in_header_rec(1).sold_to_org_id||
           ' Currency ='||in_header_rec(1).transactional_curr_code||
           ' order_type_id ='||in_header_rec(1).order_type_id||
           ' agreement_id ='||in_header_rec(1).agreement_id||
           ' price_list_id ='||in_header_rec(1).price_list_id||
           ' ship_to_org_id ='||in_header_rec(1).ship_to_org_id||
           ' invoice_to_org_id ='||in_header_rec(1).invoice_to_org_id||
           ' Conversion_type_code ='||in_header_rec(1).Conversion_type_code||
           ' Conversion_rate ='||in_header_rec(1).Conversion_rate||
           ' Order_Number ='||in_header_rec(1).order_number||
           ' line_tbl_count='||in_line_tbl.COUNT||
		     'Line_Adj_tbl_count'||in_line_Adj_Tbl.count ||
		     'Line_Adj_Attr_tbl'||in_line_adj_att_tbl.count
          );
  END IF;

  IF in_order = 'Y' then
    l_transaction_phase_code := 'F';
  ELSE
    l_transaction_phase_code := 'N';
  END IF;


-- Copy from the P_A record structure to Process Order structure is done....


 CopyINTO_PO_RecStruc
   (         p_header_rec=>in_header_rec,
             p_line_tbl=>in_line_tbl,
             p_Header_Adj_tbl=>in_header_adj_tbl,
             p_Line_Adj_tbl=> in_line_adj_tbl,
             p_Header_price_Att_tbl=> in_header_price_att_tbl,
             p_Header_Adj_Att_tbl => in_header_adj_att_tbl,
             p_Header_Adj_Assoc_tbl => in_header_adj_assoc_tbl,
             p_Line_price_Att_tbl => in_line_price_att_tbl,
             p_Line_Adj_Att_tbl => in_line_adj_att_tbl,
             p_Line_Adj_Assoc_tbl => in_line_adj_assoc_tbl,
             x_header_rec =>l_header_rec,
             x_line_tbl => l_line_tbl,
             x_Header_Adj_tbl=>l_Header_adj_tbl,
             x_Line_Adj_tbl => l_line_adj_tbl,
             x_Header_price_Att_tbl=> l_header_price_att_tbl,
             x_Header_Adj_Att_tbl => l_header_adj_att_tbl,
             x_Header_Adj_Assoc_tbl => l_header_adj_assoc_tbl,
             x_Line_price_Att_tbl => l_line_price_att_tbl,
             x_Line_Adj_Att_tbl => l_line_adj_att_tbl,
             x_Line_Adj_Assoc_tbl => l_line_adj_assoc_tbl);


  IF l_debug_level  > 0 THEN
    IF l_line_tbl.COUNT > 0 then
      FOR i in l_line_tbl.FIRST..l_line_tbl.LAST
      LOOP
        oe_debug_pub.add('=========================================='||
              ' Line '||i||
              ' item_id='||l_line_Tbl(i).inventory_item_id||
              ' line_type_id='||l_line_Tbl(i).line_type_id||
              ' agreement_id='||l_line_Tbl(i).agreement_id||
              ' ship_to_org_id='||l_line_Tbl(i).ship_to_org_id||
              ' invoice_to_org_id='||l_line_Tbl(i).invoice_to_org_id||
              ' item_type_code='||l_line_Tbl(i).item_type_code||
              ' ordered_quantity='||l_line_Tbl(i).ordered_quantity||
              ' quantity_uom='||l_line_Tbl(i).order_quantity_uom||
              ' ship_from_org_id='||l_line_Tbl(i).ship_from_org_id||
              ' ordered_item_id='||l_line_Tbl(i).ordered_item_id||
              ' item_id_type='||l_line_Tbl(i).item_identifier_type||
              ' orig_inv_id='||l_line_Tbl(i).original_inventory_item_id||
              ' orig_id_type='||l_line_Tbl(i).original_item_identifier_type||
              ' orig_ordered_id='||l_line_Tbl(i).original_ordered_item_id||
              ' Price_list='||l_line_Tbl(i).price_list_id||
              ' line_category_code='||l_line_Tbl(i).line_category_code||
              ' transaction_phase_code='||l_transaction_phase_code
                   );
      END LOOP;
    END IF;
  END IF;
 -- l_header_rec := in_header_rec; -- should copy header record values

  l_header_rec.operation := OE_Globals.G_OPR_CREATE;
  --l_header_rec.order_number := null;
  l_header_rec.order_source_id := g_order_source_id;
  l_header_rec.transaction_phase_code := l_transaction_phase_code;


 -- l_line_tbl := in_line_tbl; -- should copy line table
  oe_debug_pub.add(' in create order line table count'||l_line_tbl.count);
  FOR i in l_line_tbl.FIRST..l_line_tbl.LAST
  LOOP
    l_line_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    l_line_tbl(i).calculate_price_flag := 'Y';
    l_line_tbl(i).order_source_id := g_order_source_id;
    l_line_tbl(i).transaction_phase_code := l_transaction_phase_code;
  END LOOP;

--IF in_line_price_att_tbl.COUNT > 0 then
IF l_line_price_att_tbl.COUNT > 0 then
   -- l_Line_price_Att_tbl	:= in_line_price_att_tbl; -- copy line pricing attributes
    FOR i in l_line_price_att_tbl.FIRST..l_line_price_att_tbl.LAST
    LOOP
      l_line_price_att_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    END LOOP;

    IF l_debug_level  > 0 THEN
      IF l_line_price_att_tbl.COUNT > 0 then
      FOR i in l_line_price_att_tbl.first..l_line_price_att_tbl.last
      LOOP
        oe_debug_pub.add('BEFORE Process Order line_price_att_tbl rec='||i||
        ' line_index='||l_line_price_att_tbl(i).line_index||
        ' flex_title='||l_line_price_att_tbl(i).flex_title||
        ' pricing_context='||l_line_price_att_tbl(i).pricing_context||
        ' attr1='||l_line_price_att_tbl(i).pricing_attribute1||
        ' attr2='||l_line_price_att_tbl(i).pricing_attribute2||
        ' attr3='||l_line_price_att_tbl(i).pricing_attribute3
                      );
      END LOOP;
      END IF;
    END IF; -- if debug level
  END IF; -- if price_atts are passed




--  IF in_header_price_att_tbl.COUNT > 0 then
     IF l_header_price_att_tbl.COUNT > 0 then
  --  l_Header_price_Att_tbl	:= in_header_price_att_tbl; -- copy header pricing attributes
    FOR i in l_header_price_att_tbl.FIRST..l_header_price_att_tbl.LAST
    LOOP
      l_header_price_att_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    END LOOP;

    IF l_debug_level  > 0 THEN
      IF l_header_price_att_tbl.COUNT > 0 then
      FOR i in l_header_price_att_tbl.first..l_header_price_att_tbl.last
      LOOP
        oe_debug_pub.add('BEFORE Process Order Hdr_price_att_tbl rec='||i||
        ' flex_title='||l_header_price_att_tbl(i).flex_title||
        ' pricing_context='||l_header_price_att_tbl(i).pricing_context||
        ' attr1='||l_header_price_att_tbl(i).pricing_attribute1||
        ' attr2='||l_header_price_att_tbl(i).pricing_attribute2||
        ' attr3='||l_header_price_att_tbl(i).pricing_attribute3
                      );
      END LOOP;
      END IF;
    END IF; -- if debug level
  END IF; -- if header price_atts are passed

oe_Debug_pub.add('Line adjustment count'||l_line_Adj_tbl.count);
--IF in_line_adj_tbl.COUNT > 0 then
   IF l_line_adj_tbl.COUNT > 0 then
  --  l_Line_adj_tbl:= in_line_adj_tbl;  -- copy line adj table
    FOR i in l_line_adj_tbl.FIRST..l_line_adj_tbl.LAST
    LOOP
      l_line_adj_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    END LOOP;

    IF l_debug_level  > 0 THEN
       IF l_line_adj_tbl.COUNT > 0 then
	  FOR i in l_line_adj_tbl.first..l_line_adj_tbl.last
		   LOOP
	     oe_debug_pub.add('BEFORE Process Order line_adj_tbl rec='||i||
			      ' line_index='||l_line_adj_tbl(i).line_index||
			      ' List_line_id='||l_line_adj_tbl(i).List_line_id||
			      ' List Header id='||l_line_adj_tbl(i).list_header_id ||
			      ' Pricing Phase id='||l_line_adj_tbl(i).pricing_phase_id ||
			      ' Modifier Level code='||l_line_adj_tbl(i).Modifier_level_code ||
			      ' Operand='||l_line_adj_tbl(i).operand ||
			      ' List line type code='||l_line_adj_tbl(i).list_line_type_code ||
			      'Updated Flag=' ||l_line_adj_tbl(i).updated_flag ||
			      'Applied Flag=' ||l_line_adj_tbl(i).applied_flag ||
			      'Arithmetic Operator ='||l_line_adj_tbl(i).arithmetic_operator ||
			      'Price Break Type code =' ||l_line_adj_tbl(i).price_break_type_code
			      );
	  END LOOP;
       END IF;
    END IF; -- if debug level
 END IF; -- if line adj being passed.


 --IF in_header_adj_tbl.COUNT > 0 then
IF l_header_adj_tbl.COUNT > 0 then
  --  l_header_adj_tbl:= in_header_adj_tbl;  -- copy header adjustments
    FOR i in l_header_adj_tbl.FIRST..l_header_adj_tbl.LAST
	     LOOP
       l_header_adj_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    END LOOP;

    IF l_debug_level  > 0 THEN
       IF l_header_adj_tbl.COUNT > 0 then
	  FOR i in l_header_adj_tbl.first..l_header_adj_tbl.last
		   LOOP
	     oe_debug_pub.add('BEFORE Process Order header_adj_tbl rec='||i||
			      ' List_line_id='||l_header_adj_tbl(i).List_line_id||
			      ' List Header id='||l_header_adj_tbl(i).list_header_id ||
			      ' Pricing Phase id='||l_header_adj_tbl(i).pricing_phase_id ||
			      ' Modifier Level code='||l_header_adj_tbl(i).Modifier_level_code ||
			      ' Operand='||l_header_adj_tbl(i).operand ||
			      ' List line type code='||l_header_adj_tbl(i).list_line_type_code ||
			      'Updated Flag=' ||l_header_adj_tbl(i).updated_flag ||
			      'Applied Flag=' ||l_header_adj_tbl(i).applied_flag ||
			      'Arithmetic Operator ='||l_header_adj_tbl(i).arithmetic_operator ||
			      'Price Break Type code =' ||l_header_adj_tbl(i).price_break_type_code
			      );
	  END LOOP;
       END IF;
    END IF; -- if debug level
 END IF; -- if header adj being passed.

--IF in_line_adj_att_tbl.COUNT > 0 then
IF l_line_adj_att_tbl.COUNT > 0 then
  -- l_Line_adj_att_tbl:= in_line_adj_att_tbl;  -- copy line_adjustemnts table
   FOR i in l_line_adj_att_tbl.FIRST..l_line_adj_att_tbl.LAST
	    LOOP
      l_line_adj_att_tbl(i).operation := OE_Globals.G_OPR_CREATE;
   END LOOP;

    IF l_debug_level  > 0 THEN
       IF l_line_adj_att_tbl.COUNT > 0 then
	  FOR i in l_line_adj_att_tbl.first..l_line_adj_att_tbl.last
		   LOOP
	     oe_debug_pub.add('BEFORE Process Order line_adj_att_tbl rec='||i||
			      ' line_index='||l_line_adj_att_tbl(i).adj_index||
			      ' pricing context='||l_line_adj_att_tbl(i).pricing_context||
			      'pricing attribute='||l_line_adj_att_tbl(i).pricing_attribute||
			      'pricing attribute value from='||l_line_adj_att_tbl(i).pricing_attr_value_from||
			      'pricing attribute value to=' ||l_line_adj_att_tbl(i).pricing_attr_value_to
			      );
	  END LOOP;
       END IF;
    END IF; -- if debug level
 END IF; -- if line adj attr being passed.

--IF in_line_adj_assoc_tbl.COUNT > 0 then
IF l_line_adj_assoc_tbl.COUNT > 0 then
   -- l_Line_adj_assoc_tbl:= in_line_adj_assoc_tbl;
    FOR i in l_line_adj_assoc_tbl.FIRST..l_line_adj_assoc_tbl.LAST
    LOOP
      l_line_adj_assoc_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    END LOOP;

    IF l_debug_level  > 0 THEN
       IF l_line_adj_assoc_tbl.COUNT > 0 then
	  FOR i in l_line_adj_assoc_tbl.first..l_line_adj_assoc_tbl.last
		   LOOP
	     oe_debug_pub.add('BEFORE Process Order line_adj_att_tbl rec='||i||
			      ' line_index='||l_line_adj_assoc_tbl(i).line_index||
			      ' Adjustment index='||l_line_adj_assoc_tbl(i).adj_index||
			      'Related adjustment index'||l_line_adj_assoc_tbl(i).rltd_adj_index
			      );
	  END LOOP;
       END IF;
    END IF; -- if debug level
 END IF; -- if line adj assoc being passed.


--IF in_header_adj_att_tbl.COUNT > 0 then
IF l_header_adj_att_tbl.COUNT > 0 then
  -- l_header_adj_att_tbl:= in_header_adj_att_tbl;
   FOR i in l_header_adj_att_tbl.FIRST..l_header_adj_att_tbl.LAST
	    LOOP
      l_header_adj_att_tbl(i).operation := OE_Globals.G_OPR_CREATE;
   END LOOP;

    IF l_debug_level  > 0 THEN
       IF l_header_adj_att_tbl.COUNT > 0 then
	  FOR i in l_header_adj_att_tbl.first..l_header_adj_att_tbl.last
		   LOOP
	     oe_debug_pub.add('BEFORE Process Order header_adj_att_tbl rec='||i||
			      ' line_index='||l_header_adj_att_tbl(i).adj_index||
			      ' pricing context='||l_header_adj_att_tbl(i).pricing_context||
			      'pricing attribute='||l_header_adj_att_tbl(i).pricing_attribute||
			      'pricing attribute value from='||l_header_adj_att_tbl(i).pricing_attr_value_from||
			      'pricing attribute value to=' ||l_header_adj_att_tbl(i).pricing_attr_value_to
			      );
	  END LOOP;
       END IF;
    END IF; -- if debug level
 END IF; -- if header adj attr being passed.


--IF in_header_adj_assoc_tbl.COUNT > 0 then
IF l_header_adj_assoc_tbl.COUNT > 0 then
  --  l_header_adj_assoc_tbl:= in_header_adj_assoc_tbl;
    FOR i in l_header_adj_assoc_tbl.FIRST..l_header_adj_assoc_tbl.LAST
    LOOP
      l_header_adj_assoc_tbl(i).operation := OE_Globals.G_OPR_CREATE;
    END LOOP;

    IF l_debug_level  > 0 THEN
       IF l_header_adj_assoc_tbl.COUNT > 0 then
	  FOR i in l_header_adj_assoc_tbl.first..l_header_adj_assoc_tbl.last
		   LOOP
	     oe_debug_pub.add('BEFORE Process Order header_adj_att_tbl rec='||i||
			      ' line_index='||l_header_adj_assoc_tbl(i).line_index||
			      ' Adjustment index='||l_header_adj_assoc_tbl(i).adj_index||
			      'Related adjustment index'||l_header_adj_assoc_tbl(i).rltd_adj_index
			      );
	  END LOOP;
       END IF;
    END IF; -- if debug level
 END IF; -- if header adj assoc being passed.


  -- this is not required as it will book the order
  --l_action_request_tbl(1).entity_code := OE_GLOBALS.G_ENTITY_HEADER;
  --l_action_request_tbl(1).request_type:= OE_GLOBALS.G_BOOK_ORDER;

  oe_debug_pub.initialize;
  IF l_debug_level  > 0 THEN
     print_time('Before Calling Process Order'||l_Line_Adj_tbl.count);
  END IF;

  OE_GLOBALS.g_validate_desc_flex:='Y';
  IF OE_ORDER_CACHE.IS_FLEX_ENABLED('OE_HEADER_ATTRIBUTES') = 'Y'
  AND OE_GLOBALS.g_validate_desc_flex='Y' THEN

    IF NOT OE_VALIDATE.Header_Desc_Flex
          (p_context            => l_header_rec.context
          ,p_attribute1         => l_header_rec.attribute1
          ,p_attribute2         => l_header_rec.attribute2
          ,p_attribute3         => l_header_rec.attribute3
          ,p_attribute4         => l_header_rec.attribute4
          ,p_attribute5         => l_header_rec.attribute5
          ,p_attribute6         => l_header_rec.attribute6
          ,p_attribute7         => l_header_rec.attribute7
          ,p_attribute8         => l_header_rec.attribute8
          ,p_attribute9         => l_header_rec.attribute9
          ,p_attribute10        => l_header_rec.attribute10
          ,p_attribute11        => l_header_rec.attribute11
          ,p_attribute12        => l_header_rec.attribute12
          ,p_attribute13        => l_header_rec.attribute13
          ,p_attribute14        => l_header_rec.attribute14
          ,p_attribute15        => l_header_rec.attribute15
          ,p_attribute16        => l_header_rec.attribute16
          ,p_attribute17        => l_header_rec.attribute17
          ,p_attribute18        => l_header_rec.attribute18
          ,p_attribute19        => l_header_rec.attribute19
          ,p_attribute20        => l_header_rec.attribute20)
          THEN
      OE_GLOBALS.g_validate_desc_flex:='N';
      oe_debug_pub.add('Pricing  AVa, HEaderAttribue1-NOT VALID  ');
    END IF;
      oe_debug_pub.add('Pricing  AVa, HEaderAttribute1  '||l_header_rec.attribute1,1);
  END IF;

  IF OE_ORDER_CACHE.IS_FLEX_ENABLED('OE_HEADER_GLOBAL_ATTRIBUTE') = 'Y'
  AND OE_GLOBALS.g_validate_desc_flex='Y' THEN
          IF NOT OE_VALIDATE.G_Header_Desc_Flex
          (p_context            => l_header_rec.global_attribute_category
          ,p_attribute1         => l_header_rec.global_attribute1
          ,p_attribute2         => l_header_rec.global_attribute2
          ,p_attribute3         => l_header_rec.global_attribute3
          ,p_attribute4         => l_header_rec.global_attribute4
          ,p_attribute5         => l_header_rec.global_attribute5
          ,p_attribute6         => l_header_rec.global_attribute6
          ,p_attribute7         => l_header_rec.global_attribute7
          ,p_attribute8         => l_header_rec.global_attribute8
          ,p_attribute9         => l_header_rec.global_attribute9
          ,p_attribute10        => l_header_rec.global_attribute10
          ,p_attribute11        => l_header_rec.global_attribute11
          ,p_attribute12        => l_header_rec.global_attribute12
          ,p_attribute13        => l_header_rec.global_attribute13
          ,p_attribute14        => l_header_rec.global_attribute13
          ,p_attribute15        => l_header_rec.global_attribute14
          ,p_attribute16        => l_header_rec.global_attribute16
          ,p_attribute17        => l_header_rec.global_attribute17
          ,p_attribute18        => l_header_rec.global_attribute18
          ,p_attribute19        => l_header_rec.global_attribute19
          ,p_attribute20        => l_header_rec.global_attribute20)
          THEN
      OE_GLOBALS.g_validate_desc_flex:='N';
    END IF;
  END IF;

  IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_HEADER_TP_ATTRIBUTES') = 'Y'
  AND OE_GLOBALS.g_validate_desc_flex='Y' THEN
       IF NOT OE_VALIDATE.TP_Header_Desc_Flex
          (p_context            => l_header_rec.tp_context
          ,p_attribute1         => l_header_rec.tp_attribute1
          ,p_attribute2         => l_header_rec.tp_attribute2
          ,p_attribute3         => l_header_rec.tp_attribute3
          ,p_attribute4         => l_header_rec.tp_attribute4
          ,p_attribute5         => l_header_rec.tp_attribute5
          ,p_attribute6         => l_header_rec.tp_attribute6
          ,p_attribute7         => l_header_rec.tp_attribute7
          ,p_attribute8         => l_header_rec.tp_attribute8
          ,p_attribute9         => l_header_rec.tp_attribute9
          ,p_attribute10        => l_header_rec.tp_attribute10
          ,p_attribute11        => l_header_rec.tp_attribute11
          ,p_attribute12        => l_header_rec.tp_attribute12
          ,p_attribute13        => l_header_rec.tp_attribute13
          ,p_attribute14        => l_header_rec.tp_attribute14
          ,p_attribute15        => l_header_rec.tp_attribute15) THEN
      OE_GLOBALS.g_validate_desc_flex:='N';
    END IF;
  END IF;
  IF OE_GLOBALS.g_validate_desc_flex='Y' THEN
    p_old_line_rec:=OE_ORDER_PUB.G_MISS_LINE_REC;
  FOR i in l_line_tbl.FIRST..l_line_tbl.LAST
  LOOP
    p_x_line_rec:=l_line_tbl(i);
    G_PR_AV:='Y' ;  -- bug7380336
    OE_VALIDATE_LINE.Validate_Flex(
                   p_x_line_rec        => p_x_line_rec,
                   p_old_line_rec      => p_old_line_rec,
                   p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status     => x_return_status
                   );
      oe_debug_pub.add('Pricing  AVa,Attribute1  '||p_x_line_rec.attribute1,1);
      oe_debug_pub.add('Pricing  AVa,Attribute1-Return'||x_return_status,1);
    G_PR_AV:='N' ;  -- bug7380336

    IF x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
      OE_GLOBALS.g_validate_desc_flex:='N';
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      OE_GLOBALS.g_validate_desc_flex:='N';
    ELSIF x_return_status=FND_API.G_RET_STS_SUCCESS THEN
      null;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END LOOP;
  END IF;

  OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
 -- ,   p_control_rec                 => l_control_rec
 -- ,   p_validation_level	      => FND_API.G_VALID_LEVEL_NONE
    ,   p_x_header_Rec                => l_header_rec
    ,   p_x_line_tbl	              => l_line_tbl
 -- ,   p_line_adj_tbl	              => l_line_adj_tbl
    ,   p_x_action_request_tbl	      => l_action_request_tbl
    ,   p_x_Header_Adj_tbl            => l_Header_Adj_tbl
    ,   p_x_Header_Payment_tbl        =>l_x_Header_Payment_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl	      => l_x_lot_serial_tbl
    ,	p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
    ,   p_x_Header_price_Att_tbl	=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl	=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl	=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl	=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl	=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl	=> l_Line_Adj_Assoc_tbl
    );


    IF l_debug_level  > 0 THEN
     print_time('After Calling Process Order Return ');
    END IF;

  -- Check the status and print appropriate messages
  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS then

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in process order 1',1);
      oe_Debug_pub.add('ERROR while creating order!');
    END IF;
    rollback;

  ELSE

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Header ID :' ||l_header_rec.header_id,1);
      oe_debug_pub.add('Order number :'||l_header_rec.order_number,1);
      oe_debug_pub.add('Sold To :'||l_header_rec.sold_to_org_id,1);
      oe_debug_pub.add('Invoice To :'||l_header_rec.invoice_to_org_id,1);
      oe_debug_pub.add('Ship To :'||l_header_rec.ship_to_org_id,1);
    END IF;

    commit;
    out_header_id := l_header_rec.header_id;
    out_order_number := l_header_rec.order_number;
    out_currency := l_header_rec.transactional_curr_code;


    IF l_debug_level  > 0 THEN
      FOR i in l_line_tbl.FIRST..l_line_tbl.LAST
      LOOP
        oe_debug_pub.add('counter = '||i||
                       ' qty='||l_line_tbl(i).ordered_quantity||
                       'price='||l_line_tbl(i).unit_selling_price
                      );
      END LOOP;
    END IF;

    oe_oe_totals_summary.order_totals(
                      p_header_id=>out_header_id,
                      p_subtotal=>l_subtotal,
                      p_discount=>l_discount,
                      p_charges=>l_charges,
                      p_tax=>l_tax
                                     );

    IF l_debug_level  > 0 THEN
      oe_Debug_pub.add('After calling Order_Totals '||
                     ' subtotal='||l_subtotal||
                     ' discount='||l_discount||
                     ' charges='||l_charges||
                     ' tax='||l_tax
                    );
    END IF;

    out_order_total := l_subtotal + l_discount + l_charges + l_tax;
    out_order_amount := l_subtotal;
    out_order_charges := l_charges;
    out_order_discount := l_discount;
    out_order_tax   := l_tax;

    IF l_debug_level  > 0 THEN
      oe_Debug_pub.add('out_order_total ='||out_order_total);
    END IF;

    --out_order_total := l_line_tbl(1).ordered_quantity *
    --                   l_line_tbl(1).unit_selling_price;
   -- out_item := l_line_tbl(1).ordered_item;
    if l_debug_level > 0 then
       oe_Debug_pub.add('before quering');
       end if;
    begin
     	 select booked_flag, shipping_interfaced_flag
    into l_booked_flag, l_shipping_interfaced_flag
    from oe_order_lines_all
    where header_id = l_header_rec.header_id
      and rownum = 1;
       oe_Debug_pub.add('booked_flag'||l_booked_flag ||'shipping interfaced flag'||l_shipping_interfaced_flag);
     Exception
	When others then
	   oe_debug_pub.add('error while querying the oe_order_lines_all'||SQLERRM||SQLCODE);
     End;

     if l_debug_level >0 then
	    oe_Debug_pub.add('booked_flag'||l_booked_flag ||'shipping interfaced flag'||l_shipping_interfaced_flag);
	    end if;

    IF l_shipping_interfaced_flag <> 'Y' then

      IF l_debug_level  > 0 THEN
          oe_Debug_pub.add('Order was created but there was an ERROR during the order processing flow.');
          oe_Debug_pub.add('Order Number: '||l_header_rec.order_number);
      END IF;

      if l_booked_flag <> 'Y' then

        IF l_debug_level  > 0 THEN
          oe_Debug_pub.add('There was an error during the booking activity.');
          --x_return_status := 'E'; --fnd_api.g_ret_sts_error;
        END IF;
      else
        IF l_debug_level  > 0 THEN
          oe_Debug_pub.add('Order booked but line not interfaced to shipping.');
          oe_Debug_pub.add('There was a failure either in scheduling or shipping interface activity.');
         --x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      end if;

    ELSE

      IF l_debug_level  > 0 THEN
        oe_Debug_pub.add('Order processed successfully.');
        oe_Debug_pub.add('Order Number: '||l_header_rec.order_number);
        oe_Debug_pub.add('Order has been booked and line has been scheduled,');
        oe_Debug_pub.add('interfaced to shipping.');
      END IF;

    END IF; -- if interfaced to shipping

  END IF;

  IF x_return_status <> fnd_api.g_ret_sts_success then

    -- Print out the error messages, if any

    IF l_debug_level  > 0 THEN
      IF x_msg_count > 0 then
        oe_debug_pub.add('Number of Messages :'||x_msg_count,1);
        oe_Debug_pub.add('Number of Messages :'||x_msg_count);
      END IF;
    END IF;

    FOR k in 1 .. x_msg_count loop
      x_msg_data := oe_msg_pub.get( p_msg_index => k,
                                    p_encoded => 'F'
                                   );

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(substr(x_msg_data,1,255));
        oe_debug_pub.add(substr(x_msg_data,255,length(x_msg_data)));
        oe_Debug_pub.add('Message: '||substr(x_msg_data,1,200));
      END IF;

    END LOOP;


  END IF; -- if 2nd return status not success


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
            ,   'Create_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Create_Order;


PROCEDURE get_atp_flag(
               in_inventory_item_id in number
               ,in_org_id in number
               ,out_atp_flag out NOCOPY /* file.sql.39 change */ varchar2
               ,out_default_source_type out NOCOPY /* file.sql.39 change */ varchar2
                      ) IS


l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

CURSOR c_atp_flag IS
  SELECT atp_flag,
         decode(default_so_source_type,'EXTERNAL','External','INTERNAL','Internal')
    FROM mtl_system_items
   WHERE inventory_item_id = in_inventory_item_id
     AND organization_id   = in_org_id;

BEGIN

  IF in_inventory_item_id is not null  then

    OPEN  c_atp_flag;
    FETCH c_atp_flag
     INTO out_atp_flag,
          out_default_source_type;
    CLOSE c_atp_flag;

  ELSE
    IF l_debug_level > 0 then
      oe_debug_pub.add('get_atp_flag in_id is null');
    END IF;

  END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF c_atp_flag%ISOPEN then
       CLOSE c_atp_flag;
     END IF;
     oe_debug_pub.add('get_atp_flag id='||In_inventory_item_id||
                      SQLERRM||SQLCODE
                     );

END get_atp_flag;


FUNCTION  Is_AdPricing_inst return varchar2 IS

l_status varchar2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  -- we need to call qp_util.get_qp_status,
  -- I=advanced , S=Basic, N=No Installation

  l_status := qp_util.get_qp_status;

  IF l_debug_level > 0 then
    oe_debug_pub.add('Advanced Pricing Instaleed status ='||l_status);
  END IF;

  return l_status;
  --return 'I';
 -- return 'S';

END Is_AdPricing_Inst;

--   start .Added for bug 3559935 , to avoid recompiling the pld again and again
 --  whenever there is a change in OEXFHDRB.pls

PROCEDURE RESET_DEBUG_LEVEL
IS

BEGIN
 OE_DEBUG_PUB.G_DEBUG_LEVEL:=0;

END RESET_DEBUG_LEVEL;

PROCEDURE SET_DEBUG_LEVEL (p_debug_level IN NUMBER)
IS

BEGIN
 OE_DEBUG_PUB.G_DEBUG_LEVEL:=p_debug_level;

END SET_DEBUG_LEVEL;


PROCEDURE Get_Form_Startup_Values
(Item_Id_Flex_Code         IN VARCHAR2,
Item_Id_Flex_Num OUT NOCOPY NUMBER) IS

    CURSOR C_Item_Flex(X_Id_Flex_Code VARCHAR2) is
      SELECT id_flex_num
      FROM   fnd_id_flex_structures
      WHERE  id_flex_code = X_Id_Flex_Code;
BEGIN

    oe_debug_pub.add('Entering OE_OE_PRICING_AVAILABILITY.GET_FORM_STARTUP_VALUES', 1);

    OPEN C_Item_Flex(Item_Id_Flex_Code);
    FETCH C_Item_Flex INTO Item_Id_Flex_Num;
    CLOSE C_Item_Flex;

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.GET_FORM_STARTUP_VALUES', 1);

  EXCEPTION
    WHEN OTHERS THEN
      oe_debug_pub.add('In when others exception : OE_OE_PRICING_AVAILABILITY.GET_FORM_STARTUP_VALUES', 1);
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Form_Startup_Values'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Form_Startup_Values;


Procedure get_user_item_Pricing_Contexts(
			p_request_type_code IN   VARCHAR2,
			x_user_attribs_tbl  OUT NOCOPY USER_ATTRIBUTE_TBL_TYPE)  IS

l_user_attribs_tbl QP_Attr_Mapping_PUB.USER_ATTRIBUTE_TBL_TYPE;


Begin

	QP_Attr_Mapping_PUB.get_user_item_Pricing_Contexts(
		p_request_type_code,
		p_user_attribs_tbl =>	l_user_attribs_tbl);

	FOR I IN 1..l_user_attribs_tbl.COUNT LOOP

		x_user_attribs_tbl(I).context_name	:=   l_user_attribs_tbl(I).context_name;
		x_user_attribs_tbl(I).attribute_name	:= l_user_attribs_tbl(I).attribute_name;
	END LOOP;

 End   get_user_item_Pricing_Contexts;

 -- end 3559935

--add 3245976


FUNCTION GET_MRP_ERR_MSG_FLAG
RETURN CHAR
IS
BEGIN
  return g_mrp_error_msg_flag;
END GET_MRP_ERR_MSG_FLAG;


FUNCTION GET_MRP_ERR_MSG RETURN VARCHAR
IS
err_msg varchar2(1000);
BEGIN
	 err_msg :=g_mrp_error_msg;
	 g_mrp_error_msg :=NULL;
	 g_mrp_error_msg_flag :='F';
	 return err_msg;

END  GET_MRP_ERR_MSG;

/* start bug 3440778 , Created to convert the reference to other products serverside code  inside OEXPRAVA pld into a local call. to OE_OE_PRICING_AVAILABILITY package*/

FUNCTION Get_Cost (p_line_rec       IN  OE_ORDER_PUB.LINE_REC_TYPE   DEFAULT OE_Order_Pub.G_MISS_LINE_REC
                  ,p_request_rec    IN Oe_Order_Pub.Request_Rec_Type DEFAULT Oe_Order_Pub.G_MISS_REQUEST_REC
                  ,p_order_currency IN VARCHAR2 Default NULL
                  ,p_sob_currency   IN VARCHAR2 Default NULL
                  ,p_inventory_item_id    IN NUMBER Default NULL
                  ,p_ship_from_org_id     IN NUMBER Default NULL
                  ,p_conversion_Type_code IN VARCHAR2 Default NULL
                  ,p_conversion_rate      IN NUMBER   Default NULL
                  ,p_item_type_code       IN VARCHAR2 Default 'STANDARD'
                  ,p_header_flag          IN Boolean Default FALSE)
----------------------------------------------------------------
RETURN NUMBER IS

l_unit_cost number;
BEGIN
	l_unit_cost :=OE_MARGIN_PVT.Get_Cost(p_line_rec
	                                      ,p_request_rec
					      ,p_order_currency
					      ,p_sob_currency
					      ,p_inventory_item_id
					      ,p_ship_from_org_id
					      ,p_conversion_Type_code
					      ,p_conversion_rate
					      ,p_item_type_code
					      ,p_header_flag);
	return (l_unit_cost);
END  Get_Cost;


PROCEDURE Get_Agreement
(
    p_sold_to_org_id            IN NUMBER DEFAULT NULL
   ,p_transaction_type_id       IN NUMBER DEFAULT NULL
   ,p_pricing_effective_date    IN DATE
   ,p_agreement_tbl            OUT NOCOPY agreement_tbl
) IS

l_agreement_tbl QP_UTIL_PUB.agreement_tbl;
BEGIN

	QP_UTIL_PUB.Get_Agreement(  p_sold_to_org_id
				   ,p_transaction_type_id
				   ,p_pricing_effective_date
				   ,l_agreement_tbl);

	FOR I IN 1..l_agreement_tbl.COUNT LOOP
	  p_agreement_tbl(I).agreement_name	:= l_agreement_tbl(I).agreement_name;
	  p_agreement_tbl(I).agreement_id	:= l_agreement_tbl(I).agreement_id;
          p_agreement_tbl(I).agreement_type	:= l_agreement_tbl(I).agreement_type;
          p_agreement_tbl(I).price_list_name	:= l_agreement_tbl(I).price_list_name;
          p_agreement_tbl(I).customer_name   	:= l_agreement_tbl(I).price_list_name;
          p_agreement_tbl(I).payment_term_name	:= l_agreement_tbl(I).payment_term_name;
          p_agreement_tbl(I).start_date_active  := l_agreement_tbl(I).start_date_active;
          p_agreement_tbl(I).end_date_active  	:= l_agreement_tbl(I).end_date_active;

	END LOOP;

END Get_Agreement;

  -- round_price.p_operand_type could be 'A' for adjustment amount or 'S' for item price
PROCEDURE round_price
(
     p_operand                  IN NUMBER
    ,p_rounding_factor          IN NUMBER
    ,p_use_multi_currency       IN VARCHAR2
    ,p_price_list_id            IN NUMBER
    ,p_currency_code            IN VARCHAR2
    ,p_pricing_effective_date   IN DATE
    ,x_rounded_operand         IN OUT NOCOPY NUMBER
    ,x_status_code             IN OUT NOCOPY VARCHAR2
    ,p_operand_type             IN VARCHAR2 default 'S'
)
IS
BEGIN
	QP_UTIL_PUB.round_price
	(
	     p_operand
	    ,p_rounding_factor
	    ,p_use_multi_currency
	    ,p_price_list_id
	    ,p_currency_code
	    ,p_pricing_effective_date
	    ,x_rounded_operand
	    ,x_status_code
	    ,p_operand_type
	);
END round_price;

-- end   bug 3440778

END oe_oe_pricing_availability;

/
