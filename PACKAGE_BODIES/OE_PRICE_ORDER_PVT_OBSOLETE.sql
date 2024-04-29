--------------------------------------------------------
--  DDL for Package Body OE_PRICE_ORDER_PVT_OBSOLETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_ORDER_PVT_OBSOLETE" AS
/* $Header: OEXVPROB.pls 115.4 2004/05/18 22:01:18 aycui noship $ */

Type Index_Tbl_Type is table of number
	Index by Binary_Integer;
G_PASS_LINE_TBL Index_Tbl_Type;

-- AG change
 G_LINE_INDEX_tbl                QP_PREQ_GRP.pls_integer_type;
 G_LINE_TYPE_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_EFFECTIVE_DATE_TBL  QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_FIRST_TBL       QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_FIRST_TYPE_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
 G_ACTIVE_DATE_SECOND_TBL      QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_SECOND_TYPE_TBL QP_PREQ_GRP.VARCHAR_TYPE ;
 G_LINE_QUANTITY_TBL           QP_PREQ_GRP.NUMBER_TYPE ;
 G_LINE_UOM_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
 G_REQUEST_TYPE_CODE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICED_QUANTITY_TBL         QP_PREQ_GRP.NUMBER_TYPE;
 G_UOM_QUANTITY_TBL            QP_PREQ_GRP.NUMBER_TYPE;
 G_PRICED_UOM_CODE_TBL         QP_PREQ_GRP.VARCHAR_TYPE;
 G_CURRENCY_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
 G_UNIT_PRICE_TBL              QP_PREQ_GRP.NUMBER_TYPE;
 G_PERCENT_PRICE_TBL           QP_PREQ_GRP.NUMBER_TYPE;
 G_ADJUSTED_UNIT_PRICE_TBL     QP_PREQ_GRP.NUMBER_TYPE;
 G_UPD_ADJUSTED_UNIT_PRICE_TBL QP_PREQ_GRP.NUMBER_TYPE;
 G_PROCESSED_FLAG_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_ID_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
 G_PROCESSING_ORDER_TBL        QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ROUNDING_FACTOR_TBL              QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ROUNDING_FLAG_TBL                QP_PREQ_GRP.FLAG_TYPE;
G_QUALIFIERS_EXIST_FLAG_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_ATTRS_EXIST_FLAG_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_LIST_ID_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
 G_PL_VALIDATED_FLAG_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_REQUEST_CODE_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
 G_USAGE_PRICING_TYPE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_CATEGORY_TBL             QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_STATUS_CODE_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_STATUS_TEXT_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_LINE_INDEX_tbl            QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_ATTR_LINE_DETAIL_INDEX_tbl     QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_ATTR_VALIDATED_FLAG_tbl        QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRICING_CONTEXT_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRICING_ATTRIBUTE_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_ATTRIBUTE_LEVEL_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_ATTRIBUTE_TYPE_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_APPLIED_FLAG_tbl QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRICING_STATUS_CODE_tbl QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRICING_ATTR_FLAG_tbl QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_LIST_HEADER_ID_tbl QP_PREQ_GRP.NUMBER_TYPE;
G_ATTR_LIST_LINE_ID_tbl QP_PREQ_GRP.NUMBER_TYPE;
G_ATTR_VALUE_FROM_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_SETUP_VALUE_FROM_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_VALUE_TO_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_SETUP_VALUE_TO_tbl QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_GROUPING_NUMBER_tbl QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_ATTR_NO_QUAL_IN_GRP_tbl     QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_ATTR_COMP_OPERATOR_TYPE_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRICING_STATUS_TEXT_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_QUAL_PRECEDENCE_tbl QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_ATTR_DATATYPE_tbl          QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_QUALIFIER_TYPE_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRODUCT_UOM_CODE_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_EXCLUDER_FLAG_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRICING_PHASE_ID_TBL QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_ATTR_INCOM_GRP_CODE_TBL QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_LDET_TYPE_CODE_TBL QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_MODIFIER_LEVEL_CODE_TBL QP_PREQ_GRP.VARCHAR_TYPE;
G_ATTR_PRIMARY_UOM_FLAG_TBL QP_PREQ_GRP.VARCHAR_TYPE;
G_CATCHWEIGHT_QTY_TBL QP_PREQ_GRP.NUMBER_TYPE;
G_ACTUAL_ORDER_QTY_TBL QP_PREQ_GRP.NUMBER_TYPE;

Procedure Preprocessing(
		 px_Header_Rec        	IN OUT NOCOPY   OE_ORDER_PUB.Header_Rec_Type
		,px_Line_Rec            IN OUT NOCOPY   OE_ORDER_PUB.Line_Rec_Type
) AS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  -- Need both header rec and line rec to price the order

  IF (px_header_rec.header_id IS NULL OR
     px_line_rec.line_id IS NULL ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRICE_ORDER: SETTING REQUEST ID' , 1 ) ;
   END IF;

   G_PASS_LINE_TBL.delete;
   qp_price_request_context.set_request_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' REQUEST ID IS : ' || QP_PREQ_GRP.G_REQUEST_ID , 1 ) ;
   END IF;

  -- Use the given header to price
  OE_ORDER_PUB.g_hdr := px_header_rec;

END Preprocessing;

Procedure Insert_Manual_Adj(px_Line_Adj_Tbl        IN OUT NOCOPY   OE_ORDER_PUB.Line_Adj_Tbl_Type
)
IS
i pls_integer;
BEGIN
  -- HTML change

  i := px_line_adj_Tbl.first;
  while i is not null loop
    IF ((px_line_adj_tbl(i).modifier_level_code='ORDER' OR G_PASS_LINE_TBL.exists(px_Line_Adj_Tbl(i).line_id)) AND px_line_adj_tbl(i).list_line_id IS NOT NULL and px_line_adj_tbl(i).applied_flag='Y') THEN

insert into qp_preq_ldets_tmp_t
  (REQUEST_ID,
  LINE_DETAIL_INDEX,
  LINE_DETAIL_TYPE_CODE,
  PRICE_BREAK_TYPE_CODE,
  LINE_INDEX,
  CREATED_FROM_LIST_HEADER_ID,
  CREATED_FROM_LIST_LINE_ID,
  CREATED_FROM_LIST_LINE_TYPE,
  CREATED_FROM_LIST_TYPE_CODE,
  PRICING_GROUP_SEQUENCE,
  PRICING_PHASE_ID,
  OPERAND_CALCULATION_CODE,
  OPERAND_VALUE,
  SUBSTITUTION_TYPE_CODE,
  SUBSTITUTION_VALUE_FROM,
  SUBSTITUTION_VALUE_TO,
  PRICE_FORMULA_ID,
  PRICING_STATUS_CODE,
  PRODUCT_PRECEDENCE,
  INCOMPATABILITY_GRP_CODE,
  APPLIED_FLAG,
  AUTOMATIC_FLAG,
  OVERRIDE_FLAG,
  MODIFIER_LEVEL_CODE,
  BENEFIT_QTY,
  BENEFIT_UOM_CODE,
  LIST_LINE_NO,
  ACCRUAL_FLAG,
  ACCRUAL_CONVERSION_RATE,
  ESTIM_ACCRUAL_RATE,
  CHARGE_TYPE_CODE,
  CHARGE_SUBTYPE_CODE,
  PROCESS_CODE,
  LINE_QUANTITY,
  UPDATED_FLAG, -- begin shu, fix Bug 2599822
  CALCULATION_CODE,
  CHANGE_REASON_CODE,
  CHANGE_REASON_TEXT,
  ADJUSTMENT_AMOUNT)
(select  QP_PREQ_GRP.G_REQUEST_ID,
  i,
  'NULL',
  'NULL', --ll.PRICE_BREAK_TYPE_CODE,
  px_line_adj_tbl(i).header_id + nvl(px_line_adj_tbl(i).line_id, 0), --line.LINE_INDEX,
  px_line_adj_tbl(i).LIST_HEADER_ID,
  px_line_adj_tbl(i).LIST_LINE_ID,
  px_line_adj_tbl(i).LIST_LINE_TYPE_CODE,
  lhdr.LIST_TYPE_CODE,
  ql.PRICING_GROUP_SEQUENCE,
  ql.PRICING_PHASE_ID,
  ql.ARITHMETIC_OPERATOR,
  px_line_adj_tbl(i).operand, --nvl(adj_iface.OPERAND_PER_PQTY,adj_iface.OPERAND),
  NULL, --ll.SUBSTITUTION_ATTRIBUTE,
  NULL, --ll.SUBSTITUTION_VALUE,
  NULL,
  NULL, --ll.PRICE_BY_FORMULA_ID,
  QP_PREQ_PUB.G_STATUS_UNCHANGED,
  ql.PRODUCT_PRECEDENCE,
  ql.INCOMPATIBILITY_GRP_CODE,
  'Y', --adj_iface.APPLIED_FLAG,
  'Y', --ll.AUTOMATIC_FLAG,
  'Y', --ll.OVERRIDE_FLAG,
  px_line_adj_tbl(i).MODIFIER_LEVEL_CODE,
  NULL, --ll.BENEFIT_QTY,
  NULL, --ll.BENEFIT_UOM_CODE,
  ql.LIST_LINE_NO,
  ql.ACCRUAL_FLAG,
  ql.ACCRUAL_CONVERSION_RATE,
  ql.ESTIM_ACCRUAL_RATE,
  ql.CHARGE_TYPE_CODE,
  ql.CHARGE_SUBTYPE_CODE,
  QP_PREQ_PUB.G_STATUS_NEW,
  NULL,
  px_line_adj_tbl(i).updated_flag,
  NULL,
  NULL,
  NULL,
  px_line_adj_tbl(i).adjusted_amount --adj_iface.ADJUSTED_AMOUNT_PER_PQTY
From
      qp_list_lines ql,
      qp_list_headers_b lhdr
Where    ql.list_line_id = px_line_adj_tbl(i).list_line_id
and   lhdr.list_header_id = px_line_adj_tbl(i).list_header_id);
  END IF;
  i := px_line_adj_tbl.next(i);
  end loop;
END Insert_Manual_Adj;

-- AG change --
procedure copy_Header_to_request(
 p_header_rec           OE_Order_PUB.Header_Rec_Type
,p_Request_Type_Code    varchar2
,p_calculate_price_flag varchar2
,px_line_index in out NOCOPY NUMBER
)
is
l_req_line_rec QP_PREQ_GRP.LINE_REC_TYPE;
--l_line_index  pls_integer := px_req_line_tbl.count;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
        G_STMT_NO := 'copy_Header_to_request#10';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.COPY_HEADER_TO_REQUEST' , 1 ) ;
        END IF;

        --l_line_index := l_line_index+1;
        px_line_index := px_line_index+1;


        l_req_line_rec.CURRENCY_CODE := p_Header_rec.transactional_curr_code;
        QP_PREQ_GRP.G_CURRENCY_CODE := l_req_line_rec.currency_code;
        l_req_line_rec.PRICE_FLAG := p_calculate_price_flag;
        l_req_line_rec.Active_date_first_type := 'ORD';
        l_req_line_rec.Active_date_first := p_Header_rec.Ordered_date;

   G_LINE_INDEX_TBL(px_line_index)            :=  p_header_rec.header_id;
   G_LINE_TYPE_CODE_TBL(px_line_index)        :=  'ORDER';
   IF (p_header_rec.pricing_date is not null and p_header_rec.pricing_date <> FND_API.G_MISS_DATE) THEN
   G_PRICING_EFFECTIVE_DATE_TBL(px_line_index)
          :=  TRUNC(nvl(p_header_rec.pricing_date,sysdate));
   ELSE
     G_PRICING_EFFECTIVE_DATE_TBL(px_line_index)
          :=  TRUNC(sysdate);
   END IF;
   IF (p_header_rec.ordered_date is not null and p_header_rec.ordered_date <> FND_API.G_MISS_DATE) THEN
   G_ACTIVE_DATE_FIRST_TBL(px_line_index)
          :=  TRUNC(p_header_rec.Ordered_date);
   ELSE
     G_ACTIVE_DATE_FIRST_TBL(px_line_index)
          :=  TRUNC(sysdate);
   END IF;
   G_ACTIVE_DATE_FIRST_TYPE_TBL(px_line_index)
          :=  'ORD';
   G_ACTIVE_DATE_SECOND_TBL(px_line_index)
          := NULL;
   G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index)
          := NULL;
   G_LINE_QUANTITY_TBL(px_line_index)          := NULL;
   G_LINE_UOM_CODE_TBL(px_line_index)          := NULL;
   G_REQUEST_TYPE_CODE_TBL(px_line_index)      := 'ONT';
   G_PRICED_QUANTITY_TBL(px_line_index)        := NULL;
   G_UOM_QUANTITY_TBL(px_line_index)           := NULL;
   G_PRICED_UOM_CODE_TBL(px_line_index)        := NULL;
   G_CURRENCY_CODE_TBL(px_line_index)          := p_header_rec.transactional_CURR_CODE;
   G_UNIT_PRICE_TBL(px_line_index)             := NULL;
   G_PERCENT_PRICE_TBL(px_line_index)          := NULL;
   G_ADJUSTED_UNIT_PRICE_TBL(px_line_index)    := NULL;
   G_PROCESSED_FLAG_TBL(px_line_index)         := QP_PREQ_GRP.G_NOT_PROCESSED;
   G_PRICE_FLAG_TBL(px_line_index)             := p_calculate_price_flag;
   G_LINE_ID_TBL(px_line_index)                := p_header_rec.header_id;
   G_ROUNDING_FLAG_TBL(px_line_index)
         := 'Q';
   G_ROUNDING_FACTOR_TBL(px_line_index)        := NULL;
   G_PROCESSING_ORDER_TBL(px_line_index)       := NULL;
   G_PRICING_STATUS_CODE_tbl(px_line_index)    := QP_PREQ_GRP.G_STATUS_UNCHANGED;
   G_PRICING_STATUS_TEXT_tbl(px_line_index)    := NULL;

G_QUALIFIERS_EXIST_FLAG_TBL(px_line_index)            :='N';
 G_PRICING_ATTRS_EXIST_FLAG_TBL(px_line_index)       :='N';
 G_PRICE_LIST_ID_TBL(px_line_index)                 :=NULL;
 G_PL_VALIDATED_FLAG_TBL(px_line_index)                := 'N';
 IF (p_header_rec.price_request_code is not null and p_header_rec.price_request_code <> FND_API.G_MISS_CHAR) THEN
 G_PRICE_REQUEST_CODE_TBL(px_line_index)        := p_header_rec.price_request_code;
  ELSE
   G_PRICE_REQUEST_CODE_TBL(px_line_index)        := NULL;
  END IF;
 G_USAGE_PRICING_TYPE_TBL(px_line_index)        :='REGULAR';
G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_line_index) :=NULL;
G_LINE_CATEGORY_TBL(px_line_index):=NULL;
G_CATCHWEIGHT_QTY_TBL(px_line_index) := NULL;
G_ACTUAL_ORDER_QTY_TBL(px_line_index):=NULL;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXISTING OE_ORDER_PRICE_PVT.COPY_HEADER_TO_REQUEST' , 1 ) ;
        END IF;

end copy_Header_to_request;

procedure copy_Line_to_request(
 p_Line_rec                     OE_Order_PUB.Line_Rec_Type
--,px_req_line_tbl                in out nocopy   QP_PREQ_GRP.LINE_TBL_TYPE
,p_pricing_events               varchar2
,p_request_type_code            varchar2
,p_honor_price_flag             varchar2
,px_line_index in out NOCOPY NUMBER
)
is
--l_line_index  pls_integer := nvl(px_req_line_tbl.count,0);
l_uom_rate      NUMBER;
v_discounting_privilege VARCHAR2(30);
l_item_type_code VARCHAR2(30);
l_item_rec                    OE_ORDER_CACHE.item_rec_type; --OPM 2434270
l_dummy VARCHAR2(30);
x_return_status    VARCHAR2(30);
x_msg_count         NUMBER;
x_msg_data            VARCHAR2(2000);
x_secondary_quantity NUMBER;
x_secondary_uom_code  VARCHAR2(3);
l_shipped_quantity2 NUMBER;
x_item_rec          OE_Order_Cache.Item_Rec_Type;
l_UOM_QUANTITY      NUMBER;
l_Calculate_Price_Flag varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

   px_line_index := px_line_index + 1;
   G_LINE_INDEX_TBL(px_line_index)            :=  p_line_rec.header_id + p_line_rec.line_id;
   G_LINE_TYPE_CODE_TBL(px_line_index)        :=  'LINE';

   G_PRICING_EFFECTIVE_DATE_TBL(px_line_index):=  TRUNC(nvl(p_line_rec.PRICING_DATE,sysdate));
   G_ACTIVE_DATE_FIRST_TBL(px_line_index)     :=  OE_Order_Pub.G_HDR.Ordered_date;
  G_ACTIVE_DATE_FIRST_TYPE_TBL(px_line_index):=  'ORD';
   IF (p_line_rec.schedule_ship_date is not null) THEN
     G_ACTIVE_DATE_SECOND_TBL(px_line_index)    :=  TRUNC(p_line_rec.schedule_ship_date);
     G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index):= 'SHIP';
   ELSE
     G_ACTIVE_DATE_SECOND_TBL(px_line_index)    :=  NULL;
     G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index):= NULL;
   END IF;
/*
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'QUANTITY'||L_REQ_LINE_REC.LINE_QUANTITY||' '||L_REQ_LINE_REC.PRICED_QUANTITY , 3 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRICE FLAG'||L_REQ_LINE_REC.PRICE_FLAG ) ;
   END IF;
*/
   G_LINE_QUANTITY_TBL(px_line_index)          := p_line_rec.ordered_quantity;
   G_LINE_UOM_CODE_TBL(px_line_index)          := p_line_rec.order_quantity_uom;
   G_REQUEST_TYPE_CODE_TBL(px_line_index)      := 'ONT';
   G_PRICED_QUANTITY_TBL(px_line_index)        := NULL; --p_line_rec.PRICING_QUANTITY;
        IF (p_line_rec.item_type_code = 'SERVICE' AND p_line_rec.service_period IS NULL) THEN
          l_UOM_QUANTITY := 0;
        Elsif (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) Then
          l_UOM_QUANTITY := p_Line_rec.service_duration;
        Elsif (p_line_rec.service_period IS NOT NULL and p_line_rec.service_period <> FND_API.G_MISS_CHAR) THEN
          INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.service_period
                                       ,To_Unit   => p_Line_rec.Order_quantity_uom
                                       ,Item_ID   => p_Line_rec.Inventory_item_id
                                       ,Uom_Rate  => l_Uom_rate);
          l_UOM_QUANTITY := p_Line_rec.service_duration * l_uom_rate;
        End If;
   G_UOM_QUANTITY_TBL(px_line_index)           := l_UOM_QUANTITY;
   G_PRICED_UOM_CODE_TBL(px_line_index)        := p_line_rec.PRICING_QUANTITY_UOM;
   G_CURRENCY_CODE_TBL(px_line_index)          := oe_order_pub.g_hdr.TRANSACTIONAL_CURR_CODE;
   G_UNIT_PRICE_TBL(px_line_index)             := p_line_Rec.UNIT_LIST_PRICE_PER_PQTY;
   G_PERCENT_PRICE_TBL(px_line_index)          := NULL;
   G_ADJUSTED_UNIT_PRICE_TBL(px_line_index)    := p_line_rec.UNIT_SELLING_PRICE_PER_PQTY;
   G_PROCESSED_FLAG_TBL(px_line_index)         := QP_PREQ_GRP.G_NOT_PROCESSED;
   G_PRICE_FLAG_TBL(px_line_index)             := nvl(p_line_rec.CALCULATE_PRICE_FLAG,'Y');
   G_LINE_ID_TBL(px_line_index)                := p_line_rec.LINE_ID;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE ID IN G_LINE_ID_TBL:'|| G_LINE_ID_TBL ( PX_LINE_INDEX ) ) ;
   END IF;
   G_ROUNDING_FLAG_TBL(px_line_index)          := 'Q';
   G_ROUNDING_FACTOR_TBL(px_line_index)        := NULL;
   G_PROCESSING_ORDER_TBL(px_line_index)       := NULL;
   G_PRICING_STATUS_CODE_tbl(px_line_index)    := QP_PREQ_GRP.G_STATUS_UNCHANGED;  -- AG
   G_PRICING_STATUS_TEXT_tbl(px_line_index)    := NULL;
G_QUALIFIERS_EXIST_FLAG_TBL(px_line_index)            :='N';
 G_PRICING_ATTRS_EXIST_FLAG_TBL(px_line_index)       :='N';
 G_PRICE_LIST_ID_TBL(px_line_index)                 :=p_line_rec.price_list_id;
 G_PL_VALIDATED_FLAG_TBL(px_line_index)                := 'N';
 G_PRICE_REQUEST_CODE_TBL(px_line_index)        := p_line_rec.price_request_code;
 G_USAGE_PRICING_TYPE_TBL(px_line_index)        :='REGULAR';
G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_line_index) :=NULL;
G_LINE_CATEGORY_TBL(px_line_index) := p_line_rec.line_category_code;
   G_catchweight_qty_tbl(px_line_index) := NULL;
   g_actual_order_qty_tbl(px_line_index):= NULL;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXISTING OE_ORDER_PRICE_PVT.COPY_LINE_TO_REQUEST' , 1 ) ;
        END IF;

end copy_Line_to_request;

Procedure Insert_lines(
                p_Header_Rec            IN        OE_ORDER_PUB.Header_Rec_Type
	      ,	px_Line_Tbl	        IN OUT NOCOPY   OE_ORDER_PUB.Line_Tbl_Type
              , p_order_status_rec      QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE
              , p_pricing_events        IN VARCHAR2
) IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_pass_line_flag VARCHAR2(1);
l_check_line_flag VARCHAR2(1);
l_source_line_flag VARCHAR2(1);
l_line_rec OE_ORDER_PUB.Line_Rec_Type;
i pls_integer;
l_line_index PLS_INTEGER := 0;

BEGIN
  i := px_Line_Tbl.FIRST;
  While i is Not Null Loop
    l_line_rec := px_Line_Tbl(i);
   IF (l_line_rec.PRICING_DATE = FND_API.G_MISS_DATE) THEN
       l_line_Rec.PRICING_DATE := sysdate;
   END IF;

   IF (l_line_rec.UNIT_LIST_PRICE_PER_PQTY = FND_API.G_MISS_NUM) THEN
    IF (l_line_rec.UNIT_LIST_PRICE = FND_API.G_MISS_NUM) THEN
      l_line_Rec.UNIT_LIST_PRICE := NULL;
    END IF;
    l_line_Rec.UNIT_LIST_PRICE_PER_PQTY := l_line_rec.UNIT_LIST_PRICE;
   END IF;
   If (l_line_rec.calculate_price_Flag is null or l_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR) THEN
     l_line_rec.calculate_price_flag := 'Y';
   End IF;

   If (l_line_rec.operation is null or l_line_rec.operation = FND_API.G_MISS_CHAR) THEN
     l_line_rec.operation := oe_globals.g_opr_create;
   End IF;

    l_pass_line_flag := 'N';
    l_check_line_flag := 'N';
    l_source_line_flag := 'N';
    IF (l_line_rec.calculate_price_flag = 'N' AND p_order_status_rec.summary_line_flag = 'Y')
    THEN
      l_pass_line_flag := 'Y';
    ELSIF l_line_rec.calculate_price_flag <> 'N'
    THEN
      IF (p_order_status_rec.changed_lines_flag = 'Y' AND (
              l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
           OR l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
       )
      THEN
        l_source_line_flag := 'Y';
        l_pass_line_flag := 'Y';
      ELSIF (p_order_status_rec.all_lines_flag = 'Y' AND
             l_line_rec.operation <> OE_GLOBALS.G_OPR_DELETE)
      THEN
        l_check_line_flag := 'Y';
        l_source_line_flag := 'Y';
      END IF;
    END IF;

    IF (l_source_line_flag = 'Y')
    THEN

                     OE_ORDER_PUB.g_line := l_line_rec;
                     QP_Attr_Mapping_PUB.Build_Contexts(
                           p_request_type_code => 'ONT',
                           --p_line_index => l_line_index,
                          p_line_index => l_line_rec.header_id
                            +l_line_rec.line_id,
                           p_pricing_type_code       =>      'L',
                           p_check_line_flag         => l_check_line_flag,
                           p_pricing_event           => p_pricing_events,
                           x_pass_line               => l_pass_line_flag
                           );
    END IF;

    IF (l_pass_line_flag = 'Y')
    THEN
                       copy_Line_to_request(
                           p_Line_rec                   => l_line_rec
                           ,p_pricing_events            => p_pricing_events
                           ,p_request_type_code         => 'ONT'
                           ,p_honor_price_flag    => 'Y'
                           ,px_line_index       => l_line_index
                           );

    G_PASS_LINE_TBL(l_line_rec.line_id) := l_line_rec.line_id;
    END IF;

  i := px_line_tbl.next(i);
  END LOOP;

                QP_Attr_Mapping_PUB.Build_Contexts(
                        p_request_type_code => 'ONT',
                        p_line_index=>oe_order_pub.g_hdr.header_id,
                        p_pricing_type_code  =>      'H'
                        );


                       copy_header_to_request(
                           p_Header_rec                   => p_Header_Rec
                           ,p_request_type_code         => 'ONT'
                           ,p_calculate_price_flag    => 'Y'
                           ,px_line_index       => l_line_index
                           );

END Insert_Lines;


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
                 p_catchweight_qty     =>    G_CATCHWEIGHT_QTY_tbl,
                 p_actual_order_qty    =>    G_ACTUAL_ORDER_QTY_TBL,
                 x_status_code         =>l_return_status,
                 x_status_text         =>l_return_status_text);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'WRONG IN INSERT_LINES2'||L_RETURN_STATUS_TEXT , 1 ) ;
            END IF;
                 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERROR');
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
                 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERROR');
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


/*+--------------------------------------------------------------------
  |Reset_All_Tbls
  |To Reset all pl/sql tables.
  +--------------------------------------------------------------------
*/
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

procedure Report_Engine_Errors(
x_return_status out nocopy Varchar2
,  px_line_Tbl		in out  NOCOPY   oe_Order_Pub.Line_Tbl_Type
,  p_header_rec	        IN	   oe_Order_Pub.header_rec_type
)
is
l_line_rec				oe_order_pub.line_rec_type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
i						pls_Integer;
j						pls_Integer:=0;
l_price_list				Varchar2(240);
l_allow_negative_price		Varchar2(30) := nvl(fnd_profile.value('ONT_NEGATIVE_PRICING'),'N');
l_invalid_line Varchar2(1):='N';
l_temp_line_rec oe_order_pub.line_rec_type;
l_request_id NUMBER;
vmsg                       Varchar2(2000);

cursor wrong_lines is
  select   line_id
         , line_index
         , line_type_code
         , processed_code
         , pricing_status_code
         , pricing_status_text status_text
         , unit_price
         , adjusted_unit_price
         , priced_quantity
         , line_quantity
         , priced_uom_code
   from qp_preq_lines_tmp
   where process_status <> 'NOT_VALID' and
     (pricing_status_code not in
     (QP_PREQ_GRP.G_STATUS_UNCHANGED,
      QP_PREQ_GRP.G_STATUS_UPDATED,
      QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
      'NOT_VALID')
  OR (l_allow_negative_price = 'N' AND (unit_price<0 OR adjusted_unit_price<0)));
cursor wrong_book_lines is
  select lines.line_id
       , lines.unit_price
       , lines.adjusted_unit_price
       , lines.price_list_header_id
       , lines.priced_quantity
       , lines.line_quantity
       , l.shipped_quantity
       , l.header_id
  from oe_order_lines l
     , qp_preq_lines_tmp lines
  where lines.line_id = l.line_id
   and lines.line_type_code='LINE'
   and l.booked_flag = 'Y'
   and l.item_type_code NOT IN ('INCLUDED','CONFIG')
   and (lines.unit_price is NULL
   or lines.adjusted_unit_price is NULL
   or lines.price_list_header_id is NULL)
   and lines.process_status <> 'NOT_VALID'
   ;
   -- Bug 2079138: booked lines should always have price
   --and lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_UPDATED
   --                              , QP_PREQ_GRP.G_STATUS_GSA_VIOLATION
   --                                  );
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
begin
-- Update Order Lines
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.REPORT_ENGINE_ERROR' , 1 ) ;
	END IF;
	G_STMT_NO := 'Report_Engine_Error#10';

   For wrong_line in wrong_lines loop  --i:=  p_req_line_tbl.first;

		J:= px_Line_Tbl.First;
		While J is not null loop
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ERROR '||J||' LINE'||PX_LINE_TBL ( J ) .LINE_ID||' '||WRONG_LINE.LINE_ID ) ;
                  END IF;
		If px_Line_Tbl(j).line_id = wrong_line.line_id
                    --or
		--		J = wrong_line.line_index
                 then
			l_line_rec := px_Line_Tbl(J);
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'PRICE'||L_LINE_REC.UNIT_LIST_PRICE||'+'||L_LINE_REC.UNIT_LIST_PRICE_PER_PQTY ) ;
                        END IF;
			exit;
			End if;
			J:= px_Line_Tbl.next(j);
		end loop;

 OE_MSG_PUB.set_msg_context
      			( p_entity_code                => 'LINE'
         		,p_entity_id                   => l_line_rec.line_id
         		,p_header_id                   => l_line_rec.header_id
         		,p_line_id                     => l_line_rec.line_id
                        ,p_order_source_id             => l_line_rec.order_source_id
                        ,p_orig_sys_document_ref       => l_line_rec.orig_sys_document_ref
                        ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref
                        ,p_orig_sys_shipment_ref       => l_line_rec.orig_sys_shipment_ref
                        ,p_change_sequence             => l_line_rec.change_sequence
                        ,p_source_document_type_id     => l_line_rec.source_document_type_id
                        ,p_source_document_id          => l_line_rec.source_document_id
                        ,p_source_document_line_id     => l_line_rec.source_document_line_id
         		);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'THE STATUS'||WRONG_LINE.PRICING_STATUS_CODE||':'||WRONG_LINE.PROCESSED_CODE||':'||WRONG_LINE.STATUS_TEXT ) ;
	END IF;
        l_invalid_line := 'N';
     -- add message when the price list is found to be inactive
	IF wrong_line.line_Type_code ='LINE' and
		wrong_line.processed_code = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND Then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'PRICE LIST NOT FOUND' ) ;
		 	END IF;
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'LINDA , INVALID PRICE LIST ' , 1 ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_NO_PRICE_LIST_FOUND');
		 	FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 	FND_MESSAGE.SET_TOKEN('UOM',l_line_rec.Order_Quantity_uom);
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
        if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
  else
		  	OE_MSG_PUB.Add;
  end if;

           l_invalid_line := 'Y';
        END IF;

	if wrong_line.line_Type_code ='LINE' and
  	  wrong_line.pricing_status_code in ( QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST,
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

                 l_invalid_line := 'Y';
		 Begin
			Select name into l_price_list
			from qp_list_headers_vl where
			list_header_id = l_line_rec.price_list_id;
			Exception When No_data_found then
			l_price_list := l_line_rec.price_list_id;
		 End;

		 If wrong_line.pricing_status_code  = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'INVALID ITEM/PRICE LIST COMBINATION'||L_LINE_REC.ORDERED_ITEM||L_LINE_REC.ORDER_QUANTITY_UOM||L_PRICE_LIST ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','OE_PRC_NO_LIST_PRICE');
		 	FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 	FND_MESSAGE.SET_TOKEN('UNIT',l_line_rec.Order_Quantity_uom);
		 	FND_MESSAGE.SET_TOKEN('PRICE_LIST',l_Price_List);
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
        if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
   else
		  	OE_MSG_PUB.Add;
   end if;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'BEFORE CHECKING BOOK FLAG' ) ;
                         END IF;

                         If nvl(l_line_rec.booked_flag,'X') = 'Y' Then
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  ' EXCEPTION: PRICE LIST MISSING FOR BOOKED ORDER' ) ;
                            END IF;
                            FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_ORDER_UTIL.GET_ATTRIBUTE_NAME('UNIT_LIST_PRICE'));
                            OE_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_ERROR;
                         End If;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'PRICE'||L_LINE_REC.UNIT_SELLING_PRICE||':'||L_LINE_REC.UNIT_LIST_PRICE ) ;
                        END IF;

                        --Fix bug 1650637
                        If (l_line_rec.unit_selling_price Is Not Null or
                            l_line_rec.unit_list_price Is Not Null
                           ) --AND NOT (p_control_rec.p_write_to_db)
                        THEN
                            l_line_rec.unit_selling_price := NULL;
                            l_line_rec.unit_selling_price_per_pqty := NULL;
                            l_line_rec.unit_list_price := NULL;
                            l_line_rec.unit_list_price_per_pqty := NULL;
                        END IF;


		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND Then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'PRICE LIST NOT FOUND' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_NO_PRICE_LIST_FOUND');
		 	FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 	FND_MESSAGE.SET_TOKEN('UOM',l_line_rec.Order_Quantity_uom);
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
   else
		  	OE_MSG_PUB.Add;
   end if;
		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_FORMULA_ERROR then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'ERROR IN FORMULA PROCESSING' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_ERROR_IN_FORMULA');
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',wrong_line.status_text);
     IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
        if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
     else
		  	OE_MSG_PUB.Add;
     end if;
		Elsif wrong_line.pricing_status_code in
				( QP_PREQ_GRP.G_STATUS_OTHER_ERRORS , FND_API.G_RET_STS_UNEXP_ERROR,
						FND_API.G_RET_STS_ERROR)
		then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'OTHER ERRORS PROCESSING' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERROR');
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',wrong_line.status_text);
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
         if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
    else
		  	OE_MSG_PUB.Add;
    end if;
		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'INVALID UOM' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_UOM');
		 	FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 	FND_MESSAGE.SET_TOKEN('UOM',l_line_rec.Order_Quantity_uom);
     IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
     else
		  	OE_MSG_PUB.Add;
     end if;
		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'DUPLICATE PRICE LIST' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_DUPLICATE_PRICE_LIST');

		 	Begin
				Select name into l_price_list
				from qp_list_headers_vl a,qp_list_lines b where
				b.list_line_id =  to_number(substr(wrong_line.status_text,1,
									instr(wrong_line.status_text,',')-1))
				and a.list_header_id=b.list_header_id
				;
				Exception When No_data_found then
				l_price_list := to_number(substr(wrong_line.status_text,1,
								instr(wrong_line.status_text,',')-1));
				When invalid_number then
				l_price_list := substr(wrong_line.status_text,1,
								instr(wrong_line.status_text,',')-1);

		 	End;

		 	FND_MESSAGE.SET_TOKEN('PRICE_LIST1',
                      '( '||l_line_rec.Ordered_Item||' ) '||l_price_list);
		 	Begin
				Select name into l_price_list
				from qp_list_headers_vl a,qp_list_lines b where
				b.list_line_id =
                     to_number(substr(wrong_line.status_text,
                         instr(wrong_line.status_text,',')+1))
				and a.list_header_id=b.list_header_id	;
				Exception When No_data_found then
				l_price_list := to_number(substr(wrong_line.status_text,
						instr(wrong_line.status_text,',')+1));
				When invalid_number then
				l_price_list := substr(wrong_line.status_text,
								instr(wrong_line.status_text,',')+1);
		 	End;
		 	FND_MESSAGE.SET_TOKEN('PRICE_LIST2',l_price_list);
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
    else
		  	OE_MSG_PUB.Add;
    end if;
		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'INVALID UOM CONVERSION' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_UOM_CONVERSION');
		 	FND_MESSAGE.SET_TOKEN('UOM_TEXT','( '||l_line_rec.Ordered_Item||' ) '||
													wrong_line.status_text);
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
   else
		  	OE_MSG_PUB.Add;
   end if;
		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_INVALID_INCOMP then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'UNABLE TO RESOLVE INCOMPATIBILITY' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_INVALID_INCOMP');
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '||
                    l_line_rec.Ordered_Item||' ) '||wrong_line.status_text);
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
      if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
    else
		  	OE_MSG_PUB.Add;
    end if;
		Elsif wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR then
		 	IF l_debug_level  > 0 THEN
		 	    oe_debug_pub.add(  'ERROR WHILE EVALUATING THE BEST PRICE' ) ;
		 	END IF;
		 	FND_MESSAGE.SET_NAME('ONT','ONT_PRC_BEST_PRICE_ERROR');
		 	FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 	FND_MESSAGE.SET_TOKEN('ERR_TEXT',wrong_line.status_text);
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if l_line_rec.shipped_quantity is not null and l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM then
                        vmsg := FND_MESSAGE.GET;
       else
           OE_MSG_PUB.Add;
       end if;
   else
		  	OE_MSG_PUB.Add;
   end if;
		End if; /* wrong pricing status code */

		 --RAISE FND_API.G_EXC_ERROR;
                 --btea begin if do not write to db, we still need to
                 --return line and status code to the caller
--                 If Not p_control_rec.p_write_to_db Then
                   l_line_rec.Header_id := p_header_rec.Header_id;
                   l_line_rec.line_id := wrong_line.line_id;
                   l_line_rec.unit_selling_price_per_pqty
                     := wrong_line.adjusted_unit_price ;
                   l_line_rec.unit_list_price_per_pqty
                     := wrong_line.unit_price ;
                   l_line_rec.pricing_quantity
                     := wrong_line.priced_quantity ;
                   l_line_rec.pricing_quantity_uom
                     := wrong_line.priced_uom_code ;
                 --use industry_attribute30 as the place holder to hold error status
                 --since the line_rec doesn't have the place holder to hold error status
                   l_line_rec.industry_attribute30
                     := wrong_line.pricing_status_code;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'J IS '||J ) ;
                   END IF;
                   if (j<>0) THEN
                     px_line_tbl(j) := l_line_rec;
                   END IF;

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'PASSING BACK PRICE'||L_LINE_REC.UNIT_LIST_PRICE||' '||L_LINE_REC.UNIT_SELLING_PRICE ) ;
                   END IF;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'LINE'||L_LINE_REC.HEADER_ID||'+'||L_LINE_REC.LINE_ID ) ;
                   END IF;
  --               End If;
                 --btea end

	elsif
	   wrong_line.line_Type_code ='LINE' and
	  wrong_line.pricing_status_code = QP_PREQ_GRP.G_STATUS_OTHER_ERRORS
	Then

		  	FND_MESSAGE.SET_NAME('ONT','OE_PRICING_ERROR');
		  	FND_MESSAGE.SET_TOKEN('ERR_TEXT','( '
            ||l_line_rec.Ordered_Item||' ) '||wrong_line.status_text);
		  	OE_MSG_PUB.Add;
        elsif wrong_line.line_type_code='LINE' and
        (wrong_line.unit_price <0 or wrong_line.adjusted_unit_price<0)
        Then

		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  'NEGATIVE LIST PRICE '||WRONG_LINE.UNIT_PRICE ||'OR SELLING PRICE '||WRONG_LINE.ADJUSTED_UNIT_PRICE ) ;
		 END IF;
		 FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_PRICE');
		 FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.Ordered_Item,l_line_rec.inventory_item_id));
		 FND_MESSAGE.SET_TOKEN('LIST_PRICE',wrong_line.unit_price);
		 FND_MESSAGE.SET_TOKEN('SELLING_PRICE',wrong_line.Adjusted_unit_price);
		  OE_MSG_PUB.Add;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'BEFORE SHOWING NEGATIVE MODIFIERS MESSAGE' ) ;
                   END IF;
                 FND_MESSAGE.SET_NAME('ONT','ONT_NEGATIVE_MODIFIERS');
                 --FND_MESSAGE.SET_TOKEN('LIST_LINE_NO',get_list_lines(wrong_line.line_id));
                 OE_MSG_PUB.Add;
                 IF l_debug_level  > 0 THEN
                    -- oe_debug_pub.add(  'MODIFIERS:'||GET_LIST_LINES ( WRONG_LINE.LINE_ID ) ) ;
                     NULL;
                 END IF;
		 RAISE FND_API.G_EXC_ERROR;

        end if;

     end loop;  /* wrong_lines cursor */

For book_line in wrong_book_lines loop

  If book_line.adjusted_unit_price IS NULL Then
     FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
     OE_MSG_PUB.ADD;
  End If;

 If book_line.unit_price IS NULL
 Then
     FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' ERROR: UNIT LIST PRICE CAN NOT BE NULL' ) ;
       END IF;
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       if book_line.shipped_quantity is not null or book_line.shipped_quantity <> FND_API.G_MISS_NUM then
        vmsg := FND_MESSAGE.GET;
--        pricing_errors_hold(book_line.header_id,book_line.line_id,vmsg);
       else
        OE_MSG_PUB.ADD;
        l_temp_line_rec.line_id := book_line.line_id;
        l_temp_line_rec.ordered_quantity := book_line.line_quantity;
        l_temp_line_rec.pricing_quantity := book_line.priced_quantity;
        --Oe_Order_Adj_Pvt.Reset_Fields(l_temp_line_rec);
         RAISE FND_API.G_EXC_ERROR;
       end if;
      else
       OE_MSG_PUB.ADD;
      end if;
  End If;

  If book_line.price_list_header_id IS NULL Then
       FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRUIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_ORDER_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
       OE_MSG_PUB.ADD;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' ERROR: PRICE LIST ID CAN NOT BE NULL' ) ;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

End loop; /* wrong booked lines */
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING REPORT_ENGINE_ERRORS' ) ;
     END IF;
End Report_Engine_Errors;

Procedure Calculate_Adjustments(
		 px_Header_Rec        	IN OUT NOCOPY   OE_ORDER_PUB.Header_Rec_Type
		,px_Line_Tbl	        IN OUT NOCOPY   OE_ORDER_PUB.Line_Tbl_Type
                ,px_Line_Adj_Tbl        IN OUT NOCOPY   OE_ORDER_PUB.Line_Adj_Tbl_Type
                ,p_Line_Price_Att_Tbl   IN                Price_Att_Tbl_Type
                ,p_Action_Code          IN VARCHAR2 DEFAULT 'NONE'
                ,p_Pricing_Events       IN VARCHAR2
                ,p_Simulation_Flag      IN VARCHAR2
                ,p_Get_Freight_Flag     IN VARCHAR2
                ,x_Return_Status        OUT NOCOPY VARCHAR2 )
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
BEGIN


  Reset_All_Tbls;

  -- call QP API to determine whether or not to
  -- call lines to pricing engine
  QP_UTIL_PUB.Get_Order_Lines_Status(p_pricing_events,l_order_status_rec);

  If l_order_status_rec.ALL_LINES_FLAG = 'Y' OR l_order_status_rec.CHANGED_LINES_FLAG = 'Y'
  OR l_order_status_rec.SUMMARY_LINE_FLAG = 'Y'
  Then
    Insert_Lines( px_Header_Rec
                , px_Line_Tbl
                , l_order_status_rec
                , p_Pricing_Events);

    -- insert manual adjustments
    Insert_Manual_Adj(px_Line_Adj_Tbl);

  Populate_Temp_Table;
  End if;

END Calculate_Adjustments;

Procedure Process_Adjustments(px_line_adj_tbl IN OUT NOCOPY oe_order_pub.line_adj_tbl_type
)
Is
i PLS_INTEGER;
Cursor adj_cur IS
SELECT     /*+ ORDERED USE_NL(ldets lines qh) */
            oe_price_adjustments_s.nextval price_adjustment_id
    ,       oe_order_pub.g_hdr.header_id header_id
    ,       ldets.automatic_flag automatic_flag
    ,       decode(ldets.modifier_level_code,'ORDER',NULL,lines.line_id) line_id
    ,	  ldets.LIST_HEADER_ID list_header_id
    ,	  ldets.LIST_LINE_ID list_line_id
    ,	  ldets.LIST_LINE_TYPE_CODE list_line_type_code
    ,	  NULL MODIFIER_MECHANISM_TYPE_CODE
    ,     decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL) modified_from
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to, 'IUE', to_char(ldets.related_item_id), NULL) modified_to
    ,	  ldets.UPDATED_FLAG
    ,	  ldets.override_flag update_allowed
    ,	  ldets.APPLIED_FLAG applied_flag
    ,	  NULL CHANGE_REASON_CODE
    ,	  NULL CHANGE_REASON_TEXT
    ,	  ldets.order_qty_operand operand
    ,	  ldets.operand_calculation_code arithmetic_operator
    ,	  nvl(ldets.order_qty_adj_amt, 99) adjusted_amount
    ,	  ldets.pricing_phase_id PRICING_PHASE_ID
    ,	  ldets.CHARGE_TYPE_CODE charge_type_code
    ,	  ldets.CHARGE_SUBTYPE_CODE charge_subtype_code
    ,       ldets.list_line_no list_line_no
    ,       qh.source_system_code source_system_code
    ,       ldets.benefit_qty benefit_qty
    ,       ldets.benefit_uom_code benefit_uom_code
    ,       ldets.expiration_date expiration_date
    ,       ldets.rebate_transaction_type_code rebate_transaction_Type_code
    ,       ldets.accrual_flag accrual_flag
    ,       ldets.line_quantity  range_break_quantity
    ,       ldets.accrual_conversion_rate accrual_conversion_rate
    ,       ldets.pricing_group_sequence pricing_group_sequence
    ,       ldets.modifier_level_code modifier_level_code
    ,       ldets.price_break_type_code price_break_type_code
    ,       ldets.substitution_attribute substitution_attribute
    ,       ldets.proration_type_code  proration_type_code
    ,       ldets.include_on_returns_flag include_on_returns_flag
    ,       ldets.OPERAND_value operand_per_pqty
    ,       ldets.adjustment_amount adjusted_amount_per_pqty
    FROM
         QP_LDETS_v ldets
    ,    QP_PREQ_LINES_TMP lines
    ,    QP_LIST_HEADERS_B QH
    WHERE
         ldets.list_header_id=qh.list_header_id
    AND  ldets.process_code in (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_UNCHANGED)
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    AND lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index
    --AND  ldets.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    --AND  nvl(ldets.automatic_flag,'N') = 'Y'
     --     or
     --     (ldets.list_line_type_code = 'FREIGHT_CHARGE'))
    AND ldets.created_from_list_type_code not in ('PRL','AGR')
    AND  ldets.list_line_type_code<>'PLL'
--    AND (l_booked_flag = 'N' or ldets.list_line_type_code<>'IUE')
;
l_adj_tbl OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
BEGIN
  -- Populating QP line details table

  -- Populating pricing attributes and ask for promotion/coupons

 -- i := px_line_adj_Tbl.first;
  --while i is not null loop
   i := 0;
   For adj in adj_cur loop
    i := i + 1;
    l_adj_tbl(i).price_adjustment_id := adj.price_adjustment_id;
    l_adj_tbl(i).HEADER_ID := adj.header_id;
    l_adj_tbl(i).AUTOMATIC_FLAG := adj.automatic_flag;
    l_adj_tbl(i).LINE_ID := adj.line_id;
    l_adj_tbl(i).LIST_HEADER_ID := adj.list_header_id;
    l_adj_tbl(i).LIST_LINE_ID := adj.list_line_id;
    l_adj_tbl(i).LIST_LINE_TYPE_CODE := adj.list_line_type_code;
    l_adj_tbl(i).MODIFIER_MECHANISM_TYPE_CODE := adj.modifier_mechanism_type_code;
    l_adj_tbl(i).MODIFIED_FROM := adj.modified_from;
    l_adj_tbl(i).MODIFIED_TO := adj.modified_to;
    l_adj_tbl(i).UPDATED_FLAG := adj.updated_Flag;
    l_adj_tbl(i).UPDATE_ALLOWED := adj.update_allowed;
    l_adj_tbl(i).APPLIED_FLAG := adj.applied_flag;
    l_adj_tbl(i).CHANGE_REASON_CODE := adj.change_reason_code;
    l_adj_tbl(i).CHANGE_REASON_TEXT := adj.change_reason_text;
    l_adj_tbl(i).operand := adj.operand;
    l_adj_tbl(i).Arithmetic_operator := adj.arithmetic_operator;
    l_adj_tbl(i).ADJUSTED_AMOUNT := adj.adjusted_amount;
    l_adj_tbl(i).PRICING_PHASE_ID := adj.pricing_phase_id;
    l_adj_tbl(i).CHARGE_TYPE_CODE := adj.charge_type_code;
    l_adj_tbl(i).CHARGE_SUBTYPE_CODE := adj.charge_subtype_code;
    l_adj_tbl(i).list_line_no := adj.list_line_no;
    l_adj_tbl(i).source_system_code := adj.source_system_code;
    l_adj_tbl(i).benefit_qty := adj.benefit_qty;
    l_adj_tbl(i).benefit_uom_code := adj.benefit_uom_code;
--    l_adj_tbl(i).print_on_invoice_flag :=adj.print_on_invoice_flag;
    l_adj_tbl(i).expiration_date := adj.expiration_date;
--    l_adj_tbl(i).rebate_transaction_type_code := adj.rebate_transaction_type_code;
--    l_adj_tbl(i).rebate_transaction_reference := adj.rebate_transaction_reference;
--    l_adj_tbl(i).rebate_payment_system_code := adj.rebate_payment_system_code;
--    l_adj_tbl(i).redeemed_date
--    l_adj_tbl(i).redeemed_flag
    l_adj_tbl(i).accrual_flag := adj.accrual_flag;
    l_adj_tbl(i).range_break_quantity         := adj.range_break_quantity;
    l_adj_tbl(i).accrual_conversion_rate     := adj.accrual_conversion_rate;
    l_adj_tbl(i).pricing_group_sequence     :=adj.pricing_group_sequence;
    l_adj_tbl(i).modifier_level_code       := adj.modifier_level_code;
    l_adj_tbl(i).price_break_type_code    := adj.price_break_type_code;
--    l_adj_tbl(i).substitution_attribute
--    l_adj_tbl(i).proration_type_code
--    ,l_adj_tbl(i).CREDIT_OR_CHARGE_FLAG
--    ,l_adj_tbl(i).INCLUDE_ON_RETURNS_FLAG
    l_adj_tbl(i).OPERAND_PER_PQTY := adj.operand_per_pqty;
    l_adj_tbl(i).ADJUSTED_AMOUNT_PER_PQTY := adj.adjusted_amount_per_pqty;
--    ,l_adj_tbl(i).LOCK_CONTROL*/
    IF (l_adj_tbl(i).list_header_id IS NOT NULL) THEN
      SELECT name
      INTO l_adj_tbl(i).attribute1
     from qp_list_headers_vl
      where list_header_id = l_adj_tbl(i).list_header_id;
    END IF;

    IF (l_adj_tbl(i).arithmetic_operator IS NOT NULL) THEN
      SELECT meaning
      into l_adj_tbl(i).attribute2
      from qp_lookups
      where lookup_code = l_adj_tbl(i).arithmetic_operator
      and lookup_type = 'ARITHMETIC_OPERATOR';
    END IF;

    IF (l_adj_tbl(i).list_line_type_code IS NOT NULL) THEN
      SELECT meaning
      into l_adj_tbl(i).attribute3
     from qp_lookups
      where lookup_code = l_adj_tbl(i).list_line_type_code
      and lookup_type = 'LIST_LINE_TYPE_CODE';
    END IF;

    IF (l_adj_tbl(i).pricing_phase_id IS NOT NULL) THEN
      SELECT name
      into l_adj_tbl(i).attribute4
      from qp_pricing_phases
      where pricing_phase_id = l_adj_tbl(i).pricing_phase_id;
    END IF;

    IF (l_adj_tbl(i).automatic_flag IS NOT NULL) THEN
      SELECT meaning
      into l_adj_tbl(i).attribute5
     from qp_lookups
      where lookup_code = l_adj_tbl(i).automatic_flag
      and lookup_type = 'YES_NO';
    END IF;

 -- i := px_line_adj_tbl.next(i);
  end loop;
  px_line_adj_tbl := l_adj_tbl;

/*	Exception
          WHEN FND_API.G_EXC_ERROR THEN

                   --reseting global structure after engine call
                OE_Order_PUB.G_LINE := NULL;
                OE_Order_PUB.G_HDR  := NULL;
	    x_return_status := FND_API.G_RET_STS_ERROR;

	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'EXITING PRICE_LINE WITH EXC ERROR' , 1 ) ;
	    END IF;
            RAISE FND_API.G_EXC_ERROR;
	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                   --reseting global structure after engine call
                OE_Order_PUB.G_LINE := NULL;
                OE_Order_PUB.G_HDR  := NULL;
      	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'EXITING PRICE_LINE WITH UNEXPECTED ERROR' , 1 ) ;
	    END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  WHEN OTHERS THEN

	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   --reseting global structure after engine call
                OE_Order_PUB.G_LINE := NULL;
                OE_Order_PUB.G_HDR  := NULL;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'ERROR IN OE_ORDER_PRICE_PVT.PRICE_LINE' , 1 ) ;
	    END IF;
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  SQLERRM , 1 ) ;
	    END IF;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME
				,   'Price_line'
				);
			END IF;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.PRICE_LINE' , 1 ) ;
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_PRICE_ORDER_PVT.PRICE_ORDER' , 1 ) ;
   END IF;
*/
END Process_Adjustments;

Procedure Call_Pricing_Engine(
  p_Pricing_Events IN VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status_text varchar(2000);
l_control_rec QP_PREQ_GRP.control_record_type;
l_set_of_books Oe_Order_Cache.Set_Of_Books_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE QP_PREQ_PUB.PRICE_REQUEST' , 1 ) ;
	END IF;

            l_control_rec.calculate_flag := 'Y';
            l_control_rec.simulation_flag := 'Y';
            l_control_rec.pricing_event := p_Pricing_Events;
            l_control_rec.temp_table_insert_flag := 'N';
            l_control_rec.check_cust_view_flag := 'N';
            l_control_rec.request_type_code := 'ONT';
            --now pricing take care of all the roundings.
            l_control_rec.rounding_flag := 'Q';
            --For multi_currency price list
            l_control_rec.use_multi_currency:='Y';
            l_control_rec.USER_CONVERSION_RATE:= OE_ORDER_PUB.G_HDR.CONVERSION_RATE;
            l_control_rec.USER_CONVERSION_TYPE:= OE_ORDER_PUB.G_HDR.CONVERSION_TYPE_CODE;
            l_set_of_books := Oe_Order_Cache.Load_Set_Of_Books;
            l_control_rec.FUNCTION_CURRENCY   := l_set_of_books.currency_code;

            -- added for freight rating.
            l_control_rec.get_freight_flag := 'N';
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('get_freight_flag before calling pricing engine is: '||l_control_rec.get_freight_flag, 3 ) ;
	    END IF;

  --            IF (G_PASS_ALL_LINES in ('N', 'R')) THEN
  --            l_control_rec.full_pricing_call := 'N';
  --          ELSE
              l_control_rec.full_pricing_call := 'Y';
  --          END IF;
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
            l_control_rec.manual_adjustments_call_flag := 'N';
  END IF;

        G_STMT_NO := 'QP_PRICE_REQUEST_GRP';
	QP_PREQ_PUB.PRICE_REQUEST
		(p_control_rec		 => l_control_rec
		--,p_line_tbl              => l_Req_line_tbl
 		--,p_qual_tbl              => l_Req_qual_tbl
  		--,p_line_attr_tbl         => l_Req_line_attr_tbl
		--,p_line_detail_tbl       =>l_req_line_detail_tbl
	 	--,p_line_detail_qual_tbl  =>l_req_line_detail_qual_tbl
	  	--,p_line_detail_attr_tbl  =>l_req_line_detail_attr_tbl
	   	--,p_related_lines_tbl     =>l_req_related_lines_tbl
		--,x_line_tbl              =>x_req_line_tbl
	   	--,x_line_qual             =>x_Req_qual_tbl
	    	--,x_line_attr_tbl         =>x_Req_line_attr_tbl
		--,x_line_detail_tbl       =>x_req_line_detail_tbl
	 	--,x_line_detail_qual_tbl  =>x_req_line_detail_qual_tbl
	  	--,x_line_detail_attr_tbl  =>x_req_line_detail_attr_tbl
	   	--,x_related_lines_tbl     =>x_req_related_lines_tbl
	    	,x_return_status         =>x_return_status
	    	,x_return_status_Text         =>l_return_status_Text
		);

              IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERROR');
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 FND_MESSAGE.SET_NAME('ONT','ONT_PRICING_ERROR');
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
	         RAISE FND_API.G_EXC_ERROR;
   	      END IF;

END Call_Pricing_Engine;

Procedure Update_Lines(px_Line_Tbl IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type)
IS
l_line_index pls_integer;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
BEGIN
  l_line_index := px_line_tbl.first;
  while l_line_index is not null loop
   l_line_rec := px_line_tbl(l_line_index);
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE ID'||L_LINE_REC.LINE_ID ) ;
   END IF;

   BEGIN

     select /*+ INDEX(lines qp_preq_lines_tmp_n1) */
      nvl(lines.order_uom_selling_price, lines.ADJUSTED_UNIT_PRICE * lines.priced_quantity /l_line_rec.ordered_quantity)
    , nvl(lines.line_unit_price, lines.UNIT_PRICE * lines.priced_quantity/l_line_rec.ordered_quantity)
    , lines.ADJUSTED_UNIT_PRICE
    , lines.UNIT_PRICE
    , decode(lines.priced_quantity,-99999,l_line_rec.ordered_quantity
              ,lines.priced_quantity)
    , decode(lines.priced_quantity,-99999,l_line_rec.order_quantity_uom
              ,lines.priced_uom_code)
    , decode(lines.price_list_header_id,-9999,NULL,lines.price_list_header_id) --Bug#2830609
    , nvl(lines.percent_price, NULL)
    , nvl(lines.parent_price, NULL)
    , decode(lines.parent_price, NULL, 0, 0, 0,
           lines.adjusted_unit_price/lines.parent_price)
    INTO
           l_line_rec.UNIT_SELLING_PRICE
         , l_line_rec.UNIT_LIST_PRICE
         , l_line_rec.UNIT_SELLING_PRICE_PER_PQTY
    , l_line_rec.UNIT_LIST_PRICE_PER_PQTY
    , l_line_rec.PRICING_QUANTITY
    , l_line_rec.PRICING_QUANTITY_UOM
    , l_line_rec.PRICE_LIST_ID
    , l_line_rec.UNIT_LIST_PERCENT
    , l_line_rec.UNIT_PERCENT_BASE_PRICE
    , l_line_rec.UNIT_SELLING_PERCENT
        from qp_preq_lines_tmp lines
       where lines.line_id=l_line_rec.line_id
       and lines.line_type_code='LINE'
       and l_line_rec.ordered_quantity <> 0
       and lines.process_status <> 'NOT_VALID'
       and lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                                  QP_PREQ_GRP.G_STATUS_UPDATED)
     ;
    EXCEPTION
      WHEN OTHERS THEN

        l_line_rec.pricing_attribute1 := SQLERRM;
    END;

    px_line_tbl(l_line_index) := l_line_rec;
    l_line_index := px_line_tbl.next(l_line_index);
   END LOOP;
END Update_Lines;

-- Price_Order is to simulate a OM pricing call to get the pricing information
-- It assumes the caller will pass all the information of the order to the call
-- For example,if your order has two lines and you only call with one line,
-- the call will price as if there is only one line
-- You can pass a line but not to reprice it by setting operation code to G_OPR_NONE
-- You can pass a line but freeze its price by setting calculate price flag to 'N'
-- This API assumes  the following setting:

--           Request_Type_Code: 'ONT'
--           Write_To_DB:       FALSE
--           Honor_Price_FLag:  TRUE
--           Calculate_flag:    TRUE
--           Simulation_Flag:   TRUE
--           Get_Freight_FLag:  FALSE
Procedure Price_Order(
		 px_Header_Rec        	IN OUT NOCOPY   OE_ORDER_PUB.Header_Rec_Type
		,px_Line_Rec            IN OUT NOCOPY   OE_ORDER_PUB.Line_Rec_Type
--		,px_Line_Tbl	        IN OUT NOCOPY   OE_ORDER_PUB.Line_Tbl_Type
                ,px_Line_Adj_Tbl        IN OUT NOCOPY   OE_ORDER_PUB.Line_Adj_Tbl_Type
                ,p_Line_Price_Att_Tbl   IN                Price_Att_Tbl_Type
                ,p_Action_Code          IN VARCHAR2 DEFAULT 'NONE'
                ,p_Pricing_Events       IN VARCHAR2
                ,p_Simulation_Flag      IN VARCHAR2
                ,p_Get_Freight_Flag     IN VARCHAR2
                ,x_Return_Status        OUT NOCOPY VARCHAR2
                ) AS
l_any_frozen_line BOOLEAN;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_header_adj_tbl OE_ORDER_PUB.Header_ADJ_Tbl_Type;
l_header_price_att_tbl OE_PRICE_ORDER_PVT.price_att_tbl_type;
l_Line_Tbl OE_ORDER_PUB.Line_Tbl_Type;
i PLS_INTEGER;
l_control_rec OE_ORDER_PRICE_PVT.Control_Rec_Type;
BEGIN


  Preprocessing(px_Header_Rec
              , px_Line_Rec);

  l_Line_Tbl(1) := px_Line_Rec;
  Calculate_Adjustments(px_Header_Rec
                       , l_Line_Tbl
                       , px_Line_Adj_Tbl
                       , p_Line_Price_Att_Tbl
                       , p_Action_Code
                       , p_Pricing_Events
                       , p_Simulation_Flag
                       , p_Get_Freight_Flag
                       , x_Return_Status);

  Call_Pricing_Engine(p_Pricing_Events, x_Return_Status);

    l_control_rec.p_write_to_db := FALSE;
    Report_Engine_Errors(x_return_status => x_Return_Status
                                           , px_line_tbl => l_line_tbl
                                           , p_header_rec  => px_header_rec);

  Update_Lines(l_Line_Tbl);
  Process_Adjustments(px_line_adj_tbl);
  px_line_rec := l_Line_Tbl(1);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (px_line_rec.unit_list_price is null) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  EXCEPTION
   WHEN OTHERS THEN

   px_line_rec.unit_list_price := 15;
   px_line_rec.unit_selling_price := 10.5;

END Price_Order;

/*  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_price_control_rec.p_write_to_db := FALSE;
  l_price_control_rec.p_multiple_events := 'Y';
  l_price_control_rec.p_use_current_header := TRUE;
  l_price_control_Rec.p_simulation_flag := nvl(p_simulation_flag, 'Y');

 l_line_tbl(1) := px_line_rec;
  amy_order_price_pvt.price_line
                 (p_Header_id    => NULL
                 ,p_Line_id             =>NULL
                 ,px_line_Tbl           =>l_line_tbl
                 ,px_header_adj_tbl     => l_header_adj_tbl
                 ,px_line_adj_tbl        => px_line_adj_tbl
                 ,p_header_price_att_tbl       => l_header_price_att_tbl
                 ,p_line_price_att_tbl       => p_line_price_att_tbl
                 ,p_Control_Rec         =>l_price_control_rec
                 ,p_action_code         =>'NONE'
                 ,p_Pricing_Events      =>p_pricing_events
                 ,x_Return_Status       =>x_return_status
                 );
  px_line_rec := l_line_tbl(1);


  -- Populating QP request lines table
  oe_order_price_pvt.calculate_adjustments(
   x_return_status 		=>  x_return_status,
   p_line_Id         		=>  NULL,
   p_header_Id			=>  NULL,
   p_pricing_events                => p_pricing_events,
   p_Control_Rec			=> l_price_control_rec,
   p_action_code                   => p_action_code,
   x_any_frozen_line        => l_any_frozen_line,
   px_line_Tbl			=> px_Line_Tbl,
   x_Header_Rec			=> lx_Header_Rec
  );
*/

end OE_PRICE_ORDER_PVT_OBSOLETE;

/
